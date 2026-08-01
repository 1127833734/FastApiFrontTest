<script setup lang="ts">
import type { JobLogItem, SchedulerJob } from '@/api/module_task/cronjob/job'
import type { NodeForm, NodeItem } from '@/api/module_task/cronjob/node'
import { onLoad, onPullDownRefresh } from '@dcloudio/uni-app'
import { ref } from 'vue'
import { JobAPI, JobLogAPI, SchedulerAPI } from '@/api/module_task/cronjob/job'
import { NodeAPI } from '@/api/module_task/cronjob/node'

definePage({
  name: 'work-cronjob',
  style: { navigationBarTitleText: '定时任务' },
})

const toast = useToast()
const jobsLoading = ref(false)
const schedulerRunning = ref(false)
const schedulerJobs = ref<SchedulerJob[]>([])
const activeTab = ref<'jobs' | 'logs' | 'nodes'>('jobs')

// ---- Node management ----
const showNodeForm = ref(false)
const nodeFormTitle = ref('新建节点')
const editingNodeId = ref<number | null>(null)
const nodeForm = reactive<NodeForm & { id?: number }>({
  name: '',
  host: '',
  port: 0,
  type: 'default',
  description: '',
})

const {
  list: nodeList,
  total: nodeTotal,
  loading: nodeLoading,
  pageParams: nodePageParams,
  loadData: loadNodes,
  loadPrev: nodeLoadPrev,
  loadNext: nodeLoadNext,
} = useListPage<NodeItem>({
  fetcher: p => NodeAPI.getPage(p),
  onError: e => toast.error(getErrorMessage(e, '加载节点列表失败')),
})

function openCreateNode() {
  nodeFormTitle.value = '新建节点'
  editingNodeId.value = null
  Object.assign(nodeForm, { name: '', host: '', port: 0, type: 'default', description: '' })
  showNodeForm.value = true
}

async function openEditNode(id: number) {
  nodeFormTitle.value = '编辑节点'
  editingNodeId.value = id
  try {
    const detail = await NodeAPI.getDetail(id)
    Object.assign(nodeForm, { name: detail.name, host: detail.host, port: detail.port, type: detail.type, description: detail.description || '' })
    showNodeForm.value = true
  }
  catch (e) { toast.error(getErrorMessage(e, '获取节点详情失败')) }
}

async function submitNode() {
  if (!nodeForm.name.trim())
    return toast.warning('请输入节点名称')
  if (!nodeForm.host.trim())
    return toast.warning('请输入节点地址')
  try {
    if (editingNodeId.value) {
      await NodeAPI.update(editingNodeId.value, { ...nodeForm })
      toast.success('更新成功')
    }
    else {
      await NodeAPI.create({ ...nodeForm })
      toast.success('创建成功')
    }
    showNodeForm.value = false
    loadNodes()
  }
  catch (e) { toast.error(getErrorMessage(e, '保存失败')) }
}

async function handleDeleteNode(ids: number[]) {
  uni.showModal({
    title: '提示',
    content: '确认删除选中的节点？',
    success: async (res) => {
      if (!res.confirm)
        return
      try {
        await NodeAPI.remove(ids)
        toast.success('删除成功')
        loadNodes()
      }
      catch (e) { toast.error(getErrorMessage(e, '删除失败')) }
    },
  })
}

async function handleClearNode(id: number) {
  uni.showModal({
    title: '提示',
    content: '确认清空该节点上的所有任务？',
    success: async (res) => {
      if (!res.confirm)
        return
      try {
        await NodeAPI.clear(id)
        toast.success('清空成功')
        loadNodes()
      }
      catch (e) { toast.error(getErrorMessage(e, '清空失败')) }
    },
  })
}

async function handleExecuteNode(id: number) {
  try {
    await NodeAPI.execute(id)
    toast.success('节点调试任务已触发')
  }
  catch (e) { toast.error(getErrorMessage(e, '执行失败')) }
}

async function refreshScheduler() {
  jobsLoading.value = true
  try {
    const [status, jobs] = await Promise.all([
      SchedulerAPI.getStatus(),
      SchedulerAPI.getJobs(),
    ])
    schedulerRunning.value = status.running
    schedulerJobs.value = jobs || []
  }
  catch (e) {
    toast.error(getErrorMessage(e, '获取调度器状态失败'))
  }
  finally {
    jobsLoading.value = false
  }
}

async function handleScheduler(action: 'start' | 'pause' | 'resume' | 'shutdown') {
  const labels: Record<string, string> = { start: '启动', pause: '暂停', resume: '恢复', shutdown: '关闭' }
  uni.showModal({
    title: '提示',
    content: `确认${labels[action]}调度器？`,
    success: async (res) => {
      if (!res.confirm)
        return
      try {
        if (action === 'start')
          await SchedulerAPI.start()
        else if (action === 'pause')
          await SchedulerAPI.pause()
        else if (action === 'resume')
          await SchedulerAPI.resume()
        else await SchedulerAPI.shutdown()
        toast.success(`${labels[action]}成功`)
        refreshScheduler()
      }
      catch (e) { toast.error(getErrorMessage(e, '操作失败')) }
    },
  })
}

async function handleTask(action: 'pause' | 'resume' | 'run' | 'remove', jobId: string, jobName: string) {
  const labels: Record<string, string> = { pause: '暂停', resume: '恢复', run: '执行', remove: '移除' }
  const content = action === 'remove' ? `确认移除任务「${jobName}」？` : `确认${labels[action]}任务「${jobName}」？`
  uni.showModal({
    title: '提示',
    content,
    success: async (res) => {
      if (!res.confirm)
        return
      try {
        if (action === 'pause') {
          await JobAPI.pause(jobId)
        }
        else if (action === 'resume') {
          await JobAPI.resume(jobId)
        }
        else if (action === 'run') {
          await JobAPI.run(jobId)
          toast.success('任务已触发执行')
        }
        else {
          await JobAPI.remove(jobId)
        }
        if (action !== 'run')
          toast.success(`${labels[action]}成功`)
        refreshScheduler()
      }
      catch (e) { toast.error(getErrorMessage(e, '操作失败')) }
    },
  })
}

const {
  list: logList,
  total: logTotal,
  loading: logLoading,
  pageParams: logPageParams,
  loadData: loadLogs,
  loadPrev: logLoadPrev,
  loadNext: logLoadNext,
} = useListPage<JobLogItem>({
  fetcher: p => JobLogAPI.getPage(p),
  onError: e => toast.error(getErrorMessage(e, '加载日志失败')),
})

async function handleClearLogs(ids: number[]) {
  uni.showModal({
    title: '提示',
    content: '确认删除这些执行日志？',
    success: async (res) => {
      if (!res.confirm)
        return
      try {
        await JobLogAPI.remove(ids)
        toast.success('删除成功')
        loadLogs()
      }
      catch (e) { toast.error(getErrorMessage(e, '删除失败')) }
    },
  })
}

onPullDownRefresh(() => {
  if (activeTab.value === 'jobs')
    refreshScheduler()
  else if (activeTab.value === 'logs')
    loadLogs()
  else loadNodes()
})

onLoad(() => {
  refreshScheduler()
  loadLogs()
  loadNodes()
})

// Status helpers
function getJobStatusColor(status?: string) {
  const map: Record<string, string> = { running: '#10B981', paused: '#F59E0B', error: '#EF4444' }
  return map[status || ''] || '#6B7280'
}
function getJobStatusLabel(status?: string) {
  const map: Record<string, string> = { running: '运行中', paused: '已暂停', error: '异常' }
  return map[status || ''] || status || '未知'
}
function getLogColor(status?: string) {
  const map: Record<string, string> = { success: '#10B981', failed: '#EF4444', running: '#4F8CFF' }
  return map[status || ''] || '#6B7280'
}
</script>

<template>
  <view class="list-page">
    <!-- Scheduler status bar -->
    <view class="scheduler-bar">
      <view class="scheduler-bar__status">
        <view class="scheduler-dot" :class="schedulerRunning ? 'scheduler-dot--on' : 'scheduler-dot--off'" />
        <text class="scheduler-bar__label">
          {{ schedulerRunning ? '调度器运行中' : '调度器已停止' }}
        </text>
        <text class="scheduler-bar__count">
          {{ schedulerJobs.length }} 个任务
        </text>
      </view>
      <view class="scheduler-bar__actions">
        <template v-if="schedulerRunning">
          <view class="scheduler-btn btn-press" @click="handleScheduler('pause')">
            <text class="scheduler-btn__text">
              ⏸ 暂停
            </text>
          </view>
          <view class="scheduler-btn scheduler-btn--danger btn-press" @click="handleScheduler('shutdown')">
            <text class="scheduler-btn__text">
              ⏹ 关闭
            </text>
          </view>
        </template>
        <template v-else>
          <view class="scheduler-btn scheduler-btn--primary btn-press" @click="handleScheduler('start')">
            <text class="scheduler-btn__text">
              ▶ 启动
            </text>
          </view>
          <view class="scheduler-btn btn-press" @click="handleScheduler('resume')">
            <text class="scheduler-btn__text">
              ↻ 恢复
            </text>
          </view>
        </template>
      </view>
    </view>

    <!-- Tab switcher -->
    <view class="tab-bar">
      <view
        class="tab-item" :class="[activeTab === 'jobs' && 'tab-item--active']"
        @click="activeTab = 'jobs'"
      >
        <text class="tab-item__text">
          任务列表
        </text>
      </view>
      <view
        class="tab-item" :class="[activeTab === 'logs' && 'tab-item--active']"
        @click="activeTab = 'logs'"
      >
        <text class="tab-item__text">
          执行日志
        </text>
      </view>
      <view
        class="tab-item" :class="[activeTab === 'nodes' && 'tab-item--active']"
        @click="activeTab = 'nodes'"
      >
        <text class="tab-item__text">
          节点管理
        </text>
      </view>
    </view>

    <!-- Jobs tab -->
    <template v-if="activeTab === 'jobs'">
      <SkeletonPage v-if="jobsLoading && schedulerJobs.length === 0" :rows="3" />
      <ListEmpty v-else-if="!jobsLoading && schedulerJobs.length === 0" text="暂无任务" />
      <view v-else class="jobs-list">
        <view v-for="job in schedulerJobs" :key="job.id" class="job-item">
          <view class="job-item__header">
            <text class="job-item__name">
              {{ job.name }}
            </text>
            <view class="job-item__actions">
              <text class="job-action" @click="handleTask('pause', job.id, job.name)">
                ⏸
              </text>
              <text class="job-action" @click="handleTask('run', job.id, job.name)">
                ▶
              </text>
              <text class="job-action job-action--danger" @click="handleTask('remove', job.id, job.name)">
                ✕
              </text>
            </view>
          </view>
          <view class="job-item__meta">
            <text class="job-item__func">
              {{ job.func || '—' }}
            </text>
            <view class="job-item__badge" :style="{ background: `${getJobStatusColor(job.status)}18`, color: getJobStatusColor(job.status) }">
              {{ getJobStatusLabel(job.status) }}
            </view>
          </view>
          <text v-if="job.next_run_time" class="job-item__next">
            下次执行: {{ job.next_run_time }}
          </text>
        </view>
      </view>
    </template>

    <!-- Logs tab -->
    <template v-else-if="activeTab === 'logs'">
      <SkeletonPage v-if="logLoading && logList.length === 0" :rows="5" />
      <ListEmpty v-else-if="!logLoading && logList.length === 0" text="暂无执行日志" />
      <view v-else class="logs-list">
        <view v-for="log in logList" :key="log.id" class="log-item">
          <view class="log-item__header">
            <text class="log-item__name">
              {{ log.job_name || '—' }}
            </text>
            <view class="log-item__badge" :style="{ background: `${getLogColor(log.status)}18`, color: getLogColor(log.status) }">
              {{ log.status || '—' }}
            </view>
          </view>
          <text class="log-item__time">
            {{ log.start_time || '—' }}
          </text>
          <text v-if="log.error_msg" class="log-item__error">
            {{ log.error_msg }}
          </text>
          <view class="log-item__delete" @click="handleClearLogs([log.id])">
            <text class="log-item__delete-icon">
              🗑
            </text>
          </view>
        </view>

        <PaginationBar :current="logPageParams.page_no" :page-size="logPageParams.page_size" :total="logTotal" @prev="logLoadPrev" @next="logLoadNext" />
      </view>
    </template>

    <!-- Nodes tab -->
    <template v-else-if="activeTab === 'nodes'">
      <view class="create-btn" @click="openCreateNode">
        <text class="create-btn__icon">
          +
        </text>
        <text class="create-btn__text">
          新建节点
        </text>
      </view>

      <view v-if="nodeLoading && nodeList.length === 0">
        <SkeletonPage :rows="3" />
      </view>
      <ListEmpty v-else-if="!nodeLoading && nodeList.length === 0" text="暂无节点" />
      <view v-else class="nodes-list">
        <view v-for="node in nodeList" :key="node.id" class="node-item">
          <view class="node-item__header">
            <view class="node-item__info">
              <text class="node-item__name">
                {{ node.name || '未命名' }}
              </text>
              <text class="node-item__host">
                {{ node.host }}{{ node.port ? `:${node.port}` : '' }}
              </text>
            </view>
            <view class="node-item__badge" :style="{ background: node.type === 'master' ? '#8B5CF618' : '#6B728018', color: node.type === 'master' ? '#8B5CF6' : '#6B7280' }">
              {{ node.type === 'master' ? '主节点' : node.type || '默认' }}
            </view>
          </view>

          <text v-if="node.description" class="node-item__desc">
            {{ node.description }}
          </text>

          <view v-if="node.status" class="node-item__meta">
            <text class="node-item__meta-text">
              状态: {{ node.status }}
            </text>
            <text v-if="node.task_count !== undefined" class="node-item__meta-text">
              {{ node.task_count }} 个任务
            </text>
          </view>

          <view class="node-item__actions">
            <view class="node-action node-action--primary btn-press" @click="handleExecuteNode(node.id)">
              <text class="node-action__text">
                ▶ 调试
              </text>
            </view>
            <view class="node-action btn-press" @click="openEditNode(node.id)">
              <text class="node-action__text">
                ✎ 编辑
              </text>
            </view>
            <view class="node-action btn-press" @click="handleClearNode(node.id)">
              <text class="node-action__text">
                ↻ 清空
              </text>
            </view>
            <view class="node-action node-action--danger btn-press" @click="handleDeleteNode([node.id])">
              <text class="node-action__text">
                ✕ 删除
              </text>
            </view>
          </view>
        </view>

        <PaginationBar :current="nodePageParams.page_no" :page-size="nodePageParams.page_size" :total="nodeTotal" @prev="nodeLoadPrev" @next="nodeLoadNext" />
      </view>
    </template>

    <!-- ========== Node Form Popup ========== -->
    <wd-popup
      v-model="showNodeForm"
      position="bottom"
      custom-style="border-radius: 32rpx 32rpx 0 0; padding-bottom: 40rpx;"
      @close="showNodeForm = false"
    >
      <view class="form-panel">
        <view class="form-panel__header">
          <text class="form-panel__title">
            {{ nodeFormTitle }}
          </text>
          <text class="form-panel__close" @click="showNodeForm = false">
            ✕
          </text>
        </view>

        <view class="form-group">
          <text class="form-group__label">
            节点名称 *
          </text>
          <wd-input v-model="nodeForm.name" placeholder="请输入节点名称" clearable />
        </view>

        <view class="form-group">
          <text class="form-group__label">
            主机地址 *
          </text>
          <wd-input v-model="nodeForm.host" placeholder="请输入主机地址 (IP/域名)" clearable />
        </view>

        <view class="form-row">
          <view class="form-group form-group--half">
            <text class="form-group__label">
              端口
            </text>
            <wd-input v-model="nodeForm.port" type="number" placeholder="端口号" />
          </view>
          <view class="form-group form-group--half">
            <text class="form-group__label">
              类型
            </text>
            <wd-input v-model="nodeForm.type" placeholder="default / master" />
          </view>
        </view>

        <view class="form-group">
          <text class="form-group__label">
            描述
          </text>
          <wd-textarea v-model="nodeForm.description" placeholder="节点描述" :maxlength="200" auto-height />
        </view>

        <view class="form-actions">
          <wd-button block type="primary" @click="submitNode">{{ editingNodeId ? '更新' : '创建' }}</wd-button>
        </view>
      </view>
    </wd-popup>

    <view style="height: 100rpx;" />
  </view>
</template>

<style lang="scss" scoped>
.list-page {
  padding: 0 32rpx;
  padding-bottom: 40rpx;
  background: var(--page-bg-color, #F9F9F9);
  min-height: 100vh;
}

/* ===== Scheduler bar ===== */
.scheduler-bar {
  background: var(--card-bg-color, #FFFFFF);
  border-radius: 24rpx;
  padding: 24rpx;
  margin: 24rpx 0;
  box-shadow: var(--shadow-sm, 0 1rpx 2rpx rgba(1, 77, 178,0.06));

  &__status {
    display: flex;
    align-items: center;
    gap: 16rpx;
    margin-bottom: 16rpx;
  }

  &__label {
    font-size: 30rpx;
    font-weight: 600;
    color: var(--text-color, #0A1628);
    flex: 1;
  }

  &__count {
    font-size: 24rpx;
    color: var(--text-color-3, #6B7280);
    background: var(--bg-color-2, #F5F6F8);
    padding: 4rpx 16rpx;
    border-radius: 16rpx;
  }

  &__actions {
    display: flex;
    gap: 16rpx;
  }
}

.scheduler-dot {
  width: 16rpx;
  height: 16rpx;
  border-radius: 50%;

  &--on { background: #10B981; box-shadow: 0 0 8rpx rgba(16, 185, 129, 0.4); }
  &--off { background: #9CA3AF; }
}

.scheduler-btn {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  height: 64rpx;
  border-radius: 16rpx;
  background: var(--bg-color-2, #F5F6F8);
  transition: all 0.15s ease;

  &--primary {
    background: var(--primary-color, #4F8CFF);
    .scheduler-btn__text { color: #FFFFFF; }
  }

  &--danger {
    background: var(--danger-color-light, #FEF2F2);
    .scheduler-btn__text { color: var(--danger-color, #EF4444); }
  }

  &__text {
    font-size: 26rpx;
    font-weight: 500;
    color: var(--text-color-2, #4B5563);
  }
}

/* ===== Tab bar ===== */
.tab-bar {
  display: flex;
  gap: 0;
  background: var(--card-bg-color, #FFFFFF);
  border-radius: 24rpx;
  padding: 8rpx;
  margin-bottom: 24rpx;
  box-shadow: var(--shadow-sm, 0 1rpx 2rpx rgba(1, 77, 178,0.06));
}

.tab-item {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  height: 72rpx;
  border-radius: 18rpx;
  transition: all 0.2s ease;

  &--active {
    background: var(--primary-color, #4F8CFF);

    .tab-item__text { color: #FFFFFF; font-weight: 600; }
  }

  &__text {
    font-size: 28rpx;
    color: var(--text-color-3, #6B7280);
    font-weight: 500;
  }
}

/* ===== Jobs list ===== */
.jobs-list {
  display: flex;
  flex-direction: column;
  gap: 16rpx;
}

.job-item {
  background: var(--card-bg-color, #FFFFFF);
  border-radius: 24rpx;
  padding: 24rpx;
  box-shadow: var(--shadow-sm, 0 1rpx 2rpx rgba(1, 77, 178,0.06));

  &__header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 12rpx;
  }

  &__name {
    font-size: 30rpx;
    font-weight: 600;
    color: var(--text-color, #0A1628);
    flex: 1;
  }

  &__actions {
    display: flex;
    gap: 12rpx;
  }

  &__meta {
    display: flex;
    align-items: center;
    gap: 12rpx;
    margin-bottom: 8rpx;
  }

  &__func {
    font-size: 24rpx;
    color: var(--text-color-3, #6B7280);
    font-family: 'SF Mono', 'Consolas', monospace;
  }

  &__badge {
    font-size: 20rpx;
    padding: 2rpx 12rpx;
    border-radius: 8rpx;
    font-weight: 500;
  }

  &__next {
    font-size: 22rpx;
    color: var(--text-color-4, #B0B0B0);
  }
}

.job-action {
  font-size: 24rpx;
  width: 48rpx;
  height: 48rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  background: var(--bg-color-2, #F5F6F8);
  transition: all 0.15s ease;

  &--danger {
    color: var(--danger-color, #EF4444);
  }

  &:active {
    opacity: 0.7;
    transform: scale(0.9);
  }
}

/* ===== Logs list ===== */
.logs-list {
  display: flex;
  flex-direction: column;
  gap: 16rpx;
}

.log-item {
  position: relative;
  background: var(--card-bg-color, #FFFFFF);
  border-radius: 24rpx;
  padding: 24rpx 72rpx 24rpx 24rpx;
  box-shadow: var(--shadow-sm, 0 1rpx 2rpx rgba(1, 77, 178,0.06));

  &__header {
    display: flex;
    align-items: center;
    gap: 16rpx;
    margin-bottom: 8rpx;
  }

  &__name {
    font-size: 28rpx;
    font-weight: 600;
    color: var(--text-color, #0A1628);
    flex: 1;
  }

  &__badge {
    font-size: 22rpx;
    padding: 2rpx 12rpx;
    border-radius: 8rpx;
    font-weight: 500;
  }

  &__time {
    font-size: 24rpx;
    color: var(--text-color-4, #B0B0B0);
  }

  &__error {
    display: block;
    font-size: 22rpx;
    color: var(--danger-color, #EF4444);
    background: var(--danger-color-light, #FEF2F2);
    padding: 8rpx 16rpx;
    border-radius: 8rpx;
    margin-top: 8rpx;
  }

  &__delete {
    position: absolute;
    top: 24rpx;
    right: 24rpx;
    width: 48rpx;
    height: 48rpx;
    border-radius: 50%;
    background: var(--bg-color-2, #F5F6F8);
    display: flex;
    align-items: center;
    justify-content: center;

    &-icon { font-size: 24rpx; opacity: 0.4; }
  }
}

/* ===== Load more ===== */
.load-more {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 80rpx;
  background: var(--bg-color-2, #F5F6F8);
  border-radius: 16rpx;
  margin-top: 8rpx;

  &__text {
    font-size: 26rpx;
    color: var(--text-color-3, #6B7280);
  }
}

/* ===== Create button ===== */
.create-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12rpx;
  height: 80rpx;
  background: var(--primary-color, #4F8CFF);
  border-radius: 24rpx;
  margin-bottom: 24rpx;
  box-shadow: 0 4rpx 16rpx rgba(1, 77, 178, 0.2);
  transition: all 0.15s ease;

  &:active { opacity: 0.85; transform: scale(0.98); }

  &__icon {
    font-size: 36rpx;
    color: #FFFFFF;
    font-weight: 300;
  }
  &__text {
    font-size: 28rpx;
    color: #FFFFFF;
    font-weight: 600;
  }
}

/* ===== Nodes list ===== */
.nodes-list {
  display: flex;
  flex-direction: column;
  gap: 16rpx;
}

.node-item {
  background: var(--card-bg-color, #FFFFFF);
  border-radius: 24rpx;
  padding: 24rpx;
  box-shadow: var(--shadow-sm, 0 1rpx 2rpx rgba(1, 77, 178,0.06));

  &__header {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    margin-bottom: 12rpx;
  }

  &__info {
    flex: 1;
    min-width: 0;
  }

  &__name {
    display: block;
    font-size: 30rpx;
    font-weight: 600;
    color: var(--text-color, #0A1628);
    margin-bottom: 4rpx;
  }

  &__host {
    font-size: 24rpx;
    color: var(--text-color-3, #6B7280);
    font-family: 'SF Mono', 'Consolas', monospace;
  }

  &__badge {
    font-size: 20rpx;
    padding: 2rpx 12rpx;
    border-radius: 8rpx;
    font-weight: 500;
    flex-shrink: 0;
  }

  &__desc {
    display: block;
    font-size: 24rpx;
    color: var(--text-color-2, #4B5563);
    margin-bottom: 10rpx;
  }

  &__meta {
    display: flex;
    gap: 16rpx;
    margin-bottom: 12rpx;
  }

  &__meta-text {
    font-size: 22rpx;
    color: var(--text-color-4, #B0B0B0);
  }

  &__actions {
    display: flex;
    gap: 12rpx;
    padding-top: 12rpx;
    border-top: 1rpx solid var(--border-color, #F0F0F0);
  }
}

.node-action {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  height: 56rpx;
  border-radius: 12rpx;
  background: var(--bg-color-2, #F5F6F8);
  transition: all 0.15s ease;

  &--primary { background: var(--primary-color-light, rgba(1,77,178,0.08)); }
  &--danger { background: var(--danger-color-light, #FEF2F2); }

  &--primary .node-action__text { color: var(--primary-color, #4F8CFF); }
  &--danger .node-action__text { color: var(--danger-color, #EF4444); }

  &__text {
    font-size: 22rpx;
    font-weight: 500;
    color: var(--text-color-2, #4B5563);
    white-space: nowrap;
  }

  &:active { opacity: 0.7; transform: scale(0.95); }
}

/* ===== Form Panel ===== */
.form-panel {
  padding: 32rpx;

  &__header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 32rpx;
  }

  &__title {
    font-size: 34rpx;
    font-weight: 700;
    color: var(--text-color, #0A1628);
  }

  &__close {
    font-size: 32rpx;
    color: var(--text-color-3, #6B7280);
    width: 56rpx;
    height: 56rpx;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 50%;
    background: var(--bg-color-2, #F5F6F8);

    &:active { opacity: 0.6; }
  }
}

.form-group {
  margin-bottom: 24rpx;

  &__label {
    display: block;
    font-size: 26rpx;
    font-weight: 500;
    color: var(--text-color-2, #4B5563);
    margin-bottom: 12rpx;
  }

  &--half {
    flex: 1;
  }
}

.form-row {
  display: flex;
  gap: 16rpx;
}

.form-actions {
  margin-top: 32rpx;
}
</style>
