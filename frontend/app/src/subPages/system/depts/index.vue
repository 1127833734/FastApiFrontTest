<script setup lang="ts">
import type { DeptForm, DeptItem } from '@/api/module_system/dept'
import { onLoad } from '@dcloudio/uni-app'
import { reactive, ref } from 'vue'
import { DeptAPI } from '@/api/module_system/dept'

definePage({ name: 'work-depts', style: { navigationBarTitleText: '部门管理' } })

const toast = useToast()
const loading = ref(false)
const treeList = ref<DeptItem[]>([])
const flatList = ref<(DeptItem & { _depth: number })[]>([])
const showForm = ref(false)
const formTitle = ref('')
const currentId = ref<number>()
const formData = reactive<DeptForm>({ name: '', code: '', order: 1, parent_id: undefined, leader: '', phone: '', email: '', status: 0, description: '' })

function flatten(items: DeptItem[], depth = 0): (DeptItem & { _depth: number })[] {
  let r: (DeptItem & { _depth: number })[] = []
  for (const item of items) {
    r.push({ ...item, _depth: depth })
    if (item.children?.length)
      r = r.concat(flatten(item.children, depth + 1))
  }
  return r
}

async function loadTree() {
  loading.value = true
  try {
    treeList.value = await DeptAPI.getTree() || []
    flatList.value = flatten(treeList.value)
  }
  catch (e) { toast.error(getErrorMessage(e, '加载失败')) }
  finally { loading.value = false }
}
function resetForm() {
  formData.name = ''
  formData.code = ''
  formData.order = 1
  formData.parent_id = undefined
  formData.leader = ''
  formData.phone = ''
  formData.email = ''
  formData.status = 0
  formData.description = ''
}
function openCreate(parentId?: number) {
  formTitle.value = '新增部门'
  currentId.value = undefined
  resetForm()
  formData.parent_id = parentId
  showForm.value = true
}
async function handleSubmit() {
  loading.value = true
  try {
    if (currentId.value) {
      await DeptAPI.update(currentId.value, formData)
      toast.success('更新成功')
    }
    else {
      await DeptAPI.create(formData)
      toast.success('创建成功')
    }
    showForm.value = false
    loadTree()
  }
  catch (e) { toast.error(getErrorMessage(e, '操作失败')) }
  finally { loading.value = false }
}
function handleDelete(id: number) {
  uni.showModal({ title: '提示', content: '确认删除该部门？', success: async (res) => {
    if (res.confirm) {
      try {
        await DeptAPI.remove([id])
        toast.success('删除成功')
        loadTree()
      }
      catch (e) { toast.error(getErrorMessage(e, '删除失败')) }
    }
  } })
}
onLoad(() => loadTree())
</script>

<template>
  <view class="page-wraper">
    <view class="action-bar">
      <text class="font-bold text-lg">
        部门列表
      </text>
      <u-button size="mini" type="primary" text="+ 新增" @click="openCreate()" />
    </view>
    <view class="px-sm">
      <view class="admin-card">
        <SkeletonPage v-if="loading" />
        <ListEmpty v-else-if="flatList.length === 0" text="暂无部门" />
        <u-cell-group v-else>
          <u-cell v-for="item in flatList" :key="item.id">
            <template #title>
              <view class="flex items-center gap-xs" :style="{ marginLeft: `${(item._depth || 0) * 36}rpx` }">
                <text v-if="item._depth > 0" class="text-muted" style="font-size: 20rpx;">
                  └─
                </text>
                <StatusBadge :status="item.status" dot />
                <text class="font-medium text-md">
                  {{ item.name }}
                </text>
                <text class="text-xs text-muted">
                  [{{ item.code }}]
                </text>
              </view>
            </template>
            <template #right>
              <u-icon name="plus" size="18" color="var(--success-color)" @click.stop="openCreate(item.id)" />
              <u-icon name="trash" size="18" color="var(--danger-color)" @click.stop="handleDelete(item.id)" />
            </template>
          </u-cell>
        </u-cell-group>
      </view>
    </view>
    <u-popup :show="showForm" mode="bottom" :round="10" custom-style="max-height: 80vh; overflow-y: auto;" @close="showForm = false">
      <view class="p-xl">
        <u-navbar :title="formTitle" left-icon="arrow-left" @left-click="showForm = false" />
        <u-form :model="formData" class="mt-lg">
          <u-form-item label="部门名称" prop="name" :border-bottom="true">
            <u-input v-model="formData.name" border="none" placeholder="请输入" />
          </u-form-item>
          <u-form-item label="部门编码" prop="code" :border-bottom="true">
            <u-input v-model="formData.code" border="none" placeholder="请输入" />
          </u-form-item>
          <u-form-item label="排序" :border-bottom="true">
            <u-input v-model="formData.order" border="none" type="number" placeholder="请输入" />
          </u-form-item>
          <u-form-item label="负责人" :border-bottom="true">
            <u-input v-model="formData.leader" border="none" placeholder="请输入" />
          </u-form-item>
          <u-form-item label="联系电话" :border-bottom="true">
            <u-input v-model="formData.phone" border="none" placeholder="请输入" />
          </u-form-item>
          <u-form-item label="邮箱" :border-bottom="true">
            <u-input v-model="formData.email" border="none" placeholder="请输入" />
          </u-form-item>
          <u-form-item label="备注" :border-bottom="true">
            <u-textarea v-model="formData.description" border="none" placeholder="请输入" />
          </u-form-item>
        </u-form>
        <view class="flex gap-md mt-xl">
          <u-button :block="true" :plain="true" text="取消" @click="showForm = false" /><u-button :block="true" type="primary" :loading="loading" text="保存" @click="handleSubmit" />
        </view>
      </view>
    </u-popup>
  </view>
</template>
