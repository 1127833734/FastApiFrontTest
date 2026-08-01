/**
 * 代码生成 API 模块（对应后端 module_generator 插件）
 */
import { http } from '@/http'

const GEN_BASE = '/generator/gencode'

export const GencodeAPI = {
  /** 查询业务表列表 */
  getPage(params?: Record<string, any>): Promise<PageResult<GenTableItem>> {
    return http.Get(`${GEN_BASE}/list`, params)
  },
  /** 查询数据库表列表 */
  getDbTables(params?: Record<string, any>): Promise<PageResult<DbTableItem>> {
    return http.Get(`${GEN_BASE}/db/list`, params)
  },
  /** 导入表结构 */
  importTable(tableName: string): Promise<void> {
    return http.Post(`${GEN_BASE}/import`, { table_name: tableName })
  },
  /** 获取业务表详情 */
  getDetail(id: number): Promise<GenTableItem> {
    return http.Get(`${GEN_BASE}/detail/${id}`)
  },
  /** 编辑业务表 */
  update(id: number, data: Partial<GenTableItem>): Promise<GenTableItem> {
    return http.Put(`${GEN_BASE}/update/${id}`, data)
  },
  /** 删除业务表 */
  remove(ids: number[]): Promise<void> {
    return http.Delete(`${GEN_BASE}/delete`, { ids: JSON.stringify(ids) })
  },
  /** 批量生成代码 (返回 zip) */
  batchGenerate(ids: number[]): Promise<unknown> {
    return http.Patch(`${GEN_BASE}/batch/output`, { ids })
  },
  /** 预览代码 */
  preview(id: number): Promise<string | Record<string, any>> {
    return http.Get(`${GEN_BASE}/preview/${id}`)
  },
  /** 同步数据库 */
  syncDb(tableName: string): Promise<void> {
    return http.Post(`${GEN_BASE}/sync_db/${tableName}`)
  },
}

/* ==================== 类型定义 ==================== */

export interface GenTableItem {
  id: number
  table_name: string
  table_comment?: string
  class_name?: string
  package_name?: string
  module_name?: string
  business_name?: string
  function_name?: string
  sub_table_name?: string
  sub_table_fk_name?: string
  parent_menu_id?: number
  description?: string
  created_time?: string
  updated_time?: string
}

export interface DbTableItem {
  table_name?: string
  name?: string
  table_comment?: string
  comment?: string
}
