import type { BatchSetStatus } from './user'
import { http } from '@/http'

const SYSTEM_BASE = '/system'

/**
 * 部门管理 API
 * 与 web 端 module_system/dept.ts 对齐（完整字段定义）
 */
export const DeptAPI = {
  getTree(search?: DeptQuery): Promise<DeptItem[]> {
    return http.Get(`${SYSTEM_BASE}/dept/tree`, search)
  },
  getDetail(id: number): Promise<DeptItem> {
    return http.Get(`${SYSTEM_BASE}/dept/detail/${id}`)
  },
  create(data: DeptForm): Promise<DeptItem> {
    return http.Post(`${SYSTEM_BASE}/dept/create`, data)
  },
  update(id: number, data: DeptForm): Promise<DeptItem> {
    return http.Put(`${SYSTEM_BASE}/dept/update/${id}`, data)
  },
  remove(ids: number[]): Promise<void> {
    return http.Delete(`${SYSTEM_BASE}/dept/delete`, { ids: JSON.stringify(ids) })
  },
  batchStatus(data: BatchSetStatus): Promise<void> {
    return http.Patch(`${SYSTEM_BASE}/dept/status/batch`, data)
  },
}

export interface DeptQuery {
  name?: string
  status?: string
}

export interface DeptForm extends BaseFormType {
  name?: string
  code: string
  parent_id?: number
  order?: number
  leader?: string
  phone?: string
  email?: string
  status?: number
  description?: string
}

export interface DeptItem extends BaseType, DeptForm {
  id: number
  parent_name?: string
  children?: DeptItem[]
}
