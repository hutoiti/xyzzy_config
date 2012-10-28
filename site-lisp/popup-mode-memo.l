;;; -*- Mode: Lisp -*-
;;; popup-mode-memo.l

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Version: 0.0.0.3
;; Time-stamp: <2005/10/08 11:48:23 +0900>

;;; Commentary:

;; Description:
;;
;;  モード毎のキーバインディングや自分で設定したメモをポップアップ表示
;;  します。
;;

;; Installation:
;;
;;      1. アーカイブを展開して popup-mode-memo.l を $XYZZY/site-lisp に
;;         コピーします。
;;
;;      2. バイトコンパイルします。
;;
;;              M-x byte-compile-file
;;              Byte compile file: $XYZZY/site-lisp/popup-mode-memo.l
;;
;;      3. ~/.xyzzy または $XYZZY/site-lisp/siteinit.l に以下のコードを
;;         追加します。
;;
;;              (require "popup-mode-memo")
;;              (global-set-key #\C-F12 'popup-mode-memo)
;;              (set-function-bar-label #\C-F12 "memo")
;;
;;      4. 上記の設定を反映させるために、xyzzy を再起動します。
;;         siteinit.l に記述した場合は Ctrl キーと Shift キーを押しながら
;;         xyzzy を再起動し、ダンプファイルを再構築します。
;;

;; Uninstallation:
;;
;;      1. popup-mode-memo.l に関する記述を削除します。
;;
;;      2. siteinit.l に記述していた場合は Ctrl キーと Shift キーを押し
;;         ながら xyzzy を再起動し、ダンプファイルを再構築します。
;;

;; Key bind:
;;
;;      C-F12   メモのポップアップ表示
;;

;; Setting example:
;;
;;      (require "popup-mode-memo")
;;      (global-set-key #\C-F12 'popup-mode-memo)
;;      (set-function-bar-label #\C-F12 "memo")
;;
;;      ; 設定
;;      (setq *popup-mode-memo-view-minormode-bindings* t)
;;      (setq *popup-mode-memo-view-local-bindings* t)
;;      (setq *popup-mode-memo-view-global-bindings* nil)
;;      (setq *popup-mode-memo-one-side-local* nil)
;;
;;      ;------------------------------------------------------------
;;      ;; buffer-mode で指定
;;      ; とりあえず作ってみる
;;      (popup-mode-memo-add-bottom 'lisp-interaction-mode "はじめ" "つぎ" "三つ目")
;;      ; 先頭にいれてみる
;;      (popup-mode-memo-add-top 'lisp-interaction-mode "先頭1" "先頭2")
;;      ; 末尾にいれてみる
;;      (popup-mode-memo-add-bottom 'lisp-interaction-mode "末尾1" "末尾2")
;;      ; 上書きしてみる
;;      (popup-mode-memo-add-new 'lisp-interaction-mode "上書き1" "上書き2")
;;      ; 削除してみる
;;      (popup-mode-memo-del 'lisp-interaction-mode)
;;
;;      ;; mode-name で指定
;;      (popup-mode-memo-add-bottom "Lisp Interaction" "はじめ" "つぎ" "三つ目")
;;      (popup-mode-memo-add-top "Lisp Interaction" "先頭1" "先頭2")
;;      (popup-mode-memo-add-bottom "Lisp Interaction" "末尾1" "末尾2")
;;      (popup-mode-memo-add-new "Lisp Interaction" "上書き1" "上書き2")
;;      (popup-mode-memo-del "Lisp Interaction")
;;      ;------------------------------------------------------------
;;
;;      ;; ex.
;;
;;      (popup-mode-memo-add-new
;;       'lisp-interaction-mode
;;       "F1:           info-modoki"
;;       "F5:           開いているファイルを byte-compile"
;;       "F10:          load-library 等の上で押すと対象ファイルを開く"
;;       "C-c b:        siteinit.l をコンパイルし、ダンプファイルを消す"
;;       "C-x C-e:      最後のセンテンスを評価 (eval-last-sexp)"
;;      )
;;
;;      (popup-mode-memo-add-new
;;       'editor::diff-mode
;;       "n:            diff-forward"
;;       "ESC Down:     diff-forward"
;;       "p:            diff-backward"
;;       "ESC Up:       diff-backward"
;;       "m:            diff-merge              (新を旧にマージ)"
;;       "r:            diff-merge-reverse      (旧を新にマージ)"
;;       "u:            diff-undo"
;;       "q:            diff-quit"
;;      )
;;
;;      (popup-mode-memo-add-new
;;       "Lisp"
;;       "F1:           info-modoki"
;;       "C-x C-e:      最後のセンテンスを評価 (eval-last-sexp)"
;;      )
;;

;; Changes:
;;
;;      [Version 0.0.0.3]
;;      Sat, 08 Oct 2005 11:12:44 +0900
;;        ・NetInstaller 対応。
;;        ・メールアドレスを変更。
;;        ・ライセンス条項(修正BSDライセンス)を記載。
;;
;;      Fri, 18 Jan 2002 22:31:21 +0900
;;        ・関数名変更。
;;          join-string-list を popup-mode-memo-join-string-list に。
;;        ・変数名変更。
;;          popup-mode-memo-list を *popup-mode-memo-list* に。
;;
;;      [Version 0.0.0.2]
;;      Fri, 17 Aug 2001 17:00:44 +0900
;;        ・*popup-mode-memo-one-side-local* 変数の追加
;;          t だとメモがある場合
;;          *popup-mode-memo-view-local-bindings* が t でも
;;          binding を表示しない。
;;          minor mode のことを考えていなかったりと適当。
;;
;;      [Version 0.0.0.1]
;;      Fri, 17 Aug 2001 11:53:06 +0900
;;        ・少しまともにして公開
;;
;;      [Version 0.0.0.0]
;;        ・とりあえず書いてみる
;;

;; Memo
;;
;;      ・minor mode に対するメモを実装していない。
;;      ・どのモードにも共通 (global) のメモが必要か検討。
;;

;; Licence:
;;
;;    popup-mode-memo は修正BSDライセンスに基づいて利用可能です。
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

(provide "popup-mode-memo")

(defconstant *popup-mode-memo-version* "0.0.0.3"
  "popup-mode-memo: バージョン")

;;------------------------------------------------------------------------------
(defvar *popup-mode-memo-view-minormode-bindings* t
  "popup-mode-memo: マイナーモードのキーバインディング表示")
(defvar *popup-mode-memo-view-local-bindings* t
  "popup-mode-memo: ローカルモードのキーバインディング表示")
(defvar *popup-mode-memo-view-global-bindings* nil
  "popup-mode-memo: グローバルなキーバインディング表示")

(defvar *popup-mode-memo-one-side-local* nil
  "popup-mode-memo: ローカルモードにメモがある場合 binding の表示なし")
;;------------------------------------------------------------------------------

(defvar *popup-mode-memo-list* nil
  "popup-mode-memo: popup-mode-memo のリスト")

(defun popup-mode-memo ()
  "popup-mode-memo: mode 毎のメモを popup 表示"
  (interactive)
  (let ((local (local-keymap))
        (global *global-keymap*)
        (minor (minor-mode-map))
        (shadow nil)
        (memo-string "")
        (local-memo-existp nil)
        (need-separator nil))
    (long-operation
      (setq memo-string (concat memo-string (format nil "======== [(~A)/~A] ========\n" mode-name buffer-mode)))
      ;; mode-name 毎の memo
      (let ((tmp (popup-mode-memo-string-mode-name mode-name)))
        (when tmp
          (setq need-separator t)
          (setq memo-string (concat memo-string tmp))
          (setq local-memo-existp t)))
      ;; buffer-mode 毎の memo
      (let ((tmp (popup-mode-memo-string-buffer-mode buffer-mode)))
        (when tmp
          (when need-separator
            (setq memo-string (concat memo-string "\n------------------------------\n")))
          (setq need-separator t)
          (setq memo-string (concat memo-string tmp))
          (setq local-memo-existp t)))
      (message "Building binding list...")
      ;; minor mode bindings
      (when (and *popup-mode-memo-view-minormode-bindings* minor)
        (when need-separator
          (setq memo-string (concat memo-string "\n------------------------------\n")))
        (setq need-separator nil)
        (setq memo-string (concat memo-string (format nil "Minor Mode Bindings:~%key\t\tbinding~%---\t\t-------")))
        (mapc #'(lambda (x)
                  (setq memo-string (concat memo-string (describe-bindings-1-string "" x shadow)))
                  (push x shadow))
              minor)
        (setq memo-string (concat memo-string "\n")))
      ;; mode bindings
      (when (and *popup-mode-memo-view-local-bindings*
                 (not (and *popup-mode-memo-one-side-local* local-memo-existp)))
        (when need-separator
          (setq memo-string (concat memo-string "\n------------------------------\n")))
        (setq need-separator nil)
        (setq memo-string (concat memo-string (format nil "Local Bindings:~%key\t\tbinding~%---\t\t-------")))
        (setq memo-string (concat memo-string (describe-bindings-1-string "" local shadow))))
      ;; global bindings
      (when *popup-mode-memo-view-global-bindings*
        (when need-separator
          (setq memo-string (concat memo-string "\n------------------------------\n")))
        (setq need-separator nil)
        (push local shadow)
        (setq memo-string (concat memo-string (format nil "~%Global Bindings:~%key\t\tbinding~%---\t\t-------")))
        (setq memo-string (concat memo-string (describe-bindings-1-string "" global shadow))))
      (message "Building binding list...done")
      (popup-string memo-string (point)))))

(defun popup-mode-memo-add-bottom (mode &rest memo-list)
  "popup-mode-memo: mode に対するメモを末尾に追加"
  (interactive)
  (let ((existp nil))
    (dolist (mode-memo *popup-mode-memo-list*)
      (when (equal mode (car mode-memo))
        (setq existp t)
        (nconc mode-memo memo-list)))
    (unless existp
      (push (cons mode memo-list) *popup-mode-memo-list*))))

(defun popup-mode-memo-add-top (mode &rest memo-list)
  "popup-mode-memo: mode に対するメモを先頭に追加"
  (interactive)
  (let ((existp nil))
    (dolist (mode-memo *popup-mode-memo-list*)
      (when (equal mode (car mode-memo))
        (setq existp t)
        (dolist (str (reverse memo-list))
          (push str (cdr mode-memo)))))
    (unless existp
      (push (cons mode memo-list) *popup-mode-memo-list*))))

(defun popup-mode-memo-del (mode)
  "popup-mode-memo: mode のメモを削除"
  (interactive)
  (let ((tmp-list))
    (dolist (mode-memo *popup-mode-memo-list*)
      (unless (equal mode (car mode-memo))
        (push mode-memo tmp-list)))
    (setq *popup-mode-memo-list* (reverse tmp-list))))

(defun popup-mode-memo-add-new (mode &rest memo-list)
  "popup-mode-memo: mode のメモを新規作成"
  (interactive)
  (popup-mode-memo-del mode)
  (push (cons mode memo-list) *popup-mode-memo-list*))

;;----------------------------------------------------------------------
;; Local function
(defun describe-bindings-1-string (prefix keymap shadow)
  (let ((str ""))
    (setq keymap (keymapp keymap))
    (when keymap
      (setq shadow (mapcan #'(lambda (x)
                               (setq x (keymapp x))
                               (and x (list x)))
                           shadow))
      (do ((index 0)
           (nl nil))
          ((>= index *full-keymap-length*))
        (let ((nindex (1+ index))
              (bound (ed::lookup-keymap-index keymap shadow index)))
          (when bound
            (if (>= index 128)
                (when nl
                  (setq str (concat str (format nil "~%")))
                  (setq nl nil))
              (unless nl
                (setq str (concat str (format nil "~%")))
                (setq nl t)))
            ; key の表示
            (setq str (concat str (format nil "~A~:C" prefix (*keymap-index-char index))))
            ; binding の表示
            (cond ((symbolp bound)
                   (while (and (< nindex *full-keymap-length*)
                               (eq bound (ed::lookup-keymap-index keymap shadow nindex)))
                     (setq nindex (1+ nindex)))
                   (when (/= index (1- nindex))
                     (setq str (concat str (format nil " ... ~A~:C" prefix (*keymap-index-char (1- nindex))))))
                   ; スペースを適当にいれる。
                   (cond ((< 6 (length (format nil "~A~:C" prefix (*keymap-index-char index))))
                          (setq str (concat str (format nil "\t"))))
                         (t
                          (setq str (concat str (format nil "\t\t")))))
                   (setq str (concat str (format nil "~S~%" bound))))
                  ((keymapp bound)
                   ; スペースを適当にいれる。
                   (cond ((< 6 (length (format nil "~A~:C" prefix (*keymap-index-char index))))
                          (setq str (concat str (format nil "\t"))))
                         (t
                          (setq str (concat str (format nil "\t\t")))))
                   (setq str (concat str (format nil "Prefix Command~%"))))
                  (t
                   ; スペースを適当にいれる。
                   (cond ((< 6 (length (format nil "~A~:C" prefix (*keymap-index-char index))))
                          (setq str (concat str (format nil "\t"))))
                         (t
                          (setq str (concat str (format nil "\t\t")))))
                   (setq str (concat str (format nil "Command~%"))))))
          (setq index nindex)))
      (dotimes (index *full-keymap-length*)
        (let* ((c (*keymap-index-char index))
               (x (ed::lookup-keymap keymap c)))
          (when (keymapp x)
            (let ((y (mapcar #'(lambda (x) (ed::lookup-keymap x c)) shadow)))
              (when (notany #'(lambda (x) (and x (not (keymapp x)))) y)
                (setq str (concat str (describe-bindings-1-string (format nil "~A~:C " prefix c) x y)))))))))
    str))

(defun popup-mode-memo-string-buffer-mode (&optional (mode-symbol buffer-mode))
  (dolist (mode-memo *popup-mode-memo-list*)
    (if (symbolp (car mode-memo))
        (when (equal mode-symbol (car mode-memo))
          (return-from popup-mode-memo-string-buffer-mode
            (popup-mode-memo-join-string-list "\n" (cdr mode-memo)))))))

(defun popup-mode-memo-string-mode-name (&optional (mode-string mode-name))
  (dolist (mode-memo *popup-mode-memo-list*)
    (if (stringp (car mode-memo))
        (when (equal mode-string (car mode-memo))
          (return-from popup-mode-memo-string-mode-name
            (popup-mode-memo-join-string-list "\n" (cdr mode-memo)))))))

(defun popup-mode-memo-join-string-list (join str-list)
  (let ((return-str "") (cnt (length str-list)))
    (dolist (str str-list)
      (decf cnt)
      (setq return-str (concat return-str str (if (plusp cnt) join ""))))
    return-str))

;;; popup-mode-memo.l ends here
