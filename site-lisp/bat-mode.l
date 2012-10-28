;;; -*- Mode: Lisp; Package: EDITOR -*-
;;; bat-mode.l --- Simple mode for Windows BAT files

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Version: 0.0.0.4
;; Time-stamp: <2005/10/08 14:17:36 +0900>

;;; Commentary:

;; Description:
;;
;;  バッチファイル編集モード
;;

;; Installation:
;;
;;      1. アーカイブを展開して bat-mode.l を $XYZZY/site-lisp に
;;         コピーします。
;;
;;      2. バイトコンパイルします。
;;
;;              M-x byte-compile-file
;;              Byte compile file: $XYZZY/site-lisp/bat-mode.l
;;
;;      3. *.bat を読みこんだときに自動的に bat-mode に
;;         するために、以下のコードを追加します。
;;
;;        ■ .xyzzyに追加する場合
;;              (export 'ed::bat-mode "ed")
;;              (autoload 'bat-mode "bat-mode" t)
;;              (pushnew '("\\.bat$" . bat-mode) *auto-mode-alist* :test 'equal)
;;
;;        ■ siteinit.lに追加する場合
;;              (in-package "editor")
;;              (export 'bat-mode)
;;              (autoload 'bat-mode "bat-mode" t)
;;              (pushnew '("\\.bat$" . bat-mode) *auto-mode-alist* :test 'equal)
;;              (in-package "user")
;;
;;      4. 上記の設定を反映させるために、xyzzy を再起動します。
;;         siteinit.l に記述した場合は Ctrl キーと Shift キーを押しながら
;;         xyzzy を再起動し、ダンプファイルを再構築します。
;;

;; Uninstallation:
;;
;;      1. bat-mode.l に関する記述を削除します。
;;
;;      2. siteinit.l に記述していた場合は Ctrl キーと Shift キーを押し
;;         ながら xyzzy を再起動し、ダンプファイルを再構築します。
;;

;; Key bind:
;;
;;      RET     改行＋インデント付け
;;      TAB     インデント付け
;;      C-;     現在行のコメントをトグル
;;      M-;     indent-for-comment
;;

;; Changes:
;;
;;      [Version 0.0.0.4]
;;      Sat, 08 Oct 2005 14:15:37 +0900
;;        ・HIE さんに 2002/10/17 に教えていただいていた typo の修正漏れを
;;          修正。
;;        ・メールアドレスを変更。
;;        ・ライセンス条項(修正BSDライセンス)を記載。
;;
;;      [Version 0.0.0.3]
;;      Sun, 13 Jun 2004 00:11:30 +0900
;;        ・HIE さんに 2002/10/17 に教えていただいていた typo 修正。
;;        ・NetInstaller 対応。
;;
;;      [Version 0.0.0.2]
;;      Wed, 12 Dec 2001 15:53:35 +0900
;;        ・ほとんど別物に。
;;
;;      [Version 0.0.0.1]
;;      Sat, 04 Aug 2001 02:11:45 +0900
;;        ・作法がわからないので力まかせでとりあえず初版をつくってみた。
;;

;; Todo:
;;
;;  ・%....% の環境変数を補完できるように
;;      ・">", "<", "<<", "|" 等
;;      ・PRN, AUX, NUL, CON 等
;;      ・GOTO からラベルに飛んだり戻ったり
;;      ・特殊な環境変数 COMSPEC, PATH, PROMPT, TEMP, DOSDIR, DIRCMD 等
;;      ・めっさ適当な BAT ファイル文法の確認
;;      ・適当に作ったので「FOR の変数」「ERRORLEVEL の数字」に環境変数とか
;;        書くと変になるはず

;; Memo:
;;
;;      表示抑止    ::= @
;;      ラベルA     ::= :ラベルB
;;      引数        ::= %0 ～ %9
;;      環境変数    ::= %環境変数名%
;;      変数        ::= %%文字 （１文字）
;;      コメント    ::= REM
;;      セパレータA ::= [ \t]
;;      セパレータB ::= [ \t]+
;;      インデント  ::= ^[ \t]*
;;
;;
;;      繰り返し    ::= FOR %%変数 IN (セット) DO コマンド [パラメータ]
;;      条件分岐    ::= IF [NOT] 条件 コマンド [パラメータ]
;;
;;      条件        ::= ERRORLEVEL 数値 | 文字列 == 文字列 | EXIST ファイル名
;;
;;      数値        ::= [1-9][0-9]+
;;      文字列      ::=
;;      メッセージ  ::= 任意文字列
;;      コメント    ::= 任意文字列
;;      任意文字列  ::= .*
;;
;;                  ::= CALL バッチファイル名
;;                  ::= ECHO | ECHO OFF | ECHO ON | ECHO 任意文字列 | ECHO.
;;                  ::= GOTO ラベルB
;;                  ::= SHIFT メッセージ
;;                  ::= PAUSE メッセージ
;;

;; Licence:
;;
;;    bat-mode は修正BSDライセンスに基づいて利用可能です。
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

(provide "bat-mode")

(in-package "editor")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (export '(*bat-mode-hook*
            *bat-mode-map*
            *bat-version*
            *bat-keyword-file*
            *bat-keyword-file-use*
            *bat-regexp-keyword-list*
            *bat-mode-comment-start*
            *bat-comment-column*
            *bat-mode-abbrev-table*)))
(eval-when (:compile-toplevel :load-toplevel :execute)
  (export '(bat-mode
            bat-indent-line
            bat-newline-and-indent
            bat-comment-toggle-line)))

(defconstant *bat-version* "0.0.0.4"
  "bat-mode: Version")

(defvar *bat-keyword-file-use* nil
  "bat-mode: キーワードファイルを使用")

;; 色設定
; コメント
(defvar *bat-comment-color* '(:keyword :comment))
; ラベル
(defvar *bat-lavel-color* '(:color 0 1 :underline))
; コマンド (GOTO IF FOR ECHO SET PATH PROMPT CALL PAUSE SHIFT)
(defvar *bat-command-color* '(:keyword 0))
; GOTO のラベル
(defvar *bat-goto-label-color* '(:color 1 0 :underline))
; エコー抑止
(defvar *bat-echo-stop-color* '(:keyword 1))
; 文字列
(defvar *bat-string-color* '(:keyword :string :underline))
; IF 構文 (NOT ERRORLEVEL EXIST)
(defvar *bat-if-syntax-color* '(:keyword 2))
; FOR 構文 (IN DO)
(defvar *bat-for-syntax-color* '(:keyword 2))
; ループ変数
(defvar *bat-loop-variable-color* '(:keyword 2))
; 引数
(defvar *bat-argument-color* '(:keyword 2))
; 変数
(defvar *bat-variable-color* '(:color 0 3))
; 変数参照
(defvar *bat-variable-reference-color* '(:keyword 2))


;;; ----------------------------------------
(defvar *bat-mode-hook* nil
  "bat-mode: Mode hook")

(defvar *bat-keyword-file* "BAT"
  "bat-mode: キーワードファイル")

(defvar *bat-mode-comment-start* "REM "
  "bat-mode: Commnet string")

(defvar *bat-comment-column* 0
  "bat-mode: Comment column")

; キーマップの設定
(defvar *bat-mode-map* nil
  "bat-mode: Local keymap")
(unless *bat-mode-map*
  (setq *bat-mode-map* (make-sparse-keymap))
  (define-key *bat-mode-map* #\TAB      'bat-indent-line)
  (define-key *bat-mode-map* #\RET      'bat-newline-and-indent)
  (define-key *bat-mode-map* #\C-\;     'bat-comment-toggle-line)
  )

(defvar *bat-mode-abbrev-table* nil)
(unless *bat-mode-abbrev-table*
  (define-abbrev-table '*bat-mode-abbrev-table*))

;; Make underscores count as words
(defvar *bat-mode-syntax-table* nil
  "bat-mode: Syntax table")
(unless *bat-mode-syntax-table*
  (setq *bat-mode-syntax-table* (make-syntax-table))
;  (set-syntax-string *bat-mode-syntax-table* #\")
;  (set-syntax-string *bat-mode-syntax-table* #\')
;  (set-syntax-end-comment *bat-mode-syntax-table* #\LFD nil t)
  )
  
(defvar *bat-keyword-hash-table* nil
  "bat-mode: キーワードハッシュテーブル")

(defvar *bat-regexp-keyword-list*
  nil
  "bat-mode: 正規表現キーワードリスト")
  
(setq *bat-regexp-keyword-list*
  (compile-regexp-keyword-list
   `(
     ;; ラベル行
     ("^[ \t]*:.+" t ((0 . ,*bat-lavel-color*)))
     ;; エコー抑止
     ("^[ \t]*\\(@\\)" t ((1 . ,*bat-echo-stop-color*)))
     ; コメント
     (,(concat "\\<\\(REM\\)\\>"
           "\\(?:[ \t]\\(.*\\)\\)?") t ((0 . ,*bat-comment-color*)))
     ; IF
     ("\\<IF\\>" t ((0 . ,*bat-command-color*)))
     ("\\<\\(?:NOT\\|ERRORLEVEL\\|EXIST\\)\\>" t ((0 . ,*bat-if-syntax-color*)))
     ; FOR
     ("\\<FOR\\>" t ((0 . ,*bat-command-color*)))
     ("\\<\\(?:IN\\|DO\\)\\>" t ((0 . ,*bat-for-syntax-color*)))
     ; GOTO
     (,(concat "\\<\\(GOTO\\)\\>"
               "\\(?:[ \t]\\(.*\\)\\)?") t ((1 . ,*bat-command-color*)
                                            (2 . ,*bat-goto-label-color*)))
     ; ECHO
     ("\\<\\(ECHO\\)[ \t]+\\(ON\\|OFF\\)[ \t]*$" t ((0 . ,*bat-command-color*)))
     (,(concat "\\<\\(ECHO\\.?\\)\\>"
               "\\(?:[ \t]\\(.*\\)\\)?") t ((1 . ,*bat-command-color*)
                                            (2 . ,*bat-string-color*)))
     ; SET
     ("\\<\\(SET\\)\\(?:[ \t]+\\([^=\n]+\\)\\(?:=\\(.*\\)\\)?\\)?"
      t ((1 . ,*bat-command-color*)
         (2 . ,*bat-variable-color*)
         (3 . ,*bat-string-color*)))
     ;; コマンド = 文字列
     ; [PATH] [PROMPT]
     (,(concat "\\<"
               "\\(PATH"
               "\\|PROMPT"
               "\\)\\>"
               "\\(?:[ \t]*=[ \t]*\\(.*\\)\\)")
      t ((1 . ,*bat-command-color*)
         (2 . ,*bat-string-color*)))
     ;; コマンド 文字列
     (,(concat "\\<"
               "\\(PATH"
               "\\|PROMPT"
               "\\|CALL"
               "\\|PAUSE"
               "\\|SHIFT"
               "\\)\\>"
               "\\(?:[ \t]+\\(.*\\)\\)?")
      t ((1 . ,*bat-command-color*)
         (2 . ,*bat-string-color*)))

     ;; コマンド
     ("\\<\\(CHOICE\\)\\>" t ((0 . ,*bat-command-color*)))
     
     ; 引数
     ("%[0-9]" nil ,*bat-argument-color*)
     ; ループ変数
     ("%%[a-zA-Z]" nil ,*bat-loop-variable-color*)
     ; 変数
     ("%[a-zA-Z][a-zA-Z0-9_]*%" nil ,*bat-variable-reference-color*)

     )))

;; モードの設定
(defun bat-mode ()
  (interactive)
  "Mode for DOS and Windows BAT files"
  (kill-all-local-variables)
  (setq buffer-mode 'bat-mode)
  (setq mode-name "Bat")
  (use-keymap *bat-mode-map*)
  (use-syntax-table *bat-mode-syntax-table*)

  (make-local-variable 'mode-specific-indent-command)
  (setq mode-specific-indent-command 'bat-indent-line)
  (setq comment-indent-function 'bat-comment-indent)

  (cond
   (*bat-keyword-file-use*
    (and *bat-keyword-file*
         (null *bat-keyword-hash-table*)
         (setq *bat-keyword-hash-table*
               (load-keyword-file *bat-keyword-file* t)))
    (when *bat-keyword-hash-table*
      (make-local-variable 'keyword-hash-table)
      (setq keyword-hash-table *bat-keyword-hash-table*)))
   (t
    (make-local-variable 'keyword-hash-table)
    (setq keyword-hash-table '())))

  (make-local-variable 'regexp-keyword-list)
  (setq regexp-keyword-list *bat-regexp-keyword-list*)
  
  (setq *local-abbrev-table* *bat-mode-abbrev-table*)
  (setq comment-start *bat-mode-comment-start*
        comment-end "")
  (setq comment-start-skip "[ \t]*[rR][eE][mM][ \t]*")
  (when *bat-comment-column*
    (setq comment-column *bat-comment-column*))
  (run-hooks '*bat-mode-hook*))


; ------------------------------
; 行のコメントをトグル
(defun bat-comment-toggle-line ()
  "bat-mode: 行のコメントをトグル"
  (interactive "*")
  (save-excursion
    (let (bol eol)
      (goto-eol)
      (setq eol (point))
      (goto-bol)
      (setq bol (point))
      (if (string-match "^[ \t]*[rR][eE][mM]\\(?:[ \t]*$\\|[ \t]\\)"
                        (buffer-substring bol eol))
          (delete-region (+ bol (match-beginning 0)) (+ bol (match-end 0)))
        (insert *bat-mode-comment-start*)))))

; ------------------------------
; 改行＋インデント
(defun bat-newline-and-indent (&optional (arg 1))
  "bat-mode: 改行＋インデント付け"
  (interactive "*p")
  (insert #\LFD arg)
  (bat-indent-line))

; ------------------------------
; 現在の行のインデント付け
(defun bat-indent-line ()
  "bat-mode: インデント付け"
  (interactive "*")
  (if (save-excursion
        (skip-chars-backward " \t")
        (bolp))
      (let ((column 0))
        (save-excursion
          (while (forward-line -1)
            (unless (progn
                      (skip-chars-forward " \t")
                      (eolp))
              (skip-chars-forward " \t")
              (setq column (current-column))
              (return))))
        (smart-indentation column)
        (skip-chars-forward " \t"))
    (insert "\t")))

; ------------------------------
; コメントインデント
(defun bat-comment-indent ()
  (if (and (bolp) (not (eolp)))
      0
    (save-excursion
      (skip-chars-backward " \t")
      (max (if (bolp)
               0
             (1+ (current-column)))
           comment-column))))

;;; bat-mode.l ends here
