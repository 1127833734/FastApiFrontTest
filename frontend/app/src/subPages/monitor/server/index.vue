<script setup lang="ts">
import type { ServerInfo } from '@/api/module_monitor/server'
import { onLoad, onPullDownRefresh } from '@dcloudio/uni-app'
import { ref } from 'vue'
import { ServerAPI } from '@/api/module_monitor/server'

definePage({ name: 'work-server', style: { navigationBarTitleText: '服务监控' } })

const toast = useToast()
const loading = ref(false)
const info = ref<ServerInfo>()

function pc(v = 0) {
  return Math.round(v)
}
function pcColor(v = 0) {
  if (v > 80)
    return 'var(--danger-color)'
  if (v > 60)
    return 'var(--warning-color)'
  return 'var(--success-color)'
}

async function loadData() {
  loading.value = true
  try {
    info.value = await ServerAPI.getInfo()
  }
  catch (e) { toast.error(getErrorMessage(e, '加载失败')) }
  finally {
    loading.value = false
    uni.stopPullDownRefresh()
  }
}

onPullDownRefresh(() => {
  loadData()
})

onLoad(() => loadData())
</script>

<template>
  <view class="page-wraper p-md">
    <wd-loading v-if="loading && !info" />
    <template v-else-if="info">
      <view class="stats-grid server-stats">
        <view class="stat-card">
          <text class="stat-card__label">
            CPU
          </text><text class="stat-card__value" :style="{ color: pcColor(info.cpu?.used_percent) }">
            {{ pc(info.cpu?.used_percent) }}%
          </text><text class="stat-card__trend text-muted">
            {{ info.cpu?.cores || '-' }} 核心
          </text>
        </view>
        <view class="stat-card">
          <text class="stat-card__label">
            内存
          </text><text class="stat-card__value" :style="{ color: pcColor(info.memory?.used_percent) }">
            {{ pc(info.memory?.used_percent) }}%
          </text><text class="stat-card__trend text-muted">
            {{ info.memory?.used || '-' }}
          </text>
        </view>
        <view class="stat-card">
          <text class="stat-card__label">
            磁盘
          </text><text class="stat-card__value" :style="{ color: pcColor(info.disk?.used_percent) }">
            {{ pc(info.disk?.used_percent) }}%
          </text><text class="stat-card__trend text-muted">
            {{ info.disk?.used || '-' }}
          </text>
        </view>
      </view>
      <view class="admin-card">
        <wd-cell-group border>
          <wd-cell title="操作系统" :value="info.os?.name || '-'" />
          <wd-cell title="主机名" :value="info.os?.hostname || '-'" />
          <wd-cell title="运行时间" :value="info.os?.uptime || '-'" />
          <wd-cell title="CPU 型号" :value="info.cpu?.model || '-'" />
        </wd-cell-group>
      </view>
    </template>
    <view v-else class="empty-state">
      <text class="empty-state__icon">
        ⚠️
      </text>
      <text class="empty-state__text">
        加载失败，请下拉刷新重试
      </text>
    </view>
  </view>
</template>
