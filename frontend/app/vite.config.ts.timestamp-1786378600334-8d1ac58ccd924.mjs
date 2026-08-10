// vite.config.ts
import process from "node:process";
import Uni from "file:///Users/tao/workspace/FastapiAdmin/frontend/app/node_modules/.pnpm/@uni-helper+plugin-uni@0.1.0_@dcloudio+vite-plugin-uni@3.0.0-4080520251106001_@vueuse+core@11_w3rjfof7zcdwmdq6tqmbutg7zi/node_modules/@uni-helper/plugin-uni/src/index.js";
import { isMpWeixin } from "file:///Users/tao/workspace/FastapiAdmin/frontend/app/node_modules/.pnpm/@uni-helper+uni-env@0.2.2/node_modules/@uni-helper/uni-env/dist/index.mjs";
import UniHelperComponents from "file:///Users/tao/workspace/FastapiAdmin/frontend/app/node_modules/.pnpm/@uni-helper+vite-plugin-uni-components@0.2.6_rollup@4.53.2/node_modules/@uni-helper/vite-plugin-uni-components/dist/index.mjs";
import UniHelperLayouts from "file:///Users/tao/workspace/FastapiAdmin/frontend/app/node_modules/.pnpm/@uni-helper+vite-plugin-uni-layouts@0.1.11_rollup@4.53.2/node_modules/@uni-helper/vite-plugin-uni-layouts/dist/index.mjs";
import UniHelperManifest from "file:///Users/tao/workspace/FastapiAdmin/frontend/app/node_modules/.pnpm/@uni-helper+vite-plugin-uni-manifest@0.2.12_vite@5.2.8_@types+node@20.19.43_sass@1.99.0_terser@5.49.2_/node_modules/@uni-helper/vite-plugin-uni-manifest/dist/index.mjs";
import UniHelperPages from "file:///Users/tao/workspace/FastapiAdmin/frontend/app/node_modules/.pnpm/@uni-helper+vite-plugin-uni-pages@0.3.23_vite@5.2.8_@types+node@20.19.43_sass@1.99.0_terser@5.49.2_/node_modules/@uni-helper/vite-plugin-uni-pages/dist/index.mjs";
import Optimization from "file:///Users/tao/workspace/FastapiAdmin/frontend/app/node_modules/.pnpm/@uni-ku+bundle-optimizer@2.1.0_@vueuse+core@11.0.3_vue@3.4.38_typescript@5.5.4___chokidar@3.6_m4ljxnf3flzrczdxzhcrqkghfa/node_modules/@uni-ku/bundle-optimizer/dist/index.mjs";
import UniKuRoot from "file:///Users/tao/workspace/FastapiAdmin/frontend/app/node_modules/.pnpm/@uni-ku+root@1.5.0_vite@5.2.8_@types+node@20.19.43_sass@1.99.0_terser@5.49.2_/node_modules/@uni-ku/root/dist/index.mjs";
import { UniEchartsResolver } from "file:///Users/tao/workspace/FastapiAdmin/frontend/app/node_modules/.pnpm/uni-echarts@2.5.2_echarts@6.1.0_vue@3.4.38_typescript@5.5.4_/node_modules/uni-echarts/dist-resolver/index.mjs";
import { UniEcharts } from "file:///Users/tao/workspace/FastapiAdmin/frontend/app/node_modules/.pnpm/uni-echarts@2.5.2_echarts@6.1.0_vue@3.4.38_typescript@5.5.4_/node_modules/uni-echarts/dist-vite/index.mjs";
import UnoCSS from "file:///Users/tao/workspace/FastapiAdmin/frontend/app/node_modules/.pnpm/unocss@66.0.0_postcss@8.5.10_vite@5.2.8_@types+node@20.19.43_sass@1.99.0_terser@5.49.2__vue@3.4.38_typescript@5.5.4_/node_modules/unocss/dist/vite.mjs";
import AutoImport from "file:///Users/tao/workspace/FastapiAdmin/frontend/app/node_modules/.pnpm/unplugin-auto-import@0.18.2_@vueuse+core@11.0.3_vue@3.4.38_typescript@5.5.4___rollup@4.53.2/node_modules/unplugin-auto-import/dist/vite.js";
import { defineConfig, loadEnv } from "file:///Users/tao/workspace/FastapiAdmin/frontend/app/node_modules/.pnpm/vite@5.2.8_@types+node@20.19.43_sass@1.99.0_terser@5.49.2/node_modules/vite/dist/node/index.js";

// src/resolver/index.ts
import { kebabCase } from "file:///Users/tao/workspace/FastapiAdmin/frontend/app/node_modules/.pnpm/@uni-helper+vite-plugin-uni-components@0.2.6_rollup@4.53.2/node_modules/@uni-helper/vite-plugin-uni-components/dist/index.mjs";
function WotResolver() {
  return {
    type: "component",
    resolve: (name) => {
      if (name.match(/^Wd[A-Z]/)) {
        const compName = kebabCase(name);
        return {
          name,
          from: `@wot-ui/ui/components/${compName}/${compName}.vue`
        };
      }
    }
  };
}

// vite.config.ts
var vite_config_default = defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd());
  return {
    // 注意：不能写成 /app/，否则会破坏 uni-app H5 路由/登录跳转路径（/app 无尾斜杠会 404）；
    // 静态资源拼接需在代码里自行补斜杠（见 login/index.vue 的 BASE_PATH）
    base: "/app",
    server: {
      port: Number(env.VITE_APP_PORT) || 5173
    },
    optimizeDeps: {
      exclude: ["@wot-ui/ui", "uni-echarts"]
    },
    plugins: [
      // https://github.com/uni-helper/vite-plugin-uni-manifest
      UniHelperManifest(),
      // https://github.com/uni-helper/vite-plugin-uni-pages
      UniHelperPages({
        dts: "src/uni-pages.d.ts",
        subPackages: [
          "src/subPages"
        ],
        /**
         * 排除的页面，相对于 dir 和 subPackages
         * @default []
         */
        exclude: ["**/components/**/*.*"]
      }),
      // https://github.com/uni-helper/vite-plugin-uni-layouts
      UniHelperLayouts(),
      // https://github.com/uni-helper/vite-plugin-uni-components
      UniHelperComponents({
        resolvers: [WotResolver(), UniEchartsResolver()],
        dts: "src/components.d.ts",
        dirs: ["src/components"],
        directoryAsNamespace: true
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
        logger: false
      }),
      // https://github.com/antfu/unplugin-auto-import
      AutoImport({
        imports: ["vue", "@vueuse/core", "pinia", "uni-app", {
          from: "@wot-ui/router",
          imports: ["createRouter", "useRouter", "useRoute"]
        }, {
          from: "@wot-ui/ui",
          imports: ["useToast", "useDialog", "useNotify", "CommonUtil"]
        }, {
          from: "alova/client",
          imports: ["usePagination", "useRequest"]
        }],
        dts: "src/auto-imports.d.ts",
        dirs: ["src/composables", "src/store", "src/utils", "src/api"],
        // useShare 与 @vueuse/core 重名，项目内均为显式 import，禁用自动导入避免重复警告
        ignore: ["useShare"],
        vueTemplate: true
      }),
      // https://github.com/antfu/unocss
      // see unocss.config.ts for config
      UnoCSS()
    ],
    css: {
      preprocessorOptions: {
        scss: {
          api: "modern-compiler",
          silenceDeprecations: ["legacy-js-api"]
        }
      }
    }
  };
});
export {
  vite_config_default as default
};
//# sourceMappingURL=data:application/json;base64,ewogICJ2ZXJzaW9uIjogMywKICAic291cmNlcyI6IFsidml0ZS5jb25maWcudHMiLCAic3JjL3Jlc29sdmVyL2luZGV4LnRzIl0sCiAgInNvdXJjZXNDb250ZW50IjogWyJjb25zdCBfX3ZpdGVfaW5qZWN0ZWRfb3JpZ2luYWxfZGlybmFtZSA9IFwiL1VzZXJzL3Rhby93b3Jrc3BhY2UvRmFzdGFwaUFkbWluL2Zyb250ZW5kL2FwcFwiO2NvbnN0IF9fdml0ZV9pbmplY3RlZF9vcmlnaW5hbF9maWxlbmFtZSA9IFwiL1VzZXJzL3Rhby93b3Jrc3BhY2UvRmFzdGFwaUFkbWluL2Zyb250ZW5kL2FwcC92aXRlLmNvbmZpZy50c1wiO2NvbnN0IF9fdml0ZV9pbmplY3RlZF9vcmlnaW5hbF9pbXBvcnRfbWV0YV91cmwgPSBcImZpbGU6Ly8vVXNlcnMvdGFvL3dvcmtzcGFjZS9GYXN0YXBpQWRtaW4vZnJvbnRlbmQvYXBwL3ZpdGUuY29uZmlnLnRzXCI7aW1wb3J0IHByb2Nlc3MgZnJvbSAnbm9kZTpwcm9jZXNzJ1xuaW1wb3J0IFVuaSBmcm9tICdAdW5pLWhlbHBlci9wbHVnaW4tdW5pJ1xuaW1wb3J0IHsgaXNNcFdlaXhpbiB9IGZyb20gJ0B1bmktaGVscGVyL3VuaS1lbnYnXG5pbXBvcnQgVW5pSGVscGVyQ29tcG9uZW50cyBmcm9tICdAdW5pLWhlbHBlci92aXRlLXBsdWdpbi11bmktY29tcG9uZW50cydcbmltcG9ydCBVbmlIZWxwZXJMYXlvdXRzIGZyb20gJ0B1bmktaGVscGVyL3ZpdGUtcGx1Z2luLXVuaS1sYXlvdXRzJ1xuaW1wb3J0IFVuaUhlbHBlck1hbmlmZXN0IGZyb20gJ0B1bmktaGVscGVyL3ZpdGUtcGx1Z2luLXVuaS1tYW5pZmVzdCdcbmltcG9ydCBVbmlIZWxwZXJQYWdlcyBmcm9tICdAdW5pLWhlbHBlci92aXRlLXBsdWdpbi11bmktcGFnZXMnXG5pbXBvcnQgT3B0aW1pemF0aW9uIGZyb20gJ0B1bmkta3UvYnVuZGxlLW9wdGltaXplcidcbmltcG9ydCBVbmlLdVJvb3QgZnJvbSAnQHVuaS1rdS9yb290J1xuaW1wb3J0IHsgVW5pRWNoYXJ0c1Jlc29sdmVyIH0gZnJvbSAndW5pLWVjaGFydHMvcmVzb2x2ZXInXG5pbXBvcnQgeyBVbmlFY2hhcnRzIH0gZnJvbSAndW5pLWVjaGFydHMvdml0ZSdcbmltcG9ydCBVbm9DU1MgZnJvbSAndW5vY3NzL3ZpdGUnXG5pbXBvcnQgQXV0b0ltcG9ydCBmcm9tICd1bnBsdWdpbi1hdXRvLWltcG9ydC92aXRlJ1xuaW1wb3J0IHsgZGVmaW5lQ29uZmlnLCBsb2FkRW52IH0gZnJvbSAndml0ZSdcbmltcG9ydCB7IFdvdFJlc29sdmVyIH0gZnJvbSAnLi9zcmMvcmVzb2x2ZXInXG5cbi8vIGh0dHBzOi8vdml0ZWpzLmRldi9jb25maWcvXG5leHBvcnQgZGVmYXVsdCBkZWZpbmVDb25maWcoKHsgbW9kZSB9KSA9PiB7XG4gIGNvbnN0IGVudiA9IGxvYWRFbnYobW9kZSwgcHJvY2Vzcy5jd2QoKSlcblxuICByZXR1cm4ge1xuICAgIC8vIFx1NkNFOFx1NjEwRlx1RkYxQVx1NEUwRFx1ODBGRFx1NTE5OVx1NjIxMCAvYXBwL1x1RkYwQ1x1NTQyNlx1NTIxOVx1NEYxQVx1NzgzNFx1NTc0RiB1bmktYXBwIEg1IFx1OERFRlx1NzUzMS9cdTc2N0JcdTVGNTVcdThERjNcdThGNkNcdThERUZcdTVGODRcdUZGMDgvYXBwIFx1NjVFMFx1NUMzRVx1NjU5Q1x1Njc2MFx1NEYxQSA0MDRcdUZGMDlcdUZGMUJcbiAgICAvLyBcdTk3NTlcdTYwMDFcdThENDRcdTZFOTBcdTYyRkNcdTYzQTVcdTk3MDBcdTU3MjhcdTRFRTNcdTc4MDFcdTkxQ0NcdTgxRUFcdTg4NENcdTg4NjVcdTY1OUNcdTY3NjBcdUZGMDhcdTg5QzEgbG9naW4vaW5kZXgudnVlIFx1NzY4NCBCQVNFX1BBVEhcdUZGMDlcbiAgICBiYXNlOiAnL2FwcCcsXG4gICAgc2VydmVyOiB7XG4gICAgICBwb3J0OiBOdW1iZXIoZW52LlZJVEVfQVBQX1BPUlQpIHx8IDUxNzMsXG4gICAgfSxcbiAgICBvcHRpbWl6ZURlcHM6IHtcbiAgICAgIGV4Y2x1ZGU6IFsnQHdvdC11aS91aScsICd1bmktZWNoYXJ0cyddLFxuICAgIH0sXG4gICAgcGx1Z2luczogW1xuICAgICAgLy8gaHR0cHM6Ly9naXRodWIuY29tL3VuaS1oZWxwZXIvdml0ZS1wbHVnaW4tdW5pLW1hbmlmZXN0XG4gICAgICBVbmlIZWxwZXJNYW5pZmVzdCgpLFxuICAgICAgLy8gaHR0cHM6Ly9naXRodWIuY29tL3VuaS1oZWxwZXIvdml0ZS1wbHVnaW4tdW5pLXBhZ2VzXG4gICAgICBVbmlIZWxwZXJQYWdlcyh7XG4gICAgICAgIGR0czogJ3NyYy91bmktcGFnZXMuZC50cycsXG4gICAgICAgIHN1YlBhY2thZ2VzOiBbXG4gICAgICAgICAgJ3NyYy9zdWJQYWdlcycsXG4gICAgICAgIF0sXG4gICAgICAgIC8qKlxuICAgICAgICAgKiBcdTYzOTJcdTk2NjRcdTc2ODRcdTk4NzVcdTk3NjJcdUZGMENcdTc2RjhcdTVCRjlcdTRFOEUgZGlyIFx1NTQ4QyBzdWJQYWNrYWdlc1xuICAgICAgICAgKiBAZGVmYXVsdCBbXVxuICAgICAgICAgKi9cbiAgICAgICAgZXhjbHVkZTogWycqKi9jb21wb25lbnRzLyoqLyouKiddLFxuICAgICAgfSksXG4gICAgICAvLyBodHRwczovL2dpdGh1Yi5jb20vdW5pLWhlbHBlci92aXRlLXBsdWdpbi11bmktbGF5b3V0c1xuICAgICAgVW5pSGVscGVyTGF5b3V0cygpLFxuICAgICAgLy8gaHR0cHM6Ly9naXRodWIuY29tL3VuaS1oZWxwZXIvdml0ZS1wbHVnaW4tdW5pLWNvbXBvbmVudHNcbiAgICAgIFVuaUhlbHBlckNvbXBvbmVudHMoe1xuICAgICAgICByZXNvbHZlcnM6IFtXb3RSZXNvbHZlcigpLCBVbmlFY2hhcnRzUmVzb2x2ZXIoKV0sXG4gICAgICAgIGR0czogJ3NyYy9jb21wb25lbnRzLmQudHMnLFxuICAgICAgICBkaXJzOiBbJ3NyYy9jb21wb25lbnRzJ10sXG4gICAgICAgIGRpcmVjdG9yeUFzTmFtZXNwYWNlOiB0cnVlLFxuICAgICAgfSksXG4gICAgICAvLyBodHRwczovL2dpdGh1Yi5jb20vdW5pLWt1L3Jvb3RcbiAgICAgIFVuaUt1Um9vdCgpLFxuICAgICAgLy8gaHR0cHM6Ly91bmktZWNoYXJ0cy54aWFvaGUuaW5rXG4gICAgICBVbmlFY2hhcnRzKCksXG4gICAgICAvLyBodHRwczovL3VuaS1oZWxwZXIuY24vcGx1Z2luLXVuaVxuICAgICAgVW5pKCksXG4gICAgICAvLyBodHRwczovL2dpdGh1Yi5jb20vdW5pLWt1L2J1bmRsZS1vcHRpbWl6ZXJcbiAgICAgIE9wdGltaXphdGlvbih7XG4gICAgICAgIGVuYWJsZTogaXNNcFdlaXhpbixcbiAgICAgICAgbG9nZ2VyOiBmYWxzZSxcbiAgICAgIH0pLFxuICAgICAgLy8gaHR0cHM6Ly9naXRodWIuY29tL2FudGZ1L3VucGx1Z2luLWF1dG8taW1wb3J0XG4gICAgICBBdXRvSW1wb3J0KHtcbiAgICAgICAgaW1wb3J0czogWyd2dWUnLCAnQHZ1ZXVzZS9jb3JlJywgJ3BpbmlhJywgJ3VuaS1hcHAnLCB7XG4gICAgICAgICAgZnJvbTogJ0B3b3QtdWkvcm91dGVyJyxcbiAgICAgICAgICBpbXBvcnRzOiBbJ2NyZWF0ZVJvdXRlcicsICd1c2VSb3V0ZXInLCAndXNlUm91dGUnXSxcbiAgICAgICAgfSwge1xuICAgICAgICAgIGZyb206ICdAd290LXVpL3VpJyxcbiAgICAgICAgICBpbXBvcnRzOiBbJ3VzZVRvYXN0JywgJ3VzZURpYWxvZycsICd1c2VOb3RpZnknLCAnQ29tbW9uVXRpbCddLFxuICAgICAgICB9LCB7XG4gICAgICAgICAgZnJvbTogJ2Fsb3ZhL2NsaWVudCcsXG4gICAgICAgICAgaW1wb3J0czogWyd1c2VQYWdpbmF0aW9uJywgJ3VzZVJlcXVlc3QnXSxcbiAgICAgICAgfV0sXG4gICAgICAgIGR0czogJ3NyYy9hdXRvLWltcG9ydHMuZC50cycsXG4gICAgICAgIGRpcnM6IFsnc3JjL2NvbXBvc2FibGVzJywgJ3NyYy9zdG9yZScsICdzcmMvdXRpbHMnLCAnc3JjL2FwaSddLFxuICAgICAgICAvLyB1c2VTaGFyZSBcdTRFMEUgQHZ1ZXVzZS9jb3JlIFx1OTFDRFx1NTQwRFx1RkYwQ1x1OTg3OVx1NzZFRVx1NTE4NVx1NTc0N1x1NEUzQVx1NjYzRVx1NUYwRiBpbXBvcnRcdUZGMENcdTc5ODFcdTc1MjhcdTgxRUFcdTUyQThcdTVCRkNcdTUxNjVcdTkwN0ZcdTUxNERcdTkxQ0RcdTU5MERcdThCNjZcdTU0NEFcbiAgICAgICAgaWdub3JlOiBbJ3VzZVNoYXJlJ10sXG4gICAgICAgIHZ1ZVRlbXBsYXRlOiB0cnVlLFxuICAgICAgfSksXG4gICAgICAvLyBodHRwczovL2dpdGh1Yi5jb20vYW50ZnUvdW5vY3NzXG4gICAgICAvLyBzZWUgdW5vY3NzLmNvbmZpZy50cyBmb3IgY29uZmlnXG4gICAgICBVbm9DU1MoKSxcbiAgICBdLFxuICAgIGNzczoge1xuICAgICAgcHJlcHJvY2Vzc29yT3B0aW9uczoge1xuICAgICAgICBzY3NzOiB7XG4gICAgICAgICAgYXBpOiAnbW9kZXJuLWNvbXBpbGVyJyxcbiAgICAgICAgICBzaWxlbmNlRGVwcmVjYXRpb25zOiBbJ2xlZ2FjeS1qcy1hcGknXSxcbiAgICAgICAgfSxcbiAgICAgIH0sXG4gICAgfSxcbiAgfVxufSlcbiIsICJjb25zdCBfX3ZpdGVfaW5qZWN0ZWRfb3JpZ2luYWxfZGlybmFtZSA9IFwiL1VzZXJzL3Rhby93b3Jrc3BhY2UvRmFzdGFwaUFkbWluL2Zyb250ZW5kL2FwcC9zcmMvcmVzb2x2ZXJcIjtjb25zdCBfX3ZpdGVfaW5qZWN0ZWRfb3JpZ2luYWxfZmlsZW5hbWUgPSBcIi9Vc2Vycy90YW8vd29ya3NwYWNlL0Zhc3RhcGlBZG1pbi9mcm9udGVuZC9hcHAvc3JjL3Jlc29sdmVyL2luZGV4LnRzXCI7Y29uc3QgX192aXRlX2luamVjdGVkX29yaWdpbmFsX2ltcG9ydF9tZXRhX3VybCA9IFwiZmlsZTovLy9Vc2Vycy90YW8vd29ya3NwYWNlL0Zhc3RhcGlBZG1pbi9mcm9udGVuZC9hcHAvc3JjL3Jlc29sdmVyL2luZGV4LnRzXCI7aW1wb3J0IHR5cGUgeyBDb21wb25lbnRSZXNvbHZlciB9IGZyb20gJ0B1bmktaGVscGVyL3ZpdGUtcGx1Z2luLXVuaS1jb21wb25lbnRzJ1xuXG5pbXBvcnQgeyBrZWJhYkNhc2UgfSBmcm9tICdAdW5pLWhlbHBlci92aXRlLXBsdWdpbi11bmktY29tcG9uZW50cydcblxuZXhwb3J0IGZ1bmN0aW9uIFdvdFJlc29sdmVyKCk6IENvbXBvbmVudFJlc29sdmVyIHtcbiAgcmV0dXJuIHtcbiAgICB0eXBlOiAnY29tcG9uZW50JyxcbiAgICByZXNvbHZlOiAobmFtZTogc3RyaW5nKSA9PiB7XG4gICAgICBpZiAobmFtZS5tYXRjaCgvXldkW0EtWl0vKSkge1xuICAgICAgICBjb25zdCBjb21wTmFtZSA9IGtlYmFiQ2FzZShuYW1lKVxuICAgICAgICByZXR1cm4ge1xuICAgICAgICAgIG5hbWUsXG4gICAgICAgICAgZnJvbTogYEB3b3QtdWkvdWkvY29tcG9uZW50cy8ke2NvbXBOYW1lfS8ke2NvbXBOYW1lfS52dWVgLFxuICAgICAgICB9XG4gICAgICB9XG4gICAgfSxcbiAgfVxufVxuIl0sCiAgIm1hcHBpbmdzIjogIjtBQUE0VCxPQUFPLGFBQWE7QUFDaFYsT0FBTyxTQUFTO0FBQ2hCLFNBQVMsa0JBQWtCO0FBQzNCLE9BQU8seUJBQXlCO0FBQ2hDLE9BQU8sc0JBQXNCO0FBQzdCLE9BQU8sdUJBQXVCO0FBQzlCLE9BQU8sb0JBQW9CO0FBQzNCLE9BQU8sa0JBQWtCO0FBQ3pCLE9BQU8sZUFBZTtBQUN0QixTQUFTLDBCQUEwQjtBQUNuQyxTQUFTLGtCQUFrQjtBQUMzQixPQUFPLFlBQVk7QUFDbkIsT0FBTyxnQkFBZ0I7QUFDdkIsU0FBUyxjQUFjLGVBQWU7OztBQ1h0QyxTQUFTLGlCQUFpQjtBQUVuQixTQUFTLGNBQWlDO0FBQy9DLFNBQU87QUFBQSxJQUNMLE1BQU07QUFBQSxJQUNOLFNBQVMsQ0FBQyxTQUFpQjtBQUN6QixVQUFJLEtBQUssTUFBTSxVQUFVLEdBQUc7QUFDMUIsY0FBTSxXQUFXLFVBQVUsSUFBSTtBQUMvQixlQUFPO0FBQUEsVUFDTDtBQUFBLFVBQ0EsTUFBTSx5QkFBeUIsUUFBUSxJQUFJLFFBQVE7QUFBQSxRQUNyRDtBQUFBLE1BQ0Y7QUFBQSxJQUNGO0FBQUEsRUFDRjtBQUNGOzs7QURBQSxJQUFPLHNCQUFRLGFBQWEsQ0FBQyxFQUFFLEtBQUssTUFBTTtBQUN4QyxRQUFNLE1BQU0sUUFBUSxNQUFNLFFBQVEsSUFBSSxDQUFDO0FBRXZDLFNBQU87QUFBQTtBQUFBO0FBQUEsSUFHTCxNQUFNO0FBQUEsSUFDTixRQUFRO0FBQUEsTUFDTixNQUFNLE9BQU8sSUFBSSxhQUFhLEtBQUs7QUFBQSxJQUNyQztBQUFBLElBQ0EsY0FBYztBQUFBLE1BQ1osU0FBUyxDQUFDLGNBQWMsYUFBYTtBQUFBLElBQ3ZDO0FBQUEsSUFDQSxTQUFTO0FBQUE7QUFBQSxNQUVQLGtCQUFrQjtBQUFBO0FBQUEsTUFFbEIsZUFBZTtBQUFBLFFBQ2IsS0FBSztBQUFBLFFBQ0wsYUFBYTtBQUFBLFVBQ1g7QUFBQSxRQUNGO0FBQUE7QUFBQTtBQUFBO0FBQUE7QUFBQSxRQUtBLFNBQVMsQ0FBQyxzQkFBc0I7QUFBQSxNQUNsQyxDQUFDO0FBQUE7QUFBQSxNQUVELGlCQUFpQjtBQUFBO0FBQUEsTUFFakIsb0JBQW9CO0FBQUEsUUFDbEIsV0FBVyxDQUFDLFlBQVksR0FBRyxtQkFBbUIsQ0FBQztBQUFBLFFBQy9DLEtBQUs7QUFBQSxRQUNMLE1BQU0sQ0FBQyxnQkFBZ0I7QUFBQSxRQUN2QixzQkFBc0I7QUFBQSxNQUN4QixDQUFDO0FBQUE7QUFBQSxNQUVELFVBQVU7QUFBQTtBQUFBLE1BRVYsV0FBVztBQUFBO0FBQUEsTUFFWCxJQUFJO0FBQUE7QUFBQSxNQUVKLGFBQWE7QUFBQSxRQUNYLFFBQVE7QUFBQSxRQUNSLFFBQVE7QUFBQSxNQUNWLENBQUM7QUFBQTtBQUFBLE1BRUQsV0FBVztBQUFBLFFBQ1QsU0FBUyxDQUFDLE9BQU8sZ0JBQWdCLFNBQVMsV0FBVztBQUFBLFVBQ25ELE1BQU07QUFBQSxVQUNOLFNBQVMsQ0FBQyxnQkFBZ0IsYUFBYSxVQUFVO0FBQUEsUUFDbkQsR0FBRztBQUFBLFVBQ0QsTUFBTTtBQUFBLFVBQ04sU0FBUyxDQUFDLFlBQVksYUFBYSxhQUFhLFlBQVk7QUFBQSxRQUM5RCxHQUFHO0FBQUEsVUFDRCxNQUFNO0FBQUEsVUFDTixTQUFTLENBQUMsaUJBQWlCLFlBQVk7QUFBQSxRQUN6QyxDQUFDO0FBQUEsUUFDRCxLQUFLO0FBQUEsUUFDTCxNQUFNLENBQUMsbUJBQW1CLGFBQWEsYUFBYSxTQUFTO0FBQUE7QUFBQSxRQUU3RCxRQUFRLENBQUMsVUFBVTtBQUFBLFFBQ25CLGFBQWE7QUFBQSxNQUNmLENBQUM7QUFBQTtBQUFBO0FBQUEsTUFHRCxPQUFPO0FBQUEsSUFDVDtBQUFBLElBQ0EsS0FBSztBQUFBLE1BQ0gscUJBQXFCO0FBQUEsUUFDbkIsTUFBTTtBQUFBLFVBQ0osS0FBSztBQUFBLFVBQ0wscUJBQXFCLENBQUMsZUFBZTtBQUFBLFFBQ3ZDO0FBQUEsTUFDRjtBQUFBLElBQ0Y7QUFBQSxFQUNGO0FBQ0YsQ0FBQzsiLAogICJuYW1lcyI6IFtdCn0K
