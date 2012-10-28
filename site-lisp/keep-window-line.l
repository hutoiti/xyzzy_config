;;; -*- Mode: Lisp; Package: EDITOR -*-
;;; keep-window-line.l --- ウィンドウ行を固定するマイナーモード

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Time-stamp: <2005/10/08 14:30:16 +0900>

;;; Commentary:

;; Description:
;;
;;  ウィンドウ行を固定するマイナーモードです。
;;
;;  ウィンドウをスクロールしても、カーソル行の表示位置を変更したくない
;;  場合に使用します。
;;

;; Installation:
;;
;;      1. アーカイブを展開して keep-window-line.l を $XYZZY/site-lisp に
;;         コピーします。
;;
;;      2. バイトコンパイルします。
;;
;;              M-x byte-compile-file
;;              Byte compile file: $XYZZY/site-lisp/keep-window-line.l
;;
;;      3. ~/.xyzzy または $XYZZY/site-lisp/siteinit.l に以下のコードを
;;         追加します。
;;
;;              (require "keep-window-line")
;;
;;      4. 上記の設定を反映させるために、xyzzy を再起動します。
;;         siteinit.l に記述した場合は Ctrl キーと Shift キーを押しながら
;;         xyzzy を再起動し、ダンプファイルを再構築します。
;;

;; Uninstallation:
;;
;;      1. keep-window-line.l に関する記述を削除します。
;;
;;      2. siteinit.l に記述していた場合は Ctrl キーと Shift キーを押し
;;         ながら xyzzy を再起動し、ダンプファイルを再構築します。
;;

;; Usage:
;;
;;      M-x keep-window-line-mode
;;

;; Setting example:
;;
;;      (require "keep-window-line")
;;

;; Changes:
;;
;;      Sat, 08 Oct 2005 14:28:49 +0900
;;        ・メールアドレスを変更。
;;        ・ライセンス条項(修正BSDライセンス)を記載。
;;
;;      Mon, 14 Feb 2005 20:54:11 +0900
;;        ・defvar-local 変数のシンボル名前後から * を除外。
;;        ・minor-mode 化。
;;
;;      Sun, 23 Feb 2003 18:56:24 +0900
;;        ・初版作成。
;;

;; Licence:
;;
;;    keep-window-line は修正BSDライセンスに基づいて利用可能です。
;;    <http://www.opensource.org/licenses/bsd-license.php>
;;
;;
;;    Copyright (C) 2001-2005, OHKUBO Hiroshi.  All rights reserved.
;;
;;    Redistribution and use in source and binary forms, with or without
;;    modification, are permitted provided that the following conditions
;;    are met:
;;
;;    1. Redistributions of source code must retain the above copyright
;;       notice, this list of conditions and the following disclaimer.
;;
;;    2. Redistributions in binary form must reproduce the above copyright
;;       notice, this list of conditions and the following disclaimer in
;;       the documentation and/or other materials provided with the
;;       distribution.
;;
;;    3. Neither the name of the University nor the names of its
;;       contributors may be used to endorse or promote products derived
;;       from this software without specific prior written permission.
;;
;;    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
;;    ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
;;    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
;;    A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
;;    OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
;;    SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
;;    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
;;    DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
;;    THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
;;    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
;;    OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;;

;;; Code:

(provide "keep-window-line")

(in-package "editor")

(export '(keep-window-line-mode))

(defvar-local keep-window-line-mode nil)
(defvar-local keep-window-line nil)

(defun keep-window-line ()
  "Keep window line."
  (when (and keep-window-line-mode
             (integerp keep-window-line)
             (/= keep-window-line (get-window-line)))
    (let ((goal (goal-column)))
      (recenter keep-window-line)
      (set-goal-column goal))))

(defun keep-window-line-mode (&optional (arg nil sv))
  "ウィンドウ行を固定するマイナーモード"
  (interactive "p")
  (toggle-mode 'keep-window-line-mode arg sv)
  (update-mode-line t)
  (if keep-window-line-mode
      (progn
        (setq keep-window-line (get-window-line))
        (add-hook '*post-command-hook* 'keep-window-line))
    (progn
      (setq keep-window-line nil)
      (dolist (buffer (buffer-list) (delete-hook '*post-command-hook* 'keep-window-line))
        (when (buffer-local-value buffer 'keep-window-line-mode)
          (return)))))
  t)
(pushnew '(keep-window-line-mode . "KWLine") *minor-mode-alist* :key #'car)

;;; keep-window-line.l ends here
