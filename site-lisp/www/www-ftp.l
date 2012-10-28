; $Id: www-ftp.l,v 1.3 2005/11/24 15:12:27 torihat Exp $
;
; www-ftp.l
;
; by HATTORI Masashi

(require "wip/ftp")

(provide "www/www-ftp")

(in-package "www")

(defvar *www-ftp-port* 21)

(defun www-ftp-get (host path file &optional port)
  (let (ftp user pass savename)
    (setq savename (www-get-savename file))
    (setq user
	  (read-string (format nil "User Name for ~A: " host)
		       :default (or *www-anon-ftp-user* "")))
    (setq pass
	  (www-get-password (format nil "Password for ~A@~A: " user host)
			    :default (or *www-anon-ftp-pass* "")))
    (when (string-match file path)
      (setq path (substring path 0 (match-beginning 0)))
    )
    (setq path (concat "/" path))
    (save-excursion
      (set-buffer (get-buffer-create *www-buffer-temp*))
      (with-output-to-selected-buffer
	(unwind-protect
	    (progn
	      (message "Connecting to ~A ..." host)
	      (setq ftp (ftp-connect host (or port *www-ftp-port*)))
	      (message "Logging in as ~A ..." user)
	      (ftp-login ftp user pass)
	      (message "Logged in: ~A@~A" user host)
	      (unless (ftp-cd ftp path)
		(error "Could not CWD to ~A" path))
	      (let (os)
		(with-open-stream (os (open savename :direction :output))
		  (ftp-get ftp file os)
		  (unless (= (ftp-get-reply ftp) *ftp-complete*)
		    (error "ERROR: RETR ~A " file))
		  (message "Fetched ~A" savename)
		)
	      )
	    )
	  (ftp-quit ftp)
	  (set-buffer-modified-p nil)
	)
      )
    )
  ))
