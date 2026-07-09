import json
import uuid
from datetime import datetime, timedelta
from typing import NewType

import ua_parser
from fastapi import BackgroundTasks, Request
from redis.asyncio.client import Redis
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.v1.module_system.user.crud import UserCRUD
from app.api.v1.module_system.user.model import UserModel
from app.common.enums import RedisInitKeyConfig
from app.config.setting import settings
from app.core.base_schema import (
    AuthSchema,
    JWTOutSchema,
    JWTPayloadSchema,
)
from app.core.exceptions import CustomException
from app.core.logger import logger
from app.core.redis_crud import RedisCURD
from app.core.security import (
    CustomOAuth2PasswordRequestForm,
    create_access_token,
    decode_access_token,
)
from app.utils.captcha_util import CaptchaUtil
from app.utils.common_util import get_random_character
from app.utils.hash_bcrpy_util import PwdUtil
from app.utils.ip_local_util import IpLocalUtil, get_client_ip

from .schema import (
    CaptchaOutSchema,
    EnterPlatformOutSchema,
    ImpersonateOutSchema,
    LoginWithTenantsSchema,
    SelectTenantOutSchema,
    TenantOptionSchema,
    TenantRegisterOutSchema,
)

CaptchaKey = NewType("CaptchaKey", str)
CaptchaBase64 = NewType("CaptchaBase64", str)


async def _write_login_log(
    username: str,
    status: int,
    login_ip: str | None = None,
    login_location: str | None = None,
    request_os: str | None = None,
    request_browser: str | None = None,
    msg: str | None = None,
) -> int | None:
    """写入登录日志；返回日志 ID（用于后台补全归属地）。"""
    from app.api.v1.module_system.log.crud import LoginLogCRUD
    from app.api.v1.module_system.log.schema import LoginLogCreateSchema
    from app.core.database import async_db_session

    try:
        async with async_db_session() as session, session.begin():
            _auth = AuthSchema.anonymous(db=session)
            obj = await LoginLogCRUD(_auth).create(
                data=LoginLogCreateSchema(
                    username=username,
                    status=status,
                    login_ip=login_ip,
                    login_location=login_location,
                    request_os=request_os,
                    request_browser=request_browser,
                    msg=msg,
                ),
            )
            return obj.id if obj else None
    except Exception:
        return None


async def _async_fill_login_location(redis, login_log_id: int, ip: str | None) -> None:
    """后台异步补全登录日志的归属地。"""
    if not ip:
        return
    try:
        location = await IpLocalUtil.resolve_location_async(redis, ip)
        logger.info(f"异步解析IP归属地结果: ip={ip}, log_id={login_log_id}, location={location}")
        if location == "归属地查询中" or not location:
            return
        from sqlalchemy import update as sa_update

        from app.api.v1.module_system.log.model import LoginLogModel
        from app.core.database import async_db_session

        async with async_db_session() as session, session.begin():
            await session.execute(sa_update(LoginLogModel).where(LoginLogModel.id == login_log_id).values(login_location=location))
            logger.info(f"登录日志归属地已更新: log_id={login_log_id}, location={location}")
    except Exception as e:
        logger.warning(f"异步补全登录归属地失败: {e}")


class LoginService:
    """登录认证服务"""

    def __init__(self, auth: AuthSchema) -> None:
        self.auth = auth

    @classmethod
    async def authenticate_user(
        cls,
        request: Request,
        background_tasks: BackgroundTasks,
        redis: Redis,
        login_form: CustomOAuth2PasswordRequestForm,
        db: AsyncSession,
    ) -> LoginWithTenantsSchema:
        """用户认证"""
        ua_result = ua_parser.parse(request.headers.get("user-agent") or "")
        request_ip = get_client_ip(request)
        login_location = await IpLocalUtil.resolve_location_for_log(redis, request_ip)
        _login_os = ua_result.os.family if ua_result.os else "Unknown"
        _login_browser = ua_result.user_agent.family if ua_result.user_agent else "Unknown"
        _login_username = login_form.username

        referer = request.headers.get("referer", "")
        request_from_docs = referer.endswith(("docs", "redoc"))

        if settings.CAPTCHA_ENABLE and not request_from_docs:
            if not login_form.captcha_key or not login_form.captcha:
                raise CustomException(msg="验证码不能为空")
            await CaptchaService.check_captcha(
                redis=redis,
                key=login_form.captcha_key,
                captcha=login_form.captcha,
            )

        auth = AuthSchema.anonymous(db=db)
        user = await UserCRUD(auth).get(username=login_form.username)

        if not user:
            await _write_login_log(
                username=_login_username,
                status=2,
                login_ip=request_ip,
                login_location=login_location,
                request_os=_login_os,
                request_browser=_login_browser,
                msg="用户不存在",
            )
            raise CustomException(msg="用户不存在")

        if not PwdUtil.verify_password(plain_password=login_form.password, password_hash=user.password):
            await _write_login_log(
                username=_login_username,
                status=2,
                login_ip=request_ip,
                login_location=login_location,
                request_os=_login_os,
                request_browser=_login_browser,
                msg="账号或密码错误",
            )
            raise CustomException(msg="账号或密码错误")
        if user.status == 1:
            await _write_login_log(
                username=_login_username,
                status=2,
                login_ip=request_ip,
                login_location=login_location,
                request_os=_login_os,
                request_browser=_login_browser,
                msg="用户已被停用",
            )
            raise CustomException(msg="用户已被停用")

        from sqlalchemy import select

        from app.api.v1.module_platform.tenant.model import TenantModel

        tenant_stmt = select(TenantModel).where(TenantModel.id == user.tenant_id, TenantModel.status == 0, TenantModel.is_deleted.is_(False)).limit(1)
        tenant_result = await auth.db.execute(tenant_stmt)
        if not tenant_result.scalar_one_or_none():
            await _write_login_log(
                username=_login_username,
                status=2,
                login_ip=request_ip,
                login_location=login_location,
                request_os=_login_os,
                request_browser=_login_browser,
                msg="所属租户已被禁用",
            )
            raise CustomException(msg="所属租户已被禁用，请联系平台管理员")

        await UserCRUD(auth).update_last_login(id=user.id)

        if not user:
            raise CustomException(msg="用户不存在")
        if not login_form.login_type:
            raise CustomException(msg="登录类型不能为空")

        token = await cls.create_token(
            request=request,
            redis=redis,
            user=user,
            login_type=login_form.login_type,
        )

        tenants_auth = AuthSchema(db=db, user=user, check_data_scope=False)
        tenants = await LoginService(tenants_auth).get_user_tenants(user_id=user.id)

        user_info = {
            "id": user.id,
            "username": user.username,
            "name": user.name,
            "avatar": user.avatar,
            "is_superuser": user.is_superuser,
        }

        log_id = await _write_login_log(
            username=user.username,
            status=1,
            login_ip=request_ip,
            login_location=login_location,
            request_os=_login_os,
            request_browser=_login_browser,
            msg="登录成功",
        )
        # 登录成功后异步补全归属地，不阻塞返回
        if log_id and login_location == "归属地查询中":
            background_tasks.add_task(_async_fill_login_location, redis, log_id, request_ip)

        return LoginWithTenantsSchema(
            access_token=token.access_token,
            refresh_token=token.refresh_token,
            expires_in=token.expires_in,
            token_type=token.token_type,
            tenants=tenants,
            user_info=user_info,
        )

    @classmethod
    async def create_token(cls, request: Request, redis: Redis, user: UserModel, login_type: str) -> JWTOutSchema:
        """创建访问令牌和刷新令牌"""
        session_id = str(uuid.uuid4())
        ua_result = ua_parser.parse(request.headers.get("user-agent") or "")
        request_ip = get_client_ip(request)

        login_location = await IpLocalUtil.resolve_location_for_log(redis, request_ip)

        from dataclasses import replace

        from app.core.request_context import RequestContext

        base_ctx = getattr(request.state, "ctx", None) or RequestContext()
        request.state.ctx = replace(
            base_ctx,
            session_id=session_id,
            user_username=user.username,
            login_location=login_location,
        )

        access_expires = timedelta(seconds=settings.ACCESS_TOKEN_EXPIRE_SECONDS)
        refresh_expires = timedelta(seconds=settings.REFRESH_TOKEN_EXPIRE_SECONDS)

        now = datetime.now()

        tenant_status = getattr(user.tenant, "status", 0) if hasattr(user, "tenant") and user.tenant else 0

        permissions = []
        permissions_with_menu = {}
        menu_ids = []
        data_scopes = []
        custom_dept_ids = []
        if not user.is_superuser and hasattr(user, "roles"):
            for role in user.roles:
                if role and role.status == 0 and hasattr(role, "menus"):
                    for menu in role.menus:
                        if menu and menu.status == 0:
                            menu_ids.append(menu.id)
                            if menu.permission:
                                permissions.append(menu.permission)
                                permissions_with_menu[menu.permission] = menu.id
                    if hasattr(role, "data_scope"):
                        data_scopes.append(role.data_scope)
                    if hasattr(role, "depts") and role.depts:
                        for dept in role.depts:
                            if dept:
                                custom_dept_ids.append(dept.id)

        session_dict = {
            "session_id": session_id,
            "user_id": user.id,
            "tenant_id": user.tenant_id if not user.is_superuser else 0,
            "tenant_status": tenant_status,
            "is_superuser": user.is_superuser,
            "user_status": user.status,
            "name": user.name,
            "user_name": user.username,
            "dept_id": user.dept_id,
            "mobile": user.mobile,
            "email": user.email,
            "gender": user.gender,
            "avatar": user.avatar,
            "permissions": permissions,
            "permissions_with_menu": permissions_with_menu,
            "menu_ids": menu_ids,
            "data_scopes": data_scopes,
            "custom_dept_ids": custom_dept_ids,
            "ipaddr": request_ip,
            "login_location": login_location,
            "os": ua_result.os.family if ua_result.os else "Unknown",
            "browser": ua_result.user_agent.family if ua_result.user_agent else "Unknown",
            "login_time": user.last_login,
            "login_type": login_type,
        }
        session_info = json.dumps(session_dict, default=str)

        # 会话信息存 Redis（完整 JSON），JWT sub 仅含 session_id
        await RedisCURD(redis).set(
            key=f"{RedisInitKeyConfig.USER_SESSION.key}:{session_id}",
            value=session_info,
            expire=int(refresh_expires.total_seconds()),
        )

        access_token = create_access_token(
            payload=JWTPayloadSchema(
                sub=session_id,
                is_refresh=False,
                exp=now + access_expires,
            ),
        )
        refresh_token = create_access_token(
            payload=JWTPayloadSchema(
                sub=session_id,
                is_refresh=True,
                exp=now + refresh_expires,
            ),
        )

        await RedisCURD(redis).set(
            key=f"{RedisInitKeyConfig.ACCESS_TOKEN.key}:{session_id}",
            value=access_token,
            expire=int(access_expires.total_seconds()),
        )

        await RedisCURD(redis).set(
            key=f"{RedisInitKeyConfig.REFRESH_TOKEN.key}:{session_id}",
            value=refresh_token,
            expire=int(refresh_expires.total_seconds()),
        )

        return JWTOutSchema(
            access_token=access_token,
            refresh_token=refresh_token,
            expires_in=int(access_expires.total_seconds()),
            token_type=settings.TOKEN_TYPE,
        )

    @classmethod
    async def refresh_token(
        cls,
        db: AsyncSession,
        redis: Redis,
        refresh_token: str,
    ) -> JWTOutSchema:
        """刷新访问令牌"""
        token_payload: JWTPayloadSchema = decode_access_token(token=refresh_token)
        if not token_payload.is_refresh:
            raise CustomException(msg="非法凭证，请传入刷新令牌")

        session_id = token_payload.sub
        session_info = await RedisCURD(redis).get(f"{RedisInitKeyConfig.USER_SESSION.key}:{session_id}")
        if not session_info:
            raise CustomException(msg="会话已过期，请重新登录")

        user_id = json.loads(session_info).get("user_id")

        if not session_id or not user_id:
            raise CustomException(msg="非法凭证,无法获取会话编号或用户ID")

        auth = AuthSchema.anonymous(db=db)
        user = await UserCRUD(auth).get(id=user_id)
        if not user:
            raise CustomException(msg="刷新token失败，用户不存在")
        if user.status == 1:
            raise CustomException(msg="用户已被停用")

        access_expires = timedelta(seconds=settings.ACCESS_TOKEN_EXPIRE_SECONDS)
        refresh_expires = timedelta(seconds=settings.REFRESH_TOKEN_EXPIRE_SECONDS)
        now = datetime.now()

        # 延长会话信息 Redis TTL
        await RedisCURD(redis).expire(
            key=f"{RedisInitKeyConfig.USER_SESSION.key}:{session_id}",
            expire=int(refresh_expires.total_seconds()),
        )

        access_token = create_access_token(
            payload=JWTPayloadSchema(
                sub=session_id,
                is_refresh=False,
                exp=now + access_expires,
            ),
        )

        refresh_token_new = create_access_token(
            payload=JWTPayloadSchema(
                sub=session_id,
                is_refresh=True,
                exp=now + refresh_expires,
            ),
        )

        await RedisCURD(redis).set(
            key=f"{RedisInitKeyConfig.ACCESS_TOKEN.key}:{session_id}",
            value=access_token,
            expire=int(access_expires.total_seconds()),
        )

        await RedisCURD(redis).set(
            key=f"{RedisInitKeyConfig.REFRESH_TOKEN.key}:{session_id}",
            value=refresh_token_new,
            expire=int(refresh_expires.total_seconds()),
        )

        return JWTOutSchema(
            access_token=access_token,
            refresh_token=refresh_token_new,
            token_type=settings.TOKEN_TYPE,
            expires_in=int(access_expires.total_seconds()),
        )

    @staticmethod
    async def logout(redis: Redis, token: str) -> bool:
        """退出登录"""
        payload: JWTPayloadSchema = decode_access_token(token=token)
        session_id = payload.sub

        if not session_id:
            raise CustomException(msg="非法凭证,无法获取会话编号")

        await RedisCURD(redis).delete(f"{RedisInitKeyConfig.ACCESS_TOKEN.key}:{session_id}")
        await RedisCURD(redis).delete(f"{RedisInitKeyConfig.REFRESH_TOKEN.key}:{session_id}")
        await RedisCURD(redis).delete(f"{RedisInitKeyConfig.USER_SESSION.key}:{session_id}")

        logger.info(f"用户退出登录成功,会话编号:{session_id}")

        return True

    async def get_user_tenants(
        self,
        user_id: int | None = None,
    ) -> list[TenantOptionSchema]:
        """获取用户关联的租户列表"""
        from sqlalchemy import select

        from app.api.v1.module_platform.tenant.model import TenantModel, TenantUserModel

        user = self.auth.user
        if not user:
            raise CustomException(msg="未认证用户")

        uid = user_id or user.id
        if not uid:
            return []

        if user.is_superuser:
            stmt = select(TenantModel).where(TenantModel.status == 0, TenantModel.is_deleted.is_(False)).order_by(TenantModel.sort, TenantModel.id)
            result = await self.auth.db.execute(stmt)
            tenant_objs = result.scalars().all()
            return [TenantOptionSchema(id=t.id, name=t.name, code=t.code) for t in tenant_objs]

        stmt = (
            select(TenantModel)
            .join(TenantUserModel, TenantUserModel.tenant_id == TenantModel.id)
            .where(
                TenantUserModel.user_id == uid,
                TenantModel.status == 0,
                TenantModel.is_deleted.is_(False),
            )
            .order_by(TenantUserModel.is_default.desc(), TenantModel.sort, TenantModel.id)
        )
        result = await self.auth.db.execute(stmt)
        tenant_objs = result.scalars().all()
        return [TenantOptionSchema(id=t.id, name=t.name, code=t.code) for t in tenant_objs]

    async def select_tenant(
        self,
        request: Request,
        redis: Redis,
        tenant_id: int,
    ) -> SelectTenantOutSchema:
        """选择租户：验证用户归属并签发含租户上下文的新 JWT Token"""
        from sqlalchemy import select

        from app.api.v1.module_platform.tenant.model import TenantModel, TenantUserModel

        user = self.auth.user
        if not user:
            raise CustomException(msg="未认证用户")

        if not user.is_superuser:
            exist_stmt = (
                select(TenantUserModel)
                .where(
                    TenantUserModel.user_id == user.id,
                    TenantUserModel.tenant_id == tenant_id,
                )
                .limit(1)
            )
            result = await self.auth.db.execute(exist_stmt)
            if not result.scalar_one_or_none():
                raise CustomException(msg="您不属于该租户，无法切换")

        tenant_stmt = select(TenantModel).where(TenantModel.id == tenant_id, TenantModel.status == 0).limit(1)
        result = await self.auth.db.execute(tenant_stmt)
        tenant = result.scalar_one_or_none()
        if not tenant:
            raise CustomException(msg="租户不存在或已被禁用")

        ctx = getattr(request.state, "ctx", None)
        session_id = ctx.session_id if ctx else None
        session_info = ctx.session_info if ctx else None

        if not session_id or not session_info:
            raise CustomException(msg="会话已失效")

        # 更新会话中的租户 ID 并写回 Redis
        session_info["tenant_id"] = tenant_id
        refresh_expires = timedelta(seconds=settings.REFRESH_TOKEN_EXPIRE_SECONDS)
        from app.core.redis_crud import RedisCURD
        from app.core.security import create_access_token

        await RedisCURD(redis).set(
            key=f"{RedisInitKeyConfig.USER_SESSION.key}:{session_id}",
            value=json.dumps(session_info) if isinstance(session_info, dict) else session_info,
            expire=int(refresh_expires.total_seconds()),
        )

        access_expires = timedelta(seconds=settings.ACCESS_TOKEN_EXPIRE_SECONDS)
        now = datetime.now()

        new_access_token = create_access_token(
            payload=JWTPayloadSchema(
                sub=session_id,
                is_refresh=False,
                exp=now + access_expires,
            ),
        )

        await RedisCURD(redis).set(
            key=f"{RedisInitKeyConfig.ACCESS_TOKEN.key}:{session_id}",
            value=new_access_token,
            expire=int(access_expires.total_seconds()),
        )

        new_refresh_token = create_access_token(
            payload=JWTPayloadSchema(
                sub=session_id,
                is_refresh=True,
                exp=now + refresh_expires,
            ),
        )
        await RedisCURD(redis).set(
            key=f"{RedisInitKeyConfig.REFRESH_TOKEN.key}:{session_id}",
            value=new_refresh_token,
            expire=int(refresh_expires.total_seconds()),
        )

        from app.core.request_context import set_current_tenant

        set_current_tenant(tenant_id)

        logger.info(f"用户 {user.username}(id={user.id}) 切换到租户 {tenant.name}(id={tenant_id})")

        return SelectTenantOutSchema(
            access_token=new_access_token,
            token_type=settings.TOKEN_TYPE,
            expires_in=int(access_expires.total_seconds()),
        )

    async def enter_platform(
        self,
        request: Request,
        redis: Redis,
    ) -> EnterPlatformOutSchema:
        """进入平台管理模式：清除会话中的 tenant_id，返回平台作用域 JWT"""
        user = self.auth.user
        if not user:
            raise CustomException(msg="未认证用户")

        ctx = getattr(request.state, "ctx", None)
        session_id = ctx.session_id if ctx else None
        session_info = ctx.session_info if ctx else None

        if not session_id or not session_info:
            raise CustomException(msg="会话已失效")

        session_info["tenant_id"] = 0
        refresh_expires = timedelta(seconds=settings.REFRESH_TOKEN_EXPIRE_SECONDS)

        await RedisCURD(redis).set(
            key=f"{RedisInitKeyConfig.USER_SESSION.key}:{session_id}",
            value=json.dumps(session_info) if isinstance(session_info, dict) else session_info,
            expire=int(refresh_expires.total_seconds()),
        )

        access_expires = timedelta(seconds=settings.ACCESS_TOKEN_EXPIRE_SECONDS)
        now = datetime.now()

        new_access_token = create_access_token(
            payload=JWTPayloadSchema(
                sub=session_id,
                is_refresh=False,
                exp=now + access_expires,
            ),
        )

        await RedisCURD(redis).set(
            key=f"{RedisInitKeyConfig.ACCESS_TOKEN.key}:{session_id}",
            value=new_access_token,
            expire=int(access_expires.total_seconds()),
        )

        new_refresh_token = create_access_token(
            payload=JWTPayloadSchema(
                sub=session_id,
                is_refresh=True,
                exp=now + refresh_expires,
            ),
        )
        await RedisCURD(redis).set(
            key=f"{RedisInitKeyConfig.REFRESH_TOKEN.key}:{session_id}",
            value=new_refresh_token,
            expire=int(refresh_expires.total_seconds()),
        )

        from app.core.request_context import clear_current_tenant

        clear_current_tenant()

        logger.info(f"用户 {user.username}(id={user.id}) 返回平台管理模式")

        return EnterPlatformOutSchema(
            access_token=new_access_token,
            token_type=settings.TOKEN_TYPE,
            expires_in=int(access_expires.total_seconds()),
        )

    async def impersonate(
        self,
        request: Request,
        redis: Redis,
        tenant_id: int,
    ) -> ImpersonateOutSchema:
        """平台管理员代签入：以指定租户身份登录（仅超级管理员可用）"""
        from sqlalchemy import select

        from app.api.v1.module_platform.tenant.model import TenantModel

        user = self.auth.user
        if not user or not user.is_superuser:
            raise CustomException(msg="仅平台管理员可执行代签入")

        tenant_stmt = select(TenantModel).where(TenantModel.id == tenant_id, TenantModel.is_deleted.is_(False)).limit(1)
        result = await self.auth.db.execute(tenant_stmt)
        tenant = result.scalar_one_or_none()
        if not tenant:
            raise CustomException(msg="租户不存在")

        ctx = getattr(request.state, "ctx", None)
        session_id = ctx.session_id if ctx else None
        session_info = ctx.session_info if ctx else None

        if not session_id or not session_info:
            raise CustomException(msg="会话已失效")

        session_info["tenant_id"] = tenant_id
        session_info["is_impersonate"] = True
        refresh_expires = timedelta(seconds=settings.REFRESH_TOKEN_EXPIRE_SECONDS)

        await RedisCURD(redis).set(
            key=f"{RedisInitKeyConfig.USER_SESSION.key}:{session_id}",
            value=json.dumps(session_info) if isinstance(session_info, dict) else session_info,
            expire=int(refresh_expires.total_seconds()),
        )

        access_expires = timedelta(seconds=settings.ACCESS_TOKEN_EXPIRE_SECONDS)
        now = datetime.now()

        new_access_token = create_access_token(
            payload=JWTPayloadSchema(
                sub=session_id,
                is_refresh=False,
                exp=now + access_expires,
            ),
        )

        await RedisCURD(redis).set(
            key=f"{RedisInitKeyConfig.ACCESS_TOKEN.key}:{session_id}",
            value=new_access_token,
            expire=int(access_expires.total_seconds()),
        )

        new_refresh_token = create_access_token(
            payload=JWTPayloadSchema(
                sub=session_id,
                is_refresh=True,
                exp=now + refresh_expires,
            ),
        )
        await RedisCURD(redis).set(
            key=f"{RedisInitKeyConfig.REFRESH_TOKEN.key}:{session_id}",
            value=new_refresh_token,
            expire=int(refresh_expires.total_seconds()),
        )

        from app.core.request_context import set_current_tenant

        set_current_tenant(tenant_id)

        logger.warning(f"平台管理员 {user.username}(id={user.id}) 代签入租户 {tenant.name}(id={tenant_id})")

        return ImpersonateOutSchema(
            access_token=new_access_token,
            refresh_token=new_refresh_token,
            token_type=settings.TOKEN_TYPE,
            expires_in=int(access_expires.total_seconds()),
            tenant_id=tenant_id,
            tenant_name=tenant.name,
        )


class CaptchaService:
    """验证码服务"""

    @staticmethod
    async def get_captcha(redis: Redis) -> CaptchaOutSchema:
        """获取验证码"""
        if not settings.CAPTCHA_ENABLE:
            raise CustomException(msg="未开启验证码服务")

        captcha_base64, captcha_value = CaptchaUtil.captcha_arithmetic()
        captcha_key = get_random_character()

        redis_key = f"{RedisInitKeyConfig.CAPTCHA_CODES.key}:{captcha_key}"
        await RedisCURD(redis).set(
            key=redis_key,
            value=captcha_value,
            expire=settings.CAPTCHA_EXPIRE_SECONDS,
        )

        return CaptchaOutSchema(
            enable=settings.CAPTCHA_ENABLE,
            key=CaptchaKey(captcha_key),
            img_base=CaptchaBase64(f"data:image/png;base64,{captcha_base64}"),
        )

    @staticmethod
    async def check_captcha(redis: Redis, key: str, captcha: str) -> bool:
        """校验验证码"""
        if not captcha:
            raise CustomException(msg="验证码不能为空")

        redis_key = f"{RedisInitKeyConfig.CAPTCHA_CODES.key}:{key}"
        captcha_value = await RedisCURD(redis).get(redis_key)
        if not captcha_value:
            raise CustomException(msg="验证码已过期")

        if captcha.lower() != captcha_value.lower():
            raise CustomException(msg="验证码错误")

        await RedisCURD(redis).delete(redis_key)
        return True


class TenantRegisterService:
    """PRD §4.5 租户自助注册：一次性创建租户 + 管理员 + owner 角色 + 菜单分配"""

    DEFAULT_TRIAL_DAYS: int = settings.TENANT_TRIAL_DAYS

    @classmethod
    async def register(
        cls,
        db: AsyncSession,
        username: str,
        password: str,
        email: str,
        tenant_name: str | None = None,
    ) -> TenantRegisterOutSchema:
        """租户自助注册：一次性创建租户 + 管理员 + owner 角色 + 菜单分配"""
        from sqlalchemy import func, select
        from sqlalchemy.exc import IntegrityError

        from app.api.v1.module_platform.package.model import PackageMenuModel, PackageModel
        from app.api.v1.module_platform.tenant.model import TenantModel, TenantUserModel
        from app.api.v1.module_system.role.model import RoleMenusModel, RoleModel
        from app.api.v1.module_system.user.model import UserModel, UserRolesModel

        exists_stmt = (
            select(func.count())
            .select_from(UserModel)
            .where(
                UserModel.is_deleted.is_(False),
                (UserModel.username == username) | (UserModel.email == email),
            )
        )
        cnt = (await db.execute(exists_stmt)).scalar() or 0
        if cnt > 0:
            raise CustomException(msg="用户名或邮箱已被占用")

        pkg_stmt = select(PackageModel).where(PackageModel.status == 0).order_by(PackageModel.id).limit(1)
        default_pkg = (await db.execute(pkg_stmt)).scalar_one_or_none()

        now = datetime.now()
        trial_end = now + timedelta(days=cls.DEFAULT_TRIAL_DAYS)

        base = tenant_name or username
        code_suffix = base.encode("utf-8").hex()[:6].upper()
        tenant_code = f"T{code_suffix}"

        tenant = TenantModel(
            name=tenant_name or f"{username}的租户",
            code=tenant_code,
            contact_name=username,
            package_id=default_pkg.id if default_pkg else None,
            start_time=now,
            end_time=trial_end,
            status=0,
        )
        db.add(tenant)
        await db.flush()

        user = UserModel(
            name=username,
            username=username,
            password=PwdUtil.hash_password(password),
            email=email,
            tenant_id=tenant.id,
            status=0,
        )
        db.add(user)
        await db.flush()

        tenant_user = TenantUserModel(
            user_id=user.id,
            tenant_id=tenant.id,
            role="owner",
            is_default=1,
        )
        db.add(tenant_user)
        await db.flush()

        owner_role = RoleModel(
            name="租户管理员",
            code="owner",
            tenant_id=tenant.id,
            order=1,
            data_scope=4,
            description="自助注册创建的管理员角色",
        )
        db.add(owner_role)
        await db.flush()

        user_role = UserRolesModel(user_id=user.id, role_id=owner_role.id)
        db.add(user_role)

        if default_pkg:
            pkg_menu_stmt = select(PackageMenuModel).where(
                PackageMenuModel.package_id == default_pkg.id,
            )
            pkg_menus = (await db.execute(pkg_menu_stmt)).scalars().all()
            for pm in pkg_menus:
                db.add(RoleMenusModel(role_id=owner_role.id, menu_id=pm.menu_id))

        try:
            await db.commit()
        except IntegrityError:
            await db.rollback()
            raise CustomException(msg="租户编码或用户名已被占用，请重试")

        return TenantRegisterOutSchema(
            user_id=user.id,
            username=username,
            tenant_id=tenant.id,
            tenant_name=tenant.name,
            tenant_code=tenant_code,
            package=default_pkg.name if default_pkg else None,
            trial_end=trial_end.strftime("%Y-%m-%d"),
            message="注册成功",
        )


class TenantLookupService:
    """租户查询服务（登录页根据编码查找租户）"""

    @staticmethod
    async def lookup_by_code(db: AsyncSession, code: str) -> dict:
        from sqlalchemy import select

        from app.api.v1.module_platform.tenant.model import TenantModel

        stmt = select(TenantModel).where(
            TenantModel.code == code,
            TenantModel.is_deleted.is_(False),
        )
        result = (await db.execute(stmt)).scalar_one_or_none()
        if not result:
            raise CustomException(msg="未找到该租户")

        return {
            "id": result.id,
            "name": result.name,
            "code": result.code,
            "logo_url": result.logo_url,
            "login_bg": result.login_bg,
            "version": result.version,
        }

    @staticmethod
    async def lookup_by_domain(db: AsyncSession, domain: str) -> dict:
        from sqlalchemy import select

        from app.api.v1.module_platform.tenant.model import TenantModel

        stmt = select(TenantModel).where(
            TenantModel.domain == domain,
            TenantModel.is_deleted.is_(False),
        )
        result = (await db.execute(stmt)).scalar_one_or_none()
        if not result:
            raise CustomException(msg="未找到该域名对应的租户")

        return {
            "id": result.id,
            "name": result.name,
            "code": result.code,
            "logo_url": result.logo_url,
            "login_bg": result.login_bg,
            "version": result.version,
        }
