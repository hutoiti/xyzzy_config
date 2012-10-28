;;; -*- mode: lisp -*-
;;; name:     igsearch
;;; version:  2008.01.06
;;; author:   snj14
;;; category: Utilities
;;; src:      http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Figsearch&openfile=
;;; changes:  igsearch-minibuffer-end-of-buffer追加
;;;           igsearch-minibuffer-beginning-of-buffer追加
;;;           正規表現での検索で１文字目に^を入力すると固まったのを修正
;;; files:    site-lisp/igsearch.l
;;;           site-lisp/igsearch.lc
;;;           site-lisp/ni-autoload/silog/igsearch.l

;; Copyright (C) 1996-2005 Tetsuya Kamei
;; Copyright (C) 2005 matsushita
;; Copyright (C) 2006-2007 snj14
;;
;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions
;; are met:
;;
;; 1. Redistributions of source code must retain the above copyright
;;    notice, this list of conditions and the following disclaimer.
;;
;; 2. Redistributions in binary form must reproduce the above copyright
;;    notice, this list of conditions and the following disclaimer in
;;    the documentation and/or other materials provided with the
;;    distribution.
;;
;; 3. The name of the author may not be used to endorse or promote
;;    products derived from this software without specific prior
;;    written permission.
;;
;; THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
;; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
;; PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
;; DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
;; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
;; OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
;; HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
;; STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
;; ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;; POSSIBILITY OF SUCH DAMAGE.

;;; Commentary:

;; 概要:
;;
;;   インクリメンタルサーチ中に
;;    - マッチした候補を反対側のウィンドウに列挙
;;    - エスケープシーケンスの理解とそのトグル
;;    - *case-fold-search*の値のトグル
;;    - Migemo検索,曖昧検索,正規表現検索,通常検索の切り替え
;;    - 検索語のハイライト
;;   ができます。
;;   
;;   また、ミニバッファで文字入力中に実行すると
;;    - 履歴の一覧を表示
;;    - 履歴のインクリメンタルサーチ
;;    - 履歴の削除
;;   ができます。
;;   

;; 動作環境:
;;
;;   xyzzy 0.2.2.235 以降
;;
;;   Option
;;     migemo                JunkScripts   (http://www7a.biglobe.ne.jp/~hat/)
;;     approx-search         silog         (http://white.s151.xrea.com/wiki/)

;; 設定:
;;
;; NetInstallerで導入した方は 1 は不要です
;;
;;   1 $XYZZY/site-lisp/ 以下にコピーし、バイトコンパイルしてください。
;;   2 .xyzzy や siteinit.l に以下を参考に記述し、
;;     siteinit.lに記述した方は再ダンプしてください。
;;   (require "igsearch") ; ni-autoloadしている人は不要
;;   (setf *igsearch-init-state* :migemo)     ; 最初はmigemo
;;   (setf *igsearch-escape-sequence* t)      ; エスケープシーケンスを理解する
;;   (setf *igsearch-next-buffer-use-olt2* t) ; バッファ移動はolt2の順で
;;   もっと詳しく知りたい方は「カスタマイズ用変数ここから」周辺を見てください。

;; 使い方
;;
;;   C-s インクリメンタルサーチ開始
;;   C-r インクリメンタルサーチ開始
;;
;;   インクリメンタルサーチ中のキーバインド(変更分のみ)
;;   C-.      次のバッファに切り替えます。
;;   C-,      前のバッファに切り替えます。
;;   C->      エスケープシーケンスを理解したりしなかったりします
;;            モードラインにESCと出ていたら理解します。
;;                          escと出ていたら理解しません。
;;   C-<      大文字小文字の区別をしたりしなかったり、大文字の時だけしたりします。
;;            モードラインにCASEと出ていたら区別します。
;;                          caseと出ていたら区別しません。
;;                          Caseと出ていたら全て小文字の時だけ区別しません。
;;   C-d      検索語を1文字削除します。(C-hと違って戻りません)
;;            Migemoで検索中ならばMigemoをオフにします。
;;   C-f      検索後をバッファから1文字追加します
;;            Migemoで検索中ならばMigemoをオフにします。
;;   C-t      regexp,migemo,approx,normalの順に切り替えます。
;;            migemoとapproxを未導入の場合は飛ばします。
;;   C-o      候補表示バッファに移動
;;   C-w      検索語をバッファから1単語追加します。
;;            Migemoで検索中ならば通常検索に切り替えます。
;;   ESC ESC  インクリメンタルサーチを中止します。
;;   M-c      検索語のハイライトを終了後も残すかどうか切り替えます。
;;   M-r      正規表現検索に切り替えます。
;;            既に正規表現検索なら通常検索に切り替えます。
;;   M-a      Approx-searchが入っていれば曖昧検索に切り替えます。
;;            既に曖昧検索なら通常検索に切り替えます。
;;   M-m      Migemoが入っていればMigemo検索に切り替えます。
;;            既にMigemo検索なら通常検索に切り替えます。
;;   M-p      ヒストリを一つ戻ります。[Up]と同じです。
;;   M-n      ヒストリを一つ進みます。[Down]と同じです。
;;   \        通常通り、\を検索語に追加します。
;;            正規表現検索中であれば通常検索に切り替えます。
;;
;;   ミニバッファからigsearchしたときのみ
;;   C-n      文字が入力されていればC-sと同じ。そうでなければ1行下へ
;;   Down     文字が入力されていればC-sと同じ。そうでなければ1行下へ
;;   C-p      文字が入力されていればC-sと同じ。そうでなければ1行上へ
;;   Up       文字が入力されていればC-sと同じ。そうでなければ1行上へ
;;   C-v      文字が入力されていればC-sと同じ。そうでなければ1ページ上へ
;;   PageDown 文字が入力されていればC-sと同じ。そうでなければ1ページ上へ
;;   M-v      文字が入力されていればC-sと同じ。そうでなければ1ページ下へ
;;   PageUp   文字が入力されていればC-sと同じ。そうでなければ1ページ下へ
;;   M-<      文字が入力されていればC-sと同じ。そうでなければバッファの先頭へ
;;   M->      文字が入力されていればC-sと同じ。そうでなければバッファの末尾へ
;;   C-d      履歴を削除
;;
;;   候補表示バッファのキーバインド
;;
;;   ESC      バッファを閉じます
;;   q        バッファを閉じます
;;   TAB      カーソルのある行を反対側のウィンドウで表示します
;;   SPC      カーソルのある行を反対側のウィンドウで表示し、
;;            反対側のウィンドウにカーソルを移動させます。
;;   RET      カーソルのある行を反対側のウィンドウで表示し、
;;            候補表示バッファを閉じます。
;;   C-n      [Down] + [TAB]
;;   C-p      [Up] + [TAB]
;;   M-c      検索語のハイライトを終了後も残すかどうか切り替えます。
;;   f        flush lines(正規表現を入力し、マッチする行を削除)します。
;;   k        keep lines(正規表現を入力し、マッチしない行を削除)します。

;; 注意:
;;
;; - 候補表示バッファにC-oで移動した後に色々
;;   (ウィンドウ分割したり元のバッファを消したりバッファを移動したりフレームを移動したり etc)
;;   やるとエラーが出たり挙動がおかしくなったりするので優しく取り扱ってください。
;; - 正規表現検索をしたい時はとりあえずC-tでNormalにして正規表現を入力し、
;;   その後にC-tでRegexpに切り替え、C-sすることをお勧めします。

;; 履歴:
;; 
;; 2008.01.06
;; - igsearch-minibuffer-end-of-buffer追加
;; - igsearch-minibuffer-beginning-of-buffer追加
;; - 正規表現での検索で１文字目に^を入力すると固まったのを修正
;; 
;; 2007.03.04
;; - 前回の変更でミニバッファ以外でのC-dが潰されていたのを修正
;; 
;; 2007.03.02
;; - ミニバッファで履歴を検索中にC-dで履歴を消せるようにした
;; 
;; 2007.02.28
;; - エラー修正
;; - ミニバッファの履歴の区切りを変更可能にした
;; 
;; 2007.02.27
;; - 使い辛かったのでigsearch-toggle-grepのデフォルトのキーバインドをM-tに変更
;; - 名前変更 igsearch-rotate-method igsearch-toggle-method
;; - ミニバッファ中の履歴表示の前回分を消していなかったのを修正
;; - ミニバッファで履歴を検索した後にエラーが出ていたのを修正
;; - ミニバッファで履歴に改行が含まれていてもちゃんと選択できるようにした
;; 
;; 2007.02.19
;; - 折り返していると強調表示されない場合があったのを修正
;; - 特定のバッファは常に候補を列挙しない設定追加
;; 
;; 2007.02.15
;; - キーボードマクロ実行時にちらつかないようにした
;; - igsearch-refresh-highlight-toggleを候補表示バッファでも出来るようにした
;; - ミニバッファにいる時にC-s/C-rで履歴からインクリメンタルサーチするようにした
;; - 検索語の強調表示を元に戻す場合はインクリメンタルサーチ前の属性を元に戻すようにした
;; 
;; 2007.02.11
;; - 一覧表示のトグル機能追加
;; - 一覧表示のトグルをしたら即表示/非表示するようにした
;; 
;; 2007.02.08
;; - outline-tree2がないとバイトコンパイルできなかったのを修正
;; - インクリメンタルサーチ中にC-bを押した時の挙動をいろいろ変更
;; 
;; 2007.02.01
;; - マッチしたものを列挙するウィンドウの表示位置を上下左右から選べるようにした
;;   それに伴って*igsearch-window-bottom*を廃止し*igsearch-window-type*を追加
;; 
;; 2007.01.29
;; - インクリメンタルサーチ開始後すぐにigsearch-repeat-forward/backward出来るようにした
;; - C-rでigsearch-repeat-backwardした時に候補列挙するウィンドウが切れていたのを修正
;; 
;; 2006.12.28
;; - バッファ切り替え時に各バッファのカーソルより上の行を検索していなかったのを修正
;; - C-jを入力した時のエラーを修正
;; - typo修正
;; 
;; 2006.11.12
;; - olt2が表示されていない時はバッファ切り替えの順はバッファバーの順にした
;; - 何も入力せずにバッファを切り替えると無限ループになったのを修正
;; - バッファを切り替えた時にバッファバーの表示を更新できてなかったのを修正
;; - *grep-hook*が残っていたのを削除
;; - 候補列挙時に元のバッファのキーワードの色付けをコピーするようにした
;; 
;; 2006.11.11
;; - バッファの切り替えが出来るようにした
;; 
;; 2006.11.08
;; - 初版

;; 謝辞:
;;
;; - xyzzy付属のisearch.lとgrep.lを超参考にしました。
;; - 「tips/migemo で C-w」 (http://xyzzy.s53.xrea.com/wiki/index.php?cmd=read&page=tips%2Fmigemo%20%A4%C7%20C-w)
;;   をigsearch.l用に修正したものを一緒に配布させていただいています。
;;
;; 作者のTetsuya Kameiさん、matsushitaさんに感謝します。

;;; Code:

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "isearch"))

(provide "igsearch")
(in-package "editor")
(export '(*igsearch-attribute*
		  *igsearch-attribute-incremental*
		  *igsearch-grep*
		  *igsearch-grep-incremental*
		  *igsearch-separator*
		  *igsearch-grep-height*
		  *igsearch-window-type*
		  *igsearch-init-state*
		  *igsearch-init-ime-state*
		  *igsearch-escape-sequence*
		  *igsearch-next-buffer-use-olt2*
		  *igsearch-scanner-check-hook*
		  *igsearch-non-grep-buffer-name-list*
		  igsearch-delete-coloring
		  igsearch-forward
		  igsearch-backward))

;;; -----------------------------------------------------------------
;;; カスタマイズ用変数ここから
;;;     .xyzzyかsiteinite.l等に
;;;     (setf *igsearch-grep* t)
;;;     のように書いてください

;;; -----------------------------------------------------------------
;;; バッファの修飾
;;; -----------------------------------------------------------------
;;; nil  しない
;;; '(:foreground 8) ;文字色を8に
;;; '(:background 3 :bold t) ;背景色を3、太字
;;; 詳細はリファレンスの set-text-attribute を参照
(defvar *igsearch-attribute* '(:foreground 10 :bold t))

;;; -----------------------------------------------------------------
;;; バッファの修飾をインクリメンタルに
;;; -----------------------------------------------------------------
;;; t   する
;;; nil しない
(defvar *igsearch-attribute-incremental* t)

;;; -----------------------------------------------------------------
;;; 同一バッファ内の全候補列挙
;;; -----------------------------------------------------------------
;;; t   する
;;; nil しない
(defvar *igsearch-grep* t)

;;; -----------------------------------------------------------------
;;; 同一バッファ内の全候補列挙をしないバッファ名
;;; -----------------------------------------------------------------
;;; デフォルトで*igsearch-grep-buffer-name*が設定されているので
;;; pushnewを使うなどして追加してください
(defvar *igsearch-non-grep-buffer-name-list* nil)

;;; -----------------------------------------------------------------
;;; 同一バッファ内の全候補列挙をインクリメンタルに
;;; -----------------------------------------------------------------
;;; t   する  （文字を入力するたびに表示）
;;; nil しない（C-s/C-rを押して初めて表示）
(defvar *igsearch-grep-incremental* nil)

;;; -----------------------------------------------------------------
;;; 縦棒の修飾
;;; -----------------------------------------------------------------
(defvar *igsearch-separator* '(:foreground 3 :bold t))

;;; -----------------------------------------------------------------
;;; 候補を表示するバッファの高さ/幅
;;; -----------------------------------------------------------------
;;; 数字      高さ/幅
;;; それ以外  半分
(defvar *igsearch-grep-height* nil)

;;; -----------------------------------------------------------------
;;; 候補を表示するバッファの位置
;;; -----------------------------------------------------------------
;;; top
;;; bottom
;;; right
;;; left
(defvar *igsearch-window-type* "bottom")

;;; -----------------------------------------------------------------
;;; 検索方法の初期値
;;; -----------------------------------------------------------------
;;; :migemo  Migemo検索
;;; :approx  曖昧検索
;;; :regexp  正規表現
;;; 上記以外 通常検索
(defvar *igsearch-init-state* nil)

;;; -----------------------------------------------------------------
;;; IMEの初期値
;;; -----------------------------------------------------------------
;;; t   オン
;;; nil オフ
(defvar *igsearch-init-ime-state* nil)

;;; -----------------------------------------------------------------
;;; エスケープシーケンスを理解(する|しない) の初期値
;;; -----------------------------------------------------------------
;;; t   理解する
;;; nil 理解しない
(defvar *igsearch-escape-sequence* nil)

;;; -----------------------------------------------------------------
;;; バッファ切り替えの順番
;;; -----------------------------------------------------------------
;;; t   outline-tree2の順
;;; nil バッファバーの順
(defvar *igsearch-next-buffer-use-olt2* nil)

;;; -----------------------------------------------------------------
;;; バッファ切り替え(C-bの方)で使う関数
;;; -----------------------------------------------------------------
;;; 引数を一つ取る関数などを指定してください。
;;; 入力していた文字列が渡されます。
;;; funcallで呼ばれます。
(defvar *igsearch-switch-buffer-hook* nil)

;;; -----------------------------------------------------------------
;;; バッファ切り替え(C-bの方)でiswitchbを使う
;;; -----------------------------------------------------------------
;;; wikiの方じゃなくてNetInstaller又はMegahurtzから入手できる方(= elispを使う方)
;;; を使うことを明示したい人用
(defvar *igsearch-iswitchb-elisp* nil)

;;; -----------------------------------------------------------------
;;; ミニバッファのヒストリを表示するときの区切り
;;; -----------------------------------------------------------------
;;; 半角ハイフンの連続、＿、￣、は
;;; lineをmigemoで変換したものにマッチするのでそれ以外で。
;;; なるべく普通の入力方法ではマッチしない文字がよろしいかと。
;;; 
;;; (make-sequence 'string (truncate (window-columns) 2) :initial-element #\)
;;; "－・－・－・－・－・－・－・－・－・－・－・－・－・－－・－・－・－・－"
;;; "#|((((((((((((((((((((((((((((((((( 亀 )))))))))))))))))))))))))))))))))|#"
(defvar *igsearch-minibuffer-candidate-splitter*
  (make-sequence 'string (truncate (window-columns) 2) :initial-element #\))

;;; -----------------------------------------------------------------
;;; ↑の色
;;; -----------------------------------------------------------------
;;; nil なら色付けしない(しない方が早い)
;;; '(:foreground 2)
(defvar *igsearch-minibuffer-candidate-splitter-attribute*
  nil)

;;; カスタマイズ用変数ここまで
;;; -----------------------------------------------------------------

;;; keybind
(define-key *isearch-map* '(#\ESC #\ESC) 'isearch-search-or-exit)
(define-key *isearch-map* #\C-m          'igsearch-exit)
(define-key *isearch-map* #\\            'igsearch-insert-backslash)
(define-key *isearch-map* #\C-q          'igsearch-quote-char)
(define-key *isearch-map* #\C-y          'igsearch-yank)
(define-key *isearch-map* #\C-g          'igsearch-abort)
(define-key *isearch-map* #\C-h          'igsearch-delete-char)
(define-key *isearch-map* #\C-d          'igsearch-real-delete-char)
(define-key *isearch-map* #\C-f          'igsearch-yank-char)
(define-key *isearch-map* #\C-o          'igsearch-grep-window)
(define-key *isearch-map* #\C-t          'igsearch-toggle-method)
(define-key *isearch-map* #\C-r          'igsearch-repeat-backward)
(define-key *isearch-map* #\C-s          'igsearch-repeat-forward)
(define-key *isearch-map* #\C-w          'igsearch-yank-word)
(define-key *isearch-map* #\C-<          'igsearch-case-fold-rotate)
(define-key *isearch-map* #\C->          'igsearch-escape-sequence-toggle)
(define-key *isearch-map* #\C-\,         'igsearch-prev-buffer)
(define-key *isearch-map* #\C-.          'igsearch-next-buffer)
(define-key *isearch-map* #\LFD          'igsearch-self-insert)
(define-key *isearch-map* #\C-b          'igsearch-switch-buffer)
(define-key *isearch-map* #\S-Insert     'igsearch-paste-from-clipboard)
(define-key *isearch-map* #\M-t          'igsearch-toggle-grep)
(define-key *isearch-map* #\M-c          'igsearch-refresh-highlight-toggle)
(define-key *isearch-map* #\M-m          'igsearch-migemo-toggle)
(define-key *isearch-map* #\M-r          'igsearch-regexp-toggle)
(define-key *isearch-map* #\M-a          'igsearch-approx-toggle)
(define-key *isearch-map* #\M-p          'isearch-search-history-backward)
(define-key *isearch-map* #\M-n          'isearch-search-history-forward)

(defun igsearch-switch-buffer ()
  (let ((str *isearch-current-string*))
	(unwind-protect
		(isearch-exit)
	  (cond (*igsearch-switch-buffer-hook*
			 (funcall *igsearch-switch-buffer-hook* str))
			(t
			 (let* ((lst (remove-if #'(lambda (x) (string-match "^ " x)) (mapcar 'buffer-name (buffer-list))))
					(match1 (remove-if-not #'(lambda (x) (string-match (concat "^" (regexp-quote str)) x)) lst))
					(match2 (remove-if-not #'(lambda (x) (string-match (regexp-quote str) x)) lst)))
			   (cond ((and match1 (null (cdr match1)))
					  (switch-to-buffer (first match1)))
					 ((and match2 (null (cdr match2)))
					  (switch-to-buffer (first match2)))
					 ((or *igsearch-iswitchb-elisp*
						  (and (modulep "iswitchb") ;; NetInstaller 経由の iswitchb
							   (find "iswitchb"
									 (mapcar #'(lambda (x) (cdr (assoc "name" x :test 'equal)))
											 (eval (intern "*install-data*" "netinst")))
									 :test 'equal)))
					  (setf *igsearch-iswitchb-string* str)
					  (add-hook (intern "iswitchb-minibuffer-setup-hook" "elisp")
								'igsearch-iswitchb-init)
					  (funcall (intern "iswitchb-buffer" "elisp")))
					 ((modulep "outline-tree/outline-tree")
					  (funcall (intern "outline-tree-isearch-forward" "outline-tree2")))
					 (t
					  (switch-to-buffer (read-exist-buffer-name "Switch to buffer: " :default str))))))))))
(defvar *igsearch-iswitchb-string* nil)
(defun igsearch-iswitchb-init ()
  (delete-hook (intern "iswitchb-minibuffer-setup-hook" "elisp")
			   'igsearch-iswitchb-init)
  (insert *igsearch-iswitchb-string*)
  (setf *igsearch-iswitchb-string* nil))

(defmacro do-while (test &body body)
  `(progn
     ,@body
     (do ()
	 ((not ,test))
       ,@body)))

(defun igsearch-olt2-p ()
  (and *igsearch-next-buffer-use-olt2*
       (modulep "outline-tree/outline-tree")
       (eval (intern "*outline-tree-use*" "outline-tree2"))))

(defun igsearch-next-buffer (&optional prev)
  (when (and *igsearch-minibuffer-list-buffer*
			 (not *executing-macro*));; ミニバッファで履歴を探してる時はバッファ移動しないよーに
	(message "バッファの移動は出来ません"))
  (when (and (not (equal *isearch-current-string* ""))
			 (not *igsearch-minibuffer-list-buffer*))
	(igsearch-delete-coloring)
	(when *igsearch-winconf*
	  (set-window-configuration *igsearch-winconf*)
	  (setf *igsearch-winconf* nil))
	(do-while
	 (and (save-excursion
			(goto-char (point-min))
			(not (isearch-scanner *isearch-current-string* nil))))
	 (cond ((igsearch-olt2-p)
			(if prev
				(funcall (intern "outline-tree-previous-buffer" "outline-tree2"))
			  (funcall (intern "outline-tree-next-buffer" "outline-tree2"))))
		   (t
			(if prev
				(previous-buffer)
			  (next-buffer)))))
	(goto-char (match-beginning 0))
	(when (igsearch-olt2-p)
	  (funcall (intern "outline-tree-select-node-by-buffer" "outline-tree2") (selected-buffer)))
	(unless *executing-macro*
	  (refresh-screen 1))
	(when *igsearch-attribute-incremental*
	  (igsearch-delete-coloring)
	  (igsearch-coloring t))))
(defun igsearch-prev-buffer ()
  (igsearch-next-buffer t))

(global-set-key #\C-s 'igsearch-forward)
(global-set-key #\C-r 'igsearch-backward)

(defvar *igsearch-beginning-buffr* nil)

;;; grep buffer/window
(defvar *igsearch-grep-buffer-name* " *igsearch*")
(pushnew *igsearch-grep-buffer-name* *igsearch-non-grep-buffer-name-list* :test 'equal)
(defvar *igsearch-orig-buffer* nil)
(defvar *igsearch-last-pattern* nil)
(defvar *igsearch-last-type* nil)
(defvar-local *igsearch-winconf* nil)

;;; state
(defvar *igsearch-orig-ime-state* nil)
(defvar *igsearch-orig-approx-state* nil)
(defvar *igsearch-orig-migemo-state* nil)
(defvar *igsearch-regexp-state* nil)
(defvar *igsearch-refresh-highlight* t)
(defvar-local igsearch-coloring nil)
(defvar-local igsearch-orig-attributes nil)

;;; hook
(defvar *igsearch-scanner-check-hook* nil)

;;; mode line
(defvar *igsearch* nil)
(defvar *igsearch-escape-sequence* nil)
(defvar *igsearch-type-string* nil)
(defvar *igsearch-mode-line* nil)
(defvar *igsearch-case-fold-string* "I-Normal")
(defvar *igsearch-escape-sequence-string* "")
(defvar *igsearch-repeat-soon* nil)

;;; minibuffer?
(defvar *igsearch-minibuffer* nil)
(defvar *igsearch-minibuffer-list-buffer* nil)
(defvar *igsearch-minibuffer-orig-buffer* nil)

(pushnew '(*igsearch* . *igsearch-mode-line*) *minor-mode-alist* :key #'car)

(defmacro asynchronous-while ((test &optional (interval 500)) &body body)
  (let ((func (gensym))
	(last (gensym)))
    `(let ((,last 0) ,func)
       (setf (symbol-function ',func)
	     #'(lambda ()
		 (when ,test
		   (when (> (- (get-internal-real-time) ,last) ,interval)
		     ,@body
		     (setf ,last (get-internal-real-time)))
		   (start-timer 0 ',func t))))
       (start-timer 0 ',func t))))

(defun igsearch-toggle-mode-line (&optional (arg nil sv))
  (toggle-mode '*igsearch* arg sv)
  (igsearch-update-mode-line))

(defun igsearch-update-mode-line ()
  (setf *igsearch-case-fold-string*
	(cond ((eq *case-fold-search* :smart) "Case")
	      ((not *case-fold-search*) "CASE")
	      (t "case")))
  (setf *igsearch-escape-sequence-string*
	(if *igsearch-escape-sequence* "ESC" "esc"))
  (setf *igsearch-mode-line*
	(concat *igsearch-type-string*
		"[" *igsearch-case-fold-string*
		":" *igsearch-escape-sequence-string* "]"))
  (when (and (not *executing-macro*)
			 (not *igsearch-minibuffer*))
	(update-mode-line)
	(with-selected-window
	  (other-window)
	  (update-mode-line))))
(igsearch-update-mode-line)

;;; case fold
(defun igsearch-case-fold-rotate ()
  "t -> smart -> nil" ;; マッチする候補が多い順(?)
  (setf *case-fold-search*
	(cond ((eq *case-fold-search* :smart) nil)
	      ((not *case-fold-search*) t)
	      (t :smart)))
  (igsearch-update-mode-line))

;;; escape sequence
(defun igsearch-escape-sequence-toggle (&optional (arg nil sv))
  (toggle-mode '*igsearch-escape-sequence* arg sv)
  (igsearch-update-mode-line))

;;; migemo
(defun igsearch-migemo-p ()
  (modulep "migemo"))
(defun igsearch-migemo-toggle (&optional (arg nil sv))
  (when (igsearch-migemo-p)
	(when (igsearch-approx-on)
	  (igsearch-approx-toggle))
	(when *igsearch-regexp-state*
	  (igsearch-regexp-toggle1))
	(if sv
		(funcall (intern "migemo-toggle" "editor") arg)
	  (funcall (intern "migemo-toggle" "editor")))
	(unless *executing-macro*
	  (clear-message))
	(setf *igsearch-type-string* (concat "I-" (if (igsearch-migemo-on) "Migemo" "Normal")))
	(unless (igsearch-migemo-on)
	  (setf *isearch-scanner-hook* nil))
	(igsearch-update-mode-line)))

(defun igsearch-migemo-on ()
  (when (igsearch-migemo-p)
    (eval (intern "*migemo-on*" "editor"))))

;;; approx
(defun igsearch-approx-p ()
  (modulep "approx-search"))

(defun igsearch-approx-toggle (&optional (arg nil sv))
  (when (igsearch-approx-p)
    (when (igsearch-migemo-on)
      (igsearch-migemo-toggle))
    (when *igsearch-regexp-state*
      (igsearch-regexp-toggle))
    (if sv
	(funcall (intern "approx-toggle") arg)
      (funcall (intern "approx-toggle")))
	(unless *executing-macro*
	  (clear-message))
    (setf *igsearch-type-string* (concat "I-" (if (igsearch-approx-on) "Approx" "Normal")))
    (unless (igsearch-approx-on)
      (setf *isearch-scanner-hook* nil))
    (igsearch-update-mode-line)))

(defun igsearch-approx-on ()
  (when (igsearch-approx-p)
    (eval (intern "*approx-on*" "editor"))))

;;; regexp
(defun igsearch-regexp-search (pattern)
  (setf *isearch-regexp* t)
  pattern)

(defun igsearch-insert-backslash ()
  (when *igsearch-regexp-state*
	(igsearch-regexp-toggle))
  (igsearch-self-insert))

(defun igsearch-regexp-toggle1 (&optional (arg nil sv))
  (toggle-mode '*igsearch-regexp-state* arg sv))

(defun igsearch-regexp-toggle (&optional (arg nil sv))
  (interactive "p")
  (when (igsearch-migemo-on)
	(igsearch-migemo-toggle))
  (when (igsearch-approx-on)
	(igsearch-approx-toggle))
  (if sv
	  (igsearch-regexp-toggle1 arg)
	(igsearch-regexp-toggle1))
  (setf *isearch-scanner-hook* (when *igsearch-regexp-state*
								 #'igsearch-regexp-search)
		*igsearch-type-string* (concat "I-" (if *igsearch-regexp-state* "Regexp" "Normal")))
  (igsearch-update-mode-line))

;;; normal
(defun igsearch-normal ()
  (interactive)
  (cond ((igsearch-migemo-on)
	 (igsearch-migemo-toggle))
	((igsearch-approx-on)
	 (igsearch-approx-toggle))
	(*igsearch-regexp-state*
	 (igsearch-regexp-toggle))))

(defun igsearch-toggle-method ()
  "regexp -> migemo -> approx -> normal"
  (interactive)
  (let (current)
	(cond (*igsearch-regexp-state*
		   (cond ((igsearch-migemo-p)
				  (setf current "migemo")
				  (igsearch-migemo-toggle))
				 ((igsearch-approx-p)
				  (setf current "approx")
				  (igsearch-approx-toggle))
				 (t
				  (setf current "normal")
				  (igsearch-regexp-toggle))))
		  ((igsearch-migemo-on)
		   (cond ((igsearch-approx-p)
				  (setf current "approx")
				  (igsearch-approx-toggle))
				 (t
				  (setf current "normal")
				  (igsearch-migemo-toggle))))
		  ((igsearch-approx-on)
		   (setf current "normal")
		   (igsearch-approx-toggle))
		  (t
		   (setf current "regexp")
		   (igsearch-regexp-toggle)))
	(unless *executing-macro*
	  (message (substitute-string
				(cond ((and (igsearch-migemo-p)
							(igsearch-approx-p))
					   "regexp > migemo > approx > normal")
					  ((and (igsearch-migemo-p)
							(not (igsearch-approx-p)))
					   "regexp > migemo > normal")
					  ((and (not (igsearch-migemo-p))
							(igsearch-approx-p))
					   "regexp > approx > normal")
					  ((and (not (igsearch-migemo-p))
							(not (igsearch-approx-p)))
					   "regexp > normal"))
				current
				(string-upcase current)))
	  (stop-timer 'clear-message)
	  (start-timer 2 'clear-message t))))

;;; yank
(defun igsearch-forward-point ()
  (+ (point)
     (length *isearch-current-match-string*)))

(defun igsearch-yank ()
  (let ((x (current-kill 0)))
    (if (and *isearch-smart-case*
	     (eq *case-fold-search* :smart)
	     (not (string-match "[A-Z]" *isearch-current-string*)))
	(setq x (mapcar #'string-downcase x)))
    (igsearch-push-status)
    (isearch-scanner1 (apply #'concat *isearch-current-string* x) nil)))

(defun igsearch-yank-char ()
  (let* ((start (if (igsearch-migemo-on)
		    (point)
		  (+ (point) (length *isearch-current-string*))))
	 (end (if (igsearch-migemo-on)
		  (1+ (igsearch-forward-point))
		(save-excursion
		  (goto-char start)
		  (1+ (point)))))
	 (next-word (buffer-substring start end)))
    (when (igsearch-migemo-on)
      (setf *isearch-current-string* next-word))
    (if (and *isearch-smart-case*
	     (eq *case-fold-search* :smart)
	     (not (string-match "[A-Z]" *isearch-current-string*)))
	(setf next-word (string-downcase next-word)))
    (igsearch-push-status)
    (cond ((igsearch-migemo-on)
	   (igsearch-migemo-toggle nil)
	   (isearch-scanner1 next-word nil))
	  (t
	   (isearch-scanner1 (concat *isearch-current-string* next-word) nil)))
    (when *igsearch-attribute-incremental*
      (igsearch-delete-coloring)
      (igsearch-coloring t))))

(defun igsearch-yank-word ()
  (let* ((start (if (igsearch-migemo-on)
		    (point)
		  (+ (point) (length *isearch-current-string*))))
	 (end (if (igsearch-migemo-on)
		  (save-excursion
		    (goto-char
		     (igsearch-forward-point))
		    (forward-word)
		    (point))
		(save-excursion
		  (goto-char start)
		  (forward-word)
		  (point))))
	 (next-word (buffer-substring start end)))
    (when (igsearch-migemo-on)
      (setf *isearch-current-string* next-word))
    (if (and *isearch-smart-case*
	     (eq *case-fold-search* :smart)
	     (not (string-match "[A-Z]" *isearch-current-string*)))
	(setf next-word (string-downcase next-word)))
    (igsearch-push-status)
    (cond ((igsearch-migemo-on)
	   (igsearch-migemo-toggle nil)
	   (isearch-scanner1 next-word nil))
	  (t
	   (isearch-scanner1 (concat *isearch-current-string* next-word) nil)))
    (when *igsearch-attribute-incremental*
      (igsearch-delete-coloring)
      (igsearch-coloring t))))

(defun igsearch-keep-function ()
  (let ((last-match (match-data))
		res)
	(save-excursion
	  (goto-bol)
	  (setf res (scan-buffer "defun" :limit (save-excursion (goto-eol) (point))))
	  (store-match-data last-match))
    res))

;;; defun
;(add-hook '*igsearch-scanner-check-hook* 'igsearch-keep-function)
;(delete-hook '*igsearch-scanner-check-hook* 'igsearch-keep-function)
;(setf *igsearch-scanner-check-hook* 'igsearch-keep-function)
(setf *igsearch-scanner-check-hook* nil)

(defun isearch-scanner1 (string no-dup)
  (with-set-buffer
	(when *igsearch-minibuffer-list-buffer*
	  (set-buffer *igsearch-minibuffer-list-buffer*))
	(let ((*isearch-regexp* nil)
		  (pattern string))
	  (when *isearch-scanner-hook*
		(setq pattern (funcall *isearch-scanner-hook* pattern)))
	  (setq *isearch-current-string* string)
	  (setq *isearch-last-match*
			(if (and (scan-buffer pattern
								  :reverse (not *isearch-direction*)
								  :no-dup no-dup
								  :regexp *isearch-regexp*
								  :case-fold *case-fold-search*)
					 (setq *isearch-current-match-string* (match-string 0))
					 (if *igsearch-scanner-check-hook*
						 (funcall *igsearch-scanner-check-hook*)
					   t))
				t
			  (progn
				(setq *isearch-current-match-string* nil)
				(ding)
				nil)))
	  *isearch-last-match*)))

;;;
;;; status
;;;
(defun igsearch-push-status ()
  (push (list (selected-buffer) (point) *isearch-direction* *isearch-last-match*
			  *isearch-current-string* *isearch-wrapped*)
		*isearch-status*))

(defun igsearch-pop-status ()
  (let ((x (pop *isearch-status*)))
	(unless (equal (selected-buffer) (first x))
	  (handler-case
		  (set-buffer (first x))
		(error (c)
		  (msgbox "error:\t ~a~%~S" (si:*condition-string c) x )))
	  (and *igsearch-next-buffer-use-olt2*
		   (modulep "outline-tree/outline-tree")
		   (funcall (intern "outline-tree-select-node-by-buffer" "outline-tree2")
					(selected-buffer))))
	(goto-char (second x))
	(setq *isearch-direction* (third x)
		  *isearch-last-match* (fourth x)
		  *isearch-current-string* (fifth x)
		  *isearch-wrapped* (sixth x))))

(defun igsearch-paste-from-clipboard ()
  (let ((x (get-clipboard-data)))
    (when x
      (igsearch-push-status)
      (isearch-scanner1 (concat *isearch-current-string* x) nil))))

(defun igsearch-quote-char ()
  (let ((c (quote-char-read)))
    (igsearch-push-status)
    (isearch-scanner1 (concat *isearch-current-string* (string c)) nil)))

;;; minibuffer
(defun igsearch-exit ()
  (when *igsearch-minibuffer*
	(let (res)
	  (with-set-buffer
		(set-buffer *igsearch-minibuffer-list-buffer*)
		(setf res (buffer-substring
				   (progn (goto-bol) (point))
				   (cond ((scan-buffer *igsearch-minibuffer-candidate-splitter*)
						  (1- (match-beginning 0)))
						 (t (goto-eol)
							(point))))))
	  (unless (equal res "")
		(delete-region (point-min) (point-max))
		(insert res))))
  (unless (string= *isearch-current-string* "")
	(setq *last-search-string* *isearch-current-string*))
  (throw 'isearch-exit t))

(defun igsearch-minibuffer-set-keybind ()
  (define-key *isearch-map* #\C-d          'igsearch-minibuffer-delete-history)
  (define-key *isearch-map* #\C-n          'igsearch-minibuffer-next-line)
  (define-key *isearch-map* #\Down         'igsearch-minibuffer-next-line)
  (define-key *isearch-map* #\C-p          'igsearch-minibuffer-prev-line)
  (define-key *isearch-map* #\Up           'igsearch-minibuffer-prev-line)
  (define-key *isearch-map* #\C-v          'igsearch-minibuffer-next-page)
  (define-key *isearch-map* #\PageDown     'igsearch-minibuffer-next-page)
  (define-key *isearch-map* #\M-v          'igsearch-minibuffer-prev-page)
  (define-key *isearch-map* #\PageUp       'igsearch-minibuffer-prev-page)
  (define-key *isearch-map* #\M->          'igsearch-minibuffer-end-of-buffer)
  (define-key *isearch-map* #\M-<          'igsearch-minibuffer-beginning-of-buffer)
  )

(defun igsearch-minibuffer-unset-keybind ()
  (define-key *isearch-map* #\C-d          'igsearch-real-delete-char)
  (undefine-key *isearch-map* #\C-n)
  (undefine-key *isearch-map* #\Down)
  (undefine-key *isearch-map* #\C-p)
  (undefine-key *isearch-map* #\Up)
  (undefine-key *isearch-map* #\C-v)
  (undefine-key *isearch-map* #\PageDown)
  (undefine-key *isearch-map* #\M-v)
  (undefine-key *isearch-map* #\PageUp)
  (undefine-key *isearch-map* #\M->)
  (undefine-key *isearch-map* #\M-<))

(defun igsearch-minibuffer-delete-history ()
  (let (from to str)
	(with-set-buffer
	  (save-excursion
		(setf from (save-excursion
					 (if (scan-buffer *igsearch-minibuffer-candidate-splitter* :reverse t)
						 (1+ (match-end 0))
					   (point-min)))
			  to (save-excursion
				   (if (scan-buffer *igsearch-minibuffer-candidate-splitter*)
					   (1- (match-beginning 0))
					 (point-max))))
		(and from to
			 (setf str (buffer-substring from to)))
		(delete-region from
					   (save-excursion
						 (if (scan-buffer *igsearch-minibuffer-candidate-splitter*)
							 (1+ (match-end 0))
						   (point-max))))))
	(setf minibuffer-current-history (remove str minibuffer-current-history :test 'equal))
	(set minibuffer-current-history-variable minibuffer-current-history)))

(defun igsearch-minibuffer-next-line ()
  (cond ((equal *isearch-current-string* "")
		 (with-set-buffer
		   (let ((str *igsearch-minibuffer-candidate-splitter*))
			 (set-buffer *igsearch-minibuffer-list-buffer*)
			 (do nil
				 ((or (equal str (buffer-substring
								  (save-excursion (goto-bol) (point))
								  (save-excursion (goto-eol) (point))))
					  (eobp)))
			   (next-line))
			 (next-line)
			 (goto-bol)
			 (setf *isearch-current-match-string* "")
			 (save-excursion
			   (igsearch-delete-coloring)
			   (apply 'set-text-attribute
					  (progn (goto-bol) (point))
					  (cond ((scan-buffer str)
							 (match-beginning 0))
							(t (goto-eol)
							   (point)))
					  'igsearch
					  *igsearch-attribute*)))))
		(*isearch-current-string*
		 (let ((*isearch-current-string* (if *igsearch-escape-sequence*
											 (decode-escape-sequence *isearch-current-string* nil)
										   *isearch-current-string*))
			   (*isearch-this-command* 'isearch-repeat-forward))
		   (igsearch-repeat-forward1))
		 (when *isearch-last-match*
		   (igsearch-coloring t)
		   (igsearch-show-candidate)))))

(defun igsearch-minibuffer-next-page ()
  (cond ((equal *isearch-current-string* "")
		 (with-set-buffer
		   (let ((str *igsearch-minibuffer-candidate-splitter*))
			 (set-buffer *igsearch-minibuffer-list-buffer*)
			 (when (next-page)
			   (igsearch-minibuffer-next-line)))))
		(*isearch-current-string*
		 (igsearch-minibuffer-next-line))))

(defun igsearch-minibuffer-end-of-buffer ()
  (cond ((equal *isearch-current-string* "")
		 (with-set-buffer
		   (let ((str *igsearch-minibuffer-candidate-splitter*))
			 (set-buffer *igsearch-minibuffer-list-buffer*)
			 (when (goto-char (point-max))
			   (igsearch-minibuffer-next-line)))))
		(*isearch-current-string*
		 (igsearch-minibuffer-next-line))))

(defun igsearch-minibuffer-prev-line ()
  (cond ((equal *isearch-current-string* "")
		 (with-set-buffer
		   (let ((str *igsearch-minibuffer-candidate-splitter*))
			 (set-buffer *igsearch-minibuffer-list-buffer*)
			 (previous-line 2)
			 (let (bob)
			   (do nil
				   ((or (and (bobp) (setf bob t))
						(equal str (buffer-substring
									(save-excursion (goto-bol) (point))
									(save-excursion (goto-eol) (point))))))
				 (previous-line))
			   (unless bob
				 (next-line)))
			 (goto-bol)
			 (setf *isearch-current-match-string* "")
			 (save-excursion
			   (igsearch-delete-coloring)
			   (apply 'set-text-attribute
					  (progn (goto-bol) (point))
					  (cond ((scan-buffer str)
							 (match-beginning 0))
							(t (goto-eol)
							   (point)))
					  'igsearch
					  *igsearch-attribute*)))))
		(*isearch-current-string*
		 (let ((*isearch-current-string* (if *igsearch-escape-sequence*
											 (decode-escape-sequence *isearch-current-string* nil)
										   *isearch-current-string*))
			   (*isearch-this-command* 'isearch-repeat-backward))
		   (igsearch-repeat-forward1))
		 (when *isearch-last-match*
		   (igsearch-coloring t)
		   (igsearch-show-candidate)))))

(defun igsearch-minibuffer-prev-page ()
  (cond ((equal *isearch-current-string* "")
		 (with-set-buffer
		   (let ((str *igsearch-minibuffer-candidate-splitter*))
			 (set-buffer *igsearch-minibuffer-list-buffer*)
			 (when (previous-page)
			   (igsearch-minibuffer-prev-line)))))
		(*isearch-current-string*
		 (igsearch-minibuffer-prev-line))))

(defun igsearch-minibuffer-beginning-of-buffer ()
  (cond ((equal *isearch-current-string* "")
		 (with-set-buffer
		   (let ((str *igsearch-minibuffer-candidate-splitter*))
			 (set-buffer *igsearch-minibuffer-list-buffer*)
			 (when (goto-char (point-min))
			   (igsearch-minibuffer-prev-line)))))
		(*isearch-current-string*
		 (igsearch-minibuffer-prev-line))))

;;; igsearch
(defun igsearch-forward (&optional reverse)
  (interactive)
  (igsearch-toggle-mode-line t)
  (igsearch-delete-coloring)
  (setf *igsearch-orig-migemo-state* (igsearch-migemo-on)
		*igsearch-orig-approx-state* (igsearch-approx-on)
		*igsearch-orig-ime-state* (get-ime-mode))
  (toggle-ime *igsearch-init-ime-state*)
  (cond ((and (eq *igsearch-init-state* :migemo)
			  (igsearch-migemo-p))
		 (igsearch-migemo-toggle t))
		((and (eq *igsearch-init-state* :approx)
			  (igsearch-approx-p))
		 (igsearch-approx-toggle t))
		((eq *igsearch-init-state* :regexp)
		 (igsearch-regexp-toggle t))
		(t (igsearch-normal)))
  (setf igsearch-orig-attributes (list-text-attributes))
  (let ((*isearch-current-string* "")
		(*igsearch-minibuffer* (eq (selected-window) (minibuffer-window)))
		(*isearch-current-match-string* nil)
		(*isearch-last-match* t)
		(*isearch-no-clear* nil)
		(*isearch-history-index* -1)
		(*isearch-last-history* nil)
		(*isearch-history-last-string* nil)
		(*isearch-this-command* nil)
		(*isearch-last-command* nil)
		(*isearch-wrapped* nil)
		(*isearch-status* nil)
		(*isearch-direction* (not reverse))
		(*igsearch-beginning-buffr* (selected-buffer))
		(*igsearch-orig-grep* *igsearch-grep*)
		*igsearch-minibuffer-list-buffer*
		*igsearch-minibuffer-orig-buffer*
		*igsearch-minibuffer-orig-winconf*
		keymap (keymapview ""))
	(when *igsearch-minibuffer*
	  (let* ((buf (get-buffer-create " *igsearch minibuffer*")))
		(igsearch-minibuffer-set-keybind)
		(erase-buffer buf)
		(with-output-to-buffer (buf)
		  (dolist (x minibuffer-current-history)
			(format t "~A~%~A~%" x *igsearch-minibuffer-candidate-splitter*)))
		(with-set-buffer
		  (setf *igsearch-minibuffer-orig-winconf* (current-window-configuration))
		  (delete-other-windows)
		  (setf *igsearch-minibuffer-orig-buffer* (selected-buffer))
		  (when *igsearch-minibuffer-candidate-splitter-attribute*
			(set-buffer buf)
			(save-excursion
			  (goto-char (point-min))
			  (while (scan-buffer *igsearch-minibuffer-candidate-splitter* :no-dup t)
				(apply 'set-text-attribute
					   (match-beginning 0)
					   (match-end 0)
					   'splitter
					   *igsearch-minibuffer-candidate-splitter-attribute*)
				))))
		(setf *igsearch-minibuffer-list-buffer* buf)))
	(setf *last-search-regexp-p* nil)
	(when *igsearch-repeat-soon*
	  (if reverse
		  (funcall 'igsearch-repeat-backward)
		(funcall 'igsearch-repeat-forward))
	  (setf *igsearch-repeat-soon* nil))
	(unwind-protect
		(catch 'isearch-exit
		  (loop
			(with-set-buffer
			  (when *igsearch-minibuffer-list-buffer*
				(set-buffer *igsearch-minibuffer-list-buffer*))
			  (reverse-region (point)
							  (+ (point)
								 (if (and *isearch-last-match*
										  (not (eq *isearch-last-command*
												   'isearch-search-history-forward)))
									 (max (length *isearch-current-match-string*) 1)
								   1))
							  t))
			(unless *executing-macro*
			  (minibuffer-prompt "~:[Failing ~;~]~:[~;Wrapped ~]I-search~:[ backward~;~]: ~a"
								 *isearch-last-match* *isearch-wrapped*
								 *isearch-direction* *isearch-current-string*))
			(let ((*isearch-command-char* (read-char *keyboard*)))
			  (setf *isearch-this-command* (lookup-keymap (or keymap *isearch-map*)
														  *isearch-command-char* t))
			  (cond ((keymapp *isearch-this-command*);prefix
					 (setf keymap *isearch-this-command*)
					 (setf keymapview
						   (concat keymapview (key-to-string *isearch-command-char*) " "))
					 (unless *executing-macro*
					   (message "~A-" keymapview)))
					(*isearch-this-command*
					 (when keymap
					   (setf keymapview
							 (concat keymapview (key-to-string *isearch-command-char*)))
					   (unless *executing-macro*
						 (message "~A" keymapview)))
					 (funcall *isearch-this-command*)
					 (setf keymap nil keymapview ""
						   *isearch-last-command* *isearch-this-command*))
					(t
					 (igsearch-self-insert *isearch-command-char*)
					 (setf keymap nil keymapview ""))))))
	  (when (or *igsearch-regexp-state*
				(igsearch-approx-on)
				(igsearch-migemo-on))
		(setf *last-search-regexp*
			  (funcall *isearch-scanner-hook* *isearch-current-string*))
		(setf *last-search-regexp-p* t))
	  (unless *isearch-no-clear*
		(unless *executing-macro*
		  (clear-reverse-region))
		(add-history *isearch-current-string* '*isearch-history*))
	  (unless (equal *igsearch-orig-grep* *igsearch-grep*)
		(setf *igsearch-grep* *igsearch-orig-grep*))
	  (save-excursion
		(cond (*igsearch-refresh-highlight*
			   (igsearch-delete-coloring)
			   (setf igsearch-orig-attributes nil))
			  (t (igsearch-coloring)))
		(with-set-buffer
		  (when *igsearch-minibuffer-list-buffer*
			(set-buffer *igsearch-minibuffer-list-buffer*))
		  (when *igsearch-winconf*
			(set-window-configuration *igsearch-winconf*)
			;(recenter)
			(setf *igsearch-winconf* nil))
		  (when *igsearch-minibuffer-orig-winconf*
			(igsearch-minibuffer-unset-keybind)
			(set-window-configuration *igsearch-minibuffer-orig-winconf*))))
	  ;; ここにrefresh-screenがないとC-s中にC-a等で終了した時に画面の最下部や最上部に飛んでしまう。なぜ。
	  (unless *executing-macro*
		(refresh-screen))
	  (when *igsearch-minibuffer-list-buffer*
		(with-set-buffer
		 (delete-buffer *igsearch-minibuffer-list-buffer*))
		(with-set-buffer
		  (set-buffer *igsearch-minibuffer-orig-buffer*)))
	  (cond (*igsearch-orig-migemo-state*
			 (igsearch-migemo-toggle t))
			(*igsearch-orig-approx-state*
			 (igsearch-approx-toggle t)))
	  (toggle-ime *igsearch-orig-ime-state*)
	  (igsearch-toggle-mode-line nil))))
(defun igsearch-backward ()
  (interactive)
  (igsearch-forward t))

(defun igsearch-abort ()
  (let ((last *isearch-last-match*)
		(curstr *isearch-current-string*))
	(loop
	  (unless *isearch-status*
		(unless (string= curstr "")
		  (setq *last-search-string* curstr))
		(quit))
	  (and (not last)
		   *isearch-last-match*
		   (return))
	  (igsearch-pop-status))))

(defvar *igsearch-mode* nil)

(defun igsearch-self-insert (&optional (ch *isearch-command-char*))
  (unless (or (member *isearch-this-command* '(igsearch-self-insert isearch-self-insert))
			  (graphic-char-p ch))
	(unread-char ch *keyboard*)
	(isearch-exit))
  (igsearch-push-status)
  (let ((str (concat *isearch-current-string* (string ch))))
	(case *igsearch-mode*
	  (:buffer-name )
	  (:frame )
	  (t
	   (and (prog1 (isearch-scanner1 (if *igsearch-escape-sequence*
										 (decode-escape-sequence str nil)
									   str)
									 nil)
			  (setf *isearch-current-string* str))
			*igsearch-grep-incremental*
			(igsearch-show-candidate))
	   (when *igsearch-attribute-incremental*
		 (igsearch-delete-coloring)
		 (igsearch-coloring t))))))

(defun igsearch-real-delete-char ()
  (unless (< (length *isearch-current-string*) 1)
    (setf *isearch-current-string*
	  (cond ((igsearch-migemo-on)
		 (igsearch-migemo-toggle nil)
		 (buffer-substring (point)
				   (igsearch-forward-point)))
		(t
		 (subseq *isearch-current-string* 0 (1- (length *isearch-current-string*)))))))
  (setf *isearch-this-command* 'isearch-search-history-forward)
  (when *igsearch-attribute-incremental*
    (igsearch-delete-coloring)
    (igsearch-coloring t)))

(defun igsearch-delete-char ()
  (if (or (eq *isearch-last-command* 'isearch-search-history-forward)
	  (not *isearch-status*))
      (let ((l (length *isearch-current-string*)))
	(if (zerop l)
	    (ding)
	  (setq *isearch-current-string* (subseq *isearch-current-string* 0 (- l 1))))
	(setq *isearch-this-command* 'isearch-search-history-forward))
    (igsearch-pop-status))
  (when *igsearch-attribute-incremental*
    (igsearch-delete-coloring)
    (igsearch-coloring t)))

(defun igsearch-scanner (pattern word-search)
  #'(lambda (&optional limit tail)
	  (let ((pos (point)))
		(and (scan-buffer pattern
						  :tail tail
						  :case-fold *case-fold-search*
						  :left-bound word-search
						  :right-bound word-search
						  :limit limit)
			 (if limit
				 (not (= pos (point)))
			   (if *igsearch-scanner-check-hook*
				   (funcall *igsearch-scanner-check-hook*)
				 t))))))

(defun igsearch-repeat-forward ()
  (interactive)
  (when (string= *isearch-current-string* "")
	(setf *isearch-current-string* *last-search-string*))
  (let ((*isearch-current-string* (if *igsearch-escape-sequence*
									  (decode-escape-sequence *isearch-current-string* nil)
									*isearch-current-string*))
		(*isearch-this-command* 'isearch-repeat-forward))
	(igsearch-repeat-forward1))
  (when *isearch-last-match*
	(igsearch-coloring t)
	(igsearch-show-candidate)))

(defun igsearch-repeat-forward1 ()
  (when (string= *isearch-current-string* "")
	(setq *isearch-current-string* *last-search-string*))
  (let ((last-dir *isearch-direction*)
		(no-wrap t))
	(setq *isearch-direction* (eq *isearch-this-command* 'isearch-repeat-forward))
	(unless (string= *isearch-current-string* "")
	  (igsearch-push-status)
	  (with-set-buffer
		(set-buffer *igsearch-minibuffer-list-buffer*)
		(or *isearch-last-match*
			(not (eq last-dir *isearch-direction*))
			(progn
			  (setq *isearch-wrapped* t no-wrap nil)
			  (goto-char (if *isearch-direction* (point-min) (point-max))))))
	  (isearch-scanner1 *isearch-current-string* no-wrap)
	  (and *isearch-wrapped*
		   (not *isearch-last-match*)
		   (goto-char (cadar *isearch-status*))))))

(defun igsearch-repeat-backward ()
  (interactive)
  (when (string= *isearch-current-string* "")
    (setf *isearch-current-string* *last-search-string*))
  (let ((*isearch-current-string* (if *igsearch-escape-sequence*
				      (decode-escape-sequence *isearch-current-string* nil)
				    *isearch-current-string*)))
    (igsearch-repeat-forward1))
  (when *isearch-last-match*
    (igsearch-coloring t)
    (igsearch-show-candidate)))

;;;
;;; coloring
;;;
(defun igsearch-delete-coloring ()
  (interactive)
  (setf igsearch-coloring nil)
  (with-set-buffer
	(when *igsearch-minibuffer-list-buffer*
	  (set-buffer *igsearch-minibuffer-list-buffer*))
	(delete-text-attributes 'igsearch)
	(when igsearch-orig-attributes
	  (dolist (attr igsearch-orig-attributes)
		(apply 'set-text-attribute attr)))
	t))

(defun igsearch-coloring (&optional visual)
  (when *igsearch-attribute*
	(with-set-buffer
	  (when *igsearch-minibuffer-list-buffer*
		(set-buffer *igsearch-minibuffer-list-buffer*))
	  (let ((pattern *isearch-current-string*)
			(*isearch-regexp* nil)
			start end scanner)
		(when *igsearch-escape-sequence*
		  (setf pattern (decode-escape-sequence pattern nil)))
		(when *isearch-scanner-hook*
		  (setf pattern (funcall *isearch-scanner-hook* pattern)))
		(when (and (not (regexpp pattern))
				   *isearch-regexp*)
		  (setf pattern (compile-regexp pattern *case-fold-search*)))
		(unless (or igsearch-coloring
					(and (equal *igsearch-last-type* *igsearch-mode-line*)
						 (equal *igsearch-last-pattern* pattern)))
		  (save-excursion
			(cond (visual
				   (refresh-screen);;;ここでしないとスクロールしてくれないので値がおかしくなる
				   (setf start (progn (goto-virtual-line (get-window-start-line))
								 (goto-bol) (point))
						 end (progn (goto-virtual-line (+ (window-height) (get-window-start-line)))
							   (goto-eol) (point))))
				  (t
				   (setf start (progn (goto-char (point-min)) (point))
						 end (progn (goto-char (point-max)) (point)))))
			(when (and pattern
					   (not (equal pattern "")))
			  (setf scanner (igsearch-scanner pattern *word-search*))
			  (goto-char start)
			  (unless visual
				(setf igsearch-coloring t))
			  (cond (visual
					 (while (funcall scanner end t)
					   (apply 'set-text-attribute
							  (match-beginning 0)
							  (match-end 0)
							  'igsearch
							  *igsearch-attribute*)))
					(t
					 (let ((point start)
						   (window (selected-window)))
					   (asynchronous-while
						((and igsearch-coloring
							  (with-selected-window
								(set-window window)
								(save-excursion
								  (goto-char point)
								  (funcall scanner end t)
								  (setf point (point)))))
						 0)
						(apply 'set-text-attribute
							   (match-beginning 0)
							   (match-end 0)
							   'igsearch
							   *igsearch-attribute*))))))))))))

(defun igsearch-refresh-highlight-toggle (&optional (arg nil sv))
  (interactive)
  (toggle-mode '*igsearch-refresh-highlight* arg sv)
  (unless *executing-macro*
	(message "highlight: ~A"
			 (if *igsearch-refresh-highlight* "clear" "remain"))))

(defun igsearch-toggle-grep (&optional (arg nil sv))
  (toggle-mode '*igsearch-grep* arg sv)
  (with-set-buffer
	(when *igsearch-minibuffer*
	  (set-buffer *igsearch-minibuffer-list-buffer*))
	(cond ((and (not *igsearch-grep*)
				*igsearch-winconf*)
		   (set-window-configuration *igsearch-winconf*)
		   (setf *igsearch-winconf* nil))
		  (t (igsearch-show-candidate)))))

(defun igsearch-grep-window ()
  (cond (*igsearch-minibuffer-list-buffer*
		 (unless *executing-macro*
		   (message "移動はできません")))
		(t *igsearch-winconf*
		   (igsearch-coloring)
		   (other-window)
		   (setf buffer-read-only t))))

(defun igsearch-show-candidate ()
  (when *igsearch-grep*
	(with-set-buffer
	  (when *igsearch-minibuffer-list-buffer*
		(set-buffer *igsearch-minibuffer-list-buffer*))
	  (unless (find (buffer-name (selected-buffer))
					*igsearch-non-grep-buffer-name-list* :test 'equal)
		(unless *igsearch-winconf*
		  (setf *igsearch-winconf* (current-window-configuration))
		  (delete-other-windows))
		(let ((pattern *isearch-current-string*)
			  (*isearch-regexp* nil))
		  (when *igsearch-escape-sequence*
			(setf pattern (decode-escape-sequence pattern (regexpp pattern))))
		  (when *isearch-scanner-hook*
			(setf pattern (funcall *isearch-scanner-hook* pattern)))
		  (and pattern
			   (not (equal pattern ""))
			   (igsearch-show-candidate1 pattern t)))))))

(defun igsearch-other-window-is-grep ()
  (save-window-excursion
    (and (= 2 (count-windows))
	 (other-window)
	 (equal (selected-buffer) (find-buffer *igsearch-grep-buffer-name*)))))

(defun igsearch-show-candidate1 (regexp &optional arg)
  (long-operation
	(and arg
		 (setf arg (selected-buffer)))
	(let ((line (current-line-number))
		  (bufname (buffer-name (selected-buffer)))
		  (syntax (syntax-table))
		  keyword first-time)
	  (when (local-variable-p 'keyword-hash-table)
		(setq keyword keyword-hash-table))
	  (cond ((and (= 2 (count-windows))
				  (igsearch-other-window-is-grep)
				  (equal *igsearch-last-type* *igsearch-mode-line*)
				  (equal *igsearch-last-pattern* regexp))
			 (other-window))
			(t
			 (setf first-time t)
			 (when (/= 1 (count-windows))
			   (delete-other-windows))
			 (cond ((equal *igsearch-window-type* "bottom")
					(split-window (when (numberp *igsearch-grep-height*)
									(- 0 *igsearch-grep-height*)) nil))
				   ((equal *igsearch-window-type* "top")
					(split-window *igsearch-grep-height* nil))
				   ((equal *igsearch-window-type* "right")
					(split-window (when (numberp *igsearch-grep-height*)
									(- 0 *igsearch-grep-height*)) t))
				   ((equal *igsearch-window-type* "left")
					(split-window *igsearch-grep-height* t)))
			 (let ((coordinate (window-coordinate)))
			   (when (find *igsearch-window-type* '("top" "left") :test 'equal)
				 (other-window))
			   (when (= 0 (first coordinate) (second coordinate))
				 (other-window)))
			 (set-buffer (get-buffer-create *igsearch-grep-buffer-name*))
			 (kill-all-local-variables)
			 (setf *igsearch-grep-current-stirng* *isearch-current-string*)
			 (use-syntax-table syntax)
			 (make-local-variable 'keyword-hash-table)
			 (setf keyword-hash-table keyword)
			 (make-local-variable 'need-not-save)
			 (setf need-not-save t)
			 (use-keymap *igsearch-mode-map*)
			 (with-output-to-buffer ((get-buffer-create *igsearch-grep-buffer-name*))
			   (erase-buffer (selected-buffer))
			   (setf *igsearch-last-pattern* regexp)
			   (setf *igsearch-last-type* *igsearch-mode-line*)
			   (when *igsearch-escape-sequence*
				 (setf regexp (decode-escape-sequence regexp (regexpp regexp))))
			   (when (and (not (regexpp regexp))
						  *isearch-regexp*)
				 (setf regexp (compile-regexp regexp *case-fold-search*)))
			   (let ((sbuffer (buffer-stream-buffer *standard-output*))
					 (scanner (igsearch-scanner regexp *word-search*)))
				 (save-excursion
				   (set-buffer sbuffer)
				   (setf *igsearch-grep-mode-scanner* scanner)
				   (make-local-variable 'buffer-read-only)
				   (setf buffer-read-only nil)
				   (set-buffer-fold-width nil sbuffer)
				   (dolist (buffer (if arg (list arg)
									 (remove-if #'(lambda (buf)
													(string-match "^ " (buffer-name buf)))
												(buffer-list))))
					 (let ((bufname (buffer-name buffer)))
					   (unless (eq buffer sbuffer)
						 (set-buffer buffer)
						 (save-excursion
						   (goto-char (point-min))
						   (igsearch-scan-file scanner))))))))))
	  (goto-char (point-min))
	  (when (scan-buffer (format nil "~5D|" line))
		(reverse-region (progn (goto-bol) (point))
						(progn (goto-eol) (forward-char) (point)))
		(unless first-time
		  (recenter)))
	  (other-window))
	t))

(defun igsearch-scan-file (scanner)
  (let ((found nil))
	(while (funcall scanner)
	  (setf found t)
	  (let ((beg (progn (goto-bol) (point)))
			(end (progn (goto-eol) (point))))
		(format t "~5D|~A~%" (current-line-number) (buffer-substring beg end))
		(when (and *grep-highlight-match*
				   (buffer-stream-p *standard-output*))
		  (save-excursion
			(set-buffer (buffer-stream-buffer *standard-output*))
			(let ((p (- (buffer-stream-point *standard-output*) end 1)))
			  (goto-char (+ (match-beginning 0) p))
			  (let ((limit (save-excursion (goto-eol) (point))))
				(while (funcall scanner limit t)
				  (apply #'set-text-attribute (match-beginning 0) (match-end 0)
						 'grep *grep-highlight-match*)))
			  (goto-bol)
			  (apply #'set-text-attribute (progn (scan-buffer ".\\{5\\}" :regexp t) (match-end 0))
					 (1+ (match-end 0))
					 'grep *igsearch-separator*)))))
	  (or (forward-char 1)
		  (return)))
	found))

;;;
;;; grep-mode
;;;

(defvar *igsearch-mode-map* nil)
(defvar-local *igsearch-grep-mode-scanner* nil)
(defvar-local *igsearch-grep-current-stirng* nil)
(unless *igsearch-mode-map*
  (setf *igsearch-mode-map* (make-sparse-keymap))
  (define-key *igsearch-mode-map* #\q    'igsearch-grep-exit)
  (define-key *igsearch-mode-map* #\f    'igsearch-grep-flush-lines)
  (define-key *igsearch-mode-map* #\k    'igsearch-grep-keep-lines)
  (define-key *igsearch-mode-map* #\ESC  'igsearch-grep-exit)
  (define-key *igsearch-mode-map* #\TAB  'igsearch-grep-view)
  (define-key *igsearch-mode-map* #\SPC  'igsearch-grep-jump)
  (define-key *igsearch-mode-map* #\RET  'igsearch-grep-jump-and-exit)
  (define-key *igsearch-mode-map* #\C-n  'igsearch-grep-next-virtual-line)
  (define-key *igsearch-mode-map* #\C-p  'igsearch-grep-prev-virtual-line)
  (define-key *igsearch-mode-map* #\M-c  'igsearch-refresh-highlight-toggle)
  (substitute-key-definition 'undo 'igsearch-grep-undo
							 *igsearch-mode-map* *global-keymap*)
  (substitute-key-definition 'redo 'igsearch-grep-redo
							 *igsearch-mode-map* *global-keymap*))

(defun igsearch-reset-attribute ()
  (save-excursion
    (goto-char (point-min))
    (while (funcall *igsearch-grep-mode-scanner*)
      (apply #'set-text-attribute (match-beginning 0) (match-end 0)
	     'grep *grep-highlight-match*))))

(defun igsearch-grep-undo ()
  (interactive)
  (setf buffer-read-only nil)
  (undo)
  (igsearch-reset-attribute)
  (setf buffer-read-only t))

(defun igsearch-grep-redo ()
  (interactive)
  (setf buffer-read-only nil)
  (redo)
  (igsearch-reset-attribute)
  (setf buffer-read-only t))

(defun igsearch-grep-next-virtual-line (&optional (n 1))
  (interactive)
  (next-virtual-line n)
  (igsearch-grep-view))

(defun igsearch-grep-prev-virtual-line (&optional (n 1))
  (interactive)
  (igsearch-grep-next-virtual-line (- 0 n)))

(defun igsearch-grep-view ()
  (interactive)
  (goto-bol)
  (when (scan-buffer " *\\([0-9]+\\)|" :regexp t)
	(let ((line (match-string 1)))
	  (let ((*isearch-current-string* *igsearch-grep-current-stirng*))
		(other-window)
		(goto-line (parse-integer line))
		(set-mark)
		(recenter)
;		(refresh-screen)
		(igsearch-coloring t)
		(other-window)))))

(defun igsearch-grep-jump ()
  (interactive)
  (goto-bol)
  (when (scan-buffer " *\\([0-9]+\\)|" :regexp t)
	(let ((line (match-string 1)))
	  (other-window)
	  (goto-line (parse-integer line)))))

(defun igsearch-grep-jump-and-exit ()
  (interactive)
  (goto-bol)
  (when (scan-buffer " *\\([0-9]+\\)|" :regexp t)
    (let ((line (match-string 1)))
      (igsearch-grep-exit)
      (goto-line (parse-integer line)))))

(defun igsearch-grep-exit ()
  (interactive)
  (other-window)
  (when *igsearch-winconf*
	(with-set-buffer
	  (when *igsearch-minibuffer-list-buffer*
		(set-buffer *igsearch-minibuffer-list-buffer*))
	  (set-window-configuration *igsearch-winconf*)
	  (when *igsearch-refresh-highlight*
		(igsearch-delete-coloring))
	  (setf *igsearch-winconf* nil))))

(defun igsearch-grep-flush-lines ()
  (interactive)
  (setf buffer-read-only nil)
  (unwind-protect
      (call-interactively 'flush-lines-buffer)
    (setf buffer-read-only t)))

(defun igsearch-grep-keep-lines ()
  (interactive)
  (setf buffer-read-only nil)
  (unwind-protect
      (call-interactively 'keep-lines-buffer)
    (setf buffer-read-only t)))

;;;
;;; Utility
;;;

;;; Flush lines
(defun flush-lines (regexp &optional (start (point)) (end (point-max)))
  "正規表現にマッチする行を削除"
  (interactive "*sFlush lines: ")
  (when (> start end)
    (rotatef start end))
  (save-excursion
    (goto-char end)
    (while (scan-buffer regexp :regexp t :limit start :reverse t)
      (delete-region (progn (goto-bol) (point))
		     (progn (goto-eol) (forward-char) (point))))))
(defun flush-lines-buffer (regexp &optional (start (point-min)) (end (point-max)))
  "正規表現にマッチする行を削除(バッファ全体)"
  (interactive "*sFlush lines (buffer): ")
  (flush-lines regexp start end))

;;; Keep lines
(defun keep-lines (regexp &optional (start (point)) (end (point-max)))
  "正規表現にマッチしない行を削除"
  (interactive "*sKeep lines: ")
  (when (> start end)
    (rotatef start end))
  (save-excursion
    (goto-char end)
    (while (cond ((<= (point) start) nil)
		 ((scan-buffer regexp :regexp t :reverse t
			       :limit (save-excursion
					(goto-bol) (max (point) start))))
		 (t (delete-region (progn (goto-bol) (point))
				   (progn (goto-eol) (forward-char) (point)))))
      (if (backward-line) (goto-eol) (goto-bol)))))
(defun keep-lines-buffer (regexp &optional (start (point-min)) (end (point-max)))
  "正規表現にマッチしない行を削除(バッファ全体)"
  (interactive "*sKeep lines (buffer): ")
  (keep-lines regexp start end))

;;; igsearch.l ends here
