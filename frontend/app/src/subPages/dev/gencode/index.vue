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
    <view class="flex items-center gap-sm p-md" style="background:var(--card-bg-color);border-bottom:1px solid var(--border-color);">
      <u-button :type="activeTab === 'biztables' ? 'primary' : 'default'" size="mini" text="业务表" @click="activeTab = 'biztables'; loadBizTables()" />
      <u-button :type="activeTab === 'dbtables' ? 'primary' : 'default'" size="mini" text="数据库表" @click="activeTab = 'dbtables'; loadDbTables()" />
    </view>

    <!-- Business Tables -->
    <template v-if="activeTab === 'biztables'">
      <view class="action-bar">
        <text class="text-md font-bold text-muted">
          共 {{ bizTotal }} 张表
        </text>
        <u-button size="mini" type="primary" text="导入表" @click="showDbPicker = true" />
      </view>
      <SkeletonPage v-if="bizLoading" :rows="5" />
      <template v-else>
        <view class="px-sm">
          <view class="admin-card">
            <ListEmpty v-if="bizTables.length === 0" text="暂无业务表，请从数据库导入" />
            <u-cell-group v-else>
              <u-cell v-for="item in bizTables" :key="item.id || item.table_name">
                <template #title>
                  <view class="flex items-center gap-sm">
                    <u-icon name="list" size="18" color="var(--primary-color)" />
                    <view>
                      <text class="font-medium text-md">
                        {{ item.table_name || '-' }}
                      </text>
                      <text class="text-xs text-muted block">
                        {{ item.table_comment || '' }}
                      </text>
                    </view>
                  </view>
                </template>
                <template #right>
                  <u-button size="mini" type="primary" :plain="true" text="生成" @click="batchGenerate([item.id])" />
                  <u-button size="mini" :plain="true" text="预览" @click="previewCode(item.id)" />
                </template>
              </u-cell>
            </u-cell-group>
          </view>
        </view>
        <PaginationBar :current="bizPageParams.page_no" :page-size="bizPageParams.page_size" :total="bizTotal" @prev="bizLoadPrev" @next="bizLoadNext" />
      </template>
    </template>

    <!-- Database Tables -->
    <template v-else>
      <view class="action-bar">
        <text class="text-md font-bold text-muted">
          数据库表列表
        </text>
        <u-button size="mini" type="primary" :loading="dbLoading" text="刷新" @click="loadDbTables" />
      </view>
      <SkeletonPage v-if="dbLoading" :rows="5" />
      <template v-else>
        <view class="px-sm">
          <view class="admin-card">
            <ListEmpty v-if="dbTables.length === 0" text="暂无数据库表" />
            <u-cell-group v-else>
              <u-cell v-for="item in dbTables" :key="item.table_name">
                <template #title>
                  <view class="flex items-center gap-sm">
                    <u-icon name="list" size="18" color="var(--success-color)" />
                    <view>
                      <text class="font-medium text-md font-mono">
                        {{ item.table_name || item.name || '-' }}
                      </text>
                      <text class="text-xs text-muted block">
                        {{ item.table_comment || item.comment || '' }}
                      </text>
                    </view>
                  </view>
                </template>
                <template #right>
                  <u-button size="mini" type="success" :plain="true" text="导入" @click="importTable(item.table_name || '')" />
                </template>
              </u-cell>
            </u-cell-group>
          </view>
        </view>
        <PaginationBar :current="dbPageParams.page_no" :page-size="dbPageParams.page_size" :total="dbTotal" @prev="dbLoadPrev" @next="dbLoadNext" />
      </template>
    </template>

    <!-- Preview Popup -->
    <u-popup :show="showPreview" mode="bottom" custom-style="max-height:80vh;overflow-y:auto;" :round="10" @close="showPreview = false">
      <view class="p-xl">
        <u-navbar title="代码预览" left-icon="arrow-left" @left-click="showPreview = false" />
        <view class="flex items-center justify-between mt-lg mb-md">
          <text class="font-bold text-md">
            预览 ID: {{ previewId }}
          </text>
          <view class="flex gap-sm">
            <u-button size="mini" type="primary" text="生成下载" @click="batchGenerate([previewId])" />
            <u-button size="mini" type="success" text="同步数据库" @click="syncDb(bizTables.find(t => t.id === previewId)?.table_name || '')" />
          </view>
        </view>
        <view class="code-block" style="background:var(--bg-color-3);border-radius:12rpx;padding:24rpx;font-family:monospace;font-size:22rpx;white-space:pre-wrap;overflow-x:auto;max-height:50vh;">
          <text>{{ previewContent || '暂无预览内容' }}</text>
        </view>
      </view>
    </u-popup>

    <!-- Import DB Table Picker -->
    <u-popup :show="showDbPicker" mode="bottom" custom-style="max-height:70vh;overflow-y:auto;" :round="10" @close="showDbPicker = false">
      <view class="p-xl">
        <u-navbar title="选择数据库表" left-icon="arrow-left" @left-click="showDbPicker = false" />
        <view class="mt-lg">
          <u-cell-group :border="true">
            <u-cell v-for="item in dbTables" :key="item.table_name" :title="item.table_name || item.name" :label="item.table_comment || item.comment || ''" center>
              <template #right>
                <u-button size="mini" type="success" :plain="true" text="导入" @click="importTable(item.table_name || '')" />
              </template>
            </u-cell>
          </u-cell-group>
          <view v-if="dbTables.length === 0" class="empty-state mt-xl">
            <text class="empty-state__text">
              点击"数据库表"Tab 刷新表列表
            </text>
          </view>
        </view>
      </view>
    </u-popup>
  </view>
</template>
