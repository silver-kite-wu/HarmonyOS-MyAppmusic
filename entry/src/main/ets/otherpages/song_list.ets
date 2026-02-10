import router from '@ohos.router'
import { songlist, songtype } from '../data/music'
import avplayerClass from '../services/avplayermanager'

interface SongListParams {
  title: string
  ids: number[]
}

@Entry
@Component
export struct SongListPage {
  private pageTitle: string = '歌曲列表'
  private ids: number[] = []
  private songs: songtype[] = []

  aboutToAppear(): void {
    const params = router.getParams() as SongListParams | undefined
    this.pageTitle = params?.title ?? '歌曲列表'
    this.ids = Array.isArray(params?.ids) ? params!.ids : []
    // 根据 ids 过滤出歌曲
    const idSet: Set<number> = new Set(this.ids)
    this.songs = songlist.filter((s) => idSet.has(s.id))
  }

  private async playAt(index: number): Promise<void> {
    // 设置播放列表为当前筛选结果，再播放对应下标
    avplayerClass.playlist = this.songs
    avplayerClass.playindex = index
    await avplayerClass.playSongByIndex(index)
    // 跳转到播放页
    router.pushUrl({ url: 'pages/Playnow' })
  }

  build(): void {
    Column() {
      // 顶部栏
      Row() {
        Image($r('app.media.back'))
          .width(25)
          .height(25)
          .onClick((): void => router.back())

        Text(this.pageTitle)
          .layoutWeight(1)
          .fontSize(18)
          .fontWeight(600)
          .textAlign(TextAlign.Center)
      }
      .margin({bottom:20})
      .width('100%')
      .height(48)
      .padding({ left: 12, right: 12 })

      // 歌曲列表
      List() {
        ForEach(this.songs, (item: songtype, index: number) => {
          ListItem() {
            Row() {
              Image(item.img).width(56).height(56).borderRadius(8)
                .margin({right:'20%'})
              Column({ space: 6 }) {
                Text(item.name).fontSize(16).fontWeight(600)
                  .width('100%')
                Text(item.author).fontSize(12).fontColor('#666')
                  .width('100%')
              }
              .width('100%')
              .padding({ left: 10 })
            }
            .borderRadius(10)
            .backgroundColor('#ffa99a41')
            .width('100%')
            .margin({bottom:10})
            .padding({ top: 10, bottom: 10, left: 12, right: 12 })
          }
          .onClick(() => { this.playAt(index) })
        })
      }
      .edgeEffect(EdgeEffect.Spring)
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

@Builder
export function song_listBuilder(): void {
  SongListPage()
}


