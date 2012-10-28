; $Id: readme.txt 749 2007-03-13 15:48:27Z torihat $

 php-mode for xyzzy

 by Masashi Hattori

■ php-mode とは？

	xyzzy用のPHP書きモードです。
	ほとんどc++-modeの置換です。

	-- キーワードを色分け
	-- TABなどで自動インデント
	-- タグジャンプ
	-- 関数の一覧表示
	-- キーワードの補完
	-- マニュアル、ヘルプへジャンプ
	-- デバッグ

	などができたりできなかったりします。

	利用条件等に関しては、LICENSE.txtをご覧下さい。

■ インストール

    1. ファイルを展開する。

	-- php-mode.l, php-misc.l, php-xdebug.l をxyzzy/site-lisp に置いて
	   バイトコンパイルして下さい。
	-- PHP は xyzzy/etc に置いて下さい。

    2. .xyzzyなどに設定

	(load-library "php-mode")
	(pushnew '("\\.php$" . php-mode) *auto-mode-alist*)
	;; php-miscを使う場合
	(load-library "php-misc")
	(setq *php-html-help-path* "C:/xyzzy/etc/php_manual_ja.chm")

■ 使い方

	基本的な使い方は、xyzzyの他の言語モードと変わりません。

	[基本的なキーバインド]
		Enter			改行 ＋ インデント
		TAB			インデント
		ESC TAB			キーワード補完
		F4			タグジャンプ
		S-F4			タグジャンプを戻る

	[その他]
		M-x list-function	関数一覧の表示 ("listfn.l"がロードされている場合)

	[php-misc]
		F1			www.php.net のマニュアル表示 (設定でローカル等他の場所も可）
		S-F1			HTML Help版マニュアル表示
		C-c s			PHPUnit.php 用のスケルトン生成

	[php-xdebug]
		※ 設定に関しては以下の"Xdebug"を見てください。
		F5			デバッグ開始／終了
		F6			ブレークポイントまで、または最後まで実行
		F7			ブレークポイントを設定／解除
		C-F7			ブレークポイントを全て解除
		F8			変数を表示
		F9			変数を表示（値のみ）
		F10			step over
		F11			step into
		C-F11			step out
		F12			URLを指定してブラウザを起動

■ Xdebug

	Xdebug <http://www.xdebug.org/>を利用してリモートデバッグを行う事ができます。
	プロトコルはDBGpのみ対応しています。

	また、リモートとはいいつつ今のところローカルコンピューターのApache上のPHPしか
	デバッグできません。(*1)

	PHP側で以下のような設定をしてXdebugのリモートデバッグを有効にしてください。

	zend_extension_ts = "path_to_php_xdebug.dll"
	xdebug.remote_enable = On
	max_execution_time = 0    ; デバッグ中に終了されないため

	動作にはXdebugで配布されているのdebugclient.exeが必要です。入手してパスの通った
	ところに置いてください。

	xyzzy側では .xyzzy などに以下の設定を行ってください。また、xml-parser-modoki
	が必要ですので、別途インストールしておいてください。

	;; php-xdebugを使う場合
	(load-library "php-xdebug")
	;; phpの内部コード設定
	(setq *php-xdebug-encoding* *encoding-euc-jp*)  ; EUC-JPの場合
	;(setq *php-xdebug-encoding* *encoding-utf8n*)  ; UTF-8の場合

	上記の設定後にPHPファイルを開いて、PHP-Xdebugマイナーモードが有効になっている
	のを確認してください。

	デバッグは以下のように行います。

	1. F5 でdebugclient を起動。
	2. F12 でURLを入力してブラウザを起動後(*2)、xyzzyに戻る。
	3. ステップ実行したい場合はまずF11を押す。
	4. ブレークポイントを設定してそこまで進める場合は、
		- 設定したい場所で、F7を押す
		- F6を押す
	5. 変数の内容を表示したい場合にはF8またはF9を押して変数名を入力。
	6. stopped と表示されたら実行は終了していますので、ブラウザを操作して再度開始。
	7. デバッグを終了する時はF5を押す。

	(*1) 以下の関数を定義してローカルとリモートのパスをマッピングしてやれば、
	     動くかもしれません。
		- php-xdebug-map-remote-to-local
		- php-xdebug-map-local-to-remote
	(*2) ブラウザで直接URLを入力しても構いませんが、その場合にはURLに以下のパラメータ
	     を追加してください。

		XDEBUG_SESSION_START=xyzzy_php_xdebug


■ その他

	・キーワードファイルは、php-4.2.2 + 同梱のkeyword.php で生成したものです。
	  他のバージョンが必要な場合には、keyword.php を使って生成してください。

■ Changelog

	[2007/03/14]
	-- キーワードファイルにPHP5のキーワードを適当に追加。
	-- php-xdebug.l を追加。

	[2005/11/25]
	-- ライセンスを適用とか。

	[2004/04/10]
	-- php-misc.l の www.php.net のマニュアル表示の変更に追随。
	-- browserex.l をロードしている場合にはそちらで表示するようにした。
	-- キーワードファイル生成スクリプトサンプルを同梱。

	[2003/03/17]
	-- php-misc.lにHTML Help用コードを追加。

	[2003/02/03]
	-- キーワードファイルを少しアップデート。

	[2001/12/01]
	-- 小倉さんから頂いたキーワードファイルに差し替え。(__)
	-- php-misc.lを同梱。

	[2001/11/11]
	-- コメントとかをちょっといじった。
	-- キーワードから補完とか。

	[2000/05/22]
	-- xyzzy-0.2.1.143のindent-for-comment対応。

	[1999/11/20]
	-- xyzzy-0.1.1.111対応。
	-- list-functionを使えるようにした。
