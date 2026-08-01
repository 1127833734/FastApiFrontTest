<script setup lang="ts">
import type { DictDataForm, DictDataItem, DictTypeForm, DictTypeItem } from '@/api/module_system/dict'
import { onLoad, onPullDownRefresh } from '@dcloudio/uni-app'
import { ref } from 'vue'
import { DictAPI } from '@/api/module_system/dict'

definePage({ name: 'work-dicts', style: { navigationBarTitleText: '字典管理' } })

const toast = useToast()
const searchName = ref('')
const showForm = ref(false)
const formTitle = ref('')
const currentId = ref<number>()
const formData = reactive<DictTypeForm>({ dict_name: '', dict_type: '', status: 0, description: '' })

const STATUS_OPTIONS = [{ value: 0, label: '正常' }, { value: 1, label: '禁用' }]

/* ===== Type list ===== */
const { list, total, loading, pageParams, loadData, toFirst, loadPrev, loadNext } = useListPage<DictTypeItem>({
  fetcher: p => DictAPI.getTypePage({ ...p, dict_name: searchName.value || undefined }),
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
  Object.assign(formData, { dict_name: '', dict_type: '', status: 0, description: '' })
}
function openCreate() {
  formTitle.value = '新增字典'
  currentId.value = undefined
  resetForm()
  showForm.value = true
}
async function handleSubmit() {
  loading.value = true
  try {
    if (currentId.value) {
      await DictAPI.updateType(currentId.value, formData)
      toast.success('更新成功')
    }
    else {
      await DictAPI.createType(formData)
      toast.success('创建成功')
    }
    showForm.value = false
    loadData()
  }
  catch (e) { toast.error(getErrorMessage(e, '操作失败')) }
  finally { loading.value = false }
}
function handleDelete(id: number) {
  uni.showModal({ title: '提示', content: '确认删除？', success: async (res) => {
    if (res.confirm) {
      try {
        await DictAPI.removeType([id])
        toast.success('删除成功')
        loadData()
      }
      catch (e) { toast.error(getErrorMessage(e, '删除失败')) }
    }
  } })
}

/* ===== Data sub-list ===== */
const showDataSection = ref(false)
const showDataForm = ref(false)
const dataFormTitle = ref('')
const dataCurrentId = ref<number>()
const currentTypeId = ref(0)
const currentTypeCode = ref('')
const dataFormData = reactive<DictDataForm>({ dict_label: '', dict_value: '', dict_type: '', dict_type_id: 0, dict_sort: 1, status: 0, description: '', is_default: false })

const {
  list: dataList,
  total: dataTotal,
  loading: dataLoading,
  pageParams: dataPageParams,
  loadData: loadDataList,
  toFirst: dataToFirst,
  loadPrev: dataLoadPrev,
  loadNext: dataLoadNext,
} = useListPage<DictDataItem>({
  fetcher: p => DictAPI.getDataPage({ ...p, dict_type_id: currentTypeId.value }),
  onError: e => toast.error(getErrorMessage(e, '加载失败')),
})

function loadDictData(item: DictTypeItem) {
  currentTypeCode.value = item.dict_type
  currentTypeId.value = item.id
  dataFormData.dict_type = item.dict_type
  dataFormData.dict_type_id = item.id
  dataToFirst()
  loadDataList()
  showDataSection.value = true
}
function resetDataForm() {
  Object.assign(dataFormData, { dict_label: '', dict_value: '', dict_sort: 1, status: 0, description: '', is_default: false, dict_type: currentTypeCode.value, dict_type_id: currentTypeId.value })
}
function openCreateData() {
  dataFormTitle.value = '新增字典项'
  dataCurrentId.value = undefined
  resetDataForm()
  showDataForm.value = true
}
async function openEditData(id: number) {
  dataFormTitle.value = '编辑字典项'
  dataCurrentId.value = id
  try {
    const detail = await DictAPI.getDataDetail(id)
    Object.assign(dataFormData, {
      dict_label: detail.dict_label || '',
      dict_value: detail.dict_value || '',
      dict_sort: detail.dict_sort ?? 1,
      status: detail.status ?? 0,
      description: detail.description || '',
      is_default: detail.is_default ?? false,
      dict_type: detail.dict_type || currentTypeCode.value,
      dict_type_id: detail.dict_type_id || currentTypeId.value,
    })
    showDataForm.value = true
  }
  catch (e) { toast.error(getErrorMessage(e, '获取详情失败')) }
}
async function handleSubmitData() {
  dataLoading.value = true
  try {
    if (dataCurrentId.value) {
      await DictAPI.updateData(dataCurrentId.value, dataFormData)
      toast.success('更新成功')
    }
    else {
      await DictAPI.createData(dataFormData)
      toast.success('创建成功')
    }
    showDataForm.value = false
    loadDataList()
  }
  catch (e) { toast.error(getErrorMessage(e, '操作失败')) }
  finally { dataLoading.value = false }
}
function handleDeleteData(id: number) {
  uni.showModal({ title: '提示', content: '确认删除？', success: async (res) => {
    if (res.confirm) {
      try {
        await DictAPI.removeData([id])
        toast.success('删除成功')
        loadDataList()
      }
      catch (e) { toast.error(getErrorMessage(e, '删除失败')) }
    }
  } })
}
function closeDataSection() {
  showDataSection.value = false
}

onReachBottom(() => {
  if (!showDataSection.value && !loading.value)
    loadNext()
})
onPullDownRefresh(() => {
  loadData()
})
onLoad(() => loadData())
</script>

<template>
  <view class="page-wraper">
    <view v-if="!showDataSection">
      <view class="search-bar">
        <view class="flex items-center gap-sm">
          <wd-input v-model="searchName" placeholder="搜索字典名称" clearable class="flex-1" />
          <wd-button size="small" type="primary" plain @click="onSearch">搜索</wd-button>
          <wd-button size="small" plain @click="onReset">重置</wd-button>
        </view>
      </view>
      <view class="action-bar">
        <text class="text-md font-bold text-muted">
          共 {{ total }} 条
        </text>
        <wd-button size="small" type="primary" @click="openCreate">+ 新增</wd-button>
      </view>
      <view class="px-sm">
        <view class="admin-card">
          <SkeletonPage v-if="loading" />
          <ListEmpty v-else-if="list.length === 0" text="暂无字典" />
          <wd-cell-group v-else>
            <wd-cell v-for="item in list" :key="item.id" is-link @click="loadDictData(item)">
              <template #title>
                <view>
                  <text class="font-medium text-md">
                    {{ item.dict_name }}
                  </text><text class="text-xs text-muted block mt-xs">
                    类型: {{ item.dict_type }}
                  </text>
                </view>
              </template>
              <view class="flex items-center gap-xs">
                <StatusBadge :status="item.status" />
                <wd-icon name="delete" size="18px" color="var(--danger-color)" @click.stop="handleDelete(item.id!)" />
              </view>
            </wd-cell>
          </wd-cell-group>
        </view>
      </view>
      <PaginationBar :current="pageParams.page_no" :page-size="pageParams.page_size" :total="total" @prev="loadPrev" @next="loadNext" />
    </view>

    <view v-else>
      <view class="search-bar">
        <view class="flex items-center gap-sm">
          <u-icon name="arrow-left" size="20" @click="closeDataSection" /><text class="font-bold text-md">
            {{ currentTypeCode }} - 字典项
          </text>
        </view>
      </view>
      <view class="action-bar">
        <text class="text-md font-bold text-muted">
          共 {{ dataTotal }} 项
        </text><wd-button size="small" type="primary" @click="openCreateData">+ 新增</wd-button>
      </view>
      <view class="px-sm">
        <view class="admin-card">
          <ListEmpty v-if="!dataLoading && dataList.length === 0" text="暂无字典项" /><wd-cell-group v-else>
            <wd-cell v-for="item in dataList" :key="item.id" is-link @click="openEditData(item.id!)">
              <template #title>
                <view>
                  <text class="font-medium text-md">
                    {{ item.dict_label }}
                  </text><text class="text-xs text-muted block mt-xs">
                    值: {{ item.dict_value }}
                  </text>
                </view>
              </template>
              <view class="flex items-center gap-xs">
                <StatusBadge :status="item.status" />
                <wd-icon name="delete" size="18px" color="var(--danger-color)" @click.stop="handleDeleteData(item.id!)" />
              </view>
            </wd-cell>
          </wd-cell-group>
        </view>
      </view>
      <PaginationBar :current="dataPageParams.page_no" :page-size="dataPageParams.page_size" :total="dataTotal" @prev="dataLoadPrev" @next="dataLoadNext" />

      <!-- Data form -->
      <wd-popup v-model="showDataForm" position="bottom" round custom-style="max-height: 60vh; overflow-y: auto;" @close="showDataForm = false">
        <view class="p-xl">
          <wd-navbar :title="dataFormTitle" left-arrow @click-left="showDataForm = false" /><wd-form :model="dataFormData" class="mt-lg">
            <wd-form-item label="标签" prop="dict_label" border>
              <wd-input v-model="dataFormData.dict_label" placeholder="请输入" />
            </wd-form-item><wd-form-item label="值" prop="dict_value" border>
              <wd-input v-model="dataFormData.dict_value" placeholder="请输入" />
            </wd-form-item><wd-form-item label="排序" border>
              <wd-input v-model="dataFormData.dict_sort" type="number" placeholder="请输入" />
            </wd-form-item><wd-form-item label="状态" border>
              <wd-radio-group v-model="dataFormData.status">
                <wd-radio v-for="opt in STATUS_OPTIONS" :key="opt.value" :value="opt.value">
                  {{ opt.label }}
                </wd-radio>
              </wd-radio-group>
            </wd-form-item><wd-form-item label="备注" border>
              <wd-textarea v-model="dataFormData.description" placeholder="请输入" />
            </wd-form-item>
          </wd-form><view class="flex gap-md mt-xl">
            <wd-button block plain @click="showDataForm = false">取消</wd-button><wd-button block type="primary" :loading="dataLoading" @click="handleSubmitData">保存</wd-button>
          </view>
        </view>
      </wd-popup>
    </view>

    <!-- Type form (shared, outside v-if/v-else) -->
    <u-popup :show="showForm" mode="bottom" :round="10" custom-style="max-height: 60vh; overflow-y: auto;" @close="showForm = false">
      <view class="p-xl">
        <u-navbar :title="formTitle" left-icon="arrow-left" @left-click="showForm = false" /><u-form :model="formData" class="mt-lg">
          <u-form-item label="字典名称" prop="dict_name" :border-bottom="true">
            <u-input v-model="formData.dict_name" border="none" placeholder="请输入" />
          </u-form-item><u-form-item label="字典类型" prop="dict_type" :border-bottom="true">
            <u-input v-model="formData.dict_type" border="none" placeholder="请输入" />
          </u-form-item><u-form-item label="状态" :border-bottom="true">
            <u-radio-group v-model="formData.status">
              <u-radio v-for="opt in STATUS_OPTIONS" :key="opt.value" :name="opt.value" :label="opt.value">
                {{ opt.label }}
              </u-radio>
            </u-radio-group>
          </u-form-item><u-form-item label="备注" :border-bottom="true">
            <u-textarea v-model="formData.description" border="none" placeholder="请输入" />
          </u-form-item>
        </u-form><view class="flex gap-md mt-xl">
          <u-button :block="true" :plain="true" text="取消" @click="showForm = false" /><u-button :block="true" type="primary" :loading="loading" text="保存" @click="handleSubmit" />
        </view>
      </view>
    </u-popup>
  </view>
</template>
