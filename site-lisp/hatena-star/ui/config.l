; -*- mode: lisp; package: hatena-star.ui -*-

;;; hatena-star/ui/config.l
;;
;; Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;
;; hatena-star is released under an MIT license.
;; See hatena-star/docs/MIT-LICENSE for full license.
;;

;;; Code:

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "hatena-star/ui/package")
  )

(in-package :hatena-star.ui)

(export '(*hatena-star-default-star-color*
          *hatena-star-default-star-char*
          *hatena-star-inner-count-min*
          ))

(defvar *hatena-star-default-star-color* '(:foreground 11))
(defvar *hatena-star-default-star-char* #\š)
(defvar *hatena-star-inner-count-min* 16)


(provide "hatena-star/ui/config")

;;; End
