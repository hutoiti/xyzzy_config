; -*- mode: lisp; package: user -*-

;;; hatena-star/ui/package.l
;;
;; Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;
;; hatena-star is released under an MIT license.
;; See hatena-star/docs/MIT-LICENSE for full license.
;;

;;; Code:

(in-package :user)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "hatena-star/api")

  (unless (find-package :hatena-star.ui)
    (defpackage :hatena-star.ui
      (:use
       :lisp
       :editor

       :hatena-star.api
       ))))


(provide "hatena-star/ui/package")

;;; End
