;;;; -*- mode: lisp; package: hatena-star.api -*-
;;;;
;;;; File: hatena-star/api/future.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;;;
;;;;   hatena-star is released under an MIT license.
;;;;   See hatena-star/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "hatena-star/api/package")
  )

(in-package :hatena-star.api)

;; hatena-star のユーザが xml-http-request を直接利用しなくても言いように
;; wrapper を提供。

(export '(hatena-star-future-p
          hatena-star-future-completed-p
          hatena-star-future-value
          ))

(defun hatena-star-future-p (future)
  (xhr-future-p future))

(defun hatena-star-future-completed-p (future)
  (xhr-future-completed-p future))

(defun hatena-star-future-value (future &rest options)
  (apply 'xhr-future-value (cons future options)))


(provide "hatena-star/api/future")

;;;; End
