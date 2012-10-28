;;;; -*- mode: lisp; package: hatena-haiku.util -*-
;;;;
;;;; File: hatena-haiku-mode/util/buffer.l
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
  (require "hatena-haiku-mode/util/macros")
  )

(in-package :hatena-haiku.util)

(export '(lv
          safe-lv
          set-lv
          make-lv
          scan-text-attribute
          buffer-line-string
          line-point-values
          line-points
          beginning-of-line-point
          end-of-line-point
          ))


;;;; buffer local variables

(defun lv (symbol &optional (buffer (selected-buffer)))
  (buffer-local-value buffer symbol))

(defun safe-lv (symbol &optional (buffer (selected-buffer)))
  (when (local-variable-p symbol)
    (lv symbol buffer)))

(defun set-lv (symbol value &optional (buffer (selected-buffer)))
  (unless (local-variable-p symbol buffer)
    (plain-error "`~S' is not local variable!" symbol))
  (with-temporary-set-buffer (buffer)
    (setf (symbol-value symbol) value)))

(defun make-lv (symbol value &optional (buffer (selected-buffer)))
  (with-temporary-set-buffer (buffer)
    (make-local-variable symbol)
    (setf (symbol-value symbol) value)))


;;;; text attributes

(defun scan-text-attribute (tag &key (test #'eql) (key #'identity) no-dup limit tail reverse)
  (funcall (if reverse
               'scan-text-attribute-backward
             'scan-text-attribute-forward)
           tag limit test key no-dup tail))

(defun scan-text-attribute-forward (tag limit test key no-dup tail)
  (let ((start (point)))
    (goto-text-attribute tag
                         #'(lambda (from to)
                             (if no-dup
                                 (< start from)
                               (<= start to)))
                         (list-text-attributes (- start 1000) limit)
                         test key tail)))

(defun scan-text-attribute-backward (tag limit test key no-dup tail)
  (let ((end (point)))
    (goto-text-attribute tag
                         #'(lambda (from to)
                             (if no-dup
                                 (< to end)
                               (<= from end)))
                         (reverse (list-text-attributes limit (+ end 1000)))
                         test key tail)))

(defun goto-text-attribute (tag pointer attrs test key tail)
  (let ((r (find-text-attr tag pointer attrs test key)))
    (when r
      (goto-char (if tail (cadr r) (car r)))
      (values-list r))))

(defun find-text-attr (tag pointer attrs test key)
  (find-if #'(lambda (attr)
               (multiple-value-bind (from to found-tag)
                   (values-list attr)
                 (and
                  (funcall test (funcall key found-tag) tag)
                  (funcall pointer from to))))
           attrs))


;;;; points

(defun buffer-line-string (&optional (pt (point)))
  (apply 'buffer-substring (line-points pt)))

(defun line-point-values (&optional (pt (point)))
  (values-list (line-points pt)))

(defun line-points (&optional (pt (point)))
  (save-excursion
    (goto-char pt)
    (list (progn (goto-bol) (point))
          (progn (goto-eol) (point)))))

(defun beginning-of-line-point (&optional (pt (point)))
  (car (line-points pt)))

(defun end-of-line-point (&optional (pt (point)))
  (cadr (line-points pt)))


(provide "hatena-haiku-mode/util/buffer")

;;;; End
