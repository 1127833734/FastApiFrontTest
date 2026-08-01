import { http } from '@/http'

const SYSTEM_BASE = '/system'

/**
 * 版本发布管理 API
 * 与 web 端 module_system/version.ts 对齐（完整字段定义）
 */
export const VersionAPI = {
  getPage(params?: Record<string, any>): Promise<PageResult<VersionItem>> {
    return http.Get(`${SYSTEM_BASE}/versions/list`, params)
  },
  /** 获取已发布版本列表（无需认证） */
  getPublished(): Promise<VersionItem[]> {
    return http.Get(`${SYSTEM_BASE}/versions/published`)
  },
  getDetail(id: number): Promise<VersionItem> {
    return http.Get(`${SYSTEM_BASE}/versions/detail/${id}`)
  },
  create(data: VersionForm): Promise<VersionItem> {
    return http.Post(`${SYSTEM_BASE}/versions/create`, data)
  },
  update(id: number, data: VersionForm): Promise<VersionItem> {
    return http.Put(`${SYSTEM_BASE}/versions/update/${id}`, data)
  },
  remove(ids: number[]): Promise<void> {
    return http.Delete(`${SYSTEM_BASE}/versions/delete`, { ids: JSON.stringify(ids) })
  },
  setStatus(id: number, status: number): Promise<void> {
    return http.Put(`${SYSTEM_BASE}/versions/${id}/status`, { status })
  },
}

export interface VersionForm extends BaseFormType {
  version?: string
  title?: string
  date?: string
  content?: string
  description?: string
  sort?: number
  status?: number
  require_re_login?: boolean
}

export interface VersionItem extends BaseType, VersionForm {}
