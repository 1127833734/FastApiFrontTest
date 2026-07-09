from datetime import datetime

from pydantic import BaseModel


class RecentLoginItem(BaseModel):
    """最近登录记录"""
    username: str
    status: int  # 1:成功 2:失败
    login_time: datetime
    login_ip: str | None = None
    login_location: str | None = None


class DashboardStatsSchema(BaseModel):
    """首页仪表盘统计数据"""
    online_users: int = 0
    total_users: int = 0
    total_tenants: int = 0
    total_orders: int = 0
    today_login_count: int = 0      # 今日登录人次
    today_unique_users: int = 0     # 今日登录人数
    week_user_created: int = 0      # 本周新增用户
    week_tenant_created: int = 0    # 本周新增租户
    paid_orders: int = 0            # 已支付订单数
    recent_logins: list[RecentLoginItem] = []
