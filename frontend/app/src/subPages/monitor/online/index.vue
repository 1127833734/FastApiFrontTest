<script setup lang="ts">
import type { OnlineUserItem } from '@/api/module_monitor/online'
import { onLoad, onPullDownRefresh } from '@dcloudio/uni-app'
import { OnlineAPI } from '@/api/module_monitor/online'

definePage({ name: 'work-online', style: { navigationBarTitleText: '在线用户' } })

const toast = useToast()

const { list, total, loading, pageParams, loadData, loadPrev, loadNext } = useListPage<OnlineUserItem>({
  fetcher: p => OnlineAPI.getPage(p),
  onError: e => toast.error(getErrorMessage(e, '加载失败')),
})

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
        catch (e) { toast.error(getErrorMessage(e, '操作失败')) }
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
      <text class="text-md font-bold text-muted">
        共 {{ total }} 在线
      </text>
    </view>
    <view class="px-sm">
      <view class="admin-card">
        <ListEmpty v-if="!loading && list.length === 0" text="暂无在线用户" />
        <wd-cell-group v-else>
          <wd-cell v-for="item in list" :key="item.session_id || item.user_id">
            <template #title>
              <view>
                <text class="font-medium text-md">
                  {{ item.user_name || item.name || '-' }}
                </text>
                <text class="text-xs text-muted block mt-xs">
                  IP: {{ item.ipaddr || '-' }} · {{ item.login_location || '' }}
                </text>
              </view>
            </template>
            <template #label>
              <text class="text-xs text-muted">
                {{ item.browser || '' }}{{ item.browser && item.os ? ' / ' : '' }}{{ item.os || '' }}
              </text>
            </template>
            <template #default>
              <view class="flex items-center gap-sm">
                <StatusBadge status="active" />
                <wd-button size="small" type="danger" plain @click="forceLogout(item.session_id!)">下线</wd-button>
              </view>
            </template>
          </wd-cell>
        </wd-cell-group>
      </view>
    </view>
    <PaginationBar :current="pageParams.page_no" :page-size="pageParams.page_size" :total="total" @prev="loadPrev" @next="loadNext" />
  </view>
</template>
