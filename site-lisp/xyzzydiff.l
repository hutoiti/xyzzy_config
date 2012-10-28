; -*- Mode: Lisp; Package: editor -*-

#|
= xyzzydiff - コマンドラインから指定したファイルを diff する

* Author:  miyamuko ((<URL:mailto:miyamuko (at) mtb.biglobe.ne.jp>))
* URL: ((<URL:http://miyamuko.s56.xrea.com/xyzzy/xyzzydiff.html>))
* Version: $Id: xyzzydiff.l,v 1.3 2004/08/09 14:03:28 miyamuko Exp $


== 説明

コマンドラインから指定した 2 つのファイルを diff します。

  > xyzzydiff old-file new-file

((<"TortoiseCVS"|URL:http://www.tortoisecvs.org/>)) の External diff application
などに指定すると少し幸せになれます。

* 指定したファイルが 1 つの場合は普通に開きます。
* 指定したファイルが 3 つ以上の場合は最初の 2 つを diff し残りは普通に開きます。
* -l や -e などの通常の xyzzy の引数も同時に指定可能です。


== インストール

((<NetInstaller|URL:http://www.mirai.ne.jp/~gyo/xyzzy/ni.html>)) でインストールした場合は
4 以降で OK です。

(1) アーカイブをダウンロードします。

    ((<URL:http://miyamuko.s56.xrea.com/xyzzy/archives/xyzzydiff.zip>))

(2) アーカイブを展開して、$XYZZY/site-lisp 配下にファイルをコピーします。

(3) xyzzycli.exe を xyzzydiff.exe という名前でコピーします。

(4) $XYZZY/site-lisp/siteinit.l に以下のコードを追加します。

        ; xyzzydiff
        (require "xyzzydiff")

    ※必ず siteinit.l に追加してください。.xyzzy だと動作しません。

(5) 設定を反映させるには xyzzy を再ダンプしてください。

(6) ((%xyzzydiff oldfile newfile%)) で diff を取ります。


== リファレンス

=== 変数

--- *diff-command-line-hook*
    diff の実行前に実行するフックです。

    diff するファイル名を引数 (old, new の順) に run-hook-with-args で実行します。

    例:
        (add-hook '*diff-command-line-hook* #'(lambda (old new)
                                                (msgbox "diff: ~A ~A" old new)))

=== xyzzydiff.ini

通常の設定では既に xyzzy が起動している場合、その xyzzy で diff を実行します。
常に xyzzy を新規に起動したい場合は xyzzydiff.ini で (({multipleInstances=1})) を設定してください。

    [xyzzy]
    precedingOptions="-f diff-command-line-setup"
    followingOptions="-f diff-command-line-teardown"
    multipleInstances=1


== これからやるかもしれないこと

* なし?


== ライセンス

xyzzydiff は修正 BSD ライセンスに基づいて利用可能です。

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

(provide "xyzzydiff")
(in-package "editor")

(export '(diff-command-line-setup
          diff-command-line-teardown
          *diff-command-line-hook*))

(defvar *diff-command-line-hook* nil)
(defvar *diff-command-line-file-list* nil)

(defun diff-process-command-line (file)
  "コマンドラインオプションをちゃんと処理するため
*process-command-line-hook* で渡された引数だけを
*diff-command-line-file-list* に集める。"
  (setf *diff-command-line-file-list*
        (append *diff-command-line-file-list* (list file))))

(defun diff-command-line-setup ()
  (setf *diff-command-line-file-list* nil)
  (add-hook '*process-command-line-hook* 'diff-process-command-line))

(defun diff-command-line-teardown ()
  "*diff-command-line-file-list* に最初の 2 つの引数を diff する。
残りの引数は普通に処理する。"
  (delete-hook '*process-command-line-hook* 'diff-process-command-line)
  (when (<= 2 (length *diff-command-line-file-list*))
    (let ((old (pop *diff-command-line-file-list*))
          (new (pop *diff-command-line-file-list*)))
      (run-hook-with-args '*diff-command-line-hook* old new)
      ; xyzzy の diff は new old の順
      (diff new old)))
  (unless (zerop (length *diff-command-line-file-list*))
    (setf si:*command-line-args* *diff-command-line-file-list*)
    (process-command-line)))

;;
;; $Id: xyzzydiff.l,v 1.3 2004/08/09 14:03:28 miyamuko Exp $
;;
