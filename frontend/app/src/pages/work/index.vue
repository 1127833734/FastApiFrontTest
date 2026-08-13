<script setup lang="ts">
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { getTicketStats } from '@/composables/useCachedRequest'
import { useI18nNavTitle } from '@/composables/useI18nNavTitle'
import { useShare } from '@/composables/useShare'
import { useUserStore } from '@/store/userStore'

const { t } = useI18n()

useShare({
  title: t('work.shareTitle'),
  path: '/pages/work/index',
})

definePage({
  name: 'work',
  layout: 'tabbar',
  style: { navigationBarTitleText: '工作台' },
})
useI18nNavTitle('work.navTitle')

const router = useRouter()
const userStore = useUserStore()
const userInfo = computed(() => userStore.userInfo)
function navigateTo(name: string) {
  router.push({ name })
}

/** 工单统计（共享缓存，与 mine 页面复用，30秒内不重复请求） */
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
  if (pages.length > 0 && pages[pages.length - 1].route === 'pages/work/index') {
    uni.$emit('updateTabbar', 'work')
    loadTicketStats()
  }
})

const groups = [
  {
    titleKey: 'work.businessCenter',
    color: 'var(--brand-orange)',
    bg: 'var(--brand-orange-soft)',
    items: [
      { icon: 'notification', titleKey: 'common.nav.notices', name: 'work-notices' },
      { icon: 'message', titleKey: 'common.nav.tickets', name: 'work-tickets' },
    ],
  },
  {
    titleKey: 'work.devTools',
    color: 'var(--brand-purple)',
    bg: 'var(--brand-purple-soft)',
    items: [
      { icon: 'message', titleKey: 'common.nav.aiChat', name: 'work-chat' },
      { icon: 'robot', titleKey: 'common.nav.aiModels', name: 'work-ai-models' },
    ],
  },
]

/** 搜索关键词，本地过滤模块分组 */
const keyword = ref('')
const filteredGroups = computed(() => {
  const kw = keyword.value.trim().toLowerCase()
  if (!kw)
    return groups
  return groups
    .map(group => ({ ...group, items: group.items.filter(item => t(item.titleKey).toLowerCase().includes(kw)) }))
    .filter(group => group.items.length > 0)
})
</script>

<template>
  <view class="page-wraper py-3">
    <!-- 用户信息卡（品牌渐变 + 极光装饰圆环） -->
    <view class="work-user-card mx-3 mb-4 flex items-center gap-4 rounded-3 px-5 py-6">
      <wd-avatar
        size="64px"
        round
        :src="userInfo?.avatar || ''"
        icon="user"
      />
      <view class="min-w-0 flex-1">
        <view class="text-4 text-white font-bold">
          {{ userInfo?.name || t('work.nameFallback') }}
        </view>
        <view class="mt-1 truncate text-3" style="color: rgba(255, 255, 255, 0.75);">
          {{ userInfo?.roles?.map(r => r.name).join(', ') || t('work.roleFallback') }}
        </view>
      </view>
    </view>

    <!-- 模块搜索 -->
    <view class="mx-3 mb-4">
      <wd-search v-model="keyword" :placeholder="t('work.searchPlaceholder')" variant="light" hide-cancel />
    </view>

    <!-- 模块分组 -->
    <view v-for="(group, gi) in filteredGroups" :key="gi" class="mb-4">
      <view class="mb-2 mt-1 flex items-center gap-2 px-3">
        <view class="h-3.5 w-1 rounded-full" :style="{ backgroundColor: group.color }" />
        <wd-text class="text-3.5 wot-text-text-main" :text="t(group.titleKey)" bold />
        <wd-text class="text-2.5 wot-text-text-auxiliary" :text="group.items.length" />
      </view>
      <wd-cell-group border custom-class="mx-3 rounded-2! overflow-hidden">
        <wd-cell
          v-for="item in group.items"
          :key="item.name"
          center
          is-link
          @click="navigateTo(item.name)"
        >
          <template #title>
            <view class="flex items-center gap-2.5">
              <view
                class="h-8 w-8 flex shrink-0 items-center justify-center rounded-lg"
                :style="{ backgroundColor: group.bg }"
              >
                <wd-icon :name="item.icon" size="16px" :color="group.color" />
              </view>
              <text>
                {{ t(item.titleKey) }}
              </text>
            </view>
          </template>
        </wd-cell>
      </wd-cell-group>
    </view>

    <!-- 搜索无结果 -->
    <wd-empty v-if="filteredGroups.length === 0" :tip="t('work.emptyTip')" />
  </view>
</template>

<style lang="scss" scoped>
/* 用户信息卡：品牌渐变 + 极光装饰圆环（与首页 Banner 视觉呼应） */
.work-user-card {
  position: relative;
  overflow: hidden;
  background: var(--brand-gradient-blue);
  box-shadow: 0 8rpx 24rpx rgba(37, 99, 235, 0.25);

  /* 右上角装饰圆环 */
  &::before {
    content: '';
    position: absolute;
    right: -60rpx;
    top: -70rpx;
    width: 220rpx;
    height: 220rpx;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.12);
  }

  &::after {
    content: '';
    position: absolute;
    right: 60rpx;
    bottom: -90rpx;
    width: 160rpx;
    height: 160rpx;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.08);
  }
}
</style>


<style lang="scss">
</style>
