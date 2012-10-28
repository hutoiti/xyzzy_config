;;;; -*- mode: lisp; package: user -*-
;;;;
;;;; File: hatena-haiku-mode.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;;;
;;;;   hatena-haiku-mode is released under an MIT license.
;;;;   See hatena-haiku-mode/docs/MIT-LICENSE for full license.
;;;;

(in-package :user)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "hatena-haiku-mode/api")
  (require "hatena-haiku-mode/ui")
  )

(use-package :hatena-haiku.ui :user)

(provide "hatena-haiku-mode")


;;;; End
