;;;; -*- mode: lisp; package: hatena-haiku.ui -*-
;;;;
;;;; File: hatena-haiku-mode/ui/user-list.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;;;
;;;;   hatena-haiku-mode is released under an MIT license.
;;;;   See hatena-haiku-mode/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "hatena-haiku-mode/ui/base")
  )

(in-package :hatena-haiku.ui)

(defparameter *haiku-user-window-flags*
  `((,*window-flag-line-number* . nil)
    (,*window-flag-newline* . nil)
    (,*window-flag-eof* . nil)
    (,*window-flag-ruler* . nil)
    (,*window-flag-just-inverse* . t)
    (,*window-flag-cursor-line* . nil)
    (,*window-flag-fold-mark* . t)
    ))

(defun haiku-user-mode (&optional (buffer (selected-buffer))
                                  reload-function super-reload-function)
  (with-temporary-set-buffer (buffer)
    (kill-all-local-variables)
    (make-lv '@reload-function reload-function)
    (make-lv '@super-reload-function super-reload-function)
    (make-lv '@current-user-function 'current-user-name)
    (setf buffer-mode 'haiku-user-mode)
    (setf mode-name "Haiku: User")
    (use-keymap *haiku-entry-sidebar-user-map*)
    (setup-local-window-flags *haiku-user-window-flags* buffer)
    ))


(defun haiku-init-user-buffer (b &key reload-function super-reload-function)
  (erase-buffer b)
  (haiku-user-mode b reload-function super-reload-function))

(defun haiku-reset-user-buffer (&optional (b (selected-buffer)))
  (erase-buffer b))


;;;; render

(defun haiku-render-user-buffer (b users &key reset)
  (when reset
    (haiku-reset-user-buffer b))
  (haiku-insert-users b users))

(defun haiku-insert-users (buffer users)
  (with-temporary-writable (buffer)
    (with-append-to-buffer (buffer)
      (fresh-line)
      (dolist (u users)
        (render "~A" (html-textize (user-text u))
                `(:user ,u) *haiku-user-color*)
        (awhen (html-textize (user-keyword u))
          (render " Åu~AÅv" _it_))
        (terpri)))))


;;;; commands

(defun haiku-next-user1 ()
  (haiku-forward-text-attribute :user))
(define-prefix-argument-command haiku-next-user haiku-next-user1)

(defun haiku-previous-user1 ()
  (haiku-backward-text-attribute :user))
(define-prefix-argument-command haiku-previous-user haiku-previous-user1)

(defun haiku-open-user-by-browser ()
  (interactive)
  (awhen (current-user-name)
    (open-browser (user-entries-url _it_))))


;;;; private

(defun haiku-show-user-keyword-entry ()
  (interactive)
  (awhen (current-user-keyword)
    (haiku-keyword-entries-pane _it_)))

(defun haiku-show-user-entry ()
  (interactive)
  (awhen (current-user-name)
    (haiku-user-entries-pane _it_)))

(defun current-user-name ()
  (user-text (current-userinfo)))

(defun current-user-keyword ()
  (user-keyword (current-userinfo)))

(defun current-userinfo ()
  (multiple-value-bind (from to attr)
      (haiku-forward-text-attribute :user :no-dup nil)
    (awhen (cadr attr)
      _it_)))


(provide "hatena-haiku-mode/ui/user-list")

;;;; End
