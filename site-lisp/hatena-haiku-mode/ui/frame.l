;;;; -*- mode: lisp; package: hatena-haiku.ui -*-
;;;;
;;;; File: hatena-haiku-mode/ui/frame.l
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
  )

(in-package :hatena-haiku.ui)

(defvar *hatena-haiku-frame* "Hatena Haiku")


(defun create-haiku-frame ()
  (unless (find-haiku-frame)
    (toggle-save-last-frame-hook t)
    (save-last-frame)
    (new-pseudo-frame *hatena-haiku-frame* nil nil nil)))

(defun delete-haiku-frame ()
  (let ((next *last-frame*))
    (awhen (find-haiku-frame)
      (delete-pseudo-frame _it_)
      (unless (deleted-frame-p next)
        (select-pseudo-frame next))))
  (toggle-save-last-frame-hook nil))

(defun find-haiku-frame ()
  (find-pseudo-frame *hatena-haiku-frame*))

(defun haiku-frame-p (frame)
  (and frame
       (equal (ed::pseudo-frame-name frame) *hatena-haiku-frame*)))

(defun switch-or-create-haiku-frame ()
  (let ((f (or (find-haiku-frame)
               (create-haiku-frame))))
    (select-pseudo-frame f)))



(defparameter *current-frame* nil)
(defparameter *last-frame* nil)

(defun switch-last-frame ()
  (let ((next *last-frame*))
    (if (deleted-frame-p next)
        (other-pseudo-frame)
      (select-pseudo-frame next))))

(defun clear-last-frame ()
  (setf *last-frame* nil
        *current-frame* nil))

(defun save-last-frame ()
  (setf *last-frame* *current-frame*
        *current-frame* (selected-pseudo-frame)))

(defun toggle-save-last-frame-hook (on)
  (clear-last-frame)
  (funcall (if on 'add-hook 'delete-hook)
           '*select-pseudo-frame-hook* 'save-last-frame))

(defun deleted-frame-p (frame)
  (or (not frame)
      (not (find-pseudo-frame (ed::pseudo-frame-name frame)))))


(provide "hatena-haiku-mode/ui/frame")

;;;; End
