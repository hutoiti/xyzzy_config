;;;; -*- mode: lisp; package: hatena-haiku.ui -*-
;;;;
;;;; File: hatena-haiku-mode/ui/star.l
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

(export '(haiku-star-limiter-release
          ))

(defvar *haiku-star-mode* :accel)

(defparameter *haiku-star-mode-list* '(:exceed :excellion :accel))
(defparameter *haiku-star-working-count* 0)
(defparameter *haiku-star-working-limit* 50)
(defparameter *url-max-bytes* 1800) ;; 2084 でエラーになる


(defun haiku-star-limiter-release (&optional limiter nomsg)
  (interactive)
  (let ((limiter (cond ((interactive-p)
                        (intern
                         (completing-read "Limiter: " *haiku-star-mode-list*
                                          :must-match t
                                          :default (string *haiku-star-mode*))
                         :keyword))
                       ((member limiter *haiku-star-mode-list*)
                        limiter)
                       (t
                        (plain-error "invalid limiter `~S', ~S" limiter *haiku-star-mode-list*)))))
    (setf *haiku-star-mode* limiter)
    (unless nomsg
      (message "~@(~A~) Mode Ready" limiter))
    limiter))

(defun haiku-star-progress-message ()
  (when (< 0 *haiku-star-working-count*)
    (message "スター中... 残り ~A"
             (hatena-star-make-stars-string *haiku-star-working-count*
                                            :star-char #\☆
                                            ))))

(defun haiku-star-start ()
  (incf *haiku-star-working-count*))

(defun haiku-star-done ()
  (decf *haiku-star-working-count*)
  (when (minusp *haiku-star-working-count*)
    (setf *haiku-star-working-count* 0)))

(defun haiku-star-entries-future (&optional permalinks)
  (with-if-modified-since-unix-epoch
    (mapcar #'haiku-star-get-entries-future
            (separate-by-max-url (mapcar #'entry-permanent-url permalinks)))))

(defun haiku-star-entries (future)
  (multiple-value-bind (entries rks)
      (hatena-star-future-value future :nowait t)
    (when entries
      (when rks (store-rks rks))
      (mapcar #'(lambda (entry)
                  (cons (url-path (hatena-star-entry-uri entry))
                        (hatena-star-entry-stars entry)))
              entries))))

(defun haiku-add-star-entry (permalink title quote &optional callback)
  (unless (hatena-rks)
    (plain-error "☆をつけるには IE ではてなにログインしてください"))
  (flet ((star-later! ()
           (haiku-star-start)
           (haiku-star-progress-message)
           (haiku-star-add-star (entry-permanent-url permalink) (hatena-rks)
                                :title title
                                :quote quote
                                :nomsg t
                                :callback callback)
           ))
    (case *haiku-star-mode*
      (:exceed
       (star-later!))
      (:excellion
       (if (<= *haiku-star-working-limit* *haiku-star-working-count*)
           (msgbox "☆の付けすぎです。自重してください。")
         (star-later!)))
      (t
       (when (<= *haiku-star-working-count* 0)
         (star-later!)))
      )))


;;;; private

(defun separate-by-max-url (urls)
  (when urls
    (let ((sum 0))
      (multiple-value-bind (head rest)
          (take-if #'(lambda (e) (> (incf sum e) *url-max-bytes*))
                   urls :key 'length)
        (cond ((null rest)
               (list head))
              ((null head)
               (cons (list (car rest))
                     (separate-by-max-url (cdr rest))))
              (t
               (cons head
                     (separate-by-max-url rest))))))))


(provide "hatena-haiku-mode/ui/star")

;;;; End
