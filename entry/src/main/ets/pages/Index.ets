import { AppStorageV2 } from '@kit.ArkUI';
/*
author:wuzheng
* time:2025/8/7
* log:完成
 */
@Entry
@Component
struct Index {
  pageStack : NavPathStack = AppStorageV2.connect(NavPathStack,'navStack',()=>new NavPathStack())!

  build() {
    Navigation(this.pageStack){
    }.onAppear(() => {
      this.pageStack.pushPathByName("start", null, false);//跳转页面start
    })
    .hideNavBar(true)//不会把自己放到控制跳转的对象里去-》点返回不会返回这个页面
  }
}