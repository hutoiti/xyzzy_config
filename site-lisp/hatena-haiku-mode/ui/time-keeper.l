;;;; -*- mode: lisp; package: hatena-haiku.ui -*-
;;;;
;;;; File: hatena-haiku-mode/ui/time-keeper.l
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

(defun init-time-keeper-local-variable (buffer)
  (with-temporary-set-buffer (buffer)
    (make-lv '@haiku-last-fetch-time nil)
    ))

(defun reset-time-keeper-local-variable (buffer)
  (set-haiku-last-fetch-time nil))

(defun haiku-last-fetch-time (&optional (buffer (selected-buffer)))
  (lv '@haiku-last-fetch-time buffer))

(defun set-haiku-last-fetch-time (time &optional (buffer (selected-buffer)))
  (set-lv '@haiku-last-fetch-time time buffer))

(defmacro with-if-modified-since-last-fetch (&body body)
  (with-gensyms (since)
    `(let ((,since (or (haiku-last-fetch-time) :epoch)))
       (unwind-protect
           (with-if-modified-since (,since)
             ,@body)
         (set-haiku-last-fetch-time (get-universal-time))))))
(setf (get 'with-if-modified-since-last-fetch 'ed::lisp-indent-hook) 0)


(provide "hatena-haiku-mode/ui/time-keeper")

;;;; End
