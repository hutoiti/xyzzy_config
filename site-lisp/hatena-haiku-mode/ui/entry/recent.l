;;;; -*- mode: lisp; package: hatena-haiku.ui -*-
;;;;
;;;; File: hatena-haiku-mode/ui/entry/recent.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008-2009 MIYAMUKO Katsuyuki.
;;;;
;;;;   hatena-haiku-mode is released under an MIT license.
;;;;   See hatena-haiku-mode/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "hatena-haiku-mode/ui/entry/base")
  )

(in-package :hatena-haiku.ui)

(export '(haiku-recent-entries-pane
          ))

(defvar *haiku-recent-mode-hook* nil)

(defun haiku-recent-entries-pane ()
  (interactive)
  (haiku-recent-pane 'haiku-recent-entries-pane
                     'recent-entries :entries
                     "Recent Entries"))

(defun haiku-recent-pane (fn fetcher type banner)
  (haiku-save-history fn)
  (haiku-create-entry-pane 'haiku-init-recent-buffer
                           (list fetcher type banner)))

(defun haiku-init-recent-buffer (b fetcher type banner)
  (erase-buffer b)
  (haiku-recent-mode b fetcher type banner))

(defun haiku-recent-mode (buffer fetcher type banner)
  (with-temporary-set-buffer (buffer)
    (kill-all-local-variables)
    (init-entry-local-variable buffer)
    (init-entry-local-variable buffer)
    (make-lv '@reload-function 'haiku-reload-entry)
    (make-lv '@super-reload-function 'haiku-super-reload-entry)
    (make-lv '@entry-fetcher fetcher)
    (make-lv '@entry-fetcher-arg nil)
    (make-lv '@entry-type type)
    (setf buffer-mode 'haiku-recent-mode)
    (setf mode-name (concat "Haiku: " banner))
    (use-keymap *haiku-recent-entry-map*)
    (setup-local-window-flags *haiku-entry-window-flags* buffer)
    (run-hooks '*haiku-entry-mode-hook*)
    (run-hooks '*haiku-recent-mode-hook*)
    ))


;;;; private

(defun haiku-show-new-entry-pane-recent-page ()
  (interactive)
  (haiku-show-new-entry-pane (current-entry-keyword)))

(defun entry-type (&optional (buffer (selected-buffer)))
  (safe-lv '@entry-type buffer))


(provide "hatena-haiku-mode/ui/entry/recent")

;;;; End
