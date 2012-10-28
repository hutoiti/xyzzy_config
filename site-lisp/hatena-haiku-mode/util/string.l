;;;; -*- mode: lisp; package: hatena-haiku.util -*-
;;;;
;;;; File: hatena-haiku-mode/util/string.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008-2009 MIYAMUKO Katsuyuki.
;;;;
;;;;   hatena-haiku-mode is released under an MIT license.
;;;;   See hatena-haiku-mode/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "hatena-haiku-mode/util/package")
  )

(in-package :hatena-haiku.util)

(export '(gsub
          ))

(defmacro gsub ((str re) &body body)
  `(call-gsub ,str ,re #'(lambda () ,@body)))
(setf (get 'gsub 'ed:lisp-indent-hook) 1)

(defun call-gsub (str re fn)
  (when (and re str)
    (let ((result)
          (start 0))
      (while (string-match re str start)
        (let ((b (match-beginning 0))
              (e (match-end 0)))
          (push (substring str start b) result)
          (push (funcall fn) result)
          (setf start e)))
      (push (substring str start) result)
      (format nil "~{~A~}" (reverse result)))))


(provide "hatena-haiku-mode/util/string")

;;;; End
