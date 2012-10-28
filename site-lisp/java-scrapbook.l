; -*- Mode: Lisp; Package: editor -*-

#|
= java-scrapbook - Java のコード片を実行する

* Author:  miyamuko ((<URL:mailto:miyamuko (at) mtb.biglobe.ne.jp>))
* URL: ((<URL:http://miyamuko.s56.xrea.com/xyzzy/java-scrapbook.html>))
* Version: $Id: java-scrapbook.l,v 1.11 2004/09/13 17:02:06 miyamuko Exp $


== 説明

Java のコード片を実行します。

ちょっとしたコードの実行結果を知りたい場合に便利です。
名前からもわかるとおり Eclipse にある ScrapBook のぱくりです。

== できること

* 簡単に Java ソースを生成しコンパイル → 実行できる。
* import 文を指定できる。
* classpath を指定できる。
  * eclipse の .classpath 読み込める。

== これからやるかもしれないこと

* メソッド定義
* クラス定義
* package 名の指定
* バッファを作らずに実行結果をカーソル位置に挿入する
  * エラーになったら表示する
* 複数の jdk を簡単に切り替え可能にする
  * 同じコードを複数の jdk で実行して結果を全部表示
    * 実行結果はバージョンごとにバッファを作ることもできる (diff しやすい)

* package-list を読み込んでワイルドカードで import 指定

== インストール

((<NetInstaller|URL:http://www.mirai.ne.jp/~gyo/xyzzy/ni.html>)) でインストールした場合は 3 以降を、
NetInstaller + (({ni-autoload})) を使っている人は 4 以降で OK です。

(1) アーカイブをダウンロードします。

    ((<URL:http://miyamuko.s56.xrea.com/xyzzy/archives/java-scrapbook.zip>))

(2) アーカイブを展開して、$XYZZY/site-lisp 配下にファイルをコピーします。

(3) ~/.xyzzy または $XYZZY/site-lisp/siteinit.l に以下のコードを追加します。

        ;; java-scrapbook
        (require "java-scrapbook")

(4) 設定を反映させるため xyzzy を再起動してください。

    ※siteinit.l に記述した場合には再ダンプが必要です。

(5) 実行したいコード片をリージョンで指定して ((% M-x java-scrapbook-region %))、
    または ((% M-x java-scrapbook-oneliner %))、((% M-x java-scrapbook-display %))
    でミニバッファから一行入力して実行します。

    例: システムプロパティを表示する例 (java-scrapbook-oneliner で入力)。

        System.getProperties().list(System.out);


== リファレンス

=== 関数

--- java-scrapbook-current-kill
    kill ring の文字列を java コード片として実行します。

--- java-scrapbook-clipboard
    クリップボードの文字列を java コード片として実行します。

--- java-scrapbook-buffer
    バッファ全体を Java コードを実行します。

--- java-scrapbook-region
    リージョンの Java コードを実行します。

--- java-scrapbook-oneliner
    ミニバッファから Java のコードを一行入力して実行します。

--- java-scrapbook-display
    ミニバッファから Java の式を一行入力してその評価結果を表示します。

    入力した値はそのまま System.out.println の引数に渡します。
    よって入力するのは Java の式である必要があります。
    (= セミコロンはいらない)

=== 変数

--- *java-scrapbook-template*
    生成するソースファイルのテンプレートを指定します。

    テンプレートは以下の引数を与えられ format されます。

    (1) import 宣言のリスト

        ((<*java-scrapbook-import-list*>)) で指定したリストです。

    (2) コード片中に書いてある import 宣言のリスト

    (3) クラス名

    (4) 実行する Java コード片

--- *java-scrapbook-import-list*
     import 宣言のリストです。

     デフォルトは Java 1.4 の java. で始まり
     AWT と Applet 以外のパッケージです。

     Java 1.2 or 1.3 を利用している人は以下のようにしてください。

         (setf *java-scrapbook-import-list* *java-scrapbook-java1.3-import-list*)

     新しく追加する場合は以下のようにしてください。

        (pushnew "javax.accessibility.*" *java-scrapbook-import-list* :test #'equal)
        (pushnew "javax.crypto.*" *java-scrapbook-import-list* :test #'equal)

--- *java-scrapbook-java1.3-import-list*
--- *java-scrapbook-java1.4-import-list*
    それぞれ Java 1.2/1.3 と Java1.4 の import 宣言のリストです。

--- *java-scrapbook-substitute-alist*
     生成する Java コードの置換リストです。

     デフォルトでは sout と serr がそれぞれ
     System.out.println と System.err.println に置換されるように
     なっています。

     新しく追加する場合は以下のようにしてください。

         (pushnew '("regexp" . "replacement") *java-scrapbook-substitute-alist*)

     例:

         (pushnew '("ae" . "assertEquals") *java-scrapbook-substitute-alist*)

--- *java-scrapbook-keep-file-p*
     生成した Java ファイルを保存・削除を決定するフラグです。

     生成したファイルを削除しないなら以下のように ((|non-nil|)) を指定してください。

         (setq *java-scrapbook-keep-file-p* t)

     生成先は環境変数 ((|%Temp%|)) 配下（たぶん）の Scrap_～.book
     というディレクトリです。

     デフォルトは nil （削除する）です。

--- *java-scrapbook-source-buffer-name*
--- *java-scrapbook-javac-buffer-name*
--- *java-scrapbook-java-buffer-name*
     それぞれ生成したソースコード、コンパイル結果、実行結果を
     書き込むバッファ名です。

     デフォルトはすべて同じで ((|*Java Scrap*|)) です。

--- *java-scrapbook-java-command*
--- *java-scrapbook-javac-command*

    Java の実行コマンドとコンパイルコマンドを指定します。

    文字列以外を指定すると適当に文字列に変換します。
    関数を指定した場合 funcall するので動的に値を変更できます。

--- *java-scrapbook-before-java-hook*
--- *java-scrapbook-before-javac-hook*

    なんとなく用意したフックです。
    プリプロセッサに通したいとか ajc したいとかに使えるかも。

    それぞれ java コマンドの前と javac コマンドの前に
    (({run-hook-with-args-while-success})) で実行します。
    フックが ((|nil|)) を返すとその時点ですべての実行を中断します。

    フックの引数は次のとおりです。

      (1) 生成したソースファイルの絶対パス
      (2) クラス名

--- *java-scrapbook-search-eclipse-classpath-p*

    Eclipse の .classpath ファイルを読み込むかどうかを指定します。
    ((|nil|)) を指定した場合、読み込みません。

    .classpath の検索はカレントディレクトリから上位に探します。

--- *java-scrapbook-classpath*

    クラスパスを指定します。
    デフォルト値は環境変数 CLASSPATH の値です。

    ((< *java-scrapbook-search-eclipse-classpath-p* >)) に ((|non-nil|))
    を指定した場合 Eclipse の .classpath ファイルを読み込んでクラスパスの
    先頭に追加します。

--- *java-scrapbook-erase-output-buffer*

    javac コマンドや java コマンド実行前にバッファの内容を削除する場合 t
    (デフォルト ((|nil|)))。


== ライセンス

java-scrapbook は修正 BSD ライセンスに基づいて利用可能です。

  Copyright (C) 2003-2004 MIYAMUKO Katsuyuki. All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  1 Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer as the first lines
    of this file unmodified.

  2 Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
  OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
  SUCH DAMAGE.
|#

(provide "java-scrapbook")
(in-package "editor")

(export '(java-scrapbook-current-kill
          java-scrapbook-clipboard
          java-scrapbook-buffer
          java-scrapbook-region
          java-scrapbook-oneliner
          java-scrapbook-display
          *java-scrapbook-template*
          *java-scrapbook-import-list*
          *java-scrapbook-java1.3-import-list*
          *java-scrapbook-java1.4-import-list*
          *java-scrapbook-substitute-alist*
          *java-scrapbook-keep-file-p*
          *java-scrapbook-source-buffer-name*
          *java-scrapbook-javac-buffer-name*
          *java-scrapbook-java-buffer-name*
          *java-scrapbook-java-command*
          *java-scrapbook-javac-command*
          *java-scrapbook-source-dir*
          *java-scrapbook-search-eclipse-classpath-p*
          *java-scrapbook-classpath*
          *java-scrapbook-erase-output-buffer*
          *java-scrapbook-before-java-hook*
          *java-scrapbook-before-javac-hook*
          ))


;; ----------------------------------------------------------------------
;; Hooks

(defvar *java-scrapbook-before-javac-hook* nil
  "java-scrapbook: コンパイルコマンドの前に呼ばれる。
引数:
  1. 生成した Java ソースのファイル名
  2. クラス名
nil を返した場合そこで処理が中断する。")

(defvar *java-scrapbook-before-java-hook* nil
  "java-scrapbook: 実行コマンドの前に呼ばれる。
引数:
  1. 生成した Java ソースのファイル名
  2. クラス名
nil を返した場合そこで処理が中断する。")

;; ----------------------------------------------------------------------
;; variables

(defvar *java-scrapbook-template*
"~{import ~A; ~}

~{import ~A; ~}

public class ~A {
    public static void main(String[] args) throws Exception {
~A
    }
}
"
  "java-scrapbook: 生成するソースファイルのテンプレート。
   arguments: (import list) (local import list) class statements")

(defvar *java-scrapbook-java1.3-import-list*
  '("java.beans.*"
    "java.beans.beancontext.*"
    "java.io.*"
    "java.lang.*"
    "java.lang.ref.*"
    "java.lang.reflect.*"
    "java.math.*"
    "java.net.*"
    "java.rmi.*"
    "java.rmi.activation.*"
    "java.rmi.dgc.*"
    "java.rmi.registry.*"
    "java.rmi.server.*"
    "java.security.*"
    "java.security.acl.*"
    "java.security.cert.*"
    "java.security.interfaces.*"
    "java.security.spec.*"
    "java.sql.*"
    "java.text.*"
    "java.util.*"
    "java.util.jar.*"
    "java.util.zip.*")
  "java-scrapbook: Java2 SDK 1.2, 1.3 の import 宣言のリスト")

(defvar *java-scrapbook-java1.4-import-list*
  (append *java-scrapbook-java1.3-import-list*
          '("java.nio.*"
            "java.nio.channels.*"
            "java.nio.channels.spi.*"
            "java.nio.charset.*"
            "java.nio.charset.spi.*"
            "java.util.logging.*"
            "java.util.prefs.*"
            "java.util.regex.*"))
  "java-scrapbook: Java2 SDK 1.4 の import 宣言のリスト")

(defvar *java-scrapbook-import-list*
  *java-scrapbook-java1.4-import-list*
  "java-scrapbook: ソースを生成するときの import 宣言のリスト")

(defvar *java-scrapbook-substitute-alist*
  '(("\\<sout\\>" . "System.out.println")
    ("\\<serr\\>" . "System.err.println"))
  "java-scrapbook: 置換リスト")

(defvar *java-scrapbook-keep-file-p* nil
  "java-scrapbook: 生成した java ソースファイルを削除しない t")

(defvar *java-scrapbook-source-buffer-name* "*Java Scrap*"
  "java-scrapbook: 生成したソースを書き込む一時バッファの名前")

(defvar *java-scrapbook-javac-buffer-name* "*Java Scrap*"
  "java-scrapbook: コンパイル結果を書き込む一時バッファの名前")

(defvar *java-scrapbook-java-buffer-name* "*Java Scrap*"
  "java-scrapbook: 実行結果を書き込む一時バッファの名前")

(defvar *java-scrapbook-java-command* "java"
  "java-scrapbook: java コマンド")

(defvar *java-scrapbook-javac-command* "javac"
  "java-scrapbook: javac コマンド")

(defvar *java-scrapbook-source-dir* nil
  "java-scrapbook: 生成したソースの出力先ディレクトリ。
   nil を指定すると環境変数 %Temp% を利用する。
   存在しているディレクトリを指定する必要がある。")

(defvar *java-scrapbook-classpath* (si:getenv "CLASSPATH")
  "java-scrapbook: デフォルトのクラスパス。
デフォルトは環境変数 CLASSPATH の値")

(defvar *java-scrapbook-search-eclipse-classpath-p* t
  "java-scrapbook: eclipse の .classpath を検索するなら t。
現在の directory から上位に検索していく")

(defvar *java-scrapbook-erase-output-buffer* nil
  "java-scrapbook: 出力バッファを javac, java コマンド実行前に erase-buffer するなら t")


(defvar *java-scrapbook-class-name* "Scrap"
  "java-scrapbook: 生成するソースのクラス名")

(defvar *java-scrapbook-import-regexp* "^import[ \t]+\\([^;]+\\);?$"
  "java-scrapbook: import 文のパターン")

(defvar *java-scrapbook-temp-buffer-name* "*java scrapbook:temp"
  "java-scrapbook: 一時バッファの名前")

;; ----------------------------------------------------------------------
;; commands

(defun java-scrapbook-current-kill ()
  "java-scrapbook: kill ring の java コードを実行する。"
  (interactive)
  (java-scrapbook (car (ed::current-kill 0))))

(defun java-scrapbook-clipboard ()
  "java-scrapbook: クリップボードの java コードを実行する。"
  (interactive)
  (java-scrapbook (get-clipboard-data)))

(defun java-scrapbook-region ()
  "java-scrapbook: バッファ全体を実行する。"
  (interactive)
  (java-scrapbook-region (point-min) (point-max)))

(defun java-scrapbook-region (start end)
  "java-scrapbook: リージョンを実行する。"
  (interactive "r")
  (if (< end start) (rotatef start end))
  (java-scrapbook (buffer-substring start end)))

(defun java-scrapbook-oneliner (statement)
  "java-scrapbook: ミニバッファから Java のコードを一行入力して実行する。"
  (interactive "sjava statement: ")
  (java-scrapbook statement))

(defun java-scrapbook-display (expression)
  "java-scrapbook: ミニバッファから Java の式を一行入力してその評価結果を表示する。"
  (interactive "sjava expression: ")
  (java-scrapbook (concat "System.out.println(" expression ");")))

;;
;; private
;;
(defun java-scrapbook (scrap)
  (let* ((dir (make-temp-file-name "Scrap_" "book" *java-scrapbook-source-dir* t))
         (file (merge-pathnames (concat *java-scrapbook-class-name* ".java") dir))
         (class *java-scrapbook-class-name*))

    (java-scrapbook-save-page file class scrap)
    (unwind-protect
        (and
         (run-hook-with-args-while-success
          '*java-scrapbook-before-javac-hook* file class)
         (zerop (java-scrapbook-execute-scrap
                 (java-scrapbook-command (java-scrapbook-javac-command)
                                         (java-scrapbook-classpath)
                                         file)
                 *java-scrapbook-javac-buffer-name*
                 dir))
         (run-hook-with-args-while-success
          '*java-scrapbook-before-java-hook* file class)
         (zerop (java-scrapbook-execute-scrap
                 (java-scrapbook-command (java-scrapbook-java-command)
                                         (java-scrapbook-classpath)
                                         class)
                 *java-scrapbook-java-buffer-name*
                 dir)))
      (unless *java-scrapbook-keep-file-p*
        (java-scrapbook-delete-directory-recursive dir)))
    ))

(defun java-scrapbook-command (exe classpath arg)
  (let ((cp (string-trim " \t\r\f\n" (or classpath ""))))
    (if (zerop (length cp))
        (format nil "~A ~A" exe arg)
      (format nil "~A -classpath ~A ~A" exe cp arg))))

(defun java-scrapbook-save-page (file class scrap)
  (with-output-to-temp-buffer (*java-scrapbook-source-buffer-name*)
    (insert (java-scrapbook-generate-src class scrap) #\LFD)
    (java-scrapbook-preprocess)
    (set-buffer (find-buffer *java-scrapbook-source-buffer-name*))
    (write-file file)))

(defun java-scrapbook-generate-src (class scrap)
  (multiple-value-bind (local-import rest)
      (java-scrapbook-parse scrap)
    (format nil *java-scrapbook-template*
            *java-scrapbook-import-list* local-import
            class rest)))

;; "foo;\nimport hoge.*;\nbar;\nimport baz.*"
;; => (values "foo;\n\nbar\n" ("hoge.*" "baz.*"))
(defun java-scrapbook-parse (scrap)
  (let (import-list (rest scrap))
    (setf rest (java-scrapbook-gsub *java-scrapbook-import-regexp*
                                    rest #'(lambda (s)
                                             (push (match-string 1) import-list)
                                             "")))
    (values import-list rest)))

(defun java-scrapbook-preprocess ()
  (save-excursion
    (goto-char (point-min))
    (java-scrapbook-substitute-buffer *java-scrapbook-substitute-alist*)))

(defun java-scrapbook-substitute-buffer (sub-alist)
  (when sub-alist
    (save-excursion
      (replace-buffer (caar sub-alist) (cdar sub-alist) :regexp t))
    (java-scrapbook-substitute-buffer (cdr sub-alist))))

(defun java-scrapbook-execute-scrap (command output dir &optional msg)
  (long-operation
    (progn
      (let ((buffer (get-buffer-create output)))
        (set-buffer buffer)
        (when *java-scrapbook-erase-output-buffer*
          (erase-buffer (selected-buffer)))
        (goto-char (point-max))
        (insert (format nil "> ~A~%" command))
        (message "~A" (or msg command))
        (make-process command :output buffer :exec-directory dir)
        (java-scrapbook-wait-for-exit-process (buffer-process buffer))))))

(defun java-scrapbook-wait-for-exit-process (proc &optional (interval 0.1))
  (while (eq (process-status proc) ':run)
    (sit-for interval))
  (process-exit-code proc))

(defun java-scrapbook-javac-command ()
  (java-scrapbook-as-string *java-scrapbook-javac-command*))

(defun java-scrapbook-java-command ()
  (java-scrapbook-as-string *java-scrapbook-java-command*))

;;
;; eclipse classpath
;;

(defun java-scrapbook-classpath ()
  (let ((classpath (list (java-scrapbook-as-string *java-scrapbook-classpath*))))
    (when *java-scrapbook-search-eclipse-classpath-p*
      (setf classpath (append (java-scrapbook-eclipse-classpath-entry
                               (java-scrapbook-eclipse-classpath-file))
                              classpath)))
    (java-scrapbook-join ";" classpath)))

;; <classpathentry kind="lib" path="D:/opt/java/junit3.8.1/junit.jar" sourcepath="D:/opt/java/junit3.8.1/src.jar"/>
;; <classpathentry kind="lib" path="lib/xsdlib.jar"/>
;; <classpathentry kind="output" path="build/classes"/>
(defun java-scrapbook-eclipse-classpath-entry (dot-classpath)
  (unless dot-classpath
    (return-from java-scrapbook-eclipse-classpath-entry))
  (let (buffer result)
    (unwind-protect
        (progn
          (setf buffer (create-new-buffer *java-scrapbook-temp-buffer-name*))
          (set-buffer buffer)
          (insert-file-contents dot-classpath)
          (goto-char (point-min))
          (while (scan-buffer "kind=\"\\(lib\\|output\\)\" +path=\"\\([^\"]+\\)\""
                              :regexp t :tail t)
            (push (match-string 2) result)))
      (delete-buffer buffer))
    ;; map to fullpath
    (mapcar #'(lambda (lib)
                (if (string-matchp "[a-z]:/" lib)
                    lib
                  (merge-pathnames lib (directory-namestring dot-classpath))))
            result)))

(defun java-scrapbook-eclipse-classpath-file
  (&optional (dir (directory-namestring (or (get-buffer-file-name) ""))))
  (when dir
    (if (file-exist-p (merge-pathnames ".classpath" dir))
        (merge-pathnames ".classpath" dir)
      (java-scrapbook-eclipse-classpath-file (java-scrapbook-parent-directory dir)))))

;;
;; util
;;

(defun java-scrapbook-as-string (something)
  (cond ((null something)
         "")
        ((stringp something)
         something)
        ((listp something)
         (format nil "~A" (mapcar #'java-scrapbook-as-string something)))
        ((functionp something)
         (java-scrapbook-as-string (funcall something)))
        ((characterp something)
         (format nil "~A" something))
        (t
         (format nil "~S" something))))

(defun java-scrapbook-gsub (re str fn)
  (unless (and re str)
    (return-from java-scrapbook-gsub str))
  (let ((result))
    (labels ((java-scrapbook-gsub-internal (re str fn start)
               (if (string-match re str start)
                   (progn
                     (push (substring str start (match-beginning 0)) result)
                     (if fn (push (funcall fn (match-string 0)) result))
                     (java-scrapbook-gsub-internal re str fn (match-end 0)))
                 (push (substring str start) result))))
      (java-scrapbook-gsub-internal re str fn 0))
    (format nil "~{~A~}" (reverse result))))

(defun java-scrapbook-parent-directory (dir)
  (multiple-value-bind (result count)
      (substitute-string (map-backslash-to-slash dir) "[^/]+/?$" "")
    (if (or (zerop count)
            (zerop (length result)))
        nil
      result)))

(defun java-scrapbook-delete-directory-recursive (dir)
  (dolist (file (directory dir))
    (if (file-directory-p file)
        (java-scrapbook-delete-directory-recursive file)
      (delete-file (merge-pathnames file dir))))
  (delete-directory dir))

(defun java-scrapbook-join (sep l)
  (format nil (concat "~A~{" sep "~A~}") (car l) (cdr l)))

;;
;; $Id: java-scrapbook.l,v 1.11 2004/09/13 17:02:06 miyamuko Exp $
;;
