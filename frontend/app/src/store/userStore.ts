import type { LoginFormData, LoginResult } from '@/api/module_system/auth'
import type { UserInfo } from '@/api/module_system/user'
import { defineStore } from 'pinia'
import AuthAPI from '@/api/module_system/auth'
import UserAPI from '@/api/module_system/user'
import {
  ACCESS_TOKEN_KEY,
  REFRESH_TOKEN_KEY,
  USER_INFO_KEY,
} from '@/constants'
import { Storage } from '@/utils/storage'

export const useUserStore = defineStore('appUserInfo', {
  state: () => ({
    userInfo: Storage.get<UserInfo>(USER_INFO_KEY),
    isLoggingIn: false,
  }),

  getters: {
    isLogin: state => !!state.userInfo,
  },

  // 统一的登录处理方法
  actions: {
    // 获取访问 token
    getAccessToken(): string | null {
      return Storage.get<string>(ACCESS_TOKEN_KEY) || null
    },

    // 设置访问 token
    setAccessToken(token: string): void {
      Storage.set(ACCESS_TOKEN_KEY, token)
    },

    // 获取刷新 token
    getRefreshToken(): string | null {
      return Storage.get<string>(REFRESH_TOKEN_KEY) || null
    },

    // 设置刷新 token
    setRefreshToken(token: string): void {
      Storage.set(REFRESH_TOKEN_KEY, token)
    },

    // 清除所有 token
    clearTokens(): void {
      Storage.remove(ACCESS_TOKEN_KEY)
      Storage.remove(REFRESH_TOKEN_KEY)
    },

    // 获取用户信息
    getUserInfo(): UserInfo | undefined {
      return Storage.get<UserInfo>(USER_INFO_KEY)
    },

    // 设置用户信息
    setUserInfo(userInfo: Partial<UserInfo>): void {
      Storage.set(USER_INFO_KEY, userInfo)
    },

    // 清除用户信息
    clearUserInfo(): void {
      Storage.remove(USER_INFO_KEY)
    },

    // 清除所有缓存信息
    clearAll(): void {
      this.clearTokens()
      this.clearUserInfo()
    },

    /** 是否已登录（仅判断，不跳转；跳转由路由守卫与 HTTP 拦截器统一处理） */
    isLoggedIn(): boolean {
      return !!(this.getAccessToken() && this.userInfo)
    },

    async handleLogin(loginFn: () => Promise<LoginResult>, loginType: string): Promise<LoginResult> {
      if (this.isLoggingIn)
        throw new Error('登录中，请稍后')

      this.isLoggingIn = true
      try {
        const result = await loginFn()
        this.setAccessToken(result.access_token)
        this.setRefreshToken(result.refresh_token)

        // 登录成功后获取用户信息
        await this.getInfo()

        return result
      }
      catch (error) {
        console.error(`${loginType}登录失败`, error)
        throw error
      }
      finally {
        this.isLoggingIn = false
      }
    },

    // 账号密码登录
    async login(data: LoginFormData): Promise<LoginResult> {
      return this.handleLogin(() => AuthAPI.login(data), '账号密码')
    },

    // 微信小程序登录（code → 后端换 token）
    async wxLogin(data: { code: string, nickname?: string, avatar?: string }): Promise<LoginResult> {
      return this.handleLogin(() => AuthAPI.wxLogin(data), '微信')
    },

    // 微信手机号快速登录（2023+ 新方案：仅传 code）
    async wxPhoneLogin(data: { code: string }): Promise<LoginResult> {
      return this.handleLogin(() => AuthAPI.wxPhoneLogin(data), '微信手机号')
    },

    // 获取用户信息
    async getInfo(): Promise<UserInfo | null> {
      try {
        const userInfoData = await UserAPI.getCurrentUserInfo()
        this.setUserInfo(userInfoData)
        // 确保响应式数据更新
        this.userInfo = userInfoData
        return userInfoData
      }
      catch (error) {
        console.error('获取用户信息失败', error)
        return null
      }
    },

    // 登出
    async logout(): Promise<void> {
      try {
        await AuthAPI.logout(this.getAccessToken() || '') // 调用后台注销接口（body 为 JWT 字符串）
      }
      catch (error) {
        console.error('登出失败', error)
      }
      finally {
        this.clearAll() // 清除本地的 token
        this.userInfo = {} // 清空用户信息
        // 跳转到登录页面
        uni.reLaunch({
          url: '/pages/login/index',
        })
      }
    },
  },
})
