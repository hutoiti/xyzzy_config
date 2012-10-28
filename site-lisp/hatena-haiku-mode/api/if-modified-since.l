;;;; -*- mode: lisp; package: hatena-haiku.api -*-
;;;;
;;;; File: hatena-haiku-mode/api/if-modified-since.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;;;
;;;;   hatena-haiku-mode is released under an MIT license.
;;;;   See hatena-haiku-mode/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "hatena-haiku-mode/api/package")
  )

(in-package :hatena-haiku.api)

(export '(*http-get-get-getif-modified-since*
          *http-get-if-modified-since-fix-p*
          with-current-if-modified-since
          with-if-modified-since
          with-force-if-modified-since
          with-if-modified-since-unix-epoch
          with-no-if-modified-since
          ))

(defvar *http-get-no-if-modified-since* nil)

(defparameter *http-get-if-modified-since* nil)
(defparameter *http-get-if-modified-since-fix-p* nil)


(defmacro with-current-if-modified-since (&body body)
  `(let ((*http-get-if-modified-since-fix-p* t))
     ,@body))
(setf (get 'with-current-if-modified-since 'ed::lisp-indent-hook) 0)

(defmacro with-if-modified-since ((since) &body body)
  `(progn
     (let ((*http-get-if-modified-since*
            (if *http-get-if-modified-since-fix-p*
                *http-get-if-modified-since*
              ,since)))
       (progn ,@body))))
(setf (get 'with-if-modified-since 'ed::lisp-indent-hook) 0)

(defmacro with-force-if-modified-since ((since) &body body)
  `(with-if-modified-since (,since)
     (with-current-if-modified-since
       ,@body)))
(setf (get 'with-force-if-modified-since 'ed::lisp-indent-hook) 0)

(defmacro with-if-modified-since-unix-epoch (&body body)
  `(with-force-if-modified-since (:epoch)
     ,@body))
(setf (get 'with-if-modified-since-unix-epoch 'ed::lisp-indent-hook) 0)

(defmacro with-no-if-modified-since (&body body)
  `(with-force-if-modified-since (nil)
     ,@body))
(setf (get 'with-no-if-modified-since 'ed::lisp-indent-hook) 0)


(provide "hatena-haiku-mode/api/if-modified-since")

;;;; End
