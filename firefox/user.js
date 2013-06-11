// 閉じるボタンを右端にのみ表示する
user_pref("browser.tabs.closeButtons", 3);

// 検索結果を新しいタブで開く
user_pref("browser.search.openintab", true);

// mailto:をクリックしてもメーラーを起動しない
user_pref("network.protocol-handler.external.mailto", false);

// ダウンロード終了後の通知を消す
user_pref("browser.download.manager.showAlertOnComplete", false);

// JavaScriptのエラー表示を厳密にする
user_pref("javascript.options.strict", true);

// ダウンロードファイルを最近使ったファイルに追加しない
user_pref("browser.download.manager.addToRecentDocs", false);

// 最後のタブを閉じれないようにする
user_pref("browser.tabs.closeWindowWithLastTab", false);

// URLバーをクリックしたときURLを全選択しない
user_pref("browser.urlbar.clickSelectsAll", false);

// タブのアニメーションをしない
user_pref("browser.tabs.animate", false);

// タブをツルーバー下にする
user_pref("browser.tabs.onTop", false);
