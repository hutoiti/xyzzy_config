; -*- Mode: Lisp; Package: editor -*-

#|
= natural-compare - xyzzy で自然順ソート

* Authror: MIYAMUKO Katsuyuki ((<URL:mailto:miyamuko (at) mtb.biglobe.ne.jp>))
* URL: ((<URL:http://miyamuko.s56.xrea.com/xyzzy/natural-compare.html>))
* Version: $Id: natural-compare.l,v 1.3 2005/07/09 20:00:20 miyamuko Exp $

== 説明

xyzzy で自然順ソートを行うためのライブラリです。

※ natural-compare はライブラリでありユーザが直接利用するものではありません。

== 使用例

* 連番つきのファイル名のソート

    (sort '("rfc822.txt" "rfc1.txt" "rfc2086.txt") #'natural<)
    ("rfc1.txt" "rfc822.txt" "rfc2086.txt")

* バージョン番号のソート

    (sort '("1.3" "1.1" "1.02" "1.010" "1.002" "1.001") #'natural<)
    ("1.001" "1.002" "1.010" "1.02" "1.1" "1.3")

* IP アドレスのソート

    (sort '("20.30.40.50" "100.1.1.1" "192.168.10.10" "192.168.2.20") 'natural<)
    ("20.30.40.50" "100.1.1.1" "192.168.2.20" "192.168.10.10")

== インストール

((<NetInstaller|URL:http://www.mirai.ne.jp/~gyo/xyzzy/ni.html>)) でインストールした場合は
3 以降で OK です。

(1) アーカイブをダウンロードします。

    ((<URL:http://miyamuko.s56.xrea.com/xyzzy/archives/natural-compare.zip>))

(2) アーカイブを展開して、$XYZZY/site-lisp 配下にファイルをコピーします。

(3) ~/.xyzzy または $XYZZY/site-lisp/siteinit.l に以下のコードを追加します。

        ;; natural-compare
        (require "natural-compare")

(4) 設定を反映させるには xyzzy を再起動してください。

    ※siteinit.l に記述した場合には再ダンプが必要です。


== リファレンス

--- natural-compare

    natural-compare a b &optional case-fold => -1 or 0 or 1

    自然順に比較して a と b が同じなら 0、
    a が小さいなら負数を
    a が b より大きいなら正数を返します。

--- natural=

    Syntax:

        natural= a b => t or nil

    空白文字を無視して比較します。
    大文字小文字の違いは区別します。

    Examples:

        (natural= "rfc1.txt" "rfc1 .txt")
        t
        (natural= "rfc1.txt" "rfc01.txt")
        nil
        (natural= "rfc1.txt" "RFC1.txt")
        nil

--- natural<

    Syntax:

        natural< a b => t or nil

    自然順に比較して a が小さい場合に t を返します。
    大文字小文字の違いは区別します。

    Examples:

        (natural< "rfc1.txt" "rfc1 .txt")
        nil
        (natural< "rfc1.txt" "RFC1.txt")
        nil
        (natural< "rfc1.txt" "rfc01.txt")
        nil
        (natural< "rfc01.txt" "rfc1.txt")
        t
        (natural< "rfc01.txt" "rfc02.txt")
        t

--- natural>

    Syntax:

        natural> a b => t or nil

    自然順に比較して a が大きい場合に t を返します。
    大文字小文字の違いは区別します。

    Examples:

        (natural> "rfc1.txt" "rfc1 .txt")
        nil
        (natural> "rfc1.txt" "rfc01.txt")
        t
        (natural> "rfc01.txt" "rfc1.txt")
        nil
        (natural> "rfc01.txt" "rfc02.txt")
        nil

--- natural-equal

    Syntax:

        natural-equal a b => t or nil

    ((< natural= >)) の大文字小文字を区別しない版

--- natural-lessp

    Syntax:

        natural-lessp a b => t or nil

    ((< natural< >)) の大文字小文字を区別しない版

--- natural-greaterp

    Syntax:

        natural-greaterp a b => t or nil

    ((< natural> >)) の大文字小文字を区別しない版


== これからやるかもしれないこと

* x2-g8 < x2-y08 < x2-y7 < x8-y8 となるのをどうにかする。
  leading zeros を無視するオプションがあればいいのかなぁ。


== 関連するかもしれないページ

: Natural Order Numerical Sorting
    ((<URL:http://www.naturalordersort.org/>))

: Natural Order String Comparison
    ((<URL:http://sourcefrog.net/projects/natsort/>))


== ライセンス

natural-compare は修正 BSD ライセンスに基づいて利用可能です。

  Copyright (C) 2005 MIYAMUKO Katsuyuki. All rights reserved.

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

(provide "natural-compare")
(in-package "editor")

(export '(natural-compare
          natural=
          natural<
          natural>
          natural-equal
          natural-lessp
          natural-greaterp))

(defun natural-compare (a b &key case-fold)
  (labels ((split (str)
             (let (r)
               (while (and (< 0 (length str))
                           (string-match "^\\([^0-9]*\\)\\([0-9]*\\)\\(.*\\)" str))
                 (push (cons (match-string 1) (match-string 2)) r)
                 (setf str (match-string 3)))
               (reverse r)))
           (strip (str)
             (substitute-string str "[ \t]+" "")))
    (when (string= a b)
      (return-from natural-compare 0))
    (setf a (strip a)
          b (strip b))
    (when case-fold
      (setf a (string-downcase a)
            b (string-downcase b)))
    (when (string= a b)
      (return-from natural-compare 0))
    (natural-compare0 (split a) (split b))))

(defun natural-compare0 (alist blist)
  (when (and (null alist) (null blist))
    (return-from natural-compare0 0))
  (case (natural-compare-test (car alist) (car blist))
    (0
     (case (if (and (< 0 (length (cdar alist)))
                    (< 0 (length (cdar blist)))
                    (not (char= (char (cdar alist) 0) #\0))
                    (not (char= (char (cdar blist) 0) #\0)))
               (natural-compare-test (car alist) (car blist)
                                     :test< #'< :test> #'>
                                     :key #'(lambda (s)
                                              (and s (parse-integer (cdr s) :junk-allowed t))))
             (natural-compare-test (car alist) (car blist) :key #'cdr))
       (0 (natural-compare0 (cdr alist) (cdr blist)))
       (-1 -1)
       (1 1)))
    (-1 -1)
    (1 1)))

(defun natural-compare-test (apair bpair &key (key #'car) (test< #'string<) (test> #'string>))
  (let ((a (funcall key apair))
        (b (funcall key bpair)))
    (cond ((and (null a) (null b))
           0)
          ((and (null a) (not (null b)))
           -1)
          ((and (not (null a)) (null b))
           1)
          ((funcall test< a b) -1)
          ((funcall test> a b) 1)
          (t 0))))

(defun natural= (a b)
  (= (natural-compare a b) 0))

(defun natural< (a b)
  (< (natural-compare a b) 0))

(defun natural> (a b)
  (> (natural-compare a b) 0))

(defun natural-equal (a b)
  (= (natural-compare a b :case-fold t) 0))

(defun natural-lessp (a b)
  (< (natural-compare a b :case-fold t) 0))

(defun natural-greaterp (a b)
  (> (natural-compare a b :case-fold t) 0))

;;
;; $Id: natural-compare.l,v 1.3 2005/07/09 20:00:20 miyamuko Exp $
;;
