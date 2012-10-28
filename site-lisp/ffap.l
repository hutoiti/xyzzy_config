;;; -*- mode: lisp -*-
;;; name:     ffap
;;; version:  2007.10.19
;;; author:   shiro
;;; category: Utilities
;;; src:      http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fffap&openfile=
;;; changes:  virtual-fileからfind-fileした場合の初期ディレクトリをまともにした
;;; files:    site-lisp/ffap.l
;;;           site-lisp/ffap.lc
;;;           site-lisp/ni-autoload/silog/ffap.l

;; Copyright (C) 2001-2005 OHKUBO Hiroshi.
;; Copyright (C) 2006-2007 snj14
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
;;   emacsにあるffapの説明(http://www.bookshelf.jp/soft/meadow_23.html#SEC226)
;;   をみて想像で実装したものです。
;;   コードは参考にしていないのでバグや機能不足があるかもしれません。
;;
;;   カーソル位置周辺の文字を見てパスやURIを探し、
;;   パスの場合、デフォルトの値に指定した状態でfind-fileします。
;;   URIの場合、ブラウザ等で開きます。(設定可)
;;   カーソル位置周辺から探せなかった場合は、
;;   以前と変わらぬfind-fileをお楽しみ頂けます。
;;
;;   要するに (require "ffap") や <a href="../index.html">
;;   等の上でC-x C-fしたときにミニバッファが
;;   Find file: c:/bin/xyzzy/site-lisp/ffap.l
;;   や
;;   Find file: c:/data/web/index.html
;;   という状態でfind-fileを開始できるようになります。
;;
;;   カーソル周辺のファイル名の親ディレクトリをアクティブな側、
;;   またはアクティブでない側のパスにして2画面ファイラを開く機能もあります。

;; 設定:
;;
;; NetInstallerで導入した方は 1 は不要です
;; (ni-autoload)している方は 2 の1行目は不要です
;;
;;   1 $XYZZY/site-lisp/ 以下にコピーし、
;;     バイトコンパイルしてください
;;   2 .xyzzy や siteinit.l に以下を記述し、
;;     siteinit.lに記述した方は再ダンプしてください。
;;
;;   (require "ffap")
;;   (ffap-bindings)

;; 使い方:
;;
;; find-file-at-point :
;;
;;   通常通りfind-file(デフォルトはC-x C-f)してください
;;   以前のfind-file同様、C-u C-x C-fでエンコードを指定出来ます
;;   ffapがパスを探せず、困った時はセレクションで選択してC-x C-fしてください
;;   URIが見つかった場合は関連付けに従って開こうとします
;;
;; open-filer-at-point :
;;
;;   通常通りopen-filer(デフォルトはC-c C-f)してください
;;   アクティブな側のパスを変更してファイラを開く
;;      C-u C-c C-f
;;   アクティブでない側のパスを変更してファイラ開く
;;      C-u C-u C-c C-f

;; 履歴:
;; 
;; 2007.10.19
;; - virtual-fileからfind-fileした場合の初期ディレクトリをまともにした
;; 
;; 2007.02.22
;; - キャレット付近に空白があるときにopen-filer-at-pointするとエラーが出たのを修正
;; 
;; 2007.02.19
;; - uriのヒストリを取るようにした
;; 
;; 2007.02.13
;; - find-other-file-at-point, insert-file-at-point, read-file-at-pointを追加
;; - 全てのキー割り当てをする関数 ffap-bindings を追加
;; 
;; 2007.02.08
;; - open-filer-at-pointでバッファ上の文字がパスでない場合はdefault-directoryを使うようにした
;; 
;; 2006.10.08
;; - バッファ上の文字を考慮してファイラを開く機能を追加
;;
;; 2006.10.05
;; - 1画面ファイラを開いた時に複数のファイルが選べなくなっていたのを修正
;;
;; 2006.05.10
;; - 初版

;; 謝辞:
;;
;;   作成にあたり、clickable-uriを参考にさせていただきました。
;;   作者のOHKUBO Hiroshiさんに感謝いたします。

;;; Code:

(provide "ffap")

(in-package "editor")

(export '(*ffap-uri-open-command-alist*
		  *ffap-uri-chars*
		  *ffap-extension-alist*
		  *ffap-path-alist*
		  *ffap-uri-modify-uri-alist*
		  *ffap-default-extension*
		  find-file-at-point
		  open-filer-at-point
		  find-other-file-at-point
		  insert-file-at-point
		  read-file-at-point
		  ffap-bindings))

;;; URIを開く設定
;;; 設定無し       : 関連付け実行
;;; 文字列         : コマンドラインとみなして実行する
;;;                : URIを記述するべき場所に~Aと記述
;;; lambda式       : lambda式にURIを引数として渡して評価する
;;; 関数のシンボル : 関数    に      〃
;;;
;;; 例
;;; (push '("^https?:" . "C:/bin/FireFox/FireFox.exe ~A")
;;;       *ffap-uri-open-command-alist*)
(defvar *ffap-uri-open-command-alist*
  '((#'(lambda (uri) (string-matchp "^file:.+\\.l$" uri)) .
	 #'find-file)
	))

;;; URI正規表現 (てきとー)
(defvar *ffap-uri-regexp*
  "\\(h?t?tps?\\|ftp\\|telnet\\|gopher\\|www\\|wais\\|file\\|mailto\\):[-a-zA-Z0-9_/~.@?&=;+(),'$!*:#%|]+")

;;; メールアドレス正規表現
(defvar *ffap-uri-mail-address-regexp*
  "[-a-zA-Z0-9_.]+@[-a-zA-Z0-9_]+\\(?:\\.[-a-zA-Z0-9_]+\\)+")

;;; URI構成文字列
;;; skip-chars-forward,skip-chars-backwardで使用
(defvar *ffap-uri-chars* "-a-zA-Z0-9_/\\~.@?&=;+(),'$!*:#%| ")

;;; URI補正関数 連想リスト
(defvar *ffap-uri-modify-uri-alist*
  '((#'ffap-uri-uri-mail-address-p  . #'(lambda (uri) (concat "mailto:" uri)))
	("^ttp:" . #'(lambda (uri) (concat "h"  uri)))
	("^tp:"  . #'(lambda (uri) (concat "ht" uri)))
	("^file://"  . #'(lambda (uri) (substring uri 7)))
	))

;;; モードと拡張子の設定
;;; (require "hoge") 等、拡張子の無い文字列からファイルを探す場合の拡張子を正規表現でモード毎に指定します。
;;; 通常は *auto-mode-alist* から拡張子を取得しますが、
;;; *auto-mode-alist*に設定されていないモードはこれに追加してください。
;;; *auto-mode-alist*にもここにも設定されていないモードの場合は環境変数PATHEXTから拡張子を取得します。
(defvar *ffap-extension-alist*
  '((lisp-interaction-mode . "\\.l$")))

;;; モードとパスの設定
;;; 検索するパスをモード毎に変更する場合はここで指定します。
;;; 検索は以下の4つで指定されたパスを全て使って行います。
;;;  1 モード毎に設定されたパス
;;;  2 デフォルトのパス*ffap-default-path*
;;;  3 バッファが作業しているディレクトリ = (default-directory)の返す値
;;;  4 開いているファイルの親ディレクトリ(バッファがファイルの場合)
;;; なお、末尾の/や\\の有無は問いません。
;;;
;;; 例
;;; ;py-modeでの検索パスにclnchex,script,extensionを追加する
;;; (push '(py-mode "c:/bin/clnchex/" "c:/bin/clnchex/script" "c:/bin/clnchex/extension")
;;;       *ffap-path-alist*)
(defvar *ffap-path-alist*
  (list (append (list 'lisp-mode) *load-path*)
		(append (list 'lisp-interaction-mode) *load-path*)))

;; デフォルトの拡張子
;; >> "\\.\\(COM\\|EXE\\|BAT\\|CMD\\|VBS\\|VBE\\|JS\\|JSE\\|WSF\\|WSH\\)$"
(defvar *ffap-default-extension*
  (concat "\\.\\("
		  (substitute-string (substitute-string
							  (si:getenv "PATHEXT")
							  "\\." "")
							 ";" "\\\\|")
		  "\\)$"))

;; デフォルトのパス
(defvar *ffap-default-path*
  (append ;xyzzyのインストールディレクトリ
   (list (si:system-root))
   ;環境変数 PATH
   (mapcar 'map-backslash-to-slash
		   (split-string (si:getenv "PATH") ";"))
   ;Windows (あってるか自信ない)
   (mapcar 'map-backslash-to-slash
		   (split-string (si:getenv "WINDIR") ";"))
   ;Home
   (mapcar 'map-backslash-to-slash
		   (split-string (si:getenv "HOME") ";"))
   ;XyzzyHome
   (mapcar 'map-backslash-to-slash
		   (split-string (si:getenv "XYZZYHOME") ";"))))

;; history
(defvar *ffap-uri-history* nil)
(setf (get '*ffap-uri-history* 'minibuffer-history-variable)
      '*ffap-uri-history*)
(register-history-variable '(*ffap-uri-history*))

(defun ffap-uri-uri-mail-address-p (uri)
  (and (stringp *ffap-uri-mail-address-regexp*)
	   (string-matchp (concat "^" *ffap-uri-mail-address-regexp* "$") uri)))

(defun ffap-get-extension-from-auto-mode-alist (mode)
  "*auto-mode-alist*とモード名から拡張子を取得"
  (let ((list (apply 'append
					 (mapcar #'(lambda (x)
								 (when (eq (cdr x) mode)
								   (list (car x))))
							 *auto-mode-alist*))))
	(when list
	  (format nil "\\(~A)" (string-right-trim "|" (format nil "~{~A\\|~}" list))))))

(defun ffap-get-path-and-extension (&optional buffer)
  "bufferのモード名から検索するパスと拡張子を得る"
  (let ((mode buffer-mode))
	(when buffer
	  (save-excursion
		(set-buffer buffer)
		(setf mode buffer-mode)))
	(values (remove-duplicates
			 (append (cdr (assoc mode *ffap-path-alist*))
					 (list (default-directory)) ;作業ディレクトリ
					 (let ((cur (get-buffer-file-name))) ;開いてるファイルの親ディレクトリ
					   (when cur (list (map-backslash-to-slash
										(directory-namestring cur)))))
					 *ffap-default-path*)
			 :test 'equalp)
			(or (cdr (assoc mode *ffap-extension-alist*))
				(ffap-get-extension-from-auto-mode-alist mode)
				*ffap-default-extension*))))

;; (ffap-locate "grep.l")
;; >> ("C:/bin/xyzzy/lisp/grep.l")
;; (ffap-locate "grep.exe")
;; >> ("c:/cygwin/bin/grep.exe")
(defun ffap-locate (file)
  "ファイル名からフルパスを探す"
  (when (string= file "")
	(return-from ffap-locate))
  (let (path-list extension res)
	(multiple-value-setq (path-list extension)
	  (ffap-get-path-and-extension))
	(setf res
		  (some #'(lambda (path)
					(when (file-exist-p path) path))
				(mapcar #'(lambda (dir)
							(merge-pathnames file dir))
						path-list)))
	(and res (not (file-directory-p res))
		 res)))

;; (ffap-locate-approx "lisp/grep")
;; >> "C:/bin/xyzzy/lisp/grep.l"
(defun ffap-locate-approx (file)
  "ファイル名(拡張子なし)からフルパスを探す"
  (when (string= file "")
	(return-from ffap-locate-approx))
  (let (path-list extension res)
	(multiple-value-setq (path-list extension)
	  (ffap-get-path-and-extension))
	(setf res
		  (some #'(lambda (path)
					(when (string-matchp
						   (concat "[\\/]" (regexp-quote file) extension)
						   path)
					  path))
				(apply 'append
					   (mapcar #'(lambda (dir)
								   (directory (directory-namestring
											   (merge-pathnames file dir))
											  :absolute t))
							   path-list))))
	(and res (not (file-directory-p res))
		 res)))

(defun ffap-get-uri (str)
  (and (string-matchp *ffap-uri-regexp* str)
	   (match-string 0)))

(defun ffap-get-mail-address (str)
  (and (string-matchp *ffap-uri-mail-address-regexp* str)
	   (match-string 0)))

(defun ffap-get-region ()
  "リージョンが一行なら文字列を返す"
  (let ((ptline (current-line-number))
		mkline)
	(save-excursion
	  (and (mark t)
		   (goto-char (mark))
		   (setf mkline (current-line-number))))
	(when (eq ptline mkline)
	  (buffer-substring (point) (mark)))))

(defun ffap-get-current-string-regexp ()
  (let ((pt (point)) string
		(region (ffap-get-region)))
	(save-excursion
	  (and (stringp region)
		   (> (mark) pt)
		   (goto-char (mark)))
	  (and (scan-buffer *ffap-uri-regexp* :regexp t :reverse t
						:limit (or (and region (> (mark) pt) pt)
								   (and region (< (mark) pt) (mark))
								   (save-excursion (goto-bol) (point))))
		   (< (match-beginning 0) pt)
		   (<= pt (match-end 0))
		   (setf string (match-string 0);(buffer-substring (match-beginning 0) pt)
				 )
		   (string-match *ffap-uri-regexp* string)
		   string))))

(defun ffap-get-current-string-uri-chars ()
  "*ffap-uri-chars*を見て文字を取得"
  (save-excursion
	(unless (pre-selection-p)
	  (skip-chars-forward *ffap-uri-chars*)
	  (ed::begin-selection)
	  (skip-chars-backward *ffap-uri-chars*))
	(selection-start-end (start end)
	  (buffer-substring start end))))

(defun ffap-get-current-string-syntax ()
  "シンタックステーブルを見て文字を取得"
  (save-excursion
	(unless (pre-selection-p)
	  (skip-syntax-spec-forward "w_.\\")
	  (ed::begin-selection)
	  (skip-syntax-spec-backward "w_.\\"))
	(selection-start-end (start end)
	  (buffer-substring start end))))

(defun ffap-correct-uri (uri)
  (when uri
	(let ((modify-func
		   (eval (cdr (assoc uri *ffap-uri-modify-uri-alist*
							 :test #'(lambda (uri checker)
									   (setf checker (eval checker))
									   (or (and (or (regexpp checker) (stringp checker))
												(string-matchp checker uri))
										   (and (functionp checker) (funcall checker uri)))))))))
	  (if modify-func
		  (funcall modify-func uri)
		uri))))

(defvar *ffap-find-uri* t)

(defun ffap-get-path ()
  (let ((str (substitute-string
			  (ffap-get-current-string-syntax)
			  "\\\\\\\\" "\\\\")); パスの区切りが\\の時にこの値が"\\\\"となる対策
		(str1 (substitute-string
			   (ffap-get-current-string-uri-chars)
			   "\\\\\\\\" "\\\\")))
	(ffap-correct-uri
	 (or (and (not (string= str "")) (file-exist-p str) str)
		 (and (not (string= str1 "")) (file-exist-p str1) str1)
		 (ffap-locate str)
		 (ffap-locate-approx str)
		 (when *ffap-find-uri*
		   (ffap-get-uri str))
		 (ffap-get-mail-address str)
		 
		 (ffap-locate str1)
		 (ffap-locate-approx str1)
		 (when *ffap-find-uri*
		   (ffap-get-uri str1))
		 (ffap-get-mail-address str1)))))

(defun ffap-open-uri (uri)
  (when (and uri
			 (string-matchp *ffap-uri-regexp* uri)
			 (setf uri (read-string "URI: " :default (match-string 0)
									:history '*ffap-uri-history*))
			 (not (string= uri "")))
	(let ((cmd (cdr (assoc uri *ffap-uri-open-command-alist*
						   :test #'(lambda (uri checker)
									 (setf checker (eval checker))
									 (or (and (or (regexpp checker) (stringp checker))
											  (string-matchp checker uri))
										 (and (functionp checker) (funcall checker uri))))))))
	  (cond ((consp cmd)
			 (funcall (eval cmd) uri))
			((functionp cmd)
			 (funcall (symbol-function cmd) uri))
			((stringp cmd)
			 (call-process
			  (format nil (map-slash-to-backslash cmd) uri)
			  :wait nil))
			(t (shell-execute uri t))
			))))

(defun ffap-get-truename (path)
  (when path
	(let ((file (string-match "^file://" path)))
	  (setf path (truename path))
	  (and (file-directory-p path)
		   (not (string-match "/$" path))
		   (setf path (concat path "/")))
	  (if file
		  (concat "file://" path)
		path))))


;; virtual file ?
(defun ffap-check-virtual-file ()
  (when (find-package "complete+")
	(eval (intern "*virtual-file-mode*" "complete+"))))
;; virtual-file-archive (C:/archive/hoge.zip:moge -> C:/archive/hoge.zip/moge )
(defun ffap-virtual-file-archive-convert (file)
  (if (= 2 (count #\: file))
	  (substitute #\/ #\: file :from-end t :count 1)
	file))

(defun find-file-at-point ()
  (interactive)
  (let ((path (ffap-get-path)))
	(or (ffap-open-uri path)
		(find-file (read-file-name-list "Find-file: "
										:default (if (ffap-check-virtual-file)
													 (directory-namestring
													  (ffap-virtual-file-archive-convert
													   (get-buffer-alternate-file-name)))
												   (ffap-get-truename path)))
				   (when *prefix-args*
					 (read-char-encoding "Encoding: "))))))

(defun find-other-file-at-point (filename &optional encoding nomsg)
  (interactive "FFind other file: \n0zEncoding: "
	:title0 "Find other file"
	:default0 (or (let ((*ffap-find-uri* nil))
					(ffap-get-path))
				  (cond ((ffap-check-virtual-file)
						 (let ((p (get-buffer-alternate-file-name)))
						   (if *find-other-file-requires-file-name*
							   (ffap-virtual-file-archive-convert p)
							 (directory-namestring p))))
						(*find-other-file-requires-file-name*
						 (get-buffer-file-name)))))
  (find-other-file filename encoding nomsg))

(defun insert-file-at-point (filename &optional encoding)
  (interactive "*fInsert file: \n0zEncoding: "
	:title0 "Insert file"
	:default0 (let ((*ffap-find-uri* nil))
				(ffap-get-path)))
  (insert-file filename encoding))

(defun read-file-at-point (filename &optional encoding nomsg)
  (interactive "fRead file: \n0zEncoding: "
	:title0 "Read file"
	:default0 (let ((*ffap-find-uri* nil))
				(ffap-get-path)))
  (read-file filename encoding nomsg))

(defun open-filer-at-point-current-window (path)
  (let ((*filer-primary-directory* path))
	(open-filer)))

(defun open-filer-at-point-other-window (path)
  (let ((*filer-secondary-directory* path))
	(open-filer)))

(defun open-filer-at-point ()
  (interactive)
  (cond (*prefix-args*
		 (let ((path (ffap-get-path))
			   (dir (default-directory)))
		   (cond ((and path
					   (not (string= path ""))
					   (not (string-match "^ *$" path))
					   (valid-path-p path))
				  (when (and (not (file-directory-p path)))
					(setf path (directory-namestring path)))
				  (cond ((> *prefix-value* 4)
						 (open-filer-at-point-other-window path))
						(t
						 (open-filer-at-point-current-window path))))
				 (t
				  (cond ((> *prefix-value* 4)
						 (open-filer-at-point-other-window dir))
						(t
						 (open-filer-at-point-current-window dir)))))))
		(t
		 (open-filer))))

(defun ffap-bindings ()
  "[C-x C-f], [C-c C-f], [C-x C-v], [C-x i], [C-x C-r]にffap用の関数を割り当てます"
  (global-set-key '(#\C-x #\C-f) 'find-file-at-point)
  (global-set-key '(#\C-c #\C-f) 'open-filer-at-point)
  (global-set-key '(#\C-x #\C-v) 'find-other-file-at-point)
  (global-set-key '(#\C-x #\i)   'insert-file-at-point)
  (global-set-key '(#\C-x #\C-r) 'read-file-at-point))

;;; ffap.l ends here
