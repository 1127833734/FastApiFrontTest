<!--
  备件知识库 · 业务场景 / 备件合规比对
  复刻原型 compliance 页：比对输入区 / 比对结果表格
-->
<template>
  <div class="kb-compliance">
    <ElCard shadow="never">
      <template #header>
        <span class="kb-card-title">备件合规比对</span>
      </template>
      <ElForm inline>
        <ElFormItem label="备件编号">
          <ElInput v-model="spareNo" placeholder="例如：SP-001" clearable style="width: 180px" />
        </ElFormItem>
        <ElFormItem label="比对规则">
          <ElSelect v-model="rule" placeholder="全部标准" clearable style="width: 180px">
            <ElOption v-for="r in rules" :key="r" :label="r" :value="r" />
          </ElSelect>
        </ElFormItem>
        <ElFormItem>
          <ElButton type="primary" :icon="ScaleToOriginal" @click="doCompare">开始比对</ElButton>
        </ElFormItem>
      </ElForm>
    </ElCard>

    <ElCard shadow="never" v-if="compared">
      <template #header>
        <div class="kb-card-header">
          <span class="kb-card-title">比对结果</span>
          <ElTag :type="resultPass ? 'success' : 'danger'">{{ resultPass ? "全部合规" : "存在冲突" }}</ElTag>
        </div>
      </template>
      <ElTable :data="compareItems" stripe>
        <ElTableColumn prop="item" label="检查项" min-width="160" />
        <ElTableColumn prop="actual" label="当前值" min-width="150" show-overflow-tooltip />
        <ElTableColumn prop="required" label="标准要求" min-width="150" show-overflow-tooltip />
        <ElTableColumn label="结果" width="110">
          <template #default="{ row }">
            <ElTag :type="row.pass ? 'success' : 'danger'" size="small">
              {{ row.pass ? "合规" : "冲突" }}
            </ElTag>
          </template>
        </ElTableColumn>
        <ElTableColumn prop="note" label="说明" min-width="180" show-overflow-tooltip />
      </ElTable>
    </ElCard>
  </div>
</template>

<script setup lang="ts">
import { ScaleToOriginal } from "@element-plus/icons-vue";

defineOptions({ name: "KbCompliance" });

const rules = ["核电备件采购规范 Q/HD-001", "密封件通用技术条件", "轴承安装与维护规程"];
const spareNo = ref("");
const rule = ref("");
const compared = ref(false);

interface CompareItem {
  item: string;
  actual: string;
  required: string;
  pass: boolean;
  note: string;
}

const compareItems = ref<CompareItem[]>([]);
const resultPass = computed(() => compareItems.value.every((i) => i.pass));

function doCompare() {
  if (!spareNo.value.trim()) {
    ElMessage.warning("请输入备件编号");
    return;
  }
  compared.value = true;
  compareItems.value = [
    { item: "供应型号与图纸一致性", actual: "6208-2RS-SKF", required: "6208-2RS（GB/T 276）", pass: true, note: "型号匹配，供应商在合格名录内" },
    { item: "材质要求", actual: "GCr15 轴承钢", required: "GCr15 轴承钢", pass: true, note: "材质符合标准" },
    { item: "采购周期检查", actual: "30 天", required: "≤ 45 天", pass: true, note: "满足大修工期要求" },
    { item: "供应商资质", actual: "SKF 授权经销商", required: "需提供核电业绩证明", pass: false, note: "缺少核电行业供货业绩证明" },
  ];
}
</script>

<style scoped>
.kb-compliance {
  display: flex;
  flex-direction: column;
  gap: 12px;
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
