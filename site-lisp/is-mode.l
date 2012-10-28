; -*- Mode: Lisp; Package: editor -*-

#|
= is-mode - InstallScript ファイルを編集したりする

* Author:  miyamuko ((<URL:mailto:miyamuko (at) mtb.biglobe.ne.jp>))
* URL: ((<URL:http://miyamuko.s56.xrea.com/xyzzy/is-mode.html>))
* Version: $Id: is-mode.l,v 1.9 2004/08/09 14:03:06 miyamuko Exp $


== 説明

InstallScript (InstallShield 用スクリプト) 用の編集モードです。

* 適当なインデント
* 適当な色づけ
* キーワードの補完
* function と #define のタグジャンプ


== インストール

((<NetInstaller|URL:http://www.mirai.ne.jp/~gyo/xyzzy/ni.html>)) でインストールした場合は 3 以降を、
NetInstaller + (({ni-autoload})) を使っている人は 4 以降で OK です。

(1) アーカイブをダウンロードします。

    ((<URL:http://miyamuko.s56.xrea.com/xyzzy/archives/is-mode.zip>))

(2) アーカイブを展開して、$XYZZY/site-lisp 配下にファイルをコピーします。

(3) 拡張子が rul のファイルを開いたときに自動的に is-mode になるように
    ~/.xyzzy または $XYZZY/site-lisp/siteinit.l に以下のコードを追加します。

        ;; is-mode
        (require "is-mode")
        (pushnew '("\\.rul$" . is-mode) *auto-mode-alist* :test 'equal)

(4) 設定を反映させるため xyzzy を再起動してください。

    ※siteinit.l に記述した場合には再ダンプが必要です。


== リファレンス

=== キー割り当て

: ((%TAB%))
    インデントする。

    Compiler directive (#defineとか) はインデントしません。

: ((%RET%))
    改行＋インデント付け。

: ((%M-TAB%))
    キーワードと組み込み関数の補完。

    先行する文字があればその文字から始まるキーワードをツールチップで表示します。
    先行する文字がなければすべてのキーワードを表示します。

=== 変数

--- *is-label-level*
--- *is-label-offset*

インデントレベルを設定します。

    ;; インデントの幅(下図で _ の部分, default=4)
    (setq *is-indent-level* 4)

    ;; ラベルのオフセット(下図で - の部分, default=-4)
    ;;; 説明のためのありえない設定。
    (setq *is-label-offset* 4)

    ;; function Foo(nBar)
    ;; ____number nFoo;
    ;; begin
    ;; ____if (nBar != 0) goto Baz;
    ;; ____nFoo = 10
    ;; ____----Label:
    ;; ____// ...
    ;; end;


== これからやるかもしれないこと

* MSI のキーワードをまとめる。
* リファレンス。
* ステートメントが継続する場合のインデントをちゃんとする。
* でも、へなちょこなので放置


== 既知のバグ

以下のような場合適切にインデントできない。

    if (szHoge == "HOGE"
    || szFoo == "FOO") then  // この行をインデントできない
    endif;

    nPos = StrFind(svTarget,
    szFindMe);  // ここも

本当は次のようにしたい。

    if (szHoge == "HOGE"
        || szFoo == "FOO") then
    endif;

    nPos = StrFind(svTarget,
                   szFindMe);

でもやる気がない。


== 関連するかもしれないページ

: InstallShield - Software Installation and Migration for SysAdmins and Developers
    ((<URL:http://www.installshield.com/>))


== ライセンス

properties-mode は修正 BSD ライセンスに基づいて利用可能です。

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

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:
|#


(provide "is-mode")
(in-package "editor")
(export '(*is-mode-hook*
          *is-mode-map*
          *is-comment-column*
          *is-indent-level*
          *is-label-offset*
          is-completion
          is-mode))

; フック
(defvar *is-mode-hook* nil
  "is-mode: フック変数")

; configuration
(defvar *is-comment-column* nil)
(defvar *is-indent-level* 4
  "インデントで入れるスペースの数")
(defvar *is-label-offset* -4
  "ラベルのオフセット")

; compiled regexp
(defvar *is-label-regexp*
  (compile-regexp "^[ \t]*[A-Z_][A-Z0-9_]*:[ \t]*$")
  "ラベルの正規表現")

(defvar *is-block-beg-regexp*
  (compile-regexp "\\<try\\|for\\|program\\|switch\\|while\\|function\\|repeat\\>")
  "ブロックが開始する識別子の正規表現。
   このほかにも if ... then がある。
   if ... goto label; という特別な if 構造があるので単純に if でブロックを開始できない。
  ")

(defvar *is-block-mid-regexp*
  (compile-regexp "\\<begin\\|case\\|default\\|catch\\|else\\|elseif\\>"))

(defvar *is-block-end-regexp*
  (compile-regexp "\\<\\(until\\|end\\(catch\\|for\\|if\\|program\\|switch\\|while\\)?\\)\\>"))


; キーワード
(defvar *is-completion-list* nil
  "is-mode: 補完リストのポップアップ")

(defvar *is-keyword-hash-table* nil)
(defvar *is-keyword-file* "InstallScript")

;; label color
(defvar *is-label-color* '(:keyword 0 :bold)
  "ラベルの色")

(defvar *is-regexp-keyword-list* nil
  "is-mode: 正規表現キーワードリスト")

(setq *is-regexp-keyword-list*
  (compile-regexp-keyword-list
   `(
     ;; ラベル行
     (,*is-label-regexp* t ((0 . ,*is-label-color*)))
     )))


;; シンタックステーブル
(defvar *is-mode-syntax-table* nil)
(unless *is-mode-syntax-table*
  (setq *is-mode-syntax-table* (make-syntax-table))
  (do ((x #x21 (1+ x))) ((>= x #x7f))
    (let ((c (code-char x)))
      (unless (alphanumericp c)
        (set-syntax-punctuation *is-mode-syntax-table* c))))
  ; 以下modeに合わせて設定
  (set-syntax-word *is-mode-syntax-table* #\#)
  (set-syntax-string *is-mode-syntax-table* #\")
  (set-syntax-string *is-mode-syntax-table* #\')
  (set-syntax-escape *is-mode-syntax-table* #\\)
  (set-syntax-symbol *is-mode-syntax-table* #\_)
  (set-syntax-match *is-mode-syntax-table* #\( #\)) ; 対応する()に飛ぶ
  (set-syntax-match *is-mode-syntax-table* #\{ #\})
  (set-syntax-match *is-mode-syntax-table* #\[ #\])
  (set-syntax-start-multi-comment *is-mode-syntax-table* "/*")
  (set-syntax-end-multi-comment *is-mode-syntax-table* "*/")
  (set-syntax-start-c++-comment *is-mode-syntax-table* #\/)
  (set-syntax-end-c++-comment *is-mode-syntax-table* #\LFD)
  )

;; キーマップ
(defvar *is-mode-map* nil)
(unless *is-mode-map*
  (setq *is-mode-map* (make-sparse-keymap))
  ; 以下キー割当
  (define-key *is-mode-map* #\# 'is-electric-insert)
  (define-key *is-mode-map* #\: 'is-electric-insert)
  (define-key *is-mode-map* #\C-h 'backward-delete-char-untabify-or-selection)
  (define-key *is-mode-map* #\TAB 'is-indent-line)
  (define-key *is-mode-map* #\C-M-q 'indent-sexp)
  (define-key *is-mode-map* #\RET 'is-newline-and-indent)
  (define-key *is-mode-map* #\M-TAB 'is-completion)       ; 補完
  )

(defun is-electric-insert (&optional (arg 1))
  (interactive "*p")
  (self-insert-command arg)
  (is-indent-line))

(defun is-newline-and-indent (&optional (arg 1))
  (interactive "*p")
  (is-indent-line)
  (delete-trailing-spaces)
  (insert #\LFD arg)
  (is-indent-line))

; from c-indent-line
(defun is-indent-line ()
  (interactive "*")
  (if (or (not (interactive-p))
          *c-tab-always-indent*
          (save-excursion
            (skip-chars-backward " \t")
            (bolp)))
      (case (save-excursion
              (goto-bol)
              (parse-point-syntax))
        (:string)
        (:comment
         (let ((column (calc-c-comment-indent)))
           (when (integerp column)
             (smart-indentation column))))
        (t
         (let ((column (calc-is-indent)))
           (when (integerp column)
             (smart-indentation column)))))
    (insert "\t"))
  t)

(defun is-previous-line ()
  "前の有効な行まで戻る"
  (let ((in-conditional-compilation nil))
    (save-restriction
      (while (forward-line -1)
        (goto-bol)
        (cond
         ;; #else の中にいる場合 #ifdef の前まで戻る
         (in-conditional-compilation
          (if (looking-at "[ \t]*#ifn?def")
              (setq in-conditional-compilation nil)))
         ((equal (parse-point-syntax) :comment)
          ; nop
          )
         ((looking-at "[ \t]*#else")
          (setq in-conditional-compilation t))
         ((not (or (is-space-line) (is-compiler-directive) (is-label)))
          (return-from is-previous-line t))
         ))
      )))

(defun is-space-line ()
  "空行かどうか"
  (save-excursion
    (goto-bol)
    (looking-at "[ \t]*$")))

(defun is-compiler-directive ()
  "compiler directive かどうか"
  (save-excursion
    (goto-bol)
    (looking-at "[ \t]*#")))

(defun is-label ()
  "ラベルかどうか"
  (save-excursion
    (goto-bol)
    (looking-at *is-label-regexp*)))

(defun calc-is-indent ()
  "インデントする数を数える。"
  (let ((column 0))
    ; compiler directive はインデントなし
    (if (is-compiler-directive)
        (return-from calc-is-indent 0))

    (save-excursion
      ;前の行を調べる
      (when (is-previous-line)
        (save-restriction
          (narrow-to-region (progn (goto-eol) (point))
                            (progn (goto-bol) (point)))
          (goto-bol)
          (skip-chars-forward " \t")
          ; インデント数
          (setq column (current-column))
;          (msgbox "base indent(line ~D): ~D" (current-line-number) column)

          ; 開きものがあればインデント数を増やす
          (cond
           ((or (looking-at *is-block-beg-regexp*)
                (looking-at *is-block-mid-regexp*)
                (and (looking-at "if") (scan-buffer "then[ \t]*$" :regexp t)))
            (incf column *is-indent-level*)
;            (msgbox " open ~D" column)
            ))
          )))
    ; 現在の行を調べる
    (save-excursion
      (goto-bol)
      (skip-chars-forward " \t")
      ; 閉じものがあればインデント数を減らす
      (cond
       ((or (looking-at *is-block-mid-regexp*)
            (looking-at *is-block-end-regexp*))
        (decf column *is-indent-level*)
;        (msgbox "close ~D" column)
        ))
      ; ラベルなら *is-label-offset* 分増やす
      (if (is-label)
          (return-from calc-is-indent (+ column *is-label-offset*)))
      )
    column
    ))


; 補完
;; addrev-table
(defvar *is-mode-abbrev-table* nil)
(unless *is-mode-abbrev-table*
  (define-abbrev-table '*is-mode-abbrev-table*))

;; popup 補完
(defun is-completion ()
  "is-mode: 補完"
  (interactive)
  (or *is-completion-list*
      (setq *is-completion-list* (make-list-from-keyword-table *is-keyword-hash-table*))
      (return-from is-completion nil))
  (let ((opoint (point)))
    (skip-syntax-spec-backward "w_")
    (let ((from (point)))
      (goto-char opoint)
      ; :list-ignore-case=補完で大文字小文字を区別しない, :list=する
      (do-completion from opoint :list-ignore-case *is-completion-list*
                     nil nil *is-completion-list* ; xyzzy 0.2.2.211以前を使う場合はコメントアウト
                     ))))

; function 名の一覧
(defun is-build-summary-of-functions ()
  (let ((result nil))
    (save-excursion
      (goto-char (point-min))
      (while (scan-buffer (concat "^[ \t]*function[ \t]+"
                                  "\\([a-zA-Z0-9_]+[ \t]+\\)?"
                                  "\\([a-zA-Z0-9_]+\\)[ \t]*(")
                          :regexp t :tail t)
        (push (list (current-line-number) (match-string 2)) result)))
    (nreverse result)
    ))

; tag
(pushnew '(is-maketags "*.rul" "*.h") *maketags-list* :key #'car)

(defun tags-find-is-point (class name functionp point)
  (goto-char (- point *jump-tag-limit*))
  (and (or (scan-buffer "^#[ \t]*define[ \t]+[A-Z_]+"
                        :regexp t :limit (+ point *jump-tag-limit*))
           (scan-buffer (concat "^[ \t]*function[ \t]+"
                                "\\([a-zA-Z]+[ \t]+\\)?"
                                (regexp-quote name) "[ \t]+(")
                        :regexp t :limit (+ point *jump-tag-limit*)))
       (point)))

;; function をタグ付け
;;   function [return type] name (parameters)
(defun is-maketags (file count)
  (goto-char (point-min))
  (while (scan-buffer "^[ \t]*\\(#define\\|function\\)[ \t]+" :regexp t :tail t :case-fold t)
    (do-events)
    (when (and (equal (match-string 1) "function")
               (looking-at "[a-zA-Z0-9_]+[ \t]+"))
      (goto-char (match-end 0)))
    (let ((opoint (point)))
      (skip-chars-forward "a-zA-Z0-9_")
      (unless (= opoint (point))
        (format t "~A~A~D" (buffer-substring opoint (point)) file opoint)
        (setq count (1+ count)))))
  count)

; modeの実行
(defun is-mode ()
  "is-mode"
  (interactive)
  (kill-all-local-variables)
  (setq mode-name "InstallScript")
  (setq buffer-mode 'is-mode)
  (use-syntax-table *is-mode-syntax-table*)
  (use-keymap *is-mode-map*)

  ; 略語展開
  (setq *local-abbrev-table* *is-mode-abbrev-table*)

  (make-local-variable 'paragraph-start)
  (setq paragraph-start "^$\\|\f") ; forward|backward-paragraph で移動する段落位置
  (make-local-variable 'paragraph-separate)
  (setq paragraph-separate paragraph-start)

  ; タグ関連
  (make-local-variable 'tags-find-target)
  (setq tags-find-target #'tags-find-target-simple)
  (make-local-variable 'tags-find-point)
  (setq tags-find-point #'tags-find-is-point)
  (make-local-variable 'build-summary-function)
  (setq build-summary-function 'is-build-summary-of-functions)

  ; indent
  (make-local-variable 'mode-specific-indent-command)
  (setq mode-specific-indent-command 'is-indent-line)
  (make-local-variable 'mode-newline-and-indent-command)
  (setq mode-newline-and-indent-command 'is-newline-and-indent)

  ; comment
  (setq comment-start "// " comment-end "") ; indent-for-commentで挿入される奴
  (setq comment-start-skip "/+[ \t]*")
  (setq comment-indent-function 'calc-is-indent)
  (when *is-comment-column*
    (setq comment-column *is-comment-column*))

  ; keyword
  (and *is-keyword-file*
       (null *is-keyword-hash-table*)
       (setq *is-keyword-hash-table*
             (load-keyword-file *is-keyword-file* nil))) ; t=大文字小文字を区別しない, nil=する
  (when *is-keyword-hash-table*
    (make-local-variable 'keyword-hash-table)
    (setq keyword-hash-table *is-keyword-hash-table*))
  (make-local-variable 'regexp-keyword-list)
  (setq regexp-keyword-list *is-regexp-keyword-list*)

  ; フックの実行
  (run-hooks '*is-mode-hook*))
