<script setup lang="ts">
import type { DeptItem } from '@/api/module_system/dept'
import type { UserForm } from '@/api/module_system/user'
import { onLoad } from '@dcloudio/uni-app'
import { ref } from 'vue'
import { DeptAPI } from '@/api/module_system/dept'
import { RoleAPI } from '@/api/module_system/role'
import UserAPI from '@/api/module_system/user'
import SkeletonPage from '@/components/SkeletonPage.vue'

definePage({
  name: 'work-user-detail',
  style: { navigationBarTitleText: '用户详情' },
})

const toast = useToast()
const router = useRouter()
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

const STATUS_OPTIONS = [
  { value: 1, label: '正常', color: '#10B981', bg: '#E8F8F1' },
  { value: 0, label: '禁用', color: '#EF4444', bg: '#FEF2F2' },
]

const GENDER_OPTIONS = [
  { value: 0, label: '男' },
  { value: 1, label: '女' },
  { value: 2, label: '未知' },
]

function statusBadge(status?: number) {
  return STATUS_OPTIONS.find(s => s.value === status) || STATUS_OPTIONS[1]
}

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
  const newStatus = user.value.status === 1 ? 0 : 1
  const action = newStatus === 0 ? '禁用' : '启用'
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

function goBack() {
  router.back()
}

onLoad((query) => {
  userId.value = Number(query?.id)
  loadOptions()
  loadUser()
})
</script>

<template>
  <view class="user-detail-page">
    <SkeletonPage v-if="loading" :rows="6" />

    <template v-else>
      <!-- Nav -->
      <view class="detail-nav">
        <text class="detail-nav__back" @click="goBack">
          ← 返回
        </text>
        <text class="detail-nav__title">
          用户详情
        </text>
        <view class="detail-nav__edit" @click="isEdit = !isEdit">
          <text class="detail-nav__edit-text">
            {{ isEdit ? '取消' : '编辑' }}
          </text>
        </view>
      </view>

      <!-- Avatar -->
      <view class="detail-avatar-area">
        <view class="detail-avatar">
          <text class="detail-avatar__text">
            {{ (user.name || user.username || '?').charAt(0) }}
          </text>
        </view>
        <text class="detail-avatar__name">
          {{ user.name || user.username || '未知用户' }}
        </text>
      </view>

      <!-- View mode -->
      <view v-if="!isEdit" class="detail-card">
        <view class="detail-row">
          <text class="detail-row__label">
            用户名
          </text>
          <text class="detail-row__value">
            {{ user.username || '-' }}
          </text>
        </view>
        <view class="detail-divider" />
        <view class="detail-row">
          <text class="detail-row__label">
            邮箱
          </text>
          <text class="detail-row__value">
            {{ user.email || '-' }}
          </text>
        </view>
        <view class="detail-divider" />
        <view class="detail-row">
          <text class="detail-row__label">
            手机号
          </text>
          <text class="detail-row__value">
            {{ user.mobile || '-' }}
          </text>
        </view>
        <view class="detail-divider" />
        <view class="detail-row">
          <text class="detail-row__label">
            性别
          </text>
          <text class="detail-row__value">
            {{ genderLabel(user.gender) }}
          </text>
        </view>
        <view class="detail-divider" />
        <view class="detail-row">
          <text class="detail-row__label">
            角色
          </text>
          <text class="detail-row__value" style="color: var(--primary-color);">
            {{ user.role_names?.join(', ') || roleOptions.find(r => user.role_ids?.includes(r.value))?.label || '-' }}
          </text>
        </view>
        <view class="detail-divider" />
        <view class="detail-row">
          <text class="detail-row__label">
            部门
          </text>
          <text class="detail-row__value">
            {{ user.dept_name || deptOptions.find(d => d.value === user.dept_id)?.label || '-' }}
          </text>
        </view>
        <view class="detail-divider" />
        <view class="detail-row">
          <text class="detail-row__label">
            状态
          </text>
          <view class="detail-status" :style="{ background: statusBadge(user.status).bg, color: statusBadge(user.status).color }">
            <text class="detail-status__text">
              {{ statusBadge(user.status).label }}
            </text>
          </view>
        </view>
      </view>

      <!-- Edit mode -->
      <view v-else class="detail-card">
        <view class="form-row">
          <text class="form-row__label">
            用户名
          </text>
          <wd-input v-model="user.username" placeholder="请输入用户名" />
        </view>
        <view class="detail-divider" />
        <view class="form-row">
          <text class="form-row__label">
            姓名
          </text>
          <wd-input v-model="user.name" placeholder="请输入姓名" />
        </view>
        <view class="detail-divider" />
        <view class="form-row">
          <text class="form-row__label">
            邮箱
          </text>
          <wd-input v-model="user.email" placeholder="请输入邮箱" />
        </view>
        <view class="detail-divider" />
        <view class="form-row">
          <text class="form-row__label">
            手机号
          </text>
          <wd-input v-model="user.mobile" placeholder="请输入手机号" />
        </view>
        <view class="detail-divider" />
        <view class="form-row">
          <text class="form-row__label">
            性别
          </text>
          <wd-radio-group v-model="user.gender">
            <wd-radio v-for="g in GENDER_OPTIONS" :key="g.value" :value="g.value">
              {{ g.label }}
            </wd-radio>
          </wd-radio-group>
        </view>
        <view class="detail-divider" />
        <view class="form-row">
          <text class="form-row__label">
            部门
          </text>
          <view style="flex:1" @click="showPickerDept = true">
            <wd-cell :value="deptOptions.find(o => o.value === user.dept_id)?.label || '选择部门'" is-link :border="false" />
          </view>
          <wd-picker :visible="showPickerDept" :columns="[deptOptions]" @confirm="handleDeptConfirm" @cancel="showPickerDept = false" />
        </view>
        <view class="detail-divider" />
        <view class="form-row">
          <text class="form-row__label">
            角色
          </text>
          <view style="flex:1" @click="showPickerRole = true">
            <wd-cell :value="roleOptions.find(o => o.value === user.role_ids?.[0])?.label || '选择角色'" is-link :border="false" />
          </view>
          <wd-picker :visible="showPickerRole" :columns="[roleOptions]" @confirm="handleRoleConfirm" @cancel="showPickerRole = false" />
        </view>
      </view>

      <!-- Actions -->
      <view v-if="isEdit" class="detail-actions">
        <view class="detail-btn detail-btn--primary" @click="handleSave">
          <text class="detail-btn__text">
            保存修改
          </text>
        </view>
      </view>

      <view v-else class="detail-actions">
        <view class="detail-btn detail-btn--primary" @click="isEdit = true">
          <text class="detail-btn__text">
            编辑资料
          </text>
        </view>
        <view
          class="detail-btn detail-btn--danger"
          @click="handleToggleStatus"
        >
          <text class="detail-btn__text">
            {{ user.status === 1 ? '禁用账号' : '启用账号' }}
          </text>
        </view>
      </view>
    </template>
  </view>
</template>

<style lang="scss" scoped>
.user-detail-page {
  min-height: 100vh;
  background: var(--page-bg-color, #F9F9F9);
  padding: var(--spacing-lg, 16px);
  padding-bottom: calc(var(--spacing-lg, 16px) + env(safe-area-inset-bottom));
}

.detail-nav {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 44px;
  margin-bottom: var(--spacing-lg, 16px);

  &__back {
    font-size: var(--font-md, 28rpx);
    color: var(--primary-color, #4F8CFF);
  }

  &__title {
    font-size: var(--font-xl, 36rpx);
    font-weight: 600;
    color: var(--text-color, #0A1628);
  }

  &__edit {
    background: var(--primary-color, #4F8CFF);
    border-radius: var(--radius-full, 9999rpx);
    padding: 4px 14px;
  }

  &__edit-text {
    font-size: var(--font-sm, 24rpx);
    color: #FFFFFF;
  }
}

.detail-avatar-area {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  margin-bottom: var(--spacing-lg, 16px);
}

.detail-avatar {
  width: 72px;
  height: 72px;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--primary-color, #4F8CFF), var(--primary-color-dark, #2970FF));
  display: flex;
  align-items: center;
  justify-content: center;

  &__text {
    font-size: 32px;
    font-weight: 700;
    color: #FFFFFF;
  }

  &__name {
    font-size: var(--font-xl, 36rpx);
    font-weight: 600;
    color: var(--text-color, #0A1628);
  }
}

.detail-card {
  background: var(--card-bg-color, #FFFFFF);
  border-radius: var(--radius-md, 16rpx);
  box-shadow: var(--shadow-sm, 0 1rpx 2rpx rgba(1, 77, 178,0.06));
  margin-bottom: var(--spacing-lg, 16px);
  overflow: hidden;
}

.detail-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 16px;

  &__label {
    font-size: var(--font-md, 28rpx);
    color: var(--text-color-3, #6B7280);
  }

  &__value {
    font-size: var(--font-md, 28rpx);
    color: var(--text-color, #0A1628);
  }
}

.detail-divider {
  height: 1px;
  background: var(--border-color, #EAEAEA);
  margin: 0 16px;
}

.detail-status {
  padding: 4px 12px;
  border-radius: var(--radius-full, 9999rpx);
  font-size: var(--font-xs, 20rpx);
  font-weight: 500;
}

.form-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 10px 16px;
  gap: 12px;

  &__label {
    font-size: var(--font-md, 28rpx);
    color: var(--text-color-3, #6B7280);
    flex-shrink: 0;
    width: 60px;
  }

  :deep(.wd-input) {
    flex: 1;
  }
}

.detail-actions {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-md, 12px);
}

.detail-btn {
  height: 48px;
  border-radius: var(--radius-full, 9999rpx);
  display: flex;
  align-items: center;
  justify-content: center;

  &--primary {
    background: linear-gradient(135deg, var(--primary-color, #4F8CFF), var(--primary-color-dark, #2970FF));
    box-shadow: 0 4px 12px rgba(1, 77, 178, 0.25);
  }

  &--danger {
    background: var(--danger-color-light, #FEF2F2);
  }

  &__text {
    font-size: var(--font-lg, 32rpx);
    font-weight: 600;
    color: #FFFFFF;
  }

  &--danger &__text {
    color: var(--danger-color, #EF4444);
    font-weight: 500;
  }
}
</style>
