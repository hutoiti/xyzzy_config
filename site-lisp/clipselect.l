;;; -*- Mode: Lisp; Last modified: <2007/12/31 01:13:20> -*-
;;;
;;; This file is not part of xyzzy.
;;;
;;;   clipselect.l --- クリップボード履歴から選択して貼り付け
;;;
;;;     by HIE Masahiro <madoinu@ybb.ne.jp>
#|

■概要

  xyzzy およびその他のアプリケーションがクリップボードにコピーした
  データの履歴を作成し、ポップアップリストから選択して貼り付けます。

  セレクションがあれば、上書きして貼り付けます。

  既に履歴に存在する文字列をコピーした場合は、既存の要素を削除して、
  あらためて先頭要素として追加します。

  文字列の中に改行が含まれる場合は、指定した文字に置き換えてリスト
  に表示します。

  リストに表示される文字数は、*clipselect-string-length* で指定した
  値までしか表示しません。文字列が省略されている場合は、末尾に " ..."
  を表示します。

  nonentity さんの、「まいくろちっぷすxyzzy部門」
         http://members.tripod.co.jp/zauberer/microtips/xyzzy.html
  にある clipstore.l を参考に、clipview.l を使わせていただきつつ、
  つくってみました。nonentity さんには、clipview.l の同時配布も快諾
  していただき感謝です。

  おまけでつけた clipselect-yank は、須田さん
                              http://member.nifty.ne.jp/seiya-suda/
  の yank-select を参考にさせていただきました。こちらは、キルリング
  から選択して貼り付けます。


■インストール

  1. clipview.l と clipselect.l を ~/site-lisp にコピーする。

  2. .xyzzy か siteinit.l に以下の記述を追加する。

      (require "clipselect")

使い方:

  ・履歴から選択して貼り付け  M-x clipselect
  ・clipboard と同期化切替    M-x clipselect-toggle-sync

■設定例

  ・キーバインド

      (define-key ctl-x-map #\Insert 'clipselect-paste)
      (define-key ctl-x-map #\y 'clipselect-yank)
      (define-key ctl-x-map #\F9 'clipselect-yank-selection)

    とか。


■更新履歴

  [Version 1.05] 2007-12-31 (月)
  ・ライセンス条項(MITライセンス)を記載。

  [Version 1.04.1] 2004/07/04 (日)
  ・編集メニューにも追加できるようにした。
  ・「セレクションリングから貼り付け」も同梱した。
  ・clipselect を clipselect-paste に変更した。

  [Version 2003.05.13]
  ・右クリックメニューへ追加した。
  ・yankselect を clipselect-yank に変更した。

  [Version 1.03] 2003/04/09 (水)
  ・リストの表示文字数を制限するために、を popup-menu を使うようにした。
  ・改行を別の文字に置き換えて表示できるようにした。
  ・clipselect-sync を clipselect-toggle-sync に変更した。
  ・おまけで、yankselect をつけた。
  ・同梱の clipview.l を新しいものにした。（nonentity さんありがとうございます。）

  [Version 1.02.1] 2003/01/15 (水)
  ・終了処理用 hook の追加/削除を丁寧にするようにした。

  [Version 1.02] 2003/01/15 (水)
  ・後から起動した xyzzy を先に終了させると、clipboard と同期が取れ
    なくなる不具合を修正した。（つもり）

  [Version 1.01] 2003/01/14 (火)
  ・clipselect-copy, clipselect-kill が不要なことに今頃気付き削除した。
  ・*clipselect-sync*, clipselect-sync を追加した。
  ・データ末尾のホワイトスペースおよび改行を削除しないようにした。
  ・clipselect-clear, *clipselect-enable-self-owner* を削除した。
  ・clipselect-viewer-hook を削除し、clipselect-push にまとめた。

  [Version 1.00] 2002/12/30 (月)
  ・つくった。


■ライセンス

  clipselect.l はMITライセンスに基づいて利用可能です。
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

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "clipview"))

(provide "clipselect")


;;; ──────────────────────────────────── ;;;
;;;  ■ 変数設定（適当にカスタマイズするあたり）
;;; ──────────────────────────────────── ;;;

;;; xyzzy 起動時に clipboard と同期を開始
(defvar *clipselect-sync* t)

;;; 保存する履歴の数
(defvar *clipselect-ring-max* 16)

;;; ポップアップメニューの表示文字数
(defvar *clipselect-string-length* 50)

;;; 改行を置き換える文字
(defvar *clipselect-new-line-char* "┃")

;;; 編集メニューへ追加する
(defvar *clipselect-add-menu* t)

;;; ショートカットメニューへ追加する
(defvar *clipselect-add-popup-menu* t)

;;; メニュー挿入位置
(defvar *clipselect-menu-position* 4)

(defvar *clipselect-ring* nil)


;;; ──────────────────────────────────── ;;;
;;;  ■ クリップボード履歴操作
;;; ──────────────────────────────────── ;;;

(defun clipselect-paste ()
  "clipselect: クリップボードの履歴から選択して貼り付け"
  (interactive "*")
  (let ((menu (create-popup-menu nil))
	from to)
    (dotimes (arg (length *clipselect-ring*))
      (let* ((str (string (nth arg *clipselect-ring*)))
	     (shortstr (if *clipselect-new-line-char*
			   (substitute-string str "\n" *clipselect-new-line-char*)
			 str)))
	(add-menu-item menu 'clipselect
		       (if (< (length shortstr) *clipselect-string-length*)
			   shortstr
			 (concat (substring shortstr 0 *clipselect-string-length*) " ..."))
		       #'(lambda ()
			   (interactive)
			   (selection-start-end (start end)
			     (delete-region start end))
			   (insert str)))))
    (track-popup-menu menu)))

;;; 旧関数名との互換
(setf (symbol-function 'clipselect) 'clipselect-paste)

#|
;;; 前に使ってたもの
(defun clipselect-paste ()
  "clipselect: クリップボードの履歴から選択して貼り付け"
  (interactive "*")
  (let (from to)
    (selection-start-end (start end)
      (setq from start)(setq to end))
    (popup-list *clipselect-ring*
		#'(lambda (str)
		    (when (and from to)
		      (delete-region from to))
		    (insert str)
		    (refresh-screen)))))
|#

(defun clipselect-toggle-sync ()
  "clipselect: クリップボードとの同期を切り替え"
  (interactive)
  (if *clipselect-sync*
      (progn (setq *clipselect-sync* nil)
	(win-user::delete-clipboard-viewer-hook 'clipselect-push)
	(delete-hook '*kill-xyzzy-hook* 'clipselect-exit)
	(message "clipselect-sync stop."))
    (progn (setq *clipselect-sync* t)
      (win-user::add-clipboard-viewer-hook 'clipselect-push)
      (add-hook '*kill-xyzzy-hook* 'clipselect-exit)
      (message "clipselect-sync start."))))

(defun clipselect-push ()
  (let ((str (get-clipboard-data)))
    (when str
      (setq *clipselect-ring* (remove str *clipselect-ring* :test #'string=))
      (setq *clipselect-ring*
	    (ed::push-kill-ring str *clipselect-ring* *clipselect-ring-max*)))))

(defun clipselect-exit ()
  (win-user::delete-clipboard-viewer-hook 'clipselect-push))


;;; ──────────────────────────────────── ;;;
;;;  ■ *kill-ring*/*selection-ring* 操作
;;; ──────────────────────────────────── ;;;

(defun clipselect-yank ()
  "clipselect: キルリングから選択して貼り付け"
  (interactive "*")
  (let ((menu (create-popup-menu nil))
	from to)
    (dotimes (arg (length *kill-ring*))
      (let* ((str (car (ed::current-kill arg t)))
	     (shortstr (if *clipselect-new-line-char*
			   (substitute-string str "\n" *clipselect-new-line-char*)
			 str)))
	(add-menu-item menu 'yankselect
		       (if (< (length shortstr) *clipselect-string-length*)
			   shortstr
			 (concat (substring shortstr 0 *clipselect-string-length*) " ..."))
		       #'(lambda ()
			   (interactive)
			   (selection-start-end (start end)
			     (delete-region start end))
			   (insert str)))))
    (track-popup-menu menu)))

(defun clipselect-yank-selection ()
  "clipselect: セレクションリングから選択して貼り付け"
  (interactive "*")
  (let ((menu (create-popup-menu nil))
	from to)
    (dotimes (arg (length *selection-ring*))
      (let* ((str (cdr (ed::current-selection arg t)))
	     (shortstr (if *clipselect-new-line-char*
			   (substitute-string str "\n" *clipselect-new-line-char*)
			 str)))
	(add-menu-item menu 'clipselect2
		       (if (< (length shortstr) *clipselect-string-length*)
			   shortstr
			 (concat (substring shortstr 0 *clipselect-string-length*) " ..."))
		       #'(lambda ()
			   (interactive)
			   (selection-start-end (start end)
			     (delete-region start end))
			   (insert str)))))
    (track-popup-menu menu)))


;;; ──────────────────────────────────── ;;;
;;;  ■ メニュー
;;; ──────────────────────────────────── ;;;

;;; 編集メニューに追加
;;;   OHKUBO さんの multiple-replace.l から頂き m(_ _)m
(defun clipselect-insert-menu (&key menu position head-sep tail-sep)
  (if (and (not (menup menu)) (menup *app-menu*))
      (setq menu (get-menu *app-menu* 'ed::edit)))
  (when (menup menu)
    ;(clipselect-delete-menu menu)
    (unless (and (numberp position) (integerp position) (not (minusp position))
		 (get-menu menu position t))
      (setq position -1)
      (while (get-menu menu (incf position) t)))
    (decf position)
    (if (and head-sep
	     (not (minusp position))
	     (get-menu menu position t))
	(insert-menu-separator menu (incf position) 'clipselect-sep))
    (insert-menu-item menu (incf position) nil
		      "履歴から選択して貼り付け(&H)..."
		      'clipselect-paste
		      #'(lambda ()
			  (unless *clipselect-ring*
			    :disable)))
    (insert-menu-item menu (incf position) nil
		      "キルリングから選択して貼り付け(&K)..."
		      'clipselect-yank
		      #'(lambda ()
			  (unless *kill-ring*
			    :disable)))
    (insert-menu-item menu (incf position) nil
		      "セレクションリングから選択して貼り付け(&Y)..."
		      'clipselect-yank-selection
		      #'(lambda ()
			  (unless *selection-ring*
			    :disable)))
    (if (and tail-sep
	     (get-menu menu (incf position) t))
	(insert-menu-separator menu position 'clipselect-sep))))

;;; ショートカットメニューに追加
(defun clipselect-insert-popup-menu ()
  (let (pos menu)
    (setq pos *clipselect-menu-position*)
    (setq menu *app-popup-menu*)
    (setq pos (1- pos))
    (insert-menu-separator menu (incf pos))
    (insert-menu-item menu (incf pos) nil
		      "履歴から選択して貼り付け(&H)..."
		      'clipselect-paste
		      #'(lambda ()
			  (unless *clipselect-ring*
			    :disable)))
    (insert-menu-item menu (incf pos) nil
		      "キルリングから選択して貼り付け(&K)..."
		      'clipselect-yank
		      #'(lambda ()
			  (unless *kill-ring*
			    :disable)))
    (insert-menu-item menu (incf pos) nil
		      "セレクションリングから選択して貼り付け(&Y)..."
		      'clipselect-yank-selection
		      #'(lambda ()
			  (unless *selection-ring*
			    :disable)))
    (insert-menu-separator menu (incf pos))))


;;; ──────────────────────────────────── ;;;
;;;  ■ 起動時の処理
;;; ──────────────────────────────────── ;;;

(defun clipselect-init ()
  (when *clipselect-add-menu*
    (clipselect-insert-menu :position 7 :head-sep t :tail-sep t))
  (when *clipselect-add-popup-menu*
    (clipselect-insert-popup-menu))
  (when *clipselect-sync*
    (win-user::add-clipboard-viewer-hook 'clipselect-push)
    (add-hook '*kill-xyzzy-hook* 'clipselect-exit)))

(add-hook '*init-app-menus-hook* #'clipselect-init)


;;; clipselect.l ends here.
