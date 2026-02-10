/*
author:silver-kite
* time:2025/8/17
* log:AI
 */
import { media } from "@kit.MediaKit";
import { songtype, songlist } from "../data/music";
import { emitter } from '@kit.BasicServicesKit'
import http from "@ohos.net.http";
import fs from "@ohos.file.fs";
// 使用函数指针方式获取 rawfile 描述符，避免直接依赖类型命名

// 最小化上下文类型与显式平台扩展接口
// 使用官方资源管理器类型，避免结构化类型报错

interface AVFdSrc { fd: number; offset: number; length: number }
interface RawFdDesc { fd: number; offset: number; length: number }
interface AVPlayerWithFd extends media.AVPlayer { fdSrc: AVFdSrc }

// 定义播放器状态类型
type AVPlayerState = 'idle' | 'initialized' | 'prepared' | 'playing' | 'paused' | 'completed' | 'stopped' | 'error';

// 定义播放状态对象接口
interface PlayStateData {
  duration: number;
  time: number;
  isplay: boolean;//播放状态
  playmodel: 'auto' | 'repeat' | 'random';
  playlist: songtype[];
  playindex: number;
  img: string;
  name: string;
  author: string;
}

interface GeneratedObjectLiteralInterface_1 {
  img: string;
  name: string;
  author: string;
}

export default class avplayerClass {
  static player: media.AVPlayer | null = null;
  static duration: number = 0;
  static time: number = 0;
  static isplay: boolean = false;
  static playmodel: 'auto' | 'repeat' | 'random' = 'auto';
  static playlist: songtype[] = songlist;
  static playindex: number = -1;
  static isInitialized: boolean = false;
  static cacheDir: string | null = null;
  static filesDir: string | null = null;
  static getRawFileDescriptor: ((path: string) => Promise<RawFdDesc>) | null = null;
  static currentTmpPath: string | null = null;
  static lastBufferingPercent: number = -1;
  static isSwitching: boolean = false;
  static lastNotifyMs: number = 0;
  static lastNotifiedIndex: number = -999;
  static lastNotifiedTime: number = -1;
  static lastNotifiedDuration: number = -1;

  static setContext(cacheDir: string, filesDir: string, getRawFileDescriptor: (path: string) => Promise<RawFdDesc>) {
    avplayerClass.cacheDir = cacheDir;
    avplayerClass.filesDir = filesDir;
    avplayerClass.getRawFileDescriptor = getRawFileDescriptor;
  }

  static async init(): Promise<void> {
    if (avplayerClass.isInitialized && avplayerClass.player) {
      return;
    }
    try {
      avplayerClass.player = await media.createAVPlayer();
      avplayerClass.isInitialized = true;

      // 使用 SDK 实际支持的事件名称和类型
      avplayerClass.player.on('stateChange', (state: string) => {
        console.log(`播放器状态变化: ${state}`);

        // 将状态转换为我们的类型
        const playerState = state as AVPlayerState;

        switch (playerState) {
          case 'initialized':
            // 不在初始化时自动 prepare，等待设置数据源后再准备
            break;
          case 'prepared':
            console.log('播放器准备就绪');
            break;
          case 'playing':
            avplayerClass.isplay = true;
            console.log('开始播放');
            break;
          case 'paused':
            avplayerClass.isplay = false;
            console.log('播放暂停');
            break;
          case 'completed':
            console.log('播放完成');
            avplayerClass.next();
            break;
          case 'error':
            console.error('播放器发生错误');
            break;
          default:
            console.log(`处理状态: ${playerState}`);
        }
        avplayerClass.updatestate();
      });

      // 时长与进度，统一毫秒
      avplayerClass.player.on('durationUpdate', (duration: number) => {
        avplayerClass.duration = Math.max(0, Number(duration) || 0);
        avplayerClass.updatestate();
      });

      avplayerClass.player.on('timeUpdate', (time: number) => {
        avplayerClass.time = Math.max(0, Number(time) || 0);
        avplayerClass.updatestate();
      });

      // 兼容缓冲与错误（节流日志）
      avplayerClass.player.on?.('bufferingUpdate', (percent: number) => {
        const p = Math.max(0, Math.min(100, Math.floor(Number(percent) || 0)));
        if (p !== avplayerClass.lastBufferingPercent) {
          avplayerClass.lastBufferingPercent = p;
          console.log('缓冲进度:', p);
        }
      });
      avplayerClass.player.on('error', (err: Error) => {
        console.error('AVPlayer错误:', JSON.stringify(err));
      });

      console.log('播放器初始化成功');

    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      console.error('初始化播放器失败:', errorMessage);
    }
  }

  static async play(): Promise<void> {
    console.log('avplayerClass.play() called');
    if (!avplayerClass.player) {
      await avplayerClass.init();
    }

    if (avplayerClass.playindex < 0 && avplayerClass.playlist.length > 0) {
      avplayerClass.playindex = 0;
      await avplayerClass.playSongByIndex(0);
      return;
    }

    if (!avplayerClass.player) {
      console.error('Player initialization failed');
      return;
    }

    const state = avplayerClass.player.state as AVPlayerState;
    console.log('Current player state:', state);

    if (state === 'paused' || state === 'completed' || state === 'prepared') {
      try {
        await avplayerClass.player.play();
        avplayerClass.isplay = true;
        console.log('Playback started successfully');
        
        // 更新UI状态
        avplayerClass.updatestate();
      } catch (error) {
        const errorMessage = error instanceof Error ? error.message : String(error);
        console.error('播放失败:', errorMessage);
      }
    } else if (state === 'idle' || state === 'initialized') {
      // 如果播放器处于空闲或初始化状态，尝试播放当前索引的歌曲
      if (avplayerClass.playindex >= 0 && avplayerClass.playlist[avplayerClass.playindex]) {
        console.log('Player is idle, playing song at index:', avplayerClass.playindex);
        await avplayerClass.playSongByIndex(avplayerClass.playindex);
      }
    }
  }

  static async pause(): Promise<void> {
    console.log('avplayerClass.pause() called');
    if (!avplayerClass.player) {
      console.error('Player is not initialized');
      return;
    }

    const state = avplayerClass.player.state as AVPlayerState;
    console.log('Current player state before pause:', state);

    if (state === 'playing' || state === 'prepared') {
      try {
        await avplayerClass.player.pause();
        avplayerClass.isplay = false;
        console.log('Playback paused successfully');
        
        // 更新UI状态
        avplayerClass.updatestate();
      } catch (error) {
        const errorMessage = error instanceof Error ? error.message : String(error);
        console.error('暂停失败:', errorMessage);
      }
    }
  }

  static async previous(): Promise<void> {
    if (avplayerClass.playlist.length === 0) {
      return;
    }

    if (avplayerClass.playindex < 0) {
      avplayerClass.playindex = 0;
      await avplayerClass.playSongByIndex(0);
      return;
    }

    avplayerClass.playindex--;
    if (avplayerClass.playindex < 0) {
      avplayerClass.playindex = avplayerClass.playlist.length - 1;
    }

    await avplayerClass.playSongByIndex(avplayerClass.playindex);
  }

  static async next(): Promise<void> {
    if (avplayerClass.playlist.length === 0) {
      return;
    }

    if (avplayerClass.playindex < 0) {
      avplayerClass.playindex = 0;
      await avplayerClass.playSongByIndex(0);
      return;
    }

    switch (avplayerClass.playmodel) {
      case 'repeat':
        await avplayerClass.playSongByIndex(avplayerClass.playindex);
        break;
      case 'random':
        const randomIndex = Math.floor(Math.random() * avplayerClass.playlist.length);
        avplayerClass.playindex = randomIndex;
        await avplayerClass.playSongByIndex(randomIndex);
        break;
      case 'auto':
      default:
        avplayerClass.playindex++;
        if (avplayerClass.playindex >= avplayerClass.playlist.length) {
          avplayerClass.playindex = 0;
        }
        await avplayerClass.playSongByIndex(avplayerClass.playindex);
    }
  }

  static async playSongByIndex(index: number): Promise<void> {
    if (avplayerClass.isSwitching) {
      return;
    }
    avplayerClass.isSwitching = true;
    if (!avplayerClass.player) {
      await avplayerClass.init();
    }

    if (!avplayerClass.player) {
      avplayerClass.isSwitching = false;
      return;
    }

    const song = avplayerClass.playlist[index];
    if (!song?.url) {
      console.error('无效的歌曲或URL');
      avplayerClass.isSwitching = false;
      return;
    }

    // 支持 rawfile:filename.mp3 直接播放
    const url = song.url;
    if (url.startsWith('rawfile:')) {
      const name = url.substring('rawfile:'.length);
      try {
        // 切歌前重置进度与时长，确保UI进度从0开始（rawfile 场景）
        avplayerClass.time = 0;
        avplayerClass.duration = 0;
        avplayerClass.updatestate();
        await avplayerClass.playFromRawfile(name, index);
      } finally {
        avplayerClass.isSwitching = false;
      }
      return;
    }

    try {
      // 切歌前重置进度与时长，确保UI进度从0开始
      avplayerClass.time = 0;
      avplayerClass.duration = 0;
      avplayerClass.updatestate();
      await avplayerClass.playFromLocalOrDownload(song, index);
    } finally {
      avplayerClass.isSwitching = false;
    }
  }

  private static ensureDir(dir: string) {
    try {
      fs.accessSync(dir);
    } catch (_) {
      try {
        fs.mkdirSync(dir);
      } catch (e) {
        console.error('创建目录失败:', e);
      }
    }
  }

  private static async playFromLocalOrDownload(song: songtype, index: number): Promise<void> {
    if (!avplayerClass.player) {
      await avplayerClass.init();
    }
    if (!avplayerClass.player) {
      return;
    }

    if (!avplayerClass.filesDir) {
      console.error('未设置上下文，无法定位存储目录。请在 EntryAbility 调用 avplayerClass.setContext(context)');
      return;
    }

    const baseDir = `${avplayerClass.filesDir}/music`;
    avplayerClass.ensureDir(baseDir);
    const safeName = `song_${song.id ?? avplayerClass.computeStableHash(song.url || '')}.mp3`;
    const filePath = `${baseDir}/${safeName}`;

    try {
      // 若文件不存在则下载
      let needDownload = false;
      try {
        const st = fs.statSync(filePath);
        if (!st.isFile() || st.size <= 0) {
          needDownload = true;
        }
      } catch (_) {
        needDownload = true;
      }

      if (needDownload) {
        const client = http.createHttp();
        try {
          const normalizedUrl = (song.url || '').startsWith('http://')
            ? (song.url as string).replace('http://', 'https://')
            : (song.url as string);
          const resp = await client.request(normalizedUrl, {
            method: http.RequestMethod.GET,
            connectTimeout: 15000,
            readTimeout: 60000,
            expectDataType: http.HttpDataType.ARRAY_BUFFER
          });
          const buffer: ArrayBuffer = resp.result as ArrayBuffer;
          if (!buffer) {
            throw new Error('下载结果为空');
          }
          // 覆盖写入
          const file: fs.File = fs.openSync(filePath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE | fs.OpenMode.TRUNC);
          const u8 = new Uint8Array(buffer);
          fs.writeSync(file.fd, u8);
          fs.fsyncSync(file.fd);
          fs.closeSync(file);
        } finally {
          try { client.destroy(); } catch {}
        }
      }

      // 使用 file:// URL 播放
      const fileUrl = `file://${filePath}`;
      await avplayerClass.ensureReadyForNewSource();
      avplayerClass.player.url = fileUrl;
      await avplayerClass.waitUntilInitialized(1500);
      await avplayerClass.player.prepare();
      await avplayerClass.player.play();

      avplayerClass.isplay = true;
      avplayerClass.playindex = index;
      avplayerClass.updatestate();
      console.log(`已从本地播放: ${song.name} => ${filePath}`);
    } catch (e) {
      const msg = e instanceof Error ? e.message : String(e);
      console.error('本地/下载播放失败:', msg);
    }
  }

  private static async playFromDownload(song: songtype, index: number): Promise<void> {
    if (!avplayerClass.player) {
      await avplayerClass.init();
    }
    if (!avplayerClass.player) {
      return;
    }

    if (!avplayerClass.cacheDir) {
      console.error('未设置上下文，无法创建缓存目录。请在 EntryAbility 调用 avplayerClass.setContext(context)');
      return;
    }

    const cacheDir = avplayerClass.cacheDir;
    const safeName = `song_${song.id ?? avplayerClass.computeStableHash(song.url || '')}.mp3`;
    const filePath = `${cacheDir}/${safeName}`;

    try {
      // 下载
      const client = http.createHttp();
      const normalizedUrl = (song.url || '').startsWith('http://')
        ? song.url.replace('http://', 'https://')
        : song.url;
      const resp = await client.request(normalizedUrl, {
        method: http.RequestMethod.GET,
        connectTimeout: 15000,
        readTimeout: 60000,
        expectDataType: http.HttpDataType.ARRAY_BUFFER
      });
      const buffer: ArrayBuffer = resp.result as ArrayBuffer;
      if (!buffer) {
        throw new Error('下载结果为空');
      }

      // 写入文件
      try {
        // 若已存在旧文件，覆盖
        const file: fs.File = fs.openSync(filePath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE | fs.OpenMode.TRUNC);
        const u8 = new Uint8Array(buffer);
        fs.writeSync(file.fd, u8);
        fs.fsyncSync(file.fd);
        fs.closeSync(file);
      } catch (e) {
        console.error('写缓存文件失败:', e);
        throw new Error(String(e));
      }

      // 使用 file:// URL 播放
      const fileUrl = `file://${filePath}`;
      await avplayerClass.ensureReadyForNewSource();
      avplayerClass.player.url = fileUrl;
      await avplayerClass.waitUntilInitialized(1500);
      await avplayerClass.player.prepare();
      await avplayerClass.player.play();

      avplayerClass.isplay = true;
      avplayerClass.playindex = index;
      avplayerClass.updatestate();
      console.log(`已使用离线回退播放: ${song.name} => ${filePath}`);
    } catch (e) {
      console.error('离线回退播放失败:', e);
    }
  }

  private static async playFromRawfile(rawName: string, index: number): Promise<void> {
    if (!avplayerClass.player) {
      await avplayerClass.init();
    }
    if (!avplayerClass.player) {
      return;
    }
    if (!avplayerClass.getRawFileDescriptor) {
      console.error('未设置上下文，无法读取 rawfile');
      return;
    }

    try {
      const desc = await avplayerClass.getRawFileDescriptor(rawName);
      if (!desc || typeof desc.fd !== 'number') {
        throw new Error('rawfile 描述符无效');
      }

      await avplayerClass.ensureReadyForNewSource();
      const playerWithFd = avplayerClass.player as AVPlayerWithFd;
      playerWithFd.fdSrc = { fd: desc.fd, offset: desc.offset, length: desc.length };
      await avplayerClass.waitUntilInitialized(1500);
      await avplayerClass.player.prepare();
      await avplayerClass.player.play();

      avplayerClass.isplay = true;
      avplayerClass.playindex = index;
      avplayerClass.updatestate();
      console.log(`已从 rawfile 播放: ${rawName}`);
    } catch (e) {
      const msg = e instanceof Error ? e.message : String(e);
      console.error('rawfile 播放失败:', msg);
    }
  }

  private static computeStableHash(input: string): number {
    let hash = 0;
    for (let i = 0; i < input.length; i++) {
      const chr = input.charCodeAt(i);
      hash = ((hash << 5) - hash) + chr;
      hash |= 0;
    }
    return Math.abs(hash);
  }

  private static async ensureReadyForNewSource(): Promise<void> {
    if (!avplayerClass.player) {
      return;
    }
    const state = avplayerClass.player.state as AVPlayerState;
    if (state === 'playing' || state === 'paused' || state === 'prepared' || state === 'completed') {
      try { await avplayerClass.player.stop(); } catch {}
      try { await avplayerClass.player.reset(); } catch {}
    } else if (state === 'stopped') {
      try { await avplayerClass.player.reset(); } catch {}
    } else {
      // idle/initialized: 不做额外处理
    }
  }

  private static async waitUntilInitialized(timeoutMs: number): Promise<void> {
    if (!avplayerClass.player) {
      return;
    }
    const start = Date.now();
    while (Date.now() - start <= timeoutMs) {
      const stateNow = avplayerClass.player.state as AVPlayerState;
      if (stateNow === 'initialized') {
        return;
      }
      await new Promise<void>((resolve) => setTimeout(resolve, 30));
    }
  }

  static async singplay(song: songtype): Promise<void> {
    if (!avplayerClass.player) {
      await avplayerClass.init();
    }

    if (!avplayerClass.player) {
      return;
    }

    const index = avplayerClass.playlist.findIndex(item => item.id === song.id);

    if (index >= 0) {
      await avplayerClass.playSongByIndex(index);
    } else {
      avplayerClass.playlist.push(song);
      avplayerClass.playindex = avplayerClass.playlist.length - 1;
      await avplayerClass.playSongByIndex(avplayerClass.playindex);
    }
  }

  static updatestate(): void {
    const currentSong =
      avplayerClass.playindex >= 0 &&
        avplayerClass.playindex < avplayerClass.playlist.length
        ? avplayerClass.playlist[avplayerClass.playindex]
        : ({
        img: '', name: '', author: ''
      } as GeneratedObjectLiteralInterface_1);

    // 定义显式类型的状态对象
    const stateData: PlayStateData = {
      duration: avplayerClass.duration,
      time: avplayerClass.time,
      isplay: avplayerClass.isplay,
      playmodel: avplayerClass.playmodel,
      playlist: avplayerClass.playlist,
      playindex: avplayerClass.playindex,
      img: currentSong.img || '',
      name: currentSong.name || '',
      author: currentSong.author || ''
    };

    // 发送状态更新事件（BasicServicesKit：字符串事件ID）
    try {
      emitter.emit('play_state_update', {
        data: {
          img: stateData.img,
          name: stateData.name,
          author: stateData.author,
          isplay: stateData.isplay,
          playindex: stateData.playindex,
          // 增加进度与总时长，供UI（如 Playnow 页）使用
          time: stateData.time,
          duration: stateData.duration
        }
      });
    } catch (e) {
      console.error('发送状态更新事件失败:', e);
    }
  }
}