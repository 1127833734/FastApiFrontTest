import { shallowRef } from 'vue'

export interface ListPageParams {
  page_no: number
  page_size: number
}

export interface ListPageOptions<T> {
  fetcher: (params: ListPageParams) => Promise<PageResult<T>>
  pageSize?: number
  onError?: (error: unknown) => void
}

/**
 * 通用列表分页逻辑
 * 统一管理页码、总数、加载态与翻页动作，配合 PaginationBar 使用
 */
export function useListPage<T>(options: ListPageOptions<T>) {
  const { fetcher, pageSize = 10, onError } = options

  const list = shallowRef<T[]>([])
  const total = ref(0)
  const loading = ref(false)
  const pageParams = ref<ListPageParams>({ page_no: 1, page_size: pageSize })

  /** 加载当前页数据 */
  async function loadData() {
    loading.value = true
    try {
      const res = await fetcher({ page_no: pageParams.value.page_no, page_size: pageParams.value.page_size })
      list.value = res.list ?? []
      total.value = res.total ?? 0
    }
    catch (error) {
      onError?.(error)
    }
    finally {
      loading.value = false
    }
  }

  /** 上一页 */
  function loadPrev() {
    if (pageParams.value.page_no <= 1)
      return
    pageParams.value.page_no -= 1
    loadData()
  }

  /** 下一页 */
  function loadNext() {
    pageParams.value.page_no += 1
    loadData()
  }

  /** 跳回第一页（搜索/重置时使用） */
  function toFirst() {
    pageParams.value.page_no = 1
    loadData()
  }

  return { list, total, loading, pageParams, loadData, loadPrev, loadNext, toFirst }
}
