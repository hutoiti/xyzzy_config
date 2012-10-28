; $Id: www-form.l,v 1.5 2005/12/21 14:58:24 torihat Exp $
;
; www-form.l
;
; by HATTORI Masashi

(provide "www/www-form")

(in-package "www")

;;;
;;; form
;;;
(defun www-tag-form-after (opts in)
  (setq www-form-data
	(cons (cons opts (reverse www-form-current)) www-form-data))
  (incf www-form-count 1)
  (setq www-form-current nil)
  (setq www-select-list nil)
)

(setf (get 'form 'www-after) 'www-tag-form-after)

;;;
;;; textarea
;;;
(defvar *www-textarea-mode-map* nil)
(setq *www-textarea-mode-map* (make-sparse-keymap))
(define-key *www-textarea-mode-map* '(#\C-x #\C-s) 'www-form-textarea-change)
(define-key *www-textarea-mode-map* #\C-g 'www-form-textarea-cancel)

(defun www-textarea-input-mode ()
  (make-local-variable 'www-textarea)
  (setq www-textarea nil)
  (make-local-variable 'www-return-marker)
  (setq www-return-marker nil)
  (make-local-variable 'www-return-point-end)
  (setq www-return-point-end nil)
  (setq buffer-mode 'www-textarea-input-mode)
  (setq mode-name "WWW TEXTAREA")
  (use-keymap *www-textarea-mode-map*)
)

(defun www-tag-textarea-after (opts in)
  (let ((beg (www-tag-get-option 'point opts))
	(name (www-tag-get-option 'name opts))
	value)
    (unless name
      (message-box "WWW: warning missing NAME in TEXTAREA")
      (return-from www-tag-textarea-after)
    )
    (setq value (buffer-substring beg (point)))
    (delete-region beg (point))
    (push (list 'value value) opts)
    (push (list 'type "textarea") opts)
    (push (list name opts) www-form-current)
    (www-form-textarea-insert opts)
  ))

(defun www-form-textarea-insert (opts &optional end)
  (let (beg
	(name (www-tag-get-option 'name opts))
	(rows (www-tag-get-option 'rows opts))
	(cols (www-tag-get-option 'cols opts))
	(string (www-tag-get-option 'value opts))
	lines
	str-len
	beg-marker)
    (if (and (stringp rows)
	     (string-match "^[0-9]+$" rows))
	(setq rows (parse-integer rows))
      (setq rows 5))
    (if (and (stringp cols)
	     (string-match "^[0-9]+$" cols))
	(setq cols (parse-integer cols))
      (setq cols 40))
    (when end
      (setq cols (- end (point)))
      (forward-char -1)
      (delete-region (point) (+ end 1)))
    (setq lines (split-string string "\n"))
    (setq string "")
    (when (stringp (car lines))
      (setq string (car lines)))
    (www-view-indent-print)
    (insert "[")
    (setq beg (point))
    (setq beg-marker (point-marker))
    ;(insert (format nil (format nil "~~~D@A" cols) (substring string 0 (min cols (length string)))))
    ;length‚Å‚Í‚©‚é
    (setq value (abbreviate-display-string string cols))
    (setq str-len (length value))
    (insert value)
    (insert " " (- cols str-len))
    (www-view-mark-string beg '((u) (form-element)))
    (unless end
      (push (list beg-marker (point-marker) 'textarea (list www-form-count name)) www-marker-link-alist))
    (insert "]")
;    (when (< www-width (current-column))
;      (save-excursion
;	(goto-char (1- beg))
;	(insert "\n")))
  ))

(setf (get 'textarea 'www-after) 'www-tag-textarea-after)

(defun www-form-textarea-input (val beg end)
  (let ((num (car val))
	(name (cadr val))
	form
	tag
	value
	marker
       )
    (goto-char beg)
    (setq marker (point-marker))
    (setq form (nth num www-form-data))
    (setq tag (cadr (assoc name form :test #'equal)))
    (when tag
      (setq value (or (cadr (assoc 'value tag)) ""))
      (switch-to-buffer *www-buffer-form-textarea*)
      (erase-buffer *www-buffer-form-textarea*)
      (www-textarea-input-mode)
      (setq www-textarea val)
      (setq www-return-marker marker)
      (setq www-return-point-end end)
      (insert value)
    )
  ))

(defun www-form-textarea-change ()
  (interactive)
  (let ((num (car www-textarea))
	(name (cadr www-textarea))
	(marker www-return-marker)
	(end www-return-point-end)
	form
	tag
	value)
    (setq value (buffer-substring (point-min) (point-max)))
    (www-form-textarea-change-1 num name marker end value)
    (delete-buffer *www-buffer-form-textarea*)
    ))

(defun www-form-textarea-change-1 (num name marker end value &optional norewrite)
  (interactive)
  (let (form
	tag)
    ;(msgbox "~{~S~%~}" (list num name marker end value))
    (switch-to-buffer (marker-buffer marker))
    (goto-char (marker-point marker))
    (setq form (nth num www-form-data))
    (setq tag (cadr (assoc name form :test #'equal)))
    (when value
      (if (assoc 'value tag)
	  (setf (cadr (assoc 'value tag)) value)
	(progn
	  (push (list 'value value) tag)
	  (setf (cadr (assoc name form :test #'equal)) tag)
	)
      )
      (when norewrite
	(return-from www-form-textarea-change-1))
      (let ((buffer-read-only nil))
	(declare (special buffer-read-only))
	(save-excursion
	  (www-form-textarea-insert tag end)
	  (www-view-put-text-attributes)
	)
	(forward-char 1)
      )
      (set-buffer-modified-p nil)
    )
  ))

(defun www-form-textarea-cancel ()
  (interactive)
  (let ((marker www-return-marker))
    (switch-to-buffer (marker-buffer marker))
    (goto-char (marker-point marker))
    (delete-buffer *www-buffer-form-textarea*)
  ))

;;;
;;; input
;;;
(defun www-form-input-after (opts in)
  (let ((name (www-tag-get-option 'name opts))
	(type (www-tag-get-option 'type opts)))
    (unless name
      (message "WWW: warning missing NAME on INPUT")
      ;(return-from www-form-input-after)
    )
    (push (list (or name "") opts) www-form-current)
    (cond ((or (not type)
	       (string-equal type "text"))
	   (www-form-input-text-insert opts)
	  )
	  ((string-equal type "password")
	   (www-form-input-password-insert opts)
	  )
	  ((string-equal type "checkbox")
	   (www-form-input-checkbox-insert opts)
	  )
	  ((string-equal type "hidden")
	  )
	  ((string-equal type "radio")
	   (www-form-input-radio-insert opts)
	  )
	  ((string-equal type "submit")
	   (www-form-input-submit-insert opts)
	  )
	  ((string-equal type "reset")
	   (www-form-input-reset-insert opts)
	  )
	  ((string-equal type "button")
	  )
	  ((string-equal type "image")
	  )
	  ((string-equal type "file")
	   (www-form-input-file-insert opts)
	  )
    );cond
  ))

(setf (get 'input 'www-after) 'www-form-input-after)

;
; textbox
;
(defun www-form-input-text-insert (opts &optional end)
  (let (beg
	(name (www-tag-get-option 'name opts))
	(value (or (www-tag-get-option 'value opts) ""))
	(size (www-tag-get-option 'size opts))
	beg-marker
	str-len)
    (if (and (stringp size)
	     (string-match "^[0-9]+$" size))
	(setq size (parse-integer size))
      (setq size 20))
    (when end
      (setq size (- end (point)))
      (forward-char -1)
      (delete-region (point) (+ end 1)))
    (www-view-indent-print)
    (insert "[")
    (setq beg (point))
    (setq beg-marker (point-marker))
    ;(insert (format nil (format nil "~~~D@A" size) (abbreviate-display-string value (- size 1))))
    ;length‚Å‚Í‚©‚é
    (setq value (abbreviate-display-string value size))
    (setq str-len (length value))
    (insert value)
    (insert " " (- size str-len))
    (www-view-mark-string beg '((u) (form-element)))
    (unless end
      (push (list beg-marker (point-marker) 'text (list www-form-count name)) www-marker-link-alist))
    (insert "]")
;    (when (< www-width (current-column))
;      (save-excursion
;	(goto-char (1- beg))
;	(insert "\n")))
  ))

(defun www-form-input-text-change (val beg end)
  (let ((num (car val))
	(name (cadr val))
	form
	tag
	value
       )
    (setq form (nth num www-form-data))
    (setq tag (cadr (assoc name form :test #'equal)))
    (setq value (read-string "Text: " :default (or (cadr (assoc 'value tag)) "")))
    (when value
      (if (assoc 'value tag)
	  (setf (cadr (assoc 'value tag)) value)
	(progn
	  (push (list 'value value) tag)
	  (setf (cadr (assoc name form :test #'equal)) tag)
	)
      )
      (let ((buffer-read-only nil))
	(declare (special buffer-read-only))
	(save-excursion
	  (goto-char beg)
	  (www-form-input-text-insert tag end)
	  (www-view-put-text-attributes)
	)
	(forward-char 1)
      )
      (set-buffer-modified-p nil)
    )
  ))

;
; password
;
(defun www-form-input-password-insert (opts &optional end)
  (let (beg
	(name (www-tag-get-option 'name opts))
	(value (or (www-tag-get-option 'value opts) ""))
	(size (www-tag-get-option 'size opts))
	len
	beg-marker
	(line "")
	str-len)
    (if (and (stringp size)
	     (string-match "^[0-9]+$" size))
	(setq size (parse-integer size))
      (setq size 20))
    (when end
      (setq size (- end (point)))
      (forward-char -1)
      (delete-region (point) (1+ end)))
    (www-view-indent-print)
    (insert "[")
    (setq beg (point))
    (setq beg-marker (point-marker))
    (if (< (- size 1) (length value))
	(setq len (- size 1))
      (setq len (length value)))
    (dotimes (i len)
      (setq line (concat line "*")))
    ;(insert (format nil (format nil "~~~D@A" size) line))
    ;length‚Å‚Í‚©‚é
    (setq line (abbreviate-display-string line size))
    (setq str-len (length line))
    (insert line)
    (insert " " (- size str-len))
    (www-view-mark-string beg '((u) (form-element)))
    (unless end
      (push (list beg-marker (point-marker) 'password (list www-form-count name)) www-marker-link-alist))
    (insert "]")
;    (when (< www-width (current-column))
;      (save-excursion
;	(goto-char (1- beg))
;	(insert "\n")))
  ))

(defun www-form-input-password-change (val beg end)
  (let ((num (car val))
	(name (cadr val))
	form
	tag
	value
       )
    (setq form (nth num www-form-data))
    (setq tag (cadr (assoc name form :test #'equal)))
    (setq value (www-get-password "Password: "
				  :default (or (cadr (assoc 'value tag)) "")))
    (when value
      (if (assoc 'value tag)
	  (setf (cadr (assoc 'value tag)) value)
	(progn
	  (push (list 'value value) tag)
	  (setf (cadr (assoc name form :test #'equal)) tag)
	)
      )
      (let ((buffer-read-only nil))
	(declare (special buffer-read-only))
	(save-excursion
	  (goto-char beg)
	  (www-form-input-password-insert tag end)
	  (www-view-put-text-attributes)
	)
	(forward-char 1)
      )
      (set-buffer-modified-p nil)
    )
  ))

;
; checkbox
;
(defun www-form-input-checkbox-insert (opts &optional end)
  (let (beg
	(name (www-tag-get-option 'name opts))
	(value (or (www-tag-get-option 'value opts) ""))
	(checked (www-tag-get-option 'checked opts))
	beg-marker
	check)
    (when end
      (forward-char -1)
      (delete-region (point) (+ end 1)))
    (if checked
	(setq check "*")
      (setq check " "))
    (www-view-indent-print)
    (when (< www-width (+ (current-column) 3))
      (insert "\n"))
    (insert "[")
    (setq beg (point))
    (setq beg-marker (point-marker))
    (insert check)
    (www-view-mark-string beg '((u) (form-element)))
    (unless end
      (push (list beg-marker (point-marker) 'checkbox (list www-form-count name)) www-marker-link-alist))
    (insert "]")
  ))

(defun www-form-input-checkbox-change (val beg end)
  (let ((num (car val))
	(name (cadr val))
	(value (caddr val))
	form
	len
	)
    (setq form (cdr (nth num www-form-data)))
    (setq len (list-length form))
    (dotimes (i len)
      (setq x (nth i form))
      (let ((rname (car x))
	    (rtag (cadr x))
	    rvalue
	    rtype
	    rchecked)
	(when (string= name rname)
	  (setq rvalue (cadr (assoc 'value rtag)))
	  (setq rtype (cadr (assoc 'type rtag)))
	  (when (and (stringp rtype)
		     (string-equal rtype "checkbox")
		     (stringp rvalue)
		     (string= value rvalue))
	    (setq rchecked (cadr (assoc 'checked rtag)))
	    (if rchecked
		(delete 'checked rtag :test #'eq :key #'car)
	      (push (list 'checked t) rtag))
	    (setf (cadr (nth i form)) rtag)
	    (let ((buffer-read-only nil))
	      (declare (special buffer-read-only))
	      (save-excursion
		(goto-char beg)
		(www-form-input-checkbox-insert rtag end)
		(www-view-put-text-attributes)
		)
	      (forward-char 1)
	      )
	    (set-buffer-modified-p nil)
	    (return)))))
    ))

;
; radio
;
(defun www-form-input-radio-insert (opts &optional end)
  (let (beg
	(name (www-tag-get-option 'name opts))
	(value (or (www-tag-get-option 'value opts) ""))
	(checked (www-tag-get-option 'checked opts))
	beg-marker
	check)
    (when end
      (forward-char -1)
      (delete-region (point) (+ end 1)))
    (if checked
	(setq check "*")
      (setq check " "))
    (www-view-indent-print)
    (when (< www-width (+ (current-column) 3))
      (insert "\n"))
    (insert "(")
    (setq beg (point))
    (setq beg-marker (point-marker))
    (insert check)
    (www-view-mark-string beg '((u) (form-element)))
    (unless end
      (push (list beg-marker (point-marker) 'radio (list www-form-count name value)) www-marker-link-alist))
    (insert ")")
  ))

(defun www-form-input-radio-change (val beg end)
  (let ((num (car val))
	(name (cadr val))
	(value (caddr val))
	form
	len
	tag
	checked
	radio
	x
       )
    (setq form (cdr (nth num www-form-data)))
    (setq len (list-length form))
    (dotimes (i len)
      (setq x (nth i form))
      (let ((rname (car x))
	    (rtag (cadr x))
	    rvalue
	    rtype
	    rchecked)
	(when (string= name rname)
	  (setq rvalue (cadr (assoc 'value rtag)))
	  (setq rtype (cadr (assoc 'type rtag)))
	  (when (and (stringp rtype)
		     (string-equal rtype "radio")
		     (stringp rvalue)
		     (string= value rvalue))
	    (setq rchecked (cadr (assoc 'checked rtag)))
	    (if rchecked
		(delete 'checked rtag :test #'eq :key #'car)
	      (progn
		(push (list 'checked t) rtag)
		(setq checked t)
	      )
	    )
	    (setf (cadr (nth i form)) rtag)
	    (return)
	  );when
	);when
      )
    );dolist
    (when checked
      (dotimes (i len)
	(setq x (nth i form))
	(let ((rname (car x))
	      (rtag (cadr x))
	      rvalue
	      rtype
	      rchecked)
	  (when (string= name rname)
	    (setq rvalue (cadr (assoc 'value rtag)))
	    (setq rtype (cadr (assoc 'type rtag)))
	    (when (and (stringp rtype)
		       (string-equal rtype "radio")
		       (stringp rvalue)
		       (not (string= value rvalue)))
	      (setq rchecked (cadr (assoc 'checked rtag)))
	      (when rchecked
		(delete 'checked rtag :test #'eq :key #'car)
		(setf (cadr (nth i form)) rtag)
	      )
	    );when
	  );when
	)
      );dolist
    );when
    (let ((buffer-read-only nil))
      (declare (special buffer-read-only))
      (save-excursion
	(goto-char beg)
	(www-form-input-radio-refresh num name)
	(www-view-put-text-attributes)
      )
      (forward-char 1)
    )
    (set-buffer-modified-p nil)
  ))

(defun www-form-input-radio-refresh (num name)
  (let ()
    (save-excursion
      (dolist (x www-link-register)
	(let* ((beg (car x))
	       (end (cadr x))
	       (tag (caddr x))
	       (val (cadddr x))
	       tnum
	       tname
	       tvalue
	       radio)
	  (when (listp val)
	    (setq tnum (car val))
	    (setq tname (cadr val))
	    (setq tvalue (caddr val))
	  )
	  (when (and tnum tname tvalue
		     (= num tnum)
		     (string= name tname))
	    ;(message-box (format nil "~S:~S:~S:~S:~S:~S" beg end tag tnum tname tvalue))
	    (setq radio (www-form-input-radio-get tnum tname tvalue))
	    ;(message-box (format nil "~S" radio))
	    (when radio
	      (goto-char beg)
	      (www-form-input-radio-insert radio end)
	    )
	  )
	)
      );dolist
    );save-excursion
  ))

(defun www-form-input-radio-get (num name value)
  (let (form)
    (setq form (cdr (nth num www-form-data)))
    (dolist (x form)
      (let ((rname (car x))
	    (rtag (cadr x))
	    rvalue
	    rtype
	    rchecked)
	(when (string= name rname)
	  (setq rvalue (cadr (assoc 'value rtag)))
	  (setq rtype (cadr (assoc 'type rtag)))
	  (when (and (string-equal rtype "radio")
		     (string= value rvalue))
	    (return-from www-form-input-radio-get rtag)
	  );when
	);when
      )
    );dolist
    nil
  ))

;
; file
;

(defun www-form-input-file-insert (opts &optional end)
  (let (beg
	(name (www-tag-get-option 'name opts))
	(value (or (www-tag-get-option 'value opts) ""))
	(size (www-tag-get-option 'size opts))
	beg-marker
	str-len)
    (if (and (stringp size)
	     (string-match "^[0-9]+$" size))
	(setq size (parse-integer size))
      (setq size 20))
    (when end
      (setq size (- end (point)))
      (forward-char -1)
      (delete-region (point) (+ end 1)))
    (www-view-indent-print)
    (insert "[")
    (setq beg (point))
    (setq beg-marker (point-marker))
    ;(insert (format nil (format nil "~~~D@A" size) (abbreviate-display-string value (- size 1))))
    ;length‚Å‚Í‚©‚é
    (setq value (abbreviate-display-string value size))
    (setq str-len (length value))
    (insert value)
    (when (< 0 (- size str-len))
      (insert " " (- size str-len)))
    (www-view-mark-string beg '((u) (form-element)))
    (unless end
      (push (list beg-marker (point-marker) 'file (list www-form-count name)) www-marker-link-alist))
    (insert "]")
;    (when (< www-width (current-column))
;      (save-excursion
;	(goto-char (1- beg))
;	(insert "\n")))
  ))

(defun www-form-input-file-change (val beg end)
  (let ((num (car val))
	(name (cadr val))
	form
	tag
	value
       )
    (setq form (nth num www-form-data))
    (setq tag (cadr (assoc name form :test #'equal)))
    (setq value (read-file-name "File: " :default (or (cadr (assoc 'value tag)) "")))
    (when value
      (if (assoc 'value tag)
	  (setf (cadr (assoc 'value tag)) value)
	(progn
	  (push (list 'value value) tag)
	  (setf (cadr (assoc name form :test #'equal)) tag)
	)
      )
      (let ((buffer-read-only nil))
	(declare (special buffer-read-only))
	(save-excursion
	  (goto-char beg)
	  (www-form-input-file-insert tag end)
	  (www-view-put-text-attributes)
	)
	(forward-char 1)
      )
      (set-buffer-modified-p nil)
    )
  ))

;
; submit
;
(defun www-form-input-submit-insert (opts)
  (let (beg
	(name (www-tag-get-option 'name opts))
	(value (www-tag-get-option 'value opts))
	beg-marker)
    (www-view-indent-print)
    (setq beg (point))
    (setq beg-marker (point-marker))
    (insert "[")
    (insert (or value "Submit"))
    (insert "]")
    (www-view-mark-string beg '((u) (form-element)))
    (push (list beg-marker (point-marker) 'submit (list www-form-count name value)) www-marker-link-alist)
;    (when (< www-width (current-column))
;      (save-excursion
;	(goto-char beg)
;	(insert "\n")))
  ))

(defun www-form-submit-form (val)
  (let ((num (car val))
	(name (cadr val))
	(value (caddr val))
	form
	action
	method
	enctype
	referer
	data
	formlist
	filelist
	add-headers
	string)
    (setq form (car (nth num www-form-data)))
    (setq action
	  (www-url-merge-path (or www-url-base www-url)
			      (or (www-tag-get-option 'action form) www-url)))
    (setq method (www-tag-get-option 'method form))
    (setq enctype (www-tag-get-option 'enctype form))
    (setq data (cdr (nth num www-form-data)))
    (when (and name value)
      (push (list name value) formlist)
    )
    (dolist (x data)
      (let* ((tag (cadr x))
	     (type (www-tag-get-option 'type tag))
	     (key (www-tag-get-option 'name tag))
	     (val (www-tag-get-option 'value tag))
	     add)
	(cond ((or (not type)
		   (string-equal type "text")
		   (string-equal type "password")
		   (string-equal type "hidden")
		   (string-equal type "textarea")
	       )
	       (when (and key val)
		 (push (list key val) formlist)
	       )
	      )
	      ((or (string-equal type "checkbox")
		   (string-equal type "radio"))
	       (let ((checked (www-tag-get-option 'checked tag)))
		 (when (and key val checked)
		   (push (list key val) formlist)
		 )
	       ))
	      ((string-equal type "select")
	       (let ((options (www-tag-get-option 'options tag))
		     y
		     z)
		 (multiple-value-setq (y z val)
		   (www-form-select-get options))
		 (setq key (car x))
		 (when (and key val)
		   (push (list key val) formlist)
		 )
	       ))
	      ((string-equal type "submit")
	      )
	      ((string-equal type "button")
	      )
	      ((string-equal type "image")
	      )
	      ((string-equal type "file")
	       (when (and key val)
		 (push (list key val) filelist)
		 )
	       )
	      );cond
	)
      );dolist
    (cond ((equalp enctype "multipart/form-data")
	   (let ((boundary (concat "X-Yzzy-" (si:md5 (format-date-string "%Y-%m-%d %H:%M:%S")))))
	     (push (cons "content-type"
			 (format nil "~A; boundary=~A" enctype boundary))
		   add-headers)
	     (setq string
		   (with-output-to-string (s)
		     (dolist (y (reverse formlist))
		       (let ((key (car y))
			     (val (cadr y)))
			 (when (and www-charset
				    (not (equal www-charset *encoding-auto*)))
			   (setq key (convert-encoding-from-internal www-charset key))
			   (setq val (convert-encoding-from-internal www-charset val)))
			 (when (< 0 (length key))
			   (format s "--~A~%" boundary)
			   (format s "Content-Disposition: form-data; name=\"~A\"~%" key)
			   (format s "~%")
			   (format s "~A~%" val))))
		     (dolist (y (reverse filelist))
		       (let ((key (car y))
			     (val (cadr y))
			     file)
			 (when (and www-charset
				    (not (equal www-charset *encoding-auto*)))
			   (setq key (convert-encoding-from-internal www-charset key))
			   (setq file (convert-encoding-from-internal www-charset val)))
			 (when (and val
				    (< 0 (length val))
				    (file-exist-p val))
			   (format s "--~A~%" boundary)
			   (format s "Content-Disposition: form-data; name=\"~A\"; filename=\"~A\"~%"
				   key
				   file)
			   (format s "Content-Type: application/octet-stream~%")
			   (format s "Content-Transfer-Encoding: binary~%")
			   (format s "~%")
			   (with-open-file (is
					    val
					    :encoding :binary)
			     (www-put-data-to-stream is s (file-length val)))
			   (format s "~%")
;			   (format s "Content-Transfer-Encoding: base64~%")
;			   (format s "~%")
;			   (with-open-file (is
;					    val
;					    :encoding :binary)
;			     (format s "~A~%" (si:base64-encode is)))
			   )))
		     (format s "--~A--~%" boundary)
		     )))
	   )
	  (t
	   (dolist (y (reverse formlist))
	     (let ((key (car y))
		   (val (cadr y))
		   add)
	       (when (and www-charset
			  (not (equal www-charset *encoding-auto*)))
		 (setq key (convert-encoding-from-internal www-charset key))
		 (setq val (convert-encoding-from-internal www-charset val)))
	       (if string
		   (setq string (format nil "~A&~A=~A" string (www-url-encode key) (www-url-encode val)))
		 (setq string (format nil "~A=~A" (www-url-encode key) (www-url-encode val)))
		 )))))
    (when (string-match "^http://" www-url)
      (setq referer www-url))
    (setq *www-history-future-list* nil)
    (www-history-back-add)
    (if (and (stringp method)
	     (string-equal method "post"))
	(www-open action
		  :post string
		  :referer referer
		  :other add-headers)
      (www-open (concat action "?" string)
		:referer referer)
      )))

;
; reset
;
(defun www-form-input-reset-insert (opts)
  (let (beg
	(name (www-tag-get-option 'name opts))
	(value (or (www-tag-get-option 'value opts) "Reset"))
	beg-marker)
    (www-view-indent-print)
    (setq beg (point))
    (setq beg-marker (point-marker))
    (insert "[")
    (insert value)
    (insert "]")
    (www-view-mark-string beg '((u) (form-element)))
    (push (list beg-marker (point-marker) 'reset (list www-form-count name)) www-marker-link-alist)
;    (when (< www-width (current-column))
;      (save-excursion
;	(goto-char beg)
;	(insert "\n")))
  ))

;;;
;;; select
;;;
(defun www-tag-select-after (opts in)
  (let ((name (www-tag-get-option 'name opts)))
    (unless name
      (message-box "WWW: warning missing NAME on SELECT")
      (return-from www-tag-select-after)
    )
    (push (list 'options (reverse www-select-current)) opts)
    (push (list 'type "select") opts)
    (push (list name opts) www-form-current)
    ;(message-box (format nil "~S" opts))
    (www-form-select-show opts)
    (setq www-select-current nil)
  ))

;(setf (get 'select 'www-before) 'www-tag-select-before)
(setf (get 'select 'www-after) 'www-tag-select-after)

(defun www-form-select-show (opts &optional end)
  (let ((len 0)
	(name (www-tag-get-option 'name opts))
	(options (www-tag-get-option 'options opts))
	string
	str-len
	beg
	beg-marker)
    (multiple-value-setq (string len)
      (www-form-select-get options))
    (when end
      (setq len (- end (point)))
      (forward-char -1)
      (delete-region (point) (1+ end)))
    (www-view-indent-print)
    (insert "[")
    (setq beg (point))
    (setq beg-marker (point-marker))
    ;(insert (format nil (format nil "~~~D@A" len) string))
    ;length‚Å‚Í‚©‚é
    (setq value (abbreviate-display-string string len))
    (setq str-len (length string))
    (insert string)
    (when (< str-len len)
      (insert " " (- len str-len)))
    (www-view-mark-string beg '((u) (form-element)))
    (unless end
      (push (list beg-marker (point-marker) 'select (list www-form-count name)) www-marker-link-alist))
    (insert "]")
;    (when (< www-width (current-column))
;      (save-excursion
;	(goto-char (1- beg))
;	(insert "\n")))
  ))

(defun www-form-select-get (options)
  (let ((count 0)
	(len 0)
	string
	val)
    (dolist (x options)
      (let ((value (www-tag-get-option 'string x))
	    (selected (www-tag-get-option 'selected x)))
	(when (stringp value)
	  (when (< len (* 2 (length value)))
	    (setq len (* 2 (length value)))))
	(when (or selected
		  (= count 0))
	  (setq string value)
	  (setq val (www-tag-get-option 'value x))
	)
      )
      (incf count 1)
    );dolist
    (values (or string "") len val)
  ))

(defun www-form-select-change (val beg end)
  (let ((num (car val))
	(name (cadr val))
	form
	tag
	options
	options-len
	opt-num
	targets
	string
	(menu (create-popup-menu))
	format-str-current
	)
    (setq form (nth num www-form-data))
    (setq tag (cadr (assoc name form :test #'equal)))
    (setq options (www-tag-get-option 'options tag))
    (setq options-len (list-length options))
    (dotimes (i options-len)
      (let* ((x (nth i options))
	     (value (www-tag-get-option 'string x))
	     (selected (www-tag-get-option 'selected x))
	     format-str)
	(when (stringp value)
	  (setq format-str (format nil "~D: ~A" (1+ i) value))
	  (when selected
	    (setq format-str-current format-str))
	  (add-menu-item menu
			 nil
			 value
			 #'(lambda ()
			     (interactive)
			     (www-form-select-change-do val beg end format-str))
			 #'(lambda ()
			     (when (equal format-str format-str-current)
			       :check))))
	))
    (track-popup-menu menu)
    ))

(defun www-form-select-change-do (val beg end result)
  (let ((num (car val))
	(name (cadr val))
	form
	tag
	options
	options-len
	opt-num
	)
    (setq form (nth num www-form-data))
    (setq tag (cadr (assoc name form :test #'equal)))
    (setq options (www-tag-get-option 'options tag))
    (setq options-len (list-length options))
    (when (and (stringp result)
	       (string-match "^[0-9]+" result))
      (setq opt-num (1- (parse-integer (substring result (match-beginning 0) (match-end 0)))))
      (dotimes (i options-len)
	(let* ((x (nth i options))
	       (selected (www-tag-get-option 'selected x)))
	  (if (= opt-num i)
	      (unless selected
		(push (list 'selected t) x)
		(setf (nth i options) x))
	    (when selected
	      (delete 'selected x :test #'eq :key #'car)
	      (setf (nth i options) x)))))
      (let ((buffer-read-only nil))
	(declare (special buffer-read-only))
	(save-excursion
	  (goto-char beg)
	  (www-form-select-show tag end)
	  (www-view-put-text-attributes))
	(forward-char 1))
      (set-buffer-modified-p nil)
      )))

;;;
;;; option
;;;
(defun www-tag-option-after (opts in)
  (let ((beg (www-tag-get-option 'point opts))
	string)
    (unless beg
      (message-box "WWW: option start point not found")
      (return-from www-tag-option-after)
    )
    (setq string (buffer-substring beg (point)))
    (delete-region beg (point))
    (setq string (string-trim " \t\n" string))
    (push (list 'string string) opts)
    (push opts www-select-current)
  ))

(setf (get 'option 'www-after) 'www-tag-option-after)
