; -*- Mode: Lisp; Package: editor -*-

#|
= bnf-mode - BNF ファイルを編集したりする

* Author:  miyamuko ((<URL:mailto:miyamuko (at) mtb.biglobe.ne.jp>))
* URL: ((<URL:http://miyamuko.s56.xrea.com/xyzzy/bnf-mode.html>))
* Version: $Id: bnf-mode.l,v 1.9 2004/08/09 14:03:01 miyamuko Exp $


== 説明

BNF を読みために作ったモードです。書くことはあまり考慮していません。

* ABNF(Augmented BNF) と EBNF(Extended BNF) に大体対応
* 適当なインデント
* 適当な色づけ
* ルール名のタグジャンプ


== インストール

((<NetInstaller|URL:http://www.mirai.ne.jp/~gyo/xyzzy/ni.html>)) でインストールした場合は 3 以降を、
NetInstaller + (({ni-autoload})) を使っている人は 4 以降で OK です。

(1) アーカイブをダウンロードします。

    ((<URL:http://miyamuko.s56.xrea.com/xyzzy/archives/bnf-mode.zip>))

(2) アーカイブを展開して、$XYZZY/site-lisp 配下にファイルをコピーします。

(3) 拡張子が bnf、abnf、ebnf のファイルを開いたときに自動的に bnf-mode になるように
    ~/.xyzzy または $XYZZY/site-lisp/siteinit.l に以下のコードを追加します。

        ;; bnf-mode
        (require "bnf-mode")
        (pushnew '("\\.[ae]?bnf$" . bnf-mode) *auto-mode-alist* :test 'equal)

(4) 設定を反映させるため xyzzy を再起動してください。

    ※siteinit.l に記述した場合には再ダンプが必要です。


== リファレンス

=== キー割り当て

: ((%TAB%))
    インデントします。

    * ルールを継続する文字があれば前の行とインデントをそろえます。
    * ルールを継続する文字がない場合、通常インデントしません。
    * 通常インデントしない行でも行頭にスペースが一文字以上あればインデントします。

    ルールを複数行にわたって書く場合は次のようにインデントします。

        TypeDeclaration = ClassDeclaration /
                          InterfaceDeclaration
                          / ";"

    ルール名の直後で改行した場合は次のようにインデントします。
    ((({*bnf-indent-level*})) が 2 の場合)

        declaration-specifiers:
          (storage-class-specifier | type-specifier
          | type-qualifier)+

: ((%RET%))
    改行＋インデント付け。

=== 変数

--- *bnf-indent-level*

インデントの幅を設定します。(下図の _ 部分, デフォルト 2)

    rule_name:
    __element

インデントの深さを 4 カラムに変更する場合。

    ;; インデントは 4
    (setq *bnf-indent-level* 4)

--- *bnf-rule-separator-regexp*

ルールのセパレータのパターンを設定します。(デフォルトは (::= or : or = or =/))

    ;; セパレータをコロンのみに設定
    (setq *bnf-rule-separator-regexp* ":")


== これからやるかもしれないこと

(1) ルール名の区切り文字のインデントを前のルールとあわせる。

        rule_name1    = foo ; 最初は手でインデント。
        rule_name2    = bar ; ここは自動的に前の行にあわせる。
        loooooooong_rule_name1 = baz ; これはしょうがない。
        rule_name3 = hoge ; ここも戻る。

(2) へなちょこなので放置


== 関連するかもしれないページ

: RFC2234 - Augmented BNF for Syntax Specifications: ABNF
    ((<URL:http://www.ietf.org/rfc/rfc2234.txt>))


== ライセンス

bnf-mode は修正 BSD ライセンスに基づいて利用可能です。

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

(provide "bnf-mode")
(in-package "editor")

(export '(*bnf-mode-hook*
          *bnf-mode-map*
          *bnf-indent-level*
          *bnf-rule-separator-regexp*
          bnf-mode
          ))


; フック
(defvar *bnf-mode-hook* nil
  "bnf-mode: フック変数")

; configurable
(defvar *bnf-comment-column* nil)
(defvar *bnf-rule-separator-regexp* "\\(:\\|=/?\\|::=\\)"
  "bnf-mode: rule と element の区切り文字: ABNF は = or =/, BNF は ::=, yacc は : ")
(defvar *bnf-indent-level* 2
  "bnf-mode: element のインデント幅")

(defvar *bnf-rule-name-regexp* "^[a-zA-Z][a-zA-Z0-9_-]*"
  "rule name の正規表現")

; regexp keyword
(defvar bnf-regexp-keyword nil
  "正規表現キーワード")

; color
(defvar *bnf-rule-name-color* '(:keyword 0))
(defvar *bnf-option-element-color* '(:keyword 1))
(defvar *bnf-ref-element-color* '(:keyword 2))
(setf *bnf-regexp-keyword*
  (compile-regexp-keyword-list
   `(
     ;; rule name
     (,*bnf-rule-name-regexp* t ((0 . ,*bnf-rule-name-color*)))
     ;; option
     ("\\[[^]]+\\]" t ((0 . ,*bnf-option-element-color*)))
     ;; ref
     ("<[^>]+>" t ((0 . ,*bnf-ref-element-color*)))
     )))


; シンタックステーブル
(defvar *bnf-mode-syntax-table* nil)
(unless *bnf-mode-syntax-table*
  (setf *bnf-mode-syntax-table* (make-syntax-table))
  (do ((x #x21 (1+ x)))((>= x #x7f))
    (let ((c (code-char x)))
      (unless (alphanumericp c)
        (set-syntax-punctuation *bnf-mode-syntax-table* c))))
  ; 以下modeに合わせて設定
  (set-syntax-word *bnf-mode-syntax-table* #\_)
  (set-syntax-word *bnf-mode-syntax-table* #\-)
  (set-syntax-string *bnf-mode-syntax-table* #\")
  (set-syntax-match *bnf-mode-syntax-table* #\( #\)) ; 対応する()に飛ぶ
  (set-syntax-match *bnf-mode-syntax-table* #\< #\>)
  (set-syntax-match *bnf-mode-syntax-table* #\[ #\])
  (set-syntax-start-comment *bnf-mode-syntax-table* #\;)
  (set-syntax-end-comment *bnf-mode-syntax-table* #\LFD)
  )

; キーマップ
(defvar *bnf-mode-map* nil)
(unless *bnf-mode-map*
  (setf *bnf-mode-map* (make-sparse-keymap))
  ; 以下キー割当
  (define-key *bnf-mode-map* #\| 'bnf-electric-insert)
  (define-key *bnf-mode-map* #\/ 'bnf-electric-insert)
  (define-key *bnf-mode-map* #\( 'bnf-electric-insert)
  (define-key *bnf-mode-map* #\) 'bnf-electric-close)
  (define-key *bnf-mode-map* #\C-h 'backward-delete-char-untabify-or-selection)
  (define-key *bnf-mode-map* #\TAB 'bnf-indent-line)
  (define-key *bnf-mode-map* #\C-M-q 'indent-sexp)
  (define-key *bnf-mode-map* #\RET 'bnf-newline-and-indent)
  )

(defun bnf-electric-insert (&optional (arg 1))
  (interactive "*p")
  (self-insert-command arg)
  (bnf-indent-line))

(defun bnf-electric-close (&optional (arg 1))
  (interactive "*p")
  (self-insert-command arg)
  (bnf-indent-line)
  (save-excursion
    (forward-char -1)
    (and (goto-matched-parenthesis)
         (show-matched-parenthesis)))
  t)

(defun bnf-newline-and-indent (&optional (arg 1))
  (interactive "*p")
  (delete-trailing-spaces)
  (insert #\LFD arg)
  (bnf-indent-line))

; from c-indent-line
(defun bnf-indent-line ()
  (interactive "*")
  (let ((column (calc-bnf-indent)))
    (when (integerp column)
      (smart-indentation column)))
  t)

(defun bnf-previous-line ()
  "空行じゃない行まで戻る"
  (while (forward-line -1)
    (unless (or (bnf-space-line) (bnf-comment-line))
      (return-from bnf-previous-line t))))

(defun bnf-space-line ()
  "空行かどうか（ってこうやって調べるものなのか？）"
  (save-excursion
    (goto-bol)
    (looking-at "[ \t]*$")))

(defun bnf-comment-line ()
  "コメントかどうか"
  (save-excursion
    (goto-bol)
    (looking-at "^[ \t]*;")))

(defun calc-bnf-indent ()
  "インデントする数を数える"
  (let ((column 0) (prev-column 0))
    (save-excursion
      ;前の行を調べる
      (when (bnf-previous-line)
        (save-restriction
          (narrow-to-region (progn (goto-eol) (point))
                            (progn (goto-bol) (point)))
          (goto-bol)
          (skip-chars-forward " \t")
          (setf prev-column (current-column))

          ; element のインデントをコピーしておく
          (when (scan-buffer (concat *bnf-rule-name-regexp* "[ \t]*"
                                     *bnf-rule-separator-regexp* "[ \t]*") :regexp t :tail t)
            ; rule name とデリミタ のみなら + *bnf-indent-level*
            (if (eolp)
                (setf column *bnf-indent-level*)
              (setf prev-column (current-column))))

          ; 行末に継続する文字がある場合はインデントする
          (when (scan-buffer "[|/(][ \t]*$" :regexp t)
            (setf column prev-column))
          )))
    ; 現在の行を調べる
    (save-excursion
      (goto-bol)
      (skip-chars-forward " \t")
      (cond
       ; 行頭が | / ( ) [ ] < > " なら前の行のインデントをコピー
       ((looking-at "[][|/()<>\"]")
        (setf column prev-column))
       ; 非継続行だけど行頭に SPC があればインデントしてあげる
       ((and (equal column 0) (not (bolp)))
        (setf column prev-column))
       ))
    column
    ))


; rule name の一覧
(defun bnf-build-summary-of-functions ()
  (let ((result nil))
    (save-excursion
      (goto-char (point-min))
      (while (scan-buffer (concat "\\(" *bnf-rule-name-regexp* "\\)")
                          :regexp t :tail t)
        (push (list (current-line-number) (match-string 1)) result)))
    (nreverse result)
  ))

; tag
(pushnew '(bnf-maketags "*.bnf" "*.ebnf" "*.abnf") *maketags-list* :key #'car)

(defun tags-find-bnf-point (class name functionp point)
  (goto-char (- point *jump-tag-limit*))
  (and (scan-buffer (concat "^"
                            (regexp-quote name)
                            "[ \t]*"
                            *bnf-rule-separator-regexp*)
                    :regexp t :limit (+ point *jump-tag-limit*))
       (point)))

; XTAGS ファイルの作成関数
;; ^rule_name [:=] elements
(defun bnf-maketags (file count)
  (goto-char (point-min))
  (while (scan-buffer *bnf-rule-name-regexp* :regexp t :case-fold t)
    (do-events)
    (let ((opoint (point)))
      (skip-chars-forward "a-zA-Z0-9_-")
      (unless (= opoint (point))
        (format t "~A~A~D" (buffer-substring opoint (point)) file opoint)
        (setf count (1+ count)))))
  count)

; modeの実行
(defun bnf-mode ()
  "bnf-mode"
  (interactive)
  (kill-all-local-variables)
  (setf mode-name "BNF") ; modelineに表示される名前。modeと違う名前でも可
  (setf buffer-mode 'bnf-mode)
  (use-syntax-table *bnf-mode-syntax-table*)
  (use-keymap *bnf-mode-map*)

  ; paragraph
  (make-local-variable 'paragraph-start)
  (setf paragraph-start "^$\\|\f") ; forward|backward-paragraph で移動する段落位置
  (make-local-variable 'paragraph-separate)
  (setf paragraph-separate paragraph-start)

  ; タグ関連
  (make-local-variable 'tags-find-target)
  (setf tags-find-target #'tags-find-target-simple)
  (make-local-variable 'tags-find-point)
  (setf tags-find-point #'tags-find-bnf-point)

  ; list of rule name
  (make-local-variable 'build-summary-function)
  (setf build-summary-function 'bnf-build-summary-of-functions)

  ; indent
  (make-local-variable 'mode-specific-indent-command)
  (setf mode-specific-indent-command 'bnf-indent-line)
  (make-local-variable 'mode-newline-and-indent-command)
  (setf mode-newline-and-indent-command 'bnf-newline-and-indent)

  ; comment
  (setf comment-start "; " comment-end "") ; indent-for-commentで挿入される奴
  (setf comment-start-skip ";+[ \t]*")
  (setf comment-indent-function 'calc-bnf-indent)
  (when *bnf-comment-column*
    (setf comment-column *bnf-comment-column*))

  ; keyword
  (make-local-variable 'regexp-keyword-list)
  (setf regexp-keyword-list *bnf-regexp-keyword*)

  ; フックの実行
  (run-hooks '*bnf-mode-hook*))
