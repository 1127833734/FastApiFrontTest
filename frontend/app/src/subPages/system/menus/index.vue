<script setup lang="ts">
import type { MenuForm, MenuItem } from '@/api/module_system/menu'
import { onLoad } from '@dcloudio/uni-app'
import { reactive, ref } from 'vue'
import { MenuAPI } from '@/api/module_system/menu'

definePage({ name: 'work-menus', style: { navigationBarTitleText: '菜单管理' } })

const toast = useToast()
const loading = ref(false)
const treeList = ref<MenuItem[]>([])
const flatList = ref<(MenuItem & { _depth: number })[]>([])
const showForm = ref(false)
const formTitle = ref('')
const currentId = ref<number>()
const formData = reactive<MenuForm>({ name: '', type: 2, order: 1, parent_id: undefined, permission: '', icon: '', route_name: '', route_path: '', component_path: '', redirect: '', hidden: false, keep_alive: true, always_show: false, title: '', affix: false, status: 0, description: '', client: 'pc' })

const typeLabels: Record<number, string> = { 1: '目录', 2: '菜单', 3: '按钮', 4: '外链' }
const typeColors: Record<number, string> = { 1: 'primary', 2: 'enabled', 3: 'draft', 4: 'failed' }

function flatten(items: MenuItem[], depth = 0): (MenuItem & { _depth: number })[] {
  let r: (MenuItem & { _depth: number })[] = []
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
    treeList.value = await MenuAPI.getTree() || []
    flatList.value = flatten(treeList.value)
  }
  catch (e) { toast.error(getErrorMessage(e, '加载失败')) }
  finally { loading.value = false }
}
function resetForm() {
  Object.assign(formData, { name: '', type: 2, order: 1, parent_id: undefined, permission: '', icon: '', route_name: '', route_path: '', component_path: '', redirect: '', hidden: false, keep_alive: true, always_show: false, title: '', affix: false, status: 0, description: '', client: 'pc' })
}
function openCreate(parentId?: number) {
  formTitle.value = '新增菜单'
  currentId.value = undefined
  resetForm()
  formData.parent_id = parentId
  showForm.value = true
}
async function handleSubmit() {
  loading.value = true
  try {
    if (currentId.value) {
      await MenuAPI.update(currentId.value, formData)
      toast.success('更新成功')
    }
    else {
      await MenuAPI.create(formData)
      toast.success('创建成功')
    }
    showForm.value = false
    loadTree()
  }
  catch (e) { toast.error(getErrorMessage(e, '操作失败')) }
  finally { loading.value = false }
}
function handleDelete(id: number) {
  uni.showModal({ title: '提示', content: '确认删除该菜单？', success: async (res) => {
    if (res.confirm) {
      try {
        await MenuAPI.remove([id])
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
        菜单列表
      </text>
      <wd-button size="small" type="primary" @click="openCreate()">
        + 新增
      </wd-button>
    </view>
    <view class="px-sm">
      <view class="admin-card">
        <SkeletonPage v-if="loading" />
        <ListEmpty v-else-if="flatList.length === 0" text="暂无菜单" />
        <wd-cell-group v-else>
          <wd-cell v-for="item in flatList" :key="item.id">
            <template #title>
              <view class="flex items-center gap-xs" :style="{ marginLeft: `${(item._depth || 0) * 36}rpx` }">
                <text v-if="item._depth > 0" class="text-muted" style="font-size: 20rpx;">
                  └─
                </text>
                <text v-if="item.icon" class="text-primary" style="font-size: 24rpx;">
                  {{ item.icon }}
                </text>
                <text class="text-md font-medium">
                  {{ item.name }}
                </text>
                <span class="status-badge" :class="`status-badge--${typeColors[item.type] || 'disabled'}`" style="font-size: 18rpx; padding: 0 10rpx;">
                  {{ typeLabels[item.type] || '未知' }}
                </span>
              </view>
            </template>
            <template #default>
              <StatusBadge :status="item.status" />
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
          <wd-form-item label="菜单名称">
            <wd-input v-model="formData.name" placeholder="请输入" />
          </wd-form-item>
          <wd-form-item label="类型(1-4)">
            <wd-input v-model="formData.type" type="number" placeholder="目录/菜单/按钮/外链" />
          </wd-form-item>
          <wd-form-item label="排序">
            <wd-input v-model="formData.order" type="number" placeholder="请输入" />
          </wd-form-item>
          <wd-form-item label="权限标识">
            <wd-input v-model="formData.permission" placeholder="如 sys:user:query" />
          </wd-form-item>
          <wd-form-item label="路由地址">
            <wd-input v-model="formData.route_path" placeholder="如 /system/user" />
          </wd-form-item>
          <wd-form-item label="组件路径">
            <wd-input v-model="formData.component_path" placeholder="system/user/index" />
          </wd-form-item>
          <wd-form-item label="图标">
            <wd-input v-model="formData.icon" placeholder="图标名称" />
          </wd-form-item>
          <wd-form-item label="备注">
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
