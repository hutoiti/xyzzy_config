;; refer-for.l - reference.xmlを検索して参照する
;; -*- mode:lisp; package:refer-for -*-
;;
;; $Rev: 226 $
;;
;;
;; License
;; =======
;;
;; Copyright (c) 2003-2006 kia
;;
;; Permission is hereby granted, free of charge, to any person obtaining a
;; copy of this software and associated documentation files (the "Software"),
;; to deal in the Software without restriction, including without
;; limitation the rights to use, copy, modify, merge, publish, distribute,
;; sublicense, and/or sell copies of the Software, and to permit persons to
;; whom the Software is furnished to do so, subject to the following
;; conditions:
;;
;; The above copyright notice and this permission notice shall be included
;; in all copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
;; OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
;; IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
;; CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
;; TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
;; SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
;;
;;
;; インストール
;; ============
;;
;; reference.xmlが必要ですので入手してください。
;; <http://xyzzy.s53.xrea.com/wiki/?%A5%EA%A5%D5%A5%A1%A5%EC%A5%F3%A5%B9>か
;; ら入手できます。
;;
;; MSXML3.0もしくはMSXML4.0が必要ですので無ければ入手してインストールしてく
;; ださい。<http://msdn.microsoft.com/>からたどれば入手できるでしょう。なお、
;; IE6がインストールされていればMSXML3.0が入ってるらしいです（未確認）。
;;
;; refer-for.lと同時に配布しているrefer-for.xslとrefer-for-search.xslが必要
;; です。xyzzyをインストールしたディレクトリのetcディレクトリにその
;; refer-for.xslとrefer-for-search.xslをコピーしてください。
;;
;; xyzzyをインストールしたディレクトリのsite-lispディレクトリにこの
;; refer-for.lを入れます。
;;
;; ~/.xyzzyでrefer-forをロードして、use-package するようにします。
;; たとえば次のように記述します。
;;
;;     (require "refer-for")
;;     (use-package "refer-for")
;;
;; autoloadでロードしたいときには上の代わりに次のように書きます。
;;
;;     (defpackage "refer-for" (:use "lisp"))
;;     (in-package "refer-for")
;;     (export '(refer-for refer-to-titles))
;;     (in-package "user")
;;     (use-package "refer-for")
;;     (autoload 'refer-for "refer-for" t)
;;     (autoload 'refer-to-titles "refer-for" t)
;;
;; 必要ならリファレンスファイルのパス名を設定します。
;; デフォルトは (xyzzyをインストールしたディレクトリ)/etc/reference.xml です。
;;
;;     (setq refer-for::*reference-file* "~/reference.xml")
;;
;; 必要ならスタイルファイルのパス名を設定します。
;; デフォルトは (xyzzyをインストールしたディレクトリ)/etc/refer-for.xsl です。
;;
;;     (setq refer-for::*style-file* "~/refer-for.xsl")
;;
;; 必要なら正規表現検索用のスタイルファイルのパス名を設定します。
;; デフォルトは (xyzzyをインストールしたディレクトリ)/etc/refer-for-search.xsl です。
;;
;;     (setq refer-for::*style-file-for-search* "~/refer-for-search.xsl")
;;
;; 相対パスでの指定がうまくいかないときは絶対パスで記述してみてください。
;;
;; MSXML3.0を使うときは次の一行を追加してください。
;;
;;     (setq refer-for::*msxml-prog-id* "Msxml2.DOMDocument.3.0")
;;
;; 正規表現で検索を行わないときは次の一行を追加してください。
;;
;;     (setq refer-for::*regexp-search* nil)
;;
;; 検索結果をソートしないときは次の一行を追加してください。
;;
;;     (setq refer-for::*sort-alphabetically* nil)
;;
;; refer-for:*refer-for-reference-file* は廃止予定です。
;; refer-for:*refer-for-style-file* は廃止予定です。
;; refer-for:*refer-for-style-file-for-search* は廃止予定です。
;; refer-for:*refer-for-buffer-name* は廃止予定です。
;; refer-for:*refer-for-msxml-prog-id* は廃止予定です。
;; refer-for:*refer-for-regexp* は廃止予定です。
;;
;; refer-for::*prog-id* は廃止しました。
;; refer-for::*refer-for-keep-alive* は廃止しました。
;;
;;
;; 使い方
;; ======
;;
;; コマンドは二つあります。refer-for と refer-to-titles です。
;;
;; refer-for が reference.xml の各chaperの中身全部を検索するのに対し、
;; refer-to-titles は <title>～</title>の部分だけを対象にして検索します。
;;
;; どちらのコマンドもミニバッファで入力できるようになりますから、適当なキー
;; ワードを入力してください。検索してテンポラリバッファに結果を表示します。
;; 検索するキーワードには正規表現が使えます。ただし検索にはJScriptエンジン
;; を使いますので、Xyzzy上での正規表現とは表記が異なります。
;;
;; 検索結果を表示しているバッファでは、デフォルトで次のようにキーバインドが
;; 使えます。
;;
;; b              : 前のページ
;; SPC            : 次のページ
;; j              : スクロールアップ
;; k              : スクロールダウン
;; J or TAB       : 次の項目(chapter)へカーソルを移動
;; K              : 前の項目(chapter)へカーソルを移動
;; B or l or C-h  : 最新の履歴を捨てて、一つ前の検索をもう一度実行
;; s              : 検索履歴一覧のダイアログから選択して検索
;; q              : バッファが表示されているウィンドウを削除
;; r              : refer-forコマンドの実行
;; R              : refer-to-titlesの実行
;; RET            : カーソルがSeealso項目の行のとき、そのSeealsoの内容で検索
;;
;;
;; アドレス
;; ========
;;
;; kia <meshinsha@yahoo.co.jp>
;; http://www.geocities.jp/kiaswebsite/

(provide "refer-for")
(defpackage "refer-for" (:use "lisp"))
(in-package "refer-for")
(shadow '(refer-for
          refer-to-titles
          refer-for-last-search
          refer-for-search-seealso
          refer-for-select-search
          refer-for-next-chapter
          refer-for-previous-chapter
          refer-for-scroll-up
          refer-for-scroll-down
          refer-for-mode
          *refer-for-mode-hook*
          *refer-for-mode-map*
          *refer-for-reference-file*
          *refer-for-style-file*
          *refer-for-style-file-for-search*
          *refer-for-regexp*
          *refer-for-buffer-name*
          *refer-for-msxml-prog-id*
          *buffer-name*
          *msxml-prog-id*
          *reference-file*
          *regexp-search*
          *search-history*
          *sort-alphabetically*
          *style-file*
          *style-file-for-search*
          add-interactive-attr-and-result-number
          create-document-object
          if-not-bound
          load-xml-object
          load-searcher-object
          nodes2list
          output
          search
          set-history
          sort-alphabetically
          ))
(export '(refer-for
          refer-to-titles
          refer-for-last-search
          refer-for-search-seealso
          refer-for-select-search
          refer-for-next-chapter
          refer-for-previous-chapter
          refer-for-scroll-up
          refer-for-scroll-down
          refer-for-mode
          *refer-for-reference-file*
          *refer-for-style-file*
          *refer-for-style-file-for-search*
          *refer-for-regexp*
          *refer-for-buffer-name*
          *refer-for-msxml-prog-id*
          *refer-for-mode-hook*
          *refer-for-mode-map*
          ))
(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "ole"))

(defvar *buffer-name* "*Reference*")
(defvar *msxml-prog-id* "Msxml2.DOMDocument.4.0")
(defvar *reference-file* (merge-pathnames "reference/reference.xml" (si:system-root)))
(defvar *regexp-search* t)
(defvar *sort-alphabetically* t)
(defvar *search-history* nil)
(defvar *style-file* (merge-pathnames "etc/refer-for.xsl" (si:system-root)))
(defvar *style-file-for-search* (merge-pathnames "etc/refer-for-search.xsl" (si:system-root)))
(defvar *refer-for-mode-hook* nil)
(defvar *refer-for-mode-map* nil)
(unless *refer-for-mode-map*
  (setq *refer-for-mode-map* (ed:make-sparse-keymap))
  (ed:define-key *refer-for-mode-map* #\b 'ed:previous-page)
  (ed:define-key *refer-for-mode-map* #\B 'refer-for-last-search)
  (ed:define-key *refer-for-mode-map* #\j 'refer-for-scroll-up)
  (ed:define-key *refer-for-mode-map* #\k 'refer-for-scroll-down)
  (ed:define-key *refer-for-mode-map* #\l 'refer-for-last-search)
  (ed:define-key *refer-for-mode-map* #\q 'ed:delete-window)
  (ed:define-key *refer-for-mode-map* #\s 'refer-for-select-search)
  (ed:define-key *refer-for-mode-map* #\C-h 'refer-for-last-search)
  (ed:define-key *refer-for-mode-map* #\TAB 'refer-for-next-chapter)
  (ed:define-key *refer-for-mode-map* #\J 'refer-for-next-chapter)
  (ed:define-key *refer-for-mode-map* #\K 'refer-for-previous-chapter)
  (ed:define-key *refer-for-mode-map* #\SPC 'ed:next-page)
  (ed:define-key *refer-for-mode-map* #\r 'refer-for)
  (ed:define-key *refer-for-mode-map* #\R 'refer-to-titles)
  (ed:define-key *refer-for-mode-map* #\RET 'refer-for-search-seealso))

(defmacro if-not-bound (v1 v2)
  `(if (boundp ',v1) ,v1 ,v2))

(defun create-document-object ()
  (let ((obj (ed:ole-create-object (if-not-bound *refer-for-msxml-prog-id* *msxml-prog-id*))))
    (setf #{obj.async} nil)
    (setf #{obj.validateOnParse} t)
    #{obj.setProperty["SelectionLanguage"]["XPath"]}
    obj))

(defun load-xml-object (fn)
  (let ((obj (create-document-object)))
    (unless #{obj.load[(ed:map-slash-to-backslash (merge-pathnames fn))]}
      (let* ((pe #{obj.parseError})
             (line #{pe.line})
             (linepos #{pe.linepos})
             (reason #{pe.reason}))
        (error "ファイルがロードできません~2%filename = ~A~%line = ~A~%linepos = ~A~%reason = ~A" fn line linepos reason)))
    obj))

(defun load-searcher-object (s by-title)
  (flet ((set-param (sobj name val)
           #{sobj.selectSingleNode[(format nil "//*[local-name()='param'][@name='~A']" name)].setAttribute["select"][val]}))
    (let ((obj (load-xml-object (if-not-bound *refer-for-style-file-for-search* *style-file-for-search*))))
      (set-param obj "pattern" (format nil "'~A'" s))
      (set-param obj "bytitle" (if by-title 1 0))
      obj)))

(defun add-interactive-attr-and-result-number (lst)
  (let ((fmt (format nil "~~D/~D" (length lst)))
        (count 0))
    (mapc #'(lambda (node)
              #{node.setAttribute["resultNumber"][(format nil fmt (incf count))]}
              (let ((title #{node.selectSingleNode["title"]})
                    (type #{node.selectSingleNode["type"]}))
                (if (and (string-equal #{type.text} "Function")
                         (ed:commandp (find-symbol #{title.text} "user")))
                    #{type.setAttribute["interactive"]["t"]})))
          lst)))

(defun nodes2list (nodes)
  (let (lst)
    (do ((n (1- #{nodes.length}) (1- n)))
        ((< n 0) lst)
      (setq lst (cons #{nodes.item[n]} lst)))))

(defun search (s &key by-title)
  (nodes2list
   (if (if-not-bound *refer-for-regexp* *regexp-search*)
       (let ((obj (load-xml-object (if-not-bound *refer-for-reference-file* *reference-file*)))
             (sobj (load-searcher-object s by-title))
             (result (create-document-object)))
         #{obj.transformNodeToObject[sobj][result]}
         #{result.documentElement.childNodes})
     (let ((obj (load-xml-object (if-not-bound *refer-for-reference-file* *reference-file*))))
       #{obj.documentElement.selectNodes[(format nil "//chapter[contains(~A, '~A')]" (if by-title "title" ".") s)]}))))

(defun set-history (str &optional by-title)
  (let ((p (cons str by-title)))
    (setq *search-history* (cons p (delete p *search-history* :test #'equal)))))

(defun output (lst)
  (flet ((remove-cr (s) (ed:substitute-string s "\r" "")))
    (let ((obj (load-xml-object (if-not-bound *refer-for-style-file* *style-file*))))
      (ed:with-output-to-temp-buffer ((if-not-bound *refer-for-buffer-name* *buffer-name*))
        (mapc #'(lambda (n) (princ (remove-cr #{n.transformNode[obj]}))) (add-interactive-attr-and-result-number (if *sort-alphabetically* (sort-alphabetically lst) lst))))
      (message "~D件見つかりました" (length lst))
      (refer-for-mode))))

(defun sort-alphabetically (lst)
  (mapcar #'cdr (sort (mapcar #'(lambda (n) (cons #{n.selectSingleNode["title"].text} n)) lst) #'string< :key #'car)))

(defun refer-for (s)
  (ed:interactive (list (ed:read-string (format nil "refer-for~A: " (if (if-not-bound *refer-for-regexp* *regexp-search*) "(Regexp)" "")))))
  (let ((lst (search s)))
    (if lst
        (progn
          (output lst)
          (ed:refresh-screen)
          (refer-for-next-chapter)
          (set-history s))
      (message "文字列が見つかりません"))))

(defun refer-to-titles (s)
  (ed:interactive (list (ed:read-string (format nil "refer-to-titles~A: " (if (if-not-bound *refer-for-regexp* *regexp-search*) "(Regexp)" "")))))
  (let ((lst (search s :by-title t)))
    (if lst
        (progn
          (output lst)
          (ed:refresh-screen)
          (refer-for-next-chapter)
          (set-history s t))
      (message "文字列が見つかりません"))))

(defun refer-for-last-search ()
  (ed:interactive)
  (if (cadr *search-history*)
      (progn
        (pop *search-history*)
        (let ((last (car *search-history*)))
          (when last
            (if (cdr last)
                (refer-to-titles (car last))
              (refer-for (car last))))))
    (message "これより前の検索履歴はありません")))

(defun refer-for-search-seealso ()
  (ed:interactive)
  (flet ((seealso-value ()
           (ed:save-excursion
             (ed:goto-eol)
             (let ((pnt (ed:point)))
               (ed:goto-bol)
               (if (ed:scan-buffer "^\\[See also   \\]: \\(.+\\)$" :regexp t :limit pnt)
                   (string-trim " \t" (ed:buffer-substring (ed:match-beginning 1) (ed:match-end 1))))))         ))
    (let ((str (seealso-value)))
      (when str
        (let ((str (if (if-not-bound *refer-for-regexp* *regexp-search*)
                       (format nil "^~A$" (ed:regexp-quote str))
                     str)))
          (output (search str :by-title t))
          (set-history str t))))))

(defun refer-for-select-search ()
  (ed:interactive)
  (if *search-history*
      (multiple-value-bind (result data)
          (ed:dialog-box '(ed:dialog 0 0 260 120
                           (:caption "refer-for: 検索履歴一覧")
                           (:font 9 "MS UI Gothic")
                           (:control
                            (:listbox list nil #x50b10111 4 5 192 114)
                            (:button IDOK "OK" #x50010001 205 5 52 14)
                            (:button IDCANCEL "キャンセル" #x50010000 205 22 52 14)))
                         (list (cons 'list (mapcar #'(lambda (x)
                                                       (cons (ed:concat (car x) (if (cdr x) " <title>")) x))
                                                   *search-history*)))
                         '((list :must-match t :enable (IDOK))))
        (when result
          (let ((tmp (cddr (assoc 'list data))))
            (output (search (car tmp) :by-title (cdr tmp))))))
    (message "検索履歴はありません")))

(defun refer-for-next-chapter ()
  (ed:interactive)
  (unless (ed:scan-buffer "^■" :regexp t :no-dup t)
    (message "既に最後の項目です"))
  (ed:recenter 1))

(defun refer-for-previous-chapter ()
  (ed:interactive)
  (unless (ed:scan-buffer "^■" :regexp t :no-dup t :reverse t)
    (message "既に最初の項目です"))
  (ed:recenter 1))

(defun refer-for-scroll-up ()
  (ed:interactive)
  (ed:scroll-window 1))

(defun refer-for-scroll-down ()
  (ed:interactive)
  (ed:scroll-window -1))

(defun refer-for-mode ()
  (ed:interactive)
  (ed:kill-all-local-variables)
  (setq ed:mode-name "ReferFor")
  (setq ed:buffer-mode 'refer-for-mode)
  (setq ed:buffer-read-only t)
  (ed:use-keymap *refer-for-mode-map*)
  (ed:run-hooks '*refer-for-mode-hook*))

;;; refer-for.l はここまで
