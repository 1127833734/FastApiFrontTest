<script setup lang="ts">
import type { VersionForm, VersionItem } from '@/api/module_system/version'
import { onLoad, onPullDownRefresh } from '@dcloudio/uni-app'
import { reactive, ref } from 'vue'
import { VersionAPI } from '@/api/module_system/version'

definePage({ name: 'work-versions', style: { navigationBarTitleText: '版本管理' } })

const toast = useToast()
const searchName = ref('')
const showForm = ref(false)
const formTitle = ref('')
const currentId = ref<number>()
const initForm: VersionForm = { version: '', title: '', date: '', content: '', description: '', sort: 0, status: 0 }
const formData = reactive<VersionForm>({ ...initForm })

const STATUS_MAP: Record<number, string> = { 0: 'draft', 1: 'published', 2: 'deprecated' }
const STATUS_LABELS: Record<number, string> = { 0: '草稿', 1: '已发布', 2: '已废弃' }
const STATUS_OPTIONS = [{ value: 0, label: '草稿' }, { value: 1, label: '已发布' }, { value: 2, label: '已废弃' }]

function getStatus(status: number | string | undefined) {
  return STATUS_MAP[Number(status)] || 'draft'
}
function getStatusLabel(status: number | string | undefined) {
  return STATUS_LABELS[Number(status)] || '未知'
}

const { list, total, loading, pageParams, loadData, toFirst, loadPrev, loadNext } = useListPage<VersionItem>({
  fetcher: p => VersionAPI.getPage({ ...p, title: searchName.value || undefined }),
  onError: e => toast.error(getErrorMessage(e, '加载失败')),
})

function onSearch() {
  toFirst()
  loadData()
}
function onReset() {
  searchName.value = ''
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
async function openEdit(id: number) {
  formTitle.value = '编辑'
  currentId.value = id
  try {
    const detail = await VersionAPI.getDetail(id)
    Object.assign(formData, {
      version: detail.version || '',
      title: detail.title || '',
      date: detail.date || '',
      content: detail.content || '',
      description: detail.description || '',
      sort: detail.sort ?? 0,
      status: detail.status ?? 0,
    })
    showForm.value = true
  }
  catch (e) { toast.error(getErrorMessage(e, '获取详情失败')) }
}
async function handleSubmit() {
  loading.value = true
  try {
    if (currentId.value) {
      await VersionAPI.update(currentId.value, { ...formData })
      toast.success('更新成功')
    }
    else {
      await VersionAPI.create({ ...formData })
      toast.success('创建成功')
    }
    showForm.value = false
    loadData()
  }
  catch (e) { toast.error(getErrorMessage(e, '操作失败')) }
  finally { loading.value = false }
}
function handleDelete(id: number) {
  uni.showModal({
    title: '提示',
    content: '确认删除？',
    success: async (res) => {
      if (res.confirm) {
        try {
          await VersionAPI.remove([id])
          toast.success('删除成功')
          loadData()
        }
        catch (e) { toast.error(getErrorMessage(e, '删除失败')) }
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
        <wd-input v-model="searchName" placeholder="搜索版本标题" clearable class="flex-1" />
        <wd-button size="small" type="primary" plain @click="onSearch">搜索</wd-button>
        <wd-button size="small" plain @click="onReset">重置</wd-button>
      </view>
    </view>
    <view class="action-bar">
      <text class="text-md font-bold text-muted">
        共 {{ total }} 条
      </text>
      <wd-button size="small" type="primary" @click="openCreate">+ 新增</wd-button>
    </view>
    <SkeletonPage v-if="loading" :rows="5" search />
    <template v-else>
      <view class="px-sm">
        <view class="admin-card">
          <ListEmpty v-if="!loading && list.length === 0" text="暂无数据" />
          <wd-cell-group v-else>
            <wd-cell v-for="item in list" :key="item.id" is-link @click="openEdit(item.id!)">
              <template #title>
                <view>
                  <text class="font-medium text-md">
                    {{ item.title || '未命名' }}
                  </text><text class="text-xs text-muted block mt-xs">
                    v{{ item.version || '-' }}{{ item.date ? ` · ${item.date}` : '' }}
                  </text>
                </view>
              </template>
              <template #label>
                <text class="text-xs text-muted">
                  {{ getStatusLabel(item.status) }}
                </text>
              </template>
              <view class="flex items-center gap-xs">
                <StatusBadge :status="getStatus(item.status)" />
                <wd-icon name="delete" size="18px" color="var(--danger-color)" @click.stop="handleDelete(item.id!)" />
              </view>
            </wd-cell>
          </wd-cell-group>
        </view>
      </view>
      <PaginationBar :current="pageParams.page_no" :page-size="pageParams.page_size" :total="total" @prev="loadPrev" @next="loadNext" />
      <wd-popup v-model="showForm" position="bottom" round custom-style="max-height: 80vh; overflow-y: auto;" @close="showForm = false">
        <view class="p-xl">
          <wd-navbar :title="formTitle" left-arrow @click-left="showForm = false" />
          <wd-form :model="formData" class="mt-lg">
            <wd-form-item label="版本号">
              <wd-input v-model="formData.version" placeholder="如 1.0.0" />
            </wd-form-item>
            <wd-form-item label="版本标题">
              <wd-input v-model="formData.title" placeholder="请输入" />
            </wd-form-item>
            <wd-form-item label="发布日期">
              <wd-input v-model="formData.date" placeholder="如 2024-01-01" />
            </wd-form-item>
            <wd-form-item label="排序">
              <wd-input v-model="formData.sort" type="number" placeholder="请输入" />
            </wd-form-item>
            <wd-form-item label="状态">
              <wd-radio-group v-model="formData.status">
                <wd-radio v-for="opt in STATUS_OPTIONS" :key="opt.value" :value="opt.value">
                  {{ opt.label }}
                </wd-radio>
              </wd-radio-group>
            </wd-form-item>
            <wd-form-item label="更新内容">
              <wd-textarea v-model="formData.content" placeholder="请输入" />
            </wd-form-item>
            <wd-form-item label="备注">
              <wd-textarea v-model="formData.description" placeholder="请输入" />
            </wd-form-item>
          </wd-form>
          <view class="flex gap-md mt-xl">
            <wd-button block plain @click="showForm = false">取消</wd-button>
            <wd-button block type="primary" :loading="loading" @click="handleSubmit">保存</wd-button>
          </view>
        </view>
      </wd-popup>
    </template>
  </view>
</template>
