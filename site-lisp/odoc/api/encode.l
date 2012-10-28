;;; -*- Mode: Lisp -*-
;;  encode:
;;; Author:        amefura <amefura@gmail.com>
;;; License:       encode is released under an MIT license.
;;                 See odoc/doc/mit-license for full license.
;;; Code:

(in-package :odoc-api)

(defun encode()
  (let((enc (car (conf-member :encode))))
	(if enc
		(eval(read-from-string enc))
	  *encoding-sjis*)))

(provide :odoc/api/encode)

;; end
