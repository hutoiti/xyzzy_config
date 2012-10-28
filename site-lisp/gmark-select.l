;;; -*- mode: lisp -*-
;;; name:     gmark-select
;;; version:  2007.02.22
;;; author:   shiro
;;; category: Utilities
;;; src:      http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fgmark-select&openfile=
;;; changes:  gmark-select-search-forwardで次のバッファも探すようにした
;;; files:    site-lisp/gmark-select.l
;;;           site-lisp/gmark-select.lc
;;;           site-lisp/ni-autoload/silog/gmark-select.l

;; Copyright (C) 1996-2005 Tetsuya Kamei
;; Copyright (C) 2006-2007 shiro
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
;; 画面を分割してグローバルマークを選び、ジャンプしたり削除したりできます。

;; 設定:
;; 
;; ;; ni-autoloadしてる人は不要
;; (export '(ed::gmark-select
;;           ed::gmark-select-set
;;           ed::gmark-select-search-forward
;;           ed::gmark-select-search-backward) "ed")
;; (autoload 'gmark-select-set "gmark-select" t nil)
;; (autoload 'gmark-select "gmark-select" t nil)
;; (autoload 'gmark-select-search-backward "gmark-select" t nil)
;; (autoload 'gmark-select-search-forward "gmark-select" t nil)
;; 
;; ;; お好みで
;; (define-key ctl-x-map #\C-g 'gmark-select)
;; (define-key ctl-x-map #\NUL 'gmark-select-set)
;; (global-set-key #\C-Down 'gmark-select-search-forward)
;; (global-set-key #\C-Up 'gmark-select-search-backward)

;; キーバインド:
;; 
;; q   抜ける
;; C-g 抜ける
;; d   現在行のglobal-markを削除
;; SPC 反対側の窓に表示
;; TAB 反対側の窓に表示
;; RET ジャンプ(SPC + q)

;; 履歴:
;; 
;; 2007.02.22
;; - gmark-select-search-forwardで次のバッファも探すようにした
;; 
;; 2007.02.19
;; - 初版

;;; Code:

(provide "gmark-select")

(require "gmark")

(in-package "editor")

;;; top bottom left right
(defvar *gmark-select-window-position* "bottom"
  "Position of *gmark-select* buffer.")

(defvar *gmark-select-window-height* 15
  "Height or width of *gmark-select* buffer.")
(defvar *gmark-select-attribute-buffer-name1* '(:foreground 1)
  "Attribute for same buffer name in *gmark-select* buffer.")
(defvar *gmark-select-attribute-buffer-name2* '(:foreground 2)
  "Attribute for other buffer name in *gmark-select* buffer.")
(defvar *gmark-select-attribute-line-number* '(:foreground 3)
  "Attribute for line number in *gmark-select* buffer.")
(defvar *gmark-select-attribute-text* '(:foreground 4)
  "Attribute for text in *gmark-select* buffer.")
(defvar *gmark-select-mark-attribute* '(:background 13 :prefix #\*)
  "Attribute for gmark in marked buffer.")

(defvar *gmark-select-mode-map* nil)
(defvar *gmark-select-winconf* nil)
(defvar *gmark-select-buffer-name* " *gmark select*")

(defvar *gmark-select-next-buffer-use-olt2* nil)

(unless *gmark-select-mode-map*
  (setq *gmark-select-mode-map* (make-sparse-keymap))
  (define-key *gmark-select-mode-map* #\q   'gmark-select-exit)
  (define-key *gmark-select-mode-map* #\d   'gmark-select-delete)
  (define-key *gmark-select-mode-map* #\C-g 'gmark-select-exit)
  (define-key *gmark-select-mode-map* #\SPC 'gmark-select-jump)
  (define-key *gmark-select-mode-map* #\TAB 'gmark-select-jump)
  (define-key *gmark-select-mode-map* #\RET 'gmark-select-jump-and-exit)
  )

(defun gmark-select-get-buffer-and-line ()
  (save-excursion
	(goto-bol)
	(multiple-value-bind (from to tag)
		(find-text-attribute 'buffer :start (point) :key 'first)
	  (values (second tag)
			  (and from to (buffer-substring from to))
			  (multiple-value-bind (from to)
				  (find-text-attribute 'line :start (point))
				(and from to (parse-integer (buffer-substring from to))))))))

(defun gmark-select-delete ()
  "delete gmark"
  (interactive)
  (multiple-value-bind (marker buffer line)
	  (gmark-select-get-buffer-and-line)
	(when marker
	  (save-excursion
		(set-buffer (marker-buffer marker))
		(goto-marker marker)
		(delete-text-attributes-if #'(lambda (x)
									   (and (consp x)
											(equal (first x) 'gmark)
											(equal (second x) marker)))))
	  (setf *global-mark-list* (delete marker *global-mark-list* :test #'eq))
	  (delete-marker marker)
	  (setf buffer-read-only nil)
	  (delete-region (progn (goto-bol) (point))
					 (progn (goto-eol) (forward-char) (point)))
	  (setf buffer-read-only t))))

(defun gmark-select-jump ()
  "jump gmark in other side window"
  (interactive)
  (multiple-value-bind (marker buffer line)
	  (gmark-select-get-buffer-and-line)
	(when marker
	  (other-window)
	  (global-mark-goto marker)
	  (set-mark)
	  (recenter)
	  (other-window))))

(defun gmark-select-jump-and-exit ()
  "jump gmark and exit gmark-select-mode"
  (interactive)
  (multiple-value-bind (marker buffer line)
	  (gmark-select-get-buffer-and-line)
	(when marker
	  (gmark-select-exit)
	  (global-mark-goto marker)
	  (recenter))))

(defun gmark-select-exit ()
  "exit gmark-select-mode"
  (interactive)
  (delete-buffer (selected-buffer))
  (set-window-configuration *gmark-select-winconf*)
  (setf *gmark-select-winconf* nil)
  t)

(defun gmark-select ()
  "Display *gmark-select* buffer with split window to select gmark."
  (interactive)
  (unless *global-mark-list*
	(unless *executing-macro*
	  (message "there are no gmarks."))
	(return-from gmark-select))
  (unless (equal (buffer-name (selected-buffer)) *gmark-select-buffer-name*)
	(let ((position *gmark-select-window-position*)
		  (height *gmark-select-window-height*)
		  (buffer (get-buffer-create *gmark-select-buffer-name*))
		  (markers0 (global-mark-make-list))
		  (name (buffer-name (selected-buffer)))
		  markers1 markers2 max-file-name-length)
	  (setf *gmark-select-winconf* (current-window-configuration)
			max-file-name-length
			(apply 'max (mapcar #'(lambda (x)
									(length (buffer-name (second x))))
								markers0)))
	  (dolist (x markers0)
		(if (equal name (buffer-name (second x)))
			(push x markers1)
		  (push x markers2)))
	  (setf markers1 (sort markers1 #'<
						   :key #'(lambda (x) (marker-point (first x))))
			markers2 (sort markers2 #'string<
						   :key #'(lambda (x) (buffer-name (second x)))))
	  (when (/= 1 (count-windows))
		(delete-other-windows))
	  (cond ((equal position "bottom")
			 (split-window (when (numberp height)
							 (- 0 height)) nil))
			((equal position "top")
			 (split-window height nil))
			((equal position "right")
			 (split-window (when (numberp height)
							 (- 0 height)) t))
			((equal position "left")
			 (split-window height t)))
	  (with-output-to-buffer (buffer)
		(dolist (markers (list markers1 markers2))
		  (dolist (x markers)
			(format t (format nil "<~~A>:~~~DT~~D~~~DT~~A~~%"
							  (+ 5 max-file-name-length)
							  (+ 11 max-file-name-length))
					(buffer-name (second x)) (third x) (fourth x)))))
	  (set-buffer buffer)
	  (goto-char (point-min))
	  (let ((lst (append markers1 markers2))
			tmp)
		(while (not (eobp))
		  (setf tmp (pop lst))
		  (if (equal (buffer-name (second tmp)) name)
			  (when (scan-buffer "<\\(.*?\\)>" :regexp t :tail t)
				(apply 'set-text-attribute (match-beginning 1) (match-end 1)
					   (list 'buffer (first tmp)) *gmark-select-attribute-buffer-name1*))
			(when (scan-buffer "<\\(.*?\\)>" :regexp t :tail t)
			  (apply 'set-text-attribute (match-beginning 1) (match-end 1)
					 (list 'buffer (first tmp)) *gmark-select-attribute-buffer-name2*)))
		  (when (scan-buffer "[0-9]+" :regexp t :tail t)
			(apply 'set-text-attribute (match-beginning 0) (match-end 0)
				   'line *gmark-select-attribute-line-number*))
		  (when (scan-buffer ".+$" :regexp t :tail t)
			(apply 'set-text-attribute (match-beginning 0) (match-end 0)
				   'text *gmark-select-attribute-text*))
		  (goto-eol)
		  (forward-char)))
	  (goto-char (point-min))
	  (make-local-variable 'buffer-read-only)
	  (setf buffer-read-only t)
	  (use-keymap *gmark-select-mode-map*))))

(defun gmark-select-restore-attribute ()
  (save-excursion
	(dolist (buf (buffer-list))
	  (set-buffer buf)
	  (when *gmark-select-mark-attribute*
		(save-excursion
		  (delete-text-attributes-if
		   #'(lambda (x)
			   (and (consp x)
					(equal 'gmark (first x)))))
		  (dolist (marker *global-mark-list*)
			(when (equal buf (marker-buffer marker))
			  (goto-marker marker)
			  (goto-bol)
			  (apply 'set-text-attribute
					 (point) (point)
					 (list 'gmark marker)
					 *gmark-select-mark-attribute*))))))))
(defun gmark-select-set-restore-gmark-attribute ()
  (when (modulep "gmark-session")
	(add-hook (intern "*after-session-load-hook*" "ed")
			  'gmark-select-restore-attribute)))
(defun gmark-select-set-restore-gmark-attribute-in-history-hook ()
  (when (modulep "gmark-session")
	(add-hook (intern "*after-session-load-hook*" "ed")
			  'gmark-select-restore-attribute)))
(cond ((modulep "startup")
	   (gmark-select-restore-attribute)
	   (gmark-select-set-restore-gmark-attribute))
	  (t
	   (add-hook '*pre-startup-hook* 'gmark-select-restore-attribute)
	   (add-hook '*pre-startup-hook* 'gmark-select-set-restore-gmark-attribute)
	   ))

(defun gmark-select-set ()
  "Set gmark at beginning of current line."
  (interactive)
  (let ((x (car *global-mark-list*))
		marker)
	(unless (and x
				 (eq (marker-buffer x) (selected-buffer))
				 (eql (marker-point x) (point)))
	  (setf marker (set-marker (make-marker)))
	  (push marker *global-mark-list*)
	  (setq *last-global-mark* nil)
	  (let ((exceed (- (length *global-mark-list*) *global-mark-max*)))
		(when (> exceed 0)
		  (setq *global-mark-list* (nbutlast *global-mark-list* exceed))))
	  (when *gmark-select-mark-attribute*
		(save-excursion
		  (save-restriction
			(widen)
			(goto-bol)
			(apply 'set-text-attribute
				   (point) (point)
				   (list 'gmark marker)
				   *gmark-select-mark-attribute*))))
	  (unless *executing-macro*
		(message "set gmark."))))
  t)

(defun gmark-select-olt2-p ()
  (and *gmark-select-next-buffer-use-olt2*
	   (modulep "outline-tree/outline-tree")
	   (eval (intern "*outline-tree-use*" "outline-tree2"))))

(defun gmark-select-next-buffer (&optional reverse)
  (cond ((gmark-select-olt2-p)
		 (if reverse
			 (funcall (intern "outline-tree-previous-buffer" "outline-tree2"))
		   (funcall (intern "outline-tree-next-buffer" "outline-tree2"))))
		(t
		 (if reverse
			 (previous-buffer)
		   (next-buffer)))))
(defvar *gmark-allow-next-buffer* nil)
(defun gmark-select-search-forward (&optional reverse)
  "Do search gmark forward in current buffer."
  (interactive)
  (when *global-mark-list*
	(flet ((fn1 (marker)
			 (and (equal (selected-buffer) (marker-buffer marker))
				  (funcall (if reverse '> '<) (point) (marker-point marker))))
		   (fn2 (x y)
			 (if (funcall (if reverse '< '>) (marker-point x) (marker-point y)) y x)))
	  (let ((buffer (selected-buffer))
			lst marker change-buffer)
		(save-excursion
		  (setf marker (do* ((buf (selected-buffer) (selected-buffer))
							 (point (point)
									(prog1 (point)
									  (goto-char (if reverse (point-max) (point-min)))))
							 (lst (remove-if-not #'fn1 *global-mark-list*)
								  (remove-if-not #'fn1 *global-mark-list*))
							 (res (and lst (reduce #'fn2 lst))
								  (and lst (reduce #'fn2 lst))))
						   (res res)
						 (goto-char point)
						 (gmark-select-next-buffer reverse)
						 (unless change-buffer
						   (setf change-buffer t)))))
		(when marker
		  (cond ((and (equal (selected-buffer) (marker-buffer marker))
					  (equal (point) (marker-point marker)))
				 (unless *executing-macro*
				   (message "no more gmark.")))
				((or (equal (selected-buffer) (marker-buffer marker))
					 (equal *gmark-allow-next-buffer* (if reverse 'backward 'forward )))
				 (set-buffer (marker-buffer marker))
				 (goto-marker marker)
				 (setf *gmark-allow-next-buffer* nil))
				(t
				 (unless *executing-macro*
				   (minibuffer-message "No more gmark in this buffer.")
				   (sit-for 3))
				 (setf *gmark-allow-next-buffer* (if reverse 'backward 'forward ))))))))
  t)

(defun gmark-select-search-backward ()
  "Do search gmark backward in current buffer."
  (interactive)
  (gmark-select-search-forward t))


