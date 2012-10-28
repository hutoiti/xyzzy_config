;;; -*- mode: lisp -*-
;;; name:     virtual-file-ftp
;;; version:  2007.03.23
;;; author:   shiro
;;; depends:  complete+, virtual-file
;;; category: Utilities, File Systems
;;; src:      http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fvirtual-file-ftp&openfile=
;;; changes:  リストを返す関数の仕様を変更
;;; files:    site-lisp/virtual-file/virtual-file-ftp.l
;;;           site-lisp/virtual-file/virtual-file-ftp.lc
;;;           site-lisp/ni-autoload/silog/virtual-file-ftp.l

;; Copyright (C) 1999-2005 Masashi Hattori
;; Copyright (C) 2007 shiro
;;
;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions
;; are met:
;;
;; 1. Redistributions of source code must retain the above copyright
;;    notice, this list of conditions and the following disclaimer.
;;
;; 2. Redistributions in binary form must reproduce the above copyright
;;    notice, this list of conditions and the following disclaimer in
;;    the documentation and/or other materials provided with the
;;    distribution.
;;
;; 3. The name of the author may not be used to endorse or promote
;;    products derived from this software without specific prior
;;    written permission.
;;
;; THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
;; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
;; PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
;; DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
;; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
;; OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
;; HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
;; STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
;; ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;; POSSIBILITY OF SUCH DAMAGE.

;; 概要:
;; 
;; virtual-fileのFTP用プラグイン
;; 
;; ミニバッファでFTPに接続して補完し、
;; 読み込み時に一時ファイルにダウンロードし、
;; 保存時に再アップロードを行います。

;; 設定:
;; 
;; あらかじめ以下の例のように書かれた
;; ファイル foo._ftp を用意する。
;; 
;; :user   "bar"
;; :pass   "baz"
;; :host   "ftp.qux.com"
;; 
;; 初期ディレクトリを指定したい人は
;; :cwd    "public_html"
;; も書いておく。
;; 
;; 日本語のファイル名が文字化けする人は
;; :encode  map-euc-to-sjis
;; も書いておく。
;; utf8 なら map-utf-8-to-sjis を使う。
;; それ以外の人は $XYZZY/lisp/encoding.l を見て適当に。
;; 
;; pasvが良い人は.xyzzyに以下を書けばいいかも(参考: lisp/wip/ftp.l)
;; (setf *ftp-passive-mode* t)

;; 使い方:
;; 
;; 1. 上記の設定を行う
;; 2. find-file [C-x C-f]
;; 3. 上記の設定を行ったファイルの末尾に/をつける
;; 4. 編集が終わったら save-buffer [C-x C-s] で勝手にアップロード

;; 注意:
;; 
;; ファイル1つにつきログイン・ファイルの取得・ログアウトを行います。
;; セッションで10も20もファイルを開くようなことをすると超遅いかもしれません。
;; 
;; 改行コードまでは変換しないので
;;  [C-x C-k n]
;; または
;;  M-x change-eol-code
;; で改行コードをlfにしてから保存してください。

;; 履歴:
;; 
;; 2007.03.23
;; - リストを返す関数の仕様を変更
;; 
;; 2007.03.22
;; - リストを返す関数が全ての候補のみを返すようにした
;; 
;; 2007.03.14
;; - 一時ファイルに保存してアップロードするようにした
;; 
;; 2007.03.07
;; - 初版

;;; Code:

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "virtual-file/virtual-file")
  (require "wip/ftp"))

(provide "virtual-file/virtual-file-ftp")
(in-package "complete+")

;; non-nilならFTPのメッセージが*FTP Message*というバッファに出力します。
;; e.g. (setf complete+::*plugin-ftp-message-buffer* t)
(defvar *plugin-ftp-message-buffer* nil)

;; キャッシュする時間 (default: 300000=5min)
(defvar *plugin-ftp-cache-interval* 300000)

(defparameter *plugin-ftp-complete-hash*
  (make-hash-table :test 'equalp))

(defun plugin-ftp-list-internal (base file &key host cwd user pass encode)
  (format t "~%* FTP connect to ~S (list)~%" host)
  (let (subpath hash fname)
	(unless file
	  (return-from plugin-ftp-list-internal nil))
	(if (string-match "\\(.*\\)/\\([^/]*\\)$" file)
		(setq subpath (match-string 1)
			  fname (match-string 2))
	  (psetq subpath ""
			 fname subpath))
	(let* ((not-match 0)
		   (hash (gethash (concat base subpath) *plugin-ftp-complete-hash*))
		   (x (if (and hash
					   (> (+ *plugin-ftp-cache-interval* (cadr hash))
						  (get-internal-real-time)))
				  (car hash)
				(user::with-ftp-stream (ftp host)
				  (user::ftp-login ftp user pass)
				  (let ((ret (user::ftp-ls ftp (concat (when cwd (append-trail-slash cwd)) subpath))))
					(setf (gethash (concat base subpath) *plugin-ftp-complete-hash*) (list ret (get-internal-real-time)))
					ret
					)))))
	  (setq x (mapcar (lambda (f)
						(cond ((string-match *plugin-ftp-file-line-regexp-1* f)
							   (let* ((perm (match-string 1))
									  (file (if (string= "->" (match-string 3))
												(match-string 2)
											  (match-string 4))))
								 (list file
									   nil
									   (plugin-ftp-file-type perm)
									   f)))
							  ((string-match *plugin-ftp-file-line-regexp-1* f)
							   (let ((ftime (format nil "~A ~A"
													(match-string 1)
													(match-string 2)))
									 (size (match-string 3))
									 (file (match-string 4)))
								 (list file
									   ftime
									   (if (equal "<DIR>" size)
										   *plugin-ftp-directory*
										 *plugin-ftp-file*)
									   f)))
							  (t
							   (list "" ""))
							  )) x))
	  (let ((ret (mapcar (lambda (x) (concat (car x)
											 (if (eql *plugin-ftp-directory* (caddr x)) "/")))
						 x)))
		(when (and (= (length ret) 1)
				   (string-match (concat (regexp-quote fname) "/$") (car ret)))
		  (setf ret (mapcar (lambda (x) (concat (car ret) x))
							(plugin-ftp-list-internal
							 base (concat base subpath (car ret))
							 :host host :cwd cwd :user user :pass pass))))
		(when encode
		  (setf ret (mapcar (lambda (f) (funcall encode f)) ret)))
		ret))))

(defun plugin-ftp-load-internal (base file &key host cwd user pass encode)
  (format t "~%* FTP connect to ~S (load)~%" host)
  (user::with-ftp-stream (ftp host)
	(user::ftp-login ftp user pass)
	(let* ((dir (make-temp-file-name "ftp_" "" nil t))
		   (bufname (if (string-match "[/\\]\\([^/\\]+\\)$" file)
						(subseq file (match-beginning 1) (match-end 1))
					  file))
		   (tmp-file (merge-pathnames (file-namestring file) dir)))
	  (with-open-file (fs tmp-file :direction :output)
		(user::ftp-get ftp (if (and cwd (not (string= cwd "")))
							   (concat (append-trail-slash cwd) file)
							 file)
					   fs))
	  (unwind-protect
		  (progn
			(find-file tmp-file)
			(set-default-directory
			 (directory-namestring
			  (remove-trail-slash base)))
			(rename-buffer bufname)
			(set-buffer-file-name nil)
			(set-buffer-alternate-file-name
			 (merge-pathnames file base))
			(virtual-file-mode-on))
		(delete-file tmp-file :if-access-denied :force)
		(delete-directory dir :if-access-denied :force)))
	(selected-buffer)))

(defun plugin-ftp-save-internal (base file nomsg append &key host cwd user pass encode)
  (save-excursion
	(let ((tmp-file (make-temp-file-name)))
	  (unwind-protect
		  (progn
			(when append
			  (save-excursion
				(set-buffer (plugin-ftp-load-internal
							 base file
							 :host host :cwd cwd :user user :pass pass :encode encode))
				(write-file tmp-file t)))
			(write-file tmp-file t append)
			(user::with-ftp-stream (ftp host)
			  (user::ftp-login ftp user pass)
			  (with-open-file (s tmp-file)
				(user::ftp-put ftp s (if (and cwd (not (string= cwd "")))
										 (concat (append-trail-slash cwd) file)
									   file)))))
		(delete-file tmp-file))))
  (set-buffer-modified-p nil)
  (unless nomsg
	(message "Wrote ~a: ~a~a"
			 host
			 (if (and cwd (not (string= cwd ""))) (append-trail-slash cwd) "")
			 file)))

(defvar *plugin-ftp-file-line-regexp-1*
  "^[ \t]*\\([^ \t]+\\)[ \t]+[^ \t]+[ \t]+.*[ \t]\\([^ \t]+\\)[ \t]+\\([^ \t]+\\)[ \t]+\\([^ \t]+\\)$")
(defvar *plugin-ftp-file-line-regexp-2*
  "\\([-0-9]+\\)[ \t]+\\([0-9:]+[AP]M\\)[ \t]+\\([^ \t\n]+\\)[ \t]+\\([^ \t\n]+\\)")

(defvar *plugin-ftp-file* nil)
(defvar *plugin-ftp-directory* 1)

(defvar *plugin-ftp-symlink* 2)

(defun plugin-ftp-file-type (perm)
  (cond ((char= (char perm 0) #\d)
		 *plugin-ftp-directory*)
		((char= (char perm 0) #\l)
		 *plugin-ftp-symlink*)
		(t
		 *plugin-ftp-file*)))

(defun plugin-ftp-get-log-buffer ()
  (let* ((name "*FTP Message*")
		 (buf (find-buffer name)))
	(unless buf
	  (setf buf (create-new-buffer name))
	  (with-set-buffer
		(save-excursion
		  (set-buffer buf)
		  (setq buffer-read-only nil)
		  (setq need-not-save t)
		  (setq kept-undo-information nil)
		  (setq auto-save nil))))
	buf))

(defun plugin-ftp-list (base file)
  (let ((param (with-open-file (f base)
				 (let (ret tmp)
				   (while (setf tmp (read f nil))
					 (push tmp ret))
				   (nreverse ret)))))
	(values (cond (*plugin-ftp-message-buffer*
				   (with-output-to-buffer ((plugin-ftp-get-log-buffer))
					 (format t "~%* FTP connect --- ~S~%" param)
					 (apply #'plugin-ftp-list-internal base file param)))
				  (t (apply #'plugin-ftp-list-internal base file param)))
			:list)))

(defun plugin-ftp-load (base file)
  (let ((param (with-open-file (f base)
				 (let (ret tmp)
				   (while (setf tmp (read f nil))
					 (push tmp ret))
				   (nreverse ret)))))
	(cond (*plugin-ftp-message-buffer*
		   (with-output-to-buffer ((plugin-ftp-get-log-buffer))
			 (apply #'plugin-ftp-load-internal base file param)))
		  (t (apply #'plugin-ftp-load-internal base file param)))))

;; char-encoding と eol-code は良くわかってないのでパス
(defun plugin-ftp-save (base file nomsg append char-encoding eol-code)
  (let ((param (with-open-file (f base)
				 (let (ret tmp)
				   (while (setf tmp (read f nil))
					 (push tmp ret))
				   (nreverse ret)))))
	(cond (*plugin-ftp-message-buffer*
		   (with-output-to-buffer ((plugin-ftp-get-log-buffer))
			 (apply #'plugin-ftp-save-internal base file nomsg append param)))
		  (t (apply #'plugin-ftp-save-internal base file nomsg append param)))))

(regist-virtual-file-handler
 ;; マッチする正規表現
 "\\._ftp/$"

 ;; 補完リストの生成を行う関数を指定する
 ;; 
 ;; 引数
 ;;   base  ._ftp/までのパス
 ;;   file  ._ftp/より後のパス
 ;;   
 ;;   e.g.  C:/ftp/foo._ftp/ , public_htm/index.html
 ;; 
 ;; 戻り値
 ;;   補完候補のリスト(ディレクトリ不要)
 ;;   
 ;;   e.g. ("abbrev.l" "about.l" "backup.l")
 'plugin-ftp-list
 
 ;; ファイルの読み込みを行う関数を指定する
 ;; 
 ;; 引数
 ;;   base ._ftp/までのパス
 ;;   file ._ftp/より後のパス
 ;;   
 ;;   e.g.  C:/ftp/foo._ftp/ , public_htm/index.html
 ;;
 ;; 戻り値
 ;;   選択したいバッファ
 ;;
 'plugin-ftp-load
 
 ;; ファイルの保存を行う関数を指定する
 ;;
 ;; 引数
 ;;   base          ._ftp/までのパス
 ;;   file          ._ftp/より後のパス
 ;;                 (ここからoptional)
 ;;   nomsg         メッセージを表示しない
 ;;   append        既存のファイルに追加する
 ;;   char-encoding エンコード
 ;;   eol-code      改行コード
 ;;   
 ;;   e.g.  C:/ftp/foo._ftp/, public_htm/index.html, nil, t
 'plugin-ftp-save
 )

;;; virtual-file-ftp.l ends here
