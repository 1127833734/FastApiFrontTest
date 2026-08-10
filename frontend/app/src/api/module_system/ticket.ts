import { http } from '@/http'

const SYSTEM_BASE = '/system'

/**
 * 工单管理 API
 * 与 web 端 module_system/ticket.ts 对齐（完整字段定义）
 */
export const TicketAPI = {
  getPage(params?: Record<string, any>): Promise<PageResult<TicketItem>> {
    return http.Get(`${SYSTEM_BASE}/ticket/list`, params)
  },
  getDetail(id: number): Promise<TicketItem> {
    return http.Get(`${SYSTEM_BASE}/ticket/detail/${id}`)
  },
  create(data: TicketForm): Promise<TicketItem> {
    return http.Post(`${SYSTEM_BASE}/ticket/create`, data)
  },
  update(id: number, data: Record<string, any>): Promise<TicketItem> {
    return http.Put(`${SYSTEM_BASE}/ticket/update/${id}`, data)
  },
  remove(ids: number[]): Promise<void> {
    return http.Delete(`${SYSTEM_BASE}/ticket/delete`, { ids: JSON.stringify(ids) })
  },
  batch(data: { ids: number[], status: number, assigned_id?: number }): Promise<void> {
    return http.Put(`${SYSTEM_BASE}/ticket/batch`, data)
  },
  exportTickets(params?: Record<string, any>): Promise<unknown> {
    return http.Post(`${SYSTEM_BASE}/ticket/export`, params)
  },
  getComments(ticketId: number, params?: Record<string, any>): Promise<PageResult<TicketComment>> {
    return http.Get(`${SYSTEM_BASE}/ticket/${ticketId}/comments`, params)
  },
  createComment(ticketId: number, data: { content: string }): Promise<TicketComment> {
    return http.Post(`${SYSTEM_BASE}/ticket/${ticketId}/comments`, data)
  },
}

export interface TicketForm extends BaseFormType {
  title: string
  ticket_content?: string
  summary?: string
  ticket_type: string
  images?: string
  reply?: string
  assigned_id?: number
  status?: number
  description?: string
}

export interface TicketItem extends BaseType {
  title?: string
  ticket_content?: string
  summary?: string
  ticket_type?: string
  status?: string | number
  assigned_id?: number
  assigned_by?: CommonType
  images?: string
  reply?: string
  description?: string
}

export interface TicketComment extends BaseType {
  ticket_id?: number
  user_id?: number
  username?: string
  content?: string
  created_by_name?: string
}
