import { TicketAPI } from '@/api/module_system/ticket'

/**
 * 缓存的请求结果
 */
interface CachedData<T> {
  data: T
  timestamp: number
}

/**
 * 请求中标记（防重复并发请求）
 */
const pendingRequests = new Map<string, Promise<any>>()

/**
 * 本地缓存存储
 */
const cacheStore = new Map<string, CachedData<any>>()

/** 默认缓存有效期（30秒） */
const DEFAULT_TTL = 30_000

/**
 * 带缓存的请求 composable
 *
 * 解决多个页面重复请求同一接口的问题（如 work 和 mine 页面都调用工单统计）。
 * 提供本地内存缓存 + 并发去重 + TTL 过期机制。
 *
 * @example
 * ```ts
 * const { getCached } = useCachedRequest()
 *
 * // 多页面共享缓存，30秒内不重复请求
 * const stats = await getCached('ticket-stats', () => fetchTicketStats(), 30_000)
 * ```
 */
export function useCachedRequest() {
  /**
   * 获取带缓存的数据
   *
   * @param key 缓存键
   * @param fetcher 数据获取函数
   * @param ttl 缓存有效期（毫秒），默认 30 秒
   * @returns 数据
   */
  async function getCached<T>(key: string, fetcher: () => Promise<T>, ttl = DEFAULT_TTL): Promise<T> {
    // 检查缓存是否有效
    const cached = cacheStore.get(key)
    if (cached && Date.now() - cached.timestamp < ttl) {
      return cached.data as T
    }

    // 检查是否有进行中的相同请求
    const pending = pendingRequests.get(key)
    if (pending) {
      return pending as Promise<T>
    }

    // 发起新请求
    const promise = fetcher()
      .then((data) => {
        cacheStore.set(key, { data, timestamp: Date.now() })
        pendingRequests.delete(key)
        return data
      })
      .catch((error) => {
        pendingRequests.delete(key)
        throw error
      })

    pendingRequests.set(key, promise)
    return promise
  }

  /** 强制刷新缓存 */
  async function refresh<T>(key: string, fetcher: () => Promise<T>): Promise<T> {
    cacheStore.delete(key)
    return getCached(key, fetcher, 0)
  }

  /** 清除指定缓存 */
  function invalidate(key: string): void {
    cacheStore.delete(key)
  }

  /** 清除所有缓存 */
  function clearAll(): void {
    cacheStore.clear()
  }

  return {
    getCached,
    refresh,
    invalidate,
    clearAll,
  }
}

/**
 * 工单统计缓存（work 和 mine 页面共享）
 */
export interface TicketStats {
  pending: number
  processing: number
  done: number
}

/**
 * 获取工单统计（带缓存，多页面共享）
 *
 * 缓存键 'ticket-stats'，TTL 30 秒。
 * work 页面和 mine 页面切换时不会重复请求。
 */
export async function getTicketStats(): Promise<TicketStats> {
  const { getCached } = useCachedRequest()
  return getCached('ticket-stats', async () => {
    const [pending, processing, done] = await Promise.allSettled([
      TicketAPI.getPage({ page_no: 1, page_size: 1, status: '0' }),
      TicketAPI.getPage({ page_no: 1, page_size: 1, status: '1' }),
      TicketAPI.getPage({ page_no: 1, page_size: 1, status: '2' }),
    ])
    return {
      pending: pending.status === 'fulfilled' ? (pending.value.total || 0) : 0,
      processing: processing.status === 'fulfilled' ? (processing.value.total || 0) : 0,
      done: done.status === 'fulfilled' ? (done.value.total || 0) : 0,
    }
  })
}
