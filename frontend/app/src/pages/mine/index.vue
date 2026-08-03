<script lang="ts" setup>
import { TicketAPI } from '@/api/module_system/ticket'
import { useGlobalDialog } from '@/composables/useGlobalDialog'
import { useUserStore } from '@/store/userStore'

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

const globalDialog = useGlobalDialog()

function handleLogout() {
  globalDialog.confirm({
    title: '提示',
    msg: '确认退出登录吗？',
    confirmButtonText: '退出',
    success: (res) => {
      if (res.action === 'confirm')
        userStore.logout()
    },
  })
}

/** 通知开关（演示 wd-switch 使用） */
const notifyEnabled = ref(false)

/** 工单统计（真实数据：待处理 / 处理中 / 已完成） */
const pendingTickets = ref<number | null>(null)
const processingTickets = ref<number | null>(null)
const doneTickets = ref<number | null>(null)

async function loadTicketStats() {
  const [pending, processing, done] = await Promise.allSettled([
    TicketAPI.getPage({ page_no: 1, page_size: 1, status: '0' }),
    TicketAPI.getPage({ page_no: 1, page_size: 1, status: '1' }),
    TicketAPI.getPage({ page_no: 1, page_size: 1, status: '2' }),
  ])
  if (pending.status === 'fulfilled')
    pendingTickets.value = pending.value.total || 0
  if (processing.status === 'fulfilled')
    processingTickets.value = processing.value.total || 0
  if (done.status === 'fulfilled')
    doneTickets.value = done.value.total || 0
}

onShow(() => {
  const pages = getCurrentPages()
  if (pages.length > 0 && pages[pages.length - 1].route === 'pages/mine/index') {
    uni.$emit('updateTabbar', 'mine')
    loadTicketStats()
  }
})

const settingsList = [
  { title: '个人资料', name: 'profile' },
  { title: '修改密码', name: 'account' },
  { title: '关于我们', name: 'about' },
]

const quickLinks = [
  { title: '用户管理', name: 'work-users', icon: 'user', color: '#4F8CFF' },
  { title: '角色管理', name: 'work-roles', icon: 'lock', color: '#F59E0B' },
  { title: '部门管理', name: 'work-depts', icon: 'apps', color: '#10B981' },
  { title: '菜单管理', name: 'work-menus', icon: 'menu', color: '#8B5CF6' },
  { title: '岗位管理', name: 'work-positions', icon: 'list', color: '#4F8CFF' },
  { title: '字典管理', name: 'work-dicts', icon: 'tags', color: '#F59E0B' },
  { title: '通知公告', name: 'work-notices', icon: 'notification', color: '#10B981' },
  { title: '参数管理', name: 'work-params', icon: 'settings', color: '#8B5CF6' },
  { title: 'AI 模型', name: 'work-ai-models', icon: 'robot', color: '#8B5CF6' },
]
</script>

<template>
  <view class="box-border min-h-screen py-3">
    <!-- 用户信息卡 -->
    <view class="mx-3 mb-3 flex items-center gap-4 rounded-3 px-5 py-6 wot-bg-filled-oppo">
      <wd-badge is-dot>
        <wd-avatar
          size="64px"
          round
          :text="(userInfo?.name || '管').charAt(0)"
          bg-color="#4F8CFF"
          color="#FFFFFF"
        />
      </wd-badge>
      <view class="min-w-0 flex-1">
        <view class="text-4 font-bold wot-text-text-main">
          {{ userInfo?.name || '管理员' }}
        </view>
        <view class="mt-1 truncate text-3 wot-text-text-secondary">
          {{ userInfo?.roles?.map(r => r.name).join(', ') || '超级管理员 · 技术部' }}
        </view>
      </view>
      <!-- 设置入口（纯 icon，打开设置页：内含主题设置） -->
      <view
        class="h-9 w-9 flex shrink-0 items-center justify-center rounded-full active:opacity-70"
        hover-class="wot-bg-bg"
        @click="navigateTo('setting')"
      >
        <wd-icon name="settings" size="20px" custom-class="wot-text-text-secondary" />
      </view>
    </view>

    <!-- 工单统计 -->
    <view class="mx-3 mb-3">
      <wd-row :gutter="12">
        <wd-col :span="8">
          <view class="rounded-2 p-4 text-center wot-bg-filled-oppo active:opacity-70" @click="navigateTo('work-tickets')">
            <view class="text-5 font-bold" style="color: var(--warning-color, #F59E0B);">
              {{ pendingTickets ?? '-' }}
            </view>
            <view class="mt-1 text-3 wot-text-text-secondary">
              待处理工单
            </view>
          </view>
        </wd-col>
        <wd-col :span="8">
          <view class="rounded-2 p-4 text-center wot-bg-filled-oppo active:opacity-70" @click="navigateTo('work-tickets')">
            <view class="text-5 font-bold" style="color: var(--primary-color, #4F8CFF);">
              {{ processingTickets ?? '-' }}
            </view>
            <view class="mt-1 text-3 wot-text-text-secondary">
              处理中工单
            </view>
          </view>
        </wd-col>
        <wd-col :span="8">
          <view class="rounded-2 p-4 text-center wot-bg-filled-oppo active:opacity-70" @click="navigateTo('work-tickets')">
            <view class="text-5 font-bold" style="color: var(--success-color, #10B981);">
              {{ doneTickets ?? '-' }}
            </view>
            <view class="mt-1 text-3 wot-text-text-secondary">
              已完成工单
            </view>
          </view>
        </wd-col>
      </wd-row>
    </view>

    <!-- 快捷入口 -->
    <view class="mx-3 mb-3 rounded-2 p-2 wot-bg-filled-oppo">
      <wd-grid :column="3" :border="false" clickable>
        <wd-grid-item
          v-for="item in quickLinks"
          :key="item.name"
          @click="navigateTo(item.name)"
        >
          <view
            class="h-11 w-11 flex items-center justify-center rounded-xl"
            :style="{ backgroundColor: `${item.color}1a` }"
          >
            <wd-icon :name="item.icon" size="20px" :color="item.color" />
          </view>
          <view class="mt-1 text-2.5 wot-text-text-secondary">
            {{ item.title }}
          </view>
        </wd-grid-item>
      </wd-grid>
    </view>

    <!-- 设置列表 -->
    <view class="mx-3 mb-3">
      <view class="mb-2 mt-1 flex items-center gap-2 px-3">
        <view class="h-3.5 w-1 rounded-full" style="background-color: var(--primary-color, #4F8CFF);" />
        <text class="text-3.5 font-bold wot-text-text-main">
          设置
        </text>
      </view>
      <wd-cell-group border custom-class="rounded-2! overflow-hidden">
        <wd-cell
          v-for="item in settingsList"
          :key="item.name"
          :title="item.title"
          is-link
          @click="navigateTo(item.name)"
        />
        <wd-cell title="通知设置" :is-link="false">
          <wd-switch v-model="notifyEnabled" size="22px" />
        </wd-cell>
      </wd-cell-group>
    </view>

    <!-- 退出登录 -->
    <view class="mx-3">
      <wd-button type="danger" plain round block @click="handleLogout">
        退出登录
      </wd-button>
    </view>

    <!-- Bottom safe area -->
    <wd-gap height="100rpx" safe-area-bottom />
  </view>
</template>
