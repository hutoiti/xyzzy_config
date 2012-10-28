;;;; -*- mode: lisp; package: hatena-haiku.ui -*-
;;;;
;;;; File: hatena-haiku-mode/ui/base.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;;;
;;;;   hatena-haiku-mode is released under an MIT license.
;;;;   See hatena-haiku-mode/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "hatena-haiku-mode/ui/package")
  (require "hatena-haiku-mode/ui/config")
  (require "hatena-haiku-mode/ui/color")
  (require "hatena-haiku-mode/ui/buffer")
  (require "hatena-haiku-mode/ui/window")
  (require "hatena-haiku-mode/ui/frame")
  (require "hatena-haiku-mode/ui/browser")
  (require "hatena-haiku-mode/ui/pager")
  (require "hatena-haiku-mode/ui/time-keeper")
  (require "hatena-haiku-mode/ui/history")
  (require "hatena-haiku-mode/ui/star")
  (require "hatena-haiku-mode/ui/hatena")
  (require "hatena-haiku-mode/ui/keybind")
  )

(in-package :hatena-haiku.ui)

(export '(haiku-show
          haiku-hide
          haiku-quit
          ))

;;;; commands

(defun haiku-show ()
  (interactive)
  (switch-or-create-haiku-frame)
  (unless (haiku-buffer-p (selected-buffer))
    (aif (find-if 'haiku-buffer-p (buffer-list))
        (set-buffer _it_)
      (haiku-recent-entries-pane))))

(defun haiku-hide ()
  (interactive)
  (when (haiku-frame-p (selected-pseudo-frame))
    (switch-last-frame))
  (while (haiku-buffer-p (selected-buffer))
    (set-buffer (other-buffer))))

(defun haiku-quit ()
  (interactive)
  (haiku-init-history)
  (haiku-delete-all-buffers)
  (delete-haiku-frame))

(defun haiku-next-page-base1 (fn)
  (let ((moved (next-page)))
    (when (and (load-next-pages fn) (not moved))
      (haiku-next-page-base1 fn))))
(define-prefix-argument-command haiku-next-page-base haiku-next-page-base1)

(defun haiku-next-line-base1 (fn)
  (let ((moved (next-line)))
    (when (and (load-next-pages fn) (not moved))
      (haiku-next-line-base1 fn))))
(define-prefix-argument-command haiku-next-line-base haiku-next-line-base1)

(defun haiku-forward-text-attribute (tag &key (no-dup t))
  (scan-text-attribute tag :key #'safe-car :no-dup no-dup))

(defun haiku-backward-text-attribute (tag &key (no-dup t))
  (scan-text-attribute tag :key #'safe-car :no-dup no-dup :reverse t))

(defun haiku-backward-page ()
  (interactive)
  (if (haiku-history-backward?)
      (with-no-if-modified-since
        (haiku-history-backward))
    (message "ñﬂÇÍÇ‹ÇπÇÒ")))

(defun haiku-forward-page ()
  (interactive)
  (if (haiku-history-forward?)
      (with-no-if-modified-since
        (haiku-history-forward))
    (message "êiÇﬂÇ‹ÇπÇÒ")))


;;;; render

(defun goto-stream-point ()
  (goto-char (buffer-stream-point *standard-output*)))

(defun set-stream-point (&optional (point (point)))
  (buffer-stream-set-point *standard-output* point))

(defun render (format &optional format-args tag text-attributes)
  (when (and tag (atom tag))
    (setf tag (list tag)))
  (with-stdout-point-start-end (s e)
      (format t format format-args)
    (when (or tag text-attributes)
      (haiku-set-text-attribute s e tag text-attributes))))

(defun html-textize (html)
  (when html
    (html-unescape (html-remove-tag html))))


;;;; reload

(defun haiku-reload-buffer ()
  (interactive)
  (awhen (lv '@reload-function)
    (funcall _it_)))

(defun haiku-super-reload-buffer ()
  (interactive)
  (awhen (lv '@super-reload-function)
    (funcall _it_)))


;;; template method

(defun haiku-current-user ()
  (awhen (lv '@current-user-function)
    (funcall _it_)))


;;; private

(defun load-next-pages (fn)
  (let (r)
    (while (progn
             (refresh-screen)
             (pos-visible-in-window-p (point-max)))
      (or (funcall fn)
          (return))
      (setf r t))
    r))


(provide "hatena-haiku-mode/ui/base")

;;;; End
