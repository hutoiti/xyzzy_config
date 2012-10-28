;;;; -*- mode: lisp; package: hatena-haiku.util -*-
;;;;
;;;; File: hatena-haiku-mode/util/whitespace.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008-2009 MIYAMUKO Katsuyuki.
;;;;
;;;;   hatena-haiku-mode is released under an MIT license.
;;;;   See hatena-haiku-mode/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "hatena-haiku-mode/util/package")
  )

(in-package :hatena-haiku.util)

(export '(+newline+
          +alt-newline+
          strip
          strip-if
          delete-extra-alt-newline-buffer
          alt-newline->newline-buffer
          newline->alt-newline-buffer
          alt-newline->newline-string
          newline->alt-newline-string
          ))

(defconstant +newline+ "\n")
(defconstant +alt-newline+ "\r")


(defun strip (str)
  (when str
    (string-trim " \t\f\n" str)))

(defun strip-if (switch str)
  (if switch (strip str) str))


(defun delete-extra-alt-newline-buffer (buffer)
  (with-temporary-set-buffer (buffer)
    (with-point-zero
     (replace-buffer (concat +alt-newline+ "+" +newline+) +newline+ :regexp t))))

(defun alt-newline->newline-buffer (buffer)
  (with-temporary-set-buffer (buffer)
    (with-point-zero
     (replace-buffer +alt-newline+ +newline+))))

(defun newline->alt-newline-buffer (buffer)
  (with-temporary-set-buffer (buffer)
    (with-point-zero
     (replace-buffer +newline+ +alt-newline+))))

(defun alt-newline->newline-string (str)
  (substitute-string str +alt-newline+ +newline+))

(defun newline->alt-newline-string (str)
  (substitute-string str +newline+ +alt-newline+))


(provide "hatena-haiku-mode/util/whitespace")

;;;; End
