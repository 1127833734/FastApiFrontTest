<script setup lang="ts">
import type { NoticeForm, NoticeItem } from '@/api/module_system/notice'
import { onLoad, onPullDownRefresh } from '@dcloudio/uni-app'
import { reactive, ref } from 'vue'
import { NoticeAPI } from '@/api/module_system/notice'

definePage({ name: 'work-notices', style: { navigationBarTitleText: '通知公告' } })

const toast = useToast()
const searchTitle = ref('')
const showForm = ref(false)
const formTitle = ref('')
const currentId = ref<number>()
const formData = reactive<NoticeForm>({ notice_title: '', notice_content: '', notice_type: '1', status: 0, description: '' })

const NOTICE_TYPE_OPTIONS = [{ value: '1', label: '通知' }, { value: '2', label: '公告' }]
const STATUS_OPTIONS = [{ value: 0, label: '草稿' }, { value: 1, label: '已发布' }, { value: 2, label: '已归档' }]

function statusLabel(s: number | string | undefined) {
  const n = Number(s)
  if (n === 1)
    return 'published'
  if (n === 2)
    return 'archived'
  return 'draft'
}

const { list, total, loading, pageParams, loadData, toFirst, loadNext } = useListPage<NoticeItem>({
  fetcher: p => NoticeAPI.getPage({ ...p, notice_title: searchTitle.value || undefined }),
  onError: () => toast.error('加载失败'),
})

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
  toFirst()
  loadData()
}
function resetForm() {
  Object.assign(formData, { notice_title: '', notice_content: '', notice_type: '1', status: 0, description: '' })
}
function openCreate() {
  formTitle.value = '新增公告'
  currentId.value = undefined
  resetForm()
  showForm.value = true
}
async function openEdit(id: number) {
  formTitle.value = '编辑公告'
  currentId.value = id
  try {
    const detail = await NoticeAPI.getDetail(id)
    Object.assign(formData, {
      notice_title: detail.notice_title || '',
      notice_content: detail.notice_content || '',
      notice_type: detail.notice_type || '1',
      status: detail.status ?? 0,
      description: detail.description || '',
    })
    showForm.value = true
  }
  catch { toast.error('获取详情失败') }
}
async function handleSubmit() {
  loading.value = true
  try {
    if (currentId.value) {
      await NoticeAPI.update(currentId.value, formData)
      toast.success('更新成功')
    }
    else {
      await NoticeAPI.create(formData)
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
          await NoticeAPI.remove([id])
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
        <wd-input v-model="searchTitle" placeholder="搜索公告标题" clearable class="flex-1" />
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
          <wd-empty v-if="!loading && list.length === 0" tip="暂无公告" />
          <wd-cell-group v-else>
            <wd-cell v-for="item in list" :key="item.id" center is-link @click="openEdit(item.id!)">
              <template #title>
                <view>
                  <text class="text-md font-medium">
                    {{ item.notice_title }}
                  </text><text class="text-muted mt-xs block text-xs">
                    {{ item.description || '' }}
                  </text>
                </view>
              </template>
              <view class="flex items-center gap-xs">
                <StatusBadge :status="statusLabel(item.status)" />
                <wd-icon name="delete" size="18px" color="var(--danger-color)" @click.stop="handleDelete(item.id!)" />
              </view>
            </wd-cell>
          </wd-cell-group>
        </view>
      </view>
      <wd-pagination
        :model-value="pageParams.page_no"
        :total="total"
        :page-size="pageParams.page_size"
        button-variant="plain"
        hide-if-one-page
        @change="handlePageChange"
      />
      <wd-popup v-model="showForm" position="bottom" round custom-style="max-height: 80vh; overflow-y: auto;" @close="showForm = false">
        <view class="p-xl">
          <wd-navbar :title="formTitle" left-arrow @click-left="showForm = false" />
          <wd-form :model="formData" class="mt-lg">
            <wd-form-item label="公告标题" prop="notice_title" border>
              <wd-input v-model="formData.notice_title" placeholder="请输入" />
            </wd-form-item>
            <wd-form-item label="公告内容" prop="notice_content" border>
              <wd-textarea v-model="formData.notice_content" placeholder="请输入内容" />
            </wd-form-item>
            <wd-form-item label="公告类型" border>
              <wd-radio-group v-model="formData.notice_type">
                <wd-radio v-for="opt in NOTICE_TYPE_OPTIONS" :key="opt.value" :value="opt.value">
                  {{ opt.label }}
                </wd-radio>
              </wd-radio-group>
            </wd-form-item>
            <wd-form-item label="状态" border>
              <wd-radio-group v-model="formData.status">
                <wd-radio v-for="opt in STATUS_OPTIONS" :key="opt.value" :value="opt.value">
                  {{ opt.label }}
                </wd-radio>
              </wd-radio-group>
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
    </template>
  </view>
</template>
