;;;; -*- mode: lisp; package: hatena-haiku.util -*-
;;;;
;;;; File: hatena-haiku-mode/util/sequence.l
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

(export '(append1
          compact
          subseq-if
          subseq-before
          take-if
          $
          subalist
          mapalist
          hash-to-alist
          ))

(defun append1 (lst item)
  (if item
      (append lst (list item))
    lst))

(defun compact (lst)
  (remove-if #'null lst))

(defun subseq-if (seq start predicate &key key)
  (subseq seq 0 (position-if predicate seq :key key)))

(defun subseq-before (item seq &key key test test-not)
  (subseq seq 0 (position item seq :key key :test test :test-not test-not)))

(defun take-if (predicate sequence &key from-end start end key)
  (let ((pos (position-if predicate sequence
                          :from-end from-end
                          :start (or start 0)
                          :end end
                          :key key)))
    (if pos
        (values (subseq sequence 0 pos)
                (subseq sequence pos))
      sequence)))

(defun $ (alist props)
  (if (listp props)
      (mapcar #'(lambda (prop)
                  ($ alist prop))
              props)
    (cdr (assoc props alist :test #'equal))))

(defun subalist (alist items &key test test-not key)
  (mapcar #'(lambda (item)
              (cons item (cdr (assoc item alist
                                     :test test
                                     :test-not test-not
                                     :key key))))
          items))

(defun mapalist (fn alist)
  (mapcar #'(lambda (pair)
              (msgbox "~S" pair)
              (funcall fn (car pair) (cdr pair)))
          alist))

(defun hash-to-alist (hsh)
  (let (r)
    (maphash #'(lambda (x y)
                 (push (cons x y) r))
             hsh)
    (reverse r)))


(provide "hatena-haiku-mode/util/sequence")

;;;; End
