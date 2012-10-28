;;; -*- Mode: Lisp -*-
;;  template:
;;; Author:        amefura <amefura@gmail.com>
;;; License:       template is released under an MIT license.
;;                 See odoc/doc/mit-license for full license.
;;; Code:

(in-package :odoc-api)

(require :odoc/api/version)

(export
 '( *doctype->html* *table-of-contents-title* *recent-title*
 *footer-from* *doc-generator*))
;;
;; string type format control
;;
(defvar *doctype->html*
  "<html>~%")

(defvar *table-of-contents-title*
  "<h3>Table of Contents</h3>~%")

(defvar *recent-title*
  "<h3><a href=\"recent.html\">Recent</a></h3>~%")

(defvar *footer-from*
  "~&<hr/>~%")

(defvar *doc-generator*
  (concat
   "\n<meta name=\"GENERATOR\" content=\"xyzzy-"
   (software-version) "::" (name) "-" (version)"\"/>\n"))

(provide :odoc/api/template)

;;end
