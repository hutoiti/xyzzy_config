;;;; -*- mode: lisp; package: hatena-haiku.ui -*-
;;;;
;;;; File: hatena-haiku-mode/ui/buffer.l
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

(defparameter *hatena-haiku-entries-buffer-name*           "*Haiku:Entries*")
(defparameter *hatena-haiku-following-buffer-name*         "*Haiku:Following*")
(defparameter *hatena-haiku-profile-buffer-name*           "*Haiku:Profile*")

(defparameter *hatena-haiku-keywords-buffer-name*          "*Haiku:Keywords*")
(defparameter *hatena-haiku-hot-keyword-buffer-name*       "*Haiku:Hot Keywords*")
(defparameter *hatena-haiku-following-keyword-buffer-name* "*Haiku:Following Keywords*")
(defparameter *hatena-haiku-related-keyword-buffer-name*   "*Haiku:Related Keywords*")

(defparameter *hatena-haiku-user-buffer-name*              "*Haiku:User*")
(defparameter *hatena-haiku-star-friends-buffer-name*      "*Haiku:Star Friends*")

(defparameter *hatena-haiku-new-entry-buffer-name*         "*Haiku:Post*")
(defparameter *hatena-haiku-reply-buffer-name*             "*Haiku:Reply*")


(defun haiku-buffer-p (buffer)
  (and buffer
       (buffer-name buffer)
       (string-match "^\\*Haiku:" (buffer-name buffer))))

(defun haiku-entries-buffer (&optional name)
  (haiku-create-buffer (haiku-entries-buffer-name name)))

(defun haiku-entries-buffer-name (&optional name)
  (case name
    (:following
     *hatena-haiku-following-buffer-name*)
    (:profile
     *hatena-haiku-profile-buffer-name*)
    (t
     *hatena-haiku-entries-buffer-name*)))

(defun haiku-users-buffer (&optional name)
  (haiku-create-buffer (haiku-users-buffer-name name)))

(defun haiku-users-buffer-name (&optional name)
  (case name
    (:star-friends
     *hatena-haiku-star-friends-buffer-name*)
    (t
     *hatena-haiku-user-buffer-name*)))

(defun haiku-keywords-buffer (&optional name)
  (haiku-create-buffer (haiku-keywords-buffer-name name)))

(defun haiku-keywords-buffer-name (&optional name)
  (case name
    (:hot-keywords
     *hatena-haiku-hot-keyword-buffer-name*)
    (:following
     *hatena-haiku-following-keyword-buffer-name*)
    (:related
     *hatena-haiku-related-keyword-buffer-name*)
    (t
     *hatena-haiku-keywords-buffer-name*)))

(defun haiku-post-buffer (&optional name)
  (haiku-create-buffer (haiku-post-buffer-name name)))

(defun haiku-post-buffer-name (&optional name)
  (case name
    (:reply
     *hatena-haiku-reply-buffer-name*)
    (t
     *hatena-haiku-new-entry-buffer-name*)))


(defun haiku-delete-all-buffers ()
  (interactive)
  (dolist (b (buffer-list))
    (when (string-matchp "^\\*Haiku:" (buffer-name b))
      (ignore-errors
       (delete-buffer b)))))

(defun haiku-create-buffer (name)
  (let ((b (get-buffer-create name)))
    (setup-temp-buffer b)
    (set-lv 'buffer-read-only t b)
    (set-buffer-fold-width t b)
    b))

(defun update-mode-name (name)
  (setf mode-name name)
  (update-mode-line))

(defmacro with-mode-name (name &body body)
  (with-gensyms (original)
    `(let ((,original (buffer-local-value (selected-buffer) 'mode-name)))
       (update-mode-name ,name)
       (unwind-protect
           (progn ,@body)
         (update-mode-name ,original)))))
(setf (get 'with-mode-name 'ed::lisp-indent-hook) 1)


(provide "hatena-haiku-mode/ui/buffer")

;;;; End
