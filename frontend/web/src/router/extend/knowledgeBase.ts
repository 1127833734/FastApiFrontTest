/**
 * 核电备件知识库原型 → 前端菜单扩展
 *
 * 完整复刻原型（http://43.155.147.178:8081/prototypes/knowledge-base/）的
 * 一级菜单与子菜单结构，作为 `builtinFrontendRoutes` 扩展点注入：
 *   MenuProcessor.ts → import { knowledgeBaseRoutes } from "./extend/knowledgeBase"
 *
 * 约定：
 * - 一级目录节点不写 component（由 RouteTransformer 以 NestedRouterParent 占位）
 * - 叶子节点 component 为相对 `src/views` 的路径（ComponentLoader 自动匹配 index.vue）
 * - 一级 path 首段全局唯一，避免与壳层（home/dashboard/fastlink）及彼此冲突
 */
import type { AppRouteRecord } from "@/types/router";

/** 备件知识库全部菜单（7 个一级菜单） */
export const knowledgeBaseRoutes: AppRouteRecord[] = [
  // ── 工作台 ──
  {
    path: "/kb-dashboard",
    name: "KbDashboard",
    component: "knowledge_base/dashboard/index",
    meta: { title: "工作台", icon: "ri:dashboard-line", keepAlive: true, alwaysShow: true },
  },
  // ── AI 备件助手 ──
  {
    path: "/kb-assistant",
    name: "KbAssistant",
    component: "knowledge_base/assistant/index",
    meta: { title: "AI 备件助手", icon: "ri:robot-line", keepAlive: false, alwaysShow: true },
  },
  // ── 知识库 ──
  {
    path: "/kb-knowledge",
    name: "KbKnowledge",
    meta: { title: "知识库", icon: "ri:book-2-line", alwaysShow: true },
    children: [
      {
        path: "/kb-knowledge/documents",
        name: "KbDocuments",
        component: "knowledge_base/knowledge/documents/index",
        meta: { title: "文档列表", icon: "ri:file-list-3-line", keepAlive: true },
      },
      {
        path: "/kb-knowledge/upload",
        name: "KbUpload",
        component: "knowledge_base/knowledge/upload/index",
        meta: { title: "上传文档", icon: "ri:upload-2-line", keepAlive: false },
      },
      {
        path: "/kb-knowledge/review",
        name: "KbReview",
        component: "knowledge_base/knowledge/review/index",
        meta: { title: "复核任务", icon: "ri:file-search-line", keepAlive: true },
      },
      {
        path: "/kb-knowledge/viewer",
        name: "KbViewer",
        component: "knowledge_base/knowledge/viewer/index",
        meta: { title: "文档查看器", icon: "ri:eye-line", keepAlive: false },
      },
    ],
  },
  // ── 零件库 ──
  {
    path: "/kb-parts",
    name: "KbParts",
    meta: { title: "零件库", icon: "ri:box-3-line", alwaysShow: true },
    children: [
      {
        path: "/kb-parts/list",
        name: "KbPartList",
        component: "knowledge_base/parts/list/index",
        meta: { title: "零件列表", icon: "ri:list-unordered", keepAlive: true },
      },
      {
        path: "/kb-parts/spares",
        name: "KbSpares",
        component: "knowledge_base/parts/spares/index",
        meta: { title: "数据维护配置", icon: "ri:settings-4-line", keepAlive: true },
      },
    ],
  },
  // ── 业务场景 ──
  {
    path: "/kb-business",
    name: "KbBusiness",
    meta: { title: "业务场景", icon: "ri:briefcase-4-line", alwaysShow: true },
    children: [
      {
        path: "/kb-business/spare-query",
        name: "KbSpareQuery",
        component: "knowledge_base/business/spare-query/index",
        meta: { title: "备件精准查询", icon: "ri:search-line", keepAlive: true },
      },
      {
        path: "/kb-business/compliance",
        name: "KbCompliance",
        component: "knowledge_base/business/compliance/index",
        meta: { title: "备件合规比对", icon: "ri:scales-3-line", keepAlive: true },
      },
      {
        path: "/kb-business/procurement",
        name: "KbProcurement",
        component: "knowledge_base/business/procurement/index",
        meta: { title: "采购辅助生成", icon: "ri:shopping-cart-2-line", keepAlive: true },
      },
      {
        path: "/kb-business/ledger",
        name: "KbLedger",
        component: "knowledge_base/business/ledger/index",
        meta: { title: "备件台账导出", icon: "ri:file-excel-2-line", keepAlive: true },
      },
      {
        path: "/kb-business/repair-guide",
        name: "KbRepairGuide",
        component: "knowledge_base/business/repair-guide/index",
        meta: { title: "维修流程指引", icon: "ri:tools-line", keepAlive: true },
      },
      {
        path: "/kb-business/maintenance-resources",
        name: "KbMaintenanceResources",
        component: "knowledge_base/business/maintenance-resources/index",
        meta: { title: "维修资源清单", icon: "ri:list-check-2", keepAlive: true },
      },
      {
        path: "/kb-business/maintenance-case",
        name: "KbMaintenanceCase",
        component: "knowledge_base/business/maintenance-case/index",
        meta: { title: "维修手册复核案例", icon: "ri:file-copy-2-line", keepAlive: true },
      },
      {
        path: "/kb-business/spare-case",
        name: "KbSpareCase",
        component: "knowledge_base/business/spare-case/index",
        meta: { title: "备件管理案例", icon: "ri:file-copy-line", keepAlive: true },
      },
      {
        path: "/kb-business/repair-case",
        name: "KbRepairCase",
        component: "knowledge_base/business/repair-case/index",
        meta: { title: "维修管理案例", icon: "ri:file-settings-line", keepAlive: true },
      },
    ],
  },
  // ── 系统管理 ──
  {
    path: "/kb-admin",
    name: "KbAdmin",
    meta: { title: "系统管理", icon: "ri:settings-3-line", alwaysShow: true },
    children: [
      {
        path: "/kb-admin/config",
        name: "KbSystemConfig",
        component: "knowledge_base/admin/config/index",
        meta: { title: "系统参数", icon: "ri:settings-4-line", keepAlive: true },
      },
    ],
  },
  // ── 运维监控 ──
  {
    path: "/kb-ops",
    name: "KbOps",
    meta: { title: "运维监控", icon: "ri:monitor-line", alwaysShow: true },
    children: [
      {
        path: "/kb-ops/tasks",
        name: "KbTaskMonitor",
        component: "knowledge_base/ops/tasks/index",
        meta: { title: "任务监控", icon: "ri:bar-chart-grouped-line", keepAlive: true },
      },
    ],
  },
];
