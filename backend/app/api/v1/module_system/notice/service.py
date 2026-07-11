from sqlalchemy.ext.asyncio import AsyncSession

from app.core.base_schema import AuthSchema, BatchSetAvailable, PageResultSchema
from app.core.exceptions import CustomException
from app.utils.excel_util import ExcelUtil

from .crud import NoticeCRUD
from .schema import NoticeCreateSchema, NoticeOutSchema, NoticeQueryParam, NoticeUpdateSchema


class NoticeService:
    """公告管理服务

    提供公告 CRUD、状态切换、已启用公告分页查询、Excel 导出等业务能力。
    """

    def __init__(self, auth: AuthSchema, db: AsyncSession) -> None:
        self.auth = auth
        self.db = db

    async def detail(self, id: int) -> NoticeOutSchema:
        obj = await NoticeCRUD(self.auth, self.db).get_or_404(id=id)
        return NoticeOutSchema.model_validate(obj)

    async def get_list(
        self,
        search: NoticeQueryParam | None = None,
        order_by: list[dict] | None = None,
    ) -> list[NoticeOutSchema]:
        notice_obj_list = await NoticeCRUD(self.auth, self.db).get_list(search=vars(search) if search else None, order_by=order_by)
        return [NoticeOutSchema.model_validate(notice_obj) for notice_obj in notice_obj_list]

    async def page(
        self,
        page_no: int,
        page_size: int,
        search: NoticeQueryParam | None = None,
        order_by: list[dict] | None = None,
    ) -> PageResultSchema[NoticeOutSchema]:
        offset = (page_no - 1) * page_size
        return await NoticeCRUD(self.auth, self.db).page(
            offset=offset,
            limit=page_size,
            order_by=order_by or [{"id": "asc"}],
            search=vars(search) if search else None,
            out_schema=NoticeOutSchema,
        )

    async def available_page(self) -> PageResultSchema[NoticeOutSchema]:
        return await NoticeCRUD(self.auth, self.db).page(
            offset=0,
            limit=10,
            order_by=[{"id": "asc"}],
            search={"status": ("eq", 0)},
            out_schema=NoticeOutSchema,
        )

    async def create(self, data: NoticeCreateSchema) -> NoticeOutSchema:
        notice = await NoticeCRUD(self.auth, self.db).get(notice_title=data.notice_title)
        if notice:
            raise CustomException(msg="创建失败，该数据已存在")
        notice_obj = await NoticeCRUD(self.auth, self.db).create(data=data)
        return NoticeOutSchema.model_validate(notice_obj)

    async def update(self, id: int, data: NoticeUpdateSchema) -> NoticeOutSchema:
        _ = await NoticeCRUD(self.auth, self.db).get_or_404(id=id, msg="更新失败，该数据不存在")
        exist_notice = await NoticeCRUD(self.auth, self.db).get(notice_title=data.notice_title)
        if exist_notice and exist_notice.id != id:
            raise CustomException(msg="更新失败，标题已存在")
        notice_obj = await NoticeCRUD(self.auth, self.db).update(id=id, data=data)
        return NoticeOutSchema.model_validate(notice_obj)

    async def delete(self, ids: list[int]) -> None:
        if len(ids) < 1:
            raise CustomException(msg="删除失败，删除对象不能为空")
        notices = await NoticeCRUD(self.auth, self.db).get_list(search={"id": ("in", ids)})
        notice_map = {n.id: n for n in notices}
        for nid in ids:
            if nid not in notice_map:
                raise CustomException(msg="删除失败，该数据不存在")
        await NoticeCRUD(self.auth, self.db).delete(ids=ids)

    async def set_available(self, data: BatchSetAvailable) -> None:
        await NoticeCRUD(self.auth, self.db).set(ids=data.ids, status=data.status)

    @staticmethod
    def export(notice_list: list[dict]) -> bytes:
        mapping_dict = {
            "id": "编号",
            "notice_title": "公告标题",
            "notice_type": "公告类型（1通知 2公告）",
            "notice_content": "公告内容",
            "status": "状态",
            "description": "备注",
            "created_time": "创建时间",
            "updated_time": "更新时间",
            "created_id": "创建者ID",
            "updated_id": "更新者ID",
        }
        data = notice_list.copy()
        for item in data:
            item["status"] = "启用" if item.get("status") == 0 else "停用"
            item["notice_type"] = "通知" if item.get("notice_type") == "1" else "公告"
        return ExcelUtil.export_list2excel(list_data=data, mapping_dict=mapping_dict)
