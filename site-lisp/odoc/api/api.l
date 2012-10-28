;;; -*- Mode: Lisp -*-
;;  api:
;;; Author:        amefura <amefura@gmail.com>
;;; License:       api is released under an MIT license.
;;                 See odoc/doc/mit-license for full license.
;;; Code:
(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package :odoc-api)
	(defpackage :odoc-api
	  (:use
	   :lisp :editor)
	  ))
  (require :odoc/api/version)
  (require :odoc/api/defs)
  (require :odoc/api/config)
  (require :odoc/api/study)
  (require :odoc/api/index)
  (require :odoc/api/tag)
  (require :odoc/api/contents)
  (require :odoc/api/encode)
  (require :odoc/api/template)
  (require :odoc/api/re-study)
  (require :odoc/api/publish)
  (require :odoc/api/guid)
  (require :odoc/api/xml)
  (require :odoc/api/rss)
  (require :odoc/api/atom)
  (require :odoc/api/md5)
  )

(in-package :odoc-api)

(provide :odoc/api/api)
;;end
