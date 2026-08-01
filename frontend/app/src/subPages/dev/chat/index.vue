<script setup lang="ts">
import type { ChatMessage, ChatSession } from '@/api/module_ai/chat'
import { onLoad } from '@dcloudio/uni-app'
import { computed, nextTick, ref } from 'vue'
import { ChatAPI } from '@/api/module_ai/chat'

definePage({ name: 'work-chat', style: { navigationBarTitleText: 'AI 助手' } })

const toast = useToast()
const sessions = ref<ChatSession[]>([])
const currentSession = ref<number | null>(null)
const currentTitle = ref('AI 助手')
const messages = ref<ChatMessage[]>([])
const inputText = ref('')
const loading = ref(false)
const showSessions = ref(false)

// ===== 消息窗口化渲染 =====
// 长会话只渲染最近 MAX_VISIBLE_MESSAGES 条，避免消息过多时 DOM 节点与 setData 数据量膨胀导致卡顿；
// 通过"加载更早消息"按步长扩大渲染窗口，保持浏览位置不跳变。
const MAX_VISIBLE_MESSAGES = 60
const INCREMENT = 40
const messageWindow = ref(MAX_VISIBLE_MESSAGES)
const scrollTarget = ref('')
const visibleMessages = computed(() => messages.value.slice(-messageWindow.value))
const hasOlderMessages = computed(() => messages.value.length > messageWindow.value)

function loadOlderMessages() {
  messageWindow.value += INCREMENT
  // 滚动到新增窗口边界，保持已读消息位置不跳变
  scrollTarget.value = `msg-${INCREMENT - 1}`
  nextTick(() => {
    scrollTarget.value = ''
  })
}

function resetWindow() {
  messageWindow.value = MAX_VISIBLE_MESSAGES
  scrollTarget.value = ''
}

async function loadSessions() {
  loading.value = true
  try {
    const res = await ChatAPI.getSessions()
    sessions.value = res.list || []
  }
  catch (e) {
    sessions.value = []
    toast.error(getErrorMessage(e, '加载会话列表失败'))
  }
  finally { loading.value = false }
}

async function createSession() {
  try {
    const res = await ChatAPI.createSession('新对话')
    // 兼容后端可能返回 { data: ChatSession } 或直接 ChatSession 两种结构
    const newSession = (res as { data?: ChatSession })?.data ?? (res as ChatSession)
    if (newSession?.id) {
      sessions.value.unshift(newSession)
      selectSession(newSession.id, newSession.title)
    }
    toast.success('新会话已创建')
  }
  catch (e) {
    toast.error(getErrorMessage(e, '创建会话失败'))
  }
}

async function selectSession(id: number, title?: string) {
  currentSession.value = id
  currentTitle.value = title || `会话 ${id}`
  showSessions.value = false
  loading.value = true
  try {
    const detail = await ChatAPI.getDetail(id)
    // 兼容后端可能返回 { messages: [] } 或 { data: { messages: [] } } 两种结构
    const detailRes = detail as { messages?: ChatMessage[], data?: { messages?: ChatMessage[] } }
    const msgs = detailRes?.messages || detailRes?.data?.messages || []
    resetWindow()
    messages.value = msgs.map(m => ({ role: m.role || 'ai', content: m.content || '', time: String(m.created_at || m.time || '') }))
  }
  catch (e) {
    messages.value = []
    toast.error(getErrorMessage(e, '加载会话消息失败'))
  }
  finally { loading.value = false }
}

async function deleteSession(id: number) {
  uni.showModal({
    title: '提示',
    content: '确认删除该会话？',
    success: async (r) => {
      if (r.confirm) {
        try {
          await ChatAPI.removeSession([id])
          sessions.value = sessions.value.filter(s => s.id !== id)
          if (currentSession.value === id) {
            currentSession.value = null
            currentTitle.value = 'AI 助手'
            messages.value = []
          }
          toast.success('已删除')
        }
        catch (e) { toast.error(getErrorMessage(e, '删除失败')) }
      }
    },
  })
}

async function sendMessage() {
  if (!inputText.value.trim())
    return
  if (!currentSession.value) {
    toast.info('请先创建或选择会话')
    return
  }

  const text = inputText.value.trim()
  messages.value.push({ role: 'user', content: text, time: new Date().toLocaleTimeString() })
  inputText.value = ''
  loading.value = true

  // Scroll to bottom
  nextTick(() => {
    // scroll-view auto-scroll
  })

  try {
    const res = await ChatAPI.sendMessage(currentSession.value, text)
    // 兼容后端可能返回 ChatMessage 或 { data: { content } } 或 { reply } 多种结构
    const replyRes = res as { content?: string, reply?: string, data?: { content?: string } }
    const reply = replyRes?.content || replyRes?.reply || replyRes?.data?.content || '已收到您的消息。'
    messages.value.push({ role: 'ai', content: reply, time: new Date().toLocaleTimeString() })
  }
  catch (e) {
    messages.value.push({ role: 'ai', content: getErrorMessage(e, '请求失败，请稍后重试。'), time: new Date().toLocaleTimeString() })
  }
  finally {
    loading.value = false
  }
}

onLoad(() => {
  loadSessions()
  messages.value = [{ role: 'ai', content: '你好！我是 FastapiAdmin AI 助手，有什么可以帮助你的？' }]
})
</script>

<template>
  <view class="chat-page" style="display:flex;flex-direction:column;height:100vh;background:var(--bg-color);">
    <!-- Header -->
    <view style="display:flex;align-items:center;gap:var(--spacing-sm,12rpx);padding:var(--spacing-md,16rpx);border-bottom:1px solid var(--border-color);background:var(--card-bg-color);">
      <u-button size="mini" :plain="true" @click="showSessions = !showSessions">
        <u-icon name="list-dot" size="16" />
      </u-button>
      <text class="font-bold text-md flex-1 text-center truncate">
        {{ currentTitle }}
      </text>
      <u-button size="mini" type="primary" :plain="true" @click="createSession">
        <u-icon name="plus" size="16" />
      </u-button>
    </view>

    <!-- Session panel overlay -->
    <view v-if="showSessions" class="session-overlay" style="position:absolute;top:88rpx;left:0;right:0;bottom:0;background:var(--bg-color);z-index:100;overflow-y:auto;">
      <view class="p-sm">
        <view class="flex items-center justify-between mb-md px-xs">
          <text class="font-bold text-lg">
            会话列表
          </text>
          <u-button size="mini" type="primary" text="新建" @click="createSession" />
        </view>
        <SkeletonPage v-if="loading && sessions.length === 0" />
        <view v-for="s in sessions" v-else :key="s.id" class="admin-card">
          <u-cell :title="s.title" :label="s.created_at ? String(s.created_at) : ''" :is-link="true" @click="selectSession(s.id, s.title)">
            <template #right>
              <u-icon name="trash" size="18" color="var(--danger-color)" @click.stop="deleteSession(s.id)" />
            </template>
          </u-cell>
        </view>
        <ListEmpty v-if="!loading && sessions.length === 0" text="暂无会话，点击右上角新建" />
      </view>
    </view>

    <!-- Messages -->
    <scroll-view
      scroll-y
      class="chat-messages"
      style="flex:1;padding:var(--spacing-md,16rpx);"
      :scroll-into-view="scrollTarget || `msg-${visibleMessages.length - 1}`"
      :scroll-with-animation="true"
    >
      <!-- 窗口化渲染：仅渲染最近 N 条消息，支持加载更早消息 -->
      <view v-if="hasOlderMessages" style="padding:16rpx 0;text-align:center;">
        <u-button size="mini" :plain="true" :text="`加载更早消息（${messages.length - visibleMessages.length} 条）`" @click="loadOlderMessages" />
      </view>
      <view v-for="(msg, i) in visibleMessages" :id="`msg-${i}`" :key="i" style="margin-bottom:24rpx;">
        <view class="flex items-start gap-sm" :class="msg.role === 'user' ? 'flex-row-reverse' : ''">
          <u-avatar :size="32" shape="round" :src="msg.role === 'user' ? '/static/images/default-avatar.png' : '/static/logo.png'" />
          <view
            class="chat-bubble"
            :style="{
              background: msg.role === 'user' ? 'var(--primary-color)' : 'var(--card-bg-color)',
              color: msg.role === 'user' ? 'var(--text-color-inverse)' : 'var(--text-color)',
              borderRadius: msg.role === 'user' ? '16rpx 16rpx 4rpx 16rpx' : '16rpx 16rpx 16rpx 4rpx',
              border: msg.role === 'user' ? 'none' : '1px solid var(--border-color)',
            }"
          >
            <text style="white-space:pre-wrap;font-size:var(--font-sm,24rpx);line-height:1.7;">
              {{ msg.content }}
            </text>
            <text v-if="msg.time" style="font-size:var(--font-xs,20rpx);opacity:0.6;margin-top:8rpx;display:block;" :style="msg.role === 'user' ? 'text-align:right' : 'text-align:left'">
              {{ msg.time }}
            </text>
          </view>
        </view>
      </view>
      <!-- Loading indicator -->
      <view v-if="loading" style="margin-bottom:24rpx;">
        <view class="flex items-start gap-sm">
          <u-avatar :size="32" shape="round" src="/static/logo.png" />
          <view class="chat-bubble" style="background:var(--card-bg-color);border:1px solid var(--border-color);border-radius:16rpx 16rpx 16rpx 4rpx;">
            <u-loading-icon />
          </view>
        </view>
      </view>
    </scroll-view>

    <!-- Input -->
    <view style="border-top:1px solid var(--border-color);padding:var(--spacing-md,16rpx);background:var(--card-bg-color);padding-bottom:calc(var(--spacing-md) + env(safe-area-inset-bottom));">
      <view class="flex items-center gap-sm">
        <u-input v-model="inputText" placeholder="输入消息..." :disabled="loading" class="flex-1" confirm-type="send" border="surround" @confirm="sendMessage" />
        <u-button :loading="loading" :disabled="!inputText.trim() || !currentSession" type="primary" text="发送" @click="sendMessage" />
      </view>
    </view>
  </view>
</template>

<style scoped>
.chat-bubble {
  padding: 16rpx 24rpx;
  max-width: 72%;
  word-break: break-word;
}
</style>
