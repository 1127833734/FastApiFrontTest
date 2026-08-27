/** 复核候选的零件属性 */
export interface PartAttributes {
  partNo: string;
  name: string;
  spec: string;
  material: string;
  unit: string;
  system: string;
  device: string;
  installLocation: string;
  category: string;
  level: string;
  importance: string;
  radiationRisk: string;
}

/** 单个复核候选（标注点） */
export interface ReviewCandidate {
  id: string;
  pageNo: number;
  label: string;
  status: "pending" | "confirmed" | "rejected" | "skipped";
  bbox: { x: number; y: number };
  isPart: boolean;
  candidateType?: "零件" | "备件" | "安全提示" | "操作步骤";
  isIncomplete?: boolean;
  partAttributes: PartAttributes;
}

/** 复核任务（一个文档一条任务） */
export interface ReviewTask {
  id: string;
  documentId: string;
  documentName: string;
  documentNo: string;
  fileType: string;
  totalPages: number;
  currentPage: number;
  candidates: ReviewCandidate[];
}
