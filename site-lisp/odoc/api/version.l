;;; -*- Mode: Lisp -*-
;;  version: 
;;; Author:        amefura <amefura@gmail.com>
;;; License:       version is released under an MIT license.
;;                 See odoc/doc/mit-license for full license.
;;; Code:

(in-package :odoc-api)

(defconstant *version* "1.0.0.3")

(defconstant *name* "ODoc")

(defun version() *version*)

(defun name() *name*)

(provide :odoc/api/version)

;;end