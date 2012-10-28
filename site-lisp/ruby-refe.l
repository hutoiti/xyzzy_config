;;; -*- Mode: Lisp; Package: EDITOR; Last updated: "2010/04/01 23:39:52" -*-
;;;
;;; This file is not part of xyzzy.
;;;
;;;   ruby-refe.l --- へなちょこ ReFe 参照用モード
;;;
;;;     by HIE Masahiro <madoinux@gmail.com>
#|

■概要

  HATTORI Masashi さんの ruby-mode から，ReFe2 を参照します。

    ruby-mode:
      http://www7a.biglobe.ne.jp/~hat/xyzzy/ruby-mode.html

    Rubyリファレンスマニュアル刷新計画:
      http://redmine.ruby-lang.org/wiki/rurema/ReleasedProducts


■インストール

  1. ruby-refe.l を site-lisp にコピーする。

  2. 必要に応じ，バイトコンパイルする。(任意)

       M-x byte-compile-file

  3. Rubyリファレンスマニュアルパッケージ版を入手し，展開する。
     c:/rubyrefm に展開する場合は，こんな感じ。

       c:/rubyrefm/
        ├ bitclust/
        │ ├ bin/
        │ │ └ refe.rb
        │ └ lib/
        ├ db-1_8_7/
        └ db-1_9_1/

     ※Rubyリファレンスマニュアルを c:/rubyrefm/ 以外にインストール
       する場合は，設定例に従い，*ruby-refe-install-path* を設定する
       必要があります。

  4. .xyzzy か siteinit.l に以下の記述を追加する。

       (require "ruby-refe")


■使い方

  M-x ruby-refe して，検索するシンボルとオプションを指定します。
  オプションに --help を指定すると，オプション一覧が表示されます。

  実行例は，<http://i.loveruby.net/ja/prog/refe.html> あたりを参照
  してください。(ReFe2 になってオプションが変わっています)

  [ruby-refe-mode]

    RET   : カーソル位置のシンボルを引く
    F1    : カーソル位置のシンボルを引く (一覧表示)
    r     : refe 実行
    l     : refe -l 実行
    o     : 次のウィンドウに移動
    q     : 終了


■設定例

  F1 キーで，カーソル位置の単語を ReFe から引く。

    (define-key *ruby-mode-map* #\F1 'ruby-refe-line-point)

  ReFe コマンドのエイリアス。M-x refe で実行するように。

    (setf (symbol-function 'refe) #'ruby-refe)

  ReFe のインストールパスを変更。(既定値は "c:/rubyrefm")

    (setq *ruby-refe-install-path* "d:/opt/rubyrefm")

  Ruby ReFe のデータベース名を指定。(既定値は "db-1_8_7")

    (setq *ruby-refe-dbname* "db-1_9_1")


■更新履歴

  [Version 2.00] 2010-04-01 (木)
  ・ReFe2 に対応した(はず)。
  ・ReFe1 非対応にした。
  ・オプションが指定できるようにした。
  ・その他いろいろ。

  [Version 1.00] 2008-01-06 (日)
  ・初版作成。


■ライセンス

  ruby-refe.l はMITライセンスに基づいて利用可能です。
  <http://www.opensource.org/licenses/mit-license.php>

Copyright (c) 2007-2010 HIE Masahiro

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

(provide "ruby-refe")

(require "ruby")

(in-package "editor")

(export '(ruby-refe
	  ruby-refe-line
	  ruby-refe-point
	  ruby-refe-line-point
	  *ruby-refe-install-path*
	  *ruby-refe-dbname*
	  *ruby-refe-buffer1*
	  *ruby-refe-buffer2*
	  ))

;;; ──────────────────────────────────── ;;;
;;;  ■ 変数設定 - 適当にカスタマイズするあたり
;;; ──────────────────────────────────── ;;;

(defvar *ruby-refe-install-path* "c:/rubyrefm"
  "ruby-refe: Ruby ReFe インストールフォルダ")

(defvar *ruby-refe-dbname* "db-1_8_7"
  "ruby-refe: Ruby ReFe データベース名")

(defvar *ruby-refe-option-default* "-l"
  "ruby-refe: ruby-refe 実行時に指定するオプションの既定値")

(defvar *ruby-refe-option-force* "-e sjis"
  "ruby-refe: 強制的に指定するオプション")

(defvar *ruby-refe-color-title* '(:keyword 0)
  "ruby-refe: タイトル(?)の色")

(defvar *ruby-refe-color-head* '(:keyword 2)
  "ruby-refe: タイトル(?)以外のヘッダ(??)の色")


;;; ──────────────────────────────────── ;;;
;;;  ■ 変数設定 - あまりさわらなくて良いもの
;;; ──────────────────────────────────── ;;;

(defvar *ruby-refe-command* "refe.rb"
  "ruby-refe: refe コマンド")

(defvar *ruby-refe-bitclust-lib-path* nil
  "ruby-refe: bitclust/lib フォルダ")

(defvar *ruby-refe-bitclust-bin-path* nil
  "ruby-refe: bitclust/bin フォルダ")

(defvar *ruby-refe-db-path* nil
  "ruby-refe: Ruby ReFe データベースフォルダ")

(defvar *ruby-refe-buffer1* " *ReFe1*"
  "ruby-refe: ReFe バッファ1")

(defvar *ruby-refe-buffer2* " *ReFe2*"
  "ruby-refe: ReFe バッファ2")

(defvar *ruby-refe-winconf* nil
  "ruby-refe: 実行前のウィンドウの状態")

(defvar *ruby-refe-mode-hook* nil
  "ruby-refe: refe 実行時処理")

(defvar *ruby-refe-mode-map* nil
  "ruby-refe: ReFeバッファ用キーマップ")

(defvar *ruby-refe-mode-syntax-table* nil
  "ruby-refe: ReFeバッファ用シンタックステーブル")

(defvar *ruby-refe-regexp-keyword-list*
  (compile-regexp-keyword-list
   `(
     ("^[A-Za-z0-9_#:.*=!?-]+$" t ((0 . ,*ruby-refe-color-title*)))
     ("^--- .*$"                t ((0 . ,*ruby-refe-color-head*)))
     ("^: .*$"                  t ((0 . ,*ruby-refe-color-head*)))
     ("^require.*$"             t ((0 . ,*ruby-refe-color-head*)))
     ))
  "ruby-refe: 正規表現による色付け")


;;; ──────────────────────────────────── ;;;
;;;  ■ 対話的な関数
;;; ──────────────────────────────────── ;;;

(defun ruby-refe-point (&optional option)
  "ruby-refe: カーソル位置のシンボルを引く"
  (interactive)
  (let ((pattern (ruby-refe-keyword)))
    (when (string= pattern "")
      (setq pattern nil))
    (ruby-refe pattern option)))

(defun ruby-refe-line-point ()
  "ruby-refe: カーソル位置のシンボルを -l オプション付きで引く"
  (interactive)
  (ruby-refe-point "-l"))

(defun ruby-refe (&optional pattern option)
  "ruby-refe: refe 実行"
  (interactive "sReFe: \nsOption: "
    :default0 (ruby-refe-keyword)
    :default1 *ruby-refe-option-default*)
  (let (buffer arg)
    (setq buffer (if (string= (buffer-name (selected-buffer)) *ruby-refe-buffer1*)
		     *ruby-refe-buffer2*
		   *ruby-refe-buffer1*))
    (when (string-match "\\(.+\\)\\.#\\(.+\\)" pattern)
      (setq pattern (string-replace-match pattern "\\1#\\2")))
    (let ((cbuf (selected-buffer))
	  (rbuf (find-buffer buffer)))
      (when rbuf
	(set-buffer rbuf)
	(setq buffer-read-only nil)
	(set-buffer cbuf)))
    (unless *ruby-refe-winconf*
      (setq *ruby-refe-winconf* (current-window-configuration)))
    (ruby-refe-set-pathname)
    (setq arg (concat *ruby-refe-option-force* " " (or option "") " " pattern))
    (execute-shell-command (format nil "@~A -I ~A ~A/~A -d file://~A ~A"
				   *ruby-prog*
				   *ruby-refe-bitclust-lib-path*
				   *ruby-refe-bitclust-bin-path*
				   *ruby-refe-command*
				   *ruby-refe-db-path*
				   arg)
			   :OUTPUT buffer
			   :DIRECTORY *ruby-refe-bitclust-bin-path*)
    (ruby-refe-mode arg)))

(defun ruby-refe-line ()
  "ruby-refe: -l オプション付きで実行"
  (interactive "sReFe: " :default0 (ruby-refe-keyword))
  (ruby-refe nil "-l"))

(defun ruby-refe-quit ()
  "ruby-refe: 終了"
  (interactive)
  (when *ruby-refe-winconf*
    (ignore-errors
     (set-window-configuration *ruby-refe-winconf*))
    (setq *ruby-refe-winconf* nil)))


;;; ──────────────────────────────────── ;;;
;;;  ■ ruby-refe-mode
;;; ──────────────────────────────────── ;;;

(unless *ruby-refe-mode-map*
  (setq *ruby-refe-mode-map* (make-sparse-keymap))
  (define-key *ruby-refe-mode-map* '#\F1  'ruby-refe-line-point)
  (define-key *ruby-refe-mode-map* '#\RET 'ruby-refe-point)
  (define-key *ruby-refe-mode-map* '#\r   'ruby-refe)
  (define-key *ruby-refe-mode-map* '#\l   'ruby-refe-line)
  (define-key *ruby-refe-mode-map* '#\o   'other-window)
  (define-key *ruby-refe-mode-map* '#\q   'ruby-refe-quit)
  )

(unless *ruby-refe-mode-syntax-table*
  (setq *ruby-refe-mode-syntax-table* (make-syntax-table))
  (set-syntax-symbol *ruby-refe-mode-syntax-table* #\_)
  (set-syntax-symbol *ruby-refe-mode-syntax-table* #\?)
  (set-syntax-symbol *ruby-refe-mode-syntax-table* #\!)
  (set-syntax-symbol *ruby-refe-mode-syntax-table* #\=)
  (set-syntax-symbol *ruby-refe-mode-syntax-table* #\-)
  (set-syntax-symbol *ruby-refe-mode-syntax-table* #\*)
  (set-syntax-symbol *ruby-refe-mode-syntax-table* #\.)
  (set-syntax-symbol *ruby-refe-mode-syntax-table* #\:)
  (set-syntax-symbol *ruby-refe-mode-syntax-table* #\#)
  )

(defun ruby-refe-mode (arg)
  "ruby-refe: リファレンス表示用モード"
  (interactive)
  (kill-all-local-variables)
  (setq buffer-mode 'ruby-refe)
  (setq mode-name "ReFe")
  (use-keymap *ruby-refe-mode-map*)
  (use-syntax-table *ruby-refe-mode-syntax-table*)
  (make-local-variable 'regexp-keyword-list)
  (setq regexp-keyword-list *ruby-refe-regexp-keyword-list*)
  (make-local-variable 'mode-line-format)
  (setq mode-line-format (format nil "--%*- %b (%M) [%k:%l] %P dbname: ~A  command: \"~A ~A\""
				 *ruby-refe-dbname*
				 *ruby-refe-command*
				 arg))
  (setq need-not-save t)
  (setq kept-undo-information nil)
  (setq auto-save nil)
  (set-buffer-modified-p nil)
  (setq buffer-read-only t)
  (let ((buf (selected-buffer)))
    (set-local-window-flags buf (+ *window-flag-newline*
				   *window-flag-tab*
				   *window-flag-full-width-space*
				   *window-flag-eof*
				   *window-flag-line-number*
				   *window-flag-half-width-space*
				   *window-flag-scrolling*)
			    nil)
    (set-local-window-flags buf (+ (if (boundp '*window-flag-fold-mark*)
				       *window-flag-fold-mark*
				     *window-flag-fold-line*))
			    t))
  (run-hooks '*ruby-refe-mode-hook*))


;;; ──────────────────────────────────── ;;;
;;;  ■ 補助関数
;;; ──────────────────────────────────── ;;;

(defun ruby-refe-set-pathname()
  "ruby-refe: Ruby ReFe パス設定"
  (setf *ruby-refe-bitclust-lib-path*
	(merge-pathnames "bitclust/lib" *ruby-refe-install-path*)
	*ruby-refe-bitclust-bin-path*
	(merge-pathnames "bitclust/bin" *ruby-refe-install-path*)
	*ruby-refe-db-path*
	(merge-pathnames *ruby-refe-dbname* *ruby-refe-install-path*)))

(defun ruby-refe-keyword ()
  "ruby-refe: カーソル位置の単語またはセレクションの文字列を返す"
  (or (selection-start-end (start end)
	(buffer-substring start end))
      (if (string-match "\\_s+" (format nil "~C" (char-after (point))))
	  (save-excursion
	    (buffer-substring (progn
				(skip-syntax-spec-forward "w_")
				(point))
			      (progn
				(skip-syntax-spec-backward "w_")
				(point))))
	"")))

;;; ruby-refe.l ends here.
