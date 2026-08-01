import { http } from '@/http'

const SYSTEM_BASE = '/system'

/**
 * 日志管理 API（操作日志 + 登录日志）
 * 与 web 端 module_system/log.ts 对齐（完整字段定义）
 */
export const OperationLogAPI = {
  getPage(params?: Record<string, any>): Promise<PageResult<OplogItem>> {
    return http.Get(`${SYSTEM_BASE}/log/operation/list`, params)
  },
  remove(ids: number[]): Promise<void> {
    return http.Delete(`${SYSTEM_BASE}/log/operation/delete`, { ids: JSON.stringify(ids) })
  },
  getDetail(id: number): Promise<OplogItem> {
    return http.Get(`${SYSTEM_BASE}/log/operation/detail/${id}`)
  },
  exportLog(params?: Record<string, any>): Promise<unknown> {
    return http.Post(`${SYSTEM_BASE}/log/export`, params)
  },
}

export const LoginLogAPI = {
  getPage(params?: Record<string, any>): Promise<PageResult<LoginLogItem>> {
    return http.Get(`${SYSTEM_BASE}/log/login/list`, params)
  },
  getDetail(id: number): Promise<LoginLogItem> {
    return http.Get(`${SYSTEM_BASE}/log/login/detail/${id}`)
  },
  remove(ids: number[]): Promise<void> {
    return http.Delete(`${SYSTEM_BASE}/log/login/delete`, { ids: JSON.stringify(ids) })
  },
}

export interface OplogItem extends BaseType {
  username?: string
  status?: number
  description?: string
  request_path?: string
  request_method?: string
  request_payload?: Record<string, unknown> | string
  request_ip?: string
  response_code?: number
  response_json?: Record<string, unknown> | string
  process_time?: string
}

export interface LoginLogItem extends BaseType {
  username?: string
  login_ip?: string
  login_location?: string
  request_browser?: string
  request_os?: string
  status?: string | number
  msg?: string
}
