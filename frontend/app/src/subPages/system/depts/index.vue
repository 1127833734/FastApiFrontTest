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
      <text class="text-lg font-bold">
        部门列表
      </text>
      <wd-button size="small" type="primary" @click="openCreate()">
        + 新增
      </wd-button>
    </view>
    <view class="px-sm">
      <view class="admin-card">
        <SkeletonPage v-if="loading" />
        <ListEmpty v-else-if="flatList.length === 0" text="暂无部门" />
        <wd-cell-group v-else>
          <wd-cell v-for="item in flatList" :key="item.id">
            <template #title>
              <view class="flex items-center gap-xs" :style="{ marginLeft: `${(item._depth || 0) * 36}rpx` }">
                <text v-if="item._depth > 0" class="text-muted" style="font-size: 20rpx;">
                  └─
                </text>
                <StatusBadge :status="item.status" dot />
                <text class="text-md font-medium">
                  {{ item.name }}
                </text>
                <text class="text-muted text-xs">
                  [{{ item.code }}]
                </text>
              </view>
            </template>
            <template #default>
              <wd-icon name="plus" size="18px" color="var(--success-color)" @click.stop="openCreate(item.id)" />
              <wd-icon name="delete" size="18px" color="var(--danger-color)" @click.stop="handleDelete(item.id)" />
            </template>
          </wd-cell>
        </wd-cell-group>
      </view>
    </view>
    <wd-popup v-model="showForm" position="bottom" round custom-style="max-height: 80vh; overflow-y: auto;" @close="showForm = false">
      <view class="p-xl">
        <wd-navbar :title="formTitle" left-arrow @click-left="showForm = false" />
        <wd-form :model="formData" class="mt-lg">
          <wd-form-item label="部门名称" prop="name" border>
            <wd-input v-model="formData.name" placeholder="请输入" />
          </wd-form-item>
          <wd-form-item label="部门编码" prop="code" border>
            <wd-input v-model="formData.code" placeholder="请输入" />
          </wd-form-item>
          <wd-form-item label="排序" border>
            <wd-input v-model="formData.order" type="number" placeholder="请输入" />
          </wd-form-item>
          <wd-form-item label="负责人" border>
            <wd-input v-model="formData.leader" placeholder="请输入" />
          </wd-form-item>
          <wd-form-item label="联系电话" border>
            <wd-input v-model="formData.phone" placeholder="请输入" />
          </wd-form-item>
          <wd-form-item label="邮箱" border>
            <wd-input v-model="formData.email" placeholder="请输入" />
          </wd-form-item>
          <wd-form-item label="备注" border>
            <wd-textarea v-model="formData.description" placeholder="请输入" />
          </wd-form-item>
        </wd-form>
        <view class="gap-md mt-xl flex">
          <wd-button plain block @click="showForm = false">
            取消
          </wd-button><wd-button block type="primary" :loading="loading" @click="handleSubmit">
            保存
          </wd-button>
        </view>
      </view>
    </wd-popup>
  </view>
</template>
