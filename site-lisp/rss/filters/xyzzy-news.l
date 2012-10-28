;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: xyzzy-news.l 561 2006-01-26 12:37:50Z torihat $
;
; rss/filters/xyzzy-news.l
;
; by HATTORI Masashi
;;
;; ■ 局所ニュースを勝手に rss 化するフィルタ
;;
;;    ・登録方法
;;        "a" => "http://popup2.tok2.com/home/i9n/"
;;        "a" => "http://popup2.tok2.com/home/i9n/2003/feb.html"
;;        ...

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "rss/main"))

(provide "rss/filter/xyzzy-news")

(in-package "rss")

(defvar *xn-title* "局所ニュース")
(defvar *xn-url-base* "http://popup2.tok2.com/home/i9n/")
(defvar *xn-url-regexp* (concat *xn-url-base* "\\(.*\\)?"))

(defun xn-parse-buffer (url title)
  (let (items
	beg
	end
	anchor)
    (save-excursion
      (goto-char (point-min))
      (replace-buffer "&nbsp;" "")
      (goto-char (point-min))
      (while (scan-buffer "<a name=\"\\(0[^\"]+\\)\"></a>"
			  :regexp t
			  :tail t)
	(let (title time anchor-current)
	  (setq anchor-current (match-string 1))
	  (setq end (match-beginning 1))
	  (when beg
	    (save-excursion
	      (goto-char beg)
	      (save-restriction
		(narrow-to-region beg end)
		(when (scan-buffer "<b>\\([^<]+\\)</b>"
				   :regexp t
				   :tail t)
		  (setq title (ed::xmlpm-decode-special-chars (match-string 1)))
		  (when (scan-buffer "<div class=\"tr\"[^>]*>[ \t\n]*\\([0-9/]+\\( +[0-9:]+\\)?\\)"
				     :regexp t
				     :tail t)
		    (setq time (match-string 1)))
		  (push (rss-create-item (concat time " " title)
					 (concat url "#" anchor))
			items)))))
	  (setq beg end)
	  (setq anchor anchor-current)))
      (when anchor
	(let (title time)
	  (when (scan-buffer "<b>\\([^<]+\\)</b>"
			     :regexp t
			     :tail t)
	    (setq title (ed::xmlpm-decode-special-chars (match-string 1)))
	    (when (scan-buffer "<div class=\"tr\">[ \t\n]*\\([0-9/]+\\( +[0-9:]+\\)?\\)"
			       :regexp t
			       :tail t)
	      (setq time (match-string 1)))
	    (push (rss-create-item (concat time " " title)
				   (concat url "#" anchor))
		  items)))))
    (nreverse items)))

;; フィルタ関数
;; (チャネル, ファイルを引数にfuncallされる)
(defun xn-filter (channel file)
  (let ((url (rss-link channel))
	title
	items)
    (if (string-match (concat *xn-url-base* "\\([0-9]+\\)/\\([a-zA-Z]+\\).html")
		      url)
	(setq title (format nil "~A ~A/~A"
			    *xn-title*
			    (match-string 1)
			    (string-capitalize (match-string 2))))
      (setq title *xn-title*))
    (save-excursion
      (set-buffer (get-buffer-create *rss-buffer-temp*))
      (erase-buffer (selected-buffer))
      (insert-file-contents file)
      (setq items (xn-parse-buffer url title))
      (delete-buffer (selected-buffer)))
    ; 元のファイルを上書き
    (convert-to-rss (rss-create title url nil items)
		    file)))

;; フィルタの登録
;; (URLがマッチした時にフィルタが呼ばれる）
(rss-filter-regist *xn-url-regexp* 'xn-filter)
