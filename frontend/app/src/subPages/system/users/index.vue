<script setup lang="ts">
import type { DeptItem } from '@/api/module_system/dept'
import type { PositionItem } from '@/api/module_system/position'
import type { RoleItem } from '@/api/module_system/role'
import type { UserForm, UserInfo } from '@/api/module_system/user'
import { onLoad, onPullDownRefresh } from '@dcloudio/uni-app'
import { ref } from 'vue'
import { DeptAPI } from '@/api/module_system/dept'
import { PositionAPI } from '@/api/module_system/position'
import { RoleAPI } from '@/api/module_system/role'
import UserAPI from '@/api/module_system/user'

definePage({ name: 'work-users', style: { navigationBarTitleText: '用户管理' } })

const router = useRouter()
const toast = useToast()
const searchName = ref('')
const showForm = ref(false)
const formTitle = ref('')
const currentId = ref<number>()
const formData = reactive<UserForm>({
  username: '',
  name: '',
  password: '',
  dept_id: undefined,
  role_ids: [],
  position_ids: [],
  email: '',
  mobile: '',
  gender: 2,
  status: 1,
  description: '',
})

const GENDER_OPTIONS = [{ value: 0, label: '男' }, { value: 1, label: '女' }, { value: 2, label: '未知' }]
const STATUS_OPTIONS = [{ value: 0, label: '正常' }, { value: 1, label: '禁用' }]

const deptOptions = ref<{ value: number, label: string }[]>([])
const roleOptions = ref<{ value: number, label: string }[]>([])
const positionOptions = ref<{ value: number, label: string }[]>([])
const showPickerDept = ref(false)
const showPickerRole = ref(false)
const showPickerPosition = ref(false)

interface PickerConfirmEvent { value: Array<string | number>, selectedOptions: any[] }
function handleDeptConfirm(e: PickerConfirmEvent) {
  const item = deptOptions.value.find(o => o.value === e.value[0])
  if (item)
    formData.dept_id = item.value
  showPickerDept.value = false
}
function handleRoleConfirm(e: PickerConfirmEvent) {
  const item = roleOptions.value.find(o => o.value === e.value[0])
  if (item)
    formData.role_ids = [item.value]
  showPickerRole.value = false
}
function handlePositionConfirm(e: PickerConfirmEvent) {
  const item = positionOptions.value.find(o => o.value === e.value[0])
  if (item)
    formData.position_ids = [item.value]
  showPickerPosition.value = false
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
    const [depts, roles, positions] = await Promise.all([
      DeptAPI.getTree(),
      RoleAPI.getPage({ page_no: 1, page_size: 1000 }),
      PositionAPI.getPage({ page_no: 1, page_size: 1000 }),
    ])
    deptOptions.value = flattenDept(depts || [])
    roleOptions.value = (roles.list || []).map((r: RoleItem) => ({ value: r.id, label: r.name || '' }))
    positionOptions.value = (positions.list || []).map((p: PositionItem) => ({ value: p.id, label: p.name || '' }))
  }
  catch {
    deptOptions.value = []
    roleOptions.value = []
    positionOptions.value = []
  }
}

const { list, total, loading, pageParams, loadData, toFirst, loadPrev, loadNext } = useListPage<UserInfo>({
  fetcher: p => UserAPI.getUserPage({ ...p, name: searchName.value || undefined }),
  onError: e => toast.error(getErrorMessage(e, '加载失败')),
})

function onSearch() {
  toFirst()
  loadData()
}

const initForm: UserForm = { username: '', name: '', password: '', dept_id: undefined, role_ids: [], position_ids: [], email: '', mobile: '', gender: 2, status: 1, description: '' }

function openCreate() {
  formTitle.value = '新增用户'
  currentId.value = undefined
  Object.assign(formData, { ...initForm })
  if (deptOptions.value.length === 0)
    loadOptions()
  showForm.value = true
}
function openEdit(id: number) {
  router.push({ name: 'work-user-detail', query: { id } })
}
async function handleSubmit() {
  loading.value = true
  try {
    const payload = { ...formData }
    if (currentId.value) {
      await UserAPI.updateUser({ ...payload, id: currentId.value })
      toast.success('更新成功')
    }
    else {
      await UserAPI.addUser(payload)
      toast.success('创建成功')
    }
    showForm.value = false
    loadData()
  }
  catch (e) { toast.error(getErrorMessage(e, '操作失败')) }
  finally { loading.value = false }
}
function handleDelete(id: number) {
  uni.showModal({ title: '提示', content: '确认删除该用户？', success: async (res) => {
    if (res.confirm) {
      try {
        await UserAPI.deleteUser([id])
        toast.success('删除成功')
        loadData()
      }
      catch (e) { toast.error(getErrorMessage(e, '删除失败')) }
    }
  } })
}

// Avatar color generator
const avatarColors = ['#014DB2', '#F59E0B', '#10B981', '#8B5CF6', '#EF4444', '#EC4899', '#06B6D4']
function getAvatarColor(index: number) {
  return avatarColors[index % avatarColors.length]
}
function getAvatarInitial(name: string) {
  return (name || '?').charAt(0)
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
  <view class="list-page">
    <!-- Search bar -->
    <view class="list-search">
      <view class="list-search__box">
        <text class="list-search__icon">
          🔍
        </text>
        <wd-input
          v-model="searchName"
          placeholder="搜索姓名或用户名"
          clearable
          @confirm="onSearch"
        />
      </view>
    </view>

    <!-- Meta bar -->
    <view class="list-meta">
      <text class="list-meta__count">
        共 {{ total }} 条
      </text>
      <view class="list-meta__add" @click="openCreate">
        <text class="list-meta__add-icon">
          +
        </text>
        <text class="list-meta__add-text">
          新增
        </text>
      </view>
    </view>

    <!-- List -->
    <SkeletonPage v-if="loading && list.length === 0" :rows="5" search />
    <template v-else>
      <ListEmpty v-if="!loading && list.length === 0" text="暂无用户" />

      <view v-for="(item, index) in list" :key="item.id" class="list-item" hover-class="list-item--hover" @click="openEdit(item.id!)">
        <view class="list-item__avatar" :style="{ background: getAvatarColor(index) }">
          <text class="list-item__avatar-text">
            {{ getAvatarInitial(item.name || item.username || '') }}
          </text>
        </view>
        <view class="list-item__info">
          <text class="list-item__name">
            {{ item.name || item.username }}
          </text>
          <text class="list-item__sub">
            {{ item.username }} · {{ item.email || '-' }}
          </text>
        </view>
        <StatusBadge :status="item.status" />
        <view class="list-item__delete" @click.stop="handleDelete(item.id!)">
          <text class="list-item__delete-icon">
            🗑
          </text>
        </view>
      </view>

      <PaginationBar :current="pageParams.page_no" :page-size="pageParams.page_size" :total="total" @prev="loadPrev" @next="loadNext" />
    </template>

    <!-- Form popup -->
    <wd-popup v-model="showForm" position="bottom" round custom-style="max-height: 80vh; overflow-y: auto;" @close="showForm = false">
      <view class="p-xl">
        <wd-navbar :title="formTitle" left-arrow @click-left="showForm = false" />
        <wd-form :model="formData" class="mt-lg">
          <wd-form-item label="用户名">
            <wd-input v-model="formData.username" placeholder="请输入" />
          </wd-form-item>
          <wd-form-item label="姓名">
            <wd-input v-model="formData.name" placeholder="请输入" />
          </wd-form-item>
          <wd-form-item v-if="!currentId" label="密码">
            <wd-input v-model="formData.password" placeholder="请输入" />
          </wd-form-item>
          <wd-form-item label="部门">
            <view @click="showPickerDept = true">
              <wd-cell title="部门" :value="deptOptions.find(o => o.value === formData.dept_id)?.label || '请选择部门'" is-link :border="false" />
            </view>
            <wd-picker :visible="showPickerDept" :columns="[deptOptions]" @confirm="handleDeptConfirm" @cancel="showPickerDept = false" />
          </wd-form-item>
          <wd-form-item label="角色">
            <view @click="showPickerRole = true">
              <wd-cell title="角色" :value="roleOptions.find(o => o.value === formData.role_ids?.[0])?.label || '请选择角色'" is-link :border="false" />
            </view>
            <wd-picker :visible="showPickerRole" :columns="[roleOptions]" @confirm="handleRoleConfirm" @cancel="showPickerRole = false" />
          </wd-form-item>
          <wd-form-item label="岗位">
            <view @click="showPickerPosition = true">
              <wd-cell title="岗位" :value="positionOptions.find(o => o.value === formData.position_ids?.[0])?.label || '请选择岗位'" is-link :border="false" />
            </view>
            <wd-picker :visible="showPickerPosition" :columns="[positionOptions]" @confirm="handlePositionConfirm" @cancel="showPickerPosition = false" />
          </wd-form-item>
          <wd-form-item label="性别">
            <wd-radio-group v-model="formData.gender">
              <wd-radio v-for="opt in GENDER_OPTIONS" :key="opt.value" :value="opt.value">
                {{ opt.label }}
              </wd-radio>
            </wd-radio-group>
          </wd-form-item>
          <wd-form-item label="状态">
            <wd-radio-group v-model="formData.status">
              <wd-radio v-for="opt in STATUS_OPTIONS" :key="opt.value" :value="opt.value">
                {{ opt.label }}
              </wd-radio>
            </wd-radio-group>
          </wd-form-item>
          <wd-form-item label="邮箱">
            <wd-input v-model="formData.email" placeholder="请输入" />
          </wd-form-item>
          <wd-form-item label="手机号">
            <wd-input v-model="formData.mobile" placeholder="请输入" />
          </wd-form-item>
          <wd-form-item label="备注">
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
  </view>
</template>

<style lang="scss" scoped>
.list-page {
  padding: 0 32rpx;
  padding-bottom: 40rpx;
  background: var(--page-bg-color, #F9F9F9);
  min-height: 100vh;
}

/* ===== Search ===== */
.list-search {
  padding: 24rpx 0;

  &__box {
    display: flex;
    align-items: center;
    gap: 16rpx;
    background: var(--bg-color-2, #F5F6F8);
    border-radius: 16rpx;
    padding: 0 24rpx;
    height: 80rpx;
  }

  &__icon {
    font-size: 28rpx;
    opacity: 0.4;
  }
}

/* ===== Meta ===== */
.list-meta {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8rpx 0 24rpx;

  &__count {
    font-size: 26rpx;
    color: var(--text-color-3, #6B7280);
  }

  &__add {
    display: flex;
    align-items: center;
    gap: 8rpx;
    background: var(--primary-color, #4F8CFF);
    color: #FFFFFF;
    padding: 8rpx 24rpx;
    border-radius: 32rpx;

    &-icon { font-size: 36rpx; font-weight: 300; line-height: 1; }

    &-text { font-size: 24rpx; font-weight: 500; }
  }
}

/* ===== List item ===== */
.list-item {
  display: flex;
  align-items: center;
  gap: 20rpx;
  background: var(--card-bg-color, #FFFFFF);
  border-radius: 24rpx;
  padding: 24rpx;
  margin-bottom: 16rpx;
  box-shadow: var(--shadow-sm, 0 1rpx 2rpx rgba(1, 77, 178,0.06));
  transition: all 0.15s ease;

  &--hover {
    opacity: 0.9;
    box-shadow: var(--shadow-md, 0 4rpx 12rpx rgba(1, 77, 178,0.10));
  }

  &__avatar {
    width: 80rpx;
    height: 80rpx;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;

    &-text {
      font-size: 32rpx;
      font-weight: 600;
      color: #FFFFFF;
    }
  }

  &__info {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 4rpx;
    overflow: hidden;
  }

  &__name {
    font-size: 30rpx;
    font-weight: 500;
    color: var(--text-color, #0A1628);
  }

  &__sub {
    font-size: 24rpx;
    color: var(--text-color-3, #6B7280);
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  &__delete {
    width: 56rpx;
    height: 56rpx;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;

    &-icon { font-size: 28rpx; opacity: 0.4; }
  }
}
</style>
