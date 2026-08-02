<script setup lang="ts">
import type { LoginLogItem } from '@/api/module_system/log'
import { onLoad, onPullDownRefresh } from '@dcloudio/uni-app'
import { ref } from 'vue'
import { LoginLogAPI } from '@/api/module_system/log'

definePage({ name: 'work-loginlogs', style: { navigationBarTitleText: '登录日志' } })

const toast = useToast()
const searchName = ref('')

const { list, total, loading, pageParams, loadData, toFirst, loadPrev, loadNext } = useListPage<LoginLogItem>({
  fetcher: p => LoginLogAPI.getPage({ ...p, username: searchName.value || undefined }),
  onError: () => toast.error('加载失败'),
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
function handleDelete(id: number) {
  uni.showModal({
    title: '提示',
    content: '确认删除？',
    success: async (res) => {
      if (res.confirm) {
        try {
          await LoginLogAPI.remove([id])
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
        <wd-input v-model="searchName" placeholder="搜索用户名" clearable class="flex-1" />
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
          <ListEmpty v-if="!loading && list.length === 0" text="暂无登录日志" />
          <wd-cell-group v-else>
            <wd-cell v-for="item in list" :key="item.id">
              <template #title>
                <view>
                  <text class="text-md font-medium">
                    {{ item.username || '-' }}
                  </text>
                  <text class="text-muted mt-xs block text-xs">
                    IP: {{ item.login_ip || '-' }} · {{ item.login_location || '-' }}
                  </text>
                </view>
              </template>
              <template #label>
                <text class="text-muted text-xs">
                  {{ item.request_browser || '' }}{{ item.request_browser && item.request_os ? ' / ' : '' }}{{ item.request_os || '' }}{{ item.msg ? ` · ${item.msg}` : '' }}
                </text>
              </template>
              <template #default>
                <view class="flex items-center gap-sm">
                  <StatusBadge :status="String(item.status) === '1' ? 'success' : 'failed'" />
                  <wd-icon name="delete" size="18px" color="var(--danger-color)" @click.stop="handleDelete(item.id!)" />
                </view>
              </template>
            </wd-cell>
          </wd-cell-group>
        </view>
      </view>
      <PaginationBar :current="pageParams.page_no" :page-size="pageParams.page_size" :total="total" @prev="loadPrev" @next="loadNext" />
    </template>
  </view>
</template>
