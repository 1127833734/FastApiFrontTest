// ====== 外部依赖导入 ======
import { RouteRecordRaw, LocationQueryRaw } from "vue-router";
import "vue-router";
import { SystemThemeEnum, MenuThemeEnum, MenuTypeEnum } from "@/enums/appEnum";
import type { EChartsOption } from "@/plugins/echarts";
import type {
  AuthDirective,
  RolesDirective,
  RippleDirective,
  HighlightDirective,
} from "@/directives";

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

  // ==================== types/common/index.ts ====================

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
  /** 主题类型 */
  type ThemeMode = "light" | "dark" | "auto";
  /** 语言类型 */
  type Language = "zh-CN" | "en-US";
  /** 环境类型 */
  type Environment = "dev" | "prod" | "test";
  /** 弹窗类型 */
  type DialogType = "add" | "edit";

  // ==================== types/component/index.ts ====================

  /** 搜索组件类型 */
  type SearchComponentType =
    | "input"
    | "select"
    | "radio"
    | "checkbox"
    | "date"
    | "datetime"
    | "daterange"
    | "datetimerange"
    | "month"
    | "monthrange"
    | "year"
    | "yearrange"
    | "week"
    | "time"
    | "timerange";

  /** 搜索框值变化参数 */
  interface SearchChangeParams {
    prop: string;
    val: unknown;
  }

  /** 状态列配置（自动渲染 StatusTag） */
  interface StatusColumnItem {
    type: "primary" | "success" | "warning" | "danger" | "info";
    text: string;
    size?: "large" | "default" | "small";
    effect?: "light" | "dark" | "plain";
  }

  /** 部分映射：只需列出需要配置的值对应的状态项 */
  type StatusColumnConfig = Partial<Record<string, StatusColumnItem>>;

  /** 表格列配置接口 */
  interface ColumnOption<T = any> {
    type?: "selection" | "expand" | "index" | "globalIndex";
    prop?: string;
    label?: string;
    width?: string | number;
    minWidth?: string | number;
    fixed?: boolean | "left" | "right";
    sortable?: boolean | "custom";
    filters?: any[];
    filterMethod?: (value: any, row: any) => boolean;
    filterPlacement?: string;
    disabled?: boolean;
    visible?: boolean;
    checked?: boolean;
    formatter?: (row: T) => any;
    status?: StatusColumnConfig;
    useSlot?: boolean;
    slotName?: string;
    useHeaderSlot?: boolean;
    headerSlotName?: string;
    [key: string]: any;
  }

  /** 分页配置 */
  interface PaginationConfig {
    currentPage: number;
    pageSize: number;
    total: number;
    pageSizes?: number[];
    layout?: string;
    small?: boolean;
  }

  /** 表单规则 */
  interface FormRule {
    required?: boolean;
    message?: string;
    trigger?: string | string[];
    min?: number;
    max?: number;
    pattern?: RegExp;
    validator?: (rule: any, value: any, callback: any) => void;
  }

  /** 对话框配置 */
  interface DialogConfig {
    title: string;
    visible: boolean;
    width?: string | number;
    closeOnClickModal?: boolean;
    closeOnPressEscape?: boolean;
    showClose?: boolean;
    lockScroll?: boolean;
    modal?: boolean;
    customClass?: string;
  }

  // ==================== types/component/chart.ts ====================

  /** 图例位置类型 */
  type LegendPosition = "bottom" | "top" | "left" | "right";

  type SymbolType =
    | "circle"
    | "rect"
    | "roundRect"
    | "triangle"
    | "diamond"
    | "pin"
    | "arrow"
    | "none";

  /** 图表主题配置 */
  interface ChartThemeConfig {
    chartHeight: string;
    fontSize: number;
    fontColor: string;
    themeColor: string;
    colors: string[];
  }

  /** 图表初始化选项 */
  interface UseChartOptions {
    initOptions?: EChartsOption;
    initDelay?: number;
    threshold?: number;
    autoTheme?: boolean;
  }

  /** 基础图表 Props 接口 */
  interface BaseChartProps {
    title?: string;
    height?: string;
    loading?: boolean;
    isEmpty?: boolean;
    colors?: string[];
  }

  /** 轴线显示控制接口 */
  interface AxisDisplayProps {
    showAxisLabel?: boolean;
    showAxisLine?: boolean;
    showSplitLine?: boolean;
  }

  /** 交互显示控制接口 */
  interface InteractionProps {
    showTooltip?: boolean;
    showLegend?: boolean;
    legendPosition?: LegendPosition;
  }

  /** 柱状图数据项接口 */
  interface BarDataItem {
    name: string;
    data: number[];
    barWidth?: string | number;
    stack?: string;
  }

  /** 柱状图 Props 接口 */
  interface BarChartProps extends BaseChartProps, AxisDisplayProps, InteractionProps {
    data: number[] | BarDataItem[];
    xAxisData?: string[];
    barWidth?: string | number;
    stack?: boolean;
    borderRadius?: number | number[];
  }

  /** 折线图数据项接口 */
  interface LineDataItem {
    name: string;
    data: number[];
    lineWidth?: number;
    showAreaColor?: boolean;
    areaStyle?: {
      startOpacity?: number;
      endOpacity?: number;
      custom?: any;
    };
    smooth?: boolean;
    symbol?: SymbolType;
    symbolSize?: number;
  }

  /** 折线图 Props 接口 */
  interface LineChartProps extends BaseChartProps, AxisDisplayProps, InteractionProps {
    data: number[] | LineDataItem[];
    xAxisData?: string[];
    lineWidth?: number;
    showAreaColor?: boolean;
    smooth?: boolean;
    symbol?: SymbolType;
    symbolSize?: number;
    animationDelay?: number;
  }

  /** 雷达图数据项接口 */
  interface RadarDataItem {
    name: string;
    value: number[];
  }

  /** 雷达图 Props 接口 */
  interface RadarChartProps extends BaseChartProps, InteractionProps {
    indicator?: Array<{ name: string; max: number }>;
    data?: RadarDataItem[];
  }

  /** 饼图/环形图数据项接口 */
  interface PieDataItem {
    value: number;
    name: string;
  }

  /** 环形图 Props 接口 */
  interface RingChartProps extends BaseChartProps, InteractionProps {
    data: PieDataItem[];
    radius?: string[];
    borderRadius?: number;
    centerText?: string;
    showLabel?: boolean;
  }

  /** K线图数据项接口 */
  interface KLineDataItem {
    time: string;
    open: number;
    close: number;
    high: number;
    low: number;
  }

  /** K线图 Props 接口 */
  interface KLineChartProps extends BaseChartProps {
    data?: KLineDataItem[];
    showDataZoom?: boolean;
    dataZoomStart?: number;
    dataZoomEnd?: number;
  }

  /** 散点图数据项接口 */
  interface ScatterDataItem {
    value: number[];
  }

  /** 散点图 Props 接口 */
  interface ScatterChartProps extends BaseChartProps, AxisDisplayProps, InteractionProps {
    data?: ScatterDataItem[];
    symbolSize?: number;
  }

  /** 双柱对比图 Props 接口 */
  interface DualBarCompareChartProps extends BaseChartProps {
    topData: number[];
    bottomData: number[];
    xAxisData: string[];
    topColor?: string;
    bottomColor?: string;
    barWidth?: number;
  }

  /** 地图图表 Props 接口 */
  interface MapChartProps extends BaseChartProps {
    mapData?: any[];
    selectedRegion?: string;
    showLabels?: boolean;
    showScatter?: boolean;
  }

  /** 双向堆叠柱状图 Props 接口（人口金字塔样式） */
  interface BidirectionalBarChartProps extends BaseChartProps, AxisDisplayProps, InteractionProps {
    positiveData: number[];
    negativeData: number[];
    xAxisData?: string[];
    positiveName?: string;
    negativeName?: string;
    barWidth?: string | number;
    yAxisMin?: number;
    yAxisMax?: number;
    showDataLabel?: boolean;
    positiveBorderRadius?: number | number[];
    negativeBorderRadius?: number | number[];
  }

  /** 图表配置生成器函数类型 */
  type ChartOptionGenerator = () => EChartsOption;

  /** 图表事件回调类型 */
  type ChartEventCallback = (params: any) => void;

  /** 图表错误信息接口 */
  interface ChartError {
    code: string;
    message: string;
    details?: any;
  }

  // ==================== types/ai/index.ts ====================

  /**
   * AI 操作处理器（简化版）
   * 可以是简单函数，也可以是配置对象
   */
  type AiActionHandler<T = any> =
    | ((args: T) => Promise<void> | void)
    | {
        execute: (args: T) => Promise<void> | void;
        needConfirm?: boolean;
        confirmMessage?: string | ((args: T) => string);
        successMessage?: string | ((args: T) => string);
        callBackendApi?: boolean;
      };

  /**
   * AI 操作配置
   */
  interface UseAiActionOptions {
    actionHandlers?: Record<string, AiActionHandler>;
    onRefresh?: () => Promise<void> | void;
    onAutoSearch?: (keywords: string) => void;
    currentRoute?: string;
  }

  // ==================== types/store/index.ts ====================

  /** 系统主题样式（light | dark） */
  interface SystemThemeType {
    className: string;
  }

  /** 定义包含多个主题的类型 */
  type SystemThemeTypes = Record<"dark" | "light", SystemThemeType>;

  /** 菜单主题样式 */
  interface MenuThemeType {
    theme: MenuThemeEnum;
    background: string;
    systemNameColor: string;
    textColor: string;
    iconColor: string;
    img?: string;
  }

  /** 设置中心 */
  interface SettingState {
    theme: string;
    uniqueOpened: boolean;
    menuButton: boolean;
    showRefreshButton: boolean;
    showCrumbs: boolean;
    autoClose: boolean;
    showWorkTab: boolean;
    showLanguage: boolean;
    showNprogress: boolean;
    themeModel: string;
  }

  /** 多标签 */
  interface WorkTab {
    title: string;
    customTitle?: string;
    path: string;
    name: string;
    keepAlive: boolean;
    fixedTab?: boolean;
    params?: object;
    query?: LocationQueryRaw;
    icon?: string;
    isActive?: boolean;
  }

  /** 用户Store状态 */
  interface UserState {
    userInfo: Api.Auth.UserInfo | null;
    token: string | null;
    roles: string[];
    permissions: string[];
  }

  /** 设置Store状态 */
  interface SettingStoreState extends SettingState {
    collapsed: boolean;
    device: "desktop" | "mobile";
    language: string;
  }

  /** 工作标签页Store状态 */
  interface WorkTabState {
    tabs: WorkTab[];
    activeTab: string;
    cachedTabs: string[];
  }

  /** 菜单Store状态 */
  interface MenuState {
    menuList: any[];
    isLoaded: boolean;
    collapsed: boolean;
  }

  /** 根Store状态类型 */
  interface RootState {
    user: UserState;
    setting: SettingStoreState;
    workTab: WorkTabState;
    menu: MenuState;
  }

  // ==================== types/config/index.ts ====================

  /** 主题设置 */
  interface ThemeSetting {
    name: string;
    theme: SystemThemeEnum;
    color: string[];
    leftLineColor: string;
    rightLineColor: string;
    img: string;
  }

  /** 菜单布局 */
  interface MenuLayout {
    name: string;
    value: MenuTypeEnum;
    img: string;
    description?: string;
  }

  /** 节日配置 */
  interface FestivalConfig {
    date: string;
    endDate?: string;
    name: string;
    image: string;
    scrollText: string;
    isActive?: boolean;
    count?: number;
    fireworkInterval?: number;
    skipFireworks?: boolean;
    isResidentBanner?: boolean;
  }

  /** 系统基础配置 */
  interface SystemBasicConfig {
    name: string;
    description?: string;
    logo?: string;
    favicon?: string;
    copyright?: string;
  }

  /** 快速入口基础项 */
  interface FastEnterBaseItem {
    name: string;
    enabled?: boolean;
    order?: number;
    routeName?: string;
    routeQuery?: Record<string, string>;
    link?: string;
    isDialog?: boolean;
  }

  /** 快速入口应用项 */
  interface FastEnterApplication extends FastEnterBaseItem {
    description: string;
    icon: string;
    iconColor: string;
  }

  /** 快速链接项 */
  type FastEnterQuickLink = FastEnterBaseItem;

  /** 快速入口配置 */
  interface FastEnterConfig {
    applications: FastEnterApplication[];
    quickLinks: FastEnterQuickLink[];
    minWidth?: number;
  }

  /** 系统配置 */
  interface SystemConfig {
    systemInfo: SystemBasicConfig;
    systemThemeStyles: SystemThemeTypes;
    settingThemeList: ThemeSetting[];
    menuLayoutList: MenuLayout[];
    themeList: MenuThemeType[];
    darkMenuStyles: MenuThemeType[];
    systemMainColor: readonly string[];
    fastEnter?: FastEnterConfig;
    headerBar?: HeaderBarFeatureConfig;
  }

  /** 环境配置 */
  interface EnvConfig {
    NODE_ENV: string;
    VITE_VERSION: string;
    VITE_PORT: string;
    VITE_BASE_URL: string;
    VITE_API_URL: string;
    VITE_USE_MOCK?: string;
    VITE_USE_GZIP?: string;
    VITE_USE_CDN?: string;
  }

  /** 应用配置 */
  interface AppConfig extends SystemConfig {
    env: EnvConfig;
    isDev: boolean;
    isProd: boolean;
    isTest: boolean;
  }

  /** 功能配置项基础接口 */
  interface FeatureConfigItem {
    enabled: boolean;
    description: string;
  }

  /** 顶部栏功能配置接口 */
  interface HeaderBarFeatureConfig {
    menuButton: FeatureConfigItem;
    refreshButton: FeatureConfigItem;
    fastEnter: FeatureConfigItem;
    breadcrumb: FeatureConfigItem;
    globalSearch: FeatureConfigItem;
    fullscreen: FeatureConfigItem;
    notification: FeatureConfigItem;
    chat: FeatureConfigItem;
    language: FeatureConfigItem;
    settings: FeatureConfigItem;
    themeToggle: FeatureConfigItem;
    sizeSelect: FeatureConfigItem;
  }

  // ==================== types/router/index.ts 导出类型 ====================

  /** 路由元数据接口 */
  interface RouteMeta extends Record<string | number | symbol, unknown> {
    title: string;
    icon?: string;
    showBadge?: boolean;
    showTextBadge?: string;
    isHide?: boolean;
    isHideTab?: boolean;
    link?: string;
    isIframe?: boolean;
    keepAlive?: boolean;
    authList?: Array<{
      title: string;
      authMark: string;
    }>;
    isFirstLevel?: boolean;
    roles?: string[];
    fixedTab?: boolean;
    activePath?: string;
    isAuthButton?: boolean;
    authMark?: string;
    parentPath?: string;
    shellRoute?: boolean;
    remountOnFullPath?: boolean;
    scope?: "web" | "app";
  }

  /** 应用路由记录接口 */
  interface AppRouteRecord extends Omit<RouteRecordRaw, "meta" | "children" | "component"> {
    id?: number;
    meta: RouteMeta;
    children?: AppRouteRecord[];
    component?: string | (() => Promise<any>);
  }
}

// ==================== 模块扩展声明 ====================

// from types/router/index.ts
declare module "vue-router" {
  // https://router.vuejs.org/zh/guide/advanced/meta.html#typescript
  // 可以通过扩展 RouteMeta 接口来输入 meta 字段
  interface RouteMeta {
    /**
     * 菜单名称
     * @example 'Dashboard'
     */
    title?: string;

    /**
     * 菜单图标
     * @example 'el-icon-edit'
     */
    icon?: string;

    /**
     * 是否隐藏菜单
     * true 隐藏, false 显示
     * @default false
     */
    hidden?: boolean;

    /**
     * 始终显示父级菜单，即使只有一个子菜单
     * true 显示父级菜单, false 隐藏父级菜单，显示唯一子节点
     * @default false
     */
    alwaysShow?: boolean;

    /**
     * 是否固定在页签上
     * true 固定, false 不固定
     * @default false
     */
    affix?: boolean;

    /**
     * 是否缓存页面
     * true 缓存, false 不缓存
     * @default false
     */
    keepAlive?: boolean;

    /**
     * 为 true 时 KeepAlive 子组件 `:key` 使用 `fullPath`（query/hash 变化会整页重挂载）。
     * 默认用 `name + params`，减轻 query 微调导致的重复 onMounted / useTable immediate。
     */
    remountOnFullPath?: boolean;

    /**
     * 静态壳层路由（路由已在 router 注册，菜单项仅用于跳转，无 component 字段）
     */
    shellRoute?: boolean;

    /**
     * 是否在面包屑导航中隐藏
     * true 隐藏, false 显示
     * @default false
     */
    breadcrumb?: boolean;
  }
}

// from types/directive/index.ts
declare module "vue" {
  export interface GlobalDirectives {
    vAuth: AuthDirective;
    vRoles: RolesDirective;
    vRipple: RippleDirective;
    vHighlight: HighlightDirective;
  }
}

export {};
