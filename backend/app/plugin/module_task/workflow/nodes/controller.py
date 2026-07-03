from typing import Annotated

from fastapi import APIRouter, Body, Depends, Path, Query
from fastapi.responses import JSONResponse

from app.common.response import ResponseSchema, SuccessResponse
from app.core.base_schema import AuthSchema, PageResultSchema, PaginationQueryParam
from app.core.dependencies import AuthPermission
from app.core.router_class import OperationLogRoute

from .schema import WorkflowNodeTypeCreateSchema, WorkflowNodeTypeOutSchema, WorkflowNodeTypeQueryParam, WorkflowNodeTypeUpdateSchema
from .service import WorkflowNodeTypeService

WorkflowNodesRouter = APIRouter(route_class=OperationLogRoute, prefix="/workflow/nodes", tags=["工作流节点"])


@WorkflowNodesRouter.get("/options", summary="节点选项", response_model=ResponseSchema[list[dict]])
async def get_workflow_node_type_options_controller(
    auth: Annotated[AuthSchema, Depends(AuthPermission(["module_task:workflow:nodes:query"]))],
) -> JSONResponse:
    service = WorkflowNodeTypeService(auth)
    result = await service.get_options()
    return SuccessResponse(data=result, msg="获取节点选项成功")


@WorkflowNodesRouter.get("/detail/{id}", summary="节点详情", response_model=ResponseSchema[WorkflowNodeTypeOutSchema])
async def get_workflow_node_type_detail_controller(
    auth: Annotated[AuthSchema, Depends(AuthPermission(["module_task:workflow:nodes:query"]))],
    id: Annotated[int, Path(description="ID")],
) -> JSONResponse:
    service = WorkflowNodeTypeService(auth)
    result_dict = await service.get_detail(id=id)
    return SuccessResponse(data=result_dict, msg="获取节点详情成功")


@WorkflowNodesRouter.get("/list", summary="节点列表", response_model=ResponseSchema[PageResultSchema[WorkflowNodeTypeOutSchema]])
async def get_workflow_node_type_list_controller(
    auth: Annotated[AuthSchema, Depends(AuthPermission(["module_task:workflow:nodes:query"]))],
    page: Annotated[PaginationQueryParam, Query(description="分页参数")],
    search: Annotated[WorkflowNodeTypeQueryParam, Query(description="查询参数")],
) -> JSONResponse:
    order_by = [{"sort_order": "asc"}, {"id": "asc"}]
    if page.order_by:
        order_by = page.order_by
    service = WorkflowNodeTypeService(auth)
    result_dict = await service.get_page(
        page_no=page.page_no,
        page_size=page.page_size,
        search=search,
        order_by=order_by,
    )
    return SuccessResponse(data=result_dict, msg="查询节点列表成功")


@WorkflowNodesRouter.post("/create", summary="创建节点", response_model=ResponseSchema[WorkflowNodeTypeOutSchema])
async def create_workflow_node_type_controller(
    auth: Annotated[AuthSchema, Depends(AuthPermission(["module_task:workflow:nodes:create"]))],
    data: Annotated[WorkflowNodeTypeCreateSchema, Body(description="创建节点参数")],
) -> JSONResponse:
    service = WorkflowNodeTypeService(auth)
    result_dict = await service.create(data=data)
    return SuccessResponse(data=result_dict, msg="创建节点成功")


@WorkflowNodesRouter.put("/update/{id}", summary="更新节点", response_model=ResponseSchema[WorkflowNodeTypeOutSchema])
async def update_workflow_node_type_controller(
    auth: Annotated[AuthSchema, Depends(AuthPermission(["module_task:workflow:nodes:update"]))],
    id: Annotated[int, Path(description="节点ID")],
    data: Annotated[WorkflowNodeTypeUpdateSchema, Body(description="更新节点参数")],
) -> JSONResponse:
    service = WorkflowNodeTypeService(auth)
    result_dict = await service.update(id=id, data=data)
    return SuccessResponse(data=result_dict, msg="更新节点成功")


@WorkflowNodesRouter.delete("/delete", summary="删除节点", response_model=ResponseSchema[None])
async def delete_workflow_node_type_controller(
    auth: Annotated[AuthSchema, Depends(AuthPermission(["module_task:workflow:nodes:delete"]))],
    ids: Annotated[list[int], Body(description="ID列表")],
) -> JSONResponse:
    service = WorkflowNodeTypeService(auth)
    await service.delete(ids=ids)
    return SuccessResponse(msg="删除节点成功")


@WorkflowNodesRouter.get("/select", summary="节点选择列表", response_model=ResponseSchema[list[dict]])
async def get_workflow_node_type_select_controller(
    auth: Annotated[AuthSchema, Depends(AuthPermission(["module_task:workflow:nodes:query"]))],
) -> JSONResponse:
    service = WorkflowNodeTypeService(auth)
    result = await service.get_select()
    return SuccessResponse(data=result, msg="获取节点选择列表成功")
