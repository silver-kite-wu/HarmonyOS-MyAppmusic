import { router } from '@kit.ArkUI'

@Entry
@Component
struct Age_page {
  @StorageLink('age') private age: number = 0;
  @State private currentAge: number = this.age || 0;
  @State private inputError: boolean = false;
  @State private isInputFocused: boolean = false; // 用于控制键盘状态

  // 验证年龄是否有效
  private isValidAge(age: number): boolean {
    return age > 0 && age < 120;
  }

  // 处理保存操作
  private handleSave() {
    if (this.isValidAge(this.currentAge)) {
      this.age = this.currentAge;
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

        Text('更换年龄')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .margin({left:'30%'})
          .textAlign(TextAlign.Center)
          .fontColor('#333333')

        Button('保存', { type: ButtonType.Normal })
          .fontColor('#1890FF')
          .backgroundColor(Color.Transparent)
          .margin({ right: 16,left:'20%' })
          .onClick(() => this.handleSave())
      }
      .height(56)
      .width('100%')
      .shadow({ radius: 2, color: Color.Gray, offsetX: 0, offsetY: 1 })

      // 内容区域
      Column() {
        // 输入框区域
        Column() {
          Row() {
            Image($r('app.media.bianji'))
              .width(20)
              .margin({ left: 16 })
              .fillColor('#666666')

            TextInput({
              placeholder: '请输入您的年龄',
              text: this.currentAge === 0 ? '' : this.currentAge.toString()
            })
              .placeholderFont({ size: 16 })
              .placeholderColor('#999999')
              .fontSize(18)
              .fontColor('#333333')
              .backgroundColor(Color.Transparent)
              .margin({ left: 8 })
              .layoutWeight(1)
              .type(InputType.Number)
              .maxLength(3)
              .onChange((value: string) => {
                this.inputError = false;
                this.currentAge = value ? parseInt(value) : 0;
              })
              .onEditChange((isEditing: boolean) => {
                this.isInputFocused = isEditing;
              })
          }
          .height(44)
          .borderRadius(10)
          .backgroundColor(Color.White)
          // 下划线
          Divider()
            .strokeWidth(1)
            .color('#1890FF33')
            .margin({ top: 4 })
        }
        .backgroundColor(Color.Transparent)
        .margin({ top: 30, bottom: 8 })
        .width('92%')

        // 错误提示
        if (this.inputError) {
          Text('请输入有效的年龄 (1-119)')
            .fontSize(14)
            .fontColor('#FF4D4F')
            .margin({ top: 10, left: 16 })
            .align(Alignment.Start)
            .width('92%')
        }

        // 年龄提示信息
        Text('年龄范围：1 - 119 岁')
          .fontSize(14)
          .fontColor('#ffc8bdbd')
          .margin({ top: 20, left: 16 })
          .align(Alignment.Start)
          .width('92%')
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Start)
      .onClick(() => {
        // 点击空白处收起键盘
        this.isInputFocused = false;
      })
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .width('100%')
    .height('100%')
    .padding({ bottom: 8 })
    .radialGradient({
      center:['90%','-10%'],
      radius:'150%',
      colors:[
        ['#ffab884c',0.5],
        [Color.Transparent,1]
      ]
    })
    .onClick(() => {
      // 点击空白处收起键盘
      this.isInputFocused = false;
    })
  }
}