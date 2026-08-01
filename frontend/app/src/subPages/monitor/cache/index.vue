<script setup lang="ts">
import type { CacheInfo } from '@/api/module_monitor/cache'
import { onLoad, onPullDownRefresh } from '@dcloudio/uni-app'
import { ref } from 'vue'
import { CacheAPI } from '@/api/module_monitor/cache'

definePage({ name: 'work-cache', style: { navigationBarTitleText: '缓存监控' } })

const toast = useToast()
const loading = ref(false)
const info = ref<CacheInfo>()

async function loadData() {
  loading.value = true
  try {
    info.value = await CacheAPI.getInfo()
  }
  catch (e) { toast.error(getErrorMessage(e, '加载失败')) }
  finally {
    loading.value = false
    uni.stopPullDownRefresh()
  }
}
function clearCache() {
  uni.showModal({ title: '提示', content: '确认清除所有缓存？', success: async (res) => {
    if (res.confirm) {
      try {
        await CacheAPI.clear()
        toast.success('缓存已清除')
        loadData()
      }
      catch (e) { toast.error(getErrorMessage(e, '操作失败')) }
    }
  } })
}

onPullDownRefresh(() => {
  loadData()
})

onLoad(() => loadData())
</script>

<template>
  <view class="page-wraper">
    <view v-if="loading" class="flex justify-center items-center py-4xl">
      <wd-loading />
    </view>
    <view v-else-if="info" class="p-md">
      <!-- Stats row -->
      <view class="stats-grid cache-stats">
        <view class="stat-card">
          <text class="stat-card__label">
            键数量
          </text><text class="stat-card__value" style="color:var(--primary-color);">
            {{ info.keys_count }}
          </text>
        </view>
        <view class="stat-card">
          <text class="stat-card__label">
            命中率
          </text><text class="stat-card__value" style="color:var(--success-color);">
            {{ info.hit_rate || '-' }}
          </text>
        </view>
        <view class="stat-card">
          <text class="stat-card__label">
            内存使用
          </text><text class="stat-card__value" style="color:var(--warning-color);font-size:var(--font-xl);">
            {{ info.used_memory || '-' }}
          </text>
        </view>
        <view class="stat-card">
          <text class="stat-card__label">
            数据库大小
          </text><text class="stat-card__value" style="color:var(--info-color);font-size:var(--font-xl);">
            {{ info.db_size ?? '-' }}
          </text>
        </view>
      </view>
      <view class="action-bar justify-center">
        <wd-button size="small" type="danger" plain @click="clearCache">清除缓存</wd-button>
      </view>
    </view>
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
