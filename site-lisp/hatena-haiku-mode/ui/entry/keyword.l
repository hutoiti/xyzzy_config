;;;; -*- mode: lisp; package: hatena-haiku.ui -*-
;;;;
;;;; File: hatena-haiku-mode/ui/entry/keyword.l
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

(export '(haiku-keyword-entries-pane
          ))

(defvar *haiku-keyword-entry-mode-hook* nil)

(defun haiku-keyword-entries-pane (keyword)
  (interactive "sKeyword: ")
  (haiku-save-history 'haiku-keyword-entries-pane keyword)
  (haiku-create-entry-pane
   'haiku-init-keyword-entry-buffer
   (list keyword)))

(defun haiku-init-keyword-entry-buffer (b keyword)
  (erase-buffer b)
  (haiku-keyword-entry-mode b keyword))

(defun haiku-keyword-entry-mode (buffer keyword)
  (with-temporary-set-buffer (buffer)
    (kill-all-local-variables)
    (init-entry-local-variable buffer)
    (make-lv '@reload-function 'haiku-reload-entry)
    (make-lv '@super-reload-function 'haiku-super-reload-entry)
    (make-lv '@entry-fetcher 'keyword-entries)
    (make-lv '@entry-fetcher-arg keyword)
    (make-lv '@post-title keyword)
    (setf buffer-mode 'haiku-keyword-entry-mode)
    (setf mode-name "Haiku: Keyword Entry")
    (use-keymap *haiku-keyword-entry-map*)
    (setup-local-window-flags *haiku-entry-window-flags* buffer)
    (run-hooks '*haiku-entry-mode-hook*)
    (run-hooks '*haiku-keyword-entry-mode-hook*)
    ))


(provide "hatena-haiku-mode/ui/entry/keyword")

;;;; End
