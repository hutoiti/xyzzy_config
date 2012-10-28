;;; -*- Mode: Lisp; Package: ChangeLogMemo -*-
;;;
;;; changelogmemo/defs.l
;;;
;;; Last updated: "2006-02-23"
;;;

(defpackage "changelogmemo"
  (:use "lisp" "editor")
  (:nicknames "cl"))

(provide "changelogmemo/defs")

(in-package "changelogmemo")

;;; ŠO•”

(defvar *cl-file* "~/cl/changelogmemo")
(defvar *cl-history-directory* "~/cl/history/")

(defvar *memo-window-height* nil)

(defvar *memo-fold-width* nil)
(defvar *memo-fill-column* nil)

(defvar *search-fold-width* nil)
(defvar *search-fill-column* nil)
(defvar *esearch-fold-width* nil)
(defvar *esearch-fill-column* nil)

(defvar *cl-user* "YOUR NAME  <your@email.address>")

(defvar *chalow-command* nil)

(defvar *item-LFD-number* 1);C-j ‚Å“ü‚ê‚é‰üs‚ÌŒÂ”

(defvar *cl-case-fold-search* t)

(defvar *cl-buffer* "*scratch*")

(defvar *buffer-prefix* "*cl")

(defvar *buffer-memo* (concat *buffer-prefix* "memo*"))
(defvar *buffer-search* (concat *buffer-prefix* "search*"))
(defvar *buffer-save* (concat " " *buffer-prefix* "save*"))
(defvar *buffer-temp* (concat *buffer-prefix* "temp*"))

(defvar *default-pframe* "Frame 1")

(defvar *cl-save-history* (default-value '*save-history*))
(defvar *cl-minibuffer-maximum-history-count*
  (default-value '*minibuffer-maximum-history-count*))

(defvar *memo-scroll-margin* 4)
(defvar *search-scroll-margin* 4)

(defvar *cl-popup-completion-list* *popup-completion-list-default*)

(defvar *unclassified-category-name* "–¢•ª—Þ")

(defvar *search-window-flag-tab* nil)
(defvar *search-window-flag-newline* nil)

(defvar *esearch-window-flag-tab* nil)
(defvar *esearch-window-flag-newline* nil)

(defvar *kept-old-versions* nil)
(defvar *kept-new-versions* nil)

(defvar *edided-entry-limit* 100)

(defvar *tool-bar-function* 'toggle-memo-tool-bar-buffer)
(defvar *tool-bar-check-function* 'tool-bar-check)

;;; F‚Ã‚¯

(defvar *date-keyword*
  '("^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] ([A-Z][a-z][a-z]).*$"
    nil (:color 10 0 :underline)))

(defvar *category-keyword*
  '("\\[\\([^][\n]+\\)\\]\\(:\\| \\[[^][\n]+\\]:\\| \\[[^][\n]+\\] \\[\\)"
    nil (:color 13 0) nil 1 1))

(defvar *link-keyword*
  '("\\[\\[.+\\]\\]"
    nil (:color 12 0)))
(defvar *date-link-keyword*
  '("\\[[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\\]"
    nil (:color 12 0)))
(defvar *url-keyword*
  '("\\(http\\|ftp\\)://[-a-zA-Z0-9_/~.#@%?&=;+(),'$!*:]+"
    nil (:color 12 0)))

(defvar *strong-keyword*
  '("==[^=\n]+=="
    nil (:color 12 0 :strike-out)))
(defvar *em-strong-keyword*
  '("\\(''[^' \t\n]+''\\|\\'''[^' \t\n]+'''\\)"
    nil (:color 12 0 :bold)))

(defvar *title-keyword*
  '("^\\* \\(\\([p][^:\n]\\|[^p \n]:\\|[^p \n][^:\n]\\)[^][\n]*\\|[^p\n]\\).*:"
    nil (:color 4 0) nil 1 1))
(defvar *title-keyword-with-tab*
  '("^\t\\* \\(\\([p][^:\n]\\|[^p \n]:\\|[^p \n][^:\n]\\)[^][\n]*\\|[^p\n]\\).*:"
    nil (:color 4 0) nil 1 1))

(defvar *private-title-keyword*
  '("^\\* p:\\([^][\n]*\\).*:"
    nil (:color 10 0) nil 1 1))
(defvar *private-title-keyword-with-tab*
  '("^\t\\* p:\\([^][\n]*\\).*:"
    nil (:color 10 0) nil 1 1))

(defvar *quote-keyword*
  (list "^\\(>.*\\||.*\\)$" nil '(:color 10 0) nil 1 1))
(defvar *quote-keyword-with-tab*
  (list "^\t\\(>.*\\||.*\\)$" nil '(:color 10 0) nil 1 1))

#|
(defvar *quote-keyword*
  (list "^\\(>[^>\n]*\\|>>[^\n]+\\||.*\\)$" nil '(:color 10 0) nil 1 1))
(defvar *quote-keyword-with-tab*
  (list "^\t\\(>[^>\n]*\\|>>[^\n]+\\||.*\\)$" nil '(:color 10 0) nil 1 1))

(defvar *multi-quote-keyword*
  (list "^\\(>>\n[^><]*\\([^<]<?\\|[^>]>?\\)[^><]*\n<<\\)$"
	nil '(:color 10 0) nil 1 1))
(defvar *multi-quote-keyword-with-tab*
  (list "^\t\\(>>\n\t[^><]*\\([^<]<?\\|[^>]>?\\)[^><]*\n\t<<\\)$"
	nil '(:color 10 0) nil 1 1))
|#

(defvar *horizon-keyword*
  '("^----"
    nil (:color 12 0 :strike-out)))
(defvar *horizon-keyword-with-tab*
  '("^\t\\(----\\)"
    nil (:color 12 0 :strike-out) nil 1 1))

(defvar *search-category-keyword*
  '("\\[\\([^][\n]+\\)\\]([0-9]+)\\(:\\| \\[[^][\n]+\\]([0-9]+):\\| \\[[^][\n]+\\]([0-9]+) \\[\\)"
    nil (:color 13 0) nil 1 1))

(defvar *search-year-month-keyword*
  '("^[0-9][0-9][0-9][0-9]: .+$"
    nil (:color 12 0)))
(defvar *search-month-day-keyword*
  '("^[0-9][0-9][0-9][0-9]-[0-9][0-9] / .+$"
    nil (:color 12 0)))

(defvar *search-attribute* '(:foreground 5))

(defvar *memo-format*
  (compile-regexp-keyword-list
   `(,*date-keyword*
     ,*category-keyword*
     ,*link-keyword*
     ,*date-link-keyword*
     ,*url-keyword*
     ,*strong-keyword*
     ,*em-strong-keyword*
     ,*title-keyword*
     ,*private-title-keyword*
     ,*quote-keyword*
     ,*horizon-keyword*)))

(defvar *search-format*
  (compile-regexp-keyword-list
   `(,*date-keyword*
     ,*category-keyword*
     ,*link-keyword*
     ,*date-link-keyword*
     ,*url-keyword*
     ,*strong-keyword*
     ,*em-strong-keyword*
     ,*title-keyword-with-tab*
     ,*private-title-keyword-with-tab*
     ,*quote-keyword-with-tab*
     ,*horizon-keyword-with-tab*
     ,*search-category-keyword*
     ,*search-year-month-keyword*
     ,*search-month-day-keyword*)))

(defvar *esearch-format*
  (compile-regexp-keyword-list
   `(,*date-keyword*
     ,*category-keyword*
     ,*link-keyword*
     ,*date-link-keyword*
     ,*url-keyword*
     ,*strong-keyword*
     ,*em-strong-keyword*
     ,*title-keyword*
     ,*private-title-keyword*
     ,*quote-keyword*
     ,*horizon-keyword*
     ,*search-category-keyword*
     ,*search-year-month-keyword*
     ,*search-month-day-keyword*)))

;;; “à•”

(defvar *date-regexp*
  (compile-regexp (format nil "^\\([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\\) ([A-Z][a-z][a-z])  ~A$" *cl-user*)))
(defvar *year-regexp*
  (compile-regexp (format nil "^\\([0-9][0-9][0-9][0-9]\\)-[0-9][0-9]-[0-9][0-9] ([A-Z][a-z][a-z])  ~A$" *cl-user*)))
(defvar *month-regexp*
  (compile-regexp (format nil "^\\([0-9][0-9][0-9][0-9]-[0-9][0-9]\\)-[0-9][0-9] ([A-Z][a-z][a-z])  ~A$" *cl-user*)))

(defvar *item-regexp* (compile-regexp "^\\(\\* .*:\\)"))
(defvar *item-regexp-with-tab* (compile-regexp "^\t\\(\\* .*:\\)"))

(defvar *title-regexp* (compile-regexp "^\\* \\(p:\\|\\)\\([^][\n]*\\).*:"))

(defvar *category-regexp*
  (compile-regexp
   "\\[\\([^][\n]+\\)\\]\\(:\\| \\[[^][\n]+\\]:\\| \\[[^][\n]+\\] \\[\\)"))

(defvar *search-category-regexp*
  (compile-regexp
   "\\[\\([^][\n]+\\)\\]([0-9]+)\\(:\\| \\[[^][\n]+\\]([0-9]+):\\| \\[[^][\n]+\\]([0-9]+) \\[\\)"))

(defvar *and-history-list* nil)
(defvar *or-history-list* nil)
(defvar *regexp-history-list* nil)
(defvar *category-history-list* nil)
(defvar *year-history-list* nil)
(defvar *month-history-list* nil)
(defvar *day-history-list* nil)

(defvar *and-filename* "and")
(defvar *or-filename* "or")
(defvar *regexp-filename* "regexp")
(defvar *category-filename* "category")
(defvar *year-filename* "year")
(defvar *month-filename* "month")
(defvar *day-filename* "day")

(defvar *memo-show-p* nil)
