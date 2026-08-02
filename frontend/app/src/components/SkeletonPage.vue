<script setup lang="ts">
/**
 * 页面骨架屏组件
 * 在数据加载时展示占位内容，提升感知性能
 */
withDefaults(defineProps<{
  /** 显示行数（列表行） */
  rows?: number
  /** 是否显示搜索栏骨架 */
  search?: boolean
  /** 是否显示操作栏骨架 */
  action?: boolean
}>(), {
  rows: 5,
})
</script>

<template>
  <view class="p-sm">
    <!-- 搜索栏骨架 -->
    <view v-if="search" class="admin-card mb-md p-md">
      <view class="skeleton-block" style="height: 64rpx; width: 100%; border-radius: var(--radius-md);" />
    </view>
    <!-- 多行列表骨架 -->
    <view class="admin-card p-sm">
      <view v-for="i in rows" :key="i" class="gap-md p-md flex items-center" :style="{ borderBottom: i < rows ? '1px solid var(--border-color)' : 'none' }">
        <view class="skeleton-block" style="width: 64rpx; height: 64rpx; border-radius: 50%; flex-shrink: 0;" />
        <view class="flex-1">
          <view class="skeleton-block" style="height: 28rpx; width: 40%; border-radius: var(--radius-sm);" />
          <view class="skeleton-block mt-sm" style="height: 22rpx; width: 70%; border-radius: var(--radius-sm);" />
        </view>
        <view class="skeleton-block" style="width: 80rpx; height: 40rpx; border-radius: var(--radius-full);" />
      </view>
    </view>
  </view>
</template>

<style scoped>
.skeleton-block {
  background: linear-gradient(90deg, var(--bg-color-3, #EAEAEA) 25%, var(--bg-color-2, #F5F6F8) 50%, var(--bg-color-3, #EAEAEA) 75%);
  background-size: 200% 100%;
  animation: shimmer 1.5s ease-in-out infinite;
}

@keyframes shimmer {
  0% { background-position: -200% 0; }
  100% { background-position: 200% 0; }
}
</style>
