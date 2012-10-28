;;; -*- Mode: Lisp -*-
;;; --- format-file --- 
;;
;; Author: amefura <amefura@gmail.com>
;; Created: Wed, 25 Nov 2009 18:00:19 +0900
;; Last Modified:Wed, 27 Jan 2010 08:53:07
;;
;;   %f: ファイル名
;;   %F: フルパス
;;   %D: PATHNAMEのディレクトリ部分
;;   %n: ファイル名（拡張子無し）
;;   %x: 拡張子
;;   %t: ファイルの日付。
;;   %T: ファイルの時間。
;;
;;; Code:
(in-package :editor)
(export '(format-file-string))

(defun format-file (s fmt)
  (do ((i 0 (+ i 1))
	   (l (length fmt)))
	  ((= i l))
	(let ((c (elt fmt i)))
	  (cond ((char= c #\%)
			 (incf i)
			 (when (= i l)
			   (return))
			 (setq c (elt fmt i))
			 (when (char= c #\#)
			   (incf i)
			   (when (= i l)
				 (return))
			   (setq c (elt fmt i)))
			 (let((bufn (get-buffer-file-name)))
			   (if bufn
				   (case c
					 (#\f
					  (princ (file-namestring bufn) s))
					 (#\F
					  (princ bufn s))
					 (#\D
					  (princ (directory-namestring bufn) s))
					 (#\n
					  (princ (pathname-name bufn) s))
					 (#\x
					  (princ (pathname-type bufn) s))
					 (#\t
					  (princ (format-date-string "%Y/%m/%d" (file-write-time bufn)) s))
					 (#\T
					  (princ (format-date-string "%Y/%m/%d %H:%M:%S" (file-write-time bufn)) s))
					 (t
					  (write-char #\% s)
					  (write-char c s)))
				 (progn
				   (write-char #\% s)
				   (write-char c s)
				   (message "not get buffer file name")))))
			(t
			 (write-char c s))))))

(defun format-file-string (fmt)
  (with-output-to-string (out)
	(format-file out fmt)))

(provide :format-file)


;;; filename ends here