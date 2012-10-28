;;;; -*- mode: lisp; package: hatena-haiku.ui -*-
;;;;
;;;; File: hatena-haiku-mode/ui/post.l
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

(export '(haiku-post-minibuffer
          ))

(defparameter *haiku-post-description* "
---- �y�w���v�z ---- 8< ---- 8< ---- 8< ---- 8< ---- 8< ----
~A
* C-c C-c �œ��e�ł��܂��B
* C-u C-c C-c �œ��e���ɓ��e�Ɏg�p����N���C�A���g�� (from ��)
  �� minibuffer ����w��ł��܂��B
* C-x k �Ńo�b�t�@����܂��B
�Ȃ��A���̐����͎����I�ɍ폜����܂��B
---- 8< ---- 8< ---- 8< ---- 8< ---- 8< ---- 8< ---- 8< ----
")
(defparameter *haiku-new-post-description*
  "���̐����̌�ɃL�[���[�h�Ɩ{������s�����ċL�����Ă��������B")
(defparameter *haiku-reply-description*
  "���̐����̌�ɕԐM���L�����Ă��������B")

(defun haiku-init-post-buffer (buffer &key reply title)
  (erase-buffer buffer)
  (haiku-post-mode buffer reply)
  (render-post-description buffer)
  (when title
    (render-post-title buffer title)))

(defun haiku-post-mode (buffer reply)
  (with-temporary-set-buffer (buffer)
    (kill-all-local-variables)
    (make-lv '@haiku-reply-to reply)
    (toggle-read-only nil)
    (setf buffer-mode 'haiku-post-mode)
    (setf mode-name "Haiku: Post")
    (use-keymap *haiku-post-map*)
    ))

(defun haiku-post-minibuffer (word body)
  (interactive "s����: \ns�{��: ")
  (check-post-data word body)
  (message "~A �ɓ��e��..." word)
  (haiku! word body :source (get-source))
  (message "~A �ɓ��e��...���Ԃ�ł���" word))


;;;; render

(defun render-post-description (buffer)
  (with-temporary-set-buffer (buffer)
    (with-append-to-buffer (buffer)
      (fresh-line)
      (render "~A" (haiku-description)
              '(:description) *haiku-post-description-color*)
      (terpri)
      (goto-stream-point))))

(defun render-post-title (buffer title)
  (with-temporary-set-buffer (buffer)
    (with-append-to-buffer (buffer)
      (fresh-line)
      (render "~A" title
              '(:title) *haiku-post-title-color*)
      (terpri)
      (terpri)
      (goto-stream-point))))


;;;; command

(defun haiku-close-post-pane ()
  (interactive)
  (delete-buffer (selected-buffer))
  (unless (one-window-p)
    (delete-window)))

(defun haiku-post-entry ()
  (interactive)
  (let ((reply-to (lv '@haiku-reply-to)))
    (multiple-value-bind (word-or-reply-to body)
        (haiku-parse-new-entry reply-to)
      (check-post-data word-or-reply-to body)
      (message "Haiku: Post ���ł�...")
      (funcall (if reply-to 'haiku-reply! 'haiku!)
               word-or-reply-to body
               :source (get-source))
      (message "Haiku: Post ���ł�...���Ԃ�ł���")
      (haiku-close-post-pane)
      (save-current-line-column
        (haiku-reload-buffer))
      (awhen (safe-lv '@post-callback)
        (funcall _it_)))))


;;;; private

(defun get-source ()
  (or (and *prefix-args*
           (read-source))
      *haiku-default-source*))

(defun read-source ()
  (let ((source (strip
                 (read-string "from: "
                              :default *haiku-default-source*))))
    (when (and source (string/= "" source))
      source)))


(defun haiku-description ()
  (strip
   (format nil *haiku-post-description*
           (if (lv '@haiku-reply-to)
               *haiku-reply-description*
             *haiku-new-post-description*))))

(defun haiku-parse-new-entry (reply-to)
  (flet ((skip-description ()
           (scan-text-attribute :description :key 'safe-car :tail t)
           (skip-chars-forward " \n"))
         (skip-title ()
           (and
            (forward-line)
            (skip-chars-forward " \n")))
         (buffer-rest ()
           (buffer-substring (point) (point-max))))
    (save-excursion
      (goto-char (point-min))
      (skip-description)
      (if reply-to
          (values reply-to (buffer-rest))
        (values
         (buffer-line-string)
         (and (skip-title)
              (buffer-rest)))))))

(defun check-post-data (word body)
  (flet ((empty? (str)
           (or (not str) (string= str ""))))
    (when (empty? word)
      (plain-error "���肪��ł�"))
    (when (empty? body)
      (plain-error "�{������ł�"))))

(provide "hatena-haiku-mode/ui/post")

;;;; End