import { http } from '@/http'

const MONITOR_BASE = '/monitor'

/**
 * 资源管理 API
 * 与 web 端 module_monitor/resource.ts 对齐（补全完整字段）
 */
export const ResourceAPI = {
  getPage(params?: Record<string, any>): Promise<PageResult<ResourceItem>> {
    return http.Get(`${MONITOR_BASE}/resource/list`, params)
  },
  getDetail(id: number): Promise<ResourceItem> {
    return http.Get(`${MONITOR_BASE}/resource/detail/${id}`)
  },
  remove(ids: number[]): Promise<void> {
    return http.Delete(`${MONITOR_BASE}/resource/delete`, { ids: JSON.stringify(ids) })
  },
  upload(path: string, filePath: string, fileName: string): Promise<ResourceUploadSchema> {
    return http.Post(`${MONITOR_BASE}/resource/upload`, { path, file_path: filePath, file_name: fileName })
  },
  download(id: number): Promise<{ url: string }> {
    return http.Get(`${MONITOR_BASE}/resource/download`, { params: { id } })
  },
  mkdir(path: string, name: string): Promise<void> {
    return http.Post(`${MONITOR_BASE}/resource/mkdir`, { path, name })
  },
  rename(id: number, newName: string): Promise<void> {
    return http.Post(`${MONITOR_BASE}/resource/rename`, { id, new_name: newName })
  },
  move(id: number, targetPath: string): Promise<void> {
    return http.Post(`${MONITOR_BASE}/resource/move`, { id, target_path: targetPath })
  },
  copy(id: number, targetPath: string): Promise<void> {
    return http.Post(`${MONITOR_BASE}/resource/copy`, { id, target_path: targetPath })
  },
}

export interface ResourceItem {
  id: number
  name: string
  file_url: string
  relative_path: string
  is_file: boolean
  is_dir: boolean
  size?: number | null
  created_time?: string
  modified_time?: string
  is_hidden?: boolean
}

export interface ResourceUploadSchema {
  file_path?: string
  file_name?: string
  origin_name?: string
  file_url?: string
}
