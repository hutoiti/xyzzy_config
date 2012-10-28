; $Id: www-update.l,v 1.3 2005/11/24 15:12:27 torihat Exp $
;
; www-update.l
;
; by HATTORI Masashi

(provide "www/www-update.l")

(in-package "www")

(defvar *www-update-data-file* (merge-pathnames "update.html" (etc-path)))

(defvar *www-update-page-title* "Update Infomation")

(defvar *www-update-quit* nil)

(defvar *www-update-header-format* "\
<html>
  <head>
    <title>~A</title>
  </head>
  <body>
    <h1>~A</h1>
")

(defun www-update-pages ()
  (interactive)
  (let ((data (www-update-read-file *www-update-data-file*))
	(count 0)
	(vbuf (concat *www-buffer-view-prefix* "file://" *www-update-data-file*)))
    (setq *www-update-quit* nil)
    (unless data
      (error "調べるページがないっす"))
    (when (yes-or-no-p "更新情報を取得しますか？")
      ;(message-box (format nil "~S" data))
      (save-excursion
	(set-buffer (get-buffer-create *www-buffer-temp*))
	(erase-buffer (selected-buffer))
	(long-operation
	  (dotimes (i (list-length data))
	    (let* ((d (nth i data))
		   (url (car d))
		   (time (cadr d))
		   fetch)
	      (insert (format nil "==> Fetching header : ~A ... " url))
	      (sit-for 0)
	      (setq fetch (www-update-last-update url))
	      (when (and fetch
			 (> fetch time))
		(setf (cadr (nth i data)) fetch)
		(insert "[UPDATED] ")
		(incf count 1)
	      )
	      (insert "done.\n")
	      (sit-for 0)
	    )
	  )
	);long-operation
      );save-excursion
      (www-update-write-file (sort data #'> :key #'cadr))
    )
    (if (find-buffer vbuf)
	(progn
	  (switch-to-buffer vbuf)
	  (www-view-reload)
	)
      (www-open-local *www-update-data-file*)
    )
  ))

(defun www-update-add (url title time)
  (let ((data (www-update-read-file *www-update-data-file*)))
    (push (list url time title) data)
    (www-update-write-file (sort data #'> :key #'cadr))
    (message "~A added." url)
  ))

(defun www-update-last-update (url)
  (let (sock status header last)
    (handler-case
	(multiple-value-setq (sock status header)
	  (www-http-get-url url :head t))
      (socket-error (c)
	(message "Socket error. Ignored.")
      )
      (quit (c)
	(message "Interrupted.")
	(unless (setq *www-update-quit* (not *www-update-quit*))
	  (quit))
      )
    )
    (if (stringp status)
	(if (and (string-match "^2[0-9][0-9]" status)
		 header)
	    (setq last (www-get-header-value "last-modified" header))
	  (message-box (format nil "ERROR: ~S~%~S" status header))
	)
    )
    (if (stringp last)
	(www-parse-header-date last)
      nil)
  ))

(defun www-update-read-file (file)
  (let (data
	(deftime (parse-date-string "1980/01/01 00:00:00")))
    (when (file-exist-p file)
      (message "Reading update data ...")
      (save-excursion
	(set-buffer (get-buffer-create *www-buffer-temp*))
	(erase-buffer (selected-buffer))
	(insert-file file)
	(goto-char (point-min))
	(while (forward-line 1)
	  (when (looking-at "^[ \t]*<li>\\(.*\\)<a href=\"\\([^\"]+\\)\">\\([^<]+\\)</a>")
	    (let (time url title)
	      (setq url (match-string 2))
	      (setq title (match-string 3))
	      (setq time (or (parse-date-string (match-string 1))
			     deftime))
	      (push (list url time title) data)
	    )
	  )
	)
      )
      (message "Reading update data ... done")
    )
    (nreverse data)
  ))

(defun www-update-write-file (data)
  (save-excursion
    (set-buffer (get-buffer-create *www-buffer-temp*))
    (erase-buffer (selected-buffer))
    (insert (format nil
		    *www-update-header-format*
		    *www-update-page-title*
		    *www-update-page-title*))
    (insert "<ul>\n")
    (dolist (x data)
      (let ((url (car x))
	    (time (cadr x))
	    (title (caddr x)))
	(insert (format nil
			"  <li>~A <a href=\"~A\">~A</a>~%"
			(format-date-string "%Y/%m/%d %H:%M:%S" time)
			url
			title))
      )
    )
    (insert "</ul>\n")
    (insert "</body>\n")
    (insert "</html>\n")
    (write-region (point-min) (point-max) *www-update-data-file*)
    (delete-buffer *www-buffer-temp*)
  ))

(defun www-update-add-current (url)
  (interactive "sURL: " :default0 www-url)
  (let (title
	modified
	(time 0))
    (setq title (read-string "Title: " :default (or www-page-title "")))
    (setq modified (www-get-header-value "last-modified" www-http-header))
    (when modified
      (setq time (www-parse-header-date modified)))
    (www-update-add url title time)
  ))

(defun www-update-convert-from-bookmark ()
  (interactive)
  (when (yes-or-no-p "Bookmarkを元にUpdateファイルを作成しますか？")
    (www-update-write-file
     (www-update-read-file *www-bookmark-file*))
    (message "作成完了")
  ))

