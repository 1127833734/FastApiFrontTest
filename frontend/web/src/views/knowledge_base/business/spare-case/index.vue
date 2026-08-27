<!--
  备件知识库 · 业务场景 / 备件管理案例
  复刻原型 spare-management-case 页：备件准备闭环 + BOM 联动
-->
<template>
  <div class="kb-scase">
    <ElCard shadow="never">
      <template #header>
        <div class="kb-card-header">
          <span class="kb-card-title">备件管理案例</span>
          <ElTag type="warning" effect="plain">示例案例</ElTag>
        </div>
      </template>
      <ElDescriptions :column="2" border size="small">
        <ElDescriptionsItem label="案例编号">CASE-S-0001</ElDescriptionsItem>
        <ElDescriptionsItem label="关联场景">泵 P-101 大修备件准备</ElDescriptionsItem>
        <ElDescriptionsItem label="触发方式">维修工单 → 知识库联动</ElDescriptionsItem>
        <ElDescriptionsItem label="备件数量">3 类 / 8 件</ElDescriptionsItem>
      </ElDescriptions>
      <div class="kb-scase-desc">
        <p>
          本案例演示<b>备件准备闭环</b>：设备维修工单下发后，知识库根据 BOM 结构与历史维修记录
          自动触发备件需求，备件库管负责备件准备与出库，采购员按需求执行采购。
        </p>
      </div>
    </ElCard>

    <ElCard shadow="never">
      <template #header>
        <span class="kb-card-title">备件联动清单</span>
      </template>
      <ElTable :data="spareLinks" stripe>
        <ElTableColumn type="index" label="序号" width="60" />
        <ElTableColumn prop="partNo" label="零件编号" width="110" />
        <ElTableColumn prop="name" label="名称" width="110" />
        <ElTableColumn prop="spec" label="规格" min-width="150" show-overflow-tooltip />
        <ElTableColumn prop="quantity" label="需求数量" width="90" align="center" />
        <ElTableColumn label="联动方式" width="120">
          <template #default="{ row }">
            <ElTag size="small" :type="row.auto ? 'primary' : 'info'" effect="plain">
              {{ row.auto ? "自动触发" : "人工确认" }}
            </ElTag>
          </template>
        </ElTableColumn>
        <ElTableColumn label="状态" width="100">
          <template #default="{ row }">
            <ElTag size="small" :type="row.status === '已备好' ? 'success' : row.status === '待采购' ? 'danger' : 'warning'">
              {{ row.status }}
            </ElTag>
          </template>
        </ElTableColumn>
      </ElTable>
    </ElCard>

    <ElCard shadow="never">
      <template #header>
        <span class="kb-card-title">BOM 结构（泵 P-101）</span>
      </template>
      <ElTree :data="bomTree" :props="{ label: 'label', children: 'children' }" default-expand-all />
    </ElCard>
  </div>
</template>

<script setup lang="ts">
defineOptions({ name: "KbSpareCase" });

const spareLinks = [
  { partNo: "P101-001", name: "轴承", spec: "6208-2RS", quantity: 2, auto: true, status: "已备好" },
  { partNo: "P101-002", name: "轴承", spec: "6207-2RS", quantity: 2, auto: true, status: "已备好" },
  { partNo: "V201-005", name: "密封垫", spec: "DN50 PN16", quantity: 4, auto: false, status: "待采购" },
];

const bomTree = [
  {
    label: "泵 P-101（卧式离心泵）",
    children: [
      { label: "泵体组件", children: [{ label: "泵壳" }, { label: "叶轮" }] },
      {
        label: "转子组件",
        children: [
          { label: "轴承 6208-2RS（驱动端）" },
          { label: "轴承 6207-2RS（非驱动端）" },
          { label: "轴" },
        ],
      },
      { label: "轴封组件", children: [{ label: "机械密封 50-80" }, { label: "密封垫 DN50 PN16" }] },
    ],
  },
];
</script>

<style scoped>
.kb-scase {
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
.kb-scase-desc {
  margin-top: 14px;
  font-size: 14px;
  line-height: 1.9;
  color: #374151;
  background: #f9fafb;
  border-radius: 6px;
  padding: 12px 16px;
}
</style>
