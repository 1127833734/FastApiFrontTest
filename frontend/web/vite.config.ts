import { defineConfig, loadEnv } from "vite";
import vue from "@vitejs/plugin-vue";
import autoprefixer from "autoprefixer";
import path from "node:path";
import { fileURLToPath } from "url";
import vueDevTools from "vite-plugin-vue-devtools";
import viteCompression from "vite-plugin-compression";
import Components from "unplugin-vue-components/vite";
import AutoImport from "unplugin-auto-import/vite";
import ElementPlus from "unplugin-element-plus/vite";
import { ElementPlusResolver } from "unplugin-vue-components/resolvers";
import tailwindcss from "@tailwindcss/vite";
import vitePluginStart from "./build/vitePluginStart";
import Icons from "unplugin-icons/vite";
import IconsResolver from "unplugin-icons/resolver";
import { name, version, engines, dependencies, devDependencies } from "./package.json";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const __APP_INFO__ = {
  pkg: { name, version, engines, dependencies, devDependencies },
  buildTimestamp: Date.now(),
};

export default ({ mode }: { mode: string }) => {
  const root = process.cwd();
  const env = loadEnv(mode, root);
  const isProduction = mode === "prod";

  return defineConfig({
    define: {
      __APP_VERSION__: JSON.stringify(env.VITE_VERSION),
      __APP_NAME__: JSON.stringify(env.VITE_APP_TITLE),
      __APP_INFO__: JSON.stringify(__APP_INFO__),
    },
    base: env.VITE_BASE_URL,
    server: {
      host: true,
      port: Number(env.VITE_PORT),
      open: true,
      proxy: {
        [env.VITE_APP_BASE_API]: {
          target: env.VITE_API_BASE_URL,
          secure: false,
          changeOrigin: true,
        },
        "/static": {
          target: env.VITE_API_BASE_URL,
          secure: false,
          changeOrigin: true,
        },
      },
    },
    resolve: {
      alias: {
        "@": fileURLToPath(new URL("./src", import.meta.url)),
        "@views": resolvePath("src/views"),
        "@imgs": resolvePath("src/assets/images"),
        "@icons": resolvePath("src/assets/images/svg"),
        "@utils": resolvePath("src/utils"),
        "@stores": resolvePath("src/store"),
        "@plugins": resolvePath("src/plugins"),
        "@styles": resolvePath("src/styles"),
        "@api": resolvePath("src/api"),
        "@fa_imgs": resolvePath("src/assets/fa_imgs"),
      },
    },
    build: {
      target: "es2024",
      outDir: "dist",
      chunkSizeWarningLimit: 4000,
      minify: isProduction ? "terser" : false,
      terserOptions: isProduction
        ? {
            compress: {
              keep_infinity: true,
              drop_console: true,
              drop_debugger: true,
              pure_funcs: ["console.log", "console.info"],
            },
            format: {
              comments: true,
            },
          }
        : {},
      rollupOptions: {
        output: {
          manualChunks(id) {
            if (!id.includes("node_modules")) return;
            if (id.includes("echarts") || id.includes("zrender")) return "echarts";
            if (id.includes("element-plus")) return "element-plus";
            if (id.includes("@wangeditor")) return "wangeditor";
            if (id.includes("codemirror")) return "codemirror";
            if (id.includes("exceljs")) return "exceljs";
            if (id.includes("@vue-flow") || id.includes("dagre")) return "vue-flow";
            if (id.includes("highlight.js") || id.includes("highlightjs")) return "highlight";
            if (id.includes("xgplayer")) return "xgplayer";
            if (id.includes("markdown-it")) return "markdown";
            if (id.includes("@iconify-json")) return "iconify-icons";
            if (id.includes("xlsx")) return "xlsx";
            if (id.includes("crypto-js")) return "crypto";
            if (id.includes("js-beautify")) return "beautify";
            if (id.includes("dayjs")) return "dayjs";
            if (
              id.includes("vue/") ||
              id.includes("vue-router") ||
              id.includes("pinia") ||
              id.includes("vue-i18n") ||
              id.includes("@vueuse")
            )
              return "vue-vendor";

            const module = id
              .toString()
              .replace(/^.*[/\\]node_modules[/\\]\.pnpm[/\\][^/\\]+[/\\]node_modules[/\\]/, "")
              .split("node_modules/")
              .pop()
              ?.split("/")[0];
            if (
              !module ||
              [
                "birpc",
                "hookable",
                "tslib",
                "copy-anything",
                "danmu.js",
                "lodash-unified",
                "perfect-debounce",
              ].includes(module)
            )
              return;
            return module;
          },
          entryFileNames: "js/[name].[hash].js",
          chunkFileNames: "js/[name].[hash].js",
          assetFileNames: (assetInfo: any) => {
            const info = assetInfo.name.split(".");
            let extType = info[info.length - 1];
            if (/\.(mp4|webm|ogg|mp3|wav|flac|aac)(\?.*)?$/i.test(assetInfo.name)) {
              extType = "media";
            } else if (/\.(png|jpe?g|gif|svg)(\?.*)?$/.test(assetInfo.name)) {
              extType = "img";
            } else if (/\.(woff2?|eot|ttf|otf)(\?.*)?$/i.test(assetInfo.name)) {
              extType = "fonts";
            }
            return `${extType}/[name].[hash].[ext]`;
          },
        },
      },
      dynamicImportVarsOptions: {
        warnOnError: true,
        exclude: [],
        include: ["src/views/**/*.vue"],
      },
    },
    plugins: [
      vue(),
      vitePluginStart(),
      tailwindcss(),
      AutoImport({
        imports: [
          "vue",
          "vue-router",
          "pinia",
          "@vueuse/core",
          "vue-i18n",
          {
            axios: [["default", "axios"]],
          },
          {
            "element-plus/es": [
              "ElScrollbar",
              "ElInput",
              "ElMessageBox",
              "ElNotification",
              "ElMessage",
              "ElSwitch",
              "ElAvatar",
              "ElButton",
            ],
          },
          // ---- 项目公共模块 ----
          {
            "@/utils/query": ["stripPaginationParams", "cleanEmptyArrayParams"],
            "@/utils/table": ["renderTableOperationCell", "resolveStatusColumns"],
            "@/enums/api/result.enum": ["ResultEnum"],
            "@/enums/appEnum": [
              "MenuTypeEnum",
              "SystemThemeEnum",
              "MenuThemeEnum",
              "LanguageEnum",
              "ContainerWidthEnum",
            ],
          },
        ],
        dirs: ["./src/hooks/core"],
        dts: "src/types/auto-imports.d.ts",
        resolvers: [ElementPlusResolver(), IconsResolver({})],
        eslintrc: {
          enabled: true,
          filepath: "./eslint-globals.json",
          globalsPropValue: true,
        },
        vueTemplate: true,
      }),
      Components({
        dirs: ["src/components", "src/**/components"],
        dts: "src/types/components.d.ts",
        resolvers: [
          ElementPlusResolver(),
          IconsResolver({
            enabledCollections: ["ep"],
          }),
        ],
      }),
      Icons({
        // 自动安装图标库
        autoInstall: true,
      }),
      ElementPlus({
        // useSource: false 使用预编译 CSS，减少构建时间和样式按需加载时的依赖优化触发
        useSource: false,
      }),
      // 生产环境：gzip 压缩（兼容性好）
      ...(isProduction
        ? [
            viteCompression({
              verbose: false,
              algorithm: "gzip",
              ext: ".gz",
              threshold: 10240,
              deleteOriginFile: false,
            }),
            // 生产环境：brotli 压缩（压缩率更高，现代浏览器支持）
            viteCompression({
              verbose: false,
              algorithm: "brotliCompress",
              ext: ".br",
              threshold: 10240,
              deleteOriginFile: false,
            }),
          ]
        : []),
      /** 仅开发启用：避免生产包体积膨胀与运行期 DevTools 开销 */
      ...(isProduction ? [] : [vueDevTools()]),
    ],
    optimizeDeps: {
      include: [
        "@vue-flow/core",
        "@vue-flow/background",
        "@vue-flow/controls",
        "@vue-flow/minimap",
        "vue-json-pretty",
        "vue-web-terminal",
        "vue3-cron-plus",
        "vuedraggable",
        "vue-draggable-plus",
        "element-plus",
        "@element-plus/icons-vue",
        "element-plus/es",
        "element-plus/es/locale/lang/en",
        "element-plus/es/locale/lang/zh-cn",
        "codemirror",
        "codemirror-editor-vue3",
        "@wangeditor-next/editor",
        "@wangeditor-next/editor-for-vue",
        "exceljs",
        "nprogress",
        "qs",
        "path-to-regexp",
        "path-browserify",
        "xgplayer",
        "@iconify/vue",
        "qrcode.vue",
        "xlsx",
        "highlight.js",
        "dagre",
        "dompurify",
        "js-beautify",
        "markdown-it",
        "markdown-it-highlightjs",
        "clipboard",
        "crypto-js",
        "file-saver",
        "mitt",
        "ohash",
        "pinia-plugin-persistedstate",
        "echarts/core",
        "echarts/renderers",
        "echarts/charts",
        "echarts/components",
      ],
    },
    css: {
      preprocessorOptions: {
        scss: {
          additionalData: `
            // Element Plus 主题色（@use with 直接改 common/var 模块默认值）。
            @use "@styles/element-plus/theme.scss" as *;
            // 业务工具 mixin 注入（供 src 内 SCSS 文件直接使用，无需手动引入）。
            @use "@styles/core/mixin.scss" as *;
          `,
        },
      },
      postcss: {
        plugins: [
          autoprefixer(),
          {
            postcssPlugin: "internal:charset-removal",
            AtRule: {
              charset: (atRule: any) => {
                if (atRule.name === "charset") {
                  atRule.remove();
                }
              },
            },
          },
        ],
      },
    },
  });
};

function resolvePath(paths: string) {
  return path.resolve(__dirname, paths);
}
