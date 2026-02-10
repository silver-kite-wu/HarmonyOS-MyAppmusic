import { router } from '@kit.ArkUI';

function isValidChinesePhoneNumber(phoneNumber: string): boolean {
  // 1. 基础格式验证
  if (typeof phoneNumber !== 'string') return false;

  // 2. 去除可能的空格和特殊字符
  const cleanedPhone = phoneNumber.replace(/[\s\-()]/g, '');

  // 3. 验证长度和组成
  if (cleanedPhone.length !== 11) return false;
  if (!/^\d+$/.test(cleanedPhone)) return false;

  // 4. 验证号段（2023年中国大陆最新号段）
  const validPrefixes = [
  // 中国移动
    '134', '135', '136', '137', '138', '139',
    '144', // 物联网号段
    '147', // 卫星通信
    '148', // 物联网
    '150', '151', '152', '157', '158', '159',
    '165', // 虚拟运营商
    '172', '178',
    '182', '183', '184', '187', '188', '195',
    '197', '198',

    // 中国联通
    '130', '131', '132',
    '145', // 物联网
    '146', // 物联网
    '155', '156',
    '166', // 虚拟运营商
    '175', '176',
    '185', '186', '196',

    // 中国电信
    '133',
    '149', // 物联网
    '153',
    '162', // 虚拟运营商
    '173', '177', '179',
    '180', '181', '189', '190', '191', '193', '199',

    // 中国广电
    '192'
  ];

  // 5. 检查前三位是否在有效号段中
  const prefix = cleanedPhone.substring(0, 3);
  return validPrefixes.includes(prefix);
}

@Entry
@Component
struct Num_page {
  @StorageLink('num') private num: string = '';

  @State private inputValue: string = this.num || '';
  @State private inputStatus: 'default' | 'success' | 'error' = 'default';
  @State private statusMessage: string = '请输入11位手机号码';
  @State private formattedPhone: string = '';

  // 处理输入变化
  private handleInputChange(value: string) {
    this.inputValue = value;

    if (!value) {
      this.inputStatus = 'default';
      this.statusMessage = '请输入11位手机号码';
      return;
    }

    // 限制输入为数字
    const cleanedValue = value.replace(/[^\d]/g, '');
    if (cleanedValue !== value) {
      this.inputValue = cleanedValue;
    }

    // 验证手机号
    if (isValidChinesePhoneNumber(cleanedValue)) {
      this.inputStatus = 'success';
      this.statusMessage = '手机号码格式正确';
      this.formattedPhone = this.formatPhoneNumber(cleanedValue);
    } else if (cleanedValue.length === 11) {
      this.inputStatus = 'error';
      this.statusMessage = '无效的手机号码，请检查';
    } else {
      this.inputStatus = 'default';
      this.statusMessage = `已输入 ${cleanedValue.length}/11 位`;
    }
  }

  // 格式化手机号码为 3-4-4 格式
  private formatPhoneNumber(phone: string): string {
    return `${phone.substring(0, 3)}-${phone.substring(3, 7)}-${phone.substring(7, 11)}`;
  }

  // 保存手机号码
  private savePhoneNumber() {
    if (isValidChinesePhoneNumber(this.inputValue)) {
      this.num = this.inputValue;
      router.back();
    } else {
      this.inputStatus = 'error';
      this.statusMessage = '请输入有效的手机号码';
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

        Text('更换号码')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .margin({left:'30%'})
          .textAlign(TextAlign.Center)

        Button('保存', { type: ButtonType.Normal })
          .fontColor('#1890FF')
          .backgroundColor(Color.Transparent)
          .margin({ right: 16 ,left:'20%'})
          .onClick(() => this.savePhoneNumber())
      }
      .height(56)
      .width('100%')
      .shadow({ radius: 2, color: Color.Gray, offsetX: 0, offsetY: 1 })

      // 内容区域
      Column({ space: 20 }) {
        // 输入区域
        Column() {
          Row() {
            Image($r('app.media.bianji'))
              .width(20)
              .margin({ left: 16 })
              .fillColor('#666666')

            TextInput({
              placeholder: '请输入11位手机号码',
              text: this.inputValue
            })
              .placeholderFont({ size: 16 })
              .placeholderColor('#999999')
              .fontSize(18)
              .fontColor('#333333')
              .backgroundColor(Color.Transparent)
              .margin({ left: 12, right: 16 })
              .layoutWeight(1)
              .type(InputType.Number) // 限制输入为数字
              .maxLength(11) // 限制最大长度为11
              .onChange((value: string) => this.handleInputChange(value))
          }
          .height(44)

          // 状态指示器
          Stack({ alignContent: Alignment.Center }) {
            Divider()
              .strokeWidth(1)
              .color(this.inputStatus === 'success' ? '#52C41A' :
                this.inputStatus === 'error' ? '#FF4D4F' : '#ffffffff')
              .width('92%')
          }
          .width('100%')
          .height(1)
          .margin({ top: 4 })
        }
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .margin({ top: 30, left: 16, right: 16 })
        .padding({ top: 8, bottom: 8 })

        // 状态消息
        Text(this.statusMessage)
          .fontSize(14)
          .fontColor(this.inputStatus === 'success' ? '#52C41A' :
            this.inputStatus === 'error' ? '#FF4D4F' : '#FFFFFF')
          .margin({ left: 40, right: 16, top: 8 })
          .textAlign(TextAlign.Start)
          .width('100%')

        // 格式化显示
        if (this.inputStatus === 'success' && this.formattedPhone) {
          Text(`格式: ${this.formattedPhone}`)
            .fontSize(16)
            .fontColor('#333333')
            .margin({ top: 16, left: 24 })
            .align(Alignment.Start)
        }

        // 提示信息
        Column({ space: 8 }) {
          Text('手机号码格式要求:')
            .fontSize(16)
            .fontColor('#333333')
            .margin({ bottom: 8 })

          Row() {
            Text('•')
              .margin({ right: 8 })
            Text('必须是11位数字')
              .fontSize(14)
              .fontColor('#666666')
          }
          .margin({ left: 8 })

          Row() {
            Text('•')
              .margin({ right: 8 })
            Text('支持中国移动、联通、电信和广电')
              .fontSize(14)
              .fontColor('#666666')
          }
          .margin({ left: 8 })

          Row() {
            Text('•')
              .margin({ right: 8 })
            Text('将保存为纯数字格式')
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
      .padding({ top: 16 })
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