<script setup lang="ts">
import type { PasswordChangeForm } from '@/api/module_system/user'
import { reactive, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import UserAPI from '@/api/module_system/user'

definePage({
  name: 'account',
  layout: 'default',
  style: { navigationBarTitleText: '修改密码' },
})

const { t } = useI18n()
const toast = useToast()

const showPasswordDialog = ref(false)
const submitting = ref(false)
const passwordForm = reactive<PasswordChangeForm>({
  old_password: '',
  new_password: '',
  confirm_password: '',
})

function openPasswordDialog() {
  passwordForm.old_password = ''
  passwordForm.new_password = ''
  passwordForm.confirm_password = ''
  showPasswordDialog.value = true
}

/** 提交修改密码：字段级校验 + 调用后端接口 */
async function handleSubmit() {
  if (!passwordForm.old_password) {
    toast.warning(t('account.oldRequired'))
    return
  }
  if (!passwordForm.new_password) {
    toast.warning(t('account.newRequired'))
    return
  }
  if (passwordForm.new_password.length < 6) {
    toast.warning(t('account.newLength'))
    return
  }
  if (!passwordForm.confirm_password) {
    toast.warning(t('account.confirmRequired'))
    return
  }
  if (passwordForm.confirm_password !== passwordForm.new_password) {
    toast.warning(t('account.mismatch'))
    return
  }

  submitting.value = true
  try {
    await UserAPI.changeCurrentUserPassword({
      old_password: passwordForm.old_password,
      new_password: passwordForm.new_password,
      confirm_password: passwordForm.confirm_password,
    })
    toast.success(t('account.success'))
    showPasswordDialog.value = false
  }
  catch {
    // http 层已统一错误提示
  }
  finally {
    submitting.value = false
  }
}
</script>

<template>
  <view class="page-wraper py-3">
    <view class="mx-3">
      <wd-cell-group border custom-class="rounded-2! overflow-hidden">
        <wd-cell
          :title="$t('account.password')"
          :label="$t('account.passwordTip')"
          is-link
          @click="openPasswordDialog"
        >
          <template #value>
            <text class="wot-text-text-secondary">
              {{ $t('account.modify') }}
            </text>
          </template>
        </wd-cell>
      </wd-cell-group>
    </view>

    <!-- 修改密码弹窗 -->
    <wd-popup
      v-model="showPasswordDialog"
      position="bottom"
      round
      custom-style="padding-bottom: env(safe-area-inset-bottom);"
    >
      <view class="px-4 pb-4 pt-4">
        <view class="mb-4 text-center text-4 font-bold wot-text-text-main">
          {{ $t('account.password') }}
        </view>
        <wd-input
          v-model="passwordForm.old_password"
          :label="$t('account.oldPassword')"
          show-password
          clearable
          :placeholder="$t('account.oldPlaceholder')"
        />
        <view class="h-3" />
        <wd-input
          v-model="passwordForm.new_password"
          :label="$t('account.newPassword')"
          show-password
          clearable
          :placeholder="$t('account.newPlaceholder')"
        />
        <view class="h-3" />
        <wd-input
          v-model="passwordForm.confirm_password"
          :label="$t('account.confirmPassword')"
          show-password
          clearable
          :placeholder="$t('account.confirmPlaceholder')"
        />
        <view class="mt-5">
          <wd-button type="primary" round block :loading="submitting" @click="handleSubmit">
            {{ $t('account.submit') }}
          </wd-button>
        </view>
      </view>
      <wd-gap :height="20" />
    </wd-popup>
  </view>
</template>
