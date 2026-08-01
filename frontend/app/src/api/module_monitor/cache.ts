import { http } from '@/http'

const MONITOR_BASE = '/monitor'

/**
 * 缓存监控 API
 * 与 web 端 module_monitor/cache.ts 对齐
 */
export const CacheAPI = {
  getInfo(): Promise<CacheInfo> {
    return http.Get(`${MONITOR_BASE}/cache/info`)
  },
  getNames(): Promise<string[]> {
    return http.Get(`${MONITOR_BASE}/cache/get/names`)
  },
  getKeys(cacheName: string): Promise<string[]> {
    return http.Get(`${MONITOR_BASE}/cache/get/keys/${cacheName}`)
  },
  getValue(cacheName: string, cacheKey: string): Promise<unknown> {
    return http.Get(`${MONITOR_BASE}/cache/get/value/${cacheName}/${cacheKey}`)
  },
  deleteName(cacheName: string): Promise<void> {
    return http.Delete(`${MONITOR_BASE}/cache/delete/name/${cacheName}`)
  },
  deleteKey(cacheKey: string): Promise<void> {
    return http.Delete(`${MONITOR_BASE}/cache/delete/key/${cacheKey}`)
  },
  clear(): Promise<void> {
    return http.Delete(`${MONITOR_BASE}/cache/clear`)
  },
}

export interface CacheInfo {
  db_size?: number
  command_stats?: Record<string, any>[]
  info?: Record<string, any>
  // computed from info dict
  keys_count?: number
  hit_rate?: string
  used_memory?: string
}

export interface CommandStats {
  name: string
  value: string
}

export interface RedisInfo {
  redis_version: string
  redis_mode: string
  tcp_port: number
  connected_clients: number
  uptime_in_days: number
  used_memory_human: string
  maxmemory_human: string
  aof_enabled: string
  instantaneous_input_kbps: number
  instantaneous_output_kbps: number
}
