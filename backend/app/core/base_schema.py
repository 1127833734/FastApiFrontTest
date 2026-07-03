import json
from datetime import datetime
from typing import TYPE_CHECKING, TypeVar

from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator
from sqlalchemy.ext.asyncio import AsyncSession

from app.common.enums import QueueEnum
from app.core.validator import DateTimeStr

if TYPE_CHECKING:
    from app.api.v1.module_system.user.model import UserModel

UserT = TypeVar("UserT")


class CommonSchema(BaseModel):
    """通用信息模型"""

    model_config = ConfigDict(from_attributes=True)

    id: int = Field(description="编号ID")
    name: str = Field(description="名称")


class BaseSchema(BaseModel):
    """通用输出模型，包含基础字段和审计字段"""

    model_config = ConfigDict(from_attributes=True)

    id: int | None = Field(default=None, description="主键ID")
    uuid: str | None = Field(default=None, description="UUID")
    created_time: DateTimeStr | None = Field(default=None, description="创建时间")
    updated_time: DateTimeStr | None = Field(default=None, description="更新时间")
    is_deleted: bool = Field(default=False, description="是否已删除")
    deleted_time: DateTimeStr | None = Field(default=None, description="删除时间")


class UserBySchema(BaseModel):
    """通用创建模型，包含基础字段和审计字段"""

    model_config = ConfigDict(from_attributes=True)

    created_id: int | None = Field(default=None, description="创建人ID")
    created_by: CommonSchema | None = Field(default=None, description="创建人信息")
    updated_id: int | None = Field(default=None, description="更新人ID")
    updated_by: CommonSchema | None = Field(default=None, description="更新人信息")
    deleted_id: int | None = Field(default=None, description="删除人ID")
    deleted_by: CommonSchema | None = Field(default=None, description="删除人信息")


class TenantBySchema(BaseModel):
    """租户嵌套出参（不再使用扁平 tenant_id / tenant_name / tenant_code）"""

    model_config = ConfigDict(from_attributes=True)

    tenant_id: int | None = Field(default=None, description="租户ID")
    tenant_by: CommonSchema | None = Field(default=None, description="租户信息")


class BatchSetAvailable(BaseModel):
    """批量设置可用状态的请求模型"""

    ids: list[int] = Field(default_factory=list, description="ID列表")
    status: int = Field(default=0, ge=0, le=1, description="是否可用")


class UploadResponseSchema(BaseModel):
    """上传响应模型"""

    model_config = ConfigDict(from_attributes=True)

    file_path: str | None = Field(default=None, description="新文件映射路径")
    file_name: str | None = Field(default=None, description="新文件名称")
    origin_name: str | None = Field(default=None, description="原文件名称")
    file_url: str | None = Field(default=None, description="新文件访问地址")


class DownloadFileSchema(BaseModel):
    """下载文件模型"""

    file_path: str = Field(..., description="新文件映射路径")
    file_name: str = Field(..., description="新文件名称")


class AuthSchema(BaseModel):
    """权限认证模型

    ``user`` 字段运行时为 ``Any``（避免与 SQLAlchemy 懒加载冲突，也避免
    循环依赖）。通过 ``get_user()`` 方法获得 IDE 类型推断。
    """

    model_config = ConfigDict(arbitrary_types_allowed=True)

    user: UserT | None = Field(default=None, description="用户信息（UserModel 实例）", exclude=True)
    check_data_scope: bool = Field(default=True, description="是否检查数据权限")
    db: AsyncSession | None = Field(default=None, description="数据库会话", exclude=True)
    tenant_id: int | None = Field(default=None, description="租户ID,用于用户认证前查询")

    def get_user(self) -> "UserModel | None":
        """类型化的用户访问方法。

        业务方 ``auth.get_user()`` 由 IDE 推断为 ``UserModel | None``，
        享受自动补全。``auth.user`` 仍可用但无类型补全。
        """
        return self.user  # type: ignore[return-value]


class JWTPayloadSchema(BaseModel):
    """JWT载荷模型"""

    sub: str = Field(..., description="用户登录信息")
    is_refresh: bool = Field(default=False, description="是否刷新token")
    exp: datetime | int = Field(..., description="过期时间")

    @model_validator(mode="after")
    def validate_fields(self):
        if not self.sub or len(self.sub.strip()) == 0:
            raise ValueError("会话编号不能为空")
        return self


class JWTOutSchema(BaseModel):
    """JWT响应模型"""

    model_config = ConfigDict(from_attributes=True)

    access_token: str = Field(..., min_length=1, description="访问token")
    refresh_token: str = Field(..., min_length=1, description="刷新token")
    token_type: str = Field(default="Bearer", description="token类型")
    expires_in: int = Field(..., gt=0, description="过期时间(秒)")


class RefreshTokenPayloadSchema(BaseModel):
    """刷新Token载荷模型"""

    refresh_token: str = Field(..., min_length=1, description="刷新token")


class LogoutPayloadSchema(BaseModel):
    """退出登录载荷模型"""

    token: str = Field(..., min_length=1, description="token")


class PageResultSchema[T](BaseModel):
    """分页查询结果模型"""

    model_config = ConfigDict(from_attributes=True)

    page_no: int | None = Field(default=None, ge=1, description="页码，默认为1")
    page_size: int | None = Field(default=None, ge=1, description="页面大小，默认为10")
    total: int = Field(default=0, ge=0, description="总记录数")
    has_next: bool | None = Field(default=False, description="是否有下一页")
    items: list[T] = Field(default_factory=list, description="分页后的数据列表")


class PaginationQueryParam(BaseModel):
    """分页 —— 自动继承 page_no / page_size / order_by，子类无需重复声明"""

    page_no: int = Field(default=1, description="当前页码", ge=1)
    page_size: int = Field(default=10, description="每页数量", ge=1, le=100)
    order_by: list = Field(
        default_factory=lambda: [{"id": "desc"}],
        description="排序字段,格式:[{'field1': 'asc'}, {'field2': 'desc'}]",
    )

    @field_validator("order_by", mode="before")
    @classmethod
    def parse_order_by(cls, v: object) -> list:
        if v is None:
            return [{"id": "desc"}]
        if isinstance(v, str):
            try:
                return json.loads(v)
            except (ValueError, json.JSONDecodeError):
                return [{"id": "desc"}]
        return v


class BaseQueryParam(BaseModel):
    """created_time + updated_time —— 子类自动继承"""

    created_time: list[DateTimeStr] | None = Field(
        None,
        description="创建时间范围",
        examples=["2025-01-01 00:00:00", "2025-12-31 23:59:59"],
    )
    updated_time: list[DateTimeStr] | None = Field(
        None,
        description="更新时间范围",
        examples=["2025-01-01 00:00:00", "2025-12-31 23:59:59"],
    )

    @model_validator(mode="after")
    def validate_query_params(self) -> "BaseQueryParam":
        ct = self.created_time
        if isinstance(ct, list) and len(ct) == 2:
            self.created_time = (QueueEnum.between.value, (ct[0], ct[1]))
        ut = self.updated_time
        if isinstance(ut, list) and len(ut) == 2:
            self.updated_time = (QueueEnum.between.value, (ut[0], ut[1]))
        return self


class UserByQueryParam(BaseModel):
    """created_id + updated_id —— 子类自动继承"""

    created_id: int | None = Field(None, description="创建人")
    updated_id: int | None = Field(None, description="更新人")

    @model_validator(mode="after")
    def validate_query_params(self) -> "UserByQueryParam":
        if isinstance(self.created_id, int):
            self.created_id = (QueueEnum.eq.value, self.created_id)
        if isinstance(self.updated_id, int):
            self.updated_id = (QueueEnum.eq.value, self.updated_id)
        return self


class TenantByQueryParam(BaseModel):
    """tenant_id —— 子类自动继承"""

    tenant_id: int | None = Field(None, description="租户ID")

    @model_validator(mode="after")
    def validate_query_params(self) -> "TenantByQueryParam":
        if isinstance(self.tenant_id, int):
            self.tenant_id = (QueueEnum.eq.value, self.tenant_id)
        return self
