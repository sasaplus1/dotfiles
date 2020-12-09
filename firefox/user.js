// ダウンロードファイルを最近使ったファイルに追加しない
user_pref('browser.download.manager.addToRecentDocs', false);

// 検索結果を新しいタブで開かない（デフォルト）
user_pref('browser.search.openintab', false);

// 最後のタブを閉じれないようにする
user_pref('browser.tabs.closeWindowWithLastTab', false);

// mailto:をクリックしてもメーラーを起動しない
user_pref('network.protocol-handler.external.mailto', false);

// userChrome.cssやuserContent.cssを使えるようにする
user_pref('toolkit.legacyUserProfileCustomizations.stylesheets', true);
