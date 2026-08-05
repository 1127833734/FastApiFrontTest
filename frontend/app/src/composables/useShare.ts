import { onShareAppMessage, onShareTimeline } from '@dcloudio/uni-app'

/** 分享配置 */
interface ShareConfig {
  /** 分享标题 */
  title: string
  /** 分享路径（带 / 开头，例如 /pages/index/index） */
  path?: string
  /** 分享图片 URL（可选，不传则使用页面截图） */
  imageUrl?: string
}

/** 默认分享配置（全局兜底） */
const DEFAULT_SHARE: ShareConfig = {
  title: 'FastapiAdmin - 高效的企业管理移动平台',
  path: '/pages/index/index',
}

/**
 * 全局分享 composable
 *
 * 在页面 setup 中调用即可注册 onShareAppMessage + onShareTimeline。
 * 微信小程序中，页面必须调用此 composable 才能开启右上角"分享"按钮。
 *
 * @example
 * ```ts
 * // 静态分享
 * useShare({ title: '工作台', path: '/pages/work/index' })
 *
 * // 动态分享（标题随数据变化）
 * const shareTitle = computed(() => `${userInfo.value?.name || '管理员'} 邀请你使用`)
 * useShare(() => ({ title: shareTitle.value, path: '/pages/index/index' }))
 * ```
 */
export function useShare(configOrGetter?: ShareConfig | (() => ShareConfig)) {
  const getConfig = (): ShareConfig => {
    if (typeof configOrGetter === 'function')
      return { ...DEFAULT_SHARE, ...configOrGetter() }
    if (configOrGetter)
      return { ...DEFAULT_SHARE, ...configOrGetter }
    return { ...DEFAULT_SHARE }
  }

  onShareAppMessage((options) => {
    const cfg = getConfig()
    // 从分享来源判断：如果是按钮分享，可携带额外参数
    const fromButton = options?.from === 'button'
    return {
      title: cfg.title,
      path: cfg.path || DEFAULT_SHARE.path,
      imageUrl: cfg.imageUrl,
    }
  })

  onShareTimeline(() => {
    const cfg = getConfig()
    return {
      title: cfg.title,
      query: '', // 朋友圈分享不支持 path，用 query 传参
      imageUrl: cfg.imageUrl,
    }
  })
}
