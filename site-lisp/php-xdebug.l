;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: php-xdebug.l 749 2007-03-13 15:48:27Z torihat $
;
; php-xdebug.l
;
; by HATTORI Masashi

(provide "php-xdebug")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "php-mode")
  (require "xml-parser-modoki"))

(in-package "editor")

(export '(*php-xdebug-mode-hook*
	  *php-xdebug-control-mode-hook*
	  *php-xdebug-prompt-regexp*
	  *php-xdebug-mode-map*
	  *php-xdebug-ret*
	  *php-xdebug-attribute-breakpoint*
	  php-xdebug
	  php-xdebug-send-command
	  php-xdebug-quit))

(defvar-local *php-xdebug-minor-mode* nil)
(defvar *php-xdebug-mode-hook* nil)
(defvar *php-xdebug-control-mode-hook* nil)

(defvar *php-xdebug-opts* nil)

(defvar *php-xdebug-ret* "\n")
(defvar *php-xdebug-buffer-debug* "*PHP Xdebug*")
(defvar *php-xdebug-buffer-control* "*PHP Xdebug Control*")
(defvar *php-xdebug-buffer-parse* "*PHP Xdebug Parse*")
(defvar *php-xdebug-window-debug* nil)

(defvar *php-xdebug-encoding* nil)

(defvar *php-xdebug-command* "debugclient.exe")

(defvar *php-xdebug-base-local-directory* nil)
(defvar *php-xdebug-base-remote-url* nil)

(defvar *php-xdebug-last-command* nil)
(defvar *php-xdebug-old-winconf* nil)

(define-key *php-mode-map* '(#\C-c #\d) 'php-xdebug)

(defvar *php-xdebug-attribute-breakpoint* '(:underline t
					    :bold t))

(defvar *php-xdebug-prompt-string* "(cmd)")
(setq *php-xdebug-response-regexp*
      "[^<]*\\(<init.*/init>\\|<response.*/response>\\|<stream.*/stream>\\)")

(defvar *php-xdebug-process* nil)

(defvar *php-xdebug-process-line* "")
(defvar *php-xdebug-break-points* nil)
(defvar *php-xdebug-break-point-tag* 'php-xdebug-break)

(defvar *php-xdebug-response-init-hook* nil)

(defvar *php-xdebug-prefix-server* "DBG:")
(defvar *php-xdebug-prefix-client* "CLI:")

(defvar *php-xdebug-current-status* 'stopped)

(defvar *php-xdebug-control-mode-keyword-list*
  (compile-regexp-keyword-list
   '(("^DBG:.*$" nil 0)
     ("^CLI:.*$" nil 1)
     ("^ERR:.*$" nil 2))))

(defvar *php-xdebug-session-name* "xyzzy_php_xdebug")
(defvar *php-xdebug-url* nil)

(defvar *php-xdebug-mode* nil)
(defvar *php-xdebug-transaction-id* 0)

(defstruct xdebugbreakpoint
  path
  lineno
  condition
  id)

(defvar *php-xdebug-breakpoint-waiting-list* nil)
(defvar *php-xdebug-break-points-saved* nil)

(defvar *php-xdebug-property-last-name* nil)

(defvar *php-xdebug-breakpoint-condition* nil)

(defvar *php-xdebug-mode-map* nil)
;(unless *php-xdebug-mode-map*
  (setq *php-xdebug-mode-map* (make-sparse-keymap))
  (define-key *php-xdebug-mode-map* #\F5         'php-xdebug)
  (define-key *php-xdebug-mode-map* '(#\C-c #\i) 'php-xdebug-input-command)
  (define-key *php-xdebug-mode-map* #\F10        'php-xdebug-command-step-over)
  (define-key *php-xdebug-mode-map* #\F11        'php-xdebug-command-step-into)
  (define-key *php-xdebug-mode-map* #\C-F11      'php-xdebug-command-step-out)
  (define-key *php-xdebug-mode-map* #\F6         'php-xdebug-command-run)
  (define-key *php-xdebug-mode-map* #\C-F5       'php-xdebug-command-stop)
  (define-key *php-xdebug-mode-map* #\F1         'php-xdebug-command-stack-get)
  (define-key *php-xdebug-mode-map* #\F7         'php-xdebug-breakpoint-toggle)
  (define-key *php-xdebug-mode-map* #\C-F7       'php-xdebug-breakpoints-clear)
  (define-key *php-xdebug-mode-map* #\F8         'php-xdebug-property-get)
  (define-key *php-xdebug-mode-map* #\F9         'php-xdebug-property-value)
  (define-key *php-xdebug-mode-map* #\F12        'php-xdebug-start-url)
  (define-key *php-xdebug-mode-map* '(#\C-c #\q) 'php-xdebug-quit)
  (define-key *php-xdebug-mode-map* '(#\C-c #\x) 'php-xdebug-exit)
;)

(defvar *php-xdebug-error-code*
  '((  0 . "no error")
    (  1 . "parse error in command")
    (  2 . "duplicate arguments in command")
    (  3 . "invalid options (ie, missing a required option)")
    (  4 . "Unimplemented command")
    (  5 . "Command not available")
    (100 . "can not open file")
    (101 . "stream redirect failed")
    (200 . "breakpoint could not be set")
    (201 . "breakpoint type not supported")
    (202 . "invalid breakpoint")
    (203 . "no code on breakpoint line")
    (204 . "Invalid breakpoint state")
    (205 . "No such breakpoint")
    (206 . "Error evaluating code")
    (207 . "Invalid expression")
    (300 . "Can not get property")
    (301 . "Stack depth invalid")
    (302 . "Context invalid")
    (900 . "Encoding not supported")
    (998 . "An internal exception in the debugger occurred")
    (999 . "Unknown error ")))

(defun php-xdebug-minor-mode (&optional (arg nil sv))
  (interactive "p")
  (toggle-mode '*php-xdebug-minor-mode* arg sv)
  (update-mode-line t)
  (if *php-xdebug-minor-mode*
      (set-minor-mode-map *php-xdebug-mode-map*)
    (unset-minor-mode-map *php-xdebug-mode-map*))
  t)

(pushnew '(*php-xdebug-minor-mode* . "PHP-Xdebug") *minor-mode-alist* :key #'car)

(add-hook '*php-mode-hook* #'(lambda ()
			       (php-xdebug-minor-mode t)))

(defun php-xdebug-mode ()
  (setq mode-name "PHP-Xdebug")
  (setq buffer-mode 'php-xdebug-mode)
  (use-keymap *php-xdebug-mode-map*)
  (setq need-not-save t)
  (setq auto-save nil)
  (setq kept-undo-information nil)
  (set-buffer-fold-width t)
  (run-hooks '*php-xdebug-mode-hook*))

(defun php-xdebug-control-mode ()
  (kill-all-local-variables)
  (setq mode-name "PHP-Xdebug-Control")
  (setq buffer-mode 'php-xdebug-control-mode)
  (use-keymap *php-xdebug-mode-map*)
  (setq need-not-save t)
  (setq auto-save nil)
  (setq kept-undo-information nil)
  (set-buffer-fold-width t)
  (make-local-variable 'regexp-keyword-list)
  (setq regexp-keyword-list *php-xdebug-control-mode-keyword-list*)
  (run-hooks '*php-xdebug-control-mode-hook*))

(defun php-xdebug-transaction-id ()
  (incf *php-xdebug-transaction-id*))

(defun php-xdebug ()
  (interactive)
  (when *php-xdebug-mode*
    (when (php-xdebug-status-running-p)
      (php-xdebug-quit))
    (php-xdebug-terminate)
    (setq *php-xdebug-mode* nil)
    (when *php-xdebug-old-winconf*
      (set-window-configuration *php-xdebug-old-winconf*))
    (return-from php-xdebug))
  (setq *php-xdebug-old-winconf* (current-window-configuration))
  (let (curw
	(dbgcmd *php-xdebug-command*))
    (unless dbgcmd
      (setq dbgcmd
	    (read-string "Xdebug client: " :default *php-xdebug-command*)))
    (setq *php-xdebug-mode* t)
    (delete-other-windows)
    (split-window)
    (setq curw (selected-window))
    (pop-to-buffer (get-buffer-create *php-xdebug-buffer-debug*))
    (php-xdebug-mode) 
    (clear-all-text-attributes)
    (goto-char (point-max))
    (let ((proc (buffer-process (selected-buffer))))
      (and proc (eq (process-status proc) ':run)
	   (setq *php-xdebug-process* proc)
	   (return-from php-xdebug t)))
    (setq *php-xdebug-process*
	  (make-process dbgcmd
			:output (selected-buffer)
			:environ *php-xdebug-opts*
			))
    (set-process-filter *php-xdebug-process* 'php-xdebug-filter)
    (setq *php-xdebug-window-debug* (selected-window))
    (php-xdebug-control-mode-init)
    (set-window curw)
    ))

(defun php-xdebug-control-mode-init ()
  (set-buffer (get-buffer-create *php-xdebug-buffer-control*))
  (erase-buffer (selected-buffer))
  (php-xdebug-control-mode))

(defun php-xdebug-start-url ()
  (interactive)
  (let (dbgurl)
    (setq dbgurl
	  (read-string "URL: " :default *php-xdebug-url*))
    (setq *php-xdebug-url* dbgurl)
    (php-xdebug-open-url (php-xdebug-url-merge-param dbgurl))
    ))

(defun php-xdebug-url-merge-param (url)
  (let ((key "XDEBUG_SESSION_START"))
    (if (string-match "\\?.+" url)
	(format nil "~A&~A=~A" url key *php-xdebug-session-name*)
      (format nil "~A?~A=~A" url key *php-xdebug-session-name*))))

(defun php-xdebug-open-url (url)
  (shell-execute url t))

(defun php-xdebug-input-command (&optional cmd)
  (interactive "sCommand: " :default (or *php-xdebug-last-command* ""))
  (if (string-match "\\([a-zA-Z0-9_]+\\) +\\(.*\\)" cmd)
      (php-xdebug-send-command (match-string 1) (match-string 2))
    (php-xdebug-send-command cmd)))

(defun php-xdebug-send-command (&optional cmd params force)
  (save-window-excursion
    (pop-to-buffer *php-xdebug-buffer-control*)
    (let* ((transaction-id (php-xdebug-transaction-id))
	   (command (format nil "~A -i ~D~@[ ~A~]" cmd transaction-id params)))
      (goto-char (point-max))
      (unless (or (php-xdebug-status-running-p)
		  force)
	(php-xdebug-insert-client "ERR: process status is ~S~%"
				  *php-xdebug-current-status*))
      (unless (and (boundp '*php-xdebug-process*)
		   *php-xdebug-process*
		   (eq (process-status *php-xdebug-process*) :run))
	(php-xdebug-insert-client "ERR: process terminated: ~A~%"
				  *php-xdebug-command*))
      (when *php-xdebug-command*
	(message "~A" command)
	(php-xdebug-insert-client "~A~%" command)
	(when (pos-not-visible-in-window-p (point))
	  (recenter (- (window-lines) 1)))
	;(set-marker (process-marker process))
	(process-send-string *php-xdebug-process*
			     (concatenate 'string command *php-xdebug-ret*)))
      transaction-id
      )))

(defun php-xdebug-terminate ()
  (let ((cnt 0))
    (save-window-excursion
      (pop-to-buffer *php-xdebug-buffer-debug*)
      (let ((proc (buffer-process (selected-buffer))))
	(when (and proc
		   (eq (process-status proc) :run))
	  (message "terminating xdebug process ...")
	  (kill-subprocess))
	(while (and proc
		    (eq (process-status proc) :run))
	  (do-events)
	  (sit-for 0.1 t)
	  (incf cnt))
	(setq *php-xdebug-process* nil)
	(message "terminating xdebug process ... done.")
	))
    ))

(defun php-xdebug-quit ()
  (interactive)
  (php-xdebug-command-quit)
  (php-xdebug-clear-breakpoints t))

(defun php-xdebug-exit ()
  (interactive)
  (when *php-xdebug-mode*
    (php-xdebug)))

(defstruct xdebuginit
  fileuri
  language
  protocol_version
  appid
  idekey)

(defun xdebuginit-create (tag)
  (let* ((opts (ed::xmlpm-tag-opts tag)))
    (if opts
	(make-xdebuginit
	 :fileuri          (ed::xmlpm-tag-get-opt "fileuri"          opts)
	 :language         (ed::xmlpm-tag-get-opt "language"         opts)
	 :protocol_version (ed::xmlpm-tag-get-opt "protocol_version" opts)
	 :appid            (ed::xmlpm-tag-get-opt "appid"            opts)
	 :idekey           (ed::xmlpm-tag-get-opt "idekey"           opts))
      (make-xdebuginit))))

(defun php-xdebug-parse (line)
  (let (xml)
    (save-window-excursion
      (save-excursion
	(set-buffer (get-buffer-create *php-xdebug-buffer-parse*))
	(erase-buffer (selected-buffer))
	(setq need-not-save t)
	(insert line)
	(goto-char (point-min))
	(when (scan-buffer "<")
	  (delete-region (point-min) (point)))
	(while (scan-buffer *php-xdebug-prompt-string*)
	  (delete-region (match-beginning 0) (match-end 0)))
	(goto-char (point-min))
	(car (xmlpm-parse nil))))))

(defun php-xdebug-print-property (prop &optional (depth 1))
  (let ((c-name (ed::xmlpm-tag-name prop))
	(c-opts (ed::xmlpm-tag-opts prop))
	(c-contents (ed::xmlpm-tag-contents prop)))
    (let ((p-name        (ed::xmlpm-tag-get-opt "name"        c-opts))
	  (p-fullname    (ed::xmlpm-tag-get-opt "fullname"    c-opts))
	  (p-classname   (ed::xmlpm-tag-get-opt "classname"   c-opts))
	  (p-numchildren (ed::xmlpm-tag-get-opt "numchildren" c-opts))
	  (p-type        (ed::xmlpm-tag-get-opt "type"        c-opts))
	  (p-encoding    (ed::xmlpm-tag-get-opt "encoding"    c-opts))
	  (depth-indent (with-output-to-string (s)
			  (dotimes (i depth)
			    (format s "  ")))))
      (when p-fullname
	(php-xdebug-insert-server "~A~@[[~A]~]~%" depth-indent p-fullname))
      (when p-name
	(php-xdebug-insert-server "~A~@[  name    : ~A~]~%" depth-indent p-name))
      (when p-classname
	(php-xdebug-insert-server "~A~@[  class   : ~A~]~%" depth-indent p-classname))
      (when p-type
	(php-xdebug-insert-server "~A~@[  type    : ~A~]~%" depth-indent p-type))
      (dolist (cc c-contents)
	(cond ((stringp cc)
	       (let ((pos (point)))
		 (php-xdebug-insert-server "~A~@[  value   : ~A~]~%"
					   depth-indent
					   (if (equal p-encoding "base64")
					       (si:base64-decode cc)
					     cc))
		 (when (< pos (point))
		   (map-char-encoding-region pos (point) *php-xdebug-encoding*))
		 ))
	      ((and (listp cc)
		    (equal (ed::xmlpm-tag-name cc) "property"))
	       (php-xdebug-print-property cc (1+ depth)))
	      (t
	       (php-xdebug-insert-server "~S~%" cc))))
      )))

(defun php-xdebug-insert-server (fmt &rest args)
  (insert (apply #'format nil (concat *php-xdebug-prefix-server* fmt) args)))

(defun php-xdebug-insert-client (fmt &rest args)
  (insert (apply #'format nil (concat *php-xdebug-prefix-client* fmt) args)))

(defun php-xdebug-map-remote-to-local (path)
  path)

(defun php-xdebug-map-local-to-remote (path)
  path)

(defun php-xdebug-status-running-p ()
  (eq *php-xdebug-current-status* 'running))

(defun php-xdebug-error-find (code)
  (assoc code *php-xdebug-error-code*))

(defun php-xdebug-parse-response (xml)
  (let ((type (ed::xmlpm-tag-name xml))
	path
	lineno
	action)
    (handler-case
	(cond ((equal type "init") ; => init
	       (let ((x (xdebuginit-create xml)))
		 (when (xdebuginit-fileuri x)
		   (setq path (php-xdebug-map-remote-to-local
			       (php-xdebug-url-to-path (xdebuginit-fileuri x)))))
		 (php-xdebug-insert-server "init~@[: ~A~]~%" path)
		 (php-xdebug-insert-server "  ~20@A: ~@[~A~]~%" "language"         (xdebuginit-language x))
		 (php-xdebug-insert-server "  ~20@A: ~@[~A~]~%" "protocol_version" (xdebuginit-protocol_version x))
		 (php-xdebug-insert-server "  ~20@A: ~@[~A~]~%" "appid"            (xdebuginit-appid x))
		 (php-xdebug-insert-server "  ~20@A: ~@[~A~]~%" "idekey"           (xdebuginit-idekey x))
		 (setq *php-xdebug-current-status* 'running)
		 (setq *php-xdebug-transaction-id* 0)
		 (setq action 'load-breakpoints)
		 ))
	      ((equal type "response") ; => response
	       (let* ((opts (ed::xmlpm-tag-opts xml))
		      (contents (ed::xmlpm-tag-contents xml))
		      (command (ed::xmlpm-tag-get-opt "command" opts))
		      (transaction-id (ed::xmlpm-tag-get-opt "transaction_id" opts))
		      (status (ed::xmlpm-tag-get-opt "status" opts))
		      (reason (ed::xmlpm-tag-get-opt "reason" opts))
		      errors)
		 (when (and transaction-id
			    (< 0 (length transaction-id)))
		   (setq transaction-id (parse-integer transaction-id)))
		 (dolist (x contents)
		   (when (listp x)
		     (let ((content-name (ed::xmlpm-tag-name x))
			   (content-opts (ed::xmlpm-tag-opts x))
			   (content-contents (ed::xmlpm-tag-contents x)))
		       (when (equal content-name "error")
			 (push x errors)))))
		 (cond ((equal command "breakpoint_set") ; breakpoint_set
			(let ((id (ed::xmlpm-tag-get-opt "id" opts)))
			  (when (and transaction-id id)
			    (php-xdebug-insert-server "~A: ~A: ~A~%" transaction-id command id)
			    (php-xdebug-breakpoint-set-id transaction-id id))
			  ))
		       ((equal command "breakpoint_remove") ; breakpoint_remove
			(php-xdebug-insert-server "~@[~A~]: ~A~%" transaction-id command)
			)
		       ((equal command "stack_get") ; stack_get
			(php-xdebug-insert-server "~@[~A~]: ~A~%" transaction-id command)
			(unless errors
			  (let ((cnt 1))
			    (dolist (x contents)
			      (let* ((stack-name (ed::xmlpm-tag-name x))
				     (stack-opts (ed::xmlpm-tag-opts x))
				     (stack-contents (ed::xmlpm-tag-contents x)))
				(when (equal stack-name "stack")
				  (let ((where (ed::xmlpm-tag-get-opt "where" stack-opts))
					(level (ed::xmlpm-tag-get-opt "level" stack-opts))
					(stack-path (ed::xmlpm-tag-get-opt "filename" stack-opts))
					(stack-lineno (ed::xmlpm-tag-get-opt "lineno" stack-opts)))
				    (php-xdebug-insert-server "~@[~A~]~@[~A~]:~@[~A~]:Line ~@[~A~]: ~@[~A~]~%"
							      (with-output-to-string (s)
								(dotimes (i cnt)
								  (format s "=> ")))
							      level
							      where
							      stack-lineno
							      (and stack-path (php-xdebug-url-to-path stack-path)))
				    (when (and (not path)
					       stack-path)
				      (setq path (php-xdebug-map-remote-to-local
						  (php-xdebug-url-to-path stack-path))))
				    (when (and (not lineno)
					       stack-lineno)
				      (setq lineno stack-lineno)))))
			      (incf cnt))))
			)
		       ((or (equal command "run")
			    (equal command "step_into")
			    (equal command "step_over")
			    (equal command "step_out")
			    (equal command "status")
			    (equal command "stop")
			    (equal command "detach"))
			(php-xdebug-insert-server "~@[~A~]: ~A: ~@[~A~]~%" transaction-id command status)
			(cond ((or (equal status "break")
				   (equal status "running")
				   (equal status "starting"))
			       (setq action 'getstack)
			       (setq *php-xdebug-current-status* 'running))
			      (t
			       (setq *php-xdebug-current-status* 'stopped)
			       (setq action 'terminate)
			       ))
			)
		       ((equal command "property_get")
			(php-xdebug-insert-server "~@[~A~]: ~A~%" transaction-id command)
			(dolist (c contents)
			  (when (equal (ed::xmlpm-tag-name c) "property")
			    (php-xdebug-print-property c)))
			)
		       ((equal command "property_value")
			(php-xdebug-insert-server "~@[~A~]: ~A~%" transaction-id command)
			(let ((type (ed::xmlpm-tag-get-opt "type" opts))
			      (encoding (ed::xmlpm-tag-get-opt "encoding" opts)))
			  (dolist (c contents)
			    (cond ((stringp c)
				   (let ((pos (point)))
				     (php-xdebug-insert-server "~@[~A: ~]~A~%"
							       type
							       (if (equal encoding "base64")
								   (si:base64-decode c)
								 c))
				     (when (< pos (point))
				       (map-char-encoding-region pos (point) *php-xdebug-encoding*))
				     ))
				  ((listp c)
				   (php-xdebug-print-property c))
				  (t
				   (php-xdebug-insert-server "~S~%" c))))))
		       (t
			(php-xdebug-insert-server "~@[~A~]: ~S~%" transaction-id command)
			(php-xdebug-insert-server "~{~S~%~}" xml)
			(insert (format nil "ERR: unknown command ~S" command))
			))
		 (when errors
		   (dolist (err (reverse errors))
		     (let (codestr
			   code
			   error-cons)
		       (if (and (listp err)
				(setq codestr (ed::xmlpm-tag-get-opt "code"
								     (ed::xmlpm-tag-opts err)))
				(setq code (parse-integer codestr))
				(setq error-cons (php-xdebug-error-find code)))
			   (php-xdebug-insert-server "Error: ~D: ~A~%"
						     (car error-cons)
						     (cdr error-cons))
			 (insert (format nil "ERR: ~S~%" err))))))
		 ))
	      (t
	       (php-xdebug-insert-server "~{~S~%~}" xml))
	      )
      (error (c)
	(insert (format nil "ERR: ~A~%" (si:*condition-string c)))))
    (values path lineno action)
    ))

(defun php-xdebug-path-to-url (path)
  (concat "file:///"
	  (si:www-url-encode path nil "0-9A-Za-z-._~")))

(defun php-xdebug-url-encode (url)
  (if url
      (si:www-url-encode url nil "0-9A-Za-z-._~")
    ""))

(defun php-xdebug-url-to-path (url)
  (let ((path (php-xdebug-url-decode url)))
    (if (string-match "^file:///" path)
	(substring path (match-end 0) (length path))
      path)))

(defun php-xdebug-url-decode (url)
  (if url
      (si:www-url-decode url)
    ""))

(defun php-xdebug-filter (process line)
  (let (file num curp xml path lineno action)
    (set-window *php-xdebug-window-debug*)
    (set-buffer *php-xdebug-buffer-debug*)
    (goto-char (point-max))
    (setq curp (point))
    (insert line)
    (setq line (concat *php-xdebug-process-line* line))
    (if (string-match (concat *php-xdebug-prompt-string* " +") line)
	(setq *php-xdebug-process-line* "")
      (progn
	(setq *php-xdebug-process-line* line)
	(refresh-screen)
	(return-from php-xdebug-filter)))
    (setq xml (php-xdebug-parse line))
    (when (pos-not-visible-in-window-p (point))
      (recenter (- (window-lines) 1)))
    (set-buffer *php-xdebug-buffer-control*)
    (goto-char (point-max))
    (multiple-value-setq (path lineno action)
      (php-xdebug-parse-response xml))
    (when (pos-not-visible-in-window-p (point))
      (recenter (- (window-lines) 2)))
    (other-window)
    (when path
      (let ((buf (php-xdebug-find-buffer path)))
	(if buf
	    (set-buffer buf)
	  (php-xdebug-find-file path)))
      (when lineno
	(goto-line (parse-integer lineno))
	(recenter)))
    (case action
      ('getstack
       (php-xdebug-command-stack-get))
      ('terminate
       (php-xdebug-quit))
      ('load-breakpoints
       (php-xdebug-load-breakpoints))
      (t
       nil))
    (refresh-screen)
    ))

(defun php-xdebug-find-file (path)
  (find-file path)
  (unless *php-xdebug-minor-mode*
    (php-xdebug-minor-mode t)))

(defun php-xdebug-find-buffer (path)
  (car (member-if #'(lambda (x)
		      (let ((p (get-buffer-file-name x)))
			(and p
			     (path-equal p path))))
		  (buffer-list))))

(defun php-xdebug-breakpoint-equal (a b)
  (and (and (xdebugbreakpoint-path a)
	    (xdebugbreakpoint-path b)
	    (path-equal (xdebugbreakpoint-path a)
			(xdebugbreakpoint-path b)))
       (eq (xdebugbreakpoint-lineno a)
	   (xdebugbreakpoint-lineno b))))

(defun php-xdebug-breakpoint-number (breakpoint)
  (car breakpoint))

(defun php-xdebug-breakpoint-struct (breakpoint)
  (cdr breakpoint))

(defun php-xdebug-breakpoint-find (path lineno)
  (car (member-if #'(lambda (x)
		      (let ((b (php-xdebug-breakpoint-struct x)))
			(and (path-equal path (xdebugbreakpoint-path b))
			     (eq lineno (xdebugbreakpoint-lineno b)))))
		  *php-xdebug-break-points*)))

(defun php-xdebug-breakpoint-saved-find (path lineno)
  (car (member-if #'(lambda (b)
		      (and (path-equal path (xdebugbreakpoint-path b))
			   (eq lineno (xdebugbreakpoint-lineno b))))
		  *php-xdebug-break-points-saved*)))

(defun php-xdebug-breakpoint-set-id (transaction-id id)
  (let ((bnum (cdr (assoc transaction-id *php-xdebug-breakpoint-waiting-list*))))
    (when bnum
      (let ((b (cdr (assoc bnum *php-xdebug-break-points*))))
	(when b
	  (setf (xdebugbreakpoint-id b) id))))))

(defun php-xdebug-breakpoint-toggle (&optional condition-p)
  (interactive "p")
  (let ((path (get-buffer-file-name (selected-buffer)))
	(lineno (current-line-number)))
    (if (or (php-xdebug-breakpoint-find path lineno)
	    (php-xdebug-breakpoint-saved-find path lineno))
	(php-xdebug-breakpoint-unset)
      (let ((condition (if condition-p
			   (php-xdebug-breakpoint-condition-read))))
	(php-xdebug-breakpoint-set condition)))))

(defun php-xdebug-breakpoint-condition-read ()
  (read-string "Condition: " :default *php-xdebug-breakpoint-condition*))

(defun php-xdebug-breakpoint-set (&optional condition)
  (interactive "p")
  (let ((path (get-buffer-file-name (selected-buffer)))
	(lineno (current-line-number))
	(condition (if condition
		       (if (interactive-p)
			   (php-xdebug-breakpoint-condition-read)
			 condition)))
	bnum)
    (unless path
      (error "ファイル名がありません。"))
    (setq *php-xdebug-breakpoint-condition* condition)
    (php-xdebug-reverse-breakpoint path lineno)
    (if (and (boundp '*php-xdebug-process*)
	     *php-xdebug-process*
	     (php-xdebug-status-running-p))
	(let ((bnum (php-xdebug-breakpoint-add path lineno))
	      (transaction-id (php-xdebug-command-breakpoint-set path lineno condition)))
	  (when (and transaction-id bnum)
	    (pushnew (cons transaction-id bnum) *php-xdebug-breakpoint-waiting-list*
		     :test #'equal)))
      (let ((b (make-xdebugbreakpoint :path path
				      :lineno lineno
				      :condition condition)))
	(pushnew b *php-xdebug-break-points-saved*
		 :test 'php-xdebug-breakpoint-equal)))
    ))

(defun php-xdebug-breakpoint-next-number ()
  (let ((num 0))
    (dolist (b *php-xdebug-break-points*)
      (let ((bnum (php-xdebug-breakpoint-number b)))
	(when (< num bnum)
	  (setq num bnum))))
    (1+ num)))

(defun php-xdebug-breakpoint-add (path lineno)
  (let ((num (php-xdebug-breakpoint-next-number)))
    (pushnew (cons num
		   (make-xdebugbreakpoint :path path
					  :lineno lineno))
	     *php-xdebug-break-points*
	     :test #'php-xdebug-breakpoint-equal
	     :key #'cdr)
    num))

(defun php-xdebug-reverse-breakpoint (path lineno)
  (save-excursion
    (apply #'set-text-attribute
	   (progn (goto-eol) (point))
	   (progn (goto-bol) (point))
	   (php-xdebug-breakpoint-tag path lineno)
	   *php-xdebug-attribute-breakpoint*)))

(defun php-xdebug-breakpoint-unset ()
  (interactive)
  (let ((path (get-buffer-file-name (selected-buffer)))
	(lineno (current-line-number)))
    (unless path
      (error "ファイル名がありません。"))
    (php-xdebug-breakpoint-del path lineno)))

(defun php-xdebug-breakpoint-tag (path lineno)
  (format nil "~S-~@[~A~]-~@[~D~]"
	  *php-xdebug-break-point-tag*
	  path
	  lineno))

(defun php-xdebug-breakpoint-del (path lineno)
  (let* ((buf (php-xdebug-find-buffer path))
	 (b (php-xdebug-breakpoint-find path lineno))
	 (bs (php-xdebug-breakpoint-saved-find path lineno)))
    (save-excursion
      (when buf
	(set-buffer buf)
	(delete-text-attributes (php-xdebug-breakpoint-tag path lineno) :test #'equal)))
    (when b
      (setq *php-xdebug-break-points*
	    (delete (car b) *php-xdebug-break-points* :key #'car)))
    (when bs
      (setq *php-xdebug-break-points-saved*
	    (delete bs *php-xdebug-break-points-saved* :test 'php-xdebug-breakpoint-equal)))
    (when (and b
	       (xdebugbreakpoint-p
		(php-xdebug-breakpoint-struct b))
	       (xdebugbreakpoint-id
		(php-xdebug-breakpoint-struct b))
	       (php-xdebug-status-running-p))
      (php-xdebug-command-breakpoint-unset
       (xdebugbreakpoint-id
	(php-xdebug-breakpoint-struct b))))
    ))

(defun php-xdebug-load-breakpoints ()
  (save-excursion
    (dolist (b *php-xdebug-break-points-saved*)
      (let* ((path (xdebugbreakpoint-path b))
	     (lineno (xdebugbreakpoint-lineno b))
	     (condition (xdebugbreakpoint-condition b)))
	(when (file-exist-p path)
	  (php-xdebug-find-file path)
	  (goto-line lineno)
	  (php-xdebug-breakpoint-set condition)))))
  (setq *php-xdebug-break-points-saved* nil))

(defun php-xdebug-breakpoints-clear ()
  (interactive)
  (php-xdebug-clear-breakpoints nil)
  (setq *php-xdebug-break-points-saved* nil))

(defun php-xdebug-clear-breakpoints (&optional save)
  (let (done)
    (dolist (x *php-xdebug-break-points*)
      (let* ((num (php-xdebug-breakpoint-number x))
	     (b (php-xdebug-breakpoint-struct x))
	     (path (xdebugbreakpoint-path b))
	     (lineno (xdebugbreakpoint-lineno b)))
	(when (and path lineno)
	  (php-xdebug-breakpoint-del path lineno)
	  (pushnew path done :test #'path-equal)
	  (when save
	    (setf (xdebugbreakpoint-id b) nil)
	    (pushnew b *php-xdebug-break-points-saved*
		     :test 'php-xdebug-breakpoint-equal)))))
    (setq *php-xdebug-break-points* nil)))

(defun php-xdebug-command-step-into ()
  (interactive)
  (php-xdebug-send-command "step_into"))

(defun php-xdebug-command-step-over ()
  (interactive)
  (php-xdebug-send-command "step_over"))

(defun php-xdebug-command-step-out ()
  (interactive)
  (php-xdebug-send-command "step_out"))

(defun php-xdebug-command-run ()
  (interactive)
  (php-xdebug-send-command "run"))

(defun php-xdebug-command-stop ()
  (interactive)
  (php-xdebug-send-command "stop" nil t))

(defun php-xdebug-command-quit ()
  (interactive)
  (php-xdebug-send-command "detach" nil t))

(defun php-xdebug-command-stack-get ()
  (interactive)
  (php-xdebug-send-command "stack_get"))

(defun php-xdebug-property-get (name)
  (interactive "sProperty: " :default0 *php-xdebug-property-last-name*)
  (setq *php-xdebug-property-last-name* name)
  (php-xdebug-send-command "property_get" (concat "-n " name)))

(defun php-xdebug-property-value (name)
  (interactive "sProperty: " :default0 *php-xdebug-property-last-name*)
  (setq *php-xdebug-property-last-name* name)
  (php-xdebug-send-command "property_value" (concat "-n " name)))

(defun php-xdebug-command-breakpoint-set (path lineno &optional condition)
  (php-xdebug-send-command "breakpoint_set"
			   (format nil "-t ~A -f ~A -n ~D~@[ -- ~A~]"
				   (if condition "conditional" "line")
				   (php-xdebug-path-to-url path)
				   lineno
				   (if condition (si:base64-encode condition))
				   )))

(defun php-xdebug-command-breakpoint-unset (id)
  (when id
    (php-xdebug-send-command "breakpoint_remove"
			     (format nil "-d ~A" id))))
