; -*- Mode: Lisp; Package: editor -*-

#|
= banner - 大きな文字で文字列を出力する

* Author:  miyamuko ((<URL:mailto:miyamuko (at) mtb.biglobe.ne.jp>))
* URL: ((<URL:http://miyamuko.s56.xrea.com/xyzzy/banner.html>))
* Version: $Id: banner.l,v 1.7 2004/08/09 14:02:59 miyamuko Exp $


== 説明

Unix にある banner コマンドの移植です。

BDF フォントさえあれば日本語だろうが AA だろうが巨大にできます。


== インストール

((<NetInstaller|URL:http://www.mirai.ne.jp/~gyo/xyzzy/ni.html>)) でインストールした場合は 3 以降を、
NetInstaller + (({ni-autoload})) を使っている人は 4 以降で OK です。

(1) アーカイブをダウンロードします。

    ((<URL:http://miyamuko.s56.xrea.com/xyzzy/archives/banner.zip>))

(2) アーカイブを展開して、$XYZZY/site-lisp 配下にファイルをコピーします。

(3) ~/.xyzzy または $XYZZY/site-lisp/siteinit.l に以下のコードを追加します。

        ;; banner
        (require "banner")

(4) 設定を反映させるため xyzzy を再起動してください。

    ※siteinit.l に記述した場合には再ダンプが必要です。

(5) BDF フォントをなにかインストールします。

(6) BDF フォントにあわせて ((<*banner-bdf-font-selecter*>)) を設定します。

(7) 巨大化したい部分をリージョンにして M-x banner-region または
    M-x banner でミニバッファから入力してください。


== リファレンス

=== コマンド

--- (banner str)

    指定された文字列を大きくして ((<*banner-output-buffer-name*>)) に
    出力します。

--- (banner-region start end)

    指定されたリージョンの文字列を大きくして ((<*banner-output-buffer-name*>)) に
    出力します。


=== 関数

--- (ed::banner-internal str &optional formatter)

    指定された文字列を大きくして ((<*banner-output-buffer-name*>)) に
    出力します。

    省略可能な第2引数には以下の出力関数を指定します。
    デフォルトは (({ed::banner-output-horizontally})) です。

--- (ed::banner-output-vertically glyphs)

    縦書きで banner を出力します。
    (({ed::banner-internal})) の引数に指定します。

--- (ed::banner-output-horizontally glyphs)

    横書きで banner を出力します。
    (({ed::banner-internal})) の引数に指定します。


=== 変数

--- *bdf-directory-list*

    BDF フォントを置いておくディレクトリを指定します。
    デフォルトは $XYZZY/fonts/bdf です。

        ;; Meadow さんの font directory を追加
        (pushnew "D:/Tools/Meadow/fonts/bdf" *bdf-directory-list*)

--- *banner-output-buffer-name*

    出力バッファの名前をしています。

--- *banner-font-fg-char*
--- *banner-font-bg-char*

    それぞれフォントを形成する文字と背景を設定します。

        ;; 四角でレイアウトする
        (setf *banner-font-fg-char* "■")
        (setf *banner-font-bg-char* "□")

    こうなる

        □□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□
        ■□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□
        ■□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□
        ■□■■□□□■■■□□■□■■□□■□■■□□□■■■□□■□■□
        ■■□□■□■□□□■□■■□□■□■■□□■□■□□□■□■■□□
        ■□□□■□□□□■■□■□□□■□■□□□■□■□□□■□■□□□
        ■□□□■□□■■□■□■□□□■□■□□□■□■■■■■□■□□□
        ■□□□■□■□□□■□■□□□■□■□□□■□■□□□□□■□□□
        ■■□□■□■□□■■□■□□□■□■□□□■□■□□□■□■□□□
        ■□■■□□□■■□■□■□□□■□■□□□■□□■■■□□■□□□
        □□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□
        □□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□

--- *banner-bdf-font-selecter*

    ある文字に対応する BDF フォントのファイル名を返す
    関数を設定します。

    ((*この変数は必ず設定してください。*))

        ;; monafont を利用する
        (setf *banner-bdf-font-selecter*
              #'(lambda (c)
                  (cond ((kanji-char-p c)
                         ; 漢字、ひらがな、カタカナ
                         "monak12.bdf")
                        ((kana-char-p c)
                         ; いわゆる半角カナ
                         "mona6x12r.bdf")
                        (t
                         ; その他
                         "mona6x12a.bdf"))))

        ;; K12 を利用する
        (setf *banner-bdf-font-selecter*
              #'(lambda (c)
                  (cond ((kanji-char-p c)
                         ; 漢字、ひらがな、カタカナ
                         "k12x10.bdf")
                        (t
                         ; その他
                         "k6x10.bdf"))))

    フォントをころころ変えたい場合はキャッシュも消したほうがいいです。

        ; キャッシュを消す
        (setf ed::*bdf-glyph-cache* nil)


== これからやるかもしれないこと

* BDF フォントの encoding をちゃんと見るようにする。
  * 今は sjis 決め打ちだった気がする。
* TrueType フォントも使えるようにする (したい)。
  * Win32 API をがんばってたたけばできるかなぁ...?
* ttf2bdf で変換した bdf フォントも使えるようにする。
  * むかし失敗した記憶がする。
* フォントの設定をもう少しまともにする。


== 関連するかもしれないページ

: BDFファイルフォーマット
    ((<URL:http://hp.vector.co.jp/authors/VA013241/font/bdf.html>))

: モナーフォント
    ((<URL:http://monafont.sourceforge.net/>))

: (X11 を中心とした)フリーの日本語ビットマップフォント一覧
    ((<URL:http://kappa.allnet.ne.jp/kanou/fonts/x11bdfs.html>))


== ライセンス

banner は修正 BSD ライセンスに基づいて利用可能です。

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

(provide "banner")
(in-package "editor")

(export '(*bdf-directory-list*
          *banner-output-buffer-name*
          *banner-font-fg-char*
          *banner-font-bg-char*
          *banner-bdf-font-selecter*
          banner
          banner-vertically
          banner-region
          banner-region-vertically))

;; ----------------------------------------------------------------------
;; variables

(defvar *bdf-directory-list*
  (list (merge-pathnames "fonts/bdf" (si::system-root))))
(defvar *banner-output-buffer-name* "*banner*")
(defvar *banner-font-fg-char* "##")
(defvar *banner-font-bg-char* "  ")
(defvar *banner-bdf-font-selecter* nil)


;; ----------------------------------------------------------------------
;; commands

(defun banner (str &optional fold-width)
  "banner: 指定された文字列を banner 化 (横書き)"
  (interactive "sBanner: \np")
  (banner-internal str fold-width))

(defun banner-vertically (str)
  "banner: 指定された文字列を banner 化 (縦書き)"
  (interactive "sBanner: ")
  (banner str 1))

(defun banner-region (start end &optional fold-width)
  "banner: 指定されたリージョンの文字列を banner 化 (横書き)"
  (interactive "r\np")
  (if (< end start) (rotatef start end))
  (banner-internal (buffer-substring start end) fold-width))

(defun banner-region-vertically (start end)
  "banner: 指定されたリージョンの文字列を banner 化 (縦書き)"
  (interactive "r")
  (banner-region start end 1))

;; ----------------------------------------------------------------------
;; functions

(defmacro dolist-with-progress-message ((msg var listform &optional (resultform ''nil)) &body body)
  `(let ((len (length ,listform))
         (current 0))
     (do* ((#1=#:tailvar ,listform (cdr #1#))
           (,var (car #1#) (car #1#)))
         ((null #1#) ,resultform)
       (incf current)
       (message ,msg (floor (* (/ current len) 100)))
       ,@body)))

(defun banner-internal (str fold-width)
  "banner: 指定された文字列を banner 化"
  (unless *banner-bdf-font-selecter*
    (error "*banner-bdf-font-selecter* を設定してくださいな"))
  (long-operation
    (with-output-to-temp-buffer (*banner-output-buffer-name*)
      (dolist-with-progress-message
       ("~D %" line (split-string str #\LFD))
       (do-events)
       (banner-output (map 'list 'bdf-get-glyph line) fold-width))))
  (switch-to-buffer *banner-output-buffer-name*))

(defun banner-output (glyphs &optional fold-width)
  "banner: フォントを出力する"
  (let ((p 0)
        (glyph-len (length glyphs)))
    (unless fold-width
      (setf fold-width glyph-len))
    (while (< p glyph-len)
      (apply #'mapcar #'(lambda (&rest line)
                          (format t "~{~A~}" line)
                          (terpri))
             (subseq glyphs p (min glyph-len (+ p fold-width))))
      (incf p fold-width))))

(defun banner-dispose ()
  (interactive)
  (setf *bdf-glyph-cache* nil)
  (bdf-kill-all-buffers))

;;

(defvar *bdf-glyph-cache* nil
  "banner: 読み込んだフォント情報のキャッシュ")

(defun bdf-get-glyph (c)
  "banner: キャッシュにあればそのフォント情報を返す"
  (let ((jis-code (char-jis-code c)))
    (unless *bdf-glyph-cache*
      (setf *bdf-glyph-cache* (make-hash-table)))
    (unless (gethash jis-code *bdf-glyph-cache*)
      (setf (gethash jis-code *bdf-glyph-cache*)
            (bdf-get-glyph-internal
             (bdf-find-file (funcall *banner-bdf-font-selecter* c))
             jis-code)))
    (gethash jis-code *bdf-glyph-cache*)))

(defun bdf-get-glyph-internal (bdfbuffer jis-code)
  "banner: BDF ファイルを解析してフォント情報を取得"
  (let ((width nil)
        (result))
    ;; setup buffer
    (set-buffer bdfbuffer)
    (goto-char (point-min))

    ;; scan glyph
    (unless (scan-buffer (format nil "^ENCODING ~D\\>" jis-code) :regexp t)
      ;; use DEFAULT_CHAR if not found.
      (if (scan-buffer "^DEFAULT_CHAR \\([0-9]+\\)\\>" :regexp t)
          (return-from bdf-get-glyph-internal
            (bdf-get-glyph bdfbuffer
                           (code-char (parse-integer (match-string 1)))))
        nil))

    ;; clipping
    (save-restriction
      (narrow-to-region (point)
                        (progn
                          (scan-buffer "^ENDCHAR\\>" :regexp t :tail t)
                          (point)))
      (goto-char (point-min))

      ;; get width
      (scan-buffer (format nil "^DWIDTH +\\([0-9]+\\) +[0-9]+" jis-code)
                   :regexp t :tail t)
      (setf width (parse-integer (match-string 1)))

      ;; get glyph info
      (scan-buffer "^BITMAP\\>" :regexp t)
      (while (and (forward-line 1)
                  (not (looking-at "^ENDCHAR\\>")))
        (push (bdf-expand-glyph width
                                (buffer-substring (progn (goto-bol) (point))
                                                  (progn (goto-eol) (point))))
              result))
      (reverse result))))

(defun bdf-expand-glyph (width hex)
  "banner: BDF Font の情報を展開する"
  (substitute-string
   (substitute-string
    (substring (format nil "~V,'0B" width (hex-to-int hex))
               0 width)
    "1" *banner-font-fg-char*)
   "0" *banner-font-bg-char*))

(defvar *bdf-find-file-buffers* nil
  "banner: open した BDF font の buffer")

(defun bdf-find-file (bdfname)
  "banner: 指定された BDF font を font path から探し buffer に読み込む。
argument: フォント名
return: フォントを読み込んだ buffer"
  (let ((bufname (concat " " bdfname)))
    (if (find-buffer bufname)
        (return-from bdf-find-file (find-buffer bufname)))
    (dolist (dir *bdf-directory-list*)
      (when (file-exist-p (merge-pathnames bdfname dir))
        (let ((buffer (get-buffer-create bufname)))
          (set-buffer buffer)
          (insert-file (merge-pathnames bdfname dir))
          (push buffer *bdf-find-file-buffers*) ;cache
          (return-from bdf-find-file buffer))))
    (error "BDF Font がないです" bdfname)))

(defun bdf-kill-all-buffers ()
  "banner: 読み込んだ BDF font をすべて削除する。"
  (dolist (buffer *bdf-find-file-buffers*)
    (if (member buffer (buffer-list))
        (delete-buffer buffer)))
  (setf *bdf-find-file-buffers* nil))

;; ----------------------------------------------------------------------
;; util

(defun char-jis-code (c)
  "banner: 文字を JIS コードに変換する"
  (if (kanji-char-p c)
      (let ((jis (map-internal-to-jis (string c))))
        (logior (ash (char-code (char jis 3)) 8)
                (char-code (char jis 4))))
    (char-code c)))

(defun hex-to-int (hex)
  "banner: 16進文字列を 10 進数値にする"
  (let ((result 0)
        (digits (map 'list
                     #'(lambda (c)
                         (cond ((char<= #\0 c #\9)
                                (- (char-code c) (char-code #\0)))
                               ((char<= #\a (char-downcase c) #\f)
                                (+ 10 (- (char-code (char-downcase c))
                                         (char-code #\a))))))
                     hex)))
    (dolist (d digits)
      (if d (setf result (+ (ash result 4) d))))
    result))

;;
;; $Id: banner.l,v 1.7 2004/08/09 14:02:59 miyamuko Exp $
;;
