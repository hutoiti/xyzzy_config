;;;; -*- mode: lisp; package: hatena-haiku.ui -*-
;;;;
;;;; File: hatena-haiku-mode/ui/pager.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;;;
;;;;   hatena-haiku-mode is released under an MIT license.
;;;;   See hatena-haiku-mode/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "hatena-haiku-mode/ui/package")
  )

(in-package :hatena-haiku.ui)

(defun init-pager-local-variable (buffer &key (page nil) (next-page-p t))
  (with-temporary-set-buffer (buffer)
    (make-lv '@haiku-current-page page)
    (make-lv '@haiku-next-page-p next-page-p)
    ))

(defun reset-pager-local-variable (buffer &key (page nil) (next-page-p t))
  (set-haiku-current-page page)
  (set-haiku-next-page next-page-p))

(defun haiku-current-page (&optional (buffer (selected-buffer)))
  (lv '@haiku-current-page buffer))

(defun set-haiku-current-page (page &optional (buffer (selected-buffer)))
  (set-lv '@haiku-current-page page buffer))

(defun haiku-next-page-p (&optional (buffer (selected-buffer)))
  (lv '@haiku-next-page-p))

(defun set-haiku-next-page (t/nil &optional (buffer (selected-buffer)))
  (set-lv '@haiku-next-page-p t/nil))

(defun haiku-next-page (&optional (buffer (selected-buffer)))
  (1+ (or (haiku-current-page) 0)))


(provide "hatena-haiku-mode/ui/pager")

;;;; End
