<script setup lang="ts">
import type { PositionForm, PositionItem } from '@/api/module_system/position'
import { onLoad, onPullDownRefresh } from '@dcloudio/uni-app'
import { reactive, ref } from 'vue'
import { PositionAPI } from '@/api/module_system/position'

definePage({ name: 'work-positions', style: { navigationBarTitleText: '岗位管理' } })

const toast = useToast()
const searchName = ref('')
const showForm = ref(false)
const formTitle = ref('')
const currentId = ref<number>()
const formData = reactive<PositionForm>({ name: '', code: '', order: 1, status: 0, description: '' })

const { list, total, loading, pageParams, loadData, toFirst, loadPrev, loadNext } = useListPage<PositionItem>({
  fetcher: p => PositionAPI.getPage({ ...p, name: searchName.value || undefined }),
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
  Object.assign(formData, { name: '', code: '', order: 1, status: 0, description: '' })
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
    const detail = await PositionAPI.getDetail(id)
    Object.assign(formData, { name: detail.name, code: detail.code || '', order: detail.order || 1, status: detail.status ?? 0, description: detail.description || '' })
    showForm.value = true
  }
  catch (e) { toast.error(getErrorMessage(e, '获取详情失败')) }
}
async function handleSubmit() {
  loading.value = true
  try {
    if (currentId.value) {
      await PositionAPI.update(currentId.value, formData)
      toast.success('更新成功')
    }
    else {
      await PositionAPI.create(formData)
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
          await PositionAPI.remove([id])
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
        <u-input v-model="searchName" placeholder="搜索名称" clearable border="surround" class="flex-1" />
        <u-button size="mini" type="primary" :plain="true" text="搜索" @click="onSearch" />
        <u-button size="mini" :plain="true" text="重置" @click="onReset" />
      </view>
    </view>
    <view class="action-bar">
      <text class="text-md font-bold text-muted">
        共 {{ total }} 条
      </text>
      <u-button size="mini" type="primary" text="+ 新增" @click="openCreate" />
    </view>
    <SkeletonPage v-if="loading" :rows="5" search />
    <template v-else>
      <view class="px-sm">
        <view class="admin-card">
          <ListEmpty v-if="!loading && list.length === 0" text="暂无数据" />
          <u-cell-group v-else>
            <u-cell v-for="item in list" :key="item.id" :is-link="true" @click="openEdit(item.id!)">
              <template #title>
                <view>
                  <text class="font-medium text-md">
                    {{ item.name }}
                  </text><text class="text-xs text-muted block mt-xs">
                    {{ `编码: ${item.code || '-'}` }}
                  </text>
                </view>
              </template>
              <template #value>
                <StatusBadge :status="item.status" />
              </template>
              <template #right>
                <u-icon name="trash" size="18" color="var(--danger-color)" @click.stop="handleDelete(item.id!)" />
              </template>
            </u-cell>
          </u-cell-group>
        </view>
      </view>
      <PaginationBar :current="pageParams.page_no" :page-size="pageParams.page_size" :total="total" @prev="loadPrev" @next="loadNext" />
      <u-popup :show="showForm" mode="bottom" :round="10" custom-style="max-height: 80vh; overflow-y: auto;" @close="showForm = false">
        <view class="p-xl">
          <u-navbar :title="formTitle" left-icon="arrow-left" @left-click="showForm = false" />
          <u-form :model="formData" class="mt-lg">
            <u-form-item label="岗位名称" prop="name" :border-bottom="true">
              <u-input v-model="formData.name" border="none" placeholder="请输入" />
            </u-form-item>
            <u-form-item label="岗位编码" prop="code" :border-bottom="true">
              <u-input v-model="formData.code" border="none" placeholder="请输入" />
            </u-form-item>
            <u-form-item label="排序" :border-bottom="true">
              <u-input v-model="formData.order" border="none" type="number" placeholder="请输入" />
            </u-form-item>
            <u-form-item label="备注" :border-bottom="true">
              <u-textarea v-model="formData.description" border="none" placeholder="请输入" />
            </u-form-item>
          </u-form>
          <view class="flex gap-md mt-xl">
            <u-button :block="true" :plain="true" text="取消" @click="showForm = false" />
            <u-button :block="true" type="primary" :loading="loading" text="保存" @click="handleSubmit" />
          </view>
        </view>
      </u-popup>
    </template>
  </view>
</template>
