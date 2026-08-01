/**
 * 定时任务 API 模块（对应后端 `plugin.module_task.cronjob.job`）
 * 包含: 调度器管理 / 任务管理 / 任务执行日志
 */
import { http } from '@/http'

const JOB_BASE = '/task/cronjob/job'

/* ==================== 调度器管理 ==================== */
export const SchedulerAPI = {
  /** 获取调度器状态 */
  getStatus(): Promise<SchedulerStatus> {
    return http.Get(`${JOB_BASE}/scheduler/status`)
  },
  /** 获取调度器任务列表 */
  getJobs(): Promise<SchedulerJob[]> {
    return http.Get(`${JOB_BASE}/scheduler/jobs`)
  },
  /** 启动调度器 */
  start(): Promise<void> {
    return http.Post(`${JOB_BASE}/scheduler/start`)
  },
  /** 暂停调度器 */
  pause(): Promise<void> {
    return http.Post(`${JOB_BASE}/scheduler/pause`)
  },
  /** 恢复调度器 */
  resume(): Promise<void> {
    return http.Post(`${JOB_BASE}/scheduler/resume`)
  },
  /** 关闭调度器 */
  shutdown(): Promise<void> {
    return http.Post(`${JOB_BASE}/scheduler/shutdown`)
  },
  /** 清空所有任务 */
  clear(): Promise<void> {
    return http.Delete(`${JOB_BASE}/scheduler/jobs/clear`)
  },
  /** 获取调度器控制台信息 */
  getConsole(): Promise<unknown> {
    return http.Get(`${JOB_BASE}/scheduler/console`)
  },
}

/* ==================== 任务管理 ==================== */
export const JobAPI = {
  /** 暂停任务 */
  pause(jobId: string): Promise<void> {
    return http.Post(`${JOB_BASE}/task/pause/${jobId}`)
  },
  /** 恢复任务 */
  resume(jobId: string): Promise<void> {
    return http.Post(`${JOB_BASE}/task/resume/${jobId}`)
  },
  /** 立即执行任务 */
  run(jobId: string): Promise<void> {
    return http.Post(`${JOB_BASE}/task/run/${jobId}`)
  },
  /** 修改任务 */
  modify(jobId: string, data: Record<string, any>): Promise<void> {
    return http.Put(`${JOB_BASE}/task/modify/${jobId}`, data)
  },
  /** 移除任务 */
  remove(jobId: string): Promise<void> {
    return http.Delete(`${JOB_BASE}/task/remove/${jobId}`)
  },
}

/* ==================== 任务执行日志 ==================== */
export const JobLogAPI = {
  /** 查询执行日志列表 */
  getPage(params?: Record<string, any>): Promise<PageResult<JobLogItem>> {
    return http.Get(`${JOB_BASE}/log/list`, params)
  },
  /** 获取执行日志详情 */
  getDetail(id: number): Promise<JobLogItem> {
    return http.Get(`${JOB_BASE}/log/detail/${id}`)
  },
  /** 删除执行日志 */
  remove(ids: number[]): Promise<void> {
    return http.Delete(`${JOB_BASE}/log/delete`, { ids: JSON.stringify(ids) })
  },
}

/* ==================== 类型定义 ==================== */

export interface SchedulerStatus {
  status?: string
  is_running?: boolean
  running: boolean
  job_count: number
}

export interface SchedulerJob {
  id: string
  name: string
  status?: string
  next_run_time?: string
  trigger?: string
  func?: string
  args?: any[]
}

export interface JobLogItem {
  id: number
  job_name?: string
  job_id?: string
  status?: string
  result?: string
  error_msg?: string
  start_time?: string
  end_time?: string
  created_time?: string
}
