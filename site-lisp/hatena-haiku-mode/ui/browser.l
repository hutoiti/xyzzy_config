;;;; -*- mode: lisp; package: hatena-haiku.ui -*-
;;;;
;;;; File: hatena-haiku-mode/ui/browser.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;;;
;;;;   hatena-haiku-mode is released under an MIT license.
;;;;   See hatena-haiku-mode/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "hatena-haiku-mode/ui/package")
  )

(in-package :hatena-haiku.ui)

(defparameter *hatena-haiku-browser-command* nil)

(defun open-browser (url)
  (let ((c *hatena-haiku-browser-command*))
    (if (functionp c)
        (funcall c url)
      (shell-execute url t))))


(provide "hatena-haiku-mode/ui/browser")

;;;; End
