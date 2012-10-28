;;; -*- mode: lisp; package: user -*-
;;;
;;; File: drive-info/api/package.l
;;;
;;; License:
;;;
;;;   Copyright (c) 2007 MIYAMUKO Katsuyuki.
;;;
;;;   drive-info is released under an MIT license.
;;;   See drive-info/docs/MIT-LICENSE for full license.
;;;

(in-package :user)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "drive-info/ffi/package")

  (unless (find-package :drive-info.api)
    (defpackage :drive-info.api
      (:nicknames :drive)
      (:use
       :lisp
       :drive-info.ffi
       )
      )))


(provide "drive-info/api/package")

;;; End
