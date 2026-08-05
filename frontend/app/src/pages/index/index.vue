<script setup lang="ts">
import type { SwiperItem } from '@wot-ui/ui/components/wd-swiper/types'
import type { DashboardStats, LoginTrendItem } from '@/api/module_monitor/dashboard'
import type { NoticeItem } from '@/api/module_system/notice'
import { onPullDownRefresh, onReady, onShow } from '@dcloudio/uni-app'
import { LineChart } from 'echarts/charts'
import { GridComponent, LegendComponent, TooltipComponent } from 'echarts/components'
import * as echarts from 'echarts/core'
import { LegacyGridContainLabel } from 'echarts/features'
import { CanvasRenderer } from 'echarts/renderers'
import { computed, ref } from 'vue'
import { DashboardAPI } from '@/api/module_monitor/dashboard'
import { NoticeAPI } from '@/api/module_system/notice'
import { TicketAPI } from '@/api/module_system/ticket'
import { useShare } from '@/composables/useShare'
import { useUserStore } from '@/store/userStore'

const userStore = useUserStore()

useShare(() => ({
  title: `${getGreeting()}！${userStore.userInfo?.name || '管理员'} 邀你使用 FastapiAdmin`,
  path: '/pages/index/index',
}))

echarts.use([
  GridComponent,
  LegendComponent,
  TooltipComponent,
  LegacyGridContainLabel,
  LineChart,
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

/** 最新公告标题（通知栏展示，无公告则隐藏通知栏） */
const latestNotice = computed(() => recentNotices.value[0]?.notice_title || '欢迎使用 FastapiAdmin')

/** 页面滚动距离（供 wd-backtop 判断显示） */
const scrollTop = ref(0)
onPageScroll((e) => {
  scrollTop.value = e.scrollTop
})

const NAV_LIST = [
  { icon: 'notification', title: '通知公告', name: 'work-notices', color: '#10B981' },
  { icon: 'message', title: '工单管理', name: 'work-tickets', color: '#F59E0B' },
  { icon: 'interaction', title: 'AI 助手', name: 'work-chat', color: '#06B6D4' },
  { icon: 'robot', title: 'AI 模型', name: 'work-ai-models', color: '#8B5CF6' },
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
    onClick: () => scrollToMonitor(),
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
    onClick: () => scrollToMonitor(),
  },
])

function navigateTo(name: string) {
  const r = getRouter()
  if (r)
    r.push({ name })
}

// ===== 系统监控（原数据概览 dashboard 合并） =====

/** 近7天登录趋势（后端 monitor/online/stats 返回，含今日） */
const loginTrend = ref<LoginTrendItem[]>([])

/** 登录趋势折线图（真实数据：登录次数 / 独立访客 / 新增用户） */
const loginTrendOption = computed(() => {
  const days = loginTrend.value.length > 0
    ? loginTrend.value.map(i => i.day.slice(5)) // 仅显示 MM-DD
    : []
  const logins = loginTrend.value.map(i => i.logins)
  const uniques = loginTrend.value.map(i => i.unique_users)
  const news = loginTrend.value.map(i => i.new_users)
  return {
    tooltip: {
      trigger: 'axis',
      textStyle: { fontSize: 12 },
    },
    legend: {
      top: 0,
      right: 0,
      itemWidth: 10,
      itemHeight: 10,
      itemGap: 8,
      textStyle: { fontSize: 10, color: '#909399' },
      data: ['登录次数', '独立访客', '新增用户'],
    },
    grid: { left: 8, right: 8, top: 34, bottom: 0, containLabel: true },
    xAxis: {
      type: 'category',
      boundaryGap: false,
      data: days,
      axisLine: { show: false },
      axisTick: { show: false },
      axisLabel: { fontSize: 10, color: '#999' },
    },
    yAxis: {
      type: 'value',
      axisLine: { show: false },
      axisTick: { show: false },
      axisLabel: { fontSize: 10, color: '#999' },
      splitLine: { lineStyle: { color: 'rgba(128, 128, 128, 0.12)', type: 'dashed' } },
    },
    series: [
      {
        name: '登录次数',
        type: 'line',
        smooth: true,
        symbol: 'circle',
        symbolSize: 5,
        data: logins,
        lineStyle: { width: 3, color: '#4F8CFF' },
        itemStyle: { color: '#4F8CFF' },
        areaStyle: {
          color: {
            type: 'linear',
            x: 0,
            y: 0,
            x2: 0,
            y2: 1,
            colorStops: [
              { offset: 0, color: 'rgba(79, 140, 255, 0.28)' },
              { offset: 1, color: 'rgba(79, 140, 255, 0.02)' },
            ],
          },
        },
      },
      {
        name: '独立访客',
        type: 'line',
        smooth: true,
        symbol: 'circle',
        symbolSize: 5,
        data: uniques,
        lineStyle: { width: 2.5, color: '#10B981' },
        itemStyle: { color: '#10B981' },
      },
      {
        name: '新增用户',
        type: 'line',
        smooth: true,
        symbol: 'circle',
        symbolSize: 5,
        data: news,
        lineStyle: { width: 2.5, color: '#F59E0B' },
        itemStyle: { color: '#F59E0B' },
      },
    ],
  }
})

/** 滚动定位到系统监控区块（dashboard 合并后无独立页面，Banner 点击改为页内定位） */
function scrollToMonitor() {
  const query = uni.createSelectorQuery()
  query.select('#monitor-section').boundingClientRect()
  query.exec((res) => {
    const rect = res[0] as UniApp.NodeInfo | null
    if (rect && typeof rect.top === 'number') {
      uni.pageScrollTo({
        scrollTop: Math.max(rect.top + scrollTop.value - 12, 0),
        duration: 300,
      })
    }
  })
}

async function loadData() {
  loading.value = true
  try {
    const [statsRes, ticketRes] = await Promise.allSettled([
      DashboardAPI.getStats(),
      TicketAPI.getPage({ page_no: 1, page_size: 1, status: '0' }),
    ])
    if (statsRes.status === 'fulfilled') {
      dashboardStats.value = statsRes.value
      loginTrend.value = statsRes.value.login_trend || []
    }
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
  <view class="page-wraper">
    <!-- 顶部通知栏：接入最新一条公告（无公告自动隐藏），点击进入公告列表 -->
    <wd-notice-bar
      :text="latestNotice"
      closable
      type="info"
      prefix="notification"
      custom-class="home-notice"
      class="mb-3"
      @click="navigateTo('work-notices')"
    />

    <!-- 轮播 Banner -->
    <view class="mx-3 mb-3">
      <wd-swiper
        :list="banners"
        height="120"
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

    <!-- 系统监控（原数据概览 dashboard 合并，Banner 点击可滚动到此区块） -->
    <view id="monitor-section" class="mt-4">
      <view class="mb-2 flex items-center gap-2 px-3">
        <view class="h-3.5 w-1 rounded-full" style="background-color: var(--danger-color, #EF4444);" />
        <text class="text-3.5 font-bold wot-text-text-main">
          系统监控
        </text>
      </view>

      <!-- 登录趋势折线图 -->
      <view class="mx-3 mb-3 rounded-2 p-4 wot-bg-filled-oppo">
        <view class="mb-4 flex items-center gap-2">
          <text class="text-3.5 font-bold wot-text-text-main">
            登录趋势 (近7天)
          </text>
        </view>
        <uni-echarts custom-class="h-52 w-full" :option="loginTrendOption" />
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

  /* 装饰圆环（极光浮动动效） */
  &::before {
    content: '';
    position: absolute;
    right: -80rpx;
    top: -80rpx;
    width: 300rpx;
    height: 300rpx;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.10);
    animation: banner-orbit 7s ease-in-out infinite;
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
    animation: banner-orbit 9s ease-in-out infinite reverse;
  }

  /* 极光呼吸：装饰圆环缓慢浮动，增强 Banner 层次感（transform 动画，真机性能友好） */
  @keyframes banner-orbit {
    0%, 100% { transform: translateY(0) scale(1); }
    50% { transform: translateY(-14rpx) scale(1.06); }
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

<style lang="scss">
/* 暗黑模式下首页通知栏底色改为半透明主色，避免默认深蓝色块 (#0A235C) 在暗色页面上过重；
   需要全局选择器，因为 .wot-theme-dark 挂在外层 wd-config-provider 根上 */
.wot-theme-dark .home-notice {
  --wot-notice-bar-info-bg: rgba(68, 128, 255, 0.12);
}
</style>
