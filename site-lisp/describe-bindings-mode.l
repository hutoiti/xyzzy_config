;;; -*- mode: lisp -*-
;;; name:     describe-bindings-mode
;;; version:  2007.02.22
;;; author:   shiro
;;; category: Utilities
;;; src:      http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fdescribe-bindings-mode&openfile=
;;; changes:  �~�j�o�b�t�@�ł��g����悤�ɂ���
;;; files:    site-lisp/describe-bindings-mode.l
;;;           site-lisp/describe-bindings-mode.lc
;;;           site-lisp/ni-autoload/silog/describe-bindings-mode.l

;; Copyright (C) 1996-2005 Tetsuya Kamei
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
;; �L�[�}�b�v�\��(describe-bindings)��
;;  * �F�t��
;;  * �^�O�W�����v
;;  * q�ŕ���
;;  * �����I�ɐ^�񒆂���㉺2�����ł̕\��
;;  * ���{��̉���\��
;; �̋@�\��t���܂��B
;; 
;; ���{��̉���\���ɂ�info-modoki-mode + reference.txt���A
;; �F�t���ɂ�lisp�̃L�[���[�h�t�@�C�����K�v�ł��B

;; �ݒ�:
;; 
;; ;;; ���D�݂̃L�[��
;; (global-set-key #\F1 'describe-bindings-mode)
;; 
;; ;;; ����ȍ~�̐ݒ������l��require���Ƃ��������ǂ�����
;; (require "describe-bindings-mode")
;; 
;; ;;; ���{��̉���������\������
;; (setf *describe-bindings-show-explain* t)
;; 
;; ;;; �\���シ���ɃC���N�������^���T�[�`���J�n����
;; (defun describe-bindings-mode-auto-isearch ()
;;   (isearch-forward))
;; (add-hook '*describe-bindings-mode-hook* 'describe-bindings-mode-auto-isearch)
;; 
;; ;;; RET��info-modoki-mode�Ń��t�@�����X�\��
;; (define-key *describe-bindings-mode-map* #\RET 'imm-refer-selection)

;; �⑫:
;; 
;; ���{��̉���͂������t�@�����X�̈�s�ڂ�\�����Ă邾���ł��B
;; 
;; F1��describe-bindings-mode�����蓖�Ă��ꍇ�A
;; C-u F1����ƈꎞ�I�ɓ��{��̉���̕\����؂�ւ��邱�Ƃ��o���܂��B

;; ����:
;; 
;; 2007.02.22
;; - �~�j�o�b�t�@�ł��g����悤�ɂ���
;; 
;; 2007.02.19
;; - �֐��Ƀh�L�������g������Ε\������悤�ɂ���
;; 
;; 2007.01.29
;; - ����

;;; Code:

(provide "describe-bindings-mode")

(in-package "editor")

(export '(*describe-bindings-mode-hook*
		  *describe-bindings-show-explain*
		  *describe-bindings-mode-map*
		  describe-bindings-mode
		  ))

;;; describe-bindings-mode
(defvar *describe-bindings-mode-map* nil
  "�L�[�}�b�v")

(defvar *describe-bindings-winconf* nil
  "�w���v���o���O�̃E�B���h�E�̏��")

(defvar *describe-bindings-cash* (make-hash-table :test 'equal)
  "�֐��Ɛ������̃L���b�V��")

(defvar *describe-bindings-mode-hook* nil
  "�\����ɌĂ΂��hook")

(defvar *describe-bindings-show-explain* nil)

(defvar *describe-bindings-category-attribute*
  '(:foreground 2))

(defvar *describe-bindings-prefix-command-attribute*
  '(:foreground 1))

(unless *describe-bindings-mode-map*
  (setq *describe-bindings-mode-map* (make-sparse-keymap))
  (define-key *describe-bindings-mode-map* #\q 'quit-describe-bindings))

(defvar *describe-bindings-syntax-table* nil)
(unless *describe-bindings-syntax-table*
  (setq *describe-bindings-syntax-table* (make-syntax-table))
  (dotimes (x 127)
    (let ((c (code-char x)))
      (unless (alphanumericp c)
	(set-syntax-symbol *describe-bindings-syntax-table* c))))
  (set-syntax-whitespace *describe-bindings-syntax-table* #\SPC)
  (set-syntax-whitespace *describe-bindings-syntax-table* #\TAB)
  (set-syntax-whitespace *describe-bindings-syntax-table* #\C-l)
  (set-syntax-whitespace *describe-bindings-syntax-table* #\RET)
  (set-syntax-end-comment *describe-bindings-syntax-table* #\LFD nil t)
  (set-syntax-quote *describe-bindings-syntax-table* #\#)
  (set-syntax-quote *describe-bindings-syntax-table* #\')
  (set-syntax-quote *describe-bindings-syntax-table* #\,)
  (set-syntax-quote *describe-bindings-syntax-table* #\`)
  (set-syntax-match *describe-bindings-syntax-table* #\( #\))
  (set-syntax-escape *describe-bindings-syntax-table* #\\)
  (set-syntax-start-multi-comment *describe-bindings-syntax-table* "#|")
  (set-syntax-end-multi-comment *describe-bindings-syntax-table* "|#"))

(defvar *describe-bindings-mode-keyword-hash-table* nil)

(defun quit-describe-bindings ()
  "�L�[�}�b�v��\�������o�b�t�@�������ăE�B���h�E�����ɖ߂�"
  (interactive)
  (delete-buffer (selected-buffer))
  (set-window-configuration *describe-bindings-winconf*)
  (set-window (minibuffer-window))
  )


(defun describe-bindings-mode-1 (prefix keymap shadow)
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
			(bound (lookup-keymap-index keymap shadow index)))
		(when bound
		  (if (>= index 128)
			  (when nl
				(terpri)
				(setq nl nil))
			(unless nl
			  (terpri)
			  (setq nl t)))
		  (format t "~A~:C" prefix (*keymap-index-char index))
		  (cond ((symbolp bound)
				 (while (and (< nindex *full-keymap-length*)
							 (eq bound (lookup-keymap-index keymap shadow nindex)))
				   (setq nindex (1+ nindex)))
				 (when (/= index (1- nindex))
				   (format t " ... ~A~:C" prefix (*keymap-index-char (1- nindex))))
				 (let* ((doc (documentation bound 'function))
						(spc (concat "\n" (make-sequence 'string 55 :initial-element #\SPC)))
						(ret (if (<= 35 (length (format nil "~S" bound))) spc "")))
				   (cond (doc
						  (setf doc (first (split-string doc "\n")))
						  (format t "~19T ~S~55T~A~A~%" bound ret (substitute-string doc "\n" spc)))
						 (*describe-bindings-show-explain*
						  (format t "~19T ~S~55T~A~A~%" bound ret (describe-bindings-mode-get-ref (string bound))))
						 (t
						  (format t "~19T ~S~%" bound)))))
				((keymapp bound)
				 (format t "~19T Prefix Command~%"))
				(t
				 (format t "~19T Command~%"))))
		(setq index nindex)))
	(dotimes (index *full-keymap-length*)
	  (let* ((c (*keymap-index-char index))
			 (x (lookup-keymap keymap c)))
		(when (keymapp x)
		  (let ((y (mapcar #'(lambda (x) (lookup-keymap x c)) shadow)))
			(when (notany #'(lambda (x) (and x (not (keymapp x)))) y)
			  (describe-bindings-mode-1 (format nil "~A~:C " prefix c) x y))))))))

(defun describe-bindings-mode (&optional arg)
  "�L�[�}�b�v��\��"
  (interactive "p")
  (let ((*describe-bindings-show-explain* *describe-bindings-show-explain*)
		(local (local-keymap))
		(global *global-keymap*)
		(minor (minor-mode-map))
		(mini (minibuffer-window-p (selected-window)))
		(shadow nil))
	(with-set-buffer
	  (setf *describe-bindings-winconf* (current-window-configuration))
	  (delete-other-windows))
	(when arg
	  (setf *describe-bindings-show-explain* (not *describe-bindings-show-explain*)))
	(long-operation
	  (message "Building binding list...")
	  (with-output-to-temp-buffer ("*Help*")
		(when minor
		  (format t "Minor Mode Bindings:~%key~20Tbinding~%---~20T-------")
		  (mapc #'(lambda (x)
					(describe-bindings-mode-1 "" x shadow)
					(push x shadow))
				minor))
		(format t "Local Bindings:~%key~20Tbinding~%---~20T-------")
		(describe-bindings-mode-1 "" local shadow)
		(push local shadow)
		(format t "~%Global Bindings:~%key~20Tbinding~%---~20T-------")
		(describe-bindings-mode-1 "" global shadow)
		(goto-char 0))
	  (message "Building binding list...done"))
	(kill-all-local-variables)
	(make-local-variable 'tags-find-target)
	(setf tags-find-target 'lisp-tags-find-target)
	(setf tags-find-point 'lisp-tags-find-point)
	(use-syntax-table *describe-bindings-syntax-table*)
	; keyword highlight
	(unless *describe-bindings-mode-keyword-hash-table*
	  (setf *describe-bindings-mode-keyword-hash-table*
			(load-keyword-file "lisp")))
	(when *describe-bindings-mode-keyword-hash-table*
	  (make-local-variable 'keyword-hash-table)
	  (setf keyword-hash-table *describe-bindings-mode-keyword-hash-table*))
	(use-keymap *describe-bindings-mode-map*)
	(set-default-directory (merge-pathnames "lisp" (si:system-root)))
	(make-local-variable 'tags-find-point)
	(dolist (text '("Minor Mode Bindings:"
					"Local Bindings:"
					"Global Bindings:"))
	  (when (scan-buffer (concat text "\nkey +binding\n[- ]+") :regexp t)
		(apply 'set-text-attribute
			   (match-beginning 0) (match-end 0) nil
			   *describe-bindings-category-attribute*))
	  (goto-char 0))
	(while (scan-buffer "Prefix Command" :no-dup t)
	  (apply 'set-text-attribute
			 (match-beginning 0) (match-end 0) nil
			 *describe-bindings-prefix-command-attribute*))
	(goto-char 0)
	(make-local-variable 'buffer-read-only)
	(setf buffer-read-only t)
	(run-hooks '*describe-bindings-mode-hook*)))

(defun describe-bindings-mode-get-ref (str)
  (or (when (modulep "info-modoki-mode")
		(let (res)
		  (save-excursion
			(user::imm-erase-buffer user::*imm-buffer-refer*)
			(user::imm-load)
			(cond ((gethash str *describe-bindings-cash*))
				  ((scan-buffer (compile-regexp (concat "^��" (regexp-quote str) "[ \t]*$")))
				   (scan-buffer "[description]: ")
				   (next-line)
				   (setf res (buffer-substring
							  (point)
							  (progn (goto-eol) (point))))
				   (setf (gethash str *describe-bindings-cash*) res)
				   res)))))
	  ""))

;;; describe-bindings-mode ends here