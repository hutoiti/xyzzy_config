; $Id: www-w3m.l,v 1.8 2005/12/21 14:58:24 torihat Exp $
;
; www-w3m.l
;
; by HATTORI Masashi

(provide "www/www-w3m")

(require "www/www")

(in-package "www")

(defvar *www-w3m-command* "w3m")

(defvar *www-w3m-halfdump-command*
  '(
    "-halfdump"
    "-o ext_halfdump=1"
    "-o fix_width_conv=1"
    ;"-O EUC-JP"
    "-o display_charset=EUC-JP"
    "-o document_charset=Shift_JIS"
    ;"-T text/html"
    "-o ucs_conv=1"
    "-o use_jisx0201=1"
    ))

(defvar *www-w3m-charset-default* *encoding-euc-jp*)

(define-key *www-view-mode-map* #\3 'www-w3m-toggle)

(defun www-w3m-command (url &optional opts cols)
  (format nil "~A~{ ~A~}~@[ -cols ~D~] ~A"
	  *www-w3m-command*
	  opts
	  cols
	  url))

(defun www-w3m-halfdump (url &key post kcode)
  (let ((buf-src (www-buffer-src url post))
	(buf-view (www-buffer-view url post))
	(w3m-charset nil)
	temp
	(opts *www-w3m-halfdump-command*))
    (unless (find-buffer buf-src)
      (error "Source not found: ~A" buf-src))
    (unwind-protect
	(progn
	  (message "WWW: executing w3m ...")
	  (setq temp (make-temp-file-name "www-w3m-" "html"))
	  (save-excursion
	    (set-buffer buf-src)
	    (setq w3m-charset www-w3m-charset)
	    (write-region (point-min)
			  (point-max)
			  temp
			  nil
			  *encoding-binary*))
	  (set-buffer (get-buffer-create buf-view))
	  (erase-buffer (selected-buffer))
	  (let ((buffer-read-only nil))
	    (declare (special buffer-read-only))
	    (let ((command (www-w3m-command (map-slash-to-backslash temp)
					    opts
					    (window-columns)))
		  (*expected-fileio-encoding* *encoding-sjis*))
	      (declare (special *expected-fileio-encoding*))
	      ;(msgbox "~S" command)
	      (execute-shell-command command nil buf-view))
	    ;(replace-buffer "†" "")	; ???
	    (unless w3m-charset
	      (setq w3m-charset *www-w3m-charset-default*))
	    (cond ((eq w3m-charset *encoding-auto*)
		   (map-char-encoding-region (point-min) (point-max)))
		  (t
		   (map-char-encoding-region (point-min) (point-max) w3m-charset)
		   (when w3m-charset
		     (set-buffer-fileio-encoding w3m-charset))))
	    (goto-char (point-min))
	    ; for w3m-0.3
	    (unless (looking-for "<pre>")
	      (save-excursion
		(insert "<pre>")
		(goto-char (point-max))
		(insert "</pre>")))
	    (save-excursion
	      (insert "<html>")
	      (goto-char (point-max))
	      (insert "</html>"))
	    ))
      (message "WWW: executing w3m ... done.")
      (delete-file temp))))

(defvar *www-w3m-on* nil)
(defvar *www-w3m-func* nil)
(defvar *www-w3m-func-names* '((www-open-view . www-open-view-w3m)
			       (www-reread . www-reread-w3m)))

(defun www-w3m-toggle (&optional arg sv)
  (interactive "p")
  (when (and arg *www-w3m-on*)
    (return-from www-w3m-toggle))
  (ed::toggle-mode '*www-w3m-on* arg sv)
  (if *www-w3m-on*
      (mapc #'(lambda (x)
		(let ((orig (car x))
		      (new (cdr x)))
		  (setf (get '*www-w3m-func* orig) (symbol-function orig))
		  (setf (symbol-function orig) (symbol-function new))))
	    *www-w3m-func-names*)
    (mapc #'(lambda (x)
	      (let ((orig (car x)))
		(setf (symbol-function orig) (get '*www-w3m-func* orig))))
	  *www-w3m-func-names*))
  (when (eq buffer-mode 'www-view-mode)
    (www-reread))
  (message "WWW: w3m ~:[off~;on~]." *www-w3m-on*))

(defvar *www-w3m-form-tags*
  '(;("form" . "form_int")
    ;("textarea" . "textarea_alt")
    ;("input" . "input_alt")
    ))

;;;
;;; form_int
;;;
(defun www-tag-form_int-after (opts in)
  (setq www-form-data
	(cons (cons opts (reverse www-form-current)) www-form-data))
  (incf www-form-count 1)
  (setq www-form-current nil)
)
(setf (get 'form_int 'www-after) 'www-tag-form_int-after)
(setf (get 'form_int 'www-close-tag-open) '(form_int internal))
(setf (get 'form_int 'www-close-tag-close) '(body html))
#|
(setf (get 'form_int 'www-after) 'www-tag-form-after)
(setf (get 'form_int 'www-close-tag-open) '(form_int))
(setf (get 'form_int 'www-close-tag-close) '(body html))
|#

;;;
;;; input_alt
;;;
(defun www-form-input_alt-after (opts in)
  (let ((fid (www-tag-get-option 'fid opts))
	(name (www-tag-get-option 'name opts))
	(type (www-tag-get-option 'type opts)))
    (unless name
      (message "WWW: warning missing NAME on INPUT"))
    (when (cond ((or (not type)
		     (string-equal type "text"))
		 (www-form-input_alt-text-insert opts in)
		 t)
		((string-equal type "password")
		 (www-form-input_alt-password-insert opts in)
		 t)
		((string-equal type "checkbox")
		 (www-form-input_alt-checkbox-insert opts in)
		 t)
		((string-equal type "hidden")
		 t)
		((string-equal type "radio")
		 (www-form-input_alt-radio-insert opts in)
		 t)
		((string-equal type "textarea")
		 (www-form-input_alt-textarea-insert opts in)
		 t)
		((string-equal type "submit")
		 (www-form-input_alt-submit-insert opts in)
		 t)
		((string-equal type "reset")
		 (www-form-input_alt-reset-insert opts in)
		 t)
		((string-equal type "select")
		 (www-form-input_alt-select-insert opts in)
		 nil)
		((string-equal type "button")
		 t)
		((string-equal type "clear")
		 t)
		((string-equal type "image")
		 (www-form-input_alt-submit-insert opts in)
		 t)
		((string-equal type "file")
		 (www-form-input_alt-file-insert opts in)
		 t)
		)
      (push (list (or name "") opts) www-form-current))
    ))

(setf (get 'input_alt 'www-after) 'www-form-input_alt-after)

(defun www-form-input_alt-text-insert (opts in)
  (www-form-input_alt-insert opts in 'text))

(defun www-form-input_alt-file-insert (opts in)
  (www-form-input_alt-insert opts in 'file))

(defun www-form-input_alt-password-insert (opts in)
  (www-form-input_alt-insert opts in 'password))

(defun www-form-input_alt-checkbox-insert (opts in)
  (www-form-input_alt-insert opts in 'checkbox))

(defun www-form-input_alt-radio-insert (opts in)
  (www-form-input_alt-insert opts in 'radio))

(defun www-form-input_alt-submit-insert (opts in)
  (www-form-input_alt-insert opts in 'submit))

(defun www-form-input_alt-reset-insert (opts in)
  (www-form-input_alt-insert opts in 'reset))

(defun www-form-input_alt-textarea-insert (opts in)
  (www-form-input_alt-insert opts in 'textarea))

(defun www-form-input_alt-select-insert (opts in)
  (let (beg-marker
	str-len
	(tag 'select)
	(name (www-tag-get-option 'name opts))
	(value (or (www-tag-get-option 'value opts) ""))
	(beg (www-tag-get-option 'point opts))
	(num (parse-integer (www-tag-get-option 'selectnumber opts)))
	end-marker)
    (save-excursion
      ;(forward-char -1)
      (setq end-marker (point-marker))
      (goto-char beg)
      (setq beg-marker (point-marker)))
    (www-view-mark-string beg '((u) (form-element)))
    (push (list beg-marker end-marker tag (list www-form-count name value)) www-marker-link-alist)
    (push (list num name www-form-count) www-select-list)
    ))

(defun www-form-input_alt-insert (opts in tag)
  (let (beg-marker
	str-len
	(name (www-tag-get-option 'name opts))
	(value (or (www-tag-get-option 'value opts) ""))
	(beg (www-tag-get-option 'point opts))
	end-marker)
    (save-excursion
      ;(forward-char -1)
      (setq end-marker (point-marker))
      (goto-char beg)
      (setq beg-marker (point-marker)))
    (www-view-mark-string beg '((u) (form-element)))
    (push (list beg-marker end-marker tag (list www-form-count name value)) www-marker-link-alist)
    (when (eq tag 'textarea)
      (unless (local-variable-p 'www-textarea-alt-list)
	(make-local-variable 'www-textarea-alt-list)
	(setq www-textarea-alt-list nil))
      (push (list (parse-integer (www-tag-get-option 'textareanumber opts))
		  www-form-count name opts beg-marker end-marker)
	    www-textarea-alt-list))
    ))

;;;
;;; option_int
;;;
(defun www-tag-option_int-after (opts in)
  (let ((beg (www-tag-get-option 'point opts))
	(value (or (www-tag-get-option 'value opts) ""))
	(string (or (www-tag-get-option 'label opts) "")))
    (unless beg
      (message-box "WWW: option start point not found")
      (return-from www-tag-option_int-after)
    )
    (push (list 'string string) opts)
    (push opts www-select-current)
    ;(msgbox "~S~%~S" opts www-select-current)
    ))

(setf (get 'option_int 'www-after) 'www-tag-option_int-after)
(setf (get 'option_int 'www-close-tag-open) '(option_int select_int form))
(setf (get 'option_int 'www-close-tag-close) '(option_int select_int form))

;;;
;;; select_int
;;;
(defun www-tag-select_int-after (opts in)
  (let* ((num (parse-integer (www-tag-get-option 'selectnumber opts)))
	 (name (cadr (assoc num www-select-list)))
	 (formcnt (caddr (assoc num www-select-list)))
	 cnt)
    (unless name
      (message-box "WWW: warning missing NAME on SELECT")
      (return-from www-tag-select_int-after)
    )
    (setq cnt (- (length www-form-data) 1 formcnt))
    (push (list 'options (reverse www-select-current)) opts)
    (push (list 'type "select") opts)
    (setf (cdr (nth cnt www-form-data))
	  (cons (list name opts) (cdr (nth cnt www-form-data))))
    (setq www-select-current nil)
    ))

(setf (get 'select_int 'www-after) 'www-tag-select_int-after)

;;;
;;; textarea_int
;;;
(defun www-tag-textarea_int-after (opts in)
  (let* ((beg (www-tag-get-option 'point opts))
	 (num (parse-integer (www-tag-get-option 'textareanumber opts)))
	 (value (buffer-substring beg (point)))
	 (curp (point))
	 alt)
    (when (local-variable-p 'www-textarea-alt-list)
      (setq alt (assoc num www-textarea-alt-list)))
    (unless alt
      (message-box "WWW: warning missing TEXTAREA")
      (return-from www-tag-textarea_int-after))
    (multiple-value-bind (tnum form-count name topts beg-marker end-marker)
	(values-list alt)
      (www-form-textarea-change-1 (- (length www-form-data) 1 form-count)
				  name
				  beg-marker
				  (marker-point end-marker)
				  value
				  t))
    (goto-char curp)
    ))

(setf (get 'textarea_int 'www-after) 'www-tag-textarea_int-after)

(defun www-w3m-form-tags-convert ()
  (dolist (tag *www-w3m-form-tags*)
    (let ((orig (concat "\\(</?\\)" (cdr tag)))
	  (targ (concat "\\1" (car tag))))
      (goto-char (point-min))
      (replace-buffer orig targ :regexp t)))
  (goto-char (point-max))
  (insert "</html>")
  (goto-char (point-min))
  (insert "<html>")
  (goto-char (point-min)))

(defun www-open-view-w3m (buf-src buf-view &key url status header kcode post type anchor)
  (if (find-buffer buf-view)
      (switch-to-buffer buf-view)
    (when (catch 'reload
	    (progn
	      (if (string-matchp "text/html" type)
		  (www-w3m-halfdump url :post post :kcode kcode)
		(progn
		  (set-buffer (get-buffer-create buf-view))
		  (erase-buffer (selected-buffer))
		  (insert-buffer buf-src)
		  (map-char-encoding-region (point-min) (point-max))))
	      (goto-char (point-min))
	      ;(www-yahoo-delete-unknown-string);Yahoo! Japanï∂éöâªÇØëŒçÙ
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
		(if (string-matchp "text/html" type)
		    (let (html)
		      (www-delete-comment)
		      (www-w3m-form-tags-convert)
		      (setq html (www-parse-html))
		      (when html
			(delete-region (point-min) (point-max))
			(www-view-html (reverse html))))
		  (progn
		    (www-convert-crlf)
		    (goto-char (point-min)))))
	      (set-buffer-modified-p nil))
	    nil)
      (www-open-view buf-src
		     buf-view
		     :url url
		     :status status
		     :header header
		     :kcode www-charset
		     :post post
		     :type type
		     :anchor anchor)))
  (when anchor
    (www-view-goto-anchor anchor)))

(defun www-reread-w3m (&optional kcode)
  (interactive)
  (let* ((url www-url)
	 (post www-post-data)
	 (sbuf (www-buffer-src url post))
	 (vbuf (www-buffer-view url post)))
    (delete-buffer (selected-buffer))
    (set-buffer sbuf)
    (when kcode
      (setq www-charset kcode)
      (setq www-w3m-charset kcode))
    (www-open url
	      :post post)
  ))

(defun www-w3m-local-charset-variable ()
  (make-local-variable 'www-w3m-charset)
  (setq www-w3m-charset nil))

(add-hook '*www-src-mode-hook* 'www-w3m-local-charset-variable)
;(add-hook '*www-view-mode-hook* 'www-w3m-local-charset-variable)

;;<img_alt src="...">alt</img_alt>
(defun www-tag-img-alt-after (opts in)
  (let ((src (www-tag-get-option 'src opts))
	(beg (www-tag-get-option 'point opts))
	(end-marker (point-marker)))
    (www-view-mark-string beg in)
    (when src
      (setq src (www-url-merge-path (or www-url-base www-url) src))
      (save-excursion
	(goto-char beg)
	(push (list (point-marker) end-marker src) www-marker-img-alist)
      ))
  ))

(setf (get 'img_alt 'www-after) 'www-tag-img-alt-after)

;; overwrite
(defun www-tag-title-after (opts in)
  (let ((beg (www-tag-get-option 'point opts)))
    (when beg
      (setq www-page-title (string-trim " \t\n" (buffer-substring beg (point))))
      (delete-region beg (point)))))

;; <title_alt title="Page Title">
(defun www-tag-title-alt-after (opts in)
  (let ((beg (www-tag-get-option 'point opts))
	(title (www-tag-get-option 'title opts)))
    (setq www-page-title title)
    (when beg
      (delete-region beg (point)))))

(pushnew 'title_alt *www-tag-single-list*)
(setf (get 'title_alt 'www-after) 'www-tag-title-alt-after)

;; <internal></internal>
(defun www-tag-internal-after (opts in)
  (let ((beg (www-tag-get-option 'point opts)))
    (when beg
      (delete-region beg (point)))))

(setf (get 'internal 'www-after) 'www-tag-internal-after)

;; for test ...
(defun user::w3m-test-halfdump ()
  (interactive)
  (www-w3m-halfdump www-url))

(defun user::w3m-test-form-show ()
  (interactive)
  (let ((str (with-output-to-string (s)
	       (mapc #'(lambda (x)
			 (mapc #'(lambda (y)
				   (format s "~S~%" y))
			       x))
		     www-form-data))))
    (copy-to-clipboard str)
    (message-box str)))
