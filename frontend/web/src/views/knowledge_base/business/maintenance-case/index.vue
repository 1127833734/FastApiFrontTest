<!--
  备件知识库 · 业务场景 / 维修手册复核案例
  复刻原型 maintenance-case 页：手册复核流程 + 候选判定 + 版本对比
-->
<template>
  <div class="kb-mcase">
    <ElCard shadow="never">
      <template #header>
        <div class="kb-card-header">
          <span class="kb-card-title">维修手册复核案例</span>
          <ElTag type="warning" effect="plain">示例案例</ElTag>
        </div>
      </template>
      <ElDescriptions :column="2" border size="small">
        <ElDescriptionsItem label="案例编号">CASE-M-0001</ElDescriptionsItem>
        <ElDescriptionsItem label="来源文档">泵 P-101 维修手册 V2.1</ElDescriptionsItem>
        <ElDescriptionsItem label="涉及页数">第 15-19 页</ElDescriptionsItem>
        <ElDescriptionsItem label="复核状态">待复审</ElDescriptionsItem>
      </ElDescriptions>
      <div class="kb-mcase-desc">
        <p>
          本案例演示维修手册接入知识库后的复核链路：<b>OCR 识别</b> → <b>零件/非零件判定</b> → <b>零件属性补充</b> →
          <b>冲突检测</b> → <b>入库发布</b>。手册中描述的轴承、密封垫等物料可被后续维修场景直接引用。
        </p>
      </div>
    </ElCard>

    <ElCard shadow="never">
      <template #header>
        <span class="kb-card-title">复核候选列表</span>
      </template>
      <ElTable :data="candidates" stripe>
        <ElTableColumn type="index" label="序号" width="60" />
        <ElTableColumn prop="pageNo" label="页码" width="80" align="center" />
        <ElTableColumn prop="type" label="复核类型" width="160">
          <template #default="{ row }">
            <ElTag size="small" effect="plain">{{ row.type }}</ElTag>
          </template>
        </ElTableColumn>
        <ElTableColumn prop="content" label="识别内容" min-width="280" show-overflow-tooltip />
        <ElTableColumn label="结果" width="100">
          <template #default="{ row }">
            <ElTag :type="row.status === '通过' ? 'success' : row.status === '驳回' ? 'danger' : 'warning'" size="small">
              {{ row.status }}
            </ElTag>
          </template>
        </ElTableColumn>
      </ElTable>
    </ElCard>

    <ElCard shadow="never">
      <template #header>
        <span class="kb-card-title">版本差异对比</span>
      </template>
      <ElTable :data="versionDiff" stripe>
        <ElTableColumn prop="field" label="对比项" width="140" />
        <ElTableColumn prop="old" label="V2.0（旧）" min-width="200" show-overflow-tooltip />
        <ElTableColumn prop="new" label="V2.1（新）" min-width="200" show-overflow-tooltip />
        <ElTableColumn label="变更类型" width="100">
          <template #default="{ row }">
            <ElTag :type="row.change === '新增' ? 'success' : row.change === '删除' ? 'danger' : 'warning'" size="small">
              {{ row.change }}
            </ElTag>
          </template>
        </ElTableColumn>
      </ElTable>
    </ElCard>
  </div>
</template>

<script setup lang="ts">
defineOptions({ name: "KbMaintenanceCase" });

const candidates = [
  { pageNo: 15, type: "零件识别", content: "驱动端轴承型号为 6208-2RS，非驱动端为 6207-2RS", status: "通过" },
  { pageNo: 16, type: "非零件判定", content: "拆卸泵联轴器护罩，拆除旧轴承（操作步骤，非零件）", status: "通过" },
  { pageNo: 17, type: "零件属性补充", content: "安装新轴承 6208-2RS，材质 GCr15，安装位置：泵驱动端", status: "待复核" },
  { pageNo: 19, type: "安全提示", content: "必须确认设备已断电并挂牌（安全要求，非零件）", status: "驳回" },
];

const versionDiff = [
  { field: "轴承型号", old: "6208", new: "6208-2RS（补充密封圈标识）", change: "修改" },
  { field: "检查周期", old: "10000 小时", new: "8000 运行小时", change: "修改" },
  { field: "安全要求", old: "无", new: "断电挂牌 + 办理工作票", change: "新增" },
  { field: "润滑脂型号", old: "3# 锂基脂", new: "（已删除，引用专项文件）", change: "删除" },
];
</script>

<style scoped>
.kb-mcase {
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
.kb-mcase-desc {
  margin-top: 14px;
  font-size: 14px;
  line-height: 1.9;
  color: #374151;
  background: #f9fafb;
  border-radius: 6px;
  padding: 12px 16px;
}
</style>
