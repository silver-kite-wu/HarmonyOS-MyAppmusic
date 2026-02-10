/*
author:wuzheng
* time:2025/8/7
* log:完成
 */
export interface SoftwareItem {
  name: string
  icon: string
  url: string
  description: string
}

export const software: SoftwareItem[] = [
  {
    name: "网易云音乐",
    icon: "https://ts4.tc.mm.bing.net/th/id/ODF.7PUR2hPDa8I_vbWjgVnmAg?w=32&h=32&qlt=90&pcl=fffffc&o=6&cb=thwsc4&pid=1.2",
    url: "https://music.163.com",
    description: "网易云音乐平台"
  },
  {
    name: "QQ音乐",
    icon: "https://ts4.tc.mm.bing.net/th/id/ODF.6dD7SjX-EusRW1l9Ys549Q?w=32&h=32&qlt=90&pcl=fffffc&o=6&cb=thwsc4&pid=1.2",
    url: "https://y.qq.com",
    description: "腾讯音乐平台"
  },
  {
    name: "酷狗音乐",
    icon: "https://tse2-mm.cn.bing.net/th/id/OIP-C.v2x5TVMxJIubEOefsNptTQHaHa?w=193&h=192&c=7&r=0&o=5&dpr=1.3&pid=1.7",
    url: "https://www.kugou.com",
    description: "酷狗音乐平台"
  }
]//其他软件数据