;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: ruby-lister.l,v 1.1.1.1 2005/11/25 13:06:17 torihat Exp $
;
; ruby-lister.l
;
; by HATTORI Masashi

(provide "ruby-lister")

(require "ruby")

(defvar editor::*ruby-lister-colors* '(
				       (class 9)
				       (module 10)
				       (def 11)
				       (attr 12)
				       (alias 13)
				      ))

(in-package "editor")

(export '(ruby-lister
	  ruby-lister-make-rtags
	  *ruby-prog*
	  *ruby-lister-rtags-path*
	  *ruby-lister-width*
	  *ruby-lister-file-fgcolor*
	  *ruby-lister-file-bgcolor*
	 ))

(defvar *ruby-lister-rtags-path* nil)

(defvar *ruby-lister-rtags-file* "TAGS")
(defvar *ruby-lister-buffer-name* "*RUBY LISTER*")
(defvar *ruby-lister-buffer-temp* "*RUBY LISTER TEMP*")
(defvar *ruby-lister-mode-name* "Ruby Lister")
(defvar *ruby-lister-width* 35)

(defvar *ruby-lister-file-fgcolor* 7)
(defvar *ruby-lister-file-bgcolor* 8)

(defvar *ruby-lister-head-regexp* "\\(class\\|def\\|module\\|alias\\|attr\\)")

(defvar *ruby-lister-package-regexp*
  "\\(class\\|module\\)[ \t]+\\([0-9a-zA-Z_!?]+\\).*\\([0-9]+\\),")
(defvar *ruby-lister-function-regexp*
  "\\(def\\|alias\\|attr\\)[ \t]+\\([0-9a-zA-Z_!?:=\.]+\\).*\\([0-9]+\\),")

;(defvar *ruby-lister-class-regexp* "class[ \t]+\\([0-9a-zA-Z_!?]+\\).*\\([0-9]+\\),")
;(defvar *ruby-lister-module-regexp* "module[ \t]+\\([0-9a-zA-Z_!?]+\\).*\\([0-9]+\\),")
;(defvar *ruby-lister-def-regexp* "def[ \t]+\\([0-9a-zA-Z_!?]+\\).*\\([0-9]+\\),")
;(defvar *ruby-lister-alias-regexp* "alias[ \t]+\\([0-9a-zA-Z_!?]+\\).*\\([0-9]+\\),")
;(defvar *ruby-lister-attr-regexp* "attr[ \t]+\\([0-9a-zA-Z_!?:]+\\).*\\([0-9]+\\),")

(defvar *ruby-lister-attr-regexp* "\\(attr\\)[ \t]*\([ \t]*\"?\\([0-9a-zA-Z_!?:]+\\)\"?.*\\([0-9]+\\),")

(define-key *ruby-mode-map* #\C-F4 'ruby-lister)
(define-key *ruby-mode-map* '(#\C-c #\m) 'ruby-lister-make-rtags)

(defvar *ruby-lister-mode-map* nil)
(setq *ruby-lister-mode-map* (make-sparse-keymap))
(define-key *ruby-lister-mode-map* #\RET 'ruby-lister-jump)
(define-key *ruby-lister-mode-map* #\LBtnDown 'ruby-lister-mouse-left-press)
(define-key *ruby-lister-mode-map* #\q 'ruby-lister-quit)

(defun ruby-lister-mouse-left-press ()
  (interactive)
  (set-window *last-mouse-window*)
  (goto-last-mouse-point)
  (ruby-lister-jump)
)

(defun ruby-lister-mode ()
  (setq buffer-mode 'ruby-lister)
  (setq mode-name *ruby-lister-mode-name*)
  (setq buffer-read-only t)
  (set-local-window-flags (selected-buffer)
			  *window-flag-line-number* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-newline* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-cursor-line* t)
  (set-buffer-fold-width nil)
  (make-local-variable 'ruby-lister-data)
  (setq ruby-lister-data nil)
  (use-keymap *ruby-lister-mode-map*)
)

(defun ruby-lister-make-rtags ()
  (interactive)
  (let (files dir command)
    (setq *ruby-prog*
	  (read-string "Ruby command: " :default *ruby-prog*))
    (unless *ruby-lister-rtags-path*
      (setq *ruby-lister-rtags-path*
	    (read-file-name "Path to rtags.rb: ")))
    (setq dir
	  (read-string "Directory: " :default (default-directory)))
    (set-default-directory dir)
    (setq files
	  (read-string "Files: " :default "*.rb"))
    (setq command
	  (format nil "~A ~A ~A"
		  *ruby-prog*
		  *ruby-lister-rtags-path*
		  files))
    (switch-to-buffer (get-buffer-create *ruby-lister-buffer-temp*))
    (execute-subprocess command nil *ruby-lister-buffer-temp*)
  ))

(defun ruby-lister-jump ()
  (interactive)
  (let (file
	line)
    (multiple-value-setq (file line)
      (ruby-lister-get-line))
    (when (and file line)
      (setq file (merge-pathnames file (default-directory)))
      (unless (file-exist-p file)
	(error "~Aがないっす" file))
      (other-window 1)
      (find-file file)
      (goto-line line)
      (recenter 3)
      (other-window 1)
    )
  ))

(defun ruby-lister-get-line ()
  (let (file
	line)
    (save-excursion
      (goto-bol)
      (if (looking-at "^[ ┃┣┗]")
	  (progn
	    (goto-eol)
	    (skip-chars-backward "^ ")
	    (if (looking-at "[0-9]+")
		(setq line (parse-integer (match-string 0)))
	      (error "行番号がわからんっす")
	    )
	    (goto-bol)
	    (while (looking-at "^[ ┃┣┗]")
	      (forward-line -1))
	    (if (looking-at "^[^ ]+")
		(setq file (match-string 0))
	      (error "ファイル名がわからんっす")
	    )
	  )
	(when (looking-at "^[^ ]+")
	  (setq line 1)
	  (setq file (match-string 0))
	)
      )
    )
    (values file line)
  ))

(defun ruby-lister-quit ()
  (interactive)
  (delete-other-windows)
  (delete-buffer *ruby-lister-buffer-name*)
)

(defun ruby-lister ()
  (interactive)
  (let ((data (ruby-lister-read-rtags)))
    (delete-other-windows)
    (split-window-vertically *ruby-lister-width*)
    (switch-to-buffer *ruby-lister-buffer-name*)
    (ruby-lister-mode)
    (setq ruby-lister-data data)
    (ruby-lister-output)
  ))

(defun ruby-lister-output ()
  (interactive)
  (let ((data ruby-lister-data)
	(buffer-read-only nil))
    (declare (special buffer-read-only))
    (erase-buffer (selected-buffer))
    (message "Formatting ...")
    (dolist (f data)
      (let ((file (car f))
	    (dat (cdr f))
	    (curp (point)))
	(insert (format nil (format nil "~~~D@A~~%" *ruby-lister-width*) file))
;	(reverse-region curp (1- (point)))
	(set-text-attribute curp (1- (point))
			    'file
			    :foreground *ruby-lister-file-fgcolor*
			    :background *ruby-lister-file-bgcolor*
	)
;	(dolist (x dat)
;	  (ruby-lister-output-print (car x) 1 nil)
;	)
	(dotimes (i (list-length dat))
	  (if (= i (1- (list-length dat)))
	      (ruby-lister-output-print (car (nth i dat)) "   " "┗ ")
	    (ruby-lister-output-print (car (nth i dat)) "┃ " "┣ ")
	  )
	)
      )
    )
    (goto-char (point-min))
    (message "Formatting ... done")
  ))

(defun ruby-lister-output-print (y level mark)
  (let ((type (cadr (assoc 'type y)))
	(name (cadr (assoc 'name y)))
	(line (cadr (assoc 'line y)))
	(data (cadr (assoc 'data y)))
	beg)
    (insert mark)
    (setq beg (point))
    (insert (format nil "~7@A" (symbol-name type)))
    (set-text-attribute beg (point)
			type
			:foreground (cadr (assoc type *ruby-lister-colors*))
    )
    (insert (format nil "~30@A ~D~%" name line))
;    (dolist (x data)
;      (ruby-lister-output-print x (1+ level) nil)
;    )
    (dotimes (i (list-length data))
      (if (= i (1- (list-length data)))
	  (ruby-lister-output-print (nth i data) (concat level "   ") (concat level "┗ "))
	(ruby-lister-output-print (nth i data) (concat level "┃ ") (concat level "┣ "))
      )
    )
  ))

(defun ruby-lister-read-rtags ()
  (let (data
	(file (merge-pathnames *ruby-lister-rtags-file* (default-directory))))
    (unless (file-exist-p file)
      (error "~Aがないっす" file))
    (save-excursion
      (set-buffer (get-buffer-create *ruby-lister-buffer-temp*))
      (erase-buffer *ruby-lister-buffer-temp*)
      (insert-file file)
      (setq data (ruby-read-rtags))
      (delete-buffer *ruby-lister-buffer-temp*)
    )
    data
  ))

(defun ruby-read-rtags ()
  (interactive)
  (let (data
	file
	cur)
    (message "Reading TAGS file ...")
    (save-excursion
      (goto-char (point-min))
      (while
	  (cond ((looking-at "^")
		 (unless (forward-line 1) (return))
		 (when cur
		   (push (nreverse cur) data)
		   (setq cur nil)
		 )
		 (if (looking-at "^\\([^,]+\\),[0-9]+")
		     (progn
		       (setq file (match-string 1))
		       (setq cur (list file))
		       (forward-line 1)
		     )
		   (error "Can not get filename")
		 ))
		((looking-at *ruby-lister-package-regexp*)
		 (push (list (ruby-read-rtags-class 0)) cur)
		)
		((looking-at *ruby-lister-function-regexp*)
		 (let (tmp)
		   (push (list 'type (intern (match-string 1))) tmp)
		   (push (list 'name (match-string 2)) tmp)
		   (push (list 'line (parse-integer (match-string 3))) tmp)
		   (push (list tmp) cur)
		   (forward-line 1)
		 ))
		((looking-at *ruby-lister-attr-regexp*)
		 (let (tmp)
		   (push (list 'type (intern (match-string 1))) tmp)
		   (push (list 'name (match-string 2)) tmp)
		   (push (list 'line (parse-integer (match-string 3))) tmp)
		   (push (list tmp) cur)
		   (forward-line 1)
		 ))
		(t
		 (forward-line 1)
		)
	  );cond
	;(message-box (format nil "~D: ~S" (current-line-number) cur))
      );while
      (when cur
	(push (nreverse cur) data))
    )
    (message "Reading TAGS file ... done")
    (nreverse data)
  ))

(defun ruby-lister-indent (level)
  (let ((space ""))
    (dotimes (i level)
      (setq space (concat space "  ")))
    space
  ))

(defun ruby-read-rtags-class (level)
  (let (class
	data
	(space (ruby-lister-indent level))
       )
    (when (looking-at (concat space *ruby-lister-package-regexp*))
      (push (list 'type (intern (match-string 1))) class)
      (push (list 'name (match-string 2)) class)
      (push (list 'line (parse-integer (match-string 3))) class)
      ;(message-box (format nil "~D: ~S" level class))
      (unless (forward-line 1)
	(return-from ruby-read-rtags-class class))
      (incf level 1)
      (setq space (ruby-lister-indent level))
      (while (looking-at (concat space *ruby-lister-head-regexp*))
	(cond ((looking-at (concat space *ruby-lister-package-regexp*))
	       (push (ruby-read-rtags-class level) data)
	      )
	      ((looking-at (concat space *ruby-lister-function-regexp*))
	       (let (tmp)
		 (push (list 'type (intern (match-string 1))) tmp)
		 (push (list 'name (match-string 2)) tmp)
		 (push (list 'line (parse-integer (match-string 3))) tmp)
		 (push tmp data)
		 (unless (forward-line 1) (return))
	       ))
	      ((looking-at (concat space *ruby-lister-attr-regexp*))
	       (let (tmp)
		 (push (list 'type (intern (match-string 1))) tmp)
		 (push (list 'name (match-string 2)) tmp)
		 (push (list 'line (parse-integer (match-string 3))) tmp)
		 (push tmp data)
		 (unless (forward-line 1) (return))
	       ))
	      (t
	       (return))
	);cond
      );while
      (push (list 'data (nreverse data)) class)
    )
    (nreverse class)
  ))

(defun ruby-lister-show-data ()
  (interactive)
  (message-box (format nil "~S" ruby-lister-data)))
