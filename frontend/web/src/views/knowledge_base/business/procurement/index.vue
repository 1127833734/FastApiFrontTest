<!--
  备件知识库 · 业务场景 / 采购辅助生成
  复刻原型 procurement 页：AI 采购建议 / 采购申请单草稿
-->
<template>
  <div class="kb-procurement">
    <ElCard shadow="never">
      <template #header>
        <div class="kb-card-header">
          <span class="kb-card-title">AI 采购建议</span>
          <ElButton type="primary" :icon="MagicStick" @click="generate">智能生成建议</ElButton>
        </div>
      </template>
      <ElTable :data="suggestions" stripe>
        <ElTableColumn type="index" label="序号" width="60" />
        <ElTableColumn prop="partNo" label="零件编号" width="110" />
        <ElTableColumn prop="name" label="名称" width="100" />
        <ElTableColumn prop="spec" label="规格" min-width="140" show-overflow-tooltip />
        <ElTableColumn prop="supplier" label="推荐供应商" width="120" />
        <ElTableColumn prop="procurementCycle" label="采购周期(天)" width="110" align="center" />
        <ElTableColumn label="建议类型" width="100">
          <template #default="{ row }">
            <ElTag :type="row.type === '紧急采购' ? 'danger' : row.type === '常规采购' ? 'primary' : 'info'" size="small">
              {{ row.type }}
            </ElTag>
          </template>
        </ElTableColumn>
        <ElTableColumn prop="reason" label="建议理由" min-width="200" show-overflow-tooltip />
      </ElTable>
      <ElEmpty v-if="suggestions.length === 0" description="点击「智能生成建议」，AI 将根据库存与维修计划生成采购建议" />
    </ElCard>

    <ElCard shadow="never" v-if="suggestions.length">
      <template #header>
        <span class="kb-card-title">采购申请单草稿</span>
      </template>
      <div class="kb-draft">
        <ElDescriptions :column="3" border size="small">
          <ElDescriptionsItem label="申请单号">PR-2026-0812</ElDescriptionsItem>
          <ElDescriptionsItem label="申请人">备件部 · 刘工</ElDescriptionsItem>
          <ElDescriptionsItem label="申请日期">2026-08-12</ElDescriptionsItem>
          <ElDescriptionsItem label="关联维修工单">WO-2026-0715（泵 P-101 大修）</ElDescriptionsItem>
          <ElDescriptionsItem label="到货要求">2026-09-30 前</ElDescriptionsItem>
          <ElDescriptionsItem label="总金额（预估）">¥ 18,600</ElDescriptionsItem>
        </ElDescriptions>
        <div class="kb-draft-actions">
          <ElButton type="primary" :icon="DocumentAdd" @click="submitDraft">提交采购申请</ElButton>
          <ElButton :icon="EditPen" @click="editDraft">编辑草稿</ElButton>
        </div>
      </div>
    </ElCard>
  </div>
</template>

<script setup lang="ts">
import { MagicStick, DocumentAdd, EditPen } from "@element-plus/icons-vue";

defineOptions({ name: "KbProcurement" });

interface Suggestion {
  partNo: string;
  name: string;
  spec: string;
  supplier: string;
  procurementCycle: number;
  type: string;
  reason: string;
}

const suggestions = ref<Suggestion[]>([]);

function generate() {
  suggestions.value = [
    { partNo: "P101-001", name: "轴承", spec: "6208-2RS", supplier: "SKF", procurementCycle: 30, type: "紧急采购", reason: "库存 1 件低于安全库存 2 件，大修计划 9 月开工" },
    { partNo: "V201-006", name: "L型密封圈", spec: "Φ140×Φ160", supplier: "南方密封", procurementCycle: 20, type: "常规采购", reason: "库存 2 件接近最低库存，周期性消耗" },
    { partNo: "M105-012", name: "碳刷", spec: "D374N 25×32×60", supplier: "哈尔滨轴承", procurementCycle: 15, type: "常规采购", reason: "库存充足但易耗，建议按年度框架合同补货" },
  ];
  ElMessage.success("已生成采购建议");
}

function submitDraft() {
  ElMessage.success("采购申请单已提交（原型演示）");
}
function editDraft() {
  ElMessage.info("编辑采购申请单草稿");
}
</script>

<style scoped>
.kb-procurement {
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
.kb-draft-actions {
  margin-top: 16px;
  display: flex;
  gap: 8px;
}
</style>
