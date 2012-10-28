; -*- Mode: Lisp; Package: editor -*-

#|
= xyzzytail - コマンドラインから指定したファイルを tail-f する

* Author:  miyamuko ((<URL:mailto:miyamuko (at) mtb.biglobe.ne.jp>))
* URL: ((<URL:http://miyamuko.s56.xrea.com/xyzzy/xyzzytail.html>))
* Version: $Id: xyzzytail.l,v 1.4 2004/08/09 14:24:52 miyamuko Exp $


== 説明

コマンドラインで指定したファイルを tail-f します。

  > xyzzytail logfile ...

send-to に入れておくと少し幸せになるかも知れません。

* -l や -e などの通常の xyzzy の引数も同時に指定可能です。


== インストール

((<NetInstaller|URL:http://www.mirai.ne.jp/~gyo/xyzzy/ni.html>)) でインストールした場合は
4 以降で OK です。

(1) アーカイブをダウンロードします。

    ((<URL:http://miyamuko.s56.xrea.com/xyzzy/archives/xyzzytail.zip>))

(2) アーカイブを展開して、$XYZZY/site-lisp 配下にファイルをコピーします。

(3) xyzzycli.exe を xyzzytail.exe という名前でコピーします。

(4) $XYZZY/site-lisp/siteinit.l に以下のコードを追加します。

        ; xyzzytail
        (require "xyzzytail")

    ※必ず siteinit.l に追加してください。.xyzzy だと動作しません。

(5) 設定を反映させるには xyzzy を再ダンプしてください。

(6) ((%xyzzytail logfile ...%)) で指定されたファイルをすべて tail-f します。


== リファレンス

=== 変数

--- *tail-f-command-line-hook*
    tail-f の実行前に実行するフックです。

    tail-f するファイル名を引数に run-hook-with-args で実行します。
    指定したファイルの数だけ実行されます。

    ex)
        (add-hook '*tail-f-command-line-hook* #'(lambda (logfile)
                                                  (msgbox "tail-f: ~A" logfile)))

=== xyzzytail.ini

通常の設定では既に xyzzy が起動している場合、その xyzzy で tail-f を実行します。
常に xyzzy を新規に起動したい場合は xyzzytail.ini で (({multipleInstances=1})) を設定してください。

    [xyzzy]
    precedingOptions="-f tail-f-command-line-setup"
    followingOptions="-f tail-f-command-line-teardown"
    multipleInstances=1


== これからやるかもしれないこと

* なし?


== ライセンス

xyzzytail は修正 BSD ライセンスに基づいて利用可能です。

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

(provide "xyzzytail")
(in-package "editor")

;; -f で実行する関数は user に export しないとだめ
(export '(tail-f-command-line-setup
          tail-f-command-line-teardown
          *tail-f-command-line-hook*))

(defvar *tail-f-command-line-hook* nil)

(defun tail-f-command-line (file)
  (run-hook-with-args '*tail-f-command-line-hook* file)
  (tail-f file))

(defun tail-f-command-line-setup ()
  (add-hook '*process-command-line-hook* 'tail-f-command-line))

(defun tail-f-command-line-teardown ()
  (delete-hook '*process-command-line-hook* 'tail-f-command-line))

;;
;; $Id: xyzzytail.l,v 1.4 2004/08/09 14:24:52 miyamuko Exp $
;;
