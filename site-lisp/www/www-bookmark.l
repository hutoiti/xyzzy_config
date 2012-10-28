; $Id: www-bookmark.l,v 1.3 2005/11/24 15:12:27 torihat Exp $
;
; www-bookmark.l
;
; by HATTORI Masashi

(provide "www/www-bookmark")

(in-package "www")

(defvar *www-bookmark-file* (merge-pathnames "bookmark.html" (etc-path)))

(defvar *www-bookmark-alist* nil)

(defvar *www-bookmark-nogroup-name* "No Group")

(defvar *www-bookmark-start-string* "<!-- www-bookmark start -->\n")

(defvar *www-bookmark-header-format* "\
<html>
  <head>
    <title>Bookmarks</title>
  </head>
  <body>
    <h1>Bookmarks</h1>
")

(defvar *www-bookmark-list-title* "    <h2>Groups</h2>\n")
;ëÂï∂éöÇ…ÇµÇƒì¶Ç∞ÇÈÇ∆Ç¢Ç§ÇƒÇ´Ç∆Å[Ç∑Ç¨ÇÈéËíiÅ´
(defvar *www-bookmark-list-format* "      <LI><A HREF=\"#~A\">~A</A></LI>~%")

(defvar *www-bookmark-anchor-format* "    <a name=\"~A\"></a>~%")
(defvar *www-bookmark-group-format* "    <h3>~A</h3>~%")
(defvar *www-bookmark-line-format* "      <li><a href=\"~A\">~A</a></li>~%")

(defun www-bookmark-open ()
  (save-excursion
    (when (and *www-bookmark-file*
	       (file-exist-p *www-bookmark-file*))
      (set-buffer (get-buffer-create *www-buffer-temp*))
      (erase-buffer *www-buffer-temp*)
      (insert-file *www-bookmark-file*)
      (setq *www-bookmark-alist* (www-bookmark-read))
      (delete-buffer *www-buffer-temp*)
    )
  ))

(defun www-bookmark-read ()
  (let (bookmarks alist group nogroup)
    (save-excursion
      (goto-char (point-min))
      ;(when (scan-buffer *www-bookmark-start-string* :tail nil)
	 (while (forward-line 1)
	   (cond ((looking-at "[ \t]*<h3>\\(.*\\)</h3>")
		  (progn
		    (if group
			(push (list group (reverse alist)) bookmarks)
		      (setq nogroup (append nogroup (reverse alist)))
		    )
		    (setq alist nil)
		    (setq group (match-string 1))
		  )
		 )
		 ((looking-at "[ \t]*<li><a href=\"\\([^\"]+\\)\">\\([^<]+\\)</a>")
		  (push (list (match-string 1) (match-string 2)) alist))
	   );cond
	 );while
	 ;);when
      (when alist
	(if group
	    (push (list group (reverse alist)) bookmarks)
	  (progn
	    (setq nogroup (append alist nogroup))
	    (push (list *www-bookmark-nogroup-name* (reverse nogroup)) bookmarks)
	  )
	)
      )
    )
    (reverse bookmarks)
  ))

(defun www-bookmark-write ()
  (save-excursion
    (set-buffer (get-buffer-create *www-buffer-temp*))
    (erase-buffer *www-buffer-temp*)
    (insert *www-bookmark-header-format*)
    (insert "    <hr>\n")
    (insert *www-bookmark-list-title*)
    (insert "    <ul>\n")
    (dolist (x *www-bookmark-alist*)
      (let ((group (car x)))
	(insert
	 (format nil *www-bookmark-list-format* group group))
      ))
    ;(insert *www-bookmark-start-string*)
    (insert "    <hr>\n")
    (dolist (x *www-bookmark-alist*)
      (let ((group (car x))
	    (books (nth 1 x)))
	(insert
	 (format nil *www-bookmark-anchor-format* group))
	(insert
	 (format nil *www-bookmark-group-format* group))
	(insert "    <ul>\n")
	(dolist (y books)
	  (insert
	   (format nil *www-bookmark-line-format* (car y) (nth 1 y)))
	)
	(insert "    </ul>\n")
	(insert "    <hr>\n")
      )
    )
    (insert "    </ul>\n")
    (insert "  </body>\n")
    (insert "</html>\n")
    (write-region (point-min) (point-max) *www-bookmark-file*)
    (delete-buffer *www-buffer-temp*)
    (message "~A saved." *www-bookmark-file*)
  ))

(defun www-bookmark-show ()
  (interactive)
  (www-open-local *www-bookmark-file*))

(defun www-bookmark-add (url title group)
  (and (www-bookmark-add-to-list url title group)
       (www-bookmark-write)))

(defun www-bookmark-add-to-list (url title group)
  (let ((alist (assoc group *www-bookmark-alist* :test #'equal))
	(new (list url title)))
    (if alist
	(let (add
	      (old (nth 1 alist)))
	  (when (member new old :test #'equal)
	    (return-from www-bookmark-add-to-list))
	  (push new add)
	  (setq alist (append old add))
	  (setf (cdr (assoc group *www-bookmark-alist* :test #'equal)) (list alist)))
      (let ((books (reverse *www-bookmark-alist*))
	    add)
	(push new add)
	(setq *www-bookmark-alist*
	      (reverse
	       (push (list group add) books))))
    )))

(defun www-bookmark-add-current (url)
  (interactive "sURL: " :default0 www-url)
  (let (title
	group)
    (setq title (read-string "Title: " :default (or www-page-title "")))
    (let ((*minibuffer-default-history* (mapcar #'car *www-bookmark-alist*)))
      (declare (special *minibuffer-default-history*))
      (setq group (completing-read "Group: "
				   *www-bookmark-alist*
				   :default (or (car *minibuffer-default-history*)
						*www-bookmark-nogroup-name*)
		  ))
    )
    (unless (or group
		(string-match "^[ \t]*$" group))
      (setq group *www-bookmark-nogroup-name*))
    (www-bookmark-add url title group)
  ))
