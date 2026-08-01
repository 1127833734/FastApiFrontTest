<script lang="ts" setup>
import type { GlobalMessageOptions } from '@/composables/useGlobalMessage'

const { messageOptions, currentPage } = storeToRefs(useGlobalMessage())
const currentPath = getCurrentPath()

watch(() => messageOptions.value, (newVal) => {
  if (newVal && currentPage.value === currentPath) {
    const option: GlobalMessageOptions = { ...newVal }
    uni.showModal({
      title: option.title || '',
      content: option.content || '',
      showCancel: option.showCancel ?? (option.type === 'confirm'),
      confirmText: option.confirmText || '确定',
      cancelText: option.cancelText || '取消',
      success: (res) => {
        option.success?.({ confirm: res.confirm, cancel: res.cancel })
      },
      fail: (err) => {
        option.fail?.(err)
      },
    })
  }
})
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
  <view />
</template>
