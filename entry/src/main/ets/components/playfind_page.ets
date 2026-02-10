//发现
import { songlist, songtype } from '../data/music'
import router from '@ohos.router'
import avplayerClass from '../services/avplayermanager'

@Component
export struct find_page {
  @LocalStorageLink('playindex')playindex:number=0
  build() {
    Column({ space: 10 }) {
      Text('全部音乐')
        .fontSize(24)
        .fontWeight(700)
        .fontColor('#fff')
        .margin({ bottom: 10 })

      List({ space: 10 }) {
        ForEach(songlist, (item: songtype, index: number) => {
          ListItem() {
            Row({ space: 10 }) {
              Text(`${index + 1}`)
                .width('10%')
                .fontSize(18)
                .fontWeight(700)
                .fontColor('#fff')
                .textAlign(TextAlign.Center)
                .padding(5)

              Image(item.img)
                .width(50)
                .height(50)
                .borderRadius(8)
                .objectFit(ImageFit.Cover)

              Column() {
                Text(item.name)
                  .fontSize(18)
                  .fontColor('#fff')
                  .fontWeight(500)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                Text(item.author)
                  .fontSize(12)
                  .fontColor('#aaa')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .layoutWeight(1)
              .margin({ left: 10 })
            }
            .padding(10)
            .borderRadius(10)
            .backgroundColor('#ffa99a41')
            .width('100%')
            .onClick(async () => {
              this.playindex = index
              await avplayerClass.singplay(item)
              router.pushUrl({ url: 'pages/Playnow' })
            })
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .radialGradient({
      center: ['90%', '-10%'],
      radius: '150%',
      colors: [
        ['#ffab884c', 0.2],
        [Color.Transparent, 1]
      ]
    })
    .height('100%')
    .width('100%')
    .padding(16)
  }
}