import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import common from '@ohos.app.ability.common'
import webview from '@ohos.web.webview'
import connection from '@ohos.net.connection'
import pasteboard from '@ohos.pasteboard'
import { Want } from '@kit.AbilityKit'

interface WebPageParams {
  url?: string
  title?: string
}
interface WebPageBeginEvent {
  url?: string
}

interface WebPageEndEvent {
  url?: string
}

interface WebErrorEvent {
  errorCode?: number
  description?: string
  url?: string
}

// URL 拦截事件的最小结构
interface MaybeUrl { url?: string }
interface MaybeRequest { request?: MaybeUrl }
interface InterceptEvent extends MaybeUrl, MaybeRequest {}
@Entry
@Component
export struct WebPage {
  private controller: webview.WebviewController = new webview.WebviewController()
  private pageTitle: string = '网页'
  private targetUrl: string = ''
  @State private isLoading: boolean = true
  @State private hasNetworkError: boolean = false
  @State private errorMessage: string = ''

  aboutToAppear(): void {
    const params = router.getParams() as WebPageParams | undefined
    this.targetUrl = params?.url ?? 'https://www.example.com'
    this.pageTitle = params?.title ?? '网页'
    
    console.log('页面初始化，目标URL:', this.targetUrl)
    // 初始状态设置为加载中，不预设错误状态
    this.isLoading = true
    this.hasNetworkError = false
  }

  private async checkNetworkAndLoad(): Promise<void> {
    try {
      console.log('开始加载网页:', this.targetUrl)
      this.controller.loadUrl(this.targetUrl)
    } catch (error) {
      console.error('网页加载失败:', error)
      this.hasNetworkError = true
      this.errorMessage = '无法打开网页，请检查网络连接'
      this.isLoading = false
    }
  }

  private normalizeUrl(src: string): string {
    if (!src) { return '' }
    const lower = src.trim().toLowerCase()
    if (lower.startsWith('http://') || lower.startsWith('https://')) { return src.trim() }
    // 其他 scheme 直接返回原串，留给外部处理
    if (lower.includes('://')) { return src.trim() }
    return `https://${src.trim()}`
  }

  private async openExternally(): Promise<void> {
    try {
      const context = getContext(this) as common.UIAbilityContext
      const url = this.normalizeUrl(this.targetUrl)
      const candidates: string[] = [
        'ohos.want.action.viewData',
        'ohos.want.action.view',
        'action.system.browse',
        'action.view'
      ]
      let launched = false
      for (const action of candidates) {
        try {
          const want: Want = { action, uri: url, flags: 0x10000000 } as Want
          await context.startAbility(want)
          launched = true
          break
        } catch (_) {}
      }
      if (!launched) { throw new Error('no browser handler') }
    } catch (error) {
      console.error('外部打开失败:', error as Error)
      try {
        const systemPasteboard = pasteboard.getSystemPasteboard()
        const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.targetUrl || '')
        await systemPasteboard.setData(data)
        promptAction.showToast({ message: '未检测到浏览器，链接已复制', duration: 2500 })
      } catch (_) {
        promptAction.showToast({ message: '未检测到浏览器或网络异常', duration: 2500 })
      }
    }
  }

  build(): void {
    Column() {
      // 顶部栏
      Row() {
        Image($r('app.media.back'))
          .width(30).height(30)
        .onClick((): void => router.back())

        Text(this.pageTitle)
          .margin({left:'30%'})
          .fontSize(18)
          .fontWeight(600)
          .textAlign(TextAlign.Center)

        Image($r('app.media.webopen'))
          .width(30).height(30)
          .margin({right:16,left:'30%'})
        .onClick(() => this.openExternally())
      }
      .width('100%')
      .height(48)
      .padding({ left: 12, right: 12 })

      // 主要内容区域
      Stack() {
        // Web组件 - 始终存在
        Web({ src: this.targetUrl, controller: this.controller })
          .width('100%')
          .height('100%')
          .javaScriptAccess(true)
          .zoomAccess(true)
          .onPageBegin((event: WebPageBeginEvent): void => {
            this.isLoading = true
            this.hasNetworkError = false
            console.log('Web 开始加载:', event.url ?? this.targetUrl)
          })
          .onPageEnd((event: WebPageEndEvent): void => {
            this.isLoading = false
            this.hasNetworkError = false
            console.log('Web 加载完成:', event.url ?? this.targetUrl)
          })
          .onErrorReceive((event) => {
            this.isLoading = false
            this.hasNetworkError = true
            
            const webError = event as WebErrorEvent
            const errorCode = webError.errorCode || 0
            
            // 根据错误码提供更具体的错误信息
            if (errorCode === -2 || errorCode === -105) {
              this.errorMessage = '无法连接到服务器，请检查网络连接'
            } else if (errorCode === -106) {
              this.errorMessage = '网络连接超时，请检查网络状态'
            } else if (errorCode === -118) {
              this.errorMessage = '网络连接已断开，请检查网络连接'
            } else if (errorCode === -8) {
              this.errorMessage = '网页地址无效或无法访问'
            } else if (errorCode === -15) {
              this.errorMessage = '网络不可用，请检查网络设置'
            } else {
              this.errorMessage = '网页加载失败，请检查网络连接'
            }
            
            console.error('Web 加载错误:', JSON.stringify(event))
            console.error('错误码:', errorCode, '错误描述:', webError.description)
            
            promptAction.showToast({ 
              message: this.errorMessage, 
              duration: 3000 
            })
          })
          .onUrlLoadIntercept((event): boolean => {
            const e = event as InterceptEvent
            const nextUrl: string | undefined = e.request?.url ?? e.url
            if (!nextUrl) {
              return false
            }
            // 仅放行 http/https，其他 scheme 交给外部处理
            const lower = nextUrl.toLowerCase()
            const isHttp = lower.startsWith('http://') || lower.startsWith('https://')
            if (!isHttp) {
              console.log('拦截外部链接并外部打开:', nextUrl)
              try {
                const context = getContext(this) as common.UIAbilityContext
                const url = this.normalizeUrl(nextUrl)
                // 为了避免在同步回调中使用 await，这里只尝试首选动作并忽略其异步结果
                const want: Want = { action: 'ohos.want.action.viewData', uri: url, flags: 0x10000000 } as Want
                context.startAbility(want).catch(() => {})
              } catch (e2) {
                console.error('外部处理 scheme 失败:', e2 as Error)
              }
              return true
            }
            return false
          })
        
        // 加载提示覆盖层
        if (this.isLoading) {
          Row() {
            LoadingProgress()
            Text(' 正在加载...')
              .margin({ left: 8 })
          }
          .width('100%')
          .height(40)
          .backgroundColor('rgba(255, 255, 255, 0.9)')
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
        }
        
        // 错误状态覆盖层
        if (this.hasNetworkError) {
          Column({ space: 12 }) {
            Image($r('app.media.shibai'))
              .width(48)
              .height(48)
            
            Text(this.errorMessage)
              .fontSize(16)
              .fontColor('#666')
              .textAlign(TextAlign.Center)
              .maxLines(3)
            
            Row({ space: 12 }) {
              Button('重新加载')
                .onClick(() => {
                  this.hasNetworkError = false
                  this.isLoading = true
                  this.checkNetworkAndLoad()
                })
              
              Button('外部打开')
                .onClick(() => this.openExternally())
            }
          }
          .width('100%')
          .height('100%')
          .backgroundColor('#FFFFFF')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .padding(24)
        }
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}

@Builder
export function web_pageBuilder(): void {
  WebPage()
}


