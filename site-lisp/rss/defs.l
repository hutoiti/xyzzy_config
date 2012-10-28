;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: defs.l 731 2006-09-01 18:09:41Z torihat $
;
; rss/defs.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "junk/http"))
(require "xml-parser-modoki")

(defpackage "rss"
  (:use "lisp" "editor"))

(provide "rss/defs")

(in-package "rss")

(defvar *version* "0.0.3.0beta1")

(defvar *prog-name* (format nil "rss-mode/~A" *version*))

(defvar *user-agent* (format nil "~A|~A" *prog-name* junk::*junk-http-user-agent*))

(defconstant *rss-item-flags-read*     t)
(defconstant *rss-item-flags-unread* nil)

(defvar *online* nil)

(defvar *rss-buffer-prefix* "*RSS ")
(defvar *rss-buffer-group*
  (concat *rss-buffer-prefix* "GROUP*"))
(defvar *rss-buffer-menu*
  (concat *rss-buffer-prefix* "MENU*"))
(defvar *rss-buffer-temp*
  (concat *rss-buffer-prefix* "TEMP*"))
(defvar *rss-buffer-update-temp*
  (concat *rss-buffer-prefix* "UPTEMP*"))
(defvar *rss-buffer-format*
  (concat *rss-buffer-prefix* "FORMAT*"))
(defvar *rss-buffer-clip*
  (concat *rss-buffer-prefix* " CLIP*"))
(defvar *rss-buffer-history*
  (concat *rss-buffer-prefix* " HISTORY*"))

(defvar *pframe-name* "RSS")
(defvar *pframe-old* nil)

(defvar *rss-menu-width* 20)
(defvar *rss-item-window-height* 10)

(defvar *rss-directory* "~/.rss")

(defvar *rss-menu-file*
  (merge-pathnames "rss-menu.dat" *rss-directory*))
(defvar *rss-config-file*
  (merge-pathnames "config.l" *rss-directory*))
(defvar *rss-group-file*
  (merge-pathnames "group-menu.dat" *rss-directory*))
(defvar *rss-clip-file*
  (merge-pathnames "clip-list.dat" *rss-directory*))
(defvar *rss-history-file*
  (merge-pathnames "history-list.dat" *rss-directory*))

(defvar *rss-menu-data* nil)

(defvar *rss-current-channel* nil)
(defvar-local *rss-channel* nil)
(defvar-local *rss-item-list* nil)
(defvar-local *rss-pos-list* nil)
(defvar *rss-clip-list* nil)
(defvar *rss-history-list* nil)

(defvar *rss-group-title* "[Groups]")
(defvar *rss-group-default-name* "Default")
(defvar *rss-group-list* nil)
(defvar *rss-group-list-default* (list (list nil)))
(defvar *rss-group-current* nil)

(defvar *rss-attribute-group-title* '(:bold t))
(defvar *rss-attribute-group* nil)
(defvar *rss-attribute-group-unread* '(:foreground 1))
(defvar *rss-attribute-menu-title* '(:bold t))
(defvar *rss-attribute-menu* nil)
(defvar *rss-attribute-menu-unread* '(:foreground 1))
(defvar *rss-attribute-channel-title* '(:bold t))
(defvar *rss-attribute-channel-description* nil)
(defvar *rss-attribute-item-prefix* nil)
(defvar *rss-attribute-item-title* '(:bold nil
				     :foreground 1))
(defvar *rss-attribute-item-title-unread* '(:bold t
					    :foreground 1))
(defvar *rss-attribute-item-description* nil)
(defvar *rss-attribute-item-site* nil)

(defvar *rss-datetime-format* "%Y/%m/%d %H:%M")

(defvar *rss-recenter-param* 0)
(defvar *rss-item-show-description* t)

(defvar *rss-start-hook* nil)
(defvar *rss-finish-hook* nil)
(defvar *rss-open-rss-hook* nil)
(defvar *rss-fetch-data-hook* nil)
(defvar *rss-jump-hook* nil)

(defvar *rss-search-unread-with-updated* nil)
(defvar *rss-search-next-unread-open*  t)
(defvar *rss-search-next-unread-menu*  t)
(defvar *rss-search-next-unread-group* t)

(defvar *rss-cache-max-number* 0)

(defvar *rss-clip-max-number* 100)
(defvar *rss-clip-clipboard* nil)
(defvar *rss-clip-window-conf-backup* nil)
(defvar *rss-clip-channel* (list (cons "title" "Clip")
				 (cons "link" nil)
				 (cons "description" nil)))

(defvar *rss-history-max-number* 100)
(defvar *rss-history-clipboard* nil)
(defvar *rss-history-window-conf-backup* nil)
(defvar *rss-history-channel* (list (cons "title" "History")
				    (cons "link" nil)
				    (cons "description" nil)))
