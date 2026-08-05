import { computed, onMounted, ref } from 'vue'
import { WATERMARK_KEY } from '@/constants'
import { useUserStore } from '@/store/userStore'
import { Storage } from '@/utils/storage'

/**
 * 小程序水印逻辑（配合 wd-watermark 使用）
 * - 显示条件：本地偏好开启（默认开，由设置页"水印"开关控制）&& 已登录
 * - 水印内容为当前登录用户名（username 优先，回退 name）
 */
export function useWatermark() {
  const userStore = useUserStore()
  const enabled = ref(false)

  const content = computed(() => userStore.userInfo?.username || userStore.userInfo?.name || '')

  onMounted(() => {
    const localSwitch = Storage.get<boolean>(WATERMARK_KEY) ?? true
    enabled.value = localSwitch && !!content.value
  })

  return { enabled, content }
}
