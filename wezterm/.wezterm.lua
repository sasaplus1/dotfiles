local wezterm = require 'wezterm'

-- https://coralpink.github.io/commentary/wezterm/dpi-detection.html
-- window:get_dimensions().dpi
-- MacBook Pro (13-inch, M1, 2020) 内蔵Retinaディスプレイ 13.3インチ(2560x1600) : 144dpi
-- RDT231WLM 23インチ(1920x1080) : 72dpi

local DPI_CHANGE_NUM = 140
local DPI_CHANGE_FONT_SIZE = 11.0

local prev_dpi = 0

wezterm.on('window-focus-changed', function(window, pane)
  local dpi = window:get_dimensions().dpi

  if dpi == prev_dpi then
    return
  end

  local overrides = window:get_config_overrides() or {}
  overrides.font_size = dpi >= DPI_CHANGE_NUM and DPI_CHANGE_FONT_SIZE or nil

  window:set_config_overrides(overrides)

  prev_dpi = dpi
end)

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
  font_size = 11,
  -- cell_width = 0.996,
  -- line_height = 1.0,

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

  -- IMEへ送信する修飾キー
  -- Ctrl-hでIME入力中の文字列に対してBackspaceの挙動をしてほしい
  -- Alt-;で「…」をきちんとIMEに送信して欲しい
  -- https://github.com/wez/wezterm/pull/2435
  -- https://github.com/wez/wezterm/pull/2435#issuecomment-1491290065
  -- https://wezfurlong.org/wezterm/config/lua/config/macos_forward_to_ime_modifier_mask.html
  macos_forward_to_ime_modifier_mask = "ALT|CTRL|SHIFT",
}
