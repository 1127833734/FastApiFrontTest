<script setup lang="ts">
import type { AIModelConfig, AIModelForm } from '@/api/module_ai/chat'
import { onLoad, onPullDownRefresh } from '@dcloudio/uni-app'
import { reactive, ref } from 'vue'
import { ChatAPI } from '@/api/module_ai/chat'

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
  catch { toast.error('加载模型列表失败') }
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
  catch { toast.error('保存失败') }
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
      catch { toast.error('删除失败') }
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
      catch { toast.error('切换失败') }
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
  <view class="page-wraper">
    <!-- Meta bar -->
    <view class="action-bar">
      <text class="text-md text-muted font-bold">
        共 {{ models.length }} 条
      </text>
      <wd-button size="small" type="primary" @click="openCreate">
        + 新建配置
      </wd-button>
    </view>

    <!-- List -->
    <SkeletonPage v-if="loading && models.length === 0" :rows="3" />
    <template v-else>
      <view class="px-sm">
        <view class="admin-card">
          <wd-empty v-if="!loading && models.length === 0" tip="暂无模型配置" />
          <wd-cell-group v-else>
            <wd-cell v-for="model in models" :key="model.config_id" center>
              <template #title>
                <view class="flex items-center gap-2">
                  <text class="truncate text-3.5 font-medium wot-text-text-main">
                    {{ model.name || '未命名' }}
                  </text>
                  <wd-tag v-if="model.is_active" size="small" type="success" round>
                    使用中
                  </wd-tag>
                </view>
              </template>
              <template #label>
                <view class="flex flex-col">
                  <text class="truncate text-2.5 wot-text-text-auxiliary">
                    {{ model.model_id }} · 温度 {{ model.temperature ?? '—' }}
                  </text>
                  <text class="truncate text-2.5 wot-text-text-auxiliary">
                    {{ model.base_url }}
                  </text>
                </view>
              </template>
              <template #default>
                <view class="flex items-center gap-2">
                  <wd-button
                    v-if="!model.is_active"
                    size="mini"
                    type="primary"
                    variant="plain"
                    @click.stop="handleActivate(model.config_id)"
                  >
                    激活
                  </wd-button>
                  <wd-icon name="edit" size="18px" color="var(--text-color-3, #6B7280)" @click.stop="openEdit(model)" />
                  <wd-icon name="delete" size="18px" color="var(--danger-color)" @click.stop="handleDelete(model.config_id)" />
                </view>
              </template>
            </wd-cell>
          </wd-cell-group>
        </view>
      </view>
    </template>

    <!-- Form Popup -->
    <wd-popup v-model="showForm" position="bottom" round custom-style="max-height: 80vh; overflow-y: auto;" @close="showForm = false">
      <view class="p-xl">
        <wd-navbar :title="formTitle" left-arrow @click-left="showForm = false" />
        <wd-form :model="form" class="mt-lg">
          <wd-form-item label="配置名称" border>
            <wd-input v-model="form.name" placeholder="如：生产环境 GPT-4" clearable />
          </wd-form-item>
          <wd-form-item label="模型 ID" border>
            <wd-input v-model="form.model_id" placeholder="如：gpt-4o / deepseek-chat" clearable />
          </wd-form-item>
          <wd-form-item label="API 地址" border>
            <wd-input v-model="form.base_url" placeholder="https://api.openai.com/v1" clearable />
          </wd-form-item>
          <wd-form-item label="API Key" border>
            <wd-input v-model="form.api_key" placeholder="sk-..." show-password clearable />
          </wd-form-item>
          <wd-form-item label="温度 (0-2)" border>
            <wd-input v-model="form.temperature" type="number" placeholder="0.7" />
          </wd-form-item>
        </wd-form>
        <view class="gap-md mt-xl flex">
          <wd-button variant="plain" block @click="showForm = false">
            取消
          </wd-button>
          <wd-button block type="primary" :loading="submitting" @click="submitForm">
            {{ editingId ? '更新' : '创建' }}
          </wd-button>
        </view>
      </view>
    </wd-popup>
  </view>
</template>
