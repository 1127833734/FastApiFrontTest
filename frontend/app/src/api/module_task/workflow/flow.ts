/**
 * 工作流流程 API 模块（对应后端 `plugin.module_task.workflow.flow`）
 * 与 web 端 module_task/workflow/flow.ts 对齐（完整字段定义）
 */
import { http } from '@/http'

const FLOW_BASE = '/task/workflow/flow'

/* ==================== 流程编排 ==================== */
export const WorkflowAPI = {
  /** 工作流详情 */
  getDetail(id: number): Promise<WorkflowItem> {
    return http.Get(`${FLOW_BASE}/detail/${id}`)
  },
  /** 工作流列表 */
  getPage(params?: Record<string, any>): Promise<PageResult<WorkflowItem>> {
    return http.Get(`${FLOW_BASE}/list`, params)
  },
  /** 创建工作流 */
  create(data: WorkflowForm): Promise<WorkflowItem> {
    return http.Post(`${FLOW_BASE}/create`, data)
  },
  /** 更新工作流 */
  update(id: number, data: WorkflowForm): Promise<WorkflowItem> {
    return http.Put(`${FLOW_BASE}/update/${id}`, data)
  },
  /** 删除工作流 */
  remove(ids: number[]): Promise<void> {
    return http.Delete(`${FLOW_BASE}/delete`, { ids: JSON.stringify(ids) })
  },
  /** 发布工作流 */
  publish(id: number): Promise<void> {
    return http.Post(`${FLOW_BASE}/publish/${id}`)
  },
  /** 执行工作流 */
  execute(data: WorkflowExecuteForm): Promise<WorkflowExecuteResult> {
    return http.Post(`${FLOW_BASE}/execute`, data)
  },
}

/* ==================== 类型定义 ==================== */

export interface WorkflowPageQuery extends PageQuery {
  name?: string
  code?: string
  status?: number
}

export interface WorkflowForm {
  name: string
  description?: string
  nodes?: WorkflowNode[]
  edges?: WorkflowEdge[]
}

export interface WorkflowItem extends WorkflowForm {
  id: number
  status?: string
  version?: number
  created_time?: string
  updated_time?: string
}

export interface WorkflowPublishForm {
  remark?: string
}

export interface WorkflowExecuteForm {
  workflow_id: number
  variables?: Record<string, any>
  business_key?: string
  job_id?: number
}

export interface WorkflowExecuteResult {
  workflow_id: number
  workflow_name: string
  status: number
  start_time?: string
  end_time?: string
  variables?: Record<string, any>
  node_results?: Record<string, any>
  error?: string
}

export interface WorkflowNode {
  id?: string
  type: string
  label?: string
  position?: { x: number, y: number }
  data?: Record<string, any>
}

export interface WorkflowEdge {
  id?: string
  source: string
  target: string
  label?: string
  condition?: string
}
