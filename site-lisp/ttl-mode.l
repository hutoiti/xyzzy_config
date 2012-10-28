;;; -*- Mode: Lisp; Package: EDITOR; Last modified: <2007/12/31 01:15:39> -*-
;;;
;;; This file is not part of xyzzy.
;;;
;;;   ttl-mode.l --- Simple mode for Tera Term Language
;;;
;;;     by HIE Masahiro <madoinu@ybb.ne.jp>
#|

■概要

  Tera Term マクロ用のモード。

  その他、参考にさせていただいたもの。（とか、ほぼそのまま使わせて
  いただいたもの。）

    htmlmode.l
    bat-mode.l
    php-mode.l
    csv-mode.l
    xyzzy ML
    その他沢山...

  多くの有用なコードを公開して頂いている諸先輩方に多謝。


■使用上の注意

  ・Tera Term の実行パスは、レジストリ(のたぶん関連付けの部分)から
    取得するようにしてみたが、起動しない場合（および関連付けのして
    ない場合）は、*ttl-path* を直接指定しないといけないと思う。

  ・Lisp も TTL も良く解からないまま作っているので、怪しい。


インストール:

  1. ttl-mode.l を ~/site-lisp に、TTL を ~/etc にコピーする。

  2. 必要ならばバイトコンパイルする。

  3. *.ttl を読みこんだときに自動的に ttl-mode にするために、以下
     のコードを追加する（たぶん）。

     ○ .xyzzyに追加する場合
           (export 'ed::ttl-mode "ed")
           (autoload 'ttl-mode "ttl-mode" t)
           (pushnew '("\\.ttl$" . ttl-mode) *auto-mode-alist* :test 'equal)

     ○ siteinit.lに追加する場合
           (in-package "editor")
           (export 'ttl-mode)
           (autoload 'ttl-mode "ttl-mode" t)
           (pushnew '("\\.ttl$" . ttl-mode) *auto-mode-alist* :test 'equal)
           (in-package "user")

   4. 補完をポップアップ一覧表示をする場合は、以下のコードを初期化
      ファイルに追加する。

           (setq *popup-completion-list-default* :always)

   5. 上記の設定を反映させるために、xyzzyを再起動する。


■使い方

  M-x ttl-mode

  スクリプトを実行する場合に、パラメータを指定する場合は、
  Parameters: 欄に入力する。複数指定する場合は、半角スペース区切り
  で、半角スペースを持った文字列を指定する場合は、"" でくくって指定
  する。パラメータが不要な場合は、未入力のまま Enter で OK。


■キーバインド

  F1       ヘルプを検索
  C-.      キーワード補完
  C-;      セレクションがあればセレクションにコメント文字列を挿入、
           なければ現在行のコメントをトグル
  M-C-;    セレクションのコメント文字列を削除
  C-c x    TTL スクリプト実行


■設定例

  ;; スクリプト実行時にファイルを保存
  (setq *ttl-auto-save* nil)


■更新履歴

  [Version 1.08] 2007-12-31 (月)
  ・ライセンス条項(MITライセンス)を記載。

  [Version 1.07.1] 2002/09/15 12:06:11 +0900
  ・補完のポップアップ一覧表示の設定は、必要な部分のみとした(つもり)。

  [Version 1.07] 2002/09/15 00:14:52 +0900
  ・補完の一覧表示は、山本 泰三さんの Tips を使っていたのを今頃思
    い出し、説明文を追加した。

  [Version 1.06] 2002/09/14 08:46:48 +0900
  ・スクリプト実行時、引数を取得するのに minibuffer-prompt を使用
    するのをやめた。また、実行するファイル名を "" でくくるようにし
    た。
  ・*ttl-auto-save* の既定値を t にした。

  [Version 1.05] 2002/09/14 00:32:56 +0900
  ・スクリプト実行時に、バッファ編集状況をチェックし、場合によって
    は保存してからするようにした。

  [Version 1.04] 2002/09/03 11:13:47 +0900
  ・コメント文字列の挿入、削除の方法を変更した。
  ・キーバインドが標準的(?)でなかったのを変更した。
  ・もしかしたらカスタマイズするかもしれないあたりを export した。
  ・一応、断りも無く Tera Term のページにリンクするのをやめた。

  [Version 1.03] 2002/09/02 11:16:40 +0900
  ・ベーカー街の物置(http://members.tripod.co.jp/mystery_trick_room/)
    を参考にヘルプの検索方法を正しい(?)方法に変更した。

  [Version 1.02] 2002/08/30(金)
  ・レジストリから Tera Term のインストールディレクトリを取得する
    ようにした。
  ・メニューをつけた。

  [Version 1.01] 2002/08/28(水)
  ・インデントするようにした。
  ・その他細かい修正。

  [Version 1.00] 2002/08/12(月)
  ・ttl-run-script を追加した。
  ・ttl-search-help-selection に、winbat32.exe または TTLHelp.btw 
    がない場合の処理を追加した。

  [Version 0.4] 2002/08/10(土)
  ・ttl-encomment-selection, ttl-outcomment-selection
    を追加した。

  [Version 0.3] 2002/08/08(木)
  ・ini-mode ベースから、batch-mode ベースに変更した。
  ・ttl-search-help-selection を追加した。（要 WinBatchEh）
  ・rito-ttl-outcomment-selection, rito-ttl-outcomment-selection
    を削除した。
    → siteinit.l で設定するようにした。

  [Version 0.3] 2002/04/09
  ・rito-ttl-outcomment-selection, rito-ttl-outcomment-selection
    を追加した。

  [Version 0.2] 2001/11/22
  ・lisp-mode ベースから、ini-mode ベースに変更した。

  [Version 0.1]
  ・lispmode.l のコメント色付けを使用するためだけに、少しだけ改造してつくった。


■ライセンス

  ttl-mode.l はMITライセンスに基づいて利用可能です。
  <http://www.opensource.org/licenses/mit-license.php>

Copyright (c) 2001-2007 HIE Masahiro

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

(provide "ttl-mode")

(in-package "editor")

(export '(ttl-mode
	  ttl-show-winhelp
	  ttl-run-script
	  ttl-completion
	  ttl-encomment-selection-or-comment-toggle-line
	  ttl-outcomment-selection
	  *ttl-mode-hook*
	  *ttl-mode-map*
	  *ttl-keyword-file*
	  *ttl-prog*
	  ))

(defconstant *ttl-mode-version* "1.07.1")

;; スクリプト実行時にファイルを保存
(defvar *ttl-auto-save* t)

(defun ttl-path ()
  "レジストリから Tera Term のパスを取得"
  (let ((dat (read-registry "SOFTWARE\\Classes\\TTL_auto_file\\shell\\open\\command"
			    "" :local-machine)))
    (if dat (directory-namestring dat)
      "C:/Program Files/TTERMPRO/")))

;; Tera Term のインストールディレクトリ
(defvar *ttl-path* (ttl-path))

;; ttpmacro.exe のフルパス
(defvar *ttl-prog* (merge-pathnames "ttpmacro.exe" *ttl-path*))

;; ヘルプファイルのフルパス
(defvar *ttl-winhelp-path* (merge-pathnames "macroj.hlp" *ttl-path*))

;; startup message
(defvar *ttl-startup-message* t)

(defvar *ttl-mode-hook* nil)

(defvar *ttl-keyword-hash-table* nil)
(defvar *ttl-keyword-file* "TTL")
(defvar *ttl-completion-list* nil)

(defvar *ttl-mode-map* nil)
(unless *ttl-mode-map*
  (setq *ttl-mode-map* (make-sparse-keymap))
  (define-key *ttl-mode-map*   #\F1       'ttl-show-winhelp)
  (define-key *ttl-mode-map*   #\TAB      'ttl-indent-line)
  (define-key *ttl-mode-map*   #\RET      'ttl-newline-and-indent)
  (define-key *ttl-mode-map*   #\C-.      'ttl-completion)
  (define-key *ttl-mode-map*   #\C-\;     'ttl-encomment-selection-or-comment-toggle-line)
  (define-key *ttl-mode-map*   #\M-\C-\;  'ttl-outcomment-selection)
  (define-key *ttl-mode-map* '(#\C-c #\x) 'ttl-run-script)
  (define-key *ttl-mode-map* '(#\C-c #\?) 'ttl-mode-version))

(defvar *ttl-mode-abbrev-table* nil)
(unless *ttl-mode-abbrev-table*
  (define-abbrev-table '*ttl-mode-abbrev-table*))

(defvar *ttl-mode-syntax-table* nil)
(unless *ttl-mode-syntax-table*
  (setq *ttl-mode-syntax-table* (make-syntax-table))
  (set-syntax-start-comment *ttl-mode-syntax-table* #\; t)
  (set-syntax-end-comment *ttl-mode-syntax-table* #\LFD t t)
  (set-syntax-string *ttl-mode-syntax-table* #\")
  (set-syntax-string *ttl-mode-syntax-table* #\'))

(defun ttl-mode ()
  (interactive)
  (kill-all-local-variables)
  (if *ttl-startup-message*
      (message "Tera Term Language mode ~A for xyzzy."
	       *ttl-mode-version*))
  (setq buffer-mode 'ttl-mode)
  (setq mode-name "TTL")
  (use-keymap *ttl-mode-map*)
  (use-syntax-table *ttl-mode-syntax-table*)
  (and *ttl-keyword-file*
       (null *ttl-keyword-hash-table*)
       (setq *ttl-keyword-hash-table*
	     (load-keyword-file *ttl-keyword-file* t)))
  (when *ttl-keyword-hash-table*
    (make-local-variable 'keyword-hash-table)
    (setq keyword-hash-table *ttl-keyword-hash-table*))
  (setq *local-abbrev-table* *ttl-mode-abbrev-table*)
  (ttl-menu-update)
  (run-hooks '*ttl-mode-hook*))

(defun ttl-newline-and-indent (&optional (arg 1))
  "改行＋インデント"
  (interactive "*p")
  (insert #\LFD arg)
  (ttl-indent-line))

(defun ttl-indent-line ()
  "現在の行のインデント付け"
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

(defun ttl-completion ()
  "キーワードから補完"
  (interactive)
  (or *ttl-completion-list*
      (setq *ttl-completion-list* (make-list-from-keyword-table *ttl-keyword-hash-table*))
      (return-from ttl-completion nil))
  (let ((opoint (point)))
    (when (skip-syntax-spec-backward "w_.")
      (let ((from (point)))
	(goto-char opoint)
	(do-completion from opoint :list *ttl-completion-list*)))))

(defun ttl-encomment-selection-or-comment-toggle-line ()
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
	  (insert ";")
	  (while (forward-line 1)
	    (insert ";")))))
    ;セレクションがなければ、コメントをトグル
    (save-excursion
      (let (bol eol)
	(goto-eol)
	(setq eol (point))
	(goto-bol)
	(setq bol (point))
	(if (string-match "^[ \t]*\\;+"
			  (buffer-substring bol eol))
	    (delete-region (+ bol (match-beginning 0)) (+ bol (match-end 0)))
	  (insert ";"))))))

(defun ttl-outcomment-selection ()
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
	(replace-buffer (concat "^" ";") "" :regexp t)))))

(defun ttl-run-script (&optional arg)
  "スクリプトよ走れ"
  (interactive "sParameters: ")
  (if (file-exist-p *ttl-prog*)
      (progn
	(if (and (buffer-modified-p) *ttl-auto-save*)
	    (save-buffer-dialog))
	(if (not (buffer-modified-p))
	      (call-process (concat *ttl-prog* " \""
				    (map-slash-to-backslash (get-buffer-file-name)) "\" " arg)
			    :wait nil)
	  (message "保存されてない。")))
    (message (concat *ttl-prog* " がみつからない。"))))

(defun ttl-show-winhelp ()
  "ヘルプの検索"
  (interactive)
  (run-winhelp *ttl-winhelp-path*
	       (let ((topic (get-winhelp-topic)))
		 (and (not (equal topic "")) topic))))

(defun teraterm-home ()
  (interactive)
  (shell-execute "http://hp.vector.co.jp/authors/VA002416/teraterm.html" t))

(defun ttl-mode-version ()
  (interactive)
  (message-box (concat "ttl-mode.l version " *ttl-mode-version*)))


;; Menu

(defvar *ttl-menu-name*  "TTL(&T)")

(defun ttl-menu-update ()
  (interactive)
  (use-local-menu (ttl-add-menu)))

(defun ttl-add-menu ()
  (let ((menu (copy-menu-items *app-menu* (create-menu))))
    (insert-popup-menu menu (get-menu-position menu 'help)
                       *ttl-menu-default*
                       *ttl-menu-name*)
    menu))

(defvar *ttl-menu-default* nil)
(unless *ttl-menu-default*
  (setq *ttl-menu-default*
        (let ((menu (create-popup-menu nil)))
          (add-menu-item menu nil "ヘルプを検索(&H)"     'ttl-show-winhelp)
          (add-menu-item menu nil "スクリプトを実行(&X)" 'ttl-run-script)
	  	  (add-menu-separator menu)
	  (add-menu-item menu nil "キーワード補完(&K)"     'ttl-completion)
	  (add-menu-item menu nil "コメント文字列挿入またはトグル(&R)"
			 'ttl-encomment-selection-or-comment-toggle-line)
	  (add-menu-item menu nil "コメント文字列削除(&D)" 'ttl-outcomment-selection)
	  (add-menu-separator menu)
	  ;(add-menu-item menu nil "Tera Term Home Page(&W)" 'teraterm-home)
          (add-menu-item menu nil "バージョン情報(&V)"      'ttl-mode-version)
          menu)))


;;; ttl-mode.l ends here.
