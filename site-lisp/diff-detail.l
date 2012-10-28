;;; -*- Mode: Lisp; Package: EDITOR -*-
;;; diff-detail.l --- トークン単位 diff

;; Copyright (C) 2001-2006 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Time-stamp: <2006/03/31 00:02:35 +0900>

;;; Commentary:

;; Description:
;;
;;  diff の更新行を、正規表現または関数で指定したトークン単位で
;;  再度比較します。
;;

;; Installation:
;;
;;      1. アーカイブを展開して diff-detail.l を、$XYZZY/site-lisp に
;;         コピーします。
;;
;;      2. バイトコンパイルします。
;;
;;              M-x byte-compile-file
;;              Byte compile file: $XYZZY/site-lisp/diff-detail.l
;;
;;      3. ~/.xyzzy または $XYZZY/site-lisp/siteinit.l に以下のコードを
;;         追加します。
;;
;;              (require "diff-detail")
;;
;;      4. 上記の設定を反映させるために、xyzzy を再起動します。
;;         siteinit.l に記述した場合は Ctrl キーと Shift キーを押しながら
;;         xyzzy を再起動し、ダンプファイルを再構築します。
;;

;; Uninstallation:
;;
;;      1. ESC ESC (ed::diff-detail-uninstall) とタイプし、
;;         diff-detail.l 関連の情報を xyzzy から削除します。
;;
;;      2. diff-detail.l に関する記述を削除します。
;;
;;      3. siteinit.l に記述していた場合は Ctrl キーと Shift キーを押し
;;         ながら xyzzy を再起動し、ダンプファイルを再構築します。
;;

;; Usage:
;;
;;      1. 実行
;;          1.1 diff または diff-detail を実行
;;              M-x diff
;;                or
;;              M-x diff-detail
;;
;;          1.2. 詳細表示 (token とする正規表現の変更)
;;              "." キー (M-x diff-detail-change-grain)
;;
;;      2. 移動
;;              n: diff-mode の n と同等
;;              p: diff-mdoe の p と同等
;;
;;              N: 次の変更位置へ移動
;;              P: 前の変更位置へ移動
;;
;;            TAB: 比較バッファの対応する変更位置へ移動
;;
;;      3. 差分編集
;;              m: diff-mode の m と同等
;;              r: diff-mode の r と同等
;;              u: diff-mode の u と同等
;;
;;              M: diff-detail 部分を merge
;;              R: diff-detail 部分を merge-reverse
;;              U: diff-detail 部分を undo
;;
;;      4. その他
;;              c: diff 画面の縦横分割の切り替え
;;            SPC: 比較バッファの対応する変更範囲を強調表示
;;              v: HTML に変換した結果を表示
;;        C-c C-h: HTML に変換
;;        C-c RET: 真鵺道(Manued)に変換
;;

;; Setting example:
;;
;;      (require "diff-detail")
;;      (setq *diff-detail-temp-html-file* "~/diff-detail-temp.html")
;;      (setq *diff-detail-convert-to-html-mode* 'html+-mode)
;;

;; Customize:
;;
;;      *diff-detail-old-file-attributes*
;;      *diff-detail-new-file-attributes*
;;      *diff-detail-merge-attributes*
;;      *diff-detail-blink-attributes*
;;      *diff-detail-blink-timeout*
;;      *diff-detail-token-regexp*
;;
;;      *diff-detail-forward-interactive-hook*
;;      *diff-detail-mode-hook*
;;      *diff-detail-mode-map*
;;
;;      *diff-detail-output-buffer-name*
;;
;;      *diff-detail-temp-html-file*
;;      *diff-detail-html-header*
;;      *diff-detail-html-footer*
;;      *diff-detail-convert-to-html-mode*
;;
;;      *diff-detail-manued-l-parenthesis-str*
;;      *diff-detail-manued-r-parenthesis-str*
;;      *diff-detail-manued-delete-str*
;;      *diff-detail-manued-swap-str*
;;      *diff-detail-manued-comment-str*
;;      *diff-detail-manued-escape-str*
;;      *diff-detail-manued-order-str*
;;      *diff-detail-manued-version-str*
;;      *diff-detail-convert-to-manued-mode*
;;

;; Changes:
;;
;;      Thu, 30 Mar 2006 23:55:16 +0900
;;        ・比較ファイルに違いがない場合、diff-detail がエラーとなるのを
;;          修正。(2ch 励ましあえ その8 >>955-957 情報)
;;
;;      Mon, 05 Dec 2005 00:48:13 +0900
;;        ・diff-detail-change-grain-default 追加。
;;
;;      Mon, 05 Dec 2005 00:23:11 +0900
;;        ・diff-detail 関数の引数 token-regexp の初期値を
;;          *diff-detail-token-regexp* に。
;;
;;      Sat, 08 Oct 2005 12:40:32 +0900
;;        ・メールアドレスを変更。
;;        ・ライセンス条項(修正BSDライセンス)を記載。
;;
;;      Fri, 18 Feb 2005 00:26:07 +0900
;;        ・安全な側にたおすために、HTML 出力時の CSS クラス名に
;;          使用していた _ を - に変更。(From DocDiff ML)
;;          - *diff-detail-html-header* 変更。
;;          - diff-detail-convert-to-html 変更。
;;
;;      Mon, 07 Feb 2005 00:02:02 +0900
;;        ・*diff-detail-token-regexp* 初期値変更。
;;
;;      Sat, 22 Jan 2005 03:05:48 +0900
;;        ・Manued 変換の修正/拡張。
;;          - 各種制御文字を設定可能に。( [/|;]~ からの変更)
;;          - older-first/last newer-first/last を設定可能に。
;;          - defcommand 出力追加。
;;
;;      Wed, 19 Jan 2005 21:50:17 +0900
;;        ・DocDiff <http://www.kt.rim.or.jp/~hisashim/docdiff/> を
;;          参考にし HTML 出力追加。
;;          - diff-detail-convert-to-html 追加。
;;          - diff-detail-view-html 追加。
;;          - *diff-detail-temp-html-file* 追加。
;;        ・真鵺道 (Manued) 出力追加。
;;          - diff-detail-convert-to-manued 追加。
;;        ・文字列の token 分解に正規表現以外に関数を用いれるように拡張。
;;          - diff-detail-char, diff-detail-word は正規表現でなく、
;;            forward-char, forward-word を用いるように変更。
;;          - その他各種関数拡張。
;;          - diff-detail-change-grain-char, diff-detail-change-grain-word
;;            を追加。
;;        ・diff-detail 状態から diff 状態への復帰方法を変更。
;;          - diff-text-attributes 追加。
;;          - diff-text-attributes-buffer-modified-count 追加。
;;          - diff-detail-save-attributes 追加。
;;          - diff-detail-restore-attributes 変更。
;;        ・diff-detail-find-text-attribute のバグ修正。
;;          - from と to の値が等しい tag が存在した場合にループに
;;            至ることがあった。
;;
;;      Mon, 08 Mar 2004 22:52:39 +0900
;;        ・diff-detail-blink 追加。
;;        ・*diff-detail-forward-interactive-hook* 追加
;;        ・diff-merge-ex, diff-merge-reverse-ex, diff-undo-ex 追加。
;;        ・その他。
;;
;;      Mon, 08 Mar 2004 01:16:13 +0900
;;        ・diff-detail, diff-detail-change-grain での token 正規表現入力
;;          用に hisotry (*diff-detail-token-regexp-history*) を追加。
;;        ・hisotry 追加に伴い diff-detail-uninstall 追加。
;;
;;      Sun, 07 Mar 2004 09:52:15 +0900
;;        ・$XYZZY/lisp/diff.l 中 diff-set-modified の不具合と同様の
;;          diff-detail-set-modified の不具合を修正。
;;        ・*diff-detail-merge-attributes* 追加。
;;        ・diff-detail-forward, diff-detail-backward で merge 状態の
;;          +, - 行に移動できなかった点を修正。
;;
;;      Mon, 01 Dec 2003 00:30:34 +0900
;;        ・以下を追加。
;;          diff-forward-ex,
;;          diff-backward-ex,
;;          diff-detail-merge, diff-detail-merge-reverse,
;;          diff-detail-undo
;;        ・キーバインド変更
;;
;;      Fri, 28 Nov 2003 12:49:03 +0900
;;        ・diff-detail-change-grain 追加
;;
;;      Sun, 23 Nov 2003 00:55:15 +0900
;;        ・diff-detail-forward, diff-detail-backward 追加
;;
;;      Mon, 27 Oct 2003 01:01:20 +0900
;;        ・token 単位での比較に拡張
;;
;;      Wed, 22 Oct 2003 11:23:12 +0900
;;        ・作成
;;
;;      Tue, 21 Oct 2003 10:43:27 +0900
;;        ・作成開始
;;

;; Todo:
;;
;;      ・文字コードの考慮
;;      ・HTML 出力時の文字コードの考慮
;;

;; Memo:
;;
;; ■Token
;;      ・改行文字は必ず単独でトークンになる。
;;          => ".+" と  "\\(.\\|\n\\)+" は同じ結果に
;;
;;      ・token-regexp にマッチした部分がトークン
;;      ・トークンとトークンの間の文字列もトークン
;;          => "[^x]+" と "x+" は同じ結果に  # x は任意の単位正規表現
;;
;;
;; ■BNF like.
;;
;;   <TAG>                   ::= <DIFF-TAG>         # 従来タグ
;;                             | <DIFF-EX-TAG>      # 従来タグに DETAIL 情報付加拡張
;;                             | <DIFF-DETAIL-TAG>  # 新規タグ
;;
;;   <DIFF-TAG>              ::= <DIFF-TAG-INIT>    # 初期タグ
;;                             | <DIFF-TAG-MERGE>   # マージ後タグ
;;                             | <DIFF-TAG-UNDO>    # マージをアンドゥした後のタグ
;;
;;   <DIFF-TAG-INIT>         ::= (ed::diff <OPERATION> (<OLD-LINE-RANGE> <NEW-LINE-RANGE>))
;;   <DIFF-TAG-MERGE>        ::= (ed::diff (<OPERATION> . <REVERSE>) <text>)
;;   <DIFF-TAG-UNDO>         ::= (ed::diff <OPERATION>)
;;
;;   <OLD-LINE-RAGE>         ::= <LINE-RANGE>
;;   <NEW-LINE-RAGE>         ::= <LINE-RANGE>
;;   <LINE-RANGE>            ::= (<FROM-LINE> . <TO-LINE>)  # FROM, TO 共に範囲に含む
;;   <FROM-LINE>             ::= <LINE>
;;   <TO-LINE>               ::= <LINE>
;;   <LINE>                  ::= <number>
;;
;;   ----------------------------------------
;;     <DIFF-TAG-INIT> において
;;       case 1) <OPERATION> == #\+
;;                  <OLD-LINE-RAGE> ::= (<対応直前行> . <対応直前行>)
;;                  <NEW-LINE-RAGE> ::= (<追加開始行 (含む)> . <追加終了行 (含む)>)
;;
;;       case 2) <OPERATION> == #\-
;;                  <OLD-LINE-RAGE> ::= (<削除開始行 (含む)> . <削除終了行 (含む)>)
;;                  <NEW-LINE-RAGE> ::= (<対応直前行> . <対応直前行>)
;;
;;       case 3) <OPERATION> == #\!
;;                  <OLD-LINE-RAGE> ::= (<更新開始行 (含む)> . <更新終了行 (含む)>)
;;                  <NEW-LINE-RAGE> ::= (<更新開始行 (含む)> . <更新終了行 (含む)>)
;;   ----------------------------------------
;;
;;   ----------------------------------------------------------------------
;;
;;   <DIFF-EX-TAG>           ::= <DIFF-EX-TAG-MERGE>   # マージ後タグ (DETAIL 情報保存)
;;
;;   <DIFF-EX-TAG-MERGE>     ::= (ed::diff (<OPERATION> . <REVERSE>) <text>
;;                                         (<OLD-ATTRIBUTES> . <NEW-ATTRIBUTES>))
;;
;;   <OLD-ATTRIBUTES>        ::= <attributes>
;;   <NEW-ATTRIBUTES>        ::= <attributes>
;;
;;   <attributes>            ::= <point 補正済、タグ該当範囲内の merge 前 test-attributes 情報>
;;
;;   ----------------------------------------------------------------------
;;
;;   <DIFF-DETAIL-TAG>       ::= <DIFF-DETAIL-TAG-INIT>  # 初期タグ
;;                             | <DIFF-DETAIL-TAG-MERGE> # マージ後タグ
;;                             | <DIFF-DETAIL-TAG-UNDO>  # マージをアンドゥした後のタグ
;;
;;   <DIFF-DETAIL-TAG-INIT>  ::= (ed::diff-detail <OPERATION> <DIFF-TAG> (<OLD-POINT-RANGE> <NEW-POINT-RANGE>))
;;   <DIFF-DETAIL-TAG-MERGE> ::= (ed::diff-detail (<OPERATION>  . <REVERSE>) <DIFF-TAG> <text>)
;;   <DIFF-DETAIL-TAG-UNDO>  ::= (ed::diff-detail <OPERATION> <DIFF-TAG>)
;;
;;   <OLD-POINT-RAGE>        ::= <POINT-RANGE>
;;   <NEW-POINT-RAGE>        ::= <POINT-RANGE>
;;   <POINT-RANGE>           ::= (<FROM-POINT> . <TO-POINT>)  # FROM は含み、TO は含まない
;;   <FROM-POINT>            ::= <POINT>
;;   <TO-POINT>              ::= <POINT>
;;   <POINT>                 ::= <number>
;;
;;   ----------------------------------------
;;     <DIFF-DETAIL-TAG-INIT> において
;;       case 1) <OPERATION> == #\+
;;                  <OLD-POINT-RAGE> ::= (<対応開始ポイント> . <対応開始ポイント>)
;;                  <NEW-POINT-RAGE> ::= (<追加開始ポイント (含む)> . <追加終了ポイント (含まない)>)
;;
;;       case 2) <OPERATION> == #\-
;;                  <OLD-POINT-RAGE> ::= (<削除開始ポイント> . <削除終了ポイント (含まない)>)
;;                  <NEW-POINT-RAGE> ::= (<対応開始ポイント> . <対応開始ポイント>)
;;
;;       case 3) <OPERATION> == #\!
;;                  <OLD-POINT-RAGE> ::= (<更新開始ポイント (含む)> . <更新終了ポイント (含まない)>)
;;                  <NEW-POINT-RAGE> ::= (<更新開始ポイント (含む)> . <更新終了ポイント (含まない)>)
;;   ----------------------------------------
;;
;;   <OPERATION>             ::= #\+ | #\- | #\!
;;   <REVERSE>               ::= nil | t
;;
;;   <text>                  ::= <文字列>
;;   <number>                ::= <0以上の整数>
;;

;; Info:
;;
;;    ・真鵺道 (Manued (Manuscript Editing language))
;;      http://www.mpi-sb.mpg.de/~hitoshi/otherprojects/manued/index-j.shtml
;;    ・DocDiff
;;      http://www.kt.rim.or.jp/~hisashim/docdiff/
;;

;; Licence:
;;
;;    diff-detail は修正BSDライセンスに基づいて利用可能です。
;;    <http://www.opensource.org/licenses/bsd-license.php>
;;
;;
;;    Copyright (C) 2001-2006, OHKUBO Hiroshi.  All rights reserved.
;;
;;    Redistribution and use in source and binary forms, with or without
;;    modification, are permitted provided that the following conditions
;;    are met:
;;
;;    1. Redistributions of source code must retain the above copyright
;;       notice, this list of conditions and the following disclaimer.
;;
;;    2. Redistributions in binary form must reproduce the above copyright
;;       notice, this list of conditions and the following disclaimer in
;;       the documentation and/or other materials provided with the
;;       distribution.
;;
;;    3. Neither the name of the University nor the names of its
;;       contributors may be used to endorse or promote products derived
;;       from this software without specific prior written permission.
;;
;;    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
;;    ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
;;    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
;;    A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
;;    OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
;;    SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
;;    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
;;    DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
;;    THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
;;    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
;;    OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;;

;;; Code:

(provide "diff-detail")

(require "diff")

(in-package "editor")

(export '(*diff-detail-old-file-attributes*
          *diff-detail-new-file-attributes*
          *diff-detail-merge-attributes*
          *diff-detail-blink-attributes*
          *diff-detail-blink-timeout*
          *diff-detail-token-regexp*
          *diff-detail-forward-interactive-hook*
          *diff-detail-mode-hook*
          *diff-detail-mode-map*
          *diff-detail-output-buffer-name*
          *diff-detail-temp-html-file*
          *diff-detail-html-header*
          *diff-detail-html-footer*
          *diff-detail-convert-to-html-mode*
          *diff-detail-manued-l-parenthesis-str*
          *diff-detail-manued-r-parenthesis-str*
          *diff-detail-manued-delete-str*
          *diff-detail-manued-swap-str*
          *diff-detail-manued-comment-str*
          *diff-detail-manued-escape-str*
          *diff-detail-manued-order-str*
          *diff-detail-manued-version-str*
          *diff-detail-convert-to-manued-mode*
          string-diff
          diff-detail
          diff-detail-char
          diff-detail-word
          diff-detail-change-grain
          diff-detail-change-grain-default
          diff-detail-change-grain-char
          diff-detail-change-grain-word
          diff-detail-forward
          diff-detail-backward
          diff-detail-merge
          diff-detail-merge-reverse
          diff-detail-undo
          diff-forward-ex
          diff-backward-ex
          diff-merge-ex
          diff-merge-reverse-ex
          diff-undo-ex
          diff-detail-switch-window
          diff-split-change
          diff-detail-convert-to-html
          diff-detail-view-html
          diff-detail-convert-to-manued))

(defvar *diff-detail-old-file-attributes* '(:bold t :background 6)
  "old file での diff-detail 強調表示属性")
(defvar *diff-detail-new-file-attributes* '(:bold t :background 6)
  "new file での diff-detail 強調表示属性")
(defvar *diff-detail-merge-attributes*
  (list :foreground *diff-merge-foreground*
        :background *diff-merge-background*)
  "merge 済み状態の表示属性")
(defvar *diff-detail-blink-attributes* '(:background 5)
  "diff-detail-blink での強調表示属性")
(defvar *diff-detail-blink-timeout* 0.3
  "diff-detail-blink の表示時間")
(defvar *diff-detail-token-regexp* "\\(\\w+\\|[ \t]\\)"
  "diff-detail でのデフォルト token 正規表現")
(define-history-variable *diff-detail-token-regexp-history* nil
  "diff-detail での token 正規表現ヒストリ")
(defvar *diff-detail-forward-interactive-hook* nil
  "diff-detail-forward インタラクティブ実行時 hook")
(defvar *diff-detail-mode-hook* nil
  "diff-detail-mode の hook")
(defvar *diff-detail-mode-map* nil
  "diff-detail-mode の keymap")

(unless *diff-detail-mode-map*
  (setq *diff-detail-mode-map* (make-sparse-keymap))
  (define-key *diff-detail-mode-map* #\M-Down 'diff-forward-ex)
  (define-key *diff-detail-mode-map* #\M-Up 'diff-backward-ex)
  (define-key *diff-detail-mode-map* #\q 'diff-quit)
  (define-key *diff-detail-mode-map* #\n 'diff-forward-ex)
  (define-key *diff-detail-mode-map* #\p 'diff-backward-ex)
  (define-key *diff-detail-mode-map* #\m 'diff-merge-ex)
  (define-key *diff-detail-mode-map* #\r 'diff-merge-reverse-ex)
  (define-key *diff-detail-mode-map* #\u 'diff-undo-ex)
  (define-key *diff-detail-mode-map* #\S-M-Down 'diff-detail-forward)
  (define-key *diff-detail-mode-map* #\S-M-Up 'diff-detail-backward)
  (define-key *diff-detail-mode-map* #\Q 'diff-quit)
  (define-key *diff-detail-mode-map* #\N 'diff-detail-forward)
  (define-key *diff-detail-mode-map* #\P 'diff-detail-backward)
  (define-key *diff-detail-mode-map* #\M 'diff-detail-merge)
  (define-key *diff-detail-mode-map* #\R 'diff-detail-merge-reverse)
  (define-key *diff-detail-mode-map* #\U 'diff-detail-undo)
  (define-key *diff-detail-mode-map* #\. 'diff-detail-change-grain)
  (define-key *diff-detail-mode-map* #\, 'diff-detail-change-grain-default)
  (define-key *diff-detail-mode-map* #\SPC 'diff-detail-blink)
  (define-key *diff-detail-mode-map* #\TAB 'diff-detail-switch-window)
  (define-key *diff-detail-mode-map* #\c 'diff-split-change)
  (define-key *diff-detail-mode-map* #\v 'diff-detail-view-html)
  (define-key *diff-detail-mode-map* '(#\C-c #\C-h) 'diff-detail-convert-to-html)
  (define-key *diff-detail-mode-map* '(#\C-c #\RET) 'diff-detail-convert-to-manued))
(define-key *diff-mode-map* #\. 'diff-detail-change-grain)
(define-key *diff-mode-map* #\, 'diff-detail-change-grain-default)
(define-key *diff-mode-map* #\SPC 'diff-detail-blink)
(define-key *diff-mode-map* #\TAB 'diff-detail-switch-window)
(define-key *diff-mode-map* #\c 'diff-split-change)
(define-key *diff-mode-map* #\v 'diff-detail-view-html)
(define-key *diff-mode-map* '(#\C-c #\C-h) 'diff-detail-convert-to-html)
(define-key *diff-mode-map* '(#\C-c #\RET) 'diff-detail-convert-to-manued)

(defvar *diff-detail-temp-html-file*
  (map-backslash-to-slash
   (merge-pathnames "diff-detail-temp.html"
                    (or (si:getenv "TEMP")
                        (si:getenv "TMP")
                        (user-homedir-pathname)
                        (si:system-root)))))

(defvar *diff-detail-output-buffer-name* "*DiffDetail Output*")

(defvar *diff-detail-html-encode-alist*
  '(("&" . "&amp;")
    ("<" . "&lt;")
    (">" . "&gt;")
    ( "\"" . "&quot;")
;   (" " . "&nbsp;") ; " " は状況に応じて変換
    ))
(defvar *diff-detail-html-header*
  "<?xml version=\"1.0\" encoding=\"Shift_JIS\"?>
<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"
\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">
<html><head>
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=Shift_JIS\" />
<title>Difference</title>
<style type=\"text/css\">
 body {font-family: monospace;}
 span.del {background: hotpink; border: thin inset;}
 span.add {background: deepskyblue; font-weight: bolder; border: thin outset;}
 span.before-change {background: yellow; border: thin inset;}
 span.after-change {background: lime; font-weight: bolder; border: thin outset;}
 li.entry .position {font-weight: bolder; margin-top: 0em; margin-bottom: 0em; padding-top: 0em; padding-bottom: 0em;}
 li.entry .body {margin-top: 0em; margin-bottom: 0em; padding-top: 0em; padding-bottom: 0em;}
</style>
</head><body><pre>")
(defvar *diff-detail-html-footer* "</pre></body></html>")
(defvar *diff-detail-convert-to-html-mode* 'html-mode)

(defconstant *diff-detail-manued-default-l-parenthesis-str* "[")
(defconstant *diff-detail-manued-default-r-parenthesis-str* "]")
(defconstant *diff-detail-manued-default-delete-str* "/")
(defconstant *diff-detail-manued-default-swap-str* "|")
(defconstant *diff-detail-manued-default-comment-str* ";")
(defconstant *diff-detail-manued-default-escape-str* "~")
(defconstant *diff-detail-manued-default-order-str* "older-first")

(defvar *diff-detail-manued-l-parenthesis-str* *diff-detail-manued-default-l-parenthesis-str*)
(defvar *diff-detail-manued-r-parenthesis-str* *diff-detail-manued-default-r-parenthesis-str*)
(defvar *diff-detail-manued-delete-str* *diff-detail-manued-default-delete-str*)
(defvar *diff-detail-manued-swap-str* *diff-detail-manued-default-swap-str*)
(defvar *diff-detail-manued-comment-str* *diff-detail-manued-default-comment-str*)
(defvar *diff-detail-manued-escape-str* *diff-detail-manued-default-escape-str*)
(defvar *diff-detail-manued-order-str* *diff-detail-manued-default-order-str*)
;; manued.el の実装には依存していないため "0.9.5" でなく "-"
(defvar *diff-detail-manued-version-str* "-")

(defvar *diff-detail-convert-to-manued-mode* 'text-mode)

(defvar-local diff-text-attributes nil)
(defvar-local diff-text-attributes-buffer-modified-count nil)

(defun string-tokenizer (str &optional token-regexp token-forward-func tmp-buffer)
  "文字列を正規表現または関数に従い token に分解"
  (let (pos str-list ret-list tmp-buffer-create-p)
    (while (setq pos (position #\LFD str))
      (push (substring str 0 pos) str-list)
      (push (copy-string "\n") str-list)
      (setq str (substring str (1+ pos))))
    (when (plusp (length str))
      (push str str-list))
    (setq str-list (nreverse str-list))
    ;;
    (cond
     (token-forward-func
      ;; tmp-buffer が指定されていない場合は、現在のバッファの
      ;; syntax-table で tmp-buffer を作成
      (unless tmp-buffer
        (setq tmp-buffer (create-new-buffer " *string-tokenizer-tmp*")
              tmp-buffer-create-p t)
        (save-excursion
          (use-syntax-table (syntax-table) tmp-buffer)
          (set-buffer tmp-buffer)
          (make-local-variable 'need-not-save)
          (setq need-not-save t)))
      (save-excursion
        (unwind-protect
            (progn
              (set-buffer tmp-buffer)
              (dolist (str str-list)
                (erase-buffer tmp-buffer)
                (insert str)
                (goto-char (point-min))
                (while (plusp (point-max))
                  (funcall token-forward-func)
                  (when (= (point) 0)
                    (goto-char (point-max)))
                  (push (buffer-substring 0 (point)) ret-list)
                  (delete-region (point) 0))))
          (when tmp-buffer-create-p
            (delete-buffer tmp-buffer))))
      (nreverse ret-list))
     (t
      (unless token-regexp
        (setq token-regexp (compile-regexp ".")))
      (dolist (str str-list)
        (while (string-match token-regexp str)
          (if (not (zerop (match-beginning 0)))
              (push (substring str 0 (match-beginning 0)) ret-list))
          (push (substring str (match-beginning 0) (match-end 0)) ret-list)
          (setq str (substring str (match-end 0))))
        (when (plusp (length str))
          (push str ret-list)))
      (nreverse ret-list)))))

(defun string-diff (new-string old-string &optional token-regexp token-forward-func tmp-buffer)
  "2 つの文字列間での diff"
  (when (string= new-string old-string)
    (return-from string-diff nil))
  (unless token-regexp
    (setq token-regexp (compile-regexp ".")))
  (let ((new-file (make-temp-file-name))
        (old-file (make-temp-file-name))
        (new-string-list (string-tokenizer new-string token-regexp token-forward-func tmp-buffer))
        (old-string-list (string-tokenizer old-string token-regexp token-forward-func tmp-buffer))
        new-string-length-list old-string-length-list
        (buffer nil) c diffs string-diffs)
    (let (len)
      (setq len 0)
      (push len new-string-length-list)
      (dolist (str new-string-list)
        (incf len (length str))
        (push len new-string-length-list))
      (setq new-string-length-list (nreverse new-string-length-list))
      (setq len 0)
      (push len old-string-length-list)
      (dolist (str old-string-list)
        (incf len (length str))
        (push len old-string-length-list))
      (setq old-string-length-list (nreverse old-string-length-list)))
    (unwind-protect
        (progn
          (with-open-file (fp new-file
                              :direction :output
                              :if-exists :supersede
                              :if-does-not-exist :create)
            (dolist (str new-string-list)
              (format fp "~A" str)
              (if (string/= str "\n")
                  (terpri fp))))
          (with-open-file (fp old-file
                              :direction :output
                              :if-exists :supersede
                              :if-does-not-exist :create)
            (dolist (str old-string-list)
              (format fp "~A" str)
              (if (string/= str "\n")
                  (terpri fp))))
          (setq buffer (create-new-buffer " *string-diff-tmp*"))
          (save-window-excursion
            (execute-shell-command (format nil "~A ~A \"~A\" \"~A\""
                                           *diff-command-name*
                                           *diff-command-option*
                                           old-file new-file)
                                   nil buffer))
          (setq diffs (diffs-set-offset (diff-scan buffer) -1 -1))
          (dolist (d diffs)
            (case (nth 1 d)
              (#\!
               (push (list 'string-diff #\!
                           (cons (nth (car (nth 2 d)) old-string-length-list)
                                 (nth (1+ (cdr (nth 2 d))) old-string-length-list))
                           (cons (nth (car (nth 3 d)) new-string-length-list)
                                 (nth (1+ (cdr (nth 3 d))) new-string-length-list)))
                     string-diffs))
              (#\+
               (push (list 'string-diff #\+
                           (cons (nth (1+ (car (nth 2 d))) old-string-length-list)
                                 (nth (1+ (cdr (nth 2 d))) old-string-length-list))
                           (cons (nth (car (nth 3 d)) new-string-length-list)
                                 (nth (1+ (cdr (nth 3 d))) new-string-length-list)))
                     string-diffs))
              (#\-
               (push (list 'string-diff #\-
                           (cons (nth (car (nth 2 d)) old-string-length-list)
                                 (nth (1+ (cdr (nth 2 d))) old-string-length-list))
                           (cons (nth (1+ (car (nth 3 d))) new-string-length-list)
                                 (nth (1+ (cdr (nth 3 d))) new-string-length-list)))
                     string-diffs)))))
      (progn
        (and buffer
             (delete-buffer buffer))
        (delete-file new-file :if-does-not-exist :skip)
        (delete-file old-file :if-does-not-exist :skip)))
    string-diffs))

(defun diffs-set-offset (diffs offset-new offset-old)
  "diffs の補正"
  (let (new-diffs)
    (dolist (d diffs)
      (push (list (nth 0 d) (nth 1 d)
                  (cons (+ (car (nth 2 d)) offset-old)
                        (+ (cdr (nth 2 d)) offset-old))
                  (cons (+ (car (nth 3 d)) offset-new)
                        (+ (cdr (nth 3 d)) offset-new)))
            new-diffs))
    (nreverse new-diffs)))

(defun diff-detail-merged-p (tag)
  "tag が diff, diff-detail での merge 済みを示すものであるか判定"
  (and (member (safe-car tag) '(diff diff-detail))
       (consp (safe-cadr tag))))

(defun diff-detail-modified-p (tag)
  "カレントバッファへの変更済みを示す tag か判定"
  (and (diff-detail-merged-p tag)
       (let ((reverse (cdadr tag)))
         (or (and diff-new-file-p reverse)
             (and (not diff-new-file-p) (not reverse))))))

(defun diff-detail-set-modified ()
  "diff, diff-detail での merge 済み状態が存在した場合にバッファを編集済みへ"
  (set-buffer-modified-p (find-text-attribute-if #'diff-detail-modified-p)))

(defun diff-detail-merge-1 (old-buffer p1 p2 new-buffer q1 q2 tag ope reverse)
  "new-buffer の変更を old-buffer に merge するための内部関数"
  (save-excursion
    (let* ((diff-tag (caddr tag))
           (new-tag (list 'diff-detail (cons ope reverse) diff-tag nil)))
      (set-buffer old-buffer)
      (delete-text-attributes tag)
      (let ((text (save-excursion
                    (set-buffer new-buffer)
                    (delete-text-attributes tag)
                    (apply #'set-text-attribute q1 q2 new-tag
                           (append *diff-detail-merge-attributes*
                                   (list :prefix ope :extend t)))
                    (buffer-substring q1 q2)))
            (buffer-read-only nil))
        (declare (special buffer-read-only))
        (goto-char p1)
        (apply #'set-text-attribute
               (point)
               (progn
                 (unless (eq ope #\+)
                   (setf (cadddr new-tag) (buffer-substring p1 p2))
                   (delete-region p1 p2))
                 (unless (eq ope #\-)
                   (insert text))
                 (point))
               new-tag
               (append *diff-detail-merge-attributes*
                       (list :prefix ope :extend t)))))))

(defun diff-detail-undo-1 (old-buffer p1 p2 new-buffer q1 q2 tag ope reverse)
  "diff-detail-modify から呼び出される内部関数"
  (save-excursion
    (let* ((diff-tag (caddr tag))
           (new-tag (list 'diff-detail ope diff-tag))
           ofa nfa)
      (if reverse
          (setq nfa *diff-detail-old-file-attributes*
                ofa *diff-detail-new-file-attributes*)
        (setq ofa *diff-detail-old-file-attributes*
              nfa *diff-detail-new-file-attributes*))
      (set-buffer new-buffer)
      (delete-text-attributes tag)
      (apply #'set-text-attribute q1 q2 new-tag
             (append nfa (list :prefix ope :extend t)))
      (set-buffer old-buffer)
      (delete-text-attributes tag)
      (let ((text (cadddr tag))
            (buffer-read-only nil))
        (declare (special buffer-read-only))
        (goto-char p1)
        (apply #'set-text-attribute
               (point)
               (progn
                 (delete-region p1 p2)
                 (and text (insert text))
                 (point))
               new-tag
               (append ofa (list :prefix ope :extend t)))
        (diff-detail-set-modified)))))

(defun diff-detail-modify (undo-p reverse)
  "diff-detail-merge(-reverse), diff-detail-undo から呼び出される関数"
  (interactive "p")
  (multiple-value-bind (p1 p2 tag)
      (find-text-attribute-point (point))
    (let* ((buffer (selected-buffer))
           (old-buffer buffer)
           (new-buffer diff-buffer)
           q1 q2)
      (unless (and p1
                   (eq 'diff-detail (safe-car tag))
                   (if undo-p
                       (diff-detail-merged-p tag)
                     (not (diff-detail-merged-p tag)))
                   (save-excursion
                     (set-buffer diff-buffer)
                     (multiple-value-setq (q1 q2)
                       (find-text-attribute tag))))
        (plain-error "ないっす"))
      (when diff-new-file-p
        (rotatef old-buffer new-buffer)
        (rotatef p1 q1)
        (rotatef p2 q2))
      (cond (undo-p
             (let ((ope (caadr tag))
                   (reverse (cdadr tag)))
               (if reverse
                   (diff-detail-undo-1 new-buffer q1 q2 old-buffer p1 p2 tag
                                (diff-toggle-code ope) reverse)
                 (diff-detail-undo-1 old-buffer p1 p2 new-buffer q1 q2 tag
                                     ope reverse))))
            (reverse
             (diff-detail-merge-1 new-buffer q1 q2 old-buffer p1 p2 tag
                           (diff-toggle-code (cadr tag)) t))
            (t
             (diff-detail-merge-1 old-buffer p1 p2 new-buffer q1 q2 tag
                                  (cadr tag) nil)))
      t)))

(defun diff-detail-mode (buffer)
  "diff-detail 実行時バッファのモード"
  (save-excursion
    (set-buffer buffer)
    (setq buffer-mode 'diff-detail-mode)
    (setq mode-name "DiffDetail")
    (use-keymap *diff-detail-mode-map*)
    (run-hooks '*diff-detail-mode-hook*)))

(setf (get 'diff-detail 'minibuffer-history-variable)
      '*diff-detail-token-regexp-history*)
(setf (get '*diff-detail-token-regexp-history*
           'minibuffer-reject-newline) t)

(defun diff-detail (new-file old-file &optional (token-regexp *diff-detail-token-regexp*) token-forward-func)
  "正規表現または関数で指定したトークン単位で diff を行う"
  (interactive "fdiff(new file): \nfdiff(old file): \nsToken-Regexp: "
    :default2 (or *diff-detail-token-regexp*
                  (car *diff-detail-token-regexp-history*))
    :history2 'diff-detail)
  (long-operation
    (setq new-file (namestring new-file))
    (setq old-file (namestring old-file))
    (diff new-file old-file)
    (when (and (find-buffer *diff-old-buffer-name*)
               (find-buffer *diff-new-buffer-name*))
      (diff-detail-mode *diff-old-buffer-name*)
      (diff-detail-mode *diff-new-buffer-name*)
      (diff-detail-1 token-regexp token-forward-func))))

(defun diff-detail-char (new-file old-file)
  "文字単位で diff を行う"
  (interactive "fdiff(new file): \nfdiff(old file): ")
  (diff-detail new-file old-file nil #'forward-char))

(defun diff-detail-word (new-file old-file)
  "単語単位で diff を行う"
  (interactive "fdiff(new file): \nfdiff(old file): ")
  (diff-detail new-file old-file nil #'forward-word))

(defun diff-detail-change-grain (&optional token-regexp token-forward-func)
  "正規表現または関数で指定したトークン単位で再度 diff を行う"
  (interactive "sDiff-Detail Token-Regexp: "
    :default0 (or *diff-detail-token-regexp*
                  (car *diff-detail-token-regexp-history*))
    :history0 'diff-detail)
  (long-operation
    (when (and (find-buffer *diff-old-buffer-name*)
               (find-buffer *diff-new-buffer-name*))
      (diff-detail-mode *diff-old-buffer-name*)
      (diff-detail-mode *diff-new-buffer-name*)
      (diff-detail-1 token-regexp token-forward-func))))

(defun diff-detail-change-grain-default ()
  (interactive)
  (diff-detail-change-grain *diff-detail-token-regexp*))

(defun diff-detail-change-grain-char ()
  (interactive)
  (diff-detail-change-grain nil #'forward-char))

(defun diff-detail-change-grain-word ()
  (interactive)
  (diff-detail-change-grain nil #'forward-word))

(defun diff-detail-1 (token-regexp &optional token-forward-func)
  "diff-detail, diff-detail-change-grain から呼び出される内部関数
token-forward-func は token-regexp より優先される。"
  (let ((buffer-old (find-buffer *diff-old-buffer-name*))
        (buffer-new (find-buffer *diff-new-buffer-name*))
        list-text-attributes-old list-text-attributes-new
        tag attr-old attr-new start-old start-new end-old end-new
        substring-old substring-new string-diffs
        number-of-attribute (processing-number-of-attribute 0)
        string-diff-tmp-buffer)
    (unless (and buffer-old buffer-new)
      (return-from diff-detail-1 nil))
    ;; merge 状態の復旧
    (if (or (buffer-modified-p buffer-old)
            (buffer-modified-p buffer-new))
        (diff-undo-buffer))
    (save-excursion
      (if (diff-detail-p buffer-new)
          ;; diff 状態への復旧
          (diff-detail-restore-attributes)
        ;; diff 状態の保存
        (diff-detail-save-attributes))
      ;; diff-detail 状態への変更
      (when (or (and token-regexp (not (equal token-regexp "")))
                token-forward-func)
        (when (and (stringp token-regexp)
                   (not (regexpp token-regexp)))
        (setq token-regexp (compile-regexp token-regexp)))
        (set-buffer buffer-old)
        (setq list-text-attributes-old (list-text-attributes))
        (set-buffer buffer-new)
        (setq list-text-attributes-new (list-text-attributes))
        (setq number-of-attribute (length list-text-attributes-old))
        ;; string-diff-tmp-buffer の作成
        (when token-forward-func
          (save-excursion
            (setq string-diff-tmp-buffer (create-new-buffer " *diff-detail-tmp*"))
            (use-syntax-table (syntax-table buffer-new) string-diff-tmp-buffer)
            (set-buffer string-diff-tmp-buffer)
            (make-local-variable 'need-not-save)
            (setq need-not-save t)))
        (while list-text-attributes-old
          (incf processing-number-of-attribute)
          (message "diff-detail: ~D/~D (~2D%)"
                   processing-number-of-attribute number-of-attribute
                   (floor (* 100 (/ processing-number-of-attribute number-of-attribute))))
          (setq tag (nth 2 (car list-text-attributes-old)))
          (when (and (consp tag) (eq (car tag) 'diff) (eq (cadr tag) #\!))
            (setq start-old (nth 0 (car list-text-attributes-old)))
            (setq end-old (nth 1 (car list-text-attributes-old)))
            (setq attr-old (cdddr (car list-text-attributes-old)))
            (setq substring-old (progn
                                  (set-buffer buffer-old)
                                  (buffer-substring start-old end-old)))
            (setq start-new (nth 0 (car list-text-attributes-new)))
            (setq end-new (nth 1 (car list-text-attributes-new)))
            (setq attr-new (cdddr (car list-text-attributes-new)))
            (setq substring-new (progn
                                  (set-buffer buffer-new)
                                  (buffer-substring start-new end-new)))
            (setq string-diffs
                  (diffs-set-offset
                   (string-diff substring-new substring-old token-regexp
                                token-forward-func string-diff-tmp-buffer)
                   start-new start-old))
            (dolist (d string-diffs)
              (setq d (list 'diff-detail (nth 1 d) tag (nth 2 d) (nth 3 d)))
              (set-buffer buffer-old)
              (apply #'set-text-attribute
                     (car (nth 3 d)) (cdr (nth 3 d)) d
                     (append *diff-detail-old-file-attributes* attr-old))
              (set-buffer buffer-new)
              (apply #'set-text-attribute
                     (car (nth 4 d)) (cdr (nth 4 d)) d
                     (append *diff-detail-new-file-attributes* attr-new))))
          (setq list-text-attributes-old (cdr list-text-attributes-old))
          (setq list-text-attributes-new (cdr list-text-attributes-new))))
      (when string-diff-tmp-buffer
        (delete-buffer string-diff-tmp-buffer)))
    (message "diff-detail: done.")))

(defun diff-detail-match-tag-p (dummy tag)
  (or (eq (safe-car tag) 'diff-detail)
      (and (eq (safe-car tag) 'diff)
           (let (operation)
             (setq operation (safe-cadr tag))
             (if (consp operation)
                 (setq operation (car operation)))
             (member operation '(#\+ #\-))))))

(defun diff-detail-forward (&optional reverse interactive-p)
  "次の diff-detail 部分、もしくは diff で +, - の部分に移動"
  (interactive "p")
  (multiple-value-bind (p1 p2 tag)
      (if reverse
          (find-text-attribute nil :end (- (point) 1) :from-end t
                               :test #'diff-detail-match-tag-p)
        (find-text-attribute nil :start (+ (point) 1)
                             :test #'diff-detail-match-tag-p))
    (unless (and p1
                 (save-excursion
                   (set-buffer diff-buffer)
                   (setq p2 (find-text-attribute tag))))
      (plain-error "ないっす"))
    (diff-update p1 p2))
  (if (or (interactive-p) interactive-p)
      (run-hooks '*diff-detail-forward-interactive-hook*)))

(defun diff-detail-backward ()
  "前の diff-detail 部分、もしくは diff で +, - の部分に移動"
  (interactive)
  (diff-detail-forward t (interactive-p)))

(add-hook '*diff-detail-forward-interactive-hook* 'diff-detail-blink)

(defun diff-detail-merge (&optional reverse)
  "現在位置の diff-detail 部分について new ファイルの内容を old ファイルに反映"
  (interactive "p")
  (diff-detail-modify nil reverse))

(defun diff-detail-merge-reverse ()
  "現在位置の diff-detail 部分について old ファイルの内容を new ファイルに反映"
  (interactive)
  (diff-detail-merge t))

(defun diff-detail-undo ()
  "diff-detail-merge, diff-detail-merge-reverse 済み diff-detail 部分を undo"
  (interactive)
  (diff-detail-modify t nil))

(defun diff-detail-find-text-attribute (tag &key start end from-end)
  "diff-detail タグでの分割を考慮した上で diff タグの位置を検索。
find-text-attribute と同様に、開始ポイント、終了ポイント、タグを返す。
tag に 「nil, diff タグ」以外を指定した場合の動作は不定。
start end from-end 指定は find-text-attribute に準ずる。"
  (save-excursion
    (let (from to (otag tag))
      (unless start (setq start (point-min)))
      (unless end (setq end (point-max)))
      (multiple-value-bind (from1 to1 tag1)
          (if from-end
              (find-text-attribute tag :end end :from-end t
                                   :test #'(lambda (tag target-tag)
                                             (if tag
                                                 (eq tag target-tag)
                                               (member (safe-car target-tag)
                                                       '(diff diff-detail)))))
            (find-text-attribute tag :start start
                                 :test #'(lambda (tag target-tag)
                                           (if tag
                                               (eq tag target-tag)
                                             (member (safe-car target-tag)
                                                     '(diff diff-detail))))))
        ;; diff もしくは diff-detail タグが存在した場合
        (when from1
          (unless tag
            ;; diff のタグを取得
            (if (eq (car tag1) 'diff)
                (setq tag tag1)
              (setq tag (caddr tag1))))
          ;; diff タグの先頭開始位置 (from) の取得
          (multiple-value-bind (from2 to2 tag2)
              (find-text-attribute
               tag :test #'(lambda (tag target-tag)
                             (or (eq tag target-tag)
                                 (and (eq (safe-car target-tag) 'diff-detail)
                                      (eq (safe-caddr target-tag) tag)))))
            (setq from from2))
          ;; diff タグの末尾終了位置 (to) の取得
          (multiple-value-bind (from2 to2 tag2)
              (find-text-attribute
               tag :end (point-max) :from-end t
               :test #'(lambda (tag target-tag)
                         (or (eq tag target-tag)
                             (and (eq (safe-car target-tag) 'diff-detail)
                                  (eq (safe-caddr target-tag) tag)))))
            (setq to to2))
          (if (and (not from-end) (< from start))
              ;; 結果的に diff タグ開始位置が start より前だった場合は次を検索
              (diff-detail-find-text-attribute
               otag :start (if (= start to) (1+ start) to) :end end :from-end nil)
            (values from to tag)))))))

(defun diff-detail-find-text-attribute-point (point &key detail-enable)
  "point での diff タグについて find-text-attribute-point と同様のものを返す。
detail-enable が non-nil で point に diff-detail タグがある場合、
diff-detail タグについて find-text-attribute-point と同様のものを返す。"
  (let (from to tag return-list)
    (multiple-value-bind (from1 to1 tag1)
        (find-text-attribute-point point)
      (cond
       ((and detail-enable tag1 (eq (safe-car tag1) 'diff-detail))
        (find-text-attribute-point point))
       ((and tag1 (member (safe-car tag1) '(diff diff-detail)))
        ;; diff タグの取得
        (if (eq (car tag1) 'diff)
            (setq tag tag1)
          (setq tag (caddr tag1)))
        ;; 開始位置、終了位置の取得
        (multiple-value-bind (from2 to2 tag2)
            (diff-detail-find-text-attribute tag)
          (setq from from2 to to2)
          ;; from to tag 以外の属性を取得
          (multiple-value-bind (from3 to3 tag3)
              (find-text-attribute tag)
            (when from3
              (setq return-list
                    (multiple-value-list (find-text-attribute-point from3)))
              (setf (nth 0 return-list) from)
              (setf (nth 1 return-list) to)
              (apply 'values return-list)))))))))

(defun diff-detail-list-text-attributes ()
  "list-text-attributes から diff-detail タグによる影響をクリーニングして返す"
  (let (to tag work-list-text-attributes return-list-text-attributes)
    (dolist (attr (list-text-attributes))
      (setq to (nth 1 attr) tag (nth 2 attr))
      ;; 保存していた diff タグに変更
      (when (eq (safe-car tag) 'diff-detail)
        (setq tag (nth 2 tag))
        (setf (nth 2 attr) tag)
        (setf (cdddr attr)
              (if diff-new-file-p
                  (list :foreground *diff-new-file-foreground*
                        :background *diff-new-file-background*
                        :prefix #\! :extend t)
                (list :foreground *diff-old-file-foreground*
                      :background *diff-old-file-background*
                      :prefix #\! :extend t))))
      ;; 更新 or 登録
      (if (and (eq (safe-car tag) 'diff)
               (setq work-list-text-attributes
                     (member tag return-list-text-attributes :key #'safe-caddr)))
          (progn
            (setq return-list-text-attributes work-list-text-attributes)
            (setf (cadar return-list-text-attributes) to))
        (push attr return-list-text-attributes)))
    (nreverse return-list-text-attributes)))

(defun diff-detail-blink ()
  "現在位置の diff, diff-detail 部分に対応する diff-buffer の範囲をブリンク"
  (interactive)
  (let ((opoint (point)))
    (multiple-value-bind (p1 p2 tag)
        (find-text-attribute-point (point))
      (let ((buffer (selected-buffer))
            q1 q2 text-attribute-list)
        (unless (and p1
                     (member (safe-car tag) '(diff diff-detail))
                     (save-excursion
                       (set-buffer diff-buffer)
                       (multiple-value-setq (q1 q2)
                         (diff-detail-find-text-attribute tag))))
          (plain-error "ないっす"))
        (diff-update p1 q1)
        (goto-char opoint)
        (save-excursion
          (set-buffer diff-buffer)
          (setq text-attribute-list (list-text-attributes q1 q2))
          (apply #'set-text-attribute q1 q2 'diff-detail-blink
                 (append *diff-detail-blink-attributes*
                         (list :prefix #\* :extend t))))
        (sit-for *diff-detail-blink-timeout*)
        (save-excursion
          (set-buffer diff-buffer)
          (delete-text-attribute-point q1)
          ;; 正順で set-text-attribute すると from と to が一致している
          ;; ものがつぶれてしまうため逆順で set-text-attribute する
          (dolist (attr (reverse text-attribute-list))
            (apply #'set-text-attribute attr)))))))

(defun diff-detail-undo-region (from to)
  "from to 範囲内の diff-detail の merge を undo"
  (save-excursion
    (save-restriction
      (if (< to from)
          (rotatef from to))
      (narrow-to-region from to)
      (loop
        (multiple-value-bind (from1 to1 tag1)
            (find-text-attribute-if #'(lambda (tag)
                                        (and (consp tag)
                                             (eq (car tag) 'diff-detail)
                                             (diff-detail-merged-p tag))))
            (if from1
                (progn
                  (goto-char from1)
                  (diff-detail-undo))
              (return)))))))

(defun diff-detail-undo-current-diff ()
  "現在の diff 範囲に属する diff-detail の merge を undo"
  (interactive)
  (multiple-value-bind (from to tag)
      (diff-detail-find-text-attribute-point (point))
    (if from
        (diff-detail-undo-region from to))))

(defun diff-detail-undo-buffer (&optional buffer)
  "バッファの diff-detail の merge を undo"
  (save-excursion
    (if buffer
        (set-buffer buffer))
    (diff-detail-undo-region (point-min) (point-max))))

(defun diff-undo-buffer (&optional buffer)
  "バッファの diff の merge を undo"
  (save-excursion
    (if buffer
        (set-buffer buffer))
    (loop
      (multiple-value-bind (from to tag)
          (find-text-attribute-if #'diff-detail-merged-p)
        (if from
            (progn
              (goto-char from)
              (ignore-errors (diff-undo-ex)))
          (return))))))

(defun diff-detail-save-attributes ()
  (let ((buffer-old (find-buffer *diff-old-buffer-name*))
        (buffer-new (find-buffer *diff-new-buffer-name*)))
    (save-excursion
      (set-buffer buffer-old)
      (unless (eql (buffer-modified-count) diff-text-attributes-buffer-modified-count)
        (setq diff-text-attributes (list-text-attributes))
        (setq diff-text-attributes-buffer-modified-count (buffer-modified-count)))
      (set-buffer buffer-new)
      (unless (eql (buffer-modified-count) diff-text-attributes-buffer-modified-count)
        (setq diff-text-attributes (list-text-attributes))
        (setq diff-text-attributes-buffer-modified-count (buffer-modified-count))))))

(defun diff-detail-restore-attributes ()
  "diff-detail による attributes の変化をクリーニングする"
  (let ((buffer-old (find-buffer *diff-old-buffer-name*))
        (buffer-new (find-buffer *diff-new-buffer-name*)))
    (save-excursion
      (set-buffer buffer-old)
      (clear-all-text-attributes)
      (dolist (attr (reverse diff-text-attributes))
        (apply #'set-text-attribute attr))
      (set-buffer buffer-new)
      (clear-all-text-attributes)
      (dolist (attr (reverse diff-text-attributes))
        (apply #'set-text-attribute attr)))))

(defun diff-detail-text-attributes-set-offset (text-attributes offset)
  "text-attributes の from to を offset 補正する。
副作用として text-attributes 自体が書き換わる"
  (dolist (attr text-attributes)
    (setf (car attr) (+ (car attr) offset))
    (setf (cadr attr) (+ (cadr attr) offset)))
  text-attributes)

(defun diff-detail-text-attributes-choice (text-attributes)
  "text-attributes から diff-detail タグのみ抽出"
  (let (return-text-attributes)
    (dolist (attr text-attributes)
      (if (eq (safe-caaddr attr) 'diff-detail)
          (push attr return-text-attributes)))
    (nreverse return-text-attributes)))

(defun diff-detail-text-attributes-replace-diff-tag (text-attributes diff-tag)
  "diff-detail タグ中 diff タグを置換する。
副作用として text-attributes 自体が書き換わる"
  (dolist (attr text-attributes)
    (if (eq (safe-caaddr attr) 'diff-detail)
        (setf (nth 2 (nth 2 attr)) diff-tag)))
  text-attributes)

(defun diff-merge-1-ex (old-buffer p1 p2 new-buffer q1 q2 tag ope reverse)
  "merge 前 diff 範囲内 attributes 情報を保存するように拡張した diff-merge-1"
  (save-excursion
    (let ((new-tag (list 'diff (cons ope reverse) nil nil))
          old-attributes new-attributes)
      (set-buffer old-buffer)
      (delete-text-attributes tag)
      (let ((text (save-excursion
                    (set-buffer new-buffer)
                    (setq new-attributes
                          (diff-detail-text-attributes-choice
                           (diff-detail-text-attributes-set-offset
                            (list-text-attributes q1 q2) (- q1))))
                    (delete-text-attributes tag)
                    (set-text-attribute q1 q2 new-tag
                                        :foreground *diff-merge-foreground*
                                        :background *diff-merge-background*
                                        :prefix ope :extend t)
                    (buffer-substring q1 q2)))
            (buffer-read-only nil))
        (declare (special buffer-read-only))
        (setq old-attributes
              (diff-detail-text-attributes-choice
               (diff-detail-text-attributes-set-offset
                (list-text-attributes p1 p2) (- p1))))
        (if diff-new-file-p
            (rotatef old-attributes new-attributes))
        (setf (cadddr new-tag) (cons old-attributes new-attributes))
        (goto-char p1)
        (set-text-attribute (point)
                            (progn
                              (unless (eq ope #\+)
                                (setf (caddr new-tag) (buffer-substring p1 p2))
                                (delete-region p1 p2))
                              (unless (eq ope #\-)
                                (insert text))
                              (point))
                            new-tag
                            :foreground *diff-merge-foreground*
                            :background *diff-merge-background*
                            :prefix ope :extend t)))))

(defun diff-undo-1-ex (old-buffer p1 p2 new-buffer q1 q2 tag ope reverse)
  "merge 前 diff 範囲内 attributes 情報を復元するように拡張した diff-undo-1"
  (save-excursion
    (let* ((new-tag (list 'diff ope))
           ofg obg nfg nbg
           (old-attributes (diff-detail-text-attributes-replace-diff-tag
                            (car (safe-cadddr tag)) new-tag))
           (new-attributes (diff-detail-text-attributes-replace-diff-tag
                            (cdr (safe-cadddr tag)) new-tag)))
      (if reverse
          (setq nfg *diff-old-file-foreground*
                nbg *diff-old-file-background*
                ofg *diff-new-file-foreground*
                obg *diff-new-file-background*)
        (setq ofg *diff-old-file-foreground*
              obg *diff-old-file-background*
              nfg *diff-new-file-foreground*
              nbg *diff-new-file-background*))
      (set-buffer new-buffer)
      (unless diff-new-file-p
        (rotatef old-attributes new-attributes))
      (delete-text-attributes tag)
      (set-text-attribute q1 q2 new-tag
                          :foreground nfg
                          :background nbg
                          :prefix ope :extend t)
      ;; 逆順に set-text-attributre
      (dolist (attr (reverse (diff-detail-text-attributes-set-offset
                              new-attributes q1)))
        (apply #'set-text-attribute attr))
      (set-buffer old-buffer)
      (delete-text-attributes tag)
      (let ((text (caddr tag))
            (buffer-read-only nil))
        (declare (special buffer-read-only))
        (goto-char p1)
        (set-text-attribute (point)
                            (progn
                              (delete-region p1 p2)
                              (and text (insert text))
                              (point))
                            new-tag
                            :foreground ofg
                            :background obg
                            :prefix ope :extend t)
        ;; 逆順に set-text-attributre
        (dolist (attr (reverse (diff-detail-text-attributes-set-offset
                                old-attributes p1)))
          (apply #'set-text-attribute attr))
        (diff-detail-set-modified)))))

(defun diff-modify-ex (undo-p reverse)
  "merge 前 diff 範囲内 attributes 情報を扱うように拡張した diff-modify"
  (interactive "p")
  ;; 該当 diff に対する diff-detail での変更を全て undo
  (diff-detail-undo-current-diff)
  (multiple-value-bind (p1 p2 tag)
      (diff-detail-find-text-attribute-point
       (save-excursion (goto-bol) (point)))
    (let* ((buffer (selected-buffer))
           (old-buffer buffer)
           (new-buffer diff-buffer)
           q1 q2)
      (unless (and p1
                   (eq 'diff (safe-car tag))
                   (if undo-p
                       (diff-detail-merged-p tag)
                     (not (diff-detail-merged-p tag)))
                   (save-excursion
                     (set-buffer diff-buffer)
                     (multiple-value-setq (q1 q2)
                       (diff-detail-find-text-attribute tag))))
        (plain-error "ないっす"))
      (when diff-new-file-p
        (rotatef old-buffer new-buffer)
        (rotatef p1 q1)
        (rotatef p2 q2))
      (cond (undo-p
             (let ((ope (caadr tag))
                   (reverse (cdadr tag)))
               (if reverse
                   (diff-undo-1-ex new-buffer q1 q2 old-buffer p1 p2 tag
                                   (diff-toggle-code ope) reverse)
                 (diff-undo-1-ex old-buffer p1 p2 new-buffer q1 q2 tag
                                 ope reverse))))
            (reverse
             (diff-merge-1-ex new-buffer q1 q2 old-buffer p1 p2 tag
                              (diff-toggle-code (cadr tag)) t))
            (t
             (diff-merge-1-ex old-buffer p1 p2 new-buffer q1 q2 tag
                              (cadr tag) nil)))
      t)))

(defun diff-forward-ex (&optional reverse)
  "diff-detail を考慮し次の diff 部分へ移動"
  (interactive "p")
  (multiple-value-bind (p1 p2 tag)
      (if reverse
          (diff-detail-find-text-attribute nil :end (1- (point)) :from-end t)
        (diff-detail-find-text-attribute nil :start (1+ (point))))
    (unless (and p1
                 (save-excursion
                   (set-buffer diff-buffer)
                   (setq p2 (find-text-attribute tag))))
      (plain-error "ないっす"))
    (diff-update p1 p2)))

(defun diff-backward-ex ()
  "diff-detail を考慮し前の diff 部分へ移動"
  (interactive)
  (diff-forward-ex t))

(defun diff-merge-ex (&optional reverse)
  "拡張 diff-merge"
  (interactive "p")
  (diff-modify-ex nil reverse))

(defun diff-merge-reverse-ex ()
  "拡張 diff-merge-reverse"
  (interactive)
  (diff-merge-ex t))

(defun diff-undo-ex ()
  "拡張 diff-undo"
  (interactive)
  (diff-modify-ex t nil))

(defun diff-detail-switch-window ()
  "diff-buffer の対応する位置へ移動"
  (interactive)
  (multiple-value-bind (p1 p2 tag)
      (find-text-attribute-point (point))
    (let ((buffer (selected-buffer)) q1 q2)
      (unless (and p1
                   (member (safe-car tag) '(diff diff-detail))
                   (save-excursion
                     (set-buffer diff-buffer)
                     (multiple-value-setq (q1 q2)
                       (diff-detail-find-text-attribute tag))))
        (plain-error "ないっす"))
      (diff-update p1 q1)
      (if (get-buffer-window diff-buffer)
          (set-window (get-buffer-window diff-buffer))))))

(defun diff-split-change ()
  "diff 画面の縦横分割の切り替え"
  (interactive)
  (setq *diff-split-vertically* (not *diff-split-vertically*))
  (delete-other-windows)
  (diff-set-buffer diff-buffer)
  (diff-set-buffer diff-buffer))

(defun diff-detail-p (&optional buffer)
  (save-excursion
    (when buffer
      (set-buffer buffer))
    (find-text-attribute 'diff-detail :key #'car)))

;; 結果の変換出力
(defun diff-detail-convert-to-x (main-func &optional header-func footer-func)
  (unless diff-buffer
    (return-from diff-detail-convert-to-x nil))
  (long-operation
    (let ((buffer (get-buffer-create *diff-detail-output-buffer-name*))
          diff-detail-p from to common-str del-str add-str
          (processing-number-of-attribute 0))
      (save-excursion
        (save-excursion
          (set-buffer buffer)
          (setq buffer-read-only nil))
        (erase-buffer buffer)
        (unless diff-new-file-p
          (set-buffer diff-buffer))
        (with-output-to-buffer (buffer)
          (goto-char (point-min))
          (setq from (point) to (point))
          (setq diff-detail-p (diff-detail-p))
          (when header-func (funcall header-func))
          (cond
           ;; diff-detail の場合
           (diff-detail-p
            ;; 最初
            (multiple-value-bind (p1 p2 tag)
                (find-text-attribute-point (point))
              (when (diff-detail-match-tag-p nil tag)
                (message "diff-detail convert: ~D" (incf processing-number-of-attribute))
                (setq add-str (buffer-substring p1 p2))
                (setq to p2)
                (save-excursion
                  (set-buffer diff-buffer)
                  (multiple-value-bind (q1 q2)
                      (diff-detail-find-text-attribute tag)
                    (setq del-str (buffer-substring q1 q2))))
                (funcall main-func nil del-str add-str)
                (setq from to)))
            ;; ループ
            (while (handler-case (progn (diff-detail-forward) t) (error (c) nil))
              (message "diff-detail convert: ~D" (incf processing-number-of-attribute))
              (setq common-str (buffer-substring from (point)))
              (multiple-value-bind (p1 p2 tag)
                  (find-text-attribute-point (point))
                (setq add-str (buffer-substring p1 p2))
                (setq to p2)
                (save-excursion
                  (set-buffer diff-buffer)
                  (multiple-value-bind (q1 q2)
                      (diff-detail-find-text-attribute tag)
                    (setq del-str (buffer-substring q1 q2)))))
              (funcall main-func common-str del-str add-str)
              (setq from to))
            ;; 最後
            (message "diff-detail convert: ~D done." processing-number-of-attribute)
            (setq common-str (buffer-substring from (point-max)))
            (funcall main-func common-str nil nil))
           ;; diff の場合
           (t
            ;; 最初
            (multiple-value-bind (p1 p2 tag)
                (find-text-attribute-point (point))
              (when (eq 'diff (safe-car tag))
                (message "diff-detail convert: ~D" (incf processing-number-of-attribute))
                (setq add-str (buffer-substring p1 p2))
                (setq to p2)
                (save-excursion
                  (set-buffer diff-buffer)
                  (multiple-value-bind (q1 q2)
                      (find-text-attribute tag)
                    (setq del-str (buffer-substring q1 q2))))
                (funcall main-func nil del-str add-str)
                (setq from to)))
            ;; ループ
            (while (handler-case (progn (diff-forward) t) (error (c) nil))
              (message "diff-detail convert: ~D" (incf processing-number-of-attribute))
              (setq common-str (buffer-substring from (point)))
              (multiple-value-bind (p1 p2 tag)
                  (find-text-attribute-point (point))
                (setq add-str (buffer-substring p1 p2))
                (setq to p2)
                (save-excursion
                  (set-buffer diff-buffer)
                  (multiple-value-bind (q1 q2)
                      (find-text-attribute tag)
                    (setq del-str (buffer-substring q1 q2)))))
              (funcall main-func common-str del-str add-str)
              (setq from to))
            ;; 最後
            (message "diff-detail convert: ~D done." processing-number-of-attribute)
            (setq common-str (buffer-substring from (point-max)))
            (funcall main-func common-str nil nil)))
          (when footer-func (funcall footer-func))
          (set-buffer-modified-p nil buffer)))
      (pop-to-buffer buffer)
      buffer)))

(defun diff-detail-html-encode-string (str &optional encode-half-space-p)
  (dolist (x *diff-detail-html-encode-alist*)
    (setq str (substitute-string str (car x) (cdr x))))
  (if encode-half-space-p
      (setq str (substitute-string str " " "&nbsp;")))
  str)

(defun diff-detail-convert-to-html ()
  "HTML に変換"
  (interactive)
  (let (buffer)
    (setq buffer
          (diff-detail-convert-to-x
           #'(lambda (common-str del-str add-str)
               (when (string= common-str "") (setq common-str nil))
               (when (string= del-str "") (setq del-str nil))
               (when (string= add-str "") (setq add-str nil))
               (when common-str
                 (format t "<span class=\"common\">~A</span>"
                         (diff-detail-html-encode-string common-str)))
               (cond
                ((and del-str add-str)
                 (format t "<span class=\"before-change\"><del>~A</del></span>"
                         (diff-detail-html-encode-string del-str))
                 (format t "<span class=\"after-change\"><ins>~A</ins></span>"
                         (diff-detail-html-encode-string add-str)))
                (del-str
                 (format t "<span class=\"del\"><del>~A</del></span>"
                         (diff-detail-html-encode-string del-str)))
                (add-str
                 (format t "<span class=\"add\"><ins>~A</ins></span>"
                         (diff-detail-html-encode-string add-str)))))
           #'(lambda () (format t "~A~%" *diff-detail-html-header*))
           #'(lambda () (format t "~%~A~%" *diff-detail-html-footer*))))
    (when buffer
      (save-excursion
        (set-buffer buffer)
        (funcall *diff-detail-convert-to-html-mode*)))))

(defun diff-detail-view-html ()
  "HTML に変換した結果を表示"
  (interactive)
  (let (buffer)
    (when diff-buffer
      (save-excursion
        (save-window-excursion
          (diff-detail-convert-to-html)
          (setq buffer (find-buffer *diff-detail-output-buffer-name*))
          (set-buffer buffer)
          (write-file *diff-detail-temp-html-file*)
          (delete-buffer buffer)
          (shell-execute *diff-detail-temp-html-file*))))))

;; Manued
(defun diff-detail-manued-encode-string (str in-cell-p)
  (if in-cell-p
      (dolist (x (list *diff-detail-manued-escape-str*
                       *diff-detail-manued-l-parenthesis-str*
                       *diff-detail-manued-r-parenthesis-str*
                       *diff-detail-manued-delete-str*
                       *diff-detail-manued-swap-str*
                       *diff-detail-manued-comment-str*))
        (setq str (substitute-string
                   str
                   (regexp-quote x)
                   (concat *diff-detail-manued-escape-str* x))))
    (setq str (substitute-string
               str
               (regexp-quote *diff-detail-manued-l-parenthesis-str*)
               (concat *diff-detail-manued-escape-str*
                       *diff-detail-manued-l-parenthesis-str*))))
  str)

(defun diff-detail-convert-to-manued ()
  "真鵺道(Manued)に変換"
  (interactive)
  (let (buffer first-str last-str)
    (setq buffer
          (diff-detail-convert-to-x
           #'(lambda (common-str del-str add-str)
               (when (string= common-str "") (setq common-str nil))
               (when (string= del-str "") (setq del-str nil))
               (when (string= add-str "") (setq add-str nil))
               (if (member *diff-detail-manued-order-str*
                           '("older-last" "newer-first") :test #'string=)
                   (setq first-str add-str last-str del-str)
                 (setq first-str del-str last-str add-str))
               (when common-str
                 (format t "~A" (diff-detail-manued-encode-string common-str nil)))
               (cond
                ((and first-str last-str)
                 (format t "~A~A~A~A~A"
                         *diff-detail-manued-l-parenthesis-str*
                         (diff-detail-manued-encode-string first-str t)
                         *diff-detail-manued-delete-str*
                         (diff-detail-manued-encode-string last-str t)
                         *diff-detail-manued-r-parenthesis-str*))
                (first-str
                 (format t "~A~A~A~A"
                         *diff-detail-manued-l-parenthesis-str*
                         (diff-detail-manued-encode-string first-str t)
                         *diff-detail-manued-delete-str*
                         *diff-detail-manued-r-parenthesis-str*))
                (last-str
                 (format t "~A~A~A~A"
                         *diff-detail-manued-l-parenthesis-str*
                         *diff-detail-manued-delete-str*
                         (diff-detail-manued-encode-string last-str t)
                         *diff-detail-manued-r-parenthesis-str*))))
           #'(lambda ()
               (unless (and (equal *diff-detail-manued-default-l-parenthesis-str*
                                   *diff-detail-manued-l-parenthesis-str*)
                            (equal *diff-detail-manued-default-r-parenthesis-str*
                                   *diff-detail-manued-r-parenthesis-str*)
                            (equal *diff-detail-manued-default-delete-str*
                                   *diff-detail-manued-delete-str*)
                            (equal *diff-detail-manued-default-swap-str*
                                   *diff-detail-manued-swap-str*)
                            (equal *diff-detail-manued-default-comment-str*
                                   *diff-detail-manued-comment-str*)
                            (equal *diff-detail-manued-default-escape-str*
                                   *diff-detail-manued-escape-str*)
                            (equal *diff-detail-manued-default-order-str*
                                   *diff-detail-manued-order-str*)
                            (equal *diff-detail-manued-default-order-str*
                                   *diff-detail-manued-order-str*))
                 (format t "defparentheses  ~A ~A~%" *diff-detail-manued-l-parenthesis-str*
                                                     *diff-detail-manued-r-parenthesis-str*)
                 (format t "defdelete       ~A~%" *diff-detail-manued-delete-str*)
                 (format t "defswap         ~A~%" *diff-detail-manued-swap-str*)
                 (format t "defcomment      ~A~%" *diff-detail-manued-comment-str*)
                 (format t "defescape       ~A~%" *diff-detail-manued-escape-str*)
                 (format t "deforder        ~A~%" *diff-detail-manued-order-str*)
                 (format t "defversion      ~A~%" *diff-detail-manued-version-str*)
                 (format t "~%")))))
    (when buffer
      (save-excursion
        (set-buffer buffer)
        (funcall *diff-detail-convert-to-manued-mode*)))))

;;; uninstall
(defun diff-detail-uninstall ()
  "diff-detail のアンインストール"
  (interactive)
  (let ((history-variables
         '(*diff-detail-token-regexp-history*)))
    (dolist (variable history-variables)
      (unregister-history-variable variable))))

;;; diff-detail.l ends here
