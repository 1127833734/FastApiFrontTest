<script setup lang="ts">
import type { DashboardStats } from '@/api/module_monitor/dashboard'
import { onLoad, onPullDownRefresh, onShow } from '@dcloudio/uni-app'
import { ref } from 'vue'
import { DashboardAPI } from '@/api/module_monitor/dashboard'
import SkeletonPage from '@/components/SkeletonPage.vue'

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
  <view class="dashboard-page">
    <!-- Nav header -->
    <view class="dash-nav">
      <text class="dash-nav__title">
        数据概览
      </text>
      <view class="dash-nav__badge">
        <text class="dash-nav__badge-text">
          今日
        </text>
      </view>
    </view>

    <SkeletonPage v-if="loading && !stats" :rows="6" />

    <template v-else>
      <!-- Stats row -->
      <view class="stats-row">
        <view class="stat-card card-pressable">
          <text class="stat-card__value" style="color: var(--primary-color);">
            {{ stats?.total_users?.toLocaleString() ?? '-' }}
          </text>
          <text class="stat-card__label">
            总用户数
          </text>
        </view>
        <view class="stat-card card-pressable">
          <text class="stat-card__value" style="color: var(--success-color);">
            {{ stats?.today_login_count ?? '-' }}
          </text>
          <text class="stat-card__label">
            今日活跃
          </text>
        </view>
      </view>

      <!-- Chart section -->
      <view class="chart-card">
        <view class="chart-card__header">
          <text class="chart-card__title">
            登录趋势 (近7天)
          </text>
          <text class="chart-card__period">
            7天
          </text>
        </view>
        <view class="chart-bars">
          <view v-for="item in loginTrend" :key="item.day" class="chart-bar-wrap">
            <view class="chart-bar" :style="{ height: `${item.value}%` }">
              <text class="chart-bar__tip">
                {{ item.label }}
              </text>
            </view>
            <text class="chart-bar__label">
              {{ item.day }}
            </text>
          </view>
        </view>
      </view>

      <!-- Alerts -->
      <view class="alert-card">
        <view class="alert-card__header">
          <text class="alert-card__title">
            系统告警
          </text>
          <view class="alert-card__badge">
            <text class="alert-card__badge-text">
              {{ alerts.length }}
            </text>
          </view>
        </view>
        <view
          v-for="alert in alerts" :key="alert.id"
          class="alert-item"
          :class="`alert-item--${alert.level}`"
        >
          <view class="alert-item__dot" :class="`alert-item__dot--${alert.level}`" />
          <text class="alert-item__text">
            {{ alert.text }}
          </text>
          <text class="alert-item__time">
            {{ alert.time }}
          </text>
        </view>
      </view>
    </template>
  </view>
</template>

<style lang="scss" scoped>
.dashboard-page {
  min-height: 100vh;
  background: var(--page-bg-color, #F9F9F9);
  padding: var(--spacing-2xl, 32rpx);
  padding-bottom: calc(40rpx + env(safe-area-inset-bottom));
}

.dash-nav {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 88rpx;
  margin-bottom: var(--spacing-lg, 20rpx);

  &__title {
    font-size: var(--font-2xl, 40rpx);
    font-weight: 600;
    color: var(--text-color, #0A1628);
  }

  &__badge {
    background: var(--bg-color-2, #F2F3F5);
    border-radius: var(--radius-full, 9999rpx);
    padding: 8rpx 24rpx;
  }

  &__badge-text {
    font-size: var(--font-sm, 24rpx);
    color: var(--text-color-3, #6B7280);
  }
}

.stats-row {
  display: flex;
  gap: var(--spacing-md, 16rpx);
  margin-bottom: var(--spacing-lg, 20rpx);
}

.stat-card {
  flex: 1;
  background: var(--card-bg-color, #FFFFFF);
  border-radius: var(--radius-md, 16rpx);
  padding: var(--spacing-md, 16rpx);
  box-shadow: var(--shadow-sm, 0 1rpx 2rpx rgba(1, 77, 178, 0.06));
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8rpx;

  &__value {
    font-size: var(--font-2xl, 40rpx);
    font-weight: 700;
    font-family: 'Inter', sans-serif;
  }

  &__label {
    font-size: var(--font-xs, 20rpx);
    color: var(--text-color-3, #6B7280);
  }
}

.chart-card {
  background: var(--card-bg-color, #FFFFFF);
  border-radius: var(--radius-md, 16rpx);
  padding: var(--spacing-lg, 20rpx);
  box-shadow: var(--shadow-sm, 0 1rpx 2rpx rgba(1, 77, 178, 0.06));
  margin-bottom: var(--spacing-lg, 20rpx);

  &__header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: var(--spacing-lg, 20rpx);
  }

  &__title {
    font-size: var(--font-md, 28rpx);
    font-weight: 600;
    color: var(--text-color, #0A1628);
  }

  &__period {
    font-size: var(--font-sm, 24rpx);
    color: var(--text-color-3, #6B7280);
  }
}

.chart-bars {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  height: 280rpx;
  gap: 12rpx;
}

.chart-bar-wrap {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12rpx;
  height: 100%;
  justify-content: flex-end;
}

.chart-bar {
  width: 52rpx;
  min-height: 16rpx;
  background: linear-gradient(180deg, var(--primary-color-light, #E8F0FF) 0%, var(--primary-color, #4F8CFF) 100%);
  border-radius: 8rpx;
  position: relative;
  transition: height 0.6s ease;

  &__tip {
    position: absolute;
    top: -36rpx;
    left: 50%;
    transform: translateX(-50%);
    font-size: var(--font-xs, 20rpx);
    color: var(--text-color-3, #6B7280);
    white-space: nowrap;
    opacity: 0.8;
  }

  &__label {
    font-size: var(--font-xs, 20rpx);
    color: var(--text-color-3, #6B7280);
  }
}

.alert-card {
  background: var(--card-bg-color, #FFFFFF);
  border-radius: var(--radius-md, 16rpx);
  padding: var(--spacing-lg, 20rpx);
  box-shadow: var(--shadow-sm, 0 1rpx 2rpx rgba(1, 77, 178, 0.06));

  &__header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: var(--spacing-md, 16rpx);
  }

  &__title {
    font-size: var(--font-md, 28rpx);
    font-weight: 600;
    color: var(--text-color, #0A1628);
  }

  &__badge {
    background: var(--danger-color, #EF4444);
    border-radius: 50%;
    width: 44rpx;
    height: 44rpx;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  &__badge-text {
    font-size: var(--font-sm, 24rpx);
    font-weight: 700;
    color: var(--text-color-inverse, #FFFFFF);
  }
}

.alert-item {
  display: flex;
  align-items: center;
  gap: 16rpx;
  padding: 20rpx;
  border-radius: var(--radius-sm, 8rpx);
  margin-bottom: 12rpx;

  &:last-child { margin-bottom: 0; }

  &--danger { background: var(--danger-color-light, #FEF2F2); }
  &--warning { background: var(--warning-color-light, #FFF8E6); }
  &--info { background: var(--info-color-light, #F2F3F5); }

  &__dot {
    width: 12rpx;
    height: 12rpx;
    border-radius: 50%;
    flex-shrink: 0;

    &--danger { background: var(--danger-color, #EF4444); }
    &--warning { background: var(--warning-color, #F59E0B); }
    &--info { background: var(--info-color, #8892A3); }
  }

  &__text {
    flex: 1;
    font-size: var(--font-sm, 24rpx);
    color: var(--text-color, #0A1628);
  }

  &__time {
    font-size: var(--font-xs, 20rpx);
    color: var(--text-color-3, #6B7280);
    flex-shrink: 0;
  }
}
</style>
