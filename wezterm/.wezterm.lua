local wezterm = require 'wezterm'

return {
  -- ベルを無効化する
  audible_bell = 'Disabled',

  -- 色を変更する
  colors = {
    -- カーソルの背景色
    cursor_bg = 'silver',
    -- カーソルの枠の色（フォーカスが外れた時に描画される）
    cursor_border = 'silver',
  },

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
    },
  },

  -- Altキー（Optionキー）をコンポジションキーとする
  -- JIS配列では1つしかキーがないためtrueにしないと特定の文字が入力できない（例えば option + ; など）
  -- https://wezfurlong.org/wezterm/config/keyboard-concepts.html#macos-left-and-right-option-key
  send_composed_key_when_left_alt_is_pressed = true,
}
