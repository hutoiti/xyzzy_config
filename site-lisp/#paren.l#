;;; paren.l -*- Mode: Lisp; Package: EDITOR -*-

;; Last updated: <2001/03/20 01:54:32 +0900>

;; Copyright (C) 1999-2001 Junichiro KITA <kita@a1.mbn.or.jp>

;; Author: Junichiro KITA <kita@a1.mbn.or.jp>

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or (at
;; your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; usage:
;;
;; (require 'paren)
;; (turn-on-paren)

;;; Code:

(provide "paren")

(in-package "editor")

(export '(*paren-highlight-only-paren*
	  *paren-attribute* *paren-paren-attribute* *paren-invalid-attribute*
	  *paren-show-not-visible-matched-paren*
	  toggle-paren turn-on-paren turn-off-paren turn-on-global-paren))

(defvar-local *paren-status* nil
  "If non-nil, paren-highlighting is activated.")

(defvar-local *paren-highlight-only-paren* nil
  "* If non-nil, highlight only paren.")

(defvar-local *paren-attribute* '(:bold t)
  "Attribute for body.")

(defvar-local *paren-paren-attribute* *paren-attribute*
  "Attribute for paren.")

(defvar-local *paren-invalid-attribute* '(:bold t :background 1)
  "Attribute for invalid paren.")

(defvar-local *paren-show-not-visible-matched-paren* t
  "* If non-nil, show line containing the matched paren.")

(defvar *paren-tag* 'paren)

(defun paren-highlight ()
  (delete-text-attributes *paren-tag*)
  (when *paren-status*
    (cond ((syntax-close-p (preceding-char))
	   (do-paren-highlight 'close))
	  ((syntax-open-p (following-char))
	   (do-paren-highlight 'open)))))

(defun do-paren-highlight (state)
  (let ((goal-column (goal-column)) from to attrib)
    (save-excursion
      (setq from (point))
      (and (eq state 'close)
	   (backward-char 1))
      (if (goto-matched-parenthesis)
	  ;; found
	  (progn
	    (and (eq state 'open)
		 (forward-char 1))
	    (setq to (point))
	    ;; show invisible paren
	    (and *paren-show-not-visible-matched-paren*
		 (pos-not-visible-in-window-p (point))
		 (let ((bol (progn (goto-virtual-bol) (point))))
		   (message "~A" (buffer-substring bol
						   (min (+ bol 100)
							(progn
							  (goto-virtual-eol)
							  (point)))))))
	    (unless *paren-highlight-only-paren*
	      ;; highlight body between paren
	      (apply #'set-text-attribute from to *paren-tag* *paren-attribute*))
	    (when (> from to)
	      (psetq from to to from))
	    (apply #'set-text-attribute from (1+ from) *paren-tag* *paren-paren-attribute*)
	    (apply #'set-text-attribute (1- to) to *paren-tag* *paren-paren-attribute*))
	;; not found
	(progn
	  (message "‘Î‰ž‚·‚éŠ‡ŒÊ‚ª‚È‚¢‚Å")
	  (if (eq state 'open)
	      (forward-char 1))
	  (setq to (point))
	  (apply #'set-text-attribute from to *paren-tag* *paren-invalid-attribute*))))
    (set-goal-column goal-column)))

(defun toggle-paren ()
  "Toggle paren status."
  (interactive)
  (setq *paren-status* (null *paren-status*)))

(defun turn-on-paren ()
  "Activate paren."
  (interactive)
  (setq *paren-status* t))

(defun turn-off-paren ()
  "Deactivate paren."
  (interactive)
  (setq *paren-status* nil))

(defun turn-on-global-paren ()
  "Globally activate paren.
Already created buffer is not affected this command."
  (interactive)
  (setq-default *paren-status* t))

(add-hook '*post-command-hook* 'paren-highlight)
