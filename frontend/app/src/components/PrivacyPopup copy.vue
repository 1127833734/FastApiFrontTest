<script lang="ts" setup>
import { onBeforeMount, ref } from 'vue'

interface Props {
  title?: string // 标题
  desc?: string // 描述
  subDesc?: string // 字描述
  protocol?: string // 协议名称
}

withDefaults(defineProps<Props>(), {
  title: '用户隐私保护提示',
  desc: '感谢您使用本应用，您使用本应用的服务之前请仔细阅读并同意',
  subDesc: '。当您点击同意并开始时用产品服务时，即表示你已理解并同意该条款内容，该条款将对您产生法律约束力。如您拒绝，将无法使用相应服务。',
  protocol: '《用户隐私保护指引》',
})

const emit = defineEmits(['agree', 'disagree'])
const showPopup = ref<boolean>(false) // 是否展示popup

/** 微信隐私授权 resolve 类型（wx.onNeedPrivacyAuthorization 回调参数） */
type PrivacyResolve = (options: { event: string, buttonId?: string }) => void

const privacyResolves = ref(new Set<PrivacyResolve>()) // onNeedPrivacyAuthorization的reslove

function privacyHandler(resolve: PrivacyResolve) {
  showPopup.value = true
  privacyResolves.value.add(resolve)
}

onBeforeMount(() => {
  // 注册监听
  if (wx.onNeedPrivacyAuthorization) {
    wx.onNeedPrivacyAuthorization((resolve) => {
      privacyHandler(resolve as unknown as PrivacyResolve)
    })
  }
})

/**
 * 同意隐私协议
 */
function handleAgree() {
  showPopup.value = false
  privacyResolves.value.forEach((resolve) => {
    resolve({
      event: 'agree',
      buttonId: 'agree-btn',
    })
  })
  privacyResolves.value.clear()
  emit('agree')
}

/**
 * 拒绝隐私协议
 */
function handleDisagree() {
  showPopup.value = false
  privacyResolves.value.forEach((resolve) => {
    resolve({
      event: 'disagree',
    })
  })
  privacyResolves.value.clear()
}

/**
 * 打开隐私协议
 */
function openPrivacyContract() {
  wx.openPrivacyContract({})
}

/**
 * 弹出框关闭时清空
 */
function handleClose() {
  privacyResolves.value.clear()
}
</script>

<script lang="ts">
export default {
  options: {
    virtualHost: true,
    addGlobalClass: true,
    styleIsolation: 'shared',
  },
}
</script>

<template>
  <view>
    <u-popup :show="showPopup" mode="center" :close-on-click-overlay="false" :round="16" @close="handleClose">
      <view class="privacy-popup__header">
        <!-- 标题 -->
        <view class="privacy-popup__title">
          {{ title }}
        </view>
      </view>
      <view class="privacy-popup__container">
        <text>{{ desc }}</text>
        <text class="privacy-popup__container-protocol" @click="openPrivacyContract">
          {{ protocol }}
        </text>
        <text>{{ subDesc }}</text>
      </view>
      <view class="privacy-popup__footer">
        <button id="disagree-btn" class="privacy-btn privacy-btn--plain" @click="handleDisagree">
          拒绝
        </button>
        <button
          id="agree-btn"
          class="privacy-btn privacy-btn--primary"
          open-type="agreePrivacyAuthorization"
          @agreeprivacyauthorization="handleAgree"
        >
          同意
        </button>
      </view>
    </u-popup>
  </view>
</template>

<style lang="scss" scoped>
.privacy-popup-container {
  width: 600rpx;
  padding: 0 24rpx;
  box-sizing: border-box;
  border-radius: 32rpx;
  overflow: hidden;
}

.privacy-popup {
  &__header {
    width: 100%;
    height: 128rpx;
    line-height: 128rpx;
    color: var(--text-color, rgba(0, 0, 0, 0.85));
    font-size: var(--font-lg, 30rpx);
    padding: 0 12rpx;
    box-sizing: border-box;
  }

  &__container {
    width: 100%;
    box-sizing: border-box;
    padding: 0 12rpx;
    margin-bottom: 32rpx;

    font-size: var(--font-md, 28rpx);
    line-height: 1.8;
    color: var(--text-color-2, #3e3e3e);
    text-align: left;
    font-weight: 550;
    &-protocol {
      color: var(--primary-color, #4d80f0);
    }
  }

  &__footer {
    display: flex;
    justify-content: space-between;
    padding-bottom: 36rpx;

    button {
      border: none;
      outline: none;
    }
  }
}

.privacy-btn {
  flex: 1;
  height: 80rpx;
  line-height: 80rpx;
  border-radius: 40rpx;
  font-size: var(--font-md, 28rpx);
  text-align: center;
  transition: opacity 0.15s ease;

  &--plain {
    background: transparent;
    border: 2rpx solid var(--border-color, #ccc);
    color: var(--text-color-3, #666);
    margin-right: 20rpx;
  }

  &--primary {
    background: var(--primary-color, #4d80f0);
    color: var(--text-color-inverse, #fff);
  }
}
</style>
