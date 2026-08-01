<script setup lang="ts">
import { computed } from 'vue'
import { useUserStore } from '@/store/userStore'

definePage({
  name: 'work',
  layout: 'tabbar',
  style: { navigationBarTitleText: '工作台' },
})

const router = useRouter()
const userStore = useUserStore()
const userInfo = computed(() => userStore.userInfo)
function navigateTo(name: string) {
  router.push({ name })
}

onShow(() => {
  const pages = getCurrentPages()
  if (pages.length > 0 && pages[pages.length - 1].route === 'pages/work/index') {
    uni.$emit('updateTabbar', 'work')
  }
})

const groups = [
  {
    title: '系统管理',
    color: 'var(--primary-color)',
    bg: 'var(--primary-color-light)',
    items: [
      { icon: 'user', text: '用户管理', name: 'work-users' },
      { icon: 'lock', text: '角色管理', name: 'work-roles' },
      { icon: 'apps', text: '部门管理', name: 'work-depts' },
      { icon: 'menu', text: '菜单管理', name: 'work-menus' },
      { icon: 'list', text: '岗位管理', name: 'work-positions' },
    ],
  },
  {
    title: '系统配置',
    color: '#F59E0B',
    bg: 'var(--warning-color-light)',
    items: [
      { icon: 'tags', text: '字典管理', name: 'work-dicts' },
      { icon: 'notification', text: '通知公告', name: 'work-notices' },
      { icon: 'settings', text: '参数管理', name: 'work-params' },
      { icon: 'refresh', text: '版本管理', name: 'work-versions' },
    ],
  },
  {
    title: '运维监控',
    color: '#10B981',
    bg: 'var(--success-color-light)',
    items: [
      { icon: 'message', text: '工单管理', name: 'work-tickets' },
      { icon: 'file', text: '操作日志', name: 'work-oplogs' },
      { icon: 'eye-fill', text: '登录日志', name: 'work-loginlogs' },
      { icon: 'user', text: '在线用户', name: 'work-online' },
      { icon: 'dashboard', text: '服务监控', name: 'work-server' },
      { icon: 'refresh', text: '缓存管理', name: 'work-cache' },
      { icon: 'folder', text: '文件管理', name: 'work-file-manager' },
      { icon: 'clock-circle-fill', text: '定时任务', name: 'work-cronjob' },
      { icon: 'phone', text: '设备管理', name: 'work-devices' },
    ],
  },
  {
    title: '开发者工具',
    color: '#8B5CF6',
    bg: 'var(--bg-color-2)',
    items: [
      { icon: 'message', text: 'AI 助手', name: 'work-chat' },
      { icon: 'robot', text: 'AI 模型', name: 'work-ai-models' },
      { icon: 'file', text: '代码生成', name: 'work-gencode' },
      { icon: 'play-arrow', text: '工作流', name: 'work-workflow' },
    ],
  },
]
</script>

<template>
  <view class="work-page">
    <!-- Navigation -->
    <view class="work-nav">
      <text class="work-nav__title">
        工作台
      </text>
      <view class="work-nav__avatar" @click="navigateTo('mine')">
        <text class="work-nav__avatar-text">
          {{ (userInfo?.name || '管').charAt(0) }}
        </text>
      </view>
    </view>

    <!-- User info card -->
    <view class="user-card fade-in-up">
      <view class="user-card__avatar">
        <text class="user-card__avatar-text">
          {{ (userInfo?.name || '管').charAt(0) }}
        </text>
      </view>
      <view class="user-card__info">
        <text class="user-card__name">
          {{ userInfo?.name || 'FastapiAdmin' }}
        </text>
        <text class="user-card__role">
          {{ userInfo?.roles?.map(r => r.name).join(', ') || '超级管理员' }}
        </text>
      </view>
    </view>

    <!-- Module groups -->
    <view v-for="(group, gi) in groups" :key="gi" class="module-group" :class="[`fade-in-up-${gi + 1}`]">
      <text class="module-group__title">
        {{ group.title }}
      </text>
      <view class="module-grid">
        <view
          v-for="item in group.items"
          :key="item.name"
          class="module-item"
          hover-class="module-item--hover"
          @click="navigateTo(item.name)"
        >
          <view class="module-item__icon" :style="{ background: group.bg }">
            <wd-icon :name="item.icon" size="22px" :color="group.color" />
          </view>
          <text class="module-item__text">
            {{ item.text }}
          </text>
        </view>
      </view>
    </view>

    <!-- Bottom safe area -->
    <view style="height: 100rpx;" />
  </view>
</template>

<style lang="scss" scoped>
.work-page {
  padding: 0 32rpx;
  padding-bottom: calc(120rpx + env(safe-area-inset-bottom));
  background: var(--page-bg-color, #F9F9F9);
  min-height: 100vh;
}

/* ===== Navigation ===== */
.work-nav {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16rpx 0 24rpx;

  &__title {
    font-size: var(--font-2xl, 40rpx);
    font-weight: 600;
    color: var(--text-color, #0A1628);
  }

  &__avatar {
    width: 72rpx;
    height: 72rpx;
    border-radius: 50%;
    background: linear-gradient(135deg, var(--primary-color, #4F8CFF), var(--primary-color-dark, #2970FF));
    display: flex;
    align-items: center;
    justify-content: center;
  }

  &__avatar-text {
    font-size: var(--font-md, 28rpx);
    font-weight: 600;
    color: #FFFFFF;
  }
}

/* ===== User card ===== */
.user-card {
  display: flex;
  align-items: center;
  gap: 24rpx;
  background: var(--card-bg-color, #FFFFFF);
  border-radius: 32rpx;
  padding: 32rpx;
  margin-bottom: 40rpx;
  box-shadow: var(--shadow-sm, 0 1rpx 2rpx rgba(1, 77, 178,0.06));

  &__avatar {
    width: 96rpx;
    height: 96rpx;
    border-radius: 50%;
    background: linear-gradient(135deg, var(--primary-color, #4F8CFF), var(--primary-color-dark, #2970FF));
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
  }

  &__avatar-text {
    font-size: var(--font-xl, 36rpx);
    font-weight: 600;
    color: #FFFFFF;
  }

  &__info {
    display: flex;
    flex-direction: column;
    gap: 4rpx;
  }

  &__name {
    font-size: var(--font-xl, 36rpx);
    font-weight: 600;
    color: var(--text-color, #0A1628);
  }

  &__role {
    font-size: var(--font-sm, 24rpx);
    color: var(--text-color-3, #6B7280);
  }
}

/* ===== Module group ===== */
.module-group {
  margin-bottom: 40rpx;

  &__title {
    display: block;
    font-size: var(--font-lg, 32rpx);
    font-weight: 600;
    color: var(--text-color, #0A1628);
    margin-bottom: 20rpx;
  }
}

.module-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16rpx;
}

.module-item {
  display: flex;
  align-items: center;
  gap: 20rpx;
  background: var(--card-bg-color, #FFFFFF);
  border-radius: 24rpx;
  padding: 24rpx;
  box-shadow: var(--shadow-sm, 0 1rpx 2rpx rgba(1, 77, 178,0.06));
  transition: all 0.15s ease;

  &--hover {
    opacity: 0.85;
    transform: scale(0.98);
    box-shadow: var(--shadow-md, 0 4rpx 12rpx rgba(1, 77, 178,0.10));
  }

  &__icon {
    width: 64rpx;
    height: 64rpx;
    border-radius: 16rpx;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
  }

  &__text {
    font-size: var(--font-md, 28rpx);
    font-weight: 500;
    color: var(--text-color, #0A1628);
  }
}
</style>
