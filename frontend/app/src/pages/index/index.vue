<script setup lang="ts">
import type { DashboardStats } from '@/api/module_monitor/dashboard'
import type { NoticeItem } from '@/api/module_system/notice'
import { onPullDownRefresh, onReady, onShow } from '@dcloudio/uni-app'
import { ref } from 'vue'
import { DashboardAPI } from '@/api/module_monitor/dashboard'
import { NoticeAPI } from '@/api/module_system/notice'
import { TicketAPI } from '@/api/module_system/ticket'

definePage({
  name: 'home',
  layout: 'tabbar',
  style: { navigationBarTitleText: '工作台概览' },
})

let _router: ReturnType<typeof useRouter> | null = null
function getRouter() {
  if (!_router) {
    try {
      _router = useRouter()
    }
    catch {}
    return _router
  }
}

const loading = ref(false)
const dashboardStats = ref<DashboardStats | null>(null)
const pendingTickets = ref(0)
const recentNotices = ref<NoticeItem[]>([])

const NAV_LIST = [
  { icon: '/static/icons/user.png', title: '用户管理', name: 'work-users' },
  { icon: '/static/icons/role.png', title: '角色管理', name: 'work-roles' },
  { icon: '/static/icons/notice.png', title: '通知公告', name: 'work-notices' },
  { icon: '/static/icons/setting.png', title: '系统配置', name: 'work-params' },
]

function navigateTo(name: string) {
  const r = getRouter()
  if (r)
    r.push({ name })
}

async function loadData() {
  loading.value = true
  try {
    const [statsRes, ticketRes] = await Promise.allSettled([
      DashboardAPI.getStats(),
      TicketAPI.getPage({ page_no: 1, page_size: 1, status: '0' }),
    ])
    if (statsRes.status === 'fulfilled')
      dashboardStats.value = statsRes.value
    if (ticketRes.status === 'fulfilled')
      pendingTickets.value = ticketRes.value.total || 0
  }
  catch { /* silent */ }
  finally {
    loading.value = false
    uni.stopPullDownRefresh()
  }
}

async function loadNotices() {
  try {
    const res = await NoticeAPI.getPage({ page_no: 1, page_size: 3, status: 1 })
    recentNotices.value = res.list || []
  }
  catch { /* silent */ }
}

onPullDownRefresh(() => {
  Promise.all([loadData(), loadNotices()])
})

onReady(() => {
  Promise.all([loadData(), loadNotices()])
})

onShow(() => {
  const pages = getCurrentPages()
  if (pages.length > 0 && pages[pages.length - 1].route === 'pages/index/index')
    uni.$emit('updateTabbar', 'index')
})

function getDateString() {
  const now = new Date()
  const weekDays = ['日', '一', '二', '三', '四', '五', '六']
  return `${now.getFullYear()}年${now.getMonth() + 1}月${now.getDate()}日 星期${weekDays[now.getDay()]}`
}

function getGreeting() {
  const hour = new Date().getHours()
  if (hour < 6)
    return '夜深了'
  if (hour < 9)
    return '早上好'
  if (hour < 12)
    return '上午好'
  if (hour < 14)
    return '中午好'
  if (hour < 18)
    return '下午好'
  return '晚上好'
}
</script>

<template>
  <view class="home-page">
    <!-- Navigation bar -->
    <view class="home-nav">
      <text class="home-nav__title">
        工作台概览
      </text>
      <view class="home-nav__bell">
        <text class="home-nav__bell-icon" @click="navigateTo('work-notices')">
          🔔
        </text>
        <view v-if="pendingTickets > 0" class="home-nav__badge" />
      </view>
    </view>

    <!-- Greeting card -->
    <view class="greeting-card fade-in-up">
      <text class="greeting-card__text">
        {{ getGreeting() }}，管理员
      </text>
      <text class="greeting-card__date">
        {{ getDateString() }}
      </text>
    </view>

    <!-- Dashboard entry -->
    <view class="dashboard-entry card-pressable fade-in-up-1" @click="navigateTo('dashboard')">
      <view class="dashboard-entry__icon">
        <text class="dashboard-entry__icon-text">
          📊
        </text>
      </view>
      <view class="dashboard-entry__info">
        <text class="dashboard-entry__title">
          数据概览
        </text>
        <text class="dashboard-entry__sub">
          查看系统运行状态与趋势分析
        </text>
      </view>
      <text class="dashboard-entry__arrow">
        ›
      </text>
    </view>

    <!-- Quick nav -->
    <view class="home-grid home-grid--nav">
      <wd-grid :column="4" clickable>
        <wd-grid-item v-for="(item, i) in NAV_LIST" :key="i" @click="navigateTo(item.name)">
          <image class="home-nav-icon" :src="item.icon" mode="aspectFit" />
          <text class="home-grid__label">
            {{ item.title }}
          </text>
        </wd-grid-item>
      </wd-grid>
    </view>

    <!-- Stats -->
    <view class="section-header">
      <text class="section-header__title">
        运营概览
      </text>
    </view>
    <SkeletonPage v-if="loading && !dashboardStats" :rows="3" />
    <template v-else>
      <view class="stats-row">
        <view class="stat-item card-pressable fade-in-up-1">
          <text class="stat-item__value stat-item__value--primary count-up">
            {{ dashboardStats?.total_users ?? '-' }}
          </text>
          <text class="stat-item__label">
            注册用户
          </text>
          <text class="stat-item__sub">
            本周新增 {{ dashboardStats?.week_user_created ?? 0 }}
          </text>
        </view>
        <view class="stat-item card-pressable fade-in-up-2">
          <text class="stat-item__value stat-item__value--success count-up">
            {{ dashboardStats?.online_users ?? '-' }}
          </text>
          <text class="stat-item__label">
            在线用户
          </text>
          <text class="stat-item__sub">
            当前在线
          </text>
        </view>
        <view class="stat-item card-pressable fade-in-up-3">
          <text class="stat-item__value stat-item__value--warning count-up">
            {{ dashboardStats?.today_login_count ?? '-' }}
          </text>
          <text class="stat-item__label">
            今日登录
          </text>
          <text class="stat-item__sub">
            {{ dashboardStats?.today_unique_users ?? 0 }} 独立用户
          </text>
        </view>
      </view>

      <!-- Pending ticket alert -->
      <view v-if="pendingTickets > 0" class="alert-bar btn-press fade-in-up-4" @click="navigateTo('work-tickets')">
        <view class="alert-bar__dot" />
        <text class="alert-bar__text">
          您有 {{ pendingTickets }} 个待处理工单，点击查看 →
        </text>
      </view>

      <!-- Recent notices -->
      <view v-if="recentNotices.length > 0" class="home-section">
        <view class="section-header">
          <text class="section-header__title">
            最新公告
          </text>
          <text class="section-header__more" @click="navigateTo('work-notices')">
            全部 →
          </text>
        </view>
        <view class="home-card">
          <wd-cell-group border>
            <wd-cell v-for="item in recentNotices" :key="item.id" :title="item.notice_title" is-link @click="navigateTo('work-notices')">
              <template #label>
                <text class="home-cell__time">
                  {{ item.created_time || '' }}
                </text>
              </template>
            </wd-cell>
          </wd-cell-group>
        </view>
      </view>

      <!-- Recent logins -->
      <view v-if="dashboardStats?.recent_logins?.length" class="home-section">
        <view class="section-header">
          <text class="section-header__title">
            最近登录
          </text>
        </view>
        <view class="home-card">
          <wd-cell-group border>
            <wd-cell v-for="(item, i) in dashboardStats.recent_logins" :key="i" :title="item.username">
              <template #label>
                <text class="home-cell__time">
                  {{ item.login_time || '' }}{{ item.login_ip ? ` · ${item.login_ip}` : '' }}
                </text>
              </template>
              <StatusBadge :status="item.status === 1 ? 'success' : 'failed'" />
            </wd-cell>
          </wd-cell-group>
        </view>
      </view>
    </template>

    <!-- Bottom safe area -->
    <view style="height: 100rpx;" />
  </view>
</template>

<style lang="scss" scoped>
.home-page {
  padding: 0 32rpx;
  padding-bottom: calc(120rpx + env(safe-area-inset-bottom));
  background: var(--page-bg-color, #F9F9F9);
  min-height: 100vh;
}

/* ===== Navigation ===== */
.home-nav {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16rpx 0 24rpx;

  &__title {
    font-size: var(--font-2xl, 40rpx);
    font-weight: 600;
    color: var(--text-color, #0A1628);
  }

  &__bell {
    position: relative;
    width: 72rpx;
    height: 72rpx;
    border-radius: 50%;
    background: var(--bg-color-2, #F5F6F8);
    display: flex;
    align-items: center;
    justify-content: center;

    &-icon { font-size: var(--font-lg, 32rpx); }
  }

  &__badge {
    position: absolute;
    top: 14rpx;
    right: 14rpx;
    width: 16rpx;
    height: 16rpx;
    border-radius: 50%;
    background: var(--danger-color, #EF4444);
    border: 2rpx solid var(--bg-color, #FFFFFF);
  }
}

/* ===== Greeting ===== */
.greeting-card {
  background: var(--gradient-primary, linear-gradient(135deg, #4F8CFF, #2563EB));
  border-radius: 32rpx;
  padding: 40rpx 32rpx;
  margin-bottom: 32rpx;
  box-shadow: var(--shadow-lg, 0 12rpx 40rpx rgba(1, 77, 178, 0.15));

  &__text {
    display: block;
    font-size: var(--font-2xl, 40rpx);
    font-weight: 600;
    color: #FFFFFF;
    margin-bottom: 8rpx;
  }

  &__date {
    font-size: var(--font-sm, 24rpx);
    color: rgba(255, 255, 255, 0.80);
  }
}

/* ===== Dashboard entry ===== */
.dashboard-entry {
  display: flex;
  align-items: center;
  gap: 20rpx;
  background: linear-gradient(135deg, #F0F5FF, #E8F0FE);
  border: 2rpx solid rgba(1, 77, 178, 0.08);
  border-radius: 24rpx;
  padding: 28rpx;
  margin-bottom: 32rpx;
  transition: all 0.15s ease;

  &__icon {
    width: 80rpx;
    height: 80rpx;
    border-radius: 20rpx;
    background: linear-gradient(135deg, var(--primary-color, #4F8CFF), var(--primary-color-dark, #2970FF));
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;

    &-text { font-size: var(--font-xl, 36rpx); }
  }

  &__info {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 4rpx;
  }

  &__title {
    font-size: var(--font-lg, 32rpx);
    font-weight: 600;
    color: var(--text-color, #0A1628);
  }

  &__sub {
    font-size: var(--font-sm, 24rpx);
    color: var(--text-color-3, #6B7280);
  }

  &__arrow {
    font-size: var(--font-2xl, 40rpx);
    font-weight: 300;
    color: var(--primary-color, #4F8CFF);
    font-family: 'Inter', -apple-system, sans-serif;
  }
}

/* ===== Quick nav grid ===== */
.home-grid {
  &--nav {
    background: var(--card-bg-color, #FFFFFF);
    border-radius: 24rpx;
    padding: 16rpx 0;
    margin-bottom: 32rpx;
    box-shadow: var(--shadow-xs, 0 3rpx 8rpx rgba(1, 77, 178, 0.03));
  }

  &__label {
    font-size: var(--font-sm, 24rpx);
    color: var(--text-color-3, #6B7280);
  }
}

.home-nav-icon { width: 64rpx; height: 64rpx; border-radius: 12rpx; }

/* ===== Section header ===== */
.section-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 24rpx;

  &__title {
    font-size: var(--font-lg, 32rpx);
    font-weight: 600;
    color: var(--text-color, #0A1628);
  }

  &__more {
    font-size: var(--font-sm, 24rpx);
    color: var(--primary-color, #4F8CFF);
  }
}

/* ===== Stats row ===== */
.stats-row {
  display: flex;
  gap: 24rpx;
  margin-bottom: 24rpx;
}

.stat-item {
  flex: 1;
  background: var(--card-bg-color, #FFFFFF);
  border-radius: 24rpx;
  padding: 24rpx;
  box-shadow: var(--shadow-xs, 0 3rpx 8rpx rgba(79, 140, 255, 0.03));
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  transition: transform var(--transition-fast), box-shadow var(--transition-fast);

  &__value {
    font-size: var(--font-3xl, 48rpx);
    font-weight: 600;
    font-family: 'Inter', -apple-system, sans-serif;
    margin-bottom: 8rpx;

    &--primary { color: var(--primary-color, #4F8CFF); }
    &--success { color: var(--success-color, #10B981); }
    &--warning { color: var(--warning-color, #F59E0B); }
  }

  &__label {
    font-size: var(--font-sm, 24rpx);
    color: var(--text-color-3, #6B7280);
    margin-bottom: 4rpx;
  }

  &__sub {
    font-size: var(--font-xs, 20rpx);
    color: var(--text-color-4, #B0B0B0);
  }
}

/* ===== Alert bar ===== */
.alert-bar {
  display: flex;
  align-items: center;
  gap: 16rpx;
  background: var(--warning-color-light, #FFF8E6);
  border-radius: 24rpx;
  padding: 24rpx;
  margin-bottom: 32rpx;

  &__dot {
    width: 12rpx;
    height: 12rpx;
    border-radius: 50%;
    background: var(--warning-color, #F59E0B);
    flex-shrink: 0;
  }

  &__text {
    font-size: var(--font-md, 28rpx);
    color: var(--warning-color, #F59E0B);
  }
}

/* ===== Home card ===== */
.home-section {
  margin-bottom: 32rpx;
}

.home-card {
  background: var(--card-bg-color, #FFFFFF);
  border-radius: 24rpx;
  box-shadow: var(--shadow-xs, 0 3rpx 8rpx rgba(1, 77, 178, 0.03));
  overflow: hidden;
}

/* ===== Home cell time ===== */
.home-cell__time {
  font-size: var(--font-sm, 24rpx);
  color: var(--text-color-4, #B0B0B0);
}
</style>
