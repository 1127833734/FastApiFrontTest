<script lang="ts" setup>
import type { FormSchema } from '@wot-ui/ui/components/wd-form/types'
import type { SlideVerifyInstance } from '@wot-ui/ui/components/wd-slide-verify/types'
import type { CaptchaInfo, LoginFormData, OAuthProvider } from '@/api/module_system/auth'
import { onLoad } from '@dcloudio/uni-app'
import { reactive, ref } from 'vue'
import AuthAPI from '@/api/module_system/auth'
import { REMEMBER_ME_KEY } from '@/constants'
import { useUserStore } from '@/store/userStore'
import { Storage } from '@/utils/storage'

definePage({ name: 'login', style: { navigationBarTitleText: '登录' } })

const loginFormRef = ref()
const sliderCaptchaRef = ref<SlideVerifyInstance>()
const loading = ref(false)
const userStore = useUserStore()
const redirect = ref('/pages/index/index')

/** 表单验证 schema — 用户名/密码字段级错误提示（wot-ui 函数式校验） */
const loginSchema: FormSchema = {
  validate: (model) => {
    const errors: Array<{ path: Array<string | number>, message: string }> = []
    const username = String(model.username ?? '')
    const password = String(model.password ?? '')
    if (!username)
      errors.push({ path: ['username'], message: '请输入用户名' })
    else if (username.length < 3 || username.length > 20)
      errors.push({ path: ['username'], message: '用户名长度为 3-20 个字符' })
    if (!password)
      errors.push({ path: ['password'], message: '请输入密码' })
    else if (password.length < 6 || password.length > 20)
      errors.push({ path: ['password'], message: '密码长度为 6-20 个字符' })
    return errors
  },
}

const loginFormData = reactive<LoginFormData>({
  username: '',
  password: '',
  captcha: '',
  captcha_key: '',
  remember: true,
  login_type: '移动端',
})

const captchaState = reactive<CaptchaInfo>({ enable: false, key: '', img_base: '' })

/** 滑块验证是否已通过（后端返回 verified=true 后置位） */
const sliderPassed = ref(false)

/** 从本地存储恢复记住的用户名（仅用户名，不存储密码） */
function restoreRememberedUser() {
  const remembered = Storage.get<{ username: string, remember: boolean }>(REMEMBER_ME_KEY)
  if (remembered) {
    loginFormData.username = remembered.username || ''
    loginFormData.remember = remembered.remember ?? true
  }
}

async function getLoginCaptcha() {
  try {
    const result = await AuthAPI.getCaptcha()
    if (result && typeof result === 'object') {
      captchaState.enable = Boolean(result.enable)
      captchaState.key = result.key || ''
      captchaState.img_base = result.img_base || ''
      if (captchaState.enable) {
        loginFormData.captcha_key = captchaState.key
        // 重置滑块到初始状态
        resetSliderCaptcha()
      }
    }
    else {
      captchaState.enable = false
    }
  }
  catch (e) {
    console.error('验证码获取失败', e)
    captchaState.enable = false
  }
}

/**
 * wd-slide-verify 拖动到终点触发 success — 调用后端 slider_complete 接口标记验证完成
 * 后端仅标记 captcha_key 状态为 verified，不校验 x 坐标
 */
async function handleSliderSuccess() {
  if (!captchaState.key) {
    uni.showToast({ title: '验证码已过期，请刷新', icon: 'none' })
    sliderCaptchaRef.value?.reset()
    return
  }

  try {
    const result = await AuthAPI.completeSliderCaptcha({
      captcha_key: captchaState.key,
      x: 100, // 占位值，后端未使用
    })
    if (result?.verified) {
      sliderPassed.value = true
      loginFormData.captcha = 'verified' // 占位值，后端只校验 captcha_key 状态
    }
    else {
      uni.showToast({ title: '验证失败，请重试', icon: 'none' })
      sliderCaptchaRef.value?.reset()
    }
  }
  catch (e) {
    console.error('滑块验证失败', e)
    uni.showToast({ title: '验证失败，请重试', icon: 'none' })
    sliderCaptchaRef.value?.reset()
  }
}

/** 重置滑块验证状态并清空占位验证值（验证码刷新 / 拖动未到终点触发 fail 时） */
function resetSliderCaptcha() {
  sliderPassed.value = false
  loginFormData.captcha = ''
  sliderCaptchaRef.value?.reset()
}

onLoad((options) => {
  const from = options?.redirect ? decodeURIComponent(options.redirect) : ''
  // 安全验证：仅允许本地页面路径，防止开放重定向攻击
  if (from && from !== '/pages/login/index' && from.startsWith('/pages/')) {
    redirect.value = from
  }
  restoreRememberedUser()
  getLoginCaptcha()
})

/** 登录提交 — 防抖 + 字段验证 + 滑块校验 + 错误提示 + 记住密码 */
async function handleSubmit() {
  if (loading.value)
    return

  // 滑块验证前置校验
  if (captchaState.enable && !sliderPassed.value) {
    uni.showToast({ title: '请先完成滑块验证', icon: 'none' })
    return
  }

  loading.value = true
  try {
    const { valid } = await loginFormRef.value.validate()
    if (!valid) {
      loading.value = false
      return
    }
    await userStore.login(loginFormData)
    // 登录成功后处理记住密码：仅存储用户名，不存储密码
    if (loginFormData.remember) {
      Storage.set(REMEMBER_ME_KEY, { username: loginFormData.username, remember: true })
    }
    else {
      Storage.remove(REMEMBER_ME_KEY)
    }
    uni.reLaunch({ url: redirect.value })
  }
  catch {
    uni.showToast({ title: '登录失败，请检查账号密码', icon: 'none', duration: 2500 })
    // 登录失败后自动刷新验证码并重置滑块
    if (captchaState.enable)
      getLoginCaptcha()
  }
  finally {
    loading.value = false
  }
}

/** 第三方 OAuth 登录 */
async function handleOAuth(provider: OAuthProvider) {
  try {
    const result = await AuthAPI.getOAuthLoginUrl(provider)
    if (result?.url) {
      // #ifdef H5
      window.location.href = result.url
      // #endif
      // #ifdef MP-WEIXIN
      uni.setClipboardData({
        data: result.url,
        success: () => {
          uni.showToast({ title: '链接已复制，请在浏览器中打开', icon: 'none' })
        },
      })
      // #endif
    }
  }
  catch {
    uni.showToast({ title: 'OAuth登录失败', icon: 'none' })
  }
}
</script>

<template>
  <view class="login-page">
    <!-- Brand area -->
    <view class="login-brand fade-in-up">
      <image class="brand-logo" src="/static/logo.png" mode="aspectFit" />
      <text class="brand-title">
        FastapiAdmin
      </text>
      <text class="brand-subtitle">
        高效的企业管理移动平台
      </text>
    </view>

    <!-- Form card -->
    <view class="login-card bounce-in">
      <text class="login-card__title">
        账号登录
      </text>

      <wd-form ref="loginFormRef" :model="loginFormData" :schema="loginSchema">
        <!-- Username -->
        <wd-form-item prop="username">
          <view class="login-field">
            <wd-input
              v-model="loginFormData.username"
              placeholder="请输入用户名"
              clearable
              confirm-type="next"
              @confirm="handleSubmit"
            >
              <template #prefix>
                <wd-icon name="user" size="20rpx" color="#9CA3AF" />
              </template>
            </wd-input>
          </view>
        </wd-form-item>

        <!-- Password — show-password 自动启用密码可见性切换 -->
        <wd-form-item prop="password">
          <view class="login-field">
            <wd-input
              v-model="loginFormData.password"
              placeholder="请输入密码"
              show-password
              clearable
              confirm-type="go"
              @confirm="handleSubmit"
            >
              <template #prefix>
                <wd-icon name="lock" size="20rpx" color="#9CA3AF" />
              </template>
            </wd-input>
          </view>
        </wd-form-item>

        <!-- Slider Captcha — wd-slide-verify 滑块拖动验证（条件显示） -->
        <wd-form-item v-if="captchaState.enable">
          <wd-slide-verify
            ref="sliderCaptchaRef"
            text="向右滑动滑块验证"
            success-text="验证成功"
            @success="handleSliderSuccess"
            @fail="resetSliderCaptcha"
          />
        </wd-form-item>

        <!-- 记住密码 + 忘记密码 -->
        <view class="login-options">
          <view class="remember-check" @click="loginFormData.remember = !loginFormData.remember">
            <view class="remember-check__box" :class="{ 'is-checked': loginFormData.remember }">
              <text v-if="loginFormData.remember" class="remember-check__tick">
                ✓
              </text>
            </view>
            <text class="remember-check__label">
              记住密码
            </text>
          </view>
          <text class="forgot-link">
            忘记密码？
          </text>
        </view>

        <!-- Submit -->
        <wd-button
          type="primary"
          :loading="loading"
          round
          block
          @click="handleSubmit"
        >
          {{ loading ? '登录中...' : '登 录' }}
        </wd-button>
      </wd-form>
    </view>

    <!-- OAuth Login -->
    <view class="oauth-section fade-in-up-3">
      <view class="oauth-divider">
        <view class="oauth-divider__line" />
        <text class="oauth-divider__text">
          第三方登录
        </text>
        <view class="oauth-divider__line" />
      </view>
      <view class="oauth-buttons">
        <!-- WeChat -->
        <view class="oauth-btn" @click="handleOAuth('wechat')">
          <view class="oauth-btn__icon" style="background: #07C160">
            <image class="oauth-btn__iconify" src="/static/icons/wechat.svg" />
          </view>
          <text class="oauth-btn__label">
            微信
          </text>
        </view>

        <!-- GitHub -->
        <view class="oauth-btn" @click="handleOAuth('github')">
          <view class="oauth-btn__icon" style="background: #24292F">
            <image class="oauth-btn__iconify" src="/static/icons/github.svg" />
          </view>
          <text class="oauth-btn__label">
            GitHub
          </text>
        </view>

        <!-- Gitee -->
        <view class="oauth-btn" @click="handleOAuth('gitee')">
          <view class="oauth-btn__icon" style="background: #C71D23">
            <image class="oauth-btn__iconify" src="/static/icons/gitee.svg" />
          </view>
          <text class="oauth-btn__label">
            Gitee
          </text>
        </view>

        <!-- QQ -->
        <view class="oauth-btn" @click="handleOAuth('qq')">
          <view class="oauth-btn__icon" style="background: #12B7F5">
            <image class="oauth-btn__iconify" src="/static/icons/qq.svg" />
          </view>
          <text class="oauth-btn__label">
            QQ
          </text>
        </view>
      </view>
    </view>

    <!-- Footer -->
    <view class="login-footer">
      <text class="login-footer__text">
        立即注册 | 游客访问
      </text>
    </view>
  </view>
</template>

<style lang="scss" scoped>
.login-page {
  display: flex;
  flex-direction: column;
  align-items: center;
  /* H5 下 100vh 包含导航栏，使用uni-app的可用视口高度变量避免溢出 */
  /* #ifdef H5 */
  height: calc(100vh - 44px);
  /* #endif */
  /* #ifndef H5 */
  height: 100vh;
  /* #endif */
  padding: 0 64rpx;
  padding-bottom: calc(48rpx + env(safe-area-inset-bottom));
  background: var(--page-bg-color, #F9F9F9);
  overflow: hidden;
  box-sizing: border-box;
}

/* 暗黑模式下整页背景 + 所有子元素继承深色，消除白色断层 */
:deep(.theme-dark) .login-page,
.login-page:has(.theme-dark),
.theme-dark .login-page {
  background: var(--bg-color-1, #0F0F11);
}

/* ===== Brand ===== */
.login-brand {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding-top: 72rpx;
  padding-bottom: 40rpx;
  gap: 12rpx;
  flex-shrink: 0;

  .brand-logo {
    width: 140rpx;
    height: 140rpx;
    margin-bottom: 4rpx;
  }

  .brand-title {
    font-size: var(--font-3xl, 48rpx);
    font-weight: 700;
    color: var(--text-color, #0A1628);

    /* 暗黑模式下使用纯白，提升品牌标题醒目度 */
    :deep(.theme-dark) &,
    .theme-dark & {
      color: #FFFFFF;
    }
  }

  .brand-subtitle {
    font-size: var(--font-md, 28rpx);
    color: var(--text-color-3, #6B7280);

    /* 暗黑下提亮到 --text-color-2，避免 #9CA3AF 在深底上偏暗 */
    :deep(.theme-dark) &,
    .theme-dark & {
      color: var(--text-color-2, #D1D5DB);
    }
  }
}

/* ===== Card（不再是毛玻璃，使用纯色背景 + 与页面背景形成层级差） ===== */
.login-card {
  width: 100%;
  max-width: 654rpx;
  background: var(--card-bg-color, #FFFFFF);
  border-radius: var(--radius-xl, 32rpx);
  padding: 40rpx 36rpx;
  border: 2rpx solid var(--border-color, #EAECF0);
  box-shadow: var(--shadow-md, 0 8rpx 32rpx rgba(15, 23, 42, 0.04));
  margin-bottom: 20rpx;
  flex-shrink: 0;

  /* 暗黑模式：卡片用深色 2 级，页面背景用深色 1 级，形成细微层级差 */
  :deep(.theme-dark) &,
  .theme-dark & {
    background: var(--bg-color-3, #1A1A1A);
    border-color: var(--border-color, #2C2C2E);
    box-shadow: 0 8rpx 32rpx rgba(0, 0, 0, 0.2);
  }

  &__title {
    display: block;
    font-size: var(--font-xl, 36rpx);
    font-weight: 600;
    color: var(--text-color, #0A1628);
    margin-bottom: 28rpx;

    /* 暗黑模式下使用纯白，提升卡片标题醒目度 */
    :deep(.theme-dark) &,
    .theme-dark & {
      color: #FFFFFF;
    }
  }
}

/* ===== 表单输入框容器 — 圆角底色包裹，替代 uview 的 border="surround" ===== */
.login-field {
  background: var(--bg-color-2, #F5F6F8);
  border: 2rpx solid var(--border-color, #EAECF0);
  border-radius: 16rpx;
  padding: 0 20rpx;
  transition: border-color var(--transition-fast, 0.15s ease);
}

/* 暗黑模式适配（wot-ui 输入框主题变量 + 容器背景） */
:deep(.wd-form-item) {
  margin-bottom: 20rpx;
}

.theme-dark :deep(.wd-input) {
  --wot-input-bg: var(--bg-color-3, #2C2C2E);
  --wot-input-inner-color: var(--text-color, #FFFFFF);
  --wot-input-inner-placeholder-color: var(--text-color-4, #6B7280);
}

.theme-dark .login-field {
  background: var(--bg-color-3, #2C2C2E);
  border-color: var(--border-color, #2C2C2E);
}

/* 暗黑模式适配（wot-ui 滑块主题变量 + 深色层级体系） */
.theme-dark :deep(.wd-slide-verify) {
  --wot-slide-verify-bg: var(--bg-color-2, #1C1C1E);
  --wot-slide-verify-button-bg: var(--bg-color-3, #2C2C2E);
  --wot-slide-verify-text-color: var(--text-color-3, #9CA3AF);
}

/* ===== 记住密码 + 忘记密码 ===== */
.login-options {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 28rpx;
  margin-top: 4rpx;
}

.remember-check {
  display: flex;
  align-items: center;
  gap: 12rpx;
  padding: 8rpx 0;

  &__box {
    width: 36rpx;
    height: 36rpx;
    border-radius: 8rpx;
    border: 2rpx solid var(--text-color-4, #B0B0B0);
    display: flex;
    align-items: center;
    justify-content: center;
    transition: background var(--transition-fast, 0.15s ease), border-color var(--transition-fast, 0.15s ease);

    &.is-checked {
      background: var(--primary-color, #4F8CFF);
      border-color: var(--primary-color, #4F8CFF);
    }
  }

  &__tick {
    font-size: 24rpx;
    color: #ffffff;
    line-height: 1;
  }

  &__label {
    font-size: var(--font-md, 28rpx);
    color: var(--text-color-3, #6B7280);
  }
}

.forgot-link {
  font-size: var(--font-md, 28rpx);
  color: var(--primary-color, #4F8CFF);
}

/* ===== OAuth Section ===== */
.oauth-section {
  width: 100%;
  max-width: 654rpx;
  margin-top: 16rpx;
  flex-shrink: 0;
}

.oauth-divider {
  display: flex;
  align-items: center;
  gap: 24rpx;
  margin-bottom: 24rpx;

  &__line {
    flex: 1;
    height: 1rpx;
    background: var(--border-color, #EAEAEA);
  }

  &__text {
    font-size: var(--font-sm, 24rpx);
    color: var(--text-color-4, #B0B0B0);
    flex-shrink: 0;
  }
}

.oauth-buttons {
  display: flex;
  justify-content: center;
  gap: 48rpx;
}

.oauth-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12rpx;

  &__icon {
    width: 88rpx;
    height: 88rpx;
    border-radius: 44rpx;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: transform var(--transition-fast, 0.15s ease);
  }

  &:active &__icon {
    transform: scale(0.92);
  }

  &__iconify {
    width: 48rpx;
    height: 48rpx;
  }

  &__label {
    font-size: var(--font-xs, 20rpx);
    color: var(--text-color-3, #6B7280);
  }
}

/* ===== Footer ===== */
.login-footer {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 24rpx 0 0;
  flex-shrink: 0;

  &__text {
    font-size: var(--font-sm, 24rpx);
    color: var(--text-color-4, #B0B0B0);
  }
}
</style>
