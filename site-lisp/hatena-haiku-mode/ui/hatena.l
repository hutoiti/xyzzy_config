;;;; -*- mode: lisp; package: hatena-haiku.ui -*-
;;;;
;;;; File: hatena-haiku-mode/ui/hatena.l
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

(defun open-hatena-service-by-browser (domain user)
  (when (and domain user)
    (open-browser (format nil "http://~A.hatena.ne.jp/~A/" domain user))))

(defmacro define-hatena-open-command (name domain)
  `(defun ,name ()
     (interactive)
     (open-hatena-service-by-browser ,domain (haiku-current-user))))

(define-hatena-open-command open-hatena-question-by-browser "q")
(define-hatena-open-command open-hatena-antenna-by-browser "a")
(define-hatena-open-command open-hatena-bookmark-by-browser "b")
(define-hatena-open-command open-hatena-diary-by-browser "d")
(define-hatena-open-command open-hatena-photolife-by-browser "f")
(define-hatena-open-command open-hatena-group-by-browser "g")
(define-hatena-open-command open-hatena-rss-by-browser "r")
(define-hatena-open-command open-hatena-graph-by-browser "graph")
(define-hatena-open-command open-hatena-idea-by-browser "i")
(define-hatena-open-command open-hatena-star-by-browser "s")
(define-hatena-open-command open-hatena-message-by-browser "m")
(define-hatena-open-command open-hatena-world-by-browser "w")
(define-hatena-open-command open-hatena-haiku-by-browser "h")


(provide "hatena-haiku-mode/ui/hatena")

;;;; End
