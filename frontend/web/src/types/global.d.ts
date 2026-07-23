declare global {
  /**
   * 系统设置
   */
  interface AppSettings {
    /** 系统名称 */
    name: string;
    /** 系统标题 */
    title: string;
    /** 系统版本 */
    version: string;
    /** 是否显示设置按钮 */
    showSettings: boolean;
    /** 是否显示菜单搜索 */
    showMenuSearch: boolean;
    /** 是否显示全屏切换 */
    showFullscreen: boolean;
    /** 是否显示布局大小 */
    showSizeSelect: boolean;
    /** 是否显示语言选择 */
    showLangSelect: boolean;
    /** 是否显示通知 */
    showNotification: boolean;
    /** 是否显示多标签导航 */
    showTagsView: boolean;
    /** 是否显示应用Logo */
    showAppLogo: boolean;
    /** 导航栏布局(left|top|mix) */
    layout: "left" | "top" | "mix";
    /** 主题颜色 */
    themeColor: string;
    /** 主题模式(dark|light) */
    theme: import("@/enums/settings/theme.enum").ThemeMode;
    /** 布局大小(default |large |small) */
    size: string;
    /** 语言( zh-cn| en) */
    language: string;
    /** 是否显示水印 */
    showWatermark: boolean;
    /** 水印内容 */
    watermarkContent: string;
    /** 侧边栏配色方案 */
    sidebarColorScheme: "classic-blue" | "minimal-white";
    /** 项目引导 */
    guideVisible: boolean;
    /** 是否启动引导 */
    showGuide: boolean;
    /** 是否开启AI助手 */
    aiEnabled: boolean;
    /** 是否开启灰色模式 */
    grayMode: boolean;
    /** 页面切换动画 */
    pageSwitchingAnimation: string;
  }

  /**
   * 下拉选项数据类型
   */
  interface OptionType {
    /** 值 */
    value: string | number;
    /** 文本 */
    label: string;
    /** 子列表  */
    children?: OptionType[];
  }

  /**
   * 导入结果
   */
  interface ExcelResult {
    /** 状态码 */
    code: string;
    /** 无效数据条数 */
    invalidCount: number;
    /** 有效数据条数 */
    validCount: number;
    /** 错误信息 */
    messageList: Array<string>;
  }

  /**
   * 基础响应结构
   */
  interface ApiResponse<T = any> {
    code: number;
    data: T;
    msg: string;
    status_code: number;
    success: boolean;
  }

  /**
   * web 目前以真实接口模块导出的类型为准，这里先提供最小声明避免 vue-tsc 阻断。
   */
  namespace Api {
    namespace Auth {
      interface UserInfo {
        [key: string]: unknown;
      }
    }
  }

  /**
   * 基础查询参数（基础层：状态 + 时间范围）
   */
  interface BaseQueryParams {
    created_time?: string[];
    updated_time?: string[];
  }

  /**
   * 审计人查询参数（继承基础查询 + 创建人/更新人）
   */
  interface UserByQueryParams extends BaseQueryParams {
    created_id?: number;
    updated_id?: number;
  }

  /**
   * 分页查询参数（继承基础查询 + 分页字段）
   */
  interface PageQuery extends BaseQueryParams {
    page_no: number;
    page_size: number;
  }

  /**
   * 分页响应对象（列表接口 `data` 统一为该结构）
   */
  interface PageResult<T = any> {
    items: T[];
    total: number;
    page_no: number;
    page_size: number;
    has_next: boolean;
  }

  /**
   * 创建人/更新人/删除人
   */
  interface CommonType {
    id?: number;
    name?: string;
  }

  /**
   * 基础表单类型（基础层：仅包含 id）
   */
  interface BaseFormType {
    id?: number;
  }

  /**
   * 基础类型（基础层：包含通用字段）
   */
  interface BaseType extends BaseFormType {
    index?: number;
    uuid?: string;
    is_deleted?: boolean;
    created_time?: string;
    updated_time?: string;
    deleted_time?: string;
    created_by?: CommonType;
    updated_by?: CommonType;
    deleted_by?: CommonType;
  }

  /**
   * 批量操作类型
   */
  interface BatchType {
    ids: number[];
    status: number;
  }

  /**
   * 上传文件路径
   */
  interface UploadFilePath {
    file_path: string;
    file_name: string;
    origin_name: string;
    file_url: string;
  }

  /**
   * 通用搜索参数
   */
  type CommonSearchParams = Pick<PageQuery, "page_no" | "page_size">;

  /**
   * 启用状态
   */
  type EnableStatus = "0" | "1";

  // ====== 通用类型（原 common/index.ts） ======

  /** 状态类型（0: 禁用, 1: 启用） */
  type Status = 0 | 1;
  /** 性别类型 */
  type Gender = "male" | "female" | "unknown";
  /** 排序方向 */
  type SortOrder = "ascending" | "descending";
  /** 操作类型 */
  type ActionType =
    | "create"
    | "update"
    | "delete"
    | "view"
    | "export"
    | "import"
    | "patch"
    | "download";
  /** 可选的记录类型 */
  type Recordable<T = any> = Record<string, T>;
  /** 键值对类型 */
  interface KeyValue<T = any> {
    key: string;
    value: T;
    label?: string;
  }
  /** 时间范围类型 */
  interface TimeRange {
    startTime: string;
    endTime: string;
  }
  /** 文件类型 */
  interface FileInfo {
    name: string;
    url: string;
    size: number;
    type: string;
    lastModified?: number;
  }
  /** 坐标类型 */
  interface Position {
    x: number;
    y: number;
  }
  /** 尺寸类型 */
  interface Size {
    width: number;
    height: number;
  }
  /** 响应式断点类型 */
  type Breakpoint = "xs" | "sm" | "md" | "lg" | "xl";
  /** 主题模式（轻量字面量类型，区别于 enums 中的 ThemeMode const enum） */
  type ThemeMode = "light" | "dark" | "auto";
  /** 语言类型 */
  type Language = "zh-CN" | "en-US";
  /** 环境类型 */
  type Environment = "dev" | "prod" | "test";
  /** 弹窗类型 */
  type DialogType = "add" | "edit";

  /**
   * 登录参数
   */
  interface LoginParams {
    username: string;
    password: string;
    captcha_key?: string;
    captcha?: string;
    remember?: boolean;
    login_type?: string;
  }

  /**
   * 登录响应
   */
  interface LoginResponse {
    access_token: string;
    refresh_token: string;
    token_type: string;
    expires_in: number;
  }

  /**
   * 用户信息
   */
  interface UserInfo {
    user_id: number;
    username: string;
    nickname?: string;
    email?: string;
    avatar?: string;
    phone?: string;
    roles?: RoleInfo[];
    permissions?: string[];
    menus?: MenuTable[];
    created_at?: string;
    updated_at?: string;
  }

  /**
   * 角色信息
   */
  interface RoleInfo {
    id?: number;
    name?: string;
    code?: string;
    menus?: any[];
  }

  /**
   * 用户列表
   */
  type UserList = PageResult<UserListItem>;

  /**
   * 用户列表项
   */
  interface UserListItem {
    id: number;
    avatar: string;
    status: number;
    userName: string;
    userGender: string;
    nickName: string;
    userPhone: string;
    userEmail: string;
    userRoles: string[];
    createBy: string;
    createTime: string;
    updateBy: string;
    updateTime: string;
  }

  /**
   * 用户搜索参数
   */
  type UserSearchParams = Partial<
    Pick<UserListItem, "id" | "userName" | "userGender" | "userPhone" | "userEmail" | "status"> &
      CommonSearchParams
  >;

  /**
   * 角色列表
   */
  type RoleList = PageResult<RoleListItem>;

  /**
   * 角色列表项
   */
  interface RoleListItem {
    roleId: number;
    roleName: string;
    roleCode: string;
    description: string;
    enabled: boolean;
    createTime: string;
  }

  /**
   * 角色搜索参数
   */
  type RoleSearchParams = Partial<
    Pick<RoleListItem, "roleId" | "roleName" | "roleCode" | "description" | "enabled"> &
      CommonSearchParams & {
        startTime: string | null;
        endTime: string | null;
      }
  >;
}

export {};
