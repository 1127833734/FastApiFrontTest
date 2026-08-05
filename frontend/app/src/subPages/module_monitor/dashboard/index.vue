<script setup lang="ts">
import type { DashboardStats } from '@/api/module_monitor/dashboard'
import { onLoad, onPullDownRefresh, onShow } from '@dcloudio/uni-app'
import { ref } from 'vue'
import { DashboardAPI } from '@/api/module_monitor/dashboard'

definePage({
  name: 'dashboard',
  style: { navigationBarTitleText: '数据概览' },
})

const toast = useToast()
const loading = ref(false)
const stats = ref<DashboardStats | null>(null)

// 7-day mock login trend data
const loginTrend = ref([
  { day: '一', value: 45, label: '128' },
  { day: '二', value: 60, label: '186' },
  { day: '三', value: 85, label: '245' },
  { day: '四', value: 72, label: '210' },
  { day: '五', value: 100, label: '312' },
  { day: '六', value: 68, label: '198' },
  { day: '日', value: 38, label: '95' },
])

const alerts = ref([
  { id: 1, level: 'danger', text: '磁盘使用率超过 85%', time: '10分钟前' },
  { id: 2, level: 'warning', text: '内存使用率持续升高', time: '30分钟前' },
  { id: 3, level: 'info', text: '新用户注册量异常增长', time: '1小时前' },
])

function alertBg(level: string) {
  const map: Record<string, string> = {
    danger: 'var(--danger-color-light, #FEF2F2)',
    warning: 'var(--warning-color-light, #FFF8E6)',
    info: 'var(--info-color-light, #F2F3F5)',
  }
  return map[level] || 'var(--bg-color-2, #F2F3F5)'
}
function alertColor(level: string) {
  const map: Record<string, string> = {
    danger: 'var(--danger-color, #EF4444)',
    warning: 'var(--warning-color, #F59E0B)',
    info: 'var(--info-color, #8892A3)',
  }
  return map[level] || '#8892A3'
}

async function loadData() {
  loading.value = true
  try {
    stats.value = await DashboardAPI.getStats()
  }
  catch {
    toast.error('加载失败')
  }
  finally {
    loading.value = false
    uni.stopPullDownRefresh()
  }
}

onLoad(() => loadData())
onShow(() => {
  const pages = getCurrentPages()
  if (pages.length > 0 && pages[pages.length - 1].route === 'subPages/biz/dashboard/index') {
    uni.$emit('updateTabbar', 'work')
  }
})
onPullDownRefresh(() => loadData())
</script>

<template>
  <view class="page-wraper py-3">
    <SkeletonPage v-if="loading && !stats" :rows="6" />

    <template v-else>
      <!-- Stats row -->
      <view class="mx-3 mb-3 flex gap-3">
        <view class="flex-1 rounded-2 p-4 text-center wot-bg-filled-oppo">
          <text class="block text-5 font-bold" style="color: var(--primary-color);">
            {{ stats?.total_users?.toLocaleString() ?? '-' }}
          </text>
          <text class="mt-1 block text-2.5 wot-text-text-secondary">
            总用户数
          </text>
        </view>
        <view class="flex-1 rounded-2 p-4 text-center wot-bg-filled-oppo">
          <text class="block text-5 font-bold" style="color: var(--success-color);">
            {{ stats?.today_login_count ?? '-' }}
          </text>
          <text class="mt-1 block text-2.5 wot-text-text-secondary">
            今日活跃
          </text>
        </view>
      </view>

      <!-- Chart section -->
      <view class="mx-3 mb-3 rounded-2 p-4 wot-bg-filled-oppo">
        <view class="mb-4 flex items-center justify-between">
          <text class="text-3.5 font-bold wot-text-text-main">
            登录趋势 (近7天)
          </text>
          <text class="text-2.5 wot-text-text-auxiliary">
            7天
          </text>
        </view>
        <view class="flex items-end justify-between gap-3" style="height: 280rpx;">
          <view v-for="item in loginTrend" :key="item.day" class="h-full flex flex-1 flex-col items-center justify-end gap-2">
            <text class="text-2.5 wot-text-text-auxiliary">
              {{ item.label }}
            </text>
            <view
              class="w-[52rpx] rounded-lg"
              :style="{ height: `${Math.max(item.value * 1.8, 16)}rpx`, background: 'linear-gradient(180deg, var(--primary-color-light, #E8F0FF) 0%, var(--primary-color, #4F8CFF) 100%)' }"
            />
          </view>
        </view>
        <view class="mt-2 flex justify-between gap-3">
          <text v-for="item in loginTrend" :key="item.day" class="flex-1 text-center text-2.5 wot-text-text-auxiliary">
            {{ item.day }}
          </text>
        </view>
      </view>

      <!-- Alerts -->
      <view class="mx-3 mb-3 rounded-2 p-4 wot-bg-filled-oppo">
        <view class="mb-3 flex items-center justify-between">
          <text class="text-3.5 font-bold wot-text-text-main">
            系统告警
          </text>
          <wd-tag type="danger" round size="small">
            {{ alerts.length }}
          </wd-tag>
        </view>
        <view
          v-for="alert in alerts"
          :key="alert.id"
          class="mb-2 flex items-center gap-3 rounded-lg p-3 last:mb-0"
          :style="{ background: alertBg(alert.level) }"
        >
          <view class="h-1.5 w-1.5 shrink-0 rounded-full" :style="{ background: alertColor(alert.level) }" />
          <text class="flex-1 text-3 wot-text-text-main">
            {{ alert.text }}
          </text>
          <text class="shrink-0 text-2.5 wot-text-text-auxiliary">
            {{ alert.time }}
          </text>
        </view>
      </view>
    </template>
  </view>
</template>
