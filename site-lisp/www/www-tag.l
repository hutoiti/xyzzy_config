; $Id: www-tag.l,v 1.4 2005/11/24 15:12:27 torihat Exp $
;
; www-tag.l
;
; by HATTORI Masashi

(provide "www/www-tag")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "www/overlay"))

(in-package "www")

(defvar *www-link-fgcolor* 4)
(defvar *www-link-bgcolor* nil)

(defvar *www-form-fgcolor* 1)

(defvar *www-tag-list-char* '("・" "◇" "☆" "〇" "□"))

(defvar *www-overlay-fgcolor* 4)
(defvar *www-overlay-bgcolor* 3)

(defvar *www-link-overlay*
  (create-overlay (create-overlay-attr nil t nil *www-overlay-fgcolor* *www-overlay-bgcolor* nil nil)
		  (create-overlay-attr nil nil nil *www-link-fgcolor* *www-link-bgcolor* nil nil)))

(defvar *www-tag-single-list* '(br
				hr
				input
				img
				link
				meta
				base
				isindex
				frame
			       ))

(defvar *www-tag-nochange-list* '(pre
				  xmp
				  listing
				  plaintext
				  textarea
				 ))

(defvar *www-tag-indent-list* '(ul
				ol
				li
				dd
				blockquote
				frameset;とりあえず
			       ))

(defvar *www-tag-h-list* '(h1 h2 h3 h4 h5 h6))

(defvar *www-tag-paragraph-list*
  (append '(p
	    div
	    hr
	    tr;とりあえず
	    blockquote
	    dl dt dd
	    ul
	    ol
	    form
	   )
	  *www-tag-h-list*
  ))

(defvar *www-tag-trim-list*
  (append *www-tag-paragraph-list*
	  '(li
	    td
	    th
	    title
	    table
	    tr
	    html
	    head
	    body
	    form
	    option
	    select
	    frameset
	    frame
	   )
  ))

;;
;; 自分以外の自分を閉じるタグ（？）
;;
(setf (get 'li 'www-close-tag-open) '(li))
(setf (get 'li 'www-close-tag-close) '(ul li ol))

(setf (get 'tr 'www-close-tag-open) '(tr))
(setf (get 'tr 'www-close-tag-close) '(tr table))

(setf (get 'td 'www-close-tag-open) '(td th tr))
(setf (get 'td 'www-close-tag-close) '(td th tr table))

(setf (get 'th 'www-close-tag-open) '(td th tr))
(setf (get 'th 'www-close-tag-close) '(td th tr table))

(setf (get 'option 'www-close-tag-open) '(option select form))
(setf (get 'option 'www-close-tag-close) '(option select form))

(setf (get 'dt 'www-close-tag-open) '(dt dd))
(setf (get 'dt 'www-close-tag-close) '(dl dt dd))

(setf (get 'dd 'www-close-tag-open) '(dt dd))
(setf (get 'dd 'www-close-tag-close) '(dl dt dd))

(setf (get 'a 'www-close-tag-open) '(a link))

(setf (get 'form 'www-close-tag-open) '(form))
(setf (get 'form 'www-close-tag-close) '(body html))

;;
;; text-attribute
;;

; bold
(dolist (x '(b h1 h2 h3 h4 h5 h6 strong em big var))
  (setf (get x 'www-bold) t))
; italic
(dolist (x '(i cite address))
  (setf (get x 'www-italic) t))
; underline
(dolist (x '(u))
  (setf (get x 'www-underline) t))
; strike-out
(setf (get 'strike 'www-strike-out) t)
(setf (get 's 'www-strike-out) t)

; overlay
(setf (get 'a 'www-overlay) t)

(defun www-tag-set-colors ()
  ; foreground
  (setf (get 'a 'www-foreground) *www-link-fgcolor*)
  (setf (get 'form-element 'www-foreground) *www-form-fgcolor*)
  ; overlay
  (setq *www-link-overlay*
	(create-overlay (create-overlay-attr nil t nil *www-overlay-fgcolor* *www-overlay-bgcolor* nil nil)
			(create-overlay-attr nil nil nil *www-link-fgcolor* *www-link-bgcolor* nil nil)))
  (setf (get 'www-link 'overlay) *www-link-overlay*)
)

(www-tag-set-colors)

(defmacro www-tag-name (tag)
  `(car ,tag))

(defmacro www-tag-opt (tag)
  `(cadr ,tag))

(defmacro www-tag-get-option (key opts)
  `(cadr (assoc ,key ,opts)))

(defmacro www-tag-trim-ok-p (tag)
  `(member (www-tag-name ,tag) *www-tag-trim-list*))

(defmacro www-tag-nochange-p (tag)
  `(member (www-tag-name ,tag) *www-tag-nochange-list*))

(defmacro www-tag-indent-p (tag)
  `(member (www-tag-name ,tag) *www-tag-indent-list*))

(defmacro www-tag-paragraph-p (tag)
  `(member (www-tag-name ,tag) *www-tag-paragraph-list*))

(defmacro www-tag-close-p (tag)
  `(assoc 'close (www-tag-opt ,tag)))

(defmacro www-tag-is-close-for-p (otag ctag)
  `(let ((oname (www-tag-name ,otag))
	 (cname (www-tag-name ,ctag)))
     (cond ((www-tag-close-p ,ctag)
	    (member cname (www-tag-close-for-close oname)))
	   (t
	    (member cname (www-tag-close-for-open oname))))))

(defmacro www-tag-close-for-open (tag)
  `(get ,tag 'www-close-tag-open))

(defmacro www-tag-close-for-close (tag)
  `(get ,tag 'www-close-tag-close))

(defmacro www-tag-single-p (tag rest)
  `(let ((tname (www-tag-name ,tag)))
     (cond ((eq tname 'p)
	    (www-tag-p-is-single-p ,rest))
	   ((eq tname 'a)
	    (www-tag-a-is-single-p ,tag ,rest))
	   (t
	    (member tname *www-tag-single-list*)))))

(defun www-tag-p-is-single-p (rest)
  (dolist (x rest)
    (when (listp x)
      (let ((tname (www-tag-name x)))
	(when (eq tname 'p)
	  (if (www-tag-close-p x)
	      (return-from www-tag-p-is-single-p nil)
	    (return-from www-tag-p-is-single-p t)
	  )
	)
      )
    )
  );dolist
  t
)

(defun www-tag-a-is-single-p (tag rest)
  (let ((opts (www-tag-opt tag)))
    (when (www-tag-get-option 'href opts)
      (return-from www-tag-a-is-single-p nil))
    (dolist (x rest)
      (when (listp x)
	(let ((tname (www-tag-name x)))
	  (when (eq tname 'a)
	    (if (www-tag-close-p x)
		(return-from www-tag-a-is-single-p nil)
	      (return-from www-tag-a-is-single-p t)
	    )
	  )
	)
      )
    );dolist
    t
  ))

(defun www-tag-paragraph-open ()
  (if (bolp)
      (unless (www-blank-line-p -1)
	(insert "\n"))
    (insert "\n\n")
  ))

;;;
;;;
;;; 各タグの設定
;;;
;;;

;;; td, th (とりあえず)
(defun www-tag-td-after (opts in)
  (insert "\t")
)

(setf (get 'td 'www-after) 'www-tag-td-after)
(setf (get 'th 'www-after) 'www-tag-td-after)

;;; br
(defun www-tag-br-after (opts in)
  (insert "\n")
)

(setf (get 'br 'www-after) 'www-tag-br-after)

;;; hr
(defun www-tag-hr-after (opts in)
  (when (not (bolp))
    (insert "\n"))
  (www-view-indent-print)
  (insert "-" (- www-width (current-column)))
  (insert "\n")
)

(setf (get 'hr 'www-after) 'www-tag-hr-after)

;;; ol
(defun www-tag-ol-before (opts in)
  (let ((start (www-tag-get-option 'start opts)))
    (if (and (stringp start)
	     (string-match "^[0-9]+$" start))
	(push (parse-integer start) www-tag-ol-number)
      (push 1 www-tag-ol-number)
    )
  ))

(defun www-tag-ol-after (opts in)
  (pop www-tag-ol-number))

(defun www-tag-ol-in (in)
  (when www-tag-ol-number
    (dolist (tag in)
      (cond ((eq (www-tag-name tag) 'ul)
	     (return-from www-tag-ol-in))
	    ((eq (www-tag-name tag) 'ol)
	     (return-from www-tag-ol-in t))
      )
    )
  )
  nil
)

(setf (get 'ol 'www-before) 'www-tag-ol-before)
(setf (get 'ol 'www-after) 'www-tag-ol-after)

;;; li
(defun www-tag-list-char (num)
  (nth (rem num (list-length *www-tag-list-char*)) *www-tag-list-char*))

(defun www-tag-li-before (opts in)
  (when (not (bolp))
    (insert "\n"))
  (www-view-indent-print)
  (if (www-tag-ol-in in)
      (let ((curn (car www-tag-ol-number)))
	(insert (format nil "~2D. " curn))
	(setf (car www-tag-ol-number) (1+ curn))
      )
    (insert (format nil " ~A " (www-tag-list-char www-view-indent-level)))
  )
)

(defun www-tag-li-after (opts in)
  (unless (bolp)
    (insert "\n"))
)

(setf (get 'li 'www-before) 'www-tag-li-before)
(setf (get 'li 'www-after) 'www-tag-li-after)

;;; head

(defun www-tag-head-after (opts in)
  (delete-region (point-min) (point))
)

(setf (get 'head 'www-after) 'www-tag-head-after)

;;; img

(defun www-tag-img-after (opts in)
  (let ((alt (www-tag-get-option 'alt opts))
	(src (www-tag-get-option 'src opts))
	beg
	end-marker)
    (when (and (stringp alt) (string-match "^[ \t]*$" alt))
      (setq alt nil))
    (www-view-indent-print)
    (setq beg (point))
    (insert (format nil "[~A]" (or alt "IMG")))
    (www-view-mark-string beg in)
    (when src
      (setq src (www-url-merge-path (or www-url-base www-url) src))
      (save-excursion
	(setq end-marker (point-marker))
	(goto-char beg)
	(push (list (point-marker) end-marker src) www-marker-img-alist)
      ))
  ))

(setf (get 'img 'www-after) 'www-tag-img-after)

;;; a

;(defun www-tag-a-before (opts in)
;  (let ((anc (www-tag-get-option 'name opts)))
;    (when anc
;      (push (list (point-marker) anc) www-marker-anchor-alist)
;    )
;  ))

(defun www-tag-a-after (opts in)
  (let ((anc (or (www-tag-get-option 'name opts)
		 (www-tag-get-option 'id opts)))
	(href (www-tag-get-option 'href opts))
	(beg (www-tag-get-option 'point opts))
	(end-marker (point-marker)))
    (when (stringp anc)
      (save-excursion
	(when beg
	  (goto-char beg))
	(push (list (point-marker) anc) www-marker-anchor-alist)
      )
    )
    (when (and beg (stringp href))
      (setq href (www-url-merge-path (or www-url-base www-url) href))
      (setq href (substitute-string href "&amp;" "&"))
      (save-excursion
	(goto-char beg)
	(skip-chars-forward " \t\n")
	(push (list (point-marker) end-marker 'href href) www-marker-link-alist)
      )
    )
  ))

;(setf (get 'a 'www-before) 'www-tag-a-before)
(setf (get 'a 'www-after) 'www-tag-a-after)

;;; title
(defun www-tag-title-after (opts in)
  (let ((beg (www-tag-get-option 'point opts)))
    (when beg
      (setq www-page-title (string-trim " \t\n" (buffer-substring beg (point)))))
  ))

(setf (get 'title 'www-after) 'www-tag-title-after)

;;; base
(defun www-tag-base-after (opts in)
  (let ((href (www-tag-get-option 'href opts)))
    (when href
      (setq www-url-base href))
  ))

(setf (get 'base 'www-after) 'www-tag-base-after)

;;; frame
(defun www-tag-frame-after (opts in)
  (let ((src (www-tag-get-option 'src opts))
	(name (www-tag-get-option 'name opts))
	beg-marker
	(beg (point)))
    (when src
      (setq src (www-url-merge-path (or www-url-base www-url) src))
      (www-tag-li-before nil nil)
      (setq beg-marker (point-marker))
      (insert (format nil "[FRAME: ~A]" (or name src)))
      (push (list beg-marker (point-marker) 'href src) www-marker-link-alist)
      (www-view-mark-string beg '((link)))
      (www-tag-li-after nil nil)
    )
  ))

(setf (get 'frame 'www-after) 'www-tag-frame-after)

;;; p
(defun www-tag-p-after (opts in)
  (let ((align (www-tag-get-option 'align opts))
	(beg (www-tag-get-option 'point opts)))
    (when (and beg (stringp align))
      (when (< beg (point-min))
	(setq beg (point-min)))
      (cond ((string-equal "center" align)
	     (www-view-align-center beg (point)))
	    ((string-equal "right" align)
	     (www-view-align-right beg (point)))
      )
    )
  ))

(dolist (x '(p h1 h2 h3 h4 h5 h6 div))
  (setf (get x 'www-after) 'www-tag-p-after))

;;; center
(defun www-tag-center-after (opts in)
  (let ((beg (www-tag-get-option 'point opts)))
    (when beg
      (when (< beg (point-min))
	(setq beg (point-min)))
      (www-view-align-center beg (point))
    )
  ))

(setf (get 'center 'www-after) 'www-tag-center-after)

