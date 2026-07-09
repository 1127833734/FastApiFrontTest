from typing import Annotated

from fastapi import APIRouter, Depends, Security
from fastapi.responses import JSONResponse
from redis.asyncio.client import Redis
from sqlalchemy.ext.asyncio import AsyncSession

from app.common.response import ResponseSchema, SuccessResponse
from app.core.base_schema import AuthSchema
from app.core.dependencies import AuthPermission, db_getter, redis_getter
from app.core.router_class import OperationLogRoute

from .schema import DashboardStatsSchema
from .service import MonitorDashboardService

MonitorDashboardRouter = APIRouter(
    route_class=OperationLogRoute,
    prefix="/dashboard",
    tags=["仪表盘"],
)


@MonitorDashboardRouter.get(
    "/stats",
    summary="获取仪表盘统计数据",
    response_model=ResponseSchema[DashboardStatsSchema],
)
async def get_dashboard_stats_controller(
    db: Annotated[AsyncSession, Depends(db_getter)],
    redis: Annotated[Redis, Depends(redis_getter)],
    auth: Annotated[AuthSchema, Security(AuthPermission(["module_monitor:dashboard:query"]))],
) -> JSONResponse:
    """获取首页仪表盘统计数据（在线用户、用户数、租户数、订单数、登录统计等）"""
    data = await MonitorDashboardService.get_dashboard_stats(db=db, redis=redis, auth=auth)
    return SuccessResponse(data=data, msg="获取仪表盘统计成功")
