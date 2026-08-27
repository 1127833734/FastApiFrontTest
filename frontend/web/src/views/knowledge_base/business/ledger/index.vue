<!--
  备件知识库 · 业务场景 / 备件台账导出
  复刻原型 ledger 页：台账统计 / 台账表格 / 导出
-->
<template>
  <div class="kb-ledger">
    <div class="kb-ledger-stats">
      <ElCard shadow="never">
        <div class="kb-stat-value">1,248</div>
        <div class="kb-stat-label">台账总条目</div>
      </ElCard>
      <ElCard shadow="never">
        <div class="kb-stat-value">26</div>
        <div class="kb-stat-label">涉及设备</div>
      </ElCard>
      <ElCard shadow="never">
        <div class="kb-stat-value">8</div>
        <div class="kb-stat-label">低库存项</div>
      </ElCard>
    </div>

    <ElCard shadow="never">
      <template #header>
        <div class="kb-card-header">
          <span class="kb-card-title">备件台账</span>
          <div>
            <ElButton type="primary" :icon="Download" @click="exportLedger">导出台账</ElButton>
          </div>
        </div>
      </template>
      <ElTable :data="ledgerRows" stripe>
        <ElTableColumn type="index" label="序号" width="60" />
        <ElTableColumn prop="inventoryNo" label="库存编号" width="110" />
        <ElTableColumn prop="spareNo" label="备件编码" width="100" />
        <ElTableColumn prop="partName" label="名称" min-width="120" show-overflow-tooltip />
        <ElTableColumn prop="spec" label="规格" min-width="140" show-overflow-tooltip />
        <ElTableColumn prop="location" label="库位" width="110" />
        <ElTableColumn prop="quantity" label="数量" width="80" align="center" />
        <ElTableColumn prop="unitPrice" label="单价(元)" width="100" align="center" />
        <ElTableColumn prop="updatedAt" label="最近变动" width="170" />
      </ElTable>
    </ElCard>
  </div>
</template>

<script setup lang="ts">
import { Download } from "@element-plus/icons-vue";

defineOptions({ name: "KbLedger" });

const ledgerRows = [
  { inventoryNo: "INV-1001", spareNo: "SP-001", partName: "轴承 6208-2RS", spec: "6208-2RS-SKF", location: "A-01-03", quantity: 5, unitPrice: 860, updatedAt: "2026-08-02 10:20" },
  { inventoryNo: "INV-1002", spareNo: "SP-002", partName: "轴承 6208-2RS", spec: "6208-2RS-NSK", location: "A-01-04", quantity: 1, unitPrice: 790, updatedAt: "2026-07-28 15:40" },
  { inventoryNo: "INV-2005", spareNo: "SP-003", partName: "密封垫 DN50", spec: "DN50-PN16-G", location: "B-02-01", quantity: 6, unitPrice: 45, updatedAt: "2026-08-01 09:12" },
  { inventoryNo: "INV-3008", spareNo: "SP-004", partName: "碳刷 D374N", spec: "D374N-25×32×60", location: "C-03-02", quantity: 12, unitPrice: 120, updatedAt: "2026-07-30 11:00" },
  { inventoryNo: "INV-2009", spareNo: "SP-005", partName: "L型密封圈", spec: "Φ140×Φ160-F", location: "B-02-05", quantity: 2, unitPrice: 68, updatedAt: "2026-07-26 16:30" },
];

function exportLedger() {
  ElMessage.success("台账已导出（原型演示）");
}
</script>

<style scoped>
.kb-ledger {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.kb-ledger-stats {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
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
