;;; -*- Mode: Lisp; Package: EDITOR -*-
;;; pickup-pattern.l

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Version: 0.0.0.6
;; Time-stamp: <2005/10/08 12:11:46 +0900>

;;; Commentary:

;; Description:
;;
;;  検索文字列/指定したパターンを強調表示します。
;;  選択パターン/全パターンの強調表示の解除、再描画が可能です。
;;

;; Installation:
;;
;;      1. アーカイブを展開して pickup-pattern.l を $XYZZY/site-lisp に
;;         コピーします。
;;
;;      2. バイトコンパイルします。
;;
;;              M-x byte-compile-file
;;              Byte compile file: $XYZZY/site-lisp/pickup-pattern.l
;;
;;      3. ~/.xyzzy または $XYZZY/site-lisp/siteinit.l に以下のコードを
;;         追加します。
;;
;;              (require "pickup-pattern")
;;
;;      4. 必要ならばキーバインド等の設定のコードを追加します。
;;
;;          例：
;;          (global-set-key '(#\C-c #\p #\s) 'pickup-pattern-set-input)
;;          (global-set-key '(#\C-c #\p #\C-s) 'pickup-pattern-set-input-detail)
;;          (global-set-key '(#\C-c #\p #\r) 'pickup-pattern-refresh-select)
;;          (global-set-key '(#\C-c #\p #\C-r) 'pickup-pattern-refresh-all)
;;          (global-set-key '(#\C-c #\p #\u) 'pickup-pattern-unset-select)
;;          (global-set-key '(#\C-c #\p #\C-u) 'pickup-pattern-unset-all)
;;          (global-set-key '(#\C-c #\p #\d) 'pickup-pattern-delete-select)
;;          (global-set-key '(#\C-c #\p #\C-d) 'pickup-pattern-delete-all)
;;          (global-set-key '(#\C-c #\p #\l) 'pickup-pattern-list-show)
;;          (global-set-key #\M-s 're-search-forward-pickup)
;;          (global-set-key #\M-C-s 're-search-backward-pickup)
;;          (setq *pickup-pattern-fg* 1)
;;          (setq *pickup-pattern-bg* 3)
;;          (setq *pickup-pattern-bold* t)
;;          (setq *pickup-pattern-underline* nil)
;;          (setq *pickup-pattern-strike-out* nil)
;;          (setq *pickup-pattern-regexp* t)
;;          (setq *pickup-pattern-overlap* nil)
;;          (setq *pickup-pattern-pre-search-unset* t)
;;          (setq *pickup-pattern-search-pattern-add* nil)
;;
;;      5. 上記の設定を反映させるために、xyzzy を再起動します。
;;         siteinit.l に記述した場合は Ctrl キーと Shift キーを押しながら
;;         xyzzy を再起動し、ダンプファイルを再構築します。
;;

;; Uninstallation:
;;
;;      1. ESC ESC (ed::pickup-pattern-uninstall) とタイプし、
;;         pickup-pattern.l 関連の情報を xyzzy から削除します。
;;
;;      2. pickup-pattern.l に関する記述を削除します。
;;
;;      3. siteinit.l に記述していた場合は Ctrl キーと Shift キーを押し
;;         ながら xyzzy を再起動し、ダンプファイルを再構築します。
;;

;; Changes:
;;
;;      [Version 0.0.0.6]
;;      Sat, 08 Oct 2005 12:10:51 +0900
;;        ・メールアドレスを変更。
;;        ・ライセンス条項(修正BSDライセンス)を記載。
;;
;;      [Version 0.0.0.5]
;;      Mon, 14 Jun 2004 01:10:48 +0900
;;        ・*pickup-pattern-list* を history 変数に変更。
;;        ・pickup-pattern-uninstall 追加。
;;        ・NetInstaller 対応。
;;
;;      Tue, 19 Feb 2002 12:07:12 +0900
;;        ・コメントを修正。
;;
;;      [Version 0.0.0.4]
;;      Thu, 06 Dec 2001 11:42:14 +0900
;;        ・"前景色" と書いていたところを "文字色" に変更。
;;        ・pickup-pattern-set-input-detail で未入力、または不正な入力
;;          の場合 pickup-pattern のデフォルト設定に従っていたのを
;;          nil に変更。
;;
;;      Thu, 22 Nov 2001 19:13:20 +0900
;;        ・ML で亀井さんに教えてもらったとおりにして
;;          (define-history-variable) 問題修正。
;;
;;      [Version 0.0.0.3]
;;      Mon, 19 Nov 2001 23:03:13 +0900
;;        ・byte-compile してもまともに動くように。
;;        ・*pickup-pattern-set-hook*, *pickup-pattern-unset-all-hook* 追加。
;;        ・検索文字列をリストに追加するかどうかの
;;          *pickup-pattern-search-pattern-add* を追加。
;;        ・editor::*show-match-hook* に引っかけて使う
;;          pickup-pattern-last-search を追加。
;;        ・pickup-pattern-list-show 追加。
;;        ・document の typo 修正。
;;        ・いろいろと変更。
;;
;;      [Version 0.0.0.2]
;;      Fri, 16 Nov 2001 18:01:23 +0900
;;        ・defstruct を使ったら、やっぱりバイトコンパイルすると動かない。
;;          macro への理解が足りない。いったいどうすれば。
;;        ・なんとなく *pickup-pattern-list* を export するのをやめた。
;;        ・デフォルトの配色などの設定を変えた。
;;        ・pickup-pattern-set-input-detail の追加。
;;        ・pickup-pattern-delete-all で問い合わせるように。
;;
;;      Fri, 16 Nov 2001 14:01:30 +0900
;;        ・正規表現で pickup するパターンがグループ化されていたら、
;;          一番目のグループにマッチした文字列のみ pickup するように変更。
;;
;;      [Version 0.0.0.1]
;;      Tue, 13 Nov 2001 23:10:02 +0900
;;        ・変数、関数にドキュメントの追加。
;;        ・editor package に入れた。
;;        ・pickup-string を pickup-pattern に置換。
;;          Changes の該当個所も置換。
;;
;;      Tue, 13 Nov 2001 08:33:43 +0900
;;        ・検索時に *case-fold-search* を反映するように。
;;        ・*pickup-pattern-overlap* の追加。
;;        ・re-search-forward-pickup, re-search-backward-pickup の追加。
;;
;;      Fri, 09 Nov 2001 18:30:06 +0900
;;        ・search-forward, re-search-forward 等と同じ history を
;;          使用するように。
;;
;;      Thu, 08 Nov 2001 17:42:30 +0900
;;        ・pickup-pattern-set-input のプロンプトを修正。
;;
;;      Thu, 08 Nov 2001 15:56:04 +0900
;;        ・text-attribute の tag を識別するための
;;          *pickup-pattern-identifier* の追加。
;;        ・正規表現検索するかどうかのフラグ *pickup-pattern-regexp* の追加。
;;        ・pickup-pattern-unset の挙動を変更。
;;        ・pickup-pattern-refresh-all, pickup-pattern-unset-all,
;;          pickup-pattern-delete-select, pickup-pattern-delete-all の追加。
;;
;;      Wed, 07 Nov 2001 23:42:57 +0900
;;        ・初版作成。

;; Licence:
;;
;;    pickup-pattern は修正BSDライセンスに基づいて利用可能です。
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

(provide "pickup-pattern")

(require "struct")

(in-package "editor")

(export '(*pickup-pattern-fg* *pickup-pattern-bg* *pickup-pattern-bold*
          *pickup-pattern-underline* *pickup-pattern-strike-out*
          *pickup-pattern-regexp* *pickup-pattern-overlap*
          *pickup-pattern-identifier*
          *pickup-pattern-pre-search-unset* *pickup-pattern-search-pattern-add*
          *pickup-pattern-set-hook* *pickup-pattern-unset-all-hook*))

(export '(pickup-pattern-set-input
          pickup-pattern-set-input-detail
          pickup-pattern-refresh-select
          pickup-pattern-refresh-all
          pickup-pattern-unset-select
          pickup-pattern-unset-all
          pickup-pattern-delete-select
          pickup-pattern-delete-all
          pickup-pattern-list-show
          re-search-forward-pickup
          re-search-backward-pickup
          pickup-pattern-last-search))

(defconstant *pickup-pattern-version* "0.0.0.6"
  "pickup-pattern: Version")

(defstruct pickup-pattern-item
  (pattern    nil)
  (name       nil)
  (foreground :default)
  (background :default)
  (bold       :default)
  (underline  :default)
  (strike-out :default)
  (regexp     :default))

(defvar *pickup-pattern-fg* 1
  "pickup-pattern: 文字色")
(defvar *pickup-pattern-bg* 3
  "pickup-pattern: 背景色")
(defvar *pickup-pattern-bold* t
  "pickup-pattern: ボールド表示")
(defvar *pickup-pattern-underline* nil
  "pickup-pattern: アンダーライン表示")
(defvar *pickup-pattern-strike-out* nil
  "pickup-pattern: 打ち消し線表示")

(defvar *pickup-pattern-regexp* t
  "pickup-pattern: パターンを正規表現とみなす")
(defvar *pickup-pattern-overlap* nil
  "pickup-pattern: オーバーラップしたパターンにもマッチ")
(defvar *pickup-pattern-identifier* 'pickup-pattern
  "pickup-pattern: tag 識別子")

(defvar *pickup-pattern-pre-search-unset* t
  "pickup-pattern: 検索前に pickup 表示を全て解除")
(defvar *pickup-pattern-search-pattern-add* nil
  "pickup-pattern: 検索文字列をリストに追加")

(define-history-variable *pickup-pattern-list* nil
  "pickup-pattern: pickup パターンのリスト")

(defvar *pickup-pattern-select-string-info-show* nil
  "pickup-pattern: パターン選択時にデフォルト以外の設定を表示")
(defvar *pickup-pattern-select-string-info-left* " 【"
  "pickup-pattern: パターン選択時に表示する情報の左端文字列")
(defvar *pickup-pattern-select-string-info-right* "】"
  "pickup-pattern: パターン選択時に表示する情報の右端文字列")
(defvar *pickup-pattern-select-string-info-separator* ", "
  "pickup-pattern: パターン選択時に表示する情報の区切り文字列")

(defvar *pickup-pattern-set-hook* nil
  "pickup-pattern: pickup 時フック")
(defvar *pickup-pattern-unset-all-hook* nil
  "pickup-pattern: pickup 全解除時フック")


(defun pickup-pattern-set-input ()
  "pickup-pattern: 入力パターンを pickup"
  (interactive)
  (let (pattern pickup-item)
    (setq pattern
          (if *pickup-pattern-regexp*
              (read-string "Re-Pickup: " :default *last-search-regexp*
                           :history 'search)
            (read-string "Pickup: " :default *last-search-string*
                         :history 'search)))
    (when (string/= "" pattern)
      (setq pickup-item
            (make-pickup-pattern-item :pattern pattern
                                      :regexp *pickup-pattern-regexp*))
      (pickup-pattern-set pickup-item *pickup-pattern-overlap*)
      (setq *pickup-pattern-list*
            (delete pickup-item *pickup-pattern-list* :test 'equalp))
      (pushnew pickup-item *pickup-pattern-list* :test 'equalp)
      (if *pickup-pattern-regexp*
          (setq *last-search-regexp* pattern)
        (setq *last-search-string* pattern)))))

(defun pickup-pattern-set-input-detail ()
  "pickup-pattern: 入力パターンを指定した強調方法で pickup"
  (interactive)
  (let (pickup-item input
        pattern name foreground background bold underline strike-out)
    (setq pattern
          (if *pickup-pattern-regexp*
              (read-string "Re-Pickup: " :default *last-search-regexp*
                           :history 'search)
            (read-string "Pickup: " :default *last-search-string*
                         :history 'search)))
    (when (string/= "" pattern)
      (setq name (read-string "選択時表示名: " :default pattern))
      (if (string= "" (string-trim " " name))
          (setq name pattern))
      (setq input (read-string (format nil "文字色 (0-15): ")))
      (if (string-match "[0-9]+" input)
          (setq foreground (parse-integer (match-string 0)))
        (setq foreground nil))
      (setq input (read-string (format nil "背景色 (0-15): ")))
      (if (string-match "[0-9]+" input)
          (setq background (parse-integer (match-string 0)))
        (setq background nil))
      (setq input (string-trim " " (read-string (format nil "Bold (yes or no): "))))
      (cond
       ((string-match "^\\([yY]\\|[yY][eE][sS]\\)$" input) (setq bold t))
       ((string-match "^\\([nN]\\|[nN][oO]\\)$" input) (setq bold nil))
       (t (setq bold nil)))
      (setq input (string-trim " " (read-string (format nil "Underline (yes or no): "))))
      (cond
       ((string-match "^\\([yY]\\|[yY][eE][sS]\\)$" input) (setq underline t))
       ((string-match "^\\([nN]\\|[nN][oO]\\)$" input) (setq underline nil))
       (t (setq underline nil)))
      (setq input (string-trim " " (read-string (format nil "Strike-Out (yes or no): "))))
      (cond
       ((string-match "^\\([yY]\\|[yY][eE][sS]\\)$" input) (setq strike-out t))
       ((string-match "^\\([nN]\\|[nN][oO]\\)$" input) (setq strike-out nil))
       (t (setq strike-out nil)))

      (setq pickup-item
            (make-pickup-pattern-item :pattern    pattern
                                      :name       name
                                      :foreground foreground
                                      :background background
                                      :bold       bold
                                      :underline  underline
                                      :strike-out strike-out
                                      :regexp     *pickup-pattern-regexp*))
      (pushnew pickup-item *pickup-pattern-list* :test 'equalp)
      (pickup-pattern-set pickup-item *pickup-pattern-overlap*)
      (if *pickup-pattern-regexp*
          (setq *last-search-regexp* pattern)
        (setq *last-search-string* pattern)))))

(defun pickup-pattern-set (pickup-item overlap &optional (whole-pickup nil))
  "pickup-pattern: パターンを pickup
引数：
  ・pickup-item: 文字列も渡せるようになっているが、
    基本的に pickup-pattern-item 構造体を渡す。
  ・overlap: nil の場合一度マッチした文字列にはマッチしない。
  ・whole-pickup: t の場合パターンが正規表現かつグループ化されていても、
    マッチした文字列全体を pickup する。"
  (let (pattern
        pattern-fg pattern-bg pattern-bold pattern-underline pattern-strike-out
        pattern-regexp)
    (cond
     ((stringp pickup-item)
      (setq pattern pickup-item)
      (setq pattern-regexp *pickup-pattern-regexp*)
      (setq pattern-fg *pickup-pattern-fg*)
      (setq pattern-bg *pickup-pattern-bg*)
      (setq pattern-bold *pickup-pattern-bold*)
      (setq pattern-underline *pickup-pattern-underline*)
      (setq pattern-strike-out *pickup-pattern-strike-out*))
     ((pickup-pattern-item-p pickup-item)
      (setq pattern (pickup-pattern-item-pattern pickup-item))
      (setq pattern-regexp (pickup-pattern-item-regexp pickup-item))
      (setq pattern-fg (pickup-pattern-item-foreground pickup-item))
      (setq pattern-bg (pickup-pattern-item-background pickup-item))
      (setq pattern-bold (pickup-pattern-item-bold pickup-item))
      (setq pattern-underline (pickup-pattern-item-underline pickup-item))
      (setq pattern-strike-out (pickup-pattern-item-strike-out pickup-item))
      (if (eq pattern-regexp :default)
          (setq pattern-regexp *pickup-pattern-regexp*))
      (if (eq pattern-fg :default)
          (setq pattern-fg *pickup-pattern-fg*))
      (if (eq pattern-bg :default)
          (setq pattern-bg *pickup-pattern-bg*))
      (if (eq pattern-bold :default)
          (setq pattern-bold *pickup-pattern-bold*))
      (if (eq pattern-underline :default)
          (setq pattern-underline *pickup-pattern-underline*))
      (if (eq pattern-strike-out :default)
          (setq pattern-strike-out *pickup-pattern-strike-out*))
      ))
    (when pattern
      (save-excursion
        (goto-char (point-min))
        (while (scan-buffer pattern
                            :regexp pattern-regexp
                            :case-fold *case-fold-search*)
          (if (and pattern-regexp (not whole-pickup) (match-beginning 1))
              (set-text-attribute (match-beginning 1) (match-end 1)
                                  (cons *pickup-pattern-identifier* pickup-item)
                                  :foreground pattern-fg
                                  :background pattern-bg
                                  :bold       pattern-bold
                                  :underline  pattern-underline
                                  :strike-out pattern-strike-out)
            (set-text-attribute (match-beginning 0) (match-end 0)
                                (cons *pickup-pattern-identifier* pickup-item)
                                :foreground pattern-fg
                                :background pattern-bg
                                :bold       pattern-bold
                                :underline  pattern-underline
                                :strike-out pattern-strike-out))
          (if overlap (forward-char) (goto-char (match-end 0)))))))
    (run-hooks '*pickup-pattern-set-hook*))

(defun pickup-pattern-make-select-list ()
  (let (select-list display-string info-list (i 1))
    (dolist (pickup-item *pickup-pattern-list*)
      (cond
       ((stringp pickup-item)
        (setq display-string (format nil "~2,'0D: ~A" i pickup-item))
        (setq display-string (concat display-string " (all default)")))
       ((pickup-pattern-item-p pickup-item)
        (setq display-string (format nil "~2,'0D: ~A" i
                                     (cond
                                      ((pickup-pattern-item-name pickup-item))
                                      ((pickup-pattern-item-pattern pickup-item)))))
        (when *pickup-pattern-select-string-info-show*
          (setq info-list nil)
          (if (and (stringp (pickup-pattern-item-name pickup-item))
                   (string/= (pickup-pattern-item-name pickup-item)
                             (pickup-pattern-item-pattern pickup-item)))
              (push (format nil "PT: ~S" (pickup-pattern-item-pattern pickup-item)) info-list))
          (unless (eq (pickup-pattern-item-foreground pickup-item) :default)
            (push (format nil "FG: ~S" (pickup-pattern-item-foreground pickup-item)) info-list))
          (unless (eq (pickup-pattern-item-background pickup-item) :default)
            (push (format nil "BG: ~S" (pickup-pattern-item-background pickup-item)) info-list))
          (unless (eq (pickup-pattern-item-bold pickup-item) :default)
            (push (format nil "B: ~S" (pickup-pattern-item-bold pickup-item)) info-list))
          (unless (eq (pickup-pattern-item-underline pickup-item) :default)
            (push (format nil "U: ~S" (pickup-pattern-item-underline pickup-item)) info-list))
          (unless (eq (pickup-pattern-item-strike-out pickup-item) :default)
            (push (format nil "S: ~S" (pickup-pattern-item-strike-out pickup-item)) info-list))
          (when info-list
            (setq display-string
                  (concat display-string
                          *pickup-pattern-select-string-info-left*
                          (pickup-pattern-join-string-list
                           *pickup-pattern-select-string-info-separator*
                           (nreverse info-list))
                          *pickup-pattern-select-string-info-right*)))))
       (t (push "" select-list)))
      (push display-string select-list)
      (incf i))
    (nreverse select-list)))

(defun pickup-pattern-refresh-select ()
  "pickup-pattern: 選択パターンの pickup 表示を再描画"
  (interactive)
  (if (null *pickup-pattern-list*)
      (message "パターンが登録されていません")
    (popup-list (pickup-pattern-make-select-list)
                #'(lambda (string)
                    (let (index pickup-item)
                      (when (string-match "\\(.*?\\)0*\\([1-9][0-9]*\\): \\(.*\\)" string)
                        (setq index (parse-integer (match-string 2)))
                        (setq pickup-item (nth (1- index) *pickup-pattern-list*))
                        (pickup-pattern-set pickup-item *pickup-pattern-overlap*)
                        (setq *pickup-pattern-list*
                              (nconc
                               (subseq *pickup-pattern-list* 0 (1- index))
                               (subseq *pickup-pattern-list* index)))
                        (push pickup-item *pickup-pattern-list*)
                        (refresh-screen))))
                (point))))

(defun pickup-pattern-refresh-all ()
  "pickup-pattern: 全パターンの pickup 表示を再描画"
  (interactive)
  (dolist (pickup-item (reverse *pickup-pattern-list*))
    (pickup-pattern-set pickup-item *pickup-pattern-overlap*)))

(defun pickup-pattern-unset (pickup-item)
  "pickup-pattern: パターンの pickup 表示を解除"
  (delete-text-attributes pickup-item :test
                          #'(lambda (pickup-item tag)
                              (if (and (consp tag)
                                       (eq (car tag) *pickup-pattern-identifier*)
                                       (equalp (cdr tag) pickup-item))
                                  t nil))))

(defun pickup-pattern-unset-select ()
  "pickup-pattern: 選択パターンの pickup 表示を解除"
  (interactive)
  (if (null *pickup-pattern-list*)
      (message "パターンが登録されていません")
    (popup-list (pickup-pattern-make-select-list)
                #'(lambda (string)
                    (let (index pickup-item)
                      (when (string-match "\\(.*?\\)0*\\([1-9][0-9]*\\): \\(.*\\)" string)
                        (setq index (parse-integer (match-string 2)))
                        (setq pickup-item (nth (1- index) *pickup-pattern-list*))
                        (pickup-pattern-unset pickup-item)
                        (setq *pickup-pattern-list*
                              (nconc
                               (subseq *pickup-pattern-list* 0 (1- index))
                               (subseq *pickup-pattern-list* index)))
                        (push pickup-item *pickup-pattern-list*)
                        (refresh-screen))))
                (point))))

(defun pickup-pattern-unset-all ()
  "pickup-pattern: 全パターンの pickup 表示を解除"
  (interactive)
  (delete-text-attributes nil :test
                          #'(lambda (pickup-item tag)
                              (if (and (consp tag)
                                       (eq (car tag) *pickup-pattern-identifier*))
                                  t nil)))
  (run-hooks '*pickup-pattern-unset-all-hook*))

(defun pickup-pattern-delete-select ()
  "pickup-pattern: 選択パターンの pickup 表示を解除しリストから削除"
  (interactive)
  (if (null *pickup-pattern-list*)
      (message "パターンが登録されていません")
    (popup-list (pickup-pattern-make-select-list)
                #'(lambda (string)
                    (let (index pickup-item)
                      (when (string-match "\\(.*?\\)0*\\([1-9][0-9]*\\): \\(.*\\)" string)
                        (setq index (parse-integer (match-string 2)))
                        (setq pickup-item (nth (1- index) *pickup-pattern-list*))
                        (pickup-pattern-unset pickup-item)
                        (setq *pickup-pattern-list*
                              (nconc
                               (subseq *pickup-pattern-list* 0 (1- index))
                               (subseq *pickup-pattern-list* index)))
                        (refresh-screen))))
                (point))))

(defun pickup-pattern-delete-all ()
  "pickup-pattern: 全パターンの pickup 表示を解除しリストから削除"
  (interactive)
  (when (and *pickup-pattern-list*
             (string-match "^\\([yY]\\|[yY][eE][sS]\\)"
                           (read-string "全パターンを削除してよいですか？(yes/no): ")))
    (pickup-pattern-unset-all)
    (setq *pickup-pattern-list* nil)))

(defun re-search-forward-pickup (regexp &optional noerror)
  "pickup-pattern: 正規表現前方検索 & pickup 表示"
  (interactive "sRe-search forward: "
    :default0 *last-search-regexp* :history0 'search)
  (let (pickup-item)
    (if *pickup-pattern-pre-search-unset*
        (pickup-pattern-unset-all))
    (setq pickup-item (make-pickup-pattern-item :pattern regexp :regexp  t))
    (pickup-pattern-set pickup-item t t)
    (when (and *pickup-pattern-search-pattern-add* (string/= "" regexp))
      (setq *pickup-pattern-list*
            (delete pickup-item *pickup-pattern-list* :test 'equalp))
      (pushnew pickup-item *pickup-pattern-list* :test 'equalp))
    (search-command regexp nil t (interactive-p) noerror)))

(defun re-search-backward-pickup (regexp &optional noerror)
  "pickup-pattern: 正規表現後方検索 & pickup 表示"
  (interactive "sRe-search backward: "
    :default0 *last-search-regexp* :history0 'search)
  (let (pickup-item)
    (if *pickup-pattern-pre-search-unset*
        (pickup-pattern-unset-all))
    (setq pickup-item (make-pickup-pattern-item :pattern regexp :regexp  t))
    (pickup-pattern-set pickup-item t t)
    (when (and *pickup-pattern-search-pattern-add* (string/= "" regexp))
      (setq *pickup-pattern-list*
            (delete pickup-item *pickup-pattern-list* :test 'equalp))
      (pushnew pickup-item *pickup-pattern-list* :test 'equalp))
    (search-command regexp t t (interactive-p) noerror)))

(defun pickup-pattern-last-search ()
  "pickup-pattern: editor::*show-match-hook* 用 function"
  (let (pickup-item)
    (if *pickup-pattern-pre-search-unset*
        (pickup-pattern-unset-all))
    (if *last-search-regexp-p*
        (setq pickup-item (make-pickup-pattern-item :pattern *last-search-regexp*
                                                    :regexp t))
      (setq pickup-item (make-pickup-pattern-item :pattern *last-search-string*
                                           :regexp nil)))
    (when *pickup-pattern-search-pattern-add*
      (setq *pickup-pattern-list*
            (delete pickup-item *pickup-pattern-list* :test 'equalp))
      (pushnew pickup-item *pickup-pattern-list* :test 'equalp))
    (pickup-pattern-set pickup-item t t))
  t)

(defun pickup-pattern-list-show ()
  "pickup-pattern: パターンリストの表示"
  (interactive)
  (let ((current-buffer-mode buffer-mode) (i 1) info-list
        pattern pattern-fg pattern-bg pattern-bold pattern-underline
        pattern-strike-out pattern-regexp)
    (delete-other-windows)
    (split-window)
    (switch-to-buffer "*PickupPatternShow*")
    (kill-all-local-variables)
    (setq buffer-mode current-buffer-mode)
    (setq mode-name "PickupPatternShow")
    (make-local-variable 'need-not-save)
    (setq need-not-save t)
    (make-local-variable 'auto-save)
    (setq auto-save nil)

    (erase-buffer (selected-buffer))
    (dolist (pickup-item *pickup-pattern-list*)
      (setq info-list nil)
      (cond
       ((stringp pickup-item)
        (setq pattern pickup-item)
        (setq pattern-regexp *pickup-pattern-regexp*)
        (setq pattern-fg *pickup-pattern-fg*)
        (setq pattern-bg *pickup-pattern-bg*)
        (setq pattern-bold *pickup-pattern-bold*)
        (setq pattern-underline *pickup-pattern-underline*)
        (setq pattern-strike-out *pickup-pattern-strike-out*))
       ((pickup-pattern-item-p pickup-item)
        (setq pattern (pickup-pattern-item-pattern pickup-item))
        (setq pattern-regexp (pickup-pattern-item-regexp pickup-item))
        (setq pattern-fg (pickup-pattern-item-foreground pickup-item))
        (setq pattern-bg (pickup-pattern-item-background pickup-item))
        (setq pattern-bold (pickup-pattern-item-bold pickup-item))
        (setq pattern-underline (pickup-pattern-item-underline pickup-item))
        (setq pattern-strike-out (pickup-pattern-item-strike-out pickup-item))
        (if (eq pattern-regexp :default)
            (setq pattern-regexp *pickup-pattern-regexp*)
          (push (format nil "R: ~S" pattern-regexp) info-list))
        (if (eq pattern-fg :default)
            (setq pattern-fg *pickup-pattern-fg*)
          (push (format nil "FG: ~S" pattern-fg) info-list))
        (if (eq pattern-bg :default)
            (setq pattern-bg *pickup-pattern-bg*)
          (push (format nil "BG: ~S" pattern-bg) info-list))
        (if (eq pattern-bold :default)
            (setq pattern-bold *pickup-pattern-bold*)
          (push (format nil "B: ~S" pattern-bold) info-list))
        (if (eq pattern-underline :default)
            (setq pattern-underline *pickup-pattern-underline*)
          (push (format nil "U: ~S" pattern-underline) info-list))
        (if (eq pattern-strike-out :default)
            (setq pattern-strike-out *pickup-pattern-strike-out*)
          (push (format nil "S: ~S" pattern-strike-out) info-list))
        ))

      (insert (format nil "■~2,'0D: " i))
      (cond
       ((stringp pickup-item)
        (set-text-attribute (point)
                            (progn (insert (format nil "~A~%" pickup-item)) (point))
                            nil
                            :foreground pattern-fg
                            :background pattern-bg
                            :bold       pattern-bold
                            :underline  pattern-underline
                            :strike-out pattern-strike-out)
        (insert (format nil "~A~%" pickup-item)))
       ((pickup-pattern-item-p pickup-item)
        (set-text-attribute (point)
                            (progn
                              (insert (format nil  "~A"
                                              (cond
                                               ((pickup-pattern-item-name pickup-item))
                                               ((pickup-pattern-item-pattern pickup-item)))))
                              (point))
                            nil
                            :foreground pattern-fg
                            :background pattern-bg
                            :bold       pattern-bold
                            :underline  pattern-underline
                            :strike-out pattern-strike-out)
        (insert (format nil "~A~%"
                        (if info-list
                            (concat *pickup-pattern-select-string-info-left*
                                    (pickup-pattern-join-string-list
                                     *pickup-pattern-select-string-info-separator*
                                     (nreverse info-list))
                                    *pickup-pattern-select-string-info-right*)
                          "")))
        (insert (format nil "~A~%" (pickup-pattern-item-pattern pickup-item)))))
      (incf i))
    (goto-char (point-min))
    (set-buffer-modified-p nil)
    (other-window)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 汎用関数
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; join
(defun pickup-pattern-join-string-list (join str-list)
  (let ((return-str "") (cnt (length str-list)))
    (dolist (str str-list)
      (incf cnt -1)
      (when (stringp str)
        (setq return-str (concat return-str str (if (> cnt 0) join "")))))
    return-str))

#|
(global-set-key '(#\C-c #\p #\s) 'pickup-pattern-set-input)
(global-set-key '(#\C-c #\p #\C-s) 'pickup-pattern-set-input-detail)
(global-set-key '(#\C-c #\p #\r) 'pickup-pattern-refresh-select)
(global-set-key '(#\C-c #\p #\C-r) 'pickup-pattern-refresh-all)
(global-set-key '(#\C-c #\p #\u) 'pickup-pattern-unset-select)
(global-set-key '(#\C-c #\p #\C-u) 'pickup-pattern-unset-all)
(global-set-key '(#\C-c #\p #\d) 'pickup-pattern-delete-select)
(global-set-key '(#\C-c #\p #\C-d) 'pickup-pattern-delete-all)
(global-set-key '(#\C-c #\p #\l) 'pickup-pattern-list-show)
(global-set-key #\M-s 're-search-forward-pickup)
(global-set-key #\M-C-s 're-search-backward-pickup)
|#

;; uninstall
(defun pickup-pattern-uninstall ()
  (let ((history-variables
         '(*pickup-pattern-list*)))
    (dolist (variable history-variables)
      (unregister-history-variable variable))))

;;; pickup-pattern.l ends here
