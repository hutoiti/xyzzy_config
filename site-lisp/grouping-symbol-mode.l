;;; -*- mode: lisp -*-
;;; name:     grouping-symbol-mode
;;; version:  2007.07.13
;;; author:   shiro
;;; category: Editing
;;; src:      http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fgrouping-symbol-mode&openfile=
;;; changes:  初版
;;; files:    site-lisp/grouping-symbol-mode.l
;;;           site-lisp/grouping-symbol-mode.lc
;;;           site-lisp/ni-autoload/silog/grouping-symbol-mode.l

;; Copyright (C) 2007 shiro
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
;; 閉じ括弧の入力を支援するマイナーモード
;; 
;; (前置引数を渡すことで,どこに閉じ括弧を挿入するか決める)

;; 設定:
;;
;; NetInstallerで導入した方は 1 は不要です
;;
;;   1 $XYZZY/site-lisp/ 以下にコピーし、バイトコンパイルしてください。
;;   
;;   2 .xyzzy や siteinit.l に以下を参考に記述し、
;;     siteinit.lに記述した方は再ダンプしてください。
;;     
;;     (require "grouping-symbol-mode") ; ni-autoloadしている人は不要
;;   
;;   3 好みに応じて
;;   
;;     ;; lisp-mode/lisp-interaction-modeでgrouping-symbol-modeをon
;;     (add-hook '*lisp-mode-hook* 'grouping-symbol-mode-on)
;;     (add-hook '*lisp-interaction-mode-hook* 'grouping-symbol-mode-on)
;;     ;; lisp-mode時にC-8で閉じ括弧付き丸括弧
;;     (define-key ed::*lisp-mode-map* #\C-8 'ed::grouping-symbol-mode-insert-paren)

;; 使い方:
;; 
;; 1. grouping-symbol-modeがonになっていることを確認
;; 
;; 2. キーを入力
;;    最初に開き括弧が挿入され、最後に開き括弧の直後まで戻ってきます
;;    また、{,<,[でも可能です
;;    
;;    (             | 通常通り(を入力
;;    M-0 (         | 開き括弧の直後に閉じ括弧を挿入
;;    C-u (         | 同上
;;    M-1 (         | forward-sexpを1回行った位置に閉じ括弧を挿入
;;    C-u C-u (     | 同上
;;    M-2 (         | forward-sexpを2回行った位置に閉じ括弧を挿入
;;    C-u C-u C-u ( | 同上
;;    .             | 
;;    .             | 
;;    .             | 
;;    
;;    grouping-symbol-mode-insert-{paren,brace,bracket}を独自のキーに設定している場合
;;    digit-argumentの時(M-0, M-1, M-3 ,,,)は上記と同様で、
;;    universal-argumentの時(C-u, C-u C-u ,,,)は1回入力回数が少なくて済みます

;; その他:
;; 
;; grouping-symbol-mode-get-position-hookに何か引っ掛ければ
;; forward-sexp以外の位置に挿入可能かも
;; (run-hook-with-args-until-successで実行される)
;; 
;; grouping-symbol-mode-listを増やして
;; *grouping-symbol-mode-last-command-string*をletで一時的に変更してやれば
;; 任意の組の文字列を前置引数によって自動挿入、とかできるかも。

;; 履歴:
;; 
;; 2007.07.13
;; - 初版


;;; Code:

(provide "grouping-symbol-mode")

(in-package "editor")

(export '(grouping-symbol-mode
		  grouping-symbol-mode-on
		  grouping-symbol-mode-off
		  grouping-symbol-mode-insert
		  grouping-symbol-mode-insert-paren
		  grouping-symbol-insert-bracket
		  grouping-symbol-mode-insert-brace
		  ))

(defvar-local grouping-symbol-mode-get-position-hook nil)

(defvar-local grouping-symbol-mode-list
  '(("(" ")")
	("{" "}")
	("[" "]")
	("<" ">")
	))

(defvar *grouping-symbol-mode-last-command-string* nil)

(defun grouping-symbol-mode-get-close-char ()
  (let ((res (assoc (or *grouping-symbol-mode-last-command-string*
						(string *last-command-char*))
					grouping-symbol-mode-list :test 'equal)))
	(when res
	  (second res))))

;; ------------------------------------------------------------------
;; Command
;; ------------------------------------------------------------------
(defun grouping-symbol-mode-insert ()
  (interactive "*")
  (insert (or *grouping-symbol-mode-last-command-string*
			  *last-command-char*))
  (when *prefix-args*
	(let ((char (grouping-symbol-mode-get-close-char)))
	  (when char
		(cond ((equal 'universal-argument *prefix-args*)
			   (save-excursion
				 (unless (run-hook-with-args-until-success grouping-symbol-mode-get-position-hook)
				   (forward-sexp (- (rationalize (log *prefix-value* 4)) 1)))
				 (insert char)))
			  ((equal 'digit-argument *prefix-args*)
			   (save-excursion
				 (forward-sexp *prefix-value*)
				 (insert char))))))))

(defmacro grouping-symbol-mode-make-insert-command (string)
  `(let ((*prefix-value*
		  (cond ((equal 'universal-argument *prefix-args*)
				 (* 4 *prefix-value*))
				((equal 'digit-argument *prefix-args*)
				 *prefix-value*)
				((not *prefix-args*)
				 4)))
		 (*prefix-args* (or *prefix-args* 'universal-argument))
		 (*grouping-symbol-mode-last-command-string* ,string))
	 (grouping-symbol-mode-insert)))

(defun grouping-symbol-mode-insert-paren ()
  (interactive "*")
  (grouping-symbol-mode-make-insert-command "("))

(defun grouping-symbol-insert-bracket ()
  (interactive "*")
  (grouping-symbol-mode-make-insert-command "["))

(defun grouping-symbol-mode-insert-brace ()
  (interactive "*")
  (grouping-symbol-mode-make-insert-command "{"))

;; ------------------------------------------------------------------
;; Mode
;; ------------------------------------------------------------------

(pushnew '(grouping-symbol-mode-on . "Gr") *minor-mode-alist* :key #'car)
(defvar-local grouping-symbol-mode-on nil)

(defvar *grouping-symbol-mode-map* nil)
(unless *grouping-symbol-mode-map*
  (setf *grouping-symbol-mode-map* (make-sparse-keymap))
  (define-key *grouping-symbol-mode-map* #\( 'grouping-symbol-mode-insert)
  (define-key *grouping-symbol-mode-map* #\{ 'grouping-symbol-mode-insert)
  (define-key *grouping-symbol-mode-map* #\< 'grouping-symbol-mode-insert)
  (define-key *grouping-symbol-mode-map* #\[ 'grouping-symbol-mode-insert))

(defun grouping-symbol-mode (&optional (arg nil sv))
  (interactive "p")
  (toggle-mode 'grouping-symbol-mode-on arg sv)
  (if grouping-symbol-mode-on
	  (set-minor-mode-map *grouping-symbol-mode-map*)
	(unset-minor-mode-map *grouping-symbol-mode-map*))
  (unless *executing-macro*
	(update-mode-line)))

(defun grouping-symbol-mode-on ()
  (interactive)
  (grouping-symbol-mode t))

(defun grouping-symbol-mode-off ()
  (interactive)
  (grouping-symbol-mode nil))

;;; grouping-symbol-mode.l ends here
