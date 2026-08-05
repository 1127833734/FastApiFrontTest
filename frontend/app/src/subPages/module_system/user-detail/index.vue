<script setup lang="ts">
import type { DeptItem } from '@/api/module_system/dept'
import type { UserForm } from '@/api/module_system/user'
import { onLoad } from '@dcloudio/uni-app'
import { ref } from 'vue'
import { DeptAPI } from '@/api/module_system/dept'
import { RoleAPI } from '@/api/module_system/role'
import UserAPI from '@/api/module_system/user'

definePage({
  name: 'work-user-detail',
  style: { navigationBarTitleText: '用户详情' },
})

const toast = useToast()
const loading = ref(false)
const saving = ref(false)
const isEdit = ref(false)
const userId = ref<number>()

const user = ref<UserForm>({})
const deptOptions = ref<{ value: number, label: string }[]>([])
const roleOptions = ref<{ value: number, label: string }[]>([])
const showPickerDept = ref(false)
const showPickerRole = ref(false)

interface PickerConfirmEvent { value: Array<string | number>, selectedOptions: any[] }
function handleDeptConfirm(e: PickerConfirmEvent) {
  const item = deptOptions.value.find(o => o.value === e.value[0])
  if (item)
    user.value.dept_id = item.value
  showPickerDept.value = false
}
function handleRoleConfirm(e: PickerConfirmEvent) {
  const item = roleOptions.value.find(o => o.value === e.value[0])
  if (item)
    user.value.role_ids = [item.value]
  showPickerRole.value = false
}

const GENDER_OPTIONS = [
  { value: 0, label: '男' },
  { value: 1, label: '女' },
  { value: 2, label: '未知' },
]

function genderLabel(gender?: number) {
  return GENDER_OPTIONS.find(g => g.value === gender)?.label || '未知'
}

function flattenDept(items: DeptItem[], prefix = ''): { value: number, label: string }[] {
  let r: { value: number, label: string }[] = []
  for (const item of items) {
    r.push({ value: item.id, label: prefix + item.name })
    if (item.children?.length)
      r = r.concat(flattenDept(item.children, `${prefix}  `))
  }
  return r
}

async function loadOptions() {
  try {
    const [deptTree, roleRes] = await Promise.all([
      DeptAPI.getTree().catch(() => [] as DeptItem[]),
      RoleAPI.getOptions().catch(() => []),
    ])
    deptOptions.value = flattenDept(deptTree || [])
    roleOptions.value = (roleRes || []).map(r => ({ value: r.value, label: r.label }))
  }
  catch { /* silent */ }
}

async function loadUser() {
  if (!userId.value)
    return
  loading.value = true
  try {
    const res = await UserAPI.getUserDetail(userId.value)
    user.value = res
  }
  catch {
    toast.error('加载用户详情失败')
  }
  finally {
    loading.value = false
  }
}

async function handleSave() {
  if (!user.value.id)
    return
  saving.value = true
  try {
    await UserAPI.updateUser(user.value)
    toast.success('保存成功')
    isEdit.value = false
  }
  catch {
    toast.error('保存失败')
  }
  finally {
    saving.value = false
  }
}

function handleToggleStatus() {
  // 后端规范: 0=启用, 1=禁用
  const newStatus = user.value.status === 1 ? 0 : 1
  const action = newStatus === 0 ? '启用' : '禁用'
  uni.showModal({
    title: '确认操作',
    content: `确认${action}该用户吗？`,
    success: async (res) => {
      if (res.confirm) {
        try {
          user.value.status = newStatus
          await UserAPI.updateUser(user.value)
          toast.success(`${action}成功`)
        }
        catch {
          toast.error('操作失败')
        }
      }
    },
  })
}

onLoad((query) => {
  userId.value = Number(query?.id)
  loadOptions()
  loadUser()
})
</script>

<template>
  <view class="page-wraper py-3">
    <SkeletonPage v-if="loading" :rows="6" />

    <template v-else>
      <!-- Avatar -->
      <view class="mx-3 mb-3 flex flex-col items-center gap-2 py-4">
        <wd-avatar
          size="80px"
          round
          :text="(user.name || user.username || '?').charAt(0)"
          bg-color="var(--primary-color)"
          color="#FFFFFF"
        />
        <text class="text-4 font-bold wot-text-text-main">
          {{ user.name || user.username || '未知用户' }}
        </text>
      </view>

      <!-- View mode -->
      <view v-if="!isEdit" class="mx-3 mb-3">
        <wd-cell-group border custom-class="rounded-2! overflow-hidden">
          <wd-cell title="用户名" :value="user.username || '-'" />
          <wd-cell title="邮箱" :value="user.email || '-'" />
          <wd-cell title="手机号" :value="user.mobile || '-'" />
          <wd-cell title="性别" :value="genderLabel(user.gender)" />
          <wd-cell title="角色" :value="user.role_names?.join(', ') || roleOptions.find(r => user.role_ids?.includes(r.value))?.label || '-'" />
          <wd-cell title="部门" :value="user.dept_name || deptOptions.find(d => d.value === user.dept_id)?.label || '-'" />
          <wd-cell title="状态">
            <StatusBadge :status="user.status" />
          </wd-cell>
        </wd-cell-group>
      </view>

      <!-- Edit mode -->
      <view v-else class="mx-3 mb-3">
        <view class="rounded-2 p-3 wot-bg-filled-oppo">
          <wd-form :model="user">
            <wd-form-item label="用户名" border>
              <wd-input v-model="user.username" placeholder="请输入用户名" />
            </wd-form-item>
            <wd-form-item label="姓名" border>
              <wd-input v-model="user.name" placeholder="请输入姓名" />
            </wd-form-item>
            <wd-form-item label="邮箱" border>
              <wd-input v-model="user.email" placeholder="请输入邮箱" />
            </wd-form-item>
            <wd-form-item label="手机号" border>
              <wd-input v-model="user.mobile" placeholder="请输入手机号" />
            </wd-form-item>
            <wd-form-item label="性别" border>
              <wd-radio-group v-model="user.gender">
                <wd-radio v-for="g in GENDER_OPTIONS" :key="g.value" :value="g.value">
                  {{ g.label }}
                </wd-radio>
              </wd-radio-group>
            </wd-form-item>
            <wd-form-item label="部门" border>
              <view class="flex-1" @click="showPickerDept = true">
                <wd-cell :value="deptOptions.find(o => o.value === user.dept_id)?.label || '选择部门'" is-link :border="false" />
              </view>
              <wd-picker :visible="showPickerDept" :columns="[deptOptions]" @confirm="handleDeptConfirm" @cancel="showPickerDept = false" />
            </wd-form-item>
            <wd-form-item label="角色" border>
              <view class="flex-1" @click="showPickerRole = true">
                <wd-cell :value="roleOptions.find(o => o.value === user.role_ids?.[0])?.label || '选择角色'" is-link :border="false" />
              </view>
              <wd-picker :visible="showPickerRole" :columns="[roleOptions]" @confirm="handleRoleConfirm" @cancel="showPickerRole = false" />
            </wd-form-item>
          </wd-form>
        </view>
      </view>

      <!-- Actions -->
      <view v-if="isEdit" class="mx-3 flex flex-col gap-3">
        <wd-button type="primary" round block :loading="saving" @click="handleSave">
          保存修改
        </wd-button>
        <wd-button variant="plain" round block @click="isEdit = false">
          取消
        </wd-button>
      </view>
      <view v-else class="mx-3 flex flex-col gap-3">
        <wd-button type="primary" round block @click="isEdit = true">
          编辑资料
        </wd-button>
        <wd-button type="danger" plain round block @click="handleToggleStatus">
          {{ user.status === 1 ? '启用账号' : '禁用账号' }}
        </wd-button>
      </view>
    </template>
  </view>
</template>
