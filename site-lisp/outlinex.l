;;; -*- Mode: Lisp; Package: USER; Last modified: "2010/04/14 07:34:47" -*-
;;;
;;; This file is not part of xyzzy.
;;;
;;;   OutlineX --- 簡易アウトライン
;;;
;;;     by HIE Masahiro <madoinux@gmail.com>
#|

■概要

  バッファから指定したパターンにマッチする行を抽出します。


■インストール

  1. outlinex.l を site-lisp にコピーする。

  2. 必要に応じ，バイトコンパイルする。

       M-x byte-compile-file

  3. .xyzzy か siteinit.l に以下の記述を追加する。

      (require "outlinex")

  4. xyzzy を再起動し，設定を反映させる。
     siteinit.l に記述した場合は再ダンプもする。


■起動方法

    M-x olx           : 正規表現を指定して実行

    M-x olx-selection : セレクションの文字列をキーとして実行
                        正規表現OFFで実行します。

    M-x olx-flex      : 正規表現既定値を使って実行
                        ローカル変数 olx-pattern に設定された正規表現で実行します。
                        モード毎に既定値を設定するなどして使います。(設定例参照)

    M-x olx-reload    : 前回の検索パターンで再度実行
                        outlinex バッファが存在している＆outlinex バッファがアクティブ
                        でない場合に実行すると，outlinex バッファを更新します。

    M-x olx-dialog    : ダイアログからパターンを指定して実行
                        単語単位検索，大文字小文字区別，分割方法を指定する場合は，
                        このコマンドで。


■キーバインド

  アウトラインバッファにおけるキーバインドは，以下のとおり。

    q   : 終了
    TAB : カーソル位置のノードを閲覧
    SPC : カーソル位置のノードに移動
    RET : カーソル位置のノードに移動し終了

    M-Up       : 同時上向スクロール
    M-Down     : 同時下向スクロール

    d : 削除マークをつける（ソースバッファは編集しません）
    m : マークをつける（着色するだけ）
    p : 現在行をポップアップ表示
    t : ポップアップ表示をトグル
    u : マークを外す
    U : 全てのマークを外す
    x : マークを実行
    e : 行番号を削除


■設定例

  ○F3 系占有設定例

    ;;; セレクションの文字列をキーとして実行 (非正規表現)
    (global-set-key #\F3 'olx-selection)
    (set-function-bar-label #\F3 "olx-select")

    ;;; 正規表現を指定して実行
    (global-set-key #\S-F3 'olx)
    (set-function-bar-label #\S-F3 "olx")

    ;;; ローカルな正規表現を使って実行
    (global-set-key #\S-C-F3 'olx-flex)
    (set-function-bar-label #\S-C-F3 "olx-flex")

    ;;; 前回の検索パターンで再度実行 (or olx-rerun)
    (global-set-key #\M-F3 'olx-reload)
    (set-function-bar-label #\M-F3 "olx-reload")

    ;;; ダイアログからパターンを指定して実行
    (global-set-key #\C-F3 'olx-dialog)
    (set-function-bar-label #\C-F3 "olx-dialog")

  ○既定値の変更

    ;;; 検索パターンの既定値
    (setq-default olx-pattern "[■□●○◎◆◇]")

    ;;; 縦に分割する
    (setq-default olx-vert-p t)

    ;;; 行番号の表示色
    (setq *olx-color-line-number* '(:color 6 9))

  ○モード毎の検索パターンを設定例

    ;;; lisp-mode
    (add-hook '*lisp-mode-hook*
              #'(lambda ()
                  (setq olx-pattern "^\\(;;;\\|(def\\)")
                  (setq olx-vert-p t)))

    ;;; html-mode
    (add-hook 'ed::*html-mode-hook*
              #'(lambda ()
                  (setq olx-pattern "\\(<title\\|<h[0-4]\\)\\(>\\| +.*?>\\)")
                  (setq olx-coloring nil)))

  ○<strike>桃好きな方</strike>psearch愛好者向け

    ;;; psearch のような色付けをする
    (setq *olx-coloring-like-psearch* t)

    ;;; psearch のような色付けをした場合の色設定
    (setq *olx-attribute-like-psearch* '(:foreground 1 :background 2))

    ;;; psearch のような色付けを削除
    (global-set-key '(#\C-c #\F3) 'olx-delete-attributes)

    ;;; ↓以下は，psearch をロードした後に設定すること。↓

    ;;; psearch 実行時に olx の色を消す
    (add-hook '*psearch-hook* 'olx-delete-attributes)

    ;;; olx 実行時に psearch の色を消す
    (defun olx-delete-psearch-attributes ()
      "outlinex: psearch の色付けを削除"
      (when (fboundp 'psearch-delete-attributes)
        (psearch-delete-attributes)))
    (add-hook '*olx-pre-hook* 'olx-delete-psearch-attributes)

    ;;; 色を消したい時は psearch の色付けも同時に削除
    (defun olx-delete-attributes-with-psearch ()
      "outlinex: olx と psearch の色付けを同時に削除"
      (interactive)
      (olx-delete-attributes)
      (olx-delete-psearch-attributes))
    (global-set-key '(#\C-c #\]) 'olx-delete-attributes-with-psearch)

    ;;; olx-selection でポイントの文字列を取得
    (setq *olx-use-psearch-get-string* t)

  とか。


■更新履歴

  [Version 3.06] 2010-04-14 (水)
  ・olx-reload の際に，場合によりソースバッファのデータを壊してしまう
    不具合を修正した。(T-T)
  ・抽出対象がなかった場合に，アウトラインバッファを削除しないようにした。
    (リロード時に抽出対象がないと穴があくため)
  ・ノードに移動時，必ずソースバッファに移動するように。
  ・olx-rerun を追加した。昔の olx-reload と同じ。現在の olx-reload との
    違いは，既にアウトラインバッファが存在する場合に，どちらがアクティブ
    になるかだけ。
  ・その他細かな修正。

  [Version 3.05.1] 2010-04-02 (金)
  ・psearch.l より先にロードすると，psearch-delete-attributes の export に
    失敗する不具合を修正した(はず)。 
    olx-delete-psearch-attributes, olx-delete-attributes-with-psearch は，
    必要に応じ初期設定ファイルで設定するように。

  [Version 3.05] 2010-04-01 (木)
  ・ヒットした文字列が point より前にしかない場合にリストが作成され
    ない不具合を修正した。
  ・正規表現を使わない場合，regexp t のまま指定文字列を regexp-quote 
    して実行していたが，regexp nil で実行するようにした。
  ・複数のフレームで実行すると表示が崩れてしまうので，ソースバッファ毎に
    アウトラインバッファを持つようにした。
  ・dialogs.l から search-dialog と *search-dialog-template* を拝借。
      - ダイアログから検索オプションを指定できるようにした。
      - 検索オプションは，すべてバッファローカルな値として保持するようにした。
  ・psearch に改めて感化された。
      - ポイントの文字列を取得できるようにした。(要 psearch)
      - 色付けできるようにした。
          *olx-coloring-like-psearch*, *olx-attribute-like-psearch* 追加。
      - 色付け削除を考慮した。
          *olx-pre-hook*, olx-delete-attributes, olx-delete-psearch-attributes, 
          olx-delete-attributes-with-psearch 追加。
  ・モード行に，検索オプションを表示するようにした。
      [SWRE]─┬─ S or C : 大文字小文字を区別
              ├─ W      : 単語単位で検索
              ├─ R      : 正規表現
              └─ E      : エスケープシーケンスを理解
  ・olx-reload の挙動を多少変更した。(アウトラインの更新をそれらしく)
  ・縦分割を復活(--)。ついでに，ポップアップ表示するようにした。
      olx-vert-p 追加。
  ・検索文字列を *minibuffer-search-string-history* に追加するようにした。
  ・上下ノード入替(olx-transpose-node-up と olx-transpose-node-down)を廃止した。
    これで，ソースバッファを編集することはなくなった。
  ・olx-left-press(ダブルクリックで開く) は，デフォルトではキー割り当てをしない
    ようにした。(マウス選択ができなくなってしまうので)
  ・その他細かな修正多数。

  [Version 3.04] 2007-12-31 (月)
  ・MITライセンスにした。

  [Version 3.03] いつ？
  ・検索パターンの設定方法を変更した。設定方法は，設定例を参考に。検索パ
    ターンと着色有無は，以下のローカル変数で設定するように。
      olx-pattern
      olx-coloring
  ・以下の変数を削除した。
      *olx-pattern-default*
      *olx-coloring*
      *olx-coloring-exception-mode*
      *olx-flex-mode-list*
  ・行番号を削除できるようにした。(Jump はできなくなります)
  ・関数 outlinex を interactive でなくした。
  ・関数 olx-toggle-coloring を削除した。

  [Version 3.02] 2005-02-03 (Thu)
  ・grep を使用すると，隠しバッファに対して実行できないようなので，やは
    り自前でアウトラインを作成するようにした。(-.-)
  ・olx-scroll-up-both-window, olx-scroll-down-both-window を復活。(-.-)

  [Version 3.01] 2004-12-09 (Thu)
  ・マーク＆削除マークの着色方法を少し変更した。

  [Version 3.00] 2004-12-01 (Wed)
  ・スクラッチから書き直し，xyzzy の標準機能である grep を使用してアウト
    ラインを作成するようにした。
  ・ライセンスを NYSL とした。
  ・モード毎の検索パターンを変数で指定できるようにした。
  ・上下のノードを入れ替えられるようにした。
    （試作品:ソースバッファを編集します。）
  ・マークを付けたり，行削除とかできるようにした。
    （ソースバッファは編集しません。）
  ・着色しないモードをあらかじめ指定しておくようにした。
  ・行番号は常に表示するようにした。
  ・左右に表示できなくした。
  ・需要のなさそうな検索コマンドを削除した。
  ・その他いろいろな機能削除を含む変更。

  [Version 2.02] 2004/03/12 06:25:43 +0900
  ・行番号を text-attribute に持つようにした。
  ・キーワードの色付けをするようにした(適当)。
  ・ノード移動時にマークをつけるようにした。共通設定の「マーク行の行番号を反転」
    にチェックを入れておくと，移動した場所がわかりやすいかも。
  ・行番号を表示できるようにした。（但し，行番号を表示すると，モードによっては
    キーワードの色付けができなくなるものがありますのであしからず）。
  ・表示位置を切り替えられるようにした。
  ・olx-search では，キーワードを regexp-quote するようにした。
  ・ヘッダとフッタを削除した。
  ・かわりにパターンを表示したり，コピーしたりできるようにした。
  ・*outlinex-mode-hook* を作成した。
  ・*outlinex-default-size* を *outlinex-default-height* と *outlinex-default-width*
    に分けた。
  ・*outlinex-colors* を *outlinex-buffer-colors* に変更した。
  ・キーバインドを変更した。（私が使ってないものを削除してしまった）。
  ・なるべく余計な処理をしないように。
  ・それらしいとこに移動するのをもう少しそれらしく。
  ・サンプルを少し変更。
  ・その他いろいろ。

  [Version 2.01] 2003/04/19 13:52:37 +0900
  ・user パッケージに入れた。(__)
  ・関数名 outlinex を olx に変更した。
  ・psearch.l をまねて，olx-search を追加した。
  ・作成する対象がない場合は，アウトラインウィンドウを作らないようにした。
  ・スクロールマージンの既定値を 2 にした。
  ・サンプルの my-outlinex にちょっと追加。

  [Version 2.00] 2003/01/25 22:02:28 +0900
  ・outlinex パッケージに入れてみた。
  ・モード毎に処理を判断するあたりを削除し，「設定例」に加えてみた。
  ・スクロールマージンを設定した。
  ・色付けを変更できるようにした。
  ・パターンにマッチする文字列が無かった場合に，エラーが発生するよ
    うになっていたのを修正した。
  ・検索時に，マッチする文字列が無いと，カーソルが一人歩きしてしま
    うのを修正した。
  ・outlinex-auto, *outlinex-make-and-move* 削除。
  ・その他いろいろ。

  (snip)

  [Version 1.00] 2002/08/18(日)
  ・初版作成。(おそらく)


■ライセンス

  outlinex.l はMITライセンスに基づいて利用可能です。
  <http://www.opensource.org/licenses/mit-license.php>

Copyright (c) 2007-2010 HIE Masahiro

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.


■謝辞

outlinex を作成するにあたり，使わせていただいたり，参考にさせていただい
たりしたもの。

・亀井さんの xyzzy (dialogs.l)
    http://www.jsdlab.co.jp/~kei/xyzzy/

・ふかえさんの psearch
    http://www5e.biglobe.ne.jp/~fukafuka/xyzzy/script/

感謝です。

|#

(provide "outlinex")

(defconstant *olx-version* "3.06")


;;; ──────────────────────────────────── ;;;
;;;  ■ 変数設定 - 適当にカスタマイズするあたり
;;; ──────────────────────────────────── ;;;

(defvar-local olx-pattern
	      "^[ 　\t]*\\(\\[\\|[【■□○◎●]\\|[0-9A-Za-z]+[.)] \\|[0-9]+-[0-9]+\\. \\)"
	      "outlinex: 検索パターンの既定値")

(defvar-local olx-coloring t
	      "outlinex: 着色する")

(defvar-local olx-case-fold-search ':smart
	      "outlinex: 大文字小文字を区別する")

(defvar-local olx-word-search nil
	      "outlinex: 単語単位で検索する")

(defvar-local olx-vert-p t
	      "outlinex: 縦に分割する")

(defvar-local olx-num-of-rows 35
	      "outlinex: 縦に分割した際の表示列数
  - 「15 ～ (xyzzyのウィンドウ全体の幅-15)」の間で指定")

(defvar *olx-color-buffer* nil
  "outlinex: バッファの色
  - BGRを表す数値をベクタで指定 (set-buffer-colors に渡す)
  - #(0 #xe0ffff) とか")

(defvar *olx-color-line-number* '(:color 15)
  "outlinex: 行番号の表示色")

(defvar *olx-color-delete-line* '(:color 1 11)
  "outlinex: 削除マーク行の表示色")

(defvar *olx-color-mark-line* '(:color 4 11)
  "outlinex: マーク行の表示色")

(defvar *olx-color-point-line* '(:color 4 15)
  "outlinex: ポイント行の表示色")

(defvar *olx-recenter-arg* 2
  "outlinex: ノード移動時の表示位置(行数)")

(defvar *olx-use-psearch-get-string* nil
  "outlinex: psearchでポイントの文字列を取得")

(defvar *olx-coloring-like-psearch* nil
  "outlinex: ソースバッファにpsearchのような色付けをする")

(defvar *olx-attribute-like-psearch* '(:foreground 6 :background 15)
  "outlinex: ソースバッファへの色付け時の属性")

;;; ──────────────────────────────────── ;;;
;;;  ■ 変数設定 - あまりさわらなくて良いもの
;;; ──────────────────────────────────── ;;;

(defvar-local olx-buffer-name nil)

(defvar-local olx-last-search-pattern ""
	      "outlinex: 最後の検索パターン")

(defvar-local olx-last-search-pattern-pair nil
	      "outlinex: エスケープシーケンスを理解する場合の最後の検索パターン")

(defvar-local olx-last-search-regexp-p t
	      "outlinex: 最後の検索が正規表現かどうか")

(defvar-local olx-understand-escape-sequences nil
	      "outlinex: エスケープシーケンスを理解する")

(defvar-local olx-move-and-popup nil
	      "outlinex: 上下移動時にポップアップ")

(defvar *olx-buffer-prefix* " *olx*-"
  "outlinex: アウトラインバッファ名接頭語")

(defvar *olx-src-conf* nil
  "outlinex: 実行時のウィンドウの数＆バッファ")

(defvar *olx-mark-char-list*
  '((#\M #\P #\+)   (#\D #\P #\-)
    (#\+ #\: #\P)   (#\- #\: #\P)   (#\P #\: #\SPC)
    (#\P #\c #\:)   (#\+ #\c #\M)   (#\- #\c #\D)
    (#\: #\c #\SPC) (#\M #\c #\SPC) (#\D #\c #\SPC)
    )
  "outlinex: マーク文字の組合せ
  - ex. (#\M #\P #\+)
    現在行が M の場合に P が指定されると + に変更する。
  - #\SPC は変更しない場合。")

(defvar *outlinex-mode-map* nil
  "outlinex: アウトラインバッファ用キーマップ")

(defvar *olx-pre-hook* nil
  "outlinex: アウトライン生成前処理")

(defvar *olx-hook* nil
  "outlinex: アウトライン生成後処理")


;;; ──────────────────────────────────── ;;;
;;;  ■ アウトライン作成
;;; ──────────────────────────────────── ;;;

(defun olx (pattern)
  "outlinex: 正規表現を指定してアウトラインを作成"
  (interactive "solx(regexp): " :default0 olx-pattern :history0 'ed::search)
  (olx-exec pattern t olx-coloring))

(defun olx-selection ()
  "outlinex: セレクションの文字列でアウトラインを作成
  - セレクションがない場合は問い合わせます。
  - psearch を使うと，ポイントの文字列を取得します。
  - 正規表現は使用しません。"
  (interactive)
  (let ((pattern (cond ((eq (get-selection-type) 2)
			(buffer-substring (selection-mark)
					  (selection-point)))
		       ((and *olx-use-psearch-get-string*
			     (fboundp 'ed::psearch-get-string))
			(ed::psearch-get-string))
		       (t (read-string "olx(non-regexp): " :history 'ed::search)))))
    (unless (string= pattern "")
      (olx-exec pattern nil olx-coloring))))

(defun olx-flex ()
  "outlinex: モード毎に登録された正規表現でアウトラインを作成"
  (interactive)
  (olx-exec olx-pattern t olx-coloring))

(defun olx-reload (&optional active-olx-buffer)
  "outlinex: 前回の検索パターンで再度アウトラインを作成
  - 既にアウトラインが存在している＆アウトラインバッファがアクティブでない
    (と想像される)場合は，アウトラインを更新する。(手抜き)"
  (interactive)
  (unless olx-buffer-name
    (plain-error))
  (let* ((olx-buf (find-buffer olx-buffer-name))
	 (olx-buf-p (eq buffer-mode 'outlinex-mode))
	 (olx-p (and olx-buf
		     (not olx-buf-p)
		     (> (count-windows) 1)))
	 res)
    (when olx-buf-p
      (plain-error))
    (setq res (olx-exec olx-last-search-pattern olx-last-search-regexp-p olx-coloring))
    (when (and res olx-p)
      (recenter)
      (unless active-olx-buffer
	(olx-mark-point)
	(other-window -1)))))

(defun olx-rerun ()
  "outlinex: 前回の検索パターンで再度アウトラインを作成
  - リロード実行後，アウトラインバッファをアクティブにしておく。"
  (interactive)
  (olx-reload t))

(defun olx-exec (pattern regexp &optional coloring)
  "outlinex: アウトラインを作成"
  (long-operation
    (run-hooks '*olx-pre-hook*)
    (when *olx-coloring-like-psearch*
      (delete-text-attributes 'olx))
    (let ((num-of-windows (count-windows))
	  (start-line (current-line-number))
	  (src-keyword-hash-table keyword-hash-table)
	  (src-syntax-table (syntax-table))
	  (src-regexp-keyword-list regexp-keyword-list)
	  (lines 0)
	  (match-p nil)
	  (olx-line nil)
	  (case-fold olx-case-fold-search)
	  (word-search olx-word-search)
	  (understand-escape olx-understand-escape-sequences)
	  (src-buffer (selected-buffer))
	  olx-buffer
	  )
      (setf olx-buffer-name (concat *olx-buffer-prefix* (buffer-name src-buffer)))
      ;; 実行時の状態を記憶 (count-window と buffer)
      (unless (find-buffer olx-buffer-name)
	(setf *olx-src-conf* nil)
	(push num-of-windows *olx-src-conf*)
	(when (> num-of-windows 1)
	  (save-excursion
	    (other-window 1)
	    (setf *olx-src-conf*
		  (reverse (push src-buffer *olx-src-conf*)))
	    (other-window -1))))
      ;; 検索パターンを記憶
      ;; ダイアログ以外のコマンドでも使用する変数はここで記憶
      (add-history pattern '*minibuffer-search-string-history*)
      (setf olx-last-search-regexp-p regexp)
      (setf olx-last-search-pattern pattern)
      ;; olx バッファを作成
      (save-excursion
	(setf olx-buffer (switch-to-buffer olx-buffer-name))
	(setf buffer-read-only nil)
	(erase-buffer olx-buffer))
      ;; 検索実行
      (save-excursion
	(goto-char (point-min))
	(with-output-to-buffer (olx-buffer)
	  (while (scan-buffer (if regexp (compile-regexp pattern) pattern)
			      :regexp regexp
			      :no-dup nil
			      :case-fold   case-fold
			      :left-bound  word-search
			      :right-bound word-search
			      )
	    (setf match-p t)
	    (let ((match-line (current-line-number)))
	      (format t "~6,' D:~A~%"
		      match-line (buffer-substring (progn (goto-eol)(point))
						   (progn (goto-bol)(point))))
	      (setf lines (1+ lines))
	      (message "scanning ... ~D" (current-line-number))
	      (unless olx-line
		(setf olx-line (cond ((= match-line start-line) lines)
				     ((> match-line start-line) (1- lines))))))
	    (when *olx-coloring-like-psearch*
	      (apply #'set-text-attribute
		     (match-beginning 0)
		     (match-end 0)
		     'olx *olx-attribute-like-psearch*))
	    (or (next-line)
		(return)))))
      ;; 何も抽出できなかった場合
      (unless match-p
	;(delete-buffer olx-buffer)
	(message (concat "\"" pattern "\" は見つからない"))
	(return-from olx-exec nil))
      ;; ウィンドウ分割
      (if olx-vert-p
	  (pop-to-buffer olx-buffer olx-num-of-rows t)
	(pop-to-buffer olx-buffer t))
      (outlinex-mode pattern regexp coloring
		     src-keyword-hash-table
		     src-regexp-keyword-list
		     src-syntax-table
		     case-fold
		     word-search
		     understand-escape
		     )
      ;; それらしい位置に移動
      (goto-line (or olx-line (point-max)))
      (refresh-screen)
      (recenter)
      (message "~D lines completed." lines)
      (run-hooks '*olx-hook*)))
  t)


;;; ──────────────────────────────────── ;;;
;;;  ■ 色付け削除
;;; ──────────────────────────────────── ;;;

(defun olx-delete-attributes ()
  "outlinex: 色を消す"
  (interactive)
  (delete-text-attributes 'olx))


;;; ──────────────────────────────────── ;;;
;;;  ■ outlinex-mode
;;; ──────────────────────────────────── ;;;

(unless *outlinex-mode-map*
  (setf *outlinex-mode-map* (make-sparse-keymap))
  (define-key *outlinex-mode-map* #\TAB 'olx-view)
  (define-key *outlinex-mode-map* #\SPC 'olx-jump-and-mark)
  (define-key *outlinex-mode-map* #\RET 'olx-jump-and-quit)
  (define-key *outlinex-mode-map* #\M-Up 'olx-scroll-down-both-window)
  (define-key *outlinex-mode-map* #\M-Down 'olx-scroll-up-both-window)
  ;(define-key *outlinex-mode-map* #\LBtnUp 'olx-left-press)
  (define-key *outlinex-mode-map* #\d 'olx-mark-delete)
  (define-key *outlinex-mode-map* #\m 'olx-mark)
  (define-key *outlinex-mode-map* #\u 'olx-unmark)
  (define-key *outlinex-mode-map* #\U 'olx-unmark-all)
  (define-key *outlinex-mode-map* #\x 'olx-mark-execute)
  (define-key *outlinex-mode-map* #\e 'olx-erase-line-number)
  (define-key *outlinex-mode-map* #\p 'olx-popup-line)
  (define-key *outlinex-mode-map* #\t 'olx-toggle-move-and-popup)
  (define-key *outlinex-mode-map* #\Up 'olx-previous-line)
  (define-key *outlinex-mode-map* #\Down 'olx-next-line)
  (define-key *outlinex-mode-map* #\q 'olx-quit))

(defun outlinex-mode (pattern
		      regexp
		      coloring
		      src-keyword-hash-table
		      src-regexp-keyword-list
		      src-syntax-table
		      case-fold
		      word-search
		      understand-escape)
  "outlinex: アウトライン表示用モード"
  (kill-all-local-variables)
  (setf buffer-mode 'outlinex-mode)
  (setf mode-name "OutlineX")
  (use-keymap *outlinex-mode-map*)
  (setf buffer-read-only t)
  (setf ed::*paren-status* nil)
  ;; ソースバッファのモードで着色
  (when coloring
    (when src-keyword-hash-table
      (make-local-variable 'keyword-hash-table)
      (setf keyword-hash-table src-keyword-hash-table))
    (when src-syntax-table
      (use-syntax-table src-syntax-table)))
  (make-local-variable 'regexp-keyword-list)
  (let ((olx-regexp-keyword-list
	 (compile-regexp-keyword-list
	  `(("^ *[0-9]+:" t ,*olx-color-line-number*)
	    ("^\\( *[0-9]+D\\)\\(.*\\)" t ((1 . ,*olx-color-delete-line*)
					   (2 . ,*olx-color-delete-line*)))
	    ("^\\( *[0-9]+M\\)\\(.*\\)" t ((1 . ,*olx-color-mark-line*)
					   (2 . ,*olx-color-mark-line*)))
	    ("^\\( *[0-9]+[P+-]\\)\\(.*\\)" t ((1 . ,*olx-color-point-line*)
					       (2 . ,*olx-color-point-line*)))
	    ))))
    (setf regexp-keyword-list (if (and coloring src-regexp-keyword-list)
				  (append src-regexp-keyword-list olx-regexp-keyword-list)
				olx-regexp-keyword-list)))
  (make-local-variable 'mode-line-format)
  (setf mode-line-format
	(format nil "--%*- %M version ~A [%k:%l] %P [~A~A~A~A] pattern:\"~A\""
		*olx-version*
		(cond ((equal case-fold ':smart) "S")
		      ((not case-fold) "C")
		      (t "-"))
		(if word-search "W" "-")
		(if regexp "R" "-")
		(if understand-escape "E" "-")
		pattern))
  ;; バッファの状態を調整
  (let ((buf (selected-buffer)))
    (set-local-window-flags buf *window-flag-line-number* nil)
    (set-local-window-flags buf *window-flag-cursor-line* t)
    (set-buffer-fold-width nil buf)
    (set-buffer-modified-p nil buf)
    (set-buffer-colors *olx-color-buffer* buf)))

(defun olx-view ()
  "outlinex: ノードを表示"
  (interactive)
  (olx-jump t))

(defun olx-jump (&optional view mark)
  "outlinex: ノードに移動"
  (interactive)
  (unless (eq buffer-mode 'outlinex-mode)
    (return-from olx-jump nil))
  (when mark
    (olx-mark-point))
  (let* ((num (if (eobp)
		  -1
		(olx-line-number)))
	 (src-buffer-name (substitute-string
			   (buffer-name (selected-buffer))
			   (regexp-quote *olx-buffer-prefix*)
			   ""))
	 (src-buffer (find-buffer src-buffer-name)))
    (unless src-buffer
      (msgbox "~A がないよん" src-buffer-name)
      (return-from olx-jump nil))
    (when (and num (other-window -1))
      (set-buffer src-buffer)
      (if (= num -1)
	  (progn
	    (goto-char (point-max))
	    (goto-bol))
	(goto-line num))
      (set-mark)
      (recenter *olx-recenter-arg*)
      (when view
	(other-window)))))

(defun olx-jump-and-mark ()
  "outlinex: ノードに移動しマーク"
  (interactive)
  (olx-jump nil t))

(defun olx-quit ()
  "outlinex: 終了"
  (interactive)
  (when (eq buffer-mode 'outlinex-mode)
    (close-selected-buffer)
    (let ((c (first  *olx-src-conf*))
	  (b (second *olx-src-conf*)))
      (if (and (> c 1)
	       (= c (count-windows)))
	  (progn
	    (set-buffer b)
	    (other-window -1))
	(if (> (count-windows) 1)
	    (delete-window))))))

(defun olx-jump-and-quit ()
  "outlinex: ノードに移動し終了"
  (interactive)
  (olx-view)
  (olx-quit))

(defun olx-left-press ()
  "outlinex: ダブルクリックで開く"
  (interactive)
  (let ((click (mod *last-mouse-click-count* 6)))
    (if (= click 2)
	(olx-jump-and-quit)
      (mouse-left-press))))

(defun olx-scroll-up-both-window ()
  "outlinex: 上向同時スクロール"
  (interactive)
  (next-line)
  (olx-view))

(defun olx-scroll-down-both-window ()
  "outlinex: 下向同時スクロール"
  (interactive)
  (previous-line)
  (olx-view))

(defun olx-erase-line-number ()
  "outlinex: 行番号を削除"
  (interactive)
  (when (and (eq buffer-mode 'outlinex-mode)
	     (yes-or-no-p "行番号を削除しますの？"))
    (save-excursion
      (setf buffer-read-only nil)
      (kill-rectangle (progn
			(goto-char (point-min))
			(point))
		      (progn
			(goto-char (point-max))
			(previous-line)
			(scan-buffer ":" :tail t)
			(point)))
      (setf buffer-read-only t))))

(defun olx-toggle-move-and-popup ()
  "outlinex: 上下移動時にポップアップをトグル"
  (interactive)
  (unless olx-move-and-popup
    (olx-popup-line))
  (setf olx-move-and-popup (not olx-move-and-popup)))

(defun olx-popup-line ()
  "outlinex: 現在行の文字列をポップアップ表示"
  (interactive)
  (save-excursion
    (let ((p (point))
	  (s (buffer-substring
	      (progn (goto-bol) (forward-char 7) (point))
	      (progn (goto-eol) (point)))))
      (popup-string (string-left-trim " \t" s) p))))

(defun olx-next-line (&optional previous)
  "outlinex: 次行に移動＆行の文字列をポップアップ表示"
  (interactive)
  (if previous
      (previous-line)
    (next-line))
  (when olx-move-and-popup
    (olx-popup-line)))

(defun olx-previous-line ()
  "outlinex: 前行に移動＆行の文字列をポップアップ表示"
  (interactive)
  (olx-next-line t))


;;; ──────────────────────────────────── ;;;
;;;  ■ まーく
;;; ──────────────────────────────────── ;;;

(defun olx-mark (&optional (c #\M) no-move)
  "outlinex: マークをつける
  - 1行で表現しているため切替が面倒な。
  - M: マーク
  - D: 削除マーク
  - P: olx-jumpした行
  - +: M + P
  - -: D + P"
  (interactive)
  (when (or (not (eq buffer-mode 'outlinex-mode))
	    (get-buffer-file-name))
    (plain-error))
  (goto-column 1)
  (when (eobp)
    ;(plain-error "ありません")
    (return-from olx-mark nil))
  (scan-buffer "[:DMP+-]" :regexp t)
  (let ((buffer-read-only nil)
	(a (char-after (point)))
	cc)
    (declare (special buffer-read-only))
    (setf cc (dolist (x *olx-mark-char-list*)
	       (when (and (char= (first x) a)
			  (char= (second x) c))
		 (return (third x)))))
    (cond (;マークの変更をしない
	   (and cc (char= cc #\SPC))
	   (insert cc)
	   (backward-char))
	  (;変換後のマークに変更
	   cc (insert cc))
	  (;指定されたマークに変更
	   t  (insert c)))
    (delete-char 1)
    (set-buffer-modified-p nil))
  (unless no-move
    (forward-line 1)))

(defun olx-mark-point ()
  "outlinex: ポイント行(ジャンプする行)にマークをつける"
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (not (eobp))
      (olx-mark #\c)))
  (olx-mark #\P t))

(defun olx-mark-delete ()
  "outlinex: 削除する行にマークをつける"
  (interactive)
  (olx-mark #\D))

(defun olx-unmark ()
  "outlinex: マークを外す"
  (interactive)
  (olx-mark #\:))

(defun olx-unmark-all ()
  "outlinex: ぜんぶのマークを外す"
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (not (eobp))
      (olx-unmark))))

(defun olx-mark-execute ()
  "outlinex: マークを実行
  - 削除マークの付いたアウトライン行を削除する。
    ※元バッファは削除されません。"
  (interactive)
  (goto-char (point-min))
  (let ((buffer-read-only nil))
    (declare (special buffer-read-only))
    (while (scan-buffer "^ *[0-9]+D.*" :regexp t)
      (delete-region (point) (progn (next-line) (point))))
    (set-buffer-modified-p nil))
  (goto-char (point-min)))


;;; ──────────────────────────────────── ;;;
;;;  ■ 補助関数
;;; ──────────────────────────────────── ;;;

(defun olx-line-number ()
  "outlinex: カーソル位置のノードの行番号を取得"
  (save-excursion
    (goto-bol)
    (if (looking-at "^ *\\([0-9]+\\)[:DMP+-]")
	(parse-integer
	 (string-left-trim
	  " "
	  (buffer-substring (match-beginning 1) (match-end 1))))
      0)))

;;; ──────────────────────────────────── ;;;
;;;  ■ ダイアログ
;;; ──────────────────────────────────── ;;;

(defvar *olx-dialog-template*
  '(dialog 0 0 242 114
    (:caption "OutlineX")
    (:font 9 "MS UI Gothic")
    (:control
     (:static nil "検索(&S):" #x50020000 7 10 28 8)
     (:combobox search nil #x50210842 39 8 140 96)
     (:button case-fold "大文字小文字を区別する(&C)" #x50010006 39 27 96 10)
     (:button word "単語単位で検索する(&W)" #x50010003 39 40 83 10)
     (:button regexp "正規表現(&E)" #x50010003 39 53 52 10)
     (:button escseq "エスケープシーケンスを理解しろ(&Y)" #x50010003 39 66 107 10)
     (:button vert-p "縦に分割(&V)" #x50010003 39 79 107 10)
     (:static nil "列数(&L):" #x50020000 7 96 40 8)
     (:edit rows nil #x50810086 39 92 20 14)
     (:button IDOK "実行(&E)" #x50010001 185 7 50 14)
     (:button IDCANCEL "キャンセル" #x50010000 185 24 50 14)
     )))

(defun olx-dialog ()
  "outlinex: ダイアログから条件を指定してアウトラインを作成
  - 「ダイアログで設定された値は，すべてバッファローカルな値として保持される。"
  (interactive)
  (multiple-value-bind (result data)
      (let ((string (or (selection-start-end (start end)
			  (buffer-substring start end))
			(unless (string= olx-last-search-pattern "")
			  olx-last-search-pattern)
			olx-pattern)))
	(dialog-box *olx-dialog-template*
		    (list (cons 'search *minibuffer-search-string-history*)
			  (cons 'case-fold (ed::cfs2dialog olx-case-fold-search))
			  (cons 'word olx-word-search)
			  (cons 'regexp olx-last-search-regexp-p)
			  (cons 'vert-p olx-vert-p)
			  (cons 'rows (format nil "~A" olx-num-of-rows))
			  (cons 'search (if (eq (cdr olx-last-search-pattern-pair)
						string)
					    (car olx-last-search-pattern-pair)
					  string))
			  )
		    '((word :disable (regexp))
		      (search :non-null "検索文字列を入力して" :enable (IDOK))
		      (vert-p :enable (rows))
		      )))
    (when result
      (let ((string (cdr (assoc 'search data))))
	(when string
	  ;; ダイアログでしか使用しない変数はここで記憶
	  (setf olx-case-fold-search (ed::dialog2cfs (cdr (assoc 'case-fold data))))
	  (setf olx-word-search (cdr (assoc 'word data)))
	  (setf olx-last-search-regexp-p (cdr (assoc 'regexp data)))
	  (setf olx-understand-escape-sequences (cdr (assoc 'escseq data)))
	  (if olx-understand-escape-sequences
	      (setf olx-last-search-pattern-pair
		    (cons string
			  (setf string (decode-escape-sequence
					string olx-last-search-regexp-p))))
	    (setq olx-last-search-pattern-pair nil))
	  (setf olx-vert-p (cdr (assoc 'vert-p data)))
	  (setf olx-num-of-rows (olx-dialog2nor (cdr (assoc 'rows data))))
	  (olx-exec string olx-last-search-regexp-p olx-coloring)
	  )))))

(defun olx-dialog2nor (x)
  "outlinex: 表示列数指定時のエラーチェック
  - エラーとなりそうな値が指定された場合は，現在の値のままとする。
  - 0 を指定すると，半分に分割される。"
  (let ((rows (ignore-errors (parse-integer x))))
    (if (and rows
	     (or (zerop rows)
		 (and (> rows 14)
		      (< rows (- (screen-width) 15)))))
	rows
      olx-num-of-rows)))


;;; outlinex.l ends here.
