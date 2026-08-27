<!--
  备件知识库 · 运维监控 / 任务监控
  复刻原型 task-monitor 页：任务列表 / 进度 / 成功失败统计
-->
<template>
  <div class="kb-tasks">
    <div class="kb-task-stats">
      <ElCard shadow="never">
        <div class="kb-stat-value">286</div>
        <div class="kb-stat-label">今日任务</div>
      </ElCard>
      <ElCard shadow="never">
        <div class="kb-stat-value" style="color: #18a058">271</div>
        <div class="kb-stat-label">今日成功</div>
      </ElCard>
      <ElCard shadow="never">
        <div class="kb-stat-value" style="color: #ef4444">5</div>
        <div class="kb-stat-label">今日失败</div>
      </ElCard>
      <ElCard shadow="never">
        <div class="kb-stat-value" style="color: #3b82f6">10</div>
        <div class="kb-stat-label">排队中</div>
      </ElCard>
    </div>

    <ElCard shadow="never">
      <template #header>
        <div class="kb-card-header">
          <span class="kb-card-title">任务列表</span>
          <div>
            <ElButton :icon="Refresh" @click="refresh">刷新</ElButton>
          </div>
        </div>
      </template>
      <ElTable :data="taskRows" stripe>
        <ElTableColumn type="index" label="序号" width="60" />
        <ElTableColumn prop="type" label="任务类型" width="150">
          <template #default="{ row }">
            <ElTag effect="plain" size="small">{{ row.type }}</ElTag>
          </template>
        </ElTableColumn>
        <ElTableColumn prop="status" label="状态" width="100">
          <template #default="{ row }">
            <ElTag :type="statusColor[row.status]" size="small">{{ statusText[row.status] }}</ElTag>
          </template>
        </ElTableColumn>
        <ElTableColumn label="进度" min-width="200">
          <template #default="{ row }">
            <ElProgress
              :percentage="row.progress"
              :status="row.status === 'failed' ? 'exception' : row.status === 'success' ? 'success' : undefined"
              :stroke-width="10"
            />
          </template>
        </ElTableColumn>
        <ElTableColumn prop="success" label="成功" width="80" align="center" />
        <ElTableColumn prop="failed" label="失败" width="80" align="center" />
        <ElTableColumn prop="errorMsg" label="错误信息" min-width="180" show-overflow-tooltip />
        <ElTableColumn prop="createdAt" label="创建时间" width="170" />
      </ElTable>
    </ElCard>
  </div>
</template>

<script setup lang="ts">
import { Refresh } from "@element-plus/icons-vue";

defineOptions({ name: "KbTaskMonitor" });

const statusText: Record<string, string> = {
  running: "运行中",
  success: "成功",
  failed: "失败",
  pending: "排队中",
};
const statusColor: Record<string, "primary" | "success" | "danger" | "info"> = {
  running: "primary",
  success: "success",
  failed: "danger",
  pending: "info",
};

const taskRows = ref([
  { type: "文档解析", status: "running", progress: 65, success: 83, failed: 0, errorMsg: "", createdAt: "2026-08-03 09:00" },
  { type: "文档复核", status: "running", progress: 30, success: 15, failed: 0, errorMsg: "", createdAt: "2026-08-03 08:30" },
  { type: "向量索引更新", status: "failed", progress: 40, success: 200, failed: 300, errorMsg: "模型服务连接超时", createdAt: "2026-08-03 08:00" },
  { type: "备件合规比对", status: "success", progress: 100, success: 45, failed: 0, errorMsg: "", createdAt: "2026-08-03 07:20" },
  { type: "采购建议生成", status: "pending", progress: 0, success: 0, failed: 0, errorMsg: "", createdAt: "2026-08-03 09:10" },
]);

function refresh() {
  ElMessage.success("任务列表已刷新");
}
</script>

<style scoped>
.kb-tasks {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.kb-task-stats {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
}
.kb-stat-value {
  font-size: 24px;
  font-weight: 700;
  color: #111827;
}
.kb-stat-label {
  font-size: 13px;
  color: #6b7280;
  margin-top: 4px;
}
.kb-card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.kb-card-title {
  font-size: 15px;
  font-weight: 600;
  color: #111827;
}
</style>
