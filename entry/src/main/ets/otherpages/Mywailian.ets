import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import pasteboard from '@ohos.pasteboard'
@Entry
@Component
struct Mywailian {
  @State url: string = ''
  @State urlmp3: string = ''

  // 解析网易云分享/网页链接，提取 id 构造外链 mp3 地址
  private handleurl(input: string): string {
    if (!input || input.trim().length === 0) {
      return ''
    }
    const text = input.trim()
    // 支持如: https://music.163.com/#/song?id=123 | https://y.music.163.com/m/song?id=123 等
    const match = text.match(/song\?id=(\d+)/)
    const id = match && match[1] ? match[1] : ''
    if (!id) {
      return ''
    }
    // 使用 https，避免 http 跨域或降级
    return `https://music.163.com/song/media/outer/url?id=${id}.mp3`
  }

  private async pasteFromClipboard(): Promise<void> {
    try {
      const systemPasteboard = pasteboard.getSystemPasteboard()
      const data = await systemPasteboard.getData()
      const mime = data?.getPrimaryMimeType ? data.getPrimaryMimeType() : ''
      const txt = mime === pasteboard.MIMETYPE_TEXT_PLAIN && data?.getPrimaryText ? data.getPrimaryText() : ''
      if (txt) {
        this.url = txt
        console.log('粘贴取得链接:', txt)
        promptAction.showToast({ message: '已粘贴链接', duration: 1200 })
      } else {
        promptAction.showToast({ message: '剪贴板为空', duration: 1500 })
      }
    } catch (e) {
      promptAction.showToast({ message: '读取剪贴板失败', duration: 1500 })
    }
  }

  private async copyMp3ToClipboard(): Promise<void> {
    try {
      if (!this.urlmp3) {
        promptAction.showToast({ message: '没有可复制的 mp3 链接', duration: 1500 })
        return
      }
      const systemPasteboard = pasteboard.getSystemPasteboard()
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.urlmp3)
      await systemPasteboard.setData(data)
      console.log('已复制 mp3 链接:', this.urlmp3)
      promptAction.showToast({ message: 'mp3 链接已复制', duration: 1200 })
    } catch (_) {
      promptAction.showToast({ message: '复制失败', duration: 1500 })
    }
  }
  build() {
    Column({space:10}){
      Row(){
        Image($r('app.media.back'))
          .width(20)
          .fillColor(Color.Black)
          .margin({left:10})
          .onClick(()=>{
            router.back()
          })
        Text('外联转换')
          .margin({left:'30%'})
          .fontSize(24)
          .fontWeight(500)
      }
      .height(50)
      .width('100%')
      Image('https://tse1-mm.cn.bing.net/th/id/OIP-C.6ECWLER4835Nn75LoqaAsAHaHa?w=202&h=188&c=7&r=0&o=5&dpr=1.3&pid=1.7')
        .width(100)
        .borderRadius(10)
      Column(){
        Row() {
          Image($r('app.media.bianji'))
            .width(20)
            .margin({ left: 20 })

          TextInput({
            placeholder: '复制链接到此处...' ,
            text:$$this.url
          })
            .fontSize(18)
            .backgroundColor(Color.Transparent)
            .width('100%')
            .textAlign(TextAlign.Start)
            .onSubmit(()=>{
              this.urlmp3 = this.handleurl(this.url)
              if (this.urlmp3) {
                console.log('原始链接:', this.url)
                console.log('生成 mp3 链接:', this.urlmp3)
                promptAction.showToast({ message: '转换成功', duration: 1000 })
              } else {
                promptAction.showToast({ message: '链接格式错误', duration: 1500 })
              }
            })
            .onChange((v:string)=>{ this.url = v })
        }
        .height(40)
        .backgroundColor('#f5f6f5')
        .borderRadius(20)
        .margin({ left: 15, right: 20, top: 10, bottom: 10 })
        .clip(true)
        Image($r('app.media.zhantie'))
          .width(30).height(30)
          .margin({ right: 12 })
          .onClick(()=>{ this.pasteFromClipboard() })
        Row() {
          TextInput({
            placeholder: 'mp3...' ,
            text:$$this.urlmp3
          })
            .fontSize(18)
            .backgroundColor(Color.Transparent)
            .width('100%')
            .textAlign(TextAlign.Start)
        }
        .height(40)
        .backgroundColor('#f5f6f5')
        .borderRadius(20)
        .margin({ left: 15, right: 20, top: 10, bottom: 10 })
        .clip(true)
        Row({space:30}){
          Image($r('app.media.copy'))
            .width(30).height(30)
            .margin({ right: 12 })
            .onClick(()=>{ this.copyMp3ToClipboard() })
          Image($r('app.media.qingkong'))
            .margin({right:12})
            .width(30).height(30)
            .onClick(()=>{ this.url=''; this.urlmp3='' })
        }
      }
      .width('100%')
      .height('100%')
    }
    .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
    .width('100%')
    .height('100%')
    .padding({left:10,right:10,top:5,bottom:5})
    .radialGradient({
      center:['90%','-10%'],
      radius:'150%',
      colors:[
        ['#ffab884c',0.5],
        [Color.Transparent,1]
      ]
    })
  }
}