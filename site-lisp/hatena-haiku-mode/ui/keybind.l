;;;; -*- mode: lisp; package: hatena-haiku.ui -*-
;;;;
;;;; File: hatena-haiku-mode/ui/keybind.l
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
  (require "hatena-haiku-mode/ui/config")
  )

(in-package :hatena-haiku.ui)

(defmacro define-keymap (name base &body body)
  #+hatena-haiku-mode-debug
  (progn
    ;; symbol の関数が存在するかチェック
    (dolist (bind (mapcar 'cadr body))
      (when (eq (safe-car bind) 'quote)
        (symbol-function (cadr bind))))
    `(setf ,name
           (with-keymap ,base
             ,@body)))
  #-hatena-haiku-mode-debug
  `(unless ,name
     (setf ,name
           (with-keymap ,base
             ,@body))))
(setf (get 'define-keymap 'ed::lisp-indent-hook) 'defun)


(define-keymap *haiku-base-map* (make-sparse-keymap)
  (#\z 'haiku-hide)
  (#\q 'haiku-quit)
  (#\/ 'haiku-search-keyword)

  (#\T 'haiku-recent-entries-pane)
  (#\M 'haiku-my-following-pane)
  (#\L 'haiku-keyword-list-pane)
  (#\H 'haiku-hot-keyword-list-pane)

  (#\SPC 'next-page)

  (#\F5 'haiku-reload-buffer)
  (#\S-F5 'haiku-super-reload-buffer)

  (#\C-h 'haiku-backward-page)
  (#\M-Left 'haiku-backward-page)
  (#\M-Right 'haiku-forward-page)

  (#\C-a 'beginning-of-virtual-line)
  (#\C-e 'end-of-virtual-line)
  (#\C-n 'next-virtual-line)
  (#\C-p 'previous-virtual-line)
  )


(define-keymap *haiku-keyword-base-map* *haiku-base-map*
  (#\RET 'haiku-show-keyword-entry)
  (#\t 'haiku-show-keyword-entry)

  (#\j 'haiku-next-keyword-w/o-scroll)
  (#\k 'haiku-previous-keyword-w/o-scroll)
  (#\v 'haiku-open-keyword-by-browser)
  )

(define-keymap *haiku-entry-sidebar-keyword-map* (copy-keymap *haiku-keyword-base-map*)
  )

(define-keymap *haiku-hot-keyword-list-map* (copy-keymap *haiku-keyword-base-map*)
  )

(define-keymap *haiku-keyword-list-map* (copy-keymap *haiku-keyword-base-map*)
  (#\j 'haiku-next-keyword)
  (#\k 'haiku-previous-keyword)
  (#\SPC 'haiku-keyword-next-page)
  (#\C-v 'haiku-keyword-next-page)
  (#\C-n 'haiku-keyword-next-line)
  )


(define-keymap *haiku-entry-sidebar-user-map* (copy-keymap *haiku-base-map*)
  (#\RET 'haiku-show-user-entry)
  (#\u 'haiku-show-user-entry)
  (#\t 'haiku-show-user-keyword-entry)
  (#\v 'haiku-open-user-by-browser)

  (#\j 'haiku-next-user)
  (#\k 'haiku-previous-user)

  ('(#\h #\q) 'open-hatena-question-by-browser)
  ('(#\h #\a) 'open-hatena-antenna-by-browser)
  ('(#\h #\b) 'open-hatena-bookmark-by-browser)
  ('(#\h #\d) 'open-hatena-diary-by-browser)
  ('(#\h #\f) 'open-hatena-photolife-by-browser)
  ('(#\h #\g) 'open-hatena-group-by-browser)
  ('(#\h #\r) 'open-hatena-rss-by-browser)
  ('(#\h #\i) 'open-hatena-idea-by-browser)
  ('(#\h #\s) 'open-hatena-star-by-browser)
  ('(#\h #\m) 'open-hatena-message-by-browser)
  ('(#\h #\w) 'open-hatena-world-by-browser)
  ('(#\h #\h) 'open-hatena-haiku-by-browser)
  ('(#\h #\G) 'open-hatena-graph-by-browser)
  )


(define-keymap *haiku-entry-base-map* (copy-keymap *haiku-base-map*)
  (#\U 'haiku-toggle-user-pane)
  (#\K 'haiku-toggle-keyword-pane)

  (#\N 'haiku-show-new-entry-pane)
  (#\R 'haiku-show-reply-pane)
  (#\S 'haiku-star-current-entry)
  (#\D 'haiku-delete-current-entry)

  (#\j 'haiku-next-entry)
  (#\k 'haiku-previous-entry)
  (#\u 'haiku-show-current-entry-user-page)
  (#\t 'haiku-show-current-entry-keyword-page)
  (#\v 'haiku-open-current-entry-by-browser)

  (#\RET 'haiku-show-current-entry-keyword-page)
  (#\SPC 'haiku-entry-next-page)
  (#\C-v 'haiku-entry-next-page)
  (#\C-n 'haiku-entry-next-line)

  ('(#\h #\q) 'open-hatena-question-by-browser)
  ('(#\h #\a) 'open-hatena-antenna-by-browser)
  ('(#\h #\b) 'open-hatena-bookmark-by-browser)
  ('(#\h #\d) 'open-hatena-diary-by-browser)
  ('(#\h #\f) 'open-hatena-photolife-by-browser)
  ('(#\h #\g) 'open-hatena-group-by-browser)
  ('(#\h #\r) 'open-hatena-rss-by-browser)
  ('(#\h #\i) 'open-hatena-idea-by-browser)
  ('(#\h #\s) 'open-hatena-star-by-browser)
  ('(#\h #\m) 'open-hatena-message-by-browser)
  ('(#\h #\w) 'open-hatena-world-by-browser)
  ('(#\h #\h) 'open-hatena-haiku-by-browser)
  ('(#\h #\G) 'open-hatena-graph-by-browser)
  )

(define-keymap *haiku-keyword-entry-map* (copy-keymap *haiku-entry-base-map*)
  (#\RET 'haiku-show-current-entry-user-page)
  )

(define-keymap *haiku-recent-entry-map* (copy-keymap *haiku-entry-base-map*)
  (#\N 'haiku-show-new-entry-pane-recent-page)
  )

(define-keymap *haiku-user-entry-map* (copy-keymap *haiku-entry-base-map*)
  (#\E 'haiku-switch-user-entries)
  (#\F 'haiku-switch-user-following)
  (#\P 'haiku-switch-user-profile)
  )


(define-keymap *haiku-post-map* (make-sparse-keymap)
  ('(#\C-x #\k) 'haiku-close-post-pane)
  ('(#\C-c #\C-c) 'haiku-post-entry)
  )


(provide "hatena-haiku-mode/ui/keybind")

;;;; End
