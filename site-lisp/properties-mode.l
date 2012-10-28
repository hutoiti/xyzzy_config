; -*- Mode: Lisp; Package: editor -*-

#|
= properties-mode - Java の properties ファイルを編集したりする

* Author:  miyamuko ((<URL:mailto:miyamuko (at) mtb.biglobe.ne.jp>))
* URL: ((<URL:http://miyamuko.s56.xrea.com/xyzzy/properties-mode.html>))
* Version: $Id: properties-mode.l,v 1.12 2004/08/09 14:03:17 miyamuko Exp $


== 説明

Java の properties ファイルを編集するためのメジャーモードです。

* ロード時に (({native2ascii -reverse})) を勝手に実行
* 保存時に ((%native2ascii%)) を勝手に実行
* 適当なインデント
* 適当な色づけ
* 前のキーをコピーできる
* カラムの自動調整


== インストール

((<NetInstaller|URL:http://www.mirai.ne.jp/~gyo/xyzzy/ni.html>)) でインストールした場合は 3 以降を、
NetInstaller + (({ni-autoload})) を使っている人は 4 以降で OK です。

(1) アーカイブをダウンロードします。

    ((<URL:http://miyamuko.s56.xrea.com/xyzzy/archives/properties-mode.zip>))

(2) アーカイブを展開して、$XYZZY/site-lisp 配下にファイルをコピーします。

(3) 拡張子が properties のファイルを開いたときに自動的に properties-mode になるように
    ~/.xyzzy または $XYZZY/site-lisp/siteinit.l に以下のコードを追加します。

        ;; properties-mode
        (load-library "properties-mode")
        (pushnew '("\\.properties$" . properties-mode) *auto-mode-alist* :test 'equal)

(4) 設定を反映させるには xyzzy を再起動してください。

    ※siteinit.l に記述した場合には再ダンプが必要です。


== リファレンス

=== キー割り当て

: ((%TAB%))
    インデントする。

    * 継続行なら value の開始とインデントをそろえます。
    * プロパティを継続する文字がない場合、通常インデントしません。

    プロパティを複数行にわたって書く場合は次のように値の先頭をそろえるように
    インデントします。

        font = family1 family2 family3 family4 \
               - size1 size2 size3 size4 size5 \
               - bold italic underline

    key の直後で改行した場合は次のようにインデントします。
    ((({*properties-indent-level*})) が 2 の場合)

        fontLabel=\
          Font

: ((%RET%))
    改行＋インデント付け。

: ((%C-M-\%))
    前のキーをコピーする。

    連続して実行するとさかのぼってキーをコピーしてきます。

: ((%C-c n%))
    リージョンを ((%native2ascii -reverse%)) します。

: ((%C-c a%))
    リージョンを ((%native2ascii%)) します。

: ((%C-c C-a%))
    リージョンのプロパティのカラムをそろえる。

    * before

          a.b=      c
          a b
          a.b.c: d

    * after

          a.b   =     c
          a           b
          a.b.c :     d

: ((%C-c C-o%))
    リージョンのセパレータ周りの余計な空白を除去します。

    * before

          a.b  = c
          a      b

    * after

          a.b=c
          a b

: ((%C-c C-c%))
    リージョンをコメントアウトします。

: ((%C-c C-u%))
    リージョンをコメント解除します。

: ((%C-/%))
    現在行のコメント・非コメントを切り替えます。

: ((%C-c C-s C-v%))
    バッファ全体を csv に変換します。

    ((<csv-mode|URL:http://members.tripod.co.jp/ohkubo/xyzzy/#csv-mode>))
    がインストールされていて (({*properties-auto-csv-mode*})) が
    ((|non-nil|)) の場合、変換後自動的に csv-mode を実行します。

=== 変数

--- *properties-indent-level*
    継続行のインデント幅を設定します。
    デフォルト値は 2 です。

      properties.key = \
      ____properties.value

    例:

      ;; インデント幅を 4 にする
      (setq *properties-indent-level* 4)

--- *properties-n2a-buffer-name*
    native2ascii した結果のバッファ名です。

--- *properties-auto-csv-mode*
    (({properties-convert-to-csv})) を実行したときに自動的に
    csv-mode にするかどうかのフラグです。

    ((|non-nil|)) かつ csv-mode がインストールされている場合、
    自動的に csv-mode にします。

    デフォルトは t です。

--- *properties-auto-native2ascii*
    自動的に native2ascii を実行するかどうかのフラグです。

    ((|non-nil|)) なら自動的にロード時・保存時に native2ascii します。

    デフォルトは t です。


== 関連するかもしれないページ

: java.util.properties#load
    ((<URL:http://java.sun.com/j2se/1.4/ja/docs/ja/api/java/util/Properties.html#load(java.io.InputStream)>))

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
|#


(provide "properties-mode")
(in-package "editor")
(export '(*properties-mode-hook*
          *properties-mode-map*
          *properties-comment-column*
          *properties-indent-level*
          *properties-n2a-buffer-name*
          *properties-auto-csv-mode*
          *properties-auto-native2ascii*
          properties-toggle-auto-n2a
          properties-completion
          properties-adjust-property
          properties-optimize-property
          properties-comment-toggle-line
          properties-comment-region
          properties-uncomment-region
          properties-convert-to-csv
          properties-mode))

; フック
(defvar *properties-mode-hook* nil
  "properties-mode: フック変数")

; configuration
(defvar *properties-comment-column* nil
  "properties-mode: comment のなにか")
(defvar *properties-indent-level* 2
  "properties-mode: value がない場合の継続行のインデントレベル
   key = \\
   __<- hear!")
(defvar *properties-n2a-buffer-name* "*native2ascii*"
  "native2ascii するときのバッファ名")
(defvar *properties-auto-csv-mode* t
  "non-nil: properties-convert-to-csv したときに自動的に csv-mode にする。")
(defvar *properties-auto-native2ascii* t
  "non-nil: 読み込み・保存時に native2ascii 自動的する。
nil: 読み込み・保存時になにもしない。")

;; ----------------------------------------------------------------------
;; regex pattern

(defvar *properties-escaped-char-pattern*
  "\\\\\\(?:.\\|\n\\)"
  "properties-mode: escape した文字のパターン。
改行をエスケープした場合次行の行頭の空白は無視される。")

(defvar *properties-key-pattern*
  (concat "\\("
          "\\(?:" "[^#!:= \t\r\n\\]" "\\|" *properties-escaped-char-pattern* "\\)"
          "\\(?:" "[^:= \t\r\n\\]" "\\|" *properties-escaped-char-pattern* "\\)*"
          "\\)")
  "properties-mode: key のパターン, $1 = key")

(defvar *properties-separator-pattern*
  "\\([ \t]*[:=][ \t]*\\|[ \t]+\\)"
  "properties-mode: separator のパターン, $1 = separator")

(defvar *properties-value-pattern*
  (concat "\\("
          "\\(?:" "[^\r\n\\]" "\\|" *properties-escaped-char-pattern* "\\)+"
          "\\)")
  "properties-mode: value のパターン, $1 = value")

(defvar *properties-pattern*
  (concat "^[ \t]*" *properties-key-pattern*
          "\\(?:"
          *properties-separator-pattern*
          *properties-value-pattern*
          "\\)?")
  "properties-mode: key = value のパターン, $1 = key, $2 = separator, $3 = value")

;; ----------------------------------------------------------------------
;; keyword
(defvar *properties-key-color* '(:keyword 0)
  "properties-mode: key の色")

(defvar *properties-regexp-keyword-list* nil
  "properties-mode: 正規表現キーワードリスト")

(setq *properties-regexp-keyword-list*
  (compile-regexp-keyword-list
   `(
     ; 単純化のため行頭に空白があるキーは無視
     (,(concat "^" *properties-key-pattern*) t ((1 . ,*properties-key-color*)))
     )))

;; ----------------------------------------------------------------------
;; シンタックステーブル
(defvar *properties-mode-syntax-table* nil)
(unless *properties-mode-syntax-table*
  (setq *properties-mode-syntax-table* (make-syntax-table))
  (do ((x #x21 (1+ x))) ((>= x #x7f))
    (let ((c (code-char x)))
      (unless (alphanumericp c)
        (set-syntax-punctuation *properties-mode-syntax-table* c))))
  ; 以下modeに合わせて設定
  (set-syntax-escape *properties-mode-syntax-table* #\\)
  (set-syntax-start-comment *properties-mode-syntax-table* #\#)
  (set-syntax-start-comment *properties-mode-syntax-table* #\!)
  (set-syntax-end-comment *properties-mode-syntax-table* #\LFD))

; キーマップ
(defvar *properties-mode-map* nil)
(unless *properties-mode-map*
  (setq *properties-mode-map* (make-sparse-keymap))
  ; 以下キー割当
  (define-key *properties-mode-map* #\C-h 'backward-delete-char-untabify-or-selection)
  (define-key *properties-mode-map* #\TAB 'properties-indent-line)
  (define-key *properties-mode-map* #\C-M-q 'indent-sexp)
  (define-key *properties-mode-map* #\C-M-\, 'properties-copy-key)
  (define-key *properties-mode-map* #\RET 'properties-newline-and-indent)
  (define-key *properties-mode-map* '(#\C-c #\n) 'properties-ascii-to-native-region)
  (define-key *properties-mode-map* '(#\C-c #\a) 'properties-native-to-ascii-region)
  (define-key *properties-mode-map* '(#\C-c #\C-a) 'properties-adjust-property)
  (define-key *properties-mode-map* '(#\C-c #\C-o) 'properties-optimize-property)
  (define-key *properties-mode-map* '(#\C-c #\C-c) 'properties-comment-region)
  (define-key *properties-mode-map* '(#\C-c #\C-u) 'properties-uncomment-region)
  (define-key *properties-mode-map* '(#\C-c #\C-s #\C-v) 'properties-convert-to-csv)
  (define-key *properties-mode-map* '(#\C-/) 'properties-comment-toggle-line)
  )

;; ----------------------------------------------------------------------
;; 読み込み時、ロード時に narive2ascii を実行する
(defvar *properties-n2a-buffer* nil)
(defun properties-ascii-to-native-region (start end)
  (interactive "*r")
  (filter-region "native2ascii.exe -reverse" start end))

(defun properties-native-to-ascii-region (start end)
  (interactive "*r")
  (filter-region "native2ascii.exe" start end))

(defun properties-contain-multibyte-char-p ()
  "コメント以外にマルチバイト文字が含まれていれば t"
  (save-excursion
    (beginning-of-buffer)
    (while (scan-buffer "[^\x00-\x7f]" :regexp t :tail t)
      (unless (eq (parse-point-syntax) :comment)
        (return-from properties-contain-multibyte-char-p t)))
    nil))

(defun properties-contain-unicode-char-p ()
  "Unicode 文字(\uxxxx) が含まれていれば t"
  (save-excursion
    (beginning-of-buffer)
    (scan-buffer "\\u[a-fA-F0-9]\\{4\\}" :regexp t)))

(defun properties-on-load ()
  "ファイル読み込み時に呼び出す。
   マルチバイト文字が含まれていない場合に ascii2native してバッファの更新時刻を修正する"
  (when (and (not (properties-contain-multibyte-char-p))
             (properties-contain-unicode-char-p)
             *properties-auto-native2ascii*)
    (message "ascii2native")
    (properties-ascii-to-native-region (point-min) (point-max))
    (update-visited-file-modtime)
    (set-buffer-modified-p nil)))

(defun properties-save-buffer ()
  "native2ascii して保存する"
  (interactive "*")
  (if (or (not (properties-contain-multibyte-char-p))
          (not *properties-auto-native2ascii*))
      (return-from properties-save-buffer nil))

  (let ((current-buffer (selected-buffer))
        (content (properties-get-buffer-content))
        (filename (get-buffer-file-name)))

    (set-buffer (properties-n2a-buffer))
    (properties-set-buffer-content content)
    (properties-native-to-ascii-region (point-min) (point-max))

    (write-file filename)

    (set-buffer current-buffer)
    (update-visited-file-modtime)
    (set-buffer-modified-p nil)
    t))

(defun properties-set-buffer-content (content)
  "current buffer の内容を置き換える"
  (save-restriction
    (widen)
    (erase-buffer (selected-buffer))
    (insert content)))

(defun properties-get-buffer-content ()
  "current buffer の全内容を取得する"
  (save-restriction
    (widen)
    (buffer-substring (point-min) (point-max))))

(defun properties-n2a-buffer ()
  "properties-mode: n2a バッファの取得"
  (unless (and *properties-n2a-buffer*
               (find-buffer *properties-n2a-buffer-name*))
    (when (setq *properties-n2a-buffer*
                (switch-to-buffer *properties-n2a-buffer-name*))
      (make-local-variable 'kept-undo-information)
      (setq kept-undo-information nil)
      (make-local-variable 'need-not-save)
      (setq need-not-save t)))
  *properties-n2a-buffer*)

(defun properties-toggle-auto-n2a ()
  (interactive)
  (setf *properties-auto-native2ascii*
        (not *properties-auto-native2ascii*))
  (message "auto native2ascii: ~A" *properties-auto-native2ascii*))

;; ----------------------------------------------------------------------
;; 前のキーをコピーする
;;   連続してコマンドを実行した場合さかのぼってコピーする
(defvar-local *properties-copy-last-line* nil)
(defvar-local *properties-copy-dst-point* nil)
(defun properties-copy-key ()
  "properties-mode: 前のキーをコピーする"
  (interactive "*")
  (let ((key nil))
    (save-excursion
      (cond
       ;; このコマンド連続して実行している
       ((and (eq *last-command* 'properties-copy-key)
             (integerp *properties-copy-last-line*))
        (goto-line *properties-copy-last-line*)
        (clear-undo-boundary))

       ;; 初回実行
       (t
        (setf *properties-copy-dst-point* (point))))

      (when (and (properties-previous-line)
                 (scan-buffer *properties-pattern* :regexp t))
        (setf key (match-string 1))
        (setf *properties-copy-last-line* (current-line-number))))

    (unless key
      (message "もうないです。")
      (return-from properties-copy-key))

    (delete-region *properties-copy-dst-point* (point))
    (insert key)))

;; ----------------------------------------------------------------------
;; リージョンのプロパティのカラムをそろえる

(defun properties-adjust-property (start end)
  (interactive "*r")
  (if (< end start) (rotatef start end))

  (let ((key-width 0) (sep-width 0)
        (key nil) (sep nil) (value nil))
    (save-excursion
      (save-restriction
        (narrow-to-region start end)

        ;; インデントしておく
        (indent-region start end)

        ;; 最長のカラムを取得
        ;;   key  =  value
        ;;   <--->    : key-width
        ;;        <-> : sep-width
        (goto-char (point-min))
        (while (scan-buffer *properties-pattern* :regexp t :tail t)
          (setf key (match-string 1))
          (setf sep (match-string 2))
          (setf value (match-string 3))

          (when (and key sep)
            (when (<= key-width (+ (length key) (or (string-match "[:=]" sep) 0)))
              (setf key-width (+ (length key) (or (string-match "[:=]" sep) 0)))
              (if (string-match "^[:=]" sep) (incf key-width))))
          (when (and sep value)
            (when (<= sep-width (- (length sep) (or (string-match "[:=]" sep) (length sep))))
              (setf sep-width (- (length sep) (or (string-match "[:=]" sep) (length sep))))
              (if (string-match "[:=]$" sep) (incf sep-width))))
          )

        ;; セパレータが空白文字のみの場合は sep-width が 0 なので 1 を設定
        (if (zerop sep-width) (setf sep-width 1))

        ;; で、それにあわせる
        (goto-char (point-min))
        (while (scan-buffer *properties-pattern* :regexp t :tail t)
          (setf key (match-string 1))
          (setf sep (string-trim " \t\r\f\n" (match-string 2)))
          (setf value (match-string 3))

          (when (and key sep value)
            (delete-region (match-beginning 0) (match-end 0))
            (insert (format nil
                            (format nil "~~~D@A~~~D@A~~A" key-width sep-width)
                            key sep value))))

        ;; インデントしておく
        (indent-region (point-min) (point-max))
        ))))

;; ----------------------------------------------------------------------
;; リージョンのセパレータ周りの空白を削除

(defun properties-optimize-property (start end)
  (interactive "*r")
  (if (< end start) (rotatef start end))

  (save-excursion
    (save-restriction
      (narrow-to-region start end)

      (goto-char (point-min))
      (while (scan-buffer *properties-pattern* :regexp t :tail t)
        (let ((key (match-string 1))
              (sep (match-string 2))
              (val (match-string 3)))
          (when (and key sep)
            (delete-region (match-beginning 0) (match-end 0))
            (insert (format nil "~A~A~A"
                            key
                            (funcall #'(lambda (str) (if (equal str "") " " str))
                                     (string-trim " \t\r\f\n" sep))
                            (or val "")))))))
    ;; インデントしておく
    (indent-region start end)
    ))

;; ----------------------------------------------------------------------
;; マーク行から現在行までを csv に変換
(defvar *properties-buffer-convert* "*Properties Convert*")
(defun properties-convert-to-csv ()
  (interactive)

  (let ((in-buffer (selected-buffer)))
    (save-excursion
      (with-output-to-temp-buffer (*properties-buffer-convert*)
        (set-buffer in-buffer)
        (goto-char (point-min))
        (while (scan-buffer *properties-pattern* :regexp t :tail t)
          (let ((key (match-string 1))
                (val (match-string 3)))
            (when (and key val)
              (format t "~A,~A~%"
                      (properties-escape-csv (properties-unescape-property key))
                      (properties-escape-csv (properties-unescape-property val))))
            ))
        ))

    ;; csv-mode にする
    (when (and *properties-auto-csv-mode*
               (find-load-path "csv-mode"))
      (set-buffer *properties-buffer-convert*)
      (require "csv-mode")
      (csv-mode))))

;; \ " '  ! # : = はエスケープして書き込まれている。
;; CR LF TAB もエスケープされるけどこれは元に戻さない。
(defun properties-unescape-property (str)
  (setf str (substitute-string str "\\\\\n[ \t]*" ""))
  (setf str (string-trim "[ \t\r\f\n]" str))
  (setf str (substitute-string str "\\\\\\([\"\\' !#:=]\\)" "\\1")))

(defun properties-escape-csv (str)
  (setf str (substitute-string str "\"" "\"\""))
  (if (string-match "[\n\r\",]" str)
      (concat "\"" str "\"")
    str))

;; ----------------------------------------------------------------------
;; 行のコメントをトグル

(defun properties-comment-toggle-line ()
  "properties-mode: 行のコメントをトグル"
  (interactive "*")
  (save-excursion
    (let ((start (progn (goto-bol) (point)))
          (end (progn (goto-eol) (point))))
      (if (properties-comment-line)
          (properties-uncomment-region start end)
        (properties-comment-region start end)))))

;; ----------------------------------------------------------------------
;; リージョンをコメントアウト

(defun properties-comment-region (start end)
  "properties-mode: リージョンをコメント"
  (interactive "*r")
  (if (< end start) (rotatef start end))

  (save-excursion
    (save-restriction
      (narrow-to-region (progn (goto-char end) (goto-eol) (point))
                        (progn (goto-char start) (goto-bol) (point)))
      (loop
        (goto-bol)
        (insert comment-start)
        (goto-eol)
        (insert comment-end)
        (unless (forward-line 1) (return)))
      )))

;; ----------------------------------------------------------------------
;; リージョンをコメント解除

(defun properties-uncomment-region (start end)
  "properties-mode: リージョンをコメント"
  (interactive "*r")
  (if (< end start) (rotatef start end))

  (save-excursion
    (save-restriction
      (narrow-to-region (progn (goto-char end) (goto-eol) (point))
                        (progn (goto-char start) (goto-bol) (point)))
      (loop
        (goto-bol)
        (if (scan-buffer comment-start :regexp t)
            (delete-region (match-beginning 0) (match-end 0)))
        (goto-eol)
        (if (scan-buffer comment-end :regexp t :reverse t)
            (delete-region (match-beginning 0) (match-end 0)))
        (unless (forward-line 1) (return)))
      )))

;; ----------------------------------------------------------------------

(defun properties-electric-insert (&optional (arg 1))
  (interactive "*p")
  (self-insert-command arg)
  (properties-indent-line))

(defun properties-newline-and-indent (&optional (arg 1))
  (interactive "*p")
  (insert #\LFD arg)
  (properties-indent-line))

;; indent
(defun properties-indent-line ()
  (interactive "*")
  (let ((column (calc-properties-indent)))
    (when (integerp column)
      (smart-indentation column)))
  t)

(defun properties-continued-line ()
  "継続行かどうか"
  (save-excursion
    (if (not (forward-line -1))
        (return-from properties-continued-line nil))
    (let ((limit (progn (goto-eol) (point))))
      (goto-bol)
      (and (scan-buffer "\\(\\\\+\\)[ \t]*$" :regexp t :limit limit)
           (oddp (length (match-string 1)))))))

(defun properties-previous-line ()
  "前の行まで戻る"
  (while (forward-line -1)
    (unless (or (properties-space-line)
                (properties-comment-line)
                (properties-continued-line))
      (return-from properties-previous-line t))))

(defun properties-space-line ()
  "空行かどうか"
  (save-excursion
    (goto-bol)
    (and (not (properties-continued-line))
         (looking-at "[ \t]*$"))))

(defun properties-comment-line ()
  "コメント行かどうか"
  (save-excursion
    (goto-bol)
    (looking-at "^[ \t]*[#!]")))

(defun calc-properties-indent ()
  "インデントする数を数える"
  (let ((column 0)
        (continued-line-p (properties-continued-line)))
    (save-excursion
      ; 前の行を調べる
      (when (properties-previous-line)
        (goto-bol)
        (when continued-line-p
          ;; 前の行の value のインデント
          (scan-buffer (concat "^[ \t]*"
                               *properties-key-pattern*
                               "\\(" *properties-separator-pattern* "\\)?")
                       :regexp t :tail t)
          ;; value がなかったら *properties-indent-level*
          (if (looking-at "\\\\$")
              (incf column *properties-indent-level*)
            (setf column (current-column)))
          )))
    column
    ))

;; ----------------------------------------------------------------------
;; key の一覧: list-function で表示される
(defun properties-build-summary-of-functions ()
  (let ((result nil))
    (save-excursion
      (goto-char (point-min))
      (while (scan-buffer *properties-pattern* :regexp t :tail t)
        (push (list (current-line-number) (match-string 1)) result)))
    (nreverse result)
    ))

; modeの実行
(defun properties-mode ()
  "properties-mode"
  (interactive)
  (kill-all-local-variables)
  (setq mode-name "Properties")
  (setq buffer-mode 'properties-mode)
  (use-syntax-table *properties-mode-syntax-table*)
  (use-keymap *properties-mode-map*)

  (make-local-variable 'paragraph-start)
  (setq paragraph-start "^$\\|\f")
  (make-local-variable 'paragraph-separate)
  (setq paragraph-separate paragraph-start)

  ; indent
  (make-local-variable 'mode-specific-indent-command)
  (setq mode-specific-indent-command 'properties-indent-line)
  (make-local-variable 'mode-newline-and-indent-command)
  (setq mode-newline-and-indent-command 'properties-newline-and-indent)

  ; list of key
  (make-local-variable 'build-summary-function)
  (setf build-summary-function 'properties-build-summary-of-functions)

  ; keyword
  (make-local-variable 'regexp-keyword-list)
  (setq regexp-keyword-list *properties-regexp-keyword-list*)

  ; comment
  (setq comment-start "# " comment-end "")
  (setq comment-start-skip "[#!]+[ \t]*")
  (setq comment-indent-function 'calc-properties-indent)
  (when *properties-comment-column*
    (setq comment-column *properties-comment-column*))

  (make-variable-buffer-local '*before-save-buffer-hook*)
  (add-hook '*before-save-buffer-hook*
            #'properties-save-buffer)

  ; ascii2native する
  (properties-on-load)

  ; フックの実行
  (run-hooks '*properties-mode-hook*))
