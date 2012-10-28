;;; -*- Mode: Lisp; Package: SORT-LINE -*-
;;; sort-line.l --- 行ソート

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Time-stamp: <2005/10/08 12:58:55 +0900>

;;; Commentary:

;; Description:
;;
;;  任意のカラム以降をキーとして、バッファ全体／選択範囲の行のソートを
;;  行います。
;;
;;  選択範囲の先頭行については、カーソルが矩形選択の右上の場合を除き、
;;  行全体が含まれていなくともソート範囲とみなします。
;;  選択範囲の末尾行については、カーソルが行頭の場合、矩形選択の左下の
;;  場合を除きソート範囲とみなします。
;;

;; Installation:
;;
;;      1. アーカイブを展開して sort-line.l を $XYZZY/site-lisp に
;;         コピーします。
;;         toolbar-sort-line.bmp を $XYZZY/etc にコピーします。
;;
;;      2. バイトコンパイルします。
;;
;;              M-x byte-compile-file
;;              Byte compile file: $XYZZY/site-lisp/sort-line.l
;;
;;      3. ~/.xyzzy または $XYZZY/site-lisp/siteinit.l に以下のコードを
;;         追加します。
;;
;;              (require "sort-line")
;;
;;      4. 上記の設定を反映させるために、xyzzy を再起動します。
;;         siteinit.l に記述した場合は Ctrl キーと Shift キーを押しながら
;;         xyzzy を再起動し、ダンプファイルを再構築します。
;;
;;      5. メニューの「表示」→「ツールバー」に追加されている
;;         「行ソート」をチェックし、ツールバーを表示します。
;;

;; Uninstallation:
;;
;;      1. ESC ESC (sort-line::sort-line-uninstall) とタイプし、
;;         sort-line.l 関連の情報を xyzzy から削除します。
;;
;;      2. sort-line.l に関する記述を削除します。
;;
;;      3. siteinit.l に記述していた場合は Ctrl キーと Shift キーを押し
;;         ながら xyzzy を再起動し、ダンプファイルを再構築します。
;;

;; Setting example:
;;
;;      ;; キーボードでの操作の設定例
;;      (require "sort-line")
;;      (global-set-key #\S-F11 'sort-line:sort-string-ascending)
;;      (set-function-bar-label #\S-F11 "sort A")
;;      (global-set-key #\S-C-F11 'sort-line:sort-string-descending)
;;      (set-function-bar-label #\S-C-F11 "sort Z")
;;      (global-set-key #\S-F12 'sort-line:sort-number-ascending)
;;      (set-function-bar-label #\S-F12 "sort 1")
;;      (global-set-key #\S-C-F12 'sort-line:sort-number-descending)
;;      (set-function-bar-label #\S-C-F12 "sort 9")
;;

;; Customize:
;;
;;      ;; 大文字小文字を区別する
;;      (setq sort-line:*sort-line-case-fold* nil)
;;      ;; 大文字小文字を区別しない
;;      (setq sort-line:*sort-line-case-fold* t)
;;

;; Changes:
;;
;;      Sat, 08 Oct 2005 12:53:26 +0900
;;        ・メールアドレスを変更。
;;        ・ライセンス条項(修正BSDライセンス)を記載。
;;
;;      Fri, 15 Apr 2005 00:02:42 +0900
;;        ・コメント修正。
;;        ・xyzzy 0.2.2.234 対応
;;          - 半角カナを全角カナに変更。
;;        ・sort-line-uninstall を interactive でない関数に変更。
;;
;;      Wed, 03 Mar 2004 00:12:05 +0900
;;        ・NetInstaller 対応。
;;        ・その他。
;;
;;      Fri, 08 Mar 2002 23:23:11 +0900
;;        ・矩形選択範囲をキーとしてソートできるように。
;;        ・キーのカラム指定を可能に。
;;        ・選択形式の変換コマンドの追加。
;;        ・その他。
;;
;;      Fri, 11 Jan 2002 05:33:35 +0900
;;        ・psetq を rotatef で書き換え。
;;
;;      Fri, 28 Dec 2001 22:19:07 +0900
;;        ・lisp だけでソートすることに意味はないような気がする
;;          けれど使っているものを公開。
;;

;; Licence:
;;
;;    sort-line は修正BSDライセンスに基づいて利用可能です。
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

(provide "sort-line")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package "sort-line")
    (defpackage "sort-line" (:use "lisp" "editor"))))

(in-package "sort-line")

(export '(sort-string-ascending sort-string-descending
          sort-number-ascending sort-number-descending
          sort-string-length-ascending sort-string-descending
          sort-line-tool-bar
          *sort-line-case-fold*))

(defvar *sort-line-case-fold* t
  "大文字小文字を区別しない")

(defun sort-line (predicate &optional converter reverse nomsg)
  (let ((selection-type (get-selection-type))
        line-from   ; 先頭行
        line-to     ; 末尾行 (含む)
        column-from ; 開始カラム
        column-to)  ; 終了カラム (含まない)
    (if (not selection-type)
        (if (or nomsg
                (yes-or-no-p "~D カラム以降をキーとしてソートしますか？" (current-column)))
            (setq column-from (current-column))
          (return-from sort-line nil))
      (let ((p1 (selection-point)) (p2 (selection-mark)))
        (if (> p1 p2)
            (rotatef p1 p2))
        (case selection-type
          ((1) ; 行モード選択
           (setq line-from (progn (goto-char p1) (current-line-number)))
           (setq line-to
                 (progn (goto-char p2) (backward-line) (current-line-number))))
          ((2) ; 文字モード選択
           (setq line-from (progn (goto-char p1) (current-line-number)))
           (setq line-to
                 (progn (goto-char p2) (if (bolp) (backward-line)) (current-line-number))))
          ((3) ; 矩形選択
           (let ((c1 (progn (goto-char p1) (current-column)))
                 (c2 (progn (goto-char p2) (current-column))))
             (if (< c1 c2)
                 (progn
                   (setq line-from (progn (goto-char p1) (current-line-number)))
                   (setq line-to (progn (goto-char p2) (current-line-number)))
                   (setq column-from c1)
                   (setq column-to c2))
               (progn
                 (setq line-from (progn (goto-char p1) (forward-line) (current-line-number)))
                 (setq line-to (progn (goto-char p2) (backward-line) (current-line-number)))
                 (setq column-from c2)
                 (setq column-to c1))))))))
    (sort-line-1 predicate converter reverse line-from line-to column-from column-to)))

(defun sort-line-1 (predicate converter reverse line-from line-to column-from column-to)
  (if reverse
      (setq reverse -1)
    (setq reverse 1))
  (unless line-from
    (setq line-from 1))
  (unless line-to
    (goto-char (point-max))
    (if (eobp)
        (backward-char))
    (setq line-to (current-line-number)))
  (unless column-from
    (setq column-from 0))
  (goto-line line-from)
  (let (lines key str p1 p2)
    (while (<= (current-line-number) line-to)
      (setq str (buffer-substring (point) (progn (goto-eol) (point))))
      (if (and (= column-from 0) (eq column-to nil))
          (setq key str)
        (progn
          (unless (or (>= (goto-column column-from) column-from)
                      (eolp))
            (forward-char 1))
          (setq p1 (point))
          (if column-to
              (goto-column column-to)
            (goto-eol))
          (setq p2 (point))
          (unless (<= p1 p2)
            (setq p2 p1))
          (setq key (buffer-substring p1 p2))))
      (if converter
          (setq key (funcall converter key)))
      (push (list (current-line-number) key str) lines)
      (unless (forward-line)
        (return)))
    (flet ((stable-predicate (unit-A unit-B)
             (let ((line-number-A (car unit-A))
                   (line-number-B (car unit-B))
                   (key-A (cadr unit-A))
                   (key-B (cadr unit-B)))
               (cond
                ((and (null key-A) (null key-B))
                 (< line-number-A line-number-B))
                ((null key-A) nil)
                ((null key-B) t)
                (t
                 (case (* (funcall predicate key-A key-B) reverse)
                   (1 nil)
                   (-1 t)
                   (0 (< line-number-A line-number-B))
                   (t (< line-number-A line-number-B))))))))
      (setq lines (stable-sort lines #'stable-predicate)))
    (goto-line line-from)
    (dolist (line (mapcar #'caddr lines))
      (delete-region (point) (progn (goto-eol) (point)))
      (insert line)
      (forward-line))))

(defun sort-line-cmp (str-a str-b)
  "大文字小文字を区別して文字列比較"
  (cond
   ((string< str-a str-b) -1)
   ((string= str-a str-b)  0)
   (t 1)))

(defun sort-line-cmp-p (str-a str-b)
  "大文字小文字を区別しないで文字列比較"
  (cond
   ((string-lessp str-a str-b) -1)
   ((string-equal str-a str-b)  0)
   (t 1)))

(defun sort-line-<=> (int-a int-b)
  "数比較"
  (cond
   ((< int-a int-b) -1)
   ((= int-a int-b) 0)
   (t 1)))

(defvar *integer-regexp* (compile-regexp "^[ \t]*\\(-?[0-9]+\\)"))
(defun sort-line-convert-to-integer (str)
  "文字列を整数に変換"
  (if (string-match *integer-regexp* str)
      (parse-integer (match-string 1))
    nil))

(defun sort-line-convert-to-length (str)
  "文字列を文字列長に変換"
  (length str))

(defun sort-string-ascending ()
  "文字列で昇順にソート"
  (interactive "*")
  (sort-line (if *sort-line-case-fold*
                 #'sort-line-cmp-p #'sort-line-cmp)
             nil nil))

(defun sort-string-descending ()
  "文字列で降順にソート"
  (interactive "*")
  (sort-line (if *sort-line-case-fold*
                 #'sort-line-cmp-p #'sort-line-cmp)
             nil t))

(defun sort-number-ascending ()
  "先頭の整数で昇順にソート"
  (interactive "*")
  (sort-line #'sort-line-<=> #'sort-line-convert-to-integer nil))

(defun sort-number-descending ()
  "先頭の整数で降順にソート"
  (interactive "*")
  (sort-line #'sort-line-<=> #'sort-line-convert-to-integer t))

(defun sort-string-length-ascending ()
  "文字列長で昇順にソート"
  (interactive "*")
  (sort-line #'sort-line-<=> #'sort-line-convert-to-length nil))

(defun sort-string-length-descending ()
  "文字列長で降順にソート"
  (interactive "*")
  (sort-line #'sort-line-<=> #'sort-line-convert-to-length t))

(defun change-selection-type ()
  "選択形式の変更、またはリージョンを選択に変換"
  (interactive)
  (case (get-selection-type)
    (1 (set-selection-type 2 t))
    (2 (set-selection-type 3 t))
    (3 (set-selection-type 1 t))
    (t
     (let ((from (mark t)) (to (point)))
       (when from
         (save-restriction
           (narrow-to-region from to)
           (if (< from to)
               (progn
                 (goto-char (point-min))
                 (selection-end-of-buffer))
             (progn
               (goto-char (point-max))
               (selection-beginning-of-buffer)))
           (set-selection-type 2 t)))))))

;;; tool-bar
(defun tool-bar-update-change-selection-type ()
  (or (mark t) (get-selection-type) :disable))

(defun sort-line-tool-bar ()
  (create-tool-bar
   'sort-line-tool-bar
   (merge-pathnames "toolbar-sort-line.bmp" (etc-path))
   '(("文字列で昇順にソート" 0 sort-string-ascending)
     ("文字列で降順にソート" 1 sort-string-descending)
     ("整数で昇順にソート" 2 sort-number-ascending)
     ("整数で降順にソート" 3 sort-number-descending)
;     ("選択形式の変更" 4 change-selection-type tool-bar-update-change-selection-type)
     )))

;; tool-bar 登録
(define-command-bar 'sort-line-tool-bar "行ソート(&L)")

;;; uninstall
(defun sort-line-uninstall ()
  "sort-line のアンインストール"
  (delete-command-bar 'sort-line::sort-line-tool-bar)
  (let ((package (find-package "sort-line")))
    (dolist (x (copy-list ed::*history-variable-list*))
      (if (eq (symbol-package x) package)
          (unregister-history-variable x)))))

;;; sort-line.l ends here
