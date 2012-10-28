; -*- Mode: Lisp; Package: editor -*-

#|
= ci-mode - しぃ(*ﾟーﾟ)言語用モード

* Author:  miyamuko ((<URL:mailto:miyamuko (at) mtb.biglobe.ne.jp>))
* URL: ((<URL:http://miyamuko.s56.xrea.com/xyzzy/ci-mode.html>))
* Version: $Id: ci-mode.l,v 1.7 2004/08/09 14:03:03 miyamuko Exp $


== 説明

しぃ(*ﾟーﾟ)言語用の編集モードです。
今のところ以下のことができます。

* 適当な色づけ
* キーワードの補完

そのうち実行できるようになっていたり、いなかったりするかもしれません。


== インストール

((<NetInstaller|URL:http://www.mirai.ne.jp/~gyo/xyzzy/ni.html>)) でインストールした場合は 3 以降を、
NetInstaller + (({ni-autoload})) を使っている人は 4 以降で OK です。

(1) アーカイブをダウンロードします。

    ((<URL:http://miyamuko.s56.xrea.com/xyzzy/archives/ci-mode.zip>))

(2) アーカイブを展開して、$XYZZY/site-lisp 配下にファイルをコピーします。

(3) 拡張子が ー のファイルを開いたときに自動的に ci-mode になるように
    ~/.xyzzy または $XYZZY/site-lisp/siteinit.l に以下のコードを追加します。

        ;; ci-mode
        (require "ci-mode")
        (pushnew '("\\.ー$" . ci-mode) *auto-mode-alist* :test 'equal)

(4) 設定を反映させるため xyzzy を再起動してください。

    ※siteinit.l に記述した場合には再ダンプが必要です。


== リファレンス

=== キー割り当て

: ((%M-TAB%))
    キーワードの補完。


== これからやるかもしれないこと

(1) インタプリタを作る。


== 関連するかもしれないページ

: しぃ言語を作ろう！
    ((<URL:http://www.geocities.co.jp/SiliconValley-PaloAlto/2423/index.html>))


== ライセンス

ci-mode は修正 BSD ライセンスに基づいて利用可能です。

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

(provide "ci-mode")
(in-package "editor")

(export '(*ci-mode-hook*
          *ci-mode-map*
          ci-completion
          ci-mode
          ))

(defvar *ci-completion-list* nil
  "ci-mode: 補完リストのポップアップ")

(defvar *ci-keyword-hash-table* nil)
(defvar *ci-keyword-file* "Ci") ; キーワードファイル名
(defvar *ci-comment-regexp*
  "(´-`).｡ｏO.*$")
(defvar *ci-keyword-char*
  "(´-`).｡ｏO.|( ﾟдﾟ)|＜寝る！( ﾟДﾟ)( ﾟωﾟ)( ･∀･)(ﾟДﾟ)ﾏｽﾞー(ﾟДﾟ)ｳﾏー(*ﾟヮﾟ)[ :(*ﾟヮﾟ)< :")

(defvar *ci-regexp-keyword-list* nil
  "ci-mode: 正規表現キーワードリスト")
(setf *ci-regexp-keyword-list*
      (compile-regexp-keyword-list
       `((,*ci-comment-regexp* t :comment)
         ("|( ﾟдﾟ)|＜寝る！" t 0)
         ("|( ﾟдﾟ)|＜" t 0)
         ("( ﾟДﾟ)" t 0)
         ("( ﾟωﾟ)" t 0)
         ("( ･∀･)" t 0)
         ("(ﾟДﾟ)ﾏｽﾞー" t 0)
         ("(ﾟДﾟ)ｳﾏー" t 0)
         ("(\\*ﾟヮﾟ)\\[ :" t 0)
         ("(\\*ﾟヮﾟ)< :" t 0)
         )))

; フック
(defvar *ci-mode-hook* nil
  "ci-mode: フック変数")

; シンタックステーブル
(defvar *ci-mode-syntax-table* nil)
(unless *ci-mode-syntax-table*
  (setf *ci-mode-syntax-table* (make-syntax-table))
  (do ((x #x21 (1+ x)))((>= x #x7f))
    (let ((c (code-char x)))
      (unless (alphanumericp c)
        (set-syntax-punctuation *ci-mode-syntax-table* c))))
  ; 以下modeに合わせて設定
  (set-syntax-string *ci-mode-syntax-table* #\")
  (set-syntax-match *ci-mode-syntax-table* #\[ #\]))

; キーマップ
(defvar *ci-mode-map* nil)
(unless *ci-mode-map*
  (setf *ci-mode-map* (make-sparse-keymap))
  ; 以下キー割当
  (define-key *ci-mode-map* #\M-TAB 'ci-completion)
  (define-key *ci-mode-map* #\M-TAB 'ci-run))

;; 実行
(defun ci-run ()
  (interactive)
  )

(defun ci-expand-string (str vtbl)
  (if (and str vtbl)
      (ci-gsub "\\[\\(.+?\\)\\]" str
               #'(lambda ()
                   (format nil "~A" (gethash (intern (match-string 1)) vtbl))))
    str))

(defun ci-gsub (re str fn)
  (unless (and re str)
    (return-from ci-gsub str))
  (let ((result))
    (labels ((ci-gsub-internal (re str fn start)
               (when (string-match re str start)
                 (push (substring str start (match-beginning 0)) result)
                 (if fn (push (funcall fn) result))
                 (ci-gsub-internal re str fn (match-end 0)))))
      (ci-gsub-internal re str fn 0))
    (format nil "~{~A~}" (reverse result))))

(defvar *ci-keyword-list*
  '("|( ﾟдﾟ)|＜"
    "( ﾟДﾟ)"
    "( ﾟωﾟ)"
    "( ･∀･)"
    "(ﾟДﾟ)ﾏｽﾞー"
    "(ﾟДﾟ)ｳﾏー"
    "(\\*ﾟヮﾟ)\\[ :"
    "(\\*ﾟヮﾟ)< :"))


(define-condition ci-parse-error (simple-error) (file line column message)
  (:report (lambda (c s)
             (format s "~A:~D: ~A"
                     (ci-parse-error-file c)
                     (ci-parse-error-line c)
                     (ci-parse-error-message c)))))

(defun ci-parse-number (in)
  (ci-parse-type (in 'numberp "数字じゃないみたい")))

(defun ci-parse-string (in)
  (ci-parse-type (in 'stringp "文字列じゃないみたい")))

(defun ci-parse-type (in typep msg)
  (let ((result (read in)))
    (if (funcall typep result)
        result
      (progn
        (set-buffer (buffer-stream-buffer in))
        (error 'ci-parse-error
               :file (get-buffer-file-name (selected-buffer))
               :line (current-line-number)
               :message msg)))))

;; popup 補完
(defvar *ci-mode-abbrev-table* nil)
(unless *ci-mode-abbrev-table*
  (define-abbrev-table '*ci-mode-abbrev-table*))
(defun ci-completion ()
  "ci-mode: 補完"
  (interactive)
  (or *ci-completion-list*
      (setf *ci-completion-list* (make-list-from-keyword-table
                                  *ci-keyword-hash-table*))
      (return-from ci-completion nil))
  (let ((opoint (point)))
    (skip-chars-backward *ci-keyword-char*)
    (skip-chars-forward " ")
    (if (< opoint (point)) (goto-char opoint))

    (let ((from (point)))
      (goto-char opoint)
      ; :list-ignore-case=補完で大文字小文字を区別しない, :list=する
      (do-completion from opoint :list-ignore-case *ci-completion-list*
                     nil nil *ci-completion-list* ; xyzzy 0.2.2.211以前を使う場合はコメントアウト
                     ))))

(defun ci-mode ()
  "ci-mode"
  (interactive)
  (kill-all-local-variables)
  (setf mode-name "*ﾟーﾟ")
  (setf buffer-mode 'ci-mode)
  (use-syntax-table *ci-mode-syntax-table*)
  (use-keymap *ci-mode-map*)

  ; 略語展開
  (setf *local-abbrev-table* *ci-mode-abbrev-table*)

  (make-local-variable 'paragraph-start)
  (setf paragraph-start "^$\\|\f") ; forward|backward-paragraph で移動する段落位置
  (make-local-variable 'paragraph-separate)
  (setf paragraph-separate paragraph-start)

  ; keyword
  (and *ci-keyword-file*
       (null *ci-keyword-hash-table*)
       (setf *ci-keyword-hash-table*
             (load-keyword-file *ci-keyword-file* t))) ; t=大文字小文字を区別しない, nil=する
  (when *ci-keyword-hash-table*
    (make-local-variable 'keyword-hash-table)
    (setf keyword-hash-table *ci-keyword-hash-table*))
  (make-local-variable 'regexp-keyword-list)
  (setf regexp-keyword-list *ci-regexp-keyword-list*)

  ; フックの実行
  (run-hooks '*ci-mode-hook*))
