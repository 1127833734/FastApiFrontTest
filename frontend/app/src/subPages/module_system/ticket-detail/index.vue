<script setup lang="ts">
import type { TicketComment, TicketItem } from '@/api/module_system/ticket'
import { onLoad, onPullDownRefresh } from '@dcloudio/uni-app'
import { reactive, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { TicketAPI } from '@/api/module_system/ticket'
import { useI18nNavTitle } from '@/composables/useI18nNavTitle'
import { useShare } from '@/composables/useShare'
import { MARKDOWN_TAG_STYLE } from '@/constants/markdown.constant'

const { t } = useI18n()
const ticket = ref<TicketItem | null>(null)
const ticketId = ref(0)

useShare(() => ({
  title: ticket.value ? t('ticketDetail.shareTitle', { title: ticket.value.title }) : t('ticketDetail.title'),
  path: `/subPages/module_system/ticket-detail/index?id=${ticketId.value}`,
}))

definePage({
  name: 'work-ticket-detail',
  style: { navigationBarTitleText: '工单详情' },
})
useI18nNavTitle('ticketDetail.title')

const toast = useToast()
const loading = ref(false)
const comments = ref<TicketComment[]>([])
const commentTotal = ref(0)
const commentPage = reactive({ page_no: 1, page_size: 20 })
const commentText = ref('')
const submitting = ref(false)
const previewRef = ref<{ open: (options: { images: string[], startPosition?: number }) => void }>()

async function loadTicket() {
  if (!ticketId.value)
    return
  loading.value = true
  try {
    ticket.value = await TicketAPI.getDetail(ticketId.value)
  }
  catch {
    toast.error(t('ticketDetail.loadFailed'))
  }
  finally {
    loading.value = false
  }
}

async function loadComments() {
  if (!ticketId.value)
    return
  try {
    const res = await TicketAPI.getComments(ticketId.value, { page_no: commentPage.page_no, page_size: commentPage.page_size })
    comments.value = res.list || []
    commentTotal.value = res.total || 0
  }
  catch (e) {
    console.error(t('common.loadFailed'), e)
  }
}

async function submitComment() {
  if (!commentText.value.trim())
    return toast.warning(t('ticketDetail.commentRequired'))
  submitting.value = true
  try {
    await TicketAPI.createComment(ticketId.value, { content: commentText.value.trim() })
    commentText.value = ''
    toast.success(t('ticketDetail.commentSuccess'))
    loadComments()
  }
  catch {
    toast.error(t('ticketDetail.commentFailed'))
  }
  finally {
    submitting.value = false
  }
}

function getTypeLabel(type?: string) {
  const map: Record<string, string> = {
    suggestion: 'common.type.suggestion',
    bug: 'common.type.bug',
    optimize: 'common.type.optimize',
    other: 'common.type.other',
  }
  return t(map[type || ''] || 'common.type.other')
}
function getTypeColor(type?: string) {
  const map: Record<string, string> = { suggestion: '#4F8CFF', bug: '#EF4444', optimize: '#F59E0B', other: '#6B7280' }
  return map[type || ''] || '#6B7280'
}
function getStatusLabel(status?: string | number) {
  const map: Record<string, string> = { 0: 'pending', 1: 'processing', 2: 'completed', 3: 'closed' }
  return t(`common.status.${map[String(status ?? '')] || 'unknown'}`)
}
function getStatusColor(status?: string | number) {
  const map: Record<string, string> = { 0: '#F59E0B', 1: '#4F8CFF', 2: '#10B981', 3: '#6B7280' }
  return map[String(status ?? '')] || '#6B7280'
}
function parseImages(images?: string): string[] {
  if (!images)
    return []
  try {
    return JSON.parse(images)
  }
  catch {
    return []
  }
}

function previewImages(images: string[], current: number) {
  previewRef.value?.open({ images, startPosition: current })
}

onPullDownRefresh(async () => {
  try {
    await Promise.all([loadTicket(), loadComments()])
  }
  finally {
    uni.stopPullDownRefresh()
  }
})

onLoad((options) => {
  ticketId.value = Number(options?.id || 0)
  if (ticketId.value) {
    loadTicket()
    loadComments()
  }
})
</script>

<template>
  <view class="page-wraper" style="padding-bottom: 140rpx;">
    <SkeletonPage v-if="loading && !ticket" :rows="5" />

    <template v-else-if="ticket">
      <!-- Ticket Header -->
      <view class="mx-3 mb-3 rounded-2 p-4 wot-bg-filled-oppo">
        <text class="block text-4 font-bold wot-text-text-main">
          {{ ticket.title || t('ticketDetail.unnamed') }}
        </text>
        <view class="mt-3 flex gap-2">
          <wd-tag size="small" round :bg-color="`${getTypeColor(ticket.ticket_type)}18`" :color="getTypeColor(ticket.ticket_type)">
            {{ getTypeLabel(ticket.ticket_type) }}
          </wd-tag>
          <wd-tag size="small" round :bg-color="`${getStatusColor(ticket.status)}18`" :color="getStatusColor(ticket.status)">
            {{ getStatusLabel(ticket.status) }}
          </wd-tag>
        </view>
      </view>

      <!-- Ticket Status Steps -->
      <view class="mx-3 mb-3 rounded-2 p-4 wot-bg-filled-oppo">
        <text class="mb-3 block text-3.5 font-bold wot-text-text-main">
          {{ t('ticketDetail.progress') }}
        </text>
        <wd-steps :active="Number(ticket.status ?? 0)" align-center>
          <wd-step :title="t('common.status.pending')" />
          <wd-step :title="t('common.status.processing')" />
          <wd-step :title="t('common.status.completed')" />
          <wd-step :title="t('common.status.closed')" />
        </wd-steps>
      </view>

      <!-- Ticket Info -->
      <view class="mx-3 mb-3">
        <wd-cell-group border custom-class="rounded-2! overflow-hidden">
          <wd-cell :title="t('ticketDetail.createdAt')" :value="ticket.created_time || '—'" />
          <wd-cell :title="t('ticketDetail.handler')" :value="ticket.assigned_by?.name || t('ticketDetail.unassigned')" />
          <wd-cell :title="t('ticketDetail.updatedAt')" :value="ticket.updated_time || '—'" />
        </wd-cell-group>
      </view>

      <!-- Ticket Content -->
      <view v-if="ticket.ticket_content || ticket.summary" class="mx-3 mb-3 rounded-2 p-4 wot-bg-filled-oppo">
        <text class="block text-3.5 font-bold wot-text-text-main">
          {{ t('ticketDetail.content') }}
        </text>
        <wd-divider class="my-3!" />
        <mp-html :content="ticket.summary || ticket.ticket_content" markdown :tag-style="MARKDOWN_TAG_STYLE" />
      </view>

      <!-- Images -->
      <view v-if="parseImages(ticket.images).length > 0" class="mx-3 mb-3 rounded-2 p-4 wot-bg-filled-oppo">
        <text class="block text-3.5 font-bold wot-text-text-main">
          {{ t('ticketDetail.attachments') }}
        </text>
        <wd-divider class="my-3!" />
        <view class="flex flex-wrap gap-3">
          <wd-img
            v-for="(img, idx) in parseImages(ticket.images)"
            :key="img"
            :src="img"
            width="200rpx"
            height="200rpx"
            radius="16rpx"
            mode="aspectFill"
            lazy-load
            @click="previewImages(parseImages(ticket.images), idx)"
          />
        </view>
      </view>

      <!-- Reply -->
      <view v-if="ticket.reply" class="mx-3 mb-3 rounded-2 p-4 wot-bg-filled-oppo">
        <text class="block text-3.5 font-bold wot-text-text-main">
          {{ t('ticketDetail.replies') }}
        </text>
        <wd-divider class="my-3!" />
        <view class="rounded-lg p-3" style="background: var(--primary-color-light, rgba(1, 77, 178, 0.06));">
          <mp-html :content="ticket.reply" markdown :tag-style="MARKDOWN_TAG_STYLE" />
        </view>
      </view>

      <!-- Comments -->
      <view class="mx-3 mb-3 rounded-2 p-4 wot-bg-filled-oppo">
        <text class="block text-3.5 font-bold wot-text-text-main">
          {{ t('ticketDetail.comments', { count: commentTotal }) }}
        </text>
        <wd-divider class="my-3!" />
        <wd-empty v-if="comments.length === 0" :tip="t('ticketDetail.emptyComments')" />
        <view v-else class="flex flex-col gap-4">
          <view v-for="comment in comments" :key="comment.id" class="flex gap-3">
            <wd-avatar
              size="32px"
              round
              :text="(comment.username || t('ticketDetail.anonymous')).charAt(0)"
            />
            <view class="min-w-0 flex-1">
              <view class="flex items-center gap-3">
                <text class="text-3 font-semibold wot-text-text-main">
                  {{ comment.username || t('ticketDetail.anonymous') }}
                </text>
                <text class="text-2.5 wot-text-text-auxiliary">
                  {{ comment.created_time || '' }}
                </text>
              </view>
              <text class="mt-1 block text-3 leading-relaxed wot-text-text-secondary">
                {{ comment.content }}
              </text>
            </view>
          </view>

          <view v-if="commentTotal > comments.length" class="flex items-center justify-center py-1" @click="commentPage.page_no++; loadComments()">
            <text class="text-3 wot-text-primary">
              {{ t('ticketDetail.loadMore') }}
            </text>
          </view>
        </view>
      </view>
    </template>

    <wd-empty v-else :tip="t('ticketDetail.notFound')" />

    <!-- 图片预览 -->
    <wd-image-preview ref="previewRef" />

    <!-- Comment Input -->
    <view
      v-if="ticket"
      class="fixed inset-x-0 bottom-0 flex items-center gap-3 px-4 py-3"
      style="z-index: 100; background: var(--card-bg-color, #FFFFFF); border-top: 1rpx solid var(--border-color, #F0F0F0); padding-bottom: calc(12px + env(safe-area-inset-bottom));"
    >
      <wd-input
        v-model="commentText"
        :placeholder="t('ticketDetail.commentPlaceholder')"
        clearable
        class="flex-1"
      />
      <wd-button
        size="small"
        type="primary"
        :loading="submitting"
        :disabled="!commentText.trim()"
        @click="submitComment"
      >
        {{ t('common.send') }}
      </wd-button>
    </view>
  </view>
</template>
