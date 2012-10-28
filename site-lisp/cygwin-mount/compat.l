;;;; -*- mode: lisp; package: editor -*-
;;;;
;;;; File: cygwin-mount/compat.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2005,2008 MIYAMUKO Katsuyuki.
;;;;
;;;;   cygwin-mount is released under an MIT license.
;;;;   See cygwin-mount/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "cygwin-mount/resolver")
  )

(in-package :editor)

;; cygwin-mount 0.1 ŒÝŠ·‘w

(export '(cygwin-mount-resolve
          ))

(defun cygwin-mount-resolve (cygpath)
  (cygwin-mount:cygmount-cygpath->winpath cygpath))

(defun cygwin-mount-table ()
  (mapcar #'(lambda (mount)
              (cons (cygwin-mount:cygmount-point-cygpath mount)
                    (cygwin-mount:cygmount-point-winpath mount)))
          (cygwin-mount:cygmount-point-info)))

(defun cygwin-mount-cygdrive-prefix ()
  (cygwin-mount:cygdrive-prefix))


(provide "cygwin-mount/compat")

;;; End
