<script setup lang="ts">
import type { AIModelConfig, AIModelForm } from '@/api/module_ai/chat'
import { onLoad, onPullDownRefresh } from '@dcloudio/uni-app'
import { reactive, ref } from 'vue'
import { ChatAPI } from '@/api/module_ai/chat'
import SkeletonPage from '@/components/SkeletonPage.vue'

definePage({
  name: 'work-ai-models',
  style: { navigationBarTitleText: 'AI 模型配置' },
})

const toast = useToast()
const loading = ref(false)
const models = ref<AIModelConfig[]>([])

const showForm = ref(false)
const formTitle = ref('新建模型配置')
const editingId = ref<number | null>(null)
const submitting = ref(false)
const form = reactive<AIModelForm>({
  name: '',
  base_url: '',
  api_key: '',
  model_id: '',
  temperature: 0.7,
})

async function loadModels() {
  loading.value = true
  try {
    const res = await ChatAPI.getModels()
    models.value = res || []
  }
  catch (e) {
    toast.error(getErrorMessage(e, '加载模型列表失败'))
  }
  finally {
    loading.value = false
    uni.stopPullDownRefresh()
  }
}

function openCreate() {
  formTitle.value = '新建模型配置'
  editingId.value = null
  Object.assign(form, { name: '', base_url: '', api_key: '', model_id: '', temperature: 0.7 })
  showForm.value = true
}

function openEdit(model: AIModelConfig) {
  formTitle.value = '编辑模型配置'
  editingId.value = model.config_id
  Object.assign(form, {
    name: model.name,
    base_url: model.base_url,
    api_key: model.api_key,
    model_id: model.model_id,
    temperature: model.temperature ?? 0.7,
  })
  showForm.value = true
}

async function submitForm() {
  if (!form.name.trim())
    return toast.warning('请输入配置名称')
  if (!form.base_url.trim())
    return toast.warning('请输入 API 地址')
  if (!form.model_id.trim())
    return toast.warning('请输入模型 ID')
  submitting.value = true
  try {
    if (editingId.value) {
      await ChatAPI.updateModel(editingId.value, { ...form })
      toast.success('更新成功')
    }
    else {
      await ChatAPI.createModel({ ...form })
      toast.success('创建成功')
    }
    showForm.value = false
    loadModels()
  }
  catch (e) {
    toast.error(getErrorMessage(e, '保存失败'))
  }
  finally {
    submitting.value = false
  }
}

async function handleDelete(configId: number) {
  uni.showModal({
    title: '提示',
    content: '确认删除此模型配置？',
    success: async (res) => {
      if (!res.confirm)
        return
      try {
        await ChatAPI.deleteModel(configId)
        toast.success('删除成功')
        loadModels()
      }
      catch (e) { toast.error(getErrorMessage(e, '删除失败')) }
    },
  })
}

async function handleActivate(configId: number) {
  uni.showModal({
    title: '提示',
    content: '确认切换到此模型配置？',
    success: async (res) => {
      if (!res.confirm)
        return
      try {
        await ChatAPI.activateModel(configId)
        toast.success('已切换激活模型')
        loadModels()
      }
      catch (e) { toast.error(getErrorMessage(e, '切换失败')) }
    },
  })
}

onPullDownRefresh(() => {
  loadModels()
})
onLoad(() => {
  loadModels()
})
</script>

<template>
  <view class="list-page">
    <view class="create-btn fade-in-up" @click="openCreate">
      <text class="create-btn__icon">
        +
      </text>
      <text class="create-btn__text">
        新建模型配置
      </text>
    </view>

    <SkeletonPage v-if="loading && models.length === 0" :rows="3" />
    <ListEmpty v-else-if="!loading && models.length === 0" text="暂无模型配置" />
    <view v-else class="models-list">
      <view
        v-for="(model, idx) in models"
        :key="model.config_id"
        class="model-item" :class="[`fade-in-up-${Math.min(idx % 5 + 1, 5)}`, model.is_active && 'model-item--active']"
      >
        <view class="model-item__header">
          <view class="model-item__info">
            <text class="model-item__name">
              {{ model.name || '未命名' }}
            </text>
            <view v-if="model.is_active" class="model-item__active-tag">
              <text class="model-item__active-text">
                ● 使用中
              </text>
            </view>
          </view>
          <text class="model-item__model-id">
            {{ model.model_id }}
          </text>
        </view>

        <view class="model-item__meta">
          <text class="model-item__url">
            {{ model.base_url }}
          </text>
          <text class="model-item__temp">
            温度: {{ model.temperature ?? '—' }}
          </text>
        </view>

        <view class="model-item__actions">
          <view
            v-if="!model.is_active"
            class="model-action model-action--primary btn-press"
            @click="handleActivate(model.config_id)"
          >
            <text class="model-action__text">
              ⚡ 激活
            </text>
          </view>
          <view class="model-action btn-press" @click="openEdit(model)">
            <text class="model-action__text">
              ✎ 编辑
            </text>
          </view>
          <view class="model-action model-action--danger btn-press" @click="handleDelete(model.config_id)">
            <text class="model-action__text">
              ✕ 删除
            </text>
          </view>
        </view>
      </view>
    </view>

    <view style="height: 120rpx;" />

    <!-- Form Popup -->
    <u-popup
      :show="showForm"
      mode="bottom"
      custom-style="border-radius: 32rpx 32rpx 0 0; padding-bottom: 40rpx;"
      @close="showForm = false"
    >
      <view class="form-panel">
        <view class="form-panel__header">
          <text class="form-panel__title">
            {{ formTitle }}
          </text>
          <text class="form-panel__close" @click="showForm = false">
            ✕
          </text>
        </view>

        <view class="form-group">
          <text class="form-group__label">
            配置名称 *
          </text>
          <u-input v-model="form.name" placeholder="如：生产环境 GPT-4" clearable border="surround" />
        </view>

        <view class="form-group">
          <text class="form-group__label">
            模型 ID *
          </text>
          <u-input v-model="form.model_id" placeholder="如：gpt-4o / deepseek-chat" clearable border="surround" />
        </view>

        <view class="form-group">
          <text class="form-group__label">
            API 地址 *
          </text>
          <u-input v-model="form.base_url" placeholder="https://api.openai.com/v1" clearable border="surround" />
        </view>

        <view class="form-group">
          <text class="form-group__label">
            API Key *
          </text>
          <u-input v-model="form.api_key" placeholder="sk-..." password clearable border="surround" />
        </view>

        <view class="form-group">
          <text class="form-group__label">
            温度 (0-2)
          </text>
          <u-input v-model="form.temperature" type="number" placeholder="0.7" border="surround" />
        </view>

        <view class="form-actions">
          <u-button :block="true" type="primary" :loading="submitting" :text="editingId ? '更新' : '创建'" @click="submitForm" />
        </view>
      </view>
    </u-popup>
  </view>
</template>

<style lang="scss" scoped>
.list-page {
  padding: 0 32rpx;
  padding-bottom: 40rpx;
  background: var(--page-bg-color, #F9F9F9);
  min-height: 100vh;
}

/* ===== Create button ===== */
.create-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12rpx;
  height: 80rpx;
  background: var(--primary-color, #4F8CFF);
  border-radius: 24rpx;
  margin: 24rpx 0;
  box-shadow: 0 4rpx 16rpx rgba(1, 77, 178, 0.2);
  transition: all 0.15s ease;

  &:active { opacity: 0.85; transform: scale(0.98); }

  &__icon { font-size: 36rpx; color: #FFFFFF; font-weight: 300; }
  &__text { font-size: 28rpx; color: #FFFFFF; font-weight: 600; }
}

/* ===== Models list ===== */
.models-list {
  display: flex;
  flex-direction: column;
  gap: 16rpx;
}

.model-item {
  background: var(--card-bg-color, #FFFFFF);
  border-radius: 24rpx;
  padding: 24rpx;
  box-shadow: var(--shadow-sm, 0 1rpx 2rpx rgba(1, 77, 178,0.06));
  border: 2rpx solid transparent;
  transition: all 0.2s ease;

  &--active {
    border-color: var(--primary-color, #4F8CFF);
    box-shadow: 0 4rpx 16rpx rgba(1, 77, 178, 0.12);
  }

  &__header {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    margin-bottom: 12rpx;
  }

  &__info {
    flex: 1;
    min-width: 0;
    display: flex;
    align-items: center;
    gap: 12rpx;
  }

  &__name {
    font-size: 30rpx;
    font-weight: 600;
    color: var(--text-color, #0A1628);
  }

  &__active-tag {
    background: rgba(16, 185, 129, 0.1);
    padding: 2rpx 10rpx;
    border-radius: 8rpx;
  }

  &__active-text {
    font-size: 20rpx;
    color: #10B981;
    font-weight: 500;
  }

  &__model-id {
    font-size: 22rpx;
    color: var(--primary-color, #4F8CFF);
    background: var(--primary-color-light, rgba(1,77,178,0.08));
    padding: 4rpx 12rpx;
    border-radius: 8rpx;
    font-family: 'SF Mono', 'Consolas', monospace;
    flex-shrink: 0;
  }

  &__meta {
    display: flex;
    align-items: center;
    gap: 16rpx;
    margin-bottom: 16rpx;
  }

  &__url {
    font-size: 24rpx;
    color: var(--text-color-3, #6B7280);
    font-family: 'SF Mono', 'Consolas', monospace;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    flex: 1;
  }

  &__temp {
    font-size: 22rpx;
    color: var(--text-color-4, #B0B0B0);
    flex-shrink: 0;
  }

  &__actions {
    display: flex;
    gap: 12rpx;
    padding-top: 12rpx;
    border-top: 1rpx solid var(--border-color, #F0F0F0);
  }
}

.model-action {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  height: 56rpx;
  border-radius: 12rpx;
  background: var(--bg-color-2, #F5F6F8);
  transition: all 0.15s ease;

  &--primary { background: var(--primary-color-light, rgba(1,77,178,0.08)); }
  &--danger { background: var(--danger-color-light, #FEF2F2); }

  &--primary .model-action__text { color: var(--primary-color, #4F8CFF); }
  &--danger .model-action__text { color: var(--danger-color, #EF4444); }

  &__text {
    font-size: 22rpx;
    font-weight: 500;
    color: var(--text-color-2, #4B5563);
    white-space: nowrap;
  }

  &:active { opacity: 0.7; transform: scale(0.95); }
}

/* ===== Form Panel ===== */
.form-panel {
  padding: 32rpx;

  &__header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 32rpx;
  }

  &__title {
    font-size: 34rpx;
    font-weight: 700;
    color: var(--text-color, #0A1628);
  }

  &__close {
    font-size: 32rpx;
    color: var(--text-color-3, #6B7280);
    width: 56rpx;
    height: 56rpx;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 50%;
    background: var(--bg-color-2, #F5F6F8);
    &:active { opacity: 0.6; }
  }
}

.form-group {
  margin-bottom: 24rpx;

  &__label {
    display: block;
    font-size: 26rpx;
    font-weight: 500;
    color: var(--text-color-2, #4B5563);
    margin-bottom: 12rpx;
  }
}

.form-actions {
  margin-top: 32rpx;
}
</style>
