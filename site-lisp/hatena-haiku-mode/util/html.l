;;;; -*- mode: lisp; package: hatena-haiku.util -*-
;;;;
;;;; File: hatena-haiku-mode/util/html.l
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
  (require "hatena-haiku-mode/util/string")
  )

(in-package :hatena-haiku.util)

(export '(html-unescape
          html-remove-tag
          ))

(defvar *html-special-chars-alist*
  '(("&nbsp;" . " ")
    ("&lt;" . "<")
    ("&gt;" . ">")
    ("&quot;" . "\"")
    ("&amp;" . "&")))

(defun html-remove-tag (str)
  (substitute-string str "<[^<>]+>" ""))

(defun html-unescape (html)
  (gsub (html "&[a-zA-Z]+;")
    (let ((m (string-downcase (match-string 0))))
      (or (cdr (assoc m *html-special-chars-alist* :test #'string=))
          m))))


(provide "hatena-haiku-mode/util/html")

;;;; End
