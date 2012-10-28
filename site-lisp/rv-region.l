;;; -*- Mode: Lisp; Last modified: <2007/12/31 01:12:59> -*-
;;;
;;; This file is not part of xyzzy.
;;;
;;;   rv-region.l --- リージョンを反転表示
;;;
;;;     by HIE Masahiro <madoinu@ybb.ne.jp>
#|

■概要

  リージョンを反転表示する。そして、それなりに解除する。
  そうしたければ、リージョンの作成と同時にセレクションも作成する。


■インストール

  1. rv-region.l を ~/site-lisp にコピーする。

  2. 必要ならばバイトコンパイルする。

       M-x byte-compile-file

  3. .xyzzy か siteinit.l に以下の記述を追加する。

      (require "rv-region")


■使い方

  リージョンの反転を開始するために、「その１」または「その２」の設定
  を行う。

  リージョン、セレクション、矩形、マウス関係等のコマンドを実行すると、
  反転表示が解除される。

  強制的に反転表示を止める場合は、C-g する。

  反転表示色は、「ニセ反転色」で設定されたもの。しかし，[共通設定
  ][表示][ちゃんと反転する]にチェックが入っていると、「ニセ反転色」
  は使用されないようです。


  その１

  反転表示開始用コマンド実行時のみ、反転表示を開始する。以下の設定
  では、C-@ でマークを設定すると、リージョンの反転表示を開始する。
  その他のコマンドでマークを設定した場合は、反転表示しない。

    (global-set-key #\C-@ 'rv-set-mark-command)

  この設定では、反転表示開始後、反転表示が解除されるまでの間のみ、
  反転表示解除用コマンドが、*post-command-hook* に設定されている。

  *post-command-hook* への設定コマンドを（xyzzy への負荷を）、極力
  減らしたい方には、こちらの方が良いかも。


  その２

  マークセット後は必ず反転表示を開始する。以下の設定をすると、
  *rv-start-command-list* に登録されたコマンドを実行後、リージョン
  の反転表示を開始する。

    (setq *rv-region-stay-on* t)

  この設定では、常時、反転表示開始用コマンドが、*post-command-hook*
  に設定されている。

  反転表示待機の停止/開始は、M-x rv-toggle-watch する。


■設定例

  ・リージョンの作成と同時にセレクションも作成し、反転表示はセレク
    ションに任す。

      (setq *rv-region-use-selection* t)

  ・反転を止めるコマンド実行後も、次のコマンド実行まで反転表示を続
    ける。

      (setq *rv-region-keep-reverse* t)

  ・反転表示を開始するコマンドを追加する。（「その２」の場合に有効）

      (pushnew 'command *rv-start-command-list*)

  ・反転表示を止めるコマンドを追加する。

      (setq *rv-exit-command-list* (list 'command1 'command2))

  ・反転表示を続けるコマンドを追加する。

      (setq *rv-continue-command-list* (list 'command1 'command2))

  ・反転されていないリージョンに対し反転を開始する。(M-R)

      (global-set-key #\M-R 'rv-restart)

  ・反転されていないリージョンを一時的に反転する。(M-V)

      (global-set-key #\M-V 'rv-check)


■更新履歴

  [Version 2.04] 2007-12-31 (月)
  ・ライセンス条項(MITライセンス)を記載。

  [Version 2.03.2] 2004/04/09
  ・*rv-exit-command-regexp* に，register を追加した。

  [Version 2.03.1] 2003/04/19
  ・*rv-exit-command-regexp* に、tabify を追加した。

  [Version 2.03] 2003/01/28
  ・rv-restart の追加および処理がいくらかでも軽くなることを願って
    rv-region-command を書き直してみた。
  ・*rv-exit-command-regexp* にいくらか追加した。
  ・rv-region-toggle-watch を rv-toggle-watch に変更した。
  ・rv-region-check を rv-check に変更した。
  ・「使い方」の「その１」と「その２」を入替え、「その１」をおススメ
    とした。

  [Version 2.02.1] 2003/01/26
  ・2.02 で修正できていなかったのを修正した。
    かぎわださんが詳しく書いてくれていたのに．．．。;(;_;);

  [Version 2.02] 2003/01/26 (日)
  ・*rv-region-use-selection* を t にしていると、set-mark-command
    でしか反転表示（セレクション）が開始されないのを修正した。

  [Version 2.01] 2003/01/26 (日)
  ・かぎわださんのを参考に、リージョンの作成と同時にセレクションも
    作成し、反転表示はセレクションに任すこともできるようにした。
  ・rv-region-start, rv-region-stop を interactive でなくした。

  [Version 2.00] 2003/01/22 (水)
  ・TKI さんのを参考に、マークを設定するコマンドの実行を待ってリー
    ジョンの反転表示を開始することもできるようにした。
  ・反転を止めるコマンド実行後も、次のコマンド実行まで反転表示を続
    けることもできるようにした。
  ・矩形処理実行後にも、反転表示を解除するようにした。
  ・その他いろいろ。

  [Version 1.02] 2003/01/18 (土) 夜
  ・終了するコマンドを全て列記しないで、大体で判断するようにした。
  ・*rv-continue-command-list* を追加した。

  [Version 1.01] 2003/01/18 (土) 朝
  ・rv-quit を削除した。

  [Version 1.00] 2003/01/17 (金)
  ・つくった。


■ライセンス

  rv-region.l はMITライセンスに基づいて利用可能です。
  <http://www.opensource.org/licenses/mit-license.php>

Copyright (c) 2003-2007 HIE Masahiro

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

(provide "rv-region")

;;; ──────────────────────────────────── ;;;
;;;  ■ 変数設定
;;; ──────────────────────────────────── ;;;

(defvar *rv-region-stay-on* nil
  "rv-region: マークセット後は常に反転表示を開始")

(defvar *rv-region-keep-reverse* nil
  "rv-region: 次のコマンド実行まで反転表示を続ける")

(defvar *rv-region-use-selection* nil
  "rv-region: リージョンとセレクションを同時に作成する")

(defvar *rv-start-command-list*
  (list 'set-mark-command 'mark-paragraph 'mark-page 'mark-defun
	'mark-sexp 'mark-word 'mark-whole-buffer 'rv-restart)
  "rv-region: 反転表示を開始するコマンドのリスト")

(defvar *rv-exit-command-list* nil
  "rv-region: 反転表示を止めるコマンドのリスト")

(defvar *rv-continue-command-list* nil
  "rv-region: 反転表示を続けるコマンドのリスト")

(defvar *rv-exit-command-regexp*
  (compile-regexp (concat
		   "\\(quit\\|self-insert-command"
		   "\\|.*\\(region\\|selection\\|rectangle\\|mouse\\|newline\\|indent\\|tabify\\|register\\).*\\)"))
  "rv-region: 反転表示を止めるコマンドを表す正規表現")


;;; ──────────────────────────────────── ;;;
;;;  ■ リージョン反転表示用関数
;;; ──────────────────────────────────── ;;;

(defun rv-region ()
  (let ((com (if *rv-region-keep-reverse* *last-command* *this-command*)))
    (if (and (not (member com *rv-continue-command-list*))
	     (or (member com *rv-exit-command-list*)
		 (string-match *rv-exit-command-regexp* (format nil "~S" com))))
	(rv-region-stop)
      (let ((m (mark t)))
	(and m (rv-region-command m com))))))

(defun rv-region-command (m com)
  (let ((p (point)))
    (if *rv-region-use-selection*
	(if (member com (remove 'set-mark-command *rv-start-command-list*))
	    (save-excursion
	      (save-restriction
		(narrow-to-region m p)
		(if (> m p)
		    (progn
		      (goto-char (point-max))
		      (selection-beginning-of-buffer))
		  (progn
		    (goto-char (point-min))
		    (selection-end-of-buffer)))))
	  (ed::begin-selection))
      (reverse-region m p t))))

(defun rv-region-watch ()
  (let ((m (mark t))
	(com *this-command*))
    (when (and m (member com *rv-start-command-list*))
      (rv-region-start)
      (rv-region-command m com))))

(defun rv-region-start ()
  (stop-selection)
  (add-hook '*post-command-hook* 'rv-region))

(defun rv-region-stop ()
  (delete-hook '*post-command-hook* 'rv-region))


;;; ──────────────────────────────────── ;;;
;;;  ■ 対話的な関数
;;; ──────────────────────────────────── ;;;

(defun rv-set-mark-command ()
  "rv-region: マークを付けリージョン反転表示を開始"
  (interactive)
  (set-mark-command)
  (rv-region-start))

(defun rv-restart ()
  "rv-region: リージョン反転表示を開始"
  (interactive)
  (rv-region-start))

(defun rv-check ()
  "rv-region: 反転されていないリージョンを一時的に反転表示"
  (interactive)
  (let ((m (mark t)))
    (and m (reverse-region m (point) t))))

(defun rv-toggle-watch ()
  "rv-region: マークセット後常に反転表示のトグル"
  (interactive)
  (if *rv-region-stay-on*
      (progn
	(delete-hook '*post-command-hook* 'rv-region-watch)
	(setq *rv-region-stay-on* nil)
	(message "rv-region: off"))
    (progn
      (add-hook '*post-command-hook* 'rv-region-watch)
      (setq *rv-region-stay-on* t)
      (message "rv-region: on"))))


;;; ──────────────────────────────────── ;;;
;;;  ■ 起動処理
;;; ──────────────────────────────────── ;;;

(add-hook '*post-startup-hook*
	  #'(lambda ()
	      (when *rv-region-stay-on*
		(add-hook '*post-command-hook* 'rv-region-watch))))


;;; rv-region.l ends here.
