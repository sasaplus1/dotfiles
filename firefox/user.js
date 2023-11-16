// NOTE: see about:profiles

// ダウンロードファイルを最近使ったファイルに追加しない
user_pref('browser.download.manager.addToRecentDocs', false);

// ファイルダウンロード時にポップアップを表示する
user_pref('browser.download.panel.shown', true);

// Activity Streamの各種feedを非表示にする
user_pref('browser.newtabpage.activity-stream.feeds.section.highlights', false);
user_pref('browser.newtabpage.activity-stream.feeds.snippets', false);
user_pref('browser.newtabpage.activity-stream.feeds.topsites', false);

// ブラウザコンソールを有効にする
// https://developer.mozilla.org/ja/docs/Tools/Browser_Console
user_pref('devtools.chrome.enabled', true);

// ブラウザーツールボックスを有効にする
// https://firefox-source-docs.mozilla.org/devtools-user/browser_toolbox/index.html
user_pref('devtools.debugger.remote-enabled', true);

// おすすめの拡張機能を非表示にする
user_pref('extensions.htmlaboutaddons.recommendations.enabled', false)

// mailto:をクリックしてもメーラーを起動しない
user_pref('network.protocol-handler.external.mailto', false);

// userChrome.cssやuserContent.cssを使えるようにする
user_pref('toolkit.legacyUserProfileCustomizations.stylesheets', true);
