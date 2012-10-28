; $Id: www-cookie.l,v 1.3 2005/11/24 15:12:27 torihat Exp $
;
; www-cookie.l
;
; by HATTORI Masashi

(provide "www/www-cookie")

(in-package "www")

(defvar *www-cookie-enable* nil)
(defvar *www-cookie-alert-always* nil)
(defvar *www-cookie-alert-host-mismatch* nil)
(defvar *www-cookie-ignore-host-mismatch* t)

(defvar *www-cookie-max-cnt* 300)
(defvar *www-cookie-max-len* 4096)

(defvar *www-cookie-file* "~/.www-cookie")
(defvar *www-cookie-data* nil)

(defmacro cookie-domain (cookie)
  `(car ,cookie))

(defmacro cookie-path (cookie)
  `(nth 1 ,cookie))

(defmacro cookie-name (cookie)
  `(nth 2 ,cookie))

(defmacro cookie-value (cookie)
  `(nth 3 ,cookie))

(defmacro cookie-expire (cookie)
  `(nth 4 ,cookie))

(defun data-read-from-file (file)
  (let (data)
    (when (file-exist-p file)
      (with-open-file (s
		       file
		       :direction :input
		       :if-does-not-exist :error)
	(let (tmp)
	  (while (setq tmp (read s nil))
	    (push tmp data)))))
    (nreverse data)))

(defun data-write-to-file (file data)
  (with-open-file (s
		   file
		   :direction :output
		   :if-exists :overwrite
		   :if-does-not-exist :create)
    (format s "~{~S~%~}" data))
  t)

(defun cookie-alive-p (cookie)
  (let ((expire (cookie-expire cookie))
	(res nil))
    (when (and expire
	       (<= (get-universal-time) expire))
      (setq res t))
    res))

(defun cookie-load ()
  (let (data
	cookies)
    (message "WWW: loading cookies ...")
    (setq data (data-read-from-file *www-cookie-file*))
    (dolist (d data)
      (when (cookie-alive-p d)
	(push d cookies)))
    (setq *www-cookie-data* (nreverse cookies))
    (message "WWW: loading cookies ... done.")))

(defun cookie-save ()
  (let (cookies)
    (dolist (d *www-cookie-data*)
      (when (cookie-alive-p d)
	(push d cookies)))
    (data-write-to-file *www-cookie-file*
			(nreverse cookies))))

(defun cookie-equal-p (c1 c2)
  (and (equalp (cookie-domain c1)
	       (cookie-domain c2))
       (equal (cookie-path c1)
	      (cookie-path c2))
       (equal (cookie-name c1)
	      (cookie-name c2))))

(defun cookie-add (cookie)
  (let (new
	(done nil))
    (dolist (d *www-cookie-data*)
      (if (cookie-equal-p d cookie)
	  (progn
	    (push cookie new)
	    (setq done t))
	(push cookie d)))
    (unless done
      (push cookie new))
    (let ((cnt (length new)))
      (when (< *www-cookie-max-cnt* cnt)
	(setq new (butlast new (- cnt *www-cookie-max-cnt*)))))
    (setq *www-cookie-data* (reverse new))
    (cookie-save)))

(defun cookie-eat (set-cookie host file)
  (let ((cookie (cookie-parse set-cookie host file)))
    (when cookie
      (when *www-http-debug*
	(msgbox "eat cookie~%~S" cookie))
      (when (or (not *www-cookie-alert-always*)
		(cookie-alert-always cookie host))
	(cookie-add cookie)))))

(defun cookie-get (host file)
  (let (cookies
	cookstr)
    (dolist (d *www-cookie-data*)
      (let ((domreg (concat (cookie-domain d) "$"))
	    (pathreg (concat "^" (cookie-path d))))
	(when (and (string-matchp domreg host)
		   (string-match pathreg file))
	  (push (format nil "~A=~A" (cookie-name d) (cookie-value d))
		cookies))))
    (when cookies
      (setq cookstr
	    (format nil "~A~{;~A~}" (car cookies) (cdr cookies))))
    cookstr))

(defun cookie-parse (cookie host file)
  (let (name
	value
	expires
	domain
	path
	parts)
    (unless (stringp cookie)
      (return-from cookie-parse))
    (setq parts (split-string cookie ";" nil " \t\r\n"))
    (setq value (pop parts))
    (unless value
      (msgbox "No value: ~S" value)
      (return-from cookie-parse))
    (when (< *www-cookie-max-len* (length value))
      (msgbox "Cookie is too long.: < ~D ~D"
	      *www-cookie-max-len*
	      (length value))
      (return-from cookie-parse))
    (unless (string-match "\\([^ \t\r\n;,=]+\\)=\\([^ \t\r\n;,]+\\)" value)
      (msgbox "Not cookie name & value: ~S" value)
      (return-from cookie-parse))
    (setq name (match-string 1))
    (setq value (match-string 2))
    (dolist (part parts)
      (if (string-matchp "\\(expires\\|path\\|domain\\|secure\\)\\(=\\(.+\\)\\)?" part)
	  (let ((k (match-string 1))
		v)
	    (when (match-beginning 2)
	      (setq v (string-trim " \t\r\n" (match-string 3))))
	    ;(msgbox "~S~%~S" k v)
	    (cond ((equalp k "expires")
		   (when v
		     (setq expires (cookie-parse-date v)))
		   )
		  ((equalp k "path")
		   (when v
		     (setq path v))
		   )
		  ((equalp k "domain")
		   (when v
		     (unless (string-match "\.[-_0-9a-zA-Z]+\.[-_0-9a-zA-Z]+$" v)
		       (msgbox "Illegal domain in cookie. Ignored. ~S" v)
		       (return-from cookie-parse))
		     (if (string-matchp (concat v "$") host)
			 (setq domain v)
		       (if *www-cookie-ignore-host-mismatch*
			   (return-from cookie-parse)
			 (if *www-cookie-alert-host-mismatch*
			     (if (cookie-alert-host-mismatch-ok cookie host)
				 (setq domain v)
			       (return-from cookie-parse))
			   (setq domain v)))))
		   )
		  ((equalp k "secure")
		   ;; https をサポートしていないのでsecure cookieは受付できない
		   (when *www-http-debug*
		     (msgbox "Ignore Secure Cookie"))
		   (return-from cookie-parse)
		   )))
	(msgbox "Not cookie options: ~S" part)))
    (unless domain
      (setq domain host))
    (unless path
      (setq path file))
    (list domain path name value expires)
    ))

(defun cookie-alert-host-mismatch-ok (cookie host)
  (no-or-yes-p "~Aはdomainの一致しない以下のcookieを送ってきています。~%食べますか？~%~%~A"
	       host
	       cookie))

(defun cookie-alert-always (cookie host)
  (no-or-yes-p "~Aは以下のcookieを送ってきています。~%食べますか？~%~%~A=~A~%~%~@[Domain: ~A~]~%~@[Path: ~A~]~%~@[Expires: ~A~]"
	       host
	       (cookie-name cookie)
	       (cookie-value cookie)
	       (cookie-domain cookie)
	       (cookie-path cookie)
	       (and (cookie-expire cookie)
		    (format-date-string "%Y/%m/%d %H:%M:%S" (cookie-expire cookie)))))

(defun cookie-parse-date (date)
  (when
      (string-match
       "\\([0-9]+\\)-\\([a-zA-Z]+\\)-\\([0-9]+\\)[ \t]+\\([0-9][0-9]\\):\\([0-9][0-9]\\):\\([0-9][0-9]\\)"
       date)
    (let ((day (parse-integer (match-string 1)))
	  (mstr (match-string 2))
	  (year (parse-integer (match-string 3)))
	  (hour (parse-integer (match-string 4)))
	  (min (parse-integer (match-string 5)))
	  (sec (parse-integer (match-string 6)))
	  month
	  date-value)
      (setq month (or (car (cdr (assoc (string-downcase mstr) *month-name-alist* :test #'equal))) 0))
      (setq date-value (encode-universal-time sec min hour day month year 0))
      date-value
      )))
