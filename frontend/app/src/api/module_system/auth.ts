import { http } from '@/http'
import { ContentTypeEnum } from '@/http/tools/enum'

const AUTH_BASE_URL = '/system/auth'

/** 方案提供方 */
export type OAuthProvider = 'wechat' | 'qq' | 'github' | 'gitee'

/**
 * 认证 API
 * 与 web 端 module_system/auth.ts 对齐（完整字段定义）
 */
const AuthAPI = {
  /**
   * 登录
   * @param body 登录表单数据
   * @returns 登录结果
   */
  login(body: LoginFormData): Promise<LoginResult> {
    return http.Post(`${AUTH_BASE_URL}/login`, body, {
      headers: {
        'Content-Type': ContentTypeEnum.FORM_URLENCODED,
      },
      meta: { ignoreAuth: true },
    })
  },

  /**
   * 刷新令牌
   * @param body 刷新令牌请求体
   * @returns 新的访问令牌
   */
  refreshToken(body: RefreshToekenBody): Promise<LoginResult> {
    return http.Post(`${AUTH_BASE_URL}/token/refresh`, body, { meta: { ignoreAuth: true } })
  },

  /**
   * 获取验证码
   * @returns 验证码信息
   */
  getCaptcha(): Promise<CaptchaInfo> {
    // 添加随机参数防止缓存
    const timestamp = new Date().getTime()
    return http.Get(`${AUTH_BASE_URL}/captcha/get?timestamp=${timestamp}`, { meta: { ignoreAuth: true } })
  },

  /**
   * 登出
   * @param body 登出请求体
   */
  logout(body: LogoutBody): Promise<void> {
    return http.Post(`${AUTH_BASE_URL}/logout`, body)
  },

  /**
   * 获取第三方 OAuth 登录跳转 URL
   * @param provider oauth 提供商: wechat / qq / github / gitee
   * @returns 跳转 URL
   */
  getOAuthLoginUrl(provider: OAuthProvider): Promise<{ url: string }> {
    return http.Get(`${AUTH_BASE_URL}/oauth/${provider}/login`, { meta: { ignoreAuth: true } })
  },

  /**
   * 滑块验证码完成
   * 后端仅标记 captcha_key 状态为 verified，不校验 x 坐标值（x 为占位字段）
   * @param data 验证数据
   * @param data.captcha_key 验证码 key
   * @param data.x 滑块 x 坐标（占位，后端未使用）
   * @returns 验证结果 { captcha_key, verified }
   */
  completeSliderCaptcha(data: { captcha_key: string, x: number }): Promise<{ captcha_key: string, verified: boolean }> {
    return http.Post(`${AUTH_BASE_URL}/captcha/slider/complete`, data, { meta: { ignoreAuth: true } })
  },
}

export default AuthAPI

/** 登录表单数据 */
export interface LoginFormData {
  username: string
  password: string
  captcha_key?: string
  captcha?: string
  remember?: boolean
  login_type?: string
}

/** 刷新令牌请求体 */
export interface RefreshToekenBody {
  refresh_token: string
}

/** JWT 响应 */
export interface LoginResult {
  access_token: string
  refresh_token: string
  token_type: string
  expires_in: number
}

/** 验证码信息（滑块模式：img_base 为空字符串） */
export interface CaptchaInfo {
  enable: boolean
  key: string
  img_base: string
}

/** 退出登录操作 */
export interface LogoutBody {
  token: string
}
