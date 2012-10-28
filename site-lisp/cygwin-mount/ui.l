;;;; -*- mode: lisp; package: editor -*-
;;;;
;;;; File: cygwin-mount/ui.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;;;
;;;;   cygwin-mount is released under an MIT license.
;;;;   See cygwin-mount/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "cygwin-mount/package")
  )

(in-package :editor)

(export '(cygwin-mount-show-mount-point
          ))

(defun cygwin-mount-show-mount-point ()
  (interactive)
  (flet ((show (table)
           (dolist (mount (cygwin-mount::sort-by-winpath table))
             (format t "~A on ~A type ~A (~{~A~^,~})~%"
                     (cygwin-mount:cygmount-point-winpath mount)
                     (cygwin-mount:cygmount-point-cygpath mount)
                     (cygwin-mount:cygmount-point-type mount)
                     (cygwin-mount:cygmount-point-flags mount)
                     ))))
    (let ((b (get-buffer-create "*cygwin mount*")))
      (setup-temp-buffer b)
      (erase-buffer b)
      (with-output-to-buffer (b)
        (show (cygwin-mount:cygmount-point-info)))
      (pop-to-buffer b -20))))


(provide "cygwin-mount/ui")

;;; End
