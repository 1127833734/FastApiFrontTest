import type { uniappRequestAdapter } from '@alova/adapter-uniapp'
import type { UniappNormalResponse } from '../types'
import AdapterUniapp from '@alova/adapter-uniapp'
import { createAlova } from 'alova'
import { createServerTokenAuthentication } from 'alova/client'
import VueHook from 'alova/vue'
import AuthAPI from '@/api/module_system/auth'
import { useUserStore } from '@/store/userStore'
// 移除了 @dcloudio/types 导入，该模块不存在
import { toLoginPage } from '@/utils/toLoginPage'
import { ContentTypeEnum, HttpStatus, ResultEnum, ShowMessage } from '../tools/enum'

// 配置动态Tag
export const API_DOMAINS = {
  DEFAULT: import.meta.env.VITE_API_BASE_URL || '',
  SECONDARY: import.meta.env.VITE_SERVER_BASEURL_SECONDARY || '',
}

/**
 * 创建请求实例
 */
const { onAuthRequired, onResponseRefreshToken }
  = createServerTokenAuthentication<typeof VueHook, typeof uniappRequestAdapter>({
    // 如果下面拦截不到，请使用 refreshTokenOnSuccess by 群友@琛
    refreshTokenOnError: {
      isExpired: (error) => {
        return error.response?.status === HttpStatus.UNAUTHORIZED
      },
      handler: async () => {
        const userStore = useUserStore()
        const refreshToken = userStore.getRefreshToken()
        if (!refreshToken) {
          toLoginPage({ mode: 'reLaunch' })
          return
        }
        try {
          const res = await AuthAPI.refreshToken({ refresh_token: refreshToken })
          if (res?.access_token) {
            userStore.setAccessToken(res.access_token)
            if (res.refresh_token) {
              userStore.setRefreshToken(res.refresh_token)
            }
          }
          else {
            toLoginPage({ mode: 'reLaunch' })
          }
        }
        catch {
          toLoginPage({ mode: 'reLaunch' })
        }
      },
    },
  })

/**
 * alova 请求实例
 */
const alovaInstance = createAlova({
  baseURL: `${API_DOMAINS.DEFAULT}${import.meta.env.VITE_APP_BASE_API || ''}`,
  ...AdapterUniapp(),
  timeout: 10000,
  statesHook: VueHook,

  beforeRequest: onAuthRequired((method) => {
    // 设置默认 Content-Type
    method.config.headers = {
      ContentType: ContentTypeEnum.JSON,
      Accept: 'application/json, text/plain, */*',
      ...method.config.headers,
    }

    const { config } = method
    // 处理动态域名
    if (config.meta?.domain)
      method.baseURL = config.meta.domain

    // 免认证请求（验证码/登录/刷新令牌等）通过 meta.ignoreAuth 标记，统一跳过鉴权
    if (config.meta?.ignoreAuth)
      return

    // 需要认证的请求：校验 token 并注入 Authorization 头
    const userStore = useUserStore()
    const token = userStore.getAccessToken()
    if (!token)
      throw new Error('[请求错误]：未登录')
    method.config.headers.Authorization = `Bearer ${token}`
  }),

  responded: onResponseRefreshToken((response, method) => {
    const { config } = method
    const { requestType } = config

    // 处理特殊请求类型（上传/下载）：原样返回，不解构业务数据
    if (requestType === 'upload' || requestType === 'download')
      return response

    // 普通请求：uniapp adapter 响应结构为 { statusCode, data }（上传/下载已提前返回，此处必为普通请求）
    const { statusCode, data: rawData } = response as unknown as UniappNormalResponse

    // 处理 HTTP 状态码错误
    if (statusCode !== 200) {
      const errorMessage
        = rawData?.msg || rawData?.message || rawData?.error || ShowMessage(statusCode) || `HTTP请求错误[${statusCode}]`
      throw new Error(errorMessage)
    }

    // 处理业务逻辑错误
    const { code, message, msg, data } = rawData
    // 0 为成功，见 ResultEnum
    if (code !== ResultEnum.SUCCESS) {
      const errorMessage = msg || message || '请求错误'
      throw new Error(errorMessage)
    }
    // 处理成功响应，返回业务数据
    return data
  }),
})

export const http = alovaInstance
