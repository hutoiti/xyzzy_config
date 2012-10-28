;;; -*- mode: lisp; package: drive-info.ffi -*-
;;;
;;; File: drive-info/ffi/macros.l
;;;
;;; License:
;;;
;;;   Copyright (c) 2007 MIYAMUKO Katsuyuki.
;;;
;;;   drive-info is released under an MIT license.
;;;   See drive-info/docs/MIT-LICENSE for full license.
;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "drive-info/ffi/package")
  )

(in-package :drive-info.ffi)

(defmacro make-c-type-accessor (type)
  (let ((make (intern (format nil "make-~A-chunk" type)))
        (unpack (intern (format nil "unpack-~A" type))))
    `(progn
       (defun ,make ()
         (si:make-chunk nil ,(c::ctypedef-size (c::expand-c-type type))))
       (defun ,unpack (chunk)
         (,(c::ctypedef-accessor (c::expand-c-type type)) chunk 0))
       (export '(,make ,unpack)))))


(provide "drive-info/ffi/macros")

;;; End
