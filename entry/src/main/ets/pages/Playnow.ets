/*
author:wuzheng
* time:2025/9/19
* log:...
 */
import { playstate, songlist } from '../data/music'
import router from '@ohos.router'
import { emitter } from '@kit.BasicServicesKit'
import avplayerClass from '../services/avplayermanager'
import { notificationManager } from '@kit.NotificationKit'
import { image } from '@kit.ImageKit'
import { wantAgent } from '@kit.AbilityKit'
import abilityAccessCtrl from '@ohos.abilityAccessCtrl'
import common from '@ohos.app.ability.common'

AppStorage.SetOrCreate('val',0)
AppStorage.SetOrCreate('total',100)
// 事件回调数据接口：与 BasicServicesKit emitter 的 EventData.data 结构对齐
interface EmittedPlayState {
  data?: Partial<playstate>
}

@Entry
@Component
export struct Playnow {
  // 定义显式接口，避免对象字面量作为类型声明
  private onStateUpdate: ((ev: EmittedPlayState) => void) | null = null;
  @LocalStorageLink('playindex')playindex:number=0
  @State start: number = 0
  @StorageLink('val')val:number|null=null
  @StorageLink('total')total:number|null=null
  @State playstate: playstate = {
    duration: 0,
    time: 0,
    isplay: false,
    playmodel: 'auto',
    playindex: this.playindex,
    img: songlist[this.playindex].img,
    name: songlist[this.playindex].name,
    author: songlist[this.playindex].author
  }
  @State isLiked: boolean = false
  @State firstAppear: boolean = true

  private timerId: number = 0

  aboutToAppear(): void {
    console.log('Playnow page aboutToAppear');

    // 请求通知权限
    this.requestNotificationPermission().then(granted => {
      if (granted) {
        console.info('通知权限已授予');
      } else {
        console.warn('通知权限被拒绝');
      }
    });

    // 初始化播放器
    if (this.firstAppear) {
      this.firstAppear = false;
      avplayerClass.init().then(() => {
        console.log('播放器初始化完成');
      }).catch((error:Error) => {
        const errorMessage = error instanceof Error ? error.message : String(error);
        console.error('播放器初始化失败:', errorMessage);
      });
    }

    // 从路由参数读取当前播放索引，若有效则与全局播放器保持一致
    try {
      const params = router.getParams() as Record<string, number> | undefined;
      const idx = params && typeof params['playindex'] === 'number' ? Number(params['playindex']) : NaN;

      if (!isNaN(idx) && idx >= 0 && idx < songlist.length) {
        this.playindex = idx;
        avplayerClass.playindex = idx;
      } else if (typeof avplayerClass.playindex === 'number' && avplayerClass.playindex >= 0) {
        this.playindex = avplayerClass.playindex;
      } else if (songlist.length > 0) {
        // 如果都没有设置，默认使用第一首歌
        this.playindex = 0;
        avplayerClass.playindex = 0;
      }

      // 进入页面后，立即用当前索引同步一次展示数据（即使暂停也能显示正确歌曲）
      const cur = songlist[this.playindex];
      if (cur) {
        this.playstate = {
          duration: avplayerClass.duration || 0,
          time: avplayerClass.time || 0,
          isplay: !!avplayerClass.isplay,
          playmodel: avplayerClass.playmodel,
          playindex: this.playindex,
          img: cur.img,
          name: cur.name,
          author: cur.author
        };
      }

      // 主动广播一次全局状态，确保订阅者收到
      avplayerClass.updatestate();
    } catch (error) {
      console.error('初始化播放状态失败:', error);
    }

    // 订阅播放状态更新（使用字符串事件ID）
      this.onStateUpdate = (eventData: EmittedPlayState) => {
        const data = eventData.data;
        if (!data) return;

        console.log('收到状态更新:', data);

        // 手动合并状态更新
        const newState: playstate = {
          duration: data.duration !== undefined ? data.duration : this.playstate.duration,
          time: data.time !== undefined ? data.time : this.playstate.time,
          isplay: data.isplay !== undefined ? data.isplay : this.playstate.isplay,
          playmodel: data.playmodel || this.playstate.playmodel,
          playindex: data.playindex !== undefined ? data.playindex : this.playstate.playindex,
          img: data.img || this.playstate.img,
          name: data.name || this.playstate.name,
          author: data.author || this.playstate.author
        };

        this.playstate = newState;

        // 确保当前播放索引是最新的
        if (data.playindex !== undefined) {
          this.playindex = data.playindex;
        }

        // 在播放状态改变或播放进度更新时都更新通知
        if (data.isplay !== undefined || data.playindex !== undefined || data.name !== undefined || data.time !== undefined) {
          this.notifyPlaybackState();
        }
      };

    emitter.on('play_state_update', this.onStateUpdate);
    this.startAnimation();
  }

  startAnimation(): void {
    const animate = () => {
      this.timerId = setTimeout(() => {
        this.start = (this.start + 1) % 360
        this.val=this.playstate.time
        this.total=this.playstate.duration
        animate()
      }, 16)
    }

    animate()
  }

  aboutToDisappear(): void {
    // 清除定时器
    if (this.timerId) {
      clearTimeout(this.timerId);
      this.timerId = 0;
    }

    // 取消事件订阅
    if (this.onStateUpdate) {
      emitter.off('play_state_update', this.onStateUpdate);
      this.onStateUpdate = null;
    }
  }
  private async publishNotification(): Promise<void> {
    try {
      // 1. 获取当前播放歌曲信息
      const currentSong = this.playstate;
      const songName = currentSong.name || songlist[this.playindex].name || '未知歌曲';
      const artistName = currentSong.author || songlist[this.playindex].author || '未知歌手';
      const coverImg = currentSong.img || songlist[this.playindex].img;
      let pixelMap: image.PixelMap | undefined;

      try {
        // 正确处理图片加载，确保pixelMap在使用前已经赋值
        const rm = getContext(this).resourceManager;
        const file = await rm.getMediaContent($r('app.media.startIcon'));
        const imageSource = image.createImageSource(file.buffer);
        pixelMap = await imageSource.createPixelMap();
        console.info('图片加载成功');
      } catch (err) {
        console.error(`创建PixelMap失败: ${err instanceof Error ? err.message : String(err)}`);
        // 即使图片加载失败，也继续创建通知，只是不显示封面图片
      }

      // 4. 配置音乐通知模板
      let notificationRequest: notificationManager.NotificationRequest = {
        id: 99, // 唯一标识符
        template: {
          name: 'playbackTemplate', // API 20支持的音乐播放模板
          data: {
            progressValue: currentSong.time > 0 && currentSong.duration > 0 ? 
                          Math.floor((currentSong.time / currentSong.duration) * 100) : 0,
            progressMaxValue: 100,
            title: songName,
            artist: artistName,
            cover: pixelMap!,
            // 添加必要的进度条显示属性
            isShowProgress: true,
            progressType: 0 // 0表示确定进度条类型
          }
        },
        content: {
          contentType: 1, // 使用数值代替枚举，避免类型冲突
          notificationContentType: 1, // 添加missing的notificationContentType属性
          longText: { 
            title: songName,
            text: artistName,
            briefText: '正在播放',
            expandedTitle: songName,
            longText: `${songName} - ${artistName}` 
          }, // 完善NotificationLongTextContent类型，添加所有必需属性
          normal: {
            title: songName,
            text: artistName,
            additionalText: '正在播放'
          }
        },
        actionButtons: [], // 移除所有操作按钮，只显示图片和文字
        sound: '', // 无声
        tapDismissed: false // 点击不关闭通知
      };

      // 5. 发布通知
      await notificationManager.publish(notificationRequest);
      console.info('音乐通知发布成功');
      
      // 释放PixelMap资源已移除，因为图片处理逻辑已注释掉
    } catch (err) {
      console.error(`通知发布失败: ${err instanceof Error ? err.message : String(err)}`);
    }
  }

  // 创建WantAgent，用于通知按钮的点击操作
  private async createWantAgent(action: string): Promise<Object> { // 使用Object类型避免不存在的类型错误
    try {
      const wantAgentInfo: wantAgent.WantAgentInfo = {
        wants: [
          {
            bundleName: 'com.wuzheng.mymusic', // 使用真实的bundleName
            abilityName: 'EntryAbility', // 使用真实的abilityName
            parameters: {
              action: action,
              playindex: this.playindex
            }
          }
        ],
        operationType: wantAgent.OperationType.START_ABILITY,
        requestCode: 0,
        wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
      };
      
      const wantAgentObj = await wantAgent.getWantAgent(wantAgentInfo);
      console.info(`成功创建WantAgent，action: ${action}`);
      return wantAgentObj;
    } catch (err) {
      console.error(`创建WantAgent失败: ${err instanceof Error ? err.message : String(err)}`);
      throw new Error(`创建WantAgent失败: ${err instanceof Error ? err.message : String(err)}`); // 使用Error对象
    }
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Image($r('app.media.back'))
          .width(28)
          .height(28)
          .margin({ left: 20 })
          .onClick(() => {
            router.back()
          })
          .opacity(0.9)

        Text('正在播放')
          .fontSize(22)
          .fontColor('#fff')
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Image(this.isLiked ? $r('app.media.like') : $r('app.media.unlike'))
          .width(32)
          .height(32)
          .margin({ right: 20 })
          .onClick(() => {
            this.isLiked = !this.isLiked
          })
          .opacity(0.9)
      }
      .height('15%')
      .width('100%')
      .padding( {bottom: 10 })

      // 专辑封面区域
      Stack() {
        // 背景模糊效果
        Image(songlist[this.playindex].img)
          .width('100%')
          .height('100%')
          .borderRadius(24)
          .padding(12)
          .blur(25)
          .opacity(0.35)
          .scale({ x: 1.3, y: 1.3 })

        Column() {
          // 专辑封面
          Stack() {
            Image(this.playstate.img || songlist[this.playindex].img)
              .width(300)
              .height(300)
              .borderRadius(150)
              .objectFit(ImageFit.Cover)
              .border({ width: 10, color: '#ff27fcf4' })
              .shadow({ radius: 25, color: '#00000070' })
              .rotate({
                x: 0,
                y: 0,
                z: 1,
                angle: this.start
              })
          }
          .margin({ top: 40, bottom: 50 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .height('40%')
      .width('100%')
      .margin(10)

      // 歌曲信息
      Column() {
        Text(this.playstate.name || songlist[this.playindex].name || '未知歌曲')
          .fontColor('#fff')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textAlign(TextAlign.Center)
          .margin({ bottom: 12 })

        Text(this.playstate.author || songlist[this.playindex].author || '未知歌手')
          .fontColor('#bbb')
          .fontSize(18)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textAlign(TextAlign.Center)
          .margin({ bottom: 35 })
      }
      .width('90%')
      .alignItems(HorizontalAlign.Center)
      // 进度条和时间
      Column() {
        Row() {
          Text(this.formatTime(this.playstate.time))
            .fontSize(14)
            .fontColor('#ddd')
            .width('15%')
            .textAlign(TextAlign.Start)

          Slider({
            value: this.playstate.time,
            min: 0,
            max: this.playstate.duration > 0 ? this.playstate.duration : 1,
            step: 1000,
            style: SliderStyle.OutSet
          })
            .blockColor('#ffffff')
            .trackColor('#a1a1a1a1')
            .selectedColor('#ffffff')
            .width('70%')
            .onChange(async (value: number) => {
              if (avplayerClass.player && avplayerClass.player.seek) {
                try {
                  await avplayerClass.player.seek(value);
                } catch (e) {
                  console.error('seek失败', e)
                }
              }
            })

          Text(this.formatTime(this.playstate.duration))
            .fontSize(14)
            .fontColor('#ddd')
            .width('15%')
            .textAlign(TextAlign.End)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('90%')
      .padding({ bottom: 25 })

      // 控制按钮
      Row() {
        Image($r('app.media.previous'))
          .width(52)
          .height(52)
          .onClick(() => {
            // 交由 avplayerClass 维护索引，避免与UI重复修改导致错乱
            avplayerClass.previous()
          })
          .opacity(0.9)

        // 播放中显示“暂停”图标，暂停时显示“播放”图标
        Image(this.playstate.isplay ? $r('app.media.play') : $r('app.media.pause'))
          .width(60)
          .height(60)
          .fillColor(Color.Black)
          .margin({ left: 35, right: 35 })
          .onClick(async () => {
            console.log('Play/Pause button clicked, current state:', this.playstate.isplay);
            try {
              if (this.playstate.isplay) {
                await avplayerClass.pause();
              } else {
                // 如果没有正在播放的歌曲，播放当前索引的歌曲
                if (avplayerClass.playindex < 0 && avplayerClass.playlist.length > 0) {
                  await avplayerClass.playSongByIndex(this.playindex >= 0 ? this.playindex : 0);
                } else {
                  await avplayerClass.play();
                }
              }
              // 手动更新UI状态
              this.playstate.isplay = avplayerClass.isplay;
              
              // 播放状态改变后更新通知
              this.notifyPlaybackState();
            } catch (error) {
              console.error('切换播放状态失败:', error);
            }
          })

        Image($r('app.media.next'))
          .width(52)
          .height(52)
          .onClick(() => {
            // 交由 avplayerClass 维护索引，避免与UI重复修改导致错乱
            avplayerClass.next()
          })
          .opacity(0.9)
      }
      .margin({ top: 15, bottom: 15 })
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#ff2e8857')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  private formatTime(seconds: number): string {
    if (seconds <= 0 || isNaN(seconds)) return '00:00';
    const mins = Math.floor(seconds/1000 / 60);
    const secs = Math.floor(seconds/1000 % 60);
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }

  // 请求通知权限
  private async requestNotificationPermission(): Promise<boolean> {
    try {
      const notificationPermission = 'ohos.permission.NFC_NOTIFICATION'; // 使用系统定义的权限名称
      
      // 获取上下文
      const context = getContext(this) as common.UIAbilityContext;
      
      // 检查权限状态
      const atManager = abilityAccessCtrl.createAtManager();
      
      // 使用verifyAccessToken替代checkPermission，需要两个参数：tokenID和permissionName
      const grantStatus = await atManager.verifyAccessToken(0, notificationPermission);

      if (grantStatus === 0) { // 0表示已授权
        console.info('通知权限已授予');
        return true;
      }
      
      // 请求权限
      const result = await atManager.requestPermissionsFromUser(context, [notificationPermission]);
      
      // 处理返回结果（调整访问方式以匹配实际返回类型，使用可选链替代in操作符）
      if (result && (result).authResults?.length > 0) {
        return (result).authResults[0] === 0; // 0表示已授权
      }
      return false;
    } catch (err) {
      console.error(`请求通知权限失败: ${err instanceof Error ? err.message : String(err)}`);
      return false;
    }
  }

  // 在适当的时机手动调用通知发布，例如播放状态改变时
  private notifyPlaybackState(): void {
    this.publishNotification().catch((err: Error) => {
      console.error('发布播放状态通知失败:', err instanceof Error ? err.message : String(err));
    });
  }
}