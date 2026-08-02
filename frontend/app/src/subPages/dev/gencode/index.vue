<script setup lang="ts">
import type { DbTableItem, GenTableItem } from '@/api/module_generator/gencode'
import { onLoad, onPullDownRefresh } from '@dcloudio/uni-app'
import { ref } from 'vue'
import { GencodeAPI } from '@/api/module_generator/gencode'

definePage({ name: 'work-gencode', style: { navigationBarTitleText: '代码生成器' } })

const toast = useToast()
const activeTab = ref('biztables')
const showDbPicker = ref(false)
const showPreview = ref(false)
const previewId = ref<number>(0)
const previewContent = ref('')

const {
  list: bizTables,
  total: bizTotal,
  loading: bizLoading,
  pageParams: bizPageParams,
  loadData: loadBizTables,
  loadPrev: bizLoadPrev,
  loadNext: bizLoadNext,
} = useListPage<GenTableItem>({
  fetcher: p => GencodeAPI.getPage({ page: p.page_no, page_size: p.page_size }),
  onError: e => toast.error(getErrorMessage(e, '加载失败')),
})

const {
  list: dbTables,
  total: dbTotal,
  loading: dbLoading,
  pageParams: dbPageParams,
  loadData: loadDbTables,
  loadPrev: dbLoadPrev,
  loadNext: dbLoadNext,
} = useListPage<DbTableItem>({
  fetcher: p => GencodeAPI.getDbTables({ page: p.page_no, page_size: p.page_size }),
  onError: e => toast.error(getErrorMessage(e, '加载数据库表失败')),
})

async function importTable(tableName: string) {
  bizLoading.value = true
  try {
    await GencodeAPI.importTable(tableName)
    toast.success(`${tableName} 导入成功`)
    showDbPicker.value = false
    loadBizTables()
  }
  catch (e) { toast.error(getErrorMessage(e, '导入失败')) }
  finally { bizLoading.value = false }
}

async function previewCode(id: number) {
  bizLoading.value = true
  try {
    const res = await GencodeAPI.preview(id)
    previewContent.value = typeof res === 'string' ? res : JSON.stringify(res, null, 2)
    previewId.value = id
    showPreview.value = true
  }
  catch (e) { toast.error(getErrorMessage(e, '预览失败')) }
  finally { bizLoading.value = false }
}

async function batchGenerate(ids: number[]) {
  bizLoading.value = true
  try {
    await GencodeAPI.batchGenerate(ids)
    toast.success('代码生成成功，请下载 ZIP 文件')
  }
  catch (e) { toast.error(getErrorMessage(e, '生成失败')) }
  finally { bizLoading.value = false }
}

async function syncDb(tableName: string) {
  uni.showModal({
    title: '提示',
    content: `确认同步表 ${tableName} 到数据库？`,
    success: async (res) => {
      if (res.confirm) {
        bizLoading.value = true
        try {
          await GencodeAPI.syncDb(tableName)
          toast.success('同步成功')
        }
        catch (e) { toast.error(getErrorMessage(e, '同步失败')) }
        finally { bizLoading.value = false }
      }
    },
  })
}

onPullDownRefresh(() => {
  if (activeTab.value === 'biztables')
    loadBizTables()
  else loadDbTables()
})

onLoad(() => loadBizTables())
</script>

<template>
  <view class="page-wraper">
    <!-- Tabs -->
    <view class="p-md flex items-center gap-sm" style="background:var(--card-bg-color);border-bottom:1px solid var(--border-color);">
      <wd-button :type="activeTab === 'biztables' ? 'primary' : 'info'" size="small" @click="activeTab = 'biztables'; loadBizTables()">
        业务表
      </wd-button>
      <wd-button :type="activeTab === 'dbtables' ? 'primary' : 'info'" size="small" @click="activeTab = 'dbtables'; loadDbTables()">
        数据库表
      </wd-button>
    </view>

    <!-- Business Tables -->
    <template v-if="activeTab === 'biztables'">
      <view class="action-bar">
        <text class="text-md text-muted font-bold">
          共 {{ bizTotal }} 张表
        </text>
        <wd-button size="small" type="primary" @click="showDbPicker = true">
          导入表
        </wd-button>
      </view>
      <SkeletonPage v-if="bizLoading" :rows="5" />
      <template v-else>
        <view class="px-sm">
          <view class="admin-card">
            <ListEmpty v-if="bizTables.length === 0" text="暂无业务表，请从数据库导入" />
            <wd-cell-group v-else>
              <wd-cell v-for="item in bizTables" :key="item.id || item.table_name">
                <template #title>
                  <view class="flex items-center gap-sm">
                    <wd-icon name="list" size="18px" color="var(--primary-color)" />
                    <view>
                      <text class="text-md font-medium">
                        {{ item.table_name || '-' }}
                      </text>
                      <text class="text-muted block text-xs">
                        {{ item.table_comment || '' }}
                      </text>
                    </view>
                  </view>
                </template>
                <template #suffix>
                  <wd-button size="small" type="primary" variant="plain" @click="batchGenerate([item.id])">
                    生成
                  </wd-button>
                  <wd-button size="small" variant="plain" @click="previewCode(item.id)">
                    预览
                  </wd-button>
                </template>
              </wd-cell>
            </wd-cell-group>
          </view>
        </view>
        <PaginationBar :current="bizPageParams.page_no" :page-size="bizPageParams.page_size" :total="bizTotal" @prev="bizLoadPrev" @next="bizLoadNext" />
      </template>
    </template>

    <!-- Database Tables -->
    <template v-else>
      <view class="action-bar">
        <text class="text-md text-muted font-bold">
          数据库表列表
        </text>
        <wd-button size="small" type="primary" :loading="dbLoading" @click="loadDbTables">
          刷新
        </wd-button>
      </view>
      <SkeletonPage v-if="dbLoading" :rows="5" />
      <template v-else>
        <view class="px-sm">
          <view class="admin-card">
            <ListEmpty v-if="dbTables.length === 0" text="暂无数据库表" />
            <wd-cell-group v-else>
              <wd-cell v-for="item in dbTables" :key="item.table_name">
                <template #title>
                  <view class="flex items-center gap-sm">
                    <wd-icon name="list" size="18px" color="var(--success-color)" />
                    <view>
                      <text class="text-md font-medium font-mono">
                        {{ item.table_name || item.name || '-' }}
                      </text>
                      <text class="text-muted block text-xs">
                        {{ item.table_comment || item.comment || '' }}
                      </text>
                    </view>
                  </view>
                </template>
                <template #suffix>
                  <wd-button size="small" type="success" variant="plain" @click="importTable(item.table_name || '')">
                    导入
                  </wd-button>
                </template>
              </wd-cell>
            </wd-cell-group>
          </view>
        </view>
        <PaginationBar :current="dbPageParams.page_no" :page-size="dbPageParams.page_size" :total="dbTotal" @prev="dbLoadPrev" @next="dbLoadNext" />
      </template>
    </template>

    <!-- Preview Popup -->
    <wd-popup v-model="showPreview" position="bottom" custom-style="max-height:80vh;overflow-y:auto;" round @close="showPreview = false">
      <view class="p-xl">
        <wd-navbar title="代码预览" left-arrow @click-left="showPreview = false" />
        <view class="mb-md mt-lg flex items-center justify-between">
          <text class="text-md font-bold">
            预览 ID: {{ previewId }}
          </text>
          <view class="flex gap-sm">
            <wd-button size="small" type="primary" @click="batchGenerate([previewId])">
              生成下载
            </wd-button>
            <wd-button size="small" type="success" @click="syncDb(bizTables.find(t => t.id === previewId)?.table_name || '')">
              同步数据库
            </wd-button>
          </view>
        </view>
        <view class="code-block" style="background:var(--bg-color-3);border-radius:12rpx;padding:24rpx;font-family:monospace;font-size:22rpx;white-space:pre-wrap;overflow-x:auto;max-height:50vh;">
          <text>{{ previewContent || '暂无预览内容' }}</text>
        </view>
      </view>
    </wd-popup>

    <!-- Import DB Table Picker -->
    <wd-popup v-model="showDbPicker" position="bottom" custom-style="max-height:70vh;overflow-y:auto;" round @close="showDbPicker = false">
      <view class="p-xl">
        <wd-navbar title="选择数据库表" left-arrow @click-left="showDbPicker = false" />
        <view class="mt-lg">
          <wd-cell-group border>
            <wd-cell v-for="item in dbTables" :key="item.table_name" :title="item.table_name || item.name" :label="item.table_comment || item.comment || ''" center>
              <template #suffix>
                <wd-button size="small" type="success" variant="plain" @click="importTable(item.table_name || '')">
                  导入
                </wd-button>
              </template>
            </wd-cell>
          </wd-cell-group>
          <view v-if="dbTables.length === 0" class="empty-state mt-xl">
            <text class="empty-state__text">
              点击"数据库表"Tab 刷新表列表
            </text>
          </view>
        </view>
      </view>
    </wd-popup>
  </view>
</template>
