import { http } from '@/http'

const MONITOR_BASE = '/monitor'

/**
 * 服务器监控 API
 * 与 web 端 module_monitor/server.ts 对齐（补全完整字段）
 */
export const ServerAPI = {
  getInfo(): Promise<ServerInfo> {
    return http.Get(`${MONITOR_BASE}/server/info`)
  },
}

export interface CpuInfo {
  used_percent: number
  cores: number
  model: string
  cpu_num?: number
  used?: number
  sys?: number
  free?: number
}

export interface MemoryInfo {
  total: string
  used: string
  used_percent: number
  free?: string
  usage?: number
}

export interface DiskInfo {
  total: string
  used: string
  used_percent: number
}

export interface OsInfo {
  name: string
  hostname: string
  uptime: string
}

export interface JvmInfo {
  version: string
  used: string
  used_percent: number
}

export interface ServerInfo {
  cpu?: CpuInfo
  memory?: MemoryInfo
  disk?: DiskInfo
  os?: OsInfo
  jvm?: JvmInfo
}
