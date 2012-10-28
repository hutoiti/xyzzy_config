;;;; -*- mode: lisp; package: hatena-haiku.ui -*-
;;;;
;;;; File: hatena-haiku-mode/ui/history.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008-2009 MIYAMUKO Katsuyuki.
;;;;
;;;;   hatena-haiku-mode is released under an MIT license.
;;;;   See hatena-haiku-mode/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "hatena-haiku-mode/ui/package")
  )

(in-package :hatena-haiku.ui)

(defparameter *haiku-history-current* nil)
(defparameter *haiku-history-forward-list* nil)
(defparameter *haiku-history-backward-list* nil)
(defparameter *haiku-history-navigating* nil)

(defstruct history
  fn args)

(defun haiku-init-history ()
  (setf *haiku-history-backward-list* nil
        *haiku-history-forward-list* nil
        *haiku-history-current* nil))

(defmacro save-current-history (place)
  `(when *haiku-history-current*
     (push *haiku-history-current* ,place)))

(defun haiku-save-history (fn &rest args)
  (unless *haiku-history-navigating*
    (let ((cc (make-history :fn fn :args args)))
      (unless (equalp cc *haiku-history-current*)
        (save-current-history *haiku-history-backward-list*)
        (setf *haiku-history-forward-list* nil)
        (setf *haiku-history-current* cc)))))


(defmacro haiku-history? (place)
  `(not (null (car ,place))))

(defun haiku-history-backward? ()
  (haiku-history? *haiku-history-backward-list*))

(defun haiku-history-forward? ()
  (haiku-history? *haiku-history-forward-list*))


(defun playback-history (h)
  (let ((*haiku-history-navigating* t))
    (apply (history-fn h) (history-args h))
    ))

(defmacro haiku-history-go (from to)
  `(awhen (car ,from)
     (setf ,from (cdr ,from))
     (save-current-history ,to)
     (setf *haiku-history-current* _it_)
     (playback-history _it_)))

(defun haiku-history-backward ()
  (haiku-history-go *haiku-history-backward-list*
                    *haiku-history-forward-list*))

(defun haiku-history-forward ()
  (haiku-history-go *haiku-history-forward-list*
                    *haiku-history-backward-list*))


(provide "hatena-haiku-mode/ui/history")

;;;; End
