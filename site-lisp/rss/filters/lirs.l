;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: lirs.l 561 2006-01-26 12:37:50Z torihat $
;
; rss/filters/lirs.l
;
; by HATTORI Masashi
;;
;; ■  LIRS形式をrss化するフィルタ
;;
;;    ・設定（config.l参照）
;;      - 必要なURLの数だけ rss-filter-regist する
;;        （デフォルトでは、"lirs.txt" "lirs.txt.gz" "lirs.gz"にマッチ）
;;      - *lirs-url-max* に最大表示件数を指定（多くすると遅い）
;;    ・登録
;;      登録時にタイトルを入力する必要がある

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "rss/main"))

(provide "rss/filter/lirs")

(in-package "rss")

;; "lirs.txt" "lirs.txt.gz" "lirs.gz" にマッチ
(defvar *lirs-url-regexp* "lirs\\(\.txt\\|\.txt.gz\\|\.gz\\)$")
(defvar *lirs-items-max* 30)

#|
Last modified Information Relaying Specification
 <http://aniki.haun.org/natsu/LIRS.html>

LIRSレコードヘッダ
更新時刻(Last-Modified：GMT)
更新時刻を取得した時刻(Last-Detected：GMT)
対象サイトのGMTとの誤差(秒)
対象サイトの容量(Content-Length：バイト)
対象サイトのURL
対象サイトのタイトル
対象サイトの管理者名
情報取得元サイトのURL,(拡張部...)
(\015)\012
|#

(defvar *lirs-time-diference* (ed::parse-date-string "1970/01/01 09:00:00"))

(defmacro lirs-last-modified (line)
  `(nth 1 ,line))

(defmacro lirs-site-url (line)
  `(nth 5 ,line))

(defmacro lirs-site-title (line)
  `(nth 6 ,line))

(defun lirs-last-modified-parse (last-modified)
  (if (and (stringp last-modified)
	   (string-match "^[0-9]+$" last-modified))
      (parse-integer last-modified)
    0))

(defun lirs-last-modified-format (time)
  (format-date-string "%Y/%m/%d %H:%M:%S" (+ time *lirs-time-diference*)))

(defun lirs-parse-line ()
  (split-string (buffer-substring (progn (goto-bol) (point))
				  (progn (goto-eol) (point)))
		""
		t))

(defun lirs-parse-buffer ()
  (let (items)
    (save-excursion
      (message "parsing LIRS format ...")
      (goto-char (point-min))
      ;; 区切り文字をあらかじめ消しておく ("" => "")
      (replace-buffer "" "")
      (goto-char (point-min))
      ;; エスケープされていない "," を置換 ("," => "")
      (replace-buffer "\\([^\\]\\)," "\\1" :regexp t)
      (goto-char (point-min))
      (replace-buffer "," "")
      ;; エスケープされた "," を戻す ("\," => ",")
      (goto-char (point-min))
      (replace-buffer "\\," ",")
      ;; エスケープを戻す ("\\" => "\")
      (goto-char (point-min))
      (replace-buffer "\\\\" "\\")
      (goto-char (point-min))
      (while (looking-for "LIRS")
	(let ((line (lirs-parse-line)))
	  (setf (lirs-last-modified line)
		(lirs-last-modified-parse (lirs-last-modified line)))
	  (push line items))
	(or (forward-line 1) (return)))
      (message "parsing LIRS format ... done."))
    ;; 更新日時降順でソート
    (setq items (sort items #'> :key #'(lambda (x)
					 (lirs-last-modified x))))
    ;; 最大件数以下切り捨て
    (when (and *lirs-items-max*
	       (< *lirs-items-max* (list-length items)))
      (setq items (butlast items (- (list-length items) *lirs-items-max*))))
    (mapcar #'(lambda (x)
		(rss-create-item (format nil "~@[~A~] ~@[~A~]"
					 (lirs-last-modified-format (lirs-last-modified x))
					 (lirs-site-title x))
				 (lirs-site-url x)))
	    items)))

(defun lirs-filter (channel file)
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
      (setq items (lirs-parse-buffer))
      (delete-buffer (selected-buffer)))
    ; 元のファイルを上書き
    (convert-to-rss (rss-create title url nil items)
		    file)))

;; フィルタの登録
;; (URLがマッチした時にフィルタが呼ばれる）
(rss-filter-regist *lirs-url-regexp* 'lirs-filter)
