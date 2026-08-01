/**
 * 工作流节点类型 API 模块（对应后端 `plugin.module_task.workflow.nodes`）
 */
import { http } from '@/http'

const NODES_BASE = '/task/workflow/nodes'

/* ==================== 工作流节点类型 ==================== */
export const WorkflowNodeTypeAPI = {
  /** 节点选项 */
  getOptions(): Promise<WorkflowNodeTypeOption[]> {
    return http.Get(`${NODES_BASE}/options`)
  },
  /** 节点详情 */
  getDetail(id: number): Promise<WorkflowNodeTypeItem> {
    return http.Get(`${NODES_BASE}/detail/${id}`)
  },
  /** 节点列表 */
  getPage(params?: Record<string, any>): Promise<PageResult<WorkflowNodeTypeItem>> {
    return http.Get(`${NODES_BASE}/list`, params)
  },
  /** 创建节点 */
  create(data: WorkflowNodeTypeForm): Promise<WorkflowNodeTypeItem> {
    return http.Post(`${NODES_BASE}/create`, data)
  },
  /** 更新节点 */
  update(id: number, data: WorkflowNodeTypeForm): Promise<WorkflowNodeTypeItem> {
    return http.Put(`${NODES_BASE}/update/${id}`, data)
  },
  /** 删除节点 */
  remove(ids: number[]): Promise<void> {
    return http.Delete(`${NODES_BASE}/delete`, { ids: JSON.stringify(ids) })
  },
  /** 节点选择列表 */
  getSelect(): Promise<WorkflowNodeTypeOption[]> {
    return http.Get(`${NODES_BASE}/select`)
  },
}

/* ==================== 类型定义 ==================== */

export interface WorkflowNodeTypeOption {
  value: number
  label: string
  type: string
}

export interface WorkflowNodeTypeForm {
  name: string
  type: string
  handler_path?: string
  params_schema?: Record<string, any>
  description?: string
}

export interface WorkflowNodeTypeItem extends WorkflowNodeTypeForm {
  id: number
  created_time?: string
  updated_time?: string
}
