<script setup lang="ts">
/**
 * 状态徽标组件
 * 用于统一展示启用/禁用/草稿/发布等状态
 */
withDefaults(defineProps<{
  status?: string | boolean | number
  /** 自定义映射: { '0': 'enabled', '1': 'disabled', true: 'enabled', false: 'disabled' } */
  map?: Record<string, string>
  /** 自定义标签文本 */
  label?: string
  /** 仅显示圆点 */
  dot?: boolean
}>(), {
  status: '',
  label: '',
  dot: false,
})

const statusMap: Record<string, { label: string, cls: string }> = {
  enabled: { label: '启用', cls: 'status-badge--enabled' },
  disabled: { label: '禁用', cls: 'status-badge--disabled' },
  draft: { label: '草稿', cls: 'status-badge--draft' },
  published: { label: '发布', cls: 'status-badge--primary' },
  archived: { label: '归档', cls: 'status-badge--disabled' },
  active: { label: '活跃', cls: 'status-badge--primary' },
  success: { label: '成功', cls: 'status-badge--enabled' },
  failed: { label: '失败', cls: 'status-badge--danger' },
  pending: { label: '待处理', cls: 'status-badge--draft' },
  processing: { label: '处理中', cls: 'status-badge--primary' },
  completed: { label: '已完成', cls: 'status-badge--enabled' },
  closed: { label: '已关闭', cls: 'status-badge--disabled' },
  deprecated: { label: '已废弃', cls: 'status-badge--danger' },
  expired: { label: '过期', cls: 'status-badge--danger' },
}

function resolve(input: string | boolean | number): { label: string, cls: string } {
  if (input === true || input === 'true' || input === '1' || input === 1 || input === '0' || input === 0 || input === false || input === 'false') {
    // 后端规范: 0=启用, 1=禁用
    const isEnabled = input === 0 || input === '0' || input === true || input === 'true'
    return isEnabled
      ? { label: '启用', cls: 'status-badge--enabled' }
      : { label: '禁用', cls: 'status-badge--disabled' }
  }
  return statusMap[String(input)] || { label: String(input), cls: 'status-badge--disabled' }
}
</script>

<template>
  <text v-if="dot" class="status-badge--dot" :class="resolve(status).cls" />
  <text v-else class="status-badge" :class="resolve(status).cls">
    <text class="status-badge--dot" :class="resolve(status).cls" />
    {{ label || resolve(status).label }}
  </text>
</template>
