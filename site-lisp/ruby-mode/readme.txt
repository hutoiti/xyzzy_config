$Id: readme.txt,v 1.1.1.1 2005/11/25 13:06:17 torihat Exp $

 ruby-mode for xyzzy

 by Masashi Hattori

■ ruby-mode とは？

	xyzzy用のruby書きモードです。
	c-mode, c++-modeその他言語用モードを参考に作りました。

	-- キーワードを色分け
	-- TABなどで自動インデント
	-- タグジャンプ
	-- クラス、関数の一覧表示
	-- クラス名、関数名の補完

	などができたりできなかったりします。

	利用条件等は LICENSE.txt をご覧下さい。

■ インストール

    1. ファイルを展開する。

	-- *.lは xyzzy/site-lisp に置いて下さい。
	-- Ruby は xyzzy/etc に置いて下さい。

    2. バイトコンパイルする

	-- *.lをバイトコンパイル。

    3. .xyzzyなどに設定

	(load-library "ruby")
	(push '("\\.rb$" . ruby-mode) *auto-mode-alist*)
	; インデント量を変える
	;(setq *ruby-indent-column* 3)
	(load-library "ruby-lister")
	; rtags.rbまでのパス
	(setq *ruby-lister-rtags-path* "C:/ruby/rtags.rb")
	(load-library "ruby-debug")	;debugモードを使うなら
	(load-library "ruby-doc")	;rdモードを使うなら
	(load-library "ruby-misc")	;その他を使うなら
	; ri.rbまでのパス
	(setq *ruby-information-command* "C:/cygwin/usr/local/bin/ri.rb")

■ 問題点

	-- インデントがうまくいかない場合多々あり

■ Changelog

	[2005/11/25]
	-- ライセンスを適用とか。

	[2001/11/11]
	-- キーワードをちょっといじった
	-- ruby-misc.l追加。

	[2000/06/18]
	-- へなちょこRD用モードを追加。
	   なんかRD自体まだよくわかってないけど。

	   キーバインドを
		C-c d	=>	RDモード
		C-x d	=>	デバッグモード
	   に変えました。

	[2000/06/04]
	-- へなちょこデバッグモードを追加。

	[2000/05/22]
	-- xyzzy-0.2.1.143で追加されたindent-for-commentに対応。

	[2000/01/28]
	-- ESC TABでキーワードから補完できるようにした。

	[1999/11/19]
	-- xyzzy-0.1.1.111に対応。maketags.lをいじらなくても良くなった。

	[1999/11/16]
	-- infoを1.4のinfo対応に変更。

	[1999/10/15]
	-- 自動インデント時に "=begin ... =end" を無視するようにした（たぶん）。
	-- キーワード設定をちょっと変更。

	[1999/10/12]
	-- rtags.rbのTAGSファイルを利用したクラス、関数ツリー表示を作った。

	[1999/10/08]
	-- 久しぶりに使おうとしたらインデントが全然できなくなっていたので
	   直した。
	-- readme.txtを書いた。
	-- CVSで管理するようにした。
	-- MLで流れた亀井さんの関数一覧マクロ用にコードを追加した。

■ その他

	★ [F1] で infoから検索できるようにする。

		1. 山本さんのところからinfo.lを持って来て入れる。
			<http://www1.neweb.ne.jp/wa/sinj/xyzzy/>
		2. ruby-texi-1.4.tar.gzを取ってきてinfo.lから読めるようにする。
			<ftp://ftp.netlab.co.jp/pub/lang/ruby/doc/>など

	★ 関数一覧表示してジャンプ

		1. M-x list-function (C-c l)

	★ クラス、関数をツリー表示

		1. rtags.rbでTAGSファイルを作る
			-- rtags.rb はirbに含まれています。
				http://raa.ruby-lang.org/list.rhtml?name=irb-tools
			-- ruby-modeからなら M-x ruby-lister-make-rtags (C-c m)。
		2. M-x ruby-lister (C-F4)

	★ デバッグモード

		M-x ruby-debug (C-x d)でデバッグモードに入る。

		キーバインド

		Enter		コマンドなどを入力
		Y		(y/n)とかでyを入力
		N		(y/n)とかでnを入力
		q		デバッグモードを終了
		Q		デバッグモードを終了（確認なし）
		b		現在行にbreak pointを設定
		B		設定されているbreak pointを表示
		w		現在行にwatch pointを設定
		d		現在行に設定されているpointを解除
		D		設定されているpointをすべて解除
		e		displayを設定
		E		設定されているdisplayを表示
		u		displayを解除
		U		displayをすべて解除
		c		続行
		s		step
		C-u s		step（数入力）
		n		next
		C-u n		next（数入力）
		h		where
		C-Up		up
		C-Down		down
		f		finish
		p		pコマンド

	★ RD用モード

		M-x ruby-doc-minor-mode (C-c d)でモードに入る

		キーバインド

		Enter		改行してインデント
		TAB		インデント
		M-Left		インデントを減らす
		M-Right		インデントを増やす
		C-c f e		Insert Inline Emphasis
		C-c f c		Insert Inline Code
		C-c f v		Insert Inline Var
		C-c f k		Insert Inline Keyboard
		C-c f i		Insert Inline Index
		C-c f r		Insert Inline Reference
		c-c f u		Insert Inline URL
		C-c f f		Insert Inline Footnote
		C-c f b		Insert Inline Verb

	★ その他

		ruby-misc.lをロード

		キーバインド
		C-c x		スクリプトを走らせる
		C-c w		スクリプトのエラーチェック
		S-F1		riで引く
