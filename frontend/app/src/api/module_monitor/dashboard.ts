import { http } from '@/http'

const MONITOR_BASE = '/monitor'

/**
 * 运营大盘 API
 * 与 web 端 module_monitor/dashboard.ts 对齐
 */
export const DashboardAPI = {
  getStats(): Promise<DashboardStats> {
    return http.Get(`${MONITOR_BASE}/online/stats`)
  },
}

export interface RecentLoginItem {
  username: string
  status: number
  login_time: string
  login_ip?: string
  login_location?: string
}

export interface DashboardStats {
  online_users: number
  total_users: number
  today_login_count: number
  today_unique_users: number
  week_user_created: number
  recent_logins: RecentLoginItem[]
}
