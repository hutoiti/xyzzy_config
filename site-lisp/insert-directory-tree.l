;;; -*- Mode: Lisp -*-
;;; insert-directory-tree.l --- ディレクトリツリーの出力

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Time-stamp: <2005/10/19 01:38:21 +0900>

;;; Commentary:

;; Description:
;;
;;  ディレクトリツリーを出力します。
;;

;; Installation:
;;
;;      1. 展開して insert-directory-tree.l を $XYZZY/site-lisp に
;;         コピーします。
;;
;;      2. バイトコンパイルします。
;;
;;              M-x byte-compile-file
;;              Byte compile file: $XYZZY/site-lisp/insert-directory-tree.l
;;
;;      3. ~/.xyzzy または $XYZZY/site-lisp/siteinit.l に以下のコードを
;;         追加します。
;;
;;              (autoload 'insert-directory-tree "insert-directory-tree" t)
;;
;;      4. 上記の設定を反映させるために、xyzzy を再起動します。
;;         siteinit.l に記述した場合は Ctrl キーと Shift キーを押しながら
;;         xyzzy を再起動し、ダンプファイルを再構築します。
;;

;; Uninstallation:
;;
;;      1. insert-directory-tree.l に関する記述を削除します。
;;
;;      2. siteinit.l に記述していた場合は Ctrl キーと Shift キーを押し
;;         ながら xyzzy を再起動し、ダンプファイルを再構築します。
;;

;; Usage:
;;
;;      M-x insert-directory-tree
;;

;; Setting example:
;;
;;      (require "insert-directory-tree")
;;

;; Customize:
;;
;;      ; ファイルサイズを出力
;;      (setq *insert-directory-tree-leaf-function*
;;            #'(lambda (file)
;;                (unless (file-directory-p file)
;;                  (format nil "\t~D Bytes" (file-length file)))))
;;
;;      ; ファイルの更新日時を出力
;;      (setq *insert-directory-tree-leaf-function*
;;            #'(lambda (file)
;;                (unless (file-directory-p file)
;;                  (format-date-string "\t(%y/%m/%d %H:%M:%S)"
;;                                      (cadr (get-file-info file))))))
;;

;; Changes:
;;
;;      Wed, 19 Oct 2005 01:15:32 +0900
;;        ・NANRI さんの拡張を取り込み。
;;          *insert-directory-tree-leaf-function* に、file を引数にと
;;          り文字列を返す関数を指定することで情報を付加出力する。
;;
;;      Sat, 08 Oct 2005 14:37:47 +0900
;;        ・メールアドレスを変更。
;;        ・ライセンス条項(修正BSDライセンス)を記載。
;;
;;      Sat, 08 Jan 2005 06:17:25 +0900
;;        ・box-fixation-mode.l 作成に伴い、縦線を｜(0x8162)から
;;          │(0x84A0)に変更。
;;
;;      Sun, 13 Jun 2004 20:00:56 +0900
;;        ・出力フォーマット一部修正。
;;        ・NetInstaller 対応。
;;
;;      Tue, 04 Mar 2003 21:44:48 +0900
;;        ・honami さんから頂いていた除外ファイルリスト拡張を統合。
;;        ・修正。
;;
;;      Fri, 19 Oct 2001 13:19:20 +0900
;;        ・作成
;;

;; Licence:
;;
;;    insert-directory-tree は修正BSDライセンスに基づいて利用可能です。
;;    <http://www.opensource.org/licenses/bsd-license.php>
;;
;;
;;    Copyright (C) 2001-2005, OHKUBO Hiroshi.  All rights reserved.
;;
;;    Redistribution and use in source and binary forms, with or without
;;    modification, are permitted provided that the following conditions
;;    are met:
;;
;;    1. Redistributions of source code must retain the above copyright
;;       notice, this list of conditions and the following disclaimer.
;;
;;    2. Redistributions in binary form must reproduce the above copyright
;;       notice, this list of conditions and the following disclaimer in
;;       the documentation and/or other materials provided with the
;;       distribution.
;;
;;    3. Neither the name of the University nor the names of its
;;       contributors may be used to endorse or promote products derived
;;       from this software without specific prior written permission.
;;
;;    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
;;    ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
;;    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
;;    A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
;;    OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
;;    SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
;;    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
;;    DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
;;    THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
;;    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
;;    OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;;

;;; Code:

(provide "insert-directory-tree")

(defvar *insert-directory-tree-ignore-list* '("^CVS/$" ".*lc$")
  "ディレクトリツリー作成時に無視するフォルダ/ファイル名 (正規表現) のリスト")
(defvar *insert-directory-tree-verbose-p* nil
  "non-nil なら *insert-directory-tree-ignore-list* の指定を無視してツリーを作成する")

(defvar *insert-directory-tree-leaf-function* nil
  "fileを引数にとり文字列を返す関数")

(defun insert-directory-tree (directory)
  "ディレクトリツリーを作成"
  (interactive "*Ddirectory: "
    :default0 (if (get-buffer-file-name)
                  (directory-namestring (get-buffer-file-name))
                (si:system-root)))
  (labels ((insert-leaf (base branch &optional file directory directory-p)
             (insert (format nil "~A~A~@[ ~A~]~@[~A~]~@[~A~]~%" base branch
                             file (and directory-p "/")
                             (and file
                                  directory
                                  *insert-directory-tree-leaf-function*
                                  (funcall *insert-directory-tree-leaf-function* (merge-pathnames file directory))))))
           (insert-directory-tree-1 (base-directory &optional (base-str ""))
             (let (file-list directory-list last-file last-directory)
               (dolist (file (directory base-directory))
                 (when (or *insert-directory-tree-verbose-p*
                           (not (member file *insert-directory-tree-ignore-list*
                                        :test #'(lambda (string regexp)
                                                  (string-match regexp string)))))
                   (if (string-match "/$" file)
                       (push (string-right-trim "/" file) directory-list)
                     (push file file-list))))
               (setq file-list (stable-sort file-list #'string-lessp))
               (setq directory-list (stable-sort directory-list #'string-lessp))
               (setq last-file (car (last file-list)))
               (setq last-directory (car (last directory-list)))
               (dolist (file file-list)
                 (if (and (eq file last-file) (not directory-list))
                     (insert-leaf base-str "└" file base-directory)
                   (insert-leaf base-str "├" file base-directory)))
               (dolist (file directory-list)
                 (insert-leaf base-str "│")
                 (if (eq file last-directory)
                     (progn
                       (insert-leaf base-str "└" file base-directory t)
                       (insert-directory-tree-1 (merge-pathnames file base-directory)
                                                (concat base-str "   ")))
                   (progn
                     (insert-leaf base-str "├" file base-directory t)
                     (insert-directory-tree-1 (merge-pathnames file base-directory)
                                              (concat base-str "│ "))))))))
    (unless (file-directory-p directory)
      (return-from insert-directory-tree nil))
    (setq directory (append-trail-slash (map-backslash-to-slash directory)))
    (insert (format nil "~A~%" directory))
    (insert-directory-tree-1 directory " ")))

;;; insert-directory-tree.l ends here
