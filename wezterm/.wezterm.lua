local wezterm = require 'wezterm'

return {
  -- フォントを変更する
  font = wezterm.font_with_fallback {
    'Menlo',
    'ヒラギノ角ゴシック',
  },
  font_size = 11.0,

  -- タブを非表示にする
  enable_tab_bar = false,

  -- フルスクリーンを有効にする
  native_macos_fullscreen_mode = true,

  -- キーボードショートカットの設定
  keys = {
    {
      key = 'f',
      mods = 'CMD|CTRL',
      action = wezterm.action.ToggleFullScreen,
    }
  }
}
