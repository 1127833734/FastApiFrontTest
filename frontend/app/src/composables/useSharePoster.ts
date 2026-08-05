/**
 * 小程序码与分享海报 composable
 *
 * 封装小程序码生成、海报绘制、保存到相册等功能。
 * 用于"邀请好友"场景，生成带参小程序码供扫码进入。
 *
 * 使用前提：
 * 1. 后端实现 /system/auth/wx-qrcode/generate 接口（调用微信 getwxacodeunlimit API）
 * 2. 小程序已上线或处于体验版（开发版无法生成小程序码）
 *
 * @example
 * ```ts
 * const { generateQrCode, saveImageToAlbum } = useSharePoster()
 *
 * // 生成带参小程序码
 * const qrUrl = await generateQrCode({ scene: 'invite_123', page: 'pages/index/index' })
 *
 * // 保存到相册
 * await saveImageToAlbum(tempFilePath)
 * ```
 */
import AuthAPI from '@/api/module_system/auth'

/** 小程序码生成参数 */
interface QrCodeParams {
  /** 场景值（最大32字符，如 invite_123） */
  scene: string
  /** 目标页面路径（不带 /，如 pages/index/index） */
  page?: string
  /** 宽度（px），默认 430 */
  width?: number
  /** 是否有 hyaline 透明底 */
  isHyaline?: boolean
}

/**
 * 分享海报 composable
 */
export function useSharePoster() {
  /**
   * 生成小程序码
   * 调用后端接口，后端通过微信 API getwxacodeunlimit 生成
   * 返回 base64 data URI，可直接用于 <image> 或 Canvas 绘制
   *
   * @param params 生成参数
   * @returns 图片 URL（data:image/png;base64,...）
   */
  async function generateQrCode(params: QrCodeParams): Promise<string> {
    // #ifdef MP-WEIXIN
    try {
      const result = await AuthAPI.generateWxQrCode({
        scene: params.scene,
        page: params.page || 'pages/index/index',
        width: params.width || 430,
      })
      return result.url
    }
    catch (error) {
      console.error('[useSharePoster] 生成小程序码失败', error)
      uni.showToast({ title: '生成小程序码失败', icon: 'none' })
      return ''
    }
    // #endif

    // #ifndef MP-WEIXIN
    uni.showToast({ title: '请在微信小程序中使用', icon: 'none' })
    return ''
    // #endif
  }

  /**
   * 下载网络图片到本地临时路径
   *
   * @param url 网络图片 URL
   * @returns 本地临时文件路径
   */
  async function downloadImage(url: string): Promise<string> {
    try {
      const res = await uni.downloadFile({ url })
      if (res.statusCode === 200)
        return res.tempFilePath
      throw new Error('下载图片失败')
    }
    catch (error) {
      console.error('[useSharePoster] 下载图片失败', error)
      return ''
    }
  }

  /**
   * 保存图片到相册
   *
   * @param tempFilePath 本地临时文件路径
   */
  async function saveImageToAlbum(tempFilePath: string): Promise<boolean> {
    // #ifdef MP-WEIXIN
    try {
      // 检查相册权限
      const setting = await uni.getSetting({})
      if (!(setting as any).authSetting?.['scope.writePhotosAlbum']) {
        await uni.authorize({ scope: 'scope.writePhotosAlbum' })
      }

      await uni.saveImageToPhotosAlbum({ filePath: tempFilePath })
      uni.showToast({ title: '已保存到相册', icon: 'success' })
      return true
    }
    catch (error) {
      console.error('[useSharePoster] 保存到相册失败', error)
      // 用户拒绝权限时引导去设置
      if ((error as any)?.errMsg?.includes('auth deny')) {
        uni.showModal({
          title: '需要相册权限',
          content: '保存图片需要相册权限，是否前往设置开启？',
          confirmText: '去设置',
          success: (res) => {
            if (res.confirm)
              uni.openSetting({})
          },
        })
      }
      return false
    }
    // #endif

    // #ifndef MP-WEIXIN
    uni.showToast({ title: '请在微信小程序中使用', icon: 'none' })
    return false
    // #endif
  }

  /**
   * 生成分享海报（Canvas 绘制）
   * 将品牌信息 + 用户信息 + 小程序码绘制到一张图片上
   *
   * @param options 海报配置
   * @param options.qrCodeUrl 小程序码图片 URL
   * @param options.userName 用户名
   * @param options.brandTitle 品牌标题
   * @param options.brandSubtitle 品牌副标题
   * @returns 本地临时文件路径
   */
  async function generatePoster(options: {
    qrCodeUrl: string
    userName: string
    brandTitle?: string
    brandSubtitle?: string
  }): Promise<string> {
    const { qrCodeUrl, userName, brandTitle = 'FastapiAdmin', brandSubtitle = '高效的企业管理移动平台' } = options

    // #ifdef MP-WEIXIN
    try {
      // 下载小程序码到本地
      const localQrPath = await downloadImage(qrCodeUrl)
      if (!localQrPath)
        return ''

      // 使用 Canvas 绘制海报
      const canvasId = 'share-poster-canvas'
      const ctx = uni.createCanvasContext(canvasId)

      // 海报尺寸 750x1200
      const W = 750
      const H = 1200

      // 背景：白色
      ctx.setFillStyle('#FFFFFF')
      ctx.fillRect(0, 0, W, H)

      // 顶部渐变背景
      const gradient = ctx.createLinearGradient(0, 0, 0, 400)
      gradient.addColorStop(0, '#4F8CFF')
      gradient.addColorStop(1, '#2563EB')
      ctx.setFillStyle(gradient)
      ctx.fillRect(0, 0, W, 400)

      // 品牌标题
      ctx.setFillStyle('#FFFFFF')
      ctx.setFontSize(36)
      ctx.setTextAlign('center')
      ctx.fillText(brandTitle, W / 2, 120)

      // 品牌副标题
      ctx.setFontSize(24)
      ctx.setFillStyle('rgba(255, 255, 255, 0.85)')
      ctx.fillText(brandSubtitle, W / 2, 160)

      // 用户名
      ctx.setFontSize(28)
      ctx.setFillStyle('#FFFFFF')
      ctx.fillText(`${userName} 邀请你加入`, W / 2, 220)

      // 中间区域：功能介绍
      ctx.setFillStyle('#1A1628')
      ctx.setFontSize(32)
      ctx.fillText('工单管理 · AI助手 · 数据监控', W / 2, 520)

      ctx.setFontSize(24)
      ctx.setFillStyle('#6B7280')
      ctx.fillText('移动办公更高效，随时随地理业务', W / 2, 560)

      // 小程序码
      const qrSize = 280
      const qrX = (W - qrSize) / 2
      const qrY = 640
      ctx.drawImage(localQrPath, qrX, qrY, qrSize, qrSize)

      // 底部提示
      ctx.setFontSize(22)
      ctx.setFillStyle('#9CA3AF')
      ctx.fillText('长按识别小程序码，立即体验', W / 2, 980)

      // 绘制并导出
      return new Promise((resolve) => {
        ctx.draw(false, () => {
          setTimeout(() => {
            uni.canvasToTempFilePath({
              canvasId,
              width: W,
              height: H,
              destWidth: W * 2,
              destHeight: H * 2,
              success: res => resolve(res.tempFilePath),
              fail: () => resolve(''),
            })
          }, 200)
        })
      })
    }
    catch (error) {
      console.error('[useSharePoster] 生成海报失败', error)
      return ''
    }
    // #endif

    // #ifndef MP-WEIXIN
    return ''
    // #endif
  }

  return {
    generateQrCode,
    downloadImage,
    saveImageToAlbum,
    generatePoster,
  }
}
