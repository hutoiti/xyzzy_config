;;; -*- mode: lisp -*-
;;; name:     lisp-minibuffer-mode
;;; version:  2008.01.06
;;; author:   snj14
;;; category: Editing
;;; src:      http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Flisp-minibuffer-mode&openfile=
;;; changes:  ミニバッファのサイズを変更できない時でも可能な大きさで拡大するように修正
;;;           lisp-minibuffer-mode-check-size をミニバッファの post-command-hook にhookするように修正
;;; files:    site-lisp/lisp-minibuffer-mode.l
;;;           site-lisp/lisp-minibuffer-mode.lc
;;;           site-lisp/ni-autoload/silog/lisp-minibuffer-mode.l

;; Copyright (C) 2007 snj14
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

;;; Commentary:

;; 概要:
;; 
;; eval-expression [ESC ESC] 用のメジャーモードです
;; 
;; 以下の特徴があります
;; - paren.lの強調が有効になる
;; - 専用のキーマップが指定できる
;; - ミニバッファの高さが可変になる
;; - undoができる
;; 

;; 設定:
;; 
;; ;; ac-modeを使う
;; (define-key *lisp-minibuffer-mode-map* #\TAB 'ac-mode-complete-or-indent)
;; 

;; 履歴:
;; 
;; 2008.01.06
;; - ミニバッファのサイズを変更できない時でも可能な大きさで拡大するように修正
;; - lisp-minibuffer-mode-check-size をミニバッファの post-command-hook にhookするように修正
;; 
;; 2007.04.12
;; - 初版

;;; Code:

(provide "lisp-minibuffer-mode")

(in-package "editor")

(export '(*lisp-minibuffer-mode-map*
		  *lisp-minibuffer-mode-hook*
		  ))

(defvar *lisp-minibuffer-mode-map*
  (let ((keymap (copy-keymap minibuffer-local-map)))
	(define-key keymap #\) 'lisp-electric-close)
	(define-key keymap #\TAB 'lisp-indent-line)
	(define-key keymap #\C-M-q 'indent-sexp)
	keymap))

(defvar *lisp-minibuffer-mode-hook* nil)

(defvar *lisp-minibuffer-mode-keyword-hash-table* nil)

(defun lisp-minibuffer-mode-load-keyword-file ()
  (setf *lisp-minibuffer-mode-keyword-hash-table*
		(load-keyword-file "lisp")))

(if (modulep "startup")
	(lisp-minibuffer-mode-load-keyword-file)
  (add-hook '*pre-startup-hook* 'lisp-minibuffer-mode-load-keyword-file))

;; ミニバッファのサイズを変更できない時でも、可能な大きさで拡大。
(defun enlarge-window-if-possible (extend)
  (loop
	(handler-case
		(progn
		  (enlarge-window extend)
		  (refresh-screen)
		  (return))
	  (error (c)
		(if (= extend 1)
			(return))
		(setq extend (1- extend))))))

(defun lisp-minibuffer-mode-check-size ()
 (let ((line (save-excursion
               (goto-char (point-max))
               (current-line-number)))
       (height (window-height)))
   (unless (= line height)
     (enlarge-window-if-possible (- line height))
     )))

(defun lisp-minibuffer-mode-prologue (&optional buf his)
  (when (eq his :lisp-sexp)
	(let ((point (point)))
	  (with-set-buffer
		(save-excursion
		  (set-buffer buf)
		  (kill-all-local-variables)
		  (make-local-variable 'highlight-keyword)
		  (setf highlight-keyword t)
		  (make-local-variable 'keyword-hash-table)
		  (setf keyword-hash-table *lisp-minibuffer-mode-keyword-hash-table*)
		  (use-syntax-table *lisp-mode-syntax-table*)
		  (use-keymap *lisp-minibuffer-mode-map*)
		  (make-local-variable 'mode-specific-indent-command)
		  (setf mode-specific-indent-command 'lisp-indent-line)
		  (make-local-variable 'kept-undo-information)
		  (setf kept-undo-information (default-value 'kept-undo-information))
		  (setf buffer-mode 'lisp-minibuffer-mode)
		  (make-local-variable '*post-command-hook*)
		  (add-hook '*post-command-hook* 'lisp-minibuffer-mode-check-size)
		  (when (and (modulep "paren")
					 (not (eval (intern "*paren-status*" "ed"))))
			(funcall (intern "turn-on-paren"))))
;		(add-hook '*post-command-hook* 'lisp-minibuffer-mode-check-size)
		(ed::minibuffer-initialize buf his point)
		(run-hooks '*lisp-minibuffer-mode-hook*)
		))))

(add-hook '*enter-minibuffer-hook* 'lisp-minibuffer-mode-prologue)

(defun lisp-minibuffer-mode-epilogue (buf his)
  (with-set-buffer
	(save-excursion
	  (set-buffer buf)
	  (when (eq buffer-mode 'lisp-minibuffer-mode)
		(use-keymap minibuffer-local-map)
		(delete-hook '*post-command-hook* 'lisp-minibuffer-mode-check-size)))))

(add-hook '*exit-minibuffer-hook* 'lisp-minibuffer-mode-epilogue)

;;; lisp-minibuffer-mode.l ends here
