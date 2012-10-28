;;;; -*- mode: lisp; package: hatena-star.api -*-
;;;;
;;;; File: hatena-star/api/util.l
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

(defmacro type-error (datum expected-type)
  `(error 'type-error
          :datum ,datum
          :expected-type ,expected-type))

(defun $ (alist key)
  (let ((v (cdr (assoc key alist :test #'equal))))
    (unless (equal v "")
      v)))

(defun $N (alist key)
  (let ((v ($ alist key)))
    (cond ((stringp v)
           (parse-integer v))
          (t
           v))))

(defun partition-if (predicate sequence &key start end key)
  (let ((key (or key #'identity)))
    (values-list
     (mapcar #'nreverse
             (reduce #'(lambda (acc e)
                         (if (funcall predicate (funcall key e))
                             (push e (car acc))
                           (push e (cadr acc)))
                         acc)
                     sequence
                     :start (or start 0)
                     :end end
                     :initial-value (list nil nil)
                     )))))

(defun chomp (lst)
  (nreverse (member-if-not #'null (reverse lst))))

(defun chomp! (lst)
  (let ((n (position-if-not #'null lst :from-end t)))
    (when n
      (setf (cdr (nthcdr n lst)) nil))
    lst))

(defun append1 (lst item)
  (if item
      (append lst (list item))
    lst))

(defun list-if (v)
  (if (and v (atom v))
      (list v)
    v))

(defun last1 (lst)
  (car (last lst)))

(defun seal (val)
  (when val
    (if (functionp val)
        val
      #'(lambda () val))))

(defun release (sealed-val)
  (when sealed-val
    (funcall sealed-val)))

(defmacro trace-output (fmt &rest args)
  `(when (and si:*trace-on-error*
              (buffer-stream-p *error-output*)
              (ignore-errors (buffer-stream-buffer *error-output*)))
     (stack-trace *error-output*)
     (buffer-stream-set-point *error-output* (1- (buffer-stream-point *error-output*)))
     (format *error-output* ,fmt ,@args)
     (buffer-stream-set-point *error-output* (1+ (buffer-stream-point *error-output*)))))


(provide "hatena-star/api/util")

;;;; End
