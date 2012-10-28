;;; -*- Mode: Lisp -*-
;;  config:
;;; Author:        amefura <amefura@gmail.com>
;;; License:       config is released under an MIT license.
;;                 See odoc/doc/mit-license for full license.
;;; Code:
(in-package :odoc-api)

(defun conf-member(type)
  (setq content ())
  (dolist(x *config* (nreverse content))
	(and(eq type (car x))
		(push (cdr x) content))))

(defun config()
  (interactive)
  (let*((file(get-buffer-file-name))
		(dir (and file (directory-namestring file)))
		(cur (merge-pathnames *odoc-config-file* dir))
		(conf (if (and dir (file-exist-p cur))
				  cur
				(merge-pathnames *odoc-config-file*
								 *default-conf-path*)))
		(buf *config-buffer-name*)
		(ch)(r))
	(when
		(file-exist-p conf)
	  (set-buffer (get-buffer-create buf))
	  (insert-file-contents conf)
	  (flet((scan(x)
			  (let((str(buffer-substring
						(point)
						(progn(goto-eol)(point)))))
				(setq ch x)
				(if(and(not(zerop (length str)))
					   (not(string-match "^%" str)))
					(push (cons ch str) r)))
			  (forward-line)
			  ))
		(while(not(eobp))
		  (cond
		   ((looking-at "^%site_title$")
			(scan :title))
		   ((looking-at "^%site_sub$")
			(scan :sub))
		   ((looking-at "^%header$")
			(scan :header))
		   ((looking-at "^%footer$")
			(scan :footer))
		   ((looking-at "^%encode$")
			(scan :encode))
		   ((looking-at "^%date$")
			(scan :date))
		   ((looking-at "^%macro$")
			(scan :macro))
		   ((looking-at "^%regex$")
			(scan :regex))
		   ((looking-at "^%author$")
			(scan :author))
		   ((looking-at "^%host$")
			(scan :host))
		   ((looking-at "^%mail$")
			(scan :mail))
		   ((looking-at "^%menu$")
			(scan :menu))
		   ((looking-at "^%menu plugins$")
			(scan :menu-plugins))
		   ((looking-at "^ *\\(#\\|$\\)")	; comment,blank line
			(forward-line))
		   (t (scan ch)))
		  ))
	  (erase-buffer (selected-buffer))
	  (delete-buffer buf))
	(setq *config* (nreverse r))))

(provide :odoc/api/config)
