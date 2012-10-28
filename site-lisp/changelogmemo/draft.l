;;; -*- Mode: Lisp; Package: ChangeLogMemo -*-
;;;
;;; changelogmemo/draft.l
;;;
;;; Last updated: "2006-02-23"
;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "wip/winapi"))

(provide "changelogmemo/draft")

(in-package "changelogmemo")

;;; edit-memo
(defun edit-memo ()
  (interactive)
  (edit-memo-1 *buffer-memo* nil))

(defun edit-memo-1 (buffer height)
  (let ((pframe (ed::pseudo-frame-name (selected-pseudo-frame)))
	(sbuf (selected-buffer)) (point (point)) (buf (find-buffer buffer))
	(file *cl-file*) winconf)
    (select-pseudo-frame (find-pseudo-frame *default-pframe*))
    (setq winconf (current-window-configuration))
    (set-buffer sbuf)
    (goto-char point)
    (delete-other-windows)
    (and height (split-window height))
    (let ((kept-undo-information nil))
      (declare (special kept-undo-information))
      (if buf
	  (set-buffer buf)
	(progn
	  (set-buffer (create-new-buffer buffer))
	  (ed::find-file-auto-encoding file)
	  (insert-file-contents file)
	  (goto-char (point-min))
	  (memo-mode)
	  (set-buffer-file-name file)
	  (set-buffer-modified-p nil))))
    (setq memo-winconf winconf)
    (setq memo-pframe pframe)
    (setq *memo-show-p* t)))

;;; add-memo
(defun add-memo ()
  (interactive)
  (add-memo-1 *buffer-memo* *memo-window-height*))

(defun add-memo-1 (buffer height &optional modify)
  (let ((pframe (ed::pseudo-frame-name (selected-pseudo-frame)))
	(sbuf (selected-buffer)) (point (point)) (buf (find-buffer buffer))
	(today (format-date-string "%Y-%m-%d")) (file *cl-file*)
	winconf modified)
    (select-pseudo-frame (find-pseudo-frame *default-pframe*))
    (setq winconf (current-window-configuration))
    (set-buffer sbuf)
    (goto-char point)
    (delete-other-windows)
    (and height (split-window height))
    (let ((kept-undo-information nil))
      (declare (special kept-undo-information))
      (if buf
	  (progn
	    (set-buffer buf)
	    (goto-char (point-min))
	    (setq modified (buffer-modified-p)))
	(progn
	  (set-buffer (create-new-buffer buffer))
	  (ed::find-file-auto-encoding file)
	  (insert-file-contents file)
	  (goto-char (point-min))
	  (memo-mode)
	  (set-buffer-file-name file)
	  (set-buffer-modified-p nil))))
    (if (string= (get-date-string) today)
	(progn
	  (forward-line)
	  (insert "\n* \n")
	  (forward-char -1))
      (progn
	(with-output-to-selected-buffer
	  (format t "~A~%~%* ~%~%" (make-entry-header today)))
	(forward-char -2)))
    (unless modify
      (if buf
	  (set-buffer-modified-p modified)
	(set-buffer-modified-p nil)))
    (setq memo-winconf winconf)
    (setq memo-pframe pframe)
    (setq *memo-show-p* t)))

;;; add-memo-from-clipboard
(defun add-memo-from-clipboard ()
  (interactive)
  (let ((string (get-clipboard-data)))
    (add-memo-1 *buffer-memo* *memo-window-height*)
    (when string
      (save-excursion
	(forward-line)
	(insert string "\n")))))

;;; add-memo-from-region
(defun add-memo-from-region ()
  (interactive)
  (let ((string (buffer-substring (mark) (point))))
    (add-memo-1 *buffer-memo* *memo-window-height*)
    (when string
      (save-excursion
	(forward-line)
	(insert string "\n")))))

;;; edit-memo-buffer
(defun edit-memo-buffer ()
  (interactive)
  (edit-memo-buffer-1 *buffer-memo* *cl-buffer* nil))

(defun edit-memo-buffer-1 (buffer1 buffer2 height)
  (let ((pframe (ed::pseudo-frame-name (selected-pseudo-frame)))
	(sbuf (selected-buffer)) (point (point))
	(buf1 (find-buffer buffer1)) (buf2 (find-buffer buffer2))
	(file *cl-file*) winconf info)
    (select-pseudo-frame (find-pseudo-frame *default-pframe*))
    (setq winconf (current-window-configuration))
    (cond (buf1
	   (set-buffer buf1)
	   (and (boundp 'buffer-info) (setq info buffer-info)))
	  (buf2
	   (set-buffer buf2)
	   (setq info (get-buffer-info))))
    (set-buffer sbuf)
    (goto-char point)
    (delete-other-windows)
    (and height (split-window height))
    (let ((kept-undo-information nil))
      (declare (special kept-undo-information))
      (cond (buf1
	     (set-buffer buf1))
	    (buf2
	     (set-buffer buf2)
	     (ed::find-file-auto-encoding file)
	     (insert-file-contents file)
	     (goto-char (point-min))
	     (memo-mode)
	     (set-buffer-file-name file)
	     (set-buffer-modified-p nil)
	     (rename-buffer buffer1))
	    (t
	     (set-buffer (create-new-buffer buffer1))
	     (ed::find-file-auto-encoding file)
	     (insert-file-contents file)
	     (goto-char (point-min))
	     (memo-mode)
	     (set-buffer-file-name file)
	     (set-buffer-modified-p nil))))
    (setq memo-winconf winconf)
    (setq buffer-info info)
    (setq memo-pframe pframe)
    (setq *memo-show-p* t)))

;;; add-memo-buffer
(defun add-memo-buffer ()
  (interactive)
  (add-memo-buffer-1 *buffer-memo* *cl-buffer* *memo-window-height*))

(defun add-memo-buffer-1 (buffer1 buffer2 height &optional modify)
  (let ((pframe (ed::pseudo-frame-name (selected-pseudo-frame)))
	(sbuf (selected-buffer)) (point (point))
	(buf1 (find-buffer buffer1)) (buf2 (find-buffer buffer2))
	(today (format-date-string "%Y-%m-%d"))
	(file *cl-file*) winconf info modified)
    (select-pseudo-frame (find-pseudo-frame *default-pframe*))
    (setq winconf (current-window-configuration))
    (cond (buf1
	   (set-buffer buf1)
	   (and (boundp 'buffer-info) (setq info buffer-info)))
	  (buf2
	   (set-buffer buf2)
	   (setq info (get-buffer-info))))
    (set-buffer sbuf)
    (goto-char point)
    (delete-other-windows)
    (and height (split-window height))
    (let ((kept-undo-information nil))
      (declare (special kept-undo-information))
      (cond (buf1
	     (set-buffer buf1)
	     (goto-char (point-min))
	     (setq modified (buffer-modified-p)))
	    (buf2
	     (set-buffer buf2)
	     (set-buffer-file-name nil);エラーを回避するため
	     (ed::find-file-auto-encoding file)
	     (insert-file-contents file)
	     (goto-char (point-min))
	     (memo-mode)
	     (set-buffer-file-name file)
	     (set-buffer-modified-p nil)
	     (rename-buffer buffer1))
	    (t
	     (set-buffer (create-new-buffer buffer1))
	     (ed::find-file-auto-encoding file)
	     (insert-file-contents file)
	     (goto-char (point-min))
	     (memo-mode)
	     (set-buffer-file-name file)
	     (set-buffer-modified-p nil))))
    (if (string= (get-date-string) today)
	(progn
	  (forward-line)
	  (insert "\n* \n")
	  (forward-char -1))
      (progn
	(with-output-to-selected-buffer
	  (format t "~A~%~%* ~%~%" (make-entry-header today)))
	(forward-char -2)))
    (unless modify
      (if buf1
	  (set-buffer-modified-p modified)
	(set-buffer-modified-p nil)))
    (setq memo-winconf winconf)
    (setq buffer-info info)
    (setq memo-pframe pframe)
    (setq *memo-show-p* t)))

;;; add-memo-buffer-from-clipboard
(defun add-memo-buffer-from-clipboard ()
  (interactive)
  (let ((string (get-clipboard-data)))
    (add-memo-buffer-1 *buffer-memo* *cl-buffer* *memo-window-height*)
    (when string
      (save-excursion
	(forward-line)
	(insert string "\n")))))

;;; add-memo-buffer-from-region
(defun add-memo-buffer-from-region ()
  (interactive)
  (let ((string (buffer-substring (mark) (point))))
    (add-memo-buffer-1 *buffer-memo* *cl-buffer* *memo-window-height*)
    (when string
      (save-excursion
	(forward-line)
	(insert string "\n")))))

;;; toggle-memo-tool-bar
(defun toggle-memo-tool-bar ()
  (interactive)
  (if *memo-show-p*
      (let ((memo-buf *buffer-memo*)
	    (sbuf (buffer-name (selected-buffer)))
	    (winconf (current-window-configuration)))
	(set-buffer memo-buf)
	(and (boundp 'memo-winconf)
	     (string/= sbuf memo-buf)
	     (setq memo-winconf winconf))
	(kill-buffer (selected-buffer)))
    (add-memo-1 *buffer-memo* nil)))

(c:define-dll-entry c:short GetKeyState (c:int) "user32")

(defun toggle-memo-tool-bar-buffer ()
  (interactive)
  (let ((memo-buf *buffer-memo*) (cl-buf *cl-buffer*)
	(sbuf (buffer-name (selected-buffer))))
    (if ;outline-tree2 より借用↓
	(or (minusp (GetKeyState 17))
	    (minusp (GetKeyState 162))
	    (minusp (GetKeyState 163)));↑
	(if *memo-show-p*
	    (let ((winconf (current-window-configuration))
		  (cl (find-buffer cl-buf)))
	      (set-buffer memo-buf)
	      (and (boundp 'memo-winconf)
		   (string/= sbuf memo-buf)
		   (setq memo-winconf winconf))
	      (if cl
		  (delete-and-show-memo-buffer cl-buf)
		(kill-and-create-memo-buffer memo-buf)))
	  (add-memo-1 memo-buf nil))
      (if *memo-show-p*
	  (let ((winconf (current-window-configuration)))
	    (set-buffer memo-buf)
	    (and (boundp 'memo-winconf)
		 (string/= sbuf memo-buf)
		 (setq memo-winconf winconf))
	    (kill-buffer (selected-buffer)))
	(add-memo-buffer-1 memo-buf cl-buf nil)))
    ))

(defun kill-and-create-memo-buffer (buffer)
  (let ((pframe (ed::pseudo-frame-name (selected-pseudo-frame)))
	(sbuf (selected-buffer)) (info (get-buffer-info))
	winconf)
    (select-pseudo-frame (find-pseudo-frame *default-pframe*))
    (set-buffer sbuf)
    (kill-memo-buffer t)
    (setq winconf (current-window-configuration))
    (set-buffer (create-new-buffer buffer))
    (let ((kept-undo-information nil))
      (declare (special kept-undo-information))
      (restore-buffer-info info))
    (memo-mode)
    (setq memo-winconf winconf)
    (setq memo-pframe pframe)
    (setq *memo-show-p* t)))

(defun delete-and-show-memo-buffer (buffer)
  (let ((pframe (ed::pseudo-frame-name (selected-pseudo-frame)))
	(sbuf (selected-buffer)) (info (get-buffer-info))
	winconf)
    (select-pseudo-frame (find-pseudo-frame *default-pframe*))
    (set-buffer sbuf)
    (delete-buffer (selected-buffer))
    (setq winconf (current-window-configuration))
    (set-buffer buffer)
    (let ((f (get-buffer-info)))
      (let ((kept-undo-information nil))
	(declare (special kept-undo-information))
	(restore-buffer-info info))
      (memo-mode)
      (setq buffer-info f))
    (rename-buffer *buffer-memo*)
    (setq memo-winconf winconf)
    (setq memo-pframe pframe)
    (setq *memo-show-p* t)))

(defun tool-bar-check ()
  (and *memo-show-p* :check))

(defun tool-bar-not-check ()
  nil)

;;; memo-mode

(defvar *memo-mode-hook* nil)

(defvar *memo-mode-map* nil)

(unless *memo-mode-map*
  (setq *memo-mode-map* (make-sparse-keymap))
  (define-key *memo-mode-map* #\M-Up 'previous-entry)
  (define-key *memo-mode-map* #\M-Down 'next-entry)
  (define-key *memo-mode-map* #\C-\. 'complete-category)
  (define-key *memo-mode-map* #\C-j 'insert-item)
  (define-key *memo-mode-map* '(#\C-x #\j) 'insert-entry))

;textmode.l の *text-mode-syntax-table* より借用
(defvar *memo-mode-syntax-table* nil)
(unless *memo-mode-syntax-table*
  (setq *memo-mode-syntax-table* (make-syntax-table))
  (set-syntax-symbol *memo-mode-syntax-table* #\&)
  (set-syntax-symbol *memo-mode-syntax-table* #\*)
  (set-syntax-symbol *memo-mode-syntax-table* #\+)
  (set-syntax-symbol *memo-mode-syntax-table* #\-)
  (set-syntax-symbol *memo-mode-syntax-table* #\/)
  (set-syntax-symbol *memo-mode-syntax-table* #\<)
  (set-syntax-symbol *memo-mode-syntax-table* #\=)
  (set-syntax-symbol *memo-mode-syntax-table* #\>)
  (set-syntax-symbol *memo-mode-syntax-table* #\_)
  (set-syntax-symbol *memo-mode-syntax-table* #\|))

(defvar *memo-mode-abbrev-table* nil)
(unless *memo-mode-abbrev-table*
  (define-abbrev-table '*memo-mode-abbrev-table*))

(defun memo-mode ()
  (interactive)
  (kill-all-local-variables)
  (setq buffer-mode 'memo-mode)
  (setq mode-name "CL Memo")
  (setq need-not-save nil);必要
  (setq auto-save (default-value 'auto-save))
  (and *kept-old-versions*
       (ed::set-buffer-local 'kept-old-versions *kept-old-versions*))
  (and *kept-new-versions*
       (ed::set-buffer-local 'kept-new-versions *kept-new-versions*))
  (make-local-variable 'memo-winconf)
  (make-local-variable 'memo-pframe)
  (make-local-variable 'buffer-info)
  (make-local-variable '*scroll-margin*)
  (setq *scroll-margin* *memo-scroll-margin*)
  (use-keymap *memo-mode-map*)
  (and *memo-fold-width* (set-buffer-fold-width *memo-fold-width*))
  (and *memo-fill-column* (setq fill-column *memo-fill-column*))
  (make-local-variable 'regexp-keyword-list)
  (setq regexp-keyword-list *memo-format*)
  (use-syntax-table *memo-mode-syntax-table*)
  (setq *local-abbrev-table* *memo-mode-abbrev-table*)
  (run-hooks '*memo-mode-hook*))

;;; previous-entry, next-entry
(defun next-entry (&optional reverse)
  (interactive)
  (if (scan-buffer (compile-regexp *date-regexp*)
		   :no-dup t :reverse reverse)
      (recenter *memo-scroll-margin*)
    (if reverse
	(plain-error "前のはありません")
      (plain-error "次のはありません"))))

(defun previous-entry ()
  (interactive)
  (next-entry t))

;;; カテゴリ名を補完
(defun complete-category ()
  (interactive)
  (let ((list (get-category-list)) start)
    (save-excursion
      (or (skip-syntax-spec-backward "w_")
	  (and (save-excursion
		 (and (forward-char -1)
		      (looking-at "\\sk\\|\\sj")))
	       (forward-word -1)))
      (setq start (point)))
    (do-completion start (point) :list-ignore-case list
		   nil nil *cl-popup-completion-list*)))

;;; insert-item
(defun insert-item (&optional tab)
  (interactive)
  (if (get-entry)
      (if (and (bolp) (eolp))
	  (progn
	    (while (and (save-excursion
			  (forward-char 1)
			  (and (bolp) (eolp)))
			(not (eobp)))
	      (forward-char 1))
	    (while (and (save-excursion
			  (forward-char -1)
			  (and (bolp) (eolp)))
			(not (bobp)))
	      (forward-char -1)
	      (delete-char))
	    (if (get-item tab)
		(insert "\n" *item-LFD-number*)
	      (insert "\n"))
	    (if tab
		(insert "\t* \n")
	      (insert "* \n"))
	    (forward-char -1))
	(newline-and-indent))
    (newline-and-indent)))

;;; insert-entry
(defun insert-entry ()
  (interactive)
  (let ((u-date (yyyymmdd (get-date-string)))
	(d-date (yyyymmdd (get-date-string t)))
	date day)
    (if u-date
	(if (entry-header-line-p)
	    (setq date (add-yyyymmdd u-date 1))
	  (setq date (add-yyyymmdd u-date -1)))
      (let ((today (format-date-string "%Y%m%d")))
	(if d-date
	    (if (string<= today d-date)
		(setq date (add-yyyymmdd d-date 1))
	      (setq date today))
	  (setq date today))))
    (loop
      (catch 'input
	(setq day (read-string "yyyymmdd: " :default date))
	(if (yyyymmdd-exist-p day)
	    (return)
	  (progn
	    (message "不適切な入力です")
	    (throw 'input t)))))
    (insert-entry-1 (yyyy-mm-dd day))))

(defun insert-entry-1 (date)
  (if (progn (goto-char (point-min)) (scan-buffer (date-regexp date)))
      (progn
	(goto-eol)
	(insert "\n\n* "))
    (progn
      (or (scan-buffer (month-regexp date))
	  (scan-buffer (year-regexp date)))
      (let ((no-dup nil))
	(unless (while (scan-buffer *date-regexp* :no-dup no-dup)
		  (and (string<= (match-string 1) date) (return t))
		  (setq no-dup t))
	  (goto-char (point-max))
	  (or (looking-back "\n\n") (insert "\n")))
	(with-output-to-selected-buffer
	  (format t "~A~%~%* ~%~%" (make-entry-header date)))
	(forward-char -2)))
    ))

(defun add-yyyymmdd (yyyymmdd num)
  (let ((y (parse-integer (substring yyyymmdd 0 4)))
	(m (parse-integer (substring yyyymmdd 4 6)))
	(d (parse-integer (substring yyyymmdd 6 8)))
	list)
    (setq list (multiple-value-list
		(decode-universal-time
		 (+ (encode-universal-time 0 0 0 d m y)
		    (* num 60 60 24)))))
    (format nil "~2,'0D~2,'0D~2,'0D"
	    (nth 5 list) (nth 4 list) (nth 3 list))))

(defun yyyymmdd-exist-p (yyyymmdd)
  (when (string-match "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]"
		      yyyymmdd)
    (let ((y (parse-integer (substring yyyymmdd 0 4)))
	  (m (parse-integer (substring yyyymmdd 4 6)))
	  (d (parse-integer (substring yyyymmdd 6 8))))
      (and (<= 1 m) (<= m 12) (<= 1 d)
	   (<= d (ed::calendar-gregorian-last-day-of-month y m))))))
