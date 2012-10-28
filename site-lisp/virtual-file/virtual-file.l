;;; -*- mode: lisp -*-
;;; name:     virtual-file
;;; version:  2007.07.09
;;; author:   shiro
;;; depends:  complete+, session-ext
;;; category: Utilities, File Systems
;;; src:      http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fvirtual-file&openfile=
;;; changes:  時間制限付きmemoize関数を追加
;;; files:    site-lisp/virtual-file/virtual-file.l
;;;           site-lisp/virtual-file/virtual-file.lc
;;;           site-lisp/ni-autoload/silog/virtual-file.l

;; Copyright (C) 2006-2007 shiro
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

;;; Commentary:

;; 概要:
;; 
;; 仮想的なファイルの読み込みと保存を行うための仕組みを提供するものです。
;; 単体では機能しません。
;; 
;; virtual-file-archive.lなどをインストールしてください。
;; 

;; 設定:
;; 
;; (require "virtual-file/virtual-file")
;; (virtual-file-bindings)
;; 
;; ;; emacs-write-fileが好みな方用
;; (setf *virtual-file-write-default* 'emacs-write-file)
;; 
;; ;; xyzzy wikiのtips/find-file時にディレクトリが作れるように
;; ;; をwrite-fileでも使う
;; (add-hook '*virtual-file-before-write-hook*
;;           'make-directory-unless-directory-exists)
;; 

;; 履歴:
;; 
;; 2007.07.09
;; - 時間制限付きmemoize関数を追加
;; 
;; 2007.04.24
;; - *virtual-file-before-write-hook* 追加
;; 
;; 2007.04.14
;; - C-x C-wで非virtualなファイルを指定した時に再度指定しないといけなかったのを修正
;; 
;; 2007.03.23
;; - 2重に開かないようにした
;; 
;; 2007.03.08
;; - 配置換え
;; 
;; 2007.03.07
;; - 読み込み・保存の処理をプラグイン化
;; - それに伴い名称を変更し、complete+に依存するようにした
;; 
;; 2007.02.08
;; - 既存の圧縮ファイルの中にファイルを追加/変更する関数auto-compression-mode-write-fileを追加
;; 
;; 2006.12.12
;; - session関係の関数上書きをsession-ext.lに任せるようにした。
;;
;; 2006.10.15
;; - 7zやcabの展開がうまく出来なかったのを修正
;;
;; 2006.08.16
;; - cygwin-mountと仲良く出来るようにした
;;
;; 2006.08.07
;; - アーカイブのパスに正規表現のメタキャラクタが含まれていたら補完出来なかったのを修正
;;
;; 2006.08.02
;; - 初版
;; 

;;; Code:

(provide "virtual-file/virtual-file")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "complete+")
  (require "session-ext"))

(setf (get 'virtual-file-define-load-function 'lisp-indent-hook) '2)

(in-package "complete+")

(export '(virtual-file-write-file
		  virtual-file-bindings
		  *virtual-file-write-default*
		  *virtual-file-before-write-hook*))

(defvar-local *virtual-file-mode* nil)
(pushnew '(*virtual-file-mode* . "Virtual") *minor-mode-alist* :key #'car)

(defun virtual-file-mode (&optional (arg nil sv))
  (interactive "p")
  (ed::toggle-mode '*virtual-file-mode* arg sv)
  (update-mode-line))

(defun virtual-file-mode-on ()
  (interactive)
  (virtual-file-mode t))

(defun virtual-file-separate-file-name (path)
  (labels ((get-path (path)
			 (if (file-exist-p path) path
			   (get-path (directory-namestring
						  (remove-trail-slash path))))))
	(when (stringp path)
	  (setf path (substitute-string path ":" "/" :skip 1))
	  (let* ((base (get-path path))
			 (len (string/= path base)))
		(and (stringp base)
			 len
			 (values base (substring path len)))))))

;;; ------------------------------------------------------------------
;;; library
;;; ------------------------------------------------------------------

;; キャッシュする時間 (default: 300000=5min)
(defvar *virtual-file-default-cache-interval* 300000)

;; 時間制限付きmemoize
;; 
;; memoizeした関数(↓のplugin-pscp-list-memoized)に与える引数がequalの時に
;; キャッシュが働くので、その関数にkeywor引数が付かないように調整すること
#| e.g.
(multiple-value-bind (fn dump)
	(virtual-file-memoize 'plugin-pscp-list-internal *plugin-scp-cache-interval*)
  (setf (symbol-function 'plugin-pscp-list-memoized) fn
		(symbol-function 'virtual-file-plugin-pscp-list-memoized-dump) dump))
|#
(defun virtual-file-memoize (fn &optional (interval *virtual-file-default-cache-interval*))
  (let ((cache (make-hash-table :test #'equal)))
	(values
	 ;; memoized function
	 #'(lambda (&rest args)
		 (multiple-value-bind (val win)
			 (gethash args cache)
		   (cond ((and win (> (+ interval (first val))
							  (get-internal-real-time)))
				  (second val))
				 (t
				  (let ((lst (apply fn args)))
					(setf (gethash args cache)
						  (list (get-internal-real-time) lst))
					lst)))))
	 ;; dump function
	 #'(lambda ()
		 (let ((list nil))
		   (maphash #'(lambda (x y)
						(push (list (apply 'concat x)
									(format nil "~asec"
											(ceiling (- (+ interval (first y))
														(get-internal-real-time))
													 1000))
									(second y))
							  list))
					cache)
		   (format t "~{~S~^~%~}" list)))
	 )))

;;; ------------------------------------------------------------------
;;; load file
;;; ------------------------------------------------------------------

(defun virtual-file-find-file (filename)
  (when (modulep "cygwin-mount");; cygwin-mountと仲良く
	(setf filename (map-backslash-to-slash
					(funcall (intern "cygwin-mount-resolve" "editor")
							 filename))))
  (unless (file-exist-p filename)
	(multiple-value-bind (base file)
		(virtual-file-separate-file-name filename)
	  (let (buf)
		(when (setf buf (get-alternate-file-buffer filename))
		  (message "Old buffer")
		  (return-from virtual-file-find-file buf)))
	  (and base file
		   (let ((h (find-if (lambda (x) (string-match x base))
							 *virtual-file-handlers*
							 :key 'car)))
			 (when h (funcall (caddr h) base file)))))))
(add-hook '*before-find-file-hook* 'virtual-file-find-file)

;;; ------------------------------------------------------------------
;;; write file
;;; ------------------------------------------------------------------

(defun virtual-file-save-file-internal (filename &optional nomsg append
												 (char-encoding (buffer-fileio-encoding))
												 (eol-code (buffer-eol-code)))
  (multiple-value-bind (base file)
	  (virtual-file-separate-file-name filename)
	(and base file
		 (let ((h (find-if (lambda (x) (string-match x base))
							 *virtual-file-handlers*
							 :key 'car)))
		   (when h (funcall (cadddr h) base file nomsg append char-encoding eol-code))))))
(defun virtual-file-save-file ()
  (virtual-file-save-file-internal
   (get-buffer-alternate-file-name (selected-buffer))))
(add-hook '*save-buffer-no-filenames-hook* 'virtual-file-save-file)

;;; ------------------------------------------------------------------
;;; write file
;;; ------------------------------------------------------------------

(defvar *virtual-file-write-default* 'write-file)
(defvar *virtual-file-before-write-hook* nil)
(defun virtual-file-write-file (filename &optional nomsg append
										 (char-encoding (buffer-fileio-encoding))
										 (eol-code (buffer-eol-code)))
  (interactive "FWrite file: "
	:title0 "Write File" :default0 *default-write-file-directory*)
  (let ((r (run-hook-with-args-until-success
			'*virtual-file-before-write-hook* filename)))
	(when r (return-from virtual-file-write-file r)))
  (cond ((and (interactive-p)
			  (valid-path-p filename))
		 (funcall *virtual-file-write-default* filename))
		;; write-file の関数呼び出し
		((and (valid-path-p filename)
			  (eq *virtual-file-write-default* 'write-file))
		 (write-file filename nomsg append char-encoding eol-code))
		;; emacs-write-file の関数呼び出し
		((and (valid-path-p filename)
			  (eq *virtual-file-write-default* 'emacs-write-file))
		 (emacs-write-file filename))
		;; funcallを使って引数を渡すわけにもいかないのでとりあえずエラーに。
		((valid-path-p filename)
		 (error "普通の ~a を使ってください" *virtual-file-write-default*))
		(t
		 (save-restriction
		   (setq filename (namestring filename))
		   (widen)
		   (virtual-file-save-file-internal filename nomsg append char-encoding eol-code)
		   (unless nomsg
			 (message "Wrote ~a" filename)))))
  t)

;;; ------------------------------------------------------------------
;;; session
;;; ------------------------------------------------------------------

(defun virtual-file-add-session (buffer)
  (save-excursion
	(set-buffer buffer)
	*virtual-file-mode*))
(add-hook '*before-save-session* 'virtual-file-add-session)
(add-hook '*before-restore-session* 'virtual-file-separate-file-name)

(defun virtual-file-bindings ()
  (global-set-key '(#\C-x #\C-w) 'virtual-file-write-file))


;;; virtual-file.l ends here
