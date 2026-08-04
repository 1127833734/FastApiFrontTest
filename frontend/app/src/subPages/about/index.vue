<script setup lang="ts">
import { useTeam } from '@/composables/useTeam'

definePage({
  name: 'about',
  style: {
    navigationBarTitleText: '关于',
  },
})

const { data: coreTeam } = useTeam()

function openUrl(url?: string) {
  if (!url) {
    return
  }

  window.open(url, '_blank')
}

// 打开公众号二维码
function openWeChat() {
  uni.previewImage({
    urls: ['https://wot-ui.cn/wechatPublicAccount.png'],
  })
}

// 打开捐赠二维码
function donate() {
  uni.previewImage({
    urls: ['https://wot-ui.cn/weixinQrcode.jpg'],
  })
}
</script>

<template>
  <view class="min-h-screen py-3">
    <!-- 头部介绍 -->
    <view class="mx-3 mb-3">
      <view class="rounded-3 px-5 py-8 text-center wot-bg-filled-oppo">
        <view class="mb-3 text-10">
          👋
        </view>
        <view class="mb-2 text-6 font-bold wot-text-text-main">
          关于我们
        </view>
        <view class="mb-2 text-3.5 leading-relaxed wot-text-text-secondary">
          轻量、高效的 uni-app 快速开发模板
        </view>
        <view class="text-3 wot-text-text-secondary">
          致力于开发轻量、高效的组件库与易用的快速开发模板
        </view>
      </view>
    </view>

    <!-- 核心团队 -->
    <demo-block title="核心团队" transparent>
      <view class="grid grid-cols-2 gap-3">
        <view
          v-for="member in coreTeam"
          :key="member.name"
          class="rounded-2 p-4 text-center wot-bg-filled-oppo active:opacity-70"
          @click="openUrl(member.github)"
        >
          <image
            :src="member.avatar"
            mode="aspectFill"
            class="mx-auto mb-2 h-16 w-16 rounded-full"
          />
          <view class="mb-1 text-3.5 font-bold wot-text-text-main">
            {{ member.name }}
          </view>
          <view class="mb-2 text-2.5" style="color: var(--primary-color, #4F8CFF);">
            {{ member.title }}
          </view>
          <view class="text-2.5 leading-snug wot-text-text-secondary">
            {{ member.desc }}
          </view>
        </view>
      </view>
    </demo-block>

    <!-- 关于 uni-helper 团队 -->
    <demo-block title="关于 uni-helper 团队" transparent>
      <view class="rounded-2 p-4 wot-bg-filled-oppo">
        <text class="mb-3 block text-3.5 leading-relaxed wot-text-text-secondary">
          <text style="color: var(--primary-color, #4F8CFF);" @click="openUrl('https://uni-helper.cn/')">
            uni-helper
          </text>
          是一个旨在增强 uni-app 系列产品的开发体验为爱发电的非官方组织。作为靠爱发电的非官方项目，uni-helper 提供了打包工具插件支持、编辑器扩展支持、NPM 包等并尽力维护它们。
        </text>
        <text class="text-3.5 leading-relaxed wot-text-text-secondary">
          在此我们特别向 uni-helper 团队表示感谢，他们为 uni-app 系列产品提供了强大的支持，包括打包工具插件支持、编辑器扩展支持等，这使我们得以站在巨人的巨人的肩膀上完成此项目。
        </text>
      </view>
    </demo-block>

    <!-- 更多信息 -->
    <demo-block title="更多信息" transparent>
      <wd-cell-group border custom-class="rounded-2! overflow-hidden">
        <wd-cell
          title="关注公众号"
          title-width="200px"
          label="uni-app教程、组件库讯息一手掌握！"
          is-link
          @click="openWeChat"
        />
        <wd-cell
          title="捐赠"
          title-width="200px"
          label="每一份捐赠都是对我们莫大的鼓励！"
          is-link
          @click="donate"
        />
      </wd-cell-group>
    </demo-block>
  </view>
</template>
