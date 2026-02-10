/*
author:wuzheng
* time:2025/8/7
* log:完
 */
// 跳转页面入口函数
@Builder
export function startBuilder() {
  StartPage();
}

@Component
struct StartPage {
  pathStack: NavPathStack = new NavPathStack();
  @State hasSkipped: boolean = false;
  private timeoutId: number = 0;

  aboutToAppear(): void {
    this.timeoutId = setTimeout(() => {//延时函数
      if (!this.hasSkipped) {
        this.pathStack.replacePathByName("main", null, false);
      }
    }, 3000);
  }

  aboutToDisappear(): void {
    if (this.timeoutId) {
      clearTimeout(this.timeoutId);
      this.timeoutId = 0;
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopEnd }) {
        Image($r('app.media.backgroundpicture'))
          .width('100%')
          .height('100%')
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        Button('跳过')
          .backgroundColor(Color.Gray)
          .margin(15)
          .onClick(() => {
            this.hasSkipped = true;
            if (this.timeoutId) {
              clearTimeout(this.timeoutId);
              this.timeoutId = 0;
            }
            this.pathStack.replacePathByName("main", null, false);
          })
      }
    }
    //.title('广告页')
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
  }
}