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

const { list, total, loading, pageParams, loadData, toFirst, loadNext } = useListPage<UserInfo>({
  fetcher: p => UserAPI.getUserPage({ ...p, name: searchName.value || undefined }),
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
  searchName.value = ''
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
  router.push({ name: 'work-user-detail', query: { id: String(id) } })
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
  catch { toast.error('操作失败') }
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
      catch { toast.error('删除失败') }
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
  <view class="page-wraper">
    <!-- Search bar -->
    <view class="search-bar">
      <view class="flex items-center gap-sm">
        <wd-input v-model="searchName" placeholder="搜索姓名或用户名" clearable class="flex-1" />
        <wd-button size="small" type="primary" variant="plain" @click="onSearch">
          搜索
        </wd-button>
        <wd-button size="small" variant="plain" @click="onReset">
          重置
        </wd-button>
      </view>
    </view>

    <!-- Meta bar -->
    <view class="action-bar">
      <text class="text-md text-muted font-bold">
        共 {{ total }} 条
      </text>
      <wd-button size="small" type="primary" @click="openCreate">
        + 新增
      </wd-button>
    </view>

    <!-- List -->
    <SkeletonPage v-if="loading && list.length === 0" :rows="5" search />
    <template v-else>
      <view class="px-sm">
        <view class="admin-card">
          <wd-empty v-if="!loading && list.length === 0" tip="暂无用户" />
          <wd-cell-group v-else>
            <wd-cell v-for="(item, index) in list" :key="item.id" center @click="openEdit(item.id!)">
              <template #title>
                <view class="flex items-center gap-2">
                  <wd-avatar
                    size="40px"
                    round
                    :text="getAvatarInitial(item.name || item.username || '')"
                    :bg-color="getAvatarColor(index)"
                    color="#FFFFFF"
                  />
                  <view class="min-w-0">
                    <view class="truncate text-3.5 font-medium wot-text-text-main">
                      {{ item.name || item.username }}
                    </view>
                    <view class="mt-1 truncate text-2.5 wot-text-text-auxiliary">
                      {{ item.username }} · {{ item.email || '-' }}
                    </view>
                  </view>
                </view>
              </template>
              <template #default>
                <view class="flex items-center gap-2">
                  <StatusBadge :status="item.status" />
                  <wd-icon name="delete" size="18px" color="var(--danger-color)" @click.stop="handleDelete(item.id!)" />
                </view>
              </template>
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
    </template>

    <!-- Form popup -->
    <wd-popup v-model="showForm" position="bottom" round custom-style="max-height: 80vh; overflow-y: auto;" @close="showForm = false">
      <view class="p-xl">
        <wd-navbar :title="formTitle" left-arrow @click-left="showForm = false" />
        <wd-form :model="formData" class="mt-lg">
          <wd-form-item label="用户名" border>
            <wd-input v-model="formData.username" placeholder="请输入" />
          </wd-form-item>
          <wd-form-item label="姓名" border>
            <wd-input v-model="formData.name" placeholder="请输入" />
          </wd-form-item>
          <wd-form-item v-if="!currentId" label="密码" border>
            <wd-input v-model="formData.password" placeholder="请输入" />
          </wd-form-item>
          <wd-form-item label="部门" border>
            <view class="flex-1" @click="showPickerDept = true">
              <wd-cell :value="deptOptions.find(o => o.value === formData.dept_id)?.label || '请选择部门'" is-link :border="false" />
            </view>
            <wd-picker :visible="showPickerDept" :columns="[deptOptions]" @confirm="handleDeptConfirm" @cancel="showPickerDept = false" />
          </wd-form-item>
          <wd-form-item label="角色" border>
            <view class="flex-1" @click="showPickerRole = true">
              <wd-cell :value="roleOptions.find(o => o.value === formData.role_ids?.[0])?.label || '请选择角色'" is-link :border="false" />
            </view>
            <wd-picker :visible="showPickerRole" :columns="[roleOptions]" @confirm="handleRoleConfirm" @cancel="showPickerRole = false" />
          </wd-form-item>
          <wd-form-item label="岗位" border>
            <view class="flex-1" @click="showPickerPosition = true">
              <wd-cell :value="positionOptions.find(o => o.value === formData.position_ids?.[0])?.label || '请选择岗位'" is-link :border="false" />
            </view>
            <wd-picker :visible="showPickerPosition" :columns="[positionOptions]" @confirm="handlePositionConfirm" @cancel="showPickerPosition = false" />
          </wd-form-item>
          <wd-form-item label="性别" border>
            <wd-radio-group v-model="formData.gender">
              <wd-radio v-for="opt in GENDER_OPTIONS" :key="opt.value" :value="opt.value">
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
          <wd-form-item label="邮箱" border>
            <wd-input v-model="formData.email" placeholder="请输入" />
          </wd-form-item>
          <wd-form-item label="手机号" border>
            <wd-input v-model="formData.mobile" placeholder="请输入" />
          </wd-form-item>
          <wd-form-item label="备注" border>
            <wd-textarea v-model="formData.description" placeholder="请输入" />
          </wd-form-item>
        </wd-form>
        <view class="gap-md mt-xl flex">
          <wd-button variant="plain" block @click="showForm = false">
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
