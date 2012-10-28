;;;; -*- mode: lisp; package: hatena-haiku.util -*-
;;;;
;;;; File: hatena-haiku-mode/util/promises.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;;;
;;;;   hatena-haiku-mode is released under an MIT license.
;;;;   See hatena-haiku-mode/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "hatena-haiku-mode/util/package")
  )

(in-package :hatena-haiku.util)

(export '(delay
          force
          ))

(defstruct promises
  forced enclosure)

(defmacro delay (&body body)
  `(make-promises
    :forced nil
    :enclosure #'(lambda () ,@body)))

(defun force (promises)
  (cond ((not (promises-p promises))
         promises)
        ((promises-forced promises)
         (funcall (promises-enclosure promises)))
        (t
         (let ((enc (promises-enclosure promises)))
           (when (functionp enc)
             (let ((val (funcall enc)))
               (setf (promises-enclosure promises) #'(lambda () val))))
           (setf (promises-forced promises) t)
           (funcall (promises-enclosure promises))))))


(provide "hatena-haiku-mode/util/promises")

;;;; End
