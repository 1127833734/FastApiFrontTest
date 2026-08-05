<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import { useGlobalDialog } from '@/composables/useGlobalDialog'
import {
  ACCESS_TOKEN_KEY,
  DICT_CACHE_KEY,
  LANG_KEY,
  REFRESH_TOKEN_KEY,
  REMEMBER_ME_KEY,
  USER_INFO_KEY,
  WATERMARK_KEY,
} from '@/constants'
import { useConfigStore } from '@/store/configStore'
import { Storage } from '@/utils/storage'

definePage({
  name: 'setting',
  layout: 'default',
  style: {
    navigationBarTitleText: '设置',
  },
})
const { success: showSuccess } = useGlobalToast()
const { t, locale } = useI18n()
const router = useRouter()
const globalDialog = useGlobalDialog()
const configStore = useConfigStore()
// 拉取系统参数（品牌介绍/相关链接/版本/水印开关），幂等 + 本地持久化缓存
configStore.getConfig()

/** 语言切换 */
const showLangSheet = ref(false)
const langOptions = [
  { label: '简体中文', value: 'zh-CN' },
  { label: 'English', value: 'en-US' },
]
const currentLang = computed(() => langOptions.find(o => o.value === locale.value)?.label || langOptions[0].label)

function handleLangSelect(option: { label: string, value: string }) {
  locale.value = option.value
  Storage.set(LANG_KEY, option.value)
  showLangSheet.value = false
}

/** 品牌区与相关链接参数（来自后端系统参数，带默认值兜底；web 端消费方式：configData?.[key]?.config_value） */
const brandTitle = computed(() => configStore.configData?.sys_name?.config_value?.trim() || 'FastapiAdmin')
const brandDesc = computed(() => configStore.configData?.login_subtitle?.config_value?.trim() || '提供安全、高效、可扩展的管理解决方案')
const helpDoc = computed(() => configStore.configData?.help_doc?.config_value?.trim() || '')
const gitCode = computed(() => configStore.configData?.git_code?.config_value?.trim() || '')

/** 当前系统版本（后端 version 参数） */
const version = computed(() => configStore.configData?.version?.config_value?.trim() || '')

/** 本地水印偏好，默认开启，由本页开关控制（历史脏数据统一兜底为布尔，避免脏值传给 switch） */
const watermarkSwitch = ref(Boolean(Storage.get<boolean>(WATERMARK_KEY) ?? true))

function handleWatermarkChange(value: boolean) {
  Storage.set(WATERMARK_KEY, value)
}

// 跳转关于页
function navigateToAbout() {
  router.push({ name: 'about' })
}

/** 清除本地缓存：清认证与数据缓存（保留主题、水印偏好），清除后回到登录页 */
function clearLocalCache() {
  ;[ACCESS_TOKEN_KEY, REFRESH_TOKEN_KEY, USER_INFO_KEY, REMEMBER_ME_KEY, DICT_CACHE_KEY, 'appUserInfo', 'appConfig']
    .forEach(key => Storage.remove(key))
  uni.reLaunch({ url: '/pages/login/index' })
}

function handleClearCache() {
  globalDialog.confirm({
    title: t('common.title'),
    msg: t('setting.clearCacheMsg'),
    confirmButtonText: t('setting.clearCacheConfirm'),
    success: (res) => {
      if (res.action === 'confirm')
        clearLocalCache()
    },
  })
}
const {
  theme,
  toggleTheme,
  currentThemeColor,
  showThemeColorSheet,
  themeColorOptions,
  openThemeColorPicker,
  closeThemeColorPicker,
  selectThemeColor,
  setFollowSystem,
} = useManualTheme()

const isDark = computed({
  get() {
    return theme.value === 'dark'
  },
  set() {
    toggleTheme()
  },
})

// 处理主题色选择
function handleThemeColorSelect(option: any) {
  selectThemeColor(option)
}

// 链接导航处理
function handleNavigate(url: string) {
  if (!url)
    return
  // #ifdef H5
  window.open(url, '_blank')
  // #endif
  // #ifndef H5
  uni.setClipboardData({
    data: url,
    showToast: false,
    success: () => {
      uni.hideToast()
      showSuccess({ msg: t('setting.copied', { url }) })
    },
  })
  // #endif
}
</script>

<template>
  <view class="box-border py-3">
    <view class="mx-3 box-border rounded-3 px-4 py-6 text-center wot-bg-filled-oppo">
      <text class="mb-3 block text-left text-5 font-bold wot-text-text-main">
        {{ brandTitle }}
      </text>
      <text class="mb-3 block text-left text-30rpx leading-relaxed wot-text-text-secondary">
        {{ brandDesc }}
      </text>
    </view>

    <view class="mx-3 mb-3">
      <view class="mb-2 px-1 text-3.5 font-bold wot-text-text-main">
        {{ $t('setting.basic') }}
      </view>
      <wd-cell-group border custom-class="rounded-2! overflow-hidden">
        <wd-cell :title="$t('setting.darkMode')">
          <wd-switch v-model="isDark" size="18px" />
        </wd-cell>
        <wd-cell :title="$t('setting.followSystem')">
          <wd-button size="small" @click="setFollowSystem(true)">
            {{ $t('setting.followSystem') }}
          </wd-button>
        </wd-cell>
        <wd-cell :title="$t('setting.themeColor')" is-link @click="openThemeColorPicker">
          <view class="flex items-center justify-end gap-2">
            <view
              class="h-4 w-4 rounded-full"
              :style="{ backgroundColor: currentThemeColor.primary }"
            />
            <text>{{ currentThemeColor.name }}</text>
          </view>
        </wd-cell>
        <wd-cell :title="$t('setting.watermark')" :is-link="false">
          <wd-switch
            v-model="watermarkSwitch"
            size="18px"
            @change="handleWatermarkChange"
          />
        </wd-cell>
      </wd-cell-group>
    </view>

    <view class="mx-3">
      <view class="mb-2 px-1 text-3.5 font-bold wot-text-text-main">
        {{ $t('setting.links') }}
      </view>
      <wd-cell-group border custom-class="rounded-2! overflow-hidden">
        <wd-cell :title="$t('setting.docs')" is-link @click="handleNavigate(helpDoc)" />
        <wd-cell :title="$t('setting.github')" is-link @click="handleNavigate(gitCode)" />
      </wd-cell-group>
    </view>

    <view class="mx-3 mt-3">
      <view class="mb-2 px-1 text-3.5 font-bold wot-text-text-main">
        {{ $t('setting.general') }}
      </view>
      <wd-cell-group border custom-class="rounded-2! overflow-hidden">
        <wd-cell :title="$t('setting.language')" is-link @click="showLangSheet = true">
          <text class="text-3 wot-text-text-secondary">
            {{ currentLang }}
          </text>
        </wd-cell>
        <wd-cell :title="$t('setting.version')" :is-link="false">
          <text class="text-3 wot-text-text-secondary">
            v{{ version || '--' }}
          </text>
        </wd-cell>
        <wd-cell :title="$t('setting.about')" is-link @click="navigateToAbout" />
        <wd-cell :title="$t('setting.clearCache')" is-link @click="handleClearCache" />
      </wd-cell-group>
    </view>

    <!-- 底部安全区（全面屏 Home 条避让） -->
    <wd-gap height="100rpx" safe-area-bottom />

    <!-- 主题色选择 ActionSheet -->
    <wd-action-sheet
      v-model="showThemeColorSheet"
      :title="$t('setting.themeColor')"
      :close-on-click-action="true"
      @cancel="closeThemeColorPicker"
    >
      <view class="px-4 pb-4">
        <view
          v-for="option in themeColorOptions"
          :key="option.value"
          class="flex items-center justify-between border-b py-3 wot-border-border-main last:border-b-0"
          @click="handleThemeColorSelect(option)"
        >
          <view class="flex items-center gap-3">
            <view
              class="h-6 w-6 border-2 rounded-full wot-border-border-main"
              :style="{ backgroundColor: option.primary }"
            />
            <text class="text-4 wot-text-text-main">
              {{ option.name }}
            </text>
          </view>
          <wd-icon
            v-if="currentThemeColor.value === option.value"
            name="check"
            :color="option.primary"
            size="20px"
          />
        </view>
      </view>
      <wd-gap :height="50" />
    </wd-action-sheet>

    <!-- 语言选择 ActionSheet -->
    <wd-action-sheet
      v-model="showLangSheet"
      :title="$t('setting.language')"
      :close-on-click-action="true"
      @cancel="showLangSheet = false"
    >
      <view class="px-4 pb-4">
        <view
          v-for="option in langOptions"
          :key="option.value"
          class="flex items-center justify-between border-b py-3 wot-border-border-main last:border-b-0"
          @click="handleLangSelect(option)"
        >
          <text class="text-4 wot-text-text-main">
            {{ option.label }}
          </text>
          <wd-icon
            v-if="locale === option.value"
            name="check"
            color="var(--primary-color, #4F8CFF)"
            size="20px"
          />
        </view>
      </view>
      <wd-gap :height="50" />
    </wd-action-sheet>
  </view>
</template>
