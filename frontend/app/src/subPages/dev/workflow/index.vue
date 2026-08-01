<script setup lang="ts">
import type { WorkflowItem } from '@/api/module_task/workflow/flow'
import { onLoad, onPullDownRefresh } from '@dcloudio/uni-app'
import { ref } from 'vue'
import { WorkflowAPI } from '@/api/module_task/workflow/flow'

definePage({
  name: 'work-workflow',
  style: { navigationBarTitleText: '工作流管理' },
})

const toast = useToast()
const activeTab = ref<'flows' | 'nodes'>('flows')

// Flow form
const showFlowForm = ref(false)
const flowFormTitle = ref('新建工作流')
const flowForm = reactive({ name: '', description: '' })
const editingFlowId = ref<number | null>(null)

const { list: flowList, total: flowTotal, loading, pageParams, loadData, loadPrev, loadNext } = useListPage<WorkflowItem>({
  fetcher: p => WorkflowAPI.getPage(p),
  onError: e => toast.error(getErrorMessage(e, '加载工作流列表失败')),
})

function openCreateFlow() {
  flowFormTitle.value = '新建工作流'
  editingFlowId.value = null
  flowForm.name = ''
  flowForm.description = ''
  showFlowForm.value = true
}

async function openEditFlow(id: number) {
  flowFormTitle.value = '编辑工作流'
  editingFlowId.value = id
  try {
    const detail = await WorkflowAPI.getDetail(id)
    flowForm.name = detail.name || ''
    flowForm.description = detail.description || ''
    showFlowForm.value = true
  }
  catch (e) { toast.error(getErrorMessage(e, '获取工作流详情失败')) }
}

async function submitFlow() {
  if (!flowForm.name.trim())
    return toast.warning('请输入工作流名称')
  try {
    if (editingFlowId.value) {
      await WorkflowAPI.update(editingFlowId.value, { ...flowForm })
      toast.success('更新成功')
    }
    else {
      await WorkflowAPI.create({ ...flowForm })
      toast.success('创建成功')
    }
    showFlowForm.value = false
    loadData()
  }
  catch (e) { toast.error(getErrorMessage(e, '保存失败')) }
}

async function handlePublish(id: number, name: string) {
  uni.showModal({
    title: '提示',
    content: `确认发布工作流「${name}」？发布后将生成最新版本。`,
    success: async (res) => {
      if (!res.confirm)
        return
      try {
        await WorkflowAPI.publish(id)
        toast.success('发布成功')
        loadData()
      }
      catch (e) { toast.error(getErrorMessage(e, '发布失败')) }
    },
  })
}

async function handleExecute(id: number, name: string) {
  uni.showModal({
    title: '提示',
    content: `确认立即执行工作流「${name}」？`,
    success: async (res) => {
      if (!res.confirm)
        return
      try {
        const result = await WorkflowAPI.execute({ workflow_id: id })
        toast.success(`执行完成：${JSON.stringify(result)}`)
        loadData()
      }
      catch (e) { toast.error(getErrorMessage(e, '执行失败')) }
    },
  })
}

async function handleDeleteFlow(ids: number[]) {
  uni.showModal({
    title: '提示',
    content: '确认删除选中的工作流？此操作不可恢复。',
    success: async (res) => {
      if (!res.confirm)
        return
      try {
        await WorkflowAPI.remove(ids)
        toast.success('删除成功')
        loadData()
      }
      catch (e) { toast.error(getErrorMessage(e, '删除失败')) }
    },
  })
}

// Status helpers
function getFlowStatusColor(status?: string) {
  const map: Record<string, string> = { published: '#10B981', draft: '#6B7280', running: '#4F8CFF', completed: '#8B5CF6', failed: '#EF4444' }
  return map[status || ''] || '#6B7280'
}
function getFlowStatusLabel(status?: string) {
  const map: Record<string, string> = { published: '已发布', draft: '草稿', running: '运行中', completed: '已完成', failed: '失败' }
  return map[status || ''] || status || '未知'
}

onReachBottom(() => {
  if (activeTab.value === 'flows' && !loading.value)
    loadNext()
})
onPullDownRefresh(() => {
  if (activeTab.value === 'flows')
    loadData()
})

onLoad(() => {
  loadData()
})
</script>

<template>
  <view class="list-page">
    <!-- Tab switcher -->
    <view class="tab-bar fade-in-up">
      <view
        class="tab-item" :class="[activeTab === 'flows' && 'tab-item--active']"
        @click="activeTab = 'flows'"
      >
        <text class="tab-item__text">
          工作流列表
        </text>
      </view>
      <view
        class="tab-item" :class="[activeTab === 'nodes' && 'tab-item--active']"
        @click="activeTab = 'nodes'"
      >
        <text class="tab-item__text">
          节点类型
        </text>
      </view>
    </view>

    <!-- Flow List Tab -->
    <template v-if="activeTab === 'flows'">
      <!-- Create button -->
      <view class="create-btn fade-in-up-1" @click="openCreateFlow">
        <text class="create-btn__icon">
          +
        </text>
        <text class="create-btn__text">
          新建工作流
        </text>
      </view>

      <SkeletonPage v-if="loading && flowList.length === 0" :rows="4" />
      <ListEmpty v-else-if="!loading && flowList.length === 0" text="暂无工作流" />
      <view v-else class="flows-list">
        <view v-for="(flow, idx) in flowList" :key="flow.id" class="flow-item" :class="[`fade-in-up-${Math.min(idx % 5 + 1, 5)}`]">
          <view class="flow-item__header" @click="openEditFlow(flow.id)">
            <view class="flow-item__info">
              <text class="flow-item__name">
                {{ flow.name || '未命名' }}
              </text>
              <text v-if="flow.version" class="flow-item__version">
                v{{ flow.version }}
              </text>
            </view>
            <view class="flow-item__badge" :style="{ background: `${getFlowStatusColor(flow.status)}18`, color: getFlowStatusColor(flow.status) }">
              {{ getFlowStatusLabel(flow.status) }}
            </view>
          </view>

          <text v-if="flow.description" class="flow-item__desc">
            {{ flow.description }}
          </text>

          <view class="flow-item__meta">
            <text v-if="flow.nodes" class="flow-item__count">
              {{ flow.nodes.length }} 个节点
            </text>
            <text v-if="flow.updated_time" class="flow-item__time">
              {{ flow.updated_time }}
            </text>
          </view>

          <view class="flow-item__actions">
            <view class="flow-action flow-action--primary btn-press" @click="handlePublish(flow.id, flow.name)">
              <text class="flow-action__text">
                ⬆ 发布
              </text>
            </view>
            <view class="flow-action flow-action--success btn-press" @click="handleExecute(flow.id, flow.name)">
              <text class="flow-action__text">
                ▶ 执行
              </text>
            </view>
            <view class="flow-action btn-press" @click="openEditFlow(flow.id)">
              <text class="flow-action__text">
                ✎ 编辑
              </text>
            </view>
            <view class="flow-action flow-action--danger btn-press" @click="handleDeleteFlow([flow.id])">
              <text class="flow-action__text">
                ✕ 删除
              </text>
            </view>
          </view>
        </view>

        <PaginationBar :current="pageParams.page_no" :page-size="pageParams.page_size" :total="flowTotal" @prev="loadPrev" @next="loadNext" />
      </view>
    </template>

    <!-- Node Types Tab (placeholder for future) -->
    <template v-else>
      <ListEmpty text="节点类型管理即将上线" />
    </template>

    <view style="height: 120rpx;" />

    <!-- Flow Form Popup -->
    <u-popup
      :show="showFlowForm"
      mode="bottom"
      custom-style="border-radius: 32rpx 32rpx 0 0; padding-bottom: 40rpx;"
      @close="showFlowForm = false"
    >
      <view class="form-panel">
        <view class="form-panel__header">
          <text class="form-panel__title">
            {{ flowFormTitle }}
          </text>
          <text class="form-panel__close" @click="showFlowForm = false">
            ✕
          </text>
        </view>

        <view class="form-group">
          <text class="form-group__label">
            工作流名称 *
          </text>
          <u-input v-model="flowForm.name" placeholder="请输入工作流名称" clearable border="surround" />
        </view>

        <view class="form-group">
          <text class="form-group__label">
            描述
          </text>
          <u-textarea
            v-model="flowForm.description"
            placeholder="请输入工作流描述"
            :maxlength="500"
            :autosize="{ minRows: 3, maxRows: 6 }"
            border="surround"
          />
        </view>

        <view class="form-actions">
          <u-button :block="true" type="primary" :text="editingFlowId ? '更新' : '创建'" @click="submitFlow" />
        </view>
      </view>
    </u-popup>
  </view>
</template>

<style lang="scss" scoped>
.list-page {
  padding: 0 32rpx;
  padding-bottom: 40rpx;
  background: var(--page-bg-color, #F9F9F9);
  min-height: 100vh;
}

/* ===== Tab bar ===== */
.tab-bar {
  display: flex;
  gap: 0;
  background: var(--card-bg-color, #FFFFFF);
  border-radius: 24rpx;
  padding: 8rpx;
  margin: 24rpx 0;
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

/* ===== Flows list ===== */
.flows-list {
  display: flex;
  flex-direction: column;
  gap: 16rpx;
}

.flow-item {
  background: var(--card-bg-color, #FFFFFF);
  border-radius: 24rpx;
  padding: 24rpx;
  box-shadow: var(--shadow-sm, 0 1rpx 2rpx rgba(1, 77, 178,0.06));

  &__header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 12rpx;
    cursor: pointer;
  }

  &__info {
    display: flex;
    align-items: center;
    gap: 12rpx;
    flex: 1;
    min-width: 0;
  }

  &__name {
    font-size: 30rpx;
    font-weight: 600;
    color: var(--text-color, #0A1628);
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  &__version {
    font-size: 22rpx;
    color: var(--primary-color, #4F8CFF);
    background: var(--primary-color-light, rgba(1,77,178,0.08));
    padding: 2rpx 10rpx;
    border-radius: 8rpx;
    font-family: 'SF Mono', 'Consolas', monospace;
    flex-shrink: 0;
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
    line-height: 1.5;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
  }

  &__meta {
    display: flex;
    align-items: center;
    gap: 16rpx;
    margin-bottom: 16rpx;
  }

  &__count {
    font-size: 22rpx;
    color: var(--text-color-3, #6B7280);
    background: var(--bg-color-2, #F5F6F8);
    padding: 4rpx 12rpx;
    border-radius: 8rpx;
  }

  &__time {
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

.flow-action {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  height: 56rpx;
  border-radius: 12rpx;
  background: var(--bg-color-2, #F5F6F8);
  transition: all 0.15s ease;

  &--primary { background: var(--primary-color-light, rgba(1,77,178,0.08)); }
  &--success { background: rgba(16, 185, 129, 0.08); }
  &--danger { background: var(--danger-color-light, #FEF2F2); }

  &--primary .flow-action__text { color: var(--primary-color, #4F8CFF); }
  &--success .flow-action__text { color: #10B981; }
  &--danger .flow-action__text { color: var(--danger-color, #EF4444); }

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
}

.form-actions {
  margin-top: 32rpx;
}
</style>
