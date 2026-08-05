<script lang="ts" setup>
const { enabled: watermarkEnabled, content: watermarkContent } = useWatermark()
</script>

<script lang="ts">
export default {
  options: {
    addGlobalClass: true,
    virtualHost: true,
    styleIsolation: 'shared',
  },
}
</script>

<template>
  <slot />
  <!-- #ifdef MP-WEIXIN -->
  <wd-watermark v-if="watermarkEnabled" :content="watermarkContent" />
  <!-- #endif -->
</template>
