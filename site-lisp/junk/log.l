;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: log.l 769 2007-12-14 19:18:39Z torihat $
;
; junk/log.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "junk/defs")
  (require "junk/macro"))
(require "junk/lib")

(provide "junk/log")

(in-package "junk")

(defun log-init (buffer)
  (let (log)
    (save-excursion
      (set-buffer (get-buffer-create buffer))
      (erase-buffer (selected-buffer))
      (setq need-not-save t)
      (setq log (make-buffer-stream (selected-buffer)))
      (log-output log "start at ~A" (format-date-string "%Y/%m/%d %H:%M:%S")))
    log))

(defun log-close (log buffer &optional file)
  (when (buffer-stream-p log)
    (log-output log "end at ~A" (format-date-string "%Y/%m/%d %H:%M:%S"))
    (close log))
  (when file
    (save-excursion
      (set-buffer (get-buffer-create buffer))
      (write-region (point-min)
		    (point-max)
		    file
		    t))))

(defun log-output (log fmt &rest args)
  (apply #'format log (concat fmt "~%") args))
