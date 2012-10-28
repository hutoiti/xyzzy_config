; $Id: www-misc.l,v 1.4 2005/11/24 15:12:27 torihat Exp $
;
; www-misc.l
;
; by HATTORI Masashi

(provide "www/www-misc")

(in-package "www")

(defvar *www-yahoo-unknown-string* (format nil "~A~A" (code-char 253) (code-char 254)))

(defun www-yahoo-delete-unknown-string ()
  (save-excursion
    (goto-char (point-min))
    (when (scan-buffer *www-yahoo-unknown-string*)
      (delete-region (match-beginning 0) (match-end 0)))
  ))

(defvar *www-wget-download-command* "wget -O ")

(defun www-wget-download ()
  (interactive)
  (let (tag val)
    (multiple-value-setq (tag val)
      (www-view-point-link))
    (cond ((eq tag 'href)
	   (if val
	       (let ((filename (www-get-savename (www-url-file-namestring val)))
		     (buf (concat *www-buffer-wget* val)))
		 (if (find-buffer buf)
		     (switch-to-buffer buf)
		   (progn
		     (switch-to-buffer (get-buffer-create buf))
		     (execute-subprocess
		      (concat *www-wget-download-command* filename " " val)
		      nil
		      buf)
		   )
		 )
	       )
	     (message "ÉäÉìÉNÇ∂Ç·Ç»Ç¢Ç¡Ç∑")
	   ))
	  (t
	   (message "ÉäÉìÉNÇ∂Ç·Ç»Ç¢Ç¡Ç∑")
	  )
    );cond
  ))

(defun www-get-savename (&optional file)
  (let (savename path)
    (loop
      (setq path (merge-pathnames (or file "") *www-save-directory*))
      (setq savename (read-file-name "Save to: " :default path))
      (if (file-exist-p savename)
	  (when (yes-or-no-p "è„èëÇ´ÇµÇ‹Ç∑Ç©ÅH: ~A" savename)
	    (return))
	(return)
      )
    )
    (setq *www-save-directory* (directory-namestring savename))
    savename
  ))

(defun www-get-password (&optional prompt &key default)
  (interactive)
  (let (ch
	len
	(pw (or default ""))
       )
    (loop
      (setq len (length pw))
      (minibuffer-prompt "~A~A" (or prompt "Password: ") (substitute-string pw "." "*"))
      (setq ch (read-char ed:*keyboard*))
      (cond ((char= ch #\RET)
	     (return))
	    ((char= ch #\C-h)
	     (when (< 0 len)
	       (setq pw (substring pw 0 (1- len)))))
	    ((char= ch #\C-g)
	     (quit))
	    (t
	     (setq pw (format nil "~A~C" pw ch)))
      )
    )
    pw
  ))

(defun www-blank-line-p (&optional line)
  (save-excursion
    (if line
	(unless (forward-line line)
	  (return-from www-blank-line-p))
      (goto-bol)
    )
    (looking-at "^[ \t]*$")
  ))

(defun www-convert-crlf ()
  (save-excursion
    (goto-char (point-min))
    (replace-string "\r" "" t)
  ))

(defvar *month-name-alist* '(("jan" 1)
			     ("feb" 2)
			     ("mar" 3)
			     ("apr" 4)
			     ("may" 5)
			     ("jun" 6)
			     ("jul" 7)
			     ("aug" 8)
			     ("sep" 9)
			     ("oct" 10)
			     ("nov" 11)
			     ("dec" 12)
			    ))

(defun www-parse-header-date (date)
  (when
      (string-match
       "\\([0-9]+\\)[ \t]+\\([a-zA-Z]+\\)[ \t]+\\([0-9]+\\)[ \t]+\\([0-9][0-9]:[0-9][0-9]:[0-9][0-9]\\)"
       date)
    (let ((day (substring date (match-beginning 1) (match-end 1)))
	  (mstr (substring date (match-beginning 2) (match-end 2)))
	  (year (substring date (match-beginning 3) (match-end 3)))
	  (time (substring date (match-beginning 4) (match-end 4)))
	  month
	  date-string
	  date-value)
      (setq month (or (car (cdr (assoc (string-downcase mstr) *month-name-alist* :test #'equal))) 0))
      (setq date-string (format nil "~A/~D/~A ~A" year month day time))
      (setq date-value (parse-date-string date-string))
      (when (string-match "GMT" (string-upcase date))
	(setq date-value (+ date-value (* 60 60 9))))
    date-value
    )
  ))
