;;; -*- Mode: Lisp; Package: EDITOR -*-
;;; manued-mode.l --- Manued ファイル編集用マイナー/メジャーモード

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Version: 0.0.2.0
;; Time-stamp: <2005/10/08 14:25:03 +0900>

;;; Commentary:

;; Description:
;;
;;  Manued ファイル編集用マイナー/メジャーモード
;;
;;    □真鵺道 (Manued : Manuscript Editing language)
;;      http://www.mpi-sb.mpg.de/~hitoshi/otherprojects/manued/index-j.shtml
;;      http://www.mpi-sb.mpg.de/~hitoshi/otherprojects/manued/manued-j/manued-j.html
;;
;;    □提供する機能
;;    ・校正部分のハイライト化
;;    ・校正用文書の生成
;;    ・校正記号の入った文書から校正前の文書を抽出
;;    ・校正記号の入った文書から校正後の文書を抽出
;;    ・校正位置のサーチ機能
;;    ・校正記号入力補助
;;    ・校正部分編集補助
;;    ・真鵺道シンボルの再定義
;;

;; Installation:
;;
;;      1. アーカイブを展開して manued-mode.l を $XYZZY/site-lisp に
;;         コピーします。
;;
;;      2. バイトコンパイルします。
;;
;;              M-x byte-compile-file
;;              Byte compile file: $XYZZY/site-lisp/manued-mode.l
;;
;;      3. ~/.xyzzy または $XYZZY/site-lisp/siteinit.l に以下のコードを
;;         追加します。
;;
;;              (require "manued-mode")
;;
;;      4. 上記の設定を反映させるために、xyzzy を再起動します。
;;         siteinit.l に記述した場合は Ctrl キーと Shift キーを押しながら
;;         xyzzy を再起動し、ダンプファイルを再構築します。
;;

;; Uninstallation:
;;
;;      1. manued-mode.l に関する記述を削除します。
;;
;;      2. siteinit.l に記述していた場合は Ctrl キーと Shift キーを押し
;;         ながら xyzzy を再起動し、ダンプファイルを再構築します。
;;

;; Usage:
;;
;;      M-x manued-mode
;;      M-x manued-minor-mode
;;

;; Key bind:
;;      
;;      ■manued-minor-mode
;;
;;      M-n          次のコマンドへ移動
;;      M-p          前のコマンドへ移動
;;      M-N          同レベルの次のコマンドへ移動
;;      M-P          同レベルの前のコマンドへ移動
;;      M-]          対応するコマンド開閉文字列へ移動
;;      C-l          画面表示の更新
;;      C-c C-m e    書式エラー位置へ移動
;;      C-c C-m C-e  直前のコマンドを評価
;;
;;      C-c C-m C-d  リージョンを delete コマンドに変換
;;      C-c C-m C-s  リージョンを swap コマンドに変換
;;      C-c C-m C-c  リージョンを comment に変換
;;
;;      C-c C-m d    delete コマンドの編集
;;      C-c C-m s    swap コマンドの編集
;;      C-c C-m c    コメントの編集
;;      C-c C-m C-m  状況に応じたコマンド/コメントの編集
;;
;;      S-Apps       Manued メニュー (Selection 用)
;;      S-右クリック Manued メニュー (Selection 用)
;;
;;
;;      ■manued-mode
;;
;;      M-n          次のコマンドへ移動
;;      M-p          前のコマンドへ移動
;;      M-N          同レベルの次のコマンドへ移動
;;      M-P          同レベルの前のコマンドへ移動
;;      M-]          対応するコマンド開閉文字列へ移動
;;      C-l          画面表示の更新
;;      C-c C-m e    書式エラー位置へ移動
;;      C-c C-m C-e  直前のコマンドを評価
;;
;;      C-c C-m C-d  リージョンを delete コマンドに変換
;;      C-c C-m C-s  リージョンを swap コマンドに変換
;;      C-c C-m C-c  リージョンを comment に変換
;;
;;      C-\          undo (manued-mode ならば read-only でも undo)
;;      C-w          リージョンを delete コマンドに変換 (C-c C-m C-d と同一)
;;      C-d          セレクションまたは現在位置を delete コマンドに変換
;;      Delete       同上
;;      C-h          セレクションまたは直前位置を delete コマンドに変換
;;      C-k          現在位置から行末尾までを delete コマンドに変換
;;
;;      C-c C-m d    delete コマンドの編集
;;      d            同上
;;      C-c C-m s    swap コマンドの編集
;;      s            同上
;;      C-c C-m c    コメントの編集
;;      c            同上
;;      C-c C-m C-m  状況に応じたコマンド/コメントの編集
;;      C-m          同上
;;
;;      S-Apps       Manued メニュー (Selection 用)
;;      S-右クリック Manued メニュー (Selection 用)
;;

;; Setting example:
;;
;;      (require "manued-mode")
;;

;; Customize:
;;
;;      (define-key *manued-minor-mode-map* ... ...)
;;      (define-key *manued-mode-map* ... ...)
;;
;;      (setq *manued-l-parenthesis-attributes* ...)
;;      (setq *manued-r-parenthesis-attributes* ...)
;;      (setq *manued-delete-attributes* ...)
;;      (setq *manued-swap-attributes* ...)
;;      (setq *manued-comment-attributes* ...)
;;      (setq *manued-older-contents-attributes* ...)
;;      (setq *manued-newer-contents-attributes* ...)
;;      (setq *manued-swap-a-contents-attributes* ...)
;;      (setq *manued-swap-b-contents-attributes* ...)
;;      (setq *manued-swap-c-contents-attributes* ...)
;;      (setq *manued-comment-contents-attributes* ...)
;;
;;      (setq-default manued-l-parenthesis-str "[")
;;      (setq-default manued-r-parenthesis-str "]")
;;      (setq-default manued-delete-str "/")
;;      (setq-default manued-swap-str "|")
;;      (setq-default manued-comment-str ";")
;;      (setq-default manued-escape-str "~")
;;      (setq-default manued-order-str "older-first")
;;      (setq-default manued-version-str "0.0.0.0-manued-mode_for_xyzzy")
;;
;;      (setq-default manued-command-with-comment-p t)
;;      (setq-default manued-defcommand-head-regexp "%+")
;;
;;      (setq *manued-menu-name* "&Manued")
;;      (setq *manued-menu-position* 'ed::help)
;;

;; Changes:
;;
;;      [Version 0.0.2.0]
;;      Sat, 08 Oct 2005 14:23:48 +0900
;;        ・メールアドレスを変更。
;;        ・ライセンス条項(修正BSDライセンス)を記載。
;;
;;      [Version 0.0.1.1]
;;      Sun, 13 Feb 2005 22:25:39 +0900
;;        ・find-text-attribute を find-text-attribute-if に変更。
;;
;;      [Version 0.0.1.0]
;;      Thu, 10 Feb 2005 00:20:04 +0900
;;        ・set-text-attribute に依存するコードに全面変更。
;;      Tue, 08 Feb 2005 21:07:19 +0900
;;        ・作成
;;      Fri, 21 Jan 2005 18:04:30 +0900
;;        ・作成開始
;;

;; Specification:
;;
;;    ■manued-mode.l ver. 0.0.1.0 での修正記号定義コマンド (defcommand)
;;
;;      defparentheses  [ ]
;;      defdelete       /
;;      defswap         |
;;      defcomment      ;
;;      defescape       ~
;;      deforder        older-first
;;      defversion      0.0.1.0-manued-mode_for_xyzzy
;;
;;    ■manued-mode.l ver. 0.0.1.0 での Manued コマンド (manued-command)
;;
;;      Manued コマンドを default の記号を用いて説明する。
;;
;;      ・[A/B]
;;             Aを消去し、Bを挿入する。
;;
;;             [A/] : A を消す。(A を空文字で置き換える)
;;             [/A] : A を挿入する。(空文字を A で置き換える)
;;
;;      ・[A|B|C]
;;             AとCの位置を入れ換え、CBAの並びで出力する。
;;
;;             [A||C] AとCを入れ換える。
;;
;;      ・[; comment ]
;;             ; から ] まではコメントとなる。
;;
;;    ■manued-mode.l での修正記号定義コマンドの記述可能場所
;;
;;      buffer の先頭からのみ。
;;      narrowing している場合でも、buffer 先頭の修正記号定義コマンドのみを
;;      評価する。
;;

;; Memo
;;
;;  ■Manued フォーマット自体の制限
;;  
;;   ・command 外では、~ の直後に command を設定できない。
;;    ┏━━━┳━━━━━━━━━━━━━━━━━━┓
;;    ┃      ┃     デコード後文字列、コマンド     ┃
;;    ┃文字列┠────────┬─────────┨
;;    ┃      ┃   command 外   │    command 内    ┃
;;    ┣━━━╋━━━━━━━━┿━━━━━━━━━┫
;;    ┃   [  ┃ (l-parenthesis)│  (l-parenthesis) ┃
;;    ┠───╂────────┼─────────┨
;;    ┃  ~[  ┃       "["      │        "["       ┃
;;    ┠───╂────────┼─────────┨
;;    ┃ ~~[  ┃      "~["      │"~"(l-parenthesis)┃
;;    ┠───╂────────┼─────────┨
;;    ┃~~~[  ┃     "~~["      │       "~["       ┃
;;    ┗━━━┻━━━━━━━━┷━━━━━━━━━┛
;;
;;
;;  ■言葉の定義
;;
;;    以下では、Manued コマンドとして default の記号を用いて説明する。
;;
;;    ・command
;;        Manued コマンドのこと。[ から始まり ] で終わる。
;;
;;    ・command 内 (in-command)
;;        [ の後ろのポイントから、対応する ] の後ろのポイントまでの範囲。
;;        文脈にて対象 command を指定せずに「command 内」という言葉を使
;;        用した場合は、ネストしている command の一番外側の command を
;;        対象とする。
;;        command 開始文字列 [ 上のポイントは「command 内」ではない。
;;
;;    ・command 外 (out-command)
;;        「command 内」でない領域。
;;
;;    ・top-level
;;        Manued フォーマットでは command はネスト可能である。
;;        いずれの command にも含まれない領域を top-level とする。
;;        「command 外」の領域の総称として捉えることも可能。
;;
;;    ・current-level
;;        現在のポイントが含まれる最内の command の command 内領域の総称。
;;        現在のポイントが command 外であれば、top-level と等しい。
;;
;;    ・narrow-range
;;        command A の narrow-range と言った場合、それは command A の
;;        command 内領域と等しい。
;;        command A の開始文字列 [ は command A の narrow-range に含ま
;;        れない。
;;
;;    ・wide-range
;;        narrow-range の領域に、command 開始文字列 [ の存在する領域を
;;        加えたもの。
;;        command A の開始文字列 [ は command A の wide-range に含まれる。
;;
;;    ・コマンド文字列
;;        Manued での修正記号。
;;        実際に Manued コマンドを形成しているか否かには無関係。
;;
;;    ・エスケープ
;;        「コマンド文字列」をそのまま記載すると、Manued コマンドを形成
;;        する文字列として認識されてしまう場合に、通常の文字列として認識
;;        させるために行う処理。
;;        後述の「エスケープ文字列」を対象文字列の前に挿入することで行う。
;;
;;    ・エスケープ文字列 (escape-str)
;;        「エスケープ」するために用いられる文字列。
;;
;;    ・エスケープ構成文字列
;;        「エスケープ」を実際に行っている文字列。
;;
;;    ・コマンド構成文字列
;;        実際に Manued コマンドを形成する「コマンド文字列」。
;;        「コマンド文字列」が「コマンド構成文字列」であるか否かは、
;;        その出現場所の「command 内/外」、エスケープによる。
;;
;;
;;  ■Manued での command 内/外 でのエスケープについて
;;
;;    Manued フォーマットでは、command 外では l-parenthesis-str のみが
;;    「コマンド構成文字列」としての意味を持ち、エスケープ対象となる。
;;    ただし、command 外であっても、l-parenthesis-str の直前であれば、
;;    escape-str は「エスケープ構成文字列」であり、「エスケープ」として
;;    の意味を持つ。
;;    注意しなければならない点として command 外の場合、escape-str の前
;;    の escape-str には「エスケープ」の役割はない。単なる文字列である。
;;
;;    r-parenthesis-str, delete-str, swap-str, coment-str, 及び
;;    escape-str は上記例外を除き、command 内でのみ「コマンド構成文字列」
;;    「エスケープ構成文字列」である。
;;
;;  ■command 内/外 であることの判断が必要なシチュエーション
;;
;;    □r-parenthesis-str, delete-str, swap-str, comment-str が
;;      「コマンド構成文字列」か判定する場合。
;;
;;    □直前がエスケープか判定する場合。
;;
;;      ・直前に escape-str がない         ⇒ ×
;;      ▽現在位置に l-parenthesis-str がある場合
;;      │・直前の escape-str が 1 つ      ⇒ ○
;;      │▽command 内の場合
;;      ││・直前の escape-str が奇数個   ⇒ ○
;;      ││・直前の escape-str が偶数個   ⇒ ×
;;      │▽command 外の場合
;;      ││・==========================   ⇒ ○
;;      ▽現在位置に l-parenthesis-str がない場合
;;      │▽command 内の場合
;;      ││・直前の escape-str が奇数個   ⇒ ○
;;      ││・直前の escape-str が偶数個   ⇒ ×
;;      │▽command 外の場合
;;      ││・==========================   ⇒ ×
;;      ----------------------------------------
;;        ↓ command 内/外 判定を後に
;;      ----------------------------------------
;;      ・直前に escape-str がない         ⇒ ×
;;      ▽現在位置に l-parenthesis-str がある場合
;;      │・直前の escape-str が奇数個     ⇒ ○
;;      │▽直前の escape-str が偶数個の場合
;;      ││・command 内                   ⇒ ×
;;      ││・command 外                   ⇒ ○
;;      ▽現在位置に l-parenthesis-str がない場合
;;      │・直前の escape-str が偶数個     ⇒ ×
;;      │▽直前の escape-str が奇数個の場合
;;      ││・command 内                   ⇒ ○
;;      ││・command 外                   ⇒ ×
;;

;; Licence:
;;
;;    manued-mode は修正BSDライセンスに基づいて利用可能です。
;;    <http://www.opensource.org/licenses/bsd-license.php>
;;
;;
;;    Copyright (C) 2001-2005, OHKUBO Hiroshi.  All rights reserved.
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

(provide "manued-mode")

(in-package "editor")

(export '(*manued-version*
          *manued-minor-mode-map*
          *manued-mode-map*
          *manued-mode-hook*
          *manued-l-parenthesis-attributes*
          *manued-r-parenthesis-attributes*
          *manued-delete-attributes*
          *manued-swap-attributes*
          *manued-comment-attributes*
          *manued-older-contents-attributes*
          *manued-newer-contents-attributes*
          *manued-swap-a-contents-attributes*
          *manued-swap-b-contents-attributes*
          *manued-swap-c-contents-attributes*
          *manued-comment-contents-attributes*
          manued-l-parenthesis-str
          manued-r-parenthesis-str
          manued-delete-str
          manued-swap-str
          manued-comment-str
          manued-escape-str
          manued-order-str
          manued-version-str
          manued-command-with-comment-p
          manued-defcommand-head-regexp
          manued-insert-header
          manued-goto-last-parse-command-error-point
          manued-forward-l-parenthesis
          manued-backward-l-parenthesis
          manued-forward-l-parenthesis-current-level
          manued-backward-l-parenthesis-current-level
          manued-goto-matched-parenthesis
          manued-eval-last-command
          manued-eval-command-region
          manued-eval-command-region-old
          manued-eval-command-selection
          manued-eval-command-selection-old
          manued-undo
          manued-toggle-command-with-comment
          manued-delete-command-region
          manued-delete-command-selection
          manued-delete-command-line
          manued-delete-command-char
          manued-delete-command-backward-char
          manued-delete-command-char-or-selection
          manued-delete-command-backward-char-or-selection
          manued-swap-command-region
          manued-swap-command-selection
          manued-comment-region
          manued-comment-selection
          manued-edit-delete-newer-contents
          manued-change-swap-boundary
          manued-edit-comment-contents
          manued-edit-command
          manued-convert-to-manued-document
          manued-extract-normal-old-document
          manued-extract-normal-new-document
          manued-recenter
          manued-mouse-menu-popup
          manued-apps-popup
          manued-minor-mode
          manued-mode))

(defconstant *manued-version* "0.0.2.0"
  "manued-mode のバージョン")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; manued-minor-mode 用
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar-local manued-minor-mode nil)

(defvar *manued-minor-mode-map* nil
  "manued-minor-mode のキーマップ")
(unless *manued-minor-mode-map*
  (setq *manued-minor-mode-map* (make-sparse-keymap))
  (define-key *manued-minor-mode-map* #\M-n 'manued-forward-l-parenthesis)
  (define-key *manued-minor-mode-map* #\M-p 'manued-backward-l-parenthesis)
  (define-key *manued-minor-mode-map* #\M-N 'manued-forward-l-parenthesis-current-level)
  (define-key *manued-minor-mode-map* #\M-P 'manued-backward-l-parenthesis-current-level)
  (define-key *manued-minor-mode-map* #\M-] 'manued-goto-matched-parenthesis)
  (define-key *manued-minor-mode-map* #\C-l 'manued-recenter)
  (define-key *manued-minor-mode-map* '(#\C-c #\C-m #\e) 'manued-goto-last-parse-command-error-point)
  (define-key *manued-minor-mode-map* '(#\C-c #\C-m #\C-e) 'manued-eval-last-command)
  ;;
  (define-key *manued-minor-mode-map* '(#\C-c #\C-m #\C-d) 'manued-delete-command-region)
  (define-key *manued-minor-mode-map* '(#\C-c #\C-m #\C-s) 'manued-swap-command-region)
  (define-key *manued-minor-mode-map* '(#\C-c #\C-m #\C-c) 'manued-comment-region)
  ;;
  (define-key *manued-minor-mode-map* '(#\C-c #\C-m #\d) 'manued-edit-delete-newer-contents)
  (define-key *manued-minor-mode-map* '(#\C-c #\C-m #\s) 'manued-change-swap-boundary)
  (define-key *manued-minor-mode-map* '(#\C-c #\C-m #\c) 'manued-edit-comment-contents)
  (define-key *manued-minor-mode-map* '(#\C-c #\C-m #\C-m) 'manued-edit-command)
  ;;
  (define-key *manued-minor-mode-map* #\S-RBtnDown 'mouse-nop)
  (define-key *manued-minor-mode-map* #\S-RBtnUp 'manued-mouse-menu-popup)
  (define-key *manued-minor-mode-map* #\S-Apps 'manued-apps-popup))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; manued-mode 用
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar *manued-mode-hook* nil
  "manued-mode のフック変数")
(defvar *manued-keyword-hash-table* nil
  "manued-mode のキーワードハッシュテーブル")
(defvar *manued-keyword-file* "MANUED"
  "manued-mode のキーワードファイル名")

(defvar *manued-mode-map* nil
  "manued-mode のキーマップ")
(unless *manued-mode-map*
  (setq *manued-mode-map* (make-sparse-keymap))
  (define-key *manued-mode-map* #\M-n 'manued-forward-l-parenthesis)
  (define-key *manued-mode-map* #\M-p 'manued-backward-l-parenthesis)
  (define-key *manued-mode-map* #\M-N 'manued-forward-l-parenthesis-current-level)
  (define-key *manued-mode-map* #\M-P 'manued-backward-l-parenthesis-current-level)
  (define-key *manued-mode-map* #\M-] 'manued-goto-matched-parenthesis)
  (define-key *manued-mode-map* #\C-l 'manued-recenter)
  (define-key *manued-mode-map* '(#\C-c #\C-m #\e) 'manued-goto-last-parse-command-error-point)
  (define-key *manued-mode-map* '(#\C-c #\C-m #\C-e) 'manued-eval-last-command)
  ;;
  (define-key *manued-mode-map* '(#\C-c #\C-m #\C-d) 'manued-delete-command-region)
  (define-key *manued-mode-map* '(#\C-c #\C-m #\C-s) 'manued-swap-command-region)
  (define-key *manued-mode-map* '(#\C-c #\C-m #\C-c) 'manued-comment-region)
  ;;
  (define-key *manued-mode-map* #\C-\\ 'manued-undo)
  (define-key *manued-mode-map* #\C-w 'manued-delete-command-region)
  (define-key *manued-mode-map* #\C-d 'manued-delete-command-char-or-selection)
  (define-key *manued-mode-map* #\Delete 'manued-delete-command-char-or-selection)
  (define-key *manued-mode-map* #\C-h 'manued-delete-command-backward-char-or-selection)
  (define-key *manued-mode-map* #\C-k 'manued-delete-command-line)
  ;;
  (define-key *manued-mode-map* '(#\C-c #\C-m #\d) 'manued-edit-delete-newer-contents)
  (define-key *manued-mode-map* '(#\C-c #\C-m #\s) 'manued-change-swap-boundary)
  (define-key *manued-mode-map* '(#\C-c #\C-m #\c) 'manued-edit-comment-contents)
  (define-key *manued-mode-map* '(#\C-c #\C-m #\C-m) 'manued-edit-command)
  (define-key *manued-mode-map* #\d 'manued-edit-delete-newer-contents)
  (define-key *manued-mode-map* #\s 'manued-change-swap-boundary)
  (define-key *manued-mode-map* #\c 'manued-edit-comment-contents)
  (define-key *manued-mode-map* #\C-m 'manued-edit-command)
  ;;
  (define-key *manued-mode-map* #\S-RBtnDown 'mouse-nop)
  (define-key *manued-mode-map* #\S-RBtnUp 'manued-mouse-menu-popup)
  (define-key *manued-mode-map* #\S-Apps 'manued-apps-popup))

(defvar *manued-mode-abbrev-table* nil
  "manued-mode の abbrev-table")
(unless *manued-mode-abbrev-table*
  (define-abbrev-table '*manued-mode-abbrev-table*))

(defvar *manued-mode-syntax-table* nil
  "manued-mode のシンタックステーブル")
(unless *manued-mode-syntax-table*
  (setq *manued-mode-syntax-table* (make-syntax-table))
  (set-syntax-symbol *manued-mode-syntax-table* #\&)
  (set-syntax-symbol *manued-mode-syntax-table* #\*)
  (set-syntax-symbol *manued-mode-syntax-table* #\+)
  (set-syntax-symbol *manued-mode-syntax-table* #\-)
  (set-syntax-symbol *manued-mode-syntax-table* #\/)
  (set-syntax-symbol *manued-mode-syntax-table* #\<)
  (set-syntax-symbol *manued-mode-syntax-table* #\=)
  (set-syntax-symbol *manued-mode-syntax-table* #\>)
  (set-syntax-symbol *manued-mode-syntax-table* #\_)
  (set-syntax-symbol *manued-mode-syntax-table* #\|))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 表示属性用
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar *manued-l-parenthesis-attributes* '(:foreground 1 :bold t)
  "l-parenthesis 表示属性")
(defvar *manued-r-parenthesis-attributes* '(:foreground 1 :bold t)
  "r-parenthesis 表示属性")
(defvar *manued-delete-attributes* '(:foreground 1 :bold t)
  "delete 表示属性")
(defvar *manued-swap-attributes* '(:foreground 1 :bold t)
  "swap 表示属性")
(defvar *manued-comment-attributes* '(:foreground 1 :bold t)
  "comment 表示属性")
(defvar *manued-older-contents-attributes* '(:foreground 15 :strike-out t)
  "older-contents 表示属性")
(defvar *manued-newer-contents-attributes* '(:background 3 :bold t)
  "newer-contents 表示属性")
(defvar *manued-swap-a-contents-attributes* '(:foreground 4 :background 3 :bold t)
  "swap-a-contents 表示属性")
(defvar *manued-swap-b-contents-attributes* '(:background 3)
  "swap-b-contents 表示属性")
(defvar *manued-swap-c-contents-attributes* '(:foreground 5 :background 3 :bold t)
  "swap-c-contents 表示属性")
(defvar *manued-comment-contents-attributes* '(:foreground 7 :background 15)
  "comment-contents 表示属性")

(defvar *manued-tag* 'manued
  "表示属性設定時タグ")
(defvar *manued-eval-command-tag* 'manued-eval-command
  "評価後文字列の表示属性設定時タグ")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 動作設定値
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defconstant *manued-default-l-parenthesis-str* "["
  "l-parenthesis-str のデフォルト値")
(defconstant *manued-default-r-parenthesis-str* "]"
  "r-parenthesis-str のデフォルト値")
(defconstant *manued-default-delete-str* "/"
  "delete-str のデフォルト値")
(defconstant *manued-default-swap-str* "|"
  "swap-str のデフォルト値")
(defconstant *manued-default-comment-str* ";"
  "comment-str のデフォルト値")
(defconstant *manued-default-escape-str* "~"
  "escape-str のデフォルト値")
(defconstant *manued-default-order-str* "older-first"
  "order-str のデフォルト値")
(defconstant *manued-default-version-str*
  (format nil "~A-manued-mode_for_xyzzy" *manued-version*)
  "version-str のデフォルト値")

(defvar-local manued-l-parenthesis-str *manued-default-l-parenthesis-str*
  "現在のバッファの l-parenthesis-str の値")
(defvar-local manued-r-parenthesis-str *manued-default-r-parenthesis-str*
  "現在のバッファの r-parenthesis-str の値")
(defvar-local manued-delete-str *manued-default-delete-str*
  "現在のバッファの delete-str の値")
(defvar-local manued-swap-str *manued-default-swap-str*
  "現在のバッファの swap-str の値")
(defvar-local manued-comment-str *manued-default-comment-str*
  "現在のバッファの comment-str の値")
(defvar-local manued-escape-str *manued-default-escape-str*
  "現在のバッファの escape-str の値")
(defvar-local manued-order-str *manued-default-order-str*
  "現在のバッファの order-str の値")
(defvar-local manued-version-str *manued-default-version-str*
  "現在のバッファの version-str の値")

(defconstant *manued-order-str-list*
  '("older-first" "older-last" "newer-first" "newer-last")
  "order-str に設定可能な文字列")

(defvar-local manued-command-with-comment-p t
  "コマンド追加時に comment-str を末尾にいれるか")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; マクロ
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmacro with-manued-mode-edit (&body body)
  `(when (or (not buffer-read-only)
             (eq buffer-mode 'manued-mode))
     (let ((buffer-read-only nil))
       (declare (special buffer-read-only))
       ,@body)))
(setf (get 'with-manued-mode-edit 'ed:lisp-indent-hook) 0)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; defcommand 関連
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; manued-point-min
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar-local manued-point-min-maker nil
  "manued-point-min 用マーカー")

(defun manued-set-point-min-marker (&optional point)
  (unless (markerp manued-point-min-maker)
    (setq manued-point-min-maker (make-marker)))
  (set-marker manued-point-min-maker (or point (point))))

(defun manued-get-point-min-marker ()
  (and (markerp manued-point-min-maker)
       (marker-point manued-point-min-maker)))

(defun manued-point-min ()
  "defcommand を考慮した point-min を取得"
  (or (manued-get-point-min-marker)
      (progn
        (manued-eval-defcommand)
        (manued-get-point-min-marker))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; defcommand
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar-local manued-defcommand-head-regexp "%+"
  "defcommand の前に存在してもよい(存在しなくてもよい)正規表現文字列。
また、後方参照可能なグルーピングが使用されていてはいけない。
\(バッファローカル\)。")

(defvar *manued-defcommand-alist*
  '(("defparentheses" manued-l-parenthesis-str manued-r-parenthesis-str)
    ("defdelete"      manued-delete-str)
    ("defswap"        manued-swap-str)
    ("defcomment"     manued-comment-str)
    ("defescape"      manued-escape-str)
    ("deforder"       manued-order-str)
    ("defversion"     manued-version-str))
  "defcommand 文字列と対応する変数の設定")

(defun manued-get-defcommand ()
  "現在行の defcommand (と対応する文字列)を返す"
  (save-excursion
    (goto-bol)
    (looking-at (concat "\\(?:" manued-defcommand-head-regexp "\\)?"
                        "\\("
                        (substring (format nil "~{\\|~A~}"
                                           (mapcar #'(lambda (x) (regexp-quote (car x)))
                                                   *manued-defcommand-alist*))
                                   2)
                        "\\)[ \t]+\\(.*\\)"))
    (values (match-string 1) (match-string 2))))

(defun manued-defcommand-exist-p ()
  "バッファ先頭に defcommand が存在するか"
  (save-excursion
    (save-restriction
      (widen)
      (goto-char (point-min))
      (and (manued-get-defcommand) t))))

(defun manued-eval-defcommand ()
  "バッファ先頭の defcommand を評価し、バッファローカル変数に設定。
manued-point-min も更新"
  (interactive)
  (let (defcommand value split-values symbols)
    (if (manued-defcommand-exist-p)
        (save-excursion
          (save-restriction
            (widen)
            (goto-char (point-min))
            (while (multiple-value-setq (defcommand value) (manued-get-defcommand))
              (setq split-values (split-string value " \t"))
              (when (setq symbols (cdr (find defcommand *manued-defcommand-alist*
                                             :key #'car :test #'string=)))
                (dolist (symbol symbols)
                  (set symbol (pop split-values))))
              (unless (forward-line)
                (return)))
            (manued-set-point-min-marker)))
      (manued-set-point-min-marker 0))))

(defun manued-order-older-first-p ()
  "delete コマンドで older が先か"
  (not (member manued-order-str '("older-last" "newer-first")
               :test #'string=)))

(defun manued-insert-header ()
  "defcommand ヘッダを挿入"
  (interactive)
  (with-manued-mode-edit
    (dolist (defcommand *manued-defcommand-alist*)
      (insert (format nil "~14@A" (car defcommand)))
      (dolist (val-symbol (cdr defcommand))
        (insert (format nil " ~A" (symbol-value val-symbol))))
      (insert "\n"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; special-str 関連
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun manued-get-special-str-regexp (&optional special-str-list)
  "manued の特別な文字列を判定するための正規表現を返す"
  (unless special-str-list
    (setq special-str-list
          (list manued-l-parenthesis-str manued-r-parenthesis-str
                manued-delete-str manued-swap-str
                manued-comment-str manued-escape-str)))
  (concat "\\("
          (substring (format nil "~{\\|~A~}"
                             (mapcar #'regexp-quote special-str-list))
                     2)
          "\\)"))

(defun manued-special-str-point-p (&optional point)
  "point 位置から manued の特別な文字列が開始しているか。
この関数ではエスケープは考慮しない。"
  (let ((special-str-regexp (manued-get-special-str-regexp)))
    (save-excursion
      (when point (goto-char point))
      (looking-at special-str-regexp))))

(defun manued-goto-special-str-in-command (&optional no-dup)
  "special-str まで移動
注意：command 内限定で使用可能な関数。"
  (let ((special-str-regexp (manued-get-special-str-regexp))
        from match-str)
    (save-excursion
      (when no-dup (forward-char))
      (while (scan-buffer special-str-regexp :regexp t :no-dup nil)
        (setq match-str (match-string 0))
        (unless (manued-escape-p-strict t (string= match-str manued-l-parenthesis-str))
          (setq from (point))
          (return))
        (forward-char)))
    (when from
      (goto-char from)
      match-str)))

(defun manued-forward-special-str-in-command ()
  "次の special-str まで移動
注意：command 内限定で使用可能な関数。"
  (manued-goto-special-str-in-command t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 移動用関数 (command 内/外が静的に定まる場合に使用する関数群)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; escape 判定
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun manued-escape-p-strict (in-command-p l-parenthesis-p)
  "直前がエスケープか。
現在の使用の仕方では実害はないが、コメント内判定を考慮していない。
現在位置が r-parenthesis 以外でもエスケープと判定する。"
  (when (and (not in-command-p) (not l-parenthesis-p))
    (return-from manued-escape-p-strict nil))
  (let ((escape-count 0))
    (save-excursion
      (while (looking-back manued-escape-str)
        (incf escape-count)
        (backward-char (length manued-escape-str))))
    (if (zerop escape-count)
        nil
      (if l-parenthesis-p
          (cond ((oddp escape-count)   t)
                (in-command-p        nil)
                (t                     t))
        (cond ((evenp escape-count) nil)
              (in-command-p           t)
              (t                    nil))))))

(defun manued-escape-p-in-command (l-parenthesis-p)
  (manued-escape-p-strict t l-parenthesis-p))
(defun manued-escape-p-out-command (l-parenthesis-p)
  (manued-escape-p-strict nil l-parenthesis-p))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; command 構成文字列判定
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun manued-x-p-strict (in-command-p str)
  "現在位置から str が開始していて、かつ、エスケープされていないか。
コメント内外の判定には未対応。"
  (let ((l-parenthesis-p (string= str manued-l-parenthesis-str)))
    (and (looking-for str)
         (<= (manued-point-min) (point))
         (not (manued-escape-p-strict in-command-p l-parenthesis-p))
         (or l-parenthesis-p in-command-p)
;        (or r-parenthesis-p (not in-comment-p)) ; コメント対応するとしたらこんな感じ
         )))
(defun manued-x-p-in-command (str)
  (manued-x-p-strict t str))
(defun manued-x-p-out-command (str)
  (manued-x-p-strict nil str))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 次の command 構成文字列への移動
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun manued-forward-x-simple-strict (in-command-p str)
  "次に x が出現するとしたら command 内/外のどちらであるかを
in-command-p で保証した上で、次の x に移動"
  (let (from to)
    (save-excursion
      (while (scan-buffer str :regexp nil :no-dup t)
        (setq from (match-beginning 0) to (match-end 0))
        (if (manued-x-p-strict in-command-p str)
            (return)
          (setq from nil to nil))))
    (when from
      (goto-char from)
      (values from to))))
(defun manued-forward-x-simple-in-command (str)
  (manued-forward-x-simple-strict t str))
(defun manued-forward-x-simple-out-command (str)
  (manued-forward-x-simple-strict nil str))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 現在または次の command 構成文字列への移動
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun manued-goto-x-strict (in-command-p str)
  "移動先の command 内/外を保証した上で x に移動"
  (if (manued-x-p-strict in-command-p str)
      (values (point) (+ (point) (length str)))
    (manued-forward-x-simple-strict in-command-p str)))
(defun manued-goto-x-in-command (str)
  (manued-goto-x-strict t str))
(defun manued-goto-x-out-command (str)
  (manued-goto-x-strict nil str))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (l-parenthesis)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun manued-l-parenthesis-p-strict (in-command-p)
  (manued-x-p-strict in-command-p manued-l-parenthesis-str))
(defun manued-l-parenthesis-p-in-command ()
  (manued-l-parenthesis-p-strict t))
(defun manued-l-parenthesis-p-out-command ()
  (manued-l-parenthesis-p-strict nil))

(defun manued-forward-l-parenthesis-simple-strict (in-command-p)
  (manued-forward-x-simple-strict in-command-p manued-l-parenthesis-str))
(defun manued-forward-l-parenthesis-simple-in-command ()
  (manued-forward-l-parenthesis-simple-strict t))
(defun manued-forward-l-parenthesis-simple-out-command ()
  (manued-forward-l-parenthesis-simple-strict nil))

(defun manued-goto-l-parenthesis-strict (in-command-p)
  (manued-goto-x-strict in-command-p manued-l-parenthesis-str))
(defun manued-goto-l-parenthesis-in-command ()
  (manued-goto-l-parenthesis-strict t))
(defun manued-goto-l-parenthesis-out-command ()
  (manued-goto-l-parenthesis-strict nil))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (r-parenthesis)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun manued-r-parenthesis-p-in-command ()
  (manued-x-p-in-command manued-r-parenthesis-str))
(defun manued-forward-r-parenthesis-simple-in-command ()
  (manued-forward-x-simple-in-command manued-r-parenthesis-str))
(defun manued-goto-r-parenthesis-in-command ()
  (manued-goto-x-in-command manued-r-parenthesis-str))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (comment)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun manued-comment-p-in-command ()
  (manued-x-p-in-command manued-comment-str))
(defun manued-forward-comment-simple-in-command ()
  (manued-forward-x-simple-in-command manued-comment-str))
(defun manued-goto-comment-in-command ()
  (manued-goto-x-in-command manued-comment-str))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (l-parenthesis -> r-parenthesis)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun manued-goto-matched-r-parenthesis-strict (in-command-p)
  "対応する r-parenthesis に移動
コメント対応済み"
  (let ((nest-level 1) point l-from l-to r-from r-to c-from)
    (save-excursion
      (unless (manued-l-parenthesis-p-strict in-command-p)
        (return-from manued-goto-matched-r-parenthesis-strict nil))
      (forward-char (length manued-l-parenthesis-str))
      (setq point (point))
      (setq c-from (manued-goto-comment-in-command))
      (goto-char point)
      (loop
        ;; r-parenthesis
        (setq point (point))
        (setq r-from (manued-goto-r-parenthesis-in-command))
        (unless r-from
          (return-from manued-goto-matched-r-parenthesis-strict nil))
        (setq r-to (+ r-from (length manued-r-parenthesis-str)))
        ;; l-parenthesis
        (goto-char point)
        (setq l-from (manued-goto-l-parenthesis-in-command))
        (when l-from
          (setq l-to (+ l-from (length manued-l-parenthesis-str))))
        (cond
         ;; l-from がなければ r-to へ
         ((null l-from)
          (decf nest-level)
          (goto-char r-to))
         ;; r-from の方が直後にあれば r-to へ
         ((< r-from l-from)
          (decf nest-level)
          (goto-char r-to))
         ;; l-from の方が直後にあるが、コメントの中ならば r-to へ
         ((when c-from
            (goto-char point)
            (setq c-from (manued-goto-comment-in-command))
            (and c-from (< c-from l-from)))
          (decf nest-level)
          (goto-char r-to))
         ;; l-from の方が直後にあって、l-from がコメントの中でもなければ l-to へ
         (t
          (incf nest-level)
          (goto-char l-to)))
        ;;
        (when (= nest-level 0)
          (return))))
    (goto-char r-from)
    (values r-from r-to)))
(defun manued-goto-matched-r-parenthesis-in-command ()
  (manued-goto-matched-r-parenthesis-strict t))
(defun manued-goto-matched-r-parenthesis-out-command ()
  (manued-goto-matched-r-parenthesis-strict nil))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; command-info 関連
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; 
;; TAG           ::= (*manued-tag* <IDENTITY> <TYPE> <TYPE_LIST>)
;; IDENTITY      ::= (<COMMAND_LEVEL>)
;; COMMAND_LEVEL ::= <integer>
;; TYPE          ::= 'l-parenthesis || 'r-parenthesis || 'comment || 'delete || 'swap
;;                || 'comment-contents || 'older-contents || 'newer-contents
;;                || 'swap-a-contents || 'swap-b-contents || 'swap-c-contents
;; TYPE_LIST     ::= (<TYPE>*)
;;
;; 同一コマンド構成要素か否かの判定は <IDENTITY> に対する eq で行う。

(defun manued-command-info-get-l-parenthesis-range (command-info)
  (nth 0 command-info))
(defun manued-command-info-get-r-parenthesis-range (command-info)
  (nth 1 command-info))
(defun manued-command-info-get-comment-range (command-info)
  (nth 2 command-info))
(defun manued-command-info-get-delete-range (command-info)
  (nth 3 command-info))
(defun manued-command-info-get-swap-a-range (command-info)
  (nth 4 command-info))
(defun manued-command-info-get-swap-b-range (command-info)
  (nth 5 command-info))
(defun manued-command-info-get-comment-contents-range (command-info)
  (nth 6 command-info))
(defun manued-command-info-get-older-contents-range (command-info)
  (nth 7 command-info))
(defun manued-command-info-get-newer-contents-range (command-info)
  (nth 8 command-info))
(defun manued-command-info-get-swap-a-contents-range (command-info)
  (nth 9 command-info))
(defun manued-command-info-get-swap-b-contents-range (command-info)
  (nth 10 command-info))
(defun manued-command-info-get-swap-c-contents-range (command-info)
  (nth 11 command-info))

(defun manued-command-info-get-wide-range (command-info)
  (cons (car (manued-command-info-get-l-parenthesis-range command-info))
        (cdr (manued-command-info-get-r-parenthesis-range command-info))))
(defun manued-command-info-get-narrow-range (command-info)
  (cons (cdr (manued-command-info-get-l-parenthesis-range command-info))
        (cdr (manued-command-info-get-r-parenthesis-range command-info))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; level / identity 関連
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun manued-get-field-level ()
  "現在の位置の field-level を返す。
<manued>document</manued>
        ^^^^^^^^^^^^^^^^^
上記範囲で 1 増えている。"
  (let ((point (point)))
    (save-excursion
      (save-restriction
        (widen)
        (multiple-value-bind (from to tag)
            (find-text-attribute-if #'(lambda (tag)
                                        (and (listp tag)
                                             (eq (car tag) *manued-tag*)
                                             (or (eq (nth 2 tag) 'l-parenthesis)
                                                 (eq (nth 2 tag) 'r-parenthesis))))
                                    :end point :from-end t)
          (cond
           ((null tag)
            0)
           ((eq (nth 2 tag) 'r-parenthesis)
            (if (<= to point)
                (1- (caadr tag))
              (caadr tag)))
           (t
            (if (< point to)
                (1- (caadr tag))
              (caadr tag)))))))))

(defun manued-get-current-command-level ()
  "現在の位置の command-level を返す。
<manued>document</manued>
^^^^^^^^^^^^^^^^^^^^^^^^^
上記範囲で 1 増えている。"
  (let ((point (point)))
    (save-excursion
      (save-restriction
        (widen)
        (multiple-value-bind (from to tag)
            (find-text-attribute-if #'(lambda (tag)
                                        (and (listp tag)
                                             (eq (car tag) *manued-tag*)
                                             (or (eq (nth 2 tag) 'l-parenthesis)
                                                 (eq (nth 2 tag) 'r-parenthesis))))
                                    :end (1+ point) :from-end t)
          (cond
           ((null tag)
            0)
           ((eq (nth 2 tag) 'r-parenthesis)
            (if (<= to point)
                (1- (caadr tag))
              (caadr tag)))
           (t
            (caadr tag))))))))

(defun manued-get-current-command-identity ()
  "コマンドの identity を取得する。"
  (save-excursion
    (let ((command-level (manued-get-current-command-level)))
      (when (plusp command-level)
        (manued-goto-x 'r-parenthesis command-level)
        (multiple-value-bind (from to tag)
            (find-text-attribute-point (point))
          (nth 1 tag))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; parse-command 関連
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar-local manued-last-parse-command-error-point nil
  "最後のコマンド解析でのエラー位置")
(defvar-local manued-last-parse-command-error-message nil
  "最後のコマンド解析でのエラーメッセージ")

(defun manued-goto-last-parse-command-error-point ()
  "コマンド解析でのエラー位置に移動"
  (interactive)
  (when manued-last-parse-command-error-point
    (goto-char manued-last-parse-command-error-point)
    (message "~A" manued-last-parse-command-error-message)))

(defun manued-parse-command-from-point-strict (field-level &optional attributes)
  "現在位置から開始するコマンドを構文解析して、テキスト属性を設定し、
解析結果情報 command-info を返す。"
  (let (tag identity command-level type type-list
        (in-command-p (not (zerop field-level)))
        special-str command-type (delete-count 0) (swap-count 0)
        l-parenthesis-from l-parenthesis-to r-parenthesis-from r-parenthesis-to
        delete-from delete-to comment-from comment-to
        swap-a-from swap-a-to swap-b-from swap-b-to
        first-contents-from first-contents-to
        last-contents-from last-contents-to
        older-contents-from older-contents-to
        newer-contents-from newer-contents-to
        swap-a-contents-from swap-a-contents-to
        swap-b-contents-from swap-b-contents-to
        swap-c-contents-from swap-c-contents-to
        comment-contents-from comment-contents-to)
    (unless (manued-l-parenthesis-p-strict in-command-p)
      (return-from manued-parse-command-from-point-strict nil))
    (setq manued-last-parse-command-error-point nil
          manued-last-parse-command-error-message nil)
    (setq command-level (1+ field-level))
    (setq identity (list command-level))
    (save-excursion
      (save-restriction
        ;; 開始位置取得
        (setq l-parenthesis-from (point)
              l-parenthesis-to (+ (point) (length manued-l-parenthesis-str)))
        (push 'l-parenthesis type-list)
        ;; 終了位置取得
        (unless (manued-goto-matched-r-parenthesis-strict in-command-p)
          (setq manued-last-parse-command-error-point (point))
          (setq manued-last-parse-command-error-message
                (format nil "point ~S: 対応する r-parenthesis の存在しない l-parenthesis です。" (point)))
          (plain-error "~A" manued-last-parse-command-error-message))
        (setq r-parenthesis-from (point)
              r-parenthesis-to (+ (point) (length manued-r-parenthesis-str)))
        (narrow-to-region l-parenthesis-to r-parenthesis-from)
        (goto-char (point-min))
        (while (setq special-str (manued-goto-special-str-in-command))
          (cond
           ;; [
           ((string= special-str manued-l-parenthesis-str)
            (unless (manued-goto-matched-r-parenthesis-in-command)
              (setq manued-last-parse-command-error-point (point))
              (setq manued-last-parse-command-error-message
                    (format nil "point ~S: 対応する r-parenthesis の存在しない l-parenthesis です。" (point)))
              (plain-error "~A" manued-last-parse-command-error-message))
            (forward-char (length manued-r-parenthesis-str)))
           ;; ]
           ((string= special-str manued-r-parenthesis-str)
            (setq manued-last-parse-command-error-point (point))
            (setq manued-last-parse-command-error-message
                  (format nil "point ~S: 対応する l-parenthesis の存在しない r-parenthesis です。" (point)))
            (plain-error "~A" manued-last-parse-command-error-message))
           ;; /
           ((string= special-str manued-delete-str)
            (push 'delete type-list)
            (incf delete-count)
            (unless (member command-type '(nil delete))
              (setq manued-last-parse-command-error-point (point))
              (setq manued-last-parse-command-error-message
                    (format nil "point ~S: 別のコマンド(~A)内で delete コマンドが出現しました。"
                            (point) (symbol-name command-type)))
              (plain-error "~A" manued-last-parse-command-error-message))
            (unless (< delete-count 2)
              (setq manued-last-parse-command-error-point (point))
              (setq manued-last-parse-command-error-message
                    (format nil "point ~S: delete コマンドが 2 度出現しました。" (point)))
              (plain-error "~A" manued-last-parse-command-error-message))
            (setq command-type 'delete)
            (setq delete-from (point)
                  delete-to (+ (point) (length manued-delete-str))
                  first-contents-from (point-min)
                  first-contents-to (point)
                  last-contents-from delete-to)
            (goto-char delete-to))
           ;; |
           ((string= special-str manued-swap-str)
            (push 'swap type-list)
            (incf swap-count)
            (unless (member command-type '(nil swap))
              (setq manued-last-parse-command-error-point (point))
              (setq manued-last-parse-command-error-message
                    (format nil "point ~S: 別のコマンド(~A)内で swap コマンドが出現しました。"
                            (point) (symbol-name command-type)))
              (plain-error "~A" manued-last-parse-command-error-message))
            (unless (< swap-count 3)
              (setq manued-last-parse-command-error-point (point))
              (setq manued-last-parse-command-error-message
                    (format nil "point ~S: swap コマンドが 3 度出現しました。" (point)))
              (plain-error "~A" manued-last-parse-command-error-message))
            (setq command-type 'swap)
            (if (= swap-count 1)
                (progn
                  (setq swap-a-from (point)
                        swap-a-to (+ (point) (length manued-swap-str))
                        swap-a-contents-from (point-min)
                        swap-a-contents-to swap-a-from
                        swap-b-contents-from swap-a-to)
                  (goto-char swap-a-to))
              (progn
                (setq swap-b-from (point)
                      swap-b-to (+ (point) (length manued-swap-str))
                      swap-b-contents-to swap-b-from
                      swap-c-contents-from swap-b-to)
                (goto-char swap-b-to))))
           ;; ;
           ((string= special-str manued-comment-str)
            (push 'comment type-list)
            (setq comment-from (point)
                  comment-to (+ (point) (length manued-comment-str))
                  comment-contents-from comment-to
                  comment-contents-to (point-max))
            (cond
             ((eq command-type 'delete)
              (setq last-contents-to comment-from))
             ((eq command-type 'swap)
              (when (< swap-count 2)
                (setq manued-last-parse-command-error-point (point))
                (setq manued-last-parse-command-error-message
                      (format nil "point ~S: swap コマンドが 2 度出現する前にコメントが開始されました。" (point)))
                (plain-error "~A" manued-last-parse-command-error-message))
              (setq swap-c-contents-to comment-from))
             ((and (eq command-type nil)
                   (/= l-parenthesis-to comment-from))
              (setq manued-last-parse-command-error-point (point))
              (setq manued-last-parse-command-error-message
                    (format nil "point ~S: コメントが開始する前に、コマンドを構成しない文字列が存在しています。" (point)))
              (plain-error "~A" manued-last-parse-command-error-message)))
            (goto-char (point-max)))
           ;; ~
           ((string= special-str manued-escape-str)
            (forward-char (length manued-escape-str)))
           (t
            (setq manued-last-parse-command-error-point (point))
            (setq manued-last-parse-command-error-message
                  (format nil "point ~S: manued-mode.l のバグです: 特殊文字でない文字列 (~A) を特殊文字として認識しています。" (point) special-str))
            (plain-error "~A" manued-last-parse-command-error-message))))
        (cond
         ((eq command-type 'delete)
          (unless last-contents-to
            (setq last-contents-to (point-max)))
          (if (manued-order-older-first-p)
              (setq older-contents-from first-contents-from
                    older-contents-to first-contents-to
                    newer-contents-from last-contents-from
                    newer-contents-to last-contents-to)
            (setq older-contents-from last-contents-from
                  older-contents-to last-contents-to
                  newer-contents-from first-contents-from
                  newer-contents-to first-contents-to)))
         ((eq command-type 'swap)
          (when (< swap-count 2)
            (setq manued-last-parse-command-error-point (point))
            (setq manued-last-parse-command-error-message
                  (format nil "point ~S: swap コマンドが 2 度出現する前に終了しました。" (point)))
            (plain-error "~A" manued-last-parse-command-error-message))
          (unless swap-c-contents-to
            (setq swap-c-contents-to (point-max))))))
      (push 'r-parenthesis type-list)
      (setq type-list (nreverse type-list))

      ;; set-text-attribute 適用順序によって動作が変わるので注意

      ;; l-parenthesis
      (apply #'set-text-attribute
             (append (list l-parenthesis-from l-parenthesis-to
                           (list *manued-tag* identity 'l-parenthesis type-list))
                     (or attributes *manued-l-parenthesis-attributes*)))
      ;; delete
      (when delete-from
        (if (manued-order-older-first-p)
            (progn
              (apply #'set-text-attribute
                     (append (list older-contents-from older-contents-to
                                   (list *manued-tag* identity 'older-contents type-list))
                             (or attributes *manued-older-contents-attributes*)))
              (save-restriction
                (narrow-to-region older-contents-from older-contents-to)
                (manued-parse-commands-strict command-level (or attributes *manued-older-contents-attributes*)))
              (apply #'set-text-attribute
                     (append (list delete-from delete-to
                                   (list *manued-tag* identity 'delete type-list))
                             (or attributes *manued-delete-attributes*)))
              (apply #'set-text-attribute
                     (append (list newer-contents-from newer-contents-to
                                   (list *manued-tag* identity 'newer-contents type-list))
                             (or attributes *manued-newer-contents-attributes*)))
              (save-restriction
                (narrow-to-region newer-contents-from newer-contents-to)
                (manued-parse-commands-strict command-level (or attributes *manued-newer-contents-attributes*))))
          (progn
            (apply #'set-text-attribute
                   (append (list newer-contents-from newer-contents-to
                                 (list *manued-tag* identity 'newer-contents type-list))
                           (or attributes *manued-newer-contents-attributes*)))
            (save-restriction
              (narrow-to-region newer-contents-from newer-contents-to)
              (manued-parse-commands-strict command-level (or attributes *manued-newer-contents-attributes*)))
            (apply #'set-text-attribute
                   (append (list delete-from delete-to
                                 (list *manued-tag* identity 'delete type-list))
                           (or attributes *manued-delete-attributes*)))
            (apply #'set-text-attribute
                   (append (list older-contents-from older-contents-to
                                 (list *manued-tag* identity 'older-contents type-list))
                           (or attributes *manued-older-contents-attributes*)))
            (save-restriction
              (narrow-to-region older-contents-from older-contents-to)
              (manued-parse-commands-strict command-level (or attributes *manued-older-contents-attributes*))))))
      ;; swap
      (when swap-a-from
        ;; swap-a-contents
        (apply #'set-text-attribute
               (append (list swap-a-contents-from swap-a-contents-to
                             (list *manued-tag* identity 'swap-a-contents type-list))
                       (or attributes *manued-swap-a-contents-attributes*)))
        (save-restriction
          (narrow-to-region swap-a-contents-from swap-a-contents-to)
          (manued-parse-commands-strict command-level (or attributes *manued-swap-a-contents-attributes*)))
        ;; swap-a
        (apply #'set-text-attribute
               (append (list swap-a-from swap-a-to
                             (list *manued-tag* identity 'swap type-list))
                       (or attributes *manued-swap-attributes*)))
        ;; swap-b-contents
        (apply #'set-text-attribute
               (append (list swap-b-contents-from swap-b-contents-to
                             (list *manued-tag* identity 'swap-b-contents type-list))
                       (or attributes *manued-swap-b-contents-attributes*)))
        (save-restriction
          (narrow-to-region swap-b-contents-from swap-b-contents-to)
          (manued-parse-commands-strict command-level (or attributes *manued-swap-b-contents-attributes*)))
        ;; swap-b
        (apply #'set-text-attribute
               (append (list swap-b-from swap-b-to
                             (list *manued-tag* identity 'swap type-list))
                       (or attributes *manued-swap-attributes*)))
        ;; swap-c-contents
        (apply #'set-text-attribute
               (append (list swap-c-contents-from swap-c-contents-to
                             (list *manued-tag* identity 'swap-c-contents type-list))
                       (or attributes *manued-swap-c-contents-attributes*)))
        (save-restriction
          (narrow-to-region swap-c-contents-from swap-c-contents-to)
          (manued-parse-commands-strict command-level (or attributes *manued-swap-c-contents-attributes*))))
      ;; comment
      (when comment-from
        (apply #'set-text-attribute
               (append (list comment-from comment-to
                             (list *manued-tag* identity 'comment type-list))
                       (or attributes *manued-comment-attributes*)))
        (apply #'set-text-attribute
               (append (list comment-contents-from comment-contents-to
                             (list *manued-tag* identity 'comment-contents type-list))
                       (or attributes *manued-comment-contents-attributes*))))
      ;; r-parenthesis
      (apply #'set-text-attribute
             (append (list r-parenthesis-from r-parenthesis-to
                           (list *manued-tag* identity 'r-parenthesis type-list))
                     (or attributes *manued-r-parenthesis-attributes*))))
    ;;
    (list (cons l-parenthesis-from l-parenthesis-to)
          (cons r-parenthesis-from r-parenthesis-to)
          (if comment-from (cons comment-from comment-to))
          (if delete-from (cons delete-from delete-to))
          (if swap-a-from (cons swap-a-from swap-a-to))
          (if swap-b-from (cons swap-b-from swap-b-to))
          (if comment-contents-from (cons comment-contents-from comment-contents-to))
          (if older-contents-from (cons older-contents-from older-contents-to))
          (if newer-contents-from (cons newer-contents-from newer-contents-to))
          (if swap-a-contents-from (cons swap-a-contents-from swap-a-contents-to))
          (if swap-b-contents-from (cons swap-b-contents-from swap-b-contents-to))
          (if swap-c-contents-from (cons swap-c-contents-from swap-c-contents-to)))))

(defun manued-parse-commands-strict (field-level &optional attributes)
  "現在の narrowing 範囲のフィールドレベルが filed-level であることを前提に、
narrowing 範囲に含まれるコマンド群を構文解析する。
この関数使用時は、適切に narrowing されていなければならない。"
  (let ((in-command-p (not (zerop field-level))) command-info command-info-list)
    (save-excursion
      (goto-char (manued-point-min))
      (while (and (manued-goto-l-parenthesis-strict in-command-p)
                  (progn
                    (setq command-info (manued-parse-command-from-point-strict field-level attributes))
                    (manued-command-info-get-l-parenthesis-range command-info)))
        (goto-char (cdr (manued-command-info-get-r-parenthesis-range command-info)))
        (push command-info command-info-list)))
    (nreverse command-info-list)))

(defun manued-parse-commands-from-top-level ()
  "現在の narrowing 範囲のフィールドレベルが 0 であるとして、
narrowing 範囲に含まれるコマンド群を構文解析する。"
  (interactive)
  (manued-parse-commands-strict 0))

(defun manued-parse-command-from-point ()
  "現在位置から開始するコマンドを構文解析して、テキスト属性を設定し、
解析結果情報 command-info を返す。
現在位置の field-level に応じて適切に attributes を設定した上で
manued-parse-command-from-point-strict を呼ぶ。"
  (let ((field-level (manued-get-field-level)) attributes)
    (when (plusp field-level)
      (multiple-value-bind (from to tag foreground background bold underline strike-out prefix extend)
          (find-text-attribute-point (point))
        (setq attributes (list :foreground foreground :background background
                               :bold bold :underline underline
                               :strike-out strike-out :prefix prefix :extend extend))))
    (manued-parse-command-from-point-strict field-level attributes)))
(defun manued-parse-commands ()
  "現在の narrowing 範囲のフィールドレベルが filed-level であることを前提に、
narrowing 範囲に含まれるコマンド群を構文解析する。
現在位置の field-level に応じて適切に attributes を設定した上で
manued-parse-commands-strict を呼ぶ。
この関数使用時は、適切に narrowing されていなければならない。"
  (let ((field-level (manued-get-field-level)) attributes)
    (when (plusp field-level)
      (multiple-value-bind (from to tag foreground background bold underline strike-out prefix extend)
          (find-text-attribute-point (point))
        (setq attributes (list :foreground foreground :background background
                               :bold bold :underline underline
                               :strike-out strike-out :prefix prefix :extend extend))))
    (manued-parse-commands-strict field-level attributes)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; コマンド構成文字列判定 / 移動用関数 (parse-command の結果を用いた関数群)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun manued-x-p (type)
  "現在位置が x か"
  (unless (listp type) (setq type (list type)))
  (multiple-value-bind (from to tag)
      (find-text-attribute-point (point))
    (when (and (listp tag) (member (nth 2 tag) type))
      (values from to))))

(defun manued-goto-x (type &optional field-level identity)
  "x に移動"
  (or (manued-x-p type)
      (manued-forward-x type 1 field-level identity)))

(defun manued-forward-x (type &optional (n 1) field-level identity)
  "次の x に移動
field-level と identity の両方が与えられた場合は identity を優先"
  (let (goto-point matched-type from to tag field-level-error
        current-identity current-type current-command-level current-field-level)
    (unless (listp type)
      (setq type (list type)))
    (save-excursion
      (cond
       ((plusp n)
        (forward-char)
        (while (not (zerop n))
          (decf n)
          (if (multiple-value-setq (from to tag)
                (find-text-attribute-if #'(lambda (tag)
                                            (when (and (listp tag) (eq (car tag) *manued-tag*))
                                              (let* ((current-identity (nth 1 tag))
                                                     (current-type (nth 2 tag))
                                                     (current-command-level (car current-identity))
                                                     (current-field-level (if (eq current-type 'l-parenthesis)
                                                                              (1- current-command-level)
                                                                            current-command-level)))
                                                (and (member current-type type)
                                                     (if identity
                                                         (eq current-identity identity)
                                                       (or (not field-level)
                                                           (>= field-level current-field-level)))))))
                                        :start (point)))
              ;; 上位 field-level にマッチした場合 error 記録
              (unless (or identity
                          (not field-level)
                          (progn
                            (setq current-identity (nth 1 tag)
                                  current-type (nth 2 tag)
                                  current-command-level (car current-identity)
                                  current-field-level (if (eq current-type 'l-parenthesis)
                                                          (1- current-command-level)
                                                        current-command-level))
                            (= field-level current-field-level)))
                (setq field-level-error t)))
          (if (and from (not field-level-error))
              (progn
                (setq goto-point from)
                (goto-char to))
            (return))))
       ((minusp n)
        (while (not (zerop n))
          (incf n)
          (if (multiple-value-setq (from to tag)
                (find-text-attribute-if #'(lambda (tag)
                                            (when (and (listp tag) (eq (car tag) *manued-tag*))
                                              (let* ((current-identity (nth 1 tag))
                                                     (current-type (nth 2 tag))
                                                     (current-command-level (car current-identity))
                                                     (current-field-level (if (eq current-type 'l-parenthesis)
                                                                              (1- current-command-level)
                                                                            current-command-level)))
                                                (and (member current-type type)
                                                     (if identity
                                                         (eq current-identity identity)
                                                       (or (not field-level)
                                                           (>= field-level current-field-level)))))))
                                        :end (point) :from-end t)
                )
              ;; 上位 field-level にマッチした場合 error 記録
              (unless (or identity
                          (not field-level)
                          (progn
                            (setq current-identity (nth 1 tag)
                                  current-type (nth 2 tag)
                                  current-command-level (car current-identity)
                                  current-field-level (if (eq current-type 'l-parenthesis)
                                                          (1- current-command-level)
                                                        current-command-level))
                            (= field-level current-field-level)))
                (setq field-level-error t)))
          (if (and from (not field-level-error))
              (progn
                (setq goto-point from)
                (goto-char to))
            (return))))))
    (when goto-point
      (goto-char goto-point)
      goto-point)))
(defun manued-forward-x-current-level (type &optional (n 1))
  "同一のフィールドレベルで、次の x に移動"
  (interactive "p")
  (manued-forward-x type n (manued-get-field-level)))

(defun manued-forward-x-in-current-command (type &optional (n 1))
  "同一の command 内での次の構成要素へ移動"
  (let ((identity (manued-get-current-command-identity)))
    (when identity
      (manued-forward-x type n nil identity))))
(defun manued-goto-x-in-current-command (type)
  "同一の command での構成要素へ移動"
  (let (goto-point)
    (save-excursion
      (if (manued-x-p type)
          (multiple-value-bind (from to tag)
              (find-text-attribute-point (point))
            (setq goto-point from))
        (if (manued-forward-x-in-current-command type)
            (setq goto-point (point))
          (progn
            (manued-forward-x-in-current-command 'l-parenthesis -1)
            (cond ((manued-x-p type)
                   (setq goto-point (point)))
                  ((manued-forward-x-in-current-command type)
                   (setq goto-point (point))))))))
    (when goto-point
      (goto-char goto-point)
      goto-point)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; l-parenthesis
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun manued-l-parenthesis-p ()
  (manued-x-p 'l-parenthesis))
(defun manued-goto-l-parenthesis ()
  (manued-goto-x 'l-parenthesis))
(defun manued-forward-l-parenthesis (&optional (n 1))
  (interactive "p")
  (manued-forward-x 'l-parenthesis n))
(defun manued-backward-l-parenthesis (&optional (n 1))
  (interactive "p")
  (manued-forward-l-parenthesis (- n)))
(defun manued-forward-l-parenthesis-current-level (&optional (n 1))
  (interactive "p")
  (manued-forward-x-current-level 'l-parenthesis n))
(defun manued-backward-l-parenthesis-current-level (&optional (n 1))
  (interactive "p")
  (manued-forward-l-parenthesis-current-level (- n)))
(defun manued-goto-l-parenthesis-in-current-command ()
  (interactive)
  (manued-goto-x-in-current-command 'l-parenthesis))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; r-parenthesis
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun manued-r-parenthesis-p ()
  (manued-x-p 'r-parenthesis))
(defun manued-goto-r-parenthesis ()
  (manued-goto-x 'r-parenthesis))
(defun manued-forward-r-parenthesis (&optional (n 1))
  (interactive "p")
  (manued-forward-x 'r-parenthesis n))
(defun manued-backward-r-parenthesis (&optional (n 1))
  (interactive "p")
  (manued-forward-r-parenthesis (- n)))
(defun manued-forward-r-parenthesis-current-level (&optional (n 1))
  (interactive "p")
  (manued-forward-x-current-level 'r-parenthesis n))
(defun manued-backward-r-parenthesis-current-level (&optional (n 1))
  (interactive "p")
  (manued-forward-r-parenthesis-current-level (- n)))
(defun manued-goto-r-parenthesis-in-current-command ()
  (interactive)
  (manued-goto-x-in-current-command 'r-parenthesis))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; delete
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun manued-delete-p ()
  (manued-x-p 'delete))
(defun manued-goto-delete ()
  (manued-goto-x 'delete))
(defun manued-forward-delete (&optional (n 1))
  (interactive "p")
  (manued-forward-x 'delete n))
(defun manued-backward-delete (&optional (n 1))
  (interactive "p")
  (manued-forward-delete (- n)))
(defun manued-forward-delete-current-level (&optional (n 1))
  (interactive "p")
  (manued-forward-x-current-level 'delete n))
(defun manued-backward-delete-current-level (&optional (n 1))
  (interactive "p")
  (manued-forward-delete-current-level (- n)))
(defun manued-goto-delete-in-current-command ()
  (interactive)
  (manued-goto-x-in-current-command 'delete))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; swap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun manued-swap-p ()
  (manued-x-p 'swap))
(defun manued-goto-swap ()
  (manued-goto-x 'swap))
(defun manued-forward-swap (&optional (n 1))
  (interactive "p")
  (manued-forward-x 'swap n))
(defun manued-backward-swap (&optional (n 1))
  (interactive "p")
  (manued-forward-swap (- n)))
(defun manued-forward-swap-current-level (&optional (n 1))
  (interactive "p")
  (manued-forward-x-current-level 'swap n))
(defun manued-backward-swap-current-level (&optional (n 1))
  (interactive "p")
  (manued-forward-swap-current-level (- n)))
(defun manued-forward-swap-in-current-command (&optional (n 1))
  (interactive)
  (manued-forward-x-in-current-command 'swap n))
(defun manued-goto-swap-in-current-command ()
  (interactive)
  (manued-goto-x-in-current-command 'swap))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; comment
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun manued-comment-p ()
  (manued-x-p 'comment))
(defun manued-goto-comment ()
  (manued-goto-x 'comment))
(defun manued-forward-comment (&optional (n 1))
  (interactive "p")
  (manued-forward-x 'comment n))
(defun manued-backward-comment (&optional (n 1))
  (interactive "p")
  (manued-forward-comment (- n)))
(defun manued-forward-comment-current-level (&optional (n 1))
  (interactive "p")
  (manued-forward-x-current-level 'comment n))
(defun manued-backward-comment-current-level (&optional (n 1))
  (interactive "p")
  (manued-forward-comment-current-level (- n)))
(defun manued-goto-comment-in-current-command ()
  (interactive)
  (manued-goto-x-in-current-command 'comment))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (l-parenthesis <-> r-parenthesis)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun manued-goto-matched-parenthesis ()
  "対応する parenthesis に移動"
  (interactive)
  (cond ((manued-l-parenthesis-p)
         (manued-goto-r-parenthesis-in-current-command))
        ((manued-r-parenthesis-p)
         (manued-goto-l-parenthesis-in-current-command))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; コマンド内のコマンド構成文字列位置への前後移動
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun manued-forward-any-in-current-command (&optional (n 1))
  (interactive "p")
  (manued-forward-x-in-current-command
   '(l-parenthesis r-parenthesis delete swap comment) n))
(defun manued-backward-any-in-current-command (&optional (n 1))
  (interactive "p")
  (manued-forward-any-in-current-command (- n)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; コマンド判定
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun manued-delete-command-p ()
  (save-excursion
    (manued-goto-delete-in-current-command)))
(defun manued-swap-command-p ()
  (save-excursion
    (manued-goto-swap-in-current-command)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; コマンド判定を使用した移動
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun manued-goto-older-contents-in-current-command ()
  (interactive)
  (let (goto-point)
    (save-excursion
      (when (manued-delete-command-p)
        (if (manued-order-older-first-p)
            (when (manued-goto-l-parenthesis-in-current-command)
              (forward-char (length manued-l-parenthesis-str))
              (setq goto-point (point)))
          (when (manued-goto-delete-in-current-command)
            (forward-char (length manued-delete-str))
            (setq goto-point (point))))))
    (when goto-point
      (goto-char goto-point)
      goto-point)))
(defun manued-goto-newer-contents-in-current-command ()
  (interactive)
  (let (goto-point)
    (save-excursion
      (when (manued-delete-command-p)
        (if (manued-order-older-first-p)
            (when (manued-goto-delete-in-current-command)
              (forward-char (length manued-delete-str))
              (setq goto-point (point)))
          (when (manued-goto-l-parenthesis-in-current-command)
            (forward-char (length manued-l-parenthesis-str))
            (setq goto-point (point))))))
    (when goto-point
      (goto-char goto-point)
      goto-point)))

(defun manued-goto-swap-a-contents-in-current-command ()
  (interactive)
  (let (goto-point)
    (save-excursion
      (when (manued-swap-command-p)
        (manued-goto-l-parenthesis-in-current-command)
        (forward-char (length manued-l-parenthesis-str))
        (setq goto-point (point))))
    (when goto-point
      (goto-char goto-point)
      goto-point)))
(defun manued-goto-swap-b-contents-in-current-command ()
  (interactive)
  (let (goto-point)
    (save-excursion
      (when (manued-swap-command-p)
        (manued-goto-l-parenthesis-in-current-command)
        (manued-forward-swap-in-current-command 1)
        (forward-char (length manued-swap-str))
        (setq goto-point (point))))
    (when goto-point
      (goto-char goto-point)
      goto-point)))
(defun manued-goto-swap-c-contents-in-current-command ()
  (interactive)
  (let (goto-point)
    (save-excursion
      (when (manued-swap-command-p)
        (manued-goto-l-parenthesis-in-current-command)
        (manued-forward-swap-in-current-command 2)
        (forward-char (length manued-swap-str))
        (setq goto-point (point))))
    (when goto-point
      (goto-char goto-point)
      goto-point)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 各種判定
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; in-command-p 判定
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun manued-in-command-p ()
  "コマンドの中か"
  (not (zerop (manued-get-field-level))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; in-comment-p 判定
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun manued-in-comment-p ()
  "コメントの中か"
  (let ((point (point)) from to)
    (save-excursion
      (and (prog1
               (manued-goto-comment-in-current-command)
             (forward-char (length manued-comment-str))
             (setq from (point)))
           (prog1
               (manued-goto-r-parenthesis-in-current-command)
             (setq to (point)))
           (and (<= from point) (< point to))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; escape  判定
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun manued-escape-p ()
  "直前がエスケープか
コメント対応済み。"
  (let ((escape-count 0))
    (save-excursion
      (while (looking-back manued-escape-str)
        (incf escape-count)
        (backward-char (length manued-escape-str))))
    (if (zerop escape-count)
        nil
      (if (manued-in-comment-p)
          (looking-for manued-r-parenthesis-str)
        (if (looking-for manued-l-parenthesis-str)
            (cond ((oddp escape-count)     t)
                  ((manued-in-command-p) nil)
                  (t                       t))
          (cond ((evenp escape-count)  nil)
                ((manued-in-command-p)   t)
                (t                     nil)))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; encode / decode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun manued-encode-string-strict (str in-command-p)
  (if in-command-p
      (manued-encode-string-in-command str)
    (manued-encode-string-out-command str)))

(defun manued-encode-string-out-command (str)
  "command を含まない文字列 str を command 外用にエンコードする。
注意：str に command の一部\(l-parenthesis-str\) が含まれてはならない。
      str 中の command は考慮しない。"
  (let (pattern replacement)
    (setq pattern (regexp-quote manued-l-parenthesis-str))
    (setq replacement
          (substitute-string (concat manued-escape-str manued-l-parenthesis-str)
                             "\\\\" "\\\\\\\\"))
    (substitute-string str pattern replacement)))

(defun manued-encode-string-in-command (str)
  "command を含まない文字列 str を command 内用にエンコードする。
注意：str に command の一部\(l-parenthesis-str\) が含まれてはならない。
      str 中の command は考慮しない。"
  (let (pattern replacement)
    (dolist (special-str (list manued-escape-str
                               manued-l-parenthesis-str manued-r-parenthesis-str
                               manued-delete-str manued-swap-str manued-comment-str))
      (setq pattern (regexp-quote special-str))
      (setq replacement
            (substitute-string (concat manued-escape-str special-str)
                               "\\\\" "\\\\\\\\"))
      (setq str (substitute-string str pattern replacement))))
  str)

(defun manued-decode-string-out-command (str)
  "command 外 の、command を含まない文字列 str をデコードする。"
  (let (pattern replacement)
    (setq pattern (regexp-quote (concat manued-escape-str manued-l-parenthesis-str)))
    (setq replacement (substitute-string manued-l-parenthesis-str "\\\\" "\\\\\\\\"))
    (substitute-string str pattern replacement)))

(defun manued-decode-string-in-command (str)
  "command 内 の、command を含まない文字列 str をデコードする。"
  (let (pattern replacement)
    (dolist (special-str (list manued-l-parenthesis-str manued-r-parenthesis-str
                               manued-delete-str manued-swap-str manued-comment-str
                               manued-escape-str))
      (setq pattern (regexp-quote (concat manued-escape-str special-str)))
      (setq replacement (substitute-string special-str "\\\\" "\\\\\\\\"))
      (setq str (substitute-string str pattern replacement))))
  str)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; eval manued command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun manued-eval-command-strict (command-info in-command-p &optional old-p)
  (with-manued-mode-edit
    (let ((range (manued-command-info-get-wide-range command-info))
          older-contents-str newer-contents-str
          swap-a-contents-str swap-b-contents-str swap-c-contents-str
          str)
      (save-excursion
        (save-restriction
          (narrow-to-region (car range) (cdr range))
          ;; 文字列の取得
          (cond
           ;; delete
           ((manued-command-info-get-delete-range command-info)
            (if old-p
                (progn
                  (setq range (manued-command-info-get-older-contents-range command-info))
                  (save-restriction
                    (narrow-to-region (car range) (cdr range))
                    (manued-eval-current-level-commands-strict t old-p)
                    (setq older-contents-str (buffer-substring (point-min) (point-max)))))
              (progn
                (setq range (manued-command-info-get-newer-contents-range command-info))
                (save-restriction
                  (narrow-to-region (car range) (cdr range))
                  (manued-eval-current-level-commands-strict t old-p)
                  (setq newer-contents-str (buffer-substring (point-min) (point-max)))))))
           ;; swap
           ((manued-command-info-get-swap-a-range command-info)
            ;; swap-c-contents
            (setq range (manued-command-info-get-swap-c-contents-range command-info))
            (save-restriction
              (narrow-to-region (car range) (cdr range))
              (manued-eval-current-level-commands-strict t old-p)
              (setq swap-c-contents-str (buffer-substring (point-min) (point-max))))
            ;; swap-b-contents
            (setq range (manued-command-info-get-swap-b-contents-range command-info))
            (save-restriction
              (narrow-to-region (car range) (cdr range))
              (manued-eval-current-level-commands-strict t old-p)
              (setq swap-b-contents-str (buffer-substring (point-min) (point-max))))
            ;; swap-a-contents
            (setq range (manued-command-info-get-swap-a-contents-range command-info))
            (save-restriction
              (narrow-to-region (car range) (cdr range))
              (manued-eval-current-level-commands-strict t old-p)
              (setq swap-a-contents-str (buffer-substring (point-min) (point-max))))))
          ;; 文字列削除
          (delete-region (point-min) (point-max))
          ;; 新規文字列挿入
          (if old-p
              ;; old
              (cond
               (older-contents-str
                (apply #'set-text-attribute
                       (append (list (point)
                                     (progn
                                       (insert (manued-encode-string-strict
                                                (manued-decode-string-in-command
                                                 older-contents-str)
                                                in-command-p))
                                       (point))
                                     *manued-eval-command-tag*)
                               *manued-older-contents-attributes*)))
               (swap-a-contents-str
                (apply #'set-text-attribute
                       (append (list (point)
                                     (progn
                                       (insert (manued-encode-string-strict
                                                (manued-decode-string-in-command
                                                 swap-a-contents-str)
                                                in-command-p))
                                       (point))
                                     *manued-eval-command-tag*)
                               *manued-swap-a-contents-attributes*))
                (apply #'set-text-attribute
                       (append (list (point)
                                     (progn
                                       (insert (manued-encode-string-strict
                                                (manued-decode-string-in-command
                                                 swap-b-contents-str)
                                                in-command-p))
                                       (point))
                                     *manued-eval-command-tag*)
                               *manued-swap-b-contents-attributes*))
                (apply #'set-text-attribute
                       (append (list (point)
                                     (progn
                                       (insert (manued-encode-string-strict
                                                (manued-decode-string-in-command
                                                 swap-c-contents-str)
                                                in-command-p))
                                       (point))
                                     *manued-eval-command-tag*)
                               *manued-swap-c-contents-attributes*))))
            ;; new
            (cond
               (newer-contents-str
                (apply #'set-text-attribute
                       (append (list (point)
                                     (progn
                                       (insert (manued-encode-string-strict
                                                (manued-decode-string-in-command
                                                 newer-contents-str)
                                                in-command-p))
                                       (point))
                                     *manued-eval-command-tag*)
                               *manued-newer-contents-attributes*)))
               (swap-a-contents-str
                (apply #'set-text-attribute
                       (append (list (point)
                                     (progn
                                       (insert (manued-encode-string-strict
                                                (manued-decode-string-in-command
                                                 swap-c-contents-str)
                                                in-command-p))
                                       (point))
                                     *manued-eval-command-tag*)
                               *manued-swap-c-contents-attributes*))
                (apply #'set-text-attribute
                       (append (list (point)
                                     (progn
                                       (insert (manued-encode-string-strict
                                                (manued-decode-string-in-command
                                                 swap-b-contents-str)
                                                in-command-p))
                                       (point))
                                     *manued-eval-command-tag*)
                               *manued-swap-b-contents-attributes*))
                (apply #'set-text-attribute
                       (append (list (point)
                                     (progn
                                       (insert (manued-encode-string-strict
                                                (manued-decode-string-in-command
                                                 swap-a-contents-str)
                                                in-command-p))
                                       (point))
                                     *manued-eval-command-tag*)
                               *manued-swap-a-contents-attributes*))))))))))

(defun manued-eval-current-level-commands-strict (in-command-p &optional old-p)
  (save-excursion
    (dolist (command-info (nreverse (manued-parse-commands)))
      (manued-eval-command-strict command-info in-command-p old-p))))

(defun manued-eval-last-command (&optional old-p)
  "直前のコマンドを評価する。"
  (interactive "p")
  (save-excursion
    (when (and (manued-backward-r-parenthesis)
               (manued-goto-l-parenthesis-in-current-command))
      (let ((in-command-p (not (zerop (manued-get-field-level)))))
        (manued-eval-command-strict
         (manued-parse-command-from-point) in-command-p old-p)))))

(defun manued-eval-command-region (from to &optional old-p)
  "リージョンに含まれるコマンドを評価する。"
  (interactive "r")
  (when (> from to) (rotatef from to))
  (with-manued-mode-edit
    (save-excursion
      (save-restriction
        (narrow-to-region from to)
        (goto-char from)
        (manued-eval-current-level-commands-strict (manued-in-command-p) old-p)))))

(defun manued-eval-command-region-old (from to)
  "リージョンに含まれるコマンドを評価し、元の文字列に戻す。"
  (interactive "r")
  (manued-eval-command-region from to t))

(defun manued-eval-command-selection (&optional old-p)
  "セレクションに含まれるコマンドを評価する。"
  (interactive)
  (when (manued-pre-selection-p)
    (selection-start-end (start end)
      (manued-eval-command-region start end old-p))))

(defun manued-eval-command-selection-old ()
  "セレクションに含まれるコマンドを評価し、元の文字列に戻す。"
  (interactive)
  (manued-eval-command-selection t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 編集コマンド挿入
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun manued-undo ()
  "undo する。manued-mode であるならば、read-only でも undo する。"
  (interactive)
  (with-manued-mode-edit
    (undo)))

(defun manued-pre-selection-p ()
  (member (get-selection-type) '(1 2) :test #'eql))

(defun manued-toggle-command-with-comment ()
  "コマンド挿入時にコメントを付加するかの設定をトグルする。"
  (interactive)
  (setq manued-command-with-comment-p
        (not manued-command-with-comment-p)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; delete
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun manued-insert-delete-str (str &optional with-comment-p)
  (if (manued-order-older-first-p)
      (insert (format nil "~A~A~A~A~A"
                      manued-l-parenthesis-str
                      (manued-encode-string-in-command str)
                      manued-delete-str
                      (if with-comment-p manued-comment-str "")
                      manued-r-parenthesis-str))
    (insert (format nil "~A~A~A~A~A"
                    manued-l-parenthesis-str manued-delete-str
                    (manued-encode-string-in-command str)
                    (if with-comment-p manued-comment-str "")
                    manued-r-parenthesis-str))))

(defun manued-insert-delete-command-region (from to &optional (with-comment-p manued-command-with-comment-p))
  "リージョンを新たな delete コマンドに変換する。"
  (interactive "r")
  (with-manued-mode-edit
    (when (> from to) (rotatef from to))
    (manued-insert-delete-str
     (prog1 (buffer-substring from to) (delete-region from to)) with-comment-p)
    (save-excursion
      (goto-char from)
      (manued-parse-command-from-point))))

(defun manued-delete-command-region (from to &optional interactive-p)
  "リージョンを delete コマンドに変換する。"
  (interactive "r")
  (when (> from to) (rotatef from to))
  (with-manued-mode-edit
    (let (older-contents-from)
      (save-excursion
        (goto-char to)
        (when (manued-l-parenthesis-p)
          (setq older-contents-from (manued-goto-older-contents-in-current-command))))
      (if older-contents-from
          ;; 直後の delete コマンドに追加統合する
          (progn
            (goto-char older-contents-from)
            (insert (manued-encode-string-in-command (buffer-substring from to)))
            (delete-region from to))
        ;; 直後に delete コマンドがない場合は新規に追加する
        (progn
          (manued-insert-delete-command-region from to)
          (goto-char from)
          (when (or interactive-p (interactive-p))
            (manued-edit-delete-newer-contents)))))))

(defun manued-delete-command-selection (&optional interactive-p)
  "セレクションを delete コマンドに変換する。"
  (interactive)
  (when (manued-pre-selection-p)
    (selection-start-end (start end)
      (manued-delete-command-region start end
                                    (or interactive-p (interactive-p))))))

(defun manued-delete-command-line (&optional lines)
  "現在位置から行末尾までを delete コマンドに変換する。"
  (interactive "p")
  (unless (manued-l-parenthesis-p)
    (manued-delete-command-region
     (point)
     (progn
       (cond ((null lines)
              (if (eolp)
                  (forward-line 1)
                (goto-eol)))
             ((zerop lines)
              (if (bolp)
                  (forward-line -1)
                (goto-bol)))
             (t
              (forward-line lines)))
       (point)))))

(defun manued-delete-command-char (&optional (n 1))
  "現在位置を delete コマンドに変換する。"
  (interactive "p")
  (unless (or (and (plusp n)
                   (manued-l-parenthesis-p))
              (and (minusp n)
                   (save-excursion
                     (backward-char)
                     (manued-in-command-p))))
    (manued-delete-command-region (point)
                                  (progn (forward-char n) (point)))))

(defun manued-delete-command-backward-char (&optional (n 1))
  "直前位置を delete コマンドに変換する。"
  (interactive "p")
  (manued-delete-command-char (- n)))

(defun manued-delete-command-char-or-selection (&optional (n 1) interactive-p)
  "セレクションまたは現在位置を delete コマンドに変換する。"
  (interactive "p")
  (if (manued-pre-selection-p)
      (manued-delete-command-selection (or interactive-p (interactive-p)))
    (manued-delete-command-char n)))

(defun manued-delete-command-backward-char-or-selection (&optional (n 1))
  "セレクションまたは直前位置を delete コマンドに変換する。"
  (interactive "p")
  (manued-delete-command-char-or-selection (- n) (interactive-p)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; swap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun manued-insert-swap-str (str &optional with-comment-p)
  (insert (format nil "~A~A~A~A~A~A"
                  manued-l-parenthesis-str
                  (manued-encode-string-in-command str)
                  manued-swap-str manued-swap-str
                  (if with-comment-p manued-comment-str "")
                  manued-r-parenthesis-str)))

(defun manued-insert-swap-command-region (from to &optional (with-comment-p manued-command-with-comment-p))
  "リージョンを新たな swap コマンドに変換する。"
  (interactive "r")
  (with-manued-mode-edit
    (when (> from to) (rotatef from to))
    (manued-insert-swap-str
     (prog1 (buffer-substring from to) (delete-region from to)) with-comment-p)
    (save-excursion
      (goto-char from)
      (manued-parse-command-from-point))))

(defun manued-swap-command-region (from to &optional interactive-p)
  "リージョンを新たな swap コマンドに変換するとともに swap 位置の指定を行う。"
  (interactive "r")
  (when (> from to) (rotatef from to))
  (manued-insert-swap-command-region from to)
  (goto-char from)
  (when (or interactive-p (interactive-p))
    (manued-change-swap-boundary)))

(defun manued-swap-command-selection ()
  "セレクションを新たな swap コマンドに変換するとともに swap 位置の指定を行う。"
  (interactive)
  (when (manued-pre-selection-p)
    (selection-start-end (start end)
      (manued-swap-command-region start end (interactive-p)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; comment
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun manued-insert-comment-str (str)
  (insert (format nil "~A~A~A~A"
                  manued-l-parenthesis-str manued-comment-str
                  (manued-encode-string-in-command str)
                  manued-r-parenthesis-str)))

(defun manued-insert-comment-region (from to)
  "リージョンを新たな comment に変換する。"
  (interactive "r")
  (with-manued-mode-edit
    (when (> from to) (rotatef from to))
    (manued-insert-comment-str
     (prog1 (buffer-substring from to) (delete-region from to)))
    (save-excursion
      (goto-char from)
      (manued-parse-command-from-point))))

(defun manued-comment-region (from to &optional interactive-p)
  "リージョンを新たな comment に変換するとともに comment の編集を行う。"
  (interactive "r")
  (when (> from to) (rotatef from to))
  (manued-insert-comment-region from to)
  (goto-char from)
  (when (or interactive-p (interactive-p))
    (manued-edit-comment-contents)))

(defun manued-comment-selection ()
  "セレクションを新たな comment に変換するとともに comment の編集を行う。"
  (interactive)
  (when (manued-pre-selection-p)
    (selection-start-end (start end)
      (manued-comment-region start end (interactive-p)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; コマンド内編集
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar *manued-edit-contents-map* nil
  "コマンド/コメント編集時キーマップ")
(unless *manued-edit-contents-map*
  (setq *manued-edit-contents-map* (copy-keymap *global-keymap*))
  (dotimes (index *full-keymap-length*)
    (let* ((c (*keymap-index-char index))
           (x (lookup-keymap *manued-edit-contents-map* c)))
      (cond
       ;; keymap 除外
       ((keymapp x)
        (undefine-key *manued-edit-contents-map* c))
       ;; self-insert-command 除外
       ((eq 'self-insert-command x)
        (undefine-key *manued-edit-contents-map* c))
       ;; widen 除外
       ((eq 'widen x)
        (undefine-key *manued-edit-contents-map* c))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; delete
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun manued-edit-delete-newer-contents ()
  "現在位置から開始する delete コマンドの新コンテンツを編集する。"
  (interactive)
  (with-manued-mode-edit
    (let ((command-info (manued-parse-command-from-point))
          (modified-count (buffer-modified-count))
          pre-modified-count newer-contents-range
          current-char current-command)
      (unless (manued-command-info-get-delete-range command-info)
        (message "delete コマンドが開始していません。")
        (return-from manued-edit-delete-newer-contents nil))
      (unwind-protect
          (save-excursion
            (save-restriction
              (setq newer-contents-range
                    (manued-command-info-get-newer-contents-range command-info))
              ;; 多少編集時の見栄えをよくするために末尾に dummy attributes を設定
              (multiple-value-bind (from to tag foreground background bold underline strike-out prefix extend)
                  (find-text-attribute-point (1- (cdr newer-contents-range)))
                (set-text-attribute (cdr newer-contents-range) (1+ (cdr newer-contents-range))
                                    *manued-tag*
                                    :foreground foreground :background background
                                    :bold bold :underline underline :strike-out strike-out
                                    :prefix prefix :extend extend))
              (narrow-to-region (car newer-contents-range) (cdr newer-contents-range))
              (setq pre-modified-count (buffer-modified-count))
              (loop
                (message "コンテンツの修正： ESC で終了です。")
                (refresh-screen)
                (setq current-char (read-char *keyboard*))
                (when (eq current-char #\ESC)
                  (return))
                (setq current-command
                      (lookup-keymap *manued-edit-contents-map* current-char t))
                (cond
                 (current-command
                  (call-interactively current-command))
                 (t
                  (insert current-char)))
                (unless (eql pre-modified-count (buffer-modified-count))
                  (setq pre-modified-count (buffer-modified-count))
                  (undo-boundary)))))
        (progn
          (clear-message)
          (manued-parse-command-from-point))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; swap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun manued-change-swap-boundary ()
  "現在位置から開始する swap コマンドの swap 位置を指定する。"
  (interactive)
  (with-manued-mode-edit
    (let ((command-info (manued-parse-command-from-point))
          swap-a-range swap-b-range
          backup-str success-p (swap-count 0)
          current-char current-command)
      (unless (manued-command-info-get-swap-a-range command-info)
        (message "swap コマンドが開始していません。")
        (return-from manued-change-swap-boundary nil))
      (unwind-protect
          (save-excursion
            (save-restriction
              (narrow-to-region
               (cdr (manued-command-info-get-l-parenthesis-range command-info))
               (car (or (manued-command-info-get-comment-range command-info)
                        (manued-command-info-get-r-parenthesis-range command-info))))
              (setq backup-str (buffer-substring (point-min) (point-max)))
              (unwind-protect
                  (progn
                    (setq swap-a-range (manued-command-info-get-swap-a-range command-info))
                    (setq swap-b-range (manued-command-info-get-swap-b-range command-info))
                    (delete-region (car swap-b-range) (cdr swap-b-range))
                    (delete-region (car swap-a-range) (cdr swap-a-range))
                    (goto-char (car swap-a-range))
                    (let ((buffer-read-only t))
                      (declare (special buffer-read-only))
                      (while (not success-p)
                        (message "swap 位置の修正： ~A を挿入する位置で Enter を押してください。ESC でキャンセルです。"
                                 manued-swap-str)
                        (refresh-screen)
                        (setq current-char (read-char *keyboard*))
                        (setq current-command
                              (lookup-keymap *manued-edit-contents-map* current-char t))
                        (cond
                         ((eq current-char #\ESC)
                          (return))
                         ((eq current-char #\RET)
                          (manued-change-swap-boundary-insert-swap-str)
                          (incf swap-count)
                          (when (= swap-count 2)
                            (setq success-p t)))
                         (current-command
                          (call-interactively current-command))))))
                (unless success-p
                  (delete-region (point-min) (point-max))
                  (insert backup-str)))))
        (progn
          (clear-message)
          (manued-parse-command-from-point))))))
(defun manued-change-swap-boundary-insert-swap-str ()
  (interactive)
  (let ((buffer-read-only nil))
    (declare (special buffer-read-only))
    (apply #'set-text-attribute
           (append (list (point)
                         (progn
                           (insert manued-swap-str)
                           (point))
                         *manued-tag*)
                   *manued-swap-attributes*))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; comment
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun manued-edit-comment-contents ()
  "現在位置から開始するコマンドの comment を編集する。"
  (interactive)
  (with-manued-mode-edit
    (let ((command-info (manued-parse-command-from-point))
          (modified-count (buffer-modified-count))
          pre-modified-count
          comment-contents-range r-parenthesis-range
          current-char current-command)
      (unless command-info
        (message "コマンド開始位置ではありません。")
        (return-from manued-edit-comment-contents nil))
      (unwind-protect
          (save-excursion
            (save-restriction
              (setq comment-contents-range
                    (manued-command-info-get-comment-contents-range command-info))
              (if comment-contents-range
                  (progn
                    ;; 多少編集時の見栄えをよくするために末尾に dummy attributes を設定
                    (multiple-value-bind (from to tag foreground background bold underline strike-out prefix extend)
                        (find-text-attribute-point (1- (cdr comment-contents-range)))
                      (set-text-attribute (cdr comment-contents-range) (1+ (cdr comment-contents-range))
                                          *manued-tag*
                                          :foreground foreground :background background
                                          :bold bold :underline underline :strike-out strike-out
                                          :prefix prefix :extend extend))
                    (narrow-to-region (car comment-contents-range) (cdr comment-contents-range)))
                (progn
                  (setq r-parenthesis-range
                        (manued-command-info-get-r-parenthesis-range command-info))
                  (narrow-to-region (car r-parenthesis-range) (car r-parenthesis-range))
                  (insert manued-comment-str)
                  (narrow-to-region (point) (point))))
              (setq pre-modified-count (buffer-modified-count))
              (loop
                (message "コメントの修正： ESC で終了です。")
                (refresh-screen)
                (setq current-char (read-char *keyboard*))
                (when (eq current-char #\ESC)
                  (return))
                (setq current-command
                      (lookup-keymap *manued-edit-contents-map* current-char t))
                (cond
                 (current-command
                  (call-interactively current-command))
                 (t
                  (insert current-char)))
                (unless (eql pre-modified-count (buffer-modified-count))
                  (setq pre-modified-count (buffer-modified-count))
                  (undo-boundary)))))
        (progn
          (clear-message)
          (manued-parse-command-from-point))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 自動判別
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun manued-edit-command ()
  "現在位置から開始するコマンド種類に応じて、コマンド/コメントを編集する。"
  (interactive)
  (with-manued-mode-edit
    (let ((command-info (manued-parse-command-from-point)))
      (unless command-info
        (message "コマンド開始位置ではありません。")
        (return-from manued-edit-command nil))
      (cond
       ((manued-command-info-get-delete-range command-info)
        (manued-edit-delete-newer-contents))
       ((manued-command-info-get-swap-a-range command-info)
        (manued-change-swap-boundary))
       (t
        (manued-edit-comment-contents))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Normal Document <-> Manued Document
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun manued-convert-normal-to-manued (&optional normal-buffer)
  "Normal Document のバッファを Manued Document に変換"
  (save-excursion
    (when normal-buffer
      (set-buffer normal-buffer))
    (let ((l-parenthesis-len (length manued-l-parenthesis-str)))
      (goto-char (manued-point-min))
      (while (scan-buffer manued-l-parenthesis-str :regexp nil)
        (insert manued-escape-str)
        (forward-char l-parenthesis-len)))))

(defun manued-convert-manued-to-normal (&optional manued-buffer)
  "Manued Document のバッファを Normal Document に変換"
  (save-excursion
    (when manued-buffer
      (set-buffer manued-buffer))
    (let ((pattern (concat manued-escape-str manued-l-parenthesis-str))
          (escape-len (length manued-escape-str)))
      (goto-char (manued-point-min))
      (while (scan-buffer pattern :regexp nil)
        (delete-char escape-len)))))

(defun manued-create-manued-buffer (&optional normal-buffer)
  "Normal Document のバッファを元に Manued Document のバッファを生成"
  (save-excursion
    (when normal-buffer
      (set-buffer normal-buffer))
    (let ((normal-buffer (selected-buffer))
          (manued-buffer (create-new-buffer
                          (concat (buffer-name (selected-buffer))
                                  " [Manued]"))))
      (with-output-to-buffer (manued-buffer)
        (format t "~A" (buffer-substring (point-min) (point-max))))
      (set-buffer manued-buffer)
      (manued-convert-normal-to-manued)
      (not-modified)
      manued-buffer)))

(defun manued-convert-to-manued-document (&optional normal-buffer)
  "Manued 編集を行うための、コマンド開始文字をエンコードしたバッファを生成"
  (interactive)
  (let ((manued-buffer (manued-create-manued-buffer normal-buffer)))
    (when manued-buffer
      (set-buffer manued-buffer))))

(defun manued-extract-normal-document (&optional old-p)
  (long-operation
    (let ((manued-buffer (selected-buffer))
          (normal-buffer (create-new-buffer "*Manued [Normal]*")))
      (save-excursion
        (with-output-to-buffer (normal-buffer)
          (format t "~A" (buffer-substring (point-min) (point-max))))
        (set-buffer normal-buffer)
        (setq manued-l-parenthesis-str (buffer-local-value manued-buffer 'manued-l-parenthesis-str)
              manued-r-parenthesis-str (buffer-local-value manued-buffer 'manued-r-parenthesis-str)
              manued-delete-str (buffer-local-value manued-buffer 'manued-delete-str)
              manued-swap-str (buffer-local-value manued-buffer 'manued-swap-str)
              manued-comment-str (buffer-local-value manued-buffer 'manued-comment-str)
              manued-escape-str (buffer-local-value manued-buffer 'manued-escape-str)
              manued-order-str (buffer-local-value manued-buffer 'manued-order-str)
              manued-version-str (buffer-local-value manued-buffer 'manued-version-str))
        (manued-eval-current-level-commands-strict nil old-p)
        (manued-convert-manued-to-normal)
        (not-modified))
      (pop-to-buffer normal-buffer))))
(defun manued-extract-normal-old-document ()
  "Manued 形式バッファから、編集前バッファを生成"
  (interactive)
  (manued-extract-normal-document t))
(defun manued-extract-normal-new-document ()
  "Manued 形式バッファから、編集後バッファを生成"
  (interactive)
  (manued-extract-normal-document nil))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 表示関連
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun manued-delete-text-attributes (&optional f)
  (when f
    (delete-text-attributes *manued-eval-command-tag*))
  (delete-text-attributes *manued-tag*)
  (delete-text-attributes *manued-tag* :key #'safe-car))

(defun manued-refresh-screen (&optional f)
  (manued-eval-defcommand)
  (manued-delete-text-attributes)
  (manued-parse-commands-from-top-level)
  (refresh-screen f))
  
(defun manued-recenter (&optional arg)
  "コマンドを改めて構文解析しハイライトした上で recenter を行う。"
  (interactive "p")
  (manued-refresh-screen)
  (recenter arg))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; メニュー
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar *manued-menu-name* "&Manued"
  "Manued メニュー名")
(defvar *manued-menu-position* 'ed::help
  "Manued メニュー位置")

(defun manued-create-menu (&optional selection-only-p)
  (let ((menu (create-popup-menu 'manued)))
    (add-menu-item menu 'manued-recenter "&Highlight" 'manued-recenter)
    (add-menu-separator menu)
    (if selection-only-p
        (progn
          (add-menu-item menu 'manued-delete-command-selection
                         "Selection &Delete Command" 'manued-delete-command-selection
                         #'(lambda () (or (manued-pre-selection-p) :disable)))
          (add-menu-item menu 'manued-swap-command-selection
                         "Selection &Swap Command" 'manued-swap-command-selection
                         #'(lambda () (or (manued-pre-selection-p) :disable)))
          (add-menu-item menu 'manued-comment-selection
                         "Selection &Comment" 'manued-comment-selection
                         #'(lambda () (or (manued-pre-selection-p) :disable)))
          (add-menu-item menu 'manued-toggle-command-with-comment
                         "New Command &with Comment (Toggle)" 'manued-toggle-command-with-comment
                         #'(lambda () (and manued-command-with-comment-p :check)))
          (add-menu-separator menu)
          (add-menu-item menu 'manued-eval-command-selection
                         "Selection Extract Ne&w Document (Manued Format)" 'manued-eval-command-selection
                         #'(lambda () (or (manued-pre-selection-p) :disable)))
          (add-menu-item menu 'manued-eval-command-selection-old
                         "Selection Extract O&ld Document (Manued Format)" 'manued-eval-command-selection-old
                         #'(lambda () (or (manued-pre-selection-p) :disable))))
      (progn
        (add-popup-menu menu
                        (define-popup-menu
                          (:item nil "&Delete Command" 'manued-delete-command-selection
                           #'(lambda () (or (manued-pre-selection-p) :disable)))
                          (:item nil "&Swap Command" 'manued-swap-command-selection
                           #'(lambda () (or (manued-pre-selection-p) :disable)))
                          (:item nil "&Comment" 'manued-comment-selection
                           #'(lambda () (or (manued-pre-selection-p) :disable)))
                          :separator
                          (:item nil "Extract &New Document (Manued Format)" 'manued-eval-command-selection
                           #'(lambda () (or (manued-pre-selection-p) :disable)))
                          (:item nil "Extract &Old Document (Manued Format)" 'manued-eval-command-selection-old
                           #'(lambda () (or (manued-pre-selection-p) :disable))))
                        "&Selection")
        (add-popup-menu menu
                        (define-popup-menu
                          (:item nil "&Delete Command" 'manued-delete-command-region)
                          (:item nil "&Swap Command" 'manued-swap-command-region)
                          (:item nil "&Comment" 'manued-comment-region)
                          :separator
                          (:item nil "Extract &New Document (Manued Format)" 'manued-eval-command-region)
                          (:item nil "Extract &Old Document (Manued Format)" 'manued-eval-command-region-old))
                        "&Region")
        (add-menu-item menu 'manued-toggle-command-with-comment
                       "New Command &with Comment (Toggle)" 'manued-toggle-command-with-comment
                       #'(lambda () (and manued-command-with-comment-p :check)))))
    (add-menu-separator menu)
    (add-menu-item menu 'manued-edit-command
                   "Edit Comm&and" 'manued-edit-command
                   #'(lambda () (or (manued-l-parenthesis-p) :disable)))
    (add-menu-item menu 'manued-edit-delete-newer-contents
                   "Edit Dele&te Command" 'manued-edit-delete-newer-contents
                   #'(lambda () (or (manued-l-parenthesis-p) :disable)))
    (add-menu-item menu 'manued-change-swap-boundary
                   "Edit Swa&p Command" 'manued-change-swap-boundary
                   #'(lambda () (or (manued-l-parenthesis-p) :disable)))
    (add-menu-item menu 'manued-edit-comment-contents
                   "Edit Co&mment" 'manued-edit-comment-contents
                   #'(lambda () (or (manued-l-parenthesis-p) :disable)))
    (add-menu-separator menu)
    (add-menu-item menu 'manued-insert-header "&Insert Manued Header" 'manued-insert-header)
    (add-menu-item menu 'manued-eval-last-command "&Eval Last Manued Command"
                   'manued-eval-last-command)
    (add-menu-separator menu)
    (add-menu-item menu 'manued-undo "Manued &Undo" 'manued-undo)
    (add-menu-separator menu)
    (add-menu-item menu 'manued-convert-to-manued-document
                   "Con&vert to Manued Document (Manued Format)" 'manued-convert-to-manued-document)
    (add-menu-item menu 'manued-extract-normal-new-document
                   "Extract &New Document (Normal Format)" 'manued-extract-normal-new-document)
    (add-menu-item menu 'manued-extract-normal-old-document
                   "Extract &Old Document (Normal Format)" 'manued-extract-normal-old-document)
    (add-menu-separator menu)
    (add-menu-item menu 'manued-forward-l-parenthesis "Search &Forward"
                   'manued-forward-l-parenthesis)
    (add-menu-item menu 'manued-backward-l-parenthesis "Search &Backward"
                   'manued-backward-l-parenthesis)
    (add-menu-separator menu)
    (add-menu-item menu 'manued-goto-last-parse-command-error-point "&Goto Last Error"
                   'manued-goto-last-parse-command-error-point
                   #'(lambda () (or manued-last-parse-command-error-point :disable)))
    menu))

(defun manued-delete-menu (&optional (menu (current-menu)))
  (when (menup menu)
    (while (delete-menu menu 'manued))))

(defun manued-insert-menu (&key (menu (current-menu))
                                (position *manued-menu-position*)
                                (menu-name *manued-menu-name*))
  (let ((manued-menu (manued-create-menu)))
    (when (menup menu)
      (setq menu (copy-menu-items menu (create-menu)))
      (manued-delete-menu menu)
      (cond
       ((and (numberp position) (integerp position))
        (insert-popup-menu menu position manued-menu menu-name))
       ((and (symbolp position) (get-menu-position menu position))
        (insert-popup-menu menu (get-menu-position menu position)
                           manued-menu menu-name))
       (t
        (add-popup-menu menu manued-menu menu-name)))
      (use-local-menu menu))))

(defun manued-mouse-menu-popup (&optional apps)
  "セレクション用 Manued メニューをポップアップ"
  (interactive)
  (track-popup-menu (manued-create-menu t) (or apps :button2)))

(defun manued-apps-popup ()
  "セレクション用 Manued メニューをポインタ位置にポップアップ"
  (interactive)
  (let ((*last-mouse-window* (selected-window))
        (*last-mouse-line* (current-virtual-line-number))
        (*last-mouse-column* (current-virtual-column)))
    (manued-mouse-menu-popup t)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; メジャー/マイナーモード
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun manued-minor-mode (&optional (arg nil sv))
  "Manued ファイル編集用マイナーモード"
  (interactive "p")
  (toggle-mode 'manued-minor-mode arg sv)
  (update-mode-line t)
  (if manued-minor-mode
      (progn
        (set-minor-mode-map *manued-minor-mode-map*)
        (manued-insert-menu)
        (manued-refresh-screen))
    (progn
      (unset-minor-mode-map *manued-minor-mode-map*)
      (manued-delete-menu)
      (manued-delete-text-attributes)))
  t)
(pushnew '(manued-minor-mode . "Manued") *minor-mode-alist* :key #'car)

(defun manued-mode ()
  "Manued ファイル編集用メジャーモード"
  (interactive)
  (kill-all-local-variables)
  (setq buffer-read-only t)
  (setq buffer-mode 'manued-mode)
  (setq mode-name "Manued")
  (use-keymap *manued-mode-map*)
  (use-syntax-table *manued-mode-syntax-table*)
  (and *manued-keyword-file*
       (null *manued-keyword-hash-table*)
       (setq *manued-keyword-hash-table*
             (load-keyword-file *manued-keyword-file* t)))
  (when *manued-keyword-hash-table*
    (make-local-variable 'keyword-hash-table)
    (setq keyword-hash-table *manued-keyword-hash-table*))
  (setq *local-abbrev-table* *manued-mode-abbrev-table*)
  (manued-insert-menu)
  (manued-refresh-screen)
  (run-hooks '*manued-mode-hook*))

;;; manued-mode.l ends here
