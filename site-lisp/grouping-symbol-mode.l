;;; -*- mode: lisp -*-
;;; name:     grouping-symbol-mode
;;; version:  2007.07.13
;;; author:   shiro
;;; category: Editing
;;; src:      http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fgrouping-symbol-mode&openfile=
;;; changes:  ����
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

;; �T�v:
;; 
;; �����ʂ̓��͂��x������}�C�i�[���[�h
;; 
;; (�O�u������n�����Ƃ�,�ǂ��ɕ����ʂ�}�����邩���߂�)

;; �ݒ�:
;;
;; NetInstaller�œ����������� 1 �͕s�v�ł�
;;
;;   1 $XYZZY/site-lisp/ �ȉ��ɃR�s�[���A�o�C�g�R���p�C�����Ă��������B
;;   
;;   2 .xyzzy �� siteinit.l �Ɉȉ����Q�l�ɋL�q���A
;;     siteinit.l�ɋL�q�������͍ă_���v���Ă��������B
;;     
;;     (require "grouping-symbol-mode") ; ni-autoload���Ă���l�͕s�v
;;   
;;   3 �D�݂ɉ�����
;;   
;;     ;; lisp-mode/lisp-interaction-mode��grouping-symbol-mode��on
;;     (add-hook '*lisp-mode-hook* 'grouping-symbol-mode-on)
;;     (add-hook '*lisp-interaction-mode-hook* 'grouping-symbol-mode-on)
;;     ;; lisp-mode����C-8�ŕ����ʕt���ۊ���
;;     (define-key ed::*lisp-mode-map* #\C-8 'ed::grouping-symbol-mode-insert-paren)

;; �g����:
;; 
;; 1. grouping-symbol-mode��on�ɂȂ��Ă��邱�Ƃ��m�F
;; 
;; 2. �L�[�����
;;    �ŏ��ɊJ�����ʂ��}������A�Ō�ɊJ�����ʂ̒���܂Ŗ߂��Ă��܂�
;;    �܂��A{,<,[�ł��\�ł�
;;    
;;    (             | �ʏ�ʂ�(�����
;;    M-0 (         | �J�����ʂ̒���ɕ����ʂ�}��
;;    C-u (         | ����
;;    M-1 (         | forward-sexp��1��s�����ʒu�ɕ����ʂ�}��
;;    C-u C-u (     | ����
;;    M-2 (         | forward-sexp��2��s�����ʒu�ɕ����ʂ�}��
;;    C-u C-u C-u ( | ����
;;    .             | 
;;    .             | 
;;    .             | 
;;    
;;    grouping-symbol-mode-insert-{paren,brace,bracket}��Ǝ��̃L�[�ɐݒ肵�Ă���ꍇ
;;    digit-argument�̎�(M-0, M-1, M-3 ,,,)�͏�L�Ɠ��l�ŁA
;;    universal-argument�̎�(C-u, C-u C-u ,,,)��1����͉񐔂����Ȃ��čς݂܂�

;; ���̑�:
;; 
;; grouping-symbol-mode-get-position-hook�ɉ��������|�����
;; forward-sexp�ȊO�̈ʒu�ɑ}���\����
;; (run-hook-with-args-until-success�Ŏ��s�����)
;; 
;; grouping-symbol-mode-list�𑝂₵��
;; *grouping-symbol-mode-last-command-string*��let�ňꎞ�I�ɕύX���Ă���
;; �C�ӂ̑g�̕������O�u�����ɂ���Ď����}���A�Ƃ��ł��邩���B

;; ����:
;; 
;; 2007.07.13
;; - ����


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