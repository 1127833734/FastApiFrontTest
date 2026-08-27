<!--
  备件知识库 · 知识库 / 上传文档
  复刻原型 upload 页：拖拽上传 / 解析任务状态列表
-->
<template>
  <div class="kb-upload">
    <ElCard shadow="never">
      <template #header>
        <span class="kb-card-title">上传文档</span>
      </template>
      <ElAlert
        type="info"
        :closable="false"
        show-icon
        title="支持 PDF、Word、Excel、CAD 图纸等格式；大文件解析可能需要几分钟，请耐心等待。"
      />
      <div class="kb-dropzone">
        <ElUpload
          drag
          multiple
          :auto-upload="false"
          :on-change="onFileChange"
          :on-remove="onFileRemove"
          :file-list="fileList"
          accept=".pdf,.doc,.docx,.xls,.xlsx,.dwg,.png,.jpg"
          style="width: 100%"
        >
          <ElIcon :size="48" color="#9ca3af" class="kb-dropzone-icon"><UploadFilled /></ElIcon>
          <div class="kb-dropzone-text">将文件拖到此处，或<em>点击上传</em></div>
          <div class="kb-dropzone-hint">单文件不超过 200MB</div>
        </ElUpload>
      </div>
      <div class="kb-upload-actions">
        <ElButton type="primary" :icon="Upload" :disabled="fileList.length === 0" @click="startUpload">
          开始上传（{{ fileList.length }}）
        </ElButton>
        <ElButton :icon="Delete" :disabled="fileList.length === 0" @click="clearAll">清空列表</ElButton>
      </div>
    </ElCard>

    <ElCard shadow="never" v-if="tasks.length">
      <template #header>
        <span class="kb-card-title">解析任务</span>
      </template>
      <div class="kb-tasks">
        <div v-for="t in tasks" :key="t.id" class="kb-task">
          <div class="kb-task-row">
            <span class="kb-task-name">{{ t.filename }}</span>
            <ElTag :type="taskStatusColor[t.status]">{{ taskStatusText[t.status] }}</ElTag>
          </div>
          <ElProgress
            v-if="t.status === 'running'"
            :percentage="t.progress"
            :stroke-width="8"
            status="success"
          />
          <div v-if="t.status === 'failed'" class="kb-task-error">{{ t.errorMsg }}</div>
        </div>
      </div>
    </ElCard>
  </div>
</template>

<script setup lang="ts">
import { UploadFilled, Upload, Delete } from "@element-plus/icons-vue";
import type { UploadFile } from "element-plus";

defineOptions({ name: "KbUpload" });

const fileList = ref<UploadFile[]>([]);

interface ParseTask {
  id: number;
  filename: string;
  status: "pending" | "running" | "success" | "failed";
  progress: number;
  errorMsg?: string;
}

const tasks = ref<ParseTask[]>([]);
const taskStatusText: Record<string, string> = {
  pending: "排队中",
  running: "解析中",
  success: "成功",
  failed: "解析失败",
};
const taskStatusColor: Record<string, "info" | "primary" | "success" | "danger"> = {
  pending: "info",
  running: "primary",
  success: "success",
  failed: "danger",
};

function onFileChange(file: UploadFile) {
  fileList.value = [...fileList.value, file];
}

function onFileRemove() {
  // file-list 由组件内部同步
}

function clearAll() {
  fileList.value = [];
}

function startUpload() {
  const names = fileList.value.map((f) => f.name);
  fileList.value = [];
  names.forEach((name, i) => {
    const id = Date.now() + i;
    tasks.value.unshift({ id, filename: name, status: "running", progress: 10 });
    simulateParse(id);
  });
  ElMessage.success(`已提交 ${names.length} 个文件开始解析`);
}

function simulateParse(id: number) {
  let progress = 10;
  const timer = setInterval(() => {
    const t = tasks.value.find((x) => x.id === id);
    if (!t) {
      clearInterval(timer);
      return;
    }
    progress += Math.floor(Math.random() * 30) + 10;
    if (progress >= 100) {
      t.status = "success";
      t.progress = 100;
      clearInterval(timer);
    } else {
      t.status = "running";
      t.progress = progress;
    }
  }, 600);
}
</script>

<style scoped>
.kb-upload {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.kb-card-title {
  font-size: 15px;
  font-weight: 600;
  color: #111827;
}
.kb-dropzone {
  margin-top: 16px;
}
.kb-dropzone-icon {
  margin-bottom: 8px;
}
.kb-dropzone-text {
  color: #374151;
  font-size: 14px;
}
.kb-dropzone-text em {
  color: #18a058;
  font-style: normal;
}
.kb-dropzone-hint {
  color: #9ca3af;
  font-size: 12px;
  margin-top: 4px;
}
.kb-upload-actions {
  margin-top: 16px;
  display: flex;
  gap: 8px;
}
.kb-tasks {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.kb-task {
  padding: 12px;
  border-radius: 6px;
  background: #f9fafb;
}
.kb-task-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 6px;
}
.kb-task-name {
  font-size: 14px;
  color: #374151;
  font-weight: 500;
}
.kb-task-error {
  margin-top: 6px;
  font-size: 12px;
  color: #ef4444;
}
</style>
