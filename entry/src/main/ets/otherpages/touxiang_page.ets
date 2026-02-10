import { router } from '@kit.ArkUI'
import {
  PhotoPickerComponent,
  PickerController,
  PickerOptions,
  DataType,
  ItemInfo,
  ItemType,
  ClickType,
  ReminderMode,
  photoAccessHelper
} from '@kit.MediaLibraryKit'
import filePicker from '@ohos.file.picker'

@Entry
@Component
struct Touxiang_page {
  @StorageLink('touxiang') private touxiang: string = '';
  // 头像选择（图片/视频）改为使用系统相册选择器
  pickerOptions: PickerOptions = new PickerOptions();
  @State pickerController: PickerController = new PickerController();
  @State private selectUris: string[] = []

  aboutToAppear() {
    // 展示图片和视频，最多选1张（头像）
    this.pickerOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_VIDEO_TYPE
    this.pickerOptions.maxSelectNumber = 1
    this.pickerOptions.maxSelectedReminderMode = ReminderMode.TOAST
    this.pickerOptions.isSearchSupported = true
    this.pickerOptions.isPhotoTakingSupported = true
  }

  // 保存头像：优先当前预览项，否则第一个已选
  private saveAvatar() {
    const chosen: string = (this.selectUris.length > 0 ? this.selectUris[0] : '')
    if (chosen) {
      this.touxiang = chosen
      setTimeout(() => router.back(), 300)
    }
  }

  // 资源被选中回调
  private onItemClicked(itemInfo: ItemInfo, clickType: ClickType): boolean {
    if (!itemInfo) { return false }
    const type: ItemType | undefined = itemInfo.itemType
    const uri: string | undefined = itemInfo.uri
    if (type === ItemType.CAMERA) {
      return true
    }
    if (clickType === ClickType.SELECTED) {
      if (uri) {
        this.selectUris = [uri]
        this.pickerOptions.preselectedUris = [...this.selectUris]
      }
      return true
    } else {
      if (uri) {
        this.selectUris = this.selectUris.filter((u: string) => u !== uri)
        this.pickerOptions.preselectedUris = [...this.selectUris]
      }
      return true
    }
  }
  private onPickerControllerReady(): void {}

  // 使用系统相册选择器（无需在模块中声明读取权限，由系统弹窗授权）
  private async pickAvatar(): Promise<void> {
    try {
      const picker = new filePicker.PhotoViewPicker()
      const opt = new filePicker.PhotoSelectOptions()
      opt.MIMEType = filePicker.PhotoViewMIMETypes.IMAGE_TYPE
      opt.maxSelectNumber = 1
      const res = await picker.select(opt)
      const uris: string[] = (res && res.photoUris) ? res.photoUris : []
      if (uris.length > 0) {
        this.selectUris = [uris[0]]
      }
    } catch (e) {
      console.error('系统相册选择失败:', e)
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

        Text('更换头像')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .margin({left:'30%'})
          .textAlign(TextAlign.Center)

        Button('保存', { type: ButtonType.Normal })
          .fontColor('#1890FF')
          .backgroundColor(Color.Transparent)
          .margin({ right: 16,left:'20%' })
          .onClick(() => this.saveAvatar())
      }
      .height(56)
      .width('100%')
      .shadow({ radius: 2, color: Color.Gray, offsetX: 0, offsetY: 1 })

      // 内容区域
      Column({ space: 20 }) {
        // 当前头像预览
        if (this.touxiang) {
          Text('当前头像:')
            .fontSize(16)
            .fontColor('#666666')
            .align(Alignment.Start)
            .width('90%')

          Image(this.touxiang)
            .width(120)
            .height(120)
            .borderRadius(60)
            .border({ width: 2, color: '#1890FF' })
            .margin({ top: 10 })
        }

        // 新头像预览（基于相册选择）
        Text('新头像预览:')
          .fontSize(16)
          .fontColor('#666666')
          .align(Alignment.Start)
          .width('90%')
          .margin({ top: 10 })

        Image(this.selectUris.length > 0 ? this.selectUris[0] : $r('app.media.startIcon'))
          .width(120)
          .height(120)
          .borderRadius(60)
          .border({ width: 2, color: this.selectUris.length > 0 ? '#52C41A' : '#D9D9D9' })
          .margin({ top: 10 })

        // 系统相册选择按钮（推荐方式）
        Button('从相册选择')
          .width('50%')
          .height(44)
          .borderRadius(8)
          .backgroundColor('#1890FF')
          .fontColor(Color.White)
          .onClick(() => this.pickAvatar())

        // 可选：内嵌 PhotoPicker 组件（如果设备/SDK支持）
        // PhotoPickerComponent({
        //   pickerOptions: this.pickerOptions,
        //   onItemClicked: (itemInfo: ItemInfo, clickType: ClickType): boolean => this.onItemClicked(itemInfo, clickType),
        //   onPickerControllerReady: (): void => this.onPickerControllerReady(),
        //   pickerController: this.pickerController,
        // })
        // .width('100%')
        // .height('50%')

        // 预览缩略图栏 / 预览按钮
        // 已选择的缩略图
        // Row() {
        //   ForEach(this.selectUris, (uri: string) => {
        //     Image(uri).height(50).width(50).onClick(() => {
        //       this.pickerOptions.preselectedUris = [...this.selectUris]
        //       this.pickerController.setData(DataType.SET_SELECTED_URIS, this.selectUris)
        //     })
        //   }, (uri: string) => JSON.stringify(uri))
        // }
        // .alignSelf(ItemAlign.Center)
        // .margin(this.selectUris.length ? 10 : 0)
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ top: 20 })
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