;; -*- Mode: Lisp; Package: EDITOR -*-
#|

Description:

monday.vim みたいなものです。
参考にして作ってみました。
キャレット(カーソル)直下の単語をトグルします。
・0 -> 1 -> 2 -> 3 ...
・monday -> tuesday -> wednesday ...
・True -> False -> True
・public -> protected ->  private -> public


Installation:
~/.xyzzy または $XYZZY/site-lisp/siteinit.l に
以下のコードを追加します。

(require "monday")

;キーバインドはお好みで
(global-set-key #\C-2   'monday-increase)
(global-set-key #\M-C-2 'monday-decrease)

Changes:

- 2008-02-02 文字がない場所でのエラー処理を追加
             monday-get-current-word無駄処理を削除

- 2008-01-09 ヘッダ部分を修正

- 2007-08-03 エラーが出るのを修正。macroの位置を変えた

- 2007-07-25 capitalizeに対応

- 2007-07-22 wordが隣接していた場合の処理を追加

- 2007-07-22 LICENSE適用

- 2007-07-22 初版


TODO:
- 1st 2nd 3rd対応
- 001,002 や 16進数対応


License:

    monday.l は修正BSDライセンスに基づいて利用可能です。
    <http://www.opensource.org/licenses/bsd-license.php>


    Copyright (C) 2007 bulb
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:

    1. Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright
       notice, this list of conditions and the following disclaimer in
       the documentation and/or other materials provided with the
       distribution.

    3. Neither the name of the University nor the names of its
       contributors may be used to endorse or promote products derived
       from this software without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
    A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
    OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
    SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
    DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
    THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
    OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


Author:
  bulb (ttomise at gmail dot com)

|#

;;; Code:

(provide "monday")

(in-package "editor")

(export '(monday-increase
          monday-decrease
          ))

(defvar *monday-number-regexp* "[0-9]")
(defvar *monday-string-regexp* "[a-zA-Z]")
(defvar *monday-capitalize* nil)
(defvar *monday-bool-alist*
  '(("true"  . "false")
    ("false" . "true")))
(defvar *monday-bool2-alist*
  '(("yes" . "no")
    ("no"  . "yes")))
(defvar *monday-bool3-alist*
  '(("t"   . "nil")
    ("nil" . "t")))
(defvar *monday-sw-alist*
  '(("on"  . "off")
    ("off" . "on")))
(defvar *monday-c++-alist*
  '(("public"    . "protected")
    ("protected" . "private")
    ("private"   . "public")))
(defvar *monday-week2-alist*
  '(("mon" . "tue")
    ("tue" . "wed")
    ("wed" . "thu")
    ("thu" . "fri")
    ("fri" . "sat")
    ("sat" . "sun")
    ("sun" . "mon")))
(defvar *monday-week-alist*
  '(("monday"    . "tuesday")
    ("tuesday"   . "wednesday")
    ("wednesday" . "thursday")
    ("thursday"  . "friday")
    ("friday"    . "saturday")
    ("saturday"  . "sunday")
    ("sunday"    . "monday")))
(defvar *monday-month-alist*
  '(("january"   . "february")
    ("february"  . "march")
    ("march"     . "april")
    ("april"     . "may")
    ("may"       . "june")
    ("june"      . "july")
    ("july"      . "august")
    ("august"    . "september")
    ("september" . "october")
    ("october"   . "november")
    ("november"  . "december")
    ("december"  . "january")))

(defun monday-increase () (interactive) (monday-inc  ))
(defun monday-decrease () (interactive) (monday-inc t))

(defun monday-inc (&optional (dec nil))
  (setf *monday-capitalize* 0)
  (multiple-value-bind (bool str)
      (monday-current-string-or-number)
    (if (and bool str) (monday-numeric-inc str dec)
      (or (monday-toggle str *monday-bool-alist* dec)
          (monday-toggle str *monday-bool2-alist* dec)
          (monday-toggle str *monday-bool3-alist* dec)
          (monday-toggle str *monday-c++-alist* dec)
          (monday-toggle str *monday-sw-alist* dec)
          (monday-toggle str *monday-week-alist* dec)
          (monday-toggle str *monday-week2-alist* dec)
          (monday-toggle str *monday-month-alist* dec)))))

(defun monday-toggle (str alist &optional (dec nil))
  (let* ((beg (region-beginning))
         (end (region-end))
         (pt  (point))
         (pair  (monday-get-alist str alist dec))
         (pair-search  (funcall (if dec #'cdr #'car) pair))
         (pair-return  (funcall (if dec #'car #'cdr) pair))
         )
    (when (and str (equalp str pair-search))
      (monday-replace beg end pt)
      (insert (cond
               ((= *monday-capitalize* 2) (string-upcase pair-return))
               ((= *monday-capitalize* 1) (string-upcase pair-return :start 0 :end 1))
               (t pair-return)))
      (return-from monday-toggle t)) ;見つけたので抜ける
    nil))

(defun monday-get-alist (str alist &optional (dec nil))
  (let* ((fn-ass (if dec #'rassoc #'assoc))
         (pair (funcall fn-ass str alist :test #'equalp)))
    pair))

;; inc/dec numbers
(defun monday-numeric-inc (str &optional (dec nil))
  (let* ((num (atoi str))
         (ret-num (if (not dec) (if (<= 0 num) (1+ num) 0)
                    (if (< 0 num) (1- num) 0)))
         (beg (region-beginning))
         (end (region-end))
         (pt  (point)))
    (monday-replace beg end pt)
    (insert (format nil "~S" ret-num))))

;test
;(nstring-capitalize "abcd")
(defun monday-replace (beg end pt)
  (goto-char (mark))
  (start-selection 2 t)
  (goto-char pt)
  (start-selection 2 t)
  (delete-region beg end))


;;; get current word
(defun monday-current-string-or-number ()
  (if (get-selection-type)
      (let ((str (selection-start-end (start end) (buffer-substring start end))))
        (cond
         ((numberp (string-match *monday-number-regexp* str))
          (values t (monday-get-current-word *monday-number-regexp*)))
         ((numberp (string-match *monday-string-regexp* str))
          (values nil (monday-get-current-word *monday-string-regexp*)))
         (t
          )))
    (cond
     ((or (looking-at-backward *monday-number-regexp*)
          (looking-at *monday-number-regexp*))
      (values t (monday-get-current-word *monday-number-regexp*)))
     ((or (looking-at-backward *monday-string-regexp*)
          (looking-at *monday-string-regexp*))
      (values nil (monday-get-current-word *monday-string-regexp*)))
     (t
      ))))

(defun monday-get-current-word (regexp)
  (let (word)
    (while (looking-at-backward regexp)
        (if (bolp) (return))
        (backward-char 1))
    (setf word (monday-get-word regexp))
    (cond
     ((string-capitalizep word) (setf *monday-capitalize* 1))
     ((string-all-capitalizep word) (setf *monday-capitalize* 2)))
    word))

(defun monday-get-word (regexp)
  (when (looking-at (concat regexp "+"))
    (goto-char (match-end 0))
    (start-selection 2 t)
    (set-mark)
    (prog1
        (buffer-substring (match-beginning 0) (match-end 0))
      (goto-char (match-beginning 0)))
    ))

;;; utilities
(defmacro atoi (str)
  `(multiple-value-bind (num num2) (parse-integer ,str) num))

(defmacro string-capp (regexp str)
  `(let ((p (string-match ,regexp ,str)))
     (if (and (numberp p) (= 0 p)) t nil)))
(defun string-capitalizep (str) (string-capp "^[A-Z][a-z]+$" str))
(defun string-all-capitalizep (str) (string-capp "^[A-Z]+$" str))

; http://xyzzy.s53.xrea.com/wiki/index.php?cmd=read&page=%BC%C1%CC%E4%C8%A2%2F175&word=looking-at%20
(defun looking-at-backward (regexp &optional case-fold)
  (save-excursion
    (save-restriction
      (narrow-to-region (point-min) (point))
      (goto-char (point-min))
      (scan-buffer (format nil "~A\\'" regexp)
                   :regexp t :case-fold case-fold))))
;;; monday.l ends here
