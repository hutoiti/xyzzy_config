; -*- mode: lisp; package: hatena-star.ui -*-

;;; hatena-star/ui/formatter.l
;;
;; Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;
;; hatena-star is released under an MIT license.
;; See hatena-star/docs/MIT-LICENSE for full license.
;;

;;; Code:

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "hatena-star/ui/package")
  (require "hatena-star/ui/config")
  )

(in-package :hatena-star.ui)

(export '(hatena-star-stars-insert
          hatena-star-stars-to-string
          hatena-star-make-stars-string
          ))

(defun hatena-star-stars-insert (entry-or-stars
                                 &key tag
                                 (star-char *hatena-star-default-star-char*)
                                 (color *hatena-star-default-star-color*))
  (let ((from (point)))
    (insert (hatena-star-stars-to-string entry-or-stars :star-char star-char))
    (when (or tag color)
      (apply 'set-text-attribute from (point) tag color))))

(defun hatena-star-stars-to-string (entry-or-stars &key star-char)
  (let ((star-char (or star-char *hatena-star-default-star-char*))
        (n (hatena-star-stars-count entry-or-stars)))
    (check-type star-char character)
    (if (or (hatena-star-stars-inner-count-p entry-or-stars)
            (<= *hatena-star-inner-count-min* n))
        (multiple-value-bind (first count last)
            (hatena-star-stars-inner-count-values entry-or-stars)
          (format nil "~A~D~A"
                  (if first star-char "")
                  count
                  (if last star-char "")))
      (make-star n star-char))))

(defun hatena-star-make-stars-string (count &key star-char inner (inner-min *hatena-star-inner-count-min*))
  (let ((star-char (or star-char *hatena-star-default-star-char*)))
    (check-type star-char character)
    (if (and (< 2 count) (or inner (<= inner-min count)))
        (format nil "~A~D~A" star-char (- count 2) star-char)
      (make-star count star-char))))

(defun make-star (count star-char)
  (make-sequence 'string count :initial-element star-char))


(provide "hatena-star/ui/formatter")

;;; End
