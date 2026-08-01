<script setup lang="ts">
defineProps<{
  text?: string
  icon?: string
}>()
</script>

<template>
  <view class="empty-state">
    <wd-icon :name="icon || 'no-content'" size="48rpx" custom-class="empty-state__icon" />
    <text class="empty-state__text">
      {{ text || '暂无数据' }}
    </text>
  </view>
</template>
