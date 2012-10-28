;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; ee.l
;;;
;;; Last updated: "2006-07-27"
;;;

;;; Copyright (C) 2005-2006 Mitsuaki FUKAE
;;; All rights reserved.

;;; Redistribution and use in source and binary forms, with or without
;;; modification, are permitted provided that the following conditions
;;; are met:

;;; 1. Redistributions of source code must retain the above copyright
;;;    notice, this list of conditions and the following disclaimer.
;;;
;;; 2. Redistributions in binary form must reproduce the above copyright
;;;    notice, this list of conditions and the following disclaimer in
;;;    the documentation and/or other materials provided with the
;;;    distribution.
;;;
;;; 3. The name of the author may not be used to endorse or promote
;;;    products derived from this software without specific prior
;;;    written permission.

;;; THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
;;; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
;;; PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
;;; DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
;;; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
;;; OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
;;; HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
;;; STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
;;; ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE!
;;; POSSIBILITY OF SUCH DAMAGE.

;;;
;;; ê›íË
;;; (require "ee")
;;; (setq *ee-edict-dictionary-path* "~/edict/pdwd/")
;;; (global-set-key '(#\C-c #\g) 'ee-lookup-e2j-dictionary-selection)
;;; (add-hook '*init-app-menus-hook*
;;; 	  #'(lambda ()
;;; 	      (insert-menu-item *dictionary-popup-menu* 4 nil "âpÅX(&G)"
;;; 				'ee-lookup-e2j-dictionary-selection)))
;;; ALT+íÜÉ{É^ÉìÇ≈âpÅXÇï\é¶
;;; (global-set-key #\M-MBtnDown 'ee-edict-cursor-lookup)
;;; edict-mode Ç≈âpÅXÇï\é¶
;;; (define-key ed::*edict-mode-map* #\MouseMove 'ee-edict-mouse-lookup)
;;; (define-key ed::*edict-mode-map* #\C-MouseMove 'ee-edict-mouse-lookup-conjugation)
;;;

;;;
;;; This code is based on edict.l which is part of xyzzy.
;;;

(provide "ee")

(require "edict")

(in-package "editor")

(export '(*ee-edict-dictionary-path*
	  ee-lookup-e2j-dictionary-selection
	  ee-edict-mouse-lookup ee-edict-mouse-lookup-conjugation
	  ee-edict-cursor-lookup ee-edict-cursor-lookup-conjugation))

(defvar *ee-edict-dictionary-path* "~/edict/pdwd/")

(defvar *ee-fill-column* 75)
(defvar *ee-popup-fill-column* 75)

(defun ee-lookup-e2j-dictionary-selection ()
  (interactive)
  (edict-lookup-selection #'ee-lookup-e2j-dictionary))

(defun ee-lookup-e2j-dictionary (from to)
  (interactive "r")
  (ee-edict-analogize-conjugation from to))

(defun ee-edict-analogize-conjugation (from to)
  (long-operation
    (let ((string (buffer-substring from to))
	  (rl nil))
      (when (setq r (ee-lookup-dictionary string))
	(push (cons string r) rl))
      (setq rl (ee-edict-analogize-conjugation-1 string rl))
      (unless rl
	(plain-error "ìoò^Ç≥ÇÍÇƒÇ¢Ç‹ÇπÇÒ: ~A" string))
      (let ((buffer (selected-buffer)))
	(with-output-to-temp-buffer ("*dictionary*" t)
	  (dolist (x (nreverse rl))
	    (format t "~A:~%~%  ~{~A~^~%  ~}~%~%" (car x) (cdr x))))
	(set-buffer "*dictionary*")
	(fill-region (point-min) (point-max))
	(goto-char (point-min))
	(pop-to-buffer buffer)))
    t))

(defun ee-edict-analogize-conjugation-1 (string rl)
  (mapc #'(lambda (x)
	    (when (string-matchp (car x) string)
	      (let* ((s (string-replace-match string (cdr x)))
		     (r (ee-lookup-dictionary s)))
		(when r
		  (push (cons s r) rl)))))
	*edict-conjugation-regexp*)
  rl)

(defun ee-lookup-dictionary (str)
  (let ((rl (lookup-dictionary *ee-edict-dictionary-path*
			       "xyzzydic" "xyzzye2j" str))
	list)
    (when (and rl (kanji-char-p (character (substring (car rl) 0 1))))
      (setq rl nil));edict ëŒçÙ
    (when rl
      (setq rl (ee-split-string (car rl))))))

(defun ee-split-string (str)
  (setq str (substitute-string str " \\\\ " "\n"))
  (split-string str "\n"))

(defun ee-edict-mouse-lookup (&optional conjugation)
  (interactive)
  (continue-pre-selection)
  (when edict-mode
    (with-selected-window
      (set-window *last-mouse-window*)
      (save-excursion
	(goto-last-mouse-point)
	(cond ((eolp)
	       (setq *edict-last-range-begin* nil))
	      ((and *edict-last-range-begin*
		    (<= *edict-last-range-begin* (point))
		    (< (point) *edict-last-range-end*))
	       (continue-popup))
	      (t
	       (let* ((end (progn
			     (skip-chars-forward "A-Za-z")
			     (point)))
		      (beg (progn
			     (skip-chars-backward "A-Za-z")
			     (point)))
		      s r)
		 (setq *edict-last-range-begin* beg)
		 (setq *edict-last-range-end* end)
		 (if (= beg end)
		     (return-from ee-edict-mouse-lookup nil))
		 (setq s (buffer-substring beg end))
		 (handler-case
		     (setq r (ee-lookup-dictionary s))
		   (error (e)
		     (edict-mode nil)
		     (error e)))
		 (if (or conjugation (not r))
		     (progn
		       (setq r (ee-edict-analogize-conjugation-1
				s (if r (acons s r nil) nil)))
		       (if r
			   (popup-string (with-output-to-string (so)
					   (do ((x (nreverse r) (cdr x)))
					       ((null x))
					     (format so "~A:~%~%  ~{~A~^~%  ~}~@[~%~%~]"
						     (caar x) (cdar x) (cdr x))))
					 beg)
			 (popup-string "Not found" beg)))
		   (popup-string (format nil "~A:~%~%  ~{~A~^~%  ~}" s r) beg)))))))))

(defun ee-edict-mouse-lookup-conjugation ()
  (interactive)
  (ee-edict-mouse-lookup t))

(defun ee-edict-cursor-lookup (&optional conjugation)
  (interactive)
  (let* ((end (save-excursion
		(skip-chars-forward "A-Za-z")
		(point)))
	 (beg (save-excursion
		(skip-chars-backward "A-Za-z")
		(point)))
	 s r)
    (if (= beg end)
	(return-from ee-edict-cursor-lookup nil))
    (setq s (buffer-substring beg end))
    (setq r (ee-lookup-dictionary s))
    (if (or conjugation (not r))
	(progn
	  (setq r (ee-edict-analogize-conjugation-1
		   s (if r (acons s r nil) nil)))
	  (if r
	      (popup-string (with-output-to-string (so)
			      (do ((x (nreverse r) (cdr x)))
				  ((null x))
				(format so "~A:~%~%  ~{~A~^~%  ~}~@[~%~%~]"
					(caar x) (cdar x) (cdr x))))
			    beg)
	    (popup-string "Not found" beg)))
      (popup-string (format nil "~A:~%~%  ~{~A~^~%  ~}" s r) beg))))

(defun ee-edict-cursor-lookup-conjugation ()
  (interactive)
  (ee-edict-cursor-lookup t))

;;;
