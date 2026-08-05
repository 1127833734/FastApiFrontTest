<script setup lang="ts">
import { Storage } from '@/utils/storage'

const ONBOARDING_KEY = 'onboarding_completed'

onLaunch(() => {
  // 首次安装检查：未完成引导页时跳转引导页
  const completed = Storage.get<boolean>(ONBOARDING_KEY)
  if (!completed) {
    // 延迟跳转，确保首页已注册
    setTimeout(() => {
      uni.reLaunch({ url: '/pages/onboarding/index' })
    }, 100)
  }
})
</script>

<style lang="scss">
@use '@wot-ui/ui/styles/theme/index.scss' as *;
.page-wraper {
  min-height: calc(100vh - var(--window-top));
  box-sizing: border-box;
  background: var(--wot-filled-content);
}
// .wot-theme-dark.page-wraper {
//   background: #222;
// }
</style>
