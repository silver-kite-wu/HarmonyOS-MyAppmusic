//评论
/*
author:wuzheng
* time:2025/8/10
* log:完成
 */
import { infobottom, infoitem, infotop } from '../components/pinglun_coms'
import { router } from '@kit.ArkUI'
import { Comment, commentData } from '../data/pinglundata'
@Component
export struct pinglun_page {
  @StorageLink('touxiang') touxiang:string=''
  @StorageLink('isLogin') isLogin:boolean=false
  @State comments: Comment[] = commentData.map(c => new Comment(
    c.img, c.name, c.Likenum, c.commenttxt, c.isLike, c.time, c.levelsort
  ));
  aboutToAppear(): void {
    this.handlesort(0)
  }
  // 处理点赞功能
  handlike(id: string) {
    this.comments = this.comments.map(comment => {
      if (comment.id === id) {
        return new Comment(
          comment.img,
          comment.name,
          comment.isLike ? comment.Likenum - 1 : comment.Likenum + 1,
          comment.commenttxt,
          !comment.isLike,
          comment.time,
          comment.levelsort
        );
      }
      return comment;
    });
  }

  // 处理提交
  handlesubmit(content: string) {
    if (!this.isLogin) {
      // 未登录则先去登录页
      router.pushUrl({ url: 'otherpages/login_page' })
      return
    }
    const newitem: Comment = new Comment(
      this.touxiang,
      '我',
      0,
      content,
      false,
      Date.now(),
      3
    );
    // 使用不可变更新
    this.comments = [newitem, ...this.comments];
  }
  // 排序功能（修复）
  handlesort(type: number) {
    // 创建新数组副本
    const sortedComments = [...this.comments];

    if (type === 0) {
      // 按时间排序（最新）
      sortedComments.sort((a, b) => b.time - a.time);
    } else {
      // 按点赞数排序（最热）
      sortedComments.sort((a, b) => b.Likenum - a.Likenum);
    }

    // 使用不可变更新
    this.comments = sortedComments;
  }

  build() {
    Column() {
      // 头部
      infotop({
        onsort: (type: number) => {
          this.handlesort(type);
        }
      })
      // 评论列表
      List() {
        ForEach(this.comments, (item: Comment, index: number) => {
          ListItem() {
            infoitem({
              commentData: item,
              callback: {
                onlike: (): void => this.handlike(item.id)
              }
            })
          }
        }, (item: Comment) => item.id)
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
      // 底部
      Row() {
        infobottom({
          onsubcomment: (con: string) => {
            this.handlesubmit(con)
          }
        })
      }
      .width('100%')
      .height(60)
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .width('100%')
    .height('100%')
    .radialGradient({
      center: ['90%', '-10%'],
      radius: '150%',
      colors: [
        ['#ffab884c', 0.2],
        [Color.Transparent, 1]
      ]
    })
  }
}