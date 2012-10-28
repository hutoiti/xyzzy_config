; $Id: www.l,v 1.8 2005/12/21 14:58:24 torihat Exp $
;
; www.l
;
; by HATTORI Masashi

(defpackage "www"
  (:use "lisp" "editor"))

(require "www/overlay")
(require "www/www-tag")
(require "www/www-http")
(require "www/www-url")
(require "www/www-misc")
(require "www/www-parse")
(require "www/www-view")
(require "www/www-form")
(require "www/www-bookmark")
(require "www/www-auth")
(require "www/www-ftp")
(require "www/www-update")

(provide "www/www")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "www/www-tag")
  (require "www/www-cookie"))

(defun www ()
  (interactive)
  (www::www-start))

(defun www-open-url (page)
  (interactive "sOpen page: ")
  (www::www-open-remote page))

(defun www-open-local-file (file)
  (interactive "fOpen file: ")
  (www::www-open-local file))

(defun www-open-current-buffer ()
  (interactive)
  (www::www-open-current-buffer-file))

(in-package "www")

(defvar *version* "0.0.1.6")
(defvar *www-version* (concat "www-" *version*))
(defvar *www-user-agent* (concat *www-version* " on xyzzy-" (software-version)))
(defvar *www-port* 80)

(defvar *www-package* (find-package "www"))

(defvar *www-start-page* (concat "file://" *www-bookmark-file*))

(defvar *www-save-directory* (default-directory))

(defvar *www-protocol-regexp* "^\\(http\\|mailto\\|ftp\\|news\\):")

(defvar *www-init* nil)

(defvar *www-config-file* "~/.www")

(defvar *www-anon-ftp-user* "anonymous")
(defvar *www-anon-ftp-pass* nil)

(defvar *www-authorization-alist* nil)
(defvar *www-authorization-proxy* nil)

(defvar *www-history-back-list* nil)
(defvar *www-history-forward-list* nil)
(defvar *www-history-alist* nil)

(defvar *www-mailer-func* #'(lambda (addr) (shell-execute addr t)))

(defvar *www-use-previous-encoding* nil)
(defvar *www-previous-encoding* *encoding-auto*)

(defvar *www-pframe-name* "WWW")

(defvar *www-buffer-name-prefix* "*WWW ")
(defvar *www-buffer-src-prefix*
  (concat *www-buffer-name-prefix* "SRC: "))
(defvar *www-buffer-source-prefix*
  (concat *www-buffer-name-prefix* "SOURCE: "))
(defvar *www-buffer-view-prefix*
  (concat *www-buffer-name-prefix* "VIEW: "))
(defvar *www-buffer-temp*
  (concat *www-buffer-name-prefix* "TEMP*"))
(defvar *www-buffer-work*
  (concat *www-buffer-name-prefix* "WORK*"))
(defvar *www-buffer-wget*
  (concat *www-buffer-name-prefix* "WGET:"))
(defvar *www-buffer-form-textarea*
  (concat *www-buffer-name-prefix* "TEXTAREA*"))

(defvar *www-show-status-message* t)

(defun www-start ()
  (interactive)
  (www-init)
  (let (page
	*minibuffer-default-history*)
    (declare (special *minibuffer-default-history*))
    (setq *minibuffer-default-history*
	  (mapcar #'car *www-history-alist*))
    (setq page (completing-read "Open page: "
				*www-history-alist*
				:default (or *www-start-page*
					     "")))
    (when page
      (www-open page))
  ))

(defun www-init ()
  (let ((frame (find-pseudo-frame *www-pframe-name*)))
    (if frame
	(select-pseudo-frame frame)
      (new-pseudo-frame *www-pframe-name*))
    (unless *www-init*
      (www-config-read)
      (www-bookmark-open)
      (setq *www-history-back-list* nil)
      (setq *www-history-forward-list* nil)
      (unless *www-history-alist*
	(when *www-start-page*
	  (push (list *www-start-page*) *www-history-alist*))
      )
      (www-tag-set-colors)
      (when *www-cookie-enable*
	(cookie-load))
      (setq *www-init* t)
    )))

(defun www-config-read ()
  (when (and *www-config-file*
	     (file-exist-p *www-config-file*))
    (load *www-config-file*)))

(defun www-open-remote (&optional page)
  (interactive)
  (www-init)
  (unless page
    (let (*minibuffer-default-history*)
      (declare (special *minibuffer-default-history*))
      (setq *minibuffer-default-history*
	    (mapcar #'car *www-history-alist*))
      (setq page (completing-read "Open page: "
				  *www-history-alist*
				  :default (or www-url
					       (car *minibuffer-default-history*)
					       *www-start-page*
					       "")))
    ))
  (when page
    (setq *www-history-forward-list* nil)
    (www-history-back-add)
    (www-open page)
  )
)

(defun www-open-local (file)
  (interactive "fOpen file: ")
  (www-init)
  (setq *www-history-forward-list* nil)
  (when (string-match *www-buffer-name-prefix* (buffer-name (selected-buffer)))
    (www-history-back-add)
  )
  (www-open (concat "file://" file)))

(defun www-open-current-buffer-file ()
  (interactive)
  (let ((path (get-buffer-file-name)))
    (when path
      (www-open-local path))
  ))

(defun www-open-in-other-browser (&optional url)
  (interactive)
  (setq url (or url www-url))
  (when (string-match "^file://" url)
    (setq url (substring url (match-end 0)))
  )
  (shell-execute url t)
)

(defun www-open-in-mailer (addr)
  (interactive)
  (unless *www-mailer-func*
    (error "メーラーが指定されていません。"))
  (funcall *www-mailer-func* addr)
)

(defun www-open-link-in-other-browser ()
  (interactive)
  (let (tag val)
    (multiple-value-setq (tag val)
      (www-view-point-link))
    (cond ((eq tag 'href)
	   (if val
	       (www-open-in-other-browser val)
	     (message "リンクじゃないっす")
	   ))
	  (t
	   (message "リンクじゃないっす")
	  )
    );cond
  ))

(defvar *www-src-mode-map* nil)
(setq *www-src-mode-map* (make-sparse-keymap))
(define-key *www-src-mode-map* #\RET 'www-src-to-view)
(define-key *www-src-mode-map* #\SPC 'next-page)
(define-key *www-src-mode-map* #\C-h 'previous-page)
(define-key *www-src-mode-map* #\q 'www-exit-all)
(define-key *www-src-mode-map* #\Q 'www-exit)

(defvar *www-src-mode-hook* nil)
(defvar *www-source-mode-hook* nil)

(defun www-src-mode ()
  (make-local-variable 'www-url)    ; URL
  (setq www-url nil)
  (make-local-variable 'www-http-status) ;HTTP status
  (setq www-http-status nil)
  (make-local-variable 'www-http-header) ; Header
  (setq www-http-header nil)
  (make-local-variable 'www-charset)
  (setq www-charset nil)
  (make-local-variable 'www-http-content-type)
  (setq www-http-content-type nil)
  (setq buffer-mode 'www-src-mode)
  (setq mode-name "WWW SRC")
  (use-keymap *www-src-mode-map*)
  (setq buffer-read-only t)
  (make-local-variable 'need-not-save)
  (setq need-not-save t)
  (run-hooks '*www-src-mode-hook*)
)

(defun www-source-mode ()
  (make-local-variable 'www-src-buffer)
  (setq www-src-buffer nil)
  (setq buffer-mode 'www-source-mode)
  (setq mode-name "WWW SOURCE")
  (use-keymap *www-src-mode-map*)
  (setq buffer-read-only t)
  (make-local-variable 'need-not-save)
  (setq need-not-save t)
  (run-hooks '*www-source-mode-hook*)
)

(defun www-open (url &key save kcode no-cache referer post auth other)
  (let (proto
	host
	path
	anchor
	port
	status
	header
	type
	html
	buf-src
	buf-view
       )
    (long-operation
      (when (and (interactive-p)
		 (string-match "^[a-zA-Z]:" url))
	(setq url (format nil "file://~A" url))
      )
      (multiple-value-setq (proto host path anchor port url)
	(www-url-study url))
      (setq buf-src (www-buffer-src url post))
      (setq buf-view (www-buffer-view url post))
      (if (and (not save)
	       (find-buffer buf-src))
	  (progn
	    (set-buffer buf-src)
	    (setq url www-url)
	    (setq status www-http-status)
	    (setq header www-http-header)
	    (setq type www-http-content-type)
	    (setq kcode www-charset)
	  )
	(progn
	  ; Protocolによる分岐
	  (cond ((string= "ftp" proto) ;;;; FTP
		 (let (file)
		   (setq file (www-url-file-namestring url))
		   (www-ftp-get host path file port)
		   (return-from www-open)
		 ))
		((string= "mailto" proto) ;;;; MAIL TO
		 (progn
		   (www-open-in-mailer url)
		   (return-from www-open)
		 ))
		((string= "file" proto) ;;;; Local File
		 (progn
		   (set-buffer (get-buffer-create buf-src))
		   (setq kcode (or kcode *encoding-auto*))
		   ;(insert-file-contents path)
		   (www-insert-file-contents path *encoding-sjis*)
		   (set-buffer-modified-p nil)
		   (www-src-mode)
		   (setq www-url url)
		   (if (string-match "\.html?$" path)
		       (setq type "text/html")
		     (setq type "")
		   )
		   (setq www-http-content-type type)
		 )
		)
		((string= "http" proto) ;;;; HTTP
		 (let (socket tempfile length savename)
		   ; ヘッダーの取得
		   (multiple-value-setq (socket status header)
		     (www-http-get-url url
				       :no-cache no-cache
				       :referer referer
				       :post post
				       :auth auth
				       :other other)
		   )
		   (unless (or socket status header)
		     (error "[Scoket: ~S]~%[Status: ~S]~%[Header: ~S]" socket status header)
		   )
		   ;;; STATUSによる分岐
		   (cond ((string-match "^3[0-9][0-9]" status) ; => Redirect
			  (let ((location (www-get-header-value "location" header)))
			    (when location
			      (setq socket nil)
			      ; 再度自分を呼ぶ
			      (www-open (www-url-merge-path url location)
					:save save
					:kcode kcode
					:no-cache no-cache
					:other other)
			      (return-from www-open)
			    )
			  ))
			 ((string-match "^401" status)         ; => Unauthorized
			  (when (www-auth-get-type header)
			    ;認証をセットして自分を呼ぶ
			    (setq auth (www-auth-read-account host (not auth)))
			    (www-open url
				      :save save
				      :kcode kcode
				      :no-cache no-cache
				      :post post
				      :auth auth
				      :other other)
			    (return-from www-open)
			  ))
		   );cond
		   (setq type (string-downcase (or (www-get-header-value "content-type" header) "")))
		   ; text/????でなければファイルに保存
		   (unless (string-matchp "text" type)
		     (setq save t))
		   ; encoding
		   (unless kcode
		     (setq kcode (www-get-encode type))
		   )
		   ; data length
		   (setq length (www-get-header-value "content-length" header))
		   (if (and length
			    (string-match "^[0-9]+$" length))
		       (setq length (parse-integer length))
		     (setq length nil)
		   )
		   ; 保存ファイル名をユーザーから取得
		   (when save
		     (setq savename (www-get-savename (www-url-file-namestring url))))
		   (if (and save savename)
		       (progn
			 ; データをファイルに保存
			 (www-get-data-to-file socket savename length)
			 (message "WWW: saved ~A" savename)
			 (return-from www-open)
		       )
		     ; データをSRCバッファに入れる
		     (www-get-http-data buf-src
					socket
					length
					:url url
					:status status
					:header header
					:kcode kcode
					:type type)
		   )
		 ))
		(t
		 (error "できまへん: ~A" url))
	  );cond
	);progn
      );if
      ; ページの表示
      (www-open-view buf-src
		     buf-view
		     :url url
		     :status status
		     :header header
		     :kcode kcode
		     :post post
		     :type type
		     :anchor anchor)
      (pushnew (list url) *www-history-alist* :key #'car :test #'equal)
    );long-operation
  ))

(defun www-open-view (buf-src buf-view &key url status header kcode post type anchor)
  (when (catch 'reload
	  (if (find-buffer buf-view)
	      (switch-to-buffer buf-view)
	    (progn
	      (set-buffer (get-buffer-create buf-view))
	      (erase-buffer (selected-buffer))
	      (insert-buffer buf-src)
	      (goto-char (point-min))
	      ;(www-yahoo-delete-unknown-string);Yahoo! Japan文字化け対策
	      (www-view-mode)
	      (let ((buffer-read-only nil))
		(declare (special buffer-read-only))
		(setq www-url url)
		(setq www-http-status status)
		(setq www-http-header header)
		(setq www-charset kcode)
		(setq www-post-data post)
		(when *www-use-previous-encoding*
		  (setq *www-previous-encoding* kcode))
		(cond ((string-matchp "text/html" type)
		       (if (eq kcode *encoding-auto*)
			   (map-char-encoding-region (point-min) (point-max))
			 (progn
			   (map-char-encoding-region (point-min) (point-max) kcode)
			   (when kcode
			     (set-buffer-fileio-encoding kcode))
			   ))
		       (let (html)
			 (www-delete-comment)
			 ;(refresh-screen)
			 ;(message-box "here1-beg")
			 ;(www-w3m-form-tags-convert)
			 ;(refresh-screen)
			 ;(message-box "here1-end")
			 (setq html (www-parse-html))
			 (when html
			   (delete-region (point-min) (point-max))
			   (www-view-html (reverse html)))))
;		      ((string-matchp "text/xml" type)
;		       (let ((xml (xmlpm-parse)))
;			 (delete-region (point-min) (point-max))
;			 (insert (format nil "~{~S~%~}" xml))))
		      (t
		       (if (eq kcode *encoding-auto*)
			   (map-char-encoding-region (point-min) (point-max))
			 (progn
			   (map-char-encoding-region (point-min) (point-max) kcode)
			   (when kcode
			     (set-buffer-fileio-encoding kcode))
			   ))
		       (www-convert-crlf)
		       (goto-char (point-min))))
		)
	      (set-buffer-modified-p nil)))
	  nil)
    (www-open-view buf-src
		   buf-view
		   :url url
		   :status status
		   :header header
		   :kcode www-charset
		   :post post
		   :type type
		   :anchor anchor))
  (when anchor
    (www-view-goto-anchor anchor)))

(defun www-get-http-data (buf-src socket length &key url status header kcode type)
  (set-buffer (get-buffer-create buf-src))
  (erase-buffer (selected-buffer))
  (www-get-data socket length)
  ;(www-yahoo-delete-unknown-string);Yahoo! Japan文字化け対策
  (set-buffer-modified-p nil)
  (www-src-mode)
  (setq www-url url)
  (setq www-http-status status)
  (setq www-http-header header)
  (setq www-http-content-type type)
  (setq www-charset kcode)
)

(defun www-insert-file-contents (file &optional encode)
  (let (( *expected-fileio-encoding* (or encode *encoding-auto*)))
    (declare (special *expected-fileio-encoding*))
    (insert-file-contents file)
  ))

(defun www-get-encode (type)
  ;(message-box type)
  (let (charset encoding)
    (when (and (stringp type)
	       (string-matchp "charset=\\([-_a-zA-Z0-9]+\\)" type))
      (setq charset (substring type (match-beginning 1) (match-end 1))))
    ;(message-box (format nil "charset: ~S" charset))
    (if (and charset
	     (setq encoding (gethash charset *mime-charset-name-hash-table*)))
	(progn
	  ;(message-box (format nil "encoding: ~S" encoding))
	  encoding)
      (if *www-use-previous-encoding*
	  *www-previous-encoding*
	*encoding-auto*))))

(defun www-exit-all ()
  (interactive)
  (when (yes-or-no-p "WWW: やめて全部閉じる？")
    (www-exit)))

(defun www-exit ()
  (interactive)
  (dolist (x (buffer-list))
    (let ((buf (buffer-name x)))
      (when (string-match *www-buffer-name-prefix* buf)
	(kill-buffer buf))
    )
  )
  (let ((frame (find-pseudo-frame *www-pframe-name*)))
    (when frame
      (delete-pseudo-frame frame)))
  (setq *www-init* nil)
  (message "WWW: exiting ... done"))

(defun www-history-back-add ()
  (setq *www-history-back-list*
	(cons (point-marker) *www-history-back-list*)))

(defun www-history-forward-add ()
  (setq *www-history-forward-list*
	(cons (point-marker) *www-history-forward-list*)))

(defun www-history-back ()
  (interactive)
  (if *www-history-back-list*
      (let (marker)
	(setq marker (car *www-history-back-list*))
	(setq *www-history-back-list* (cdr *www-history-back-list*))
	(www-history-forward-add)
	(switch-to-buffer (marker-buffer marker))
	(goto-char (marker-point marker)))
    (message "これ以上戻るところはないっす")
  ))

(defun www-history-next ()
  (interactive)
  (if *www-history-forward-list*
      (let (marker)
	(setq marker (car *www-history-forward-list*))
	(setq *www-history-forward-list* (cdr *www-history-forward-list*))
	(www-history-back-add)
	(switch-to-buffer (marker-buffer marker))
	(goto-char (marker-point marker)))
    (message "これ以上進むところはないっす")
  ))

#|
(defun www-view-to-src ()
  (interactive)
  (let ((buf (www-buffer-src)))
    (if (find-buffer buf)
	(switch-to-buffer buf)
      (message "Source not found: ~A" buf)
    )))

(defun www-src-to-view ()
  (interactive)
  (let ((buf (www-buffer-view)))
    (if (find-buffer buf)
	(switch-to-buffer buf)
      (www-open url))))
|#

(defun www-view-to-src ()
  (interactive)
  (let ((encoding www-charset)
	(src (www-buffer-src))
	(source (www-buffer-source)))
    (unless (find-buffer src)
      (message "Source not found: ~A" src)
      (return-from www-view-to-src))
    (set-buffer (get-buffer-create source))
    (www-source-mode)
    (setq www-src-buffer src)
    (let ((buffer-read-only nil))
      (declare (special buffer-read-only))
      (erase-buffer (selected-buffer))
      (insert-buffer src)
      (if (equal encoding *encoding-auto*)
	  (map-char-encoding-region (point-min) (point-max))
	(map-char-encoding-region (point-min) (point-max) encoding))
      (goto-char (point-min)))))

(defun www-src-to-view ()
  (interactive)
  (when (equal buffer-mode 'www-source-mode)
    (unless www-src-buffer
      (error "戻れません"))
    (set-buffer www-src-buffer))
  (let ((buf (www-buffer-view)))
    (if (find-buffer buf)
	(switch-to-buffer buf)
      (www-open url))))

(defun www-buffer-src (&optional url post)
  (let ((targ (or url www-url)))
    (unless targ
      (return-from www-buffer-src))
    (concat *www-buffer-src-prefix* targ (if post (concat " " (si:md5 post) "")))
  ))

(defun www-buffer-source (&optional url post)
  (let ((targ (or url www-url)))
    (unless targ
      (return-from www-buffer-source))
    (concat *www-buffer-source-prefix* targ (if post (concat " " (si:md5 post)) ""))
  ))

(defun www-buffer-view (&optional url post)
  (let ((targ (or url www-url)))
    (unless targ
      (return-from www-buffer-view))
    (concat *www-buffer-view-prefix* targ (if post (concat " " (si:md5 post)) ""))
  ))

(defun www-reread (&optional kcode)
  (interactive)
  (let* ((url www-url)
	 (post www-post-data)
	 (sbuf (www-buffer-src url post))
	 (vbuf (www-buffer-view url post)))
    (delete-buffer (selected-buffer))
    (set-buffer sbuf)
    (when kcode
      (setq www-charset kcode))
    (www-open url
	      :post post)
  ))

(defun www-reread-as ()
  (interactive)
  (track-popup-menu (www-encoding-menu www-charset)))

(defun www-encoding-lock-toggle ()
  (interactive)
  (when (setq *www-use-previous-encoding*
	      (not *www-use-previous-encoding*))
    (setq *www-previous-encoding* www-charset)))

(defun www-encoding-menu (&optional encode)
  (interactive)
  (unless encode
    (setq encode *encoding-auto*))
  (let ((menu (create-popup-menu nil)))
    (dolist (enc *char-encoding-list*)
      (let ((encoding enc))
	(add-menu-item menu
		       nil
		       (char-encoding-display-name encoding)
		       #'(lambda ()
			   (interactive)
			   (www-reread encoding))
		       #'(lambda ()(when (eq encoding encode) :check)))
      ))
    menu
  ))
