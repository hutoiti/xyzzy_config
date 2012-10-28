;; -*- Mode: Lisp; Package: EDITOR -*-
;;
;; yaml-mode for xyzzy
;;
;; Author: rufein <rufein_mirage at yahoo.co.jp>
;; Version: 0.0.1
;;
;; ■ yaml-modeについて
;; YAMLを編集するxyzzyのメジャーモードです。
;; ブロックスタイルのみ対応。フロースタイルには未対応です。
;; 
;; ■ できること
;;   ・適当なインデント
;;   ・適当な色付け
;;
;; ■ 設定
;; (require "yaml-mode")
;; (push '("\\.yaml\\|\\.yml$" . ed::yaml-mode) *auto-mode-alist*)
;;
;;
;;
;; ■ License
;; yaml-mode は修正BSDライセンスに基づいて利用可能です。
;; <http://www.opensource.org/licenses/bsd-license.php>
;;
;; Copyright (C) 2006 rufein
;; 
;; All rights reserved.
;;
;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions
;; are met:
;;
;; 1. Redistributions of source code must retain the above copyright
;;    notice, this list of conditions and the following disclaimer.
;;
;; 2. Redistributions in binary form must reproduce the above copyright
;;    notice, this list of conditions and the following disclaimer in
;;    the documentation and/or other materials provided with the
;;    distribution.
;;
;; 3. The name of the author may not be used to endorse or promote
;;    products derived from this software without specific prior
;;    written permission.
;;
;; THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
;; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
;; PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
;; DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
;; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
;; OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
;; HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
;; STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
;; ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;; POSSIBILITY OF SUCH DAMAGE.


(provide "yaml")

(in-package "editor")

(export '(yaml-mode
	  *yaml-mode-hook* *yaml-indent-column*
	  *yaml-mode-map*))

(defvar *yaml-mode-hook* nil)

(defvar *yaml-indent-column* 2)

(defvar *yaml-mode-syntax-table* nil)
(unless *yaml-mode-syntax-table*
  (setq *yaml-mode-syntax-table* (make-syntax-table))
  (do ((x #x21 (1+ x)))((>= x #x7f))
    (let ((c (code-char x)))
      (unless (alphanumericp c)
	(set-syntax-punctuation *yaml-mode-syntax-table* c))))
  (set-syntax-string *yaml-mode-syntax-table* #\")
  (set-syntax-string *yaml-mode-syntax-table* #\')
  (set-syntax-escape *yaml-mode-syntax-table* #\\)
  (set-syntax-symbol *yaml-mode-syntax-table* #\_)
  (set-syntax-symbol *yaml-mode-syntax-table* #\#)
  (set-syntax-match *yaml-mode-syntax-table* #\( #\))
  (set-syntax-match *yaml-mode-syntax-table* #\{ #\})
  (set-syntax-match *yaml-mode-syntax-table* #\[ #\])
  (set-syntax-start-comment *yaml-mode-syntax-table* #\# t)
  (set-syntax-end-comment *yaml-mode-syntax-table* #\LFD nil t))

(defvar *yaml-mode-map* nil)
(unless *yaml-mode-map*
  (setq *yaml-mode-map* (make-sparse-keymap))
  (define-key *yaml-mode-map* #\C-h 'backward-delete-char-untabify-or-selection)
  (define-key *yaml-mode-map* #\TAB 'yaml-indent-line)
;  (define-key *yaml-mode-map* #\M-TAB 'yaml-completion)
  (define-key *yaml-mode-map* #\RET 'yaml-newline-and-indent))


(defun yaml-newline-and-indent (&optional (arg 1))
  (interactive "*p")
  (delete-trailing-spaces)
  (insert #\LFD arg)
  (yaml-indent-line))

(defun yaml-indent-line ()
  (interactive "*")
  (let ((column (calc-yaml-indent)))
    (when (integerp column)
      (yaml-indent-to column)))
  t)

(defun yaml-indent-to (column)
  (save-excursion
    (goto-bol)
    (delete-region (point)
		   (progn
		     (skip-chars-forward " \t")
		     (point)))
    (indent-to column))
  (when (and (bolp) column)
    (skip-chars-forward " \t")))

;;インデントする数を数える
(defun calc-yaml-indent ()
  (let ((column 0)
	(add 0)
	(plus 0)
	(curp (point)))
    (save-excursion
      ;前の行を調べる
      (when (yaml-previous-line)
	(goto-bol)
	(skip-chars-forward " \t")
	(setq column (current-column))
	(cond ((looking-at "\-\n")
	       (setq add 2))
	      ((looking-at "[a-zA-Z0-9_]+:\n")
;	       (setq add (length (match-string 0))))
	       (setq add 2))
	)
;	(message-box (format nil "~D:~D:~D" column add plus))
      ))
    ; 現在の行を調べる
    (save-excursion
      (goto-bol)
      (skip-chars-forward " \t")
      ; 閉じものがあればインデント数を減らす
      (cond ((looking-at "[a-zA-Z0-9_]+:")
	     (incf column plus))
;	     (setq column (+ column add plus)))
	    ((looking-at "\- ")
	     (incf column plus))
;	     (setq column (+ column add plus)))
	    (t
	     (setq column (+ column add plus)))
;	     (incf column plus))
      ))
    (max column 0)
  ))

(defun yaml-previous-line ()
  (while (forward-line -1)
    (unless (yaml-space-line)
      (return-from yaml-previous-line t))))

(defun yaml-space-line ()
  "空行かどうか（ってこうやって調べるものなのか？）"
  (save-excursion
    (goto-bol)
    (looking-at "[ \t]*$")))

(defun yaml-comment-indent ()
  "コメント用インデントコマンド"
  (generic-comment-indent "#" #'calc-yaml-indent))

(defun yaml-mode ()
  (interactive)
  (kill-all-local-variables)
  (setq mode-name "yaml")
  (setq buffer-mode 'yaml-mode)
  (use-syntax-table *yaml-mode-syntax-table*)
  (use-keymap *yaml-mode-map*)
  (make-local-variable 'mode-specific-indent-command)
  (setq mode-specific-indent-command #'yaml-indent-line)
  (make-local-variable 'indent-tabs-mode)
  (setq indent-tabs-mode nil)
  (make-local-variable 'regexp-keyword-list)
  (setq regexp-keyword-list *yaml-variables-regexp*)
  (setq comment-start "# ")
  (setq comment-end "")
;;  (setq comment-start-skip-function 'yaml-comment-start-skip)
  (setq comment-indent-function 'yaml-comment-indent)
;;  (when *yaml-comment-column*
;;    (setq comment-column *yaml-comment-column*))
  (run-hooks '*yaml-mode-hook*))

(defvar *yaml-variables-regexp*
      (compile-regexp-keyword-list
       '(
	 ("-\\( +\\|\n\\)"
	  t (:keyword 0))
	 ("[^ \t]+:\\( +\\|\n\\)"
	  t (:keyword 1) nil)
	 ("&[^ \t]+"
	  t (:keyword 2 :underline))
	 ("\\*[^ \t]+"
	  t (:keyword 2))
	 )))

