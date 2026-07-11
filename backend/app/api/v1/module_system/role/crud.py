from typing import Any

from sqlalchemy.ext.asyncio import AsyncSession

from app.api.v1.module_platform.menu.crud import MenuCRUD
from app.api.v1.module_system.dept.crud import DeptCRUD
from app.core.base_crud import CRUDBase
from app.core.base_schema import AuthSchema
from app.core.exceptions import CustomException

from .model import RoleModel
from .schema import RoleCreateSchema, RoleUpdateSchema


class RoleCRUD(CRUDBase[RoleModel, RoleCreateSchema, RoleUpdateSchema]):
    """角色模块数据层"""

    def __init__(self, auth: AuthSchema, db: AsyncSession) -> None:
        super().__init__(model=RoleModel, auth=auth, db=db)

    async def set_role_menus_crud(self, role_ids: list[int], menu_ids: list[int]) -> None:
        """设置角色的菜单权限

        参数:
        - role_ids (list[int]): 角色ID列表
        - menu_ids (list[int]): 菜单ID列表

        返回:
        - None
        """
        from app.api.v1.module_platform.package.service import PackageService

        roles = await self.get_list(search={"id": ("in", role_ids)})
        menus = [] if not menu_ids else await MenuCRUD(self.auth, self.db).get_list(search={"id": ("in", menu_ids)})

        # 非超管需校验菜单在租户套餐范围内
        user = self.auth.user
        if user and not user.is_superuser and user.tenant_id:
            allowed_set = set[int](await PackageService(self.auth, self.db).get_tenant_available_menu_ids(user.tenant_id))
            for menu in menus:
                if int(menu.id) not in allowed_set:
                    raise CustomException(msg=f"菜单[{menu.name}]不在当前租户的功能组内，无法分配")

        for obj in roles:
            obj.menus.clear()
            obj.menus.extend(menus)
        await self.db.flush()

    async def set_role_depts_crud(self, role_ids: list[int], dept_ids: list[int]) -> None:
        """设置角色的部门权限

        参数:
        - role_ids (list[int]): 角色ID列表
        - dept_ids (list[int]): 部门ID列表

        返回:
        - None
        """
        roles = await self.get_list(search={"id": ("in", role_ids)})
        depts = [] if not dept_ids else await DeptCRUD(self.auth, self.db).get_list(search={"id": ("in", dept_ids)})

        for obj in roles:
            relationship = obj.depts
            relationship.clear()
            relationship.extend(depts)
        await self.db.flush()

    async def get_options(self) -> list[dict[str, Any]]:
        """获取角色下拉选项，返回 [{value, label}]"""
        items = await self.get_list(search={"status": 0})
        return [{"value": item.id, "label": item.name} for item in items]
