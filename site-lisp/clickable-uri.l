;;; -*- Mode: Lisp; Package: EDITOR -*-
;;; clickable-uri.l --- クリッカブル URI

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Time-stamp: <2005/10/08 12:00:53 +0900>

;;; Commentary:

;; Description:
;;
;;  左ダブルクリックによる WEB ブラウザ、メーラー等の起動を可能にします。
;;  URI (Uniform Resource Identifier) 強調表示も行います。
;;

;; Installation:
;;
;;      1. アーカイブを展開して clickable-uri.l を $XYZZY/site-lisp に
;;         コピーします。
;;
;;      2. 必要ならばバイトコンパイルします。
;;
;;              M-x byte-compile-file
;;              Byte compile file: $XYZZY/site-lisp/clickable-uri.l
;;
;;      3. ~/.xyzzy または $XYZZY/site-lisp/siteinit.l に以下のコードを
;;         追加します。
;;
;;              (require "clickable-uri")
;;
;;      4. 必要ならばキーバインド設定のコードを追加します。
;;         （左クリックについては標準でキーバインドを変更します。）
;;
;;              例：
;;              (global-set-key #\C-l 'clickable-uri-recenter)
;;              (global-set-key '(#\C-c #\C-o) 'clickable-uri-open)
;;
;;      5. 上記の設定を反映させるために、xyzzy を再起動します。
;;         siteinit.l に記述した場合は Ctrl キーと Shift キーを押しながら
;;         xyzzy を再起動し、ダンプファイルを再構築します。
;;

;; Uninstallation:
;;
;;      1. clickable-uri.l に関する記述を削除します。
;;
;;      2. siteinit.l に記述していた場合は Ctrl キーと Shift キーを押し
;;         ながら xyzzy を再起動し、ダンプファイルを再構築します。
;;

;; Specification:
;;
;;  URI の強調表示は、バッファに対して正規表現キーワードを設定、追加
;;  することで行っています。
;;  そのため、正規表現キーワードを追加する適当なタイミングがない場合は
;;  自動で強調表示となりません。また、バッファの正規表現キーワードが
;;  初期化された場合は URI 強調表示が無効化されます。
;;
;;  具体的には、regexp-keyword-list に *clickable-uri-regexp* が含まれて
;;  いれば強調表示され、含まれていなければ強調表示されません。
;;
;;      URI 強調表示有効化タイミング:
;;          ・新規バッファ作成時 (ファイルオープン時)
;;          ・以下のいずれかの実行時
;;                M-x clickable-uri-emphasis
;;                M-x clickable-uri-emphasis-force
;;                M-x clickable-uri-recenter
;;
;;      URI 強調表示無効化タイミング:
;;          ・手動での各種モード実行時 (ex. M-x lisp-mode)
;;            (各種モードで regexp-keyword-list が再設定されるが、
;;             新規バッファ作成時ではないので、*find-file-hooks* が
;;             実行されず、結果 clickable-uri-emphasis が実行されないため。)
;;
;;  また、xyzzy では同一ポイントから「キーワード」と「正規表現キーワード」
;;  が開始した場合「キーワード」が優先されます。
;;  この場合、URI は強調表示されません。
;;

;; Setting example:
;;
;;      (require "clickable-uri")
;;      ;; 強調表示は「表示色4 (青)」＋アンダーライン
;;      (setq *clickable-uri-keyword-color* '(:color 4 0 :underline))
;;      ;; オープン時の強調表示は「文字色4(青)」「アンダーライン」「ボールド」
;;      (setq *clickable-uri-open-attribute* '(:foreground 4 :underline t :bold t))
;;      ;; オープン時の強調表示時間は 0.2 秒
;;      (setq *clickable-uri-open-attribute-timeout* 0.2)
;;      ;; uri 構成文字と見なす文字を拡張
;;      (setq *clickable-uri-chars*
;;            "-a-zA-Z0-9_/~.@?&=;+(),'$!*:#%|０-９Ａ-Ｚａ-ｚぁ-んァ-ヶ亜-熙")
;;      ;; http: https: scheme をオープンするコマンドを指定
;;      (push '("^https?:" . "D:/utils/sleipnir/Sleipnir.exe")
;;            *clickable-uri-open-command-alist*)
;;      ;; 設定変更を反映
;;      (clickable-uri-set-regexp)
;;
;;      (global-set-key #\C-l 'clickable-uri-recenter)
;;      (global-set-key '(#\C-c #\C-l) 'clickable-uri-emphasis-force)
;;      (global-set-key '(#\C-c #\C-o) 'clickable-uri-open)
;;


;; Changes:
;;
;;      Sat, 08 Oct 2005 11:57:21 +0900
;;        ・file: の場合そのまま shell-execute に渡すように変更。
;;        ・メールアドレスを変更。
;;        ・ライセンス条項(修正BSDライセンス)を記載。
;;
;;      Sat, 05 Feb 2005 23:09:48 +0900
;;        ・内部コードの変更により *clickable-url-emphasis-deny-mode-list*
;;          指定の意味がほぼなくなっていたため、指定自体を削除。
;;
;;      Sat, 08 Jan 2005 07:19:24 +0900
;;        ・clickable-uri-mouse-left-press 修正。
;;          (clickable-uri-open) 処理に成功した場合は (mouse-left-press)
;;          処理を行わないように。
;;        ・コメント修正。
;;
;;      Tue, 26 Oct 2004 00:24:56 +0900
;;        ・clickable-uri として書き直し。file:... 等も open 可能に。
;;        ・スキームの typo を修正。
;;        ・何回の左クリックで URI を open するかを指定する
;;          *clickable-uri-click-count* 追加。
;;        ・clickable-uri-emphasis-any-mode を
;;          clickable-uri-emphasis-force に名称変更。
;;        ・clickable-uri-emphasis-threshold を
;;          clickable-uri-emphasis に統合し、削除。
;;        ・*clickable-uri-open-command* を廃止し、
;;          *clickable-uri-open-command-alist* を追加。
;;        ・期待通りに動いていないこともあり、*clickable-uri-keep-focus*
;;          の初期値を nil に変更。
;;        ・clickable-uri-set-regexp 追加
;;        ・*clickable-uri-modify-uri-alist* 追加
;;
;;      Sun, 26 Sep 2004 21:37:03 +0900
;;        ・*clickable-url-attribute* 廃止。
;;        ・*clickable-url-selection-attribute* を
;;          *clickable-url-open-attribute* に名称変更。
;;        ・*clickable-url-selection-timeout* を
;;          *clickable-url-open-attribute-timeout* に名称変更。
;;        ・set-text-attribute を用いなくなったため、
;;          *-set-attribute-* を *-emphasis-* に名称変更。
;;        ・URI を強調表示するモードを指定するのではなく、
;;          強調表示しないモードを指定するように変更。
;;          具体的には、*clickable-url-set-attribute-mode-list* を廃止し、
;;          *clickable-url-emphasis-deny-mode-list* を追加。
;;          強調表示しないモードのリストを設定する。
;;        ・*clickable-url-threshold* を *clickable-url-emphasis-threshold*
;;          に名称変更。
;;        ・clickable-url-emphasis-threshold の閾値判定を
;;          ファイルサイズではなくバッファサイズ (buffer-size) を
;;          元に行うように変更。
;;
;;      Sat, 25 Sep 2004 09:57:23 +0900
;;        ・根本的に書き換えるのはおいておき、強調表示を set-text-attribute
;;          でなく regexp-keyword で行うように変更。
;;          keyword に対する color 設定は *clickable-url-keyword-color* で。
;;
;;      Sat, 25 Sep 2004 00:04:11 +0900
;;        ・「xyzzyの使い方が分からぬやし 励ましあえ その5」の 528 での
;;          不具合「background=http://xyzzy.xyzzy/... の "background" 部
;;          分のダブルクリックでブラウザが立ち上がる」に対処。
;;
;;      Fri, 18 Jun 2004 18:43:45 +0900
;;        ・同一ファイル内別パッケージ(winapi)で *define したシンボル
;;          foo を winapi:foo として指定していると byte-compile できない
;;          問題に対して対応。
;;
;;      Sat, 12 Jun 2004 17:29:06 +0900
;;        ・NetInstaller 対応。
;;
;;      Mon, 20 Oct 2003 01:03:18 +0900
;;        ・ファイルサイズで閾値判定するコマンドを追加。
;;          *find-file-hooks* では本コマンドを実行。
;;          clickable-url-set-attribute-threshold
;;          *clickable-url-threshold*
;;        ・long-operation に。
;;        ・実行中 message 表示追加。
;;
;;      Mon, 27 Jan 2003 22:36:52 +0900
;;        ・*clickable-url-open-command* 追加。
;;
;;      Sat, 15 Jun 2002 12:30:32 +0900
;;        ・xyzzy のフォーカスを維持するように。してみたつもりがうまくいかない。
;;
;;      Sat, 23 Feb 2002 16:37:09 +0900
;;        ・clickable-url-open でメッセージを表示するように。
;;
;;      Sat, 23 Feb 2002 01:32:15 +0900
;;        ・選択文字列の強調表示後、既存の text-attribute を復元するように。
;;
;;      Tue, 19 Feb 2002 21:09:33 +0900
;;        ・clickable-url-open を少し賢く。
;;        ・選択文字列をシェルに渡す前に強調できるように。
;;
;;      Fri, 25 Jan 2002 23:45:13 +0900
;;        ・ttp:// でもいいように。
;;
;;      Thu, 24 Jan 2002 08:49:58 +0900
;;        ・キーボードにも動作を割り当てられるように
;;          clickable-url-open として処理を分離。
;;
;;      Thu, 24 Jan 2002 04:20:41 +0900
;;        ・とりあえず書いてみた。
;;          こんなのを editor パッケージにいれていいのか疑問。
;;

;; Todo:
;;      ・Setting example の修正。
;;      ・keep-focus の処理がが期待したとおりに動いていない。
;;        winapi::SetWindowPos を用いて書きなおす。
;;

;; Memo:
;;      ・Uniform Resource Identifer (URI) SCHEMES [IANA 管理、公式]
;;        http://www.iana.org/assignments/uri-schemes
;;      ・Addressing Schemes [RFC にあるものの一覧]
;;        http://www.w3.org/Addressing/schemes
;;

;; Licence:
;;
;;    clickable-uri は修正BSDライセンスに基づいて利用可能です。
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

(provide "clickable-uri")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "foreign")
  (require "wip/winapi"))
(in-package "winapi")

(unless (fboundp 'SetFocus)
  (*define-dll-entry HWND SetFocus (HWND) "user32"))
(unless (fboundp 'ShellExecute)
  (*define-dll-entry DWORD ShellExecute (HWND LPCSTR LPCSTR LPCSTR LPCSTR INT) "shell32" "ShellExecuteA"))

(*define SW_HIDE             0)
(*define SW_SHOWNORMAL       1)
(*define SW_NORMAL           1)
(*define SW_SHOWMINIMIZED    2)
(*define SW_SHOWMAXIMIZED    3)
(*define SW_MAXIMIZE         3)
(*define SW_SHOWNOACTIVATE   4)
(*define SW_SHOW             5)
(*define SW_MINIMIZE         6)
(*define SW_SHOWMINNOACTIVE  7)
(*define SW_SHOWNA           8)
(*define SW_RESTORE          9)
(*define SW_SHOWDEFAULT      10)
(*define SW_FORCEMINIMIZE    11)
(*define SW_MAX              11)

(in-package "editor")

(export '(*clickable-uri-emphasis-threshold*
          *clickable-uri-modify-uri-alist*
          *clickable-uri-open-command-alist*
          *clickable-uri-keyword-color*
          *clickable-uri-open-attribute*
          *clickable-uri-open-attribute-timeout*
          *clickable-uri-keep-focus*
          *clickable-uri-keep-focus-timeout*
          *clickable-uri-click-count*
          *clickable-uri-scheme-list*
          *clickable-uri-chars*
          *clickable-uri-mail-address-regexp*
          *clickable-uri-special-regexp-list*
          *clickable-uri-tag*))

(export '(clickable-uri-set-regexp
          clickable-uri-emphasis-force
          clickable-uri-emphasis
          clickable-uri-recenter
          clickable-uri-mouse-left-press
          clickable-uri-open))

(defvar *clickable-uri-emphasis-threshold* t
  "clickable-uri-emphasis のバッファサイズ実行判定閾値
               nil: 実行しない
         <integer>: バッファサイズが値以下の場合実行する
          上記以外: 実行する")
(defvar *clickable-uri-modify-uri-alist* nil
  "uri 補正関数用の連想リスト。
\(key . datum\) の組で登録する。
uri が key での判定で補正対象と認識された場合、uri を
\(funcall datum uri\) の結果で置き換える。
判定は、key が文字列もしくは、コンパイル済み正規表現の場合
\(string-matchp key uri\) で、関数の場合 \(funcall key uri\) で行う。")
(defvar *clickable-uri-open-command-alist* nil
  "uri 毎の open 実行コマンド設定用の連想リスト。
\(key . datum\) の組で登録する。
uri が key での判定で non-nil となり実行対象と認識された場合、
datum が文字列ならば URI を引数として datum プログラムで実行、
そうでなければ URL を引数として datum を funcall する。")

(defvar *clickable-uri-keyword-color* '(:color 4 0 :underline)
  "URI を正規表現キーワードリストで表示する際の color")
(defvar *clickable-uri-open-attribute* '(:foreground 4 :underline t :bold t)
  "選択した URI の強調表示属性 (set-text-attribute 用)")
(defvar *clickable-uri-open-attribute-timeout* 0.2
  "選択した URI の強調表示秒数
nil 選択した URI を強調表示しない")
(defvar *clickable-uri-keep-focus* nil
  "xyzzy のフォーカスを維持する")
(defvar *clickable-uri-keep-focus-timeout* 1
  "フォーカスを維持するための待機秒数")
(defvar *clickable-uri-click-count* 2
  "何回連続の左クリックで clickable-uri-open を実行するか")
(defvar *clickable-uri-tag* 'clickable-uri
  "開く対象を強調表示する際の tag")

(defvar *clickable-uri-scheme-list*
  '("http" "https" "ftp" "file" "news" "nntp" "wais" "telnet" "mailto" "gopher" "ttp")
  "scheme 文字列のリスト")
(defvar *clickable-uri-chars* "-a-zA-Z0-9_/~.@?&=;+(),'$!*:#%|"
  "skip-chars-forward, skip-chars-backward で用いるとともに、
正規表現の文字クラスとしても流用するため、記述には注意が必要。")
(defvar *clickable-uri-mail-address-regexp*
  "[-a-zA-Z0-9_.]+@[-a-zA-Z0-9_]+\\(?:\\.[-a-zA-Z0-9_]+\\)+"
  "E-MAIL アドレス正規表現")
(defvar *clickable-uri-special-regexp-list*
  (list *clickable-uri-mail-address-regexp*)
  "強調表示用個別正規表現")
(defvar *clickable-uri-regexp* nil
  "URI強調表示用正規表現(clickable-uri-set-regexp で設定)")

(defun clickable-uri-set-regexp (&optional (scheme-list *clickable-uri-scheme-list*)
                                           (uri-chars *clickable-uri-chars*)
                                           (special-regexp-list *clickable-uri-special-regexp-list*))
  "*clickable-uri-regexp* を設定し、既存バッファの設定も更新する"
  (let ((old-regexp *clickable-uri-regexp*) scheme-regexp uri-regexp)
    ;; 新規 *clickable-uri-regexp* の生成
    (setq scheme-regexp
          (concat "\\("
                  (substring (format nil "~{\\|~A~}" (mapcar #'regexp-quote scheme-list)) 2)
                  "\\):"))
    (setq uri-regexp (concat scheme-regexp "[" uri-chars "]+"))
    (setq *clickable-uri-regexp*
          (compile-regexp
           (concat "\\("
                   (substring
                    (format nil "~{\\|\\(?:~A\\)~}"
                            (append (list uri-regexp) special-regexp-list)) 2)
                   "\\)") t))
    ;; デフォルト設定の更新
    (when (and (boundp 'regexp-keyword-list)
               (find old-regexp (default-value 'regexp-keyword-list)
                     :test #'clickable-uri-regexp-equal :key #'car))
      (setq-default regexp-keyword-list
                    (delete old-regexp (default-value 'regexp-keyword-list)
                            :test #'clickable-uri-regexp-equal :key #'car))
      (clickable-uri-emphasis-default))
    ;; バッファ個別設定の更新
    (save-excursion
      (dolist (buffer (buffer-list))
        (set-buffer buffer)
        (when (and (local-variable-p 'regexp-keyword-list)
                   (find old-regexp regexp-keyword-list
                         :test #'clickable-uri-regexp-equal :key #'car))
          (setq regexp-keyword-list
                (delete old-regexp regexp-keyword-list
                        :test #'clickable-uri-regexp-equal :key #'car))
          (clickable-uri-emphasis-force))))))

(defun clickable-uri-regexp-equal (regexp1 regexp2 &key regexp1-case-fold-p regexp2-case-fold-p)
  "正規表現が等しいか判定"
  (let (regexp1-source-regexp regexp2-source-regexp)
    (if (regexpp regexp1)
        (setq regexp1-source-regexp (compiled-regexp-source regexp1)
              regexp1-case-fold-p (compiled-regexp-case-fold-p regexp1))
      (setq regexp1-source-regexp regexp1))
    (if (regexpp regexp2)
        (setq regexp2-source-regexp (compiled-regexp-source regexp2)
              regexp2-case-fold-p (compiled-regexp-case-fold-p regexp2))
      (setq regexp2-source-regexp regexp2))
    (and (string= regexp1-source-regexp regexp2-source-regexp)
         (eq regexp1-case-fold-p regexp2-case-fold-p))))

(defun clickable-uri-emphasis-force (&optional buffer)
  "URI 強調表示を設定(無制限)"
  (interactive)
  (save-excursion
    (when (and (bufferp buffer) (not (eq buffer (selected-buffer))))
      (set-buffer buffer))
    (when (and (boundp 'regexp-keyword-list)
               (find *clickable-uri-regexp* regexp-keyword-list
                     :test #'clickable-uri-regexp-equal :key #'car))
      (return-from clickable-uri-emphasis-force nil))
    (let ((clickable-uri-regexp-keyword-list
           (compile-regexp-keyword-list
            `((,*clickable-uri-regexp* t ,*clickable-uri-keyword-color* t)))))
      (make-local-variable 'regexp-keyword-list)
      (setq regexp-keyword-list
            (if (boundp 'regexp-keyword-list)
                (append regexp-keyword-list clickable-uri-regexp-keyword-list)
              clickable-uri-regexp-keyword-list)))))

(defun clickable-uri-emphasis (&optional buffer)
  "URI 強調表示を設定"
  (interactive)
  (if (and *clickable-uri-emphasis-threshold*
           (or (not (integerp *clickable-uri-emphasis-threshold*))
               (<= (buffer-size buffer) *clickable-uri-emphasis-threshold*)))
      (progn
        (clickable-uri-emphasis-force buffer)
        t)
    (progn
      (when (interactive-p)
        (message "clickable-uri: skip"))
      nil)))

(defun clickable-uri-emphasis-default ()
  "URI 強調表示をデフォルトとして設定"
  (let ((clickable-uri-regexp-keyword-list
         (compile-regexp-keyword-list
          `((,*clickable-uri-regexp* t ,*clickable-uri-keyword-color* t)))))
    (setq-default regexp-keyword-list
                  (if (boundp 'regexp-keyword-list)
                      (append regexp-keyword-list clickable-uri-regexp-keyword-list)
                    clickable-uri-regexp-keyword-list))))

(defun clickable-uri-open ()
  "URI に対応する処理を実行
戻り値：
  t    対象URIがあり、処理を実行
  nil  対象URIがなく、処理を不実行"
  (interactive)
  (let ((opoint (point)) epoint text-attribute-list
        uri from to modify-func command)
    (save-excursion
      (skip-chars-forward *clickable-uri-chars*)
      (setq epoint (point))
      (when (and (skip-chars-backward *clickable-uri-chars*)
                 (scan-buffer *clickable-uri-regexp* :regexp t :case-fold t :limit epoint)
                 (<= (point) opoint)
                 (< opoint epoint))
        (setq uri (match-string 0) from (match-beginning 0) to (match-end 0))))
    (unless uri
      (save-excursion
        (when (and (scan-buffer *clickable-uri-regexp* :regexp t :case-fold t :reverse t
                                :limit (save-excursion (goto-bol) (point)))
                   (<= (match-beginning 0) opoint)
                   (< opoint (match-end 0)))
          (setq uri (match-string 0) from (match-beginning 0) to (match-end 0)))))
    ;; URI 判定できないため終了
    (unless uri
      (when (interactive-p)
        (message "開くべき URI が見つかりません"))
      (return-from clickable-uri-open nil))
    ;; 開く対象の URI を強調表示
    (when (and (numberp *clickable-uri-open-attribute-timeout*)
               (plusp *clickable-uri-open-attribute-timeout*))
      (setq text-attribute-list (list-text-attributes from to))
      (apply #'set-text-attribute (append (list from to *clickable-uri-tag*)
                                          *clickable-uri-open-attribute*))
      (goto-char opoint)
      (sit-for *clickable-uri-open-attribute-timeout*)
      (delete-text-attribute-point from)
      (dolist (text-attribute text-attribute-list)
        (apply #'set-text-attribute text-attribute)))
    ;; URI 補正
    (when (setq modify-func
                (cdr (find uri *clickable-uri-modify-uri-alist*
                           :key #'car
                           :test #'(lambda (uri checker)
                                     (or (and (or (regexpp checker) (stringp checker))
                                              (string-matchp checker uri))
                                         (and (functionp checker) (funcall checker uri)))))))
      (setq uri (funcall modify-func uri)))
    (message "~A" uri)
    ;; URI 対応処理実行
    (if (setq command
              (cdr (find uri *clickable-uri-open-command-alist*
                         :key #'car
                         :test #'(lambda (uri checker)
                                   (or (and (or (regexpp checker) (stringp checker))
                                            (string-matchp checker uri))
                                       (and (functionp checker) (funcall checker uri)))))))
        (if (stringp command)
            (shell-execute (map-slash-to-backslash command) t uri)
          (funcall command uri))
      (clickable-uri-shell-execute uri t nil winapi::SW_SHOWNOACTIVATE))
    ;; xyzzy 上にフォーカスを残すための苦肉の策
    (when *clickable-uri-keep-focus*
      (sit-for *clickable-uri-keep-focus-timeout*)
      (clickable-uri-focus-editor)))
  t)

(defun clickable-uri-recenter (&optional arg)
  "recenter とともに、URI 強調表示を設定"
  (interactive "p")
  (recenter arg)
  (clickable-uri-emphasis))

(defun clickable-uri-mouse-left-press ()
  "URI クリック対応版左クリック"
  (interactive)
  (let ((click (mod *last-mouse-click-count* 6)))
    (unless (and (integerp *clickable-uri-click-count*)
                 (= click *clickable-uri-click-count*)
                 (clickable-uri-open))
      (mouse-left-press))))

(defun clickable-uri-focus-editor ()
  (interactive)
  (winapi::SetFocus (get-window-handle)))

(defun clickable-uri-shell-execute (uri &optional directory param (showcmd winapi::SW_SHOWNORMAL))
  (if (eq directory t)
      (progn
        (setq directory 0)
        (setq uri (si:make-string-chunk uri)))
    (progn
      (if (stringp directory)
          (setq directory (si:make-string-chunk (map-slash-to-backslash directory)))
        (setq directory (si:make-string-chunk (map-slash-to-backslash (directory-namestring uri)))))
      (setq uri (si:make-string-chunk (map-slash-to-backslash uri)))))
  (if (stringp param)
      (setq param (si:make-string-chunk param))
    (setq param 0))
  (winapi::ShellExecute (get-window-handle) (si:make-string-chunk "open")
                        uri param directory showcmd))

;; URI 補正用
(defun clickable-uri-uri-mail-address-p (uri)
  (and (stringp *clickable-uri-mail-address-regexp*)
       (string-matchp (concat "^" *clickable-uri-mail-address-regexp* "$") uri)))

;; URI オープン用
(defun clickable-uri-filer-open-p ()
  (handler-case
      (progn (filer-reload) t)
    (error (c) nil)))
(defun clickable-uri-find-file (path)
  (if (file-exist-p path)
      (progn
        (if (file-directory-p path)
            (progn
              (unless (clickable-uri-filer-open-p)
                (filer nil t nil t (not *filer-modal*)))
              (filer-chdir path t)
              (filer-focus))
          (find-file path))
        t)
    (progn
      (message "~A が存在しません。" path)
      nil)))

;; 初期値設定
(clickable-uri-set-regexp)
(unless *clickable-uri-modify-uri-alist*
  (setq *clickable-uri-modify-uri-alist*
        (list (cons #'clickable-uri-uri-mail-address-p
                    #'(lambda (uri) (concat "mailto:" uri)))
              (cons "^ttp:"
                    #'(lambda (uri) (concat "h" uri))))))

;(push (cons "^file:"
;            #'(lambda (uri)
;                (string-matchp "^file:\\(///\\)?\\(.+\\)" uri)
;                (clickable-uri-find-file
;                 (si:www-url-decode (match-string 2)))))
;      *clickable-uri-open-command-alist*)

(push (cons "^file:" #'(lambda (uri) (shell-execute uri)))
      *clickable-uri-open-command-alist*)


;; 起動時処理
(clickable-uri-emphasis-default)
(add-hook '*find-file-hooks* 'clickable-uri-emphasis)

(global-set-key #\LBtnDown 'clickable-uri-mouse-left-press)

;;; clickable-uri.l ends here
