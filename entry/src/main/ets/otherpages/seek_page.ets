/*
author:wuzheng
* time:2025/8/8
* log:搜索页面实现
 */
import { songlist, songtype } from '../data/music'
import router from '@ohos.router'
import avplayerClass from '../services/avplayermanager'

@Entry
@Component
struct Seek_page {
  @State searchText: string = ''
  @State searchResults: songtype[] = []
  @State isSearching: boolean = false
  @State currentTabIndex: number = 0 // 当前选中的标签页索引

  // 热门搜索关键词 - 使用music中的歌曲名称
  private hotSearchKeywords: string[] = songlist.slice(0, 20).map(song => song.name)
  
  // 热歌榜数据 - 使用music中的歌曲数据
  private hotSongList: songtype[] = songlist.slice(0, 20).reverse()

  // 获取当前日期
  private getCurrentDate(): string {
    const now = new Date()
    const month = now.getMonth() + 1
    const day = now.getDate()
    const dateString = `${month}月${day}日更新`
    console.log('当前日期:', dateString)
    return dateString
  }

  // 搜索音乐
  searchMusic(query: string) {
    if (!query.trim()) {
      this.searchResults = []
      this.isSearching = false
      return
    }
    
    this.isSearching = true
    // 模拟搜索延迟
    setTimeout(() => {
      this.searchResults = songlist.filter(song => 
        song.name.toLowerCase().includes(query.toLowerCase()) ||
        song.author.toLowerCase().includes(query.toLowerCase())
      )
      this.isSearching = false
    }, 300)
  }

  // 播放搜索结果
  playSearchResult(song: songtype) {
    avplayerClass.singplay(song).then(() => {
      router.pushUrl({ url: 'pages/Playnow' })
    })
  }

  // 播放热门歌曲
  playHotSong(song: songtype) {
    avplayerClass.singplay(song).then(() => {
      router.pushUrl({ url: 'pages/Playnow' })
    })
  }

  // 点击热门搜索关键词
  onHotSearchClick(keyword: string) {
    this.searchText = keyword
    this.searchMusic(keyword)
  }

  // 清空搜索
  clearSearch() {
    this.searchText = ''
    this.searchResults = []
    this.isSearching = false
  }

  // 自定义标签栏构建器
  @Builder
  tabBuilder(tabName: string, index: number) {
    Column({ space: 4 }) {
      Text(tabName)
        .fontSize(16)
        .fontWeight(this.currentTabIndex === index ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.currentTabIndex === index ? '#ff6b35' : '#999999')
    }
    .padding({ top: 8, bottom: 8 })
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button({ type: ButtonType.Circle }) {
          Image($r('app.media.back'))
            .width(24)
            .height(24)
            .fillColor('#fff')
        }
        .width(40)
        .height(40)
        .backgroundColor('transparent')
        .onClick(() => router.back())

        Text('搜索音乐')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#fff')
          .margin({left:'30%'})
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      // 搜索输入框
      Row() {
        Image($r('app.media.main_input'))
          .width(20)
          .height(20)
          .fillColor('#999')
          .margin({ right: 8 })

        TextInput({
          placeholder: '搜索歌手、歌曲名....',
          text: this.searchText
        })
          .placeholderColor('#999')
          .fontColor('#fff')
          .backgroundColor('transparent')
          .layoutWeight(1)
          .onChange((value: string) => {
            this.searchText = value
            this.searchMusic(value)
          })
          .onSubmit((enterKey: EnterKeyType, event: SubmitEvent) => {
            this.searchMusic(this.searchText)
          })

        Button({ type: ButtonType.Circle }) {
          Image($r('app.media.clear'))
            .width(20)
            .height(20)
            .fillColor('#fff')
        }
        .width(40)
        .height(40)
        .backgroundColor('transparent')
        .onClick(() => this.clearSearch())
      }
      .width('90%')
      .height(44)
      .backgroundColor('#2a2a2a')
      .borderRadius(22)
      .padding({ left: 16, right: 16 })
      .margin({ top: 16, bottom: 16 })

      // 主要内容区域
      if (this.isSearching || this.searchText) {
        // 搜索结果
        Column() {
          if (this.isSearching) {
            Row() {
              LoadingProgress()
                .width(24)
                .height(24)
                .color('#ff51c8')
              Text('搜索中...')
                .fontSize(16)
                .fontColor('#999')
                .margin({ left: 8 })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .padding(20)
          } else if (this.searchResults.length > 0) {
            List() {
              ForEach(this.searchResults, (song: songtype) => {
                ListItem() {
                  Row({ space: 12 }) {
                    Image(song.img)
                      .width(50)
                      .height(50)
                      .borderRadius(8)
                      .objectFit(ImageFit.Cover)
                    
                    Column({ space: 4 }) {
                      Text(song.name)
                        .fontSize(16)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#fff')
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                      
                      Text(song.author)
                        .fontSize(14)
                        .fontColor('#ccc')
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)
                    
                    Image($r('app.media.listensong'))
                      .borderRadius(5)
                      .width(30)
                      .height(30)
                      .onClick(() => this.playSearchResult(song))
                  }
                  .width('100%')
                  .padding(12)
                  .backgroundColor('#2a2a2a')
                  .borderRadius(10)
                }
              })
            }
            .width('100%')
            .height('100%')
            .scrollBar(BarState.Off)
          } else {
            Text('未找到相关音乐')
              .fontSize(16)
              .fontColor('#999')
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding(20)
          }
        }
        .layoutWeight(1)
        .width('100%')
      } else {
        // 使用Tabs组件显示热门搜索和热歌榜
        Tabs({
          barPosition: BarPosition.Start,
          index: this.currentTabIndex
        }) {
          // 热门搜索标签页
          TabContent() {
            Column({ space: 12 }) {
              Text('热门搜索')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#fff')
                .width('100%')
                .textAlign(TextAlign.Center)
                .margin({ bottom: 8 })
              
              List() {
                ForEach(this.hotSearchKeywords, (keyword: string, index: number) => {
                  ListItem() {
                    Row({ space: 8 }) {
                      Text(`${index + 1}`)
                        .fontSize(14)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(index < 3 ? '#ff51c8' : '#999')
                        .width(25)
                        .textAlign(TextAlign.Center)
                      
                      Text(keyword)
                        .fontSize(14)
                        .fontColor('#fff')
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .layoutWeight(1)
                      
                      // 标签
                      if (index < 3) {
                        Text('热')
                          .fontSize(10)
                          .fontColor('#fff')
                          .backgroundColor('#ff51c8')
                          .borderRadius(8)
                          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                      } else if (index === 2 || index === 6) {
                        Text('新')
                          .fontSize(10)
                          .fontColor('#fff')
                          .backgroundColor('#ff8c00')
                          .borderRadius(8)
                          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                      }
                    }
                    .width('100%')
                    .padding(8)
                    .backgroundColor('#2a2a2a')
                    .borderRadius(8)
                    .onClick(() => this.onHotSearchClick(keyword))
                  }
                  .height(30)
                  .margin({bottom:5})
                })
              }
              .height(400)
              .scrollBar(BarState.Off)
              .edgeEffect(EdgeEffect.Spring)
              
              Text(this.getCurrentDate())
                .fontSize(12)
                .fontColor('#666')
                .width('100%')
                .textAlign(TextAlign.Center)
                .margin({ top: 8 })
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#1a1a1a')
            .borderRadius(16)
          }
          .tabBar(this.tabBuilder('热门搜索', 0))

          // 热歌榜标签页
          TabContent() {
            Column({ space: 12 }) {
              Text('热歌榜')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#fff')
                .width('100%')
                .textAlign(TextAlign.Center)
                .margin({ bottom: 8 })
              
              List() {
                ForEach(this.hotSongList, (song: songtype, index: number) => {
                  ListItem() {
                    Row({ space: 8 }) {
                      Text(`${index + 1}`)
                        .fontSize(14)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(index < 3 ? '#ff51c8' : '#999')
                        .width(25)
                        .textAlign(TextAlign.Center)
                      
                      Text(song.name)
                        .fontSize(14)
                        .fontColor('#fff')
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .layoutWeight(1)
                    }
                    .width('100%')
                    .padding(8)
                    .backgroundColor('#2a2a2a')
                    .borderRadius(8)
                    .onClick(() => this.playHotSong(song))
                  }
                  .height(30)
                  .margin({bottom:5})
                })
              }
              .height(400)
              .scrollBar(BarState.Off)
              .edgeEffect(EdgeEffect.Spring)
              
              Text(this.getCurrentDate())
                .fontSize(12)
                .fontColor('#666')
                .width('100%')
                .textAlign(TextAlign.Center)
                .margin({ top: 8 })
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#1a1a1a')
            .borderRadius(16)
          }
          .tabBar(this.tabBuilder('热歌榜', 1))
        }
        .layoutWeight(1)
        .width('90%')
        .barMode(BarMode.Fixed)
        .barHeight(48)
        .barWidth('100%')
        .barBackgroundColor('#1a1a1a')
        .onChange((index: number) => {
          this.currentTabIndex = index
          console.log('标签页切换:', index)
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#131215')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}