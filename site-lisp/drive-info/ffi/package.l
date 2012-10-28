;;; -*- mode: lisp; package: user -*-
;;;
;;; File: drive-info/ffi/package.l
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
  (require "foreign")
  (require "wip/winapi")

  (unless (find-package :drive-info.ffi)
    (defpackage :drive-info.ffi
      (:use
       :lisp :foreign
       )
      (:import-from :winapi
       BOOL
       LONG
       DWORD
       LPCSTR
       )
      )))


(provide "drive-info/ffi/package")

;;; End
