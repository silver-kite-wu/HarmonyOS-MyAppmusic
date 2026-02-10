/*
author:wuzheng
* time:2025/8/8
* log:完成
 */
import {swiperList}from '../data/swiperdata'//轮播图数据
import {dailytype,dailydatas}from '../data/maindailytype'//每日推荐数据
import {software,SoftwareItem}from '../data/othersoft'//其他软件数据
import {playlist,playlists}from '../data/recommenddata'//推荐歌单数据
import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import pasteboard from '@ohos.pasteboard'
import avplayerClass from '../services/avplayermanager'
import { emitter } from '@kit.BasicServicesKit'
import common from '@ohos.app.ability.common'
import { saveLastMini, loadLastMini } from '../Uitl/preferences'
import { notificationManager } from '@kit.NotificationKit'

// 确保全局进度键存在（即便未进入 Playnow 页面）
AppStorage.SetOrCreate('val', 0)
AppStorage.SetOrCreate('total', 100)

// 定义Want接口
interface WantParams {
  action: string
  uri: string
  flags: number
}

// 列表路由参数类型
interface SongListRouteParams {
  title: string
  ids: number[]
}

// 播放状态（与播放器上报字段最小对齐）
interface MiniPlayState {
  img: string
  name: string
  author: string
  isplay: boolean
}

// 播放器事件负载（字段可选）
interface PlayerEventPayload {
  img?: string
  name?: string
  author?: string
  isplay?: boolean
  playindex?: number
  // 同步播放进度（毫秒）
  time?: number
  duration?: number
}

// emitter 事件结构
interface PlayerEmitterEvent {
  data?: PlayerEventPayload
}

// 为每日推荐与推荐歌单建立歌曲ID映射（基于 data/music.ets 的 id）
const DAILY_IDS: number[][] = [
  [0, 1, 2, 3, 4],      // 每日推荐
  [5, 6, 7,12,11],            // 青春经典
  [8, 9, 10,12,17],           // 流行音乐
  [11, 12, 13, 14, 15]  // 森林漫游
]

const PLAYLIST_IDS: number[][] = [
  [0, 2, 4, 6, 8],
  [1, 3, 5, 7, 9],
  [10, 11, 12,17],
  [13, 14, 15,18],
  [0, 3, 6, 9, 12]
]
  //主页
@Component
export struct main_page {
  myScroll:Scroller=new Scroller()
  @StorageLink('val')val:number|null=null
  @StorageLink('total')total:number|null=null
  // 迷你播放器状态
  @State private miniImg: string = ''
  @State private miniName: string = ''
  @State private miniAuthor: string = ''
  @State private miniIsPlay: boolean = false
  @State private miniIndex: number = -1

  private subscribed: boolean = false
  private subscribePlayer(): void {
    if (this.subscribed) { return }
    this.subscribed = true
    // 与 avplayermanager.updatestate() 一致的事件通道
    emitter.on('play_state_update', (eventData: PlayerEmitterEvent) => {
      const d = eventData && eventData.data ? eventData.data : undefined
      if (!d) { return }
      this.miniImg = d.img || this.miniImg
      this.miniName = d.name || this.miniName
      this.miniAuthor = d.author || this.miniAuthor
      this.miniIsPlay = d.isplay !== undefined ? !!d.isplay : this.miniIsPlay
      if (typeof d.playindex === 'number') { this.miniIndex = d.playindex }
      // 关键修复：直接使用全局事件中的进度与总时长，驱动悬浮栏进度条
      if (typeof d.time === 'number') { this.val = d.time }
      if (typeof d.duration === 'number') { this.total = d.duration }
      // 持久化迷你播放器状态
      try {
        const ctx = getContext(this) as common.UIAbilityContext
        saveLastMini(ctx, {
          img: this.miniImg,
          name: this.miniName,
          author: this.miniAuthor,
          isplay: this.miniIsPlay,
          playindex: this.miniIndex
        })
      } catch (_) {}
    })
  }
    aboutToAppear(): void {
    this.subscribePlayer()
    // 恢复上次关闭前的迷你播放器信息
    try {
      const ctx = getContext(this) as common.UIAbilityContext
      loadLastMini(ctx).then(s => {
        if (s) {
          // 更新UI状态
          this.miniImg = s.img || this.miniImg
          this.miniName = s.name || this.miniName
          this.miniAuthor = s.author || this.miniAuthor
          this.miniIsPlay = !!s.isplay
          
          if (typeof s.playindex === 'number' && s.playindex >= 0) {
            this.miniIndex = s.playindex
            
            // 更新播放器状态
            avplayerClass.playindex = s.playindex
            
            // 如果之前有在播放，则恢复播放
            if (s.isplay) {
              // 延迟执行，确保播放器已经初始化
              setTimeout(() => {
                avplayerClass.playSongByIndex(s.playindex).then(() => {
                  // 确保播放状态同步
                  if (avplayerClass.player) {
                    avplayerClass.player.play().then(() => {
                      avplayerClass.isplay = true;
                      this.miniIsPlay = true;
                    }).catch(() => console.error('恢复播放失败:'));
                  }
                }).catch(() => console.error('播放歌曲失败:'));
              }, 300);
            } else {
              // 如果之前是暂停状态，只更新UI不播放
              avplayerClass.isplay = false;
              this.miniIsPlay = false;
            }
          }
        }
      }).catch((error: Error) => {
        console.error('Failed to load last play state:', error);
      });
    } catch (error) {
      console.error('Error in aboutToAppear:', error);
    }
  }
  
  // 复制链接到剪贴板

  async copyToClipboard(url: string, title: string) {
    try {
      const systemPasteboard = pasteboard.getSystemPasteboard()
      const pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, url)
      await systemPasteboard.setData(pasteData)
      
      promptAction.showToast({
        message: `${title} 链接已复制到剪贴板`,  
        duration: 2000
      })
      
      console.log('链接复制成功:', url)
    } catch (error) {
      console.error('复制链接失败:', error)
      promptAction.showToast({
        message: '复制链接失败，请手动复制',
        duration: 2000
      })
    }
  }
  
  // 跳转到网页
  async navigateToWeb(url: string, title: string) {
    try {
      console.log('准备跳转到网页:', url, '标题:', title)
      
      // 验证URL格式
      if (!url || (!url.startsWith('http://') && !url.startsWith('https://'))) {
        promptAction.showToast({
          message: `无效的网址格式`,
          duration: 2000
        })
        return
      }
      
      // 显示加载提示
      promptAction.showToast({
        message: `正在打开 ${title}...`,
        duration: 1500
      })
      
      // 跳转到内置网页
      await router.pushUrl({
        url: 'otherpages/web_page',
        params: { url, title }
      })
      
      console.log('网页跳转成功')
      
    } catch (error) {
      console.error('网页跳转失败:', error)
      
      // 显示详细错误提示
      promptAction.showToast({
        message: `无法打开 ${title}，请检查网络连接`,
        duration: 3000
      })
      
      // 提供备选方案：复制链接
      setTimeout(() => {
        promptAction.showToast({
          message: `长按可复制 ${title} 链接`,
          duration: 2000
        })
      }, 3500)
    }
  }

  private openSongList(params: SongListRouteParams): void {
    try {
      promptAction.showToast({ message: `打开列表：${params.title}`, duration: 1200 })
      router.pushUrl({ url: 'otherpages/song_list', params })
    } catch (e) {
      console.error('打开歌曲列表失败:', e)
    }
  }

  private async togglePlay(): Promise<void> {
    console.log('togglePlay called, current state:', this.miniIsPlay);
    try {
      if (this.miniIsPlay) {
        await avplayerClass.pause();
      } else {
        // 如果没有正在播放的歌曲，播放当前索引的歌曲
        if (avplayerClass.playindex < 0 && avplayerClass.playlist.length > 0) {
          await avplayerClass.playSongByIndex(0);
        } else {
          await avplayerClass.play();
        }
      }
      // 更新UI状态
      this.miniIsPlay = avplayerClass.isplay;
    } catch (error) {
      console.error('切换播放状态失败:', error);
    }
  }

  private openNowPlaying(): void {
    const idx = (typeof this.miniIndex === 'number' && this.miniIndex >= 0)
      ? this.miniIndex
      : (typeof avplayerClass.playindex === 'number' ? avplayerClass.playindex : -1)

    try {
      if (idx >= 0) {
        router.pushUrl({ url: 'pages/Playnow', params: { playindex: idx } })
      } else {
        router.pushUrl({ url: 'pages/Playnow' })
      }
    } catch (e) {
      router.pushUrl({ url: 'pages/Playnow' })
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 主内容
      Column(){
        Scroll(this.myScroll){
          Column({space:15}){
            //头
            Button({ type: ButtonType.Normal }) {
              Row(){
                Image($r('app.media.main_input'))
                  .width(22)
                  .fillColor('#817D83')
                  .margin(5)
                Text('搜索音乐或歌手...')
                  .padding({left:5})
                  .fontColor('#999')
                  .layoutWeight(1)
              }
              .height('5%')
              .width('100%')
            }
            .width('100%')
            .backgroundColor('#2D2B29')
            .borderRadius(20)
            .padding({left:8,right:8})
            .onClick(()=>{
              console.log('点击搜索框，准备跳转到搜索页面')
              try {
                router.pushUrl({ url: 'otherpages/seek_page' })
                console.log('跳转成功')
              } catch (error) {
                console.error('跳转失败:', error)
              }
            })
            .stateEffect(true)
            //轮播
            Swiper(){
              ForEach(swiperList,(item:string)=>{
                Image(item)
                  .width('100%')
                  .borderRadius(10)
              })
            }
            .autoPlay(true)

            //软件跳转其他应用
            Column({space:15}){
              Text('其他应用')
                .width('100%')
                .fontSize(24)
                .fontWeight(700)
              Row(){
                ForEach(software,(item:SoftwareItem)=>{
                  Column({space:8}){
                    Image(item.icon)
                      .width(50)
                      .height(50)
                      .borderRadius(25)
                      .onClick(() => {
                        this.navigateToWeb(item.url, item.name)
                      })
                      .gesture(
                        LongPressGesture({ repeat: false })
                          .onAction(() => {
                            this.copyToClipboard(item.url, item.name)
                          })
                      )
                    Text(item.name)
                      .fontSize(12)
                      .fontColor('#333')
                      .maxLines(1)
                      .textOverflow({overflow:TextOverflow.Ellipsis})
                  }
                  .width('30%')
                  .alignItems(HorizontalAlign.Center)
                })
              }
              .justifyContent(FlexAlign.SpaceAround)
              .width('100%')
              .margin({bottom:10})
            }
            .padding(10)
            .width('100%')
            .backgroundColor('#ffc2f1e5')
            .borderRadius(10)

            //每日推荐
            Column({space:10}){
              Text('每日推荐')
                .width('100%')
                .fontSize(24)
                .fontWeight(700)
                .fontColor('#fff')
              List(){
                ForEach(dailydatas,(item:dailytype, index:number)=>{
                  ListItem(){
                    Column(){
                      Text(item.type)
                        .width('100%')
                        .height(30)
                        .backgroundColor(item.top)
                        .padding({left:5})
                        .fontSize(14)
                        .fontColor('#fff')
                        .fontWeight(600)
                      Image(item.img)
                        .width('100%')
                        .height(100)
                      Text(item.title)
                        .width('100%')
                        .backgroundColor(item.bottom)
                        .padding(5)
                        .fontSize(14)
                        .fontWeight(500)
                        .fontColor('#fff')
                        .maxLines(2)
                        .textOverflow({overflow:TextOverflow.Ellipsis})
                    }
                    .width('40%')
                    .borderRadius(10)
                    .margin({right:10})
                    .clip(true)
                  }
                  .onClick(() => {
                    const ids: number[] = DAILY_IDS[index] ?? []
                    this.openSongList({ title: item.type, ids })
                  })
                })
              }
              .listDirection(Axis.Horizontal)//list横排
              .height(170)
              .scrollBar(BarState.Off)//滑动条
            }

            //推荐歌单
            Column({space:10}){
              Text('推荐歌单')
                .width('100%')
                .fontSize(24)
                .fontWeight(700)
                .fontColor('#fff')
              List(){
                ForEach(playlists,(itme:playlist, index:number)=>{
                  ListItem(){
                    Column(){
                      Stack({alignContent:Alignment.TopStart}){
                        Image(itme.img).width('100%').height(100).borderRadius(8)
                        Text(itme.countdata).fontColor('#fff').fontSize(12).fontWeight(700).margin(6)
                      }
                      Text(itme.title).fontColor('#fff').fontSize(14).width('100%').padding(5).maxLines(2).textOverflow({overflow:TextOverflow.Ellipsis})
                    }
                    .width('30%')
                    .margin({right:10})
                  }
                  .onClick(() => {
                    const ids: number[] = PLAYLIST_IDS[index] ?? []
                    this.openSongList({ title: itme.title, ids })
                  })
                })
              }
              .listDirection(Axis.Horizontal)
            }

            // 为底部悬浮栏预留内边距，避免被遮挡
            Blank().height(64)
          }
        }
        .edgeEffect(EdgeEffect.Spring)//边缘滑动效果
        .scrollBar(BarState.Off)//滑动条
      }
      .align(Alignment.Top)
      .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
      .width('100%')
      .height('100%')
      .padding({left:10,right:10,top:5,bottom:5})
      .radialGradient({
        center:['90%','-10%'],
        radius:'150%',
        colors:[
          ['#ffab884c',0.2],
          [Color.Transparent,1]
        ]
      })

      // 悬浮底部迷你播放器（覆盖在内容之上，始终可见，底部对齐）
      Row() {
          // 封面
          if (this.miniImg) {
            Image(this.miniImg)
              .width(40)
              .height(40)
              .borderRadius(6)
              .objectFit(ImageFit.Cover)
          } else {
            Image($r('app.media.backgroundpicture')).width(40).height(40).borderRadius(6)
          }

          // 歌曲信息
          Column({ space: 4 }) {
            Text(this.miniName || '未播放')
              .fontSize(14)
              .fontWeight(600)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Text(this.miniAuthor || '')
              .fontSize(12)
              .fontColor('#666')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({bottom:2})
            Progress({value:this.val,total:this.total,type:ProgressType.Linear})
              .style({strokeWidth: 6, enableSmoothEffect: true})
          }
          .layoutWeight(1)
          .padding({ left: 10 })
          .onClick(
            () => {
              this.openNowPlaying()
            })

          // 播放/暂停：播放中显示“暂停”图标，暂停时显示“播放”图标
          Image(this.miniIsPlay ? $r('app.media.play') : $r('app.media.pause'))
            .width(28)
            .height(28)
            .onClick(() => {
              this.togglePlay()
            })
            .margin({ right: 12 })

          // 播放列表入口（跳转播放页）
          Image($r('app.media.listensong'))
            .width(28)
            .height(28)
            .onClick(() => this.openNowPlaying())
      }
      .width('100%')
      .height(56)
      .backgroundColor('#E6E6E6')
      .padding({ left: 12, right: 12 })
      .borderRadius(10)
      .margin({ left: 10, right: 10 })
      .align(Alignment.Bottom)
      .zIndex(1000)
      .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.BOTTOM])
    }
    .width('100%')
    .height('100%')
  }
}