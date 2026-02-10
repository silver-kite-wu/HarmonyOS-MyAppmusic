/*
author:wuzheng
* time:2025/8/7
* log:完
 */
import {Tabclass}from '../data/maintabdata'
import {main_page}from '../components/zhu_page'//主页
import {my_page}from '../components/my_page'//我的
import {pinglun_page}from '../components/pinglun'//评论
import {find_page}from '../components/playfind_page';//发现
import { router } from '@kit.ArkUI';

AppStorage.setOrCreate('mainindex',true)
AppStorage.setOrCreate('playindex',0)
AppStorage.SetOrCreate('touxiang','https://tse3-mm.cn.bing.net/th/id/OIP-C.EAWIumrpty4x2_YBWAhghQHaND?w=188&h=331&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3')
// 登录持久化状态与一次性回到“我的”的标志
PersistentStorage.persistProp('isLogin', false)
AppStorage.setOrCreate('selectMineAfterLogin', false)
// 跳转页面入口函数
@Builder
export function mainBuilder() {
  main();
}
@Entry
@Component
struct main {
  @State curr_index:number=0
  @StorageLink('mainindex') mainindex:boolean=true
  @StorageLink('isLogin') isLogin:boolean=false
  @StorageLink('selectMineAfterLogin') selectMineAfterLogin:boolean=false
  pathStack: NavPathStack = new NavPathStack();
  tabdata : Tabclass[] = [
  {txt:'主页',image:$r('app.media.recommend')},
  {txt:'发现',image:$r('app.media.find')},
  {txt:'评论',image:$r('app.media.pinglu')},
  {txt:'我的',image:$r('app.media.my')}
]
  @Builder tabbuilder(item:Tabclass,index:number){
    Column({space:6}){
      Image(item.image)
        .width(25)
        .fillColor(this.curr_index===index?Color.Pink:Color.Gray)
      Text(item.txt)
        .fontColor(this.curr_index===index?Color.Pink:Color.Gray)
        .fontSize(14)
    }
  }
  build() {
    NavDestination() {
      Tabs({barPosition:BarPosition.End}){
        ForEach(this.tabdata,(itme:Tabclass,index:number)=>{
          TabContent(){
            if (index===0&& this.mainindex) {
              main_page()
            }else if (index===1&&this.mainindex){
              find_page()
            }else if(index===2&&this.mainindex){
              pinglun_page()
            }else {
              // 始终渲染我的页，内部根据登录态显示不同UI
              my_page()
            }
          }
          .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
          .backgroundColor('#131215')
          .tabBar(this.tabbuilder(itme,index))
        })
      }
      .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
      .backgroundColor('#3B3F42')
      .onChange((index:number)=>{
        if(index!=3)this.mainindex=true
        this.curr_index=index
      })
    }
    //.title('布局页')
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
  }
  aboutToAppear(){
    // 登录成功返回后，自动切到“我的”，并清除一次性标志
    if (this.selectMineAfterLogin) {
      this.curr_index = 3
      this.selectMineAfterLogin = false
    }
  }
}