<script setup lang="ts">
import { computed, ref } from 'vue'
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
    ],
  },
  {
    title: '开发者工具',
    color: '#8B5CF6',
    bg: 'var(--bg-color-2)',
    items: [
      { icon: 'message', text: 'AI 助手', name: 'work-chat' },
      { icon: 'robot', text: 'AI 模型', name: 'work-ai-models' },
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
    .map(group => ({ ...group, items: group.items.filter(item => item.text.toLowerCase().includes(kw)) }))
    .filter(group => group.items.length > 0)
})
</script>

<template>
  <view class="box-border min-h-screen py-3">
    <!-- 用户信息卡 -->
    <view class="mx-3 mb-4 flex items-center gap-4 rounded-3 px-5 py-6 wot-bg-filled-oppo">
      <wd-avatar
        size="64px"
        round
        :text="(userInfo?.name || '管').charAt(0)"
        bg-color="#4F8CFF"
        color="#FFFFFF"
      />
      <view class="min-w-0 flex-1">
        <view class="text-4 font-bold wot-text-text-main">
          {{ userInfo?.name || 'FastapiAdmin' }}
        </view>
        <view class="mt-1 truncate text-3 wot-text-text-secondary">
          {{ userInfo?.roles?.map(r => r.name).join(', ') || '超级管理员' }}
        </view>
      </view>
    </view>

    <!-- 模块搜索 -->
    <view class="mx-3 mb-4">
      <wd-search v-model="keyword" placeholder="搜索模块功能" variant="light" hide-cancel />
    </view>

    <!-- 模块分组 -->
    <view v-for="(group, gi) in filteredGroups" :key="gi" class="mb-4">
      <view class="mb-2 mt-1 flex items-center gap-2 px-3">
        <view class="h-3.5 w-1 rounded-full" :style="{ backgroundColor: group.color }" />
        <text class="text-3.5 font-bold wot-text-text-main">
          {{ group.title }}
        </text>
        <text class="text-2.5 wot-text-text-auxiliary">
          {{ group.items.length }}
        </text>
      </view>
      <wd-cell-group border custom-class="mx-3 rounded-2! overflow-hidden">
        <wd-cell
          v-for="item in group.items"
          :key="item.name"
          :title="item.text"
          is-link
          @click="navigateTo(item.name)"
        >
          <template #prefix>
            <view
              class="mr-2 h-8 w-8 flex items-center justify-center rounded-lg"
              :style="{ backgroundColor: group.bg }"
            >
              <wd-icon :name="item.icon" size="16px" :color="group.color" />
            </view>
          </template>
        </wd-cell>
      </wd-cell-group>
    </view>

    <!-- 搜索无结果 -->
    <wd-empty v-if="filteredGroups.length === 0" tip="未找到相关模块，换个关键词试试" />

    <!-- Bottom safe area -->
    <wd-gap height="100rpx" safe-area-bottom />
  </view>
</template>
