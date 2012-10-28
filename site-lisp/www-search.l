#|
version  2006.10.14
category Utilities

■説明
google 検索などをするメニューと、新たな検索コマンドを作るマクロ。

■手動インストール方法
1. www-search.l と www-search.lc を ~/site-lisp に移動。
2. ~/.xyzzy か ~/site-lisp/siteinit.l に次の一文を追加。
   (require "www-search")
3. xyzzy を再起動。
   ~/site-lisp/siteinit.l に書いたのなら
   Ctrl と Shift を押しながら xyzzy を起動して再ダンプ。

■アンインストール方法
NetInstaller で インストールしたときは、
NetInstaller 内で www-search を選択して d を押す。

手動でインストールしたときは、
1. ESC ESC と入力。
2. (www-search-uninstall) と入力。
3. .xyzzy か siteinit.l に書いた (require "www-search") を削除。
4. ~/site-lisp の www-search.l と www-search.lc を削除。
5. 必要があればCtrl と Shift を押しながら xyzzy を起動して再ダンプ。

■使い方
□M-x やキーバインドなどで使えるもの

表示(V) > ツールバー(Q) > www-search(W) のツールバーで呼び出すか
M-x → google とか、(global-set-key '(#\C-c #\g) 'google) とか。

・google
  選択文字列が存在していたらそれを検索、
  そうでなければミニバッファで入力した文字列を検索
  (google "なんとかかんとか")としても検索できる。
・google1
  ミニバッファで入力した文字列をgoogle検索する。
  (google1 "なんとかかんとか")としても検索できる。
・google-selection
  選択文字列が存在したらそれを google 検索する。
  そうでなければ何もせず nil を返す
・wikipedia-jp
  上記の google のやつの wikipedia 日本語版用。
  wikipedia-jp1 やら wikipedia-jp-selection やらもあるが説明は省略。
・kokugo ruigo eiwa waei
  なんかそういう辞典

・www-search-popup
  ポップアップメニューを表示する。

□Lisp で使うもの

・www-search-define
  interactive な検索用関数を作る。
  .xyzzy か siteinit.l で (require "www-search") としていたとき、
  (www-search-define "google"
		     "http://www.google.co.jp/search?lr=lang_ja&q="
		     "Google(&G)"
		     map-internal-to-utf-8)
  のようにすると、google google1 google-selectionの
  三つの関数が現在のパッケージ内に勝手に作られて export される。
  さらに関数の情報が *www-search-data* に追加される。
  あと *www-search-define-hook* も。
  "Google(&G)" というのはメニュー作成に使われる。
  エンコードは無指定なら euc。
  指定するときは map-internal-to-utf-8 などの ~/lisp/encoding.l 内の関数を使う。

・www-search-unregister
  (www-search-unregister 'google) とすると、
  google がメニューに表示されないようにする。
  別の言い方をすると *www-search-data* から除外する。

・*www-search-hook*
  実行されたときに使う関数。funcall で呼び出されるので setq すること。
  例：ブラウザじゃなく www-mode で開く。
  (setq *www-search-hook* #'www-open-url)

■更新履歴
2006.10.14 辞書を変更。
           www-search-unregister を追加。
2006.09.04 completing-read の :history をまともに。
2006.08.01 無指定時のエンコードを euc に変更。
           *www-search-hook* を追加。ブラウザ以外で開けるようにした。
2006.04.21 メニューがまずかったのを修正。*www-search-menu* を廃止。
2006.04.16 関数名変数名を変更。
           インデント方法を xyzzy 標準のものに。
           カテゴリを変更。
2006.03.20 アンインストール方法を変更。
2006.03.15 公開。

■ライセンス
Copyright (c) 2006, sazasaza.  All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in
   the documentation and/or other materials provided with the
   distribution.

3. Neither the name of the University nor the names of its
   contributors may be used to endorse or promote products derived
   from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
|#

(provide "www-search")
(in-package "editor")
(export '(www-search-default-hook
	  www-search-define
	  www-search-unregister
	  www-search-menu
	  www-search-popup
	  www-search-bar
	  www-search-uninstall
	  *www-search-hook*
	  *www-search-data*
	  *www-search-history*
	  *www-search-define-hook*))

(defvar *www-search-hook* nil
  "www-search: 開くときの処理。funcall で呼び出されるので setq すること")
(defun www-search-default-hook (url)
  (shell-execute url t))
(unless *www-search-hook*
  (setq *www-search-hook* #'www-search-default-hook))

(defvar *www-search-data* nil)
(define-history-variable *www-search-history* '())

(setf (get :www-search 'minibuffer-history-variable) '*www-search-history*)

(defvar *www-search-define-hook* nil)

(defmacro www-search-define (fnname url caption &optional (e 'map-internal-to-euc))
  (let ((fn (intern fnname))
	(fn1 (intern (concat fnname "1")))
	(selection (intern (concat fnname "-selection")))
	(s (gensym)))
    `(progn
       (export '(,fn1
		 ,fn
		 ,selection))
       (defun ,fn1 (&optional (str (completing-read (concat ,(string-capitalize fnname)
							    ": ")
						    *www-search-history*
						    :history :www-search)))
	 (interactive)
	 (funcall *www-search-hook* (concat ,url
					    (si:www-url-encode (,e str)))))
       (defun ,selection ()
	 (interactive)
	 (if (pre-selection-p)
	     (selection-start-end (a b)
	       (,fn (buffer-substring a b)))
	   nil))
       (defun ,fn (&optional str)
	 (interactive)
	 (if str
	     (,fn1 str)
	   (unless (,selection)
	     (call-interactively ',fn1))))
       (let ((,s (find ',fn *www-search-data* :key #'car)))
	 ;既に fnname と同じものが www-search-define されていたら内容を置き換える。
	 (if ,s
	     (setf (cdddr ,s) '(,url ,caption ,e))
	   (setq *www-search-data*
		 (nconc *www-search-data*
			'((,fn ,fn1 ,selection ,url ,caption ,e)))))
	 (run-hook-with-args '*www-search-define-hook*
			     (null ,s) ',fn ',fn1 ',selection ',url ',caption ',e)
	 *www-search-data*)
       )))

(defun www-search-unregister (fn)
  "*www-search-data*から消してメニューで表示しなくする。"
  (setq *www-search-data*
	(delete fn
		*www-search-data*
		:key #'car)))

(defun www-search-menu ()
  (let ((menu (create-popup-menu :www-search)))
    (dolist (x *www-search-data*)
      (add-menu-item menu nil (fifth x) (car x)))
    menu))

(defun www-search-popup (&optional (any :button2))
  (interactive)
  (track-popup-menu (www-search-menu) any))

(defun www-search-bar ()
  (create-tool-bar 'www-search-bar
		   (merge-pathnames "toolbar.bmp" (etc-path))
		   '(("www-search" 41 www-search-popup))))
(define-command-bar 'www-search-bar "www-search(&W)")

(defun www-search-uninstall ()
  (delete-command-bar 'www-search-bar)
  (unregister-history-variable '*www-search-history*))

(www-search-define "google"
		   "http://www.google.co.jp/search?lr=lang_ja&q="
		   "Google(&G)"
		   map-internal-to-utf-8)
(www-search-define "wikipedia-jp"
		   "http://ja.wikipedia.org/wiki/%E7%89%B9%E5%88%A5:Search?search="
		   "Wikipedia-jp(&W)"
		   map-internal-to-utf-8)
(www-search-define "kokugo"
		   "http://dic.yahoo.co.jp/dsearch?stype=0&dtype=0&p="
		   "国語(&K)")
(www-search-define "ruigo"
		   "http://dic.yahoo.co.jp/dsearch?stype=0&dtype=5&p="
		   "類語(&R)")
(www-search-define "eiwa"
		   "http://dic.yahoo.co.jp/dsearch?stype=0&dtype=1&p="
		   "英和(&E)")
(www-search-define "waei"
		   "http://dic.yahoo.co.jp/dsearch?stype=0&dtype=3&p="
		   "和英(&J)")
