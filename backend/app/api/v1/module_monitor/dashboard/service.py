from datetime import date, datetime, timedelta

from redis.asyncio.client import Redis
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.v1.module_monitor.online.service import OnlineService
from app.core.base_schema import AuthSchema

from .schema import DashboardStatsSchema, RecentLoginItem


class MonitorDashboardService:
    """仪表盘统计服务"""

    @staticmethod
    async def get_dashboard_stats(
        db: AsyncSession,
        redis: Redis,
        auth: AuthSchema,
    ) -> DashboardStatsSchema:
        from app.api.v1.module_platform.order.model import OrderModel
        from app.api.v1.module_platform.tenant.model import TenantModel
        from app.api.v1.module_system.log.model import LoginLogModel
        from app.api.v1.module_system.user.model import UserModel

        today_start = datetime.combine(date.today(), datetime.min.time())
        week_start = today_start - timedelta(days=7)

        # 在线用户
        online_list = await OnlineService.get_online_list(redis)
        online_count = len(online_list)

        # 用户统计
        users_sql = select(func.count()).select_from(UserModel).where(UserModel.is_deleted.is_(False))
        user_count = (await db.execute(users_sql)).scalar() or 0

        users_week_sql = (
            select(func.count()).select_from(UserModel)
            .where(UserModel.is_deleted.is_(False), UserModel.created_time >= week_start)
        )
        user_week_count = (await db.execute(users_week_sql)).scalar() or 0

        # 租户统计
        tenants_sql = select(func.count()).select_from(TenantModel).where(TenantModel.is_deleted.is_(False))
        tenant_count = (await db.execute(tenants_sql)).scalar() or 0

        tenants_week_sql = (
            select(func.count()).select_from(TenantModel)
            .where(TenantModel.is_deleted.is_(False), TenantModel.created_time >= week_start)
        )
        tenant_week_count = (await db.execute(tenants_week_sql)).scalar() or 0

        # 订单统计
        orders_sql = select(func.count()).select_from(OrderModel).where(OrderModel.is_deleted.is_(False))
        order_count = (await db.execute(orders_sql)).scalar() or 0

        paid_sql = (
            select(func.count()).select_from(OrderModel)
            .where(OrderModel.is_deleted.is_(False), OrderModel.status == 1)
        )
        paid_count = (await db.execute(paid_sql)).scalar() or 0

        # 今日登录统计
        today_login_sql = (
            select(func.count()).select_from(LoginLogModel)
            .where(LoginLogModel.created_time >= today_start)
        )
        today_login_count = (await db.execute(today_login_sql)).scalar() or 0

        today_unique_sql = (
            select(func.count(func.distinct(LoginLogModel.username)))
            .select_from(LoginLogModel)
            .where(LoginLogModel.created_time >= today_start)
        )
        today_unique_count = (await db.execute(today_unique_sql)).scalar() or 0

        # 最近登录记录（最近 10 条）
        recent_stmt = (
            select(
                LoginLogModel.username,
                LoginLogModel.status,
                LoginLogModel.created_time,
                LoginLogModel.login_ip,
                LoginLogModel.login_location,
            )
            .where(LoginLogModel.is_deleted.is_(False))
            .order_by(LoginLogModel.created_time.desc())
            .limit(10)
        )
        recent_rows = (await db.execute(recent_stmt)).all()
        recent_logins = [
            RecentLoginItem(
                username=r.username,
                status=r.status,
                login_time=r.created_time,
                login_ip=r.login_ip,
                login_location=r.login_location,
            )
            for r in recent_rows
        ]

        return DashboardStatsSchema(
            online_users=online_count,
            total_users=user_count,
            total_tenants=tenant_count,
            total_orders=order_count,
            today_login_count=today_login_count,
            today_unique_users=today_unique_count,
            week_user_created=user_week_count,
            week_tenant_created=tenant_week_count,
            paid_orders=paid_count,
            recent_logins=recent_logins,
        )
