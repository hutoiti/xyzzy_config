;;;; -*- mode: lisp; package: hatena-haiku.util -*-
;;;;
;;;; File: hatena-haiku-mode/util/amacros.l
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

(export '(aif
          awhen
          aunless
          _it_
          ))

(defmacro aif (test then &optional else)
  `(let ((_it_ ,test))
     (if _it_
         ,then
       ,else)))
(setf (get 'aif 'ed::lisp-indent-hook) 2)

(defmacro awhen (test &body body)
  `(let ((_it_ ,test))
     (when _it_
       ,@body)))
(setf (get 'awhen 'ed::lisp-indent-hook) 'when)

(defmacro aunless (test &body body)
  `(let ((_it_ ,test))
     (unless _it_
       ,@body)))
(setf (get 'aunless 'ed::lisp-indent-hook) 'unless)


(provide "hatena-haiku-mode/util/amacros")

;;;; End
