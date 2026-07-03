from pydantic import BaseModel, Field, model_validator

from app.common.enums import QueueEnum
from app.core.validator import DateTimeStr


class OnlineOutSchema(BaseModel):
    """
    在线用户对应pydantic模型
    """

    name: str = Field(..., description="用户名称")
    session_id: str = Field(..., description="会话编号")
    user_id: int = Field(..., description="用户ID")
    tenant_id: int = Field(..., description="租户ID")
    is_superuser: bool = Field(default=False, description="是否为超级管理员")
    user_name: str = Field(..., description="用户名")
    ipaddr: str | None = Field(default=None, description="登陆IP地址")
    login_location: str | None = Field(default=None, description="登录所属地")
    os: str | None = Field(default=None, description="操作系统")
    browser: str | None = Field(default=None, description="浏览器")
    login_time: DateTimeStr | None = Field(default=None, description="登录时间")
    login_type: str | None = Field(default=None, description="登录类型 PC端 | 移动端")


class OnlineQueryParam(BaseModel):
    """在线用户查询参数"""

    name: str | None = Field(None, description="登录名称")
    ipaddr: str | None = Field(None, description="登陆IP地址")
    login_location: str | None = Field(None, description="登录所属地")

    @model_validator(mode="after")
    def validate_query_params(self) -> "OnlineQueryParam":
        self.name = (QueueEnum.like.value, self.name) if self.name else None
        self.login_location = (QueueEnum.like.value, self.login_location) if self.login_location else None
        self.ipaddr = (QueueEnum.like.value, self.ipaddr) if self.ipaddr else None
        return self
