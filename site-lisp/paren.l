;;; -*- mode: lisp; package: editor -*-
;;; name:     paren
;;; version:  2007.04.12
;;; author:   shiro
;;; category: Utilities
;;; src:      http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fparen&openfile=
;;; changes:  連続したエスケープの直後の括弧が強調できていなかったのを修正
;;; files:    site-lisp/paren.l
;;;           site-lisp/paren.lc
;;;           site-lisp/ni-autoload/silog/paren.l

;; Copyright (C) 1999-2001 Junichiro KITA <kita@a1.mbn.or.jp>
;; Copyright (C) 2007 shiro
;; 
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or (at
;; your option) any later version.
;; 
;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;; 
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; 概要:
;; 
;; KITAさん作のparen.lの改造版です
;; 
;; 以下変更点
;;  
;;  - ハイライトの前後で属性を保存
;;  - delete-text-attributesのタイミングの変更
;;  - エスケープされている場合は動作を行わないように
;;  - 指定されたコマンドの直後では動作を行わないように
;;  - シンタックスがタグの場合でもハイライト(設定可)
;;  - 閉じ括弧の反応する位置を1つ前にできるように(設定可)
;;  - ハイライト中でも元の属性を表示し続ける(設定可)

;; usage:
;;
;; (require 'paren)
;; (turn-on-paren)

;; 履歴:
;; 
;; 2007.04.12
;; - 連続したエスケープの直後の括弧が強調できていなかったのを修正
;; 
;; 2007.02.22
;; - 対応する括弧がない場合に属性が保存されなかったのを修正
;; - ハイライト中でも元の属性を表示し続ける設定追加
;; 
;; 2007.02.20
;; - 対応する閉じ括弧がない開き括弧上でハイライトしなかったのを修正
;; - goal-columnが保存されまくってたのを修正
;; 
;; 2007.02.19
;; - 初版

;;; Code:

(provide "paren")

(in-package "editor")

(export '(*paren-highlight-only-paren*
		  *paren-attribute*
		  *paren-paren-attribute*
		  *paren-invalid-attribute*
		  *paren-show-not-visible-matched-paren*
		  *paren-following-char*
		  *paren-tag-highlight*
		  *paren-not-highlight-command-list*
		  *paren-continue-original-attribute*
		  toggle-paren
		  turn-on-paren
		  turn-off-paren
		  turn-on-global-paren))

(defvar-local *paren-status* nil
  "If non-nil, paren-highlighting is activated.")

(defvar-local *paren-highlight-only-paren* nil
  "* If specified nil, highlight only paren.")

(defvar-local *paren-attribute* '(:bold t)
  "Attribute for body.")

(defvar-local *paren-paren-attribute* *paren-attribute*
  "Attribute for paren.")

(defvar-local *paren-invalid-attribute* '(:bold t :background 1)
  "Attribute for invalid paren.")

(defvar-local *paren-show-not-visible-matched-paren* t
  "* If non-nil, show line containing the matched paren.")

(defvar-local *paren-tag-highlight* t
  "If non-nil, highlight tag too.")

(defvar-local *paren-following-char* nil
  "If non-nil, use following char only.")

(defvar-local *paren-not-highlight-command-list* '(self-insert-command)
  "Interrupt highlight after these command.")

(defvar-local *paren-continue-original-attribute* nil)

(defvar *paren-tag* 'paren)

(defvar-local *paren-stored-text-attributes* nil)
(defvar *paren-allow-preceding-char-when-follow-char-is-not-open-parenthesis* t)

(defstruct paren-attribute-marker
  start end tag other)

(defun paren-save-position-by-marker-from-attribute (attributes)
  (let (markers)
	(dolist (attr attributes markers)
	  (let ((start (make-marker))
			(end (make-marker)))
		(set-marker start (first attr))
		(set-marker end (second attr))
		(push (make-paren-attribute-marker :start start
									 :end end
									 :tag (third attr)
									 :other (copy-list (cdddr attr))) markers)))))

(defun paren-restore-attribuet-by-marker (lst)
  (dolist (x lst)
	(apply 'set-text-attribute
		   (marker-point (paren-attribute-marker-start x))
		   (marker-point (paren-attribute-marker-end x))
		   (paren-attribute-marker-tag x)
		   (paren-attribute-marker-other x))))

(defun paren-save-text-attributes (start end)
  (setq *paren-stored-text-attributes*
		(paren-save-position-by-marker-from-attribute
		 (list-text-attributes start end))))

(defun paren-restore-text-attributes ()
  (paren-restore-attribuet-by-marker *paren-stored-text-attributes*)
  (setq *paren-stored-text-attributes* nil))

(defun paren-get-string (start)
  (goto-virtual-bol)
  (buffer-substring
   (point)
   (min (+ (point) 100)
		(progn
		  (goto-virtual-eol)
		  (point)))))

(defmacro paren-save-excursion-with-goal-column (&body body)
  (let ((g (gensym)))
	`(let ((,g (goal-column)))
	   (multiple-value-prog1
		(save-excursion
		  ,@body)
		(set-goal-column ,g)))))

(defun paren-get-range (state)
  (let ((start (point)) end str)
	(paren-save-excursion-with-goal-column
	 (when (or (and (eq state 'close)
					(not *paren-following-char*))
			   (and (eq state 'close2)
					*paren-allow-preceding-char-when-follow-char-is-not-open-parenthesis*
					(not (syntax-open-p (following-char)))))
	   (backward-char 1))
	 (when (goto-matched-parenthesis)
	   (setf end (point))
	   (when (> start end)
		 (rotatef start end))
	   (and *paren-show-not-visible-matched-paren*
			(if (eq state 'open)
				(pos-not-visible-in-window-p end)
			  (pos-not-visible-in-window-p start))
			(setf str (paren-get-string (cond ((find state '(close close2)) start)
											  ((eq state 'open)  end)))))
	   (values start end str)))))

(defun paren-highlight ()
  (when *paren-status*
	(delete-text-attributes *paren-tag*)
	(paren-restore-text-attributes)
	(when (find *this-command* *paren-not-highlight-command-list*)
	  (return-from paren-highlight))
	(let ((ch (if *paren-following-char* (following-char) (preceding-char)))
		  before before2 type)
	  (paren-save-excursion-with-goal-column
	   (cond (*paren-following-char*
			  (setf before (preceding-char))
			  (backward-char)
			  (setf before2 (preceding-char)))
			 (t
			  (backward-char)
			  (setf before (preceding-char))
			  (backward-char)
			  (setf before2 (preceding-char)))))
	  (setf type (cond ((and (or (syntax-close-p ch)
								 (and *paren-tag-highlight* (syntax-close-tag-p ch)))
							 (or (not (syntax-escape-p before))
								 (syntax-escape-p before2)))
						'close)
					   ((and (or (syntax-open-p (following-char))
								 (and *paren-tag-highlight* (syntax-open-tag-p (following-char))))
							 (or (not (syntax-escape-p (preceding-char)))
								 (syntax-escape-p (paren-save-excursion-with-goal-column
												   (backward-char)
												   (preceding-char)))))
						'open)
					   ((and *paren-allow-preceding-char-when-follow-char-is-not-open-parenthesis*
							 (syntax-close-p (preceding-char))
							 (not (syntax-open-p (following-char)))
							 (not (syntax-escape-p before)))
						'close2)))
	  (when type
		(multiple-value-bind (start end string)
			(paren-get-range type)
		  (cond ((and start end)
				 (paren-save-text-attributes start end)
				 (setf to (if (eq type 'open)
							  (1+ (point)) (point)))
				 (when (and *paren-attribute*
							(not *paren-highlight-only-paren*))
				   ;; highlight body between paren
				   (apply 'set-text-attribute start end *paren-tag* *paren-attribute*))
				 (apply 'set-text-attribute start (1+ start) *paren-tag* *paren-paren-attribute*)
				 (when (or (and (eq type 'close)
								(not *paren-following-char*))
						   (eq type 'close2))
				   (setf end (1- end)))
				 (apply 'set-text-attribute end (1+ end) *paren-tag* *paren-paren-attribute*)
				 (when *paren-continue-original-attribute*
				   (paren-restore-text-attributes))
				 ;; show invisible paren
				 (when string
				   (message "~A" string)))
				(t
				 (message "対応する括弧がないで")
				 (let ((from (point))
					   (to (point)))
				   (cond ((or (and (eq type 'close)
								   (not *paren-following-char*))
							  (eq type 'close2))
						  (setf from (1- from)))
						 ((eq type 'open)
						  (setf to (1+ to))))
				   (paren-save-text-attributes (1- from) to)
				   (apply 'set-text-attribute from to *paren-tag* *paren-invalid-attribute*)
				   (when *paren-continue-original-attribute*
					 (paren-restore-text-attributes))))))))))

(defun paren-delete-text-attributes ()
  (delete-text-attributes *paren-tag*)
  (delete-hook '*post-command-hook* 'paren-delete-text-attributes))

(defun toggle-paren (&optional (arg nil sv))
  "Toggle paren status."
  (interactive "p")
  (ed::toggle-mode '*paren-status* arg sv)
  (unless *paren-status*
	(add-hook '*post-command-hook* 'paren-delete-text-attributes)))

(defun turn-on-paren ()
  "Activate paren."
  (interactive)
  (toggle-paren t))

(defun turn-off-paren ()
  "Deactivate paren."
  (interactive)
  (toggle-paren nil))

(defun turn-on-global-paren ()
  "Globally activate paren.
Already created buffer is not affected this command."
  (interactive)
  (setq-default *paren-status* t))

(add-hook '*post-command-hook* 'paren-highlight)

;;; paren.l ends here
