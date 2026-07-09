<template>
  <ElCard shadow="hover" class="health-card">
    <template #header>
      <div class="flex items-center justify-between">
        <div class="flex items-center gap-2">
          <FaSvgIcon icon="ri:heart-pulse-line" class="text-base" />
          <span class="font-medium text-sm">系统健康</span>
        </div>
        <span class="text-xs text-gray-400">实时 · 30s</span>
      </div>
    </template>
    <div class="flex flex-col gap-2">
      <div v-for="row in items" :key="row.label" class="flex items-center justify-between">
        <div class="flex items-center gap-2">
          <span
            class="inline-block w-2 h-2 rounded-full"
            :class="row.status === 1 ? 'bg-green-500' : 'bg-red-500'"
          />
          <span class="text-sm">{{ row.label }}</span>
        </div>
        <span class="text-xs" :class="row.status === 1 ? 'text-gray-400' : 'text-red-500'">{{
          row.value
        }}</span>
      </div>
    </div>
  </ElCard>
</template>

<script lang="ts" setup>
import { ref, onMounted, onUnmounted } from "vue";

defineOptions({ name: "HealthStatus" });

interface Item {
  label: string;
  value: string;
  status: number;
}

const items = ref<Item[]>([
  { label: "数据库", value: "检查中…", status: 0 },
  { label: "Redis", value: "检查中…", status: 0 },
  { label: "磁盘", value: "检查中…", status: 0 },
]);

let eventSource: EventSource | null = null;

function connect() {
  const baseURL = import.meta.env.VITE_APP_BASE_API || "";
  const es = new EventSource(`${baseURL}/common/health/stream`);

  es.addEventListener("health", (event: MessageEvent) => {
    try {
      const data = JSON.parse(event.data);
      const deps = data.dependencies || {};
      items.value = [
        {
          label: "数据库",
          value: deps.database?.status ? `${deps.database.latency_ms || 0}ms` : "异常",
          status: deps.database?.status ? 1 : 0,
        },
        {
          label: "Redis",
          value: deps.redis?.status ? `${deps.redis.latency_ms || 0}ms` : "异常",
          status: deps.redis?.status ? 1 : 0,
        },
        {
          label: "磁盘",
          value: `${data.disk_usage ?? "-"}%`,
          status: (data.disk_usage ?? 100) < 90 ? 1 : 0,
        },
      ];
    } catch {
      /* 静默忽略 */
    }
  });

  es.onerror = () => {
    es.close();
  };
  eventSource = es;
}

onMounted(() => {
  connect();
});
onUnmounted(() => {
  eventSource?.close();
});
</script>

<style scoped>
.health-card {
  --el-card-border-radius: calc(var(--custom-radius) + 2px);

  border: 1px solid var(--fa-card-border);
}
</style>
