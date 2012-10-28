;;; -*- mode: lisp -*-
;;; name:     virtual-file-archive
;;; version:  2007.03.23
;;; author:   shiro
;;; depends:  complete+, virtual-file
;;; category: Utilities, File Systems
;;; src:      http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fvirtual-file-archive&openfile=
;;; changes:  リストを返す関数の仕様を変更
;;; files:    site-lisp/virtual-file/virtual-file-archive.l
;;;           site-lisp/virtual-file/virtual-file-archive.lc
;;;           site-lisp/ni-autoload/silog/virtual-file-archive.l

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
;; virtual-fileのアーカイブ用プラグイン
;; 
;; ミニバッファで圧縮ファイルの中身を補完し、
;; 読み込み時に展開し、
;; 保存時に再圧縮を行います。
;; filer-list-archive(ファイラ上でV)で開いたファイルも保存時の圧縮を行います。
;; 
;; complete+ と virtual-file が必要です。
;; 
;; 標準関数find-file-in-archiveを上書きしています。

;; 使い方:
;; 
;; 1. find-file [C-x C-f]
;; 2. 圧縮ファイルの末尾に/をつける
;; 3. 編集が終わったら save-buffer [C-x C-s] で勝手に再圧縮

;; 履歴:
;; 
;; 2007.03.23
;; - リストを返す関数の仕様を変更
;; 
;; 2007.03.22
;; - リストを返す関数が全ての候補のみを返すようにした
;; 
;; 2007.03.14
;; - provideを間違えていたのを修正
;; 
;; 2007.03.08
;; - 配置換え
;; 
;; 2007.03.07
;; - 初版

;;; Code:

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "virtual-file/virtual-file"))

(provide "virtual-file/virtual-file-archive")

;;; 関数上書きここから
(in-package "editor")
(defvar *find-file-in-archive-hook* nil)
(defun find-file-in-archive (arcname filename)
  (let (dir file)
	(unwind-protect
		(let* ((name (concat arcname ":" filename))
			   (bufname (if (string-match "[/\\]\\([^/\\]+\\)$" filename)
							(subseq filename (match-beginning 1) (match-end 1))
						  filename))
			   (buffer (get-alternate-file-buffer name)))
		  (cond (buffer
				 (set-buffer buffer)
				 (message "Out buffer"))
				(t
				 (setq dir (make-temp-file-name nil nil nil t))
				 (setq file (merge-pathnames (substitute-string filename "^[/\\]" "") dir))
				 (extract-archive arcname dir filename)
				 (unless (file-exist-p file)
				   (error "~a~%なんか知らんけど解凍できませんでした" file))
				 (prog1
					 (find-file file)
				   (set-default-directory (directory-namestring arcname))
				   (rename-buffer bufname)
				   (set-buffer-file-name nil)
				   (set-buffer-alternate-file-name name)
				   (run-hooks '*find-file-in-archive-hook*);;変更点
				   ))))
	  (when dir
		(directory dir
				   :absolute t :recursive t
				   :callback #'(lambda (f)
								 (if (file-directory-p f)
									 (delete-directory f :if-access-denied :force)
								   (delete-file f :if-access-denied :force))))
		(delete-directory dir :if-does-not-exist :skip :if-access-denied :force)))))
;;; 関数上書きここまで

(in-package "complete+")

(add-hook 'ed::*find-file-in-archive-hook* 'virtual-file-mode-on)

;;; 拡張子と*archiver-dll-list*の対応表（多分）
(defvar *plugin-archive-type-alist*
  '(;; Ish::suffixes[]
	("ish"  . :ish32)
	;; Tar::suffixes[]
	("tgz"  . :tar32)
	("taz"  . :tar32)
	("gz"   . :tar32)
	("z"    . :tar32)
	("tar"  . :tar32)
	("bz2"  . :tar32)
	("cpio" . :tar32);;;
	("rpm"  . :tar32);;;
	("deb"  . :tar32);;;
	;; Arj::suffixes[]
	("arj"  . :unarj32);
	;; Lha::csuffixes[]
	("lzh"  . :unlha32)
	("lha"  . :unlha32);;;
	("lzs"  . :unlha32);;;
	;; Zip::csuffixes[]
	;; Unzip::esuffixes[]
	("zip"  . :unzip32)
	("jar"  . :unzip32);;;
	;; Cab::csuffixes[]
	("cab"  . :cab32);
	;; Unrar::esuffixes[]
	("rar"  . :unrar32);
	;; Bga::suffixes[]
	("gza"  . :bga32);
	("bza"  . :bga32);
	;; Yz1::suffixes[]
	("yz1"  . :yz1);
	;; UnGCA::esuffixes[]
	("gca"  . :ungca32);
	;; SevenZip::suffixes[]
	("7z"   . :7-zip)
	))

;;; アーカイブ用キャッシュ
(defparameter *plugin-archive-hash*
  (make-hash-table :test 'equalp))
(defparameter *plugin-archive-hash-time*
  (make-hash-table :test 'equalp))

(defun plugin-archive-safe-list-archive (pathname &optional file-name-only)
  (let (lst
		(arc (find-exist-path pathname)))
	(unless (and (setf lst (gethash arc *plugin-archive-hash*))
				 (= (file-write-time arc)
					(gethash arc *plugin-archive-hash-time*)))
	  (when (and (tail-is-slash arc)
				 (member (cdr (assoc (pathname-type pathname)
									 *plugin-archive-type-alist*
									 :test 'equalp))
						 *archiver-dll-list*)
				 (setf lst (let ((lst (handler-case
										  (list-archive pathname t)
										(archiver-error (c) nil)))
								 dir)
							 ; (unless (equal (pathname-type pathname) "zip") ; dllが修正されてる？？
							 (setf lst (mapcar #'map-backslash-to-slash lst))
							 (dolist (item lst)
							   (when (tail-is-not-slash item)
								 (let ((path "")
									   (list (split-string item "/")))
								   (dolist (el (reverse (cdr (reverse list))))
									 (setf path (concat path el "/"))
									 (pushnew path dir :test 'equal))))
							   (pushnew item dir :test 'equal))
							 ; )
							 (or (reverse dir) lst))))
		(setf (gethash arc *plugin-archive-hash*) lst)
		(setf (gethash arc *plugin-archive-hash-time*)
			  (file-write-time arc))))
	lst))

(defun plugin-archive-list (base file)
  (values (plugin-archive-safe-list-archive (concat base file)) :tree))

(defun plugin-archive-load (arc file)
  (find-file-in-archive (remove-trail-slash arc) file)
  (selected-buffer))

(defun plugin-archive-save (archive file nomsg append char-encoding eol-code)
  (let (tmp-dir)
	(unwind-protect
		(let (temp-file)
		  (setf tmp-dir (make-temp-file-name nil nil nil t))
		  (setf temp-file (merge-pathnames file tmp-dir))
		  (unless (valid-path-p temp-file)
			(create-directory (directory-namestring temp-file)))
		  ;; write-file で append t
		  (when append
			(when (and archive file)
			  (extract-archive archive tmp-dir file)
			  (unless (file-exist-p temp-file)
				(error "~a~%なんか知らんけど解凍できませんでした" temp-file))))
		  (write-file temp-file nomsg append char-encoding eol-code)
		  (create-archive archive (list temp-file) tmp-dir)
		  (set-buffer-modified-p nil);;ちゃんと保存できた時だけにしたい
		  )
	  (directory tmp-dir
				 :absolute t :recursive t
				 :callback #'(lambda (f)
							   (if (file-directory-p f)
								   (delete-directory f :if-access-denied :force)
								 (delete-file f :if-access-denied :force))))
	  (delete-directory tmp-dir :if-does-not-exist :skip :if-access-denied :force))))

(regist-virtual-file-handler
 "\\.\\(ish\\|tgz\\|taz\\|gz\\|z\\|tar\\|bz2\\|cpio\\|rpm\\|deb\\|arj\\|lzh\\|lha\\|lzs\\|zip\\|jar\\|cab\\|rar\\|gza\\|bza\\|yz1\\|gca\\|7z\\)/$"
 'plugin-archive-list
 'plugin-archive-load
 'plugin-archive-save
 )

;;; virtual-file-archive.l ends here
