; $Id: www-view.l,v 1.8 2005/12/21 14:58:24 torihat Exp $
;
; www-view.l
;
; by HATTORI Masashi

(provide "www/www-view")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "www/www-tag")
  (require "www/www-http"))

(in-package "www")

(defvar *www-view-debug* nil)

(defvar *www-view-mode-hook* nil)

(defvar *www-view-mode-map* nil)
(setq *www-view-mode-map* (make-sparse-keymap))
(define-key *www-view-mode-map* #\RET 'www-view-goto-link)
(define-key *www-view-mode-map* #\LBtnDown 'www-mouse-left-press)
(define-key *www-view-mode-map* #\RBtnDown 'mouse-nop)
(define-key *www-view-mode-map* #\RBtnUp 'www-mouse-right-press)
(define-key *www-view-mode-map* #\SPC 'next-page)
(define-key *www-view-mode-map* #\n 'next-page)
(define-key *www-view-mode-map* #\b 'previous-page)
(define-key *www-view-mode-map* #\TAB 'www-view-next-link)
(define-key *www-view-mode-map* #\M-Down 'www-view-next-link)
(define-key *www-view-mode-map* #\M-Up 'www-view-previous-link)
(define-key *www-view-mode-map* #\M-Left 'www-history-back)
(define-key *www-view-mode-map* #\M-Right 'www-history-next)
(define-key *www-view-mode-map* #\S 'www-view-to-src)
(define-key *www-view-mode-map* #\s 'www-view-save-link)
(define-key *www-view-mode-map* #\w 'www-wget-download)
(define-key *www-view-mode-map* #\I 'www-view-save-img)
(define-key *www-view-mode-map* #\i 'www-view-open-img-in-other-browser)
(define-key *www-view-mode-map* #\g 'www-open-remote)
(define-key *www-view-mode-map* #\f 'www-open-local)
(define-key *www-view-mode-map* #\r 'www-reread-as)
(define-key *www-view-mode-map* #\R 'www-view-reload)
(define-key *www-view-mode-map* #\L 'www-view-show-link)
(define-key *www-view-mode-map* #\O 'www-open-in-other-browser)
(define-key *www-view-mode-map* #\o 'www-open-link-in-other-browser)
(define-key *www-view-mode-map* #\A 'www-bookmark-add-current)
(define-key *www-view-mode-map* #\B 'www-bookmark-show)
(define-key *www-view-mode-map* #\u 'www-update-pages)
(define-key *www-view-mode-map* #\U 'www-update-add-current)
(define-key *www-view-mode-map* #\q 'www-exit-all)
(define-key *www-view-mode-map* #\Q 'www-exit)
(define-key *www-view-mode-map* #\h 'www-view-list-popup)
(define-key *www-view-mode-map* #\C-F10 'www-view-list-popup)
;(set-function-bar-label #\C-F10 "www View List")

(defun www-view-mode ()
  (make-local-variable 'www-width)       ; windowの幅
  (setq www-width (- (window-columns) 5))
;  (set-buffer-fold-width www-width)     ; 折り返しの幅
  (make-local-variable 'www-url)         ; URL
  (setq www-url nil)
  (make-local-variable 'www-url-base)    ; baseパス
  (setq www-url-base nil)
  (make-local-variable 'www-http-status) ;HTTP status
  (setq www-http-status nil)
  (make-local-variable 'www-http-header) ; Header
  (setq www-http-header nil)
  (make-local-variable 'www-page-title)  ; Title
  (setq www-page-title nil)
  (make-local-variable 'www-post-data)
  (setq www-post-data nil)
  (make-local-variable 'www-charset)
  (setq www-charset nil)
  (make-local-variable 'www-view-indent-level)   ; インデント
  (setq www-view-indent-level 0)
  (make-local-variable 'www-tag-ol-number)       ; <OL>内の数
  (setq www-tag-ol-number nil)
  (make-local-variable 'www-marker-attributes)   ; テキスト属性仮リスト
  (setq www-marker-attributes nil)
  (make-local-variable 'www-marker-link-alist)   ; ページ内リンク仮リスト
  (setq www-marker-link-alist nil)
  (make-local-variable 'www-link-register); ページ内リンク保存リスト
  (setq www-link-register nil)
  (make-local-variable 'www-marker-img-alist)   ; ページ内画像リンク仮リスト
  (setq www-marker-img-alist nil)
  (make-local-variable 'www-img-register); ページ内画像リンク保存リスト
  (setq www-img-register nil)
  (make-local-variable 'www-marker-anchor-alist) ; ページ内アンカー仮リスト
  (setq www-marker-anchor-alist nil)
  (make-local-variable 'www-anchor-register); ページ内アンカー保存リスト
  (setq www-anchor-register nil)
  (make-local-variable 'www-form-data)
  (setq www-form-data nil)
  (make-local-variable 'www-form-count)
  (setq www-form-count 0)
  (make-local-variable 'www-form-current)
  (setq www-form-current nil)
  (make-local-variable 'www-select-current)
  (setq www-select-current nil)
  (make-local-variable 'www-select-list)
  (setq www-select-list nil)
  (make-local-variable '*post-command-hook*)
  (add-hook '*post-command-hook* 'overlay-handler)
;  (set-local-window-flags (selected-buffer)
;			  *window-flag-line-number* nil)
;  (set-local-window-flags (selected-buffer)
;			  *window-flag-newline* nil)
;  (set-local-window-flags (selected-buffer)
;			  *window-flag-eof* nil)
;  (set-local-window-flags (selected-buffer)
;			  *window-flag-tab* nil)
;  (set-local-window-flags (selected-buffer)
;			  *window-flag-zenkaku-space* nil)
  (use-keymap *www-view-mode-map*)            ; キーマップ
  (setq buffer-read-only t)
  (make-local-variable 'need-not-save)
  (setq need-not-save t)
  (setq buffer-mode 'www-view-mode)
  (setq mode-name "WWW VIEW")
  (run-hooks '*www-view-mode-hook*)
)

(defun www-view-html (html)
  (let (element
	in
	out
	now
	(len (list-length html))
	(processed 0)
       )
    (message "WWW: formatting ...")
    (www-interval-message (300)
      (while html
	(setq element (car html))
	(cond ((stringp element)
	       (www-view-insert-string element in))
	      ((listp element)
	       (let ((tname (www-tag-name element))
		     (opt (www-tag-opt element)))
		 (multiple-value-setq (in out)
		   (www-view-tag-out element in))
		 (when out
		   (dolist (x out)
		     (www-view-after-print x in)
		   )
		 )
		 (cond ((www-tag-close-p element)
		       )
		       ((www-tag-single-p element (cdr html))
			(progn
			  (www-view-after-print element in)
			))
		       (t
			(let ((tname (www-tag-name element))
			      (opt (www-tag-opt element)))
			  (push (list 'point (point)) opt)
			  (setf (nth 1 element) opt)
			  (push element in)
			  (setq now element)
			  (www-view-before-print element in)
			))
		 );cond
	       ))
	);cond
	(when *www-view-debug*
	  (insert (format nil "~%[ELEMENT:~S]~%" element))
	  (insert (format nil "[INDENT:~D]~%" www-view-indent-level))
	  (insert (format nil "[IN:~S]~%" in))
	)
	(setq html (cdr html))
	(when *www-show-status-message*
	  (incf processed 100)
	  (message "WWW: formatting ... ~3D%" (truncate processed len))
	  ;(message "WWW: formatting ... ~3D%" (truncate (/ (* 100 (- len (list-length html))) len)))
	  ;(sit-for 0)
	)
      ))
    (www-view-put-text-attributes)
    (www-view-marker-link-register)
    (www-view-marker-img-register)
    (www-view-marker-anchor-register)
    
    (when www-form-data
      (setq www-form-data (reverse www-form-data)))
    (set-buffer-modified-p nil)
    (goto-char (point-min))
    (message "WWW: formatting ... done")
  ))

(defun www-view-insert-string (element in)
  (let (beg
	lines
	(nochange (www-view-nochange-p in))
	(pre-char (preceding-char))
       )
    (when nochange
      (setq beg (point))
      (insert element)
      (www-view-mark-string beg in)
      (return-from www-view-insert-string)
    )
    (when (or (not (bolp))
	      (string-match "[^ \t\n]" element))
      (when (or (char= pre-char #\SPC)
		(char= pre-char #\TAB)
		(char= pre-char #\RET))
	(setq element (string-left-trim " \t" element))
      )
      (setq element (www-view-remove-spaces element))
      (www-view-indent-print)
      (setq beg (point))
      (insert element)
      (www-view-fold-line)
      (www-view-mark-string beg in)
    )
;    (dotimes (i (list-length lines))
;      (let ((line (nth i lines)))
;	(when (or (not (bolp))
;		  (string-match "[^ \t\n]" line)
;		  nochange)
;	  (when (or (looking-back " ")
;		    (looking-back "\n")
;		    (looking-back "\t"))
;	    (setq line (string-left-trim " \t" line))
;	  )
;	  (www-view-indent-print)
;	  (setq beg (point))
;	  (insert line)
;	  (unless (= (1+ i) (list-length lines))
;	    (insert "\n"))
;	  ;(www-view-convert-special-chars beg (point))
;	  (unless nochange
;	    ;(www-view-remove-spaces beg (point))
;	    (www-view-fold-line)
;	  )
;	  (www-view-mark-string beg in)
;	)
;      )
;    );dolist
  ))

(defun www-view-before-print (tag in)
  (when (www-tag-paragraph-p tag)
    (www-tag-paragraph-open))
  (let ((tname (www-tag-name tag))
	(opts (www-tag-opt tag))
	func)
    (setq func (get tname 'www-before))
    (when func
      (funcall func opts in))
    (when (www-tag-indent-p tag)
      (www-view-indent-increment))
  ))

(defun www-view-after-print (tag in)
  (when (www-tag-paragraph-p tag)
    (www-tag-paragraph-open))
  (let* ((tname (www-tag-name tag))
	 (opts (www-tag-opt tag))
	 (id (www-tag-get-option 'id opts))
	 (beg (www-tag-get-option 'point opts))
	 func)
    (setq func (get tname 'www-after))
    (when func
      (funcall func opts in))
;    (when (and (stringp id)
;	       (not (eq tname 'a)))
;      (save-excursion
;	(when beg
;	  (goto-char beg))
;	(push (list (point-marker) id) www-marker-anchor-alist)))
    (when (www-tag-indent-p tag)
      (www-view-indent-decrement))
  ))

(defun www-view-tag-out (tag in)
  (let ((tname (www-tag-name tag))
	target
	targetname
	before
	(after in)
	out)
    (while after
      (setq target (car after))
      (setq targetname (www-tag-name target))
      (setq after (cdr after))
      (cond ((www-tag-close-p tag)
	     (cond ((eq targetname tname)
		    (progn
		      (push target out)
		      (return-from www-view-tag-out (values (nreconc before after) (nreverse out)))
		    ))
		   ((www-tag-is-close-for-p target tag)
		    (push target out))
		   (t
		    (push target before))
	     );cond
	    )
	    (t
	     (cond ((www-tag-is-close-for-p target tag)
		    (push target out))
		   (t
		    (push target before))
	     );cond
	    )
      );cond
    );while
    (values (nreverse before) out)
  ))

(defun www-view-indent-increment ()
  (incf www-view-indent-level 1)
)

(defun www-view-indent-decrement ()
  (when (< 0 www-view-indent-level)
    (incf www-view-indent-level -1)
  ))

(defun www-view-indent-print ()
  (when (bolp)
    (insert " ");;;
    (insert "    " www-view-indent-level)
  ))

(defvar *www-view-word-chars-regexp* "[-a-zA-Z0-9_:/~#]+")

(defun www-view-fold-line ()
  (save-excursion
    (loop
      (kinsoku-goto-column www-width)
      (when (save-excursion (skip-chars-backward " \t") (bolp))
	(goto-column www-width))
      (and (eolp)
	   (return))
      (forward-char 1)
      (insert "\n")
      (www-view-indent-print))))

;(defun www-view-fold-line ()
;  (save-excursion
;    (while (< www-width (current-column))
;;      (goto-column www-width)
;      (kinsoku-goto-column www-width)
;;      (skip-chars-backward "^ \t")
;;      (when (bolp)
;;	(goto-column www-width))
;      (insert "\n")
;      (www-view-indent-print)
;      (goto-eol)
;    )
;  ))

;(defun www-view-html-convert (beg end)
;  (save-excursion
;    (save-restriction
;      (narrow-to-region beg end)
;      (www-view-remove-spaces)
;      (www-view-convert-special-chars)
;    )
;  ))

(defun www-view-trim-ok-p (in)
  (dolist (tag in)
    (unless (www-tag-trim-ok-p tag)
      (return-from www-view-trim-ok-p nil)
    )
  )
  t
)

(defun www-view-nochange-p (in)
  (dolist (tag in)
    (when (www-tag-nochange-p tag)
      (return-from www-view-nochange-p t)
    )
  )
  nil
)

(defun www-view-remove-spaces (str)
  (substitute-string str "[ \t\n]+" " "))

;(defun www-view-remove-spaces (beg end)
;  (let (pchar string)
;    (save-excursion
;      (goto-char beg)
;      (setq pchar (preceding-char))
;      (save-restriction
;	(narrow-to-region beg end)
;	(goto-char (point-min))
;	(replace-buffer "[ \t\r\n]+" " " :regexp t)
;	(when (or (eq pchar #\SPC)
;		  (eq pchar #\LFD))
;	  (goto-char (point-min))
;	  (replace-buffer "^[ \t]+" "" :regexp t)
;	)
;	;(goto-char (point-min))
;	;(replace-buffer "[ \t]+$" "" :regexp t)
;	(setq string (buffer-substring (point-min) (point-max)))
;      )
;    )
;    string
;  ))

;(defun www-view-convert-special-chars (str)
;  (dolist (y *www-special-chars-alist*)
;    (let ((from (car y))
;	  (to (cdr y)))
;      (setq str (substitute-string str from to))
;   )
; );dolist
; (while (string-match "&#\\([0-9]+\\);" str)
;   (let ((asc (parse-integer (match-string 1)))
;	  (before (substring str 0 (match-beginning 0)))
;	  (after (substring str (match-end 0) (length str))))
;      (setq str (concat before (code-char asc) after))
;    )
;  );while
;  str
;)

(defun www-view-convert-special-chars (beg end)
  (save-excursion
    (save-restriction
      (narrow-to-region beg end)
      (goto-char (point-min))
      (while (scan-buffer "&\\(#\\([0-9]+\\)\\|\\([0-9a-zA-Z]+\\)\\);"
			  :regexp t
			  :tail nil)
	(let ((x (match-string 0))
	      (start (match-beginning 0))
	      (stop (match-end 0))
	      chr)
	  (if (match-beginning 2)
	      (let ((asc (parse-integer (match-string 2))))
		(setq chr (unicode-char asc)))
	    (let ((ent1 (cdr (assoc x *www-special-chars-alist* :test #'equal)))
		  (ent2 (cdr (assoc x *www-character-entity-alist* :test #'equal))))
	      (if ent1
		  (setq chr ent1)
		(if ent2
		    (setq chr (unicode-char ent2))))))
	  (when *www-view-debug*
	    (msgbox "~S:~S" x chr))
	  (if chr
	      (progn
		(delete-region start stop)
		(insert chr))
	    (forward-char 1)))
	(do-events))
      )))

(defun www-view-align-center (beg end)
  (interactive "r")
  (save-excursion
    (let (end-line)
      (goto-char end)
      (setq end-line (current-line-number))
      (goto-char beg)
      (while (<= (current-line-number) end-line)
	(unless (www-blank-line-p)
	  (www-line-center))
	(unless (forward-line 1)
	  (return))
      ))))

(defun www-view-align-right (beg end)
  (interactive "r")
  (save-excursion
    (let (end-line)
      (goto-char end)
      (setq end-line (current-line-number))
      (goto-char beg)
      (while (<= (current-line-number) end-line)
	(unless (www-blank-line-p)
	  (www-line-right))
	(unless (forward-line 1)
	  (return))
      )
    )
  ))

(defun www-line-center ()
  (save-excursion
    (goto-eol)
    (let ((col (current-column))
	  num)
      (goto-bol)
      (skip-chars-forward " \t")
      (setq col (- col (current-column)))
      (goto-bol)
      (setq num (truncate (/ (- www-width col) 2)))
      (insert " " (if (<= 0 num) num 0))
    )
  ))

(defun www-line-right ()
  (save-excursion
    (goto-eol)
    (let ((col (current-column))
	  num)
      (goto-bol)
      (setq num (- www-width col))
      (insert " " (if (<= 0 num) num 0))
    )
  ))

;;
;; TEXTの修飾
;;
(defun www-view-mark-string (beg in)
  (let (beg-marker
	(end-marker (point-marker))
	(attr-list '(www-bold www-italic www-underline www-strike-out www-foreground www-background www-overlay))
	attr)
    (save-excursion
      (goto-char beg)
      (setq beg-marker (point-marker))
    )
    (dolist (tag in)
      (let ((tname (www-tag-name tag)))
	(cond ((eq tname 'a)
	       (when (www-tag-get-option 'href (www-tag-opt tag))
		 (dolist (x attr-list)
		   (let ((at (get tname x)))
		     (when at
		       (pushnew (list x at) attr))
		   )
		 );dolist
	       ))
	      (t
	       (dolist (x attr-list)
		 (let ((at (get tname x)))
		   (when at
		     (pushnew (list x at) attr))
		 )
	       );dolist
	      )
	);cond
      );let
    );dolist
    (when attr
      (push (list beg-marker end-marker attr) www-marker-attributes))
  ))

(defun www-view-put-text-attributes ()
  (dolist (x (reverse www-marker-attributes))
    (let ((beg-mark (nth 0 x))
	  (end-mark (nth 1 x))
	  (attr (nth 2 x))
	  beg
	  end)
      (when (and beg-mark end-mark attr)
	(setq beg (marker-point beg-mark))
	(setq end (marker-point end-mark))
	(when (and beg end)
	  (unless (or (< beg (point-min))
		      (< (point-max) beg)
		      (< end (point-min))
		      (< (point-max) end)
		  )
	    (if (www-view-get-attr attr 'www-overlay)
		(let ((tag (cons 'overlay (cons 'www-link beg))))
		  (set-text-attribute beg end tag)
		  (overlay-set-attr tag 'off))
	      (set-text-attribute beg end 'www-attributes
				  :bold (www-view-get-attr attr 'www-bold)
				  :underline (www-view-get-attr attr 'www-underline)
				  :strike-out (www-view-get-attr attr 'www-strike-out)
				  :foreground (www-view-get-attr attr 'www-foreground)
				  :background (www-view-get-attr attr 'www-background)
	      )
	    )
	  )
	)
      )
    )
  );dolist
)

(defun www-view-get-attr (attr key)
  (car (cdr (assoc key attr)))
)

;;
;; LINK
;;
(defun www-view-marker-link-register ()
  (setq www-link-register nil)
  (dolist (x (reverse www-marker-link-alist))
    (let ((beg-mark (nth 0 x))
	  (end-mark (nth 1 x))
	  (tag (nth 2 x))
	  (val (nth 3 x))
	  beg
	  end)
      (when (and beg-mark end-mark tag)
	(setq beg (marker-point beg-mark))
	(setq end (marker-point end-mark))
	;(set-text-attribute beg end 'www-link :foreground *www-link-fgcolor*)
	(push (list beg end tag val) www-link-register)
      )
    )
  )
;  (dolist (x www-marker-link-alist)
;    (let ((beg-mark (nth 0 x))
;	  (end-mark (nth 1 x))
;	 )
;      (when beg-mark
;	(delete-marker beg-mark))
;      (when end-mark
;	(delete-marker end-mark))
;    ))
)

(defun www-view-point-link ()
  (let (tag
	val
	(curp (point))
	beg
	end)
    (dolist (x www-link-register)
      (setq beg (car x))
      (setq end (cadr x))
      (when (and (>= curp beg)
		 (<= curp end))
	(setq tag (nth 2 x))
	(setq val (nth 3 x))
	(return)
      )
    )
    ;(msgbox "~S" (list tag val beg end))
    (values tag val beg end)
  ))

(defun www-view-goto-link (&optional no-cache mouse-p)
  (interactive "p")
  (multiple-value-bind (tag val beg end)
      (www-view-point-link)
    (cond ((eq tag 'href)
	   (if val
	       (let (referer)
		 (when (string-match "^http://" www-url)
		   (setq referer www-url))
		 (setq *www-history-future-list* nil)
		 (www-history-back-add)
		 (www-open val
			   :no-cache no-cache
			   :referer referer)
	       )
	     (message "リンクじゃないっす")
	   ))
	  ((eq tag 'text)
	   (if val
	       (www-form-input-text-change val beg end)
	     (message "Textbox: option not found")
	   ))
	  ((eq tag 'password)
	   (if val
	       (www-form-input-password-change val beg end)
	     (message "Password: option not found")
	   ))
	  ((eq tag 'checkbox)
	   (if val
	       (www-form-input-checkbox-change val beg end)
	     (message "Checkbox: option not found")
	   ))
	  ((eq tag 'radio)
	   (if val
	       (www-form-input-radio-change val beg end)
	     (message "Radio: option not found")
	   ))
	  ((eq tag 'textarea)
	   (if val
	       (www-form-textarea-input val beg end)
	     (message "Textarea: option not found")
	   ))
	  ((eq tag 'select)
	   (if val
	       (www-form-select-change val beg end)
	     (message "Select: option not found")
	   ))
	  ((eq tag 'file)
	   (if val
	       (www-form-input-file-change val beg end)
	     (message "File: option not found")
	     ))
	  ((eq tag 'reset)
	   (www-reread))
	  ((eq tag 'submit)
	   (www-form-submit-form val))
	  (t
	   (if mouse-p
	       (mouse-left-press)
	     (message "できないっす"))
	  )
    );cond
  ))

(defun www-view-save-link (&optional no-cache)
  (interactive "p")
  (let (tag val)
    (multiple-value-setq (tag val)
      (www-view-point-link))
    (cond ((eq tag 'href)
	   (if val
	       (www-open val
			 :save t
			 :no-cache no-cache)
	     (message "リンクじゃないっす")
	   ))
	  (t
	   (message "リンクじゃないっす")
	  )
    );cond
  ))

(defun www-view-copy-link ()
  (interactive)
  (let (tag val)
    (multiple-value-setq (tag val)
      (www-view-point-link))
    (cond ((eq tag 'href)
	   (if val
	       (www-url-to-clipboard val)
	     (message "リンクじゃないっす")
	   ))
	  (t
	   (message "リンクじゃないっす")
	  )
    );cond
  ))

;(defun www-view-save-link-no-cache ()
;  (interactive)
;  (www-view-save-link t))

(defun www-mouse-left-press ()
  (interactive)
  (set-window *last-mouse-window*)
  (goto-last-mouse-point)
  (when (string-match *www-buffer-view-prefix* (buffer-name (selected-buffer)))
    (www-view-goto-link nil t))
)

(defun www-mouse-right-press ()
  (interactive)
  (set-window *last-mouse-window*)
  (goto-last-mouse-point)
  (when (string-match *www-buffer-view-prefix* (buffer-name (selected-buffer)))
    (www-view-popup-menu))
)

(defun www-view-show-link ()
  (interactive)
  (let (tag val)
    (multiple-value-setq (tag val)
      (www-view-point-link))
    (cond ((eq tag 'href)
	   (if val
	       (popup-string (format nil "~A" val) (point))
	     (message "リンクじゃないっす")
	   ))
	  (t
	   (message "リンクじゃないっす")
	  )
    );cond
  ))

(defun www-view-next-link ()
  (interactive)
  (dolist (x (reverse www-link-register))
    (let ((beg (car x)))
      (when (< (point) beg)
	(goto-char beg)
	(return)
      )
    )
  );dolist
)

(defun www-view-previous-link ()
  (interactive)
  (dolist (x www-link-register)
    (let ((beg (car x))
	  (end (nth 1 x)))
      (when (> (point) end)
	(goto-char beg)
	(return)
      )
    )
  );dolist
)

;;
;; img
;;
(defun www-view-marker-img-register ()
  (dolist (x (reverse www-marker-img-alist))
    (let ((beg-mark (nth 0 x))
	  (end-mark (nth 1 x))
	  (img (nth 2 x))
	  beg
	  end)
      (when (and beg-mark end-mark img)
	(setq beg (marker-point beg-mark))
	(setq end (marker-point end-mark))
	;(set-text-attribute beg end 'www-img :foreground *www-img-fgcolor*)
	(push (list beg end img) www-img-register)
      )
    )
  )
  (dolist (x www-marker-img-alist)
    (let ((beg-mark (nth 0 x))
	  (end-mark (nth 1 x))
	 )
      (when beg-mark
	(delete-marker beg-mark))
      (when end-mark
	(delete-marker end-mark))
    ))     
)

(defun www-view-point-img ()
  (let (url (curp (point)))
    (dolist (x www-img-register)
      (let (beg end)
	(setq beg (car x))
	(setq end (car (cdr x)))
	(when (and (>= curp beg)
		 (<= curp end))
	  (setq url (car (cdr (cdr x))))
	  (return)
	)
      )
    )
    url
  ))

(defun www-view-save-img ()
  (interactive)
  (let ((link (www-view-point-img)))
    (if link
	(www-open link
		  :save t)
      (message "画像じゃないっす")
    )
  ))

(defun www-view-open-img-in-other-browser ()
  (interactive)
  (let ((link (www-view-point-img)))
    (if link
	(www-open-in-other-browser link)
      (message "画像じゃないっす")
    )
  ))

;;
;; anchor
;;
(defun www-view-marker-anchor-register ()
  (dolist (x (reverse www-marker-anchor-alist))
    (let ((mark (car x))
	  (anc (nth 1 x)))
      (goto-marker mark)
      (push (list anc (current-line-number)) www-anchor-register)
    )
  )
)

(defun www-view-goto-anchor (name)
  (interactive)
  (let (line)
    (setq line (car (cdr (assoc name www-anchor-register :test #'equal))))
    (if line
	(progn
	  (goto-line line)
	  (recenter 0))
      (message "No such anchor: ~A" name)
    )
  ))

(defun www-view-reload (&optional no-cache kcode)
  (interactive "p")
  (let ((url www-url)
	(post www-post-data))
    (when url
      (delete-buffer (www-buffer-view url post))
      (delete-buffer (www-buffer-src url post))
      (www-open url
		:no-cache no-cache
		:post post
		:kcode kcode)
    )
  ))

;;
;; www-mode で開いているページのタイトル一覧をポップアップメニューで表示する
;;
;; by すがわらさん <woo@dd.iij4u.or.jp>
;;

(defun www-view-list-popup ()
  (interactive)
  (continue-pre-selection)
  (track-popup-menu (www-view-list-popup-menu))
)

(defun www-view-list-popup-menu ()
  (let ((menu (create-popup-menu nil))
	(curbuf (buffer-name (selected-buffer))))
    (save-excursion
      (dolist (buffer (buffer-list))
	(let ((menu-item (buffer-name buffer)))
	  (unless (string= menu-item curbuf)
	    (when (string-match *www-buffer-view-prefix* menu-item)
	      (set-buffer menu-item)
	      (let ((url www-url))
		(add-menu-item menu 'www-buffer
			       (if (and (stringp www-page-title)
					(not (equal www-page-title "")))
				   www-page-title
				 url)
			       #'(lambda ()
				   (interactive)
				   (www-open url)))
	      )
	    )
	  )
	)
      );dolist
    );save-excursion
    menu
  ))

(defun www-view-popup-menu ()
  (interactive)
  (let ((menu (create-popup-menu nil))
	tag
	val
	(img (www-view-point-img)))
    (multiple-value-setq (tag val)
      (www-view-point-link))
    (cond ((and (eq tag 'href) val)
	   (add-menu-item menu nil "リンクを開く"
			  'www-view-goto-link)
	   (add-menu-item menu nil "リンクを保存"
			  'www-view-save-link)
	   (add-menu-item menu nil "リンクのURLをコピー"
			  'www-view-copy-link)
	   (add-menu-item menu nil "リンクを他のブラウザで開く"
			  'www-open-link-in-other-browser)
	   (add-menu-item menu nil "リンクをWGETで保存"
			  'www-wget-download)
	   (add-menu-separator menu)
	  )
	  (tag
	   (add-menu-item menu nil "フォーム"
			  'www-view-goto-link)
	   (add-menu-separator menu)
	  )
	  (img
	   (add-menu-item menu nil "画像を保存"
			  'www-view-save-img)
	   (add-menu-item menu nil "画像を他のブラウザで開く"
			  'www-view-open-img-in-other-browser)
	   (add-menu-separator menu)
	  )
    );cond
    (add-menu-item menu nil "戻る"
		   'www-history-back
		   #'(lambda () (unless *www-history-back-list* :disable)))
    (add-menu-item menu nil "進む"
		   'www-history-next
		   #'(lambda () (unless *www-history-forward-list* :disable)))
    (add-menu-separator menu)
    (add-menu-item menu nil "ページをリロード"
		   'www-view-reload)
    (add-menu-item menu nil "ページを他のブラウザで開く"
		   'www-open-in-other-browser)
    (add-menu-item menu nil "ページのURLをコピー"
		   'www-url-to-clipboard)
    (add-menu-item menu nil "ページをブックマーク"
		   'www-bookmark-add-current)
    (add-menu-item menu nil "ページを更新リストに追加"
		   'www-update-add-current)
    (add-menu-separator menu)
    (add-popup-menu menu (www-encoding-menu www-charset)
		    "ページの言語変更")
    (add-menu-item menu nil "ページの言語を固定"
		   'www-encoding-lock-toggle
		   #'(lambda () (when *www-use-previous-encoding* :check)))
    (add-menu-separator menu)
;    (add-menu-item menu nil "戻る"
;		   'www-history-back
;		   #'(lambda () (unless *www-history-back-list* :disable)))
;    (add-menu-item menu nil "進む"
;		   'www-history-next
;		   #'(lambda () (unless *www-history-forward-list* :disable)))
;    (add-menu-separator menu)
    (add-popup-menu menu (www-view-list-popup-menu) "履歴")
    (add-menu-separator menu)
    (add-menu-item menu nil "ブックマークを開く"
		   'www-bookmark-show)
    (add-menu-item menu nil "更新情報を表示"
		   'www-update-pages)
    (add-menu-separator menu)
    (add-popup-menu menu *app-popup-menu* "その他")
    (add-menu-separator menu)
    (add-menu-item menu nil "www-modeを終了"
		   'www-exit)
    (track-popup-menu menu :button2)
  ))

(defun www-url-to-clipboard (&optional url)
  (interactive)
  (setq url (or url www-url))
  (when (string-match "^file://" url)
    (setq url (substring url (match-end 0)))
  )
  (copy-to-clipboard url))

;(defvar *www-view-list-popup-menu* nil)
;(setq *www-view-list-popup-menu* (create-popup-menu nil))

;(defun www-view-list-popup ()
;  (interactive)
;  (while (get-menu-position *www-view-list-popup-menu* 'www-buffer)
;    (delete-menu *www-view-list-popup-menu* 'www-buffer))
;  (continue-pre-selection)
;  (save-excursion
;    (dolist (buffer (buffer-list))
;      (let ((menu-item (buffer-name buffer)))
;	(when (string-match *www-buffer-view-prefix* menu-item)
;	  (add-menu-item *www-view-list-popup-menu* 'www-buffer
;			 (progn
;			   (set-buffer menu-item)
;			   (if (and (stringp www-page-title)
;				    (not (equal www-page-title "")))
;			       www-page-title
;			     www-url))
;			 #'(lambda ()
;			     (interactive)
;			     (switch-to-buffer menu-item)))))))
;  (track-popup-menu *www-view-list-popup-menu*))

;(global-set-key #\C-F10 'www-view-list-popup)
;(set-function-bar-label #\C-F10 "www View List")

;;
;; =====================================================================
;;

(defun www-show-http-header ()
  (interactive)
  (let (str)
    (setq str
	  (format nil "~A~%" (or www-http-status "")))
    (dolist (x www-http-header)
      (setq str
	    (format nil
		    "~A~A: ~A~%"
		    str
		    (car x)
		    (nth 1 x)))
    )
    (message-box str)
  ))

