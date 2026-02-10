import { router } from '@kit.ArkUI'

@Entry
@Component
struct Name_page {
  @StorageLink('name') private name: string = '';
  @State private newName: string = '';
  @State private inputError: boolean = false;
  @State private errorMessage: string = '';

  // 验证姓名是否有效
  private isValidName(name: string): boolean {
    if (!name || name.trim().length === 0) {
      this.errorMessage = '姓名不能为空';
      return false;
    }

    if (name.length > 10) {
      this.errorMessage = '姓名长度不能超过10个字符';
      return false;
    }

    // 检查是否包含非法字符
    const invalidChars = /[0-9\<\>@#\$%\^&\*\?]/;
    if (invalidChars.test(name)) {
      this.errorMessage = '姓名不能包含数字或特殊字符';
      return false;
    }

    return true;
  }

  // 保存姓名
  private saveName() {
    if (this.isValidName(this.newName)) {
      this.name = this.newName;
      router.back();
    } else {
      this.inputError = true;
      // 3秒后自动清除错误提示
      setTimeout(() => {
        this.inputError = false;
      }, 3000);
    }
  }

  build() {
    Column({ space: 10 }) {
      // 顶部导航栏
      Row() {
        Image($r('app.media.back'))
          .width(20)
          .fillColor(Color.Black)
          .margin({ left: 12 })
          .onClick(() => router.back())

        Text('更换名字')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .margin({left:'30%'})
          .textAlign(TextAlign.Center)

        Button('保存', { type: ButtonType.Normal })
          .fontColor('#1890FF')
          .backgroundColor(Color.Transparent)
          .margin({ right: 16 ,left:'20%'})
          .onClick(() => this.saveName())
      }
      .height(56)
      .width('100%')
      .shadow({ radius: 2, color: Color.Gray, offsetX: 0, offsetY: 1 })

      // 内容区域
      Column({ space: 20 }) {
        // 当前名字显示
        if (this.name) {
          Text(`当前名字: ${this.name}`)
            .fontSize(18)
            .fontColor('#666666')
            .margin({ bottom: 20 })
        }

        // 输入区域
        Column() {
          Row() {
            Image($r('app.media.bianji'))
              .width(20)
              .margin({ left: 16 })
              .fillColor('#666666')

            TextInput({
              placeholder: '请输入新名字',
              text: this.newName
            })
              .placeholderFont({ size: 16 })
              .placeholderColor('#999999')
              .fontSize(18)
              .fontColor('#333333')
              .backgroundColor(Color.Transparent)
              .margin({ left: 12, right: 16 })
              .layoutWeight(1)
              .maxLength(10) // 限制最大长度
              .onChange((value: string) => {
                this.newName = value;
                this.inputError = false;
              })
          }
          .height(44)

          // 状态指示器
          Stack({ alignContent: Alignment.Center }) {
            Divider()
              .strokeWidth(1)
              .color(this.inputError ? '#FF4D4F' : '#D9D9D9')
              .width('92%')
          }
          .width('100%')
          .height(1)
          .margin({ top: 4 })
        }
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .margin({ top: 10, left: 16, right: 16 })
        .padding({ top: 8, bottom: 8 })

        // 错误提示
        if (this.inputError) {
          Text(this.errorMessage)
            .fontSize(14)
            .fontColor('#FF4D4F')
            .margin({ top: 8, left: 24 })
            .width('100%')
            .textAlign(TextAlign.Start)
        }

        // 提示信息
        Column({ space: 8 }) {
          Text('名字格式要求:')
            .fontSize(16)
            .fontColor('#333333')
            .margin({ bottom: 8 })

          Row() {
            Text('•')
              .margin({ right: 8 })
            Text('长度不超过10个字符')
              .fontSize(14)
              .fontColor('#666666')
          }
          .margin({ left: 8 })

          Row() {
            Text('•')
              .margin({ right: 8 })
            Text('不能包含数字或特殊字符')
              .fontSize(14)
              .fontColor('#666666')
          }
          .margin({ left: 8 })
        }
        .margin({ top: 30, left: 24 })
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ top: 30 })
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .width('100%')
    .height('100%')
    .padding({ bottom: 8 })
    .radialGradient({
      center: ['90%', '-10%'],
      radius: '150%',
      colors: [
        ['#ffab884c', 0.5],
        [Color.Transparent, 1]
      ]
    })
  }
}