import { AlertDialog, ConfirmDialog, LoadingDialog, SelectDialog } from '@ohos.arkui.advanced.Dialog'
import { router } from '@kit.ArkUI'

@Entry
@Component
struct Login_page {
  @StorageLink('mainindex') mainindex:boolean=false
  @StorageLink('isLogin') isLogin:boolean=false
  @StorageLink('selectMineAfterLogin') selectMineAfterLogin:boolean=false
  @State account: string = ''//账号
  @State password: string = ''//密码
  @State showPwd: boolean = false
  @State loading: boolean = false
  @State error: string = ''
  @State ischoose:boolean=false
  dialogControllerProgress: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle:'《音悦听用户服务协议》',
      content: '一、协议概述​\n' +
        '协议主体：本协议由 [音乐软件运营主体全称]（以下简称 “我们” 或 “平台”）与使用本软件及相关服务的用户（以下简称 “您”）共同缔结。​\n' +
        '协议效力：本协议是您与平台之间关于使用 [音乐软件名称]（以下简称 “本软件”）及相关服务所订立的具有法律约束力的契约。您下载、安装、注册、登录或使用本软件及服务，即表示您已充分阅读、理解并同意本协议全部条款。​\n' +
        '关联文件：本协议的附件、平台公示的《隐私政策》及其他专项规则（如付费服务条款、活动规则等）均为本协议不可分割的组成部分，与本协议具有同等法律效力。若您使用本软件特定服务，应同时遵守相应专项规则。​\n' +
        '二、服务内容与范围​\n' +
        '核心服务：平台为您提供音乐播放（在线播放、离线缓存）、音乐收藏、歌单创建与分享、个性化推荐、音乐搜索等核心服务，具体服务内容以本软件实际展示为准。​\n' +
        '增值服务：平台可根据运营需求提供付费会员、数字专辑购买、直播互动、音乐人入驻等增值服务，您选择使用增值服务时，需遵守相应的付费规则及服务说明。​\n' +
        '服务变更与终止：平台有权根据技术发展、法律法规调整或运营规划，对服务内容进行优化、变更或暂停部分服务，并将通过本软件弹窗、公告等合理方式通知您。若服务终止，平台将依法对您的合法权益予以保障（如退还未到期的付费服务费用）。​\n' +
        '三、账号注册与管理​\n' +
        '注册资格：您需年满 16 周岁且具备完全民事行为能力方可注册账号。若您为 16 周岁以下未成年人，应在监护人陪同下阅读本协议并取得监护人同意后，方可使用本软件及服务。​\n' +
        '注册信息：您注册账号时应提供真实、准确、完整的信息（如手机号码、电子邮箱等），并及时更新信息以保持其有效性。因您提供虚假信息导致的账号异常、服务无法使用等后果，由您自行承担。​\n' +
        '账号归属：账号的所有权归平台所有，您仅享有账号的使用权，且该使用权仅限您本人行使，不得转借、出租、赠与、买卖或抵押账号，也不得利用账号从事任何违法活动。​\n' +
        '账号安全：您应妥善保管账号及密码等身份凭证，对账号下的所有操作行为负责。若发现账号被盗用、异常登录等情况，应立即联系平台客服并按指引处理，平台将在合理范围内协助您找回账号，但不承担因您自身保管不善导致的损失。​\n' +
        '四、用户使用规范​\n' +
        '合法使用义务：您在使用本软件及服务时，应遵守国家法律法规、公序良俗及本协议约定，不得利用本软件从事任何违法违规行为，包括但不限于：​\n' +
        '传播含有淫秽、色情、暴力、恐怖、仇恨、反动等违法或违背公序良俗的内容；​\n' +
        '侵犯他人知识产权、肖像权、隐私权等合法权益；​\n' +
        '未经授权传播、复制、改编平台提供的音乐内容或软件程序；​\n' +
        '利用技术手段恶意刷量、篡改数据、干扰软件正常运行或侵犯其他用户权益；​\n' +
        '发布虚假信息、实施诈骗或诱导他人进行不合理消费。​\n' +
        '内容上传规范：若您通过本软件上传歌单、评论、翻唱作品等内容，应确保内容为您原创或已获得合法授权，且不违反法律法规及本协议约定。平台有权对上传内容进行审核，对违规内容予以删除、屏蔽，并视情节对账号采取限制功能、封禁等措施。​\n' +
        '权限使用：您同意平台根据服务需求获取您的设备权限（如存储权限用于离线缓存、位置权限用于本地化推荐等），您可通过设备设置自行开启或关闭权限，但关闭必要权限可能导致部分服务无法正常使用。​\n' +
        '五、知识产权​\n' +
        '平台知识产权：本软件的名称、Logo、界面设计、程序代码及平台提供的音乐内容（包括音频、歌词、封面等）均归平台或相关权利人所有，受《中华人民共和国著作权法》《商标法》等法律法规保护。未经平台或相关权利人书面许可，您不得擅自复制、传播、改编、商业使用上述知识产权成果。​\n' +
        '用户知识产权：您上传的原创内容（如原创歌单、翻唱作品等）的知识产权归您所有，但您同意授予平台非独占、免费、可转授权的使用权，平台可在服务范围内使用该内容（如展示、推荐、传播等）。​\n' +
        '侵权投诉：若您认为平台内容或其他用户上传的内容侵犯了您的知识产权，可通过本协议预留的联系方式向平台提交投诉材料，平台将在收到投诉后及时核查处理，并将结果反馈给您。​\n' +
        '六、付费服务条款​\n' +
        '费用说明：增值服务的费用标准由平台公示，平台有权根据运营情况调整费用，但会提前通知您。您通过本软件购买增值服务时，应仔细确认费用金额及服务内容，支付完成即视为您同意购买该服务。​\n' +
        '服务期限：付费服务的期限自您支付完成之日起计算，具体以订单显示为准。服务期限内，您可享受相应的增值服务权益，逾期未使用的权益将自动失效，不予折现或退还。​\n' +
        '退款规则：除法律法规另有规定或服务存在重大缺陷外，已购买的增值服务不予退款。若因平台原因导致您无法使用付费服务，平台将根据实际情况退还相应费用或延长服务期限。​\n' +
        '七、免责条款​\n' +
        '平台仅提供音乐播放及相关技术服务，对用户上传内容的真实性、合法性不承担保证责任，若因用户上传违规内容导致的纠纷，由上传用户自行承担责任。​\n' +
        '因不可抗力（如自然灾害、战争、政策调整等）、第三方服务故障（如网络运营商中断服务、支付平台异常等）或技术升级等非平台可控因素，导致本软件无法正常提供服务的，平台不承担违约责任，但会尽力协助解决问题并及时通知您。​\n' +
        '您理解并同意，平台对因您自身操作失误、设备故障、网络安全问题或未遵守本协议约定导致的损失（如账号被盗、内容丢失等）不承担责任。​\n' +
        '八、协议的变更与终止​\n' +
        '协议变更：平台有权根据法律法规变化或服务调整，对本协议进行修改。修改后的协议将在本软件显著位置公示，并通过弹窗、推送等方式通知您。若您在公示期满后继续使用本软件，即视为同意变更后的协议；若您不同意，可停止使用本软件及服务。​\n' +
        '协议终止：​\n' +
        '您可随时注销账号，账号注销后本协议自动终止，平台将按《隐私政策》约定处理您的个人信息；​\n' +
        '若您严重违反本协议约定，平台有权单方面终止协议，封禁账号并停止提供服务，且不承担任何赔偿责任；​\n' +
        '若平台停止运营，将提前 30 日在本软件公示，协议自公示的终止日期起失效。​\n' +
        '九、争议解决与适用法律​\n' +
        '适用法律：本协议的订立、履行、解释及争议解决均适用《中华人民共和国民法典》《中华人民共和国著作权法》等中华人民共和国法律法规（不包括港澳台地区法律）。​\n' +
        '争议解决：若您与平台之间发生争议，应首先通过友好协商解决；协商不成的，任何一方均有权向平台所在地有管辖权的人民法院提起诉讼。​\n' +
        '十、其他​\n' +
        '本协议中的标题仅为方便阅读而设置，不影响条款的解释与效力。​\n' +
        '若本协议任何条款被认定为无效或不可执行，不影响其他条款的效力。​\n' +
        '您对本协议有任何疑问，可通过以下方式联系我们：​\n' +
        '客服电话：[16666666666]​\n' +
        '电子邮箱：[sliver@qq.com]​\n' +
        '联系地址：[中原工学院3号楼]​\n',
    }),

  })
  dialogControllerCheckBox: CustomDialogController = new CustomDialogController({
    builder: ConfirmDialog({
      content: '我同意《音悦听隐私政策》《音悦听用户服务协议》',
      isChecked: this.ischoose,
      checkTips: '同意后不再提示',
      primaryButton: {
        value: '不同意',
        action: () => {this.ischoose=false},
      },
      secondaryButton: {
        value: '同意',
        action: () => {
          this.ischoose = true
          console.info('Callback when the second button is clicked')
        }
      },
      onCheckedChange: () => {
        console.info('Callback when the checkbox is clicked')
      },
    }),
    autoCancel: true,
    alignment: DialogAlignment.Bottom
  })
  dialogControllerConfirm: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: '《音悦听隐私政策》',
      content: '    欢迎使用 音悦听（以下简称 “本软件”）。我们深知个人信息安全的重要性，将严格遵守相关法律法规，秉持合法、正当、必要、诚信的原则，保护您的个人信息及合法权益。本政策旨在向您说明我们如何收集、使用、存储、共享和保护您的个人信息，以及您享有的相关权利。请您仔细阅读并理解本政策，若您使用本软件，即表示您同意我们按照本政策处理您的个人信息。​\n' +
        '一、适用范围\n' +
        '    本隐私政策适用于本软件及其相关服务，包括但不限于移动端应用程序、网页端平台等。若本软件的特定服务有单独的隐私说明，该服务的隐私说明将优先适用；若未作特别说明，则适用本政策。​\n' +
        '二、信息的收集与使用​\n' +
        '（一）我们收集的信息​\n' +
        '注册与账号信息：当您注册本软件账号时，您需提供手机号码、电子邮箱等信息用于身份验证及账号创建。您也可选择通过第三方账号（如微信、QQ 等）登录，此时我们将获取您在第三方平台授权公开的信息（如昵称、头像等）。​\n' +
        '使用过程中的信息：​\n' +
        '音乐相关信息：包括您的播放历史、收藏列表、搜索记录、听歌偏好（如曲风、歌手、播放时长等），用于为您提供个性化推荐、播放记录同步等服务。​\n' +
        '设备信息：包括设备型号、操作系统版本、设备标识符（如 IMEI、Android ID 等）、网络类型、设备状态等，用于保障软件运行稳定、优化服务体验及进行安全防护。​\n' +
        '位置信息：若您开启位置权限，我们可能收集您的大致位置信息，用于提供本地化音乐推荐等服务（您可随时关闭权限，关闭后将无法使用相关服务）。​\n' +
        '其他主动提供的信息：如您参与本软件的活动、反馈问题时，主动向我们提供的姓名、联系方式、意见建议等信息。​\n' +
        '（二）信息的使用目的​\n' +
        '为您提供核心服务，包括账号管理、音乐播放、收藏与分享、个性化推荐等。​\n' +
        '保障服务安全，识别并防范欺诈、盗用等风险，维护软件及您的账号安全。​\n' +
        '优化服务体验，根据您的使用习惯和偏好改进软件功能、内容及界面设计。​\n' +
        '开展运营活动，如向您推送活动通知、福利信息等（您可通过设置关闭相关推送）。​\n' +
        '处理您的咨询与投诉，为您提供售后服务与技术支持。​\n' +
        '三、信息的存储​\n' +
        '存储地点：我们将您的个人信息存储在中国大陆境内符合安全标准的服务器上，如需向境外传输，我们将依法获得您的授权并采取加密等安全措施。​\n' +
        '存储期限：我们将在实现本政策所述目的的必要期限内存储您的个人信息，超出期限后，将依法予以删除或匿名化处理。若您注销账号，我们将及时删除您的相关个人信息（法律法规另有规定的除外）。​\n' +
        '存储安全：我们采用加密技术、访问控制、安全审计等多种安全措施，建立完善的信息安全管理体系，防止您的个人信息被泄露、篡改、丢失或滥用。但请您注意，互联网环境并非绝对安全，我们无法完全规避因不可抗力、黑客攻击等非我们可控因素导致的信息风险。​\n' +
        '四、信息的共享与披露​\n' +
        '（一）共享​\n' +
        '我们不会未经您的授权向第三方共享您的个人信息，但下列情形除外：​\n' +
        '获得您明确同意后，向授权的第三方共享。​\n' +
        '为提供您所需的服务，与合作服务商共享必要信息（如支付服务提供商需获取您的订单信息完成支付），且我们会对合作服务商进行严格筛选与监管，要求其按照约定处理信息并承担保密义务。​\n' +
        '根据法律法规规定、司法机关或行政主管部门的合法要求，向相关部门提供。​\n' +
        '为维护本软件的合法权益、用户利益或公共利益，在合理范围内共享。​\n' +
        '（二）披露​\n' +
        '我们不会公开披露您的个人信息，除非获得您的明确同意或符合法律法规的强制性要求。如需披露，我们将采取脱敏处理等方式保护您的隐私安全。​\n' +
        '五、您的权利​\n' +
        '查询与更正：您可通过本软件的 “个人中心” 等相关功能，查询或更正您的账号信息、个人偏好等内容。​\n' +
        '删除与注销：若您认为我们收集的信息超出必要范围或存在错误，可联系我们申请删除；您也可通过软件内指引注销账号，账号注销后，我们将按规定删除您的个人信息。​\n' +
        '撤回同意：您可通过设备设置或软件内功能，撤回对位置、存储等权限的授权，撤回后我们将不再收集相应信息，但可能影响部分服务的正常使用。​\n' +
        '投诉与建议：若您对个人信息处理有异议或疑问，可通过本政策预留的联系方式与我们沟通，我们将在 15 个工作日内予以答复。​\n' +
        '六、Cookie 及同类技术的使用​\n' +
        '为优化服务体验，本软件可能使用 Cookie、本地存储等技术，记录您的登录状态、听歌偏好等信息，帮助您快速访问软件、获得个性化服务。您可通过浏览器或设备设置清除相关数据，但可能导致部分功能无法正常使用。​\n' +
        '七、政策的更新与通知​\n' +
        '我们将根据法律法规变化及服务调整，适时更新本隐私政策。更新后的政策将在本软件显著位置公示，并通过弹窗、推送等方式通知您。若您继续使用本软件，即表示同意更新后的政策；若您不同意，可停止使用本软件。​\n' +
        '八、联系我们​\n' +
        '如您对本隐私政策或个人信息保护有任何疑问、投诉或建议，可通过以下方式联系我们：​\n' +
        '客服电话：[16666666666]​\n' +
        '电子邮箱：[sliver@qq.com]​\n' +
        '联系地址：[中原工学院3号楼]',
    }),
  })
  private validate(): boolean {
    this.error = ''
    if (!this.account || this.account.trim().length === 0) {
      this.error = '请输入账号'
      return false
    }
    if (!this.password || this.password.trim().length < 6) {
      this.error = '密码不少于6位'
      return false
    }
    return true
  }

  private async doLogin() {
    if (!this.validate()) { return }
    this.loading = true
    try {
      // 标记登录成功并持久化
      this.isLogin = true
      this.mainindex = true
      // 设置一次性回到“我的”的标志，主页面 onPageShow 会切换到“我的”
      this.selectMineAfterLogin = true
      // 模拟登录耗时
      setTimeout(() => {
        this.loading = false
        // 返回到来源页（我的标签页），此时 UI 将根据 isLogin 显示正常
        router.back()
        this.error = ''
      }, 1200)
    } catch (e) {
      this.loading = false
      this.error = '登录失败，请重试'
    }
  }

  build() {
    Column() {
      // 顶部返回按钮
      Row() {
        Text('< 返回')
          .fontSize(16)
          .fontColor('#3274f6')
          .onClick(()=>{
            // 返回到上一个页面（例如“我的”未登录占位）
            router.back()
          })
      }
      .width('100%')
      .height(44)
      .alignItems(VerticalAlign.Center)
      .padding({ left: 12 })
      .margin({ top: 6, bottom: 6 })
      Image($r('app.media.startIcon'))
        .width(200)
        .borderRadius(40)
      // 标题
      Text('登录')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.Black)
        .opacity(0.95)
        .margin({ top: 36, bottom: 12 })

      Text('欢迎回来，开启音乐之旅!')
        .fontSize(14)
        .fontColor('#ff79e3c9')
        .opacity(0.9)
        .margin({ bottom: 24 })
      AlertDialog()
      // 表单卡片
      Column() {
        Row(){
          Text('账号：')
            .fontColor(Color.Black)
            .fontWeight(500)
            .fontSize(18)
            .textAlign(TextAlign.Center)
            .margin({ right: 8 })
          TextInput({ placeholder: '请输入账号' ,text:this.account})
            .maxLength(12)
            .placeholderColor(Color.Gray)
            .fontColor(Color.Black)
            .caretColor(Color.Black)
            .height(44)
            .backgroundColor('#f2f3f5')
            .border({ width: 1, color: Color.Gray })
            .borderRadius(12)
            .padding({ left: 14, right: 14 })
            .layoutWeight(1)
            .onChange((v: string) => {
              if (v.length===12) {
                this.error='账户不得超过12个字符！'
              }
              this.account = v })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Start)
        .margin({bottom:10})

        Row(){
          // 密码
          Text('密码：')
            .fontColor(Color.Black)
            .fontWeight(500)
            .fontSize(18)
            .textAlign(TextAlign.Center)
            .margin({ right: 8 })
          TextInput({ placeholder: '请输入密码',text:this.password })
            .maxLength(18)
            .showPasswordIcon(false)
            .placeholderColor(Color.Gray)
            .fontColor(Color.Black)
            .caretColor(Color.Black)
            .type(this.showPwd ? InputType.Normal : InputType.Password)
            .height(44)
            .backgroundColor('#f2f3f5')
            .border({ width: 1, color: Color.Gray })
            .borderRadius(12)
            .padding({ left: 14, right: 14 })
            .layoutWeight(1)
            .onChange((v: string) => { this.password = v })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)
        .margin({bottom:10})
        Row(){
          Checkbox()
            .select(this.ischoose)
            .onClick(()=>{this.ischoose=!this.ischoose})
            .width(10)
            .margin({bottom:20,right:10})
          Text(){
            Span('我已经阅读并同意 ')
            Span('《音悦听隐私政策》').fontColor('#3274f6')
              .onClick(()=>{
                this.dialogControllerConfirm.open()
              })
            Span('《音悦听用户服务协议》').fontColor('#3274f6')
              .onClick(()=>{
                this.dialogControllerProgress.open()
              })
          }
          .margin({right:2})
          .layoutWeight(1)
          .fontSize(12)
          .lineHeight(20)
          .fontColor('#666')
        }
        .width('100%')
        // 错误提示
        if (this.error) {
          Row() {
            Text(this.error)
              .fontColor('#ff6b6b')
              .fontSize(13)
          }
          .margin({ top: 12 })
        }

        // 登录按钮
        Button(this.loading ? '登录中…' : '登录')
          .height(46)
          .backgroundColor('#ffab884c')
          .fontColor(Color.Black)
          .fontSize(16)
          .borderRadius(14)
          .margin({ top: 22 })
          .enabled(!this.loading)
          .onClick(() => {
            if (!this.ischoose) {
              this.dialogControllerCheckBox.open()
              return
            }
            if (this.password.length<6){
              this.error='密码过短，要求密码至少未6位！'
            }
            if (this.account === 'admin' && this.password === '123456') {
              this.doLogin()
            } else {
              this.error = '账号或密码错误！请重试！'
            }
          })

        // 辅助链接
        // Row() {
        //   Text('忘记密码 ')
        //     .fontColor('#ff529ee0')
        //     .fontSize(13)
        //     .onClick(() => {})
        //   Blank(20)
        //   Text(' 没有账号？去注册')
        //     .fontColor('#ff529ee0')
        //     .fontSize(13)
        //     .onClick(() => {})
        // }
        // .margin({ top: 160 })
      }
      .width('100%')
      .padding(18)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
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