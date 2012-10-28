; -*- mode: lisp; package: editor -*-

;; guidgen/package.l
;;
;;   Copyright (c) 2006 MIYAMUKO Katsuyuki.
;;
;;   See guidgen/docs/MIT-LICENSE for full license.
;;

(eval-when (:compile-toplevel :load-toplevel :execute)

  #+:xyzzy
  (require "foreign")

  (unless (find-package :guidgen-ffi)
    (defpackage :guidgen-ffi
      (:use :lisp
       #+:xyzzy
       :foreign)))

  (unless (find-package :guidgen)
    (defpackage :guidgen
      (:use :lisp :guidgen-ffi)))

  (use-package :guidgen :editor)
  )


(provide "guidgen/package")

;; End
