;;; -*- mode:lisp; package:anything.source.function -*-

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "anything/anything"))

(defpackage :anything.source.function
  (:use :lisp :editor :anything))

(in-package :anything.source.function)

(defvar *summary* nil)

(defun get-summary ()
  (save-excursion
    (set-buffer #0=anything::*anything-executed-buffer*)
    (when (and (boundp '#1=ed::build-summary-function)
#1#)
      (let ((fns (funcall #1#)))
(setq *summary* (list :buffer #0# :functions fns))
(mapcar #'cadr fns)))))

(defun function-lineno (funcname)
  (car (find funcname (getf *summary* :functions)
:test #'string= :key #'cadr)))

(defun show-function (funcname)
  (let ((p (function-lineno funcname)))
    (when p
      (with-selected-window
	(other-window)
	(when (minibuffer-window-p (selected-window))
	  (other-window))
	(set-buffer anything::*anything-executed-buffer*)
	(delete-text-attributes #0='anything-function-name)
	(goto-line p)
	(apply #'set-text-attribute (point) (and (goto-eol) (1+ (point))) #0#
	       :extend t *anything-select-color*)
	(recenter)))))

(defun remove-highlight ()
  (let ((buf (getf *summary* :buffer)))
    (when buf
      (save-excursion
(set-buffer buf)
(delete-text-attributes 'anything-function-name)))))

(add-hook '*anything-close-hook*
(lambda ()
(when *summary*
(remove-highlight)
(setq *summary* nil))))


(add-anything-sources
 :name "functions"
 :candidates get-summary
 :move-action show-function
 :action (lambda (f) (goto-line (function-lineno f))))


;; functions �P�Ǝg�p�R�}���h
(defun anything::anything-list-functions ()
  (interactive)
  (let ((src #0=(gethash "functions" #1=anything::*anything-sources*))
(#1# (make-hash-table :test 'equal)))
    (setf #0# src)
    (anything:anything)))

(global-set-key '(#\C-q) 'anything::anything-list-functions)