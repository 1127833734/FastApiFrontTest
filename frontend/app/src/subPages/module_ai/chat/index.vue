<script setup lang="ts">
import type { ChatMessage, ChatSession } from '@/api/module_ai/chat'
import { onLoad, onUnload } from '@dcloudio/uni-app'
import { computed, nextTick, ref } from 'vue'
import { ChatAPI } from '@/api/module_ai/chat'
import { useAiChat } from '@/composables/useAiChat'
import { useShare } from '@/composables/useShare'
import { MARKDOWN_TAG_STYLE } from '@/constants/markdown.constant'

useShare({
  title: 'FastapiAdmin AI 助手 - 智能对话，随时答疑',
  path: '/subPages/module_ai/chat/index',
})

definePage({ name: 'work-chat', style: { navigationBarTitleText: 'AI 助手' } })

const toast = useToast()
const sessions = ref<ChatSession[]>([])
const currentSession = ref<number | null>(null)
const currentTitle = ref('AI 助手')
const messages = ref<ChatMessage[]>([])
const inputText = ref('')
const loading = ref(false)
const showSessions = ref(false)

/** 流式对话（WebSocket） */
const streamChat = useAiChat()
const streaming = streamChat.isStreaming

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
  catch {
    sessions.value = []
    toast.error('加载会话列表失败')
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
  catch { toast.error('创建会话失败') }
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
  catch {
    messages.value = []
    toast.error('加载会话消息失败')
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
        catch { toast.error('删除失败') }
      }
    },
  })
}

async function sendMessage() {
  const text = inputText.value.trim()
  if (!text || streaming.value)
    return
  // 无会话时自动创建，避免"请先创建会话"的额外步骤
  let sid = currentSession.value
  if (!sid) {
    try {
      const res = await ChatAPI.createSession()
      // 兼容后端可能返回 { data: ChatSession } 或直接 ChatSession 两种结构
      const newSession = (res as { data?: ChatSession })?.data ?? (res as ChatSession)
      if (newSession?.id) {
        sessions.value.unshift(newSession)
        sid = newSession.id
        currentSession.value = sid
        currentTitle.value = newSession.title || 'AI 助手'
      }
      else {
        return toast.error('创建会话失败')
      }
    }
    catch {
      return toast.error('创建会话失败')
    }
  }

  messages.value.push({ role: 'user', content: text, time: new Date().toLocaleTimeString() })
  inputText.value = ''
  // 占位 AI 消息，流式分片实时追加（打字机效果）
  const aiMsg: ChatMessage = { role: 'ai', content: '', time: new Date().toLocaleTimeString() }
  messages.value.push(aiMsg)
  scrollToBottom()

  try {
    await streamChat.sendMessage({ message: text, session_id: String(sid) }, {
      onChunk: (chunk) => {
        aiMsg.content += chunk
        scrollToBottom()
      },
      onDone: () => {
        if (!aiMsg.content)
          aiMsg.content = '（无回复内容）'
      },
      onError: (err) => {
        aiMsg.content = err || '请求失败，请稍后重试。'
      },
    })
  }
  finally {
    streaming.value = false
  }
}

/** 停止当前生成 */
function stopGenerate() {
  streamChat.stop()
}

/** 滚动到最新一条消息 */
function scrollToBottom() {
  scrollTarget.value = `msg-${visibleMessages.value.length - 1}`
  nextTick(() => {
    scrollTarget.value = ''
  })
}

onUnload(() => {
  streamChat.close()
})

onLoad(() => {
  loadSessions()
  messages.value = [{ role: 'ai', content: '你好！我是 FastapiAdmin AI 助手，有什么可以帮助你的？' }]
})
</script>

<template>
  <view class="chat-page" style="display:flex;flex-direction:column;height:100vh;background:var(--bg-color);">
    <!-- Header -->
    <view style="display:flex;align-items:center;gap:var(--spacing-sm,12rpx);padding:var(--spacing-md,16rpx);border-bottom:1px solid var(--border-color);background:var(--card-bg-color);">
      <wd-button size="small" variant="plain" @click="showSessions = !showSessions">
        <wd-icon name="menu" size="16px" />
      </wd-button>
      <text class="text-md flex-1 truncate text-center font-bold">
        {{ currentTitle }}
      </text>
      <wd-button size="small" type="primary" variant="plain" @click="createSession">
        <wd-icon name="plus" size="16px" />
      </wd-button>
    </view>

    <!-- Session panel overlay -->
    <view v-if="showSessions" class="session-overlay" style="position:absolute;top:88rpx;left:0;right:0;bottom:0;background:var(--bg-color);z-index:100;overflow-y:auto;">
      <view class="p-sm">
        <view class="mb-md flex items-center justify-between px-xs">
          <text class="text-lg font-bold">
            会话列表
          </text>
          <wd-button size="small" type="primary" @click="createSession">
            新建
          </wd-button>
        </view>
        <SkeletonPage v-if="loading && sessions.length === 0" />
        <view v-for="s in sessions" v-else :key="s.id" class="admin-card">
          <wd-cell :title="s.title" :label="s.created_at ? String(s.created_at) : ''" center is-link @click="selectSession(s.id, s.title)">
            <template #default>
              <wd-icon name="delete" size="18px" color="var(--danger-color)" @click.stop="deleteSession(s.id)" />
            </template>
          </wd-cell>
        </view>
        <wd-empty v-if="!loading && sessions.length === 0" tip="暂无会话，点击右上角新建" />
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
        <wd-button size="small" variant="plain" @click="loadOlderMessages">
          加载更早消息（{{ messages.length - visibleMessages.length }} 条）
        </wd-button>
      </view>
      <view v-for="(msg, i) in visibleMessages" :id="`msg-${i}`" :key="i" style="margin-bottom:24rpx;">
        <view class="flex items-start gap-sm" :class="msg.role === 'user' ? 'flex-row-reverse' : ''">
          <view
            v-if="msg.role === 'user'"
            class="h-8 w-8 flex shrink-0 items-center justify-center rounded-full"
            style="background: linear-gradient(135deg, var(--primary-color, #4F8CFF), var(--primary-color-dark, #2970FF));"
          >
            <wd-icon name="user" size="18px" color="#FFFFFF" />
          </view>
          <wd-avatar v-else size="32px" shape="round" src="/static/logo.png" />
          <view
            class="max-w-[72%] break-words px-3 py-2"
            :style="{
              background: msg.role === 'user' ? 'var(--primary-color)' : 'var(--card-bg-color)',
              color: msg.role === 'user' ? 'var(--text-color-inverse)' : 'var(--text-color)',
              borderRadius: msg.role === 'user' ? '16rpx 16rpx 4rpx 16rpx' : '16rpx 16rpx 16rpx 4rpx',
              border: msg.role === 'user' ? 'none' : '1px solid var(--border-color)',
            }"
          >
            <!-- AI 消息渲染 markdown；用户消息保持纯文本 -->
            <template v-if="msg.role !== 'user'">
              <wd-loading v-if="streaming && !msg.content" />
              <mp-html v-else :content="msg.content" markdown :tag-style="MARKDOWN_TAG_STYLE" />
            </template>
            <text v-else style="white-space:pre-wrap;font-size:var(--font-sm,24rpx);line-height:1.7;">
              {{ msg.content }}
            </text>
            <text v-if="msg.time" style="font-size:var(--font-xs,20rpx);opacity:0.6;margin-top:8rpx;display:block;" :style="msg.role === 'user' ? 'text-align:right' : 'text-align:left'">
              {{ msg.time }}
            </text>
          </view>
        </view>
      </view>
    </scroll-view>

    <!-- Input -->
    <view style="border-top:1px solid var(--border-color);padding:var(--spacing-md,16rpx);background:var(--card-bg-color);padding-bottom:calc(var(--spacing-md) + env(safe-area-inset-bottom));">
      <view class="flex items-center gap-sm">
        <wd-input v-model="inputText" placeholder="输入消息..." :disabled="streaming" class="flex-1" confirm-type="send" @confirm="sendMessage" />
        <wd-button v-if="streaming" type="danger" variant="plain" @click="stopGenerate">
          停止
        </wd-button>
        <wd-button v-else :disabled="!inputText.trim()" type="primary" @click="sendMessage">
          发送
        </wd-button>
      </view>
    </view>
  </view>
</template>
