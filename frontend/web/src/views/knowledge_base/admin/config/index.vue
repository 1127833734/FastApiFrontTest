<!--
  备件知识库 · 系统管理 / 系统参数
  复刻原型 system-config 页：参数模块分组 + 配置表格
-->
<template>
  <div class="kb-config">
    <ElTabs v-model="activeModule">
      <ElTabPane v-for="m in modules" :key="m.key" :label="m.label" :name="m.key">
        <ElTable :data="m.items" stripe>
          <ElTableColumn type="index" label="序号" width="60" />
          <ElTableColumn prop="paramKey" label="参数键" min-width="200" show-overflow-tooltip />
          <ElTableColumn prop="defaultValue" label="默认值" min-width="140" show-overflow-tooltip />
          <ElTableColumn prop="currentValue" label="当前值" min-width="140" show-overflow-tooltip />
          <ElTableColumn prop="desc" label="说明" min-width="240" show-overflow-tooltip />
          <ElTableColumn label="操作" width="110" fixed="right">
            <template #default="{ row }">
              <ElButton link type="primary" @click="editParam(row)">修改</ElButton>
            </template>
          </ElTableColumn>
        </ElTable>
      </ElTabPane>
    </ElTabs>
  </div>
</template>

<script setup lang="ts">
defineOptions({ name: "KbSystemConfig" });

const activeModule = ref("llm");

interface ParamItem {
  paramKey: string;
  defaultValue: string;
  currentValue: string;
  desc: string;
}

const modules = ref<{ key: string; label: string; items: ParamItem[] }[]>([
  {
    key: "llm",
    label: "大模型",
    items: [
      { paramKey: "llm.base_url", defaultValue: "https://api.deepseek.com", currentValue: "https://api.deepseek.com", desc: "大模型服务基础地址" },
      { paramKey: "llm.model", defaultValue: "deepseek-chat", currentValue: "deepseek-v4-flash", desc: "默认对话模型" },
      { paramKey: "llm.temperature", defaultValue: "0.7", currentValue: "0.5", desc: "生成随机性，知识库问答建议调低" },
    ],
  },
  {
    key: "kb",
    label: "知识库",
    items: [
      { paramKey: "kb.chunk_size", defaultValue: "512", currentValue: "512", desc: "文档文本切片大小（字符）" },
      { paramKey: "kb.ocr_enabled", defaultValue: "true", currentValue: "true", desc: "扫描件 OCR 识别开关" },
      { paramKey: "kb.review_required", defaultValue: "true", currentValue: "true", desc: "入库前是否强制人工复核" },
    ],
  },
  {
    key: "spare",
    label: "备件",
    items: [
      { paramKey: "spare.min_stock_alert", defaultValue: "true", currentValue: "true", desc: "低库存预警开关" },
      { paramKey: "spare.procurement_cycle_max", defaultValue: "45", currentValue: "45", desc: "采购周期上限（天），超出触发提醒" },
    ],
  },
  {
    key: "system",
    label: "系统",
    items: [
      { paramKey: "sys.site_name", defaultValue: "核电备件知识库", currentValue: "核电备件知识库", desc: "系统名称" },
      { paramKey: "sys.dark_mode", defaultValue: "false", currentValue: "false", desc: "暗色模式开关" },
    ],
  },
]);

function editParam(row: ParamItem) {
  ElMessage.info(`修改参数：${row.paramKey}（原型演示）`);
}
</script>

<style scoped>
.kb-config {
  padding: 0;
}
</style>
