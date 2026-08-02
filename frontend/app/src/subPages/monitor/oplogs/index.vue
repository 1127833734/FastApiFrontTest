<script setup lang="ts">
import type { OplogItem } from '@/api/module_system/log'
import { onLoad, onPullDownRefresh } from '@dcloudio/uni-app'
import { ref } from 'vue'
import { OperationLogAPI } from '@/api/module_system/log'

definePage({ name: 'work-oplogs', style: { navigationBarTitleText: '操作日志' } })

const toast = useToast()
const searchPath = ref('')
const showDetail = ref(false)
const detailItem = ref<OplogItem>()

const { list, total, loading, pageParams, loadData, toFirst, loadPrev, loadNext } = useListPage<OplogItem>({
  fetcher: p => OperationLogAPI.getPage({ ...p, request_path: searchPath.value || undefined }),
  onError: () => toast.error('加载失败'),
})

function onSearch() {
  toFirst()
  loadData()
}
function onReset() {
  searchPath.value = ''
  toFirst()
  loadData()
}
function viewDetail(item: OplogItem) {
  detailItem.value = item
  showDetail.value = true
}
function handleDelete(id: number) {
  uni.showModal({
    title: '提示',
    content: '确认删除？',
    success: async (res) => {
      if (res.confirm) {
        try {
          await OperationLogAPI.remove([id])
          toast.success('删除成功')
          loadData()
        }
        catch { toast.error('删除失败') }
      }
    },
  })
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
    <view class="search-bar">
      <view class="flex items-center gap-sm">
        <wd-input v-model="searchPath" placeholder="搜索请求路径" clearable class="flex-1" />
        <wd-button size="small" type="primary" variant="plain" @click="onSearch">
          搜索
        </wd-button>
        <wd-button size="small" variant="plain" @click="onReset">
          重置
        </wd-button>
      </view>
    </view>
    <view class="action-bar">
      <text class="text-md text-muted font-bold">
        共 {{ total }} 条
      </text>
    </view>
    <SkeletonPage v-if="loading" :rows="5" search />
    <template v-else>
      <view class="px-sm">
        <view class="admin-card">
          <ListEmpty v-if="!loading && list.length === 0" text="暂无日志" />
          <wd-cell-group v-else border>
            <wd-cell v-for="item in list" :key="item.id" is-link @click="viewDetail(item)">
              <template #title>
                <view class="flex flex-wrap items-center gap-sm">
                  <StatusBadge :status="(item.response_code || 0) < 300 ? 'success' : 'failed'" dot />
                  <text class="text-sm font-medium font-mono">
                    {{ item.request_method }}
                  </text>
                  <text class="text-muted truncate text-sm" style="max-width: 300rpx;">
                    {{ item.request_path }}
                  </text>
                </view>
                <text class="text-muted block text-xs">
                  {{ item.description || '-' }} · {{ item.request_ip }} · {{ item.process_time }}
                </text>
              </template>
              <template #default>
                <wd-icon name="delete" size="18px" color="var(--danger-color)" @click.stop="handleDelete(item.id!)" />
              </template>
            </wd-cell>
          </wd-cell-group>
        </view>
      </view>
      <PaginationBar :current="pageParams.page_no" :page-size="pageParams.page_size" :total="total" @prev="loadPrev" @next="loadNext" />
      <wd-popup v-model="showDetail" position="bottom" round closable @close="showDetail = false">
        <view v-if="detailItem" class="p-xl">
          <wd-navbar title="日志详情" left-arrow @click-left="showDetail = false" />
          <view class="admin-card mt-lg">
            <wd-cell-group border>
              <wd-cell title="操作人" :value="detailItem.username || '-'" />
              <wd-cell title="请求路径" :value="detailItem.request_path || '-'" />
              <wd-cell title="请求方法" :value="detailItem.request_method || '-'" />
              <wd-cell title="请求 IP" :value="detailItem.request_ip || '-'" />
              <wd-cell title="状态码">
                <StatusBadge :status="(detailItem.response_code || 0) < 300 ? 'success' : 'failed'" />
              </wd-cell>
              <wd-cell title="响应时间" :value="detailItem.process_time || '-'" />
              <wd-cell title="操作说明" :value="detailItem.description || '-'" />
            </wd-cell-group>
          </view>
          <view class="mt-sm rounded-md bg-light px-sm py-sm">
            <text class="text-muted text-xs">
              请求参数：{{ detailItem.request_payload || '无' }}
            </text>
          </view>
          <view class="mt-lg">
            <wd-button block @click="showDetail = false">
              关闭
            </wd-button>
          </view>
        </view>
      </wd-popup>
    </template>
  </view>
</template>
