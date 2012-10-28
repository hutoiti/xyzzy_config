;$Id: www-url.l,v 1.3 2005/11/24 15:12:27 torihat Exp $
;
; www-url.l
;
; by HATTORI Masashi

(provide "www/www-url")

(in-package "www")

; 基本パスとリンクパスをうまいこと結合する
(defun www-url-merge-path (url path)
  (let (res
	mer
	proto
	host
	file
	cnt
	anchor
	port
	merge
	dir)
    (setq dir (www-url-directory-namestring url))
    (multiple-value-setq (proto host file anchor port url)
      (www-url-study url))
    (multiple-value-setq (cnt merge)
      (www-path-convert path))
    (cond ((string-match *www-protocol-regexp* path)
	   path)
	  ((string-match "^file://" path)
	   path)
	  ((string-match "^#" path)
	   (concat url path))
	  ((string-match "^/" path)
	   (if port
	       (format nil "~A://~A:~D~A" proto host port path)
	     (format nil "~A://~A~A" proto host path)))
	  (t
	   (concat (www-path-up dir cnt) merge))
    )
  )
)

; ファイル名以外
(defun www-url-directory-namestring (url)
  (interactive)
  (cond ((string-match "^\\([^:]+://[^/]+\\)$" url)
	 (concat url "/"))
	((string-match "^\\(.*/\\)[^/]*$" url)
	 (substring url (match-beginning 1) (match-end 1)))
  )
)

; ファイル名だけ
(defun www-url-file-namestring (url)
  (interactive)
  (if (string-match "^.*/\\([^/]*\\)$" url)
      (substring url (match-beginning 1) (match-end 1))
    url))

; URLをばらばらにする
(defun www-url-study (url)
  (let (res
	port
	(proto "")
	(host "")
	(path "")
	anchor)
    (when (string-match "\\([^#]*\\)#\\(.*\\)" url)
      (setq anchor (substring url (match-beginning 2) (match-end 2)))
      (setq url (substring url (match-beginning 1) (match-end 1)))
    )
    (cond ((string-match "^file://\\(.*\\)$" url)
	   (progn
	     (setq proto "file")
	     (setq path (substring url
				    (match-beginning 1)
				   (match-end 1)))))
	  ((string-match "^mailto:" url)
	   (setq proto "mailto"))
	  ((string-match "^\\([^:]+\\)://\\([^:/]+\\):\\([0-9]+\\)/\\(.*\\)$" url)
	   (progn
	     (setq proto (substring url
				    (match-beginning 1)
				    (match-end 1)))
	     (setq host (substring url
				     (match-beginning 2)
				     (match-end 2)))
	     (setq port (parse-integer (substring url
						  (match-beginning 3)
						  (match-end 3))))
	     (setq path (substring url
				   (match-beginning 4)
				   (match-end 4)))
	   ))
	  ((string-match "^\\([^:]+\\)://\\([^/]+\\)/\\(.*\\)$" url)
	   (progn
	     (setq proto (substring url
				    (match-beginning 1)
				    (match-end 1)))
	     (setq host (substring url
				     (match-beginning 2)
				     (match-end 2)))
	     (setq path (substring url
				   (match-beginning 3)
				   (match-end 3)))))
	  ((string-match "^\\([^:]+\\)://\\([^/]+\\)$" url)
	   (progn
	     (setq proto (substring url
				    (match-beginning 1)
				    (match-end 1)))
	     (setq host (substring url
				     (match-beginning 2)
				     (match-end 2)))))
    )
    (values proto host path anchor port url)
  ))

; 指定数だけ上に上がる
(defun www-path-up (path cnt)
  (while (> cnt 0)
    (if (string-match "^\\(.*/\\)[^/]+/" path)
	(setq path (substring path (match-beginning 1) (match-end 1))))
    (setq cnt (1- cnt)))
  path)

; 相対パスを考える
(defun www-path-convert (path)
  (interactive)
  (let ((cnt 0) dir)
    (while (string-match "^\\([\.]+/\\)\\(.*\\)" path)
      (setq dir (substring path
			   (match-beginning 1)
			   (match-end 1)))
      (setq path (substring path
			    (match-beginning 2)
			    (match-end 2)))
      (when (string= dir "\.\./")
	(setq cnt (1+ cnt)))
    )
    (values cnt path)))

; URL encode (xyzzy-0.2.0.135以降)
(defun www-url-encode (str)
  (si:www-url-encode str))

#|
(defun www-url-encode (str)
  (with-output-to-string (s)
    (setq str (si:make-string-chunk str))
    (dotimes (i (- (si:chunk-size str) 1))
      (let ((char (code-char (si:unpack-uint8 str i))))
	(if (or (char> char #\z)
		(char< char #\-)
		(char< #\Z char #\a)
		(char< #\: char #\@))
	    (format s "~:@(%~2,'0x~)" (char-code char))
	  (write-char char s))
      )
    )
  )
)
|#
