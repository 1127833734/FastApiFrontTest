import type { BatchSetStatus } from './user'
import { http } from '@/http'

const SYSTEM_BASE = '/system'

/**
 * 角色管理 API
 * 与 web 端 module_system/role.ts 对齐（完整字段定义）
 */
export const RoleAPI = {
  getPage(params?: Record<string, any>): Promise<PageResult<RoleItem>> {
    return http.Get(`${SYSTEM_BASE}/role/list`, params)
  },
  getDetail(id: number): Promise<RoleItem> {
    return http.Get(`${SYSTEM_BASE}/role/detail/${id}`)
  },
  create(data: RoleForm): Promise<RoleItem> {
    return http.Post(`${SYSTEM_BASE}/role/create`, data)
  },
  update(id: number, data: RoleForm): Promise<RoleItem> {
    return http.Put(`${SYSTEM_BASE}/role/update/${id}`, data)
  },
  remove(ids: number[]): Promise<void> {
    return http.Delete(`${SYSTEM_BASE}/role/delete`, { ids: JSON.stringify(ids) })
  },
  batchStatus(data: BatchSetStatus): Promise<void> {
    return http.Patch(`${SYSTEM_BASE}/role/status/batch`, data)
  },
  setPermission(data: RolePermissionForm): Promise<void> {
    return http.Put(`${SYSTEM_BASE}/role/permission`, data)
  },
  getOptions(): Promise<{ value: number, label: string }[]> {
    return http.Get(`${SYSTEM_BASE}/role/options`)
  },
  exportRoles(params?: Record<string, any>): Promise<unknown> {
    return http.Post(`${SYSTEM_BASE}/role/export`, params)
  },
}

export interface RoleForm extends BaseFormType {
  name?: string
  code: string
  order?: number
  data_scope?: number
  status?: number
  description?: string
}

export interface RoleItem extends BaseType, RoleForm {
  id: number
  menus?: MenuItem[]
  depts?: DeptItem[]
}

export interface RolePermissionForm {
  role_ids: number[]
  menu_ids: number[]
  dept_ids: number[]
  data_scope: number
}

/* 菜单表（角色权限回显用） */
export interface MenuItem extends BaseType {
  id?: number
  name?: string
  type?: number
  permission?: string
  parent_id?: number
  status?: number
  description?: string
  children?: MenuItem[]
}

/* 部门树（角色权限回显用） */
export interface DeptItem extends BaseType {
  id?: number
  name?: string
  parent_id?: number
  children?: DeptItem[]
}
