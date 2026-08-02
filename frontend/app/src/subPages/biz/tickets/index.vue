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

function displayContent(item: TicketItem) {
  return item.ticket_content || ''
}
function displayType(item: TicketItem) {
  return item.ticket_type || ''
}

const { list, total, loading, pageParams, loadData, toFirst, loadPrev, loadNext } = useListPage<TicketItem>({
  fetcher: p => TicketAPI.getPage({ ...p, title: searchTitle.value || undefined }),
  onError: () => toast.error('加载失败'),
})

function onSearch() {
  toFirst()
  loadData()
}
function onReset() {
  searchTitle.value = ''
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
    </view>
    <view class="action-bar">
      <text class="text-md text-muted font-bold">
        共 {{ total }} 条
      </text>
      <wd-button size="small" type="primary" @click="openCreate">
        + 新增
      </wd-button>
    </view>
    <SkeletonPage v-if="loading" :rows="5" search />
    <template v-else>
      <view class="px-sm">
        <view class="admin-card">
          <ListEmpty v-if="!loading && list.length === 0" text="暂无数据" />
          <wd-cell-group v-else>
            <wd-cell v-for="item in list" :key="item.id" is-link @click="navigateToDetail(item.id!)">
              <template #title>
                <view>
                  <text class="text-md font-medium">
                    {{ item.title }}
                  </text>
                </view>
              </template>
              <template #label>
                <text class="text-muted text-xs">
                  {{ displayType(item) ? `${displayType(item)} · ` : '' }}{{ displayContent(item) }}
                </text>
              </template>
              <view class="flex items-center gap-xs">
                <StatusBadge :status="ticketStatus(item.status)" />
                <wd-icon name="delete" size="18px" color="var(--danger-color)" @click.stop="handleDelete(item.id!)" />
              </view>
            </wd-cell>
          </wd-cell-group>
        </view>
      </view>
      <PaginationBar :current="pageParams.page_no" :page-size="pageParams.page_size" :total="total" @prev="loadPrev" @next="loadNext" />
    </template>
    <wd-popup v-model="showForm" position="bottom" round custom-style="max-height: 80vh; overflow-y: auto;" @close="showForm = false">
      <view class="p-xl">
        <wd-navbar :title="formTitle" left-arrow @click-left="showForm = false" />
        <wd-form :model="formData" class="mt-lg">
          <wd-form-item label="工单标题">
            <wd-input v-model="formData.title" placeholder="请输入" />
          </wd-form-item>
          <wd-form-item label="内容">
            <wd-textarea v-model="formData.ticket_content" placeholder="请输入" />
          </wd-form-item>
          <wd-form-item label="类型">
            <view @click="showPickerType = true">
              <wd-cell title="类型" :value="TYPE_OPTIONS.find(o => o.value === formData.ticket_type)?.label || '请选择'" is-link :border="false" />
            </view>
            <wd-picker :visible="showPickerType" :columns="[TYPE_OPTIONS]" @confirm="handleTypeConfirm" @cancel="showPickerType = false" />
          </wd-form-item>
          <wd-form-item v-if="currentId" label="状态">
            <view @click="showPickerStatus = true">
              <wd-cell title="状态" :value="STATUS_OPTIONS.find(o => o.value === formData.status)?.label || '请选择'" is-link :border="false" />
            </view>
            <wd-picker :visible="showPickerStatus" :columns="[STATUS_OPTIONS]" @confirm="handleStatusConfirm" @cancel="showPickerStatus = false" />
          </wd-form-item>
          <wd-form-item label="备注">
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
