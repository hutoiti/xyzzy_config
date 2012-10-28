;; colorprint.l
;;
;; Copyright (c) 2003 kazu.y <samba@pal.tok2.com>
;;
;; ■ 概要
;;   OHKUBOさんのbuf2htmlを利用してxyzzyでカラー印刷します。
;;
;; ■ 使い方
;;  OHKUBOさんのbuf2htmlをインストールします。
;;    http://members.at.infoseek.co.jp/ohkubo/index.html
;;  site-lispフォルダにcolorprint.lを置き、
;;  .xyzzy や siteinit.l に以下のコードを追加します。
;;
;;     ; colorprint
;;     (setf *temp-html-file-path* "c:/colorprint.html")
;;     (require "colorprint")
;;
;;  M-x color-print でカラー印刷できるようにになります。
;;
;; ■ 注意
;;  実行中、*temp-html-file-path*で指定したhtmlファイルと、
;;  *temp-html-file-path*と同じフォルダにxyzzy.cssを
;;  生成します。すでに同名のファイルがある場合
;;  上書きされてしまうので注意してください。
;;
;; ■ 履歴
;;  2004/01/02 ver.1.01公開
;;    oleモジュールをrequireしておらず、一部の環境で動かなかった問題を修正。
;;    ieオブジェクトがいつまでもメモリに残ってしまっていた問題を修正。
;;
;;  2003/12/05 ver.1公開
;;


(require "ole")

(defvar *temp-html-file-path* "d:/colorprint.html")
(defvar *print-line-number* nil)
(defvar *print-dialog-title* "印刷")

(defun make-html (html-path &optional (line-number-p nil))
  (long-operation
    (let ((css-path (merge-pathnames "xyzzy.css" (directory-namestring html-path))))
      (delete-file css-path :if-does-not-exist :skip)
      (ini2css-file (or (and (let ((name (merge-pathnames "xyzzy.ini"
                                                          (user-config-path))))
                               (file-exist-p name) name))
                        ""))
      (set-buffer (find-buffer "*buf2html: CSS*"))
      (rename css-path)
      (save-buffer)
      (delete-buffer (selected-buffer))
      (delete-file html-path :if-does-not-exist :skip)
      (buf2html line-number-p)
      (set-buffer (find-buffer "*buf2html: HTML*"))
      (rename html-path)
      (save-buffer)
      (delete-buffer (selected-buffer)))))

(defun print-html (html-path)
  (let ((ie (ole-create-object "InternetExplorer.Application")))
    #{ie.navigate[html-path]}
    #{ie.document.parentWindow.print}))

(defun color-print ()
  "カラー印刷する"
  (interactive)
  (make-html *temp-html-file-path* *print-line-number*)
  (print-html *temp-html-file-path*))
