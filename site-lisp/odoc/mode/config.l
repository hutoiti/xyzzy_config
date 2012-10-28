;;; -*- Mode: Lisp -*-
;;  config: 
;;; Author:        amefura <amefura@gmail.com>
;;; License:       config is released under an MIT license.
;;                 See odoc/doc/mit-license for full license.
;;; Code:

(in-package :odoc-mode)

(export '(odoc-config-mode))

; no syntax
(defvar *odoc-config-mode-formats* nil)
(setf *odoc-config-mode-formats*
	  (compile-regexp-keyword-list
	   '(("^\\(#[^\r\n]+$\\)" t (:color 15 0))
		 ("^%\\([^%\r\n]+$\\)" t (:color 14 0)))))

(defun odoc-config-mode()
  (interactive)
  (kill-all-local-variables)
  (setq mode-name "Odocrc")
  (setq buffer-mode 'config)
  (make-local-variable 'regexp-keyword-list)
  (setq regexp-keyword-list *odoc-config-mode-formats*))

(provide :odoc/mode/config)
;end
