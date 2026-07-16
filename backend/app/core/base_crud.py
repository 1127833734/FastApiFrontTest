from collections.abc import Sequence
from datetime import datetime, timedelta
from typing import Any, TypeVar, cast

from pydantic import BaseModel
from sqlalchemy import asc, delete, desc, false, func, literal_column, select, update
from sqlalchemy import inspect as sa_inspect
from sqlalchemy.engine import Result
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import load_only, selectinload
from sqlalchemy.sql.elements import ColumnElement

from app.core.base_model import ModelMixin
from app.core.base_schema import AuthSchema, PageResultSchema
from app.core.exceptions import CustomException

OutSchemaType = TypeVar("OutSchemaType", bound=BaseModel)
CreateSchemaType = TypeVar("CreateSchemaType", bound=BaseModel)
UpdateSchemaType = TypeVar("UpdateSchemaType", bound=BaseModel)


class CRUDBase[ModelType: ModelMixin, CreateSchemaType, UpdateSchemaType]:
    """统一数据层基类

    核心设计：``auth`` 是必填的 ``AuthSchema``，子类可直接访问 ``self.auth.user.xxx``。

    用法:
        class UserCRUD(CRUDBase[UserModel, UserCreateSchema, UserUpdateSchema]):
            def __init__(self, auth: AuthSchema, db: AsyncSession) -> None:
                super().__init__(model=UserModel, auth=auth, db=db)
    """

    def __init__(self, model: type[ModelType], auth: AuthSchema, db: AsyncSession) -> None:
        self.model = model
        self.auth = auth
        self.db = db

    def _get_pk_col(self) -> ColumnElement:
        mapper = sa_inspect(self.model)
        pk_cols = list[Any](getattr(mapper, "primary_key", []))
        if not pk_cols:
            raise CustomException(msg="模型缺少主键")
        if len(pk_cols) > 1:
            raise CustomException(msg="暂不支持复合主键操作")
        return pk_cols[0]

    @property
    def _supports_soft_delete(self) -> bool:
        return all(hasattr(self.model, attr) for attr in ("is_deleted", "deleted_time", "deleted_id"))

    def _soft_delete_values(self) -> dict[str, Any]:
        data: dict[str, Any] = {"is_deleted": True, "deleted_time": datetime.now()}
        if self.auth.user.id:
            data["deleted_id"] = self.auth.user.id
        return data

    async def get(self, preload: list[str | Any] | None = None, **kwargs) -> ModelType | None:
        try:
            conditions = await self.__build_conditions(**kwargs)
            sql = select(self.model).where(*conditions)
            for opt in self.__loader_options(preload):
                sql = sql.options(opt)
            result: Result = await self.db.execute(sql)
            return result.scalars().first()
        except Exception as e:
            raise CustomException(msg=f"获取查询失败: {e!s}")

    async def get_by_id(self, model_id: int) -> ModelType | None:
        return await self.get(id=model_id)

    async def get_or_404(
        self,
        id: int | None = None,
        msg: str = "该数据不存在",
        preload: list[str | Any] | None = None,
        out_schema: type[OutSchemaType] | None = None,
        **kwargs,
    ) -> ModelType | OutSchemaType:
        if id is not None:
            kwargs["id"] = id
        obj = await self.get(preload=preload, **kwargs)
        if not obj:
            raise CustomException(msg=msg)
        return out_schema.model_validate(obj) if out_schema else obj

    async def exists(self, **kwargs) -> bool:
        return await self.get(**kwargs) is not None

    async def count(self, **kwargs) -> int:
        try:
            conditions = await self.__build_conditions(**kwargs)
            count_sql = select(func.count()).select_from(self.model).where(*conditions)
            result: Result = await self.db.execute(count_sql)
            return result.scalar() or 0
        except Exception as e:
            raise CustomException(msg=f"统计失败: {e!s}")

    async def get_list(
        self,
        search: dict[str, Any] | None = None,
        order_by: list[dict[str, str]] | None = None,
        preload: list[str | Any] | None = None,
        load_columns: list | None = None,
    ) -> Sequence[ModelType]:
        try:
            conditions = await self.__build_conditions(**(search or {}))
            order = order_by or [{"id": "asc"}]
            sql = select(self.model).where(*conditions).order_by(*self._parse_order(order))
            if load_columns:
                sql = sql.options(load_only(*load_columns))
            for opt in self.__loader_options(preload):
                sql = sql.options(opt)
            result: Result = await self.db.execute(sql)
            return result.scalars().all()
        except Exception as e:
            raise CustomException(msg=f"列表查询失败: {e!s}")

    async def tree_list(
        self,
        search: dict[str, Any] | None = None,
        order_by: list[dict[str, str]] | None = None,
        children_attr: str | None = None,
        preload: list[str | Any] | None = None,
    ) -> Sequence[ModelType]:
        if children_attr is None:
            children_attr = getattr(self.model, "__tree_children_attr__", "children")
        try:
            conditions = await self.__build_conditions(**(search or {}))
            order = order_by or [{"id": "asc"}]
            sql = select(self.model).where(*conditions).order_by(*self._parse_order(order))

            final_preload = preload
            if preload is None and children_attr and hasattr(self.model, children_attr):
                model_defaults = getattr(self.model, "__loader_options__", [])
                final_preload = [*list(model_defaults), children_attr]

            for opt in self.__loader_options(final_preload):
                sql = sql.options(opt)

            result: Result = await self.db.execute(sql)
            return result.scalars().all()
        except Exception as e:
            raise CustomException(msg=f"树形列表查询失败: {e!s}")

    async def page(
        self,
        offset: int,
        limit: int,
        order_by: list[dict[str, str]],
        search: dict[str, Any] | None = None,
        out_schema: type[OutSchemaType] | None = None,
        preload: list[str | Any] | None = None,
        load_columns: list | None = None,
    ) -> PageResultSchema[OutSchemaType] | PageResultSchema:
        try:
            conditions = await self.__build_conditions(**(search or {}))
            order = order_by or [{"id": "asc"}]

            mapper = sa_inspect(self.model)
            pk_cols = list(getattr(mapper, "primary_key", []))
            pk = pk_cols[0] if pk_cols else literal_column("1")

            data_sql = select(self.model).where(*conditions)
            if load_columns:
                data_sql = data_sql.options(load_only(*load_columns))
            for opt in self.__loader_options(preload):
                data_sql = data_sql.options(opt)
            count_sql = select(func.count(pk)).select_from(self.model)
            where_clause = data_sql.whereclause
            if where_clause is not None:
                count_sql = count_sql.where(where_clause)

            total_result = await self.db.execute(count_sql)
            total = total_result.scalar() or 0

            result: Result = await self.db.execute(data_sql.order_by(*self._parse_order(order)).offset(offset).limit(limit))
            objs = result.scalars().all()

            items = [out_schema.model_validate(obj) for obj in objs] if out_schema else list(objs)

            return PageResultSchema(
                page_no=offset // limit + 1 if limit else 1,
                page_size=limit or 10,
                total=total,
                has_next=offset + limit < total,
                items=items,
            )
        except Exception as e:
            raise CustomException(msg=f"分页查询失败: {e!s}")

    async def create(self, data: CreateSchemaType) -> ModelType:
        try:
            obj_dict = data if isinstance(data, dict) else cast("BaseModel", data).model_dump()
            obj = self.model(**obj_dict)

            user = self.auth.user
            if user.id:
                if hasattr(obj, "created_id"):
                    setattr(obj, "created_id", user.id)
                if hasattr(obj, "updated_id"):
                    setattr(obj, "updated_id", user.id)

            self.db.add(obj)
            await self.db.flush()
            await self.db.refresh(obj)
            return obj
        except Exception as e:
            raise CustomException(msg=f"创建失败: {e!s}")

    async def update(self, id: int, data: UpdateSchemaType) -> ModelType:
        try:
            obj_dict = data if isinstance(data, dict) else cast("BaseModel", data).model_dump(exclude_unset=True, exclude={"id"})
            model_defaults = getattr(self.model, "__loader_options__", [])
            obj = await self.get(id=id, preload=model_defaults)
            if not obj:
                raise CustomException(msg="更新对象不存在")

            user = self.auth.user
            if user.id and hasattr(obj, "updated_id"):
                setattr(obj, "updated_id", user.id)

            for key, value in obj_dict.items():
                if hasattr(obj, key):
                    setattr(obj, key, value)

            await self.db.flush()
            await self.db.refresh(obj)
            return obj
        except CustomException:
            raise
        except Exception as e:
            raise CustomException(msg=f"更新失败: {e!s}")

    async def delete(self, ids: list[int]) -> None:
        try:
            pk = self._get_pk_col()
            if self._supports_soft_delete:
                sql = update(self.model).where(pk.in_(ids)).values(**self._soft_delete_values())
            else:
                sql = delete(self.model).where(pk.in_(ids))
            await self.db.execute(sql)
            await self.db.flush()
        except Exception as e:
            raise CustomException(msg=f"删除失败: {e!s}")

    async def clear(self) -> None:
        try:
            if self._supports_soft_delete:
                sql = update(self.model).values(**self._soft_delete_values())
            else:
                sql = delete(self.model)
            await self.db.execute(sql)
            await self.db.flush()
        except Exception as e:
            raise CustomException(msg=f"清空失败: {e!s}")

    async def set(self, ids: list[int], **kwargs) -> None:
        try:
            pk = self._get_pk_col()
            sql = update(self.model).where(pk.in_(ids)).values(**kwargs)
            await self.db.execute(sql)
            await self.db.flush()
        except Exception as e:
            raise CustomException(msg=f"批量更新失败: {e!s}")

    async def restore(self, ids: list[int]) -> None:
        try:
            if not self._supports_soft_delete:
                raise CustomException(msg="该模型不支持软删除，无法恢复")
            pk = self._get_pk_col()
            sql = update(self.model).where(pk.in_(ids)).values(is_deleted=False, deleted_time=None, deleted_id=None)
            await self.db.execute(sql)
            await self.db.flush()
        except Exception as e:
            raise CustomException(msg=f"恢复失败: {e!s}")

    async def __build_conditions(self, **kwargs) -> list[ColumnElement]:
        conditions: list[ColumnElement] = []

        if hasattr(self.model, "is_deleted"):
            conditions.append(getattr(self.model, "is_deleted") == false())

        for key, value in kwargs.items():
            if value is None or value == "":
                continue
            attr = getattr(self.model, key)
            if isinstance(value, tuple):
                conditions.extend(self._resolve_condition(attr, value))
            elif isinstance(value, str):
                conditions.append(attr.like(f"%{value}%"))
            elif isinstance(value, (int, bool)):
                conditions.append(attr == value)
            elif isinstance(value, list) and len(value) == 2:
                conditions.append(attr.between(value[0], value[1]))
            else:
                conditions.append(attr == value)
        return conditions

    @staticmethod
    def _resolve_condition(attr: ColumnElement, value: tuple) -> list[ColumnElement]:
        seq, val = value

        handlers: dict[str, Any] = {
            "None": lambda: [attr.is_(None)],
            "not None": lambda: [attr.isnot(None)],
        }
        if seq in handlers:
            return handlers[seq]()

        if val is None:
            return []

        if seq == "date":
            dt = datetime.strptime(val, "%Y-%m-%d")
            return [attr >= dt, attr < dt + timedelta(days=1)]
        if seq == "month":
            dt = datetime.strptime(val, "%Y-%m")
            next_month = dt.replace(year=dt.year + 1, month=1) if dt.month == 12 else dt.replace(month=dt.month + 1)
            return [attr >= dt, attr < next_month]
        if seq == "like":
            return [attr.like(f"%{val}%")]
        if seq == "in":
            if isinstance(val, (list, tuple, set)) and len(val) == 0:
                return [false()]
            return [attr.in_(val)]
        if seq == "between" and isinstance(val, (list, tuple)) and len(val) == 2:
            return [attr.between(val[0], val[1])]

        _COMPARATORS = {
            "!=": attr.__ne__, "ne": attr.__ne__,
            ">": attr.__gt__, "gt": attr.__gt__,
            ">=": attr.__ge__, "ge": attr.__ge__,
            "<": attr.__lt__, "lt": attr.__lt__,
            "<=": attr.__le__, "le": attr.__le__,
            "eq": attr.__eq__, "==": attr.__eq__,
        }
        cmp = _COMPARATORS.get(seq)
        if cmp is not None:
            return [cmp(val)]
        return []

    @staticmethod
    def _parse_order(order: list[dict[str, str]]) -> list[ColumnElement]:
        columns: list[ColumnElement] = []
        for item in order:
            for field, direction in item.items():
                column = getattr(self.model, field)  # type: ignore[arg-type]
                columns.append(desc(column) if direction.lower() == "desc" else asc(column))
        return columns

    def __loader_options(self, preload: list[str | Any] | None = None) -> list[Any]:
        model_loader_options = getattr(self.model, "__loader_options__", [])

        if preload == []:
            return []

        names: set[str] = set(model_loader_options)
        if preload:
            for opt in preload:
                if isinstance(opt, str):
                    names.add(opt)

        options: list[Any] = []
        for name in names:
            if hasattr(self.model, name):
                options.append(selectinload(getattr(self.model, name)))

        if preload:
            options.extend(opt for opt in preload if not isinstance(opt, str))

        return options
