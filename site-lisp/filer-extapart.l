;;; -*- Mode: Lisp; Last modified: <2007/12/31 01:15:25> -*-
;;;
;;; This file is not part of xyzzy.
;;;
;;;   filer-extapart.l
;;;
;;;     by HIE Masahiro <madoinu@ybb.ne.jp>
#|

■概要

  ファイラからアーカイブ中のファイルを指定して展開します。

  ディレクトリを再構築しないで展開する場合、現在対応している形式
  は、lha, zip, cab, tar の 4 つです。ディレクトリを再構築しなが
  ら展開する場合は、xyzzy の機能をそのまま使っているので、xyzzy
  が対応している形式ならば何でもよいと思います。

  ディレクトリの選択には、nonentity さん
    http://members.tripod.co.jp/zauberer/microtips/xyzzy.html
  の、 select_directory.dll 使わせて頂いています。
  無くても動作しますが、あったほうが便利と思います。

  また、filer.l のコードもたくさん使わせて頂いてます。
  さらに、xyzzy Part7 678 のコードも参考にさせていただきました。


■インストール

  1. filer-extapart.l を site-lisp にコピーする。

  2. 必要に応じ、バイトコンパイルする。

       M-x byte-compile-file

  3. .xyzzy か siteinit.l に以下の記述を追加する。

      (load-library "filer-extapart")


■使い方

  ・M-e: 展開するディレクトリを指定して展開

  ・C-e: 既定のディレクトリに展開


■設定例

  ・select_directory.dll がない場合
  (setq *extapart-use-select_directory* nil)

  ・展開するディレクトリの既定値を変更
  (setq *extapart-base-dir* "c:/tmp")

  ・展開するディレクトリ確認時に既定のディレクトリを開く
  (setq *extapart-use-base-dir* t)

  ・ファイルを展開した後展開したディレクトリを開かない
  (setq *extapart-open-filer-after-extract* nil)


■更新履歴

  [Version 1.01] 2007-12-31 (月)
  ・ライセンス条項(MITライセンス)を記載。

  [Version 1.00] 2003/05/02 (金)
  ・つくった。


■ライセンス

  filer-extapart.l はMITライセンスに基づいて利用可能です。
  <http://www.opensource.org/licenses/mit-license.php>

Copyright (c) 2003-2007 HIE Masahiro

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

|#

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "wip/winapi"))

;;; winapi ;;;
(in-package "winapi")

(*define-dll-entry int Unlha (HWND LPCSTR LPSTR DWORD) "unlha32" "Unlha")
(*define-dll-entry int Tar   (HWND LPCSTR LPSTR DWORD) "tar32"   "Tar"  )
(*define-dll-entry int UnZip (HWND LPCSTR LPSTR DWORD) "unzip32" "UnZip")
(*define-dll-entry int Cab   (HWND LPCSTR LPSTR DWORD) "cab32"   "Cab"  )

(*define-dll-entry BOOL SelectDirectory (HWND LPCSTR LPCSTR LPSTR)
		   "select_directory" "SelectDirectory")

;;; user ;;;
(in-package "user")

(defun extapart-archiver (func cmd)
  (let* ((maxlen 10240)
	 (text (si:make-chunk nil maxlen)))
    (funcall func
	     (get-window-handle)
	     (si:make-string-chunk cmd)
	     text
	     maxlen)
    (si:unpack-string text 0)))

(defun extapart-lha   (cmd) (extapart-archiver #'winapi:Unlha cmd))
(defun extapart-tar   (cmd) (extapart-archiver #'winapi:Tar   cmd))
(defun extapart-unzip (cmd) (extapart-archiver #'winapi:UnZip cmd))
(defun extapart-cab   (cmd) (extapart-archiver #'winapi:Cab   cmd))

(defun extapart-select-directory-dialog (&optional title dir)
  (let ((result (si:make-chunk nil 256))
	(d (if dir dir
	     (default-directory)))
	(s (if title title
	     "フォルダの選択")))
    (si:pack-string result 0
		    (map-slash-to-backslash
		     (remove-trail-slash d)))
    (if (= 1 (winapi:SelectDirectory (winapi:FindWindow
				      (si:make-string-chunk "#32770")
				      (si:make-string-chunk d))
				     (si:make-string-chunk s)
				     0
				     result))
	(map-backslash-to-slash (si:unpack-string result 0))
      nil)))


(defvar *extapart-base-dir* (map-backslash-to-slash
			   (get-special-folder-location :desktop)))
(defvar *extapart-use-base-dir* nil)
(defvar *extapart-open-filer-after-extract* t)
(defvar *extapart-use-select_directory* t)

(defun extract-archive-apart (&optional arg)
  (let* ((file (ed::filer-fetch-file t))
	 (todir *extapart-base-dir*)
	 (bdir (if *extapart-use-base-dir*
		   todir
		 (filer-get-directory)))
	 usedir newdir)
    (unless todir
      (setq arg t))
    (when file
      (multiple-value-bind (result data1)
	  (dialog-box
	   `(dialog 0 0 273 237
		    (:caption ,(concat "[" (file-namestring file)
				       "] : 展開するファイルの選択"))
		    (:font 9 "ＭＳ Ｐゴシック")
		    (:control
		     (:listbox list nil #x50b10911 7 7 259 202)
		     (:button IDOK "展開" #x50010001 158 216 50 14)
		     (:button IDCANCEL "ｷｬﾝｾﾙ" #x50010000 216 216 50 14)))
	   (list (cons 'list
		       (long-operation
			 (mapcar #'(lambda (x)
				     (list (cadr x)
					   (format nil "~d" (caddr x))
					   (apply #'format
						  nil "~d/~2,'0d/~2,'0d ~2,'0d:~2,'0d"
						  (cadddr x))
					   (car x)))
				 (list-archive file)))))
	   '((list :column (6 -10 18 100) :must-match t :enable (IDOK))))
	(when result
	  (when arg
	    (setq todir (if *extapart-use-select_directory*
			    (extapart-select-directory-dialog
			     "展開するディレクトリを指定して下さい。"
			     bdir)
			  (directory-name-dialog :title   "展開するディレクトリ"
						 :default bdir))))
	  (when todir
	    (multiple-value-bind (result data2)
		(dialog-box '(dialog 0 0 231 87
			      (:caption "extapart")
			      (:font 9 "ＭＳ Ｐゴシック")
			      (:control
			       (:static IDC_STATIC "ﾃﾞｨﾚｸﾄﾘ作成(&N):" #x50020000 7 38 60 8)
			       (:edit newdir nil #x50810080 7 47 162 14)
			       (:button usedir "ﾃﾞｨﾚｸﾄﾘ付で展開(&M)" #x50010003 7 70 87 10)
			       (:button IDOK "OK" #x50010001 174 7 50 14)
			       (:button IDCANCEL "ｷｬﾝｾﾙ" #x50010000 174 24 50 14)
			       (:static IDC_STATIC "展開先(&C):" #x50020000 7 7 50 8)
			       (:edit todir nil #x50810880 7 16 162 14)))
			    (list (cons 'todir todir)
				  '(usedir . t))
			    nil)
	      (when result
		(setq newdir (cdr (assoc 'newdir data2)))
		(setq usedir (cdr (assoc 'usedir data2)))
		(when (< 0 (length newdir))
		  (setq todir (merge-pathnames newdir todir))
		  (create-directory todir))
		(multiple-value-bind (cmd opt)
		    (extapart-select-archiver file)
		  (mapc #'(lambda (f)
			    (let ((efile (nth 3 f)))
			      (if usedir
				  (extract-archive file todir efile)
				(when cmd
				  (funcall cmd (concat opt
						       " \"" file "\""
						       " \"" (append-trail-slash todir) "\""
						       " \"" efile "\""
						       ))))))
			(cdr (assoc 'list data1))))
		(when *extapart-open-filer-after-extract*
		  (filer-set-directory todir)
		  (filer-reload nil t)
		  (filer-reload nil nil)
		  )))))))))

(defun extapart-select-archiver (file)
  (cond ((string-matchp "\\.zip$" file) (values #'extapart-unzip "-u -j -o"))
	((string-matchp "\\.cab$" file) (values #'extapart-cab   "-x -i -j -n"))
	((string-matchp (concat "\\(\\.tar"
				"\\|\\.tar\\.gz"
				"\\|\\.tar\\.bz2"
				"\\|\\.tar\\.Z"
				"\\|\\.tgz"
				"\\|\\.tbz"
				"\\|\\.taz\\)$")
			file)
	 (values #'extapart-tar "--check-all-path=1 --use-directory=0 -xfo"))
	;((string-matchp "\\.bza$" file) (values nil ""))
	;((string-matchp "\\.gza$" file) (values nil ""))
	;((string-matchp "\\.yz1$" file) (values nil ""))
	;((string-matchp "\\.7z$"  file)  (values nil ""))
	(t (values #'extapart-lha "e -a1m1n1x0p1jf0"))))


(define-key filer-keymap #\C-e 'extract-archive-apart)
(define-key filer-keymap #\M-e #'(lambda () (extract-archive-apart t)))


;;; filer-extapart.l ends here.
