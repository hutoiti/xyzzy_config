;;;; -*- mode: lisp; package: hatena-haiku.ui -*-
;;;;
;;;; File: hatena-haiku-mode/ui/keyword-list.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;;;
;;;;   hatena-haiku-mode is released under an MIT license.
;;;;   See hatena-haiku-mode/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "hatena-haiku-mode/ui/base")
  )

(in-package :hatena-haiku.ui)

(export '(haiku-keyword-list-pane
          haiku-hot-keyword-list-pane
          ))

(defparameter *haiku-keyword-window-flags*
  `((,*window-flag-line-number* . nil)
    (,*window-flag-newline* . nil)
    (,*window-flag-eof* . nil)
    (,*window-flag-ruler* . nil)
    (,*window-flag-just-inverse* . t)
    (,*window-flag-cursor-line* . nil)
    (,*window-flag-fold-mark* . t)
    ))

(defun haiku-keyword-list-pane (&optional word)
  (interactive)
  (haiku-save-history 'haiku-keyword-list-pane word)
  (switch-or-create-haiku-frame)
  (let ((main (haiku-keywords-buffer)))
    (haiku-split-window-1 :main main)
    (haiku-init-keyword-buffer main :word word
                               :keymap *haiku-keyword-list-map*)
    (haiku-render-keyword-buffer main)))

(defun haiku-hot-keyword-list-pane ()
  (interactive)
  (haiku-save-history 'haiku-hot-keyword-list-pane)
  (switch-or-create-haiku-frame)
  (let ((main (haiku-keywords-buffer)))
    (haiku-split-window-1 :main main)
    (haiku-init-keyword-buffer main :nopaging t
                               :keymap *haiku-hot-keyword-list-map*
                               :reload-function 'haiku-reload-hot-keyword
                               :super-reload-function 'haiku-super-reload-hot-keyword)
    (haiku-render-hot-keyword-buffer main)))

(defun haiku-init-keyword-buffer (b &key nopaging keymap title word
                                    (reload-function 'haiku-reload-keyword)
                                    (super-reload-function 'haiku-super-reload-keyword))
  (erase-buffer b)
  (haiku-keyword-mode b nopaging keymap title word reload-function super-reload-function))

(defun haiku-keyword-mode (&optional (buffer (selected-buffer))
                                     nopaging keymap title word
                                     reload-function super-reload-function)
  (with-temporary-set-buffer (buffer)
    (kill-all-local-variables)
    (init-pager-local-variable buffer :next-page-p (not nopaging))
    (init-time-keeper-local-variable buffer)
    (make-lv '@search-word word)
    (make-lv '@reload-function reload-function)
    (make-lv '@super-reload-function super-reload-function)
    (make-lv '@last-fetch-time nil)
    (setf buffer-mode 'haiku-keyword-mode)
    (setf mode-name "Haiku: Keyword")
    (use-keymap keymap)
    (setup-local-window-flags *haiku-keyword-window-flags* buffer)
    ))

(defun haiku-reset-keyword-buffer (&optional (b (selected-buffer)))
  (erase-buffer b)
  (set-haiku-current-page nil b))


;;;; render

(defun haiku-render-hot-keyword-buffer (buffer)
  (let ((keywords (fetch-hot-keyword-list)))
    (with-temporary-set-buffer (buffer)
      (with-temporary-writable (buffer)
        (with-output-to-buffer (buffer)
          (dolist (k keywords)
            (render "~A" (html-textize (keyword-text k))
                    `(:keyword ,k)
                    (hot-keyword-color (keyword-cloud k)))
            (render "   ")))))))

(defun haiku-render-keyword-buffer (b &optional keywords &key reset)
  (when reset
    (haiku-reset-keyword-buffer b))
  (if keywords
      (progn
        (haiku-insert-keywords b keywords)
        (set-haiku-current-page 1 b))
    (progn
      (haiku-insert-keyword-page b 1)
      (load-next-pages 'haiku-insert-next-keyword-page))))

(defun haiku-insert-next-keyword-page (&optional (buffer (selected-buffer)))
  (when (haiku-next-page-p)
    (let ((next (haiku-next-page)))
      (if (haiku-insert-keyword-page buffer next)
          (message "~D ページ" next)
        (progn
          (message "~D ページ目はないよ" next)
          (set-haiku-next-page nil))))))

(defun haiku-insert-keyword-page (buffer page)
  (awhen (fetch-keyword-list :page page)
    (haiku-insert-keywords buffer _it_)
    (set-haiku-current-page page buffer)))

(defun haiku-insert-keywords (buffer keywords &optional start)
  (with-temporary-set-buffer (buffer)
    (with-temporary-writable (buffer)
      (with-output-to-buffer (buffer (or start (point-max)))
        (fresh-line)
        (dolist (k keywords)
          (render "~A" (html-textize (keyword-text k))
                  `(:keyword ,k) *haiku-keyword-color*)
          (awhen (keyword-entry-count k)
            (render " (~D)" _it_))
          (terpri))))))


;;;; commands

(defun haiku-search-keyword (word)
  (interactive "s検索: ")
  (haiku-keyword-list-pane (if (and word (string/= word "")) word nil)))

(defun haiku-show-keyword-entry ()
  (interactive)
  (awhen (current-keyword)
    (haiku-keyword-entries-pane _it_)))

(defun haiku-reload-keyword ()
  (interactive)
  (flet ((new-keywords ()
           (aif (latest-keyword)
               (subseq-before _it_ (fetch-keyword-list) :key #'keyword-text :test #'string=)
             (fetch-keyword-list))))
    (aif (new-keywords)
        (save-excursion
          (haiku-first-keyword)
          (haiku-insert-keywords (selected-buffer) _it_ (point)))
      (message "最新のキーワードはありません"))))

(defun haiku-super-reload-keyword (&optional page)
  (interactive)
  (let ((page (or page (haiku-current-page) 1)))
    (save-current-point
      (haiku-reset-keyword-buffer)
      (refresh-screen) ; フィードバックのため わざとちらつかせる
      (with-if-modified-since-unix-epoch
        (dotimes (i page)
          (haiku-insert-keyword-page (selected-buffer) (+ i 1)))))))


(defun haiku-reload-hot-keyword ()
  (interactive)
  (haiku-reload-hot-keyword-impl nil))

(defun haiku-super-reload-hot-keyword ()
  (interactive)
  (haiku-reload-hot-keyword-impl t))

(defun haiku-reload-hot-keyword-impl (super)
  (save-current-point
    (let ((b (selected-buffer)))
      (erase-buffer b)
      (refresh-screen)
      (if super
          (with-if-modified-since-unix-epoch
            (haiku-render-hot-keyword-buffer b))
        (haiku-render-hot-keyword-buffer b)))))


(defun haiku-keyword-next-page ()
  (interactive)
  (haiku-next-page-base 'haiku-insert-next-keyword-page))

(defun haiku-keyword-next-line ()
  (interactive)
  (haiku-next-line-base 'haiku-insert-next-keyword-page))

(defun haiku-first-keyword ()
  (interactive)
  (goto-char (point-min))
  (haiku-forward-text-attribute :keyword :no-dup nil))

(defun haiku-next-keyword1 ()
  (save-current-window-line
    (haiku-next-keyword-w/o-scroll-1)))
(define-prefix-argument-command haiku-next-keyword
                                haiku-next-keyword1)

(defun haiku-previous-keyword1 ()
  (save-current-window-line
    (haiku-previous-keyword-w/o-scroll-1)))
(define-prefix-argument-command haiku-previous-keyword
                                haiku-previous-keyword1)

(defun haiku-next-keyword-w/o-scroll-1 ()
  (haiku-forward-text-attribute :keyword)
  (load-next-pages 'haiku-insert-next-keyword-page))
(define-prefix-argument-command haiku-next-keyword-w/o-scroll
                                haiku-next-keyword-w/o-scroll-1)

(defun haiku-previous-keyword-w/o-scroll-1 ()
  (haiku-backward-text-attribute :keyword))
(define-prefix-argument-command haiku-previous-keyword-w/o-scroll
                                haiku-previous-keyword-w/o-scroll-1)

(defun haiku-open-keyword-by-browser ()
  (interactive)
  (awhen (current-keyword)
    (open-browser (keyword-entries-url _it_))))


;;;; private

(defun fetch-keyword-list (&key page)
  (with-if-modified-since-last-fetch
    (keyword-list :word (safe-lv '@search-word)
                  :page page)))

(defun fetch-hot-keyword-list ()
  (with-if-modified-since-last-fetch
    (hot-keyword-list)))

(defun latest-keyword ()
  (save-excursion
    (haiku-first-keyword)
    (current-keyword)))

(defun current-keyword ()
  (awhen (current-keyword-attr)
    (keyword-text _it_)))

(defun current-keyword-uri ()
  (awhen (current-keyword-attr)
    (keyword-uri _it_)))

(defun current-keyword-attr ()
  (multiple-value-bind (from to attr)
      (save-excursion
        (haiku-forward-text-attribute :keyword :no-dup nil))
    (when (<= from (point) to)
      (cadr attr))))


(provide "hatena-haiku-mode/ui/keyword-list")

;;;; End
