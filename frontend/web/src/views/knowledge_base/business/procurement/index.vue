<!--
  备件知识库 · 业务场景 / 采购辅助生成
  结构：页面标题 + 居中生成表单 +（生成后）采购申请单草稿 + AI 推荐说明 + 操作栏
-->
<template>
  <div class="kb-pa page-container">
    <!-- 页面标题（靠左） -->
    <el-text class="page-title">采购辅助生成</el-text>

    <!-- 居中表单生成组件 -->
    <div class="search-box-wrapper">
      <ElForm inline class="centered-generate-form">
        <ElFormItem label="零件编号">
          <ElInput v-model="form.partCode" placeholder="如 P101-001" clearable style="width: 160px" />
        </ElFormItem>
        <ElFormItem label="需求数量">
          <ElInputNumber v-model="form.quantity" :min="1" :max="999" style="width: 120px" />
        </ElFormItem>
        <ElFormItem label="采购类型">
          <ElSelect v-model="form.purchaseType" style="width: 140px">
            <ElOption v-for="t in purchaseTypes" :key="t" :label="t" :value="t" />
          </ElSelect>
        </ElFormItem>
        <ElFormItem>
          <ElButton type="success" :icon="MagicStick" @click="handleGenerate">生成采购单</ElButton>
        </ElFormItem>
      </ElForm>
    </div>

    <!-- 生成成功后显示 -->
    <template v-if="generated">
      <!-- 采购申请单草稿 -->
      <ElCard shadow="never" class="draft-card">
        <template #header>
          <div class="card-header">
            <el-space>
              <ElIcon><Document /></ElIcon>
              <span class="draft-title">采购申请单草稿</span>
            </el-space>
            <ElText type="info" size="small">AI 辅助生成，请核对后提交</ElText>
          </div>
        </template>

        <!-- 申请基础元信息 -->
        <ElDescriptions :column="3" border>
          <ElDescriptionsItem label="申请部门">{{ draft.dept }}</ElDescriptionsItem>
          <ElDescriptionsItem label="申请人">{{ draft.applicant }}</ElDescriptionsItem>
          <ElDescriptionsItem label="申请日期">{{ draft.date }}</ElDescriptionsItem>
        </ElDescriptions>

        <!-- 明细表格 -->
        <ElTable :data="draftItems" stripe style="margin-top: 16px">
          <ElTableColumn prop="seq" label="序号" width="70" align="center" />
          <ElTableColumn prop="partCode" label="零件编号" width="120" />
          <ElTableColumn prop="partName" label="零件名称" width="100" />
          <ElTableColumn prop="spec" label="型号规格" min-width="130" show-overflow-tooltip />
          <ElTableColumn prop="supplier" label="推荐供应商" width="120" />
          <ElTableColumn prop="leadTime" label="采购周期" width="110" align="center" />
          <ElTableColumn prop="quantity" label="数量" width="90" align="center" />
          <ElTableColumn prop="unit" label="单位" width="80" align="center" />
        </ElTable>
      </ElCard>

      <!-- AI 推荐说明 -->
      <ElAlert type="success" :closable="false" class="ai-alert">
        <template #title>AI 推荐说明</template>
        <ul class="ai-alert-list">
          <li>根据历史采购记录，SKF 为该型号主流供应商，质量评级 A。</li>
          <li>建议采购数量 2 件，可满足 1#机组泵 P-101 下次大修需求。</li>
          <li>该备件采购周期约 30 天，请提前 45 天发起流程。</li>
        </ul>
      </ElAlert>

      <!-- 底部操作栏 -->
      <div class="bottom-action-bar">
        <ElButton :icon="CopyDocument" @click="handleCopy">复制内容</ElButton>
        <ElButton :icon="Download" @click="handleExportWord">导出 Word</ElButton>
        <ElButton type="success" @click="handleSubmit">提交审批</ElButton>
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import { MagicStick, Document, CopyDocument, Download } from "@element-plus/icons-vue";

defineOptions({ name: "KbProcurement" });

const purchaseTypes = ["常规采购", "紧急采购", "框架合同"];

const form = ref({
  partCode: "",
  quantity: 2,
  purchaseType: "常规采购",
});

const generated = ref(false);

const draft = {
  dept: "维修部",
  applicant: "张三",
  date: "2026-08-04",
};

interface DraftItem {
  seq: number;
  partCode: string;
  partName: string;
  spec: string;
  supplier: string;
  leadTime: string;
  quantity: number;
  unit: string;
}

const draftItems: DraftItem[] = [
  {
    seq: 1,
    partCode: "P101-001",
    partName: "轴承",
    spec: "6208-2RS",
    supplier: "SKF",
    leadTime: "30 天",
    quantity: 2,
    unit: "件",
  },
];

function handleGenerate() {
  if (!form.value.partCode.trim()) {
    ElMessage.warning("请输入零件编号");
    return;
  }
  generated.value = true;
}

function handleCopy() {
  ElMessage.success("内容已复制（原型演示）");
}

function handleExportWord() {
  ElMessage.success("Word 文档已导出（原型演示）");
}

function handleSubmit() {
  ElMessage.success("采购申请已提交审批（原型演示）");
}
</script>

<style scoped>
.kb-pa {
  display: flex;
  flex-direction: column;
  gap: 16px;
}
.page-title {
  font-size: 18px;
  font-weight: 600;
  color: #111827;
  display: block;
  width: 100%;
  text-align: left;
}
/* 居中生成表单 */
.search-box-wrapper {
  display: flex;
  justify-content: center;
  padding: 24px 0;
}
.centered-generate-form {
  display: flex;
  align-items: center;
  padding: 20px 28px;
  background: #fff;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
}
/* 草稿卡 */
.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.draft-title {
  font-size: 15px;
  font-weight: 600;
  color: #111827;
}
/* AI 推荐说明 */
.ai-alert {
  width: 100%;
}
.ai-alert-list {
  margin: 8px 0 0;
  padding-left: 18px;
  line-height: 1.9;
}
/* 底部操作栏 */
.bottom-action-bar {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
}
</style>
