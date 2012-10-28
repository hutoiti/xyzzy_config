;;; -*- Mode: Lisp -*-
;;  index:
;;; Author:        amefura <amefura@gmail.com>
;;; License:       index is released under an MIT license.
;;                 See odoc/doc/mit-license for full license.
;;; Code:

(in-package :odoc-mode)

(export '(index))

(defun index(&optional (dir (default-directory)))
  (interactive "DDirectory appointed: "
	:default0 (default-directory))
  (and(find-buffer *index-buffer-name*)
	  (delete-buffer *index-buffer-name*))
  (with-output-to-buffer((setq buf(get-buffer-create *index-buffer-name*)))
	(format t "~{~A~%~}~%" (index-study dir))
	(goto-char(point-min))
	(set-buffer buf)
	(odoc-mode)
	(odoc-read-only-mode t)
	))

(provide :odoc/mode/index)
