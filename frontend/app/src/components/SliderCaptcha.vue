<script lang="ts" setup>
/**
 * 滑块验证码组件
 *
 * 采用手动拖拽实现（参考 web 端 FaDragVerify）：
 * - 触摸/鼠标按下时记录起点，移动时计算 起点 + (当前位移)，直接驱动 transform
 * - 拖动中 transition 置 none，保证"跟手"无迟滞；松开后复位/成功走 0.3s 过渡
 * - 相比 movable-view，无受控 :x 回写冲突、无 rpx/px 混算导致的阈值偏差
 * - 跨端：小程序走 touch 事件（catchtouchmove 阻止页面滚动），H5 额外兼容鼠标
 */
const props = defineProps<{
  status?: 'idle' | 'pending' | 'success' | 'fail'
}>()

const emit = defineEmits<{
  (e: 'verify'): void
  (e: 'reset'): void
}>()

const trackWidth = ref(0) // px，实测
const buttonWidth = ref(0) // px，实测
const offsetX = ref(0) // 按钮相对轨道左端的位移（px）
const dragging = ref(false)
const innerStatus = ref<'idle' | 'pending' | 'success' | 'fail'>(props.status || 'idle')

const SLIDER_SIZE = 88 // rpx
const TRACK_HEIGHT = 64 // rpx

let startPageX = 0
let startOffset = 0

const buttonEl = ref<HTMLElement | null>(null)

/** 可移动范围（px）：轨道宽 - 按钮宽，均以 px 实测，避免 rpx/px 混算 */
const maxMoveX = computed(() => {
  const btnW = buttonWidth.value || trackWidth.value * 0.16
  return Math.max(0, trackWidth.value - btnW)
})

function clamp(v: number, min: number, max: number) {
  return Math.max(min, Math.min(max, v))
}

watch(() => props.status, (val) => {
  if (val && val !== innerStatus.value) {
    innerStatus.value = val
    if (val === 'success')
      offsetX.value = maxMoveX.value
    if (val === 'fail') {
      setTimeout(() => reset(), 600)
    }
  }
})

// ---------- 触摸（小程序 / H5 触屏） ----------
function onTouchStart(e: TouchEvent) {
  if (innerStatus.value === 'success' || innerStatus.value === 'pending')
    return
  innerStatus.value = 'idle'
  dragging.value = true
  startPageX = e.touches?.[0]?.pageX ?? 0
  startOffset = offsetX.value
}

function onTouchMove(e: TouchEvent) {
  if (!dragging.value)
    return
  const pageX = e.touches?.[0]?.pageX ?? 0
  offsetX.value = clamp(startOffset + (pageX - startPageX), 0, maxMoveX.value)
}

function onTouchEnd() {
  finishDrag()
}

// ---------- H5 鼠标（onMounted 中以 DOM 监听器附加到滑块按钮） ----------
// #ifdef H5
function onMouseDown(e: MouseEvent) {
  e.preventDefault()
  e.stopPropagation()
  if (innerStatus.value === 'success' || innerStatus.value === 'pending')
    return
  innerStatus.value = 'idle'
  dragging.value = true
  startPageX = e.pageX
  startOffset = offsetX.value
  document.addEventListener('mousemove', onMouseMove)
  document.addEventListener('mouseup', onMouseUp)
}

function onMouseMove(e: MouseEvent) {
  if (!dragging.value)
    return
  offsetX.value = clamp(startOffset + (e.pageX - startPageX), 0, maxMoveX.value)
}

function onMouseUp() {
  document.removeEventListener('mousemove', onMouseMove)
  document.removeEventListener('mouseup', onMouseUp)
  finishDrag()
}
// #endif

/** 松开手指/鼠标：到末端触发验证，否则回弹复位 */
function finishDrag() {
  if (!dragging.value)
    return
  dragging.value = false
  if (innerStatus.value === 'success' || innerStatus.value === 'pending')
    return

  if (offsetX.value >= maxMoveX.value - 10) {
    innerStatus.value = 'pending'
    emit('verify')
  }
  else {
    // 过渡动画由 CSS transition 驱动（松开后自动恢复 transition）
    offsetX.value = 0
  }
}

function reset() {
  dragging.value = false
  offsetX.value = 0
  innerStatus.value = 'idle'
  emit('reset')
}

defineExpose({ reset })

/** 进度条宽度：从轨道左端铺到按钮中心，视觉与 web 端一致 */
const fillWidth = computed(() => offsetX.value + buttonWidth.value / 2)

const buttonStyle = computed(() => ({
  width: `${SLIDER_SIZE}rpx`,
  height: `${TRACK_HEIGHT}rpx`,
  transform: `translateX(${offsetX.value}px)`,
  transition: dragging.value ? 'none' : 'transform 0.3s ease',
}))

const fillStyle = computed(() => ({
  width: `${fillWidth.value}px`,
  transition: dragging.value ? 'none' : 'width 0.3s ease',
}))

const tipText = computed(() => {
  switch (innerStatus.value) {
    case 'success': return '验证成功'
    case 'pending': return '验证中...'
    case 'fail': return '验证失败，请重试'
    default: return '向右滑动滑块验证'
  }
})

onMounted(() => {
  nextTick(() => {
    uni.createSelectorQuery()
      .select('.slider-track')
      .boundingClientRect((rect: UniApp.NodeInfo | UniApp.NodeInfo[]) => {
        const node = Array.isArray(rect) ? rect[0] : rect
        if (node?.width != null)
          trackWidth.value = node.width
      })
      .select('.slider-button')
      .boundingClientRect((rect: UniApp.NodeInfo | UniApp.NodeInfo[]) => {
        const node = Array.isArray(rect) ? rect[0] : rect
        if (node?.width != null)
          buttonWidth.value = node.width
      })
      .exec()
    // #ifdef H5
    buttonEl.value?.addEventListener('mousedown', onMouseDown)
    // #endif
  })
})

// #ifdef H5
onBeforeUnmount(() => {
  buttonEl.value?.removeEventListener('mousedown', onMouseDown)
  document.removeEventListener('mousemove', onMouseMove)
  document.removeEventListener('mouseup', onMouseUp)
})
// #endif
</script>

<template>
  <view class="slider-captcha">
    <view
      class="slider-track"
      :class="[`is-${innerStatus}`]"
    >
      <!-- 进度填充 -->
      <view
        class="slider-track__fill"
        :style="fillStyle"
      />

      <!-- 提示文字 -->
      <text class="slider-track__tip" :class="{ 'slider-track__tip--static': innerStatus !== 'idle' }">
        {{ tipText }}
      </text>

      <!-- 滑块按钮：触摸直接驱动（H5 鼠标事件在 onMounted 中以 DOM 监听器附加） -->
      <view
        ref="buttonEl"
        class="slider-button"
        :class="[`is-${innerStatus}`]"
        :style="buttonStyle"
        @touchstart.stop="onTouchStart"
        @touchmove.stop.prevent="onTouchMove"
        @touchend="onTouchEnd"
        @touchcancel="onTouchEnd"
      >
        <text v-if="innerStatus === 'success'" class="slider-button__icon">
          ✓
        </text>
        <text v-else-if="innerStatus === 'fail'" class="slider-button__icon">
          ✕
        </text>
        <text v-else class="slider-button__icon slider-button__icon--arrow">
          →
        </text>
      </view>
    </view>
  </view>
</template>

<style lang="scss" scoped>
.slider-captcha {
  width: 100%;
  user-select: none;
}

.slider-track {
  position: relative;
  width: 100%;
  height: 64rpx;
  border-radius: 32rpx;
  background: var(--bg-color-2, #F3F4F6);
  border: 2rpx solid var(--border-color, #EAEAEA);
  overflow: hidden;
  transition: border-color 0.2s ease, background 0.2s ease;

  &.is-success {
    border-color: #10B981;
    background: rgba(16, 185, 129, 0.08);
  }

  &.is-fail {
    border-color: #EF4444;
    background: rgba(239, 68, 68, 0.08);
  }

  &.is-pending {
    border-color: var(--primary-color, #4F8CFF);
  }

  &__fill {
    position: absolute;
    top: 0;
    left: 0;
    height: 100%;
    background: linear-gradient(90deg, rgba(79, 140, 255, 0.15), rgba(79, 140, 255, 0.25));
    border-radius: 32rpx 0 0 32rpx;
    z-index: 0;
  }

  &.is-success &__fill {
    background: linear-gradient(90deg, rgba(16, 185, 129, 0.3), rgba(16, 185, 129, 0.5));
  }

  &.is-fail &__fill {
    background: linear-gradient(90deg, rgba(239, 68, 68, 0.3), rgba(239, 68, 68, 0.5));
  }

  &__tip {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    font-size: var(--font-sm, 24rpx);
    color: var(--text-color-4, #B0B0B0);
    z-index: 1;
    pointer-events: none;
    white-space: nowrap;

    &--static {
      opacity: 0.5;
    }
  }
}

.slider-button {
  position: absolute;
  top: 0;
  left: 0;
  z-index: 3;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 30rpx;
  background: #ffffff;
  border: 2rpx solid var(--border-color, #EAEAEA);
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.08);
  transition: background 0.2s ease, border-color 0.2s ease;
  will-change: transform;

  &.is-success {
    background: #10B981;
    border-color: #10B981;
  }

  &.is-fail {
    background: #EF4444;
    border-color: #EF4444;
  }

  &.is-pending {
    background: var(--primary-color, #4F8CFF);
    border-color: var(--primary-color, #4F8CFF);
  }

  &__icon {
    font-size: 28rpx;
    color: #ffffff;
    font-weight: 700;
    line-height: 1;

    &--arrow {
      color: var(--text-color-4, #B0B0B0);
      font-size: 32rpx;
    }
  }
}

/* 暗黑模式适配 */
:global(.theme-dark) .slider-track {
  background: var(--bg-color-2, #1C1C1E);
  border-color: var(--border-color, #2C2C2E);
}

:global(.theme-dark) .slider-track__tip {
  color: var(--text-color-3, #9CA3AF);
}

:global(.theme-dark) .slider-button {
  background: var(--bg-color-3, #2C2C2E);
  border-color: var(--border-color, #2C2C2E);
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.3);
}

:global(.theme-dark) .slider-button__icon--arrow {
  color: var(--text-color-3, #9CA3AF);
}
</style>
