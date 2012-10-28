;;; -*- Mode: Lisp; Last modified: <2007/12/31 01:15:06> -*-
;;;
;;; This file is not part of xyzzy.
;;;
;;;   du-d.l --- ディレクトリ毎のサイズを出力
;;;
;;;     by HIE Masahiro <madoinu@ybb.ne.jp>
#|

■概要

  OHKUBO Hiroshi さんの insert-directory-tree.l を参考に、ディレク
  トリ毎のサイズを出力するものをつくってみた。


■インストール

  1. du-d.l を site-lisp にコピーする。

  2. 必要に応じ、バイトコンパイルする。

       M-x byte-compile-file

  3. .xyzzy か siteinit.l に以下の記述を追加する。

      (load-library "du-d")


■使い方

  ・指定ディレクトリ以下の各ディレクトリのサイズを出力

      M-x dud

  ・指定ディレクトリ以下の各ディレクトリとファイルのサイズを出力

      M-x dud-all

  ・指定ディレクトリ以下の各ディレクトリのサイズをツリー形式で出力

      M-x dud-tree

  ・指定ディレクトリ以下の各ディレクトリとファイルのサイズをツリー形式で出力

      M-x dud-tree-all


■更新履歴

  [Version 1.01] 2007-12-31 (月)
  ・ライセンス条項(MITライセンス)を記載。

  [Version 1.00] 2002/12/16 (月)
  ・つくった。


■ライセンス

  du-d.l はMITライセンスに基づいて利用可能です。
  <http://www.opensource.org/licenses/mit-license.php>

Copyright (c) 2002-2007 HIE Masahiro

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

(provide "du-d")

(defun dud (&optional dir tree all)
  (interactive)
  (when (not dir)
    (setq dir
	  (read-directory-name "Dir: "
			       :default (if (get-buffer-file-name)
					    (directory-namestring (get-buffer-file-name))
					  (si:system-root)))))
  (message "データを取得しています．．．")
  (long-operation
    (unless (file-directory-p dir)
      (return-from dud nil))
    (let* ((bname "*dud*")
	   (buf (progn (when (find-buffer bname)
			 (delete-buffer bname))
		  (get-buffer-create bname))))
      (set-buffer buf)
      (setq need-not-save t)
      (setq dir (append-trail-slash (map-backslash-to-slash dir)))
      (if tree
	  (progn
	    (insert (format nil "~A [~:D]~%" dir (dud-dir-size dir)))
	    (dud-expansion dir "" t all))
	(progn
	  (insert (format nil "~D	~A~%" (dud-dir-size dir) dir))
	  (dud-expansion dir "" nil all)))
      (set-buffer-modified-p nil)))
  (goto-char (point-min))
  (message "done."))

(defun dud-expansion (base-dir &optional (bstr "") tree all)
  (let (file-list dir-list last-file last-dir)
    (dolist (file (directory base-dir :absolute t))
      (if (string-match "/$" file)
	  (push (string-right-trim "/" file) dir-list)
	(when all (push file file-list))))
    (setq dir-list (stable-sort dir-list #'string-lessp))
    (setq last-dir (car (last dir-list)))
    (when all
      (setq file-list (stable-sort file-list #'string-lessp))
      (setq last-file (car (last file-list)))
      (dolist (file file-list)
	(let ((f (file-namestring file))
	      (flen (file-length file)))
	  (if tree
	      (if (and (eq file last-file) (not dir-list))
		  (insert (format nil "~A~A ~A --- [~:D]~%" bstr "└" f flen))
		(insert (format nil "~A~A ~A --- [~:D]~%" bstr "├" f flen)))
	    (insert (format nil "~D	~A~%" flen file))))))
    (dolist (dir dir-list)
      (message "scaning ~A ..." dir)
      (let ((d (substitute-string dir (directory-namestring dir) ""))
	    (dsize (dud-dir-size dir)))
	(if tree
	    (progn
	      (insert (format nil "~A~A~%" bstr "｜"))
	      (if (eq dir last-dir)
		  (progn
		    (insert (format nil "~A~A ~A/ [~:D]~%" bstr "└" d dsize))
		    (dud-expansion dir (concat bstr "   ") t all))
		(progn
		  (insert (format nil "~A~A ~A/ [~:D]~%" bstr "├" d dsize))
		  (dud-expansion dir (concat bstr "｜ ") t all))))
	  (progn
	    (insert (format nil "~D	~A/~%" dsize dir))
	    (dud-expansion dir nil nil all)))))))

(defun dud-dir-size (dir)
  (let (dir-list (total-size  0))
    (setq dir-list (directory dir
			      :wile "*.*"
			      :absolute t
			      :file-only t
			      :recursive t
			      :show-dots t))
    (dolist (f dir-list)
      (setq total-size (+ total-size (file-length f))))
    total-size))

(defun dud-all (&optional dir)
  (interactive)
  (dud dir nil t))

(defun dud-tree (&optional dir)
  (interactive)
  (dud dir t))

(defun dud-tree-all (&optional dir)
  (interactive)
  (dud dir t t))


;;; du-d.l ends here.
