;;; -*- Mode: Lisp -*-
;;  publish: 
;;; Author:        amefura <amefura@gmail.com>
;;; License:       publish is released under an MIT license.
;;                 See odoc/doc/mit-license for full license.
;;; Code:

(in-package :odoc-mode)

(defun not-write-buffer-flag(&optional (arg t))
  (toggle-read-only arg)
  (setq need-not-save arg)
  (set-buffer-modified-p nil))

(defvar-local odoc-read-only-mode nil)

(defun odoc-read-only-mode(&optional (arg nil sv))
  (interactive "p")
  (ed::toggle-mode 'odoc-read-only-mode arg sv)
  (not-write-buffer-flag odoc-read-only-mode)
  (if odoc-read-only-mode
	  (set-minor-mode-map *odoc-read-only-mode-map*)
	(unset-minor-mode-map *odoc-read-only-mode-map*))
  (update-mode-line t)
  )

(defvar *odoc-read-only-mode-map* nil)
(unless *odoc-read-only-mode-map*
  (setf *odoc-read-only-mode-map*(make-sparse-keymap))
  (define-key *odoc-read-only-mode-map* #\q 'odoc-buffer-close)
  )

(defun odoc-buffer-close()
  (interactive)
  (delete-buffer(selected-buffer)))

;;(add-hook '*odoc-publish-hook* 'odoc-read-only-mode)

(provide :odoc/mode/ro)
;;end
