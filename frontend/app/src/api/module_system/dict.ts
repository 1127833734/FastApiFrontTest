import type { BatchSetStatus } from './user'
import { http } from '@/http'

const SYSTEM_BASE = '/system'

/**
 * 字典管理 API
 * 与 web 端 module_system/dict.ts 对齐（完整字段定义）
 */
export const DictAPI = {
  getTypePage(params?: Record<string, any>): Promise<PageResult<DictTypeItem>> {
    return http.Get(`${SYSTEM_BASE}/dict/type/list`, params)
  },
  getTypeDetail(id: number): Promise<DictTypeItem> {
    return http.Get(`${SYSTEM_BASE}/dict/type/detail/${id}`)
  },
  createType(data: DictTypeForm): Promise<DictTypeItem> {
    return http.Post(`${SYSTEM_BASE}/dict/type/create`, data)
  },
  updateType(id: number, data: DictTypeForm): Promise<DictTypeItem> {
    return http.Put(`${SYSTEM_BASE}/dict/type/update/${id}`, data)
  },
  removeType(ids: number[]): Promise<void> {
    return http.Delete(`${SYSTEM_BASE}/dict/type/delete`, { ids: JSON.stringify(ids) })
  },
  batchTypeStatus(data: BatchSetStatus): Promise<void> {
    return http.Patch(`${SYSTEM_BASE}/dict/type/status/batch`, data)
  },
  getTypeOptions(): Promise<DictTypeItem[]> {
    return http.Get(`${SYSTEM_BASE}/dict/type/optionselect`)
  },
  getDataPage(params?: Record<string, any>): Promise<PageResult<DictDataItem>> {
    return http.Get(`${SYSTEM_BASE}/dict/data/list`, params)
  },
  getDataDetail(id: number): Promise<DictDataItem> {
    return http.Get(`${SYSTEM_BASE}/dict/data/detail/${id}`)
  },
  createData(data: DictDataForm): Promise<DictDataItem> {
    return http.Post(`${SYSTEM_BASE}/dict/data/create`, data)
  },
  updateData(id: number, data: DictDataForm): Promise<DictDataItem> {
    return http.Put(`${SYSTEM_BASE}/dict/data/update/${id}`, data)
  },
  removeData(ids: number[]): Promise<void> {
    return http.Delete(`${SYSTEM_BASE}/dict/data/delete`, { ids: JSON.stringify(ids) })
  },
  batchDataStatus(data: BatchSetStatus): Promise<void> {
    return http.Patch(`${SYSTEM_BASE}/dict/data/status/batch`, data)
  },
  getDataByType(dictType: string): Promise<DictDataItem[]> {
    return http.Get(`${SYSTEM_BASE}/dict/data/info/${dictType}`)
  },
}

export interface DictTypeForm extends BaseFormType {
  dict_name?: string
  dict_type?: string
  status?: number
  description?: string
}

export interface DictTypeItem extends BaseType, DictTypeForm {
  id: number
  dict_type: string
}

export interface DictDataForm extends BaseFormType {
  dict_sort?: number
  dict_label?: string
  dict_value?: string
  dict_type?: string
  dict_type_id?: number
  css_class?: string
  list_class?: string
  is_default?: boolean | string
  status?: number
  description?: string
}

export interface DictDataItem extends BaseType, DictDataForm {}
