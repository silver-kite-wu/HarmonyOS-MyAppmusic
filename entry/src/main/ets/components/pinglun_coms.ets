//评论-自定义组件
/*
author:wuzheng
* time:2025/8/10
* log:完成
 */
import { Comment } from "../data/pinglundata"

@Extend(Button)
function button_f(ison: boolean) {
  .width(46)
  .backgroundColor(ison ? '#fff' : '#F7F8FA')
  .border({ width: 1, color: ison ? '#e4e5e6' : '#F7F8FA' })
  .height(32)
  .fontSize(12)
  .padding({ left: 5, right: 5 })
  .fontColor(ison ? '#2f2e33' : '#8e9298')
}

@Component
export struct infotop {
  @State ison: boolean = true
  onsort=(type:number)=>{}
  build() {
    Row() {
      Text('全部评论')
        .fontColor('#ffffffff')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)

      Row() {
        Button('最新', { stateEffect: false })
          .onClick(() => {
            this.ison = true
            this.onsort(0)
          })
          .button_f(this.ison)

        Button('最热', { stateEffect: false })
          .onClick(() => {
            this.ison = false
            this.onsort(1)
          })
          .button_f(!this.ison)
      }
      .height(35)
      .backgroundColor('#F7F8FA')
      .borderRadius(20)
    }
    .padding(16)
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
  }
}

// 定义回调接口
interface CommentCallback {
  onlike: () => void;
}

@Component
export struct infoitem {
  @Prop commentData: Comment
  @Prop callback: CommentCallback

  build() {
    Column() {
      Row() {
        Image(this.commentData.img)
          .width(30)
          .aspectRatio(1)
          .margin({ top: 10 })
          .borderRadius(15)
          .objectFit(ImageFit.Cover)

        Text(this.commentData.name)
          .fontSize(13)
          .fontColor(Color.Gray)
          .margin({ top: 10, left: 8 })

        Image(this.commentData.level)
          .width(20)
          .aspectRatio(1)
          .margin({ top: 10, left: 8 })
          .borderRadius(15)
      }
      Text(this.commentData.commenttxt)
        .fontSize(13)
        .fontColor(Color.Pink)
        .margin({ left: 40, top: 0, bottom: 8 })
      // 点赞区域
      Row() {
        Text(this.commentData.timeString)
          .fontColor(Color.Gray)
          .fontSize(11)
        Row() {
          Image(this.commentData.isLike ? $r('app.media.yidianzan') : $r('app.media.dianzan'))
            .width(15)
            .aspectRatio(1)
          Text(`${this.commentData.Likenum}`)
            .fontSize(11)
            .fontColor('#ff51c8b0')
            .margin({ left: 6 })
        }
        .width(40)
        .margin({ right: 20 })
        .onClick(() => {
          animateTo({ duration: 300 }, () => {
            this.callback.onlike() // 调用回调函数
          })
        })
      }
      .padding({ left: 40, top: 5 })
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 15, right: 15 })
  }
}

@Component
export struct infobottom {
  @State txt:string=''
  onsubcomment=(content:string)=>{}
  build() {
    Row() {
      Row() {
        Image($r('app.media.bianji'))
          .width(20)
          .margin({ left: 20 })

        TextInput({
          placeholder: '写评论..' ,
          text:$$this.txt
        })
          .fontSize(18)
          .backgroundColor(Color.Transparent)
          .onSubmit(()=>{
            this.onsubcomment(this.txt)
            this.txt=''
          })
      }
      .height(40)
      .backgroundColor('#f5f6f5')
      .borderRadius(20)
      .margin({ left: 15, right: 20, top: 10, bottom: 10 })
    }
    .height(60)
    .width('100%')
  }
}