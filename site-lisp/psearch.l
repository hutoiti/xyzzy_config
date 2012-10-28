;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; psearch.l
;;;
;;; Last updated: "2006-07-27"
;;;

;;;
;;; This code is based on dabbrev.l which is part of xyzzy.
;;;

(provide "psearch")

(in-package "editor")

(export '(psearch-popup-string-list psearch-popup-list-again
	  psearch-popup-string-list-word-search
	  psearch-popup-list-again-word-search
	  psearch-popup-list-again-regexp
	  psearch-goto-return-point psearch-delete-attributes
	  psearch-popup-string-list-isearch
	  psearch-popup-string-list-word-search-isearch
	  psearch-coloring
	  *psearch-string-synchronization* *psearch-case-fold-search*
	  *psearch-coloring* *psearch-hook*))

(defvar *psearch-string-synchronization* nil)

(defvar *psearch-coloring* nil)
(defvar *psearch-attribute* '(:foreground 1 :background 3 :bold t))

(defvar *psearch-hook* nil)

(defvar *psearch-last-search-string* nil)
(defvar *psearch-last-search-regexp* nil)
(defvar *psearch-last-search-regexp-p* nil)
(defvar *psearch-last-search-p* nil)

(defvar *psearch-case-fold-search* ':smart)

(defvar-local *psearch-list* nil)
(defvar-local *psearch-match-number* nil)

(defvar *psearch-coloring-last-search-string* nil)
(defvar *psearch-coloring-last-search-regexp* nil)
(defvar *psearch-coloring-last-search-regexp-p* nil)
(defvar *psearch-coloring-case-fold-search* nil)
(defvar *psearch-coloring-word-search* nil)
(defvar *psearch-coloring-understand-escape-sequences* nil)

(defun psearch-popup-string-list (&optional arg)
  (interactive "p")
  (psearch-popup-string-list-1 *psearch-case-fold-search* nil
			       *psearch-coloring*
			       arg))

(defun psearch-popup-string-list-1 (case-fold word-search coloring arg)
  (if arg
      (psearch-popup-list-1 (buffer-substring (mark) (point))
			    case-fold word-search
			    coloring)
    (cond ((eq (get-selection-type) 2)
	   (psearch-popup-list-1 (buffer-substring (selection-mark)
						   (selection-point))
				 case-fold word-search
				 coloring))
	  ((eq (get-selection-type) nil)
	   (psearch-popup-list-1 (psearch-get-string)
				 case-fold word-search
				 coloring)))))

(defun psearch-popup-string-list-word-search (&optional arg)
  (interactive "p")
  (psearch-popup-string-list-1 *psearch-case-fold-search* t
			       *psearch-coloring*
			       arg))

(defun psearch-popup-string-list-isearch ()
  (interactive)
  (psearch-popup-list-1 *isearch-current-match-string*
			*psearch-case-fold-search* nil
			*psearch-coloring*)
  (throw 'psearch-popup-string-list-isearch t))

(defun psearch-popup-string-list-word-search-isearch ()
  (interactive)
  (psearch-popup-list-1 *isearch-current-match-string*
			*psearch-case-fold-search* t
			*psearch-coloring*)
  (throw 'psearch-popup-string-list-word-search-isearch t))

(defun psearch-get-string ()
  (let ((pt (point)) beg end)
    (save-excursion
      (or (skip-syntax-spec-forward "w_")
	  (and (looking-at "\\sk\\|\\sj")
	       (forward-word)))
      (if (string-match "\n" (buffer-substring pt (point)))
	  (setq end pt)
	(setq end (point)))
      (goto-char end)
      (or (skip-syntax-spec-backward "w_")
	  (and (save-excursion
		 (and (forward-char -1)
		      (looking-at "\\sk\\|\\sj")))
	       (forward-word -1)))
      (if (string-match "\n" (buffer-substring pt (point)))
	  (setq beg pt)
	(setq beg (point))))
    (buffer-substring beg end)))

(defun psearch-popup-list-1 (str case-fold word-search coloring)
  (when (= (length str) 0)
    (plain-error "åüçıåÍÇ™Ç†ÇËÇ‹ÇπÇÒ"))
  (setq *last-search-string* str)
  (setq *last-search-regexp-p* nil)
  (setq *case-fold-search* case-fold)
  (setq *word-search* word-search)
  (setq *psearch-last-search-p* t)
  (setq *psearch-last-search-string* str)
  (setq *psearch-last-search-regexp-p* nil)
  (setq *psearch-match-number* (psearch-match-number str
						     case-fold word-search
						     nil))
  (make-local-variable 'psearch-return-marker)
  (setq psearch-return-marker (set-marker (make-marker) (point)))
  (psearch-popup-list str case-fold word-search coloring nil))

(defun psearch-popup-list (str case-fold word-search coloring regexp)
  (let ((list (psearch-make-list str case-fold word-search coloring regexp)))
    (unless list
      (let ((s (psearch-message-string str regexp)))
	(if regexp
	    (plain-error "~A: ê≥ãKï\åªÇ™å©Ç¬Ç©ÇËÇ‹ÇπÇÒ" s)
	  (plain-error "~A: ï∂éöóÒÇ™å©Ç¬Ç©ÇËÇ‹ÇπÇÒ" s))))
    (popup-list list (psearch-goto-function case-fold word-search regexp))
    (let ((match-number *psearch-match-number*) (len (list-length list))
	  (s (psearch-message-string str regexp)))
      (if (= len match-number)
	  (message "~A: ~D" s len)
	(message "~A: ~D(~D)" s len match-number)))
    (run-hooks '*psearch-hook*)))

(defun psearch-match-number (str case-fold word-search regexp)
  (let ((*case-fold-search* case-fold) (*word-search* word-search))
    (declare (special *case-fold-search* *word-search*))
    (save-excursion
      (goto-char (point-min))
      (count-matches str (not regexp) t))))

(defun psearch-message-string (str regexp)
  (if regexp
      (concat "<" (substitute-string str "\n" "\\\\n") ">")
    (if (string-match "^\\(.*\\)\n" str)
	(concat (match-string 1) "~")
      str)))

(defun psearch-make-list (str case-fold word-search coloring regexp)
  (let* ((match-table (psearch-hash-table str case-fold))
	 (start (save-excursion (goto-virtual-bol) (point)))
	 (matches (psearch-expansion str case-fold word-search
				     match-table start coloring regexp)))
    (when matches
      (setq *psearch-list* matches)
      (mapcar #'car matches))))

(defun psearch-hash-table (str case-fold)
  (case case-fold
    (nil (make-hash-table :test #'equal))
    (:smart (if (string-match "[A-Z]" str)
		(make-hash-table :test #'equal)
	      (make-hash-table :test #'equalp)))
    (t (make-hash-table :test #'equalp))))

(defun psearch-expansion (str case-fold word-search
			      match-table start coloring regexp)
  (let ((s str) matches cur)
    (when coloring
      (delete-text-attributes 'psearch))
    (when regexp
      (setq s (compile-regexp s)))
    (save-excursion
      (goto-char (point-min))
      (let ((no-dup nil))
	(while (scan-buffer s
			    :case-fold case-fold
			    :left-bound word-search
			    :right-bound word-search
			    :no-dup no-dup)
	  (let* ((from (save-excursion (goto-virtual-bol) (point)))
		 (to (save-excursion (goto-virtual-eol) (point)))
		 (num (current-virtual-line-number))
		 (ln (if (default-line-number-mode)
			 (current-virtual-line-number)
		       (current-line-number)))
		 (text (format nil "~6D  ~A"
			       ln
			       (string-left-trim '(#\SPC #\TAB)
						 (buffer-substring from to))))
		 (beg (match-beginning 0))
		 (end (match-end 0)))
	    (if (eql from start)
		(progn
		  (gethash text match-table)
		  (setq cur (cons text num)))
	      (unless (gethash text match-table)
		(setf (gethash text match-table) from)
		(push (cons text num) matches)))
	    (when coloring
	      (apply #'set-text-attribute beg end 'psearch *psearch-attribute*))
	    (setq no-dup t)))))
    (if cur
	(cons cur (nreverse matches))
      (nreverse matches))))

(defun psearch-goto-function (case-fold word-search regexp)
  #'(lambda (str)
      (let ((num (cdr (assoc str *psearch-list* :test #'string=)))
	    (s (if regexp
		   *psearch-last-search-regexp*
		 *psearch-last-search-string*)))
	(goto-virtual-line num)
	(scan-buffer s :case-fold case-fold :word-search word-search)
	(refresh-screen))))

(defun psearch-popup-list-again ()
  (interactive)
  (psearch-popup-list-2 *psearch-case-fold-search* nil *psearch-coloring*
			*psearch-string-synchronization* nil))

(defun psearch-popup-list-2 (case-fold word-search coloring synchro regexp)
  (let (str)
    (if regexp
	(setq str *last-search-regexp*)
      (if synchro
	  (setq str *last-search-string*)
	(setq str *psearch-last-search-string*)))
    (when (= (length str) 0)
      (if regexp
	  (plain-error "ê≥ãKï\åªÇ™Ç†ÇËÇ‹ÇπÇÒ")
	(plain-error "åüçıåÍÇ™Ç†ÇËÇ‹ÇπÇÒ")))
    (setq *psearch-last-search-p* t)
    (if regexp
	(progn
	  (setq *last-search-regexp-p* t)
	  (setq *psearch-last-search-regexp-p* t)
	  (setq *psearch-last-search-regexp* str))
      (progn
	(setq *last-search-regexp-p* nil)
	(setq *psearch-last-search-regexp-p* nil)
	(when synchro
	  (setq *psearch-last-search-string* str))))
    (setq *case-fold-search* case-fold)
    (setq *word-search* word-search)
    (setq *psearch-match-number* (psearch-match-number str
						       case-fold word-search
						       regexp))
    (psearch-popup-list str case-fold word-search coloring regexp)))

(defun psearch-popup-list-again-word-search ()
  (interactive)
  (psearch-popup-list-2 *psearch-case-fold-search* t *psearch-coloring*
			*psearch-string-synchronization* nil))

(defun psearch-popup-list-again-regexp ()
  (interactive)
  (psearch-popup-list-2 *psearch-case-fold-search* nil *psearch-coloring*
			*psearch-string-synchronization* t))

(defun psearch-goto-return-point ()
  (interactive)
  (when (boundp 'psearch-return-marker)
    (goto-char (marker-point psearch-return-marker))))

(defun psearch-delete-attributes ()
  (interactive)
  (delete-text-attributes 'psearch))

(defun psearch-coloring (&optional success)
  (protect-match-data
    (let* ((regexp-p *last-search-regexp-p*)
	   (str (if regexp-p
		    *last-search-regexp*
		  *last-search-string*)))
      (unless (and (eq *psearch-coloring-last-search-regexp-p* regexp-p)
		   (eq *psearch-coloring-case-fold-search* *case-fold-search*)
		   (eq *psearch-coloring-word-search* *word-search*)
		   (eq *psearch-coloring-understand-escape-sequences*
		       *understand-escape-sequences*)
		   (if regexp-p
		       (equal *psearch-coloring-last-search-regexp* str)
		     (equal *psearch-coloring-last-search-string* str)))
	(psearch-set-text-attributes str
				     *case-fold-search* *word-search*
				     regexp-p)
	(setq *psearch-coloring-last-search-regexp-p* regexp-p)
	(setq *psearch-coloring-case-fold-search* *case-fold-search*)
	(setq *psearch-coloring-word-search* *word-search*)
	(setq *psearch-coloring-understand-escape-sequences*
	      *understand-escape-sequences*)
	(if regexp-p
	    (setq *psearch-coloring-last-search-regexp* str)
	  (setq *psearch-coloring-last-search-string* str)))
      success)))

(defun psearch-set-text-attributes (str case-fold word-search regexp)
  (let ((s str))
    (delete-text-attributes 'psearch)
    (when regexp
      (setq s (compile-regexp s)))
    (save-excursion
      (goto-char (point-min))
      (let ((no-dup nil))
	(while (scan-buffer s
			    :case-fold case-fold
			    :left-bound word-search
			    :right-bound word-search
			    :no-dup no-dup)
	  (let ((beg (match-beginning 0))
		(end (match-end 0)))
	    (apply #'set-text-attribute beg end 'psearch *psearch-attribute*)
	    (setq no-dup t)))))))

;;;
