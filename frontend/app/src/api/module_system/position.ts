import type { BatchSetStatus } from './user'
import { http } from '@/http'

const SYSTEM_BASE = '/system'

/**
 * 岗位管理 API
 * 与 web 端 module_system/position.ts 对齐（完整字段定义）
 */
export const PositionAPI = {
  getPage(params?: Record<string, any>): Promise<PageResult<PositionItem>> {
    return http.Get(`${SYSTEM_BASE}/position/list`, params)
  },
  getDetail(id: number): Promise<PositionItem> {
    return http.Get(`${SYSTEM_BASE}/position/detail/${id}`)
  },
  create(data: PositionForm): Promise<PositionItem> {
    return http.Post(`${SYSTEM_BASE}/position/create`, data)
  },
  update(id: number, data: PositionForm): Promise<PositionItem> {
    return http.Put(`${SYSTEM_BASE}/position/update/${id}`, data)
  },
  remove(ids: number[]): Promise<void> {
    return http.Delete(`${SYSTEM_BASE}/position/delete`, { ids: JSON.stringify(ids) })
  },
  batchStatus(data: BatchSetStatus): Promise<void> {
    return http.Patch(`${SYSTEM_BASE}/position/status/batch`, data)
  },
  getOptions(): Promise<{ value: number, label: string }[]> {
    return http.Get(`${SYSTEM_BASE}/position/options`)
  },
  exportPositions(params?: Record<string, any>): Promise<unknown> {
    return http.Post(`${SYSTEM_BASE}/position/export`, params)
  },
}

export interface PositionForm extends BaseFormType {
  name?: string
  code?: string
  order?: number
  status?: number
  description?: string
}

export interface PositionItem extends BaseType, PositionForm {
  id: number
}
