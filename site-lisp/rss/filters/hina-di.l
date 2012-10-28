;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: hina-di.l 561 2006-01-26 12:37:50Z torihat $
;
; rss/filters/hina-di.l
;
; by HATTORI Masashi
;;
;; ■  hina-di形式をrss化するフィルタ
;;
;;    ・設定（config.l参照）
;;      - 必要なURLの数だけ rss-filter-regist する
;;        （デフォルトでは ".di$" にマッチ）
;;      - *hina-di-items-max* に最大表示件数を指定（多くすると遅い）
;;    ・登録
;;      登録時にタイトルを入力する必要がある

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "rss/main"))

(provide "rss/filter/hina-di")

(in-package "rss")

;; "*.di" にマッチ
(defvar *hina-di-url-regexp* "\.di$")
(defvar *hina-di-items-max* 30)

(defmacro hina-di-value (key item)
  `(assoc ,key ,item))

(defmacro hina-di-last-modified (item)
  `(cdr (hina-di-value 'time ,item)))

(defmacro hina-di-site-url (item)
  `(cdr (hina-di-value 'url ,item)))

(defmacro hina-di-site-title (item)
  `(cdr (hina-di-value 'title ,item)))

(defun hina-di-last-modified-format (time)
  (format-date-string "%Y/%m/%d %H:%M:%S" time))

(defun hina-di-parse-line ()
  (when (looking-at "\\([-0-9a-zA-Z]+\\) *: *\\(.*\\)$")
    (cons (match-string 1) (match-string 2))))

(defun hina-di-item-ok (item)
  (and (hina-di-site-url item)
       (hina-di-last-modified item)))

(defun hina-di-parse-item (item)
  (unless (hina-di-last-modified item)
    (push (cons 'time 0) item))
  (unless (hina-di-site-title item)
    (push (cons 'title (hina-di-site-url item)) item))
  item)

(defun hina-di-parse-buffer ()
  (let (items
	item)
    (save-excursion
      (goto-char (point-min))
      (message "parsing hina-di format ...")
      (loop
	(let* ((line (hina-di-parse-line))
	       (key (car line))
	       (val (cdr line)))
	  (when key
	    (cond ((string-matchp "^url$" key)
		   (progn
		     (when (hina-di-item-ok item)
		       (push (hina-di-parse-item item) items)
		       (do-events)
		       (setq item nil))
		     (push (cons 'url val) item)))
		  ((string-matchp "last-modified$" key)
		   (let ((time (junk::rfc822-parse-date val)))
		     (when (and time
				(not (hina-di-last-modified item)))
		       (push (cons 'time time) item))))
		  ((string-matchp "title$" key)
		   (push (cons 'title val) item)))))
	(or (forward-line 1 ) (return)))
      (when (hina-di-item-ok item)
	(push (hina-di-parse-item item) items))
      (message "parsing hina-di format ... done."))
    ;; 更新日時降順でソート
    (setq items (sort items #'> :key #'(lambda (x)
					 (hina-di-last-modified x))))
    ;; 最大件数以下切り捨て
    (when (and *hina-di-items-max*
	       (< *hina-di-items-max* (list-length items)))
      (setq items (butlast items (- (list-length items) *hina-di-items-max*))))
    ;; item生成
    (mapcar #'(lambda (x)
		(rss-create-item (format nil "~@[~A~] ~@[~A~]"
					 (hina-di-last-modified-format (hina-di-last-modified x))
					 (hina-di-site-title x))
				 (hina-di-site-url x)))
	    items)))

(defun hina-di-filter (channel file)
  (let ((url (rss-link channel))
	(title (or (and (rss-title channel)
			(not (equal (rss-title channel) *rss-menu-temp-buffer-suffix*))
			(rss-title channel))
		   (read-string "Site Title: ")))
	items)
    (save-excursion
      (set-buffer (get-buffer-create *rss-buffer-temp*))
      (erase-buffer (selected-buffer))
      (insert-file-contents file)
      (setq items (hina-di-parse-buffer))
      (delete-buffer (selected-buffer)))
    ; 元のファイルを上書き
    (convert-to-rss (rss-create title url nil items)
		    file)))

;; フィルタの登録
;; (URLがマッチした時にフィルタが呼ばれる）
(rss-filter-regist *hina-di-url-regexp* 'hina-di-filter)
