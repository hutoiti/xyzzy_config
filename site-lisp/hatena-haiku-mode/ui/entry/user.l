;;;; -*- mode: lisp; package: hatena-haiku.ui -*-
;;;;
;;;; File: hatena-haiku-mode/ui/entry/user.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;;;
;;;;   hatena-haiku-mode is released under an MIT license.
;;;;   See hatena-haiku-mode/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "hatena-haiku-mode/ui/entry/base")
  )

(in-package :hatena-haiku.ui)

(export '(haiku-my-entries-pane
          haiku-my-following-pane
          haiku-my-profile-pane
          haiku-user-entries-pane
          haiku-user-following-pane
          haiku-user-profile-pane
          ))

(defvar *haiku-user-entry-mode-hook* nil)

(defun haiku-my-entries-pane ()
  (interactive)
  (prog1
      (haiku-user-entries-pane (hatena-username))
    (message (hatena-welcome-message))))

(defun haiku-my-following-pane ()
  (interactive)
  (prog1
      (haiku-user-following-pane (hatena-username))
    (message (hatena-welcome-message))))

(defun haiku-my-profile-pane ()
  (interactive)
  (prog1
      (haiku-user-profile-pane (hatena-username))
    (message (hatena-welcome-message))))


(defun haiku-user-entries-pane (user)
  (interactive "sUser: ")
  (haiku-user-pane 'haiku-user-entries-pane
                   user 'user-entries :entries nil
                   "User Entries"))

(defun haiku-user-following-pane (user)
  (interactive "sUser: ")
  (haiku-user-pane 'haiku-user-following-pane
                   user 'user-entries-following :following nil
                   "User Following"))

(defun haiku-user-profile-pane (user)
  (interactive "sUser: ")
  (haiku-user-pane 'haiku-user-profile-pane
                   user 'user-entries-profile :profile (make-hatena-id user)
                   "User Profile"))


(defun haiku-user-pane (fn user fetcher type title banner)
  (haiku-save-history fn user)
  (haiku-create-entry-pane 'haiku-init-user-entry-buffer
                           (list user fetcher type title banner)))

(defun haiku-init-user-entry-buffer (b user fetcher type title banner)
  (erase-buffer b)
  (haiku-user-entry-mode b (or (parse-hatena-id user) user) fetcher type title banner))

(defun haiku-user-entry-mode (buffer user fetcher type title banner)
  (with-temporary-set-buffer (buffer)
    (kill-all-local-variables)
    (init-entry-local-variable buffer)
    (make-lv '@reload-function 'haiku-reload-entry)
    (make-lv '@super-reload-function 'haiku-super-reload-entry)
    (make-lv '@entry-fetcher fetcher)
    (make-lv '@entry-fetcher-arg user)
    (make-lv '@entry-type type)
    (make-lv '@post-title title)
    (setf buffer-mode 'haiku-user-entry-mode)
    (setf mode-name (concat "Haiku: " banner))
    (use-keymap *haiku-user-entry-map*)
    (setup-local-window-flags *haiku-entry-window-flags* buffer)
    (run-hooks '*haiku-entry-mode-hook*)
    (run-hooks '*haiku-user-entry-mode-hook*)
    ))


;;;; command

(defun haiku-switch-user-entries ()
  (interactive)
  (haiku-user-entries-pane (entry-page-user-name)))

(defun haiku-switch-user-following ()
  (interactive)
  (haiku-user-following-pane (entry-page-user-name)))

(defun haiku-switch-user-profile ()
  (interactive)
  (haiku-user-profile-pane (entry-page-user-name)))


;;;; private

(defun entry-type (&optional (buffer (selected-buffer)))
  (safe-lv '@entry-type buffer))

(defun entry-page-user-name (&optional (buffer (selected-buffer)))
  (safe-lv '@entry-fetcher-arg))


(provide "hatena-haiku-mode/ui/entry/user")

;;;; End
