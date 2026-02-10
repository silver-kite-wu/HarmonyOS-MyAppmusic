/*
author:wuzheng
* time:2025/9/17
* log:AI
 */
import common from '@ohos.app.ability.common'
import preferences from '@ohos.data.preferences'

const PREF_NAME = 'user_prefs'
const KEY_MINI = 'mini_player_last'

export interface MiniPersistState {
  img: string
  name: string
  author: string
  isplay: boolean
  playindex: number
}

async function getPrefs(ctx: common.UIAbilityContext): Promise<preferences.Preferences> {
  return await preferences.getPreferences(ctx, PREF_NAME)
}

export async function saveLastMini(ctx: common.UIAbilityContext, state: MiniPersistState): Promise<void> {
  const pref = await getPrefs(ctx)
  await pref.put(KEY_MINI, JSON.stringify(state))
  await pref.flush()
}

export async function loadLastMini(ctx: common.UIAbilityContext): Promise<MiniPersistState | null> {
  const pref = await getPrefs(ctx)
  const raw = await pref.get(KEY_MINI, '') as string
  if (!raw) { return null }
  try {
    const obj = JSON.parse(raw) as MiniPersistState
    // 基础校验
    if (typeof obj.name === 'string') { return obj }
  } catch (_) {}
  return null
}

