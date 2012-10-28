;;; -*- Mode: Lisp -*-
;;  setup:
;;; Author:        amefura <amefura@gmail.com>
;;; License:       setup is released under an MIT license.
;;                 See odoc/doc/mit-license for full license.
;;; Code:
(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package :odoc)
	(defpackage :odoc
	  (:use
	   :lisp :editor)
	  )))

(require :odoc/api/api)
(require :odoc/mode/mode)

(in-package :odoc)
(use-package :odoc-api)
(use-package :odoc-mode)

(export
 '(odoc-index
   odoc-publish
   odoc-mode
   odoc-config-mode
   *odoc-publish-hook*
   *odoc-mode-hook*
   *odoc-extension*
   *odoc-config-file*
   *odoc-wikiname-color*
   ))

(defun odoc-index()
  (interactive)(call-interactively 'index))

(defun odoc-publish()
  (interactive)(call-interactively 'publish))

; default mode extintion [od .odocrc]
(pushnew `(,(concat "\\." *odoc-extension* "$") .
		   odoc-mode)
		 *auto-mode-alist* :test 'equal)

(pushnew `(,(concat(regexp-quote *odoc-config-file*)"$") .
		   odoc-config-mode)
		 *auto-mode-alist* :test 'equal)

(in-package :user)

(use-package :odoc)

(provide :odoc/setup)
