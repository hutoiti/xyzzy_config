;;; -*- mode: lisp; package: layered-window.api -*-
;;;
;;; File: drive-info/api/version.l
;;;
;;; License:
;;;
;;;   Copyright (c) 2007 MIYAMUKO Katsuyuki.
;;;
;;;   drive-info is released under an MIT license.
;;;   See drive-info/docs/MIT-LICENSE for full license.
;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "drive-info/api/package")
  (require "drive-info/ffi"))

(in-package :drive-info.api)

(export '(drive-info-version
          drive-info-api-version
          ))

(defconstant *drive-info-version* "1.1.0")
(defconstant *drive-info-api-version* 1)

(defun drive-info-version ()
  *drive-info-version*)

(defun drive-info-api-version ()
  *drive-info-api-version*)


(provide "drive-info/api/version")

;;; End
