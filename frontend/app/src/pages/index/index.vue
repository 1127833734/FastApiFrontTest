<script setup lang="ts">
import type { SwiperItem } from '@wot-ui/ui/components/wd-swiper/types'
import type { DashboardStats } from '@/api/module_monitor/dashboard'
import type { NoticeItem } from '@/api/module_system/notice'
import { onPullDownRefresh, onReady, onShow } from '@dcloudio/uni-app'
import { computed, ref } from 'vue'
import { DashboardAPI } from '@/api/module_monitor/dashboard'
import { NoticeAPI } from '@/api/module_system/notice'
import { TicketAPI } from '@/api/module_system/ticket'
import { useUserStore } from '@/store/userStore'

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
  }
  return _router
}

const loading = ref(false)
const dashboardStats = ref<DashboardStats | null>(null)
const pendingTickets = ref(0)
const recentNotices = ref<NoticeItem[]>([])
const userStore = useUserStore()

const NAV_LIST = [
  { icon: '/static/icons/user.svg', title: '用户管理', name: 'work-users', color: '#4F8CFF', bg: 'rgba(79, 140, 255, 0.12)' },
  { icon: '/static/icons/role.svg', title: '角色管理', name: 'work-roles', color: '#F59E0B', bg: 'rgba(245, 158, 11, 0.14)' },
  { icon: '/static/icons/notice.svg', title: '通知公告', name: 'work-notices', color: '#10B981', bg: 'rgba(16, 185, 129, 0.12)' },
  { icon: '/static/icons/setting.svg', title: '系统配置', name: 'work-params', color: '#8B5CF6', bg: 'rgba(139, 92, 246, 0.12)' },
]

/** 轮播 Banner 条目 */
interface BannerItem extends SwiperItem {
  key: string
  tag: string
  cls: string
  title: string
  subtitle: string
  desc: string
  cta: string
  onClick: () => void
}

/**
 * 顶部轮播 Banner（轮播图风格首页核心）：
 * 1. 今日问候  2. 待办工单  3. 数据概览
 */
const banners = computed<BannerItem[]>(() => [
  {
    key: 'greet',
    tag: '今日',
    cls: 'banner-slide--greet',
    title: `${getGreeting()}，${userStore.userInfo?.name || '管理员'}`,
    subtitle: getDateString(),
    desc: '欢迎回来，开启高效的一天',
    cta: '数据概览',
    onClick: () => navigateTo('dashboard'),
  },
  {
    key: 'ticket',
    tag: '待办',
    cls: pendingTickets.value > 0 ? 'banner-slide--ticket' : 'banner-slide--ticket-empty',
    title: pendingTickets.value > 0 ? `${pendingTickets.value} 个待处理工单` : '工单已全部处理',
    subtitle: pendingTickets.value > 0 ? '点击立即处理，避免影响业务' : '处理及时，继续保持',
    desc: '点击进入工单列表',
    cta: pendingTickets.value > 0 ? '去处理' : '查看工单',
    onClick: () => navigateTo('work-tickets'),
  },
  {
    key: 'stats',
    tag: '数据',
    cls: 'banner-slide--stats',
    title: '数据概览',
    subtitle: '系统运行状态与趋势分析',
    desc: `总用户 ${dashboardStats.value?.total_users ?? '-'} · 在线 ${dashboardStats.value?.online_users ?? '-'} · 今日登录 ${dashboardStats.value?.today_login_count ?? '-'}`,
    cta: '查看详情',
    onClick: () => navigateTo('dashboard'),
  },
])

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
    <!-- 顶部导航 -->
    <view class="home-nav">
      <text class="home-nav__title">
        工作台概览
      </text>
      <view class="home-nav__bell" @click="navigateTo('work-notices')">
        <wd-icon name="notification" size="18px" color="var(--text-color-2)" />
        <view v-if="pendingTickets > 0" class="home-nav__badge" />
      </view>
    </view>

    <!-- 轮播 Banner -->
    <view class="home-banner fade-in-up">
      <wd-swiper
        :list="banners"
        height="340"
        radius="28"
        :interval="4500"
        :autoplay="true"
        :loop="true"
      >
        <template #default="{ index }">
          <view class="banner-slide" :class="banners[index].cls" @click="banners[index].onClick">
            <view class="banner-slide__body">
              <text class="banner-slide__tag">
                {{ banners[index].tag }}
              </text>
              <text class="banner-slide__title">
                {{ banners[index].title }}
              </text>
              <text class="banner-slide__subtitle">
                {{ banners[index].subtitle }}
              </text>
              <text class="banner-slide__desc">
                {{ banners[index].desc }}
              </text>
            </view>
            <view class="banner-slide__cta">
              <text class="banner-slide__cta-text">
                {{ banners[index].cta }}
              </text>
              <text class="banner-slide__cta-arrow">
                ›
              </text>
            </view>
          </view>
        </template>
        <template #indicator="{ current, total }">
          <view class="banner-dots">
            <view
              v-for="i in total"
              :key="i"
              class="banner-dots__dot"
              :class="{ 'is-active': i === current + 1 }"
            />
          </view>
        </template>
      </wd-swiper>
    </view>

    <!-- 快捷入口 -->
    <view class="home-grid fade-in-up-1">
      <wd-grid :column="4">
        <wd-grid-item v-for="item in NAV_LIST" :key="item.name" @click="navigateTo(item.name)">
          <view class="nav-item__icon" :style="{ background: item.bg }">
            <view
              class="nav-item__svg"
              :style="{
                backgroundColor: item.color,
                maskImage: `url(${item.icon})`,
                WebkitMaskImage: `url(${item.icon})`,
              }"
            />
          </view>
          <text class="home-grid__label">
            {{ item.title }}
          </text>
        </wd-grid-item>
      </wd-grid>
    </view>

    <!-- 运营概览 -->
    <view class="section-header fade-in-up-2">
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

      <!-- 最新公告 -->
      <view v-if="recentNotices.length > 0" class="home-section fade-in-up-3">
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

      <!-- 最近登录 -->
      <view v-if="dashboardStats?.recent_logins?.length" class="home-section fade-in-up-4">
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

/* ===== 顶部导航 ===== */
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

    &:active { opacity: 0.7; }
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

/* ===== 轮播 Banner ===== */
.home-banner {
  margin-bottom: 32rpx;
}

.banner-slide {
  position: relative;
  height: 340rpx;
  padding: 36rpx 40rpx;
  border-radius: 28rpx;
  display: flex;
  align-items: center;
  justify-content: space-between;
  color: #FFFFFF;
  overflow: hidden;

  /* 装饰圆环 */
  &::before {
    content: '';
    position: absolute;
    right: -80rpx;
    top: -80rpx;
    width: 300rpx;
    height: 300rpx;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.10);
  }

  &::after {
    content: '';
    position: absolute;
    right: 40rpx;
    bottom: -120rpx;
    width: 240rpx;
    height: 240rpx;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.08);
  }

  &--greet { background: linear-gradient(135deg, #4F8CFF, #2563EB); }
  &--ticket { background: linear-gradient(135deg, #F59E0B, #D97706); }
  &--ticket-empty { background: linear-gradient(135deg, #10B981, #059669); }
  &--stats { background: linear-gradient(135deg, #8B5CF6, #6D28D9); }

  &__body {
    position: relative;
    z-index: 1;
    display: flex;
    flex-direction: column;
    flex: 1;
    min-width: 0;
  }

  &__tag {
    align-self: flex-start;
    font-size: var(--font-xs, 20rpx);
    line-height: 1;
    padding: 8rpx 16rpx;
    border-radius: var(--radius-full, 9999rpx);
    background: rgba(255, 255, 255, 0.22);
    margin-bottom: 20rpx;
  }

  &__title {
    font-size: var(--font-2xl, 40rpx);
    font-weight: 700;
    line-height: 1.3;
    margin-bottom: 8rpx;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  &__subtitle {
    font-size: var(--font-sm, 24rpx);
    color: rgba(255, 255, 255, 0.88);
    margin-bottom: 8rpx;
  }

  &__desc {
    font-size: var(--font-xs, 20rpx);
    color: rgba(255, 255, 255, 0.68);
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  &__cta {
    position: relative;
    z-index: 1;
    flex-shrink: 0;
    margin-left: 24rpx;
    display: flex;
    align-items: center;
    gap: 8rpx;
    padding: 16rpx 24rpx;
    border-radius: var(--radius-full, 9999rpx);
    background: rgba(255, 255, 255, 0.22);
    border: 2rpx solid rgba(255, 255, 255, 0.35);

    &-text {
      font-size: var(--font-sm, 24rpx);
      font-weight: 500;
      color: #FFFFFF;
      white-space: nowrap;
    }

    &-arrow {
      font-size: var(--font-md, 28rpx);
      font-weight: 400;
      color: #FFFFFF;
      line-height: 1;
    }
  }
}

.banner-dots {
  position: absolute;
  right: 24rpx;
  bottom: 16rpx;
  display: flex;
  align-items: center;
  gap: 8rpx;

  &__dot {
    width: 10rpx;
    height: 10rpx;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.45);
    transition: all 0.3s ease;

    &.is-active {
      width: 28rpx;
      border-radius: var(--radius-full, 9999rpx);
      background: #FFFFFF;
    }
  }
}

/* ===== 快捷入口 ===== */
.home-grid {
  background: var(--card-bg-color, #FFFFFF);
  border-radius: 24rpx;
  padding: 20rpx 0;
  margin-bottom: 32rpx;
  box-shadow: var(--shadow-xs, 0 3rpx 8rpx rgba(1, 77, 178, 0.03));

  &__label {
    font-size: var(--font-sm, 24rpx);
    color: var(--text-color-3, #6B7280);
  }
}

.nav-item__icon {
  width: 80rpx;
  height: 80rpx;
  border-radius: 20rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 12rpx;
}

/* SVG 图标：以 mask 蒙版取形，background-color 着色（currentColor 方案） */
.nav-item__svg {
  width: 40rpx;
  height: 40rpx;
  mask-repeat: no-repeat;
  mask-position: center;
  mask-size: contain;
  -webkit-mask-repeat: no-repeat;
  -webkit-mask-position: center;
  -webkit-mask-size: contain;
}

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
  margin-bottom: 32rpx;
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
