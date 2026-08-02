<script setup lang="ts">
import type { RoleForm, RoleItem } from '@/api/module_system/role'
import { onLoad, onPullDownRefresh } from '@dcloudio/uni-app'
import { reactive, ref } from 'vue'
import { RoleAPI } from '@/api/module_system/role'

definePage({ name: 'work-roles', style: { navigationBarTitleText: '角色管理' } })

const toast = useToast()
const searchName = ref('')
const showForm = ref(false)
const formTitle = ref('')
const currentId = ref<number>()
const formRef = ref()
const formData = reactive<RoleForm>({ name: '', code: '', order: 1, data_scope: 4, status: 0, description: '' })

const { list, total, loading, pageParams, loadData, toFirst, loadPrev, loadNext } = useListPage<RoleItem>({
  fetcher: p => RoleAPI.getPage({ ...p, name: searchName.value || undefined }),
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
  formData.name = ''
  formData.code = ''
  formData.order = 1
  formData.data_scope = 4
  formData.status = 0
  formData.description = ''
}
function openCreate() {
  formTitle.value = '新增角色'
  currentId.value = undefined
  resetForm()
  showForm.value = true
}
async function openEdit(id: number) {
  formTitle.value = '编辑角色'
  currentId.value = id
  try {
    const detail = await RoleAPI.getDetail(id)
    Object.assign(formData, { name: detail.name, code: detail.code, order: detail.order || 1, data_scope: detail.data_scope || 4, status: detail.status ?? 0, description: detail.description || '' })
    showForm.value = true
  }
  catch (e) { toast.error(getErrorMessage(e, '获取详情失败')) }
}
async function handleSubmit() {
  loading.value = true
  try {
    if (currentId.value) {
      await RoleAPI.update(currentId.value, formData)
      toast.success('更新成功')
    }
    else {
      await RoleAPI.create(formData)
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
    content: '确认删除该角色？',
    success: async (res) => {
      if (res.confirm) {
        try {
          await RoleAPI.remove([id])
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
        <wd-input v-model="searchName" placeholder="搜索角色名称" clearable class="flex-1" />
        <wd-button size="small" type="primary" plain @click="onSearch">
          搜索
        </wd-button>
        <wd-button size="small" plain @click="onReset">
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
          <ListEmpty v-if="!loading && list.length === 0" text="暂无角色" />
          <wd-cell-group v-else>
            <wd-cell v-for="item in list" :key="item.id" is-link @click="openEdit(item.id!)">
              <template #title>
                <view>
                  <text class="text-md font-medium">
                    {{ item.name }}
                  </text>
                  <text class="text-muted block text-xs">
                    {{ item.code }}{{ item.description ? ` · ${item.description}` : '' }}
                  </text>
                </view>
              </template>
              <template #default>
                <StatusBadge :status="item.status" />
                <wd-icon name="delete" size="18px" color="var(--danger-color)" @click.stop="handleDelete(item.id!)" />
              </template>
            </wd-cell>
          </wd-cell-group>
        </view>
      </view>
      <PaginationBar :current="pageParams.page_no" :page-size="pageParams.page_size" :total="total" @prev="loadPrev" @next="loadNext" />
      <wd-popup v-model="showForm" position="bottom" round custom-style="max-height: 80vh; overflow-y: auto;" @close="showForm = false">
        <view class="p-xl">
          <wd-navbar :title="formTitle" left-arrow @click-left="showForm = false" />
          <wd-form ref="formRef" :model="formData" class="mt-lg">
            <wd-form-item label="角色名称" prop="name" border>
              <wd-input v-model="formData.name" placeholder="请输入" />
            </wd-form-item>
            <wd-form-item label="角色编码" prop="code" border>
              <wd-input v-model="formData.code" placeholder="请输入" />
            </wd-form-item>
            <wd-form-item label="排序" border>
              <wd-input v-model="formData.order" type="number" placeholder="请输入" />
            </wd-form-item>
            <wd-form-item label="备注" border>
              <wd-textarea v-model="formData.description" placeholder="请输入" />
            </wd-form-item>
          </wd-form>
          <view class="gap-md mt-xl flex">
            <wd-button plain block @click="showForm = false">
              取消
            </wd-button>
            <wd-button block type="primary" :loading="loading" @click="handleSubmit">
              保存
            </wd-button>
          </view>
        </view>
      </wd-popup>
    </template>
  </view>
</template>
