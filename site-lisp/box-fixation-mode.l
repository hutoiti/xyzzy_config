;;; -*- Mode: Lisp; Package: EDITOR -*-
;;; box-fixation-mode.l --- 罫線内編集用マイナー/メジャーモード

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Time-stamp: <2005/10/08 14:28:01 +0900>

;;; Commentary:

;; Description:
;;
;;  罫線内編集を行うためのマイナー/メジャーモードです。
;;
;;  罫線モード (box-drawings-mode) で記述した罫線や、CSVモードで
;;  変換した罫線の位置を固定しつつ編集を行う場合に使用します。
;;
;;  罫線間の範囲を超過する入力を行った場合、超過分を次行に入力します。
;;  罫線が閉じており次行に入力できない場合は、罫線の継続行を追加した
;;  上で超過分を入力します。
;;

;; Installation:
;;
;;      1. アーカイブを展開して box-fixation-mode.l を $XYZZY/site-lisp に
;;         コピーします。
;;         toolbar-box-fixation.bmp を $XYZZY/etc にコピーします。
;;
;;      2. バイトコンパイルします。
;;
;;              M-x byte-compile-file
;;              Byte compile file: $XYZZY/site-lisp/box-fixation-mode.l
;;
;;      3. ~/.xyzzy または $XYZZY/site-lisp/siteinit.l に以下のコードを
;;         追加します。
;;
;;              (require "box-fixation-mode")
;;
;;      4. 上記の設定を反映させるために、xyzzy を再起動します。
;;         siteinit.l に記述した場合は Ctrl キーと Shift キーを押しながら
;;         xyzzy を再起動し、ダンプファイルを再構築します。
;;

;; Uninstallation:
;;
;;      1. ESC ESC (ed::box-fixation-mode-uninstall) とタイプし、
;;         box-fixation-mode.l 関連の情報を xyzzy から削除します。
;;
;;      2. box-fixation-mode.l に関する記述を削除します。
;;
;;      3. siteinit.l に記述していた場合は Ctrl キーと Shift キーを押し
;;         ながら xyzzy を再起動し、ダンプファイルを再構築します。
;;

;; Usage:
;;
;;      M-x box-fixation-mode
;;      M-x box-fixation-minor-mode
;;

;; Key bind:
;;
;;      ■box-fixation-mode
;;
;;      C-f      列を考慮して、次の文字へ移動
;;      C-b      列を考慮して、前の文字へ移動
;;      C-n      列を考慮して、次行へ移動
;;      C-p      列を考慮して、前行へ移動
;;      C-a      列行頭もしくは行頭に移動
;;      C-e      列行末に移動
;;      M-f      次の列の列行頭に移動
;;      M-b      前の列の列行頭に移動
;;      Right    列を考慮して、次の文字へ移動
;;      Left     列を考慮して、前の文字へ移動
;;      Down     列を考慮して、次行へ移動
;;      Up       列を考慮して、前行へ移動
;;
;;      RET      改行後の文字列を次行先頭に挿入．必要に応じ新規行を追加
;;      LFD      改行後の文字列からなる次行を作成．必要に応じ新規行を追加
;;      Delete   文字を削除
;;      C-d      文字を削除
;;      C-h      後方の文字を削除
;;      C-k      列を考慮して、一行キル
;;      C-w      列を考慮して、リージョンをキルリングに追加、削除
;;      M-w      列を考慮して、リージョンをキルリングに追加
;;      M-C-w    次のキルでキルアペンドするように設定
;;      M-Up     列内センタリング(右寄り)
;;      M-Down   列内センタリング(左寄り)
;;      M-Left   列内左寄せ
;;      M-Right  列内右寄せ
;;
;;
;;      ■box-fixation-minor-mode
;;
;;      キーバインドなし
;;

;; Setting example:
;;
;;      (require "box-fixation-mode")
;;      ;; box-fixation-minor-mode にキーバインドを追加
;;      (define-key *box-fixation-minor-mode-map* #\M-Up
;;                  'box-fixation-reposition-rcenter)
;;      (define-key *box-fixation-minor-mode-map* #\M-Down
;;                  'box-fixation-reposition-lcenter)
;;      (define-key *box-fixation-minor-mode-map* #\M-Left
;;                  'box-fixation-reposition-left)
;;      (define-key *box-fixation-minor-mode-map* #\M-Right
;;                  'box-fixation-reposition-right)
;;

;; Changes:
;;
;;      Sat, 08 Oct 2005 14:26:25 +0900
;;        ・メールアドレスを変更。
;;        ・ライセンス条項(修正BSDライセンス)を記載。
;;
;;      Fri, 15 Apr 2005 00:21:58 +0900
;;        ・xyzzy 0.2.2.234 対応
;;          - 半角カナを全角カナに変更。
;;          - box-fixation-insert-menu-items 更新。
;;            「罫線内編集モード」メニューを追加する位置のデフォルトを
;;            「太い罫線」の下に。
;;        ・「罫線内編集モード」メニューをデフォルトで追加するように。
;;        ・コメント修正。
;;
;;      Wed, 02 Feb 2005 00:23:03 +0900
;;        ・ツールバー追加。
;;        ・box-fixation-mode-uninstall 追加。
;;
;;      Sat, 08 Jan 2005 00:36:27 +0900
;;        ・作成
;;
;;      Wed, 05 Jan 2005 20:16:24 +0900
;;        ・作成開始
;;

;; Specification:
;;
;;      ・TAB文字未対応。
;;      ・基本的に、同一行内の編集にのみ対応する。
;;      ・│(0x84A0) は罫線として扱うが、｜(0x8162) は罫線として扱わない。
;;      ・罫線文字：(Shift_JIS  0x849F-0x84BE 0x81A8-0x81AB)
;;          ─│┌┐┘└├┬┤┴┼
;;          ━┃┏┓┛┗┣┳┫┻╋
;;          ┠┯┨┷┿┝┰┥┸╂
;;          →←↑↓
;;

;; Restriction:
;;
;;      ・セレクションでの編集は未考慮。
;;      ・narrowing 状態での動作は未考慮。
;;

;; Todo:
;;
;;      ・同一行に罫線がない場合の各種関数動作の調整。
;;      ・box-fixation-insert を "\n" 対応にする。
;;

;; Licence:
;;
;;    box-fixation-mode は修正BSDライセンスに基づいて利用可能です。
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

#|
┏━━━━━━━━━━━━━┯━━━━━━━━━━━━━━┓
┃                          │Description: 罫線内編集を行 ┃
┃                          │うためのマイナー/メジャーモ ┃
┃                          │ードです。罫線モード (box-dr┃
┠─────────────┘awings-mode) で記述した罫線 ┃
┃や、CSVモードで変換した罫線の位置を固 ┌────────┨
┃定しつつ編集を行う場合に使用します。罫│                ┃
┣━━━━━━━━━━━━┓線間の範囲を│                ┃
┃                        ┃超過する入力│                ┃
┃          ┌──────┸───┐を行└────────┨
┃          │                    │った場合、超過分を次行┃
┃          │                    │に入力し───────┨
┃          │                    │ます。罫線が閉じており┃
┃          │                    │次行に入力できない場合┃
┃          │                    │は、罫線の継続行を追加┃
┃          │                    │した上で超過分を入力し┃
┃          │                    │ます。                ┃
┗━━━━━┷━━━━━━━━━━┷━━━━━━━━━━━┛
|#

;;; Code:

(provide "box-fixation-mode")

(require "boxdraw")

(in-package "editor")

(export '(box-fixation-minor-mode
          box-fixation-mode
          ;;
          box-fixation-beginning-of-line
          box-fixation-beginning-of-line-or-goto-bol
          box-fixation-end-of-line
          box-fixation-forward-column
          box-fixation-backward-column
          box-fixation-forward-char
          box-fixation-backward-char
          box-fixation-forward-line
          box-fixation-backward-line
          box-fixation-next-line
          box-fixation-previous-line
          ;;
          box-fixation-delete-region
          box-fixation-clear-region
          box-fixation-delete-char
          box-fixation-delete-backward-char
          box-fixation-copy-region-as-kill
          box-fixation-append-next-kill
          box-fixation-kill-region
          box-fixation-copy-region-to-clipboard
          box-fixation-kill-region-to-clipboard
          box-fixation-kill-line
          box-fixation-open-line
          box-fixation-newline
          box-fixation-newline-for-always
          box-fixation-newline-for-not-blank
          box-fixation-reposition-left
          box-fixation-reposition-right
          box-fixation-reposition-center
          box-fixation-reposition-lcenter
          box-fixation-reposition-rcenter
          ;;
          box-fixation-insert-menu-items
          box-fixation-delete-menu
          ;;
          *box-fixation-mode-hook*
          *box-fixation-minor-mode-map*
          *box-fixation-mode-map*
          *box-fixation-mode-syntax-table*
          *box-fixation-keyword-hash-table*
          *box-fixation-keyword-file*
          *box-fixation-regexp-keyword-list*
          *box-fixation-mode-abbrev-table*))

(defvar *box-fixation-mode-hook* nil)

(defvar-local box-fixation-minor-mode nil)

(defvar *box-fixation-minor-mode-map* nil)
(unless *box-fixation-minor-mode-map*
  (setq *box-fixation-minor-mode-map* (make-sparse-keymap)))

(defvar *box-fixation-mode-map* nil)
(unless *box-fixation-mode-map*
  (setq *box-fixation-mode-map* (make-sparse-keymap))
  ;; 移動
  (define-key *box-fixation-mode-map* #\C-f 'box-fixation-forward-char)
  (define-key *box-fixation-mode-map* #\C-b 'box-fixation-backward-char)
  (define-key *box-fixation-mode-map* #\C-n 'box-fixation-next-line)
  (define-key *box-fixation-mode-map* #\C-p 'box-fixation-previous-line)
  (define-key *box-fixation-mode-map* #\C-a 'box-fixation-beginning-of-line-or-goto-bol)
  (define-key *box-fixation-mode-map* #\C-e 'box-fixation-end-of-line)
  (define-key *box-fixation-mode-map* #\M-f 'box-fixation-forward-column)
  (define-key *box-fixation-mode-map* #\M-b 'box-fixation-backward-column)
  (define-key *box-fixation-mode-map* #\Right 'box-fixation-forward-char)
  (define-key *box-fixation-mode-map* #\Left 'box-fixation-backward-char)
  (define-key *box-fixation-mode-map* #\Down 'box-fixation-next-line)
  (define-key *box-fixation-mode-map* #\Up 'box-fixation-previous-line)
  ;; 編集
  (define-key *box-fixation-mode-map* #\RET 'box-fixation-newline)
  (define-key *box-fixation-mode-map* #\LFD 'box-fixation-newline-for-not-blank)
  (define-key *box-fixation-mode-map* #\Delete 'box-fixation-delete-char)
  (define-key *box-fixation-mode-map* #\C-d 'box-fixation-delete-char)
  (define-key *box-fixation-mode-map* #\C-h 'box-fixation-delete-backward-char)
  (define-key *box-fixation-mode-map* #\C-k 'box-fixation-kill-line)
  (define-key *box-fixation-mode-map* #\C-w 'box-fixation-kill-region)
  (define-key *box-fixation-mode-map* #\M-w 'box-fixation-copy-region-as-kill)
  (define-key *box-fixation-mode-map* #\M-C-w 'box-fixation-append-next-kill)
  (define-key *box-fixation-mode-map* #\M-Up 'box-fixation-reposition-rcenter)
  (define-key *box-fixation-mode-map* #\M-Down 'box-fixation-reposition-lcenter)
  (define-key *box-fixation-mode-map* #\M-Left 'box-fixation-reposition-left)
  (define-key *box-fixation-mode-map* #\M-Right 'box-fixation-reposition-right))

(defvar *box-fixation-mode-syntax-table* nil)
(unless *box-fixation-mode-syntax-table*
  (setq *box-fixation-mode-syntax-table* (make-syntax-table))
  (set-syntax-symbol *text-mode-syntax-table* #\&)
  (set-syntax-symbol *text-mode-syntax-table* #\*)
  (set-syntax-symbol *text-mode-syntax-table* #\+)
  (set-syntax-symbol *text-mode-syntax-table* #\-)
  (set-syntax-symbol *text-mode-syntax-table* #\/)
  (set-syntax-symbol *text-mode-syntax-table* #\<)
  (set-syntax-symbol *text-mode-syntax-table* #\=)
  (set-syntax-symbol *text-mode-syntax-table* #\>)
  (set-syntax-symbol *text-mode-syntax-table* #\_)
  (set-syntax-symbol *text-mode-syntax-table* #\|))

(defvar *box-fixation-keyword-hash-table* nil)

(defvar *box-fixation-keyword-file* "BoxFix")

(defvar *box-fixation-regexp-keyword-list* nil)

(defvar *box-fixation-mode-abbrev-table* nil)
(unless *box-fixation-mode-abbrev-table*
  (define-abbrev-table '*box-fixation-mode-abbrev-table*))

(defconstant *box-fixation-chars-regexp*
  (compile-regexp (concat "[" (mapcar #'car *box-drawings-chars*) "]")))

(defvar *box-fixation-minimal-column-width* 2 "列最小幅")

(defvar *box-fixation-target-buffer* nil)
(defvar *box-fixation-target-line* nil)
(defvar *box-fixation-target-modified-count* nil)
(defvar *box-fixation-column-alist* nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 最基本関数
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(let (target-buffer target-line target-modified-count cache-column-alist)
  (defun box-fixation-get-column-alist ()
    "現在行から、カラム、罫線からなる alist を生成し返す。"
    (if (and (eq target-buffer (selected-buffer))
             (eql target-line (current-line-number))
             (eql target-modified-count (buffer-modified-count)))
        cache-column-alist
      (let ((goal-column (goal-column)) (match-data (match-data))
            limit box-fixation-column-alist)
        (save-excursion
          (goto-eol)
          (setq limit (point))
          (goto-bol)
          (while (scan-buffer *box-fixation-chars-regexp* :limit limit)
            (push (cons (current-column) (char-after (point)))
                  box-fixation-column-alist)
            (unless (forward-char)
              (return))))
        (store-match-data match-data)
        (set-goal-column goal-column)
        (setq target-buffer (selected-buffer)
              target-line (current-line-number)
              target-modified-count (buffer-modified-count))
        (setq cache-column-alist (nreverse box-fixation-column-alist))))))

(defun box-fixation-get-left-column-alist (column-alist column)
  "column-alist から column より左側の部分を返す。
column と一致するものは含まない。"
  (let (left-column-alist)
    (dolist (x column-alist)
      (if (< (car x) column)
          (push x left-column-alist)
        (return)))
    (nreverse left-column-alist)))

(defun box-fixation-get-right-column-alist (column-alist column)
  "column-alist から column を含み右側の部分を返す。"
  (member column column-alist :test #'<= :key #'car))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 基本関数
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun box-fixation-get-side-column-elements (column-alist column)
  "column-alist から column をはさむ両サイドの部分を values で返す。
存在しないサイドの情報は nil とする。"
  (values (car (last (box-fixation-get-left-column-alist column-alist column)))
          (car (box-fixation-get-right-column-alist column-alist column))))

(defun box-fixation-get-column-width (&optional (left-column-element nil left-column-element-sv)
                                                (right-column-element nil right-column-element-sv))
  "幅を返す。
right-column-element が nil の場合は無制限を意味する値として nil を返す。"
  (when (and (not left-column-element-sv) (not right-column-element-sv))
    (multiple-value-setq (left-column-element right-column-element)
      (box-fixation-get-side-column-elements
       (box-fixation-get-column-alist) (current-column))))
  (if right-column-element
      (- (car right-column-element)
         (if left-column-element
             (+ (car left-column-element) (char-columns (cdr left-column-element)))
           0))
    nil))

(defun box-fixation-line-p ()
  "カーソルが罫線のある行にあるか
戻り値：
  t   カーソルが罫線のある行にある
  nil カーソルが罫線のある行にない"
  (if (box-fixation-get-column-alist) t nil))

(defun box-fixation-column-p ()
  "カーソルが(文字列が挿入可能な幅のある)列にあるか
戻り値：
  t   カーソルが文字列が挿入可能な幅のある列にある
  nil カーソルが文字列が挿入可能な幅のある列にない"
  (let ((column-width (box-fixation-get-column-width)))
    (or (null column-width) (>= column-width *box-fixation-minimal-column-width*))))

(defun box-fixation-right-most-column-p ()
  "カーソルが最右列(右端が行末の列)にあるか
戻り値：
  t   カーソルが最右列にある
  nil カーソルが最右列にない"
  (and (box-fixation-column-p)
       (null (box-fixation-get-right-column-alist
              (box-fixation-get-column-alist) (current-column)))))

(defun box-fixation-bolp ()
  "カーソルが列行頭にあるか
戻り値：
  t   カーソルが列行頭にある
  nil カーソルが列行頭にない"
  (and (or (bolp)
           (save-excursion
             (backward-char)
             (looking-at *box-fixation-chars-regexp*)))
       (box-fixation-column-p)))

(defun box-fixation-eolp ()
  "カーソルが列行末にあるか
戻り値：
  t   カーソルが列行末にある
  nil カーソルが列行末にない"
  (or (eolp)
      (and (looking-at *box-fixation-chars-regexp*)
           (box-fixation-column-p))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 移動関数
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun box-fixation-goto-bol ()
  "列行頭に移動
戻り値：
  t   カーソルが列行頭にある (カーソルが移動していなくても t)
  nil カーソルが列行頭にない"
  (let ((column-alist (box-fixation-get-column-alist))
        left-column-element right-column-element goto-point)
    (save-excursion
      (loop
        (multiple-value-setq (left-column-element right-column-element)
          (box-fixation-get-side-column-elements column-alist (current-column)))
        (if left-column-element
            (if (box-fixation-column-p)
                (progn
                  (goto-column (car left-column-element))
                  (forward-char)
                  (setq goto-point (point))
                  (return))
              (goto-column (car left-column-element)))
          (progn
            (when (box-fixation-column-p)
              (goto-bol)
              (setq goto-point (point)))
            (return)))))
    (when goto-point
      (goto-char goto-point))))

(defun box-fixation-goto-eol ()
  "列行末に移動
戻り値： t"
  (let ((column-alist (box-fixation-get-column-alist))
        left-column-element right-column-element)
    (loop
      (multiple-value-setq (left-column-element right-column-element)
        (box-fixation-get-side-column-elements
         column-alist (current-column)))
      (if right-column-element
          (progn
            (goto-column (car right-column-element))
            (if (box-fixation-column-p)
                (return)
              (forward-char)))
        (progn
          (goto-eol)
          (return)))))
  t)

(defun box-fixation-left-column-exist-p ()
  "カーソルより左側に列が存在するか
戻り値：
  t   カーソルより左側に列が存在する
  nil カーソルより左側に列が存在しない"
  (save-excursion
    (and (not (bolp))
         (backward-char)
         (box-fixation-goto-bol))))

(defun box-fixation-goto-bol-no-dup (&optional (arg 1))
  "列行頭に移動。既に列行頭にいる場合は前列の列行頭に移動。
戻り値：
  t   カーソルが移動した
  nil カーソルが移動しない"
  (let ((point (point)))
    (while (and (plusp arg) (box-fixation-left-column-exist-p))
      (decf arg)
      (backward-char)
      (box-fixation-goto-bol))
    (/= point (point))))

(defun box-fixation-goto-eol-no-dup (&optional (arg 1))
  "列行末に移動。既に列行末にいる場合は次列の列行末に移動。
戻り値：
  t   カーソルが移動した
  nil カーソルが移動しない"
  (let ((point (point)))
    (while (and (not (eolp)) (plusp arg))
      (decf arg)
      (forward-char)
      (box-fixation-goto-eol))
    (/= point (point))))

(defun box-fixation-beginning-of-line (&optional (arg 1))
  "列行頭に移動する。
box-fixation-goto-bol-no-dup の interactive 版
戻り値：
  t   カーソルが移動した
  nil カーソルが移動しない"
  (interactive "p")
  (box-fixation-goto-bol-no-dup arg))

(defun box-fixation-beginning-of-line-or-goto-bol (&optional (arg 1))
  "列行頭もしくは行頭に移動する。
戻り値：
  t   カーソルが移動した
  nil カーソルが移動しない"
  (interactive "p")
  (let ((point (point)))
    (or (box-fixation-goto-bol-no-dup arg)
        (goto-bol))
    (/= point (point))))

(defun box-fixation-end-of-line (&optional (arg 1))
  "列行末に移動する。
box-fixation-goto-eol-no-dup の interactive 版
  t   カーソルが移動した
  nil カーソルが移動しない"
  (interactive "p")
  (box-fixation-goto-eol-no-dup arg))

(defun box-fixation-forward-column (&optional (arg 1))
  "カーソルを前方の列に移動する。
列を移動できない場合は、カーソルを移動しない。
戻り値：
  t   別の列に移動した
  nil 別の列に移動しない (カーソルが移動しない)"
  (interactive "p")
  (let (moved goto-point)
    (save-excursion
      (cond ((plusp arg)
             (when (box-fixation-column-p)
               (box-fixation-goto-eol))
             (while (plusp arg)
               (setq moved (or moved (box-fixation-goto-eol-no-dup)))
               (decf arg))
             (box-fixation-goto-bol))
            ((minusp arg)
             (when (box-fixation-column-p)
               (box-fixation-goto-bol))
             (while (minusp arg)
               (setq moved (or moved (box-fixation-goto-bol-no-dup)))
               (incf arg))))
      (setq goto-point (point)))
    (when moved
      (goto-char goto-point))))

(defun box-fixation-backward-column (&optional (arg 1))
  "カーソルを後方の列に移動する。
列を移動できない場合は、カーソルを移動しない。
戻り値：
  t   別の列に移動した
  nil 別の列に移動しない (カーソルが移動しない)"
  (interactive "p")
  (box-fixation-forward-column (- arg)))

(defun box-fixation-get-next-line-destination-columns ()
  "移動先となり得る、次行の column のリストを返す。"
  (unless (box-fixation-column-p)
    (return-from box-fixation-get-next-line-destination-columns nil))
  (let (left-column right-column destination-columns)
    (save-excursion
      (box-fixation-goto-bol)
      (setq left-column (current-column))
      (box-fixation-goto-eol)
      (unless (eolp)
        (setq right-column (current-column)))
      (unless (forward-line)
        (return-from box-fixation-get-next-line-destination-columns nil))
      (unless (box-fixation-column-p)
        (box-fixation-forward-column))
      (loop
        (when (and
               ;; 列行頭が、元列の列行末よりも左
               (or (null right-column)
                   (< (current-column) right-column))
               ;; 列行末が、元列の列行頭よりも右
               (or (progn (box-fixation-goto-eol) (eolp))
                   (< left-column (current-column))))
          (box-fixation-goto-bol)
          (push (current-column) destination-columns))
        (unless (box-fixation-forward-column)
          (return))))
    (nreverse destination-columns)))

(defun box-fixation-get-previous-line-destination-columns ()
  "移動先となり得る、前行の column のリストを返す。"
  (unless (box-fixation-column-p)
    (return-from box-fixation-get-previous-line-destination-columns nil))
  (let (left-column right-column destination-columns)
    (save-excursion
      (box-fixation-goto-bol)
      (setq left-column (current-column))
      (box-fixation-goto-eol)
      (unless (eolp)
        (setq right-column (current-column)))
      (unless (backward-line)
        (return-from box-fixation-get-previous-line-destination-columns nil))
      (unless (box-fixation-column-p)
        (box-fixation-forward-column))
      (loop
        (when (and
               ;; 列行頭が、元列の列行末よりも左
               (or (null right-column)
                   (< (current-column) right-column))
               ;; 列行末が、元列の列行頭よりも右
               (or (progn (box-fixation-goto-eol) (eolp))
                   (< left-column (current-column))))
          (box-fixation-goto-bol)
          (push (current-column) destination-columns))
        (unless (box-fixation-forward-column)
          (return))))
    (nreverse destination-columns)))

(defun box-fixation-forward-char (&optional (arg 1))
  "列を考慮して次の文字へ移動する。
戻り値：
  t   移動した
  nil 移動していない"
  (interactive "p")
  (let ((point (point)) column)
    (cond ((plusp arg)
           (while (plusp arg)
             (decf arg)
             (if (or (box-fixation-eolp)
                     (save-excursion
                       (forward-char)
                       (and (not (eolp)) (box-fixation-eolp))))
                 (when (setq column (car (box-fixation-get-next-line-destination-columns)))
                   (forward-line)
                   (goto-column column))
               (forward-char))))
          ((minusp arg)
           (while (minusp arg)
             (incf arg)
             (if (box-fixation-bolp)
                 (when (setq column (car (box-fixation-get-previous-line-destination-columns)))
                   (backward-line)
                   (goto-column column)
                   (box-fixation-goto-eol)
                   (unless (eolp)
                     (backward-char)))
               (backward-char)))))
    (/= point (point))))

(defun box-fixation-backward-char (&optional (arg 1))
  "列を考慮して前の文字へ移動する。
戻り値：
  t   移動した
  nil 移動していない"
  (interactive "p")
  (box-fixation-forward-char (- arg)))

(defun box-fixation-forward-line (&optional (arg 1))
  "列を考慮して次行の列行頭へ移動する。
戻り値：
  integer  移動した行数 (+ / -)
  nil      移動していない"
  (interactive "p")
  (let ((moved 0) column)
    (cond ((plusp arg)
           (while (plusp arg)
             (decf arg)
             (cond ((not (box-fixation-column-p))
                    (when (next-line)
                      (incf moved)))
                   ((setq column (car (box-fixation-get-next-line-destination-columns)))
                    (forward-line)
                    (goto-column column)
                    (incf moved))
                   (t
                    (return)))))
          ((minusp arg)
           (while (minusp arg)
             (incf arg)
             (cond ((not (box-fixation-column-p))
                    (when (previous-line)
                      (decf moved)))
                   ((setq column (car (box-fixation-get-previous-line-destination-columns)))
                    (backward-line)
                    (goto-column column)
                    (decf moved))
                   (t
                    (return))))))
    (when (/= moved 0)
      moved)))

(defun box-fixation-backward-line (&optional (arg 1))
  "列を考慮して前行の列行頭へ移動する。
戻り値：
  integer  移動した行数 (+ / -)
  nil      移動していない"
  (interactive "p")
  (box-fixation-forward-line (- arg)))

(defun box-fixation-next-line (&optional (arg 1))
  "列を考慮して次行へ移動する。
戻り値：
  t   移動した
  nil 移動していない"
  (interactive "p")
  (let ((goal-column (goal-column)))
    (when (box-fixation-forward-line arg)
      (cond ((< goal-column (save-excursion (box-fixation-goto-bol) (current-column)))
             (box-fixation-goto-bol))
            ((< (save-excursion (box-fixation-goto-eol) (current-column)) goal-column)
             (box-fixation-goto-eol))
            (t
             (goto-column goal-column)
             (set-goal-column goal-column)))
      t)))

(defun box-fixation-previous-line (&optional (arg 1))
  "列を考慮して前行へ移動する。
戻り値：
  t   移動した
  nil 移動していない"
  (interactive "p")
  (box-fixation-next-line (- arg)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 編集関数
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun box-fixation-region-to-region-list (from to)
  "リージョンを列を意識したリージョンのリストに変換。"
  (save-excursion
    (if (> from to) (rotatef from to))
    (goto-char from)
    (unless (box-fixation-column-p)
      (return-from box-fixation-region-to-region-list nil))
    (when (= from to)
      (return-from box-fixation-region-to-region-list nil))
    (let (region-list column)
      (loop
        ;; 行単位で移動できる場合は行単位で移動
        (box-fixation-goto-eol)
        (if (<= (point) to)
            (progn
              (push (cons from (point)) region-list)
              (unless (setq column (car (box-fixation-get-next-line-destination-columns)))
                (return))
              (forward-line)
              (goto-column column)
              (setq from (point))
              (unless (< (point) to)
                (return)))
          ;; 文字単位で移動
          (progn
            (box-fixation-goto-bol)
            (while (< (point) to)
              (unless (box-fixation-forward-char)
                (return)))
            (push (cons from (point)) region-list)
            (return))))
      (nreverse region-list))))

(defun box-fixation-buffer-substring (from to &optional (trim-type :both) add-newline)
  "列を考慮し、リージョンの文字列を取得
引数：
  TRIM-TYPE
    :left     各列、左空白削除
    :right    各列、右空白削除
    :both     各列、左右空白削除
    上記以外  左右の空白を削除しない

ADD-NEWLINE
    nil       各列末尾に改行を追加しない
    non-nil   各列末尾に改行を追加"
  (let* ((string-list (mapcar #'(lambda (x) (buffer-substring (car x) (cdr x)))
                              (box-fixation-region-to-region-list from to))))
    (setq string-list
          (case trim-type
            (:left  (mapcar #'(lambda (x) (string-left-trim " " x)) string-list))
            (:right (mapcar #'(lambda (x) (string-right-trim " " x)) string-list))
            (:both  (mapcar #'(lambda (x) (string-trim " " x)) string-list))
            (t      string-list)))
    (when add-newline
      (setq string-list
            (append (mapcar #'(lambda (x) (concat x "\n")) (butlast string-list))
                    (last string-list))))
    (apply #'concat string-list)))

(defun box-fixation-delete-region (from to &optional (unit :line))
  "列を考慮し、リージョンを削除
最右列の場合は空白を補完しない
引数：
  UNIT
    :line         行単位で左詰め
    :blank-line   空白行が出現するまでの範囲を左詰め
    :column       列全体を左詰め
    上記以外      削除後、詰めない
戻り値：t
注意：
  現在は UNIT が「:line」「上記以外」の場合のみ実装済み。"
  (interactive "*r")
  (let ((region-list (box-fixation-region-to-region-list from to))
        region column-width)
    (if (> from to) (rotatef from to))
    (case unit
      (:line
       (save-excursion
         (setq region-list (nreverse region-list))
         ;; 最後の行
         (setq region (pop region-list))
         (when region
           (setq column-width (- (progn (goto-char (cdr region)) (current-column))
                                 (progn (goto-char (car region)) (current-column))))
           (unless (box-fixation-right-most-column-p)
             (box-fixation-goto-eol)
             (insert " " column-width))
           (delete-region (car region) (cdr region)))
         ;; 最後以外の行
         (dolist (region region-list)
           (setq column-width (- (progn (goto-char (cdr region)) (current-column))
                                 (progn (goto-char (car region)) (current-column))))
           (delete-region (car region) (cdr region))
           (unless (box-fixation-right-most-column-p)
             (insert " " column-width))))
       (goto-char from))
      (:blank-line ; 未実装
       nil)
      (:column     ; 未実装
       nil)
      (t
       (save-excursion
         (dolist (region (nreverse region-list))
           (setq column-width (- (progn (goto-char (cdr region)) (current-column))
                                 (progn (goto-char (car region)) (current-column))))
           (delete-region (car region) (cdr region))
           (unless (box-fixation-right-most-column-p)
             (insert " " column-width))))
       (goto-char from))))
  t)

(defun box-fixation-clear-region (from to)
  "列を考慮し、リージョンを空白に置換。
戻り値：t"
  (interactive "*r")
  (box-fixation-delete-region from to nil))

(defun box-fixation-delete-char (&optional (arg 1))
  "列を考慮し、指定文字数分だけ削除する。
戻り値：t"
  (interactive "*p")
  (box-fixation-delete-region (point)
                              (progn
                                (box-fixation-forward-char arg)
                                (point))))

(defun box-fixation-delete-backward-char (&optional (arg 1))
  "列を考慮し、指定文字数分だけ後ろの文字を削除する。
戻り値：t"
  (interactive "*p")
  (box-fixation-delete-char (- arg)))

(defun box-fixation-copy-region-as-kill (from to &optional (trim-type :both) add-newline)
  "列を考慮し、リージョンをキルリングに追加
戻り値：t"
  (interactive "r")
  (setq *clipboard-newer-than-kill-ring-p* nil
        *kill-ring-newer-than-clipboard-p* t)
  (let ((text (box-fixation-buffer-substring from to trim-type add-newline)))
    (if (eq *last-command* 'box-fixation-kill-region)
        (kill-append text (> from to))
      (kill-new text)))
  (when (and (interactive-p)
             (null *executing-macro*))
    (message "Region copied"))
  t)

(defun box-fixation-append-next-kill ()
  "次回キルでアペンドするように設定"
  (interactive)
  (setq *last-command* 'box-fixation-kill-region)
  (setq *this-command* 'box-fixation-kill-region))

(defun box-fixation-kill-region (from to &optional (trim-type :both) add-newline)
  "列を考慮し、リージョンをキルリングに追加し、リージョンを削除"
  (interactive "*r")
  (setq *this-command* 'box-fixation-kill-region)
  (box-fixation-copy-region-as-kill from to trim-type add-newline)
  (box-fixation-delete-region from to))

(defun box-fixation-copy-region-to-clipboard (from to &optional (trim-type :both) add-newline)
  "列を考慮し、リージョンをクリップボードにコピー"
  (interactive "r")
  (copy-to-clipboard (box-fixation-buffer-substring from to trim-type add-newline)))

(defun box-fixation-kill-region-to-clipboard (from to)
  "列を考慮し、リージョンをクリップボードにコピーし、リージョンを削除"
  (interactive "*r")
  (box-fixation-copy-region-to-clipboard from to)
  (box-fixation-delete-region from to))

(defun box-fixation-kill-line ()
  "列を考慮し、一行キル"
  (interactive "*")
  (unless (box-fixation-column-p)
    (return-from box-fixation-kill-line (kill-line)))
  (box-fixation-kill-region
   (point)
   (progn (box-fixation-goto-eol) (point))
   (if (box-fixation-right-most-column-p) nil :right)))

(defun box-fixation-string-line (&optional (trim-type :both))
  "列の文字列を返す。
返す文字列には左右の空白文字は含まれない。"
  (save-excursion
    (if (box-fixation-column-p)
        (box-fixation-buffer-substring
         (progn (box-fixation-goto-bol) (point))
         (progn (box-fixation-goto-eol) (point))
         trim-type)
      "")))

(defun box-fixation-delete-line ()
  "列の文字列を削除する。
削除後、列行頭に移動する。
戻り値：現在不定"
  (when (box-fixation-column-p)
    (box-fixation-delete-region
     (progn (box-fixation-goto-bol) (point))
     (progn (box-fixation-goto-eol) (point)))))

(defun box-fixation-open-line (&optional (arg 1))
  "次行に継続行を挿入する。
引数：
  ARG          : 挿入行数"
  (interactive "*p")
  (save-excursion
    (let (next-column-alist)
      (dolist (x (box-fixation-get-column-alist))
        (cond ((plusp (logand (or (cdr (assoc (cdr x) *box-drawings-chars*)) 0)
                              *box-drawings-s*))
               (push (cons (car x) #\│) next-column-alist))
              ((plusp (logand (or (cdr (assoc (cdr x) *box-drawings-chars*)) 0)
                              *box-drawings-ss*))
               (push (cons (car x) #\┃) next-column-alist))))
      (setq next-column-alist (nreverse next-column-alist))
      (goto-eol)
      (while (plusp arg)
        (decf arg)
        (insert "\n")
        (dolist (x next-column-alist)
          (insert " " (- (car x) (current-column)))
          (insert (cdr x)))))))

(defun box-fixation-insert-1 (string &optional extra-string)
  "現在の行、カラムに文字列を挿入する。
はみ出た分は戻り値で返す。
引数：
  STRING       : 挿入文字列
  EXTRA-STRING : 挿入文字列を挿入したために押し出された文字列

戻り値：
  (values <幅条件判定> string extra-string <挿入終了ポイント>)
  <幅条件判定>      : 幅があれば t 幅がなければ nil
  STRING            : 引数で与えられた string のうち、挿入できなかった分の文字列
  EXTRA-STRING      : 引数で与えられた string 挿入によって押し出された文字列
  <挿入終了ポイント>: string を挿入し終わったポイント。
                      string 挿入しきらない場合、既に挿入しきっている場合は nil"
  (when (or (not (stringp string)) (string= string ""))
    (setq string nil))
  (when (or (not (stringp extra-string)) (string= extra-string ""))
    (setq extra-string nil))
  (when (and (null string) (null extra-string))
    (return-from box-fixation-insert-1 (values t nil nil (point))))
  (save-excursion
    (let ((buffer (selected-buffer))
          (column-alist (box-fixation-get-column-alist))
          (column (current-column)) left-column-element right-column-element
          goto-point limit-column string-length)
      ;; 有効な列でない場合は終了
      (unless (box-fixation-column-p)
        (return-from box-fixation-insert-1 (values nil string extra-string nil)))
      (multiple-value-setq (left-column-element right-column-element)
        (box-fixation-get-side-column-elements column-alist column))
      ;; 右側に罫線がなければ全て挿入して正常終了
      (unless right-column-element
        (when string
          (insert string)
          (setq goto-point (point)))
        (when extra-string
          (insert extra-string))
        (return-from box-fixation-insert-1 (values t nil nil goto-point)))
      ;; 右側に罫線がある場合
      ;; 右側の罫線から、左に向けて削除可能な空白を削除
      (setq limit-column (car right-column-element))
      (goto-column limit-column)
      (delete-region (point)
                     (progn
                       (skip-chars-backward " ")
                       (when (< (current-column) column)
                         (goto-column column))
                       (point)))
      (insert "\n")
      (backward-char)
      ;;
      (goto-column column)
      ;; string を挿入
      (when string
        (setq string-length (length string))
        (dotimes (i (1+ string-length) (progn (insert string) (setq string nil)))
          (when (< limit-column (count-column (substring string 0 i) column buffer))
            (insert (substring string 0 (1- i)))
            (setq string (substring string (1- i)))
            (return)))
        (unless string
          (setq goto-point (point))))
      ;; string が挿入しきらなかった場合、スペース補正
      (when string
        (insert " " (- limit-column (current-column))))
      (setq column (current-column))
      ;; extra-string をとりあえず挿入
      (when extra-string
        (insert extra-string)
        (setq extra-string nil))
      (goto-eol)
      ;; extra-string を記録
      (when (< limit-column (current-column))
        (goto-column limit-column)
        (setq extra-string (buffer-substring (point) (progn (goto-eol) (point))))
        (delete-region (point) (progn (goto-column limit-column) (point))))
      ;; スペース補正
      (insert " " (- limit-column (current-column)))
      (delete-char)
      (values t string extra-string goto-point))))

(defun box-fixation-insert (string &optional extra-string)
  "文字列を挿入する。"
  (let (valid-p goto-point tmp-goto-point column)
    (save-excursion
      (multiple-value-setq (valid-p string extra-string tmp-goto-point)
        (box-fixation-insert-1 string extra-string))
      (unless valid-p
        (insert string)
        (return-from box-fixation-insert nil))
      (when tmp-goto-point
        (setq goto-point tmp-goto-point))
      (while (or string extra-string)
        (unless (setq column (car (box-fixation-get-next-line-destination-columns)))
          (box-fixation-open-line)
          (setq column (car (box-fixation-get-next-line-destination-columns))))
        (next-line)
        (goto-column column)
        (multiple-value-setq (valid-p string extra-string tmp-goto-point)
          (box-fixation-insert-1 string extra-string))
        (when tmp-goto-point
          (setq goto-point tmp-goto-point))))
    (when goto-point
      (goto-char goto-point))))

(defun box-fixation-newline (&optional (arg 1) newline-type)
  "文字列を改行する。
引数：
  ARG          : 改行数
  NEWLINE-TYPE : :always      常に次行に新規行を挿入
                 :not-blank   次行の列が blank でない場合のみ次行に新規行を挿入
                 nil          文字列を次行の先頭に連結。必要に応じて新規行を挿入
戻り値： t"
  (interactive "*p")
  (unless (box-fixation-column-p)
    (return-from box-fixation-newline t))
  (let (extra-string point column)
    (while (plusp arg)
      (decf arg)
      (setq point (point))
      (box-fixation-goto-eol)
      (setq extra-string (box-fixation-buffer-substring
                          point (point)
                          (if (box-fixation-right-most-column-p) nil :right)))
      (box-fixation-delete-region point (point))
      (setq column (car (box-fixation-get-next-line-destination-columns)))
      (when (or (not column)
                (eq newline-type :always)
                (and (eq newline-type :not-blank)
                     (save-excursion
                       (forward-line)
                       (goto-column column)
                       (string/= (box-fixation-string-line) ""))))
        (box-fixation-open-line)
        (setq column (car (box-fixation-get-next-line-destination-columns))))
      (next-line)
      (if column
          (goto-column column)
        (goto-bol))
      (box-fixation-insert nil extra-string)))
  t)

(defun box-fixation-newline-for-always (&optional (arg 1))
  "新規行を挿入し、文字列を改行する。
戻り値： t"
  (interactive "*p")
  (box-fixation-newline arg :always))

(defun box-fixation-newline-for-not-blank (&optional (arg 1))
  "次行の列が blank でない場合のみ新規行を挿入し、文字列を改行する。
戻り値： t"
  (interactive "*p")
  (box-fixation-newline arg :not-blank))

(defun box-fixation-reposition (left right center)
  "列の文字列を左寄せ/右寄せ/センタリングする。
注意：
  タブ文字未対応"
  (unless (box-fixation-column-p)
    (return-from box-fixation-reposition nil))
  (when (box-fixation-right-most-column-p)
    (return-from box-fixation-reposition nil))
  (let ((column (current-column))
        (column-width (box-fixation-get-column-width))
        string string-width diff-width)
    (setq string (box-fixation-string-line))
    (setq string-width (count-column string))
    (setq diff-width (- column-width string-width))
    (box-fixation-delete-line)
    (cond (center
           (forward-char (floor diff-width 2))
           (when (and (plusp diff-width) (oddp diff-width) right)
             (forward-char)))
          (right
           (forward-char diff-width)))
    (box-fixation-insert string)
    (goto-column column)))

(defun box-fixation-reposition-left ()
  "列の文字列を左寄せする。"
  (interactive "*")
  (box-fixation-reposition t nil nil))

(defun box-fixation-reposition-right ()
  "列の文字列を右寄せする。"
  (interactive "*")
  (box-fixation-reposition nil t nil))

(defun box-fixation-reposition-center ()
  "列の文字列をセンタリングする。"
  (interactive "*")
  (box-fixation-reposition nil nil t))

(defun box-fixation-reposition-lcenter ()
  "列の文字列をセンタリング(左寄り)する。"
  (interactive "*")
  (box-fixation-reposition t nil t))

(defun box-fixation-reposition-rcenter ()
  "列の文字列をセンタリング(右寄り)する。"
  (interactive "*")
  (box-fixation-reposition nil t t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; マイナーモード/メジャーモード用関数
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun box-fixation-column-study ()
  "*pre-command-hook* 登録用"
  (when (or box-fixation-minor-mode
            (eq buffer-mode 'box-fixation-mode))
    (setq *box-fixation-target-buffer* (selected-buffer)
          *box-fixation-target-line* (current-line-number)
          *box-fixation-target-modified-count* (buffer-modified-count)
          *box-fixation-column-alist* (box-fixation-get-column-alist))))

(defun box-fixation-column-restore ()
  "*post-command-hook* 登録用"
  ;; 該当条件を満たさなければ終了 (その1)
  (unless (and
           ;; box-fixation-minor-mode/box-fixation-mode のバッファである
           (or box-fixation-minor-mode
               (eq buffer-mode 'box-fixation-mode))
           ;; コマンド前、行に罫線が存在した
           *box-fixation-column-alist*
           ;; コマンド前後でバッファが同一
           (eq *box-fixation-target-buffer* (selected-buffer))
           ;; コマンド前後で編集されている
           (not (eql *box-fixation-target-modified-count* (buffer-modified-count)))
           ;; コマンド前後で行番号が同一
           (eql *box-fixation-target-line* (current-line-number))
           ;; コマンドが undo でない
           (not (eq *this-command* 'undo)))
    (setq *box-fixation-column-alist* nil)
    (return-from box-fixation-column-restore))
  (let ((pre-column-alist (copy-alist *box-fixation-column-alist*))
        (post-column-alist (box-fixation-get-column-alist))
        (post-column (current-column))
        (goal-column (goal-column)) (point (point))
        pre-left-column-alist pre-right-column-alist
        post-left-column-alist post-right-column-alist
        pre-left-column-element pre-right-column-element
        post-left-column-element post-right-column-element
        pre-column-width post-column-width diff-column-width
        string extra-string goto-point)
    ;; 該当条件を満たさなければ終了 (その2)
    (unless (and
             ;; コマンド後、カーソル右側に罫線が存在する
             (progn
               (multiple-value-setq (post-left-column-element post-right-column-element)
                 (box-fixation-get-side-column-elements post-column-alist post-column))
               post-right-column-element)
             ;; コマンド前後で罫線の種類の出現順が同一
             (equal (mapcar #'cdr pre-column-alist)
                    (mapcar #'cdr post-column-alist))
             ;; コマンド前後でコマンド後を基準としたカーソル左側の罫線の出現位置が完全一致
             (progn
               (setq post-left-column-alist
                     (box-fixation-get-left-column-alist post-column-alist post-column)
                     post-right-column-alist
                     (box-fixation-get-right-column-alist post-column-alist post-column))
               (setq pre-left-column-alist
                     (butlast pre-column-alist (length post-right-column-alist))
                     pre-right-column-alist
                     (last pre-column-alist (length post-right-column-alist)))
               (equal (mapcar #'car pre-left-column-alist) (mapcar #'car post-left-column-alist)))
             ;; コマンド前後でコマンド後を基準としたカーソル右側の罫線の出現間隔が完全一致
             (equal (maplist #'(lambda (x) (if (cdr x) (- (cadr x) (car x)) nil))
                             (mapcar #'car pre-right-column-alist))
                    (maplist #'(lambda (x) (if (cdr x) (- (cadr x) (car x)) nil))
                             (mapcar #'car post-right-column-alist)))
             ;; コマンド前のカーソル位置カラム幅が *box-fixation-minimal-column-width* 以上
             (progn
               (setq pre-left-column-element (car (last pre-left-column-alist))
                     pre-right-column-element (car pre-right-column-alist))
               (setq pre-column-width (box-fixation-get-column-width
                                       pre-left-column-element pre-right-column-element))
               (>= pre-column-width *box-fixation-minimal-column-width*)))
      (return-from box-fixation-column-restore))
    ;; メイン
    (setq post-column-width (box-fixation-get-column-width
                             post-left-column-element post-right-column-element))
    (setq diff-column-width (- post-column-width pre-column-width))
    (cond
     ;; 幅が変わらない場合 (終了)
     ((zerop diff-column-width)
      t)
     ;; へこんだ場合 (終了)
     ((minusp diff-column-width)
      (goto-column (car post-right-column-element))
      (insert " " (- diff-column-width))
      (goto-column post-column)
      (set-goal-column goal-column))
     ;; 飛び出た場合
     (t
      ;; 現在位置かつコマンド前の右罫線以降のカラム末尾の空白を削除
      ;; (空白を削除したカラム末尾に移動)
      (delete-region
       (progn (goto-column (car post-right-column-element)) (point))
       (progn
         (skip-chars-backward " ")
         (when (< (point) point)
           (goto-char point))
         (when (< (current-column) (car pre-right-column-element))
           (goto-column (car pre-right-column-element)))
         (point)))
      (if (= (current-column) (car pre-right-column-element))
          ;; 空白文字で、飛び出た分が調整できた場合 (終了)
          (progn
            (goto-char point)
            (set-goal-column goal-column))
        ;; 空白文字で、飛び出た分が調整できなかった場合
        (let ((string-right-point (point)) insert-point)
          (if (< (car pre-right-column-element) post-column)
              ;; 現在位置も飛び出ている場合
              (progn
                (when (< point string-right-point)
                  (setq extra-string (buffer-substring point string-right-point)))
                (goto-column (car pre-right-column-element))
                (when (< (point) point)
                  (setq string (buffer-substring (point) point))))
            ;; 現在位置は飛び出ていない場合
            (progn
              (setq goto-point point)
              (goto-column (car pre-right-column-element))
              (setq extra-string (buffer-substring (point) string-right-point))))
          (delete-region (point) string-right-point)
          (setq insert-point (point))
          (insert " " (- (car pre-right-column-element) (current-column)))
          (goto-char insert-point)
          (box-fixation-insert string extra-string)
          (when goto-point
            (goto-char goto-point)
            (set-goal-column goal-column))))))))

(defun box-fixation-minor-mode (&optional (arg nil sv))
  "罫線を固定した編集用マイナーモード"
  (interactive "p")
  (toggle-mode 'box-fixation-minor-mode arg sv)
  (update-mode-line t)
  (if box-fixation-minor-mode
      (progn
        (set-minor-mode-map *box-fixation-minor-mode-map*)
        (add-hook '*pre-command-hook* 'box-fixation-column-study)
        (add-hook '*post-command-hook* 'box-fixation-column-restore))
    (progn
      (unset-minor-mode-map *box-fixation-minor-mode-map*)
      (setq *box-fixation-column-alist* nil)
      (dolist (buffer
               (buffer-list)
               (progn
                 (delete-hook '*pre-command-hook* 'box-fixation-column-study)
                 (delete-hook '*post-command-hook* 'box-fixation-column-restore)))
        (when (or (eq (buffer-local-value buffer 'buffer-mode) 'box-fixation-mode)
                  (buffer-local-value buffer 'box-fixation-minor-mode))
          (return))))))
(pushnew '(box-fixation-minor-mode . "BoxFix") *minor-mode-alist* :key #'car)

(defun box-fixation-mode ()
  "罫線を固定した編集用メジャーモード"
  (interactive)
  (kill-all-local-variables)
  (setq buffer-mode 'box-fixation-mode)
  (setq mode-name "BoxFix")
  (use-keymap *box-fixation-mode-map*)
  (use-syntax-table *box-fixation-mode-syntax-table*)
  (and *box-fixation-keyword-file*
       (null *box-fixation-keyword-hash-table*)
       (setq *box-fixation-keyword-hash-table*
             (load-keyword-file *box-fixation-keyword-file* t)))
  (when *box-fixation-keyword-hash-table*
    (make-local-variable 'keyword-hash-table)
    (setq keyword-hash-table *box-fixation-keyword-hash-table*))
  (make-local-variable 'regexp-keyword-list)
  (setq regexp-keyword-list *box-fixation-regexp-keyword-list*)
  (setq *local-abbrev-table* *box-fixation-mode-abbrev-table*)
  (add-hook '*pre-command-hook* 'box-fixation-column-study)
  (add-hook '*post-command-hook* 'box-fixation-column-restore)
  (run-hooks '*box-fixation-mode-hook*))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; メニュー操作関数
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun box-fixation-insert-menu-items (&key menu pre-tag position head-sep tail-sep)
  "box-fixation-minor-mode をメニューに追加"
  (if (and (not (menup menu)) (menup *app-menu*))
      (setq menu (get-menu *app-menu* 'ed::tools)))
  (when (menup menu)
    (box-fixation-delete-menu menu)
    (unless (or pre-tag position)
      (setq pre-tag 'ed::box-drawings-toggle-line-type))
    (when (and pre-tag
               (setq position (get-menu-position menu pre-tag)))
      (incf position))
    (unless (and (numberp position) (integerp position) (not (minusp position))
                 (get-menu menu position t))
      (setq position -1)
      (while (get-menu menu (incf position) t)))
    (decf position)
    (if (and head-sep
             (not (minusp position))
             (get-menu menu position t))
        (insert-menu-separator menu (incf position) 'box-fixation-mode-sep))
    (insert-menu-item menu (incf position) 'box-fixation-minor-mode
                      "罫線内編集モード(&H)"
                      'box-fixation-minor-mode
                      #'(lambda () (and box-fixation-minor-mode :check)))
    (if (and tail-sep
             (get-menu menu (incf position) t))
        (insert-menu-separator menu position 'box-fixation-mode-sep))))

(defun box-fixation-delete-menu (&optional menu)
  "box-fixation-minor-mode をメニューから削除"
  (if (and (not (menup menu)) (menup *app-menu*))
      (setq menu (get-menu *app-menu* 'ed::file)))
  (when (menup menu)
    (while (delete-menu menu 'box-fixation-minor-mode))
    (while (delete-menu menu 'box-fixation-mode-sep))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ツールバー関数
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun tool-bar-update-box-fixation-minor-mode ()
  (and box-fixation-minor-mode :check))

(defun tool-bar-update-box-drawings-mode ()
  (and *box-drawings-mode* :check))

(defun tool-bar-update-box-drawings-thick-line ()
  (values (unless *box-drawings-mode*
            :disable)
          (if (eq *box-drawings-line-type* '*box-drawings-thick-line*)
              :check)))

(defun box-fixation-tool-bar ()
  (create-tool-bar
   'box-fixation-tool-bar
   (merge-pathnames "toolbar-box-fixation.bmp" (etc-path))
   '(("罫線モード" 0 box-drawings-mode tool-bar-update-box-drawings-mode)
     ("太い罫線" 1 box-drawings-toggle-line-type tool-bar-update-box-drawings-thick-line)
     ("罫線内編集モード" 2 box-fixation-minor-mode tool-bar-update-box-fixation-minor-mode))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; アンインストール
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun box-fixation-mode-uninstall ()
  (delete-command-bar 'box-fixation-tool-bar)
  (box-fixation-delete-menu))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 読込み時設定
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-command-bar 'box-fixation-tool-bar "罫線編集(&H)")
(if (menup ed::*app-menu*)
    (box-fixation-insert-menu-items)
  (add-hook 'ed::*init-app-menus-hook*
            #'(lambda () (box-fixation-insert-menu-items))))

;;; box-fixation-mode.l ends here
