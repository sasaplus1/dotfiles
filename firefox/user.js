// Ctrl+Tabをタブの並び順にする
user_pref('browser.ctrlTab.recentlyUsedOrder', false);

// ダウンロードファイルを最近使ったファイルに追加しない
user_pref('browser.download.manager.addToRecentDocs', false);

// ファイルダウンロード時にポップアップを表示する
user_pref('browser.download.panel.shown', true);

// Activity Streamの各種feedを非表示にする
user_pref('browser.newtabpage.activity-stream.feeds.section.highlights', false);
user_pref('browser.newtabpage.activity-stream.feeds.snippets', false);
user_pref('browser.newtabpage.activity-stream.feeds.topsites', false);

// 最後のタブを閉じれないようにする
user_pref('browser.tabs.closeWindowWithLastTab', false);

// ブラウザコンソールを有効にする
// https://developer.mozilla.org/ja/docs/Tools/Browser_Console
user_pref('devtools.chrome.enabled', true);

// おすすめの拡張機能を非表示にする
user_pref('extensions.htmlaboutaddons.recommendations.enabled', false)

// mailto:をクリックしてもメーラーを起動しない
user_pref('network.protocol-handler.external.mailto', false);

// userChrome.cssやuserContent.cssを使えるようにする
user_pref('toolkit.legacyUserProfileCustomizations.stylesheets', true);
