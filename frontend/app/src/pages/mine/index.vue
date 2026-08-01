<script lang="ts" setup>
definePage({
  name: 'mine',
  layout: 'tabbar',
  style: { navigationBarTitleText: '我的' },
})

const router = useRouter()
const userStore = useUserStore()
const userInfo = computed(() => userStore.userInfo)

function navigateTo(name: string) {
  router.push({ name })
}

function handleLogout() {
  uni.showModal({
    title: '提示',
    content: '确认退出登录吗？',
    success(res) {
      if (res.confirm) {
        userStore.logout()
      }
    },
  })
}

onShow(() => {
  const pages = getCurrentPages()
  if (pages.length > 0 && pages[pages.length - 1].route === 'pages/mine/index') {
    uni.$emit('updateTabbar', 'mine')
  }
})

const settingsList = [
  { title: '首页示例', name: 'home-demo' },
  { title: '个人资料', name: 'profile' },
  { title: '修改密码', name: 'account' },
  { title: '通知设置', name: 'settings' },
  { title: '关于我们', name: 'about' },
]

const quickLinks = [
  { title: '用户管理', name: 'work-users', icon: 'user', color: 'var(--primary-color)' },
  { title: '角色管理', name: 'work-roles', icon: 'lock', color: '#F59E0B' },
  { title: '部门管理', name: 'work-depts', icon: 'apps', color: '#10B981' },
  { title: '菜单管理', name: 'work-menus', icon: 'menu', color: '#8B5CF6' },
  { title: '岗位管理', name: 'work-positions', icon: 'list', color: 'var(--primary-color)' },
  { title: '字典管理', name: 'work-dicts', icon: 'tags', color: '#F59E0B' },
  { title: '通知公告', name: 'work-notices', icon: 'notification', color: '#10B981' },
  { title: '参数管理', name: 'work-params', icon: 'settings', color: '#8B5CF6' },
  { title: '定时任务', name: 'work-cronjob', icon: 'clock-circle', color: '#EC4899' },
  { title: '工作流', name: 'work-workflow', icon: 'play-arrow', color: '#8B5CF6' },
  { title: '设备管理', name: 'work-devices', icon: 'phone', color: '#10B981' },
  { title: 'AI 模型', name: 'work-ai-models', icon: 'robot', color: '#8B5CF6' },
]
</script>

<template>
  <view class="mine-page">
    <!-- Header -->
    <view class="mine-header fade-in-up">
      <view class="mine-header__avatar">
        <text class="mine-header__avatar-text">
          {{ (userInfo?.name || '管').charAt(0) }}
        </text>
      </view>
      <text class="mine-header__name">
        {{ userInfo?.name || '管理员' }}
      </text>
      <text class="mine-header__role">
        {{ userInfo?.roles?.map(r => r.name).join(', ') || '超级管理员 · 技术部' }}
      </text>
    </view>

    <!-- Stats -->
    <view class="mine-stats fade-in-up-1">
      <view class="mine-stat-item card-pressable">
        <text class="mine-stat-item__value">
          1,024
        </text>
        <text class="mine-stat-item__label">
          操作次数
        </text>
      </view>
      <view class="mine-stat-item card-pressable">
        <text class="mine-stat-item__value">
          365
        </text>
        <text class="mine-stat-item__label">
          登录天数
        </text>
      </view>
    </view>

    <!-- Quick links -->
    <view class="mine-section fade-in-up-2">
      <text class="mine-section__title">
        快捷入口
      </text>
      <view class="quick-grid">
        <view
          v-for="item in quickLinks" :key="item.name"
          class="quick-item"
          hover-class="quick-item--hover"
          @click="navigateTo(item.name)"
        >
          <view class="quick-item__icon" :style="{ background: `${item.color}15` }">
            <wd-icon :name="item.icon" size="22px" :color="item.color" />
          </view>
          <text class="quick-item__text">
            {{ item.title }}
          </text>
        </view>
      </view>
    </view>

    <!-- Settings list -->
    <view class="mine-section fade-in-up-3">
      <text class="mine-section__title">
        设置
      </text>
      <view class="settings-card">
        <view
          v-for="(item, i) in settingsList" :key="i"
          class="settings-item"
          hover-class="settings-item--hover"
          @click="navigateTo(item.name)"
        >
          <text class="settings-item__label">
            {{ item.title }}
          </text>
          <text class="settings-item__arrow">
            ›
          </text>
        </view>
      </view>
    </view>

    <!-- Logout -->
    <view class="mine-section fade-in-up-4">
      <view class="logout-btn" hover-class="logout-btn--hover" @click="handleLogout">
        <text class="logout-btn__text">
          退出登录
        </text>
      </view>
    </view>

    <!-- Bottom safe area -->
    <view style="height: 100rpx;" />
  </view>
</template>

<style lang="scss" scoped>
.mine-page {
  padding: 0 32rpx;
  padding-bottom: calc(120rpx + env(safe-area-inset-bottom));
  background: var(--page-bg-color, #F9F9F9);
  min-height: 100vh;
}

/* ===== Header ===== */
.mine-header {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 40rpx 40rpx 48rpx;
  margin: 16rpx 0 32rpx;
  background: var(--gradient-primary, linear-gradient(135deg, #4F8CFF, #2563EB));
  border-radius: 32rpx;

  &__avatar {
    width: 112rpx;
    height: 112rpx;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.20);
    display: flex;
    align-items: center;
    justify-content: center;
    margin-bottom: 24rpx;
  }

  &__avatar-text {
    font-size: var(--font-3xl, 48rpx);
    font-weight: 600;
    color: #FFFFFF;
  }

  &__name {
    font-size: var(--font-2xl, 40rpx);
    font-weight: 600;
    color: #FFFFFF;
    margin-bottom: 8rpx;
  }

  &__role {
    font-size: var(--font-sm, 24rpx);
    color: rgba(255, 255, 255, 0.80);
  }
}

/* ===== Stats ===== */
.mine-stats {
  display: flex;
  gap: 24rpx;
  margin-bottom: 40rpx;
}

.mine-stat-item {
  flex: 1;
  background: var(--card-bg-color, #FFFFFF);
  border-radius: 24rpx;
  padding: 32rpx;
  box-shadow: var(--shadow-sm, 0 1rpx 2rpx rgba(1, 77, 178,0.06));
  display: flex;
  flex-direction: column;
  align-items: center;

  &__value {
    font-size: var(--font-2xl, 40rpx);
    font-weight: 600;
    color: var(--text-color, #0A1628);
    font-family: 'Inter', -apple-system, sans-serif;
    margin-bottom: 8rpx;
  }

  &__label {
    font-size: var(--font-sm, 24rpx);
    color: var(--text-color-3, #6B7280);
  }
}

/* ===== Section ===== */
.mine-section {
  margin-bottom: 40rpx;

  &__title {
    display: block;
    font-size: var(--font-lg, 32rpx);
    font-weight: 600;
    color: var(--text-color, #0A1628);
    margin-bottom: 20rpx;
  }
}

/* ===== Quick grid ===== */
.quick-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16rpx;
}

.quick-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12rpx;
  background: var(--card-bg-color, #FFFFFF);
  border-radius: 24rpx;
  padding: 24rpx 16rpx;
  box-shadow: var(--shadow-sm, 0 1rpx 2rpx rgba(1, 77, 178,0.06));
  transition: all 0.15s ease;

  &--hover {
    opacity: 0.85;
    transform: scale(0.95);
  }

  &__icon {
    width: 64rpx;
    height: 64rpx;
    border-radius: 16rpx;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  &__text {
    font-size: var(--font-xs, 20rpx);
    color: var(--text-color-3, #6B7280);
    text-align: center;
  }
}

/* ===== Settings ===== */
.settings-card {
  background: var(--card-bg-color, #FFFFFF);
  border-radius: 24rpx;
  box-shadow: var(--shadow-sm, 0 1rpx 2rpx rgba(1, 77, 178,0.06));
  overflow: hidden;
}

.settings-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 32rpx;

  &:not(:last-child) {
    border-bottom: 1rpx solid var(--border-color-light, #F3F4F6);
  }

  &--hover {
    background: var(--bg-color-2, #F5F6F8);
  }

  &__label {
    font-size: var(--font-lg, 32rpx);
    color: var(--text-color, #0A1628);
  }

  &__arrow {
    font-size: var(--font-xl, 36rpx);
    color: var(--text-color-4, #B0B0B0);
    font-family: 'Inter', -apple-system, sans-serif;
  }
}

/* ===== Logout ===== */
.logout-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 96rpx;
  background: var(--danger-color-light, #FEF2F2);
  border-radius: 24rpx;
  transition: all 0.15s ease;

  &--hover {
    opacity: 0.85;
  }

  &__text {
    font-size: var(--font-lg, 32rpx);
    font-weight: 500;
    color: var(--danger-color, #EF4444);
  }
}
</style>
