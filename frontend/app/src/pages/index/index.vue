<script setup lang="ts">
import type { SwiperItem } from '@wot-ui/ui/components/wd-swiper/types'
import type { DashboardStats } from '@/api/module_monitor/dashboard'
import type { NoticeItem } from '@/api/module_system/notice'
import { onPullDownRefresh, onReady, onShow } from '@dcloudio/uni-app'
import { BarChart, PieChart } from 'echarts/charts'
import { GridComponent, LegendComponent, TooltipComponent } from 'echarts/components'
import * as echarts from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { computed, ref } from 'vue'
import { DashboardAPI } from '@/api/module_monitor/dashboard'
import { NoticeAPI } from '@/api/module_system/notice'
import { TicketAPI } from '@/api/module_system/ticket'
import { useUserStore } from '@/store/userStore'

echarts.use([
  GridComponent,
  LegendComponent,
  TooltipComponent,
  BarChart,
  PieChart,
  CanvasRenderer,
])

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
/** 页面滚动距离（供 wd-backtop 判断显示） */
const scrollTop = ref(0)
onPageScroll((e) => {
  scrollTop.value = e.scrollTop
})

const NAV_LIST = [
  { icon: 'user', title: '用户管理', name: 'work-users', color: '#4F8CFF' },
  { icon: 'lock', title: '角色管理', name: 'work-roles', color: '#F59E0B' },
  { icon: 'notification', title: '通知公告', name: 'work-notices', color: '#10B981' },
  { icon: 'settings', title: '系统配置', name: 'work-params', color: '#8B5CF6' },
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

/** 运营概览图表：在线占比环形图（真实数据，未加载时以 0 值占位） */
const onlineDonutOption = computed(() => {
  const s = dashboardStats.value
  const online = s?.online_users ?? 0
  const total = s?.total_users ?? 0
  return {
    tooltip: {
      trigger: 'item',
      formatter: '{b}: {c} ({d}%)',
      textStyle: { fontSize: 12 },
    },
    legend: { show: false },
    series: [{
      type: 'pie',
      radius: ['58%', '82%'],
      center: ['50%', '50%'],
      avoidLabelOverlap: false,
      label: { show: false },
      emphasis: { scale: false },
      data: [
        { value: online, name: '在线用户', itemStyle: { color: '#4F8CFF' } },
        { value: Math.max(total - online, 0), name: '离线用户', itemStyle: { color: 'rgba(79, 140, 255, 0.14)' } },
      ],
    }],
  }
})

/** 运营概览图表：今日数据柱状图（真实数据，未加载时以 0 值占位） */
const todayBarOption = computed(() => {
  const s = dashboardStats.value
  return {
    tooltip: {
      trigger: 'axis',
      axisPointer: { type: 'shadow' },
      textStyle: { fontSize: 12 },
    },
    grid: { left: 4, right: 4, top: 18, bottom: 0, containLabel: true },
    xAxis: {
      type: 'category',
      data: ['今日登录', '本周新增', '独立用户'],
      axisLine: { show: false },
      axisTick: { show: false },
      axisLabel: { fontSize: 10, color: '#999' },
    },
    yAxis: { type: 'value', show: false },
    series: [{
      type: 'bar',
      barWidth: 14,
      data: [
        { value: s?.today_login_count ?? 0, itemStyle: { color: '#4F8CFF', borderRadius: [6, 6, 0, 0] } },
        { value: s?.week_user_created ?? 0, itemStyle: { color: '#10B981', borderRadius: [6, 6, 0, 0] } },
        { value: s?.today_unique_users ?? 0, itemStyle: { color: '#F59E0B', borderRadius: [6, 6, 0, 0] } },
      ],
    }],
  }
})

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
  <view class="box-border min-h-screen">
    <!-- 顶部通知栏 -->
    <wd-notice-bar
      text="这是一条消息提示信息，这是一条消息提示信息，这是一条消息提示信息"
      closable
      type="warning"
      prefix="notification"
      class="mb-3"
    />

    <!-- 轮播 Banner -->
    <view class="mx-3 mb-3">
      <wd-swiper
        :list="banners"
        height="100"
        radius="14"
        :interval="4500"
        :autoplay="true"
        :loop="true"
      >
        <template #default="{ index }">
          <view class="banner-slide" :class="banners[index].cls" @click="banners[index].onClick">
            <view class="banner-slide__body">
              <view class="banner-slide__tag">
                <wd-tag size="small" round bg-color="rgba(255, 255, 255, 0.22)" color="#FFFFFF">
                  {{ banners[index].tag }}
                </wd-tag>
              </view>
              <view class="banner-slide__title">
                {{ banners[index].title }}
              </view>
              <view class="banner-slide__subtitle">
                {{ banners[index].subtitle }}
              </view>
              <view class="banner-slide__desc">
                {{ banners[index].desc }}
              </view>
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
    <view class="mx-3 mb-3 rounded-2 p-2 wot-bg-filled-oppo">
      <wd-grid :column="4" :border="false" clickable>
        <wd-grid-item
          v-for="item in NAV_LIST"
          :key="item.name"
          @click="navigateTo(item.name)"
        >
          <view class="w-full flex flex-col items-center">
            <view
              class="h-11 w-11 flex items-center justify-center rounded-xl"
              :style="{ backgroundColor: `${item.color}1a` }"
            >
              <wd-icon :name="item.icon" size="20px" :color="item.color" />
            </view>
            <view class="mt-1 w-full text-center text-2.5 wot-text-text-secondary">
              {{ item.title }}
            </view>
          </view>
        </wd-grid-item>
      </wd-grid>
    </view>

    <!-- 运营概览 -->
    <view class="mb-2 mt-4 flex items-center gap-2 px-3">
      <view class="h-3.5 w-1 rounded-full" style="background-color: var(--primary-color, #4F8CFF);" />
      <text class="text-3.5 font-bold wot-text-text-main">
        运营概览
      </text>
    </view>
    <SkeletonPage v-if="loading && !dashboardStats" :rows="3" />
    <view v-else class="mx-3">
      <wd-row :gutter="12">
        <wd-col :span="8">
          <view class="rounded-2 p-4 text-center wot-bg-filled-oppo">
            <wd-count-to v-if="dashboardStats?.total_users != null" :end-val="dashboardStats.total_users" type="primary" custom-class="stat-count" />
            <view v-else class="text-5 font-bold wot-text-text-main">
              -
            </view>
            <view class="mt-1 text-3 wot-text-text-secondary">
              注册用户
            </view>
            <view class="mt-0.5 text-2.5 wot-text-text-auxiliary">
              本周新增 {{ dashboardStats?.week_user_created ?? 0 }}
            </view>
          </view>
        </wd-col>
        <wd-col :span="8">
          <view class="rounded-2 p-4 text-center wot-bg-filled-oppo">
            <wd-count-to v-if="dashboardStats?.online_users != null" :end-val="dashboardStats.online_users" type="success" custom-class="stat-count" />
            <view v-else class="text-5 font-bold wot-text-text-main">
              -
            </view>
            <view class="mt-1 text-3 wot-text-text-secondary">
              在线用户
            </view>
            <view class="mt-0.5 text-2.5 wot-text-text-auxiliary">
              当前在线
            </view>
          </view>
        </wd-col>
        <wd-col :span="8">
          <view class="rounded-2 p-4 text-center wot-bg-filled-oppo">
            <wd-count-to v-if="dashboardStats?.today_login_count != null" :end-val="dashboardStats.today_login_count" type="warning" custom-class="stat-count" />
            <view v-else class="text-5 font-bold wot-text-text-main">
              -
            </view>
            <view class="mt-1 text-3 wot-text-text-secondary">
              今日登录
            </view>
            <view class="mt-0.5 text-2.5 wot-text-text-auxiliary">
              {{ dashboardStats?.today_unique_users ?? 0 }} 独立用户
            </view>
          </view>
        </wd-col>
      </wd-row>
    </view>

    <!-- 运营图表（未加载数据时以 0 值占位渲染） -->
    <view class="grid grid-cols-2 mx-3 mt-3 gap-3">
      <view class="rounded-2 p-3 wot-bg-filled-oppo">
        <view class="mb-1 text-center text-3 font-bold wot-text-text-main">
          在线占比
        </view>
        <uni-echarts custom-class="h-44 w-full" :option="onlineDonutOption" />
      </view>
      <view class="rounded-2 p-3 wot-bg-filled-oppo">
        <view class="mb-1 text-center text-3 font-bold wot-text-text-main">
          今日数据
        </view>
        <uni-echarts custom-class="h-44 w-full" :option="todayBarOption" />
      </view>
    </view>

    <!-- 最新公告 -->
    <view v-if="recentNotices.length > 0" class="mb-2 mt-4 flex items-center justify-between px-3">
      <view class="flex items-center gap-2">
        <view class="h-3.5 w-1 rounded-full" style="background-color: var(--success-color, #10B981);" />
        <text class="text-3.5 font-bold wot-text-text-main">
          最新公告
        </text>
      </view>
      <text class="text-3 wot-text-primary" @click="navigateTo('work-notices')">
        全部
      </text>
    </view>
    <view v-if="recentNotices.length > 0" class="mx-3">
      <wd-cell-group border custom-class="rounded-2! overflow-hidden">
        <wd-cell
          v-for="item in recentNotices"
          :key="item.id"
          :title="item.notice_title"
          is-link
          @click="navigateTo('work-notices')"
        >
          <template #label>
            <text class="text-2.5 wot-text-text-auxiliary">
              {{ item.created_time || '' }}
            </text>
          </template>
        </wd-cell>
      </wd-cell-group>
    </view>

    <!-- 最近登录 -->
    <view v-if="dashboardStats?.recent_logins?.length" class="mb-2 mt-4 flex items-center gap-2 px-3">
      <view class="h-3.5 w-1 rounded-full" style="background-color: var(--warning-color, #F59E0B);" />
      <text class="text-3.5 font-bold wot-text-text-main">
        最近登录
      </text>
    </view>
    <view v-if="dashboardStats?.recent_logins?.length" class="mx-3">
      <wd-cell-group border custom-class="rounded-2! overflow-hidden">
        <wd-cell
          v-for="(item, i) in dashboardStats.recent_logins"
          :key="i"
          :title="item.username"
        >
          <template #label>
            <text class="text-2.5 wot-text-text-auxiliary">
              {{ item.login_time || '' }}{{ item.login_ip ? ` · ${item.login_ip}` : '' }}
            </text>
          </template>
          <template #value>
            <StatusBadge :status="item.status === 1 ? 'success' : 'failed'" />
          </template>
        </wd-cell>
      </wd-cell-group>
    </view>

    <!-- Bottom safe area -->
    <wd-gap height="100rpx" safe-area-bottom />
    <wd-backtop :scroll-top="scrollTop" :top="80" />
  </view>
</template>

<style lang="scss" scoped>
/* ===== 轮播 Banner（渐变装饰 + 文字布局，其余布局全部走 UnoCSS 原子类） ===== */
.banner-slide {
  position: relative;
  width: 100%;
  height: 100%;
  padding: 36rpx 40rpx;
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
    margin-bottom: 20rpx;
  }

  &__title {
    font-size: 40rpx;
    font-weight: 700;
    line-height: 1.3;
    margin-bottom: 8rpx;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  &__subtitle {
    font-size: 24rpx;
    color: rgba(255, 255, 255, 0.88);
    margin-bottom: 8rpx;
  }

  &__desc {
    font-size: 20rpx;
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
    border-radius: 9999rpx;
    background: rgba(255, 255, 255, 0.22);
    border: 2rpx solid rgba(255, 255, 255, 0.35);

    &-text {
      font-size: 24rpx;
      font-weight: 500;
      color: #FFFFFF;
      white-space: nowrap;
    }

    &-arrow {
      font-size: 28rpx;
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
      border-radius: 9999rpx;
      background: #FFFFFF;
    }
  }
}

/* wd-count-to 数字统一字号 */
:deep(.stat-count) {
  font-size: 40rpx;
  font-weight: 700;
}
</style>
