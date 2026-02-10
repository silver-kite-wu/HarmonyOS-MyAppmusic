//主页——每日推荐数据
/*
author:wuzheng
* time:2025/8/9
* log:完成
 */
export interface dailytype{
  img:string//图
  title:string//描述
  type:string//标题
  top:string//标题背景色
  bottom:string//简介背景色
}
export const dailydatas:dailytype[]=[
  {
    img: "https://tse1-mm.cn.bing.net/th/id/OIP-C.6pksdUc73CLtAv6NEdY7AQHaEK?w=285&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3",
    title: "每日推荐 | 致回不去的校园，致那美好的曾经",
    type: "每日推荐",
    top: "#FF6B6B",      // 珊瑚红色
    bottom: "#4ECDC4"   // 蓝绿色
  },
  {
    img: "https://tse4-mm.cn.bing.net/th/id/OIP-C.QmHur5XIHx_hAyq12RQJ_wHaEH?w=288&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3",
    title: "青春经典 | 难以忘怀的青春旋律",
    type: "青春经典",
    top: "#1A535C",      // 深青蓝色
    bottom: "#FFE66D"    // 明黄色
  },
  {
    img: "https://tse4-mm.cn.bing.net/th/id/OIP-C.XGXtzljVWO78rbZRRk59dQHaEK?w=322&h=181&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3",
    title: "伤感国风小调 | 今日饮一杯愁滋味不醉不归",
    type: "流行音乐",
    top: "#6A0572",      // 深紫色
    bottom: "#9B5DE5"    // 薰衣草紫
  },
  {
    img: "https://tse4-mm.cn.bing.net/th/id/OIP-C.KdImqVdg8OyCkzCf4u50KwHaEK?w=279&h=184&c=7&r=0&o=5&dpr=1.3&pid=1.7",
    title: "清晨森林徒步，呼吸新鲜空气，聆听鸟鸣声",
    type: "森林漫游",
    top: "#2E7D32",     // 深绿色
    bottom: "#A5D6A7"   // 浅绿色
  }
]