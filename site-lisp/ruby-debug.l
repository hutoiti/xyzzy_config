;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: ruby-debug.l,v 1.1.1.1 2005/11/25 13:06:17 torihat Exp $
;
; ruby-debug.l
;
; by HATTORI Masashi

(provide "ruby-debug")

(require "ruby")

(in-package "editor")

(export '(*ruby-debug-mode-hook*
	  *ruby-debug-prompt-regexp*
	  *ruby-debug-mode-map*
	  *ruby-debug-ret*
	  ruby-debug
	  ruby-debug-send-input
	  ruby-debug-send-interrupt
	  ruby-debug-send-command
	  ruby-debug-quit
	  ruby-debug-alternate-send-input))

(defvar-local *ruby-debug-minor-mode* nil)
(defvar *ruby-debug-mode-hook* nil)

(defvar *ruby-debug-ret* "\n")
(defvar *ruby-buffer-debug* "*Ruby Debug*")
(defvar *ruby-window-debug* nil)

(defvar *ruby-debug-buffer-list* nil)

(defvar *ruby-debug-last-command* nil)
(defvar *ruby-debug-old-winconf* nil)

(defvar *ruby-debug-command-list*
  '(("break")
    ("info")
    ("watch")
    ("delete")
    ("display")
    ("undisplay")
    ("cont")
    ("step")
    ("next")
    ("where")
    ("frame")
    ("list")
    ("up")
    ("down")
    ("finish")
    ("quit")
    ("p")))

(define-key *ruby-mode-map* '(#\C-x #\d) 'ruby-debug)

(defvar *ruby-debug-mode-map* nil)
(unless *ruby-debug-mode-map*
  (setq *ruby-debug-mode-map* (make-sparse-keymap))
  (define-key *ruby-debug-mode-map* #\RET 'ruby-debug-send-command)
  (define-key *ruby-debug-mode-map* #\Y 'ruby-debug-command-yes)
  (define-key *ruby-debug-mode-map* #\y 'ruby-debug-command-yes)
  (define-key *ruby-debug-mode-map* #\N 'ruby-debug-command-no)
  (define-key *ruby-debug-mode-map* #\q 'ruby-debug-command-quit)
  (define-key *ruby-debug-mode-map* #\Q 'ruby-debug-command-quit-yes)
  (define-key *ruby-debug-mode-map* #\b 'ruby-debug-command-break)
  (define-key *ruby-debug-mode-map* #\B 'ruby-debug-command-info-break)
  (define-key *ruby-debug-mode-map* #\w 'ruby-debug-command-watch)
  (define-key *ruby-debug-mode-map* #\d 'ruby-debug-command-delete)
  (define-key *ruby-debug-mode-map* #\D 'ruby-debug-command-delete-all)
  (define-key *ruby-debug-mode-map* #\e 'ruby-debug-command-display)
  (define-key *ruby-debug-mode-map* #\E 'ruby-debug-command-display-info)
  (define-key *ruby-debug-mode-map* #\u 'ruby-debug-command-undisplay)
  (define-key *ruby-debug-mode-map* #\U 'ruby-debug-command-undisplay-all)
  (define-key *ruby-debug-mode-map* #\c 'ruby-debug-command-cont)
  (define-key *ruby-debug-mode-map* #\s 'ruby-debug-command-step)
  (define-key *ruby-debug-mode-map* #\n 'ruby-debug-command-next)
  (define-key *ruby-debug-mode-map* #\h 'ruby-debug-command-where)
  (define-key *ruby-debug-mode-map* #\C-Up 'ruby-debug-command-up)
  (define-key *ruby-debug-mode-map* #\C-Down 'ruby-debug-command-down)
  (define-key *ruby-debug-mode-map* #\f 'ruby-debug-command-finish)
  (define-key *ruby-debug-mode-map* #\p 'ruby-debug-command-p)
)

(defun ruby-debug-mode ()
  (setq mode-name "ruby-debug")
  (setq buffer-mode 'ruby-debug-mode)
  (use-keymap *ruby-debug-mode-map*)
  (setq need-not-save t)
  (setq auto-save nil)
  (setq kept-undo-information nil)
  (set-buffer-fold-width 80)
  (run-hooks '*ruby-debug-mode-hook*))

(defun ruby-debug-minor-mode (&optional (arg nil sv))
  (interactive "p")
  (toggle-mode '*ruby-debug-minor-mode* arg sv)
  (update-mode-line t)
  (if *ruby-debug-minor-mode*
      (progn
	(set-minor-mode-map *ruby-debug-mode-map*)
	(setq buffer-read-only t)
	(pushnew (buffer-name (selected-buffer)) *ruby-debug-buffer-list* :test #'equal))
    (progn
      (unset-minor-mode-map *ruby-debug-mode-map*)
      (setq buffer-read-only nil)
      (when (interactive-p)
	(loop
	  (let ((buf (pop *ruby-debug-buffer-list*)))
	    (or buf (return))
	    (when (find-buffer buf)
	      (set-buffer buf)
	      (clear-all-text-attributes)
	      (when *ruby-debug-minor-mode*
		(ruby-debug-minor-mode))))))))
  t)

(pushnew '(*ruby-debug-minor-mode* . "rdb") *minor-mode-alist* :key #'car)

(defun ruby-debug ()
  (interactive)
  (call-interactively 'ruby-debug-minor-mode)
  (unless *ruby-debug-minor-mode*
    (when *ruby-debug-old-winconf*
      (set-window-configuration *ruby-debug-old-winconf*))
    (return-from ruby-debug))
  (ruby-debug-init)
  (setq *ruby-debug-old-winconf* (current-window-configuration))
  (let (curw dbgcmd)
    (setq dbgcmd
	  (read-string "Ruby Debug: "
		       :default (format nil
					"~A -r debug ~A"
					*ruby-prog*
					(or (get-buffer-file-name) ""))))
    (delete-other-windows)
    (split-window)
    (setq curw (selected-window))
    (pop-to-buffer (get-buffer-create *ruby-buffer-debug*))
    (let ((proc (buffer-process (selected-buffer))))
      (and proc (eq (process-status proc) ':run)
	   (setq *ruby-debug-process* proc)
	   (return-from ruby-debug t)))
    (goto-char (point-max))
    (ruby-debug-mode)
    (setq *ruby-debug-process*
	  (make-process dbgcmd :output (selected-buffer)))
    (set-process-filter *ruby-debug-process* 'ruby-debug-filter)
    (setq *ruby-window-debug* (selected-window))
    (set-window curw)))

(defun ruby-debug-send-command (&optional cmd)
  (interactive "sCommand: " :default (or *ruby-debug-last-command* ""))
  (save-window-excursion
    (pop-to-buffer *ruby-buffer-debug*)
    (let ((process (buffer-process (selected-buffer))))
      (when (and process
		 (eq (process-status process) :run))
	(goto-char (point-max))
	;(insert (format nil "~A~%" cmd))
	(set-marker (process-marker process))
	(process-send-string process (concatenate 'string cmd *ruby-debug-ret*))
      ))))

(setf (symbol-function 'ruby-debug-send-interrupt) #'kill-subprocess)

(defun ruby-debug-init ()
  (setq *ruby-debug-display-list* nil)
  (setq *ruby-debug-break-points* nil))

(defun ruby-debug-quit ()
  (interactive)
  (ruby-debug-command-quit t)
  (ruby-debug))

(defvar *ruby-debug-filename-regexp*
  "^\\(#[0-9]+ \\)?\\(\\([a-zA-Z]:\\)?[^: \t\n\r]+\\):\\([0-9]+\\)")
(defvar *ruby-debug-prompt-regexp* "(rdb:-)")

(defvar *ruby-debug-process-line* "")
(defvar *ruby-debug-wait-for-prompt* nil)

(defun ruby-debug-filter (process line)
  (let (file num curp)
    (setq line (concat *ruby-debug-process-line* line))
    (when *ruby-debug-wait-for-prompt*
      (if (string-match *ruby-debug-prompt-regexp* line)
	  (setq *ruby-debug-process-line* "")
	(progn
	  (setq *ruby-debug-process-line* line)
	  (refresh-screen)
	  (return-from ruby-debug-filter))))
    (set-window *ruby-window-debug*)
    (goto-char (point-max))
    (setq curp (point))
    ;(message-box line)
    (insert line)
    (when (string-match *ruby-debug-filename-regexp* line)
      (set-text-attribute (+ curp (match-beginning 2))
			  (+ curp (match-end 2))
			  'file
			  :bold t))
    (when (string-match *ruby-debug-prompt-regexp* line)
      (set-text-attribute (+ curp (match-beginning 0))
			  (+ curp (match-end 0))
			  'prompt
			  :underline t))
    (when (pos-not-visible-in-window-p (point))
      (recenter (- (window-lines) 1)))
    (other-window)
    (when (string-match *ruby-debug-filename-regexp* line)
      (setq file (substring line (match-beginning 2) (match-end 2)))
      (setq num (parse-integer
		 (substring line (match-beginning 4) (match-end 4))))
      (unless (match-beginning 3)
	; for cygwin pathname
	(when (string-matchp "^/\\(cygdrive\\)?/\\([a-zA-Z]\\)/" file)
	  (let ((drive (substring file (match-beginning 2) (match-end 2))))
	    (setq file (concat drive
			       ":/"
			       (substring file (match-end 0) (length file)))))))
      ;(message-box file)
      (let ((buf (ruby-debug-find-buffer file)))
	(if buf
	    (set-buffer buf)
	  (progn
	    (while (not (file-exist-p file))
	      (message-box (format nil "~A‚ªŒ©‚Â‚©‚è‚Ü‚¹‚ñ" file))
	      (setq file (read-file "File: " :default file)))
	    (when (file-exist-p file)
	      (find-file file t)))))
      (unless *ruby-debug-minor-mode*
	(ruby-debug-minor-mode))
      (when (path-equal file (buffer-name (selected-buffer)))
	(goto-line num)
	(recenter)))
    (refresh-screen)))

(defun ruby-debug-find-buffer (buf)
  (dolist (b (buffer-list))
    (when (equalp buf (buffer-name b))
      (return-from ruby-debug-find-buffer b)))
  nil)

(defun ruby-debug-send-input ()
  (interactive)
  (let (command)
    (goto-bol)
    (when (looking-at "([^)]+)[ \t]+")
      (goto-char (match-end 0))
      (unless (eolp)
	(let ((curp (point)))
	  (setq command (buffer-substring curp
					  (progn (goto-eol) (point))))
	  (delete-region curp (point))
	  (ruby-debug-send-command command)
	)))))

(defun ruby-debug-command-yes ()
  (interactive)
  (ruby-debug-send-command "y"))

(defun ruby-debug-command-no ()
  (interactive)
  (ruby-debug-send-command "n"))

(defun ruby-debug-command-quit-yes ()
  (interactive)
  (ruby-debug-command-quit t))

(defun ruby-debug-command-quit (&optional yes)
  (interactive "p")
  (ruby-debug-send-command "quit")
  (when (or yes
	    (yes-or-no-p "really quit?"))
    (ruby-debug-command-yes)
    (call-interactively 'ruby-debug)))

(defvar *ruby-debug-break-points* nil)

(defun ruby-debug-break-point-add (line)
  (let ((num (1+ (list-length *ruby-debug-break-points*))))
    (push (cons line num) *ruby-debug-break-points*)
    (ruby-debug-reverse-break-point line)))

(defun ruby-debug-break-point (line)
  (cdr (assoc line *ruby-debug-break-points*)))

(defvar *ruby-debug-break-point-tag* 'break)

(defun ruby-debug-reverse-break-point (line)
  (save-excursion
    (goto-line line)
    (set-text-attribute (progn (goto-eol) (point))
			(progn (goto-bol) (point))
			(cons *ruby-debug-break-point-tag* line)
			:bold t
			:underline t)))

(defun ruby-debug-clear-break-point (line)
  (save-excursion
    (delete-text-attributes (cons *ruby-debug-break-point-tag* line) :test #'equal)))

(defun ruby-debug-clear-break-point-all ()
  (save-excursion
    (delete-text-attributes *ruby-debug-break-point-tag* :key #'car)))

(defun ruby-debug-command-break (&optional line)
  (interactive)
  (setq line (or line (current-line-number)))
  (ruby-debug-break-point-add line)
  (ruby-debug-send-command (format nil "break ~D" line)))

(defun ruby-debug-command-info-break ()
  (interactive)
  (ruby-debug-send-command "info break"))

(defun ruby-debug-command-watch (&optional line)
  (interactive)
  (setq line (or line (current-line-number)))
  (ruby-debug-break-point-add line)
  (ruby-debug-send-command (format nil "watch ~D" line)))

(defun ruby-debug-command-delete (&optional num)
  (interactive)
  (let ((line (current-line-number)))
    (setq num (or num (ruby-debug-break-point line)))
    (unless num
      (error "No break point for current line."))
    (ruby-debug-clear-break-point line)
    (ruby-debug-send-command (format nil "delete ~D" num))))

(defun ruby-debug-command-delete-all (&optional yes)
  (interactive "p")
  (ruby-debug-send-command "delete")
  (when (or yes
	    (yes-or-no-p "clear all break point?"))
    (ruby-debug-clear-break-point-all)
    (ruby-debug-command-yes)))

(defvar *ruby-debug-display-list* nil)

(defun ruby-debug-display-add (exp)
  (pushnew (list exp) *ruby-debug-display-list* :test #'equal))

(defun ruby-debug-display-del (exp)
  (delete exp *ruby-debug-display-list* :test #'equal :key #'car))

(defun ruby-debug-command-display (&optional exp)
  (interactive "sDisplay expression: ")
  (ruby-debug-display-add exp)
  (ruby-debug-send-command (format nil "display ~A" exp)))

(defun ruby-debug-command-display-info ()
  (interactive)
  (ruby-debug-send-command "info display"))

(defun ruby-debug-command-undisplay (&optional exp)
  (interactive)
  (setq exp (or exp
		(completing-read "Undisplay expression: "
				 *ruby-debug-display-list*
				 :default (or (car (car *ruby-debug-display-list*)) ""))))
  (ruby-debug-display-del exp)
  (ruby-debug-send-command (format nil "undisplay ~A" exp)))

(defun ruby-debug-command-undisplay-all (&optional yes)
  (interactive "p")
  (ruby-debug-send-command "undisplay")
  (when yes
    (ruby-debug-command-yes)))

(defun ruby-debug-command-cont ()
  (interactive)
  (ruby-debug-send-command "cont"))

(defun ruby-debug-command-step ()
  (interactive "p")
  (let ((step nil))
    (when n
      (setq step (read-integer "Step: ")))
    (ruby-debug-send-command (format nil "step~@[ ~D~]" step))))

(defun ruby-debug-command-next (&optional n)
  (interactive "p")
  (let ((step nil))
    (when n
      (setq step (read-integer "Next: ")))
    (ruby-debug-send-command (format nil "next~@[ ~D~]" step))))

(defun ruby-debug-command-where ()
  (interactive)
  (ruby-debug-send-command "where"))

(defun ruby-debug-command-up (&optional num)
  (interactive)
  (ruby-debug-send-command "up"))

(defun ruby-debug-command-down (&optional num)
  (interactive)
  (ruby-debug-send-command "down"))

(defun ruby-debug-command-finish ()
  (interactive)
  (ruby-debug-send-command "finish"))

(defvar *ruby-debug-p-last* nil)

(defun ruby-debug-command-p (&optional exp)
  (interactive "sPrint: " :default0 (or *ruby-debug-p-last* ""))
  (setq *ruby-debug-p-last* exp)
  (ruby-debug-send-command (format nil "p ~A" exp)))
