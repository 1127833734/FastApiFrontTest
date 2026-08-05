<script lang="ts" setup>
import type { FormSchema } from '@wot-ui/ui/components/wd-form/types'
import type { SlideVerifyInstance } from '@wot-ui/ui/components/wd-slide-verify/types'
import type { CaptchaInfo, LoginFormData, OAuthProvider } from '@/api/module_system/auth'
import { onLoad } from '@dcloudio/uni-app'
import { computed, nextTick, reactive, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import AuthAPI from '@/api/module_system/auth'
import { REMEMBER_ME_KEY } from '@/constants'
import { useWxLogin } from '@/composables/useWxLogin'
import { useConfigStore } from '@/store/configStore'
import { useUserStore } from '@/store/userStore'
import { Storage } from '@/utils/storage'

definePage({ name: 'login', style: { navigationBarTitleText: '登录' } })

const { t } = useI18n()
const loginFormRef = ref()
const sliderCaptchaRef = ref<SlideVerifyInstance>()
const loading = ref(false)
const userStore = useUserStore()
const configStore = useConfigStore()
const { wxLogin, wxPhoneLogin } = useWxLogin()
const redirect = ref('/pages/index/index')

/** 品牌区参数（来自后端系统参数，带默认值兜底；web 端消费方式：configData?.[key]?.config_value） */
const brandLogo = computed(() => configStore.configData?.logo_url?.config_value?.trim() || '/static/logo.png')
const brandTitle = computed(() => configStore.configData?.sys_name?.config_value?.trim() || 'FastapiAdmin')
const brandSubtitle = computed(() => configStore.configData?.login_title?.config_value?.trim() || '高效的企业管理移动平台')

/** 表单验证 schema — 用户名/密码字段级错误提示（wot-ui 函数式校验） */
const loginSchema: FormSchema = {
  validate: (model) => {
    const errors: Array<{ path: Array<string | number>, message: string }> = []
    const username = String(model.username ?? '')
    const password = String(model.password ?? '')
    if (!username)
      errors.push({ path: ['username'], message: t('login.usernameRequired') })
    else if (username.length < 3 || username.length > 20)
      errors.push({ path: ['username'], message: t('login.usernameLength') })
    if (!password)
      errors.push({ path: ['password'], message: t('login.passwordRequired') })
    else if (password.length < 6 || password.length > 20)
      errors.push({ path: ['password'], message: t('login.passwordLength') })
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

/**
 * wd-slide-verify 在小程序端 onMounted 时容器可能尚未完成布局，
 * getRect 测量到 0 宽高 → maxPosition=0 → 滑块无法拖动。
 * 渲染完成后延迟重试 init()，直至组件实例就绪并重新测量。
 */
watch(() => captchaState.enable, async (enabled) => {
  if (!enabled)
    return
  await nextTick()
  retrySliderInit()
})

function retrySliderInit(retry = 0) {
  const verify = sliderCaptchaRef.value
  if (!verify) {
    if (retry < 5)
      setTimeout(() => retrySliderInit(retry + 1), 120)
    return
  }
  verify.init()
}

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
    uni.showToast({ title: t('login.captchaExpired'), icon: 'none' })
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
      uni.showToast({ title: t('login.sliderFailed'), icon: 'none' })
      sliderCaptchaRef.value?.reset()
    }
  }
  catch (e) {
    console.error('滑块验证失败', e)
    uni.showToast({ title: t('login.sliderFailed'), icon: 'none' })
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
  // 拉取系统参数（品牌区 logo/标题/副标题），幂等 + 本地持久化缓存
  configStore.getConfig()
})

/** 登录提交 — 防抖 + 字段验证 + 滑块校验 + 错误提示 + 记住密码 */
async function handleSubmit() {
  if (loading.value)
    return

  // 滑块验证前置校验
  if (captchaState.enable && !sliderPassed.value) {
    uni.showToast({ title: t('login.sliderRequired'), icon: 'none' })
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
    uni.showToast({ title: t('login.loginFailed'), icon: 'none', duration: 2500 })
    // 登录失败后自动刷新验证码并重置滑块
    if (captchaState.enable)
      getLoginCaptcha()
  }
  finally {
    loading.value = false
  }
}

/** 跳转注册页 */
function goRegister() {
  uni.navigateTo({ url: '/pages/login/register/index' })
}

/** 跳转忘记密码页 */
function goForget() {
  uni.navigateTo({ url: '/pages/login/forget/index' })
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
          uni.showToast({ title: t('login.oauthCopyTip'), icon: 'none' })
        },
      })
      // #endif
    }
  }
  catch {
    uni.showToast({ title: t('login.oauthFailed'), icon: 'none' })
  }
}

/** 微信一键登录（仅小程序端显示按钮） */
const wxLoading = ref(false)
async function handleWxLogin() {
  if (wxLoading.value)
    return
  wxLoading.value = true
  try {
    await wxLogin()
    uni.reLaunch({ url: redirect.value })
  }
  catch {
    uni.showToast({ title: '微信登录失败，请重试', icon: 'none' })
  }
  finally {
    wxLoading.value = false
  }
}

/** 微信手机号登录（配合 open-type="getPhoneNumber"） */
async function handleWxPhoneLogin(e: any) {
  if (e.detail.errMsg !== 'getPhoneNumber:ok') {
    uni.showToast({ title: '已取消手机号授权', icon: 'none' })
    return
  }
  wxLoading.value = true
  try {
    await wxPhoneLogin(e.detail.code)
    uni.reLaunch({ url: redirect.value })
  }
  catch {
    uni.showToast({ title: '手机号登录失败，请重试', icon: 'none' })
  }
  finally {
    wxLoading.value = false
  }
}
</script>

<template>
  <view class="login-page">
    <!-- Brand area -->
    <view class="login-brand">
      <image class="brand-logo" :src="brandLogo" mode="aspectFit" />
      <text class="brand-title">
        {{ brandTitle }}
      </text>
      <text class="brand-subtitle">
        {{ brandSubtitle }}
      </text>
    </view>

    <!-- Form card -->
    <view class="login-card">
      <text class="login-card__title">
        {{ $t('login.cardTitle') }}
      </text>

      <!-- 微信一键登录（仅小程序端显示） -->
      <!-- #ifdef MP-WEIXIN -->
      <view class="wx-login-section">
        <wd-button
          type="primary"
          :loading="wxLoading"
          round
          block
          @click="handleWxLogin"
        >
          <wd-icon name="wechat" size="18px" color="#FFFFFF" />
          <text class="ml-1">微信一键登录</text>
        </wd-button>
        <wd-button
          plain
          round
          block
          custom-class="mt-3"
          :loading="wxLoading"
          open-type="getPhoneNumber"
          @getphonenumber="handleWxPhoneLogin"
        >
          手机号快速登录
        </wd-button>
      </view>
      <wd-divider>或账号密码登录</wd-divider>
      <!-- #endif -->

      <wd-form ref="loginFormRef" :model="loginFormData" :schema="loginSchema">
        <!-- Username — wot 原生 wd-input，前缀图标走 prefix-icon 属性 -->
        <wd-form-item prop="username">
          <wd-input
            v-model="loginFormData.username"
            :placeholder="$t('login.usernamePlaceholder')"
            clearable
            confirm-type="next"
            :compact="false"
            prefix-icon="user"
            @confirm="handleSubmit"
          />
        </wd-form-item>

        <!-- Password — show-password 自动启用密码可见性切换 -->
        <wd-form-item prop="password">
          <wd-input
            v-model="loginFormData.password"
            :placeholder="$t('login.passwordPlaceholder')"
            clearable
            show-password
            confirm-type="go"
            :compact="false"
            prefix-icon="lock"
            @confirm="handleSubmit"
          />
        </wd-form-item>

        <!-- Slider Captcha — wd-slide-verify 滑块拖动验证（条件显示） -->
        <wd-form-item v-if="captchaState.enable">
          <wd-slide-verify
            ref="sliderCaptchaRef"
            :text="$t('login.sliderText')"
            :success-text="$t('login.sliderSuccessText')"
            @success="handleSliderSuccess"
            @fail="resetSliderCaptcha"
          />
        </wd-form-item>

        <!-- 记住密码 + 忘记密码 -->
        <view class="login-options">
          <wd-checkbox v-model="loginFormData.remember" size="18px">
            {{ $t('login.remember') }}
          </wd-checkbox>
          <text class="forgot-link wot-text-primary" @click="goForget">
            {{ $t('login.forgot') }}
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
          {{ loading ? $t('login.submitting') : $t('login.submit') }}
        </wd-button>
      </wd-form>
    </view>

    <!-- OAuth Login -->
    <view class="oauth-section">
      <wd-divider>{{ $t('login.thirdParty') }}</wd-divider>
      <wd-grid :column="4" clickable :gutter="10">
        <!-- WeChat -->
        <wd-grid-item @click="handleOAuth('wechat')">
          <view class="oauth-btn__icon" style="background: #07C160">
            <image class="oauth-btn__iconify" src="/static/icons/wechat.svg" />
          </view>
          <text class="oauth-btn__label">
            {{ $t('login.wechat') }}
          </text>
        </wd-grid-item>

        <!-- GitHub -->
        <wd-grid-item @click="handleOAuth('github')">
          <view class="oauth-btn__icon" style="background: #24292F">
            <image class="oauth-btn__iconify" src="/static/icons/github.svg" />
          </view>
          <text class="oauth-btn__label">
            {{ $t('login.github') }}
          </text>
        </wd-grid-item>

        <!-- Gitee -->
        <wd-grid-item @click="handleOAuth('gitee')">
          <view class="oauth-btn__icon" style="background: #C71D23">
            <image class="oauth-btn__iconify" src="/static/icons/gitee.svg" />
          </view>
          <text class="oauth-btn__label">
            {{ $t('login.gitee') }}
          </text>
        </wd-grid-item>

        <!-- QQ -->
        <wd-grid-item @click="handleOAuth('qq')">
          <view class="oauth-btn__icon" style="background: #12B7F5">
            <image class="oauth-btn__iconify" src="/static/icons/qq.svg" />
          </view>
          <text class="oauth-btn__label">
            {{ $t('login.qq') }}
          </text>
        </wd-grid-item>
      </wd-grid>
    </view>

    <!-- Footer -->
    <view class="login-footer">
      <text class="login-footer__text">
        {{ $t('login.noAccount') }}
      </text>
      <text class="login-footer__link wot-text-primary" @click="goRegister">
        {{ $t('login.toRegister') }}
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
  padding-bottom: calc(32rpx + env(safe-area-inset-bottom));
  background: var(--page-bg-color, #F9F9F9);
  overflow: hidden;
  box-sizing: border-box;
}

/* 暗黑模式下整页背景变深，消除白色断层（wot 根类为 wot-theme-dark） */
.wot-theme-dark .login-page {
  background: var(--bg-color-1, #0F0F11);
}

/* ===== Brand ===== */
.login-brand {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding-top: 48rpx;
  padding-bottom: 32rpx;
  gap: 10rpx;
  flex-shrink: 0;

  .brand-logo {
    width: 104rpx;
    height: 104rpx;
  }

  .brand-title {
    font-size: var(--font-3xl, 48rpx);
    font-weight: 700;
    color: var(--text-color, #0A1628);

    /* 暗黑模式下使用纯白，提升品牌标题醒目度 */
    .wot-theme-dark & {
      color: #FFFFFF;
    }
  }

  .brand-subtitle {
    font-size: var(--font-md, 28rpx);
    color: var(--text-color-3, #6B7280);

    /* 暗黑下提亮到 --text-color-2，避免 #9CA3AF 在深底上偏暗 */
    .wot-theme-dark & {
      color: var(--text-color-2, #D1D5DB);
    }
  }
}

/* ===== Card（不再是毛玻璃，使用纯色背景 + 与页面背景形成层级差） ===== */
.login-card {
  width: 100%;
  background: var(--card-bg-color, #FFFFFF);
  border-radius: var(--radius-xl, 32rpx);
  padding: 28rpx 36rpx;
  border: 2rpx solid var(--border-color, #EAECF0);
  box-shadow: var(--shadow-md, 0 8rpx 32rpx rgba(15, 23, 42, 0.04));
  margin-bottom: 12rpx;
  flex-shrink: 0;

  /* 暗黑模式：卡片用深色 2 级，页面背景用深色 1 级，形成细微层级差 */
  .wot-theme-dark & {
    background: var(--bg-color-3, #1A1A1A);
    border-color: var(--border-color, #2C2C2E);
    box-shadow: 0 8rpx 32rpx rgba(0, 0, 0, 0.2);
  }

  &__title {
    display: block;
    font-size: var(--font-xl, 36rpx);
    font-weight: 600;
    color: var(--text-color, #0A1628);
    margin-bottom: 18rpx;

    /* 暗黑模式下使用纯白，提升卡片标题醒目度 */
    .wot-theme-dark & {
      color: #FFFFFF;
    }
  }
}

/* 输入框原生微调 — wot 自带底色/内边距/图标，仅补圆角 */
:deep(.wd-input) {
  border-radius: 16rpx;
}

/* 暗黑下 wot 的 filled-oppo 回退纯黑，与卡片/页面层级脱节：
   cell 容器回归透明，输入框回落深灰圆角块 */
.wot-theme-dark .login-page :deep(.wd-cell) {
  --wot-cell-bg: transparent;
}

.wot-theme-dark .login-page :deep(.wd-input) {
  --wot-input-bg: var(--bg-color-3, #2C2C2E);
}

:deep(.wd-form-item) {
  margin-bottom: 14rpx;
  /* 去掉 wd-cell 自带左右内边距，使输入框/滑块与登录按钮同宽 */
  padding-left: 0;
  padding-right: 0;
}

/* ===== 记住密码 + 忘记密码 ===== */
.login-options {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 16rpx;
}

.forgot-link {
  font-size: var(--font-md, 28rpx);
}

/* ===== OAuth Section ===== */
.oauth-section {
  width: 100%;
  margin-top: 8rpx;
  flex-shrink: 0;

  /* 去掉宫格项默认填充背景，仅保留图标/文字与轻量点击反馈 */
  :deep(.wd-grid-item) {
    --wot-grid-item-bg: transparent;
  }
}

/* ===== 微信一键登录区域 ===== */
.wx-login-section {
  margin-bottom: 16rpx;

  :deep(.wd-button) {
    height: 88rpx;
    font-size: 30rpx;
  }
}

.oauth-btn__icon {
  width: 72rpx;
  height: 72rpx;
  border-radius: 36rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.oauth-btn__iconify {
  width: 40rpx;
  height: 40rpx;
}

.oauth-btn__label {
  font-size: var(--font-xs, 20rpx);
  color: var(--text-color-3, #6B7280);
}

/* ===== Footer ===== */
.login-footer {
  display: flex;
  flex-direction: row;
  align-items: center;
  justify-content: center;
  gap: 8rpx;
  padding: 12rpx 0 0;
  flex-shrink: 0;

  &__text {
    font-size: var(--font-sm, 24rpx);
    color: var(--text-color-3, #6B7280);
  }

  &__link {
    font-size: var(--font-sm, 24rpx);
  }
}
</style>
