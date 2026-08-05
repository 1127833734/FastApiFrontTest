<script setup lang="ts">
import type { TicketForm, TicketItem } from '@/api/module_system/ticket'
import { onLoad, onPullDownRefresh } from '@dcloudio/uni-app'
import { reactive, ref } from 'vue'
import { TicketAPI } from '@/api/module_system/ticket'

definePage({ name: 'work-tickets', style: { navigationBarTitleText: '工单管理' } })

const router = useRouter()
const toast = useToast()
const searchTitle = ref('')
const showForm = ref(false)
const formTitle = ref('')
const currentId = ref<number>()
const initForm: TicketForm = { title: '', ticket_content: '', ticket_type: '', status: undefined, description: '' }
const formData = reactive<TicketForm>({ ...initForm })
const showPickerType = ref(false)
const showPickerStatus = ref(false)

const TYPE_OPTIONS = [{ value: 'suggestion', label: '建议' }, { value: 'bug', label: '缺陷' }, { value: 'optimize', label: '优化' }, { value: 'other', label: '其他' }]

const STATUS_OPTIONS = [{ value: 0, label: '待处理' }, { value: 1, label: '处理中' }, { value: 2, label: '已完成' }, { value: 3, label: '已关闭' }]

/** 顶部状态筛选 Tab */
const TAB_OPTIONS = [
  { title: '全部', value: undefined },
  { title: '待处理', value: 0 },
  { title: '处理中', value: 1 },
  { title: '已完成', value: 2 },
  { title: '已关闭', value: 3 },
]
const activeTab = ref<number | string>(0)
const activeStatus = ref<number | undefined>()
/** 类型筛选（wd-drop-menu） */
const typeFilter = ref<string | number>('')
const TYPE_FILTER_OPTIONS = [{ label: '全部类型', value: '' }, ...TYPE_OPTIONS]
/** 创建时间范围筛选（时间戳数组，与 wd-datetime-picker 范围模式对齐） */
const dateRange = ref<number[]>([])
const timeRangeText = ref('')
const showDatePicker = ref(false)

function formatDate(ts: number) {
  const d = new Date(ts)
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${d.getFullYear()}-${m}-${day}`
}

interface PickerConfirmEvent { value: Array<string | number>, selectedOptions: any[] }
function handleTypeConfirm(e: PickerConfirmEvent) {
  const item = TYPE_OPTIONS.find(o => o.value === e.value[0])
  if (item)
    formData.ticket_type = item.value
  showPickerType.value = false
}
function handleStatusConfirm(e: PickerConfirmEvent) {
  const item = STATUS_OPTIONS.find(o => o.value === e.value[0])
  if (item)
    formData.status = item.value
  showPickerStatus.value = false
}

const TICKET_STATUS_MAP: Record<number, string> = { 0: 'pending', 1: 'processing', 2: 'completed', 3: 'closed' }
function ticketStatus(status: number | string | undefined) {
  return TICKET_STATUS_MAP[Number(status)] || String(status)
}
function typeLabel(type?: string) {
  return TYPE_OPTIONS.find(o => o.value === type)?.label || type || ''
}

const { list, total, loading, pageParams, loadData, toFirst, loadNext } = useListPage<TicketItem>({
  fetcher: p => TicketAPI.getPage({
    ...p,
    title: searchTitle.value || undefined,
    status: activeStatus.value,
    created_time: dateRange.value.length === 2 ? [formatDate(dateRange.value[0]), formatDate(dateRange.value[1])] : undefined,
    ticket_type: typeFilter.value === '' ? undefined : String(typeFilter.value),
  }),
  onError: () => toast.error('加载失败'),
})

function handleTypeFilter(e: { value: string | number }) {
  typeFilter.value = e.value
  toFirst()
  loadData()
}

function handleDateConfirm(e: { value: string | number | Array<string | number> }) {
  const v = Array.isArray(e.value) ? e.value.map(Number) : []
  dateRange.value = v
  showDatePicker.value = false
  if (v.length === 2) {
    timeRangeText.value = `${formatDate(v[0])} ~ ${formatDate(v[1])}`
    toFirst()
    loadData()
  }
}

function handleTabChange(e: { index: number }) {
  activeStatus.value = TAB_OPTIONS[e.index]?.value
  toFirst()
  loadData()
}

function handlePageChange({ value }: { value: number }) {
  pageParams.value.page_no = value
  loadData()
}

function onSearch() {
  toFirst()
  loadData()
}
function onReset() {
  searchTitle.value = ''
  dateRange.value = []
  timeRangeText.value = ''
  typeFilter.value = ''
  toFirst()
  loadData()
}
function resetForm() {
  Object.assign(formData, { ...initForm })
}
function openCreate() {
  formTitle.value = '新增'
  currentId.value = undefined
  resetForm()
  showForm.value = true
}
function navigateToDetail(id: number) {
  router.push({ name: 'work-ticket-detail', query: { id: String(id) } })
}
/** 左滑删除：wd-swipe-action 展开后点击右侧按钮触发 */
function onSwipeRight(item: TicketItem, e: { value: string }) {
  if (e.value === 'right')
    handleDelete(item.id!)
}
async function handleSubmit() {
  loading.value = true
  try {
    if (currentId.value) {
      await TicketAPI.update(currentId.value, { ...formData })
      toast.success('更新成功')
    }
    else {
      await TicketAPI.create({ ...formData })
      toast.success('创建成功')
    }
    showForm.value = false
    loadData()
  }
  catch { toast.error('操作失败') }
  finally { loading.value = false }
}
function handleDelete(id: number) {
  uni.showModal({
    title: '提示',
    content: '确认删除？',
    success: async (res) => {
      if (res.confirm) {
        try {
          await TicketAPI.remove([id])
          toast.success('删除成功')
          loadData()
        }
        catch { toast.error('删除失败') }
      }
    },
  })
}

onReachBottom(() => {
  if (!loading.value)
    loadNext()
})
onPullDownRefresh(() => {
  loadData()
})
onLoad(() => loadData())
</script>

<template>
  <view class="page-wraper">
    <!-- 搜索 -->
    <view class="search-bar">
      <view class="flex items-center gap-sm">
        <wd-input v-model="searchTitle" placeholder="搜索标题" clearable class="flex-1" />
        <wd-button size="small" type="primary" variant="plain" @click="onSearch">
          搜索
        </wd-button>
        <wd-button size="small" variant="plain" @click="onReset">
          重置
        </wd-button>
      </view>
      <view class="mt-2 flex items-center gap-1" @click="showDatePicker = true">
        <wd-icon name="calendar" size="16px" color="var(--text-color-3, #6B7280)" />
        <text class="text-3 wot-text-text-secondary">
          {{ timeRangeText || '按创建时间筛选' }}
        </text>
        <text v-if="timeRangeText" class="ml-1 text-3 wot-text-primary" @click.stop="onReset">
          清除
        </text>
      </view>
    </view>

    <!-- 创建时间范围选择 -->
    <wd-datetime-picker
      v-model="dateRange"
      :visible="showDatePicker"
      type="date"
      title="选择创建时间范围"
      @confirm="handleDateConfirm"
      @cancel="showDatePicker = false"
    />

    <!-- 状态筛选（吸顶） -->
    <wd-tabs v-model="activeTab" line-theme="text" sticky :offset-top="0" @change="handleTabChange">
      <wd-tab v-for="opt in TAB_OPTIONS" :key="opt.title" :title="opt.title" />
    </wd-tabs>

    <!-- 类型筛选下拉 -->
    <wd-drop-menu class="mt-2" :z-index="9">
      <wd-drop-menu-item v-model="typeFilter" :options="TYPE_FILTER_OPTIONS" title="类型" @change="handleTypeFilter" />
    </wd-drop-menu>

    <!-- 卡片列表（左滑删除） -->
    <SkeletonPage v-if="loading && list.length === 0" :rows="5" search />
    <template v-else>
      <view class="mt-2 px-sm">
        <wd-empty v-if="!loading && list.length === 0" tip="暂无工单" />
        <template v-else>
          <wd-swipe-action
            v-for="item in list"
            :key="item.id"
            class="mb-3"
            @click="onSwipeRight(item, $event)"
          >
            <template #right>
              <view class="h-full flex items-center justify-center px-6" style="background-color: var(--danger-color); color: #fff;">
                <text class="text-3">
                  删除
                </text>
              </view>
            </template>
            <view class="admin-card flex items-center gap-3 rounded-2 p-4 wot-bg-filled-oppo" @click="navigateToDetail(item.id!)">
              <view class="min-w-0 flex-1">
                <view class="truncate text-3.5 font-medium wot-text-text-main">
                  {{ item.title }}
                </view>
                <view class="mt-1 truncate text-2.5 wot-text-text-auxiliary">
                  {{ typeLabel(item.ticket_type) }}{{ item.ticket_content ? ` · ${item.ticket_content}` : '' }}
                </view>
              </view>
              <StatusBadge :status="ticketStatus(item.status)" />
            </view>
          </wd-swipe-action>
        </template>
      </view>
      <wd-pagination
        :model-value="pageParams.page_no"
        :total="total"
        :page-size="pageParams.page_size"
        button-variant="plain"
        hide-if-one-page
        @change="handlePageChange"
      />
      <!-- 底部安全区（全面屏 Home 条避让） -->
      <wd-gap height="100rpx" safe-area-bottom />
    </template>

    <!-- 新增悬浮按钮（bottom gap 上移避让 Home 条） -->
    <wd-fab position="right-bottom" :expandable="false" :gap="{ bottom: 40 }" @click="openCreate" />

    <!-- 表单弹窗 -->
    <wd-popup v-model="showForm" position="bottom" round custom-style="max-height: 80vh; overflow-y: auto;" @close="showForm = false">
      <view class="p-xl">
        <wd-navbar :title="formTitle" left-arrow @click-left="showForm = false" />
        <wd-form :model="formData" class="mt-lg">
          <wd-form-item label="工单标题" border>
            <wd-input v-model="formData.title" placeholder="请输入" />
          </wd-form-item>
          <wd-form-item label="内容" border>
            <wd-textarea v-model="formData.ticket_content" placeholder="请输入" />
          </wd-form-item>
          <wd-form-item label="类型" border>
            <view class="flex-1" @click="showPickerType = true">
              <wd-cell :value="TYPE_OPTIONS.find(o => o.value === formData.ticket_type)?.label || '请选择'" is-link :border="false" />
            </view>
            <wd-picker :visible="showPickerType" :columns="[TYPE_OPTIONS]" @confirm="handleTypeConfirm" @cancel="showPickerType = false" />
          </wd-form-item>
          <wd-form-item v-if="currentId" label="状态" border>
            <view class="flex-1" @click="showPickerStatus = true">
              <wd-cell :value="STATUS_OPTIONS.find(o => o.value === formData.status)?.label || '请选择'" is-link :border="false" />
            </view>
            <wd-picker :visible="showPickerStatus" :columns="[STATUS_OPTIONS]" @confirm="handleStatusConfirm" @cancel="showPickerStatus = false" />
          </wd-form-item>
          <wd-form-item label="备注" border>
            <wd-textarea v-model="formData.description" placeholder="请输入" />
          </wd-form-item>
        </wd-form>
        <view class="gap-md mt-xl flex">
          <wd-button block variant="plain" @click="showForm = false">
            取消
          </wd-button><wd-button block type="primary" :loading="loading" @click="handleSubmit">
            保存
          </wd-button>
        </view>
      </view>
    </wd-popup>
  </view>
</template>
