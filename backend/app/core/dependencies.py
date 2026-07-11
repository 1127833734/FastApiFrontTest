import json
import time
from collections.abc import AsyncGenerator
from dataclasses import replace
from functools import wraps
from typing import Any

from fastapi import Depends, Query, Request
from redis.asyncio.client import Redis
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.v1.module_system.user.schema import UserOutSchema
from app.common.enums import RET, RedisInitKeyConfig
from app.config.setting import settings
from app.core.base_schema import AuthSchema
from app.core.database import async_db_session
from app.core.exceptions import CustomException
from app.core.logger import logger
from app.core.redis_crud import RedisCURD
from app.core.request_context import RequestContext
from app.core.request_context import get_current_tenant_id as _get_ctx_tenant_id
from app.core.security import OAuth2Schema, decode_access_token

# 套餐菜单权限缓存: {tenant_id: (timestamp, [menu_ids])}
_package_menu_cache: dict[int, tuple[float, list[int]]] = {}


async def db_getter() -> AsyncGenerator[AsyncSession, None]:
    """数据库会话 — 请求级生命周期管理。

    一个 HTTP 请求内所有 SQL 共享同一个事务：要么全成功，要么全失败。
    读操作也走这个事务（牺牲一点 MVCC 隔离换取读已写一致性）。
    """
    async with async_db_session() as session, session.begin():
        yield session


async def redis_getter(request: Request) -> Redis:
    """获取Redis连接

    参数:
    - request (Request): 请求对象

    返回:
    - Redis: Redis连接
    """
    return request.app.state.redis


async def get_current_tenant_id() -> int | None:
    """获取当前请求的租户 ID 依赖注入函数。

    从 ContextVar 中读取租户 ID（由 TenantMiddleware 设置）。
    非认证路径（白名单）返回 None。

    返回:
        int | None: 当前租户 ID，未设置时返回 None。
    """
    return _get_ctx_tenant_id()


async def _decode_token_info(token: str, redis: Redis) -> tuple[dict, str]:
    """解码 JWT token 返回 (user_info, session_id)

    JWT sub 现为纯 session_id，完整会话信息从 Redis 读取。

    参数:
        token: JWT token 字符串
        redis: Redis 连接

    返回:
        (user_info, session_id): 用户信息字典和会话 ID
    """
    payload = decode_access_token(token)
    if not payload or not hasattr(payload, "is_refresh") or payload.is_refresh:
        raise CustomException(msg="非法凭证", code=RET.INVALID_CREDENTIALS.code, status_code=401)

    session_id = payload.sub
    if not session_id:
        raise CustomException(msg="认证已失效", code=RET.UNAUTHORIZED.code, status_code=401)

    raw = await RedisCURD(redis).get(f"{RedisInitKeyConfig.USER_SESSION.key}:{session_id}")
    if not raw:
        raise CustomException(msg="认证已失效", code=RET.UNAUTHORIZED.code, status_code=401)

    user_info = json.loads(raw)
    return user_info, session_id


async def _check_token_online(redis: Redis, session_id: str) -> None:
    """检查 token 是否在线（Redis 中存在对应 session）

    参数:
        redis: Redis 连接
        session_id: 会话 ID
    """
    online_ok = await RedisCURD(redis).exists(key=f"{RedisInitKeyConfig.ACCESS_TOKEN.key}:{session_id}")
    if not online_ok:
        raise CustomException(msg="认证已失效", code=RET.UNAUTHORIZED.code, status_code=401)


async def _try_sliding_refresh(redis: Redis, session_id: str) -> None:
    """滑动过期续期（仅在 token 剩余不足一半时触发）

    参数:
        redis: Redis 连接
        session_id: 会话 ID
    """
    if not settings.TOKEN_SLIDING_EXPIRE:
        return

    ttl = await RedisCURD(redis).ttl(key=f"{RedisInitKeyConfig.ACCESS_TOKEN.key}:{session_id}")
    # TTL 返回秒，配置也是秒，无需转换
    expire_seconds = settings.ACCESS_TOKEN_EXPIRE_SECONDS
    if ttl > 0 and ttl < expire_seconds // 2:
        await RedisCURD(redis).expire(
            key=f"{RedisInitKeyConfig.ACCESS_TOKEN.key}:{session_id}",
            expire=expire_seconds,
        )
        await RedisCURD(redis).expire(
            key=f"{RedisInitKeyConfig.REFRESH_TOKEN.key}:{session_id}",
            expire=settings.REFRESH_TOKEN_EXPIRE_SECONDS,
        )


async def get_current_user(
    request: Request,
    db: AsyncSession = Depends(db_getter),
    redis: Redis = Depends(redis_getter),
    token: str = Depends(OAuth2Schema),
) -> AuthSchema:
    """获取当前用户

    用户查询使用独立的只读数据库会话（不参与请求事务，查询完成后立即释放快照），
    返回的 auth.db 指向请求级事务会话供后续写操作使用。

    参数:
    - request (Request): 请求对象
    - db (AsyncSession): 请求级事务会话
    - redis (Redis): Redis连接
    - token (str): 访问令牌

    返回:
    - AuthSchema: 已认证的信息模型
    """
    return await _authenticate(token, db, redis, request)


async def get_current_user_ws(
    token: str = Query(..., description="认证token"),
    db: AsyncSession = Depends(db_getter),
    redis: Redis = Depends(redis_getter),
) -> AuthSchema:
    """获取当前用户（WebSocket专用，从查询参数获取token）

    参数:
    - token (str): 认证token
    - db (AsyncSession): 数据库会话
    - redis (Redis): Redis连接

    返回:
    - AuthSchema: 已认证的信息模型
    """
    return await _authenticate(token, db, redis)


async def _authenticate(
    token: str,
    db: AsyncSession,
    redis: Redis,
    request: Request | None = None,
) -> AuthSchema:
    """核心认证逻辑（HTTP 与 WebSocket 共享）

    参数:
    - token: 访问令牌
    - db: 请求级事务会话
    - redis: Redis连接
    - request: HTTP 请求对象（WebSocket 场景为 None）

    返回:
    - AuthSchema: 认证信息模型
    """
    if not token:
        raise CustomException(msg="认证已失效", code=RET.UNAUTHORIZED.code, status_code=401)

    # 处理Bearer token
    if token.startswith("Bearer"):
        token = token.split(" ")[1]

    # 优先使用 TenantMiddleware 缓存在 request.state.ctx 中的会话信息（避免重复 Redis 读取）
    user_info = None
    if request:
        ctx = getattr(request.state, "ctx", None)
        user_info = ctx.jwt_user_info if ctx else None

    if not user_info:
        # 降级路径：自行从 Redis 读取会话信息
        user_info, _ = await _decode_token_info(token, redis)

    session_id = user_info.get("session_id")
    if not session_id:
        raise CustomException(msg="认证已失效", code=RET.UNAUTHORIZED.code, status_code=401)

    # Redis 在线检查 + 滑动续期
    await _check_token_online(redis, session_id)
    await _try_sliding_refresh(redis, session_id)

    username = user_info.get("user_name")
    if not username:
        raise CustomException(msg="认证已失效", code=RET.UNAUTHORIZED.code, status_code=401)

    user_status = user_info.get("user_status", 0)
    tenant_status = user_info.get("tenant_status", 0)
    is_superuser = user_info.get("is_superuser", False)
    tenant_id = user_info.get("tenant_id", 0)
    user_id = user_info.get("user_id")

    if user_status == 1:
        raise CustomException(msg="用户已被停用", code=RET.UNAUTHORIZED.code, status_code=401)

    from app.common.enums import TenantStatusEnum

    if not is_superuser and tenant_id > 0:
        if tenant_status == TenantStatusEnum.FROZEN:
            raise CustomException(msg="租户已被冻结，请联系平台管理员", code=RET.FORBIDDEN.code, status_code=423)
        if tenant_status == TenantStatusEnum.CANCELLED:
            raise CustomException(msg="租户已注销", code=RET.FORBIDDEN.code, status_code=423)

    if request:
        request.state.ctx = replace(
            (getattr(request.state, "ctx", None) or RequestContext()),
            user_id=user_id,
            user_username=username,
            session_id=session_id,
            session_info=user_info,
        )

    from app.api.v1.module_system.user.model import UserModel

    stmt = select(UserModel).where(UserModel.id == user_id, UserModel.is_deleted == False)
    result = await db.execute(stmt)
    user = result.scalars().first()
    if not user:
        raise CustomException(msg="用户不存在", code=RET.NOT_FOUND.code, status_code=401)

    auth = AuthSchema(check_data_scope=False, session_info=user_info, user=UserOutSchema.model_validate(user))
    return auth


async def _get_cached_tenant_menu_ids(auth: AuthSchema, tenant_id: int, db: AsyncSession) -> list[int]:
    """获取租户可用菜单 ID，带 60s 进程级缓存

    套餐菜单变更频率极低，缓存可大幅减少 AuthPermission 的 DB 查询次数。

    参数:
        auth: 认证信息
        tenant_id: 租户 ID
        db: 数据库会话

    返回:
        可用菜单 ID 列表
    """
    cached = _package_menu_cache.get(tenant_id)
    if cached and time.time() - cached[0] < 60:
        return cached[1]

    from app.api.v1.module_platform.package.service import PackageService

    result = await PackageService(auth, db).get_tenant_available_menu_ids(tenant_id)
    _package_menu_cache[tenant_id] = (time.time(), result)
    return result


class AuthPermission:
    """权限验证类"""

    def __init__(
        self,
        permissions: list[str] | None = None,
        check_data_scope: bool = True,
    ) -> None:
        """初始化权限验证

        参数:
        - permissions (list[str] | None): 权限标识列表。
        - check_data_scope (bool): 是否启用严格模式校验。
        """
        self.permissions = permissions or []
        self.check_data_scope = check_data_scope

    async def __call__(self, auth: AuthSchema = Depends(get_current_user), db: AsyncSession = Depends(db_getter)) -> AuthSchema:
        """调用权限验证

        参数:
        - auth (AuthSchema): 认证信息对象。

        返回:
        - AuthSchema: 已认证的权限信息对象。
        """
        auth = auth.model_copy(update={"check_data_scope": self.check_data_scope})

        user = auth.user
        if user.id is None or not user.is_superuser:
            return auth

        if not self.permissions:
            return auth

        if "*" in self.permissions or "*:*:*" in self.permissions:
            return auth

        user_permissions = set[Any](auth.session_info.get("permissions", [])) if auth.session_info else set()

        if not user_permissions:
            raise CustomException(msg="无权限操作", code=RET.FORBIDDEN.code, status_code=403)

        if user.tenant_id:
            allowed_ids = set[int](await _get_cached_tenant_menu_ids(auth, user.tenant_id, db))
            cached_perms = auth.session_info.get("permissions_with_menu", {}) if auth.session_info else {}
            user_permissions = {p for p, mid in cached_perms.items() if mid in allowed_ids}
        else:
            user_permissions = set[Any](auth.session_info.get("permissions", [])) if auth.session_info else set()

        if not any(perm in user_permissions for perm in self.permissions):
            logger.error(f"用户缺少任何所需的权限: {self.permissions}")
            raise CustomException(msg="无权限操作", code=10403, status_code=403)

        return auth


def require_superadmin(func):
    """装饰器：仅超级管理员可调用 Service 方法。

    自动校验 ``self.auth.user.is_superuser`` 属性，非超管直接抛出 403。
    适用于实例方法（``Service(auth).xxx(...)``），由 ``self.auth`` 取认证上下文。

    用法:
        class XxxService:
            def __init__(self, auth: AuthSchema) -> None:
                self.auth = auth

            @require_superadmin
            async def create(self, data: ...) -> ...:
                ...
    """

    @wraps(func)
    async def wrapper(self, *args, **kwargs):
        if not self.auth.user or not self.auth.user.is_superuser:
            raise CustomException(msg="仅平台管理员可操作")
        return await func(self, *args, **kwargs)

    return wrapper


class RequireTenantWrite:
    """租户写权限依赖 — 拒绝 ARREARS/TRIAL 租户的写操作。

    从 session_info 获取租户状态，无需查询数据库。

    豁免场景：
    - 平台管理员（is_superuser=True）
    - 平台管理员代签入模式（session_info.is_impersonate=True）
    """

    async def __call__(self, auth: AuthSchema = Depends(get_current_user), db: AsyncSession = Depends(db_getter)) -> AuthSchema:
        if auth.user.id is None or auth.user.is_superuser:
            return auth

        is_impersonate = auth.session_info.get("is_impersonate", False) if auth.session_info else False
        if is_impersonate:
            return auth

        from app.api.v1.module_platform.tenant.model import TenantModel
        from app.common.enums import TenantStatusEnum

        user = auth.user
        tenant = await db.get(TenantModel, user.tenant_id) if user.tenant_id else None
        tenant_status = tenant.status if tenant else 0
        if tenant_status in (TenantStatusEnum.ARREARS, TenantStatusEnum.TRIAL):
            if tenant_status == TenantStatusEnum.ARREARS:
                raise CustomException(msg="租户已欠费，仅允许查看操作，请联系平台管理员续费", code=RET.FORBIDDEN.code, status_code=423)
            if tenant_status == TenantStatusEnum.TRIAL:
                raise CustomException(msg="租户处于试用期，部分功能受限，请升级正式套餐", code=RET.FORBIDDEN.code, status_code=423)

        return auth
