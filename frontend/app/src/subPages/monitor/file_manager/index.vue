<script setup lang="ts">
import type { ResourceItem } from '@/api/module_monitor/resource'
import { onLoad, onPullDownRefresh } from '@dcloudio/uni-app'
import { ref } from 'vue'
import { ResourceAPI } from '@/api/module_monitor/resource'

definePage({ name: 'work-file-manager', style: { navigationBarTitleText: '文件管理' } })

const toast = useToast()
const currentPath = ref('')
const showMkdir = ref(false)
const newDirName = ref('')

const { list: files, total, loading, pageParams, loadData, toFirst, loadPrev, loadNext } = useListPage<ResourceItem>({
  fetcher: p => ResourceAPI.getPage({ ...p, path: currentPath.value || undefined }),
  onError: e => toast.error(getErrorMessage(e, '加载失败')),
})

function enterDir(path: string) {
  currentPath.value = path
  toFirst()
  loadData()
}

function goBack() {
  const parts = currentPath.value.split('/').filter(Boolean)
  parts.pop()
  currentPath.value = parts.length ? `/${parts.join('/')}` : ''
  toFirst()
  loadData()
}

function goHome() {
  currentPath.value = ''
  toFirst()
  loadData()
}

// Upload
function handleUpload() {
  uni.chooseImage({
    count: 1,
    success: async (res) => {
      const filePath = res.tempFilePaths[0]
      const fileName = filePath.split('/').pop() || 'unknown'
      try {
        await ResourceAPI.upload(currentPath.value || '/', filePath, fileName)
        toast.success('上传成功')
        loadData()
      }
      catch (e) { toast.error(getErrorMessage(e, '上传失败')) }
    },
  })
}

// Create directory
async function handleMkdir() {
  if (!newDirName.value.trim()) {
    toast.error('请输入目录名')
    return
  }
  try {
    await ResourceAPI.mkdir(currentPath.value || '/', newDirName.value.trim())
    toast.success('目录创建成功')
    showMkdir.value = false
    newDirName.value = ''
    loadData()
  }
  catch (e) { toast.error(getErrorMessage(e, '创建失败')) }
}

// Delete
function handleDelete(id: number) {
  uni.showModal({
    title: '提示',
    content: '确认删除该文件/目录？',
    success: async (r) => {
      if (r.confirm) {
        try {
          await ResourceAPI.remove([id])
          toast.success('已删除')
          loadData()
        }
        catch (e) { toast.error(getErrorMessage(e, '删除失败')) }
      }
    },
  })
}

// Download
async function handleDownload(id: number) {
  try {
    const res = await ResourceAPI.download(id)
    if (res?.url) {
      uni.downloadFile({
        url: res.url,
        success: () => { toast.success('下载成功') },
        fail: () => { toast.error('下载失败') },
      })
    }
  }
  catch (e) { toast.error(getErrorMessage(e, '下载失败')) }
}

function getFileIcon(name: string, is_dir?: boolean): string {
  if (is_dir)
    return 'folder'
  const ext = name?.split('.').pop()?.toLowerCase() || ''
  const iconMap: Record<string, string> = {
    png: 'file-image',
    jpg: 'file-image',
    jpeg: 'file-image',
    gif: 'file-image',
    svg: 'file-image',
    webp: 'file-image',
    mp4: 'file-video',
    avi: 'file-video',
    mov: 'file-video',
    mkv: 'file-video',
    mp3: 'file-audio',
    wav: 'file-audio',
    pdf: 'file-pdf',
  }
  return iconMap[ext] || 'file'
}

onReachBottom(() => {
  if (!loading.value)
    loadNext()
})
onPullDownRefresh(() => loadData())
onLoad(() => loadData())
</script>

<template>
  <view class="page-wraper">
    <!-- Breadcrumb navigation -->
    <view class="breadcrumb-bar">
      <view class="flex items-center gap-xs">
        <wd-button size="small" plain :disabled="!currentPath" @click="goHome">
          <wd-icon name="home" size="14px" />
        </wd-button>
        <text class="text-xs text-muted">
          /
        </text>
        <template v-if="currentPath">
          <wd-button size="small" plain @click="goBack">
            <wd-icon name="arrow-left" size="14px" />
          </wd-button>
          <text class="text-sm text-muted truncate flex-1">
            {{ currentPath }}
          </text>
        </template>
        <text v-else class="text-sm text-muted flex-1">
          根目录
        </text>
      </view>
    </view>

    <!-- Actions -->
    <view class="action-bar">
      <text class="text-md font-bold text-muted">
        共 {{ total }} 项
      </text>
      <view class="flex gap-sm">
        <wd-button size="small" plain @click="showMkdir = true">新建目录</wd-button>
        <wd-button size="small" type="primary" @click="handleUpload">上传文件</wd-button>
      </view>
    </view>

    <!-- File list -->
    <SkeletonPage v-if="loading" :rows="5" />
    <template v-else>
      <view class="px-sm">
        <view class="admin-card">
          <ListEmpty v-if="!loading && files.length === 0" text="当前目录为空" />
          <wd-cell-group v-else>
            <wd-cell
              v-for="item in files"
              :key="item.id"
              :is-link="item.is_dir"
              @click="item.is_dir ? enterDir(currentPath ? `${currentPath}/${item.name}` : `/${item.name}`) : null"
            >
              <template #title>
                <view class="flex items-center gap-sm">
                  <wd-icon :name="getFileIcon(item.name, item.is_dir)" size="22px" :color="item.is_dir ? 'var(--warning-color)' : 'var(--primary-color)'" />
                  <view>
                    <text class="font-medium text-md">
                      {{ item.name }}
                    </text>
                    <text class="text-xs text-muted block mt-xs">
                      {{ item.size || '-' }}{{ item.created_time ? ` · ${item.created_time}` : '' }}
                    </text>
                  </view>
                </view>
              </template>
              <template #default>
                <view class="flex items-center gap-sm">
                  <template v-if="!item.is_dir">
                    <wd-icon name="download" size="18px" color="var(--primary-color)" @click.stop="handleDownload(item.id)" />
                  </template>
                  <wd-icon name="delete" size="18px" color="var(--danger-color)" @click.stop="handleDelete(item.id)" />
                </view>
              </template>
            </wd-cell>
          </wd-cell-group>
        </view>
      </view>
      <PaginationBar :current="pageParams.page_no" :page-size="pageParams.page_size" :total="total" @prev="loadPrev" @next="loadNext" />
    </template>

    <!-- Mkdir Popup -->
    <wd-popup v-model="showMkdir" position="bottom" round @close="showMkdir = false">
      <view class="p-xl" style="max-height:40vh;">
        <wd-navbar title="新建目录" left-arrow @click-left="showMkdir = false" />
        <view class="mt-lg">
          <view class="flex items-center gap-sm">
            <text>目录名</text>
            <wd-input v-model="newDirName" placeholder="请输入目录名称" class="flex-1" />
          </view>
          <view class="flex gap-md mt-lg">
            <wd-button block plain @click="showMkdir = false">取消</wd-button>
            <wd-button block type="primary" @click="handleMkdir">创建</wd-button>
          </view>
        </view>
      </view>
    </wd-popup>
  </view>
</template>
