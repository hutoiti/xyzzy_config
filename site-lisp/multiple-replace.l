;;; -*- Mode: Lisp; Package: EDITOR -*-
;;; multiple-replace.l

;; Copyright (C) 2001-2008 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Time-stamp: <2008/02/10 14:38:35 +0900>

;;; Commentary:

;; Description:
;;
;;  複数文字列の置換を行います。
;;

;; Installation:
;;
;;      1. アーカイブを展開して multiple-replace.l を $XYZZY/site-lisp に
;;         コピーします。
;;
;;      2. バイトコンパイルします。
;;
;;              M-x byte-compile-file
;;              Byte compile file: $XYZZY/site-lisp/multiple-replace.l
;;
;;      3. ~/.xyzzy または $XYZZY/site-lisp/siteinit.l に以下のコードを
;;         追加します。
;;
;;              (require "multiple-replace")
;;
;;      4. 上記の設定を反映させるために、xyzzy を再起動します。
;;         siteinit.l に記述した場合は Ctrl キーと Shift キーを押しながら
;;         xyzzy を再起動し、ダンプファイルを再構築します。
;;

;; Uninstallation:
;;
;;      1. ESC ESC (ed::multiple-replace-uninstall) とタイプし、
;;         multiple-replace.l 関連の情報を xyzzy から削除します。
;;
;;      2. multiple-replace.l に関する記述を削除します。
;;
;;      3. siteinit.l に記述していた場合は Ctrl キーと Shift キーを押し
;;         ながら xyzzy を再起動し、ダンプファイルを再構築します。
;;

;; Usage:
;;
;;      M-x multiple-replace-string
;;      M-x query-multiple-replace
;;
;;      M-x multiple-replace-regexp
;;      M-x query-multiple-replace-regexp
;;
;;      M-x multiple-replace-dialog
;;

;; Changes:
;;
;;      Thu, 10 May 2007 00:18:24 +0900
;;        ・multiple-replace-dialog の設定を外部ファイルに保存可能に。
;;          *multiple-replace-setting-file-directory* フォルダ
;;          (初期値 "~/.multiple-replace") が存在する場合は、設定のファイル
;;          への保存、ファイルから読み込みを行う。
;;          初期状態では、無名の設定(現在の設定)についても、ファイルへ保存
;;          する。無名設定についてはファイル保存/読込をしない場合は、
;;          *multiple-replace-setting-file-current-setting-p* を nil にする。
;;        ・不要なコードを削除。
;;
;;      Fri, 27 Apr 2007 00:21:23 +0900
;;        ・docstring の追加。
;;
;;      Sat, 08 Oct 2005 12:29:40 +0900
;;        ・メールアドレスを変更。
;;        ・ライセンス条項(修正BSDライセンス)を記載。
;;
;;      Mon, 06 Jun 2005 22:22:17 +0900
;;        ・ドキュメントに Usage 追加。
;;
;;      Wed, 13 Apr 2005 00:14:57 +0900
;;        ・multiple-replace-dialog の「設定」名が入力されていない状
;;          態で「保存」をした場合、その時点の日時から設定名を決定す
;;          るように拡張。
;;
;;      Mon, 11 Apr 2005 21:22:43 +0900
;;        ・xyzzy 0.2.2.234 対応
;;          - "ＭＳ Ｐゴシック" ⇒ "MS UI Gothic"
;;          - 半角カナを全角カナに変更。
;;          - multiple-replace-insert-menu-items 更新。
;;            「複数文字列置換」メニューを追加する位置のデフォルトを
;;            「置換」の下に。
;;        ・コメント修正。
;;
;;      Sun, 21 Dec 2003 08:20:37 +0900
;;        ・一行目に検索文字列を入力しなかった場合、履歴変更が
;;          できない点を修正。
;;        ・menu 関連を修正。
;;        ・uninstall 関連追加。
;;
;;      Sat, 04 Oct 2003 03:15:19 +0900
;;        ・履歴管理追加。
;;          ともない設定の変数に multiple-replace 独自のものを用いるように。
;;
;;      Mon, 14 Apr 2003 02:38:54 +0900
;;        ・初版作成。
;;

;; Licence:
;;
;;    multiple-replace は修正BSDライセンスに基づいて利用可能です。
;;    <http://www.opensource.org/licenses/bsd-license.php>
;;
;;
;;    Copyright (C) 2001-2008, OHKUBO Hiroshi.  All rights reserved.
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

(provide "multiple-replace")

(in-package "editor")

(require "search")
(require "dialogs")

(export '(multiple-replace-string
          query-multiple-replace
          multiple-replace-regexp
          query-multiple-replace-regexp
          multiple-replace-dialog
          *multiple-replace-setting-file-directory*
          *multiple-replace-setting-file-current-setting-p*
          multiple-replace-setting-file-create-directory))

(define-history-variable *last-multiple-search-replace-string-list* nil
  "前回の「検索語(非正規表現)、置換文字列」のペアからなるリストを保存している。")
(define-history-variable *last-multiple-search-replace-regexp-list* nil
  "前回の「検索語(正規表現)、置換文字列」のペアからなるリストを保存している。")
; (((pattern1 . replace1) (pattern2 . replace2) ...) ((decode-pattern1 . decode-replace1) ...))
(define-history-variable *last-multiple-search-replace-string-list-pair* nil
  "multiple-replace-dialog 関数でのみ用いる。
*last-multiple-search-replace-string-list* 及び
*last-multiple-search-replace-regexp-list* はエスケープシーケンスデコード後の
文字列を保持している。しかし、ダイアログ表示時は、エスケープシーケンス
デコード前の文字列を表示しなければならないため、デコード前の文字列を保持
している必要がある。
よって、この変数は、最後に実行した複数置換時のリスト
(*last-multiple-search-replace-string-list* または
 *last-multiple-search-replace-regexp-list*) について、その値そのものと、
それら文字列をエスケープシーケンスをデコードした値を保持する。

ただし、*last-multiple-search-replace-string-list-pair* に関する実装は、
現在不十分。ダイアログから複数置換を実施したときしか
*last-multiple-search-replace-string-list-pair* の値を保存していないため、
ミニバッファ等から改行文字、タブ文字などを含む複数置換を実行した後に
multiple-replace-dialog を実行すると、期待しない表示となる。")

(define-history-variable *last-multiple-replace-setting* nil
  "最後に実行した複数置換の設定を保持する。
より正確には、次に実行する複数置換のデフォルト値となるべき設定を保持する。
よって、複数置換実行後、別の設定を読み込んだ場合は、読み込んだ設定を
保持する。")
; ((("hisitory-name" . string) ("setting" . sexp)) ...)
(define-history-variable *multiple-replace-setting-history* nil
  "multiple-replace-dialog 関数でのみ用いる。
ダイアログから複数置換を実行した場合、その設定に名前をつけて保持する。
過去設定についても保持する。
ミニバッファから実行する複数置換では、この値を更新することも、参照
することもない。")

(defconstant *multiple-replace-dialog-number-of-input-min* 1
  "multiple-replace-dialog での、最小入力フィールド数。
リサイズ設定時の下限値。")
(defvar *multiple-replace-dialog-number-of-input* 5
  "* multiple-replace-dialog で表示する入力フィールド数。")
(defvar *multiple-replace-case-fold-search* *case-fold-search*
  "* 検索において ASCII 文字の大文字/小文字の区別の方法を指定する。
        nil     - 大文字/小文字を区別して検索する。
        :smart  - PATTERN に大文字が含まれていない場合、大文字/小文字を
                  区別せずに検索する。
        上記以外- 大文字/小文字を区別せずに検索する。

search.l dialogs.l の *case-fold-search* を参照。")
(defvar *multiple-replace-word-search* *word-search*
  "* 検索時の境界マッチ条件の指定。
        nil      - マッチ境界に関わらずマッチ成立
        :symbol  - (概要)マッチ境界のシンタックスが word, symbol の場合影響
        上記以外 -  (概要)マッチ境界のシンタックスが word の場合影響
multiple-replace-dialog にてインタラクティブに値の変更が可能。
値によって影響がでる関数は multiple-replace-dialog, multiple-replace-string,
query-multiple-replace。

最終的に scan-buffer の :left-bound, :right-bound に指定するため、
指定値の詳細は scan-buffer のリファレンス参照。

*multiple-replace-word-search* と *multiple-replace-regexp-search* が
共に non-nil の場合、*multiple-replace-word-search* の設定が有効となる。
つまり、正規表現検索は行わない。

scan-buffer の :regexp に non-nil を指定した場合は :left-bound,
:right-bound の指定は nil として扱われる。(:regexp 指定が優先される)
multiple-replace-dialog では、dialogs.l の replace-dialog と同様、
perform-multiple-replace に渡す前に *multiple-replace-word-search* と
*multiple-replace-regexp-search* を判断して *multiple-replace-word-search*
の指定を優先している。

また、multiple-replace-dialog にて *multiple-replace-word-search* の値を
変更すると、multiple-replace-string, query-multiple-replace にも影響を与える。
multiple-replace-regexp, query-multiple-replace-regexp では正規表現検索を
優先するため、*multiple-replace-word-search* の値による影響はない。

search.l dialogs.l の replace-dialog, replace-string query-replace でも
同様の *word-search* による影響がある。

search.l dialogs.l の *word-search* を参照。")
(defvar *multiple-replace-regexp-search* *regexp-search*
  "* 正規表現検索をするか否かの指定。
        nil     - [文字列] とみなす。
        non-nil - [正規表現] とみなす。
*multiple-replace-word-search* が non-nil の場合、そちらを優先する。
基本 multiple-replace-dialog のみで使用。
ヒストリに記録するために下記3関数でも使用。
  - perform-multiple-replace
  - multiple-replace-load-setting
  - multiple-replace-make-setting

multiple-replace-dialog では、dialogs.l の replace-dialog 関数と同様、
perform-multiple-replace に渡す前に *multiple-replace-word-search* と
*multiple-replace-regexp-search* を判断して *multiple-replace-word-search*
の指定を優先している。

dialogs.l の *regexp-search* を参照。")
(defvar *multiple-replace-understand-escape-sequences* *understand-escape-sequences*
  "* エスケープシーケンスを理解させるか否かの指定。
        nil     - エスケープシーケンスを理解しない
        non-nil - エスケープシーケンスを理解する
基本 multiple-replace-dialog のみで使用。
ヒストリに記録するために下記2関数でも使用。
  - multiple-replace-load-setting
  - multiple-replace-make-setting")
(defvar *multiple-replace-replace-whole-buffer* *replace-whole-buffer*
  "* バッファの先頭から置換を行うか否かの指定。
        nil     - 現在のポイントから置換を行う
        non-nil - バッファの先頭から置換を行う
基本 multiple-replace-dialog のみで使用。
ヒストリに記録するために下記2関数でも使用。
  - multiple-replace-load-setting
  - multiple-replace-make-setting")

(defvar *multiple-replace-setting-file-directory* "~/.multiple-replace"
  "* multiple-replace-dialog の設定の保存先フォルダ。
フォルダが存在する場合は、xyzzy のヒストリ変数と共に、ファイルにも保存する。")
(defvar *multiple-replace-setting-file-current-setting-p* t
  "* 無名の設定(現在の設定)についても、ファイル保存/読込をするか否か。
        nil     ファイル保存/読込をしない
        non-nil ファイル保存/読込をする")
(defvar *multiple-replace-setting-file-alist* nil
  "multiple-replace-dialog の設定名とファイル名を関連付ける内部処理用変数。")

(defun perform-multiple-replace (pattern-replacement-list query regexp interactive-p noerror)
  "複数置換のメイン処理を行う。
以下関数で使用される。
  - multiple-replace-string
  - query-multiple-replace
  - multiple-replace-regexp
  - query-multiple-replace-regexp
  - multiple-replace-dialog"
  (let ((literal (null regexp))
        (count 0)
        (nodup nil)
        (opoint (point))
        (not-found t)
        (def nil)
        (last-match nil)
        (last-match-char nil)
        (undo-bound (or interactive-p query))
        (pattern nil)
        (replacement nil)
        (point-pattern-list nil)
        (point-search nil))
    (undo-boundary)
    (when interactive-p
      (if regexp
          (setq *last-multiple-search-replace-regexp-list*
                pattern-replacement-list)
        (setq *last-multiple-search-replace-string-list*
              pattern-replacement-list))
      (let ((*multiple-replace-regexp-search* regexp))
        (declare (special *multiple-replace-regexp-search*))
        (setq *last-multiple-replace-setting* (multiple-replace-make-setting))))
    (if regexp
        (setq pattern-replacement-list
              (mapcar #'(lambda (pattern-replacement)
                          (cons
                           (if (stringp (car pattern-replacement))
                               (compile-regexp (car pattern-replacement) *multiple-replace-case-fold-search*)
                             (car pattern-replacement))
                           (cdr pattern-replacement)))
                      pattern-replacement-list)))
    (unless query
      (begin-wait-cursor))
    (loop
      (setq point-pattern-list nil)
      (save-excursion
        (setq search-point (point))
        (dolist (pattern (mapcar 'car pattern-replacement-list))
          (when (and (or (regexpp pattern) (stringp pattern))
                     (scan-buffer pattern
                                  :regexp regexp
                                  :no-dup nodup
                                  :last-match (cons last-match last-match-char)
                                  :case-fold *multiple-replace-case-fold-search*
                                  :left-bound *multiple-replace-word-search*
                                  :right-bound *multiple-replace-word-search*))
            (push (cons (point) pattern) point-pattern-list))
          (goto-char search-point)))
      (unless point-pattern-list
        (return))
      (setq pattern (cdar (stable-sort (nreverse point-pattern-list) '< :key 'car)))
      (setq replacement (cdr (assoc pattern pattern-replacement-list :test 'equal)))
      (scan-buffer pattern
                   :regexp regexp
                   :no-dup nodup
                   :last-match (cons last-match last-match-char)
                   :case-fold *multiple-replace-case-fold-search*
                   :left-bound *multiple-replace-word-search*
                   :right-bound *multiple-replace-word-search*)
      (if (and (eql (match-beginning 0) (match-end 0))
               (eql last-match (match-beginning 0)))
          (setq nodup t)
        (progn
          (setq not-found nil)
          (show-match)
          (unless (pos-visible-in-window-p (point))
            (recenter))
          (if query
              (progn
                (refresh-screen)
                (message (if (eq def 'help)
                             "(y)置換, (n)スキップ, (!)残り全部, (u)アンドゥ, (C-g)中止, (.)中止して戻る"
                           (format nil "置換する?: ⇒ ~S" replacement)))
                (setq def (lookup-keymap *query-replace-map* (read-char *keyboard*) t)))
            (setq def 'automatic))
          (when (cond ((eq def 'act)
                       t)
                      ((eq def 'skip)
                       (setq nodup t)
                       nil)
                      ((eq def 'automatic)
                       (setq query nil)
                       t)
                      ((eq def 'undo)
                       (and (plusp count)
                            (undo)
                            (setq count (1- count)))
                       (setq nodup nil)
                       nil)
                      ((eq def 'quit-and-back)
                       (goto-char opoint)
                       (setq def 'quit)
                       (return))
                      ((eq def 'quit)
                       (return))
                      ((eq def 'recenter)
                       (recenter)
                       (setq nodup nil)
                       nil)
                      ((and (consp def)
                            (eq (car def) 'throw))
                       (throw (cdr def) count))
                      (t (setq def 'help)
                         (setq nodup nil)
                         nil))
            (setq last-match-char (unless (= (match-end 0) (point-min))
                                    (char-before (match-end 0))))
            (unless (replace-match replacement :literal literal)
              (return))
            (setq last-match (point))
            (setq nodup (= (match-beginning 0) (match-end 0)))
            (when (and undo-bound query)
              (undo-boundary))
            (setq count (1+ count)))))
      (when (eobp)
        (return)))
    (unless query
      (end-wait-cursor))
    (hide-match)
    (unless noerror
      (and (eq def 'quit)
           (quit))
      (and not-found
           (error "文字列が見つかりません")))
    (when (and interactive-p
               (null *executing-macro*))
      (message "~d個置換しました" count))
    count))

(defun multiple-replace-string (pattern-replacement-list &optional noerror)
  "複数文字列(非正規表現)の一括置換を行う"
  (interactive
      (let (pattern replacement pat-rep-list (i 1))
        (loop
          (setq pattern
                (read-string (format nil "Replace string (~D): " i)
                             :default (elt (mapcar 'car *last-multiple-search-replace-string-list*) (1- i))
                             :history 'search))
          (if (string= pattern "")
              (return)
            (progn
              (setq replacement
                    (read-string (format nil "with (~D): " i)
                                 :default (elt (mapcar 'cdr *last-multiple-search-replace-string-list*) (1- i))
                                 :history 'search))
              (push (cons pattern replacement) pat-rep-list)))
          (incf i))
        (list (nreverse pat-rep-list))))
  (when buffer-read-only
    (error "書き込み禁止バッファです"))
  (perform-multiple-replace pattern-replacement-list nil nil (interactive-p) noerror))

(defun query-multiple-replace (pattern-replacement-list &optional noerror)
  "確認を伴いながら複数文字列(非正規表現)の置換を行う"
  (interactive
      (let (pattern replacement pat-rep-list (i 1))
        (loop
          (setq pattern
                (read-string (format nil "Query replace (~D): " i)
                             :default (elt (mapcar 'car *last-multiple-search-replace-string-list*) (1- i))
                             :history 'search))
          (if (string= pattern "")
              (return)
            (progn
              (setq replacement
                    (read-string (format nil "with (~D): " i)
                                 :default (elt (mapcar 'cdr *last-multiple-search-replace-string-list*) (1- i))
                                 :history 'search))
              (push (cons pattern replacement) pat-rep-list)))
          (incf i))
        (list (nreverse pat-rep-list))))
  (when buffer-read-only
    (error "書き込み禁止バッファです"))
  (perform-multiple-replace pattern-replacement-list t nil (interactive-p) noerror))

(defun multiple-replace-regexp (pattern-replacement-list &optional noerror)
  "複数正規表現の一括置換を行う"
  (interactive
      (let (pattern replacement pat-rep-list (i 1))
        (loop
          (setq pattern
                (read-string (format nil "Replace regexp (~D): " i)
                             :default (elt (mapcar 'car *last-multiple-search-replace-regexp-list*) (1- i))
                             :history 'search))
          (if (string= pattern "")
              (return)
            (progn
              (setq replacement
                    (read-string (format nil "with (~D): " i)
                                 :default (elt (mapcar 'cdr *last-multiple-search-replace-regexp-list*) (1- i))
                                 :history 'search))
              (push (cons pattern replacement) pat-rep-list)))
          (incf i))
        (list (nreverse pat-rep-list))))
  (when buffer-read-only
    (error "書き込み禁止バッファです"))
  (perform-multiple-replace pattern-replacement-list nil t (interactive-p) noerror))

(defun query-multiple-replace-regexp (pattern-replacement-list &optional noerror)
  "確認を伴いながら複数正規表現の置換を行う"
  (interactive
      (let (pattern replacement pat-rep-list (i 1))
        (loop
          (setq pattern
                (read-string (format nil "Query replace regexp (~D): " i)
                             :default (elt (mapcar 'car *last-multiple-search-replace-regexp-list*) (1- i))
                             :history 'search))
          (if (string= pattern "")
              (return)
            (progn
              (setq replacement
                    (read-string (format nil "with (~D): " i)
                                 :default (elt (mapcar 'cdr *last-multiple-search-replace-regexp-list*) (1- i))
                                 :history 'search))
              (push (cons pattern replacement) pat-rep-list)))
          (incf i))
        (list (nreverse pat-rep-list))))
  (when buffer-read-only
    (error "書き込み禁止バッファです"))
  (perform-multiple-replace pattern-replacement-list t t (interactive-p) noerror))


(defun multiple-replace-get-setting-item (setting name &optional default)
  "setting から名前に対応する値を取得する"
  (let (lst)
    (if (setq lst (assoc name setting :test 'string=))
        (cadr lst)
      default)))
(defun multiple-replace-load-setting (setting)
  "setting の内容をロードする"
  (setq *multiple-replace-case-fold-search* (multiple-replace-get-setting-item setting "case-fold-search"))
  (setq *multiple-replace-word-search* (multiple-replace-get-setting-item setting "word-search"))
  (setq *multiple-replace-regexp-search* (multiple-replace-get-setting-item setting "regexp-search"))
  (setq *multiple-replace-understand-escape-sequences*
        (multiple-replace-get-setting-item setting "understand-escape-sequences"))
  (setq *multiple-replace-replace-whole-buffer*
        (multiple-replace-get-setting-item setting "replace-whole-buffer"))
  (setq *multiple-replace-dialog-number-of-input*
        (multiple-replace-get-setting-item setting "dialog-number-of-input"
                                           *multiple-replace-dialog-number-of-input*))
  (if *multiple-replace-regexp-search*
      (setq *last-multiple-search-replace-regexp-list*
            (multiple-replace-get-setting-item setting "pattern-replacement-list"))
    (setq *last-multiple-search-replace-string-list*
          (multiple-replace-get-setting-item setting "pattern-replacement-list")))
  (setq *last-multiple-search-replace-string-list-pair*
        (multiple-replace-get-setting-item setting "search-replace-string-list-pair"))
  nil)
(defun multiple-replace-make-setting ()
  "現在の値から setting を作成する"
  (list (list (copy-string "pattern-replacement-list")
              (if *multiple-replace-regexp-search*
                  *last-multiple-search-replace-regexp-list*
                *last-multiple-search-replace-string-list*))
        (list (copy-string "case-fold-search") *multiple-replace-case-fold-search*)
        (list (copy-string "word-search") *multiple-replace-word-search*)
        (list (copy-string "regexp-search") *multiple-replace-regexp-search*)
        (list (copy-string "understand-escape-sequences") *multiple-replace-understand-escape-sequences*)
        (list (copy-string "replace-whole-buffer") *multiple-replace-replace-whole-buffer*)
        (list (copy-string "dialog-number-of-input") *multiple-replace-dialog-number-of-input*)
        (list (copy-string "search-replace-string-list-pair") *last-multiple-search-replace-string-list-pair*)))

(defun multiple-replace-dialog (&key (setting nil sv-setting) history-name)
  "ダイアログで指定し、複数文字列を同時に置換する"
  (interactive)
  (multiple-replace-setting-file-load-all)
  (let (dialog-template
        number-of-input
        controls controls-initializers controls-handlers
        search-symbol-list replace-symbol-list
        history
        (history-name-list (mapcar
                            #'(lambda (h)
                                (multiple-replace-get-setting-item h "history-name"))
                            *multiple-replace-setting-history*)))
    (let (pos)
      (if (and (stringp history-name)
               (setq pos (position history-name *multiple-replace-setting-history*
                                   :key #'(lambda (h) (multiple-replace-get-setting-item h "history-name"))
                                   :test 'equal)))
          (setq setting (multiple-replace-get-setting-item
                         (nth pos *multiple-replace-setting-history*) "setting"))
        (progn
          (setq history-name nil)
          (if (and (null setting) (not sv-setting))
              (setq setting *last-multiple-replace-setting*)))))
    (multiple-replace-load-setting setting)
    (setq number-of-input (max *multiple-replace-dialog-number-of-input-min*
                               (if (and (numberp *multiple-replace-dialog-number-of-input*)
                                        (integerp *multiple-replace-dialog-number-of-input*)
                                        (plusp *multiple-replace-dialog-number-of-input*))
                                   *multiple-replace-dialog-number-of-input* 0)))

    ;; search, replace 用 symbol の生成
    (dotimes (i number-of-input)
      (push (make-symbol (concat "search" (format nil "~D" i))) search-symbol-list)
      (push (make-symbol (concat "replace" (format nil "~D" i))) replace-symbol-list))
    (setq search-symbol-list (nreverse search-symbol-list))
    (setq replace-symbol-list (nreverse replace-symbol-list))
    
    (push `(:button nil "" #x50020007
            2 2 310 ,(+ 22 (* 14 number-of-input))) controls)
    (push '(:static nil "検索"      #x50020001   16 10 140 8) controls)
    (push '(:static nil "置換"      #x50020001  168 10 140 8) controls)
    (dotimes (i number-of-input)
      (if (< i 9)
          (push `(:static nil ,(format nil "&~D:" (1+ i)) #x50020002
                  7 ,(+ 22 (* 14 i)) 8 8) controls)
        (push `(:static nil ,(multiple-value-bind (dec num)
                                 (floor (1+ i) 10)
                               (format nil "~D&~D:" dec num)) #x50020002
                7 ,(+ 22 (* 14 i)) 8 8) controls))
      (push `(:static nil "⇒" #x50020000
              159 ,(+ 22 (* 14 i)) 8 8) controls)
      (push `(:combobox ,(elt search-symbol-list i) nil  #x50210842
              16 ,(+ 19 (* 14 i)) 140 96) controls)
      (push `(:combobox ,(elt replace-symbol-list i) nil #x50210842
              168 ,(+ 19 (* 14 i)) 140 96) controls))
    (push `(:button case-fold "大文字小文字を区別する(&C)" #x50010006
            39 ,(+ 30 (* 14 number-of-input)) 113 10) controls)
    (push `(:button word "単語単位で検索する(&W)" #x50010003
            39 ,(+ 43 (* 14 number-of-input)) 97 10) controls)
    (push `(:button regexp "正規表現(&E)" #x50010003
            39 ,(+ 56 (* 14 number-of-input)) 63 10) controls)
    (push `(:button escseq "エスケープシーケンスを理解しろ(&Y)" #x50010003
            39 ,(+ 69 (* 14 number-of-input)) 113 10) controls)
    (push `(:button whole "バッファの先頭から(&O)" #x50010003
            39 ,(+ 82 (* 14 number-of-input)) 89 10) controls)

    (push `(:button query "確認あり(&Q)" #x50010001
            185 ,(+ 30 (* 14 number-of-input)) 50 14) controls)
    (push `(:button all "全て置換(&A)" #x50010000
            185 ,(+ 47 (* 14 number-of-input)) 50 14) controls)
    (push `(:button apply "入力数変更(&I)" #x50010000
            185 ,(+ 64 (* 14 number-of-input)) 50 14) controls)
    (push `(:static nil "(&N)" #x50020000
            264 ,(+ 67 (* 14 number-of-input)) 10 8) controls)
    (push `(:edit resize-num nil #x50812086
            238 ,(+ 64 (* 14 number-of-input)) 26 14) controls)
    (push `(:spin resize-numspin nil #x500000b6
            254 ,(+ 64 (* 14 number-of-input)) 10 14) controls)
    (push `(:button IDCANCEL "キャンセル" #x50010000
            185 ,(+ 81 (* 14 number-of-input)) 50 14) controls)

    (push `(:static nil "設定(&T):" #x50020001
            120 ,(+ 102 (* 14 number-of-input)) 30 8) controls)
    (push `(:combobox history nil #x50210842
            150 ,(+ 100 (* 14 number-of-input)) 80 80) controls)
    (push `(:button history-save "保存"  #x50010000
            234 ,(+ 100 (* 14 number-of-input)) 24 14) controls)
    (push `(:button history-load "読込"  #x50010000
            260 ,(+ 100 (* 14 number-of-input)) 24 14) controls)
    (push `(:button history-del "削除"  #x50010000
            286 ,(+ 100 (* 14 number-of-input)) 24 14) controls)

    (setq controls (nreverse controls))

    ;; controls-initializers の生成
    (push `(case-fold . ,(cfs2dialog *multiple-replace-case-fold-search*)) controls-initializers)
    (push `(word . ,*multiple-replace-word-search*) controls-initializers)
    (push `(regexp . ,*multiple-replace-regexp-search*) controls-initializers)
    (push `(escseq . ,*multiple-replace-understand-escape-sequences*) controls-initializers)
    (push `(whole . ,*multiple-replace-replace-whole-buffer*) controls-initializers)
    (let (pattern-replacement-list)
      (if *multiple-replace-regexp-search*
          (setq pattern-replacement-list
                *last-multiple-search-replace-regexp-list*)
        (setq pattern-replacement-list
              *last-multiple-search-replace-string-list*))

      ; decode-escape-sequence 後の文字列と同値の場合は decode 前の文字列へ
      (if (equalp (cdr *last-multiple-search-replace-string-list-pair*)
                  pattern-replacement-list)
          (setq pattern-replacement-list (car *last-multiple-search-replace-string-list-pair*)))
      (dotimes (i (min number-of-input (length pattern-replacement-list)))
        (push `(,(elt search-symbol-list i) . ,(car (elt pattern-replacement-list i)))
              controls-initializers)
        (push `(,(elt replace-symbol-list i) . ,(cdr (elt pattern-replacement-list i)))
              controls-initializers))
      (dotimes (i number-of-input)
        (push `(,(elt search-symbol-list i) . ,*minibuffer-search-string-history*)
              controls-initializers)
        (push `(,(elt replace-symbol-list i) . ,*minibuffer-search-string-history*)
              controls-initializers)))
    (push `(resize-num . ,(format nil "~D" *multiple-replace-dialog-number-of-input*))
          controls-initializers)

    (push (cons 'history history-name) controls-initializers)
    (push (cons 'history history-name-list) controls-initializers)

    (setq controls-initializers (nreverse controls-initializers))

    ;; controls-handlers の生成
    (push '(word :disable (regexp)) controls-handlers)
    (push `(resize-num :min ,*multiple-replace-dialog-number-of-input-min*
                       :max 99 :range-error
                       ,(format nil "~D 以上 99 以下を指定してください"
                                *multiple-replace-dialog-number-of-input-min*)
                       :type integer :type-error "数値を入力してください")
          controls-handlers)
    (push `(resize-numspin :min ,*multiple-replace-dialog-number-of-input-min*
                           :max 99) controls-handlers)
;    (push `(,(elt search-symbol-list 0) :non-null "検索文字列を入力して"
;            :enable (query all)) controls-handlers)

    (setq controls-handlers (nreverse controls-handlers))

    ;;
    (setq dialog-template
          `(dialog 0 0 316 ,(+ 119 (* 14 number-of-input))
                   (:caption ,(let ((str "複数文字列の置換"))
                                (if (stringp history-name)
                                    (setq str (format nil "~A - [~A]" str history-name)))
                                (if (or (and (stringp history-name)
                                             (multiple-replace-setting-file-get-filename history-name))
                                        (and (not history-name)
                                             *multiple-replace-setting-file-current-setting-p*))
                                    (setq str (format nil "~A - (~A)"
                                                      str (multiple-replace-setting-file-get-filename history-name))))
                                str))
                   (:font 9 "MS UI Gothic")
                   (:control
                    ,@controls)))
    (multiple-value-bind (result data)
        (dialog-box dialog-template
                    controls-initializers
                    controls-handlers)
      (when result
        (let (pattern-replacement-list j pattern replace)
          (dotimes (i number-of-input)
            (setq j (- number-of-input 1 i))
            (setq pattern (cdr (assoc (elt search-symbol-list j) data)))
            (setq replace (cdr (assoc (elt replace-symbol-list j) data)))
            (push (cons pattern replace) pattern-replacement-list)
            (if (stringp pattern)
                (add-history pattern '*minibuffer-search-string-history*))
            (if (stringp replace)
                (add-history replace '*minibuffer-search-string-history*)))

          (setq *multiple-replace-case-fold-search* (dialog2cfs (cdr (assoc 'case-fold data))))
          (setq *multiple-replace-word-search* (cdr (assoc 'word data)))
          (setq *multiple-replace-regexp-search* (cdr (assoc 'regexp data)))
          (setq *multiple-replace-understand-escape-sequences* (cdr (assoc 'escseq data)))
          (setq *multiple-replace-replace-whole-buffer* (cdr (assoc 'whole data)))
          (setq *multiple-replace-dialog-number-of-input* (cdr (assoc 'resize-num data)))
          (if *multiple-replace-understand-escape-sequences*
              (setq *last-multiple-search-replace-string-list-pair*
                    (cons (copy-tree pattern-replacement-list)
                          (setq pattern-replacement-list
                                (mapcar #'(lambda (pattern-replacement)
                                            (cons (decode-escape-sequence
                                                   (car pattern-replacement)
                                                   *multiple-replace-regexp-search*)
                                                  (decode-escape-sequence
                                                   (cdr pattern-replacement)
                                                   *multiple-replace-regexp-search*)))
                                        pattern-replacement-list))))
            (setq *last-multiple-search-replace-string-list-pair* nil))
          ;; 履歴管理の都合上、perform-multiple-replace だけでなく、ここでも保存
          (if *multiple-replace-regexp-search*
              (setq *last-multiple-search-replace-regexp-list*
                    pattern-replacement-list)
            (setq *last-multiple-search-replace-string-list*
                  pattern-replacement-list))

          (setq *last-multiple-replace-setting* (multiple-replace-make-setting))
          (setq history-name (cdr (assoc 'history data)))
          (if *multiple-replace-setting-file-current-setting-p*
              (multiple-replace-setting-file-save *last-multiple-replace-setting* nil))

          (cond
           ;; 適用
           ((eq result 'apply)
            (multiple-replace-dialog))
           ;; 実行
           ((or (eq result 'query) (eq result 'all))
            (when (cdr (assoc (elt search-symbol-list 0) data))
              (if *multiple-replace-replace-whole-buffer*
                  (goto-char (point-min)))
              (perform-multiple-replace pattern-replacement-list (eq result 'query)
                                        (and (null *multiple-replace-word-search*)
                                             *multiple-replace-regexp-search*)
                                        t nil)))
           ;; 削除
           ((eq result 'history-del)
            (let (pos)
              (if (setq pos
                        (position history-name *multiple-replace-setting-history*
                                  :key #'(lambda (h) (multiple-replace-get-setting-item h "history-name"))
                                  :test 'equal))
                  (setq *multiple-replace-setting-history*
                        (append (subseq *multiple-replace-setting-history* 0 pos)
                                (subseq *multiple-replace-setting-history* (1+ pos))))))
            (multiple-replace-setting-file-delete history-name)
            (multiple-replace-dialog))
           ;; 保存
           ((eq result 'history-save)
            (let (pos)
              (when (string-match "^[ \t]*$" history-name)
                (setq history-name (format-date-string "%Y/%m/%d %H:%M:%S")))
              (if (setq pos
                        (position history-name *multiple-replace-setting-history*
                                  :key #'(lambda (h) (multiple-replace-get-setting-item h "history-name"))
                                  :test 'equal))
                  (setq *multiple-replace-setting-history*
                        (append (subseq *multiple-replace-setting-history* 0 pos)
                                (subseq *multiple-replace-setting-history* (1+ pos)))))
              (push (list (list (copy-string "history-name") history-name)
                          (list (copy-string "setting") *last-multiple-replace-setting*))
                    *multiple-replace-setting-history*))
            (multiple-replace-setting-file-save *last-multiple-replace-setting* history-name)
            (multiple-replace-dialog :history-name history-name))
           ;; 読込
           ((eq result 'history-load)
            (let (pos setting-with-name)
              (if (setq pos
                        (position history-name *multiple-replace-setting-history*
                                  :key #'(lambda (h) (multiple-replace-get-setting-item h "history-name"))
                                  :test 'equal))
                  (progn
                    (setq setting-with-name (nth pos *multiple-replace-setting-history*))
                    (setq *last-multiple-replace-setting* (multiple-replace-get-setting-item setting-with-name "setting"))
                    (setq *multiple-replace-setting-history*
                          (append (subseq *multiple-replace-setting-history* 0 pos)
                                  (subseq *multiple-replace-setting-history* (1+ pos))))
                    (push setting-with-name *multiple-replace-setting-history*)
                    (multiple-replace-setting-file-save *last-multiple-replace-setting* history-name)
                    (multiple-replace-dialog :history-name history-name))
                (multiple-replace-dialog :setting nil)))))
          t)))))

;; ファイルへの保存機能
(defun multiple-replace-setting-file-create-directory ()
  "multiple-replace-dialog の設定の保存先フォルダを作成する。
        t   フォルダ作成を実施
        nil フォルダ作成を未実施"
  (when (and (valid-path-p *multiple-replace-setting-file-directory*)
             (not (file-exist-p *multiple-replace-setting-file-directory*)))
    (create-directory *multiple-replace-setting-file-directory*)
    t))

(defun multiple-replace-setting-file-directory-valid-p ()
  "multiple-replace-dialog の設定の保存先フォルダの存在確認。
        t   フォルダが存在する
        nil フォルダが存在しない"
  (and (valid-path-p *multiple-replace-setting-file-directory*)
       (file-exist-p *multiple-replace-setting-file-directory*)
       (file-directory-p *multiple-replace-setting-file-directory*)))

(defun multiple-replace-setting-file-get-filename (history-name)
  "設定名に対応するファイル名を返す。"
  (when (multiple-replace-setting-file-directory-valid-p)
    (let ((filenum 1) filename)
      (cond
       ((not (stringp history-name))
        (setq filename (format nil "~8,'0d.l" 0)))
       ((setq filename (cdr (assoc history-name *multiple-replace-setting-file-alist*
                                   :test #'string=))))
       (t
        (loop
          (setq filename (format nil "~8,'0d.l" filenum))
          (unless (file-exist-p (merge-pathnames filename *multiple-replace-setting-file-directory*))
            (return))
          (incf filenum))))
      filename)))

(defun multiple-replace-setting-file-format (from to)
  (interactive "*r")
  (if (> from to) (rotatef from to))
  (save-excursion
    (lisp-mode)
    (save-restriction
      (narrow-to-region from to)
      (goto-char (point-min))
      (while (scan-buffer " *(+" :regexp t)
        (when (eq (parse-point-syntax (point)) nil)
          (unless (= (point) (point-min))
            (newline)
            (lisp-indent-line))
          (skip-chars-forward "("))))))

(defun multiple-replace-setting-file-save (setting history-name)
  "設定を保存する。"
  (when (multiple-replace-setting-file-directory-valid-p)
    (save-excursion
      (let ((temp-buffer (create-new-buffer " multiple-replace"))
            (filename (multiple-replace-setting-file-get-filename history-name))
            (setting-with-name (list (list (copy-string "history-name") history-name)
                                     (list (copy-string "setting") setting)))
            setting-string)
        (save-excursion
          (set-buffer temp-buffer)
          (insert (format nil "~S~%" setting-with-name))
          (multiple-replace-setting-file-format (point-min) (point-max))
          (setq setting-string (buffer-substring (point-min) (point-max))))
        (delete-buffer temp-buffer)
        (with-open-file (fp (merge-pathnames filename *multiple-replace-setting-file-directory*)
                            :direction :output
                            :if-exists :overwrite
                            :if-does-not-exist :create)
          (format fp "~A" setting-string))))))

(defun multiple-replace-setting-file-save-all ()
  "全ての設定をファイルに保存する。
通常実行しない関数
設定保存先フォルダ作成直後など、全設定をファイル化したい場合に実行する。"
  (when (multiple-replace-setting-file-directory-valid-p)
    (let (setting history-name)
      (if *multiple-replace-setting-file-current-setting-p*
          (multiple-replace-setting-file-save *last-multiple-replace-setting* nil))
      (dolist (setting-with-name *multiple-replace-setting-history*)
        (setq history-name (multiple-replace-get-setting-item setting-with-name "history-name"))
        (setq setting (multiple-replace-get-setting-item setting-with-name "setting"))
        (multiple-replace-setting-file-save setting history-name)))))

(defun multiple-replace-setting-file-load-all ()
  "設定ファイル全てを読み込む。
multiple-replace-dialog の処理開始時に毎回実行する。"
  (when (multiple-replace-setting-file-directory-valid-p)
    (let (setting-with-name setting history-name pos)
      (setq *multiple-replace-setting-file-alist* nil)
      (dolist (file-info (stable-sort (directory *multiple-replace-setting-file-directory*
                                                 :wild "*.l"
                                                 :file-only t
                                                 :absolute t
                                                 :file-info t)
                                      #'< :key #'caddr))
        (with-open-file (fp (car file-info) :direction :input)
          (setq setting-with-name (read fp))
          (setq history-name (multiple-replace-get-setting-item setting-with-name "history-name"))
          (setq setting (multiple-replace-get-setting-item setting-with-name "setting"))
          (cond
           ;; カレント
           ((not (stringp history-name))
            (multiple-replace-load-setting setting)
            (setq *last-multiple-replace-setting* setting))
           ;; 更新
           ((setq pos (position history-name *multiple-replace-setting-history*
                                :key #'(lambda (h) (multiple-replace-get-setting-item h "history-name"))
                                :test #'string=))
            (setf (nth pos *multiple-replace-setting-history*) setting-with-name))
           ;; 追加
           (t
            (push setting-with-name *multiple-replace-setting-history*))))
        (push (cons history-name (file-namestring (car file-info)))
              *multiple-replace-setting-file-alist*)))))

(defun multiple-replace-setting-file-delete (history-name)
  "設定ファイルを削除する。"
  (when (multiple-replace-setting-file-directory-valid-p)
    (let ((filename (multiple-replace-setting-file-get-filename history-name)))
      (when (and (stringp filename)
                 (file-exist-p (merge-pathnames filename *multiple-replace-setting-file-directory*)))
        (delete-file (merge-pathnames filename *multiple-replace-setting-file-directory*))))))

;; 各種調整
(defun multiple-replace-insert-menu-items (&key menu pre-tag position head-sep tail-sep)
  "メニューにコマンドを追加する"
  (if (and (not (menup menu)) (menup *app-menu*))
      (setq menu (get-menu *app-menu* 'ed::search)))
  (when (menup menu)
    (multiple-replace-delete-menu menu)
    (unless (or pre-tag position)
      (setq pre-tag 'ed::replace-dialog))
    (when (and pre-tag
               (setq position (get-menu-position menu pre-tag)))
      (incf position))
    (unless (and (numberp position) (integerp position) (not (minusp position))
                 (get-menu menu position t))
      (setq position -1)
      (while (get-menu menu (incf position) t)))
    (decf position)
    (if (and head-sep
             (not (minusp position))
             (get-menu menu position t))
        (insert-menu-separator menu (incf position) 'multiple-replace-dialog-sep))
    (insert-menu-item menu (incf position) 'multiple-replace-dialog
                      "複数文字列置換(&Q)..." 'multiple-replace-dialog)
    (if (and tail-sep
             (get-menu menu (incf position) t))
        (insert-menu-separator menu position 'multiple-replace-dialog-sep))))

(defun multiple-replace-delete-menu (&optional menu)
  "メニューからコマンドを削除する"
  (if (and (not (menup menu)) (menup *app-menu*))
      (setq menu (get-menu *app-menu* 'ed::search)))
  (when (menup menu)
    (while (delete-menu menu 'multiple-replace-dialog))
    (while (delete-menu menu 'multiple-replace-dialog-sep))))

(defun multiple-replace-uninstall ()
  "multiple-replace のアンインストール"
  (let ((history-variables
         '(*last-multiple-search-replace-string-list*
           *last-multiple-search-replace-regexp-list*
           *last-multiple-search-replace-string-list-pair*
           *last-multiple-replace-setting*
           *multiple-replace-setting-history*)))
    (dolist (variable history-variables)
      (unregister-history-variable variable)))
  (multiple-replace-delete-menu))

(if (menup ed::*app-menu*)
    (multiple-replace-insert-menu-items)
  (add-hook 'ed::*init-app-menus-hook*
            #'(lambda () (multiple-replace-insert-menu-items))))

;;; multiple-replace.l ends here
