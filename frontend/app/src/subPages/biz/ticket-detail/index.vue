<script setup lang="ts">
import type { TicketComment, TicketItem } from '@/api/module_system/ticket'
import { onLoad, onPullDownRefresh } from '@dcloudio/uni-app'
import { reactive, ref } from 'vue'
import { TicketAPI } from '@/api/module_system/ticket'
import SkeletonPage from '@/components/SkeletonPage.vue'

definePage({
  name: 'work-ticket-detail',
  style: { navigationBarTitleText: '工单详情' },
})

const toast = useToast()
const loading = ref(false)
const ticket = ref<TicketItem | null>(null)
const comments = ref<TicketComment[]>([])
const commentTotal = ref(0)
const commentPage = reactive({ page_no: 1, page_size: 20 })
const commentText = ref('')
const submitting = ref(false)
const ticketId = ref(0)

async function loadTicket() {
  if (!ticketId.value)
    return
  loading.value = true
  try {
    ticket.value = await TicketAPI.getDetail(ticketId.value)
  }
  catch {
    toast.error('加载工单详情失败')
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
    console.error('加载评论失败', e)
  }
}

async function submitComment() {
  if (!commentText.value.trim())
    return toast.warning('请输入评论内容')
  submitting.value = true
  try {
    await TicketAPI.createComment(ticketId.value, { content: commentText.value.trim() })
    commentText.value = ''
    toast.success('评论成功')
    loadComments()
  }
  catch {
    toast.error('评论失败')
  }
  finally {
    submitting.value = false
  }
}

function getTypeLabel(type?: string) {
  const map: Record<string, string> = { suggestion: '建议', bug: '缺陷', optimize: '优化', other: '其他' }
  return map[type || ''] || type || '其他'
}
function getTypeColor(type?: string) {
  const map: Record<string, string> = { suggestion: '#4F8CFF', bug: '#EF4444', optimize: '#F59E0B', other: '#6B7280' }
  return map[type || ''] || '#6B7280'
}
function getStatusLabel(status?: string | number) {
  const map: Record<string, string> = { 0: '待处理', 1: '处理中', 2: '已完成', 3: '已关闭' }
  return map[String(status ?? '')] || '未知'
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
  uni.previewImage({ urls: images, current })
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
  <view class="detail-page">
    <SkeletonPage v-if="loading && !ticket" :rows="5" />

    <template v-else-if="ticket">
      <!-- Ticket Header -->
      <view class="ticket-header fade-in-up">
        <text class="ticket-header__title">
          {{ ticket.title || '未命名工单' }}
        </text>
        <view class="ticket-header__badges">
          <view class="badge" :style="{ background: `${getTypeColor(ticket.ticket_type)}18`, color: getTypeColor(ticket.ticket_type) }">
            {{ getTypeLabel(ticket.ticket_type) }}
          </view>
          <view class="badge" :style="{ background: `${getStatusColor(ticket.status)}18`, color: getStatusColor(ticket.status) }">
            {{ getStatusLabel(ticket.status) }}
          </view>
        </view>
      </view>

      <!-- Ticket Info -->
      <view class="ticket-info fade-in-up-1">
        <view class="info-row">
          <text class="info-row__label">
            创建时间
          </text>
          <text class="info-row__value">
            {{ ticket.created_time || '—' }}
          </text>
        </view>
        <view class="info-row">
          <text class="info-row__label">
            处理人
          </text>
          <text class="info-row__value">
            {{ ticket.assigned_by?.name || '未分配' }}
          </text>
        </view>
        <view class="info-row">
          <text class="info-row__label">
            更新时间
          </text>
          <text class="info-row__value">
            {{ ticket.updated_time || '—' }}
          </text>
        </view>
      </view>

      <!-- Ticket Content -->
      <view v-if="ticket.ticket_content || ticket.summary" class="ticket-content fade-in-up-2">
        <text class="section-title">
          工单内容
        </text>
        <text class="ticket-content__text">
          {{ ticket.summary || ticket.ticket_content }}
        </text>
      </view>

      <!-- Images -->
      <view v-if="parseImages(ticket.images).length > 0" class="ticket-images fade-in-up-2">
        <text class="section-title">
          附件图片
        </text>
        <view class="images-grid">
          <image
            v-for="(img, idx) in parseImages(ticket.images)"
            :key="img"
            :src="img"
            class="images-grid__item"
            mode="aspectFill"
            lazy-load
            @click="previewImages(parseImages(ticket.images), idx)"
          />
        </view>
      </view>

      <!-- Reply -->
      <view v-if="ticket.reply" class="ticket-reply fade-in-up-3">
        <text class="section-title">
          处理回复
        </text>
        <view class="reply-box">
          <text class="reply-box__text">
            {{ ticket.reply }}
          </text>
        </view>
      </view>

      <!-- Comments -->
      <view class="comments-section fade-in-up-3">
        <view class="comments-header">
          <text class="section-title">
            评论 ({{ commentTotal }})
          </text>
        </view>

        <ListEmpty v-if="comments.length === 0" text="暂无评论，快来抢沙发" />

        <view v-else class="comments-list">
          <view v-for="comment in comments" :key="comment.id" class="comment-item">
            <view class="comment-item__avatar">
              <text class="comment-item__avatar-text">
                {{ (comment.username || '匿').charAt(0) }}
              </text>
            </view>
            <view class="comment-item__body">
              <view class="comment-item__header">
                <text class="comment-item__name">
                  {{ comment.username || '匿名用户' }}
                </text>
                <text class="comment-item__time">
                  {{ comment.created_time || '' }}
                </text>
              </view>
              <text class="comment-item__content">
                {{ comment.content }}
              </text>
            </view>
          </view>

          <view v-if="commentTotal > comments.length" class="load-more" @click="commentPage.page_no++; loadComments()">
            <text class="load-more__text">
              加载更多
            </text>
          </view>
        </view>
      </view>
    </template>

    <ListEmpty v-else text="工单不存在或已删除" />

    <!-- Comment Input -->
    <view v-if="ticket" class="comment-bar">
      <wd-input
        v-model="commentText"
        placeholder="写下你的评论..."
        clearable
        style="flex:1"
      />
      <wd-button
        size="small"
        type="primary"
        :loading="submitting"
        :disabled="!commentText.trim()"
        @click="submitComment"
      >
        发送
      </wd-button>
    </view>
  </view>
</template>

<style lang="scss" scoped>
.detail-page {
  padding: 0 32rpx 140rpx;
  background: var(--page-bg-color, #F9F9F9);
  min-height: 100vh;
}

/* ===== Ticket Header ===== */
.ticket-header {
  background: var(--card-bg-color, #FFFFFF);
  border-radius: 24rpx;
  padding: 24rpx;
  margin: 24rpx 0 16rpx;
  box-shadow: var(--shadow-sm, 0 1rpx 2rpx rgba(1, 77, 178,0.06));

  &__title {
    display: block;
    font-size: 34rpx;
    font-weight: 700;
    color: var(--text-color, #0A1628);
    line-height: 1.4;
    margin-bottom: 16rpx;
  }

  &__badges {
    display: flex;
    gap: 12rpx;
  }
}

.badge {
  font-size: 22rpx;
  padding: 4rpx 16rpx;
  border-radius: 8rpx;
  font-weight: 500;
}

/* ===== Ticket Info ===== */
.ticket-info {
  background: var(--card-bg-color, #FFFFFF);
  border-radius: 24rpx;
  padding: 24rpx;
  margin-bottom: 16rpx;
  box-shadow: var(--shadow-sm, 0 1rpx 2rpx rgba(1, 77, 178,0.06));
}

.info-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8rpx 0;

  &__label {
    font-size: 26rpx;
    color: var(--text-color-3, #6B7280);
  }

  &__value {
    font-size: 26rpx;
    color: var(--text-color, #0A1628);
    font-weight: 500;
  }
}

/* ===== Sections ===== */
.section-title {
  display: block;
  font-size: 28rpx;
  font-weight: 600;
  color: var(--text-color, #0A1628);
  margin-bottom: 16rpx;
}

/* ===== Content ===== */
.ticket-content {
  background: var(--card-bg-color, #FFFFFF);
  border-radius: 24rpx;
  padding: 24rpx;
  margin-bottom: 16rpx;
  box-shadow: var(--shadow-sm, 0 1rpx 2rpx rgba(1, 77, 178,0.06));

  &__text {
    font-size: 28rpx;
    color: var(--text-color-2, #4B5563);
    line-height: 1.6;
  }
}

/* ===== Images ===== */
.ticket-images {
  background: var(--card-bg-color, #FFFFFF);
  border-radius: 24rpx;
  padding: 24rpx;
  margin-bottom: 16rpx;
  box-shadow: var(--shadow-sm, 0 1rpx 2rpx rgba(1, 77, 178,0.06));
}

.images-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;

  &__item {
    width: 200rpx;
    height: 200rpx;
    border-radius: 16rpx;
    background: var(--page-bg-color, #F9F9F9);
  }
}

/* ===== Reply ===== */
.ticket-reply {
  background: var(--card-bg-color, #FFFFFF);
  border-radius: 24rpx;
  padding: 24rpx;
  margin-bottom: 16rpx;
  box-shadow: var(--shadow-sm, 0 1rpx 2rpx rgba(1, 77, 178,0.06));
}

.reply-box {
  background: var(--primary-color-light, rgba(1,77,178,0.06));
  border-radius: 16rpx;
  padding: 16rpx;

  &__text {
    font-size: 28rpx;
    color: var(--text-color-2, #4B5563);
    line-height: 1.6;
  }
}

/* ===== Comments ===== */
.comments-section {
  background: var(--card-bg-color, #FFFFFF);
  border-radius: 24rpx;
  padding: 24rpx;
  margin-bottom: 16rpx;
  box-shadow: var(--shadow-sm, 0 1rpx 2rpx rgba(1, 77, 178,0.06));
}

.comments-header {
  margin-bottom: 16rpx;
}

.comments-list {
  display: flex;
  flex-direction: column;
  gap: 24rpx;
}

.comment-item {
  display: flex;
  gap: 16rpx;

  &__avatar {
    width: 64rpx;
    height: 64rpx;
    border-radius: 50%;
    background: linear-gradient(135deg, var(--primary-color, #4F8CFF), var(--primary-color-dark, #2970FF));
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
  }

  &__avatar-text {
    font-size: 28rpx;
    font-weight: 600;
    color: #FFFFFF;
  }

  &__body {
    flex: 1;
    min-width: 0;
  }

  &__header {
    display: flex;
    align-items: center;
    gap: 16rpx;
    margin-bottom: 8rpx;
  }

  &__name {
    font-size: 26rpx;
    font-weight: 600;
    color: var(--text-color, #0A1628);
  }

  &__time {
    font-size: 22rpx;
    color: var(--text-color-4, #B0B0B0);
  }

  &__content {
    font-size: 28rpx;
    color: var(--text-color-2, #4B5563);
    line-height: 1.5;
  }
}

/* ===== Load more ===== */
.load-more {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 72rpx;

  &__text {
    font-size: 26rpx;
    color: var(--primary-color, #4F8CFF);
  }
}

/* ===== Comment Bar ===== */
.comment-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  display: flex;
  align-items: center;
  gap: 16rpx;
  padding: 16rpx 32rpx;
  padding-bottom: calc(16rpx + env(safe-area-inset-bottom));
  background: var(--card-bg-color, #FFFFFF);
  border-top: 1rpx solid var(--border-color, #F0F0F0);
  z-index: 100;
}
</style>
