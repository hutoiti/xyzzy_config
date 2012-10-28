$Id: readme.txt,v 1.4 2005/11/24 15:12:27 torihat Exp $

 www-mode for xyzzy

 by HATTORI Masashi


■ www-mode とは？

	xyzzy上で動くへなちょこWWW Browserです。
	動かなかったり、まだ作ってない部分が多々あります。
	利用条件等に関しては、LICENSE.txtをご覧下さい。

■ 動作環境

	xyzzy-0.2.0.160以降

■ インストール

    1. ファイルを展開する。

	-- *.l は xyzzy/site-lisp/www/ 以下に置いて下さい。
	-- bookmark.html は xyzzy/etc に置いて下さい。

    2. バイトコンパイルする

	-- www/makefile.lをロードしてから M-x www-makeして下さい。

		バージョンアップしてエラーが出た時には、一度 www/*.lcを消してから
		xyzzyを再起動してバイトコンパイルして下さい。

    3. 設定

	-- ~/.xyzzy		同梱のsample.xyzzyを見て下さい。
	-- ~/.www		同梱のsample.wwwを見て下さい。

    4. M-x www などとして起動する。

■ 操作方法

	------------------------------------------------------------------
	[表示画面]

	(キー一覧)

	Enter		カーソル位置のリンク先を開く
			またはフォームオブジェクトの操作
	クリック	同上
	Space		次ページ
	n		同上
	b		前ページ
	g		URLを指定して開く
	f		ローカルファイルを開く
	s		リンク先をダウンロード
	C-u s		リンク先をダウンロード(Pragma: no-cache付)
	w		リンク先をwgetでダウンロード
	L		リンク先のURLを表示
	TAB		次のリンク位置またはフォームオブジェクトへ移動
	M-Down		同上
	M-Up		前のリンク位置またはフォームオブジェクトへ移動
	M-Left		戻る
	M-Right		進む
	h		ページのリストをポップアップして選択
	C-F10		同上
	R		再読込
	r		漢字コードを指定して再表示
	O		現在のページを標準のブラウザで開く
	o		リンクを標準のブラウザで開く
	S		ページのソースを表示
	B		bookmarkを開く
	A		現在のページをbookmarkに追加
	u		ページ更新一覧を開く
	U		現在のページを更新一覧に追加
	q		www-modeを終了する（確認あり）
	Q		www-modeを終了する（確認なし）

	------------------------------------------------------------------
	[ソース表示画面]

	(キー一覧)

	Enter		表示画面へ戻る
	q		www-modeを終了する（確認あり）
	Q		www-modeを終了する（確認なし）

	------------------------------------------------------------------

■ ページ更新一覧

	登録しておいたページの更新日時を調べて並べ替えて一覧表示します。

	記録ファイルは*www-update-data-file*（初期値はupdate.html）です。
	M-x www-update-convert-from-bookmark で、bookmarkから変換するか、
	ページを開いておいて、"U" で追加するか、直接開いて編集して作成して
	下さい。

	更新するには M-x www-update-pages して下さい。（www-modeから "u"）

	※ Last-modified ヘッダーを返さないページは更新日時を取得できません。

■ その他

	★Internet Explorerのお気に入りをbookmark.htmlにインポート

		M-x load-library[Enter]
		Load-library: www/import-favorites[Enter]
		M-x www-import-favorites[Enter]

■ 問題点

	-- いろいろたくさん

	ループに入って操作を受け付けなくなったときには、xyzzyを終了して下さい。

■ できたらいいなと思っていること

	-- tableの描画
	-- frameを実装

	-- その他いろいろ

■ 謝辞

	これを作成するにあたって、xyzzy の作者亀井さんをはじめ、いろいろな方々
	にアドバイス、パッチなどのご協力を頂きました。ありがとうございました。
