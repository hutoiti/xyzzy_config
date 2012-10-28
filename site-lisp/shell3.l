;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; Original file was part of xyzzy-0.2.0.129
;;;
;;; �ւȂ��傱�g�� by HATTORI Masashi<gyo@he.mirai.ne.jp>
;;;
;;;	TAB		�t�@�C������⊮
;;;	C-r		�R�}���h���q�X�g���[����⊮
;;;	C-p, Up		�q�X�g���[��߂�
;;;	C-n, Down	�q�X�g���[��i��
;;;	C-a		�R�}���h�s���Ɉړ�

(provide "shell")

(in-package "editor")

(export '(*shell-mode-hook* *shell-prompt-regexp* *shell-mode-map*
	  *shell-ret* *shell-echo* *test2-keyword-file* shell shell-send-input shell-send-interrupt
	  shell-alternate-send-input))

(defvar *shell-mode-hook* nil)
(defvar *shell-prompt-regexp* "^[^#$%>?\n]*[#$%>?] *")
(defvar-local *shell-ret* "\n")
(defvar-local *shell-echo* nil)

(defvar *shell-mode-map* nil)
(unless *shell-mode-map*
  (setq *shell-mode-map* (make-sparse-keymap))
  (define-key *shell-mode-map* #\RET 'shell-send-input)
  (define-key *shell-mode-map* #\C-j 'shell-alternate-send-input)
  (define-key *shell-mode-map* '(#\C-c #\C-c) 'shell-send-interrupt))

(defun shell-mode ()
  (setq mode-name "Shell")
  (setq buffer-mode 'shell-mode)
  (use-keymap *shell-mode-map*)
  (setq need-not-save t)
  (setq auto-save nil)
  (setq kept-undo-information nil)
  (set-buffer-fold-width 80)
  (cond ((string-matchp *eshell* "command.com$")
	 (setq *shell-ret* "\r" *shell-echo* t))
	((string-matchp *eshell* "cmd.exe$")
	 (setq *shell-ret* "\n" *shell-echo* t))
	(t
	 (setq *shell-ret* "\n" *shell-echo* nil)))
  (use-syntax-table *test2-mode-syntax-table*)
  ; �L�[���[�h�̃��[�h
  (and *test2-keyword-file*
       (null *test2-keyword-hash-table*)
       (setq *test2-keyword-hash-table*
             (load-keyword-file *test2-keyword-file* t)))
  (when *test2-keyword-hash-table*
    (make-local-variable 'keyword-hash-table)
    (setq keyword-hash-table *test2-keyword-hash-table*))
  (run-hooks '*shell-mode-hook*))

(defun shell ()
  (interactive)
  (set-buffer (get-buffer-create "*Shell*"));get-buffer-create ������΍��
  (let ((proc (buffer-process (selected-buffer))));buffer-process�́A�v���Z�X��Ԃ�
    (and proc (eq (process-status proc) ':run);���̃o�b�t�@�ŊԈႢ�Ȃ��A�v���Z�X�������Ă���ꍇ�A���֐i�ށB
	 (return-from shell t)))
  (goto-char (point-max))
  (shell-mode)
  (make-process *eshell* :output (selected-buffer)))

;;;
;;; This code is loosely based on version 0.1 by Yutaka Oiwa <oiwa@is.s.u-tokyo.ac.jp>.
;;;

(defun shell-send-input ()
  (interactive)
  (let ((process (buffer-process (selected-buffer)))
	start end prompt)
    (when (and process
	       (eq (process-status process) :run))
      (cond ((>= (point) (marker-point (process-marker process)))
	     (setq start (marker-point (process-marker process)))
	     (setq end (progn (goto-eol) (point))))
	    ((save-excursion
	      (goto-bol)
	      (looking-at *shell-prompt-regexp*))
	     (setq start (match-end 0))
	     (setq end (progn (goto-eol) (point)))
	     (setq prompt (match-string 0)))
	    (t
	     (return-from shell-send-input nil)))
      (let ((cmd (buffer-substring start end)))
	(cond ((eobp)
	       (if *shell-echo*
		   (delete-region start end)
		 (insert "\n")))
	      (t
	       (goto-char (point-max))
	       (or (bolp)
		   (insert "\n"))
	       (and prompt (insert prompt))
	       (unless *shell-echo*
		 (insert cmd "\n"))))
	(set-marker (process-marker process))
	;;; add history
	(when (and cmd
		   (< 0 (length cmd)))
	  (shell-history-save)
	  (shell-history-backward-push cmd))
	(process-send-string process (concatenate 'string cmd *shell-ret*))))))

(defun shell-alternate-send-input ()
  (interactive)
  (let ((*shell-echo* (if (equal *shell-echo* "\n") "\r" "\n")))
    (declare (special *shell-echo*))
    (shell-send-input)))

;(setf (symbol-function 'shell-send-interrupt) #'kill-subprocess)
(setf (symbol-function 'shell-send-interrupt) #'(lambda ()(interactive) (progn (kill-subprocess)
							      (end-of-buffer))))
; 


;;;
;;; added by HATTORI Masashi<gyo@he.mirai.ne.jp>
;;;
(define-key *shell-mode-map* #\TAB 'shell-complete)
(define-key *shell-mode-map* #\Up 'shell-history-previous)
(define-key *shell-mode-map* #\M-p 'shell-history-previous)
(define-key *shell-mode-map* #\Down 'shell-history-next)
(define-key *shell-mode-map* #\M-n 'shell-history-next)
(define-key *shell-mode-map* #\C-a 'shell-goto-bol)
(define-key *shell-mode-map* #\C-r 'shell-history-search-backward)

(defvar *shell-prompt-regexp2* "^\\([^#$%>?\n]*\\)[#$%>?]")

(defun shell-complete ()
  (interactive)
  (let ((curp (point))
	dir
	files
	str
	start)
    (save-excursion
      (skip-chars-backward "^ #$%>?");<=����������
      (setq start (point))
      (setq str (buffer-substring start curp))
      (goto-bol)
      (when (looking-at *shell-prompt-regexp2*)
	(let ((match (string-trim " " (match-string 1))))
	  ; bash�̏ꍇ�i�ւȂ��傱�j
	  (if (and (string-matchp "bash" *eshell*)
		   (string-match "^//\\([a-zA-Z]\\)/" match))
	      (let ((drive (substring match 2 3)))
		(setq dir (concat drive ":" (substring match 3 (length match)))))
	    (setq dir (map-backslash-to-slash match))))
	(when (file-directory-p dir)
	  (setq files
		(mapcar #'(lambda (d) (string-right-trim "/" d))
			(directory dir
				   :wild (concat str "*")))
	  )))
    );save-excursion
    (when files
      (do-completion start (point) :list-ignore-case files))))

(defvar *shell-history-backward* nil)
(defvar *shell-history-current* nil)
(defvar *shell-history-forward* nil)

(defun shell-history-save ()
  (let (command)
    (when *shell-history-current*
      (shell-history-backward-push *shell-history-current*)
      (setq *shell-history-current* nil)
    )
    (while (setq command (shell-history-forward-pop))
      (shell-history-backward-push command)
    )
  ))

(defun shell-history-backward-push (command)
  (push (list command) *shell-history-backward*))

(defun shell-history-backward-pop ()
  (car (pop *shell-history-backward*)))

(defun shell-history-forward-push (command)
  (push (list command) *shell-history-forward*))

(defun shell-history-forward-pop ()
  (car (pop *shell-history-forward*)))

(defun shell-history-previous ()
  (interactive)
  (let ((command (shell-history-backward-pop)))
    (shell-prompt-reset)
    (when *shell-history-current*
      (shell-history-forward-push *shell-history-current*))
    (setq *shell-history-current* command)
    (if command
	(insert command)
      (message "No previous history.")
    )
  ))

(defun shell-history-next ()
  (interactive)
  (let ((command (shell-history-forward-pop)))
    (shell-prompt-reset)
    (when *shell-history-current*
      (shell-history-backward-push *shell-history-current*))
    (setq *shell-history-current* command)
    (if command
	(insert command)
      (message "No next history.")
    )
  ))

(defun shell-history-search-backward ()
  (interactive)
  (let ((curp (point))
	beg)
    (save-excursion
      (shell-goto-bol)
      (setq beg (point))
      (when (= beg curp)
	(return-from shell-history-search-backward))
    )
    (do-completion beg curp :list *shell-history-backward*)
  ))

(defun shell-prompt-reset ()
  (let ((curp (point)))
    (save-excursion
      (shell-goto-bol)
      (when (< (point) curp)
	(delete-region (point) curp))
    )))

(defun shell-goto-bol ()
  (interactive)
  (let ((curp (point)))
    (goto-bol)
    (if (looking-at *shell-prompt-regexp2*)
	(goto-char (match-end 0))
      (goto-char curp)
    )))
; �t�b�N
(defvar *test2-mode-hook* nil)

; �L�[�}�b�v
(defvar *test2-mode-map* nil)
(unless *test2-mode-map*
  (setq *test2-mode-map* (make-sparse-keymap)))

; �L�[���[�h
(defvar *test2-keyword-hash-table* nil)
(defvar *test2-keyword-file* "Test")

; �V���^�b�N�X�e�[�u��
(defvar *test2-mode-syntax-table* nil)
(unless *test2-mode-syntax-table*
  (setq *test2-mode-syntax-table* (make-syntax-table)))