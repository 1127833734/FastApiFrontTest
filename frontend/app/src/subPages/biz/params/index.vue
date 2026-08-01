<script setup lang="ts">
import type { ParamsForm, ParamsItem } from '@/api/module_system/params'
import { onLoad, onPullDownRefresh } from '@dcloudio/uni-app'
import { computed, reactive, ref } from 'vue'
import { ParamsAPI } from '@/api/module_system/params'

definePage({ name: 'work-params', style: { navigationBarTitleText: '参数管理' } })

const toast = useToast()
const loading = ref(false)
const list = ref<ParamsItem[]>([])
const searchName = ref('')
const showForm = ref(false)
const currentId = ref<number>()
const formData = reactive<ParamsForm>({ config_name: '', config_key: '', config_value: '', config_type: false, status: 0, description: '' })

const STATUS_OPTIONS = [{ value: 0, label: '正常' }, { value: 1, label: '禁用' }]

const filteredList = computed(() => {
  if (!searchName.value)
    return list.value
  const keyword = searchName.value.toLowerCase()
  return list.value.filter(item =>
    (item.config_name || '').toLowerCase().includes(keyword)
    || (item.config_key || '').toLowerCase().includes(keyword),
  )
})

function displayName(item: ParamsItem) {
  return item.config_name || '未知'
}
function displayKey(item: ParamsItem) {
  return item.config_key || ''
}
function displayValue(item: ParamsItem) {
  return item.config_value || ''
}

async function loadData() {
  loading.value = true
  try {
    const res = await ParamsAPI.getInfo()
    list.value = res || []
  }
  catch (e) { toast.error(getErrorMessage(e, '加载失败')) }
  finally {
    loading.value = false
    uni.stopPullDownRefresh()
  }
}
function onSearch() { /* 前端实时过滤 */ }
function onReset() {
  searchName.value = ''
}
function openEdit(item: ParamsItem) {
  currentId.value = item.id
  Object.assign(formData, {
    config_name: displayName(item),
    config_key: displayKey(item),
    config_value: displayValue(item),
    config_type: item.config_type ?? false,
    status: item.status ?? 0,
    description: item.description || '',
  })
  showForm.value = true
}
async function handleSubmit() {
  loading.value = true
  try {
    await ParamsAPI.update(currentId.value!, formData)
    toast.success('更新成功')
    showForm.value = false
    loadData()
  }
  catch (e) { toast.error(getErrorMessage(e, '操作失败')) }
  finally { loading.value = false }
}

onPullDownRefresh(() => {
  loadData()
})
onLoad(() => loadData())
</script>

<template>
  <view class="page-wraper">
    <view class="search-bar">
      <view class="flex items-center gap-sm">
        <wd-input v-model="searchName" placeholder="搜索参数名称/键名" clearable class="flex-1" />
        <wd-button size="small" type="primary" plain @click="onSearch">搜索</wd-button>
        <wd-button size="small" plain @click="onReset">重置</wd-button>
      </view>
    </view>
    <view class="action-bar">
      <text class="text-md font-bold text-muted">
        共 {{ filteredList.length }} 条
      </text>
    </view>
    <SkeletonPage v-if="loading" :rows="5" search />
    <template v-else>
      <view class="px-sm">
        <view class="admin-card">
          <ListEmpty v-if="filteredList.length === 0" text="暂无数据" />
          <wd-cell-group v-else>
            <wd-cell v-for="item in filteredList" :key="item.id" is-link @click="openEdit(item)">
              <template #title>
                <view>
                  <text class="font-medium text-md">
                    {{ displayName(item) }}
                  </text><text class="text-xs text-muted block mt-xs">
                    {{ `键: ${displayKey(item)}` }}
                  </text>
                </view>
              </template>
              <template #label>
                <text class="text-xs text-muted">
                  {{ displayValue(item) || '-' }}
                </text>
              </template>
              <StatusBadge :status="item.status" />
            </wd-cell>
          </wd-cell-group>
        </view>
      </view>
      <wd-popup v-model="showForm" position="bottom" round custom-style="max-height: 80vh; overflow-y: auto;" @close="showForm = false">
        <view class="p-xl">
          <wd-navbar title="编辑参数" left-arrow @click-left="showForm = false" />
          <wd-form :model="formData" class="mt-lg">
            <wd-form-item label="参数名称" prop="config_name" border>
              <wd-input v-model="formData.config_name" placeholder="请输入" />
            </wd-form-item>
            <wd-form-item label="参数键名" prop="config_key" border>
              <wd-input v-model="formData.config_key" placeholder="请输入" />
            </wd-form-item>
            <wd-form-item label="参数键值" border>
              <wd-textarea v-model="formData.config_value" placeholder="请输入" />
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
          <view class="flex gap-md mt-xl">
            <wd-button block plain @click="showForm = false">取消</wd-button>
            <wd-button block type="primary" :loading="loading" @click="handleSubmit">保存</wd-button>
          </view>
        </view>
      </wd-popup>
    </template>
  </view>
</template>
