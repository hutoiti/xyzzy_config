;;; -*- Mode: Lisp; Package: EDITOR; Last modified: <2007/12/31 01:16:01> -*-
;;;
;;; This file is not part of xyzzy.
;;;
;;;   winbatch-mode.l --- Simple mode for Batch File Enhancer for Windows (WinBatchEh)
;;;
;;;     by HIE Masahiro <madoinu@ybb.ne.jp>
#|

■概要

  WinBatchEh 用のモード。

  OHKUBO Hiroshi さんの bat-mode.l をベースに WinBatchEh 用の改造品
  をつくってみた。

  清水 洋平さんにもいろいろとアドバイスを頂きました。感謝です。

  その他、参考にさせていただいたもの。（とか、ほぼそのまま使わせて
  いただいたもの。）
  
    htmlmode.l
    php-mode.l
    csv-mode.l
    xyzzy ML
    その他沢山...

  多くの有用なコードを公開して頂いている諸先輩方に多謝。


■使用上の注意

  ・WinBatchEh の実行パスは、レジストリ(のたぶん関連付けの部分)から
    取得するようにしてみたが、起動しない場合および関連付けのしてな
    い場合は、*winbatch-path* を直接指定しないといけないと思う。
  
      例: (setq *winbatch-path* "c:/utility/winbatch/")
  
  ・インラインコメントには、// か # のどちらかしか指定できない。
  
  ・フラッグ(MB_* とか)の補完も一応できるが、
      MESSAGEBOX=MB_
    まで記述して C-. しても No match になってしまう。しかし、
      MESSAGEBOX= MB_
    などとしておく(= の後にスペースをいれておく)とできなくもない。
    が、後でスペースを除かないといけないので、やはり面倒なのでつかえな
    いかも。
  
  ・コマンドのキーワード補完は、小文字でのみ有効。大文字でしたい
    場合は、キーワードファイル (WINBATCH) 中のキーワードを大文字
    にすれば良いと思う。（フラッグとかは大文字）
  
  ・フラッグの色付けは、先頭が GCD,MB,OFN,SC,SPI,SPIF,STF,SW,VK,WM + _
    で始まる単語全てに対して行っているので、実際には存在しないフラグと
    かにも色付けされる。
  
  ・ラベルとコメントの色分けはだいたいでしている。
  
  ・WinBatchEh の掲示板のアドレスは、サーバの負荷状況などにより変更
    されることがあるそうなので、リンク（メニューに表示）したい場合は、
    自分で *winbatch-forum-url* を設定する必要あり。デフォルトでは、
    表示しない。
  
  ・Lisp も WinBatchEh も良く解からないまま作っているので、怪しい。


■インストール

  1. winbatch-mode.l を ~/site-lisp に、WINBATCH を ~/etc に
     コピーする。

  2. 必要ならばバイトコンパイルする。

  3. *.btw を読みこんだときに自動的に batch-mode にするために、
     以下のコードを初期化ファイルに追加する(たぶん)。

     ○ .xyzzyに追加する場合
           (export 'ed::winbatch-mode "ed")
           (autoload 'winbatch-mode "winbatch-mode" t)
           (pushnew '("\\.btw$" . winbatch-mode) *auto-mode-alist* :test 'equal)

     ○ siteinit.lに追加する場合
           (in-package "editor")
           (export 'winbatch-mode)
           (autoload 'winbatch-mode "winbatch-mode" t)
           (pushnew '("\\.btw$" . winbatch-mode) *auto-mode-alist* :test 'equal)
           (in-package "user")

   4. 補完をポップアップ一覧表示をする場合は、以下のコードを初期化
      ファイルに追加する。

           (setq *popup-completion-list-default* :always)

   5. 上記の設定を反映させるために、xyzzyを再起動する。


■使い方

  M-x winbatch-mode

  スクリプトを実行または開く場合に、パラメータを指定する場合は、
  Parameters: 欄に入力する。複数指定する場合は、半角スペース区切り
  で、半角スペースを持った文字列を指定する場合は、"" でくくって指定
  する。パラメータが不要な場合は、未入力のまま Enter で OK。


■キーバインド

  F1       ヘルプを検索
  C-.      キーワード補完
  C-;      セレクションがあればセレクションにコメント文字列を挿入、
           なければ現在行のコメントをトグル
  M-C-;    セレクションのコメント文字列を削除
  C-c x    スクリプト実行
  C-c o    スクリプトを winbat32.exe で開く
  C-c c    ファイル名をクリップボードにコピーして、コンパイラを起動


■設定例

  ;; コメント文字列 ("REM " or ":/ ")
  (setq *winbatch-mode-comment-start* ":/ ")
  
  ;; インラインコメント文字列 ("//", "#" or nil)
  (setq *winbatch-inlinecomment-string* "#")
  
  ;; スクリプト実行時などにファイルを保存
  (setq *winbatch-auto-save* nil)
  
  ;; WinBatchEh 掲示板のページをメニューに表示 (nil or "url")
  (setq *winbatch-forum-url* "http://hpcgi3.nifty.com/b7/bbs/wforum.cgi")
  
  ;; 改行時前の行に合わせてインデント
  (setq *winbatch-use-newline-and-indent* t)

  ;; WinBatchEh スクリプト保存フォルダ（ex: c:\winbatch\data\ の場合）
  (setq *winbatch-script-directory* "c:/winbatch/data/")


■更新履歴

  [Version 1.16] 2007-12-31 (月)
  ・ライセンス条項(MITライセンス)を記載。

  [Version 1.15] 2002/09/21 01:58:52 +0900
  ・winbatch-open-filer を追加した。
      primary-directory:   表示中のファイルのあるフォルダ
      secondary-directory: *winbatch-script-directory* に指定したフォルダ
    がひらく。
  ・WinBatchEh のパスを local-machine でなく classes-root から取得
    するようにした。
  ・その他細かな変更。
  ・（それに、はじめて list を使ってみた。）

  [Version 1.14.1] 2002/09/15 12:06:01 +0900
  ・補完のポップアップ一覧表示の設定は、必要な部分のみとした(つもり)。

  [Version 1.14] 2002/09/15 00:14:46 +0900
  ・WinBatchEh を持っていないと、起動時にエラーになるのを修正した。
  ・補完の一覧表示は、山本 泰三さんの Tips を使っていたのを今頃思
    い出し、説明文を追加した。

  [Version 1.12] 2002/09/14 09:53:55 +0900
  ・スクリプトの実行、開く時の引数指定に、minibuffer-prompt を使
    わないようにした。
  ・*winbatch-auto-save* の既定値を t にした。
  
  [Version 1.11] 2002/09/12 22:21:07 +0900
  ・無駄に増えたコメントを別ファイルにして削り取った。
  ・その他役に立たない変更。
  
  [Version 1.10] 2002/09/11 23:18:52 +0900
  ・あまりにも bat-mode に染まってしまったので、bat-mode をベースと
    して書き直した。
  ・*winbatch-regexp-keyword-list* を見直した。
  ・ファイル実行時、保存されてない場合は、保存することもできるように
    した。 → *winbatch-auto-save*
  ・batch-mode → winbatch-mode に変更した。（本来の目的だったフツー
    の(?)バッチファイルで使用する必要も無いので）。
  
  [Version 1.09] 2002/09/03 10:36:05 +0900
  ・やっぱり迷惑かもしれないので、掲示板の表示はしたい場合だけ、自
    分でするようにした。→ *winbatch-forum-url*
  ・もしかしたらカスタマイズするかもしれないあたりを export した。
  
  [Version 1.08] 2002/09/03 06:27:27 +0900
  ・コメント文字列の挿入、削除の方法を変更した。また、:/ も使用で
    きるようにした。
  ・キーバインドが標準的(?)でなかったのを変更した。
  ・その他細かな変更および注意書きの追加。
  
  [Version 1.07] 2002/09/02 10:58:10 +0900
  ・ベーカー街の物置(http://members.tripod.co.jp/mystery_trick_room/)
    をみて、目から鱗。ヘルプの検索がこんな簡単にできたなんて...。
  
  [Version 1.06] 2002/09/02(月)
  ・winbat32.exe へ渡すファイル名を"" でくくるようにした。
  ・コメント文とラベル行の色付け方法を変更した。
  
  [Version 1.05] 2002/09/01(日)
  ・清水 洋平さんに教えていただいた方法を使って、WinBatchHelp.btw
    を使わなくてもヘルプ検索ができるようになった。（APIを直接呼び
    出す方法であれば、もしかしたら WinBatchEh を使わなくても xyzzy
    から直接実行できるのか？）
  
  [Version 1.04] 2002/08/30(金)
  ・レジストリから WinBatchEh のインストールディレクトリを取得する
    ようにした。
  ・コンパイラを起動とか、掲示板を表示とかつけた。
  
  [Version 1.03] 2002/08/29(木)
  ・csv-mode を参考に、ローカルなメニューをつけた。
  
  [Version 1.02] 2002/08/28(水)
  ・bat-mode から indent あたりをもらった。
    ほとんど、bat-mode ベースの改造品になった。
  ・winbatch-open-script を追加した。
  ・batch-search-help-selection に、winbat32.exe または
    WinBatchHelp.btw がない場合の処理を追加した。
  ・その他細かい修正。
  
  [Version 1.01] 2002/08/12(月)
  ・version の入ったおかしな mode-name をやめた。
  ・色付けをいくらか変更した
  
  [Version 1.00] 2002/08/11(日)
  ・winbatch-run-script を追加した。
  
  [Version 0.4] 2002/08/10(土)
  ・:/ をコメント文字列として認識するようにした。
  ・inlinecomment として、// か # のどちらかを使用できるようにした。
    既定値は、// 。
  
  [Version 0.3] 2002/08/10(土)
  ・batch-encomment-selection, batch-outcomment-selection
    を追加した。
  
  [Version 0.2] 2002/08/08(木)
  ・my-bat-mode から batch-mode に変更。
  ・search-winbatch-help-selection を追加した。（要 WinBatchEh）
  ・bat-mode から、*bat-regexp-keyword-list* あたりを頂いた。
  ・php-mode から、"キーワードから補完" を頂いた。
  ・htmlmode.l からの不要と思われるあたりを削除した。
  
  [Version 0.1]
  ・htmlmode.l のキーワード定義のみを変更してとりあえずつくった。


■ライセンス

  winbatch-mode.l はMITライセンスに基づいて利用可能です。
  <http://www.opensource.org/licenses/mit-license.php>

Copyright (c) 2002-2007 HIE Masahiro

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

|#

(provide "winbatch-mode")

(in-package "editor")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (export '(*winbatch-mode-hook*
            *winbatch-mode-map*
            *winbatch-mode-version*
            *winbatch-keyword-file*
            *winbatch-keyword-file-use*
            *winbatch-regexp-keyword-list*
            *winbatch-mode-comment-start*
            *winbatch-comment-column*
            *winbatch-mode-abbrev-table*
	    *winbatch-inlinecomment-string*
	    *winbatch-use-newline-and-indent*
	    *winbatch-path*
	    *winbatch-auto-save*
	    *winbatch-home-url*
	    *winbatch-forum-url*
	    )))
(eval-when (:compile-toplevel :load-toplevel :execute)
  (export '(winbatch-mode
            winbatch-indent-line
            winbatch-newline-and-indent
	    winbatch-comment-indent
	    winbatch-completion
	    winbatch-encomment-selection-or-comment-toggle-line
	    winbatch-outcomment-selection
	    winbatch-show-winhelp
	    winbatch-run-script
	    winbatch-open-script
	    winbatch-compile-script
	    )))

(defconstant *winbatch-mode-version* "1.15")

;; キーワードファイルを使用
(defvar *winbatch-keyword-file-use* t)

;; コメント文字列 ("REM " or ":/ ")
(defvar *winbatch-mode-comment-start* "REM ")

;; インラインコメント文字列 ("//", "#" or nil)
;;   使用しない場合は、nil を設定
(defvar *winbatch-inlinecomment-string* "//")

;; スクリプト実行時などにファイルを保存
(defvar *winbatch-auto-save* t)

;; 改行時前の行に合わせてインデント
(defvar *winbatch-use-newline-and-indent* nil)

;; 清水 洋平さんのぺーじ
(defvar *winbatch-home-url* "http://www.vector.co.jp/authors/VA000007/")

;; WinBatchEh 掲示板のページ (nil or "url")
(defvar *winbatch-forum-url* nil)

;; WinBatchEh のインストールディレクトリ
(defvar *winbatch-path*
  (let (list)
    (setq list
	  (let ((result nil))
	    (dolist (item '(".BTW\\shell\\open\\command"
			    "BTW_auto_file\\shell\\open\\command")
			  (nreverse result))
	      (push
	       (let ((p (read-registry item "" :classes-root)))
		 (if p
		     (map-backslash-to-slash
		      (substring p 0 (string-match "[wW][iI][nN][bB][aA][tT]32.[eE][xX][eE]" p)))))
	       result))))
    ;list がうまくつかえない...
    (let ((path1 (car list))
	  (path2 (cadr list)))
      (or path1 path2 ""))))

;; WinBatchEh スクリプト保存ディレクトリ
(defvar *winbatch-script-directory* (concat *winbatch-path* "sample/"))

;; winbat32.exe のフルパス
(defvar *winbatch-prog* (merge-pathnames "winbat32.exe" *winbatch-path*))

;; wbatcp.exe のフルパス
(defvar *winbatch-compiler-prog* (merge-pathnames "wbatcp.exe" *winbatch-path*))

;; ヘルプファイルのフルパス
(defvar *winbatch-winhelp-file* (merge-pathnames "winbat32.hlp" *winbatch-path*))

;; 色設定
;コメント
(defvar *winbatch-comment-color* '(:keyword :comment))
;ラベル
(defvar *winbatch-lavel-color* '(:color 1 0))
;GOTO のラベル
(defvar *winbatch-goto-label-color* '(:color 1 0))
;ECHO 本体
(defvar *winbatch-echo-color* '(:color 15 0))
;エコー抑止
(defvar *winbatch-echo-stop-color* '(:keyword 1))
;ループ変数
(defvar *winbatch-loop-variable-color* '(:color 14 0))
;引数
(defvar *winbatch-argument-color* '(:color 14 0))
;変数
(defvar *winbatch-variable-color* '(:color 14 0))
;変数参照
(defvar *winbatch-variable-reference-color* '(:color 14 0))
;keyword 0
(defvar *winbatch-keyword0-color* '(:keyword 0))
;keyword 2
(defvar *winbatch-keyword2-color* '(:keyword 2))
;フラグ
(defvar *winbatch-flag-color* '(:color  9 0))

;; startup message
(defvar *winbatch-startup-message* t)

(defvar *winbatch-mode-hook* nil)
(defvar *winbatch-keyword-hash-table* nil)
(defvar *winbatch-keyword-file* "WINBATCH")
(defvar *winbatch-completion-list* nil)

(defvar *winbatch-mode-map* nil)
(unless *winbatch-mode-map*
  (setq *winbatch-mode-map* (make-sparse-keymap))
  (define-key *winbatch-mode-map*   #\F1       'winbatch-show-winhelp)
  (define-key *winbatch-mode-map*   #\TAB      'winbatch-indent-line)
  (if *winbatch-use-newline-and-indent*
      (define-key *winbatch-mode-map* #\RET    'winbatch-newline-and-indent))
  (define-key *winbatch-mode-map*   #\C-.      'winbatch-completion)
  (define-key *winbatch-mode-map*   #\C-\;     'winbatch-encomment-selection-or-comment-toggle-line)
  (define-key *winbatch-mode-map*   #\M-\C-\;  'winbatch-outcomment-selection)
  (define-key *winbatch-mode-map* '(#\C-c #\x) 'winbatch-run-script)
  (define-key *winbatch-mode-map* '(#\C-c #\o) 'winbatch-open-script)
  (define-key *winbatch-mode-map* '(#\C-c #\c) 'winbatch-compile-script)
  (define-key *winbatch-mode-map* '(#\C-c #\f) 'winbatch-open-filer)
  (define-key *winbatch-mode-map* '(#\C-c #\?) 'winbatch-mode-show-version))

(defvar *winbatch-mode-abbrev-table* nil)
(unless *winbatch-mode-abbrev-table*
  (define-abbrev-table '*winbatch-mode-abbrev-table*))

(defvar *winbatch-mode-syntax-table* nil)
(unless *winbatch-mode-syntax-table*
  (setq *winbatch-mode-syntax-table* (make-syntax-table))
  (cond ((string= *winbatch-inlinecomment-string* "//")
	 (progn
	   (set-syntax-start-c++-comment *winbatch-mode-syntax-table* #\/)
	   (set-syntax-end-c++-comment *winbatch-mode-syntax-table* #\LFD)))
	((string= *winbatch-inlinecomment-string* "#")
	 (progn
	   (set-syntax-start-comment *winbatch-mode-syntax-table* #\#)
	   (set-syntax-end-comment *winbatch-mode-syntax-table* #\LFD))))
  (set-syntax-string *winbatch-mode-syntax-table* #\")
  (set-syntax-string *winbatch-mode-syntax-table* #\'))

(defvar *winbatch-regexp-keyword-list* nil)

(setq *winbatch-regexp-keyword-list*
  (compile-regexp-keyword-list
   `(
     ;ラベル行
     (,(concat "^[ \t]*\\(:[^/ \t\n]+\\)"
	       "\\(?:[ \t]\\(.*\\)\\)?") t ((1 . ,*winbatch-lavel-color*)
					    (2 . ,*winbatch-comment-color*)))
     ;エコー抑止
     ("^[ \t]*\\(@\\)" t ((1 . ,*winbatch-echo-stop-color*)))
     ;コメント
     ("\\<\\(REM\\)\\>\\(?:[ \t]\\(.*\\)\\)?" t ,*winbatch-comment-color*)
     ;ラベル行にマッチしなかった:で始まる行はコメント文
     ("^[ \t]*:.*" t ,*winbatch-comment-color*)
     ;引数
     ("%[0-9]" nil ,*winbatch-argument-color*)
     ;ループ変数
     ("%%[a-zA-Z]" nil ,*winbatch-loop-variable-color*)
     ;変数
     ("%@*[a-zA-Z][a-zA-Z0-9_]*\\(\\[[0-9]+\\]\\)*%" nil ,*winbatch-variable-reference-color*)
     ;goto, gosub
     (,(concat "\\<\\(GOTO\\|GOSUB\\)\\>"
	       "\\(?:[ \t]+\\([^/ \t\n]+\\)\\)?"
	       "\\(?:[ \t]+\\(.*\\)\\)?") t ((1 . ,*winbatch-keyword0-color*)
					     (2 . ,*winbatch-goto-label-color*)
					     (3 . ,*winbatch-comment-color*)))
     ;echo
     ("\\<\\(ECHO\\)[ \t]+\\(ON\\|OFF\\)[ \t]*$" t ((0 . ,*winbatch-keyword2-color*)))
     (,(concat "\\<\\(ECHO\\.?\\)\\>"
               "\\(?:[ \t]\\(.*\\)\\)?") t ((1 . ,*winbatch-keyword2-color*)
                                            (2 . ,*winbatch-echo-color*)))
     ;set
     ("\\<\\(SET\\)\\(?:[ \t]+\\([^=\n]+\\)\\(?:=\\)?\\)?" t ((1 . ,*winbatch-keyword2-color*)
							      (2 . ,*winbatch-variable-color*)))
     ;ドライブ指定
     ("^[ \t]*\\([a-zA-Z]:$\\|[a-zA-Z]: \\)" t ,*winbatch-keyword2-color*)
     ;...
     ("\\(winbat\\(?:32\\|ch\\)\\) *==" t ((1 . ,*winbatch-keyword0-color*)))
     ;フラグ
     ("\\(GCD\\|MB\\|OFN\\|SC\\|SPI\\|SPIF\\|STF\\|SW\\|VK\\|WM\\)_[A-Z]+[0-9]*" t ,*winbatch-flag-color*)
     )))

;; モードの設定
(defun winbatch-mode ()
  (interactive)
  (kill-all-local-variables)
  (if *winbatch-startup-message*
      (message "WinBatchEh mode ~A for xyzzy."
	       *winbatch-mode-version*))
  (setq buffer-mode 'winbatch-mode)
  (setq mode-name "WinBatchEh")
  (use-keymap *winbatch-mode-map*)
  (use-syntax-table *winbatch-mode-syntax-table*)

  (make-local-variable 'mode-specific-indent-command)
  (setq mode-specific-indent-command 'winbatch-indent-line)

  (cond
   (*winbatch-keyword-file-use*
    (and *winbatch-keyword-file*
         (null *winbatch-keyword-hash-table*)
         (setq *winbatch-keyword-hash-table*
               (load-keyword-file *winbatch-keyword-file* t)))
    (when *winbatch-keyword-hash-table*
      (make-local-variable 'keyword-hash-table)
      (setq keyword-hash-table *winbatch-keyword-hash-table*)))
   (t
    (make-local-variable 'keyword-hash-table)
    (setq keyword-hash-table '())))

  (make-local-variable 'regexp-keyword-list)
  (setq regexp-keyword-list *winbatch-regexp-keyword-list*)
  
  (setq *local-abbrev-table* *winbatch-mode-abbrev-table*)
  (winbatch-menu-update)
  (run-hooks '*winbatch-mode-hook*))

(defun winbatch-newline-and-indent (&optional (arg 1))
  "改行＋インデント付け"
  (interactive "*p")
  (insert #\LFD arg)
  (winbatch-indent-line))

(defun winbatch-indent-line ()
  "現在のインデント付け"
  (interactive "*")
  (if (save-excursion
        (skip-chars-backward " \t")
        (bolp))
      (let ((column 0))
        (save-excursion
          (while (forward-line -1)
            (unless (progn
                      (skip-chars-forward " \t")
                      (eolp))
              (skip-chars-forward " \t")
              (setq column (current-column))
              (return))))
        (smart-indentation column)
        (skip-chars-forward " \t"))
    (insert "\t")))

;php-mode から。
(defun winbatch-completion ()
  "キーワードから補完"
  (interactive)
  (or *winbatch-completion-list*
      (setq *winbatch-completion-list* (make-list-from-keyword-table *winbatch-keyword-hash-table*))
      (return-from winbatch-completion nil))
  (let ((opoint (point)))
    (when (skip-syntax-spec-backward "w_.")
      (let ((from (point)))
	(goto-char opoint)
	(do-completion from opoint :list *winbatch-completion-list*)))))

;[xyzzy:06776] より。
(defun winbatch-encomment-selection-or-comment-toggle-line ()
  "コメント文字列を挿入またはトグル"
  (interactive)
  (if (pre-selection-p)
      ;セレクションがあれば、選択範囲の行頭にコメント文字列を挿入
    (let ((from (selection-mark))
	  (to (selection-point)))
      (if (> from to)
	  (rotatef from to))
      (save-excursion
	(save-restriction
	  (narrow-to-region from to)
	  (goto-char from)
	  (insert *winbatch-mode-comment-start*)
	  (while (forward-line 1)
	    (insert *winbatch-mode-comment-start*)))))
    ;セレクションがなければ、コメントをトグル
    (save-excursion
      (let (bol eol)
	(goto-eol)
	(setq eol (point))
	(goto-bol)
	(setq bol (point))
	(if (string-match "^[ \t]*\\(?:[rR][eE][mM]\\|:/\\)\\(?:[ \t]*$\\|[ \t]\\)"
			  (buffer-substring bol eol))
	    (delete-region (+ bol (match-beginning 0)) (+ bol (match-end 0)))
	  (insert *winbatch-mode-comment-start*))))))

;[xyzzy:06789] より。
(defun winbatch-outcomment-selection ()
  "選択範囲の行頭からコメント文字列を削除"
  (interactive)
  (or (pre-selection-p)
      (error "selectionがない。"))
  (let ((from (selection-mark))
        (to (selection-point)))
    (if (> from to)
        (rotatef from to))
    (save-excursion
      (save-restriction
        (narrow-to-region from to)
        (goto-char from)
	(replace-buffer (concat "^" *winbatch-mode-comment-start*) "" :regexp t)))))

(defun winbatch-run-script (&optional arg)
  "スクリプトを走らせろ"
  (interactive "sParameters: ")
  (winbatch-exec "x" arg))

(defun winbatch-open-script (&optional arg)
  "スクリプトを開け"
  (interactive "sParameters: ")
  (winbatch-exec "?" arg))

(defun winbatch-exec (option arg)
  "スクリプトを WinBatchEh に渡す"
  (let (opt)
    (if (equal option "?")
	(setq opt "?")
      (setq opt ""))
    (if (winbatch-prog-p)
	(progn
	  (if (and (buffer-modified-p) *winbatch-auto-save*)
	      (save-buffer-dialog))
	  (if (not (buffer-modified-p))
		(call-process (concat *winbatch-prog* " " opt "\""
				      (map-slash-to-backslash (get-buffer-file-name)) "\" " arg)
			      :wait nil)
	    (message "保存されてない。")))
      (message (concat *winbatch-prog* " がみつからない。")))))

(defun winbatch-compile-script ()
  "コンパイラ起動"
  (interactive)
  (if (winbatch-compiler-prog-p)
      (progn
	(if (and (buffer-modified-p) *winbatch-auto-save*)
	    (save-buffer-dialog))
	(if (not (buffer-modified-p))
	    (progn
	      (copy-to-clipboard (map-slash-to-backslash (get-buffer-file-name)))
	      (call-process *winbatch-compiler-prog* :wait nil))
	  (message "保存されてない。")))
    (message (concat *winbatch-compiler-prog* " がみつからない。"))))

(defun winbatch-show-winhelp ()
  "ヘルプの検索"
  (interactive)
  (if (winbatch-help-file-p)
      (run-winhelp *winbatch-winhelp-file*
		   (let ((topic (get-winhelp-topic)))
		     (and (not (equal topic "")) topic)))
    (message (concat *winbatch-winhelp-file* " がみつからない。"))))

(defun winbatch-open-filer ()
  "WinBatchEh 用ファイラの起動"
  (interactive)
  (toggle-ime nil)
  (setq *filer-primary-directory* nil)
  (setq *filer-secondary-directory* *winbatch-script-directory*)
  (multiple-value-bind (files result)
      (filer nil t "WinBatch mode" t)
    (when result
      (dolist (f files t)
	(unless (file-directory-p f)
	  (find-file f)
	  (add-history f '*minibuffer-file-name-history*))))))

(defun winbatch-home ()
  (interactive)
  (shell-execute *winbatch-home-url* t))

(defun winbatch-forum ()
  (interactive)
  (shell-execute *winbatch-forum-url* t))

(defun winbatch-mode-show-version ()
  (interactive)
  (message-box (concat "winbatch-mode.l version " *winbatch-mode-version*) "winbatch-mode"))

(defun winbatch-prog-p ()
  "winbat32.exe の存在確認"
  (or (file-exist-p *winbatch-prog*) nil))

(defun winbatch-compiler-prog-p ()
  "wbatcp.exe の存在確認"
  (or (file-exist-p *winbatch-compiler-prog*) nil))

(defun winbatch-help-file-p ()
  "winbat32.hlp の存在確認"
  (or (file-exist-p *winbatch-winhelp-file*) nil))


;; Menu

;csv-mode を参考に。
(defvar *winbatch-menu-name*  "WinBatchEh(&B)")

(defun winbatch-menu-update ()
  (interactive)
  (use-local-menu (winbatch-add-menu)))

(defun winbatch-add-menu ()
  (let ((menu (copy-menu-items *app-menu* (create-menu))))
    (insert-popup-menu menu (get-menu-position menu 'help)
                       *winbatch-menu-default*
                       *winbatch-menu-name*)
    menu))

(defvar *winbatch-menu-default* nil)
(unless *winbatch-menu-default*
  (setq *winbatch-menu-default*
        (let ((menu (create-popup-menu nil)))
          (add-menu-item menu nil "ヘルプを検索(&H)"     'winbatch-show-winhelp
			 #'(lambda () (unless (winbatch-help-file-p) :disable)))
	  (add-menu-separator menu)
	  (add-menu-item menu nil "ファイラ(&F)"         'winbatch-open-filer)
	  (add-menu-separator menu)
          (add-menu-item menu nil "スクリプトを実行(&X)" 'winbatch-run-script
			 #'(lambda () (unless (winbatch-prog-p) :disable)))
	  (add-menu-item menu nil "スクリプトを開く(&O)" 'winbatch-open-script
			 #'(lambda () (unless (winbatch-prog-p) :disable)))
	  (add-menu-item menu nil "コンパイラ起動(&C)"   'winbatch-compile-script
			 #'(lambda () (unless (winbatch-compiler-prog-p) :disable)))
	  (add-menu-separator menu)
	  (add-menu-item menu nil "キーワード補完(&K)"     'winbatch-completion)
	  (add-menu-item menu nil "コメント文字列挿入またはトグル(&R)"
			 'winbatch-encomment-selection-or-comment-toggle-line)
	  (add-menu-item menu nil "コメント文字列削除(&D)" 'winbatch-outcomment-selection)
	  (add-menu-separator menu)
	  (add-menu-item menu nil "清水 洋平さんのページ(&W)" 'winbatch-home)
	  (if *winbatch-forum-url*
	    (add-menu-item menu nil "WinBatchの掲示板(&B)"    'winbatch-forum))
          (add-menu-item menu nil "について(&A)..."           'winbatch-mode-show-version)
          menu)))


;;;  winbatch-mode.l ends here.
