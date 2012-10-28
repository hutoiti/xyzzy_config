;;;; -*- mode: lisp; package: hatena-haiku.util -*-
;;;;
;;;; File: hatena-haiku-mode/util/encode.l
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

(export '(url-encode-utf8
          url-decode-utf8
          ))

(defun url-encode-utf8 (sjis)
  (si:www-url-encode (ed::map-internal-to-utf-8 sjis)))

(defun url-decode-utf8 (utf8)
  (ed::map-utf-8-to-internal (si:www-url-decode utf8)))


(provide "hatena-haiku-mode/util/encode")

;;;; End
