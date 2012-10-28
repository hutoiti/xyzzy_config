;;; -*- Mode: Lisp; Package: EDITOR -*-
;;; function-bar-label.l

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Time-stamp: <2005/10/08 14:33:28 +0900>

;;; Commentary:

;; Description:
;;
;;  builtin の set-function-bar-label を拡張し、
;;  get-function-bar-label での label 取得を可能にします。
;;
;;  function-bar-label 変更のタイミングでの既存設定の保存が可能と
;;  なります。
;;

;; Installation:
;;
;;      1. アーカイブを展開して function-bar-label.l を $XYZZY/site-lisp に
;;         コピーします。
;;
;;      2. バイトコンパイルします。
;;
;;              M-x byte-compile-file
;;              Byte compile file: $XYZZY/site-lisp/function-bar-label.l
;;
;;      3. set-function-bar-label function を用いて label を設定する前
;;         (典型的には $XYZZY/site-lisp/siteinit.l の先頭)に以下のコー
;;         ドを追加します。
;;
;;              (require "function-bar-label")
;;
;;      4. 上記の設定を反映させるために、xyzzy を再起動します。
;;         siteinit.l に記述した場合は Ctrl キーと Shift キーを押しながら
;;         xyzzy を再起動し、ダンプファイルを再構築します。
;;

;; Uninstallation:
;;
;;      1. function-bar-label.l に関する記述を削除します。
;;
;;      2. siteinit.l に記述していた場合は Ctrl キーと Shift キーを押し
;;         ながら xyzzy を再起動し、ダンプファイルを再構築します。
;;

;; Changes:
;;
;;      Sat, 08 Oct 2005 14:30:51 +0900
;;        ・メールアドレスを変更。
;;        ・ライセンス条項(修正BSDライセンス)を記載。
;;
;;      Mon, 22 Dec 2003 19:08:03 +0900
;;         ・初版作成。
;;

;; Licence:
;;
;;    function-bar-label は修正BSDライセンスに基づいて利用可能です。
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

(provide "function-bar-label")

(in-package "editor")

(export '(set-function-bar-label
          get-function-bar-label
          set-function-bar-label-map
          get-function-bar-label-map
          view-function-bar-label-map))

(defun function-char-p (char)
  (and (characterp char)
       (string-match "^#\\\\\\([SCM]-\\)*F[1-9][0-9]?$" (format nil "~S" char))))
(defun make-meta-char (char)
  (let (c)
    (if (characterp char)
        (setq c (read-from-string
                 (substitute-string (format nil "~S" char)
                                    "#\\\\" "#\\\\M-"))))
    c))

(defconstant *set-function-bar-label-org-func* #'set-function-bar-label)

(unless (fboundp 'get-function-bar-label)
  (let ((function-bar-label-map (make-sparse-keymap)))
    (defun set-function-bar-label (char label)
      (setq label (cond ((stringp label) label)
                        ((characterp label) (string label))
                        ((null label) (copy-string ""))
                        (t (format nil "~S" label))))
      (prog1
          (funcall *set-function-bar-label-org-func* char label)
        (define-key function-bar-label-map char label)))
    (defun get-function-bar-label (char)
      (let ((value (lookup-keymap function-bar-label-map char)))
        (cond ((stringp value) value)
              ((characterp value) (string value))
              ((null value) "")
              (t (format nil "~S" value)))))
    (defun set-function-bar-label-map (keymap)
      (when (keymapp keymap)
        (let (char)
          (dotimes (index *full-keymap-length*)
            (setq char (*keymap-index-char index))
            (when (function-char-p char)
              (set-function-bar-label char (lookup-keymap keymap char))
              (setq char (make-meta-char char))
              (set-function-bar-label char (lookup-keymap keymap char)))))))
    (defun get-function-bar-label-map ()
      (copy-keymap function-bar-label-map)))
  (si:*load-library "monkey") (gc))

(defun view-function-bar-label-map (&optional (verbose t) num)
  (interactive)
  (let ((keymap (get-function-bar-label-map)) c label)
    (cond ((null num) (setq num (number-of-function-bar-labels)))
          ((not (integerp num)) (setq num t)))
    (with-output-to-temp-buffer ("*Help*")
      (flet ((view-function-bar-label-map-1 (&optional meta-p)
               (dotimes (index *full-keymap-length*)
                 (setq c (*keymap-index-char index))
                 (when (function-char-p c)
                   (if meta-p (setq c (make-meta-char c)))
                   (setq label (lookup-keymap keymap c))
                   (if (and verbose (not (stringp label)))
                       (setq label ""))
                   (if (and (stringp label)
                            (or verbose (string/= label ""))
                            (or (eq num t)
                                (and (string-match "[1-9][0-9]*$"
                                                   (format nil "~S" c))
                                     (<= (read-from-string (match-string 0))
                                         num))))
                       (format t "~20S ~A~%" c label))))))
        (view-function-bar-label-map-1)
        (view-function-bar-label-map-1 t))))
  t)

;;; function-bar-label.l ends here
