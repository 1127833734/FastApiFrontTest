<script lang="ts" setup>
import type { PropType } from 'vue'
import dayjs from 'dayjs'
import { computed, ref, watch } from 'vue'

const props = defineProps({
  modelValue: {
    type: [Array, String] as PropType<[string, string] | string | undefined>,
    default: () => undefined,
  },
  placeholder: {
    type: String,
    default: '请选择时间范围',
  },
  label: {
    type: String,
    default: '',
  },
})

const emit = defineEmits(['update:modelValue'])

const visible = ref(false)
const dateRange = ref<number[] | null>(null)

watch(
  () => props.modelValue,
  (val) => {
    if (Array.isArray(val) && val.length === 2 && val[0] && val[1]) {
      dateRange.value = val.map(item => new Date(item).getTime())
    }
    else if (typeof val === 'string' && val.includes(',')) {
      const [startDate, endDate] = val.split(',')

      if (
        startDate
        && endDate
        && !Number.isNaN(new Date(startDate).getTime())
        && !Number.isNaN(new Date(endDate).getTime())
      ) {
        dateRange.value = [
          new Date(startDate).getTime(),
          new Date(endDate).getTime(),
        ]
      }
      else {
        dateRange.value = null
      }
    }
    else {
      dateRange.value = null
    }
  },
  {
    immediate: true,
  },
)

/** 已选范围的展示文本（优先显示实际选中值，未选时显示 placeholder） */
const displayText = computed(() => {
  if (Array.isArray(props.modelValue) && props.modelValue.length === 2) {
    return `${props.modelValue[0]} ~ ${props.modelValue[1]}`
  }
  if (typeof props.modelValue === 'string' && props.modelValue.includes(',')) {
    return props.modelValue.replace(',', ' ~ ')
  }
  return ''
})

/** wd-calendar 确认回调：value 为 13 位时间戳数组 */
function handleConfirm({ value }: { value: number[] }) {
  if (Array.isArray(value) && value.length === 2) {
    const startDate = dayjs(value[0]).format('YYYY-MM-DD')
    const endDate = dayjs(value[1]).format('YYYY-MM-DD')

    let newVal: [string, string] | string = [startDate, endDate]

    // #ifdef MP-WEIXIN
    newVal = `${startDate},${endDate}`
    // #endif

    emit('update:modelValue', newVal)
  }
  visible.value = false
}
</script>

<template>
  <view>
    <wd-cell
      :title="label || '时间范围'"
      :value="displayText || placeholder"
      is-link
      @click="visible = true"
    />
    <wd-calendar
      v-model="dateRange"
      type="daterange"
      :visible="visible"
      @confirm="handleConfirm"
      @update:visible="visible = $event"
    />
  </view>
</template>

<style scoped>
.time-filter {
  padding: 16rpx;
}
</style>
