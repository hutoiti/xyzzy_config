;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: mail-signature.l 779 2007-12-23 05:14:06Z torihat $
;
; junk/mail-signature.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "junk/defs")
  (require "junk/macro"))

(require "junk/lib")
(require "junk/mail")

(provide "junk/mail-signature")

(in-package "junk")

(defstruct mailsignature
  email
  signature)

(defvar *mail-signature-mode-name* "MailSignature")
(defvar *mail-signature-mode-hook* nil)

(defvar *mail-signature-winconf* nil)

(defvar *mail-signature-buffer*      "*Junk: Signature*")

(defvar *mail-signature-list* nil)
(defvar *mail-signature-current* 0)

(defvar *mail-signature-window-height* nil)

(defvar *mail-signature-map* nil)
(unless *mail-signature-map*
  (setq *mail-signature-map* (make-sparse-keymap))
  (define-key *mail-signature-map* #\SPC   'mail-signature-next)
  (define-key *mail-signature-map* #\C-h   'mail-signature-prev)
  (define-key *mail-signature-map* #\n     'mail-signature-next)
  (define-key *mail-signature-map* #\p     'mail-signature-prev)
  (define-key *mail-signature-map* #\j     'mail-signature-next)
  (define-key *mail-signature-map* #\k     'mail-signature-prev)
  (define-key *mail-signature-map* #\Down  'mail-signature-next)
  (define-key *mail-signature-map* #\Up    'mail-signature-prev)
  (define-key *mail-signature-map* #\Right 'mail-signature-next)
  (define-key *mail-signature-map* #\Left  'mail-signature-prev)
  (define-key *mail-signature-map* #\i     'mail-signature-insert)
  (define-key *mail-signature-map* #\RET   'mail-signature-insert)
  (define-key *mail-signature-map* #\q     'mail-signature-close)
  )

(defun mail-signature-buffer-set ()
  (set-buffer (get-buffer-create *mail-signature-buffer*)))

(defun mail-signature-buffer-clear ()
  (let ((bufs (list *mail-signature-buffer*)))
    (dolist (buf bufs)
      (when (find-buffer buf)
	(delete-buffer buf)))))

(defun mail-signature-mode-line ()
  (let* ((cnt (length *mail-signature-list*))
	 (cur (if (= 0 cnt) 0 (1+ *mail-signature-current*))))
    (setq mode-line-format (format nil "%b: ~D/~D" cur cnt))))

(defun mail-signature-window-create (&optional height)
  (setq height (or height *mail-signature-window-height*))
  (mail-signature-winconf-save)
  (split-window height)
  (refresh-screen)
  (other-window 1))

(defun mail-signature-winconf-save ()
  (setq *mail-signature-winconf*
	(current-window-configuration)))

(defun mail-signature-winconf-restore ()
  (when *mail-signature-winconf*
    (set-window-configuration *mail-signature-winconf*)
    (setq *mail-signature-winconf* nil)))

(defun mail-signature-mode ()
  (interactive)
  (kill-all-local-variables)
  (make-local-variable 'mode-line-format)
  (setq mode-name *mail-signature-mode-name*)
  (setq buffer-read-only t)
  (setq need-not-save t)
  (setq kept-undo-information nil)
  (setq auto-save nil)
  (toggle-ime nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-line-number* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-newline* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-eof* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-cursor-line* t)
  (set-buffer-fold-width t)
  (use-keymap *mail-signature-map*)
  (run-hooks '*mail-signature-mode-hook*))

(defun mail-signature-current ()
  (let* ((len (length *mail-signature-list*)))
    (when (zerop len)
      (junk-error "No signatures set."))
    (nth (mod *mail-signature-current* len) *mail-signature-list*)))

(defun mail-signature-guess (email)
  (let ((len (length *mail-signature-list*)))
    (dotimes (i len)
      (let ((sig (nth i *mail-signature-list*)))
	(when (equal email (mailsignature-email sig))
	  (return-from mail-signature-guess i))))
    0))

(defun mail-signature-show ()
  (let ((sig (mail-signature-current)))
    (unless sig
      (junk-error "~S" sig))
    (junk::modify-read-only-buffer
      (erase-buffer (selected-buffer))
      (insert (format nil "~@[~A~]" (mailsignature-signature sig)))
      (goto-char (point-min))
      (mail-signature-mode-line))
    ))

(defun mail-signature-open (&optional email)
  (interactive)
  (unless *mail-signature-list*
    (junk-error "No signatures set."))
  (setq *mail-signature-current* 0)
  (when (= 1 (length *mail-signature-list*))
    (let ((sig (car *mail-signature-list*)))
      (insert (mailsignature-signature sig))
      (return-from mail-signature-open)))
  (when email
    (setq *mail-signature-current* (mail-signature-guess email)))
  (mail-signature-window-create)
  (mail-signature-buffer-set)
  (mail-signature-mode)
  (mail-signature-show))

(defun mail-signature-next (&optional (p 1))
  (interactive)
  (setq *mail-signature-current*
	(mod (+ p *mail-signature-current*)
	     (length *mail-signature-list*)))
  (mail-signature-show))

(defun mail-signature-prev ()
  (interactive)
  (mail-signature-next -1))

(defun mail-signature-insert ()
  (interactive)
  (let ((sig (mail-signature-current)))
    (mail-signature-close)
    (when sig
      (insert (format nil "~@[~A~]" (mailsignature-signature sig))))))

(defun mail-signature-close ()
  (interactive)
  (mail-signature-winconf-restore)
  (mail-signature-buffer-clear))
