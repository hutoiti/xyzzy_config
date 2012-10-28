; $Id: www-auth.l,v 1.4 2005/11/24 15:12:27 torihat Exp $
;
; www-auth.l
;
; by HATTORI Masashi

(provide "www/www-auth.l")

(in-package "www")

(defun www-auth-read-account (server &optional noquestion)
  (let (user
	pass)
    (multiple-value-setq (user pass)
      (www-auth-get-account server))
    (unless (and noquestion
		 user)
      (ding)
      (setq user (read-string (format nil "User name for ~A: " server)
			      :default (or user "")))
    )
    (unless (and noquestion
		 pass)
      (ding)
      (setq pass (www-get-password (format nil "Password for ~A@~A: " user server)
				   :default (or pass "")))
    )
    (www-auth-set-account server user pass)
  ))

(defun www-auth-get-string (server)
  (cadr (assoc server *www-authorization-alist* :test #'string-equal)))

(defun www-auth-set-string (server string)
  (setf (cadr (assoc server *www-authorization-alist* :test #'string-equal)) string))

(defun www-auth-get-account (server)
  (let ((string (www-auth-get-string server)))
    (when string
      (www-auth-decode-account string))
  ))

(defun www-auth-decode-account (string)
  (setq string (si:base64-decode string))
  (when (string-match "\\([^:]+\\):\\(.*\\)" string)
    (values (substring string (match-beginning 1) (match-end 1))
	    (substring string (match-beginning 2) (match-end 2)))
  ))

(defun www-auth-encode-account (user pass)
  (substitute-string (si:base64-encode (concat user ":" pass))
		     "[\r\n]"
		     ""))

(defun www-auth-set-account (server user pass)
  (let ((string (www-auth-encode-account user pass)))
    (if (www-auth-get-string server)
	(www-auth-set-string server string)
      (push (list server string) *www-authorization-alist*)
    )
    string
  ))

(defun www-auth-get-type (header)
  (let ((authen (www-get-header-value "www-authenticate" header))
	atype
	rtype
	realm)
    (when (and (stringp authen)
	       (string-match "\\([^ \t]+\\)[ \t]+\\([^\n]+\\)" authen))
      (setq atype (substring authen (match-beginning 1) (match-end 1)))
      (setq realm (substring authen (match-beginning 2) (match-end 2)))
      (when (string-match "\\([^=]+\\)=\"\\([^\"]+\\)\"" realm)
	(setq rtype (string-downcase (substring realm (match-beginning 1) (match-end 1))))
	(setq realm (substring realm (match-beginning 2) (match-end 2)))
      )
      (unless (string-equal "BASIC" atype)
	(error "対応できない認証方法が必要: ~A" atype))
      t
    );when
  ))
