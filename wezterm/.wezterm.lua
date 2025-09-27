local wezterm = require 'wezterm'

local config = {}

local is_linux = string.find(wezterm.target_triple, 'linux')
local is_macos = string.find(wezterm.target_triple, 'apple')

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

-- ウィンドウ背景の不透明度を設定する
config.window_background_opacity = 0.9

-- テキスト背景の不透明度を設定する
config.text_background_opacity = 0.9

-- ベルを無効化する
config.audible_bell = 'Disabled'

-- 色を変更する
config.colors = {
  -- カーソルの背景色
  cursor_bg = 'silver',
  -- カーソルの枠の色（フォーカスが外れた時に描画される）
  cursor_border = 'silver',
}

-- タブを非表示にする
config.enable_tab_bar = false

-- デフォルトのキーバインドを無効化する
-- https://wezfurlong.org/wezterm/config/default-keys.html
config.disable_default_key_bindings = true

if is_linux then
  -- フォントを変更する
  config.font = wezterm.font_with_fallback {
    'DejaVu Sans Mono',
    'Noto Sans Mono CJK JP',
  }
  config.font_size = 11
  -- ウィンドウの装飾を指定する
  config.window_decorations = 'TITLE | RESIZE'
  -- パディングをなくす
  config.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  }
end

if is_macos then
  -- フォントを変更する
  config.font = wezterm.font_with_fallback {
    'Menlo',
    'ヒラギノ角ゴシック',
  }
  config.font_size = 11
  -- cell_width = 0.996
  -- line_height = 1.0

  -- フルスクリーンを有効にする
  config.native_macos_fullscreen_mode = true

  -- Altキー（Optionキー）をコンポジションキーとする
  -- JIS配列では1つしかキーがないためtrueにしないと特定の文字が入力できない（例えば option + ; など）
  -- https://wezfurlong.org/wezterm/config/keyboard-concepts.html#macos-left-and-right-option-key
  config.send_composed_key_when_left_alt_is_pressed = true

  -- IMEへ送信する修飾キー
  -- Ctrl-hでIME入力中の文字列に対してBackspaceの挙動をしてほしい
  -- Alt-;で「…」をきちんとIMEに送信して欲しい
  -- https://github.com/wez/wezterm/pull/2435
  -- https://github.com/wez/wezterm/pull/2435#issuecomment-1491290065
  -- https://wezfurlong.org/wezterm/config/lua/config/macos_forward_to_ime_modifier_mask.html
  config.macos_forward_to_ime_modifier_mask = 'ALT|CTRL|SHIFT'
end

-- キーボードショートカットの設定
config.keys = config.keys or {}

-- コピー&ペースト
table.insert(config.keys, {
  key = 'c',
  mods = 'CMD',
  action = wezterm.action.CopyTo 'Clipboard'
})
table.insert(config.keys, {
  key = 'v',
  mods = 'CMD',
  action = wezterm.action.PasteFrom 'Clipboard'
})

-- フォントサイズ
table.insert(config.keys, {
  key = '-',
  mods = 'CMD',
  action = wezterm.action.DecreaseFontSize,
})
table.insert(config.keys, {
  key = '+',
  mods = 'CMD',
  action = wezterm.action.IncreaseFontSize,
})
table.insert(config.keys, {
  key = '0',
  mods = 'CMD',
  action = wezterm.action.ResetFontSize,
})

-- ウィンドウ
table.insert(config.keys, {
  key = 'n',
  mods = 'CMD',
  action = wezterm.action.SpawnWindow,
})

-- フルスクリーン
table.insert(config.keys, {
  key = 'f',
  mods = 'CMD|CTRL',
  action = wezterm.action.ToggleFullScreen,
})

-- デバッグパネル
table.insert(config.keys, {
  key = 'L',
  mods = 'CMD|CTRL',
  action = wezterm.action.ShowDebugOverlay,
})

-- コマンドパレット
table.insert(config.keys, {
  key = 'P',
  mods = 'CMD|CTRL',
  action = wezterm.action.ActivateCommandPalette,
})

return config
