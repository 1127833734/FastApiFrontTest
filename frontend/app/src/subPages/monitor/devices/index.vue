<script setup lang="ts">
import type { OnlineUserItem } from '@/api/module_monitor/online'
import { onLoad, onPullDownRefresh } from '@dcloudio/uni-app'
import { ref } from 'vue'
import { OnlineAPI } from '@/api/module_monitor/online'
import SkeletonPage from '@/components/SkeletonPage.vue'

definePage({
  name: 'work-devices',
  style: { navigationBarTitleText: '设备管理' },
})

const toast = useToast()
const loading = ref(false)
const sessions = ref<OnlineUserItem[]>([])

async function loadSessions() {
  loading.value = true
  try {
    const res = await OnlineAPI.getCurrent()
    sessions.value = res || []
  }
  catch (e) {
    toast.error(getErrorMessage(e, '加载设备列表失败'))
  }
  finally {
    loading.value = false
    uni.stopPullDownRefresh()
  }
}

async function handleForceLogout(sessionId: string) {
  uni.showModal({
    title: '提示',
    content: '确认强制下线此设备？该设备的登录状态将被立即清除。',
    success: async (res) => {
      if (!res.confirm)
        return
      try {
        await OnlineAPI.forceLogout(sessionId)
        toast.success('已强制下线')
        loadSessions()
      }
      catch (e) { toast.error(getErrorMessage(e, '操作失败')) }
    },
  })
}

function getDeviceIcon(os?: string) {
  if (!os)
    return '📱'
  const lower = os.toLowerCase()
  if (lower.includes('ios') || lower.includes('iphone') || lower.includes('ipad'))
    return '📱'
  if (lower.includes('android'))
    return '🤖'
  if (lower.includes('windows'))
    return '💻'
  if (lower.includes('mac'))
    return '🖥'
  if (lower.includes('linux'))
    return '🐧'
  return '📱'
}

function getBrowserLabel(browser?: string) {
  if (!browser)
    return '未知浏览器'
  const lower = browser.toLowerCase()
  if (lower.includes('wechat') || lower.includes('weixin'))
    return '微信内置'
  if (lower.includes('chrome'))
    return 'Chrome'
  if (lower.includes('safari'))
    return 'Safari'
  if (lower.includes('firefox'))
    return 'Firefox'
  if (lower.includes('edge'))
    return 'Edge'
  return browser
}

onPullDownRefresh(() => {
  loadSessions()
})
onLoad(() => {
  loadSessions()
})
</script>

<template>
  <view class="list-page">
    <!-- Summary Card -->
    <view class="summary-card fade-in-up">
      <view class="summary-card__icon">
        <text class="summary-card__icon-text">
          🔐
        </text>
      </view>
      <view class="summary-card__body">
        <text class="summary-card__title">
          登录设备管理
        </text>
        <text class="summary-card__desc">
          当前共有 {{ sessions.length }} 个活跃会话
        </text>
      </view>
    </view>

    <!-- Sessions List -->
    <SkeletonPage v-if="loading && sessions.length === 0" :rows="3" />
    <ListEmpty v-else-if="!loading && sessions.length === 0" text="暂无活跃会话" />
    <view v-else class="sessions-list">
      <view
        v-for="(session, idx) in sessions"
        :key="(session.session_id || '') + idx"
        class="session-item" :class="[`fade-in-up-${Math.min(idx % 5 + 1, 5)}`]"
      >
        <view class="session-item__header">
          <view class="session-item__icon">
            <text class="session-item__icon-text">
              {{ getDeviceIcon(session.os) }}
            </text>
          </view>
          <view class="session-item__info">
            <text class="session-item__os">
              {{ session.os || '未知设备' }}
            </text>
            <text class="session-item__browser">
              {{ getBrowserLabel(session.browser) }}
            </text>
          </view>
          <view
            v-if="idx === 0"
            class="session-item__current-tag"
          >
            <text class="session-item__current-text">
              当前
            </text>
          </view>
        </view>

        <view class="session-item__details">
          <view class="detail-row">
            <text class="detail-row__label">
              IP 地址
            </text>
            <text class="detail-row__value">
              {{ session.ipaddr || '—' }}
            </text>
          </view>
          <view class="detail-row">
            <text class="detail-row__label">
              登录位置
            </text>
            <text class="detail-row__value">
              {{ session.login_location || '—' }}
            </text>
          </view>
          <view class="detail-row">
            <text class="detail-row__label">
              登录时间
            </text>
            <text class="detail-row__value">
              {{ session.login_time || '—' }}
            </text>
          </view>
        </view>

        <view v-if="idx !== 0" class="session-item__action">
          <view class="logout-btn btn-press" @click="handleForceLogout(session.session_id || '')">
            <text class="logout-btn__text">
              强制下线
            </text>
          </view>
        </view>
      </view>
    </view>

    <!-- Tips -->
    <view class="tips fade-in-up-3">
      <text class="tips__text">
        💡 如发现异常登录设备，请立即强制下线并修改密码。
      </text>
    </view>

    <view style="height: 80rpx;" />
  </view>
</template>

<style lang="scss" scoped>
.list-page {
  padding: 0 32rpx;
  padding-bottom: 40rpx;
  background: var(--page-bg-color, #F9F9F9);
  min-height: 100vh;
}

/* ===== Summary Card ===== */
.summary-card {
  display: flex;
  align-items: center;
  gap: 24rpx;
  background: linear-gradient(135deg, var(--primary-color, #4F8CFF), #005CD6);
  border-radius: 24rpx;
  padding: 32rpx;
  margin: 24rpx 0;
  box-shadow: 0 8rpx 24rpx rgba(1, 77, 178, 0.2);

  &__icon {
    width: 80rpx;
    height: 80rpx;
    border-radius: 20rpx;
    background: rgba(255, 255, 255, 0.2);
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
  }

  &__icon-text {
    font-size: 40rpx;
  }

  &__body {
    flex: 1;
  }

  &__title {
    display: block;
    font-size: 32rpx;
    font-weight: 700;
    color: #FFFFFF;
    margin-bottom: 4rpx;
  }

  &__desc {
    font-size: 24rpx;
    color: rgba(255, 255, 255, 0.8);
  }
}

/* ===== Sessions List ===== */
.sessions-list {
  display: flex;
  flex-direction: column;
  gap: 16rpx;
}

.session-item {
  background: var(--card-bg-color, #FFFFFF);
  border-radius: 24rpx;
  padding: 24rpx;
  box-shadow: var(--shadow-sm, 0 1rpx 2rpx rgba(1, 77, 178,0.06));

  &__header {
    display: flex;
    align-items: center;
    gap: 16rpx;
    margin-bottom: 16rpx;
  }

  &__icon {
    width: 72rpx;
    height: 72rpx;
    border-radius: 18rpx;
    background: var(--bg-color-2, #F5F6F8);
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
  }

  &__icon-text {
    font-size: 36rpx;
  }

  &__info {
    flex: 1;
    min-width: 0;
  }

  &__os {
    display: block;
    font-size: 28rpx;
    font-weight: 600;
    color: var(--text-color, #0A1628);
    margin-bottom: 4rpx;
  }

  &__browser {
    font-size: 24rpx;
    color: var(--text-color-3, #6B7280);
  }

  &__current-tag {
    background: rgba(16, 185, 129, 0.1);
    padding: 4rpx 16rpx;
    border-radius: 8rpx;
    flex-shrink: 0;
  }

  &__current-text {
    font-size: 22rpx;
    color: #10B981;
    font-weight: 600;
  }

  &__details {
    background: var(--page-bg-color, #F9F9F9);
    border-radius: 16rpx;
    padding: 16rpx;
  }

  &__action {
    margin-top: 16rpx;
    display: flex;
    justify-content: flex-end;
  }
}

.detail-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 6rpx 0;

  &__label {
    font-size: 24rpx;
    color: var(--text-color-3, #6B7280);
  }

  &__value {
    font-size: 24rpx;
    color: var(--text-color, #0A1628);
    font-weight: 500;
    font-family: 'SF Mono', 'Consolas', monospace;
  }
}

.logout-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 56rpx;
  padding: 0 32rpx;
  border-radius: 12rpx;
  background: var(--danger-color-light, #FEF2F2);
  transition: all 0.15s ease;

  &:active { opacity: 0.7; transform: scale(0.95); }

  &__text {
    font-size: 24rpx;
    font-weight: 500;
    color: var(--danger-color, #EF4444);
  }
}

/* ===== Tips ===== */
.tips {
  margin-top: 32rpx;
  padding: 24rpx;
  background: var(--warning-color-light, rgba(245, 158, 11, 0.08));
  border-radius: 16rpx;

  &__text {
    font-size: 24rpx;
    color: var(--text-color-3, #6B7280);
    line-height: 1.6;
  }
}
</style>
