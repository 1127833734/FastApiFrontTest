import { http } from '@/http'

const MONITOR_BASE = '/monitor'

/**
 * 在线用户 API
 * 与 web 端 module_monitor/online.ts 对齐（补全完整字段）
 */
export const OnlineAPI = {
  getPage(params?: Record<string, any>): Promise<PageResult<OnlineUserItem>> {
    return http.Get(`${MONITOR_BASE}/online/list`, params)
  },
  getCurrent(): Promise<OnlineUserItem[]> {
    return http.Get(`${MONITOR_BASE}/online/current`)
  },
  forceLogout(token: string): Promise<void> {
    return http.Delete(`${MONITOR_BASE}/online/delete`, { token })
  },
  clear(): Promise<void> {
    return http.Delete(`${MONITOR_BASE}/online/clear`)
  },
  getStats(): Promise<DashboardStats> {
    return http.Get(`${MONITOR_BASE}/online/stats`)
  },
}

export interface OnlineUserItem {
  session_id?: string
  user_id?: number
  is_superuser?: boolean
  user_name?: string
  name?: string
  ipaddr?: string
  login_location?: string
  login_time?: string
  login_type?: string
  os?: string
  browser?: string
  user_status?: number
}

export interface DashboardStats {
  online_users: number
  total_users: number
  today_login_count: number
  today_unique_users: number
  week_user_created: number
  recent_logins: RecentLoginItem[]
}

export interface RecentLoginItem {
  username: string
  status: number
  login_time: string
  login_ip?: string
  login_location?: string
}
