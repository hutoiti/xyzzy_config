;;;; -*- mode: lisp; package: hatena-haiku.ui -*-
;;;;
;;;; File: hatena-haiku-mode/ui/config.l
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

(export '(*haiku-post-buffer-height-ratio*
          *haiku-default-source*
          *haiku-disable-color*
          *haiku-page-title-color*
          *haiku-page-subtitle-color*
          *haiku-entry-title-color*
          *haiku-entry-meta-color*
          *haiku-entry-meta-text-color*
          *haiku-star-color*
          *haiku-hot-keyword-color-list*
          *haiku-keyword-color*
          *haiku-user-color*
          *haiku-post-description-color*
          *haiku-post-title-color*

#|
¡‚Ìì‚è‚Å‚Í base-map ‚É define-key ‚µ‚Ä‚à”½‰f‚³‚ê‚È‚¢‚Ì‚Å export ‚ÍŒ©‘—‚è

          *haiku-base-map*
          *haiku-keyword-base-map*
          *haiku-keyword-list-map*
          *haiku-hot-keyword-list-map*
          *haiku-entry-sidebar-keyword-map*
          *haiku-entry-sidebar-user-map*
          *haiku-entry-base-map*
          *haiku-keyword-entry-map*
          *haiku-recent-entry-map*
          *haiku-user-entry-map*
          *haiku-post-map*
|#
          ))


;;;; İ’è

(defvar *haiku-post-buffer-height-ratio* 0.3)
(defvar *haiku-default-source* (hatena-haiku-mode-name))

;;;; color

(defvar *haiku-disable-color* nil)

(defvar *haiku-page-title-color* '(:bold t :foreground 12))
(defvar *haiku-page-subtitle-color* *haiku-page-title-color*)

(defvar *haiku-entry-title-color* '(:bold t :underline t :foreground 10))
(defvar *haiku-entry-meta-color* '(:foreground 13))
(defvar *haiku-entry-meta-text-color* '(:foreground 15))

(defvar *haiku-star-color* *hatena-star-default-star-color*)

(defvar *haiku-hot-keyword-color-list*
  '((:foreground 15)            ; 1
    (:foreground 14)            ; 2
    (:foreground 10)            ; 3
    (:foreground 10)            ; 4
    (:foreground 10 :bold t)    ; 5
    (:foreground 10 :bold t)    ; 6
    (:foreground 10 :bold t :underline t) ; 7
    ))
(defvar *haiku-keyword-color* '(:foreground 10))
(defvar *haiku-user-color* *haiku-keyword-color*)

(defvar *haiku-post-description-color* '(:foreground 15))
(defvar *haiku-post-title-color* '(:underline t :foreground 10))


;;;; keymap

(defvar *haiku-base-map* nil)

(defvar *haiku-keyword-base-map* nil)
(defvar *haiku-keyword-list-map* nil)
(defvar *haiku-hot-keyword-list-map* nil)

(defvar *haiku-entry-sidebar-keyword-map* nil)
(defvar *haiku-entry-sidebar-user-map* nil)

(defvar *haiku-entry-base-map* nil)
(defvar *haiku-keyword-entry-map* nil)
(defvar *haiku-recent-entry-map* nil)
(defvar *haiku-user-entry-map* nil)

(defvar *haiku-post-map* nil)


(provide "hatena-haiku-mode/ui/config")

;;;; End
