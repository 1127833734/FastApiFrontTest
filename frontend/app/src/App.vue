<script setup lang="ts">
onLaunch(() => {})
</script>

<style lang="scss">
@use '@wot-ui/ui/styles/theme/index.scss' as *;

/* =====================================================================
   Design Tokens（设计令牌）
   统一的语义化颜色层，供所有页面通过 var(--xxx) 引用，替代散落的硬编码。
   亮色为默认值（挂页面根），暗色在 .wot-theme-dark 上覆盖，一处生效全站。
   色阶采用 Tailwind 风格：亮色用 600/500 级、暗色用 400 级提亮，保证深底可读。
   ===================================================================== */
page,
uni-page-body {
  /* 文本层级 */
  --text-color: #0A1628; /* 主文字（品牌深蓝黑） */
  --text-color-2: #475569; /* 次文字（slate-600） */
  --text-color-3: #64748B; /* 辅助文字（slate-500） */

  /* 表面层级 */
  --card-bg-color: #FFFFFF; /* 卡片背景 */
  --bg-color-2: #F8FAFC; /* 次级背景（slate-50） */
  --bg-color-3: #F1F5F9; /* 三级背景：输入框底等（slate-100） */
  --border-color: #E2E8F0; /* 边框（slate-200） */

  /* 品牌色（亮色 600/500 级） */
  --brand-blue: #2563EB;
  --brand-orange: #F59E0B;
  --brand-green: #10B981;
  --brand-purple: #8B5CF6;
  --brand-cyan: #06B6D4;

  /* 品牌浅底（图标/徽章底色，100 级） */
  --brand-blue-soft: #DBEAFE;
  --brand-orange-soft: #FEF3C7;
  --brand-green-soft: #D1FAE5;
  --brand-purple-soft: #EDE9FE;
  --brand-cyan-soft: #CFFAFE;

  /* 品牌渐变（Banner / 用户卡片等装饰区） */
  --brand-gradient-blue: linear-gradient(135deg, #4F8CFF 0%, #2563EB 100%);
  --brand-gradient-orange: linear-gradient(135deg, #F59E0B 0%, #D97706 100%);
  --brand-gradient-green: linear-gradient(135deg, #10B981 0%, #059669 100%);
  --brand-gradient-purple: linear-gradient(135deg, #8B5CF6 0%, #6D28D9 100%);

  /* 语义色：关联 wot-ui 主题变量，主题色切换 / 暗黑模式自动联动 */
  --primary-color: var(--wot-primary-6, #1C64FD);
  --success-color: var(--wot-success-main, #07C160);
  --warning-color: var(--wot-warning-main, #FF8F1F);
  --error-color: var(--wot-danger-main, #FA5151);
}

/* 暗色模式令牌覆盖：品牌色 400 级提亮，渐变同步提亮一档 */
.wot-theme-dark {
  --text-color: #F1F5F9; /* slate-100 */
  --text-color-2: #CBD5E1; /* slate-300 */
  --text-color-3: #94A3B8; /* slate-400 */

  --card-bg-color: #1E293B; /* slate-800 */
  --bg-color-2: #0F172A; /* slate-900 */
  --bg-color-3: #1E293B; /* slate-800 */
  --border-color: #334155; /* slate-700 */

  --brand-blue: #60A5FA;
  --brand-orange: #FBBF24;
  --brand-green: #34D399;
  --brand-purple: #A78BFA;
  --brand-cyan: #22D3EE;

  --brand-blue-soft: rgba(96, 165, 250, 0.14);
  --brand-orange-soft: rgba(251, 191, 36, 0.14);
  --brand-green-soft: rgba(52, 211, 153, 0.14);
  --brand-purple-soft: rgba(167, 139, 250, 0.14);
  --brand-cyan-soft: rgba(34, 211, 238, 0.14);

  --brand-gradient-blue: linear-gradient(135deg, #60A5FA 0%, #3B82F6 100%);
  --brand-gradient-orange: linear-gradient(135deg, #FBBF24 0%, #F59E0B 100%);
  --brand-gradient-green: linear-gradient(135deg, #34D399 0%, #10B981 100%);
  --brand-gradient-purple: linear-gradient(135deg, #A78BFA 0%, #7C3AED 100%);
}

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
