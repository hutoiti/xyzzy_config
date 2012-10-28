;;; -*- Mode: Lisp; Package: USER; Last modified: "2007/12/31 01:04:52" -*-
;;;
;;; This file is not part of xyzzy.
;;;
;;;   buf-menu-plus.l --- buffer-menu の拡張版(？)
;;;
;;;     by HIE Masahiro <madoinu@ybb.ne.jp>
#|

■概要

  ・ウィンドウを分割しないで，カレントウィンドウにリストを表示
  ・他ウィンドウを開いてバッファを閲覧
  ・マーク行等に色付け
  ・複数バッファにまとめてマークをつける/はずす
  ・ファイルのないバッファ保存時に「名前を付けて保存」ダイアログを表示
  ・終了時にマークを実行
  ・diff の実行
  ・複数ファイル一括バイトコンパイル
  ・複数ファイル一括印刷
  ・実行(shell-execute)
  ・マウスダブルクリック対応
  ・buffer-menu 起動時に，アクティブだったバッファの行に移動
  ・既定のフレームに移動して起動（要 bufmenu.l）


■インストール

  1. buf-menu-plus.l を site-lisp にコピーする。

  2. 必要に応じ，バイトコンパイルする。

       M-x byte-compile-file

  3. .xyzzy か siteinit.l に以下の記述を追加する。

      (require "buf-menu-plus")

  4. xyzzy を再起動し，設定を反映させる。
     siteinit.l に記述した場合は再ダンプもする。


■起動方法

  ・C-x C-b で拡張版(？)buffer-menuを起動します。

  ・C-u と入力してから上記コマンドを実行すると，ファイルに関連付けられた
    バッファのみを表示します。M-x buffer-menu-plus-visit でもよいです。


■キーバインド

    RET : カーソル行のバッファを開く
    TAB : カーソル行のバッファを他のウィンドウで閲覧
    M-n : 次行のバッファを他のウィンドウで閲覧（or M-Down）
    M-p : 前行のバッファを他のウィンドウで閲覧（or M-Up）
    0   : カーソル行のバッファをカレントウィンドウで開く
    1   : カーソル行のバッファを開く＆他のウィンドウを閉じる
    b   : バイトコンパイルマーク "B" をつける
    p   : 印刷マーク "P" を付ける
    D   : 全てのバッファに削除マーク "D" をつける
    S   : 未保存バッファに保存マーク "S" をつける
    U   : 全てのマークを消す
    x   : マークを実行
    t   : diff マーク "O" または "N" をトグル
    M-f : diff を実行
    M-s : カーソル行のファイルを実行
    q   : buffer-menu を終了

  その他は，標準の buffer-menu (list-buffers) と同じ。（たぶん）

    f   : カーソル行のバッファを開く
    s   : 保存マーク "S" を付ける
    d   : 削除マーク "D" を付ける
    k   : 削除マーク "D" を付ける
    o   : カーソル行のバッファを他のウィンドウで開く
    C-d : 削除マーク "D" を付けて前の行に移動
    C-k : 削除マーク "D" を付ける
    SPC : 次の行に移動
    ~   : 変更マークを消す
    u   : マークを消す


■diff

  diff の実行には，diff.exe が必要となります。どこかから手に入れてください。

  buffer-menu で比較したいバッファにカーソルを合わせ，t を押します。このキ
  ーによりマークがトグルしますが，`O' が old file，`N' が new file となり
  ます。マークを付けたら，M-f を入力し，diff を実行します。

  diff 実行後には，対象バッファに対し revert-buffer を実行し，diff の結果
  をバッファに反映させます。


■カスタマイズ

  buffer-menu から navigate を実行するにはこんな感じで。一覧から選択できる
  のでちょっと便利かも。

    ;;; browser で開く (M-b)
    (defun buf-menu-plus-navigate ()
      (interactive)
      (save-excursion
        (bx:navigate (get-buffer-file-name (ed::buffer-menu-buffname)))))
    (define-key ed::*buffer-menu-mode-map* #\M-b 'buf-menu-plus-navigate)


■更新履歴

  [Version 1.02] 2007-12-31 (月)
  ・MITライセンスにした。

  [Version 1.01] 2005-02-03 (Thu)
  ・公開用にいくらか整理。

  [Version 1.00] 2003-10-05 (Sun)
  ・初版作成。


■ライセンス

  buf-menu-plus.l はMITライセンスに基づいて利用可能です。
  <http://www.opensource.org/licenses/mit-license.php>

Copyright (c) 2007 HIE Masahiro

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

(provide "buf-menu-plus")

;;; ──────────────────────────────────── ;;;
;;;  ■ 変数設定（適当にカスタマイズするあたり）
;;; ──────────────────────────────────── ;;;

;;; 終了時にマークを実行する
(defvar *buf-menu-plus-execute-mark-before-quit* t)

;;; バッファを選択した後 buffer-menu を終了する
(defvar *buf-menu-plus-close-buffer* t)

;;; diff 実行後，勝手にディスクから読み直す
(defvar *buf-menu-plus-diff-revert-buffer-no-question* t)

;;; タイトルの色
(defvar *buffer-menu-plus-color-title* '(:color 14))

;;; セパレータの色
(defvar *buffer-menu-plus-color-sep* '(:color 15))

;;; 削除マーク行の色
(defvar *buffer-menu-plus-color-D* '(:color 1))

;;; 削除マーク行(未保存バッファ)の色
(defvar *buffer-menu-plus-color-*D* '(:color 1 0 :bold))

;;; 保存マーク行の色
(defvar *buffer-menu-plus-color-S* '(:color 4 0 :bold))

;;; バイトコンパイル/印刷マークの色
(defvar *buffer-menu-plus-color-BP* '(:color 4))

;;; Diff マーク（Old）行の色
(defvar *buffer-menu-plus-color-O* '(:color 10 0 :bold))

;;; Diff マーク（New）行の色
(defvar *buffer-menu-plus-color-N* '(:color 13 0 :bold))

;;; カレントバッファの色
(defvar *buffer-menu-plus-color-dot* '(:color 0 0 :bold))

;;; *hoge* バッファの色
(defvar *buffer-menu-plus-color-** '(:color 9))


;;; ──────────────────────────────────── ;;;
;;;  ■ その他の変数設定
;;; ──────────────────────────────────── ;;;

(defvar *buf-menu-plus-buffer-name* "*Buffer List*")
(defvar *buf-menu-plus-diff-list* nil)
(defvar *buf-menu-plus-windows* nil)
(defvar *buffer-menu-plus-hook* nil)


;;; ──────────────────────────────────── ;;;
;;;  ■ buffer-menu
;;; ──────────────────────────────────── ;;;

(defun buffer-menu-plus (&optional arg)
  "拡張版(？)buffer-menu"
  (interactive)
  (setf *buf-menu-plus-windows* (count-windows))
  ;; bufmenu.l があれば既定のフレームに移動したり
  (when (fboundp 'bufmenu-select-default-frame)
    (bufmenu-select-default-frame))
  (let (winconf)
    (setq winconf (current-window-configuration))
    (setq *list-buffers-plus-winconf* (current-window-configuration))
    (list-buffers (or arg *prefix-args*))
    (set-window-configuration winconf)
    (set-buffer *buf-menu-plus-buffer-name*)
    (scan-buffer "^\\." :regexp t))
  ;; バッファの状態を調整
  (make-local-variable 'regexp-keyword-list)
  (setf regexp-keyword-list
	(compile-regexp-keyword-list
	 `(("^ MR.*" t ,*buffer-menu-plus-color-title*)
	   ("^[ -]+$" t ,*buffer-menu-plus-color-sep*)
	   ("^.[^*]D.*" t ,*buffer-menu-plus-color-D*)
	   ("^.\\*D.*" t ,*buffer-menu-plus-color-*D*)
	   ("^.S[^D].*" t ,*buffer-menu-plus-color-S*)
	   ("^..[BP].*" t ,*buffer-menu-plus-color-BP*)
	   ("^..O.*" t ,*buffer-menu-plus-color-O*)
	   ("^..N.*" t ,*buffer-menu-plus-color-N*)
	   ("^\\..*" t ,*buffer-menu-plus-color-dot*)
	   ("^....\\*.*" t ,*buffer-menu-plus-color-**)
	   )))
  (let ((buf (selected-buffer)))
    (set-local-window-flags buf *window-flag-line-number* nil)
    (set-local-window-flags buf *window-flag-newline* nil)
    (set-local-window-flags buf *window-flag-eof* nil))
  (run-hooks '*buffer-menu-plus-hook*))

(defun buffer-menu-plus-visit ()
  "bufmenu-plus ファイルに関連付けられたバッファ一覧"
  (interactive)
  (buffer-menu-plus t))

(defun buf-menu-plus-execute ()
  "bufmenu-plus マークを実行"
  (interactive)
  ;; 保存
  (goto-char (point-min))
  (while (scan-buffer "^.S" :regexp t)
    (save-excursion
      (set-buffer (ed::buffer-menu-buffname))
      (if (get-buffer-file-name)
	  (save-buffer)
	(progn
	  (refresh-screen)
	  (save-buffer-dialog))))
    (forward-line 1))
  ;; 削除
  (goto-char (point-min))
  (while (scan-buffer "^..D" :regexp t)
    (delete-buffer (ed::buffer-menu-buffname))
    (forward-line 1))
  ;; バイトコンパイル
  (goto-char (point-min))
  (while (scan-buffer "^..B" :regexp t)
    (byte-compile-file (get-buffer-file-name (ed::buffer-menu-buffname)))
    (forward-line 1))
  ;; 印刷
  (goto-char (point-min))
  (let ((i 0))
    (while (scan-buffer "^..P" :regexp t)
      (if (zerop i)
	  (progn
	    (print-dialog (ed::buffer-menu-buffname))
	    (setq i (1+ i)))
	(print-buffer (ed::buffer-menu-buffname)))
      (forward-line 1)))
  (buffer-menu-plus))


;;; ──────────────────────────────────── ;;;
;;;  ■ buffer-menu マークをつける
;;; ──────────────────────────────────── ;;;

(defun buf-menu-plus-unmark-all ()
  "bufmenu-plus ぜんぶのマークを外す"
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (goto-line 3)
    (while (not (eobp))
      (buffer-menu-unmark))))

(defun buf-menu-plus-delete-all ()
  "bufmenu-plus ぜんぶに削除マーク"
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (goto-line 3)
    (while (not (eobp))
      (if (equal (ed::buffer-menu-buffname) "*scratch*")
	  (next-line)
	(buffer-menu-delete)))))

(defun buf-menu-plus-save-all ()
  "bufmenu-plus 未保存バッファに保存マーク"
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (goto-line 3)
    (while (scan-buffer "^.\\*" :regexp t)
      (if (equal (ed::buffer-menu-buffname) "*scratch*")
	  (next-line)
	(buffer-menu-save)))))

;;; shell-execute
(defun buf-menu-plus-shell-execute ()
  "bufmenu-plus shell-execute"
  (interactive)
  (shell-execute (get-buffer-file-name (ed::buffer-menu-buffname))))

(defun buf-menu-plus-byte-compile ()
  "bufmenu-plus バイトコンパイルするファイルにマーク"
  (interactive)
  (ed::buffer-menu-buffer-exist-p)
  (goto-column 2)
  (let ((buffer-read-only nil))
    (declare (special buffer-read-only))
    (insert #\B)
    (delete-char 1))
  (forward-line 1))

(defun buf-menu-plus-print ()
  "bufmenu-plus 印刷するファイルにマーク"
  (interactive)
  (ed::buffer-menu-buffer-exist-p)
  (goto-column 2)
  (let ((buffer-read-only nil))
    (declare (special buffer-read-only))
    (insert #\P)
    (delete-char 1))
  (forward-line 1))

(defun buf-menu-plus-mark-diff ()
  "bufmenu-plus diff するファイルにマーク"
  (interactive)
  (ed::buffer-menu-buffer-exist-p)
  (goto-column 2)
  (let ((buffer-read-only nil))
    (declare (special buffer-read-only))
    (if (not (save-excursion
	       (goto-char (point-min))
	       (scan-buffer "^..O" :regexp t)))
	(insert #\O)
      (if (not (save-excursion
		 (goto-char (point-min))
		 (scan-buffer "^..N" :regexp t)))
	  (insert #\N)
	(insert #\SPC)))
    (delete-char 1)))

;;; buffer-menuを閉じる
(defun buf-menu-plus-quit ()
  "bufmenu-plus 終了"
  (interactive)
  ;;マークを実行
  (when (and *buf-menu-plus-execute-mark-before-quit*
	     (save-excursion
	       (goto-char (point-min))
	       (scan-buffer "^.\\(S\\|.[BDP]\\)" :regexp t))
	     (yes-or-no-p "マークを実行する？"))
    (buf-menu-plus-execute))
  ;;必要に応じウィンドウを閉じる
  (when (< *buf-menu-plus-windows* (count-windows))
    (delete-other-windows))
  (kill-buffer (selected-buffer)))


;;; ──────────────────────────────────── ;;;
;;;  ■ buffer-menu バッファを選択して開く
;;; ──────────────────────────────────── ;;;

(defun buf-menu-plus-1-window ()
  "bufmenu-plus カーソル行のバッファを開く＆他のウィンドウを閉じる"
  (interactive)
  (buffer-menu-1-window)
  (when *buf-menu-plus-close-buffer*
    (delete-buffer *buf-menu-plus-buffer-name*)))

(defun buf-menu-plus-other-window ()
  "bufmenu-plus カーソル行のバッファを他ウィンドウで閲覧"
  (interactive)
  (save-excursion
    (ed::buffer-menu-other-window)
    (other-window -1)))

(defun buf-menu-plus-view-next (&optional (arg -1))
  "bufmenu-plus "
  (interactive)
  (next-virtual-line arg)
  (buf-menu-plus-other-window))

(defun buf-menu-plus-view-previous (&optional (arg 1))
  "bufmenu-plus "
  (interactive)
  (buf-menu-plus-view-next 1))

(defun buf-menu-plus-this-window ()
  "bufmenu-plus カーソル行のバッファをカレントウィンドウで開く"
  (interactive)
  (buffer-menu-this-window)
  (when *buf-menu-plus-close-buffer*
    (delete-buffer *buf-menu-plus-buffer-name*)))

(defun buf-menu-plus-left-press ()
  "bufmenu-plus ダブルクリックで開く"
  (interactive)
  (let ((click (mod *last-mouse-click-count* 6)))
    (if (= click 2)
	(buf-menu-plus-open)
      (mouse-left-press))))

;;; カーソル行のバッファをカレントウィンドウで開く
(defun buf-menu-plus-open ()
  "bufmenu-plus カーソル行のバッファを開く"
  (interactive)
  (if (= *buf-menu-plus-windows* (count-windows))
      (buf-menu-plus-this-window)
    (buf-menu-plus-1-window)))


;;; ──────────────────────────────────── ;;;
;;;  ■ buffer-menu から diff
;;; ──────────────────────────────────── ;;;

(require "diff")

(defun buf-menu-plus-diff ()
  "bufmenu-plus diff実行"
  (interactive)
  (define-key *diff-mode-map* #\q 'buf-menu-plus-diff-quit)
  (setq *buf-menu-plus-diff-list* nil)
  (let (o n)
    (goto-char (point-min))
    (while (scan-buffer "^..O" :regexp t)
      (push (ed::buffer-menu-buffname) *buf-menu-plus-diff-list*)
      (setq o (get-buffer-file-name (ed::buffer-menu-buffname)))
      (forward-line 1))
    (goto-char (point-min))
    (while (scan-buffer "^..N" :regexp t)
      (push (ed::buffer-menu-buffname) *buf-menu-plus-diff-list*)
      (setq n (get-buffer-file-name (ed::buffer-menu-buffname)))
      (forward-line 1))
    (buf-menu-plus-quit)
    (if (and o n)
	(diff n o)
      (message "ファイルがないよん"))
    ))

(defun buf-menu-plus-diff-quit ()
  "bufmenu-plus diff終了＆ディスクから読み直す"
  (interactive)
  (diff-quit)
  (with-set-buffer
    (dolist (buffer *buf-menu-plus-diff-list* t)
      (when (find-buffer buffer)
	(or (null (get-buffer-file-name buffer))
	    (null (buffer-local-value buffer 'verify-visited-file-modtime))
	    (verify-visited-file-modtime buffer)
	    (save-excursion
	      (set-buffer buffer)
	      (when (or *buf-menu-plus-diff-revert-buffer-no-question*
			(yes-or-no-p "ディスクから読み直しますか?"))
		(update-visited-file-modtime)
		(revert-buffer)))))))
  (setq *buf-menu-plus-diff-list* nil)
  ;;戻さなくても実害はないような気がするけれど…
  (define-key *diff-mode-map* #\q 'diff-quit)
  t)


;;; ──────────────────────────────────── ;;;
;;;  ■ buffer-menu キーバインド
;;; ──────────────────────────────────── ;;;

(define-key ed::*buffer-menu-mode-map* #\LBtnUp 'buf-menu-plus-left-press)

(define-key ed::*buffer-menu-mode-map* #\U   'buf-menu-plus-unmark-all)
(define-key ed::*buffer-menu-mode-map* #\D   'buf-menu-plus-delete-all)
(define-key ed::*buffer-menu-mode-map* #\S   'buf-menu-plus-save-all)

(define-key ed::*buffer-menu-mode-map* #\RET 'buf-menu-plus-open)
(define-key ed::*buffer-menu-mode-map* #\TAB 'buf-menu-plus-other-window)
(define-key ed::*buffer-menu-mode-map* #\M-Up 'buf-menu-plus-view-next)
(define-key ed::*buffer-menu-mode-map* #\M-Down 'buf-menu-plus-view-previous)
(define-key ed::*buffer-menu-mode-map* #\M-p 'buf-menu-plus-view-next)
(define-key ed::*buffer-menu-mode-map* #\M-n 'buf-menu-plus-view-previous)
(define-key ed::*buffer-menu-mode-map* #\1   'buf-menu-plus-1-window)
(define-key ed::*buffer-menu-mode-map* #\0   'buf-menu-plus-this-window)
(define-key ed::*buffer-menu-mode-map* #\b   'buf-menu-plus-byte-compile)
(define-key ed::*buffer-menu-mode-map* #\p   'buf-menu-plus-print)
(define-key ed::*buffer-menu-mode-map* #\q   'buf-menu-plus-quit)
(define-key ed::*buffer-menu-mode-map* #\x   'buf-menu-plus-execute)
(define-key ed::*buffer-menu-mode-map* #\t   'buf-menu-plus-mark-diff)
(define-key ed::*buffer-menu-mode-map* #\M-f 'buf-menu-plus-diff)
(define-key ed::*buffer-menu-mode-map* #\M-s 'buf-menu-plus-shell-execute)

;;; buffer-menu 起動
(define-key ctl-x-map #\C-b 'buffer-menu-plus)


;;; buf-menu-plus.l ends here.
