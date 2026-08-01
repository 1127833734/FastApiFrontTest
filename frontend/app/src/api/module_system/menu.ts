import type { BatchSetStatus } from './user'
import { http } from '@/http'

const SYSTEM_BASE = '/system'

/**
 * 菜单管理 API
 * 与 web 端 module_system/menu.ts 对齐（完整字段定义）
 */
export const MenuAPI = {
  getTree(params?: MenuQuery): Promise<MenuItem[]> {
    return http.Get(`${SYSTEM_BASE}/menu/tree`, params)
  },
  getDetail(id: number): Promise<MenuItem> {
    return http.Get(`${SYSTEM_BASE}/menu/detail/${id}`)
  },
  create(data: MenuForm): Promise<MenuItem> {
    return http.Post(`${SYSTEM_BASE}/menu/create`, data)
  },
  update(id: number, data: MenuForm): Promise<MenuItem> {
    return http.Put(`${SYSTEM_BASE}/menu/update/${id}`, data)
  },
  remove(ids: number[]): Promise<void> {
    return http.Delete(`${SYSTEM_BASE}/menu/delete`, { ids: JSON.stringify(ids) })
  },
  batchStatus(data: BatchSetStatus): Promise<void> {
    return http.Patch(`${SYSTEM_BASE}/menu/status/batch`, data)
  },
}

export interface MenuQuery {
  name?: string
  status?: number
  type?: number
  menu_client?: 'web' | 'app'
}

export interface MenuForm extends BaseFormType {
  name?: string
  type: number
  icon?: string
  order?: number
  permission?: string
  route_name?: string
  route_path?: string
  component_path?: string
  redirect?: string
  parent_id?: number
  keep_alive?: boolean
  hidden?: boolean
  always_show?: boolean
  title?: string
  params?: { key: string, value: string }[]
  affix?: boolean
  link?: string
  is_iframe?: boolean
  is_hide_tab?: boolean
  active_path?: string
  show_badge?: boolean
  show_text_badge?: string
  scope?: 'web' | 'app'
  client?: 'pc' | 'app'
  status?: number
  description?: string
}

export interface MenuItem extends BaseType, MenuForm {
  id: number
  parent_name?: string
  children?: MenuItem[]
}
