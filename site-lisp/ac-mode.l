;;; -*- mode: lisp -*-
;;; name:     ac-mode
;;; version:  2007.12.21
;;; author:   snj14
;;; category: Editing
;;; src:      http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fac-mode&openfile=
;;; changes:  補完はカーソルが単語の上 or 末尾にあるときのみにした
;;; files:    site-lisp/ac-mode.l
;;;           site-lisp/ac-mode.lc
;;;           site-lisp/ac-mode-css.l
;;;           site-lisp/ac-mode-css.lc
;;;           site-lisp/ac-mode-lisp.l
;;;           site-lisp/ac-mode-lisp.lc
;;;           site-lisp/ac-mode-html+.l
;;;           site-lisp/ac-mode-html+.lc
;;;           site-lisp/ni-autoload/silog/ac-mode.l

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
;; - paren,rv-region,セレクションの有無,直前に実行したコマンド を考慮したインデント
;; - snippetの展開
;; - (URI|ファイル名|abbrev|lispの関数,変数|バッファ内の関数,変数|Keyword|XTAGS|dabbrev)
;;   のインクリメンタルな補完
;; をC-i(TAB)のみで行えるようにするマイナーモードです。
;; snippetの展開には別途snippet.lが必要です。
;;
;; インテリジェント補完コマンド ac-mode
;; http://taiyaki.org/elisp/ac-mode/
;; の説明から想像で実装し、便利そうな機能を追加したものです。
;; 
;; 
;; また、いくつかの補完には専用のコマンドもあり、
;; 文字を入力せずに補完することや、
;; (complete+が入っていれば)部分一致/スキップマッチも可能です。
;; 

;; 使用方法1:
;;
;; ac-mode になっていなければ M-x ac-mode してください。
;; TAB(C-i) を押すと *ac-mode-command-list* で指定された順に判定し、
;; インデントや補完の対象でないと判断したり候補がなければ次の補完を行います。
;; デフォルトでは下記「現在実装されている補完モジュール」の順に1～12までです。
;; また、C-u TAB を押すことによって明示的にモジュールを指定できます。
;; 補完候補はpopup-stringで表示します。
;; URI補完を行うにはあらかじめ~/uri.txtにプレーンテキストで
;; URIを記述してください。
;; *ac-mode-uri-regexp*にマッチしない行は無視しますのでコメントは自由にどうぞ。
;;
;; 候補を表示した状態でのキーバインド
;;
;; C-n            次の候補を選択
;; C-p            前の候補を選択
;; PageDown(C-v)  次のページへ
;; PageUp(M-v)    前のページへ
;; TAB(C-i)       補完できれば補完、できなければ次の候補、
;;                残り候補が1つなら決定、ファイルを補完中かつディレクトリならセパレータ挿入
;; C-g            中止
;; ECS ECS        中止
;; RET(C-m)       決定
;; SPC            決定
;; Apps           補完の種類を変更
;; C-w            ファイルを補完中なら上のディレクトリへ
;; C-\            ファイルを補完中ならセパレータを\に
;;                2回続けると\\に
;; C-/            ファイルを補完中ならセパレータを/に
;; a~z,記号等     絞込み文字追加
;; C-h(BackSpace) 絞込み文字1文字削除
;; その他         決定して本来のコマンドを実行

;; 使用方法2:
;; 
;; 何から補完したいか、が確実に分かっている場合は
;; 専用のコマンドを実行した方が良いこともあります。
;; 特に、部分一致やスキップマッチを行いたいときに有効です。(要 complete+)
;; また、これらは文字を入力せず補完するということもできます。
;; 
;; 補完を専用のコマンドは以下のものがあります。
;;  - 関数
;;  - 変数
;;  - dabbrev前方
;;  - dabbrev後方
;;  - キーワード
;;  - 行
;; 
;; # 行の補完は後方(上方向)優先です。
;; # さらに、行の補完中はC-lがC-pと同じになります。
;; 
;; これらのコマンドは自動的にキー設定を行わないので、
;; 後述の「設定」を参考に各自行ってください。

;; 現在実装されている補完モジュール:
;;
;; 1  ac-mode-try-indent
;;    直前に実行したコマンドがbeginning-of-defun(M-C-A)
;;    またはend-of-defun(M-C-E)ならその関数を、
;;    直前に実行したコマンドがforward-paragraph(M-})
;;    またはbackward-paragraph(M-{)ならその段落を、
;;    セレクションがあればセレクションを、
;;    rv-regionで反転していればリージョンを、
;;    parenで強調していれば強調している範囲を、
;;    行頭または左側が空白のみの場合はその行をインデント。
;; 
;; 2  ac-mode-try-complete-URI
;;    キャレット位置の文字列が*ac-mode-uri-regexp*にマッチすれば、
;;    *ac-mode-uri-list-file*で指定したファイルから
;;    *ac-mode-uri-regexp*にマッチする行を抽出して補完します。
;; 
;; 3  ac-mode-try-complete-file
;;    キャレット位置が*ac-mode-file-regexp*にマッチすれば
;;    ファイルとみなして補完します。
;; 
;; 4  ac-mode-try-expand-snippet
;;    snippet.lがインストールされていればsnippetの展開を行います。
;; 
;; 5  ac-mode-try-abbrev-local
;;    abbrev-modeがtならローカルなabbrevテーブルから補完します。
;; 
;; 6  ac-mode-try-abbrev-global
;;    abbrev-modeがtならグローバルなabbrevテーブルから補完します。
;; 
;; 7  ac-mode-try-complete-variable
;;    現在のバッファから変数定義を抽出し補完します。
;; 
;; 8  ac-mode-try-complete-function
;;    (list-function)で表示される関数一覧から補完します。
;;    
;; 9  ac-mode-try-lisp-complete-symbol
;;    lisp-mode,lisp-interaction-modeの場合、
;;    (lisp-complete-symbol)で補完される関数・変数から補完します。
;; 
;; 10 ac-mode-try-complete-keyword
;;    メジャーモードにキーワードファイルが
;;    用意されていればキーワードから補完します。
;; 
;; 11 ac-mode-try-complete-xtags
;;    XTAGSが存在すれば関数・変数から補完します。
;; 
;; 12 ac-mode-try-dabbrev-current-buffer
;;    現在のバッファからDabbrevします。
;;    ed::*migemo-on* がtならmigemoを使った検索を行います
;; 
;; 13 ac-mode-try-dabbrev-all-buffer
;;    全バッファからDabbrevします。
;;    ed::*migemo-on* がtならmigemoを使った検索を行います
;; 
;; 14 ac-mode-default-keybind
;;    メジャーモードのC-i(TAB)と同じ動きをします。
;; 
;; 15 ac-mode-insert-tab-code
;;    タブコード[	]を挿入します


;; 設定:
;;
;;  NetInstallerで導入した方は 1 は不要です
;;  (ni-autoload)している方は 2 の requireは不要です
;;
;; 1 $XYZZY/site-lisp/以下にコピーし、バイトコンパイルしてください
;; 2 .xyzzy や siteinit.l に以下を参考に記述し、
;;   siteinit.lに書いた人は再ダンプしてください
;;
;; (require "ac-mode")
;;
;; ;; lisp-interaction-modeで常にac-modeをON
;; (add-hook '*lisp-interaction-mode-hook*
;;           'ac-mode-on)
;;
;; ;; lisp-modeで常にac-modeをON
;; (add-hook '*lisp-mode-hook*
;;           'ac-mode-on)
;;
;; ;; ファイル全てをac-mode (バッファではない)
;; (add-hook '*find-file-hooks*
;;           'ac-mode-on)
;;
;; ;; migemoを使うdabbrevはこの文字数以上の時だけ(デフォルト=4)
;; (setf *ac-mode-dabbrev-use-migemo-more-than* 5)
;;
;; ;; 補完はいらないけどインデントは便利にしたい人向け
;; (setq-default *ac-mode-command-list* '(ac-mode-try-indent
;;                                        ac-mode-default-keybind))
;;
;; ;; java-modeで常にac-modeにし、インデントとAbbrevのみにする
;; (add-hook '*java-mode-hook*
;;           #'(lambda ()
;;               (ac-mode-on)
;;               (setf *ac-mode-command-list*
;;                     '(ac-mode-try-indent
;;                       ac-mode-try-abbrev-local
;;                       ac-mode-default-keybind))))
;;
;; ;; lisp-modeで常にac-modeにし、インデントとlisp-complete-symbolのみにする
;; (add-hook '*lisp-mode-hook*
;;           #'(lambda ()
;;               (ac-mode-on)
;;               (setf *ac-mode-command-list*
;;                     '(ac-mode-try-indent
;;                       ac-mode-try-lisp-complete-symbol
;;                       ac-mode-default-keybind))))
;; 
;; ;; 専用の補完コマンド
;; ;; global-set-keyでもいいかも。
;; (define-key *ac-mode-map* '(#\C-c #\C-d) 'ac-mode-complete-function)  ;; 関数
;; (define-key *ac-mode-map* '(#\C-c #\C-v) 'ac-mode-complete-variable)  ;; 変数
;; (define-key *ac-mode-map* '(#\C-c #\C-n) 'ac-mode-complete-word-next) ;; dabbrev前方
;; (define-key *ac-mode-map* '(#\C-c #\C-p) 'ac-mode-complete-word-prev) ;; dabbrev後方
;; (define-key *ac-mode-map* '(#\C-c #\C-k) 'ac-mode-complete-keyword)   ;; キーワード
;; (define-key *ac-mode-map* '(#\C-c #\C-l) 'ac-mode-complete-line)      ;; 行
;; 

;; 履歴:
;; 
;; 2007.12.21
;; - 補完はカーソルが単語の上 or 末尾にあるときのみにした
;; 
;; 2007.04.22
;; - Appsを押してもモジュール変更が出来なくなっていたのを修正
;; 
;; 2007.03.22
;; - ac-mode-try-complete-variableをexportした
;; 
;; 2007.03.16
;; - typo修正
;; 
;; 2007.03.14-2
;; - ac-mode-lisp-complete-libraryのバグ修正
;; 
;; 2007.03.14
;; - タグ作成を別バッファで行うようにした
;; - C++スタイルのコメントの開始文字に/が設定されている場合は
;;   文字列中でなければパスとみなさないようにした
;; 
;; 2007.03.05
;; - エラー修正
;; - 補完中にC-iしたらモジュールを固定して部分一致やスキップマッチが出来るようにした
;; - dabbrev前方/後方は反対側を検索しないようにした
;; - SPCを*ac-mode-internal-map*から外した(半角スペースでも絞り込めるように)
;; - 補完中に非シンボル文字を入力したら補完を終了するようにした
;; - インデントを2回連続で行ったり変更が加えられなかった場合はdabbrev後方を行うようにした
;; - ac-mode-css.l追加
;; 
;; 2007.03.02
;; - dabbrevやfileは最初からuniqueの場合でも即補完しないようにした
;; - カレントバッファの変数定義を補完するモジュール追加
;;   (タグファイル生成用の関数を使用)
;; - 1種類の補完のみを行うコマンドを追加
;;   (カレントバッファのdabbrev後方/前方, キーワード, 関数, 変数, 行)
;; - 現在選択中の候補をtemporaryなセレクションで表示するようにした
;; 
;; 2007.02.27
;; - *ac-mode-complete-user-list*にalistを渡されてもいいようにした
;; - 最初からuniqueな時と途中まで補完できるときに、いきなり補完するようにした
;; - scope.lで定義していたlisp/html用の設定をac-modeに同梱するようにした
;; - scope.lの残骸を掃除
;; 
;; 2007.02.22
;; - scope.lとのインタフェース(?)をさらに色々
;; 
;; 2007.02.19
;; - ffapが導入されていればURI補完の際にffapのヒストリも使うようにした
;; - message, plain-error quitが２つ出る*do-completionのバグにとりあえず対応
;; - scope.lとのインタフェース(?)を色々
;; 
;; 2007.02.15
;; - キーボードマクロで使えるようにした
;; - ミニバッファから呼び出しても大丈夫にした
;; - ローカルマップに割り当てると無限ループになっていたのを修正
;; 
;; 2007.01.29
;; - ac-mode-try-complete-keywordのバグ修正
;; 
;; 2007.01.20
;; - mode-specific-indent-commandが指定されていない場合にエラーが出ないように修正
;; - 変数が定義されていません: editor::build-summary-function というエラーを出ないように修正
;; 
;; 2007.01.12
;; - abbrevの補完後の展開にバグがあったのを修正
;; - XTAGSが見つかりません というエラーを修正できてなかったので再度修正
;; 
;; 2007.01.10
;; - provideの記述忘れ修正
;; - XTAGSが見つかりません というエラーを出ないように修正
;; - 末尾に1つ以上の.があるパスを補完した時の挙動を修正
;; - UNC形式に対応
;; - snippetに対応
;; - abbrev/snippetの補完後に展開するように修正
;; 
;; 2006.11.11
;; - C-iで補完した時や/でディレクトリを確定した時にアンドゥ情報を残すようにした
;; - 相対パスに対応。(./ ../ .\ ..\ から始まっている場合のみ)
;; - ファイル補完時にcomplete+があればcomplete+を使うようにした。
;;   (*ac-mode-use-complete+*がnilの時はcomplete+があっても使わない)
;;   (ついでにこの時だけignored-extensionsを*ac-mode-ignored-extensions*に)
;; - インデントの判定条件を増やした(マーク系コマンド)
;;
;; 2006.11.07
;; - 文字入力中に候補がなくなったら次のモジュールを試すように修正
;; - 候補をソートした状態でポップアップするように修正
;;
;; 2006.10.21
;; - dabbrevを読み込んでない状態だとエラーが出たのを修正
;;
;; 2006.10.20
;; - hookを追加
;;
;; 2006.09.26
;; - (多分)migemoを入れていない状態でロードするとエラーになったのを修正
;; - 型が:symbol-nameな*do-completionの時にprefixがおかしくなっていたのを修正
;; - ac-mode-select-{next,prev}のデフォルト値をC-s,C-rからC-n,C-pに変更
;; - ac-mode-try-lisp-complete-symbolをexportし忘れていたのを修正
;;
;; 2006.08.02
;; - メジャーモードのフックやfind-fileのフックにac-mode-onを引っ掛けた場合、
;;   セッションを開く時に正常にac-modeの状態を戻せていなかったバグを修正
;;
;; 2006.06.15
;; - parenがインストールされていないとエラーが出たバグを修正
;; - セッションを開くときにマイナーモードが元に戻っていなかったバグを修正
;;
;; 2006.06.06
;; - 初版

;;; Code:

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "wip/winapi")
  (require "dabbrev"))

(provide "ac-mode")

(in-package "editor")

(export '(*ac-mode-command-list*
		  *ac-mode-map*
		  *ac-mode-menu*
		  *ac-mode-dabbrev-use-migemo-more-than*
		  *ac-mode-before-search-command-hook*
		  *ac-mode-after-search-command-hook*
		  *ac-mode-ignored-extensions*
		  *ac-mode-start-marker*
		  *ac-mode-end-marker*
		  *ac-mode-end+1-marker*
		  *ac-mode-allow-empty-string-modules*
		  *ac-mode-use-complete+-modules*
		  *ac-mode-complete-user-list*
		  *ac-mode-complete-type-list*
		  *ac-mode-highlight-complete-word-attribute*
		  ac-mode-pre-completion-hook
		  
		  ac-mode-try-indent
		  ac-mode-try-complete-URI
		  ac-mode-try-complete-file
		  ac-mode-try-expand-snippet
		  ac-mode-try-abbrev-local
		  ac-mode-try-abbrev-global
		  ac-mode-try-lisp-complete-symbol
		  ac-mode-try-complete-variable
		  ac-mode-try-complete-function
		  ac-mode-try-complete-keyword
		  ac-mode-try-complete-xtags
		  ac-mode-try-dabbrev-current-buffer
		  ac-mode-try-dabbrev-all-buffer
		  ac-mode-try-complete-list
		  ac-mode-default-keybind
		  ac-mode-insert-tab-code
		  ac-mode-on
		  ac-mode-off
		  ac-mode
		  ac-mode-complete-or-indent
		  
		  ac-mode-complete-function
		  ac-mode-complete-variable
		  ac-mode-complete-word-prev
		  ac-mode-complete-word-next
		  ac-mode-complete-keyword
		  ac-mode-complete-line
		  ))
(defvar-local ac-mode-on nil)

;;; keymap
(defvar *ac-mode-map* nil)
(unless *ac-mode-map*
  (setf *ac-mode-map* (make-sparse-keymap))
  (define-key *ac-mode-map* #\C-i 'ac-mode-complete-or-indent))

;;; keymap
(defvar *ac-mode-internal-map* nil)
(unless *ac-mode-internal-map*
  (setf *ac-mode-internal-map* (make-sparse-keymap))
  (define-key *ac-mode-internal-map* '(#\ESC #\ESC) 'ac-mode-quit)
  (define-key *ac-mode-internal-map* #\C-i        'ac-mode-complete-string)
  (define-key *ac-mode-internal-map* #\C-g        'ac-mode-quit)
  (define-key *ac-mode-internal-map* #\RET        'ac-mode-return)
  (define-key *ac-mode-internal-map* #\C-h        'ac-mode-delete-char)
  (define-key *ac-mode-internal-map* #\C-n        'ac-mode-select-next)
  (define-key *ac-mode-internal-map* #\C-p        'ac-mode-select-prev)
  (define-key *ac-mode-internal-map* #\C-v        'ac-mode-page-next)
  (define-key *ac-mode-internal-map* #\PageDown   'ac-mode-page-next)
  (define-key *ac-mode-internal-map* #\M-v        'ac-mode-page-prev)
  (define-key *ac-mode-internal-map* #\PageUp     'ac-mode-page-prev)
  (define-key *ac-mode-internal-map* #\C-w        'ac-mode-upper-dir)
  (define-key *ac-mode-internal-map* #\C-\\       'ac-mode-slash-to-backslash)
  (define-key *ac-mode-internal-map* #\C-/        'ac-mode-backslash-to-slash)
  (define-key *ac-mode-internal-map* #\/          'ac-mode-decision-or-self-insert)
  (define-key *ac-mode-internal-map* #\\          'ac-mode-decision-or-self-insert)
  (define-key *ac-mode-internal-map* #\Apps       'ac-mode-select-complete-type)
  )

;;; command
(defvar-local *ac-mode-command-list*
			  '(ac-mode-try-indent
				ac-mode-try-complete-URI
				ac-mode-try-complete-file
				ac-mode-try-expand-snippet
				ac-mode-try-abbrev-local
				ac-mode-try-abbrev-global
				ac-mode-try-complete-keyword
				ac-mode-try-lisp-complete-symbol
				ac-mode-try-complete-variable
				ac-mode-try-complete-function
				ac-mode-try-complete-xtags
				ac-mode-try-dabbrev-current-buffer
				ac-mode-try-dabbrev-all-buffer
				ac-mode-default-keybind))

(defvar *ac-mode-use-complete+* t)
(defvar *ac-mode-ignored-extensions* nil)
(defvar *ac-mode-complete-module* nil)
;;; mode line
(defvar *ac-mode-complete-type* "AC")
(defvar *ac-mode-complete-type-default* "AC")
(defvar *ac-mode-complete-type-uri* "URI")
(defvar *ac-mode-complete-type-file* "File")
(defvar *ac-mode-complete-type-abbrev-local* "Abbrev-Local")
(defvar *ac-mode-complete-type-abbrev-global* "Abbrev-Global")
(defvar *ac-mode-complete-type-lisp-complete-symbol* "lisp-symbol")
(defvar *ac-mode-complete-type-function* "Function")
(defvar *ac-mode-complete-type-keyword* "Keyword")
(defvar *ac-mode-complete-type-xtags* "XTAGS")
(defvar *ac-mode-complete-type-dabbrev-local* "Dabbrev-Local")
(defvar *ac-mode-complete-type-dabbrev-global* "Dabbrev-Global")
(defvar *ac-mode-complete-type-list* "AC-list")

;;; 最初からuniqueならいきなり補完する種類
(defvar *ac-mode-decision-if-unique*
  '(ac-mode-try-complete-URI
	;ac-mode-try-complete-file
	ac-mode-try-abbrev-local
	ac-mode-try-abbrev-global
	ac-mode-try-complete-function
	ac-mode-try-complete-variable
	ac-mode-try-lisp-complete-symbol
	ac-mode-try-complete-keyword
	ac-mode-try-complete-xtags
	;ac-mode-try-dabbrev-current-buffer
	;ac-mode-try-dabbrev-all-buffer
	ac-mode-try-complete-list))

;;; シンタックスを使いそうな補完の種類
(defvar *ac-mode-use-syntax-modules*
  '(ac-mode-try-dabbrev-all-buffer
	ac-mode-try-dabbrev-current-buffer
	ac-mode-try-complete-xtags
	ac-mode-try-complete-keyword
	ac-mode-try-lisp-complete-symbol
	ac-mode-try-complete-function
	ac-mode-try-complete-variable))

;;; loop
(defvar *ac-mode-loop* nil) ; t の間は文字入力による絞込みや候補の変更などができる
(defvar *ac-mode-command* nil) ; 内部で使われる *ac-mode-command-list*。
(defvar *ac-mode-command-char* nil) ; 入力した文字
(defvar *ac-mode-this-command* nil) ; *ac-mode-internal-map*の中で入力した文字に割り当てられたコマンド
(defvar *ac-mode-last-command* nil) ; 前回のコマンド
(defvar *ac-mode-completion-list* nil) ; 補完リスト
(defvar *ac-mode-string-decision* nil) ; 補完リストの全ての項目の先頭からの共通部分
(defvar *ac-mode-string-start* nil) ; 補完確定の際にはstartから
(defvar *ac-mode-string-end* nil)   ;                          endまでを上書きする
(defvar *ac-mode-string* nil) ; (buffer-substring start (point))の文字列 補完に使ったり比較に使ったり あちこちでinsertしないように
(defvar *ac-mode-string-match* nil) ; popup-stringで現在選んでいる文字列
(defvar *ac-mode-string-file-separater* nil) ; "\\" "\" "/" のどれか 混ざってる時の優先順位もこの順
(defvar *ac-mode-buffer* nil) ; ac-modeを行ったバッファ。read-char中でもoutline-tree2でマウスを使ってバッファを切り替えられる対策
(defvar *ac-mode-start-marker* nil) ; 文字の開始位置をここにいれられたマーカーで判断する
(defvar *ac-mode-end-marker* nil)   ;       終了位置
(defvar *ac-mode-end+1-marker* nil) ;       終了位置+1
(defvar *ac-mode-show-popup* t) ; 候補をポップアップするかどうか
(defvar *ac-mode-show-popup-complete-word* nil) ; ac-mode-complete-word-prev/ac-mode-complete-word-nextで最初からポップアップするか
(defvar *ac-mode-highlight-complete-word* nil) ; local dabbrev でハイライトするか
(defvar *ac-mode-highlight-complete-word-attribute* ; local abbrev でハイライトする時の色とか
  '(:foreground 3))
(defvar *ac-mode-highlight-complete-word-position* nil) ; ハイライト用の内部変数
(defvar-local ac-mode-highlight-complete-word-last-position nil) ; ハイライト用の内部変数

;;; hook

;; run-hook-with-args-until-successで実行されるのでこれ以上判断を行わないときはno-nilを返す
;; *ac-mode-command*にモジュールをいれるとそのモジュールでしか補完を行わない
;; 長さ0の文字も許可する場合は*ac-mode-allow-empty-string-modules*にもモジュール名を入れる
;; 判断する文字の開始位置と終了位置を指定したい場合はmarkerを作って
;; それぞれ*ac-mode-start-marker*と*ac-mode-end-marker*に設定
(defvar-local ac-mode-pre-completion-hook nil)

(defvar *ac-mode-before-search-command-hook* nil)
(defvar *ac-mode-after-search-command-hook* nil)
(defvar *ac-mode-before-main-loop-hook* nil) ; ループの前
(defvar *ac-mode-main-loop-hook* nil); 1ループごとに
(defvar *ac-mode-complete-hook* nil) ; ループ終了後

;;; complete uri
(defvar *ac-mode-uri-list-file* "~/.uri"); プレーンテキストの場所
(defvar *ac-mode-uri-list* nil)
(defvar *ac-mode-uri-regexp*; fileスキームは指定しない方がファイルパスとして指定できて便利
  "\\(https?\\|ftp\\|telnet\\|gopher\\|www\\|wais\\|mailto\\):[-a-zA-Z0-9_/~.@?&=;+(),'$!*:#%|]*")

;;; complete file
(defvar *ac-mode-file-regexp*
  "\\([a-zA-Z]:[/\\]\\|~/\\|\\.\\{1,2\\}[/\\]\\|//\\)[^:*\"?|<>\t\n]*")

;;; popup string
(defvar *ac-mode-max-view-item* 20)  ; 最高いくつ表示するか
(defvar *ac-mode-mark-current* "> ") ; popup-stringでずれる人は適当に修正してください
(defvar *ac-mode-mark-other*   "   ");                    〃

;;; popup menu
(defvar-local *ac-mode-menu* nil); :popup 以外で define-popup-menu の引数のように。

;;; dabbrev
;;; type :buffer        検索するバッファ名にマッチする正規表現
;;;      :buffer-ignore 検索しないバッファ名にマッチする正規表現
;;;      :function      バッファを引数に取る関数。非nilを返せば検索する
(defvar-local *ac-mode-dabbrev-buffer* "\\(^ \\|*Trace Output*\\)")
(defvar-local *ac-mode-dabbrev-buffer-type* :buffer-ignore)
(defvar *ac-mode-dabbrev-use-migemo-more-than* 4);この文字数以上の時にmigemoを使ってdabbrev

(defvar *ac-mode-lisp-mode* '(lisp-mode lisp-interaction-mode))

(pushnew '(ac-mode-on . *ac-mode-complete-type*) *minor-mode-alist* :key #'car)

(defun ac-mode-get-uri-list ()
  "URIのリストを返す。初回は読みに行く"
  (when (and (not *ac-mode-uri-list*)
			 (file-exist-p *ac-mode-uri-list-file*))
	(setf *ac-mode-uri-list*
		  (let (res)
			(with-open-file (fp *ac-mode-uri-list-file*)
			  (let (line)
				(while (setq line (read-line fp nil nil nil))
				  (when (string-match (concat "^" *ac-mode-uri-regexp*) line)
					(push line res)))))
			(nreverse res))))
  (union *ac-mode-uri-list*
		 (and (modulep "ffap")
			  (eval (intern "*ffap-uri-history*" "ed")))
		 :test 'equal))

(defun ac-mode-space-only-backword (&optional point)
  "後方(左)に空白しかないならt"
  (save-excursion
	(when point
	  (goto-char point))
	(or (bolp)
		(/= (current-line-number)
			(progn
			  (unless (bolp)
				(backward-char))
			  (skip-white-backward)
			  (current-line-number))))))

(defun ac-mode-space-only-forword (&optional point)
  "前方(右)に空白しかないならt"
  (save-excursion
	(when point
	  (goto-char point))
	(or (eolp)
		(/= (current-line-number)
			(progn
			  (skip-white-forward)
			  (current-line-number))))))

(defun ac-mode-get-region ()
  "リージョンが一行なら文字列を返す"
  (let ((ptline (current-line-number))
		mkline)
	(save-excursion
	  (and (mark t)
		   (goto-char (mark))
		   (setf mkline (current-line-number))))
	(when (eq ptline mkline)
	  (buffer-substring (point) (mark)))))

(defun ac-mode-get-complete-target-from-regexp (regexp)
  "リージョンが1行ならリージョンの頭まで、違うならから行頭まで戻る。
現在位置から正規表現にマッチする文字列を前方検索し、
1 マッチした先頭から現在位置までの文字列、
2 マッチした文字列全体の先頭、
3 末尾の３つの多値を返す"
  (let ((pt (point))
		string start end
		(region (ac-mode-get-region)))
	(save-excursion
	  (cond (*ac-mode-start-marker*
			 (goto-marker *ac-mode-start-marker*))
			((stringp region)
			 (and (< (mark) pt)
				  (goto-char (mark))))
			(t
			 (goto-bol)))
	  (and (scan-buffer regexp :regexp t
						:limit (or (when *ac-mode-end+1-marker*
									 (1- (marker-point *ac-mode-end+1-marker*)))
								   (when *ac-mode-end-marker*
									 (marker-point *ac-mode-end-marker*))
								   (when region
									 (if (> (mark) pt)
										 (mark) pt))
								   (save-excursion (goto-eol) (point))))
		   (< (match-beginning 0) pt)
		   (<= pt (match-end 0))
		   (setf string (buffer-substring (match-beginning 0) pt)
				 start (match-beginning 0)
				 end   (match-end 0))
		   (string-match regexp string)
		   (values string start end)))))

(defun ac-mode-get-commond-prefix (list &optional init)
  "先頭部分の一致する部分文字列を返す"
  (let ((res (or init *ac-mode-string-match*)))
	(dolist (x list)
	  (while (and (not (ac-mode-equal-if-consp-use-car "" res))
;				  (string/= res "")
				  (not (funcall (if *case-fold-search* 'equalp 'equal)
								res
								(if (< (length res) (length x))
									(substring x 0 (length res))
								  x))))
		(setf res (substring (ac-mode-car-if-consp res) 0 -1))))
	res))

(defun ac-mode-get-w_ ()
  (let ((pt (point)) start end string)
	(cond ((and (string= *ac-mode-complete-type*
						 *ac-mode-complete-type-default*)
				(or *ac-mode-start-marker* *ac-mode-end-marker* *ac-mode-end+1-marker*))
		   (cond ((and *ac-mode-start-marker* *ac-mode-end+1-marker*)
				  (setf start (marker-point *ac-mode-start-marker*)
						end (1- (marker-point *ac-mode-end+1-marker*))
						string (buffer-substring start end)))
				 ((and *ac-mode-start-marker* *ac-mode-end-marker*)
				  (setf start (marker-point *ac-mode-start-marker*)
						end (marker-point *ac-mode-end-marker*)
						string (buffer-substring start end)))
				 (*ac-mode-start-marker*
				  (setf start (marker-point *ac-mode-start-marker*))
				  (save-excursion
					(skip-syntax-spec-forward "w_")
					(setf end (point)
						  string (buffer-substring start end))))
				 (*ac-mode-end+1-marker*
				  (save-excursion
					(skip-syntax-spec-backward "w_")
					(setf start (point)
						  end (1- (marker-point *ac-mode-end+1-marker*))
						  string (buffer-substring start end))))
				 (*ac-mode-end-marker*
				  (save-excursion
					(skip-syntax-spec-backward "w_")
					(setf start (point)
						  end (marker-point *ac-mode-end-marker*)
						  string (buffer-substring start end))))))
		  ((string= *ac-mode-complete-type*
					*ac-mode-complete-type-default*)
		   (save-excursion
			 (and (skip-syntax-spec-backward "w_")
				  (/= (point) pt)
				  (setf start (point)
						string (buffer-substring start pt))
				  (skip-syntax-spec-forward "w_")
				  (setf end (point)))))
		  (t
		   (setf start  *ac-mode-string-start*
				 end    *ac-mode-string-end*
				 string *ac-mode-string*)))
	(values start end string)))

(defun ac-mode-get-variable-current-buffer ()
  (let* ((path (get-buffer-file-name
				(selected-buffer)))
		 name func res)
	(when (and path
			   (setf name (file-namestring path))
			   (setf res (some #'(lambda (m)
								   (when (some #'(lambda (wild)
												   (pathname-match-p name wild))
											   (cdr m))
									 m))
							   *maketags-list*)))
	  (let (temp-buffer tags-buffer lst)
		(save-excursion
		  ;; c-maketags がコメントを削除してしまうので別バッファにコピー
		  (with-output-to-temp-buffer (" *AC-MODE-XTAGS-ORIG*" nil)
			(setq temp-buffer (buffer-stream-buffer *standard-output*))
			(format t "~a" (buffer-substring (point-min) (point-max))))
		  (set-buffer temp-buffer)
		  (goto-char (point-min))
		  (unwind-protect
			  (with-output-to-temp-buffer (" *AC-MODE-XTAGS*" nil)
				(setq tags-buffer (buffer-stream-buffer *standard-output*))
				(funcall (car res) "" 0))
			(set-buffer tags-buffer)
			(goto-char (point-min))
			(perform-replace "[\n\t\f]" " " nil t nil t)
			(goto-char (point-min))
			(perform-replace "  +" " " nil t nil t)
			(goto-char (point-min))
			(perform-replace "\036" "\n" nil nil nil t)
			(goto-char (point-min))
			(while (scan-buffer "\026\\(.*?\\)\037" :regexp t :no-dup t)
			  (push (match-string 1) lst))
			(delete-buffer tags-buffer)
			(delete-buffer temp-buffer)))
		lst))))

(defun ac-mode-dabbrev-find-all-expansion (abbrev case-fold match-table start matches &key reverse substring)
  (let ((no-dup nil))
	(save-excursion
	  (while (scan-buffer abbrev :case-fold case-fold
						  :no-dup no-dup :left-bound :symbol
						  :reverse reverse)
		(let ((from (save-excursion
					  (if substring
						  (let ((data (match-data)))
							(skip-syntax-spec-backward "w_")
							(point))
						(point))))
			  (to (save-excursion
					(let ((end (match-end 0)))
					  (or (skip-syntax-spec-forward "w_")
						  (and (looking-at "\\sk\\|\\sj")
							   (forward-word 1)))
					  (when (< (point) end)
						(goto-char end)
						(or (skip-syntax-spec-forward "w_")
							(and (looking-at "\\sk\\|\\sj")
								 (forward-word 1)))))
					(point))))
		  (unless (or (eql from start)
					  (gethash-region from to match-table)
					  (not (string-match "\\w" (buffer-substring from to))))
			(let ((text (buffer-substring from to)))
			  (setf (gethash text match-table) from)
			  (push text matches)))
		  (setq no-dup t)))
	  matches)))

(defvar *ac-mode-complete-dabbrev-direction* nil)

(defun ac-mode-get-dabbrev (module)
  (let ((end (or (and *ac-mode-end+1-marker*
					  (1- (marker-point *ac-mode-end+1-marker*)))
				 (and *ac-mode-end-marker*
					  (marker-point *ac-mode-end-marker*))
				 (point)))
		(start (or (and *ac-mode-start-marker*
						(marker-point *ac-mode-start-marker*))
				   (cond ((eq :string (parse-point-syntax))
						  (1+ (ac-mode-get-beginning-of-string)))
						 (t (save-excursion
							  (skip-syntax-spec-backward "w_")
							  (point)))))))
	(unless (find module *ac-mode-allow-empty-string-modules*)
	  (when (and (not *ac-mode-string*)
				 (= start end))
		(return-from ac-mode-get-dabbrev)))
	(when *ac-mode-string-start*
	  (setf start *ac-mode-string-start*))
	(when *ac-mode-string-end*
	  (setf end *ac-mode-string-end*))
	(let* ((abbrev (or *ac-mode-string*
					   (buffer-substring start end)))
		   (match-table (make-hash-table
						 :test (if *dabbrevs-case-fold* #'equalp #'equal)))
		   matches current)
	  (setf (gethash abbrev match-table) start)
	  (cond ((and (stringp abbrev)
				  (find module *ac-mode-allow-empty-string-modules*)
				  *ac-mode-complete-dabbrev-direction*)
			 (setf abbrev (compile-regexp
						   (concat "\\_<"
								   (if (< 0 (length abbrev))
									   abbrev
									 "\\_s\\_s\\_s")
								   "\\_s*")
						   *dabbrevs-case-fold*))
			 (save-excursion
			   (when (equal *ac-mode-complete-dabbrev-direction* "backward")
				 (goto-char start)
				 (backward-char))
			   (do ((res (scan-buffer abbrev
									  :reverse (equal *ac-mode-complete-dabbrev-direction* "backward")
									  :no-dup t)
						 (scan-buffer abbrev
									  :reverse (equal *ac-mode-complete-dabbrev-direction* "backward")
									  :no-dup t))
					(data (match-data) (match-data)))
				   ((or (not res)
						(string-match "\\w" (match-string 0)))
					(when res
					  (store-match-data data)
					  (setf current (buffer-substring
									 (progn
									   (goto-char (match-beginning 0))
									   (skip-syntax-spec-backward "w_")
									   (point))
									 (match-end 0))))))))
			((and (modulep "migemo")
				 *migemo-on*
				 (<= *ac-mode-dabbrev-use-migemo-more-than* (length abbrev))
				 ;英数記号以外にマッチするものがない=日本語が含まれない(はず)
				 (not (string-match "[^ -~]" abbrev)))
			 (setf abbrev (compile-regexp (funcall (intern "migemo-query" "editor")
												   abbrev)
										  *dabbrevs-case-fold*))))
	  (cond ((equal *ac-mode-complete-dabbrev-direction* "backward")
			 (setf matches (reverse (ac-mode-dabbrev-find-all-expansion
									 abbrev *dabbrevs-case-fold*
									 match-table start nil
									 :reverse t
									 :substring t))))
			((equal *ac-mode-complete-dabbrev-direction* "forward")
			 (setq matches (append matches (ac-mode-dabbrev-find-all-expansion
											abbrev *dabbrevs-case-fold*
											match-table start nil
											:reverse nil
											:substring t))))
			(t
			 (setf matches (ac-mode-dabbrev-find-all-expansion
							abbrev *dabbrevs-case-fold*
							match-table start nil
							:reverse nil
							:substring t))
			 (setq matches (append matches (reverse (ac-mode-dabbrev-find-all-expansion
													 abbrev *dabbrevs-case-fold*
													 match-table start nil
													 :reverse t
													 :substring t))))))
	  (unless *dabbrev-popup-this-buffer-only*
		(let ((curbuf (selected-buffer))
			  (case-fold *dabbrevs-case-fold*)
			  (syntax-table (syntax-table)))
		  (with-set-buffer
			(with-interval-message (300)
			  (save-excursion
				(dolist (buffer (buffer-list))
				  (unless (or (eq buffer curbuf)
							  (and *ac-mode-dabbrev-buffer*
								   (cond ((equal *ac-mode-dabbrev-buffer-type* :buffer)
										  (not (string-match *ac-mode-dabbrev-buffer* (buffer-name buffer))))
										 ((equal *ac-mode-dabbrev-buffer-type* :buffer-ignore)
										  (string-match *ac-mode-dabbrev-buffer* (buffer-name buffer)))
										 ((equal *ac-mode-dabbrev-buffer-type* :function)
										  (funcall *ac-mode-dabbrev-buffer* (buffer-name buffer))))))
					(message "Searching (~A)..." (buffer-name buffer))
					(set-buffer buffer)
					(save-excursion
					  (let ((osyntax-table (syntax-table)))
						(unwind-protect
							(progn
							  (use-syntax-table syntax-table)
							  (setq matches (dabbrev-find-all-expansion
											 abbrev *dabbrevs-case-fold* match-table nil matches)))
						  (use-syntax-table osyntax-table nil t))))))))))
		(clear-message))
	  (values (cond (current
					 (let* ((matches (reverse matches))
							(pos (position current matches :test 'equal)))
					   (when pos
						 (append (subseq matches pos)
							   (subseq matches 0 pos)))))
					(t (stable-sort matches 'string<)))
			  start end))))

;; (ed::ac-mode-get-popup-string-list '(1 2 3 4 5 6) 5 2)
;; > (5 6)
;; > 3
(defun ac-mode-get-popup-string-list (list item interval)
  "listをinterval個ごとのリストに区切り、
1.itemとequalな要素を含むリスト
2.それが幾つ目の区切りか
を多値で返す"
  (let ((pos (position item list :test 'ac-mode-equal-if-consp-use-car)) from)
	(when pos
	  (setf from (* interval (truncate pos interval)))
	  (values (subseq list from (min (+ from interval) (length list)))
			  (1+ (floor pos interval))))))

(defun ac-mode-get-truename (path)
  (when path
	(let ((file (string-match "^file://" path)))
	  (setf path (truename path))
	  (and (file-directory-p path)
		   (not (string-match "/$" path))
		   (setf path (concat path "/")))
	  (if file
		  (concat "file://" path)
		path))))

(defun erase-popup ()
  "popup-stringを強制的に隠す"
  (winapi::ShowWindow
   (winapi::FindWindow (si:make-string-chunk "popup!?") 0)
   0));winapi::SW_HIDE == 0

(defmacro ac-mode-hash (entry &key (test #'eql) (size 16) (rehash-size 1))
  (let ((h (gensym))
		(e (gensym)))
	`(let ((,h (make-hash-table :test ,test :size ,size :rehash-size ,rehash-size)))
	   (dolist (,e ,entry)
		 (setf (gethash (first ,e) ,h) (rest ,e)))
	   ,h)))

;;; 1. Indent ---
(defun ac-mode-try-indent ()
  (let ((mcount (buffer-modified-count))
		(opoint (point))
		from to)
	(cond
	 ;直前にend-of-defun[ESC C-e]かbeginning-of-defun[ESC C-a]を実行していれば
	 ((find *last-command* '(beginning-of-defun
							 end-of-defun))
	  (setf from (save-excursion
				   (beginning-of-defun)
				   (point))
			to (save-excursion
				 (end-of-defun)
				 (point))))
	 ;直前にforward-paragraphを実行していれば段落をインデント
	 ((eq *last-command* 'forward-paragraph) ; ESC }
	  (setf from (save-excursion
				   (backward-paragraph)
				   (point))
			to (point)))
	 ;直前にbackward-paragraphを実行していれば段落をインデント
	 ((eq *last-command* 'backward-paragraph) ; ESC {
	  (setf from (point)
			to (save-excursion
				 (forward-paragraph)
				 (point))))
	 ;直前にmark系のコマンドを実行していればリージョンをインデント
	 ((eq *last-command* '(mark-paragraph    ; M-h
						   mark-sexp         ; ESC NUL
						   mark-whole-buffer ;
						   mark-word         ; ESC @
						   ))
	  (setf from (point)
			to (mark)))
	 ;セレクションがあれば
	 ((pre-selection-p)
	  (selection-start-end (start end)
		(setf from start
			  to  end)))
	 ;rv-regionで反転していれば
	 ((find 'user::rv-region *post-command-hook*)
	  (setf from (mark)
			to (point)))
	 ;parenで強調していれば
	 ((and (modulep "paren")
		   (setf from (find-text-attribute (eval (intern "*paren-tag*" "editor")))))
	  (setf to (multiple-value-bind (from to tag)
				   (find-text-attribute *paren-tag* :from-end t)
				 to)))
	 ;行頭or左側が空白のみであれば
	 ((and (ac-mode-space-only-backword)
		   (boundp 'mode-specific-indent-command)
		   (or (si:*closurep mode-specific-indent-command)
			   (fboundp mode-specific-indent-command)))
	  (funcall mode-specific-indent-command)
	  (return-from ac-mode-try-indent t)))
	(when (and from to
			   (boundp 'mode-specific-indent-command)
			   (or (si:*closurep mode-specific-indent-command)
				   (fboundp mode-specific-indent-command)))
	  (indent-region
	   (save-excursion (goto-char from) (previous-line) (point))
	   to)
	  t)))

(defvar *ac-mode-allow-empty-string-modules* nil)
(defvar *ac-mode-use-complete+-modules* nil)
(defmacro ac-mode-with-complete+ ((module) &body body)
  `(prog2
	   (and (or (find ',module
					  *ac-mode-use-complete+-modules*)
				*ac-mode-fix-module*)
			(modulep "complete+")
			(setf (symbol-function '*do-completion)
				  (symbol-function (intern "*do-completion+" "complete+"))))
	   ,@body
	 (and (or (find ',module
					*ac-mode-use-complete+-modules*)
			  *ac-mode-fix-module*)
		  (modulep "complete+")
		  (setf (symbol-function '*do-completion)
				(symbol-function (intern "*do-completion-" "complete+"))))))

;;; 2. Complete URI ---
(defun ac-mode-try-complete-URI ()
  (unless (find *ac-mode-complete-type*
				(list *ac-mode-complete-type-default*
					  *ac-mode-complete-type-uri*)
				:test 'string=)
	(return-from ac-mode-try-complete-URI))
  (let (string start end list)
	(multiple-value-setq (string start end)
	  (ac-mode-get-complete-target-from-regexp
	   *ac-mode-uri-regexp*))
	(when (and (or (stringp string)
				   (when (find 'ac-mode-try-complete-URI
							   *ac-mode-allow-empty-string-modules*)
					 (unless *ac-mode-string-start*
					   (setf *ac-mode-string-start* (marker-point *ac-mode-start-marker*)))
					 (setf start *ac-mode-string-start*)
					 (unless *ac-mode-string-end*
					   (setf *ac-mode-string-end*
							 (cond (*ac-mode-end+1-marker*
									(1- (marker-point *ac-mode-end+1-marker*)))
								   (*ac-mode-end-marker*
									(marker-point *ac-mode-end-marker*)))))
					 (setf end *ac-mode-string-end*)
					 (unless *ac-mode-string*
						 (setf *ac-mode-string* (buffer-substring start end)))
					 (setf string *ac-mode-string*)))
			   (ac-mode-with-complete+
				(ac-mode-try-complete-URI)
				(multiple-value-bind (str lst pre)
					(*do-completion string :list nil
									(ac-mode-get-uri-list))
				  (setf list (sort lst 'string<)))))
	  (unless *ac-mode-string*
		(setf *ac-mode-string* string))
	  (setf *ac-mode-string-start* start
			*ac-mode-string-end* end
			*ac-mode-completion-list* list
			*ac-mode-complete-type*
			*ac-mode-complete-type-uri*
			*ac-mode-complete-module* 'ac-mode-try-complete-URI))))

;;; 3. Complete file path ---
(defun ac-mode-try-complete-file ()
  (unless (find *ac-mode-complete-type*
				(list *ac-mode-complete-type-default*
					  *ac-mode-complete-type-file*)
				:test 'string=)
	(return-from ac-mode-try-complete-file))
  (let (string start end list prefix string-old)
	(multiple-value-setq (string start end)
	  (ac-mode-get-complete-target-from-regexp
	   *ac-mode-file-regexp*))
	(setf string-old string)
	(when (stringp string)
	  ;キャレットの直後が空白ならそこまでで
	  (and (string-match "^[　 ]"
						 (substring (buffer-substring start end) (1- (length string))))
		   (setf end (point)))
	  ;途中に空白のみのディレクトリがあったらやめとく
	  (and (string-match "\\(.*?\\)[/\\][　 ]+[/\\]" string)
		   (setf start nil end nil string nil)))
	(and (stringp string)
		 (syntax-c++-comment-p #\/)
		 (not (eq (parse-point-syntax) :string))
		 (string-match "^//" string)
		 (setf start nil end nil string nil))
	(and (stringp string)
		 (cond ((string-match "^//\\([^/]*?\\)" string)
				(or (equal (match-string 1) "")
					(find (match-string 1) (list-servers)
						  :test 'equalp)))
			   ((valid-path-p string)))
		 (setf *ac-mode-string-file-separater*
			   (cond ((string-match "\\\\\\\\" string)
					  (setf string (substitute-string string "\\\\\\\\" "\\\\"))
					  "\\\\\\\\")
					 ((string-match "\\\\" string) "\\\\")
					 ((string-match "/" string) "/")))
		 (string-match
		  "\\(\\(?:[a-zA-Z]:\\|^\\|~\\|//\\)[^:*\"?|<>\t\n]*/\\)[^:*\"?|<>\t\n]*"
		  string)
		 (let* ((dir (or (match-string 1) ""))
				(file (substitute-string
					   string (concat "^" (regexp-quote dir)) "")))
		   (setf string (if (string= file "") dir
						  (concat (merge-pathnames file dir)
								  ;; merge-pathnames,file-namestringは
								  ;; 最後に.の1つ以上の連続があると全部削るのでくっつける
								  (cond ((string-match "\\.+$" string)
										 (match-string 0))
										(t ""))))))
		 ;	 (let ((file (file-namestring string))
		 ;	       (dir (ac-mode-get-truename (directory-namestring string)))))
		 )
	(when (and (stringp string)
			   (cond ((string-match "^//\\([^/]*?\\)" string)
					  (or (equal (match-string 1) "")
						  (find (match-string 1) (list-servers)
								:test 'equalp)))
					 ((valid-path-p string))))
	  (and *ac-mode-use-complete+*
		   (modulep "complete+")
		   (setf (symbol-function '*do-completion)
				 (symbol-function (intern "*do-completion+" "complete+"))))
	  (let ((ignored-extensions *ac-mode-ignored-extensions*))
		(unwind-protect
			(multiple-value-bind (str lst pre)
				(*do-completion string :file-name nil)
;; 			  (when (and pre (string-match "\\\\" *ac-mode-string-file-separater*))
;; 				(msgbox "pre: ~S~%" pre)
;; 				(setf pre (substitute-string pre "/" "\\\\"))
;; 				(msgbox "pre: ~S~%" pre)
;; 				)
			  (setf list lst
					prefix (substitute-string
							string-old
							(concat (setf string (substitute-string
												  string
												  (concat "^" (when pre (regexp-quote pre)))
												  ""))
									"$")
							""))
;			  (msgbox "pre: ~S~%prefix: ~S~%string-old: ~S~%" pre prefix string-old)
			  )
		  (and *ac-mode-use-complete+*
			   (modulep "complete+")
			   (setf (symbol-function '*do-completion)
					 (symbol-function (intern "*do-completion-" "complete+"))))))
	  (setf string
			(substitute-string string "/" *ac-mode-string-file-separater*))
	  (setf list (mapcar #'(lambda (x)
							 (substitute-string x "/" *ac-mode-string-file-separater*))
						 list))
	  (unless *ac-mode-string*
		(setf *ac-mode-string* string))
	  (setf *ac-mode-string-start* start
			*ac-mode-string-end* end
			*ac-mode-completion-list* (reverse list)
			*ac-mode-string-prefix* prefix
			*ac-mode-complete-type*
			*ac-mode-complete-type-file*
			*ac-mode-complete-module* 'ac-mode-try-complete-file)
	  *ac-mode-complete-type*
	  )))

;;; 4. Expand Snippet ---
(defun ac-mode-try-expand-snippet ()
  (when (or (not (modulep "snippet"))
			(not (equal *ac-mode-complete-type* *ac-mode-complete-type-default*)))
	(return-from ac-mode-try-expand-snippet))
  (when (funcall (intern "snippet-get-abbrev" "editor"))
	(let ((fn (intern "snippet-expand" "editor")))
	  (funcall fn)
	  (setf *this-command* fn))
	t))

;;; 5. Static abbrev local ---
(defvar-local ac-mode-abbrev-filter-hook nil)
(defun ac-mode-try-abbrev (table type module)
  (unless (and (find *ac-mode-complete-type*
					 (list *ac-mode-complete-type-default* type)
					 :test 'string=)
			   (or abbrev-mode
				   (modulep "snippet")))
	(return-from ac-mode-try-abbrev))
  (let (start end string list prefix)
	(setf list (make-list-from-keyword-table table))
	(when (and ac-mode-abbrev-filter-hook list)
	  (let ((tmp (run-hook-with-args-until-success 'ac-mode-abbrev-filter-hook list)))
		(when tmp
		  (setf list tmp))))
	(when list
	  (multiple-value-setq (start end string)
		(ac-mode-get-w_)))
	(when string
	  (multiple-value-bind (str lst pre)
		  (*do-completion string :list nil list)
		(setf list (sort lst 'string<)
			  prefix pre)))
	(cond ((and start end string list)
		   (unless *ac-mode-string*
			 (setf *ac-mode-string* string))
		   (setf *ac-mode-string-start* start
				 *ac-mode-string-end* end
				 *ac-mode-completion-list* list
				 *ac-mode-string-prefix* prefix
				 *ac-mode-complete-type* type
				 *ac-mode-complete-module* module))
		  ((not *ac-mode-fix-module*)
		   (setf *ac-mode-complete-type* *ac-mode-complete-type-default*)
		   nil))))
(defun ac-mode-expand-abbrev-after-complete ()
  (and (find *ac-mode-complete-type*
			 (list *ac-mode-complete-type-abbrev-local*
				   *ac-mode-complete-type-abbrev-global*)
			 :test 'equal)
	   (cond ((modulep "snippet")
			  (let ((fn (intern "snippet-expand" "editor")))
				(setf *this-command* fn)
				(funcall fn)))
			 (t (expand-abbrev)))))
(add-hook '*ac-mode-complete-hook* 'ac-mode-expand-abbrev-after-complete)
(defun ac-mode-try-abbrev-local ()
  (ac-mode-try-abbrev *local-abbrev-table* *ac-mode-complete-type-abbrev-local* 'ac-mode-try-abbrev-local))

;;; 6. Static abbrev global ---
(defun ac-mode-try-abbrev-global ()
  (ac-mode-try-abbrev *global-abbrev-table* *ac-mode-complete-type-abbrev-global* 'ac-mode-try-abbrev-global))

;;; 7. Lisp-complete-symbol ---
(defun ac-mode-try-lisp-complete-symbol ()
  (unless (and (find *ac-mode-complete-type*
					 (list *ac-mode-complete-type-default*
						   *ac-mode-complete-type-lisp-complete-symbol*)
					 :test 'string=)
			   (find buffer-mode *ac-mode-lisp-mode*))
	(return-from ac-mode-try-lisp-complete-symbol))
  (let (start end string list type)
	(multiple-value-setq (start end string)
	  (ac-mode-get-w_))
	(ac-mode-with-complete+
	 (ac-mode-try-lisp-complete-symbol)
	 (when (and start end (< start end))
	   (multiple-value-bind (str lst pre)
		   (*do-completion
			string
			(cond ((looking-back "#\\")
				   (setq list *lisp-character-name-list*) :list)
				  ((and (looking-back "(")
						(progn
						  (forward-char -2)
						  (not (looking-at "[('#]"))))
				   :function-name)
				  (t
				   :non-trivial-symbol-name)))
		 (setf list (sort lst 'string<)
			   prefix pre))))
	;; message, plain-error quitが２つ出る*do-completionのバグ対策
	(dolist (x '("message" "plain-error" "quit"))
	  (when (= 2 (count x list :test 'equal))
		(setf list (remove x list :test 'equal :count 1))))
	(cond (list
		   (unless *ac-mode-string*
			 (setf *ac-mode-string* string))
		   (setf *ac-mode-string-start* start
				 *ac-mode-string-end* end
				 *ac-mode-completion-list* list
				 *ac-mode-string-prefix* prefix
				 *ac-mode-complete-type*
				 *ac-mode-complete-type-lisp-complete-symbol*
				 *ac-mode-complete-module* 'ac-mode-try-lisp-complete-symbol))
		  ((not *ac-mode-fix-module*)
		   (setf *ac-mode-complete-type* *ac-mode-complete-type-default*)
		   nil))))

;;; 8. Complete Function from "ed::build-summary-function" ---
(defun ac-mode-try-complete-function ()
  (unless (and (find *ac-mode-complete-type*
					 (list *ac-mode-complete-type-default*
						   *ac-mode-complete-type-function*)
					 :test 'string=)
			   (boundp 'ed::build-summary-function)
			   (or (si:*closurep ed::build-summary-function)
				   (fboundp ed::build-summary-function)))
	(return-from ac-mode-try-complete-function))
  (let ((list (long-operation
				(remove-duplicates
				 (mapcar 'second
						 (save-excursion
						   (funcall ed::build-summary-function)))
				 :test 'string=)))
		start end string prefix)
	(when list
	  (multiple-value-setq (start end string)
		(ac-mode-get-w_)))
	(when (or string
			  (and (find 'ac-mode-try-complete-function
						 *ac-mode-allow-empty-string-modules*)
				   (setf start (or *ac-mode-string-start* (point))
						 end (or *ac-mode-string-end* (point))
						 string "")))
	  (unless (equal "" string)
		(ac-mode-with-complete+
		 (ac-mode-try-complete-function)
		 (multiple-value-bind (str lst pre)
			 (*do-completion string :list nil list)
		   (setf list (sort lst 'string<)
				 prefix pre)))))
	(cond ((and list string start end
				(or (find 'ac-mode-try-complete-function
						  *ac-mode-allow-empty-string-modules*)
					(/= start end)))
		   (unless *ac-mode-string*
			 (setf *ac-mode-string* string))
		   (setf *ac-mode-string-start* start
				 *ac-mode-string-end* end
				 *ac-mode-completion-list* list
				 *ac-mode-string-prefix* prefix
				 *ac-mode-complete-type*
				 *ac-mode-complete-type-function*
				 *ac-mode-complete-module* 'ac-mode-try-complete-function))
		  ((not *ac-mode-fix-module*)
		   (setf *ac-mode-complete-type* *ac-mode-complete-type-default*)
		   nil))))

;;; 9. Complete Variable --- 
(defvar *ac-mode-complete-type-variable* "Variable")
(defun ac-mode-try-complete-variable ()
  (unless (find *ac-mode-complete-type*
				(list *ac-mode-complete-type-default*
					  *ac-mode-complete-type-variable*)
				:test 'string=)
	(return-from ac-mode-try-complete-variable))
  (let ((list (ac-mode-get-variable-current-buffer))
		start end string prefix)
	(when list
	  (multiple-value-setq (start end string)
		(ac-mode-get-w_)))
	(when (or string
			  (and (find 'ac-mode-try-complete-variable
						 *ac-mode-allow-empty-string-modules*)
				   (setf start (or *ac-mode-string-start* (point))
						 end (or *ac-mode-string-end* (point))
						 string "")))
	  (unless (equal "" string)
		(ac-mode-with-complete+
		 (ac-mode-try-complete-variablee)
		 (multiple-value-bind (str lst pre)
			 (*do-completion string :list nil list)
		   (setf list (sort lst 'string<)
				 prefix pre)))))
	(cond ((and list string start end
				(or (find 'ac-mode-try-complete-variable
						  *ac-mode-allow-empty-string-modules*)
					(/= start end)))
		   (unless *ac-mode-string*
			 (setf *ac-mode-string* string))
		   (setf *ac-mode-string-start* start
				 *ac-mode-string-end* end
				 *ac-mode-completion-list* list
				 *ac-mode-string-prefix* prefix
				 *ac-mode-complete-type*
				 *ac-mode-complete-type-variable*
				 *ac-mode-complete-module* 'ac-mode-try-complete-variable))
		  ((not *ac-mode-fix-module*)
		   (setf *ac-mode-complete-type* *ac-mode-complete-type-default*)
		   nil))))

;;; 10. Complete symbol from keyword file ---
(defun ac-mode-try-complete-keyword ()
  (unless (find *ac-mode-complete-type*
				(list *ac-mode-complete-type-default*
					  *ac-mode-complete-type-keyword*)
				:test 'string=)
	(return-from ac-mode-try-complete-keyword))
  (let (start end string list prefix)
	(multiple-value-setq (start end string)
	  (ac-mode-get-w_))
	(and *ac-mode-allow-empty-string-modules*
		 (not string)
		 (find 'ac-mode-try-complete-keyword
			   *ac-mode-allow-empty-string-modules*)
		 (setf start (or *ac-mode-string-start* (point))
			   end (or *ac-mode-string-end* (point))
			   string ""))
	(cond ((and keyword-hash-table
				(stringp string)
				(ac-mode-with-complete+
				 (ac-mode-try-complete-keyword)
				 (multiple-value-bind (str lst pre)
					 (*do-completion string :list nil
									 (make-list-from-keyword-table
									  keyword-hash-table))
				   (setf prefix pre
						 list (sort lst 'string<)))))
		   (unless *ac-mode-string*
			 (setf *ac-mode-string* string))
		   (setf *ac-mode-string-start* start
				 *ac-mode-string-end* end
				 *ac-mode-completion-list* list
				 *ac-mode-string-prefix* prefix
				 *ac-mode-complete-type*
				 *ac-mode-complete-type-keyword*
				 *ac-mode-complete-module* 'ac-mode-try-complete-keyword))
		  ((not *ac-mode-fix-module*)
		   (setf *ac-mode-complete-type* *ac-mode-complete-type-default*)
		   nil))))

;;; 11. Complete function, variable, structure from XTAGS ---
(defun ac-mode-try-complete-xtags ()
  (when (or (not (find *ac-mode-complete-type*
				(list *ac-mode-complete-type-default*
					  *ac-mode-complete-type-xtags*)
					   :test 'string=))
			(not (file-exist-p (merge-pathnames *tags-file-name* (append-trail-slash (default-directory))))))
	(return-from ac-mode-try-complete-xtags))
  (let ((buffer (with-set-buffer (ed::tags-setup-buffer)))
		start end string list prefix
		(case-insensitive ed::tags-case-insensitive))
	(multiple-value-setq (start end string)
	  (ac-mode-get-w_))
	(when (and buffer (stringp string) (not (string= string "")))
	  (with-set-buffer
		(save-excursion
		  (set-buffer buffer)
		  (while (scan-buffer (concat "^[]\\(" (regexp-quote string) ".*?\\)")
							  :case-fold case-insensitive
							  :tail t :regexp t)
			(pushnew (match-string 1) list :test 'equal))
		  (when list
			(multiple-value-bind (str lst pre)
				(*do-completion string :list nil list)
			  (setf list (sort lst 'string<)
					prefix pre))))))
	(cond (list
		   (unless *ac-mode-string*
			 (setf *ac-mode-string* string))
		   (setf *ac-mode-string-start* start
				 *ac-mode-string-end* end
				 *ac-mode-completion-list* list
				 *ac-mode-string-prefix* prefix
				 *ac-mode-complete-type*
				 *ac-mode-complete-type-xtags*
				 *ac-mode-complete-module* 'ac-mode-try-complete-xtags))
		  ((not *ac-mode-fix-module*)
		   (setf *ac-mode-complete-type* *ac-mode-complete-type-default*)
		   nil))))

;;; 12. Dynamic abbrev current buffer ---
(defun ac-mode-try-dabbrev-current-buffer ()
  (unless (find *ac-mode-complete-type*
				(list *ac-mode-complete-type-default*
					  *ac-mode-complete-type-dabbrev-local*)
				:test 'string=)
	(return-from ac-mode-try-dabbrev-current-buffer))
  (let ((*dabbrev-popup-this-buffer-only* t)
		start end list string)
	(multiple-value-setq (list start end)
	  (ac-mode-get-dabbrev 'ac-mode-try-dabbrev-current-buffer))
	(cond ((and start end list
				(setf string (buffer-substring start end)))
		   (unless *ac-mode-string*
			 (setf *ac-mode-string* string))
		   (setf *ac-mode-string-start* start
				 *ac-mode-string-end* end
				 *ac-mode-completion-list* list
				 *ac-mode-complete-type*
				 *ac-mode-complete-type-dabbrev-local*
				 *ac-mode-complete-module* 'ac-mode-try-dabbrev-current-buffer))
		  ((not *ac-mode-fix-module*)
		   (setf *ac-mode-complete-type* *ac-mode-complete-type-default*)
		   nil))))

;;; 13. Dynamic Abbrev all buffer ---
(defun ac-mode-try-dabbrev-all-buffer ()
  (unless (find *ac-mode-complete-type*
				(list *ac-mode-complete-type-default*
					  *ac-mode-complete-type-dabbrev-global*)
				:test 'string=)
	(return-from ac-mode-try-dabbrev-all-buffer))
  (let (start end list string)
	(multiple-value-setq (list start end)
	  (ac-mode-get-dabbrev 'ac-mode-try-dabbrev-all-buffer))
	(cond ((and start end list (setf string (buffer-substring start end)))
		   (unless *ac-mode-string*
			 (setf *ac-mode-string* string))
		   (setf *ac-mode-string-start* start
				 *ac-mode-string-end* end
				 *ac-mode-completion-list* list
				 *ac-mode-complete-type*
				 *ac-mode-complete-type-dabbrev-global*
				 *ac-mode-complete-module* 'ac-mode-try-dabbrev-all-buffer))
		  ((not *ac-mode-fix-module*)
		   (setf *ac-mode-complete-type* *ac-mode-complete-type-default*)
		   nil))))

;;; 14. default tab keybind ---
(defun ac-mode-default-keybind ()
  (let ((local (lookup-keymap
				(local-keymap)
				#\C-i))
		(global (lookup-keymap
				 *global-keymap*
				 #\C-i)))
	(cond ((and (fboundp local)
				(not (eq local 'ac-mode-complete-or-indent)))
		   (funcall local))
		  ((and (fboundp global)
				(not (eq local 'ac-mode-complete-or-indent)))
		   (let ((*last-command-char* #\TAB))
			 (funcall global))))))

;;; 15. insert TAB code ---
(defun ac-mode-insert-tab-code ()
  (self-insert-command))

;;; complete line
(defvar *ac-mode-complete-type-line* "Line")
(defun ac-mode-try-complete-line ()
  (unless (find *ac-mode-complete-type*
				(list *ac-mode-complete-type-default*
					  *ac-mode-complete-type-line*)
				:test 'string=)
	(return-from ac-mode-try-complete-line))
  (let* ((bol (save-excursion (goto-bol) (point)))
		 (query (cond ((and (stringp *ac-mode-string*)
							(not (equal *ac-mode-string* "")))
					   (concat "^.*" (regexp-quote *ac-mode-string*)))
					  (t (save-excursion
						   (concat "^"
								   (regexp-quote
									(string-left-trim
									 " \t" (buffer-substring bol (point)))))))))
		 (hash (make-hash-table :test 'equal))
		 lst)
	(save-excursion
	  (goto-bol)
	  (backward-char)
	  (setf (gethash (buffer-substring bol (point)) hash) t)
	  (while (scan-buffer query :regexp t :reverse t)
		(let ((str (buffer-substring
					(progn (goto-bol) (point))
					(progn (goto-eol) (point)))))
		  (unless (gethash str hash)
			(push str lst)
			(setf (gethash str hash) (point))))
		(unless (previous-line)
		  (return))))
	(save-excursion
	  (goto-eol)
	  (forward-char)
	  (setf lst (append (last lst)
						(let (l)
						  (while (scan-buffer query :regexp t)
							(let ((str (buffer-substring
										(progn (goto-bol) (point))
										(progn (goto-eol) (point)))))
							  (unless (gethash str hash)
								(push str l)
								(setf (gethash str hash) (point))))
							(unless (next-line)
							  (return)))
						  (reverse l))
						(butlast lst))))
	(when lst
	  (setf *ac-mode-string-start* bol
			*ac-mode-string-end* (point)
			*ac-mode-completion-list* lst
			*ac-mode-complete-type*
			*ac-mode-complete-type-line*
			*ac-mode-complete-module* 'ac-mode-try-complete-line))))

;;; complete list
(defvar *ac-mode-complete-user-list* nil)
(defvar *ac-mode-complete-user-list-ignore-case* t)
(defun ac-mode-try-complete-list ()
  (unless (and (find *ac-mode-complete-type*
					 (list *ac-mode-complete-type-default*
						   *ac-mode-complete-type-list*)
					 :test 'string=)
			   *ac-mode-complete-user-list*)
	(return-from ac-mode-try-complete-list))
  (let (start end string list type)
	(multiple-value-setq (start end string)
	  (ac-mode-get-w_))
	(when (or (and start end (< start end))
			  (and start end
				   (find 'ac-mode-try-complete-list
						  *ac-mode-allow-empty-string-modules*)
				   (= start end)))
	  (ac-mode-with-complete+
	   (ac-mode-try-complete-list)
	   (multiple-value-bind (str lst pre)
		   (*do-completion string (if *ac-mode-complete-user-list-ignore-case*
									  :list-ignore-case
									:list)
						   nil *ac-mode-complete-user-list*)
		 (setf list (sort lst 'string<)
			   prefix pre)
		 (when (some #'(lambda (x) (consp x))
					 *ac-mode-complete-user-list*)
		   (setf list (mapcar #'(lambda (x)
								  (find x *ac-mode-complete-user-list*
										:test 'ac-mode-equal-if-consp-use-car)) list)))
		 list))
	  (cond (list
			 (unless *ac-mode-string*
			   (setf *ac-mode-string* string))
			 (setf *ac-mode-string-start* start
				   *ac-mode-string-end* end
				   *ac-mode-completion-list* list
				   *ac-mode-string-prefix* prefix
				   *ac-mode-complete-type*
				   *ac-mode-complete-type-list*
				   *ac-mode-complete-module* 'ac-mode-try-complete-list))
			((not *ac-mode-fix-module*)
			 (setf *ac-mode-complete-type* *ac-mode-complete-type-default*)
			 nil)))))

(defun ac-mode-do ()
  (let ((*complete+-substring-match* :never)
		(*complete+-skip-match* :never))
	(dolist (command *ac-mode-command*)
	  (run-hook-with-args '*ac-mode-before-search-command-hook* command)
	  (when (funcall command)
		(run-hook-with-args '*ac-mode-after-search-command-hook* command)
		(return)))
	(let ((tmp (car *ac-mode-completion-list*)))
	  (setf *ac-mode-string-match* (ac-mode-car-if-consp tmp)))
	(when (or (and (null (cdr *ac-mode-completion-list*))
				   (string= *ac-mode-string-match* *ac-mode-string*)
				   *ac-mode-string*
				   (not (file-directory-p (substitute-string
										   *ac-mode-string* "\\\\\\\\" "\\\\"))))
			  (not *ac-mode-completion-list*))
	  (setf *ac-mode-loop* nil))
	(unless *executing-macro*
	  (update-mode-line))))

(defun ac-mode-quit ()
  "中止"
  (undo)
  (setf *ac-mode-loop* nil))

(defun ac-mode-return ()
  "popup-stringで選択している文字列に確定。
補完した文字列の最後尾にキャレットを移動。"
  (delete-region *ac-mode-string-start*
				 *ac-mode-string-end*)
  (insert (or *ac-mode-string-prefix* "")
		  *ac-mode-string-match*)
  (when (find *ac-mode-complete-module*
			  '(ac-mode-try-complete-line))
	(newline))
  (setf *ac-mode-loop* nil
		*ac-mode-string* *ac-mode-string-match*
		*ac-mode-string-end* (point)))

(defun ac-mode-self-insert (&optional (ch *ac-mode-command-char*))
  "文字入力"
  (cond ((and (graphic-char-p ch)
			  (find *ac-mode-complete-module* *ac-mode-use-syntax-modules*)
			  (not (string-match "\\sw\\|\\s_" (string ch))))
		 ;; *ac-mode-use-syntax-modules*のモジュールで補完してるときに
		 ;; 英/数/シンボルを構成する記号 以外が入力されたらac-mode終了
		 (ac-mode-return)
		 (setf *ac-mode-this-command* 'ac-mode-return)
		 (unread-char ch *keyboard*))
		((or (eq *ac-mode-this-command* 'ac-mode-self-insert)
			 (graphic-char-p ch))
		 ;; 印字文字ならインクリメンタルに補完
		 (setf *ac-mode-this-command* 'ac-mode-self-insert)
		 (setf *ac-mode-string*
			   (concat *ac-mode-string* (string ch)))
		 (insert (string ch))
		 (when (numberp *ac-mode-string-end*)
		   (setf *ac-mode-string-end*
				 (1+ *ac-mode-string-end*)))
		 (ac-mode-do))
		(t
		 ;; じゃなかったらac-mode終了して普通に入力したことにする
		 (unread-char ch *keyboard*)
		 (ac-mode-return))))

(defun ac-mode-delete-char ()
  "1文字削除。なくなったらac-mode終了"
  (let ((l (length *ac-mode-string*)))
	(if (zerop l)
		(ding)
	  (setf *ac-mode-string*
			(substring *ac-mode-string* 0 -1))))
  (when (plusp *ac-mode-string-end*)
	(delete-region *ac-mode-string-end* (decf *ac-mode-string-end*)))
  (when (eq *ac-mode-string-start*
			*ac-mode-string-end*)
	(setf *ac-mode-loop* nil)
	(return-from ac-mode-delete-char))
  (ac-mode-do))

(defun ac-mode-decision-or-self-insert ()
  "パスならセパレータを調整して確定後self-insert, 他はself-insert"
  (cond ((string= *ac-mode-complete-type*
				  *ac-mode-complete-type-file*)
		 (unless (find *ac-mode-command-char*
					   *ac-mode-string-file-separater*)
		   (if (char=  #\/ *ac-mode-command-char*)
			   (setf *ac-mode-command-char* #\\)
			 (setf *ac-mode-command-char* #\/)))
		 (delete-region *ac-mode-string-start*
						*ac-mode-string-end*)
		 (setf *ac-mode-string* (concat (or *ac-mode-string-prefix* "")
										(remove-trail-slash *ac-mode-string-match*))
			   *ac-mode-string-end*
			   (+ *ac-mode-string-start*
				  (length *ac-mode-string*)))
		 (insert *ac-mode-string*)
		 (unless (file-directory-p (substitute-string
									*ac-mode-string* "\\\\\\\\" "\\\\"))
		   (return-from ac-mode-decision-or-self-insert))
		 (when (string= *ac-mode-string-file-separater* "\\\\\\\\")
		   (setf *ac-mode-string*
				 (concat *ac-mode-string* "\\"))
		   (insert "\\")
		   (when (numberp *ac-mode-string-end*)
			 (setf *ac-mode-string-end*
				   (1+ *ac-mode-string-end*))))
		 (ac-mode-self-insert)
		 (undo-boundary))
		(t
		 (ac-mode-self-insert))))

(defvar *ac-mode-fix-module* nil);; non-nilならモジュールを固定する

(defun ac-mode-complete-string ()
  "補完候補に共通部分があれば補完、なければ次選択"
  (setf *ac-mode-fix-module* t)
  (cond ((or (equal *ac-mode-string*
					(concat (or *ac-mode-string-prefix* "")
							*ac-mode-string-decision*))
			 (equal *ac-mode-string* *ac-mode-string-decision*)
			 (path-equal *ac-mode-string*
						 (substitute-string
						  *ac-mode-string-decision* "\\\\\\\\" "\\\\")))
		 (ac-mode-select-next))
		(*ac-mode-completion-list*
		 (unless (string= *ac-mode-string* *ac-mode-string-decision*)
		   
		   (delete-region *ac-mode-string-start* *ac-mode-string-end*)
		   
		   (setf *ac-mode-string* (concat (or *ac-mode-string-prefix* "")
										  *ac-mode-string-decision*))
		   (insert *ac-mode-string*)
		   
		   (undo-boundary)
		   (setf *ac-mode-string-end*
				 (+ *ac-mode-string-start* (length *ac-mode-string*)))
		   (ac-mode-do)))))

(defun ac-mode-car-if-consp (x)
  (if (consp x) (car x) x))
(defun ac-mode-equal-if-consp-use-car (x y)
  (equal x (if (consp y)
			   (car y)
			 y)))

(defun ac-mode-select-next ()
  "次選択"
  (cond ((and (string= *ac-mode-complete-type*
					   *ac-mode-complete-type-file*)
			  (null (cdr *ac-mode-completion-list*)))
		 (setf *ac-mode-command-char* #\/)
		 (ac-mode-decision-or-self-insert))
		(t
		 (let ((lst (member *ac-mode-string-match*
							*ac-mode-completion-list*
							:test 'ac-mode-equal-if-consp-use-car)))
		   (setf *ac-mode-string-match*
				 (ac-mode-car-if-consp
				  (if (null (cdr lst))
					  (first *ac-mode-completion-list*)
					(second lst))))))))

(defun ac-mode-select-prev ()
  "前選択"
  (let ((lst (member *ac-mode-string-match*
					 (reverse *ac-mode-completion-list*)
					 :test 'ac-mode-equal-if-consp-use-car)))
	(setf *ac-mode-string-match*
		  (ac-mode-car-if-consp
		   (if (null (cdr lst))
			   (car (last *ac-mode-completion-list*))
			 (second lst))))))

(defun ac-mode-page-next ()
  "次ページ"
  (let (list page)
	(multiple-value-setq (list page)
	  (ac-mode-get-popup-string-list
	   *ac-mode-completion-list*
	   *ac-mode-string-match*
	   *ac-mode-max-view-item*))
	(setf *ac-mode-string-match*
		  (ac-mode-car-if-consp
		   (nth (min (* *ac-mode-max-view-item* page)
					 (* *ac-mode-max-view-item*
						(truncate (1- (length *ac-mode-completion-list*))
								  *ac-mode-max-view-item*)))
				*ac-mode-completion-list*)))))

(defun ac-mode-page-prev ()
  "前ページ"
  (interactive)
  (let (list page)
	(multiple-value-setq (list page)
	  (ac-mode-get-popup-string-list
	   *ac-mode-completion-list*
	   *ac-mode-string-match*
	   *ac-mode-max-view-item*))
	(setf *ac-mode-string-match*
		  (ac-mode-car-if-consp
		  (nth (max (* *ac-mode-max-view-item* (- page 2)) 0)
			   *ac-mode-completion-list*)))))

(defun ac-mode-upper-dir ()
  "パスなら１つ上のディレクトリ"
  (let ((string (buffer-substring *ac-mode-string-start* *ac-mode-string-end*)))
	(when (cond ((equal *ac-mode-complete-type* *ac-mode-complete-type-file*)
				 (cond ((string-match
						 "\\(\\(?:[a-zA-Z]:\\|^\\|~\\|//\\|\\.\\{1,2\\}\\)[^:*\"?|<>\t\n]*[/\\]\\)[^:*\"?|<>\t\n]*"
						 (remove-trail-slash string))
						(setf string (or (match-string 1) "")))
					   (t
						(setf string (remove-trail-slash string)))))
				((or (string-match "\\(.*\\)[^a-zA-Z]$" string)
					 (string-match "\\(.*[^a-zA-Z]\\)[a-zA-Z]*$" string))
				 (setf string (match-string 1))))
	  (delete-region *ac-mode-string-start* *ac-mode-string-end*)
	  (insert string)
	  (setf *ac-mode-string-end*
			(+ *ac-mode-string-start* (length string)))
	  (ac-mode-do))))

(defun ac-mode-backslash-to-slash ()
  "パスなら\\を/に変換"
  (when (and (string= *ac-mode-complete-type*
					  *ac-mode-complete-type-file*)
			 (or (string= *ac-mode-string-file-separater* "\\\\")
				 (string= *ac-mode-string-file-separater* "\\\\\\\\")))
	(setf *ac-mode-string*
		  (substitute-string
		   (substitute-string
			*ac-mode-string*
			"\\\\\\\\" "/")
		   "\\\\" "/"))
	(delete-region *ac-mode-string-start*
				   *ac-mode-string-end*)
	(setf *ac-mode-string-file-separater* "/")
	(insert *ac-mode-string*)
	(setf *ac-mode-string-end* (point))
	(unless *executing-macro*
	  (refresh-screen))
	(ac-mode-do)))

(defun ac-mode-slash-to-backslash ()
  "パスなら/を\\に変換"
  (when (and (string= *ac-mode-complete-type*
					  *ac-mode-complete-type-file*)
			 (cond ((string= *ac-mode-string-file-separater* "/")
					(setf *ac-mode-string-file-separater* "\\\\"
						  *ac-mode-string* (substitute-string
											*ac-mode-string*
											"/" "\\\\")))
				   ((and (string= *ac-mode-string-file-separater* "\\\\")
						 (eq *ac-mode-last-command* 'ac-mode-slash-to-backslash))
					(setf *ac-mode-string-file-separater* "\\\\\\\\"
						  *ac-mode-string* (substitute-string
											*ac-mode-string*
											"\\\\" "\\\\\\\\")))
				   ((and (string= *ac-mode-string-file-separater* "\\\\\\\\")
						 (eq *ac-mode-last-command* 'ac-mode-slash-to-backslash))
					(setf *ac-mode-string-file-separater* "\\\\"
						  *ac-mode-string* (substitute-string
											*ac-mode-string*
											"\\\\\\\\" "\\\\")))))
	(delete-region *ac-mode-string-start*
				   *ac-mode-string-end*)
	(insert *ac-mode-string*)
	(setf *ac-mode-string-end* (point))
	(ac-mode-do)))

(defun ac-mode-select-complete-type ()
  (flet ((init-list ()
		   (setf *ac-mode-complete-type* *ac-mode-complete-type-default*
				 *ac-mode-completion-list* nil)
		   (ac-mode-do)))
	(let (menu)
	  (setf menu
			(define-popup-menu
			  (:item nil "インデント(&I)"
			   #'(lambda () (interactive)
				   (setf *ac-mode-command* '(ac-mode-try-indent
											 ac-mode-default-keybind))
				   (init-list)))
			  (:item nil "デフォルトの操作(&O)"
			   #'(lambda () (interactive)
				   (setf *ac-mode-command* '(ac-mode-default-keybind))))
			  (:item nil "TAB文字挿入(&T)"
			   #'(lambda () (interactive)
				   (setf *ac-mode-command* '(ac-mode-insert-tab-code))
				   (init-list)))
			  :sep
			  (:item nil "URI補完(&U)"
			   #'(lambda () (interactive)
				   (setf *ac-mode-command* '(ac-mode-try-complete-URI))
				   (init-list)))
			  (:item nil "ファイル名補完(&P)"
			   #'(lambda () (interactive)
				   (setf *ac-mode-command* '(ac-mode-try-complete-file))
				   (init-list)))
			  :sep
			  (:item nil "Abbrev Local(&A)"
			   #'(lambda () (interactive)
				   (setf *ac-mode-command* '(ac-mode-try-abbrev-local))
				   (init-list))
			   #'(lambda () (and (not abbrev-mode)
								 (not (modulep "snippet"))
								 :disable)))
			  (:item nil "Abbrev Global(&A)"
			   #'(lambda () (interactive)
				   (setf *ac-mode-command* '(ac-mode-try-abbrev-global))
				   (init-list))
			   #'(lambda () (and (not abbrev-mode)
								 (not (modulep "snippet"))
								 :disable)))
			  :sep
			  (:item nil "Lisp Symbol(&l)"
			   #'(lambda () (interactive)
				   (setf *ac-mode-command* '(ac-mode-try-lisp-complete-symbol))
				   (init-list))
			   #'(lambda ()
				   (unless (find buffer-mode *ac-mode-lisp-mode* :test 'string=)
					 :disable)))
			  (:item nil "関数名補完(&F)"
			   #'(lambda () (interactive)
				   (setf *ac-mode-command* '(ac-mode-try-complete-function))
				   (init-list))
			   #'(lambda ()
				   (unless (and (boundp 'ed::build-summary-function)
								ed::build-summary-function)
					 :disable)))
			  (:item nil "キーワード補完(&K)"
			   #'(lambda () (interactive)
				   (setf *ac-mode-command* '(ac-mode-try-complete-keyword))
				   (init-list))
			   #'(lambda () (unless keyword-hash-table :disable)))
			  (:item nil "XTAGS補完(&X)"
			   #'(lambda () (interactive)
				   (setf *ac-mode-command* '(ac-mode-try-complete-xtags))
				   (init-list)))
			  :sep
			  (:item nil "現在のバッファからdabbrev(&D)"
			   #'(lambda () (interactive)
				   (setf *ac-mode-command* '(ac-mode-try-dabbrev-current-buffer))
				   (init-list)))
			  (:item nil "全てのバッファからdabbrev(&D)"
			   #'(lambda () (interactive)
				   (setf *ac-mode-command* '(ac-mode-try-dabbrev-all-buffer))
				   (init-list)))
			  ))
	  (when *ac-mode-menu*
		(mapc #'(lambda (item)
				  (cond ((eq :sep item)
						 (insert-menu-separator menu 0))
						((and (listp item)
							  (or (eq (car item) :sep)
								  (eq (car item) :separator)))
						 (insert-menu-separator menu 0 (second item)))
						((and (listp item)
							  (eq (car item) :item))
						 (insert-menu-item menu 0 (second item) (third item)
										   (eval (fourth item)) (fifth item))
						 )))
			  (reverse *ac-mode-menu*)))
	  (track-popup-menu menu))))

(defun ac-mode-get-beginning-of-string ()
  (when (ac-mode-get-syntax ":string")
	(save-excursion
	  (while (and (scan-buffer "\\s\"" :regexp t :reverse t :no-dup t)
				  (equal (parse-point-syntax
						  (1- (match-beginning 0)))
						 :string)))
	  (point))))

(defun ac-mode-get-end-of-string ()
  (when (ac-mode-get-syntax ":string")
	(save-excursion
	  (while (and (scan-buffer "\\s\"" :regexp t :tail t)
				  (equal (parse-point-syntax
						  (1+ (match-beginning 0)))
						 :string)))
	  (backward-char)
	  (point))))

(defun ac-mode-get-syntax (str)
  (when (save-excursion (forward-char))
	(let ((ch (char (buffer-substring (point) (1+ (point))) 0)))
	  (cond ((equal str ":string")
			 (eq (parse-point-syntax) :string))
			((equal str ":comment")
			 (eq (parse-point-syntax) :comment))
			((equal str ":tag")
			 (eq (parse-point-syntax) :tag))
			((equal str "c++-comment")
			 (syntax-c++-comment-p ch))
			((equal str "close")
			 (syntax-close-p ch))
			((equal str "close-tag")
			 (syntax-close-tag-p ch))
			((equal str "end-c++-comment")
			 (syntax-end-c++-comment-p ch))
			((equal str "end-comment")
			 (syntax-end-comment-p ch))
			((equal str "end-multi-comment-1")
			 (syntax-end-multi-comment-1-p ch))
			((equal str "end-multi-comment-2")
			 (syntax-end-multi-comment-2-p ch))
			((equal str "escape")
			 (syntax-escape-p ch))
			((equal str "junk")
			 (syntax-junk-p ch))
			((equal str "math")
			 (syntax-math-p ch))
			((equal str "open")
			 (syntax-open-p ch))
			((equal str "open-tag")
			 (syntax-open-tag-p ch))
			((equal str "punctuation")
			 (syntax-punctuation-p ch))
			((equal str "quote")
			 (syntax-quote-p ch))
			((equal str "start-column-comment")
			 (syntax-start-column-comment-p ch))
			((equal str "start-comment")
			 (syntax-start-comment-p ch))
			((equal str "start-multi-comment-1")
			 (syntax-start-multi-comment-1-p ch))
			((equal str "start-multi-comment-2")
			 (syntax-start-multi-comment-2-p ch))
			((equal str "string")
			 (syntax-string-p ch))
			((equal str "symbol")
			 (syntax-symbol-p ch))
			((equal str "symbol-prefix")
			 (syntax-symbol-prefix-p ch))
			((equal str "whitespace")
			 (syntax-whitespace-p ch))
			((equal str "word")
			 (syntax-word-p ch))))))

(defun ac-mode-buffer-check ()
  (setf *ac-mode-loop* nil
		*ac-mode-complete-type*
		*ac-mode-complete-type-default*)
  (erase-popup)
  (save-excursion
	(set-buffer *ac-mode-buffer*)
	(clear-reverse-region))
  (unless *executing-macro*
	(update-mode-line)
	(refresh-screen))
  (when (find-package "treeview")
	(delete-hook (intern "*treeview-focus-treeview-hook*" "treeview")
				 'ac-mode-buffer-check)))

(defvar *ac-mode-string-prefix* nil)
(defvar *ac-mode-do-pre-hook* t)

(defun ac-mode-complete-or-indent (&optional number)
  (interactive "*p")
  (unwind-protect
	  (let (*ac-mode-completion-list*
			(*ac-mode-complete-type*
			 *ac-mode-complete-type-default*)
			(*ac-mode-command*
			 *ac-mode-command-list*)
			*ac-mode-this-command*
			*ac-mode-last-command*
			*ac-mode-string*
			*ac-mode-string-start*
			*ac-mode-string-end*
			*ac-mode-string-decision*
			*ac-mode-string-match*
			*ac-mode-string-prefix*
			*ac-mode-string-file-separater*
			(*ac-mode-loop* t)
			(*ac-mode-buffer* (selected-buffer))
			*ac-mode-fix-module*
			keymap (keymapview "")
			*ac-mode-end-marker*
			*ac-mode-end+1-marker*
			*ac-mode-start-marker*
			(*ac-mode-allow-empty-string-modules* *ac-mode-allow-empty-string-modules*)
			(*ac-mode-use-complete+-modules* *ac-mode-use-complete+-modules*)
			*ac-mode-complete-user-list-ignore-case*
			*ac-mode-complete-user-list*
			(*ac-mode-complete-type-list* *ac-mode-complete-type-list*)
			(*ac-mode-complete-module* *ac-mode-complete-module*)
			(*ac-mode-highlight-complete-word-position* (point))
			(*ac-mode-use-syntax-modules* *ac-mode-use-syntax-modules*)
			looped)
		(cond (number
			   (ac-mode-select-complete-type))
			  (*ac-mode-do-pre-hook*
			   (run-hook-with-args-until-success 'ac-mode-pre-completion-hook)))
		(ac-mode-do)
		(when (and (null (cdr *ac-mode-completion-list*))
				   *ac-mode-completion-list*
				   (find *ac-mode-complete-module* *ac-mode-decision-if-unique*))
		  (setf *ac-mode-loop* nil
				*ac-mode-this-command* 'ac-mode-return)
		  (ac-mode-return))
		(when (find-package "treeview")
		  (add-hook (intern "*treeview-focus-treeview-hook*" "treeview")
					'ac-mode-buffer-check))
		(run-hooks '*ac-mode-before-main-loop-hook*)
		(while *ac-mode-loop*
		  (let ((tmp (ac-mode-get-commond-prefix
					  *ac-mode-completion-list*)))
			(cond ((and tmp (not (string= tmp "")))
				   (setf *ac-mode-string-decision* tmp)
				   (unless looped
					 (delete-region *ac-mode-string-start* *ac-mode-string-end*)
					 (setf *ac-mode-string* (concat (or *ac-mode-string-prefix* "")
													*ac-mode-string-decision*))
					 (insert *ac-mode-string*)
					 (undo-boundary)
					 (setf *ac-mode-string-end*
						   (+ *ac-mode-string-start* (length *ac-mode-string*)))))
				  (t
				   (setf *ac-mode-string-decision*
						 *ac-mode-string*))))
		  (setf looped t)
		  ;popup-listだと入力を取られたり色々面倒なのでpupup-string
		  (unless *executing-macro*
			(let (list page max len)
			  (multiple-value-setq (list page)
				(ac-mode-get-popup-string-list
				 *ac-mode-completion-list*
				 *ac-mode-string-match*
				 *ac-mode-max-view-item*))
			  (setf len (length *ac-mode-completion-list*)
					max (ceiling len *ac-mode-max-view-item*))
			  (let ((point (point)))
				(reverse-region *ac-mode-string-start*
								*ac-mode-string-end* nil)
				(insert (substring *ac-mode-string-match*
								   (min (- *ac-mode-string-end* *ac-mode-string-start*)
										(length *ac-mode-string-match*))))
				;; highlight for dabbrev-next/dabbrev-prev
				(when (and *ac-mode-highlight-complete-word*
						   (eq *ac-mode-complete-module*
							   'ac-mode-try-dabbrev-current-buffer))
				  (let ((point (point)))
					(save-excursion
					  (delete-text-attributes 'ac-mode-dabbrev)
					  (goto-char *ac-mode-string-start*)
					  (cond ((save-excursion
							   (and (scan-buffer (concat "\\_<" (regexp-quote *ac-mode-string-match*) "\\_>")
												 :regexp t
												 :reverse (equal "backward" *ac-mode-complete-dabbrev-direction*)
												 :no-dup t)
									(pos-visible-in-window-p (match-beginning 0))))
							 (while (and (scan-buffer (concat "\\_<" (regexp-quote *ac-mode-string-match*) "\\_>")
													  :regexp t
													  :reverse (equal "backward" *ac-mode-complete-dabbrev-direction*)
													  :no-dup t)
										 (pos-visible-in-window-p (match-beginning 0)))
							   (apply 'set-text-attribute
									  (match-beginning 0)
									  (match-end 0)
									  'ac-mode-dabbrev
									  *ac-mode-highlight-complete-word-attribute*)))
							(t
							 (setf *ac-mode-show-popup* t))))))
				(start-selection 2)
				(goto-char point)
				(clear-undo-boundary)
				(refresh-screen))
			  (when *ac-mode-show-popup*
				(popup-string
				 (format nil " *** ~A ***~%~D items (~D/~D)
---------------------------~%~{~%~A~}"
						 *ac-mode-complete-type* len
						 page max
						 (mapcar #'(lambda (item)
									 (let ((match *ac-mode-string-match*))
									   (if (string= match (if (consp item) (car item) item))
										   (format nil "~A~A~20T~A" *ac-mode-mark-current*
												   (ac-mode-car-if-consp item)
												   (if (consp item) (cdr item) ""))
										 (format nil "~A~A~20T~A" *ac-mode-mark-other*
												 (ac-mode-car-if-consp item)
												 (if (consp item) (cdr item) "")))))
								 list))
				 (point))))
			(continue-popup))
		  (let ((*ac-mode-command-char* (read-char *keyboard*)))
			(when (get-selection-type)
			  (delete-region (selection-mark) (selection-point))
			  (stop-selection))
			(setf *ac-mode-this-command*
				  (lookup-keymap (or keymap *ac-mode-internal-map*) *ac-mode-command-char* t))
			(if *ac-mode-loop*
				(cond ((keymapp *ac-mode-this-command*);prefix
					   (setf keymap *ac-mode-this-command*)
					   (setf keymapview
							 (concat keymapview (key-to-string *ac-mode-command-char*) " "))
					   (message "~A-" keymapview))
					  (*ac-mode-this-command*
					   (when keymap
						 (setf keymapview
							   (concat keymapview (key-to-string *ac-mode-command-char*)))
						 (message "~A" keymapview))
					   (funcall *ac-mode-this-command*)
					   (setf keymap nil keymapview ""
							 *ac-mode-last-command* *ac-mode-this-command*))
					  (t
					   (ac-mode-self-insert *ac-mode-command-char*)
					   (setf keymap nil keymapview "")
;; 					   (unless *ac-mode-this-command*
;; 						 (undo))
					   ))
			  (unread-char *ac-mode-command-char* *keyboard*)))
		  (run-hooks '*ac-mode-main-loop-hook*))
		(when (and *ac-mode-highlight-complete-word*
				   (eq *ac-mode-complete-module*
					   'ac-mode-try-dabbrev-current-buffer)
				   *ac-mode-highlight-complete-word-position*)
		  (setf ac-mode-highlight-complete-word-last-position
				*ac-mode-highlight-complete-word-position*)
		  (when (pos-visible-in-window-p *ac-mode-highlight-complete-word-position*)
			(delete-text-attributes 'ac-mode-dabbrev)))
		(run-hooks '*ac-mode-complete-hook*)
		t)
	(erase-popup)
	(when (find-package "treeview")
	  (delete-hook (intern "*treeview-focus-treeview-hook*" "treeview")
				   'ac-mode-buffer-check))
	(clear-reverse-region)
	(unless *executing-macro*
	  (update-mode-line)
	  (refresh-screen))))

(defun ac-mode (&optional (arg nil sv))
  (interactive "p")
  (toggle-mode 'ac-mode-on arg sv)
  (if ac-mode-on
	  (set-minor-mode-map *ac-mode-map*)
	(unset-minor-mode-map *ac-mode-map*))
  (unless *executing-macro*
	(update-mode-line)))

(defun ac-mode-on ()
  (interactive)
  (ac-mode t))

(defun ac-mode-off ()
  (interactive)
  (ac-mode nil))

(defun ac-mode-complete-word-next ()
  "カレントバッファから単語を前方補完"
  (interactive "*")
  (let ((*ac-mode-allow-empty-string-modules*
		 '(ac-mode-try-dabbrev-current-buffer))
		(*ac-mode-command-list*
		 '(ac-mode-try-dabbrev-current-buffer))
		(*ac-mode-complete-dabbrev-direction* "forward")
		(*ac-mode-use-complete+-modules*
		 '(ac-mode-try-dabbrev-current-buffer))
		(*ac-mode-show-popup* *ac-mode-show-popup-complete-word*)
		(*ac-mode-highlight-complete-word* t)
		(*ac-mode-do-pre-hook* nil))
	(declare (special *ac-mode-command-list*))
	(ac-mode-complete-or-indent)))

(defun ac-mode-complete-word-prev ()
  "カレントバッファから単語を後方補完"
  (interactive "*")
  (let ((*ac-mode-allow-empty-string-modules*
		 '(ac-mode-try-dabbrev-current-buffer))
		(*ac-mode-command-list*
		 '(ac-mode-try-dabbrev-current-buffer))
		(*ac-mode-use-complete+-modules*
		 '(ac-mode-try-dabbrev-current-buffer))
		(*ac-mode-complete-dabbrev-direction* "backward")
		(*ac-mode-show-popup* *ac-mode-show-popup-complete-word*)
		(*ac-mode-highlight-complete-word* t)
		(*ac-mode-do-pre-hook* nil))
	(declare (special *ac-mode-command-list*))
	(ac-mode-complete-or-indent)))

(defun ac-mode-complete-variable ()
  "カレントバッファで定義された変数を補完"
  (interactive "*")
  (let ((*ac-mode-allow-empty-string-modules*
		 '(ac-mode-try-complete-variable))
		(*ac-mode-command-list*
		 '(ac-mode-try-complete-variable))
		(*ac-mode-use-complete+-modules*
		 '(ac-mode-try-complete-variable))
		(*ac-mode-do-pre-hook* nil))
	(declare (special *ac-mode-command-list*))
	(ac-mode-complete-or-indent)))

(defun ac-mode-complete-function ()
  "カレントバッファで定義された関数を補完"
  (interactive "*")
  (let ((*ac-mode-allow-empty-string-modules*
		 '(ac-mode-try-complete-function))
		(*ac-mode-command-list*
		 '(ac-mode-try-complete-function))
		(*ac-mode-use-complete+-modules*
		 '(ac-mode-try-complete-function))
		(*ac-mode-do-pre-hook* nil))
	(declare (special *ac-mode-command-list*))
	(ac-mode-complete-or-indent)))

(defun ac-mode-complete-keyword ()
  "キーワードを補完"
  (interactive "*")
  (let ((*ac-mode-allow-empty-string-modules*
		 '(ac-mode-try-complete-keyword))
		(*ac-mode-command-list*
		 '(ac-mode-try-complete-keyword))
		(*ac-mode-use-complete+-modules*
		 '(ac-mode-try-complete-keyword))
		(*ac-mode-do-pre-hook* nil))
	(declare (special *ac-mode-command-list*))
	(ac-mode-complete-or-indent)))

(defun ac-mode-complete-line ()
  "行を補完する"
  (interactive "*")
  (let ((*ac-mode-command-list*
		 '(ac-mode-try-complete-line))
		(*ac-mode-do-pre-hook* nil))
	(declare (special *ac-mode-command-list*))
	(define-key *ac-mode-internal-map* #\C-l 'ac-mode-select-prev)
	(ac-mode-complete-or-indent)
	(undefine-key *ac-mode-internal-map* #\C-l)))

;;; ac-mode.l ends here
