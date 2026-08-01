import { http } from '@/http'

const SYSTEM_BASE = '/system'

/**
 * 参数配置 API
 * 与 web 端 module_system/params.ts 对齐（完整字段定义）
 */
export const ParamsAPI = {
  getInfo(): Promise<ParamsItem[]> {
    return http.Get(`${SYSTEM_BASE}/param/info`)
  },
  update(id: number, data: ParamsForm): Promise<ParamsItem> {
    return http.Put(`${SYSTEM_BASE}/param/update/${id}`, data)
  },
}

export interface ParamsForm extends BaseFormType {
  config_name?: string
  config_key?: string
  config_value?: string
  config_type?: boolean
  status?: number
  description?: string
}

export interface ParamsItem extends BaseType, ParamsForm {}
