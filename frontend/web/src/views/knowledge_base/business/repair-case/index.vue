<!--
  备件知识库 · 业务场景 / 维修管理案例
  复刻原型 repair-management-case 页：维修闭环管理 + 经验沉淀
-->
<template>
  <div class="kb-rcase">
    <ElCard shadow="never">
      <template #header>
        <div class="kb-card-header">
          <span class="kb-card-title">维修管理案例</span>
          <ElTag type="warning" effect="plain">示例案例</ElTag>
        </div>
      </template>
      <ElDescriptions :column="2" border size="small">
        <ElDescriptionsItem label="案例编号">CASE-R-0001</ElDescriptionsItem>
        <ElDescriptionsItem label="设备">泵 P-101（1#机组 给水系统）</ElDescriptionsItem>
        <ElDescriptionsItem label="故障现象">驱动端轴承振动异常、温升偏高</ElDescriptionsItem>
        <ElDescriptionsItem label="处理方式">大修更换驱动端轴承 6208-2RS</ElDescriptionsItem>
      </ElDescriptions>
    </ElCard>

    <ElCard shadow="never">
      <template #header>
        <span class="kb-card-title">维修闭环流程</span>
      </template>
      <ElSteps direction="vertical" :active="4" space="64px">
        <ElStep title="工单下发" description="维修部根据巡检异常开具维修工单 WO-2026-0715" />
        <ElStep title="备件联动" description="知识库自动触发轴承 6208-2RS、机械密封等备件需求" />
        <ElStep title="现场执行" description="办理工作票，断电挂牌，按维修流程指引更换轴承" />
        <ElStep title="验收归档" description="试运行正常，验收通过，归档维修记录" />
        <ElStep title="经验沉淀" description="将维修经验沉淀至知识库，供后续维修推荐" />
      </ElSteps>
    </ElCard>

    <ElCard shadow="never">
      <template #header>
        <span class="kb-card-title">知识沉淀</span>
      </template>
      <div class="kb-rcase-tags">
        <ElTag v-for="k in knowledge" :key="k" effect="plain" size="large">{{ k }}</ElTag>
      </div>
    </ElCard>
  </div>
</template>

<script setup lang="ts">
defineOptions({ name: "KbRepairCase" });

const knowledge = [
  "轴承 6208-2RS 更换周期建议 8000 运行小时",
  "泵 P-101 轴承温升异常多为润滑不足导致",
  "安装新轴承前需检查轴承座内孔公差",
  "更换机械密封时需同步更换密封垫 DN50 PN16",
];
</script>

<style scoped>
.kb-rcase {
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
.kb-rcase-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}
</style>
