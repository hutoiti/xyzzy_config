;;; -*- Mode: Lisp -*-
;;  md5:
;;; Author:        amefura <amefura@gmail.com>
;;; License:       md5 is released under an MIT license.
;;                 See odoc/doc/mit-license for full license.
;;; Code:

(in-package :odoc-api)

(defun md5()
  (si:md5 (buffer-substring(point-min)(point-max))))

(defun md5-write()
  (with-open-file(out (merge-pathnames *odoc-log-file* (default-directory))
					  :direction :output
					  :if-does-not-exist :create
					  :if-exists :append)
	(format out "~A~A~%" (get-buffer-file-name) (md5))))

(defvar-local *md5-hash-table* nil)

(defun md5-read-check()
  (let(line)
	(setq *md5-hash-table*(make-hash-table :test 'equal))
	(with-open-file(in (merge-pathnames *odoc-log-file* (default-directory))
					   :if-does-not-exist :create)
	  (while(setq line (read-line in nil nil nil))
		(let((l (split-string line #\C-])))
		  (setf (gethash (car l) *md5-hash-table*)(cadr l)))))
	  (gethash (get-buffer-file-name) *md5-hash-table*)))

(provide :odoc/api/md5)
;;end
