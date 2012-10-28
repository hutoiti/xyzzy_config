;;; -*- Mode: Lisp; Package: USER; Last modified: "2005/03/09 00:07:19"; -*-
;;;
;;; This file is not part of xyzzy.
;;;
;;;   arrange-line.l --- 行を揃える
;;;
;;;     by HIE Masahiro <madoinu@ybb.ne.jp>

#|

■概要

  行を左や右や中央に揃えます。ツールバーつき。


■インストール

  1. arrange-line.l を site-lisp にコピーする。

  2. 必要に応じ，バイトコンパイルする。

       M-x byte-compile-file

  3. .xyzzy か siteinit.l に以下の記述を追加する。

      (require "arrange-line")

  4. xyzzy を再起動し，設定を反映させる。
     siteinit.l に記述した場合は再ダンプもする。


■アンインストール

  1. ツールバー情報を削除する。

       M-x arrange-uninstall-tool-bar

  2. 初期化ファイルから設定を削除する。
     siteinit.l に記述していた場合は再ダンプする。

  3. このファイル arrange-line.l（および arrange-line.lc）を削除する。


■使い方

  ツールバーから使うには，メニューの[表示(V)]→[ツールバー(O)]→
  [arranges(A)] を選択します。

  その他，

    M-x arrange-left-selection      ; 選択範囲を左揃え
    M-x arrange-center-selection    ; 選択範囲を中央揃え
    M-x arrange-right-selection     ; 選択範囲を右揃え

  とか。


■ ライセンス

  himawari-mode.l は NYSL Version 0.9982 に従います。

    NYSL - http://www.kmonos.net/nysl/

  A. 本ソフトウェアは Everyone'sWare です。このソフトを手にした一人一人が、
     ご自分の作ったものを扱うのと同じように、自由に利用することが出来ます。

    A-1. フリーウェアです。作者からは使用料等を要求しません。
    A-2. 有料無料や媒体の如何を問わず、自由に転載・再配布できます。
    A-3. いかなる種類の 改変・他プログラムでの利用 を行っても構いません。
    A-4. 変更したものや部分的に使用したものは、あなたのものになります。
         公開する場合は、あなたの名前の下で行って下さい。

  B. このソフトを利用することによって生じた損害等について、作者は
     責任を負わないものとします。各自の責任においてご利用下さい。

  C. 著作者人格権は HIE Masahiro に帰属します。著作権は放棄します。

  D. 以上の３項は、ソース・実行バイナリの双方に適用されます。


■更新履歴:

  [Version 1.01] 2005-03-09 (Wed)
  ・書き込み禁止バッファでは，ツールバーの操作ができないように。

  [Version 1.00] 2005-03-08 (Tue)
  ・つくった。

|#

(provide "arrange-line")

;;; 中央寄せ
;;; 0: center, 1:left, 2:right
(defun arrange-center-line (&optional (arg 0))
  (interactive "*")
  (save-excursion
    (goto-bol)
    (delete-region (point)
		   (progn
		     (skip-chars-forward " \t　")
		     (point)))
    (goto-eol)
    (delete-region (point)
		   (progn
		     (skip-chars-backward " \t　")
		     (point)))
    (unless (eq arg 1)
      (let ((n (- fill-column (current-column))))
	(when (zerop arg)
	  (setq n (truncate n 2)))
	(when (plusp n)
	  (goto-bol)
	  (or (eolp)
	      (indent-to n)))))
    (untabify (progn (goto-eol) (point))
	      (progn (goto-bol) (point)))))

;;; 左寄せ
(defun arrange-left-line ()
  (interactive "*")
  (arrange-center-line 1))

;;; 右寄せ
(defun arrange-right-line ()
  (interactive "*")
  (arrange-center-line 2))


;;; 選択範囲を中央寄せ
(defun arrange-center-selection (&optional (arg 0))
  (interactive "*")
  (save-restriction
    (selection-start-end (start end)
      (narrow-to-region start end)
      (goto-char (point-min))
      (while (not (eobp))
	(case arg
	  (0 (arrange-center-line))
	  (1 (arrange-left-line))
	  (2 (arrange-right-line)))
	(goto-bol)
	(unless (forward-line 1)
	  (return))))))

;;; 選択範囲を左寄せ
(defun arrange-left-selection ()
  (interactive "*")
  (arrange-center-selection 1))

;;; 選択範囲を右寄せ
(defun arrange-right-selection ()
  (interactive "*")
  (arrange-center-selection 2))

(defun arrange-tool-bar-update ()
  (when buffer-read-only :disable))

;;; ツールバー定義
(defun arrange-tool-bar ()
  (create-tool-bar 'arrange-tool-bar
		   (merge-pathnames "toolbar.bmp" (etc-path))
		   '(("左揃え" 33 arrange-left-line arrange-tool-bar-update)
		     ("中央揃え" 35 arrange-center-line arrange-tool-bar-update)
		     ("右揃え" 32 arrange-right-line arrange-tool-bar-update))))

;;; ツールバー登録
(define-command-bar 'arrange-tool-bar "arranges(&A)")

;;; ツールバー削除
(defun arrange-uninstall-tool-bar ()
  (delete-command-bar 'arrange-tool-bar))


;;; arrange-line.l は，ここまで。
