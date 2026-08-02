<script setup lang="ts">
/**
 * 分页栏组件
 * 统一列表页的翻页 UI（上一页 / 页码 / 下一页），替代各页面重复的分页模板
 */
const props = defineProps<{
  current: number
  pageSize: number
  total: number
}>()

const emit = defineEmits<{ prev: [], next: [] }>()

const totalPages = computed(() => Math.ceil(props.total / props.pageSize) || 1)
const show = computed(() => props.total > props.pageSize)
const hasPrev = computed(() => props.current > 1)
const hasNext = computed(() => props.current < totalPages.value)
</script>

<template>
  <view v-if="show" class="flex items-center justify-center gap-sm py-sm">
    <wd-button size="small" variant="plain" :disabled="!hasPrev" @click="emit('prev')">
      上一页
    </wd-button>
    <text class="mx-sm text-sm">
      {{ current }} / {{ totalPages }}
    </text>
    <wd-button size="small" variant="plain" :disabled="!hasNext" @click="emit('next')">
      下一页
    </wd-button>
  </view>
</template>
