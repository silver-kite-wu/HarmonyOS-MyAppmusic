import { router } from '@kit.ArkUI';

@Entry
@Component
struct Sex_page {
  @StorageLink('sex') private sex: string = '';

  // 处理性别选择
  private handleGenderSelect(gender: string) {
    this.sex = gender;
  }

  // 保存并返回
  private saveAndBack() {
    router.back();
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

        Text('选择性别')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .margin({left:'30%'})
          .textAlign(TextAlign.Center)

        // Button('保存', { type: ButtonType.Normal })
        //   .fontColor('#1890FF')
        //   .backgroundColor(Color.Transparent)
        //   .margin({ right: 16,left:'20%' })
        //   .onClick(() => this.saveAndBack())
      }
      .height(56)
      .width('100%')
      .shadow({ radius: 2, color: Color.Gray, offsetX: 0, offsetY: 1 })

      // 内容区域
      Column({ space: 40 }) {
        // 男性选项
        Column() {
          Row({ space: 15 }) {
            Checkbox({ name: 'nan', group: 'genderGroup' })
              .selectedColor('#1890FF') // 使用主题蓝色
              .shape(CheckBoxShape.CIRCLE) // 圆形更符合性别选择
              .select(this.sex === '男')
              .onChange((checked: boolean) => {
                if (checked) this.handleGenderSelect('男');
              })
              .size({ width: 30, height: 30 })

            Text('男')
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.sex === '男' ? '#1890FF' : '#333333')
          }
          .padding(15)
          .backgroundColor(this.sex === '男' ? '#E6F7FF' : '#F5F5F5')
          .borderRadius(12)
          .width('80%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)

        // 女性选项
        Column() {
          Row({ space: 15 }) {
            Checkbox({ name: 'nv', group: 'genderGroup' })
              .selectedColor('#FF6B81') // 使用粉色区分
              .shape(CheckBoxShape.CIRCLE)
              .select(this.sex === '女')
              .onChange((checked: boolean) => {
                if (checked) this.handleGenderSelect('女');
              })
              .size({ width: 30, height: 30 })

            Text('女')
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.sex === '女' ? '#FF6B81' : '#333333')
          }
          .padding(15)
          .backgroundColor(this.sex === '女' ? '#FFECEC' : '#F5F5F5')
          .borderRadius(12)
          .width('80%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ top: 40 })
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