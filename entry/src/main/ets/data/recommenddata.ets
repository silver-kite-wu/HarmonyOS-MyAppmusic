/*
author:wuzheng
* time:2025/8/8
* log:完成
 */
//主页-推荐数据
export interface playlist{
  img:string
  countdata:string
  title:string
}
export const playlists:playlist[]=[
  {
    img: "https://tse3-mm.cn.bing.net/th/id/OIP-C.joBs_yjFhMxuc8VVATgDpAHaHa?w=195&h=195&c=7&r=0&o=5&dpr=1.3&pid=1.7",
    countdata: "24万+",
    title: "夏末初秋·时光絮语"
  },
  {
    img: "https://tse2-mm.cn.bing.net/th/id/OIP-C.lEYuUJeVxkAoNnG59HFwXwHaHa?w=168&h=180&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3",
    countdata: "476.9万",
    title: "《歌手2025》总决赛巅峰对决"
  },
  {
    img: "https://tse1-mm.cn.bing.net/th/id/OIP-C.nvsi9aefnwM-vplN0qtkkgHaHa?w=160&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7",
    countdata: "745.2万",
    title: "旅行Vlog·浪漫黄昏专属BGM"
  },
  {
    img: "https://tse3-mm.cn.bing.net/th/id/OIP-C.h6ISJUUiIqZFMTtZC6wPtAHaFj?w=214&h=192&c=7&r=0&o=5&dpr=1.3&pid=1.7",
    countdata: "1024.2万",
    title: "2025八月全球EDM新势力"
  },
  {
    img: "https://tse2-mm.cn.bing.net/th/id/OIP-C.Zy8mg_OSWIsoXMBcvum7IQHaHa?w=195&h=195&c=7&r=0&o=5&dpr=1.3&pid=1.7",
    countdata: "1102.3万",
    title: "迪士尼铜管魔法夜"
  }
]