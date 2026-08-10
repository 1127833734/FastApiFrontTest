<script setup lang="ts">
onLaunch(() => {})
</script>

<style lang="scss">
@use '@wot-ui/ui/styles/theme/index.scss' as *;
.page-wraper {
  min-height: calc(100vh - var(--window-top));
  box-sizing: border-box;
  background: var(--wot-filled-content);
}

/* tab 页（tabbar 布局专属）：内容区再扣掉底部 tabbar 高度，避免 min-height 撑满与底部占位 gap 叠加溢出 */
.tabbar-page > .page-wraper {
  min-height: calc(100vh - var(--window-top) - var(--tabbar-h, 50px));
}

/* ===== 暗色模式全局品牌增强（一处生效所有页面） =====
极光氛围：页面背景叠加品牌光晕（顶部主色蓝 + 底部紫），卡片叠加微弱蓝光。
仅作用于暗色模式（.wot-theme-dark 挂在 wd-config-provider 根上），
亮色模式完全保持 wot 默认，不改动任何布局结构。 */
.wot-theme-dark .page-wraper {
  background-color: var(--wot-filled-content);
  background-image:
    radial-gradient(ellipse 120% 45% at 50% -12%, rgba(79, 140, 255, 0.12), transparent 65%),
    radial-gradient(ellipse 80% 30% at 100% 105%, rgba(139, 92, 246, 0.08), transparent 70%);
  background-repeat: no-repeat;
}

/* 卡片微光：在 wot 的 filled-oppo 底色上叠极淡的蓝紫光晕，增强玻璃拟态层次 */
.wot-theme-dark .wot-bg-filled-oppo {
  background-color: var(--wot-filled-oppo);
  background-image: radial-gradient(ellipse 90% 55% at 85% -25%, rgba(79, 140, 255, 0.05), transparent 60%);
  background-repeat: no-repeat;
}
</style>
