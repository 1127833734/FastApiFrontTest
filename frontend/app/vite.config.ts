import process from 'node:process'
import Uni from '@uni-helper/plugin-uni'
import { isMpWeixin } from '@uni-helper/uni-env'
import UniHelperComponents from '@uni-helper/vite-plugin-uni-components'
import UniHelperLayouts from '@uni-helper/vite-plugin-uni-layouts'
import UniHelperManifest from '@uni-helper/vite-plugin-uni-manifest'
import UniHelperPages from '@uni-helper/vite-plugin-uni-pages'
import Optimization from '@uni-ku/bundle-optimizer'
import UniKuRoot from '@uni-ku/root'
import { UniEchartsResolver } from 'uni-echarts/resolver'
import { UniEcharts } from 'uni-echarts/vite'
import UnoCSS from 'unocss/vite'
import AutoImport from 'unplugin-auto-import/vite'
import { defineConfig, loadEnv } from 'vite'
import { WotResolver } from './src/resolver'

// https://vitejs.dev/config/
export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd())

  return {
    // 注意：不能写成 /app/，否则会破坏 uni-app H5 路由/登录跳转路径（/app 无尾斜杠会 404）；
    // 静态资源拼接需在代码里自行补斜杠（见 login/index.vue 的 BASE_PATH）
    base: '/app',
    server: {
      port: Number(env.VITE_APP_PORT) || 5173,
    },
    optimizeDeps: {
      exclude: ['@wot-ui/ui', 'uni-echarts'],
    },
    plugins: [
      // https://github.com/uni-helper/vite-plugin-uni-manifest
      UniHelperManifest(),
      // https://github.com/uni-helper/vite-plugin-uni-pages
      UniHelperPages({
        dts: 'src/uni-pages.d.ts',
        subPackages: [
          'src/subPages',
        ],
        /**
         * 排除的页面，相对于 dir 和 subPackages
         * @default []
         */
        exclude: ['**/components/**/*.*'],
      }),
      // https://github.com/uni-helper/vite-plugin-uni-layouts
      UniHelperLayouts(),
      // https://github.com/uni-helper/vite-plugin-uni-components
      UniHelperComponents({
        resolvers: [WotResolver(), UniEchartsResolver()],
        dts: 'src/components.d.ts',
        dirs: ['src/components'],
        directoryAsNamespace: true,
      }),
      // https://github.com/uni-ku/root
      UniKuRoot(),
      // https://uni-echarts.xiaohe.ink
      UniEcharts(),
      // https://uni-helper.cn/plugin-uni
      Uni(),
      // https://github.com/uni-ku/bundle-optimizer
      Optimization({
        enable: isMpWeixin,
        logger: false,
      }),
      // https://github.com/antfu/unplugin-auto-import
      AutoImport({
        imports: ['vue', '@vueuse/core', 'pinia', 'uni-app', {
          from: '@wot-ui/router',
          imports: ['createRouter', 'useRouter', 'useRoute'],
        }, {
          from: '@wot-ui/ui',
          imports: ['useToast', 'useDialog', 'useNotify', 'CommonUtil'],
        }, {
          from: 'alova/client',
          imports: ['usePagination', 'useRequest'],
        }],
        dts: 'src/auto-imports.d.ts',
        dirs: ['src/composables', 'src/store', 'src/utils', 'src/api'],
        // useShare 与 @vueuse/core 重名，项目内均为显式 import，禁用自动导入避免重复警告
        ignore: ['useShare'],
        vueTemplate: true,
      }),
      // https://github.com/antfu/unocss
      // see unocss.config.ts for config
      UnoCSS(),
    ],
    css: {
      preprocessorOptions: {
        scss: {
          api: 'modern-compiler',
          silenceDeprecations: ['legacy-js-api'],
        },
      },
    },
  }
})
