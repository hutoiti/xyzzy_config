(provide "key-chord")
(in-package "editor")

(defun key-chord-version nil
  (interactive)
  (and (interactive-p)
       (message "key-chord lapse ~A on 2009-01-31 21:46" (key-chord-version)))
  "004")

#| key-chord for xyzzy-0.2.2.235

Copyright (c) 2009 knenet \kneneglect_std(^o^)yahoo.co.jp/

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

MITライセンスです。著作者を明らかにすれば適当に使って良いです。
このソフトの使用によって生じた損益について、著作者は一切責任を持ちません。

■概要

２鍵同時押しコマンドが実行できるようになります。
f+j → end-of-line とか出来るようになります。
emacsのkey-chord.elが便利だと聞いて作りましたが、
ソースは見てないので仕様・ライセンスに互換性はありません。

■導入

(require "key-chord")
(toggle-key-chord t)
を.xyzzyにでも書きます。
このファイルを~/site-lispに入れてバイトコンパイルします。
netinstallerを用いてインストールしたならここまでは不要です。

.xyzzyに
(define-key-chord '(#\f #\j) 'end-of-line)
とか書きます。標準では何も登録されていないので、好きなだけ登録します。
x.xyzzyを評価すれば使えます。

■設定

同時入力の受付時間は ed::*key-chord-interval* で変更できます。
単位はミリ秒です。初期設定は16msです。

受付条件はed::*key-chord-test*にlambda式で記述します。
最初に読み込んだ文字を引数に判定します。
入力受付中は連続入力が効かなくなったり、入力文字が減ったりするので、
それが不便な場合にはnilを返して停止させます。

toggle-key-chordで動作をon/offできます。

■todo

コマンド一覧表示
モード毎にコマンド登録

■履歴
004 2009-01-31 21:46 キーを入力せずに実行した際にエラーになるバグを修正。
003 2009-01-28 19:11 不適切な説明を修正。
002 2009-01-04 16:51 同時打鍵数を２より大きくできるように。mapをハッシュに。
                     受付条件を柔軟に。
001 2009-01-03 18:52 できた。

説明終わり|#

(defvar *key-chord-test*
  (lambda (x) (and (not (get-ime-mode))
				   (= (char-columns x) 1))))
(defvar *key-chord-map* nil)
(unless *key-chord-map*
  (setq *key-chord-map* (make-hash-table :test 'equal :size 37)))
(defvar *key-chord-interval* 16)
(defvar *key-chord-max-length* 4)
(setq *key-chord-stack* nil)

(export '(toggle-key-chord define-key-chord))

(defun key-chord ()
  "同時押しコマンドが実行できる。"
  (let ((time (get-internal-real-time))
		(a *last-command-char*)
		c cmd)
	(when (and (null *key-chord-stack*)
			   (not *executing-macro*)
			   (funcall *key-chord-test* a))
	  (while (and (< (1+ (length c)) *key-chord-max-length*)
				  (<= (- (get-internal-real-time) time) *key-chord-interval*))
		(let ((key (read-char-no-hang *keyboard*)))
		  (when key (push key c) (do-events))))
	  (if c
		  (if (setq cmd (gethash (stable-sort (append (list a) (copy-list c)) 'char<)
								 *key-chord-map*))
			  (setq *this-command* cmd)
			(progn (setq *key-chord-stack* (reverse c)) (refresh-screen)))
		))))

(defun key-chord-post ()
  (let ((key (pop *key-chord-stack*)))
	(if key (unread-char key))))

(defun toggle-key-chord (&optional (tgl nil g))
  "同時押し入力を切り替える。"
  (interactive)
  (if g
	  (if (eq tgl t)
		  (progn
			(add-hook '#1=*pre-command-hook* '#2=key-chord)
			(add-hook '#3=*post-command-hook* '#4=key-chord-post))
		(progn
		  (delete-hook '#1# '#2#)
		  (delete-hook '#3# '#4#)))
	(if (find '#2# #1#)
		(toggle-key-chord nil)
	  (toggle-key-chord t))))

(defun define-key-chord (keys cmd)
  "同時押しコマンドを登録する。"
  (setf (gethash (stable-sort keys 'char<) *key-chord-map*) cmd))

;end of file key-chord.l