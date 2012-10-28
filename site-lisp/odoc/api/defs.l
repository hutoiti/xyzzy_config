;;; -*- Mode: Lisp -*-
;;  defs:
;;; Author:        amefura <amefura@gmail.com>
;;; License:       defs is released under an MIT license.
;;                 See odoc/doc/mit-license for full license.
;;; Code:

(in-package :odoc-api)

(export
 '(*odoc-publish-hook*
   *odoc-mode-hook*
   *odoc-extension*
   *odoc-config-file*
   *odoc-keyword-file*
   *index-buffer-name*
   *default-conf-path*
   *odoc-wikiname-color*
   *odoc-action-color*
   *odoc-toggle-switch-color*
   *odoc-mode-map*
   ))

(defvar *odoc-publish-hook* nil
  "publish after process")

(defvar *odoc-mode-hook* nil)

(defvar *odoc-extension* "od")

(defvar *odoc-config-file* ".odocrc" )

(defvar *odoc-keyword-file* ".odockwd" )

(defvar *odoc-log-file* ".odoclog" )

(defvar *odoc-wikiname-color* '(:color 1 0))

(defvar *odoc-action-color* '(:color 8 0))

(defvar *odoc-toggle-switch-color* '(:color 3 0))

(defvar *atom-xml* "atom.xml")

(defvar *rss-xml* "rss.xml")

(defconstant *default-conf-path* "~/site-lisp/odoc/")

(defvar *odoc-recent-views* 10)

(defvar *heading-link* 0)

(defvar *config* nil)

(defvar *md5* nil)

(defvar *buffer-name-prefix* "*ODoc:")

(defvar *index-buffer-name-prefix* "Index*")

(defvar *config-tmp-buffer-name-prefix* "Config:Tmp*")

(defvar *index-buffer-name*
  (concat *buffer-name-prefix*
		  *index-buffer-name-prefix*))

(defvar *config-buffer-name*
  (concat *buffer-name-prefix*
		  *config-tmp-buffer-name-prefix*))

(defvar *substitute-alist*
  '(("&" . "&#38;")
	("\"" . "&#34;")
	("<" . "&#60;")
	(">" . "&#62;")
	("[^\\]\\[\\(http://[^\[|\r\n]+\\)|\\([^\]]+\\)\\]" .
	 "<a href=\"\\1\" target=\"_blank\">\\2</a>")
	("[^\\]\\[\\([^\[|\r\n\./]+\\)\\]" .
	 "<a href=\"\\1.html\" target=\"_blank\">\\1</a>")
	("[^\\]\\[\\(\\([^\[|\r\n\.]+\\)/\\)\\]" .
	 "<a href=\"\\1\" target=\"_blank\">\\2</a>")
	("[^\\]\\[\\([^\[|\r\n]+\\.[^\]\.]+\\)\\]" .
	 "<a href=\"\\1\" target=\"_blank\">\\1</a>")
	("\\\\\\(\\[.+?\\]\\)" . "\\1")
	("[^\\]\\[img|\\(\\<[0-9]+\\),\\(\\<[0-9]+\\)|\\(\\<[^|]+?\\)|\\([^|]+?\\>\\)\\]" .
	 "<img src=\"\\3\" height=\"\\1\" width=\"\\2\" border=0 alt=\"\\4\"/>")
	;; 		("[^\\]\\[embed|\\(\\<[0-9]+\\),\\(\\<[0-9]+\\)|\\(\\<[^|]+?\\)|\\([^|]+?\\>\\)\\]" .
	;; 		 "<embed src=\"\\3\" height=\"\\1\" width=\"\\2\" border=0 alt=\"\\4\"/>")
	;; 		("[^\\]\\[flash|\\(\\<[0-9]+\\),\\(\\<[0-9]+\\)|\\(\\<[^|]+?\\)|\\([^|]+?\\>\\)\\]" .
	;; 		 "<object classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" codebase=\"http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,28,0'\" width=\"\\1\" height=\"\\1\" alt=\"\\4\">
	;; <param name=\"movie\" value=\"\\3\" />
	;; <param name=\"quality\" value=\"high\" />
	;; <param name=\"wmode\" value=\"transparent\" />
	;; <embed src=\"\\3\" quality=\"high\" pluginspage=\"http://www.macromedia.com/go/getflashplayer\" type=\"application/x-shockwave-flash\" wmode=\"transparent\" width=\"\\1\" height=\"\\2\" alt=\"\\4\"></embed>
	;; </object>")
	("\\(?:[^\"\[|\\]\\)\\(https?://[^ \t\r\n]+\\)\\([^\"|]\\|$\\)" .
	 "<a href=\"\\1\" target=\"_blank\">\\1</a>\\2") ; dirty
	("\\(?:[\\]\\)\\(https?://[^ \t\r\n]+\\)\\([^\"|]\\|$\\)" .
	 "\\1\\2")
	))

(provide :odoc/api/defs)

;;end