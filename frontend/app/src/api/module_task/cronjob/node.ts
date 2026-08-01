/**
 * 任务节点 API 模块（对应后端 `plugin.module_task.cronjob.node`）
 */
import { http } from '@/http'

const NODE_BASE = '/task/cronjob/node'

/* ==================== 任务节点 ==================== */
export const NodeAPI = {
  /** 获取节点列表（选项） */
  getOptions(): Promise<NodeOption[]> {
    return http.Get(`${NODE_BASE}/options`)
  },
  /** 获取节点详情 */
  getDetail(id: number): Promise<NodeItem> {
    return http.Get(`${NODE_BASE}/detail/${id}`)
  },
  /** 节点分页列表 */
  getPage(params?: Record<string, any>): Promise<PageResult<NodeItem>> {
    return http.Get(`${NODE_BASE}/list`, params)
  },
  /** 创建节点 */
  create(data: NodeForm): Promise<NodeItem> {
    return http.Post(`${NODE_BASE}/create`, data)
  },
  /** 修改节点 */
  update(id: number, data: NodeForm): Promise<NodeItem> {
    return http.Put(`${NODE_BASE}/update/${id}`, data)
  },
  /** 删除节点 */
  remove(ids: number[]): Promise<void> {
    return http.Delete(`${NODE_BASE}/delete`, { ids: JSON.stringify(ids) })
  },
  /** 清空节点 */
  clear(_id?: number): Promise<void> {
    return http.Delete(`${NODE_BASE}/clear`)
  },
  /** 调试节点 */
  execute(id: number): Promise<unknown> {
    return http.Post(`${NODE_BASE}/execute/${id}`)
  },
  /** 批量设置节点状态 */
  batchStatus(data: { ids: number[], status: number }): Promise<void> {
    return http.Patch(`${NODE_BASE}/status/batch`, data)
  },
}

/* ==================== 类型定义 ==================== */

export interface NodeOption {
  value: number
  label: string
  path: string
}

export interface NodeForm {
  name: string
  host: string
  port: number
  type: string
  description?: string
}

export interface NodeItem extends NodeForm {
  id: number
  status?: string
  task_count?: number
  created_time?: string
  updated_time?: string
}
