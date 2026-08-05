<script lang="ts" setup>
import { useI18n } from 'vue-i18n'
import { useGlobalDialog } from '@/composables/useGlobalDialog'
import { getTicketStats } from '@/composables/useCachedRequest'
import { useShare } from '@/composables/useShare'
import { useSharePoster } from '@/composables/useSharePoster'
import { useUserStore } from '@/store/userStore'

useShare(() => ({
  title: `${userInfo.value?.name || '管理员'} 邀请你加入 FastapiAdmin`,
  path: '/pages/index/index',
}))

definePage({
  name: 'mine',
  layout: 'tabbar',
  style: { navigationBarTitleText: '我的' },
})

const router = useRouter()
const { t } = useI18n()
const userStore = useUserStore()
const userInfo = computed(() => userStore.userInfo)

function navigateTo(name: string) {
  router.push({ name })
}

const globalDialog = useGlobalDialog()

function handleLogout() {
  globalDialog.confirm({
    title: t('common.title'),
    msg: t('mine.logoutMsg'),
    confirmButtonText: t('mine.logoutConfirm'),
    success: (res) => {
      if (res.action === 'confirm')
        userStore.logout()
    },
  })
}

/** 工单统计（共享缓存，与 work 页面复用，30秒内不重复请求） */
const pendingTickets = ref<number | null>(null)
const processingTickets = ref<number | null>(null)
const doneTickets = ref<number | null>(null)

async function loadTicketStats() {
  try {
    const stats = await getTicketStats()
    pendingTickets.value = stats.pending
    processingTickets.value = stats.processing
    doneTickets.value = stats.done
  }
  catch { /* silent */ }
}

onShow(() => {
  const pages = getCurrentPages()
  if (pages.length > 0 && pages[pages.length - 1].route === 'pages/mine/index') {
    uni.$emit('updateTabbar', 'mine')
    loadTicketStats()
  }
})

const settingsList = [
  { titleKey: 'mine.profile', name: 'profile' },
  { titleKey: 'mine.changePassword', name: 'account' },
  { titleKey: 'mine.aboutUs', name: 'about' },
]

const quickLinks = [
  { title: '通知公告', name: 'work-notices', icon: 'notification', color: '#10B981' },
  { title: '工单管理', name: 'work-tickets', icon: 'message', color: '#F59E0B' },
  { title: 'AI 助手', name: 'work-chat', icon: 'interaction', color: '#06B6D4' },
  { title: 'AI 模型', name: 'work-ai-models', icon: 'robot', color: '#8B5CF6' },
]

/** 邀请海报（获客）：生成小程序码 → 预览 → 保存相册 */
const { generateQrCode, saveImageToAlbum } = useSharePoster()
const showPoster = ref(false)
const posterUrl = ref('')
const posterLoading = ref(false)

async function handleGeneratePoster() {
  // #ifdef MP-WEIXIN
  if (posterLoading.value)
    return
  posterLoading.value = true
  try {
    // 带参小程序码：scene 携带用户 ID（invite_xxx），扫码进入首页
    const scene = `invite_${userInfo.value?.id || 0}`
    const qr = await generateQrCode({ scene, page: 'pages/index/index' })
    if (!qr) {
      uni.showToast({ title: '生成失败，请稍后重试', icon: 'none' })
      return
    }
    posterUrl.value = qr
    showPoster.value = true
  }
  finally {
    posterLoading.value = false
  }
  // #endif

  // #ifndef MP-WEIXIN
  uni.showToast({ title: '请在微信小程序中使用', icon: 'none' })
  // #endif
}

/** 保存海报到相册（base64 → 临时文件 → 相册） */
async function handleSavePoster() {
  // #ifdef MP-WEIXIN
  if (!posterUrl.value)
    return
  try {
    uni.showLoading({ title: '保存中...' })
    // base64 data URI → 写入本地临时文件
    const base64 = posterUrl.value.replace(/^data:image\/\w+;base64,/, '')
    const fs = uni.getFileSystemManager()
    const filePath = `${wx.env.USER_DATA_PATH}/invite_qr_${Date.now()}.png`
    fs.writeFileSync(filePath, base64, 'base64')
    await saveImageToAlbum(filePath)
  }
  catch {
    uni.showToast({ title: '保存失败', icon: 'none' })
  }
  finally {
    uni.hideLoading()
  }
  // #endif
}
</script>

<template>
  <view class="page-wraper py-3">
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
        hover-class="none"
        @click="navigateTo('setting')"
      >
        <wd-icon name="settings" size="20px" custom-class="wot-text-text-secondary" />
      </view>
    </view>

    <!-- 邀请好友（获客入口：转发 / 邀请海报） -->
    <view class="mx-3 mb-3 flex items-center gap-3 rounded-2 p-4 wot-bg-filled-oppo">
      <view class="h-10 w-10 flex shrink-0 items-center justify-center rounded-xl" style="background-color: #4F8CFF1a;">
        <wd-icon name="share" size="20px" color="#4F8CFF" />
      </view>
      <view class="min-w-0 flex-1">
        <view class="text-3.5 font-bold wot-text-text-main">
          邀请好友
        </view>
        <view class="mt-0.5 truncate text-2.5 wot-text-text-auxiliary">
          分享小程序给同事，一起高效办公
        </view>
      </view>
      <!-- 微信原生转发按钮（useShare 已配置分享卡片） -->
      <button class="invite-share-btn" open-type="share" size="mini">
        立即邀请
      </button>
      <view class="flex shrink-0 flex-col items-center gap-1" @click="handleGeneratePoster">
        <view class="flex h-8 w-8 items-center justify-center rounded-lg" style="background-color: #10B9811a;">
          <wd-icon v-if="!posterLoading" name="picture" size="16px" color="#10B981" />
          <wd-loading v-else :size="16" />
        </view>
        <text class="text-2 wot-text-text-auxiliary">
          海报
        </text>
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
              {{ $t('mine.pendingTickets') }}
            </view>
          </view>
        </wd-col>
        <wd-col :span="8">
          <view class="rounded-2 p-4 text-center wot-bg-filled-oppo active:opacity-70" @click="navigateTo('work-tickets')">
            <view class="text-5 font-bold" style="color: var(--primary-color, #4F8CFF);">
              {{ processingTickets ?? '-' }}
            </view>
            <view class="mt-1 text-3 wot-text-text-secondary">
              {{ $t('mine.processingTickets') }}
            </view>
          </view>
        </wd-col>
        <wd-col :span="8">
          <view class="rounded-2 p-4 text-center wot-bg-filled-oppo active:opacity-70" @click="navigateTo('work-tickets')">
            <view class="text-5 font-bold" style="color: var(--success-color, #10B981);">
              {{ doneTickets ?? '-' }}
            </view>
            <view class="mt-1 text-3 wot-text-text-secondary">
              {{ $t('mine.doneTickets') }}
            </view>
          </view>
        </wd-col>
      </wd-row>
    </view>

    <!-- 快捷入口 -->
    <view class="mx-3 mb-3 rounded-2 p-2 wot-bg-filled-oppo">
      <wd-grid :column="4" :border="false" clickable>
        <wd-grid-item
          v-for="item in quickLinks.slice(0, 4)"
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
          {{ $t('mine.settings') }}
        </text>
      </view>
      <wd-cell-group border custom-class="rounded-2! overflow-hidden">
        <wd-cell
          v-for="item in settingsList"
          :key="item.name"
          :title="$t(item.titleKey)"
          is-link
          @click="navigateTo(item.name)"
        />
      </wd-cell-group>
    </view>

    <!-- 退出登录 -->
    <view class="mx-3">
      <wd-button type="danger" plain round block @click="handleLogout">
        {{ $t('mine.logout') }}
      </wd-button>
    </view>

    <!-- 邀请海报弹窗 -->
    <wd-popup v-model="showPoster" position="center" round custom-style="width: 80%; padding: 32rpx; text-align: center;">
      <view class="flex flex-col items-center">
        <view class="mb-2 text-4 font-bold wot-text-text-main">
          邀请海报
        </view>
        <view class="mb-4 text-2.5 wot-text-text-auxiliary">
          长按识别小程序码，或保存图片分享给好友
        </view>
        <image
          v-if="posterUrl"
          :src="posterUrl"
          mode="aspectFit"
          class="h-96 w-96 rounded-2"
          show-menu-by-longpress
        />
        <wd-button
          class="mt-6 w-full"
          type="primary"
          round
          @click="handleSavePoster"
        >
          保存到相册
        </wd-button>
      </view>
    </wd-popup>

    <!-- Bottom safe area -->
    <wd-gap height="100rpx" safe-area-bottom />
  </view>
</template>

<style lang="scss" scoped>
/* 微信原生转发按钮样式重置（button 默认边框/背景去除，视觉对齐 wd-button mini） */
.invite-share-btn {
  flex-shrink: 0;
  margin: 0;
  padding: 0 24rpx;
  height: 56rpx;
  line-height: 56rpx;
  font-size: 24rpx;
  color: #FFFFFF;
  background: linear-gradient(135deg, #4F8CFF, #2563EB);
  border-radius: 9999rpx;
  border: none;

  &::after {
    border: none;
  }
}
</style>
