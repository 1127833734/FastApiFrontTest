from pydantic import BaseModel, Field, model_validator

from app.common.enums import QueueEnum
from app.core.validator import DateTimeStr


class OnlineOutSchema(BaseModel):
    """在线用户对应pydantic模型
    """

    name: str = Field(..., description="用户名称")
    session_id: str = Field(..., description="会话编号")
    user_id: int = Field(..., description="用户ID")
    tenant_id: int = Field(..., description="租户ID")
    tenant_status: int = Field(default=0, description="租户状态(0:正常 1:欠费 2:试用 3:冻结 4:注销)")
    is_superuser: bool = Field(default=False, description="是否为超级管理员")
    user_status: int = Field(default=0, description="用户状态(0:启用 1:停用)")
    user_name: str = Field(..., description="用户名")
    permissions: list[str] = Field(default_factory=list, description="用户权限列表")
    ipaddr: str | None = Field(default=None, description="登陆IP地址")
    login_location: str | None = Field(default=None, description="登录所属地")
    os: str | None = Field(default=None, description="操作系统")
    browser: str | None = Field(default=None, description="浏览器")
    login_time: DateTimeStr | None = Field(default=None, description="登录时间")
    login_type: str | None = Field(default=None, description="登录类型 PC端 | 移动端")


class OnlineQueryParam(BaseModel):
    """在线用户查询参数"""

    name: str | tuple[str, str] | None = Field(None, description="登录名称")
    ipaddr: str | tuple[str, str] | None = Field(None, description="登陆IP地址")
    login_location: str | tuple[str, str] | None = Field(None, description="登录所属地")

    @model_validator(mode="after")
    def validate_query_params(self) -> "OnlineQueryParam":
        if isinstance(self.name, str):
            self.name = (QueueEnum.like.value, self.name)
        if isinstance(self.ipaddr, str):
            self.ipaddr = (QueueEnum.like.value, self.ipaddr)
        if isinstance(self.login_location, str):
            self.login_location = (QueueEnum.like.value, self.login_location)
        return self
