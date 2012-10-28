;;;; -*- mode: lisp; package: hatena-haiku.ui -*-
;;;;
;;;; File: hatena-haiku-mode/ui/entry/base.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008-2009 MIYAMUKO Katsuyuki.
;;;;
;;;;   hatena-haiku-mode is released under an MIT license.
;;;;   See hatena-haiku-mode/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "hatena-haiku-mode/ui/base")
  (require "hatena-haiku-mode/ui/keyword-list")
  (require "hatena-haiku-mode/ui/user-list")
  (require "hatena-haiku-mode/ui/post")
  )

(in-package :hatena-haiku.ui)

(export '(haiku-show-new-entry-pane
          ))

(defvar *haiku-entry-mode-hook* nil)

(defparameter *haiku-entry-window-flags*
  `((,*window-flag-line-number* . nil)
    (,*window-flag-newline* . nil)
    (,*window-flag-eof* . nil)
    (,*window-flag-ruler* . nil)
    (,*window-flag-just-inverse* . nil)
    (,*window-flag-cursor-line* . nil)
    ))


;;;; init

(defun init-entry-local-variable (buffer)
  (with-temporary-set-buffer (buffer)
    (init-pager-local-variable buffer)
    (init-time-keeper-local-variable buffer)
    (make-lv '@current-user-function 'current-entry-username)
    ))

(defun haiku-init-user-and-keyword-buffer (userbuf keywordbuf)
  (haiku-init-user-buffer userbuf
                          :reload-function 'haiku-reload-entry
                          :super-reload-function 'haiku-super-reload-entry)
  (haiku-init-keyword-buffer keywordbuf
                             :keymap *haiku-entry-sidebar-keyword-map*
                             :nopaging t
                             :reload-function 'haiku-reload-entry
                             :super-reload-function 'haiku-super-reload-entry))

(defun haiku-create-entry-pane (init-fn arg)
  (switch-or-create-haiku-frame)
  (let ((mainbuf (haiku-entries-buffer))
        (userbuf (haiku-users-buffer))
        (keywordbuf (haiku-keywords-buffer)))
    (haiku-split-window-1 :main mainbuf)
    (apply init-fn mainbuf arg)
    (haiku-init-user-and-keyword-buffer userbuf keywordbuf)
    (multiple-value-bind (entry user keyword)
        (with-temporary-set-buffer (mainbuf)
          (fetch-entries))
      (haiku-render-entry-buffer mainbuf entry :page 1)
      (haiku-render-entry-user-buffer userbuf user)
      (haiku-render-entry-keyword-buffer keywordbuf keyword)
      (message "~A" (html-textize (entry-page-subtitle entry)))
      )))

(defun haiku-reset-entry-buffer (&optional (b (selected-buffer)))
  (erase-buffer b)
  (reset-pager-local-variable b))


;;;; fetch

(defun fetch-entries (&key page entries-only)
  (with-if-modified-since-last-fetch
    (let ((f (lv '@entry-fetcher)))
      (aif (lv '@entry-fetcher-arg)
          (funcall f _it_ :page page :entries-only entries-only)
        (funcall f :page page :entries-only entries-only)))))


;;;; render

(defmacro with-render-buffer ((buffer start) &body body)
  (with-gensyms (gbuffer)
    `(let ((,gbuffer ,buffer))
       (let ((,start (or ,start (point-max))))
         (with-temporary-set-buffer (,gbuffer)
           (with-temporary-writable (,gbuffer)
             (with-output-to-buffer (,gbuffer ,start)
               ,@body)))))))
(setf (get 'with-render-buffer 'ed:lisp-indent-hook) 'with-set-buffer)

(defun haiku-render-entry-buffer (buffer &optional entries &key page)
  (if entries
      (progn
        (haiku-insert-entries buffer entries)
        (set-haiku-current-page 1 buffer))
    (progn
      (haiku-insert-entry-page buffer 1)
      (load-next-pages 'haiku-insert-next-entry-page))))

(defun haiku-render-entry-user-buffer (buffer users)
  (if users
      (haiku-render-user-buffer buffer users :reset t)
    (delete-buffer buffer)))

(defun haiku-render-entry-keyword-buffer (buffer keywords)
  (if keywords
      (haiku-render-keyword-buffer buffer keywords :reset t)
    (delete-buffer buffer)))


(defun haiku-insert-next-entry-page (&optional (buffer (selected-buffer)))
  (when (haiku-next-page-p)
    (let ((next (haiku-next-page)))
      (if (haiku-insert-entry-page buffer next)
          (message "~D ページ" next)
        (progn
          (message "~D ページ目はないよ" next)
          (set-haiku-next-page nil))))))

(defun haiku-insert-entry-page (buffer page)
  (awhen (fetch-entries :page page :entries-only t)
    (when (and (haiku-insert-entries buffer _it_) page)
      (set-haiku-current-page page buffer))))

(defun haiku-insert-entries (buffer entrypage &optional start)
  (let* ((entries (entry-page-entries entrypage))
         (future (haiku-star-entries-future (mapcar #'entry-permalink entries))))
    (haiku-insert-entries0 buffer entrypage entries future start)
    (not (null entries))))

(defun haiku-insert-entries0 (buffer entrypage entries future-star &optional start)
  (with-render-buffer (buffer start)
    (save-current-line-column
      (goto-stream-point)
      (when (bobp)
        (render-title entrypage))
      (terpri)
      (dolist (e entries)
        (render-entry e))
      (goto-stream-point)
      (delete-backward-char)
      (render-star-later buffer future-star start)))
  (refresh-screen))

(defun haiku-insert-new-entries-only (buffer entrypage)
  (flet ((new-entries ()
           (subseq-before (latest-entry-permalink)
                          (entry-page-entries entrypage)
                          :key #'entry-permalink :test #'string=)))
    (aif (new-entries)
        (save-excursion
          (haiku-first-entry)
          (previous-line)
          (haiku-insert-entries buffer `((:entries . ,_it_)) (point))
          (message "~D件の新着" (length _it_))
          _it_)
      (progn
        (message "最新のエントリはありません")
        nil))))

(defun render-title (entrypage)
  (awhen (entry-page-title entrypage)
    (fresh-line)
    (render "~A" (html-textize _it_)
            '(:page-title) *haiku-page-title-color*)
    (terpri))
  (awhen (entry-page-subtitle entrypage)
    (fresh-line)
    (render "~A" (html-textize _it_)
            '(:page-subtitle) *haiku-page-subtitle-color*)
    (terpri))
  (format t "~A~%" (make-sequence 'string 79 :initial-element #\-)))

(defun render-entry (entry)
  (fresh-line)
  (render "~A" (html-textize (entry-keyword entry))
          `(:title ,(subalist entry '(:keyword :keyword-uri)))
          *haiku-entry-title-color*)
  (terpri)
  (render "~{~A~%~}" (parse-body (entry-body entry)))
  (render "by " nil nil *haiku-entry-meta-text-color*)
  (render "~{~A ~A~}"
          (mapcar #'html-textize ($ entry '(:username :timestamp)))
          `(:userinfo ,(subalist entry '(:permalink :username :timestamp)))
          *haiku-entry-meta-color*)
  (awhen (entry-source entry)
    (render " from " nil nil *haiku-entry-meta-text-color*)
    (render "~A"
            (html-textize _it_)
            nil
            *haiku-entry-meta-color*))
  (terpri)
  (terpri))

(defun render-star-later (buffer future-list start)
  (when future-list
    (let ((future (car future-list)))
      (if (not (hatena-star-future-completed-p future))
          (invoke-later 0.5
            (render-star-later buffer future-list start))
        (let ((entry-stars (haiku-star-entries future)))
          (when entry-stars
            (render-star buffer entry-stars start))
          (invoke-later 0.1
            (render-star-later buffer (cdr future-list) 0)))))))

(defun render-star (buffer entry-stars start)
  (with-render-buffer (buffer start)
    (save-current-line-column
      (let ((nodup nil))
        (goto-char start)
        (while (haiku-forward-text-attribute :title :nodup nodup)
          (render-star0 ($ entry-stars (current-entry-permalink)))
          (setf nodup t))
        )))
  (refresh-screen))

(defun render-star0 (stars)
  (when stars
    (goto-eol)
    (set-stream-point)
    (render " ~A" (hatena-star-stars-to-string stars)
            `(:star ,stars) *haiku-star-color*)
    ))

(defun parse-body (body)
  (multiple-value-bind (body reply)
      (parse-reply-to body)
    (mapcar #'html-unescape (parse-br (parse-link (strip body))))))

(defun parse-br (body)
  (split-string
   (substitute-string body "<br ?/?>" "\n" :case-fold t)
   #\LFD))

(defun parse-reply-to (body)
  (values
   (substitute-string body "<a href=\"\\(.*?\\)\"><img src=\"/images/icon-replylink.gif\".*?</a>" "")
   (match-string 1)))

(defun parse-link (str)
  (with-multiline-regexp-string (str)
    (reduce #'(lambda (str pair)
                (substitute-string str (car pair) (cadr pair)))
            '(("<a [^<>]+><img src=\"\\(.+?\\)\"[^<>]*?/?></a>" "\\1")
              ("<a href=\"\\(.*?\\)\"[^<>]*>\\(.*?\\)</a>" "\\2")
              ("<div class=\"video-body\">.*?<embed src=\"\\(.*?\\)\".*?</div>" "\\1")
              ("http://www.youtube.com/v/\\([a-zA-Z0-9]+\\)" "http://www.youtube.com/watch?v=\\1")
              ("<div id=\"nicovideo-.*?\"></div>" "")
              ("<script type=\"text/javascript\" src=\"http://www.nicovideo.jp/thumb_watch/\\(.*?\\)\".*?</script>"
               "http://www.nicovideo.jp/watch/\\1")
              ("<script type=\"text/javascript\">.*?</script>" "")
              )
            :initial-value str)))


;;;; commands

(defun haiku-toggle-user-pane ()
  (interactive)
  (awhen (find-buffer (haiku-users-buffer-name))
    (if (get-buffer-window _it_)
        (delete-buffer-window _it_)
      (split-window-left _it_))))

(defun haiku-toggle-keyword-pane ()
  (interactive)
  (awhen (find-buffer (haiku-keywords-buffer-name))
    (if (get-buffer-window _it_)
        (delete-buffer-window _it_)
      (split-window-right _it_))))

(defun haiku-show-new-entry-pane (&optional title)
  (interactive)
  (when *prefix-args*
    (setf title (read-string "お題: ")))
  (let ((buf (haiku-post-buffer)))
    (haiku-init-post-buffer buf :title (or title (haiku-post-title)))
    (set-window (split-window-bottom buf (or *haiku-post-buffer-height-ratio* 0.3)))))

(defun haiku-show-reply-pane ()
  (interactive)
  (awhen (current-entry-id)
    (let ((buf (haiku-post-buffer)))
      (haiku-init-post-buffer buf :reply _it_)
      (set-window (split-window-bottom buf (or *haiku-post-buffer-height-ratio* 0.3))))))

(defun haiku-delete-current-entry ()
  (interactive)
  (and-let* ((id (current-entry-id))
             (title (current-entry-keyword))
             (user (current-entry-username))
             (ans (yes-or-no-p "~A by ~A~%を削除しますか？" title user)))
    (if (haiku-delete! id)
        (save-current-line-column
          (with-temporary-writable ((selected-buffer))
            (apply 'delete-region (current-entry-points))
            (kill-line))
          (message "~A by ~A を削除しました" title user))
      (plain-error "削除できません"))))

(defun haiku-next-entry1 ()
  (save-current-window-line
    (haiku-forward-text-attribute :title)
    (load-next-pages 'haiku-insert-next-entry-page)))
(define-prefix-argument-command haiku-next-entry haiku-next-entry1)

(defun haiku-previous-entry1 ()
  (save-current-window-line
    (haiku-backward-text-attribute :title)))
(define-prefix-argument-command haiku-previous-entry haiku-previous-entry1)

(defun haiku-entry-next-page ()
  (interactive)
  (haiku-next-page-base 'haiku-insert-next-entry-page))

(defun haiku-entry-next-line ()
  (interactive)
  (haiku-next-line-base 'haiku-insert-next-entry-page))

(defun haiku-star-current-entry ()
  (interactive)
  (let ((link (current-entry-permalink)))
    (unless link
      (return-from haiku-star-current-entry nil))
    (let ((user (current-entry-username))
          (title (current-entry-keyword))
          (quote (or (current-entry-selection-string)
                     (current-entry-region-string))))
      (flet ((starbacks (r)
               (haiku-star-done)
               (cond ((null r)
                      (message "スター失敗!"))
                     ((null quote)
                      (message "スター!: ~A by ~A" title user))
                     ((equal quote (hatena-star-star-quote r))
                      (message "スター!: ~A by ~A (~A)" title user quote))
                     (t
                      (message "スター!: ~A by ~A - 引用失敗 (~A => ~A)"
                               title user quote (hatena-star-star-quote r))))
               (haiku-star-progress-message)
               (do-events)))
        (haiku-add-star-entry link title quote #'starbacks)
        ))))

(defun haiku-show-current-entry-keyword-page ()
  (interactive)
  (let ((k (current-entry-keyword)))
    (when k
      (aif (parse-hatena-id k)
          (haiku-user-entries-pane _it_)
        (haiku-keyword-entries-pane k)))))


(defun haiku-show-current-entry-user-page ()
  (interactive)
  (awhen (current-entry-username)
    (haiku-user-entries-pane _it_)))

(defun haiku-open-current-entry-by-browser ()
  (interactive)
  (awhen (current-entry-permalink :absolute t)
    (open-browser _it_)))

(defun haiku-first-entry ()
  (interactive)
  (goto-char (point-min))
  (haiku-forward-text-attribute :title :no-dup nil))


(defun haiku-reload-entry ()
  (interactive)
  (let ((mainbuf (haiku-entries-buffer))
        (userbuf (haiku-users-buffer))
        (keywordbuf (haiku-keywords-buffer)))
    (haiku-init-user-and-keyword-buffer userbuf keywordbuf)
    (multiple-value-bind (entry user keyword)
        (with-temporary-set-buffer (mainbuf)
          (fetch-entries))
      (haiku-insert-new-entries-only mainbuf entry)
      (haiku-render-entry-user-buffer userbuf user)
      (haiku-render-entry-keyword-buffer keywordbuf keyword)
      )))

(defun haiku-super-reload-entry ()
  (interactive)
  (let ((mainbuf (haiku-entries-buffer))
        (userbuf (haiku-users-buffer))
        (keywordbuf (haiku-keywords-buffer)))
    (haiku-init-user-and-keyword-buffer userbuf keywordbuf)
    (let ((page (or (haiku-current-page mainbuf) 1)))
      (save-current-point
        (haiku-reset-entry-buffer mainbuf)
        (haiku-reset-keyword-buffer keywordbuf)
        (haiku-reset-user-buffer userbuf)
        (refresh-screen)
        (multiple-value-bind (entry user keyword)
            (with-temporary-set-buffer (mainbuf)
              (with-if-modified-since-unix-epoch
                (fetch-entries)))
          (progn
            (haiku-render-entry-buffer mainbuf entry :page 1)
            (with-if-modified-since-unix-epoch
              (dotimes (i (- page 1))
                (haiku-insert-entry-page mainbuf (+ i 2)))))
          (haiku-render-entry-user-buffer userbuf user)
          (haiku-render-entry-keyword-buffer keywordbuf keyword)
          )))))


;;;; private

(defun haiku-post-title ()
  (safe-lv '@post-title))

(defmacro with-current-entry (&body body)
  `(save-excursion
     (save-restriction
       (when (narrow-to-current-entry)
         (goto-char (point-min))
         ,@body))))
(setf (get 'with-current-entry 'ed:lisp-indent-hook) 'with-set-buffer)

(defun latest-entry-permalink (&key absolute)
  (save-excursion
    (haiku-first-entry)
    (current-entry-permalink :absolute absolute)))

(defun current-entry-keyword ()
  (current-entry-keyword-info :keyword))

(defun current-entry-keyword-uri ()
  (current-entry-keyword-info :keyword-uri))

(defun current-entry-keyword-info (key)
  ($ (find-current-entry-tag-value :title) key))

(defun current-entry-permalink (&key absolute)
  (awhen (current-entry-userinfo :permalink)
    (if absolute
        (entry-permanent-url _it_)
      _it_)))

(defun current-entry-id ()
  (awhen (current-entry-userinfo :permalink)
    (car (last (split-string _it_ #\/)))))

(defun current-entry-username ()
  (current-entry-userinfo :username))

(defun current-entry-userinfo (key)
  ($ (find-current-entry-tag-value :userinfo) key))

(defun find-current-entry-tag-value (tag)
  (multiple-value-bind (from to tag)
      (find-current-entry-tag tag)
    (when tag
      (cadr tag))))

(defun find-current-entry-tag (tag)
  (with-current-entry
    (haiku-forward-text-attribute tag :no-dup nil)))

(defun current-entry-selection-string ()
  (when (pre-selection-p)
    (continue-pre-selection)
    (selection-start-end (ss se)
      (current-entry-substring ss se))))

(defun current-entry-region-string ()
  (when (mark t)
    (current-entry-substring (region-beginning) (region-end))))

(defun current-entry-substring (start end)
  (multiple-value-bind (es ee)
      (current-entry-point-values)
    (when (and es ee start end)
      (if (< end start) (rotatef start end))
      (when (and (<= es start) (<= end ee))
        (buffer-substring start end)))))

(defun narrow-to-current-entry ()
  (interactive)
  (awhen (current-entry-points)
    (apply 'narrow-to-region _it_)
    (goto-char (point-min))
    _it_))

(defun current-entry-point-values ()
  (values-list (current-entry-points)))

(defun current-entry-points ()
  (let ((s (save-excursion (and
                            (haiku-backward-text-attribute :title :no-dup nil)
                            (point))))
        (e (save-excursion (or
                            (and
                             (haiku-forward-text-attribute :title :no-dup t)
                             (backward-line)
                             (point))
                            (point-max)))))
    (when (and s e (<= s (point) e))
      (list s e))))


(provide "hatena-haiku-mode/ui/entry/base")

;;;; End
