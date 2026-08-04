<script setup lang="ts">
import type { OnlineUserItem } from '@/api/module_monitor/online'
import { onLoad, onPullDownRefresh } from '@dcloudio/uni-app'
import { OnlineAPI } from '@/api/module_monitor/online'

definePage({ name: 'work-online', style: { navigationBarTitleText: '在线用户' } })

const toast = useToast()

const { list, total, loading, pageParams, loadData, loadNext } = useListPage<OnlineUserItem>({
  fetcher: p => OnlineAPI.getPage(p),
  onError: () => toast.error('加载失败'),
})

function handlePageChange({ value }: { value: number }) {
  pageParams.value.page_no = value
  loadData()
}

function forceLogout(sessionId: string) {
  uni.showModal({
    title: '提示',
    content: '确认强制下线该用户？',
    success: async (res) => {
      if (res.confirm) {
        try {
          await OnlineAPI.forceLogout(sessionId)
          toast.success('已强制下线')
          loadData()
        }
        catch { toast.error('操作失败') }
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
    <view class="action-bar">
      <text class="text-md text-muted font-bold">
        共 {{ total }} 在线
      </text>
    </view>
    <view class="px-sm">
      <view class="admin-card">
        <wd-empty v-if="!loading && list.length === 0" tip="暂无在线用户" />
        <wd-cell-group v-else>
          <wd-cell v-for="item in list" :key="item.session_id || item.user_id" center>
            <template #title>
              <view>
                <text class="text-md font-medium">
                  {{ item.user_name || item.name || '-' }}
                </text>
                <text class="text-muted mt-xs block text-xs">
                  IP: {{ item.ipaddr || '-' }} · {{ item.login_location || '' }}
                </text>
              </view>
            </template>
            <template #label>
              <text class="text-muted text-xs">
                {{ item.browser || '' }}{{ item.browser && item.os ? ' / ' : '' }}{{ item.os || '' }}
              </text>
            </template>
            <template #default>
              <view class="flex items-center gap-sm">
                <StatusBadge status="active" />
                <wd-button size="small" type="danger" variant="plain" @click="forceLogout(item.session_id!)">
                  下线
                </wd-button>
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
  </view>
</template>
