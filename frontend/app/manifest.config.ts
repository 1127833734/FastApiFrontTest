/*
 * @Author: weisheng
 * @Date: 2025-08-28 20:59:43
 * @LastEditTime: 2025-11-17 14:28:09
 * @LastEditors: weisheng
 * @Description:
 * @FilePath: /wot-starter/manifest.config.ts
 * 记得注释
 */
import { defineManifestConfig } from '@uni-helper/vite-plugin-uni-manifest'

export default defineManifestConfig({
  'name': 'wot-starter',
  'appid': '__UNI__1208592',
  'description': '',
  'versionName': '1.0.0',
  'versionCode': '100',
  'transformPx': false,
  /* 5+App特有相关 */
  'app-plus': {
    usingComponents: true,
    nvueStyleCompiler: 'uni-app',
    compilerVersion: 3,
    splashscreen: {
      alwaysShowBeforeRender: true,
      waiting: true,
      autoclose: true,
      delay: 0,
    },
    /* 模块配置 */
    modules: {},
    /* 应用发布信息 */
    distribute: {
      /* android打包配置 */
      android: {
        permissions: [
          '<uses-permission android:name="android.permission.CHANGE_NETWORK_STATE"/>',
          '<uses-permission android:name="android.permission.MOUNT_UNMOUNT_FILESYSTEMS"/>',
          '<uses-permission android:name="android.permission.VIBRATE"/>',
          '<uses-permission android:name="android.permission.READ_LOGS"/>',
          '<uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>',
          '<uses-feature android:name="android.hardware.camera.autofocus"/>',
          '<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>',
          '<uses-permission android:name="android.permission.CAMERA"/>',
          '<uses-permission android:name="android.permission.GET_ACCOUNTS"/>',
          '<uses-permission android:name="android.permission.READ_PHONE_STATE"/>',
          '<uses-permission android:name="android.permission.CHANGE_WIFI_STATE"/>',
          '<uses-permission android:name="android.permission.WAKE_LOCK"/>',
          '<uses-permission android:name="android.permission.FLASHLIGHT"/>',
          '<uses-feature android:name="android.hardware.camera"/>',
          '<uses-permission android:name="android.permission.WRITE_SETTINGS"/>',
        ],
      },
      /* ios打包配置 */
      ios: {},
      /* SDK配置 */
      sdkConfigs: {},
    },
  },
  /* 快应用特有相关 */
  'quickapp': {},
  /* 小程序特有相关 */
  'mp-weixin': {
    optimization: {
      subPackages: true,
    },
    // TODO: 替换为实际的微信小程序 appid（在微信公众平台 → 开发管理 → 开发设置 中获取）
    appid: 'wx0000000000000000',
    setting: {
      urlCheck: false,
      // 压缩代码
      minified: true,
      // 启用 ES6 转 ES5
      es6: true,
      // 启用样式补全
      postcss: true,
      // 启用自动注入 wxss 文件
      minifyWXML: true,
    },
    usingComponents: true,
    darkmode: true,
    themeLocation: 'theme.json',
    // 微信小程序权限配置
    permission: {
      // 保存图片到相册
      'scope.writePhotosAlbum': {
        desc: '用于保存分享海报到相册',
      },
      // 获取用户位置（如需要）
      'scope.userLocation': {
        desc: '用于获取您的地理位置信息',
      },
    },
    // 接口权限声明（微信小程序隐私合规）
    requiredPrivateInfos: [
      'getLocation',
    ],
    // 订阅消息模板配置（在微信公众平台 → 订阅消息 中配置后填入）
    // subscribeMessage: {
    //   tmplIds: ['', '', ''],
    // },
  },
  'app-harmony': {},
  'mp-harmony': {},
  'mp-alipay': {
    usingComponents: true,
    compileOptions: {
      globalObjectMode: 'enable',
      treeShaking: true,
    },
  },
  'mp-baidu': {
    usingComponents: true,
  },
  'mp-toutiao': {
    usingComponents: true,
  },
  'h5': {
    darkmode: true,
    themeLocation: 'theme.json',
  },
  'uniStatistics': {
    enable: false,
  },
  'vueVersion': '3',
})
