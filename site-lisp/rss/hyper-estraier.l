;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: hyper-estraier.l 731 2006-09-01 18:09:41Z torihat $
;
; rss/hyper-estraier.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "rss/defs")
  (require "hecmd/estcmd"))

(provide "rss/hyper-estraier")

(in-package "rss")

(defvar *he-search-max* -1)
(defvar *he-search-skip* 0)

(defvar *debug-mode* nil)

(defvar *buffer-he-temp*  (concat *rss-buffer-prefix* "HyperEstraier Temp*"))

(defvar *he-casket*
  (merge-pathnames "casket" *rss-directory*))

(defvar *he-cmd-gather-option* 
  '("-il ja"
    "-pc CP932"
    "-fe"
    "-cm"
    "-sd"))

(defvar *he-data-directory*
  (merge-pathnames "hedata" *rss-directory*))

(defvar *he-attr-index-list* '(
			       ("@uri"      . "str")
			       ("@author"   . "str")
			       ("@cdate"    . "seq")
			       ("@mdate"    . "seq")
			       ("@title"    . "str")
			       ("title"     . "str")
			       ("date"      . "seq")
			       ("subject"   . "str")
			       ("link"      . "str")
			       ("timestamp" . "seq")
			       ))

(defvar *he-draft-directory*
  (merge-pathnames "hedraft" *rss-directory*))

(defvar *he-dump-directory*
  (merge-pathnames "hedump" *rss-directory*))

(defvar *he-gather-list-file*
  (merge-pathnames "he-gather.txt" *he-data-directory*))

(defvar *he-execute-batch-file*
  (merge-pathnames "he-temp.bat" *he-data-directory*))

(defvar *he-last-result* nil)

(defun he-init ()
  (unless (file-exist-p *he-data-directory*)
    (create-directory *he-data-directory*))
  (unless (file-exist-p *he-draft-directory*)
    (create-directory *he-draft-directory*))
  (unless (file-exist-p *he-dump-directory*)
    (create-directory *he-dump-directory*))
  (unless (file-exist-p *he-casket*)
    (he-create)))

(defun he-cmd-restore (dir)
  (when (string-match "/$" dir)
    (setq dir (substring dir 0 (1- (length dir))))) ; ÅŒã‚Ì "/" ‚ðÁ‚·
  (format nil "~A gather~@[ ~A~] \"~A\" \"~A\""
	  *he-estcmd*
	  *he-cmd-gather-option*
	  *he-casket*
	  dir))

(defun he-cmd-dump ()
  (format nil "~A search -max -1 -dd \"~A\" [UVSET]"
	  *he-estcmd*
	  *he-casket*))

(defun he-write-text (file text-list &optional attrs)
  (let ((values (mapcar #'cdr attrs)))
    (with-open-file (f file
		       :direction :output
		       :if-exists :overwrite
		       :if-does-not-exist :create)
      (mapc #'(lambda (x)
		(format f "~A~{\t~A~}~%" x values))
	    text-list))))

(defvar *he-execute-flag* nil)

(defun he-optimize (&optional background-p)
  (interactive "p")
  (hecmd::estcmd-optimize *he-casket* background-p))

(defun he-print-result (results)
  (let (errors
	(num-all (length results))
	(num-suc 0))
    (dolist (r results)
      (let ((cmd (car r))
	    (res (cdr r)))
	(if res
	    (incf num-suc)
	  (push cmd errors))))
    (when errors
      (msgbox "Error:~%~%~{~A~%~}" (reverse errors)))
    (message "Completed: ~D/~D" num-suc num-all)))

(defun he-gather-all-cmd ()
  (hecmd::estcmd-gather-cmd *he-casket*
			    *he-draft-directory*
			    *he-cmd-gather-option*))

(defun he-purge-all-cmd ()
  (hecmd::estcmd-purge-cmd *he-casket*))

(defun he-regather-all (&optional background-p)
  (interactive "p")
  (let ((cmd-list (list (he-purge-all-cmd)
			(he-gather-all-cmd))))
    (message "re-gathering index: ~A ... " *he-casket*)
    (hecmd::hecmd-execute-batch cmd-list
				*buffer-he-temp*
				*he-execute-batch-file*
				background-p)
    (message "re-gathering index: ~A ... done." *he-casket*)))

(defun he-dump (&optional background-p)
  (interactive "p")
  (create-directory-if *he-dump-directory*)
  (hecmd::estcmd-dump *he-casket*
		      *he-dump-directory*
		      background-p))

(defun he-create (&optional background-p)
  (interactive "p")
  (hecmd::estcmd-create *he-casket* *he-attr-index-list* background-p))

(defun he-restore (&optional background-p)
  (interactive "p")
  (when (file-exist-p *he-casket*)
    (let ((backupdir (format nil "~A-~A"
			     *he-casket*
			     (format-date-string "%Y%m%d%H%M%S"))))
      (msgbox "Šù‘¶‚Ìcasket‚ð ~A ‚É•ÏX‚µ‚Ü‚·B" backupdir)
      (unless (rename-file *he-casket* backupdir)
	(error "–¼Ì•ÏXŽ¸”s: \n~A\n=>~A"
	       *he-casket*
	       backupdir))))
  (message "restoring dump files ...")
  (he-create background-p)
  (let ((cmd (hecmd::estcmd-gather-cmd *he-casket*
				       *he-dump-directory*
				       *he-cmd-gather-option*)))
    (he-execute-batch (list cmd) background-p))
  (message "restoring dump files ... done."))

(defun he-url-encode (url)
  (si:md5 url))

(defun he-draft-directory (channel-url)
 (merge-pathnames (he-url-encode channel-url)
		  *he-draft-directory*))

(defun he-draft-file-path (channel-url url)
  (unless (and channel-url url)
    (return-from he-draft-file-path))
  (let* ((dir (he-draft-directory channel-url))
	 (file (concat (merge-pathnames (he-url-encode url)
					dir)
		       ".est"))
	 (basedir (directory-namestring file)))
    (create-directory basedir :if-exists :skip)
    file))

(defun he-header-format (string)
  (when (stringp string)
    (string-trim " \t\n"
		 (substitute-string string "\n" " "))))

(defun he-entry-to-draft (channel entry)
  (let* ((channel-title (he-header-format (rss-title channel)))
	 (channel-link (rss-link channel))
	 (url (rss-link entry))
	 (title (he-header-format (rss-title entry)))
	 (timestamp (rss-timestamp entry))
	 (description (rss-description entry)))
    (with-output-to-string (s)
      (format s "@type=application/rss+xml~%")
      (format s "@uri=~A~%" url)
      (format s "@title=~@[~A~]~%" title)
      (format s "@cdate=~A~%" (junk::rfc822-format-date (if timestamp
							    timestamp
							  (get-universal-time))))
      (format s "@mdate=~A~%" (junk::iso8601-format-datetime (if timestamp
								 timestamp
							       (get-universal-time))
							     "Z"))
      (format s "date=~A~%" (junk::rfc822-format-date (if timestamp
							  timestamp
							(get-universal-time))))
      (format s "title=~@[~A~]~%" channel-title)
      (format s "subject=~@[~A~]~%" title)
      (format s "link=~@[~A~]~%" channel-link)
      (format s "timestamp=~@[~D~]~%" timestamp)
      (format s "~%")
      (format s "~@[~A~]~%" (substitute-string (if description description "") "\t" " "))
      (format s "\t~@[~A~]~%" title)
      )))

(defun he-gather-entries-1 (channel item-list)
  (let ((channel-url (or (rss-link channel) "00misc"))
	(cnt 0)
	(curbuf (selected-buffer))
	new-files
	errors)
    (save-excursion
      (message "creating draft files ...")
      (set-buffer (get-buffer-create " *draft temp*"))
      (dolist (item item-list)
	(let* ((entry (car item))
	       (seen-p (cdr item))
	       (url (rss-link entry))
	       (file (he-draft-file-path channel-url url)))
	  (when (or (not seen-p)
		    (and file
			 (not (file-exist-p file))))
	    (handler-case
		(let ((draft (he-entry-to-draft channel entry)))
		  (when draft
		    (erase-buffer (selected-buffer))
		    (insert draft)
		    (write-region (point-min)
				  (point-max)
				  file
				  nil
				  *encoding-utf8n*
				  *eol-lf*)
		    (push file new-files)
		    (incf cnt)))
	      (error (c)
		(push (si:*condition-string c) errors))))
	  (do-events)))
      (message "creating draft files ... ~D/~D." cnt (length item-list))
      )
    (when new-files
      (he-execute-gather (reverse new-files)))
    (nreverse errors)))

(defun he-gather-entries ()
  (let (errors)
    (when (and *rss-channel*
	       *rss-item-list*)
      (when (setq errors
		  (he-gather-entries-1 *rss-channel* *rss-item-list*))
	(he-gather-error errors)))))

(defvar *he-gather-files* nil)

(defun he-execute-gather (&optional files)
  (when files
    (setq *he-gather-files*
	  (append *he-gather-files*
		  files)))
  (when *he-gather-files*
    (when *debug-mode*
      (msgbox "~D~%~%~{~S~%~}"
	      (length *he-gather-files*)
	      *he-gather-files*))
    (when hecmd::*hecmd-execute-flag*
      (message "skip execute ~D" (length *he-gather-files*))
      (return-from he-execute-gather))
    (he-write-text *he-gather-list-file*
		   *he-gather-files*)
    (let ((cmd (hecmd::estcmd-gather-cmd  *he-casket*
					  *he-gather-list-file*
					  *he-cmd-gather-option*)))
      (setq *he-gather-files* nil)
      (hecmd::hecmd-execute-batch (list cmd)
				  *buffer-he-temp*
				  *he-execute-batch-file*
				  t)
      )))

(defvar *he-search-history* nil)
(defvar *he-search-history-max* 50)
(defvar *he-search-history-file*
  (merge-pathnames "he-history.dat" *he-data-directory*))

(defun he-search-history-save ()
  (junk::data-write-to-file *he-search-history-file*
			    *he-search-history*))

(defun he-search-history-load ()
  (setq *he-search-history*
	(junk::data-read-from-file *he-search-history-file*)))

(defun he-search-history-add (query-string)
  (setq *he-search-history*
	(delete query-string *he-search-history*
		:test #'equal))
  (push query-string *he-search-history*)
  (when (< *he-search-history-max*
	   (length *he-search-history*))
    (setq *he-search-history*
	  (subseq *he-search-history* 0 *he-search-history-max*)))
  (he-search-history-save))

(defvar *he-search-options* '("-vf" "-hs" "-nl"))

(defun he-search ()
  (interactive)
  (let ((query-string (read-string "Search: "
				   :default (car *he-search-history*)
				   :history *he-search-history*))
	q
	result)
    (when (and query-string
	       (setq q (hecmd::hequery-string-parse query-string)))
      (he-search-history-add query-string)
      (when (or (hecmd::hequery-query q)
		(hecmd::hequery-attrs q))
	(setq result
	      (hecmd::estcmd-search *he-casket*
				    (hecmd::hequery-query q)
				    (hecmd::hequery-attrs q)
				    (hecmd::hequery-order q)
				    *he-search-max*
				    *he-search-skip*
				    *he-search-options*))))
    (he-open-search-result result)
    ))

(defvar *rss-buffer-search*
  (concat *rss-buffer-prefix* " SEARCH*"))

(defun rss-set-buffer-search ()
  (set-buffer (get-buffer-create *rss-buffer-search*)))

(defun he-search-result-channel (result)
  (let ((number (hecmd::heresult-number result))
	(query-string (car *he-search-history*)))
    (list (cons "title" "Search Result")
	  (cons "link" nil)
	  (cons "description" (format nil "\"~@[~A~]\" (~D hit~P)"
				      query-string
				      (if (numberp number) number 0)
				      (if (numberp number) number 0)
				      )))))

(defun he-result-item-list (result)
  (when (hecmd::heresult-p result)
    (let ((docs (hecmd::heresult-documents result))
	  items)
      (dolist (doc docs)
	(let* ((num (car doc))
	       (d (cdr doc))
	       (title       (cdr (assoc "subject"   d :test #'equal)))
	       (description (cdr (assoc "@snipet"   d :test #'equal)))
	       (link        (cdr (assoc "@uri"      d :test #'equal)))
	       (date        (cdr (assoc "@mdate"    d :test #'equal)))
	       (timestamp   (cdr (assoc "timestamp" d :test #'equal)))
	       (id          (cdr (assoc "id"        d :test #'equal))))
	  (push (cons (list (cons "title" title)
			    (cons "description" description)
			    (cons "link" link)
			    (cons "date" date)
			    (cons "timestamp" timestamp)
			    (cons "id" id))
		      t)
		items)))
      (nreverse items))))

(defun rss-search-result-print (result)
  (let ((buffer-read-only nil))
    (declare (special buffer-read-only))
    (setq *rss-channel* (he-search-result-channel result))
    (setq *rss-item-list* (he-result-item-list result))
    (erase-buffer (selected-buffer))
    (rss-print-items))
  (rss-history-mode)
  (rss-history-mode-line))

(defun he-open-search-result (result)
  (rss-history-close)
  (setq *rss-clip-window-conf-backup*
	(current-window-configuration))
  (rss-set-buffer-group)
  (delete-other-windows)
  (split-window-vertically *rss-menu-width*)
  (other-window)
  (rss-set-buffer-search)
  (rss-history-mode)
  (rss-history-mode-line)
  (rss-search-result-print result)
  (goto-char (point-min))
  (rss-item-next))

(defun he-gather-error (errors)
  (error "Error: ~%~%~{-- ~%~A~%~}" errors))

(defun he-group-gather-all ()
  (interactive)
  (let ((pos (point))
	errors)
    (save-excursion
      (dolist (group *rss-group-list*)
	(rss-group-open-1 group)
	(handler-case
	    (he-menu-gather-all)
	  (error (c)
	    (push (si:*condition-string c) errors)))))
    (rss-group-print)
    (goto-char pos)
    (when errors
      (error "Error: ~%~{~A~}" (nreverse errors)))))

(defun he-menu-gather-all ()
  (interactive)
  (let ((num (current-line-number))
	(cur (selected-buffer))
	errors)
    (dotimes (i (length *rss-menu-data*))
      (let ((line (rss-menu-number-to-line i))
	    (line-errors))
	(goto-line line)
	(rss-reverse-menu)
	(refresh-screen)
	(let ((buf (concat *rss-buffer-prefix* "UPDATEALLTEMP*")))
	  (save-excursion
	    (set-buffer (get-buffer-create buf))
	    (erase-buffer (selected-buffer))
	    (unwind-protect
		(handler-case
		    (let* ((item (nth i *rss-menu-data*))
			   (obuf (rss-buffer-title (rss-title item)))
			   (url (rss-link item))
			   (title (rss-title item))
			   (file (rss-url-to-file url))
			   (cache (rss-file-to-cache file)))
		      (when (find-buffer obuf)
			(delete-buffer obuf))
		      (when (file-exist-p cache)
			(multiple-value-bind (channel item-list)
			    (rss-load-cache cache)
			  (when (setq line-errors (he-gather-entries-1 channel item-list))
			    (dolist (line-error line-errors)
			      (push line-error errors)))))
		      )
		  (error (c)
		    (push (format nil "Error: ~S:~%~A"
				  (rss-title (nth i *rss-menu-data*))
				  (si:*condition-string c))
			  errors)))
	      (delete-buffer buf)
	      )))
	(set-buffer cur)
	))
    (clear-reverse-region)
    (goto-line num)
    (when errors
      (error "~{-- ~%~A~%~}" (nreverse errors)))))

(defun he-sync ()
  (interactive)
  (he-execute-gather nil))

(defun he-inform ()
  (interactive)
  (let ((info (hecmd::estcmd-inform *he-casket*)))
    (msgbox "~A~%~%~A" *he-casket*
	    info)))

(defun he-clear-draft-files ()
  (interactive)
  (let ((cnt 0))
    (message "parsing directory ...")
    (dolist (dir (directory *he-draft-directory*
			    :directory-only t
			    :show-dots nil
			    :absolute t))
      (message "clearing directory: ~A ..." dir)
      (dolist (file (directory dir
			       :wild "*.est"
			       :absolute t))
	(when (delete-file file
			   :if-does-not-exist :skip
			   :if-access-denied :skip)
	  (incf cnt))
	(do-events))
      (do-events))
    (message "done.(~D)" cnt)))
