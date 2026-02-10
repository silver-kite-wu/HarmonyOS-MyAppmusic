import { router } from '@kit.ArkUI';
import { allRegions, hotCities, RegionItem, generateRegionDataSource } from '../data/address_data';

@Entry
@Component
struct Address_page {
  @StorageLink('address') address: string = '';
  @State selectedAddress: string = this.address || '北京市'; // 默认值
  @State searchText: string = '';
  @State showAll: boolean = true; // 控制显示全部地区或搜索结果
  @State debounceTimer: number = 0; // 防抖计时器
  @State hasSearchResults: boolean = true; // 新增：跟踪是否有搜索结果

  // 获取筛选后的地区列表
  private filteredRegions(): string[] {
    if (!this.searchText) return allRegions;

    const searchTextLower = this.searchText.toLowerCase();
    return allRegions.filter(region =>
    region.toLowerCase().includes(searchTextLower)
    );
  }

  // 创建符合列表要求的数据源
  private regionDataSource(): RegionItem[] {
    const regions = this.showAll ? allRegions : this.filteredRegions();

    // 更新搜索结果状态
    this.hasSearchResults = regions.length > 0 || this.showAll;

    return generateRegionDataSource(regions);
  }

  // 搜索输入处理函数 (带防抖)
  private handleSearchInput(value: string) {
    this.searchText = value;
    // 清除之前的计时器
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer);
    }

    // 使用精确的 setTimeout 类型
    this.debounceTimer = setTimeout(() => {
      const hasResults = this.filteredRegions().length > 0;
      this.showAll = value === '';
      this.hasSearchResults = value === '' || hasResults;
    }, 300);
  }

  build() {
    Column({ space: 10 }) {
      // 顶部导航栏
      Row() {
        Image($r('app.media.back'))
          .width(24)
          .height(24)
          .margin({ left: 12 })
          .onClick(() => router.back())

        Text('选择地区')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({left:'30%'})
          .textAlign(TextAlign.Center)

        Button('保存', { type: ButtonType.Normal })
          .margin({ right: 16,left:'20%' })
          .fontColor('#1890FF')
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.address = this.selectedAddress;
            router.back();
          })
      }
      .height(56)
      .width('100%')
      .backgroundColor(Color.White)
      .shadow({ radius: 2, color: Color.Gray, offsetX: 0, offsetY: 1 })

      // 搜索区域
      Row() {
        Image($r('app.media.bianji'))
          .width(20)
          .height(20)
          .margin({ left: 16 })

        TextInput({ placeholder: '搜索地区', text: this.searchText })
          .placeholderColor('#BFBFBF')
          .placeholderFont({ size: 16 })
          .fontSize(16)
          .height(40)
          .margin({ left: 8 })
          .layoutWeight(1)
          .onChange((value: string) => {
            this.handleSearchInput(value);
          })

        if (this.searchText) {
          Image($r('app.media.main_input'))
            .width(16)
            .height(16)
            .margin({ right: 16 })
            .onClick(() => {
              this.searchText = '';
              this.showAll = true;
              this.hasSearchResults = true;
            })
        }
      }
      .width('92%')
      .height(44)
      .backgroundColor('#F5F5F5')
      .borderRadius(22)
      .margin({ top: 12, bottom: 8 })

      // 热门城市标签 - 只在显示全部时展示
      if (this.showAll) {
        Text('热门城市')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 16, top: 12, bottom: 8 })
          .align(Alignment.Start)

        // 热门城市快捷选择
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(hotCities, (city: string) => {
            Button(city, { type: ButtonType.Normal })
              .padding({ left: 16, right: 16, top: 6, bottom: 6 })
              .backgroundColor(this.selectedAddress === city ? '#E6F7FF' : '#F5F5F5')
              .borderColor(this.selectedAddress === city ? '#1890FF' : '#F5F5F5')
              .borderRadius(16)
              .fontColor(this.selectedAddress === city ? '#1890FF' : '#595959')
              .margin({ right: 12, bottom: 12 })
              .onClick(() => {
                this.selectedAddress = city;
              })
          }, (city: string) => city)
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
      }

      // 地区列表标题 - 只在有结果时显示
      if (this.hasSearchResults) {
        Row() {
          Text(this.showAll ? '全部地区' : '搜索结果')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)

          Text(`(${this.showAll ? allRegions.length : this.filteredRegions().length}个地区)`)
            .fontSize(14)
            .fontColor('#8C8C8C')
            .margin({ left: 8 })
        }
        .width('100%')
        .padding({ left: 16, top: 12, bottom: 8 })
        .alignItems(VerticalAlign.Center)
      }

      // 地区列表 - 只在有结果时显示
      if (this.hasSearchResults) {
        List({ space: 8 }) {
          ForEach(this.regionDataSource(), (item: RegionItem) => {
            ListItem() {
              Row() {
                Text(item.value)
                  .fontSize(16)
                  .layoutWeight(1)

                if (this.selectedAddress === item.value) {
                  Image($r('app.media.dingwei'))
                    .width(20)
                    .height(20)
                    .margin({ right: 16 })
                }
              }
              .width('100%')
              .padding({ left: 16, top: 14, bottom: 14 })
              .onClick(() => {
                this.selectedAddress = item.value;
              })
            }
            .key(item.id)
            .borderRadius(8)
            .backgroundColor(
              this.selectedAddress === item.value ? '#E6F7FF' : Color.White
            )
          }, (item: RegionItem) => item.id)
        }
        .width('100%')
        .layoutWeight(1)
        .divider({ strokeWidth: 1, color: '#F0F0F0' })
        .scrollBar(BarState.Off)
      }

      // 空状态提示 - 当没有搜索结果时显示
      if (!this.showAll && !this.hasSearchResults) {
        Column() {
          Image($r('app.media.no_data')) // 添加一个无数据图标
            .width(100)
            .height(100)
            .margin({ bottom: 16 })

          Text('没有找到匹配的地区')
            .fontSize(18)
            .fontColor('#8C8C8C')
            .margin({ bottom: 8 })

          Text(`未搜索到"${this.searchText}"相关区域`)
            .fontSize(14)
            .fontColor('#BFBFBF')
        }
        .width('100%')
        .height('60%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
    .padding({ bottom: 8 })
    .onDisAppear(() => {
      if (this.debounceTimer) {
        clearTimeout(this.debounceTimer);
      }
    })
  }
}