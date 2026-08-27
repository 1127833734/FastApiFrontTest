<!--
  备件知识库 · 知识库 / 文档列表
  复刻原型 documents 页：筛选区 / 文档表格 / 分页
-->
<template>
  <div class="kb-documents">
    <ElCard shadow="never" class="kb-filter">
      <ElForm inline>
        <ElFormItem label="关键词">
          <ElInput v-model="query.keyword" placeholder="文档名称" clearable style="width: 220px" />
        </ElFormItem>
        <ElFormItem label="类型">
          <ElSelect v-model="query.fileType" placeholder="全部类型" clearable style="width: 130px">
            <ElOption v-for="t in fileTypes" :key="t" :label="t" :value="t" />
          </ElSelect>
        </ElFormItem>
        <ElFormItem label="状态">
          <ElSelect v-model="query.status" placeholder="全部状态" clearable style="width: 130px">
            <ElOption v-for="s in statusOptions" :key="s.value" :label="s.label" :value="s.value" />
          </ElSelect>
        </ElFormItem>
        <ElFormItem label="机组">
          <ElSelect v-model="query.unit" placeholder="全部机组" clearable style="width: 130px">
            <ElOption label="1#机组" value="1#机组" />
            <ElOption label="2#机组" value="2#机组" />
          </ElSelect>
        </ElFormItem>
        <ElFormItem>
          <ElButton type="primary" :icon="Search" @click="search">查询</ElButton>
          <ElButton :icon="RefreshLeft" @click="reset">重置</ElButton>
        </ElFormItem>
      </ElForm>
    </ElCard>

    <ElCard shadow="never">
      <template #header>
        <div class="kb-card-header">
          <span class="kb-card-title">文档列表</span>
          <ElButton type="primary" :icon="Upload" @click="goUpload">上传文档</ElButton>
        </div>
      </template>
      <ElTable :data="filteredDocs" stripe>
        <ElTableColumn type="index" label="序号" width="60" />
        <ElTableColumn prop="filename" label="文档名" min-width="240" show-overflow-tooltip />
        <ElTableColumn prop="fileType" label="类型" width="90" />
        <ElTableColumn prop="pageCount" label="页数" width="80" align="center" />
        <ElTableColumn prop="unit" label="机组" width="90" />
        <ElTableColumn label="状态" width="100">
          <template #default="{ row }">
            <ElTag :type="statusColor[row.status]">{{ statusText[row.status] }}</ElTag>
          </template>
        </ElTableColumn>
        <ElTableColumn prop="uploader" label="上传人" width="110" />
        <ElTableColumn prop="createdAt" label="上传时间" width="170" />
      </ElTable>
      <div class="kb-pagination">
        <ElPagination
          v-model:current-page="page"
          :page-size="pageSize"
          :total="filteredDocs.length"
          layout="total, prev, pager, next"
        />
      </div>
    </ElCard>
  </div>
</template>

<script setup lang="ts">
import { Search, RefreshLeft, Upload } from "@element-plus/icons-vue";
import { useRouter } from "vue-router";

defineOptions({ name: "KbDocuments" });

const router = useRouter();
const page = ref(1);
const pageSize = 10;

const fileTypes = ["PDF", "DOCX", "XLSX", "DWG"];
const statusOptions = [
  { label: "已解析", value: "parsed" },
  { label: "待处理", value: "pending" },
  { label: "解析中", value: "parsing" },
  { label: "解析失败", value: "failed" },
];
const statusText: Record<string, string> = {
  parsed: "已解析",
  pending: "待处理",
  parsing: "解析中",
  failed: "解析失败",
};
const statusColor: Record<string, "success" | "warning" | "primary" | "danger"> = {
  parsed: "success",
  pending: "warning",
  parsing: "primary",
  failed: "danger",
};

const query = ref({ keyword: "", fileType: "", status: "", unit: "" });

const allDocs = [
  { id: 1, filename: "泵 P-101 维修手册 V2.1.pdf", fileType: "PDF", pageCount: 128, unit: "1#机组", status: "parsed", uploader: "技术部 · 王工", createdAt: "2026-08-03 09:12" },
  { id: 2, filename: "主汽阀 MV-201 总装图.dwg", fileType: "DWG", pageCount: 24, unit: "2#机组", status: "parsed", uploader: "技术部 · 李工", createdAt: "2026-08-03 08:45" },
  { id: 3, filename: "密封垫 DN50 采购技术协议.docx", fileType: "DOCX", pageCount: 8, unit: "1#机组", status: "pending", uploader: "采购部 · 赵工", createdAt: "2026-08-02 16:20" },
  { id: 4, filename: "大修备件清单-2026 秋.xlsx", fileType: "XLSX", pageCount: 45, unit: "全部", status: "parsed", uploader: "备件部 · 刘工", createdAt: "2026-08-02 14:03" },
  { id: 5, filename: "轴承 6208-2RS 质量证明书.pdf", fileType: "PDF", pageCount: 6, unit: "1#机组", status: "failed", uploader: "备件部 · 刘工", createdAt: "2026-08-01 11:30" },
  { id: 6, filename: "电机 M-105 碳刷更换工艺.pdf", fileType: "PDF", pageCount: 32, unit: "1#机组", status: "parsed", uploader: "维修部 · 陈工", createdAt: "2026-07-30 10:05" },
  { id: 7, filename: "给水系统 PID 图.dwg", fileType: "DWG", pageCount: 18, unit: "2#机组", status: "parsing", uploader: "技术部 · 李工", createdAt: "2026-07-29 15:40" },
  { id: 8, filename: "辐射防护管理要求.docx", fileType: "DOCX", pageCount: 20, unit: "全部", status: "parsed", uploader: "安全部 · 周工", createdAt: "2026-07-28 09:00" },
];

const filteredDocs = computed(() => {
  return allDocs.filter((d) => {
    if (query.value.keyword && !d.filename.includes(query.value.keyword)) return false;
    if (query.value.fileType && d.fileType !== query.value.fileType) return false;
    if (query.value.status && d.status !== query.value.status) return false;
    if (query.value.unit && d.unit !== query.value.unit && d.unit !== "全部") return false;
    return true;
  });
});

function search() {
  page.value = 1;
}
function reset() {
  query.value = { keyword: "", fileType: "", status: "", unit: "" };
  page.value = 1;
}
function goUpload() {
  router.push("/kb-knowledge/upload");
}
</script>

<style scoped>
.kb-documents {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.kb-filter {
  padding: 16px;
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
.kb-pagination {
  margin-top: 14px;
  display: flex;
  justify-content: flex-end;
}
</style>
