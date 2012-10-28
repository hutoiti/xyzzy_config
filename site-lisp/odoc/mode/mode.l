;;; -*- Mode: Lisp -*-
;;  mode: 
;;; Author:        amefura <amefura@gmail.com>
;;; License:       mode is released under an MIT license.
;;                 See odoc/doc/mit-license for full license.
;;; Code:
(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package :odoc-mode)
    (defpackage :odoc-mode
      (:use
       :lisp :editor :user :odoc-api)
      ))
  (require :odoc/mode/config)
  (require :odoc/mode/ro)
  (require :odoc/mode/index)
  (require :odoc/mode/odoc)
  (require :odoc/mode/action)
  )

(provide :odoc/mode/mode)
;;end
