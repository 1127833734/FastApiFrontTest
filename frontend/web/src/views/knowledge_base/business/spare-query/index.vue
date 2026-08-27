<!--
  备件知识库 · 业务场景 / 备件精准查询
  复刻原型 spare-query 页：查询输入区 / 查询结果表格
-->
<template>
  <div class="kb-spare-query">
    <ElCard shadow="never">
      <template #header>
        <span class="kb-card-title">备件精准查询</span>
      </template>
      <ElForm inline>
        <ElFormItem label="零件编号 / 名称">
          <ElInput
            v-model="keyword"
            placeholder="例如：P101-001 或 轴承"
            clearable
            style="width: 260px"
            @keyup.enter="doQuery"
          />
        </ElFormItem>
        <ElFormItem label="机组">
          <ElSelect v-model="unit" placeholder="全部机组" clearable style="width: 120px">
            <ElOption label="1#机组" value="1#机组" />
            <ElOption label="2#机组" value="2#机组" />
          </ElSelect>
        </ElFormItem>
        <ElFormItem>
          <ElButton type="primary" :icon="Search" @click="doQuery">查询</ElButton>
        </ElFormItem>
      </ElForm>
    </ElCard>

    <ElCard shadow="never">
      <template #header>
        <span class="kb-card-title">查询结果（{{ resultCount }}）</span>
      </template>
      <ElTable :data="queryResult" stripe>
        <ElTableColumn prop="partNo" label="零件编号" width="110" />
        <ElTableColumn prop="name" label="名称" width="100" />
        <ElTableColumn prop="spec" label="型号规格" min-width="140" show-overflow-tooltip />
        <ElTableColumn prop="system" label="所属系统" width="110" />
        <ElTableColumn prop="device" label="所属设备" min-width="130" show-overflow-tooltip />
        <ElTableColumn prop="inventory" label="当前库存" width="90" align="center" />
        <ElTableColumn prop="supplier" label="供应商" width="110" />
        <ElTableColumn prop="procurementCycle" label="采购周期(天)" width="110" align="center" />
      </ElTable>
      <ElEmpty v-if="queryResult.length === 0 && queried" description="未找到匹配的备件，请调整查询条件" />
    </ElCard>
  </div>
</template>

<script setup lang="ts">
import { Search } from "@element-plus/icons-vue";

defineOptions({ name: "KbSpareQuery" });

const keyword = ref("");
const unit = ref("");
const queried = ref(false);

const dataSource = [
  { partNo: "P101-001", name: "轴承", spec: "6208-2RS", system: "给水系统", device: "泵 P-101", inventory: 5, supplier: "SKF", procurementCycle: 30 },
  { partNo: "P101-002", name: "轴承", spec: "6207-2RS", system: "给水系统", device: "泵 P-101", inventory: 3, supplier: "NSK", procurementCycle: 25 },
  { partNo: "V201-005", name: "密封垫", spec: "DN50 PN16", system: "蒸汽系统", device: "主汽阀 MV-201", inventory: 6, supplier: "南方密封", procurementCycle: 20 },
  { partNo: "M105-012", name: "碳刷", spec: "D374N 25×32×60", system: "电气系统", device: "电机 M-105", inventory: 12, supplier: "哈尔滨轴承", procurementCycle: 15 },
];

const queryResult = computed(() => {
  if (!queried.value) return [];
  return dataSource.filter((p) => {
    if (keyword.value) {
      const kw = keyword.value.trim();
      if (!p.partNo.includes(kw) && !p.name.includes(kw) && !p.spec.includes(kw)) return false;
    }
    if (unit.value && !p.system.includes(unit.value)) return false;
    return true;
  });
});

const resultCount = computed(() => queryResult.value.length);

function doQuery() {
  queried.value = true;
  if (queryResult.value.length === 0) {
    ElMessage.warning("未找到匹配的备件");
  }
}
</script>

<style scoped>
.kb-spare-query {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.kb-card-title {
  font-size: 15px;
  font-weight: 600;
  color: #111827;
}
</style>
