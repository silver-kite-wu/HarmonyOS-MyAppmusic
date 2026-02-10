import { my_page } from '../components/my_page'

@Entry
@Component
struct MyRedirect {
  build() {
    Column() {
      my_page()
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .backgroundColor('#131215')
  }
}
