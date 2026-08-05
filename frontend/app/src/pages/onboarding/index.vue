<script setup lang="ts">
import { Storage } from '@/utils/storage'

definePage({
  name: 'onboarding',
  style: {
    navigationBarTitleText: '',
    navigationStyle: 'custom',
    disableScroll: true,
  },
})

const ONBOARDING_KEY = 'onboarding_completed'

const currentIndex = ref(0)

interface Slide {
  icon: string
  color: string
  bgColor: string
  title: string
  subtitle: string
  desc: string
}

const slides: Slide[] = [
  {
    icon: 'dashboard',
    color: '#4F8CFF',
    bgColor: 'linear-gradient(135deg, #4F8CFF 0%, #2563EB 100%)',
    title: '工作台概览',
    subtitle: '一屏掌握全局动态',
    desc: '实时查看注册用户、在线用户、今日登录等核心指标，近7天登录趋势一目了然',
  },
  {
    icon: 'message',
    color: '#F59E0B',
    bgColor: 'linear-gradient(135deg, #F59E0B 0%, #D97706 100%)',
    title: '工单管理',
    subtitle: '高效协作不遗漏',
    desc: '待处理、处理中、已完成全状态追踪，支持评论互动与附件查看，移动办公更高效',
  },
  {
    icon: 'interaction',
    color: '#06B6D4',
    bgColor: 'linear-gradient(135deg, #06B6D4 0%, #0891B2 100%)',
    title: 'AI 智能助手',
    subtitle: '随时答疑解惑',
    desc: '内置 AI 对话助手，支持多会话管理、流式回复、Markdown 渲染，智能辅助日常决策',
  },
  {
    icon: 'notification',
    color: '#10B981',
    bgColor: 'linear-gradient(135deg, #10B981 0%, #059669 100%)',
    title: '消息通知',
    subtitle: '重要信息不遗漏',
    desc: '系统公告、工单提醒实时推送，订阅消息让你第一时间掌握动态',
  },
]

function handleNext() {
  if (currentIndex.value < slides.length - 1) {
    currentIndex.value++
  }
  else {
    handleFinish()
  }
}

function handleSkip() {
  handleFinish()
}

function handleFinish() {
  Storage.set(ONBOARDING_KEY, true)
  uni.reLaunch({ url: '/pages/index/index' })
}

function handleSwiperChange(e: any) {
  currentIndex.value = e.detail.current
}
</script>

<template>
  <view class="onboarding-page">
    <!-- 跳过按钮 -->
    <view class="skip-btn" @click="handleSkip">
      <text>跳过</text>
    </view>

    <!-- 轮播内容 -->
    <swiper
      class="onboarding-swiper"
      :current="currentIndex"
      :indicator-dots="false"
      :autoplay="false"
      :circular="false"
      @change="handleSwiperChange"
    >
      <swiper-item v-for="(slide, i) in slides" :key="i">
        <view class="slide-item">
          <!-- 图标区域 -->
          <view class="slide-icon-wrapper" :style="{ background: slide.bgColor }">
            <wd-icon :name="slide.icon" size="72px" color="#FFFFFF" />
          </view>

          <!-- 文字区域 -->
          <view class="slide-content">
            <text class="slide-title">
              {{ slide.title }}
            </text>
            <text class="slide-subtitle">
              {{ slide.subtitle }}
            </text>
            <text class="slide-desc">
              {{ slide.desc }}
            </text>
          </view>
        </view>
      </swiper-item>
    </swiper>

    <!-- 指示器 -->
    <view class="onboarding-dots">
      <view
        v-for="(slide, i) in slides"
        :key="i"
        class="onboarding-dot"
        :class="{ 'is-active': i === currentIndex }"
      />
    </view>

    <!-- 操作按钮 -->
    <view class="onboarding-actions">
      <wd-button
        type="primary"
        round
        block
        size="large"
        @click="handleNext"
      >
        {{ currentIndex === slides.length - 1 ? '立即体验' : '下一步' }}
      </wd-button>
    </view>

    <!-- 底部安全区 -->
    <view class="safe-area-bottom" />
  </view>
</template>

<style lang="scss" scoped>
.onboarding-page {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background: var(--bg-color-1, #F9F9F9);
  position: relative;

  .wot-theme-dark & {
    background: var(--bg-color-1, #0F0F11);
  }
}

.skip-btn {
  position: absolute;
  top: calc(88rpx + env(safe-area-inset-top));
  right: 32rpx;
  z-index: 10;
  padding: 12rpx 24rpx;
  font-size: 28rpx;
  color: var(--text-color-3, #6B7280);

  .wot-theme-dark & {
    color: var(--text-color-3, #9CA3AF);
  }
}

.onboarding-swiper {
  flex: 1;
  height: 0;
}

.slide-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  padding: 0 64rpx;
}

.slide-icon-wrapper {
  width: 200rpx;
  height: 200rpx;
  border-radius: 48rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 64rpx;
  box-shadow: 0 16rpx 48rpx rgba(0, 0, 0, 0.12);
}

.slide-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
}

.slide-title {
  font-size: 48rpx;
  font-weight: 700;
  color: var(--text-color, #0A1628);
  margin-bottom: 16rpx;

  .wot-theme-dark & {
    color: #FFFFFF;
  }
}

.slide-subtitle {
  font-size: 32rpx;
  font-weight: 500;
  color: var(--primary-color, #4F8CFF);
  margin-bottom: 24rpx;
}

.slide-desc {
  font-size: 28rpx;
  line-height: 1.6;
  color: var(--text-color-3, #6B7280);
  max-width: 560rpx;

  .wot-theme-dark & {
    color: var(--text-color-3, #9CA3AF);
  }
}

.onboarding-dots {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 12rpx;
  padding: 24rpx 0;
}

.onboarding-dot {
  width: 12rpx;
  height: 12rpx;
  border-radius: 6rpx;
  background: rgba(128, 128, 128, 0.25);
  transition: all 0.3s ease;

  &.is-active {
    width: 32rpx;
    background: var(--primary-color, #4F8CFF);
  }
}

.onboarding-actions {
  padding: 0 64rpx 24rpx;
}

.safe-area-bottom {
  height: env(safe-area-inset-bottom);
}
</style>
