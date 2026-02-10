import { router } from '@kit.ArkUI'
import promptAction from '@ohos.promptAction'

interface CalendarValue { year: number; month: number; day: number }

interface MonthDay {
  month: number
  day: number
}

function parseMonthDay(dateStr: string): MonthDay | null {
  // 严格匹配整串，禁止多余字符
  const match = dateStr.trim().match(/^\s*(\d{1,2})[月\.\-](\d{1,2})\s*$/)
  if (!match) return null
  const m = parseInt(match[1])
  const d = parseInt(match[2])
  const daysInMonth = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  if (m < 1 || m > 12 || d < 1 || d > daysInMonth[m - 1]) {
    return null
  }
  const result: MonthDay = { month: m, day: d }
  return result
}

function getConstellationFromString(dateStr: string): string {
  const parsed = parseMonthDay(dateStr)
  if (!parsed) return "输入错误！";

  const month = parsed.month
  const day = parsed.day

  // 星座判断逻辑
  if ((month === 12 && day >= 22) || (month === 1 && day <= 19)) {
    return "摩羯座";
  } else if ((month === 1 && day >= 20) || (month === 2 && day <= 18)) {
    return "水瓶座";
  } else if ((month === 2 && day >= 19) || (month === 3 && day <= 20)) {
    return "双鱼座";
  } else if ((month === 3 && day >= 21) || (month === 4 && day <= 19)) {
    return "白羊座";
  } else if ((month === 4 && day >= 20) || (month === 5 && day <= 20)) {
    return "金牛座";
  } else if ((month === 5 && day >= 21) || (month === 6 && day <= 21)) {
    return "双子座";
  } else if ((month === 6 && day >= 22) || (month === 7 && day <= 22)) {
    return "巨蟹座";
  } else if ((month === 7 && day >= 23) || (month === 8 && day <= 22)) {
    return "狮子座";
  } else if ((month === 8 && day >= 23) || (month === 9 && day <= 22)) {
    return "处女座";
  } else if ((month === 9 && day >= 23) || (month === 10 && day <= 23)) {
    return "天秤座";
  } else if ((month === 10 && day >= 24) || (month === 11 && day <= 22)) {
    return "天蝎座";
  } else if ((month === 11 && day >= 23) || (month === 12 && day <= 21)) {
    return "射手座";
  }
  return "输入错误！";
}

function isValidBirthday(dateStr: string): boolean {
  return parseMonthDay(dateStr) !== null
}

// 新增函数：将日期格式化为 "X月X日" 形式
function formatDateToMonthDay(dateStr: string): string {
  const parsed = parseMonthDay(dateStr)
  if (!parsed) return dateStr
  const month = parsed.month
  const day = parsed.day
  return `${month}月${day}日`;
}

// 解析 “YYYY年M月D日”
function parseFullYMDZh(text: string): Date | null {
  if (!text) { return null }
  const m = text.trim().match(/^\s*(\d{4})年(\d{1,2})月(\d{1,2})日\s*$/)
  if (!m) { return null }
  const y = parseInt(m[1])
  const mm = parseInt(m[2])
  const dd = parseInt(m[3])
  if (isNaN(y) || mm < 1 || mm > 12 || dd < 1 || dd > 31) { return null }
  const d = new Date(y, mm - 1, dd)
  // 校验回填，避免 2/31 这类越界
  if (d.getFullYear() !== y || (d.getMonth() + 1) !== mm || d.getDate() !== dd) { return null }
  return d
}

function pad2(n: number): string { return n < 10 ? `0${n}` : `${n}` }

@Entry
@Component
struct Birthday_page {
  @StorageLink('age') private age: number|null=null
  @StorageLink('year') private year: string = '';
  @StorageLink('star') private star: string = '';
  selectedDate: Date = new Date()
  // 衍生显示字段（用于根据所选日期计算临时显示）
  @State private displayAge: number = 0
  @State private displayBirthText: string = ''
  @State private displayConstellation: string = ''
  // 草稿值：用于界面展示与编辑，保存时再同步到全局
  @State private draftAge: number|null =this.age
  @State private draftYear: string = this.year
  @State private draftStar: string = this.star

  aboutToAppear(): void {
    // 若全局已有 birthday（year 以 “YYYY年MM月DD日” 存储），用其预填
    const preset = (this.year || '').trim()
    if (preset) {
      const d = parseFullYMDZh(preset)
      if (d) { this.selectedDate = d }
    }
    // 首次进入：直接以全局为准初始化草稿；缺失时用所选日期推导
    const m0 = this.selectedDate.getMonth() + 1
    const d0 = this.selectedDate.getDate()
    const derivedAge = this.calcAge(this.selectedDate)
    const derivedYear = `${this.selectedDate.getFullYear()}年${pad2(m0)}月${pad2(d0)}日`
    const derivedStar = getConstellationFromString(`${m0}月${d0}`)
    this.draftAge = (this.age !== null) ? this.age : derivedAge
    this.draftYear = (this.year && this.year.trim().length > 0) ? this.year : derivedYear
    this.draftStar = (this.star && this.star.trim().length > 0) ? this.star : derivedStar
    // 同步显示字段以匹配草稿
    this.displayAge = this.draftAge ?? derivedAge
    this.displayBirthText = this.draftYear
    this.displayConstellation = this.draftStar
  }

  private formatDateZh(d: Date): string {
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const day = d.getDate()
    return `${y}年${m}月${day}日`
  }

  private calcAge(d: Date): number {
    const today = new Date()
    let age = today.getFullYear() - d.getFullYear()
    const hasNotHadBirthdayThisYear = (today.getMonth() < d.getMonth()) ||
      (today.getMonth() === d.getMonth() && today.getDate() < d.getDate())
    if (hasNotHadBirthdayThisYear) { age -= 1 }
    return Math.max(0, age)
  }

  private updateDerivedFields(): void {
    this.displayAge = this.calcAge(this.selectedDate)
    this.displayBirthText = this.formatDateZh(this.selectedDate)
    const m = this.selectedDate.getMonth() + 1
    const d = this.selectedDate.getDate()
    this.displayConstellation = getConstellationFromString(`${m}月${d}`)
  }

  private saveBirthday(): void {
    // 将草稿一次性同步到全局
    this.year = this.draftYear
    this.star = this.draftStar
    this.age = this.draftAge
    promptAction.showToast({ message: '生日已保存', duration: 1500 })
  }
  // 统一从一个日期应用到草稿与显示（用于日历确定/变更）
  private applyFromDate(date: Date): void {
    this.selectedDate = date
    this.updateDerivedFields()
    const m2 = this.selectedDate.getMonth() + 1
    const d2 = this.selectedDate.getDate()
    this.draftAge = this.displayAge
    this.draftYear = `${this.selectedDate.getFullYear()}年${pad2(m2)}月${pad2(d2)}日`
    this.draftStar = this.displayConstellation
  }

  build() {
    Column({ space: 10 }) {
      // 顶部导航栏
      Row() {
        Image($r('app.media.back'))
          .width(20)
          .fillColor(Color.Black)
          .margin({ left: 12 })
          .onClick(() => router.back())

        Text('更换生日')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .margin({left:'30%'})
          .textAlign(TextAlign.Center)

        Button('保存', { type: ButtonType.Normal })
          .fontColor('#1890FF')
          .backgroundColor(Color.Transparent)
          .margin({ right: 16,left:'20%' })
          .onClick(() => this.saveBirthday())//保存生日
      }
      .height(56)
      .width('100%')
      .shadow({ radius: 2, color: Color.Gray, offsetX: 0, offsetY: 1 })
      Column() {
        // 信息概览卡片：年龄 / 出生日期 / 星座
        Column({ space: 12 }) {
          Text('我的信息')
            .fontSize(14)
            .fontColor('#666')
            .margin({ bottom: 4 })

          Row() {
            Text('年龄')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333')
            Text(this.draftAge !== null ? `${this.draftAge}` : '未设置')
              .layoutWeight(1)
              .textAlign(TextAlign.End)
              .fontWeight(FontWeight.Bold)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }

          Divider().strokeWidth(1).color('#F0F0F0').width('100%')

          Row() {
            Text('出生日期')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333')
            Text(this.draftYear && this.draftYear.trim().length > 0 ? this.draftYear : '未设置')
              .layoutWeight(1)
              .textAlign(TextAlign.End)
              .fontWeight(FontWeight.Bold)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }

          Divider().strokeWidth(1).color('#F0F0F0').width('100%')

          Row() {
            Text('星座')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333')
            Text(this.draftStar && this.draftStar.trim().length > 0 ? this.draftStar : '未设置')
              .layoutWeight(1)
              .textAlign(TextAlign.End)
              .fontWeight(FontWeight.Bold)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 14, bottom: 14 })
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .shadow({ radius: 8, color: '#33000000', offsetX: 0, offsetY: 2 })
        .margin({ left: 12, right: 12, top: 6, bottom: 6 })

        Button("更改生日")
          .margin(20)
          .onClick(() => {
            console.info("CalendarDialog.show")
            CalendarPickerDialog.show({
              selected: this.selectedDate,
              onAccept: (value: Date | CalendarValue) => {
                // 兼容 CalendarPickerDialog 回调值：若是对象包含 year/month/day，则构造 Date
                const v: Date | CalendarValue = value
                let next = this.selectedDate
                if (v instanceof Date) {
                  next = v
                } else if (v && typeof (v as CalendarValue).year === 'number' && typeof (v as CalendarValue).month === 'number') {
                  const cv = v as CalendarValue
                  const dayVal = (typeof cv.day === 'number' && cv.day > 0) ? cv.day : 1
                  next = new Date(cv.year, Math.max(0, cv.month - 1), dayVal)
                }
                this.applyFromDate(next)
                console.info("calendar onAccept:" + JSON.stringify(value))
              },
              onCancel: () => {
                console.info("calendar onCancel")
              },
              onChange: (value: Date | CalendarValue) => {
                const v: Date | CalendarValue = value
                if (v instanceof Date) {
                  this.applyFromDate(v)
                } else if (v && typeof (v as CalendarValue).year === 'number' && typeof (v as CalendarValue).month === 'number') {
                  const cv = v as CalendarValue
                  const dayVal = (typeof cv.day === 'number' && cv.day > 0) ? cv.day : this.selectedDate.getDate()
                  this.applyFromDate(new Date(cv.year, Math.max(0, cv.month - 1), dayVal))
                }
                console.info("calendar onChange:" + JSON.stringify(value))
              },
              onDidAppear: () => {
                console.info("calendar onDidAppear")
              },
              onDidDisappear: () => {
                console.info("calendar onDidDisappear")
              },
              onWillAppear: () => {
                console.info("calendar onWillAppear")
              },
              onWillDisappear: () => {
                console.info("calendar onWillDisappear")
              }
            })
          })
      }.width('100%')
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .width('100%')
    .height('100%')
    .padding({ bottom: 8 })
    .radialGradient({
      center: ['90%', '-10%'],
      radius: '150%',
      colors: [
        ['#ffab884c', 0.5],
        [Color.Transparent, 1]
      ]
    })
  }
}