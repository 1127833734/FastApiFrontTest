/**
 * 示例 API 模块（对应后端 module_example 插件）
 */
import { http } from '@/http'

const DEMO_BASE = '/example/demo'

export const DemoAPI = {
  /** 示例分页列表 */
  getPage(query?: DemoPageQuery): Promise<PageResult<DemoTable>> {
    return http.Get(`${DEMO_BASE}/list`, query)
  },
  /** 示例详情 */
  getDetail(id: number): Promise<DemoTable> {
    return http.Get(`${DEMO_BASE}/detail/${id}`)
  },
  /** 创建示例 */
  create(data: DemoForm): Promise<void> {
    return http.Post(`${DEMO_BASE}/create`, data)
  },
  /** 更新示例 */
  update(id: number, data: DemoForm): Promise<void> {
    return http.Put(`${DEMO_BASE}/update/${id}`, data)
  },
  /** 删除示例 */
  remove(ids: number[]): Promise<void> {
    return http.Delete(`${DEMO_BASE}/delete`, { ids: JSON.stringify(ids) })
  },
  /** 批量设置示例状态 */
  batchStatus(data: BatchType): Promise<void> {
    return http.Patch(`${DEMO_BASE}/status/batch`, data)
  },
  /** 导出示例 */
  exportDemo(query?: DemoPageQuery): Promise<unknown> {
    return http.Post(`${DEMO_BASE}/export`, query)
  },
  /** 下载导入模板 */
  downloadTemplate(): Promise<unknown> {
    return http.Post(`${DEMO_BASE}/download/template`)
  },
  /** 导入示例数据 */
  importDemo(body: Record<string, any>): Promise<void> {
    return http.Post(`${DEMO_BASE}/import`, body, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })
  },
}

/* ==================== 类型定义 ==================== */

export interface DemoPageQuery extends PageQuery {
  name?: string
  status?: number
}

export interface DemoTable {
  id?: number
  name?: string
  status?: number
  description?: string
  int_val?: number
  bigint_val?: number
  float_val?: number
  bool_val?: boolean
  date_val?: string
  time_val?: string
  datetime_val?: string
  text_val?: string
  json_val?: Record<string, any>
}

export interface DemoForm {
  id?: number
  name?: string
  status?: number
  description?: string
  int_val?: number
  bigint_val?: number
  float_val?: number
  bool_val?: boolean
  date_val?: string
  time_val?: Date | string
  datetime_val?: Date | string
  text_val?: string
  json_val?: Record<string, any>
}
