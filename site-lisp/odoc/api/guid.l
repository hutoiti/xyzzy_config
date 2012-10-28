;;; -*- Mode: Lisp -*-
;;  guid: 
;;; Author:        amefura <amefura@gmail.com>
;;; License:       guid is released under an MIT license.
;;                 See odoc/doc/mit-license for full license.
;;; Code:

(in-package :odoc-api)

(defvar state (make-random-state t))

(defun GUID()
  (let((r ())(s())
		(data)
		(d1 8)
		(d2 4)
		(d3 4)
		(d4 4)
		(d5 12))
	(dotimes (x (random 1000 state))
	  (random 16 state))	; ??
	(flet((ps()(push r data)(setq r ())))
	(dotimes(x 32 (setq data(nreverse data)))
	  (push (random 16 state) r)
	  (cond((= (1- d1) x)(ps))
		   ((= (+ d1 (1- d2)) x)(ps))
		   ((= (+ d1 d2 (1- d3)) x)(ps))
		   ((= (+ d1 d2 d3 (1- d4)) x)(ps))
		   ((= (+ d1 d2 d3 d4 (1- d5)) x)(ps)))))
	(values
	 (format nil "~{~{~X~}-~{~X~}-~{~X~}-~{~X~}-~{~X~}~}" data)
	 (format nil "~{0x~{~X~}, 0x~{~X~}, 0x~{~X~}, {~{0x~X~X, ~}~{0x~X~X~^, ~}}~}" data)
	 data)))

(provide :odoc/api/guid)
;;end
