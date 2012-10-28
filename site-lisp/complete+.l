;;; -*- mode: lisp -*-
;;; name:     complete+
;;; version:  2007.12.21
;;; author:   snj14
;;; category: Utilities
;;; src:      http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fcomplete%2B&openfile=
;;; changes:  補完候補なしのcompleting-read中にエラーが出ていたのを修正
;;; files:    site-lisp/complete+.l
;;;           site-lisp/complete+.lc
;;;           site-lisp/ni-autoload/silog/complete+.l

;; Copyright (C) 1996-2005 Tetsuya Kamei
;; Copyright (C) 2002-2006 Mitsuaki Fukae
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
;;   ミニバッファ等で
;;    - 先頭一致/Migemo/部分一致/スキップマッチングで絞り込み、
;;      かつ全ての項目に先頭一致する文字列で補完
;;    - 存在するファイルでないものをファイルのように補完
;;      実際にファイルを開くにはvirtual-fileやその他もろもろ(virtual-file-*.l)が必要です
;;    - 大文字・小文字の区別をしたりしなかったり、大文字の時だけ区別したりする
;;    - ディレクトリのスキップマッチング( c:/d/m/hoge => c:/data/music/hoge )
;;    - 指定文字で区切りAND検索         ( c:/data/zip;xyz => c:/data/xyzzy.zip )
;;    - インクリメンタルに補完候補を表示(補完自体は行わない)
;;    - ↑を有効にしてる場合、補完できるところまでハイライトで表示
;;    - *Completion*バッファの候補のマッチしてる部分を強調表示
;;    - cygwin-mountと連携してcygwinのパスを補完
;;    - ファイル補完時に空白ならドライブも候補に入れる
;;    - C-i(TAB)やSpaceの直後の新規ファイル作成はRET2回で行なう
;;   を可能にするものです
;;   

;; 動作環境:
;;
;;   xyzzy 0.2.2.235 以降
;;
;;   Option
;;     migemo                JunkScripts   (http://www7a.biglobe.ne.jp/~hat/)
;;     cygwin-mount          xyzzyのじかん (http://miyamuko.s56.xrea.com/)
;;     virtual-file          silog         (http://white.s151.xrea.com/wiki/)

;; 設定:
;;
;; NetInstallerで導入した方は 1 は不要です
;;
;;   1 $XYZZY/site-lisp/ 以下にコピーし、バイトコンパイルしてください。
;;   2 .xyzzy や siteinit.l に以下を参考に記述し、
;;     siteinit.lに記述した方は再ダンプしてください。
;;   (require "complete+")    ; ni-autoloadしている人は不要
;;   (use-package "complete+"); ni-autoloadしている人は不要
;;   (dolist (keymap (list minibuffer-local-completion-map
;;                         minibuffer-local-must-match-map
;;                         minibuffer-local-command-line-map))
;;     (define-key keymap '#\C-n  'complete+-select-next-item)       ; 次の候補
;;     (define-key keymap '#\C-p  'complete+-select-prev-item)       ; 前の候補
;;     (define-key keymap '#\C-<  'complete+-substring-match-rotate) ; 部分一致
;;     (define-key keymap '#\C->  'complete+-skip-match-rotate)      ; スキップマッチ
;;     (define-key keymap '#\C-\, 'complete+-case-fold-ratate)       ; 大小文字区別
;;     (define-key keymap '#\C-.  'complete+-toggle-incremental))    ; インクリメンタル
;;   (setf *complete+-and-search* ";") ;AND検索
;;   (setf *complete+-show-drive* t)   ;ドライブを表示
;;   (setf *complete+-current-item-attribute* '(:foreground 1)) ; *Completion*バッファ
;;   (setf *complete+-highlight-color*        '(:foreground 2)) ; ハイライト
;;   (setf *virtual-file-add-slash-automatically* t)            ; virtual-fileな拡張子に/を付ける
;;   (setf *complete+-create-new-file-check* t)                 ; TAB,Spaceの直後の新規作成はRET2回
;;   (complete+-toggle-incremental t)                           ; 最初からインクリメンタルに補完候補を表示

;; 関数の説明:
;;
;;   minibuffer-local-completion-map や minibuffer-local-must-match-map
;;   のキーバイドに設定することを想定しています。
;;
;;   complete+-select-next-item
;;       *Completion*バッファで候補を表示した時に次の候補を選択
;;
;;   complete+-select-prev-item
;;       *Completion*バッファで候補を表示した時に前の候補を選択
;;
;;   complete+-substring-match-rotate
;;       部分一致を:always > :smart > :neverの順に変更
;;       各値の意味は *complete+-substring-match* の定義部分参照
;;
;;   complete+-skip-match-rotate
;;       スキップマッチを:always > :smart > :neverの順に変更
;;       各値の意味は *complete+-skip-match* の定義部分参照
;;
;;   complete+-case-fold-ratate
;;       大文字・小文字を区別するかどうかをnil > t > :smartの順に変更
;;
;;   complete+-toggle-incremental
;;       インクリメンタルな補完候補表示をトグル

;; 注意:
;;
;;  - complete.lのed::popup-completion-listと
;;    *do-completion(ビルトイン関数)を置き換えています。
;;    互換性は極力保っているつもりですが、
;;    動作が正確に再現できていない可能性があります。
;;  - 上書きではなく置き換えているだけなので他の拡張との衝突は無いはずですが、
;;    xyzzyがバージョンアップした時にこちらも同じように対応させないと、
;;    新機能(あれば)が使えません。
;;  - ビルトイン関数をLispで置き換えているので、速度は落ちます。
;;  - ディレクトリのスキップマッチングを行う際に候補が大量にあると重い。
;;  - アーカイブも１回目の表示時には内部で展開するので重い。
;;    以後はタイムスタンプを見つつキャッシュを使います。

;; FAQ:
;;
;;  - find-fileで拡張子***が候補に出てこない
;;    - ignored-extensionsに入ってる拡張子は出ません(complete+は関係ありません)
;;    - 例えばlzhを候補に入れたいなら (delete ".lzh" ignored-extensions :test 'equal)
;;  - [***]が含まれるファイル名がちゃんと補完できない
;;    - ツール > 共通設定 > さまざま > [...]はワイルドカード のチェックをはずす
;;  - なんか挙動が変
;;    - 「何をしたくて」「何をしたら」「どうなったのか」を具体的に報告してください

;; ToDo:
;;
;;  - cygwin-mountのパスでディレクトリスキップマッチを出来るように
;;  - 複数のアーカイブを跨いでディレクトリスキップマッチが出来るように
;;    (アーカイブのパスまでちゃんと入力したら中身のディレクトリスキップマッチは出来る)

;; 履歴:
;; 
;; 2007.12.21
;; - 補完候補なしのcompleting-read中にエラーが出ていたのを修正
;; 
;; 2007.07.09
;; - virtual-fileのリスト取得中にバッファを変更したらエラーが出たのを修正
;; 
;; 2007.05.30
;; - インクリメンタルに補完候補を表示している時に~/を入力したら即移動するようにした
;; 
;; 2007.04.24
;; - *virtual-file-add-slash-automatically* 追加
;; 
;; 2007.04.15
;; - 阿呆なバグ修正
;; 
;; 2007.03.23
;; - virtual-fileで:no-completionsな時にエラーになっていたのを修正
;; - virtual-fileのlistの仕様を変更
;; 
;; 2007.03.22
;; - find-file-in-archiveの関数上書きが残っていたのを削除
;; - completion-do-virtual側で前方一致候補の絞込みを行うようにした
;; 
;; 2007.03.07
;; - パスの途中に[a-zA-Z]:/があっても大丈夫にした
;; - 先頭以外に//があっても大丈夫にした
;; - 圧縮ファイルの補完の処理を外に出した
;; 
;; 2007.03.02
;; パスの途中に~/があっても大丈夫にした
;; 
;; 2007.02.19
;; - message, plain-error quitが２つ出る*do-completionのバグにとりあえず対応
;; 
;; 2007.02.15
;; - キーボードマクロ実行時にちらつかないようにした
;; - いつのまにかcygwinのパスが補完できなかくなってたのを修正
;; 
;; 2007.02.11
;; - バグ修正
;; 
;; 2007.01.29
;; - ショートカット経由で設定を変更したときにスクロールしないようにした
;; 
;; 2006.11.21
;; - UNC形式も補完できるようにした
;;
;; 2006.11.15
;; - 元が大文字のところは可能な限り大文字化するようにした
;; - マッチする候補がなくなったら自動で補完しないようにした
;;   (ただし、C-h,BackSpace,C-b,Left,ESC ESCを押したら自動で補完するように)
;;
;; 2006.10.21
;; - C-i(TAB)やSpaceの直後の新規ファイル作成はRET2回で行なうオプション追加
;; - *complete+-case-fold*の状態をモードラインに表示するようにした
;; - *complete+-case-fold*をインタラクティブに変更する関数を追加
;; - モードラインに表示する変数の状態の書式を変更可能にした
;; - ハイライト部分で小文字化出来ていなかったのを今度こそ修正
;;
;; 2006.10.20a
;; - ハイライト部分で小文字化出来ていなかったのを修正
;;
;; 2006.10.20
;; - キーマップの設定をケアレスミスしていたのを修正
;; - *case-fold-search*を*complete+-case-fold*に変更
;; - *complete+-case-fold*が:smartの時に小文字化を少しスマートにした
;;
;; 2006.10.15
;; - 関数を１つも上書きしないようにした(=他の拡張lisp等に影響を与えなくなった)
;;   - 影響を与えたい場合は
;;     (setf (symbol-function '*do-completion) #'complete+::*do-completion+)
;;   - 元の*do-completionに戻したい場合は
;;     (setf (symbol-function '*do-completion) #'complete+::*do-completion-)
;; - インクリメンタルな補完に*post-command-hook*を使わずキー定義で行うようにした
;; - cygwin-mountのパスで..をちゃんと変換するようにした
;; - 7zやcabの展開がうまく出来なかったのを修正
;;
;; 2006.10.08
;; - *migemo-on*が非nilなら先頭一致した候補とMigemoで一致した候補を一緒に出すようにした
;; - cygwin-mountのパスで..を入力したら1階層上の.を二つ含むファイル名を補完していたのを修正
;;
;; 2006.10.05
;; - lisp/foreign.lが読み込まれてないとエラーになったのを修正したつもり
;; - 先頭一致した候補よりmigemoで補完した候補を優先させてしまってたのを修正
;; - *migemo-on*がnilの時にmigemoを無効に出来てなかったのを修正
;; - lzhの中身が補完出来てなかったのを修正
;; - 7z,tgz,tazを忘れてたのを修正
;;
;; 2006.09.26
;; - 正規表現のメタキャラクタが含まれているとエラーになる場合があったのを修正
;; - *case-fold-search*が:smartの時に小文字化できていない場合があったのを修正
;; - *Completion*バッファの強調表示を*complete+-matched-string-attribute*
;;   で指定できるようにした(nilを指定すると無効にできるようになった)
;; - 分かりやすいように「動的なXXX」を「インクリメンタルなXXX」に変更。
;;   complete+-minibuffer-complete-per-input-toggle
;;   -> complete+-toggle-incremental
;;
;; 2006.09.16
;; - *Completion*バッファの候補のマッチしてる部分を強調表示機能追加
;; - 部分一致が:alwaysの時にディレクトリをミニバッファに表示した状態で
;;   [TAB]を押すと補完されなかったのを修正
;; - dabbrev-popupで決定したら元の文字+補完後の文字になっていたのを修正
;; - *complete+-cygwin-mount*廃止
;;   (cygwin-mount.lが入っていれば勝手にやる)
;; - *complete+-migemo-match*廃止
;;   (migemo.lが入っていて、候補に日本語が混じっていて、
;;    入力文字に日本語が混じってなければ勝手にやる)
;; - *complete+-show-message*のデフォルトの値をtに変更
;; - *complete+-highlight-color*と*complete+-current-item-attribute*の
;;   デフォルトの値を'(:foreground 3)に変更
;;
;; 2006.09.08
;; - ~/で始まるパスに対応出来てなかったのを修正
;; - :listの先頭一致ができてなかったのを修正
;; - :list-ignore-caseと:listが同じになってたのを修正
;; - 型が:list,:list-ignore-case以外の時にlistを渡しても:listとして補完していたのを修正
;; - 子ディレクトリが１つしか含まれないディレクトリでハイライトを使い、
;;    [TAB]を押すと子の末尾(/)まで補完されてしまったのを修正。
;;
;; 2006.09.07
;; - コードを整理した
;; - cygwin-mountと仲良くできるようにした
;; - migemoなしでも動くようにした
;; - ファイル補完時に空白ならドライブを出すオプション追加
;; - symbolを補完する時はmigemoを使わないようにした
;; - *complete-overwrite2*廃止(ハイライト機能で代用できる)
;; - アーカイブを含むディレクトリスキップマッチで固まるのを修正
;;
;; 2006.09.01
;; - ファイルを補完する時に:not-uniqueなど、
;;   文字列以外を返した時にprefixがnilになっていたのを修正
;;
;; 2006.08.28
;; - シンボル名にパッケージ名が含まれていたらパッケージ名が消えたのを修正
;;
;; 2006.08.27a
;; - nanaさんの修正を取り込み m(__)m
;;
;; 2006.08.27
;; - ミニバッファ以外でpopup-listを使って確定した時にバッファの内容が消えたのを修正
;; - :file-onlyなど、コロンから始まるものが考慮されていなかったのを修正
;;
;; 2006.08.25
;; - nanaさんの修正を取り込み m(__)m
;;
;; 2006.08.24a
;; - nanaさんの修正を取り込み m(__)m
;;
;; 2006.08.24
;; - popup-listで候補を選択した時のエラーを修正
;; - *complete+-and-search*が指定されていない時のエラーを修正
;;
;; 2006.08.11
;; - *complete+-archive*廃止
;; - アーカイブのキャッシュが中途半端だったのを修正
;; - アーカイブにもディレクトリのスキップマッチやアンド検索を
;;
;; 2006.08.08
;; - ミニバッファに居る時だけ補完できるところまでハイライト表示機能追加
;; - *Completion*バッファに表示された候補を上下キー等で選択できる機能追加
;;
;; 2006.08.07
;; - ファイル補完でディレクトリのスキップマッチング機能追加
;; - アーカイブのパスに正規表現のメタキャラクタが含まれていたら補完出来なかったのを修正
;;
;; 2006.08.02
;; - ファイルのprefixが間違っていたのを修正
;; - 区切り文字が\\の時に*do-completionの１つめの返り値が間違っていたのを修正
;;
;; 2006.07.31b
;; - *Completion*バッファでRETした時に前方一致していない候補も補完できるようにした
;;
;; 2006.07.31a
;; - typo修正
;;
;; 2006.07.31
;; - 不用意なrefresh-screenを削除
;; - 状態表示をミニバッファにいなくてもモードラインで表示するようにした
;;   (ミニバッファにいる時はミニバッファを抜けた時に、いない時はタイマーで戻します)
;; - 前方一致、部分一致、migemo、スキップマッチング全てに1つもマッチしないときに
;;   全ての候補が表示されていたバグを修正
;;
;; 2006.07.29
;; - コードを整理したために起きたバグを修正
;;
;; 2006.07.28
;; - パッケージ名のついた変数の候補をうまく出せていなかったバグを修正
;; - 複数選択廃止
;; - 状態表示をミニバッファにいる時のみモードラインで表示するようにした
;;
;; 2006.07.07
;; - find-file中に文字を全部消してtabを押すと出たエラーを修正
;;
;; 2006.04.28
;; - 日本語でMigemoを呼ぶと正規表現のコンパイルでエラーが出ることがあるので
;; - 日本語の時はMigemoを呼ばないようにした
;;
;; 2006.04.05
;; - listに文字列のリスト以外が渡された時にエラーが出ていたバグを修正
;; - 正規表現で特別な意味を持つ文字が入力された時にエラーが出ていたバグを修正
;; - :must-match かつ :no-match の場合は入力文字を一文字削除するようにした
;; - :must-match かつ 候補が残り1つ かつ 入力したのが文字 の場合に
;;   補完を行うオプション追加
;;
;; 2006.03.22
;; - 部分一致、スキップマッチの値を t/nil から
;;   :always :smart :neverに変更
;; - アーカイブの中身も絞込み/補完ができるようにした
;;
;; 2006.03.13
;; - 初版

;; 謝辞:
;;
;; 作成にあたり
;;   - Mitsuaki Fukaeさん (http://www5e.biglobe.ne.jp/~fukafuka/) の
;;       mmc.l
;;   - Tetsuya Kameiさん (http://www.jsdlab.co.jp/~kamei/) の
;;       complete.l (xyzzy標準ファイル)
;;       minibuf.cc (xyzzyソース)
;; を参考にさせていただきました

;;; Code:

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "foreign")
  (defpackage "complete+"
    (:use "lisp" "editor")
    ;(:nicknames "cp")
    ))

(provide "complete+")

(in-package "complete+")

(export '(*complete+-show-message*
		  *complete+-show-message-time*
		  *complete+-highlight-color*
		  *complete+-current-item-attribute*
		  *complete+-matched-string-attribute*
		  *complete+-and-search*
		  *complete+-substring-match*
		  *complete+-skip-match*
		  *complete+-show-drive*
		  *complete+-case-fold*
		  *complete+-create-new-file-check*
		  complete+-select-next-item
		  complete+-select-prev-item
		  complete+-skip-match-rotate
		  complete+-substring-match-rotate
		  complete+-toggle-incremental
		  complete+-case-fold-ratate
		  *virtual-file-add-slash-automatically*))

;;; -----------------------------------------------------------------
;;; ユーザがカスタマイズできる変数ここから
;;;     .xyzzyかsiteinite.lに
;;;     (setf *complete+-show-message* t)
;;;     のように書いてください


;;; -----------------------------------------------------------------
;;; モードラインに表示する現在の設定の書式
;;; -----------------------------------------------------------------
;;; nil    表示しない
;;; 文字列 formatの書式で指定してください。
;;;        引数は *complete+-substring-match*
;;;               *complete+-skip-match*
;;;               *complete+-case-fold*
;;;               *icompletion*
;;;        の順に渡されます。
(defvar *complete+-show-message* "[Sub:~A Skip:~A Case:~A Comp:~A]")

;;; -----------------------------------------------------------------
;;; ミニバッファに居ない時に↑の表示を維持する時間
;;; -----------------------------------------------------------------
;;; ミニバッファにいる時はミニバッファから抜けるまで維持します
(defvar *complete+-show-message-time* 2)

;;; -----------------------------------------------------------------
;;; 補完できるところまでハイライト表示
;;; -----------------------------------------------------------------
;;; nil  しない
;;; '(:foreground 8) ;文字色を8に
;;; '(:background 3 :bold t) ;背景色を3、太字
;;; 詳細はリファレンスの set-text-attribute を参照
(defvar *complete+-highlight-color*
  '(:foreground 3))

;;; -----------------------------------------------------------------
;;; AND検索を行う区切り文字
;;; -----------------------------------------------------------------
;;; 1文字の文字列 する(ex. ";")
;;; nil           しない
(defvar *complete+-and-search* nil)

;;; -----------------------------------------------------------------
;;; 部分一致
;;; -----------------------------------------------------------------
;;; :always 常に行う
;;; :never  行わない
;;; :smart  前方一致するものがなかった場合のみ
;;;         (=元の*do-completionでマッチするものが無かった場合)
(defvar *complete+-substring-match* :smart)

;;; -----------------------------------------------------------------
;;; スキップマッチング
;;; -----------------------------------------------------------------
;;; :always 常に行う
;;; :never  行わない
;;; :smart  Migemo、部分一致を行ってもマッチするものがなかった場合のみ
(defvar *complete+-skip-match* :smart)

;;; -----------------------------------------------------------------
;;; *Completion*バッファで選択中の項目を強調表示する
;;; (complete+-select-{next,prev}-itemをしないと効果が出ません)
;;; -----------------------------------------------------------------
;;; nil  しない
;;; '(:foreground 8) ;文字色を8に
;;; '(:background 3 :bold t) ;背景色を3、太字
;;; 詳細はリファレンスの set-text-attribute を参照
(defvar *complete+-current-item-attribute*
  '(:foreground 3))

;;; -----------------------------------------------------------------
;;; *Completion*バッファで候補のマッチしてる部分を強調表示する
;;; -----------------------------------------------------------------
;;; nil  しない
;;; '(:foreground 8) ;文字色を8に
;;; '(:background 3 :bold t) ;背景色を3、太字
;;; 詳細はリファレンスの set-text-attribute を参照
(defvar *complete+-matched-string-attribute*
  '(:foreground 3))

;;; -----------------------------------------------------------------
;;; ファイル補完時に文字列が空白ならドライブ名も候補に入れる
;;; -----------------------------------------------------------------
;;; t   入れる
;;; nil 入れない
(defvar *complete+-show-drive* nil)

;;; -----------------------------------------------------------------
;;; 大文字と小文字の区別するかどうか
;;; -----------------------------------------------------------------
;;; nil      区別する
;;; :smart   大文字が含まれていれば区別し、
;;;          含まれていなければ区別しない。
;;; 上記以外 区別しない
(defvar *complete+-case-fold* :smart)

;;; -----------------------------------------------------------------
;;; C-i(TAB)やSpaceの直後の新規作成はRET2回で開くように
;;; -----------------------------------------------------------------
;;; t    する
;;; nil  しない
;;; find-fileで補完しそこなって新規ファイルを頻繁に作ってしまう人向け。
(defvar *complete+-create-new-file-check* nil)


;;; ユーザがカスタマイズできる変数ここまで
;;; -----------------------------------------------------------------


;; ;;; hook
;; (defvar *complete+-hook* nil)
;; ;;; hookに引っ掛けた関数から調べる用
;; ;;;     文字列
;; (defvar *complete+-string* "")

;;; ディレクトリスキップマッチ中に
;;; complete+-{skip,substring}-match-rotateしても
;;; ed::popup-completion-listでちゃんと決定できるように
(defvar *complete-prefix* "")
(defvar *complete-result* "")
;;; *Completion* バッファでマッチしてる部分を表示するやつ
(defvar *complete-matched-substring-list* nil)
;;; 入力毎に候補を出すか
(defvar *icompletion* nil)
(defvar *icompletion-internal* nil)
;;; *Completion*バッファで現在選択中の候補(番号)
(defvar-local *completion-current-item* nil)
;;; モードラインの状態表示用
(defvar *complete-mode-line-string* "")
(defvar *complete-show-message-internal* nil)
;;; デバッグ用の時間保持変数
(defvar *complete-debug-time* 0)
;;; 補完直後にRET押して新規ファイル作る対策 で使う変数
(defvar *complete+-create-new-file* nil)
;;; 最後に補完したリスト
(defvar *complete+-list* nil)
;;; 次もインクリメンタルに補完するかどうか
(defvar *icompletion-next* t)
;;; 
(defvar *complete+-suppression-scroll* nil)

(unless (fboundp '*do-completion-)
  (setf (symbol-function '*do-completion-)
	(symbol-function 'ed::*do-completion)))

;; string and list must be included prefix
;;
;; prefix :: "c:/bin/"
;; string :: "c:/bin/A"
;; list   :: '("c:/bin/abc" "c:/bin/ade" "c:/bin/afg")
(defstruct (completion
			(:print-function
			 (lambda (o s p)
			   (format s "<completion  string    : ~A
result    : ~A
prefix    : ~A
type      : ~S
candidate : ~S
wordp     : ~A
virtual   : ~A
cand pre  : ~S
cand all  : ~S
cygwin    : ~A>"
					   (completion-string o)
					   (completion-result o)
					   (completion-prefix o)
					   (completion-type o)
					   (completion-candidate o)
					   (completion-wordp o)
					   (completion-virtual o)
					   (completion-candidate-prefix o)
					   (completion-candidate-all o)
					   (completion-cygwin o)
					   ))))
  string     result  virtual  prefix
  candidate  candidate-all    candidate-prefix
  type       wordp   cygwin)

(defun get-completion (string type &optional wordp list)
  (make-completion :string string
				   :type type
				   :wordp wordp
				   :candidate-all (when (completion-type-is-list type)
									(mapcar (correct-type-closure) list))
				   ))

(defun completion-type-is-symbol (x)
  (member (completion-type x)
		  '(:symbol-name
			:function-name
			:command-name
			:variable-name
			:non-trivial-symbol-name)))

(defun completion-type-is-file (x)
  (find (completion-type x)
		'(:exist-file-name
		  :file-name
		  :file-name-list
		  :directory-name)))

(defun completion-type-is-list (x)
  (find (if (completion-p x) (completion-type x) x)
		'(:list
		  :list-ignore-case)))

(defun completion-and (x)
  "and-search separator"
  (and (stringp *complete+-and-search*)
	   (= 1 (length *complete+-and-search*))
	   (position (char *complete+-and-search* 0)
				 (completion-string x)
				 :test 'equal :from-end t)))

(defun completion-show-debug (fmt &rest args)
  #+:complete+
  (apply #'format t
		 (concat " *** "
				 #+:time
				 "[~A] "

				 fmt "~%")
		 #+:time
		 (abs (- *complete-debug-time*
				 (setf *complete-debug-time* (get-internal-real-time))))

		 args))

(defun completion-get-prefix (x)
  (let ((new (copy-completion x)))
	(with-structure
	 (completion- string) x
	 (cond ((completion-type-is-symbol x)
			(string-match "\\(\\_s\\{0,\\}?::?\\)\\(.*\\)"
						  string)
			(setf (completion-prefix new)
				  (match-string 1)))
		   ((completion-type-is-file x)
			(string-match
			 "\\(\\(?:[a-zA-Z]:\\|^\\|~\\|//\\)[^:*\"?|<>\t\n]*/\\)[^:*\"?|<>\t\n]*"
			 string)
			(setf (completion-prefix new)
				  (or (match-string 1) "")))))
	new))

(defun completion-get-prefix-by-candidate (x)
  (with-structure
   (completion- candidate string prefix) x
   (let ((res (car candidate))
		 (func (if *complete+-case-fold* 'equalp 'equal)))
	 (dolist (cand candidate)
	   (while (not (or (equal res "")
					   (funcall func res
								(if (< (length res) (length cand))
									(substring cand 0 (length res))
								  cand))))
		 (setf res (substring res 0 -1)))
	   (and (eq *complete+-case-fold* :smart)
			(not (equal res
						(if (< (length res) (length cand))
							(substring cand 0 (length res))
						  cand)))
			(let ((p (string/= res cand)))
			  (setf res (concat (substring res 0 p) (string-downcase (substring res p)))))))
	 res)))

(winapi::*define-dll-entry winapi::LONG GetLogicalDrives nil "kernel32")
(defun get-drive-list (&optional colon)
  (let ((drive (GetLogicalDrives)) res)
	(dotimes (i 25 (nreverse res))
	  (when (/= (logand drive (ash 1 i)) 0)
		(push (concat (string (code-char (+ (char-code #\A) i)))
					  (if colon ":" "")
					  "/")
			  res)))))

(defun jp-char-p (char)
  (or (kanji-char-p char)
	  (kana-char-p char)))

(defun zero-string-p (string)
  (and (stringp string)
	   (equal string "")))
(defun not-zero-string-p (string)
  (and (stringp string)
	   (not (equal string ""))))
(defun head-is-slash (path)
  (and (stringp path)
	   (string-match "^/" path)))
(defun head-is-slash2 (path)
  (and (stringp path)
	   (string-match "^//" path)))
(defun tail-is-slash (path)
  (and (not-zero-string-p path)
	   (equal (substring path -1) "/")))
(defun tail-is-not-slash (path)
  (and (not-zero-string-p path)
	   (not (equal (substring path -1) "/"))))

#|
(complete+::map-concat "hoge[01]" ".*")
"h.*o.*g.*e.*\\[.*0.*1.*]"
|#
(defun map-concat (string1 string2)
  (remove-prefix (apply #'concat
						(map 'list #'(lambda (x)
									   (concat string2 (regexp-quote (string x))))
							 string1))
				 string2))

#|
(complete+::regexp-compile "hoge" :prefix t)
#<compiled regular expression: ^hoge>
|#
(defun regexp-compile (string &key prefix quote ignore-case)
  (when quote
	(setf string (regexp-quote string)))
  (when prefix
	(setf string (concat "^" string)))
  (compile-regexp string (or ignore-case
							 *complete+-case-fold*)))

#|
(mapcar (complete+::append-prefix-closure "::") '("A" "B" "C"))
("::A" "::B" "::C")
|#
(defun append-prefix (string prefix)
  (concat prefix string))
(defun append-prefix-closure (prefix)
  (if (not-zero-string-p prefix)
	  #'(lambda (string)
		  (append-prefix string prefix))
	'identity))

#|
(mapcar (complete+::remove-prefix-closure "::") '("::A" "::B" "::C"))
("A" "B" "C")
|#
(defun remove-prefix (string prefix &optional (case-fold *complete+-case-fold*))
  (setf string (substitute-string string (concat "^" (when (stringp prefix) (regexp-quote prefix))) ""
				  :case-fold case-fold)))
(defun remove-prefix-closure (prefix &optional (case-fold *complete+-case-fold*))
  (unless (not-zero-string-p prefix)
	(return-from remove-prefix-closure 'identity))
  (let ((pre (concat "^" (regexp-quote prefix))))
	#'(lambda (string)
		(substitute-string string pre "" :case-fold case-fold))))

(defun cygwin-mount-p ()
  (modulep "cygwin-mount"))
(defun migemo-p ()
  (and (modulep "migemo")
	   (eval (intern "*migemo-on*" "editor"))))

(defun correct-type-closure ()
  #'(lambda (c)
	  (when (consp c)
		(setf c (car c)))
	  (cond ((stringp c) c)
			((symbolp c) (symbol-name c))
			(t (format nil "~A" c)))))

;;本家(cygwin-mount.l)に取り込まれるまでここに。
(defun cygwin-mount-winpath-to-cygpath (winpath)
  (setf winpath (map-backslash-to-slash winpath))
  (let ((mount
		 (rassoc winpath
				 (ed::cygwin-mount-table)
				 :test
				 (lambda (cygpath mount)
				   (string-matchp (regexp-quote (map-backslash-to-slash mount))
								  cygpath)))))
	(if mount
		(concat (car mount) (substring winpath (length (cdr mount))))
	  (concat (ed::cygwin-mount-cygdrive-prefix) "/"
			  (substitute-string winpath ":" "")))))

(defun symb (&rest args)
  (intern (apply #'(lambda (&rest args)
					 (with-output-to-string (s)
					   (dolist (a args) (princ a s))))
				 args)
		  (find-package "complete+")))
(defmacro with-structure ((name . fields) struct &body body)
  (let ((g (gensym)))
	`(let ((,g ,struct))
	   (let ,(mapcar #'(lambda (f)
						 `(,f (,(symb name f) ,g)))
					 fields)
		 ,@body))))

#| (directory-patch "c:/d/m/hoge" "c:/data/movie/")
=> "c:/data/movie/hoge"
|#
(defun directory-patch (string1 string2)
  (cond ((< (count #\/ string1) (count #\/ string2))
		 (remove-trail-slash string2))
		((and (null (pathname-directory string1))
			  (null (pathname-directory string2))
			  (string= (directory-namestring string2) string2))
		 string1)
		((equal (length (pathname-directory string1))
				(length (pathname-directory string2)))
		 string2)
		(t
		 (let ((tmp (merge-pathnames "/" (pathname-device string1))))
		   (setf string2 (remove-trail-slash string2))
		   (when (string-not-equal (remove-trail-slash tmp) string2)
			 (setf string1
				   (substitute-string
					string1
					(dotimes (i (count #\/ string2) (regexp-quote tmp))
					  (setf tmp (merge-pathnames (nth i (pathname-directory string1))
												 tmp)))
					string2 :case-fold t)))
		   string1))))

;;; virtual
(defvar *virtual-file-handlers* nil)
(defvar *virtual-file-add-slash-automatically* nil)
(defun regist-virtual-file-handler (check-regexp list-function load-function save-function)
  (push (list check-regexp list-function
			  load-function save-function)
		*virtual-file-handlers*))

;;; virtual
(defun directory-namestring-cygwin (path)
  "cygwin-mountも考慮したdirectory-namestring"
  (cond ((and (cygwin-mount-p)
			  (head-is-slash path))
		 (substring path 0
					(1+ (position #\/ path :from-end t :test 'equal))))
		(t
		 (directory-namestring path))))
(defun file-exist-p-cygwin-virtual (path)
  (let* ((base (find-exist-path path))
		 (file (remove-prefix path base))
		 all res type)
	(multiple-value-setq (res type)
	  (completion-get-virtual-list base file))
	(when (consp res)
	  (setf all res
			res nil))
	(unless all
	  (return-from file-exist-p-cygwin-virtual))
	(find file all :test 'equalp)))
(defun file-exist-p-cygwin (path &key virtual zero)
  (cond ((and (cygwin-mount-p)
			  (head-is-slash path))
		 (let ((winpath (map-backslash-to-slash
						 (funcall (intern "cygwin-mount-resolve" "editor")
								  path))))
		   (and (equal (substring path -1) "/")
				(setf winpath (append-trail-slash winpath)))
		   (or (and virtual
					(file-exist-p-cygwin-virtual winpath))
			   (file-exist-p winpath))))
		((and zero
			  (equal path ""))
		 path)
		((and (stringp path)
			  (string-match "^//\\([^/]*?\\)/?$" path)
			  (or (equal (match-string 1) "")
				  (find (match-string 1) (list-servers)
						:test (if *complete+-case-fold* 'equalp 'equal))))
		 path)
		(t
		 (or (and virtual
				  (completion-is-virtual path)
				  ;(file-exist-p-cygwin-virtual path)
				  )
			 (file-exist-p path)))))
;; virtualがtなら ファイル名部分を削っていってマッチすれば存在することにする
(defun find-exist-path (path &key virtual zero);zero == zero length string
  (if (and (file-exist-p-cygwin path
								:virtual virtual
								:zero zero)
		   (or (and zero (equal path ""))
			   (tail-is-slash path)
			   (string-match "\\.\\.$" path)))
	  path
	(find-exist-path
	 (directory-namestring-cygwin
	  (remove-trail-slash path))
	 :virtual virtual :zero zero)))

(defun completion-is-virtual (path)
  (find-if #'(lambda (x) (when (string-match (car x) path)
						   t))
		   *virtual-file-handlers*))
(defun completion-get-virtual-list (base file)
  (let ((f (completion-is-virtual base)))
	(with-set-buffer
	  (save-excursion
		(cond (f (funcall (cadr f) base file))
			  (t t))))))

;; (split-by-last-slash "xyzzy/src/a")
;; => "xyzzy/src/"
;; => "a"
(defun split-by-last-slash (file)
  (let (name dir)
	(cond ((not (string-match "/" file))
		   (setf dir ""
				 name file))
		  ((string-match ".*/\\([^/]*\\)" file)
		   (setq name (match-string 1)
			  dir (substring file 0 (match-beginning 1))))
		  (t (setq name ""
			dir file)))
	(values dir name)))

(defun completion-do-virtual-complete-tree (file lst)
  (let (dir name)
	(multiple-value-setq (dir name)
	  (split-by-last-slash file))
	(flet ((filter (fn lst)
			 (let (res)
			   (dolist (x lst)
				 (let ((val (funcall fn x)))
				   (if val (push val res))))
			   (nreverse res))))
	  (delete-duplicates
	   (filter
		(lambda (x)
		  (and (string-match (concat "^" (regexp-quote dir)) x)
			   (string-match "^\\([^/]*/?\\)" (substring x (length dir)))
			   (not (string= "" (match-string 1)))
			   (match-string 1)
			   ))
		lst)
	   :test 'equal))))

(defun completion-do-virtual (completion)
  (let* ((path (completion-string completion))
		 (dir (directory-namestring path))
		 (base (find-exist-path path))
		 (new (copy-completion completion))
		 list all res type)
	(when (string= path "")
	  (return-from completion-do-virtual completion))
	(if (file-exist-p path)
		(and (tail-is-not-slash path)
			 (not (string-match "/\\.$" path))
			 (return-from completion-do-virtual completion))
	  (when (file-directory-p base)
		(completion-show-debug "completion-do-virtual 2~%~A" completion)
		(return-from completion-do-virtual completion)))
	(multiple-value-setq (res type)
	  (completion-get-virtual-list base (substring path (length base))))
	(when (consp res)
	  (setf all res
			res nil))
	(unless all
	  (completion-show-debug "completion-do-virtual 3~%~A" completion)
	  (return-from completion-do-virtual completion))
	(let ((fname (substring path (length dir)))
		  (file (substring path (length base))))
	  (flet ((get-list (str)
			   (multiple-value-bind (r l)
				   (*do-completion str :list-ignore-case nil all) l))
			 (resolve-show-dots (lst)
			   (if (and (not show-dots)
						(or (string= "" fname)
							(not (string= "." (substring fname 0 1)))))
				   (remove-if (lambda (f) (string= "." (substring f 0 1))) lst)
				 lst)))
		(cond ((eq type :tree);; tree
			   (setf list (resolve-show-dots (completion-do-virtual-complete-tree file (get-list file))))
			   (setf all (if (string= "" fname) list
						   (completion-do-virtual-complete-tree file all))))
			  ((eq type :list);; list
			   (setf list (resolve-show-dots (get-list fname)))
			   (when (string= "" fname)
				 (setf all list))))))
	(dolist (l list)
	  (push (cons l (remove-prefix path dir))
			*complete-matched-substring-list*))
	(setf (completion-string new) path
		  (completion-prefix new) dir
		  (completion-virtual new) base
		  (completion-candidate-all new)
		  (mapcar (append-prefix-closure dir) all)
		  (completion-candidate-prefix new) (mapcar (append-prefix-closure dir) list)
		  (completion-result new) (and (equal path dir)
									   (not list)
									   :no-completions))
	(completion-show-debug "completion-do-virtual last~%~A" completion )
	new))

;;; prefix match
(defun completion-do-prefix (x)
  (completion-show-debug "completion-do-prefix~%~A" x)
  (when (find :always (list *complete+-substring-match*
							*complete+-skip-match*))
	(return-from completion-do-prefix x))
  (let ((new (copy-completion x))
		case prefix cand)
	(with-structure
	 (completion- string type) x
	 (multiple-value-setq (cand prefix)
	   (completion-do-prefix-internal x))
	 (completion-show-debug "completion-do-prefix:after internal~%~A" x)
	 (when (equal string prefix)
	   (setf (completion-candidate-all new) cand
			 (completion-candidate-prefix new) cand
			 (completion-prefix new) prefix)
	   (return-from completion-do-prefix new))
	 (unless (eq type :list-ignore-case)
	   (when (or (eq *complete+-case-fold* :smart)
				 (eq *complete+-case-fold* nil))
		 (setf case (regexp-compile
					 (if prefix (remove-prefix string prefix) string)
					 :prefix t
					 :quote t))
		 (completion-show-debug "completion-do-prefix:set case-fold~%~A" x)
		 (setf cand (delete-if-not #'(lambda (x) (string-match case x))
								   cand
								   :key (remove-prefix-closure prefix)))
		 (completion-show-debug "completion-do-prefix:set cand~%~A" x)
		 ))
	 (setf (completion-candidate-prefix new) cand)
	 (unless (completion-prefix new)
	   (setf (completion-prefix new) prefix))
	 (completion-show-debug "completion-do-prefix:end~%~A" x)
	 new)))
(defun completion-do-prefix-internal (x)
  (completion-show-debug "completion-do-prefix-internal~%~A" x)
  (with-structure
   (completion- string type candidate-all prefix cygwin) x
   (multiple-value-bind (result lst pre)
	   (if candidate-all
		   (*do-completion- string :list-ignore-case nil candidate-all)
		 (*do-completion- string type))
	 
	 ;; message, plain-error quitが２つ出る*do-completionのバグ対策
	 (dolist (x '("message" "plain-error" "quit"))
	   (when (= 2 (count x lst :test 'equal))
		 (setf lst (remove x lst :test 'equal :count 1))))
	 
	 (completion-show-debug "completion-do-do-prefix-internal:lst~%~A" lst)
	 (let ((closure (append-prefix-closure (or pre prefix))))
	   (unless (equal closure 'identity)
		 (setf lst (mapcar closure lst))
		 (completion-show-debug "completion-do-do-prefix-internal:lst append-prefix~%~A" lst)
		 ))
	 ;; /cygdrive/ ではカレントディレクトリは探さない
	 (and cygwin
		  (string-matchp (concat "^" (ed::cygwin-mount-cygdrive-prefix)
								 "\\(?:$\\|/$\\|/\\([A-Z]\\)$\\)")
						 cygwin)
		  (setf lst nil))
	 ;;     (setf lst (mapcar (append-prefix-closure prefix) lst))
	 (dolist (l (mapcar (remove-prefix-closure pre) lst))
	   (push (cons l (remove-prefix string pre))
			 *complete-matched-substring-list*))
	 (values lst (or pre prefix)))))

;;; {migemo,sub,skip}-match
(defun completion-do-sub-migemo-skip (x)
  (completion-show-debug "completion-do-sub-migemo-skip~%~A" x)
  (when (and (or (completion-type-is-symbol x)
				 (not (migemo-p)))
			 ;sub
			 (or (eq *complete+-substring-match* :never)
				 (and (completion-candidate-prefix x)
					  (eq *complete+-substring-match* :smart)))
			 ;skip
			 (or (eq *complete+-skip-match* :never)
				 (and (eq *complete+-skip-match* :smart)
					  (completion-candidate-prefix x)
					  ;; + subをしない条件(上に書いた)
					  ;;   andだから ここに来る==subをしない条件を満たす
					  )))
	(setf (completion-candidate x)
		  (completion-candidate-prefix x))
	(return-from completion-do-sub-migemo-skip x))
  (setf x (completion-do-sub-migemo-skip-internal x))
  (completion-show-debug "completion-do-sub-migemo-skip:after internal~%~A" x)
  (when (completion-result x)
	(return-from completion-do-sub-migemo-skip x))
  (let ((new (copy-completion x))
		migemo sub skip)
	(with-structure
	 (completion- string type candidate-all candidate-prefix prefix) x
	 ;; string == prefix == need to return max list.
	 (when (equal string prefix)
	   (setf (completion-candidate x) candidate-all)
	   (return-from completion-do-sub-migemo-skip x))
	 ;; remove prefix
	 (setf candidate-all (mapcar (remove-prefix-closure prefix) candidate-all))
	 (setf candidate-prefix (mapcar (remove-prefix-closure prefix) candidate-prefix))
	 (setf string (remove-prefix string prefix))
	 (completion-show-debug "completion-do-sub-migemo-skip:remove prefix~%~A" x)
	 ;; substring
	 (when (or (and (eq *complete+-substring-match* :smart)
					(null candidate-prefix))
			   (eq *complete+-substring-match* :always))
	   (setf sub (regexp-compile string
								 :quote t
								 :ignore-case (eq type :list-ignore-case))))
	 (completion-show-debug "completion-do-sub-migemo-skip:set substring~%~A" x)
	 ;; migemo
	 (when (and (migemo-p)
				(not (completion-type-is-symbol x))
				(notany 'jp-char-p string))
	   ;; (when "use substring-match"
	   ;;       "use migemo-substring-match")
	   (let ((tmp (funcall (intern "migemo-query" "editor")
						   string)))
		 (setf migemo (if sub (regexp-compile tmp
											  :ignore-case (eq type :list-ignore-case))
						(regexp-compile tmp
										:prefix t
										:ignore-case (eq type :list-ignore-case))))))
	 (completion-show-debug "completion-do-sub-migemo-skip:set migemo~%~A" x)
	 ;; skip
	 (when (or (and (eq *complete+-skip-match* :smart)
					(null candidate-prefix))
			   (eq *complete+-skip-match* :always))
	   (setf skip (regexp-compile (map-concat string ".*")
								  :ignore-case (eq type :list-ignore-case))))
	 (completion-show-debug "completion-do-sub-migemo-skip:set skip~%~A" x)
	 ;; search
	 (let* ((closure (completion-do-sub-migemo-skip-closure
					  sub migemo
					  (when (eq *complete+-skip-match* :always) skip)))
			(cand (and closure
					   (remove-if-not closure candidate-all))))
	   (and migemo (not sub) (not skip)
			(setf cand (union cand candidate-prefix :test 'equal)))
	   (unless cand
		 (setf cand candidate-prefix))
	   (completion-show-debug "do-sub:1~%~A" cand)
	   (when (or cand
				 (eq *complete+-skip-match* :always))
		 (setf (completion-candidate new)
			   (mapcar (append-prefix-closure prefix) cand))
		 (completion-show-debug "do-sub:2~%~A" new)
		 (return-from completion-do-sub-migemo-skip new)))
	 ;; skip only
	 (let ((closure (completion-do-sub-migemo-skip-closure nil nil skip)))
	   (when closure
		 (setf (completion-candidate new)
			   (mapcar (append-prefix-closure prefix)
					   (remove-if-not closure candidate-all))))))
	(completion-show-debug "do-sub:skip-only~%~A" new)
	new))
(defun completion-do-sub-migemo-skip-internal (x)
  (completion-show-debug "completion-do-sub-migemo-skip-internal~%~A" x)
  ;; virtual, prefixの時点でstring=prefix,:list,:list-ignore-case
  ;; はcompletion-allを既に持ってる
  (when (completion-candidate-all x)
	(return-from completion-do-sub-migemo-skip-internal x))
  (let ((new (copy-completion x)))
	(with-structure
	 (completion- type candidate prefix candidate-all cygwin) x
	 (unless prefix
	   (setf prefix ""))
	 (multiple-value-bind (result list pre)
		 (*do-completion- prefix type nil candidate)
	   (unless list
		 (setf (completion-result new) result))
	   ;; /cygdrive/ ではカレントディレクトリは探さない
	   (and cygwin
			(string-matchp (concat "^" (ed::cygwin-mount-cygdrive-prefix)
								   "\\(?:$\\|/$\\|/\\([A-Z]\\)$\\)")
						   cygwin)
			(setf list nil))
	   (completion-show-debug "completion-do-sub-migemo-skip-internal:1~%~A" list)
	   (setf (completion-candidate-all new)
			 (mapcar (append-prefix-closure prefix) list))
	   (completion-show-debug "completion-do-sub-migemo-skip-internal:2~%~A" (completion-candidate-all new))
	   (setf (completion-prefix new) pre)))
	new))

(defun completion-do-sub-migemo-skip-closure (sub migemo skip);; もっとDRYにしたい…
  (if skip
	  (cond ((and sub migemo)
			 #'(lambda (item)
				 (when (or (string-match sub item)
						   (when (some 'jp-char-p item)
							 (string-match migemo item))
						   (string-match skip item))
				   (push (cons item (match-string 0)) *complete-matched-substring-list*))))
			(sub
			 #'(lambda (item)
				 (when (or (string-match sub item)
						   (string-match skip item))
				   (push (cons item (match-string 0)) *complete-matched-substring-list*))))
			(migemo
			 #'(lambda (item)
				 (when (or (when (some 'jp-char-p item)
							 (string-match migemo item))
						   (string-match skip item))
				   (push (cons item (match-string 0)) *complete-matched-substring-list*))))
			(t
			 #'(lambda (item)
				 (when (string-match skip item)
				   (push (cons item (match-string 0)) *complete-matched-substring-list*)))))
	(cond ((and sub migemo)
		   #'(lambda (item)
			   (when (or (string-match sub item)
						 (when (some 'jp-char-p item)
						   (string-match migemo item)))
				 (push (cons item (match-string 0)) *complete-matched-substring-list*))))
		  (sub
		   #'(lambda (item)
			   (when (string-match sub item)
				 (push (cons item (match-string 0)) *complete-matched-substring-list*))))
		  (migemo
		   #'(lambda (item)
			   (when (when (some 'jp-char-p item)
					   (string-match migemo item))
				 (push (cons item (match-string 0)) *complete-matched-substring-list*)))))))

(defun completion-do-other-internal (x)
  (completion-show-debug "completion-do-other-internal~%~A" x)
  (with-structure
   (completion- string candidate-all) x
   (when (and (completion-type-is-list x)
			  (equal string ""))
	 (let ((new (copy-completion x)))
	   (setf (completion-candidate new) candidate-all)
	   (return-from completion-do-other-internal new))))
  (setf x
		(completion-do-sub-migemo-skip
		 (completion-do-prefix x))))

(defun completion-do-file-internal (x)
  (completion-show-debug "completion-do-file-internal~%~A" x)
  (setf x (completion-do-virtual;; virtual
		   (completion-get-prefix x)))
  (unless (completion-virtual x)
	(setf x (completion-do-prefix x)))
  (unless (completion-result x)
	(setf x (completion-do-sub-migemo-skip x)))
  x)

(defun completion-do-and (x)
  (completion-show-debug "completion-do-and~%~A" x)
  (setf x (completion-get-prefix x))
  (let ((position (completion-and x))
		(internal-func (if (completion-type-is-file x)
						   #'completion-do-file-internal
						 #'completion-do-other-internal)))
	(cond ((realp position)
		   (with-structure
			(completion- string prefix) x
			(let ((new (copy-completion x))
				  (*complete+-substring-match* :always)
				  (split (split-string (remove-prefix string prefix)
									   *complete+-and-search*))
				  cand)
			  (completion-show-debug "do-and1~%~A~%~A" x split)
			  (setf (completion-string new)
					(append-prefix (car split) prefix)
					cand (completion-candidate
						  (funcall internal-func new)))
			  (dolist (el (cdr split))
				(setf (completion-string new) (append-prefix el prefix)
					  cand  (intersection cand
										  (completion-candidate
										   (funcall internal-func new))
										  :test 'equalp)))
			  (setf (completion-candidate new) cand
					(completion-string new) string)
			  (completion-show-debug "do-and12~%~A" new)
			  new)))
		  (t
		   (completion-show-debug "do-and2~%~A" x)
		   (funcall internal-func x)))))

(defun completion-do-directory-skip (x)
  (let ((new (copy-completion x))
		exist exists elements)
	(with-structure
	 (completion- string) x
	 ;for virtual
	 (completion-show-debug "dir-skip a~%~S~%~S~%~S" elements string exists)
	 (setf exist (find-exist-path string))
	 (push exist exists)
	 (completion-show-debug "dir-skip c~%~S~%~S~%~S" elements string exists)
	 (cond ((and (not (completion-is-virtual exist))
				 (setf elements (split-string (remove-prefix string (car exists)) "/")))
			(completion-show-debug "dir-skip1~%~S~%~S~%~S" elements string exists)
			(let ((new (copy-completion x))
				  (tmp (copy-completion x))
				  tmp-exists)
			  (dolist (el elements)
				(dolist (ex exists)
				  (setf (completion-string tmp)
						(append-prefix el ex))
				  (with-structure
				   (completion- candidate)
				   (completion-do-and tmp)
				   (setf tmp-exists (append tmp-exists candidate))))
;; 				(setf tmp-exists
;; 					  (mapcar #'(lambda (item)
;; 								  (if (completion-get-virtual-list item)
;; 									  (append-trail-slash item)
;; 									item))
;; 							  tmp-exists))
				(setf exists tmp-exists
					  tmp-exists nil))
			  (setf (completion-candidate new) exists)
			  new))
		   (t
			(completion-show-debug "dir-skip2~%~A" x)
			(completion-do-and x))))))
(defun completion-do-drive (x)
  (with-structure
   (completion- string type cygwin) x
   (if (or (and *complete+-show-drive*
				(string-matchp "^\\([a-z]:?$\\|$\\)" string))
		   (and cygwin
				(string-matchp (concat "^" (ed::cygwin-mount-cygdrive-prefix)
									   "/[a-z]?$")
							   string)))
	   (let ((new (copy-completion x)))
		 (setf (completion-candidate new)
			   (completion-candidate
				(completion-do-other-internal
				 (get-completion string :list-ignore-case nil
								 (get-drive-list (not cygwin))))))
		 new)
	 x)))

(defun completion-do (x)
  (cond ((completion-type-is-file x)
		 (with-structure
		  (completion- string) x
		  ;; backslash to slash
		  (setf string (map-backslash-to-slash string))
		  ;; [a-zA-Z]:/
		  (let ((start 0)
				res)
			(while (string-match "\\(^\\|/\\)\\([a-zA-Z]:\\)\\(/\\|$\\)" string start)
			  (setf res (match-beginning 2)
					start (match-end 0)))
			(when (numberp res)
			  (setf string (substring string res))))
		  ;; ~/
		  (let ((start 0)
				res)
			(while (string-match "\\(^\\|/\\)\\(~\\)\\(/\\|$\\)" string start)
			  (setf res (match-beginning 2)
					start (match-end 0)))
			(when (numberp res)
			  (setf string (substring string res))))
		  ;; ~/
		  (when (string-match "^~/" string)
			(let ((file (substring string 2))
				  (dir (user-homedir-pathname)))
			  (setf string (if (equal file "")
							   (append-trail-slash dir)
							 (merge-pathnames file dir)))))
		  ;; //
		  (when (string-match "./\\{2,\\}" string)
			(let ((device (pathname-device string)))
			  (setf string
					(if device (concat device ":/")
					  (concat "/" (substitute-string string "/\\{2,\\}" "/"))))))
		  (setf (completion-string x) string))
		 ;; cygwin mount
		 (cond ((cygwin-mount-p)
				(with-structure
				 (completion- string prefix) x
				 (when (and (head-is-slash string)
							(not (head-is-slash2 string)))
				   (let ((string1 (get-win-path string)))
					 (unless (equalp string string1)
					   ;; /cygdrive と /cygdrive/ が c:/cygwin/cygdriveになる対策
					   (cond ((string-matchp (concat "^" (ed::cygwin-mount-cygdrive-prefix)
													 "\\(?:$\\|/$\\|/\\([A-Z]\\)$\\)")
											 string)
							  (setf string1 (or (match-string 1) "")))
							 ((file-directory-p string1)
							  (setf string1 (append-trail-slash string1))))
					   (setf (completion-string x) string1
							 (completion-cygwin x) string))))))
			   ;; UNC
			   ((string= "/" (completion-string x))
				(setf (completion-candidate-all x) '("//"))))
		 (with-structure
		  (completion- candidate string cygwin) (completion-do-drive x);drive
		  (and (cygwin-mount-p);cygwin root
			   (equal string "")
			   (not cygwin)
			   (push "/" candidate))
		  (setf x (completion-get-prefix x))
		  (setf x (completion-do-directory-skip x))
		  (setf candidate (append (completion-candidate x)
								  candidate))
		  ;; add slash after virtual file extension.
		  ;; e.g. `._ftp/'
		  (when (and candidate *virtual-file-handlers* *virtual-file-add-slash-automatically*)
			(setf candidate
				  (mapcar (lambda (path)
							(cond ((file-directory-p path)
								   path)
								  ((completion-is-virtual (concat path "/"))
								   (concat path "/"))
								  (t path)))
						  candidate)))
		  (setf (completion-candidate x) candidate))
		 (setf x (convert-cygwin-path x))
		 x)
		(t
		 (completion-do-and (completion-get-prefix x)))))

(defun get-win-path (cygpath)
  "..で1階層上に行かないように。
バックスラッシュに変換しないように。
最後のスラッシュ外さないように。"
  (let ((count (count #\/ cygpath)))
	(cond ((> count 2)
		   (let ((pos (position #\/ cygpath :from-end t)))
			 (concat (append-trail-slash
					  (map-backslash-to-slash
					   (funcall (intern "cygwin-mount-resolve" "editor")
								(substring cygpath 0 (1+ pos)))))
					 (substring cygpath (1+ pos)))))
		  (t
		   (map-backslash-to-slash
			(funcall (intern "cygwin-mount-resolve" "editor") cygpath))))))

(defun convert-cygwin-path (x)
  (unless (and (cygwin-mount-p)
			   (completion-cygwin x))
	(return-from convert-cygwin-path x))
  (let ((new (copy-completion x)))
	(with-structure
	 (completion- cygwin prefix candidate) x
	 (setf (completion-string new) cygwin
		   new (completion-get-prefix new)
		   (completion-candidate new)
		   (mapcar (append-prefix-closure
					(completion-prefix new))
				   (mapcar (remove-prefix-closure prefix)
						   candidate))))
	(completion-show-debug "conv-cyg-path1~%~A" new)
	(let (cand res)
	  (with-structure
	   (completion- string candidate prefix) new
	   ;; mount-tableを候補に入れる
	   (setf cand (union
				   (mapcar 'append-trail-slash
						   (append (list (ed::cygwin-mount-cygdrive-prefix))
								   (remove "/" (mapcar 'car (ed::cygwin-mount-table))
										   :test 'equal)))
				   candidate :test 'equalp))
	   ;; 関係ないmount-tableは除外
	   (setf cand (delete-if-not #'(lambda (item)
									 (string-match (regexp-compile prefix :prefix t) item))
								 cand))
	   (completion-show-debug "conv-cyg-path3~%~A" cand)
	   (cond ((equalp string prefix)
			  (setf res cand))
			 ((equalp string (concat prefix ".."))
			  (setf res cand))
			 (t
			  ;; remove-prefix
			  (setf cand (mapcar (remove-prefix-closure prefix) cand))
			  (completion-show-debug "conv-cyg-path3-1~%~A" cand)
			  (setf cand (mapcar (remove-prefix-closure prefix)
								 (completion-candidate
								  (completion-do-and
								   (get-completion (remove-prefix string prefix)
												   :list-ignore-case nil cand )))))
			  (completion-show-debug "conv-cyg-path3-2~%~A" cand)
			  ;; append-prefix
			  (dolist (c cand)
				(pushnew (append-prefix (if (and (not (equal c ""))
												 (string-match "/" (substring c 0 -1)))
											(substring c 0 (match-end 0)) c)
										prefix)
						 res :test 'equalp))
			  (completion-show-debug "conv-cyg-path3-3~%~A" cand)
			  (setf res (nreverse res))))
	   (completion-show-debug "conv-cyg-path4~%~A" cand)
	   (setf (completion-candidate new) res)))
	new))

(defun completion-is-no-completion (x)
  (with-structure
   (completion- candidate result string) x
   (or (eq result :no-completions)
	   (and (completion-type-is-file x)
			(null candidate)
			(tail-is-slash string)))))

(defun completion-is-no-match (x)
  (with-structure
   (completion- candidate) x
   (null candidate)))

(defun completion-is-solo-match (x)
  (with-structure
   (completion- candidate string) x
   (and (find string candidate :test 'equal)
		(null (cdr candidate)))))

(defun completion-is-not-unique (x)
  (with-structure
   (completion- candidate string) x
   (and (find string candidate :test 'equalp)
		(cdr candidate))))

(defun completion-is-unique (x)
  (with-structure
   (completion- candidate string) x
   (and candidate
		(null (cdr candidate)))))

(defun delete-highlight (&optional attribute-only goto-to)
  (multiple-value-bind (from to tag)
	  (find-text-attribute 'complete+)
	(when from
	  (unless attribute-only
		(delete-region from to))
	  (delete-text-attributes 'complete+)
	  (goto-char to))))

(defun completion-highlight (x text)
  (let ((new (copy-completion x))
		result highlight)
	(cond ((not-zero-string-p text)
		   (setf result text)
		   (with-structure
			(completion- string prefix) x
			(when prefix
			  (setf string (remove-prefix string prefix t)
					text (remove-prefix text prefix t)))
			(when *icompletion-internal*
			  (when (and *complete+-highlight-color*
						 (minibuffer-window-p (selected-window))
						 (not (equalp string text))
						 (not (equal string ""))
						 (not (equal "" (setf highlight
											  (substitute-string
											   text
											   (concat "^" (regexp-quote string))
											   ""
											   :case-fold t))))
						 ;; highlightが部分文字列か
						 (funcall (cond ((eq *complete+-case-fold* :smart)
										 (if (some 'upper-case-p string)
											 'equal 'equalp))
										(t (if *complete+-case-fold* 'equalp 'equal)))
								  text (concat string highlight)))
				(let (point)
				  (apply 'set-text-attribute
						 (setf point (point))
						 (progn
						   (goto-char (point-max))
						   (insert highlight)
						   (point))
						 'complete+
						 *complete+-highlight-color*)
				  (goto-char point)))
			  (when prefix
				(setf string (append-prefix string prefix)))
			  (setf result string))))
		  ((stringp text)
		   (setf result text))
		  (t
		   (setf result (completion-result x))))
	(setf (completion-result new) result)
	new))

(defun completion-get-result (x)
  (with-structure
   (completion- string prefix) x
   (let ((result
		  (cond ((completion-is-no-completion x)
				 (delete-highlight t)
				 :no-completions)
				((completion-is-no-match x)
				 :no-match)
				((completion-is-solo-match x)
				 (delete-highlight t)
				 :solo-match)
				((completion-is-not-unique x)
				 (delete-highlight t)
				 :not-unique)
				(*icompletion-internal*
				 nil)
				((completion-is-unique x)
				 (multiple-value-bind (from to tag)
					 (find-text-attribute 'complete+)
				   (when from
					 (setf string (buffer-substring (point-min) from))))
				 (delete-highlight t)
				 (with-structure
				  (completion- candidate) x
				  (car candidate)))
				(t
				 (delete-highlight t)
				 nil)
				))
		 (new (copy-completion x))
		 tmp)
	 ; 子ディレクトリが１つしか含まれないディレクトリでハイライトを使い、
	 ; [TAB]を押すと子の末尾(/)まで補完されてしまう対策。
	 ; c:/Documents and Settings/user/Application Data/Mo[zilla/]  (括弧内がハイライト)
	 ; の状態でMozilla/内にFirefoxというディレクトリしか無かったら
	 ; c:/Documents and Settings/user/Application Data/Mozilla/Firefox/ まで補完してしまう。
	 (when (and (tail-is-slash result); result文字列がある時点でuniqueしかありえない
				(completion-type-is-file x)
				(string-match (concat "^" string) result)
				(= (count #\/ (remove-prefix result string)) 2)
				)
	   (setf result (directory-namestring-cygwin (remove-trail-slash result))))
	 (unless result
	   (setf tmp (completion-get-prefix-by-candidate x))
	   (when (string-match "\\.\\.$" string);; .. 対策
		 (setf string (substring string 0 -2)))
	   (unless (string-matchp (concat "^" (regexp-quote string)) tmp)
		 (setf tmp (directory-patch string tmp)))
	   ; Migemo変換で日本語が混じる場合を除き、
	   ; 補完した文字列が入力した文字列より短かったら補完はなかったことに
	   (and (if (migemo-p)
				(notany 'jp-char-p tmp)
			  t)
			(> (length string) (length tmp))
			(setf tmp string))
	   (or (completion-is-virtual (find-exist-path string :virtual t))
		   (when (and (not *icompletion-internal*)
					  (minibuffer-window-p (selected-window)))
			 (goto-char (1+ (length (find-exist-path string :virtual t))))
			 (when (looking-at "\\([^/]+\\)")
			   (goto-char (match-end 1))
			   (refresh-screen)))))
	 (setf (completion-result new) result)
	 ;; highlight
	 (setf new (completion-highlight new tmp))
	 (with-structure
	  (completion- string result prefix candidate type) new
	  (when (and (completion-type-is-file new)
				 (stringp result)
				 (notevery #'(lambda (item)
							   (string-matchp (concat "^" (regexp-quote prefix))
											  item))
						   candidate))
		(and tmp
			 (stringp tmp)
			 (setf (completion-prefix new)
				   (find-exist-path tmp :zero t)))))
	 new)))

(defun *do-completion+ (string type &optional wordp list)
  (setf *complete-matched-substring-list* nil)
  (let ((x (get-completion string type t list)) tmp)
	(completion-show-debug "completion(start)~%~A" x)
	(with-structure
	 (completion- result candidate prefix)
	 (completion-get-result
	  (completion-do x))
	 (and wordp
		  (stringp result)
		  (setf result (substring result 0
								  (string-match "\\<" result (1+ (length string))))))
	 (when prefix
	   (setf candidate
			 (remove "" (mapcar (remove-prefix-closure prefix t)
								candidate)
					 :test 'equal)))
	 (show-message)
	 (setf *complete-prefix* prefix)
	 (setf *complete-result*
		   (if (stringp result) result ""))
	 (setf *complete+-list* candidate)
	 (cond ((find result '(:no-match
						   :no-completions))
			(unless (and (not (equal string ""))
						 (string= "~" (substring string -1)))
			  (setf *icompletion-next* nil))
			(values (if (equal result string) string result)
					candidate))
		   (t
			(values (if (equal result string) string result)
					candidate prefix))))))

;;; モードラインの状態表示
(pushnew '(*complete-show-message-internal* . *complete-mode-line-string*)
		 *minor-mode-alist* :key #'car)
(defun show-message (&optional buffer history)
  (when *complete+-show-message*
	(setf *complete-show-message-internal* t
		  *complete-mode-line-string* (format nil *complete+-show-message*
											  *complete+-substring-match*
											  *complete+-skip-match*
											  *complete+-case-fold*
											  *icompletion*))
	(if (minibuffer-window-p (selected-window))
		(add-hook '*exit-minibuffer-hook* 'complete-delete-message)
	  (start-timer *complete+-show-message-time* 'complete-delete-message t))
	(unless *executing-macro*
	  (update-mode-line))));; (update-mode-line t)?

(defun complete-delete-message (&optional buffer contents)
  (setf *complete-show-message-internal* nil
		*complete-mode-line-string* "")
  (unless *executing-macro*
	(update-mode-line)
	(unless buffer
	  (refresh-screen))))

;;; ここからinteractiveな関数
(defun minibuffer-complete+ (&optional word)
  (interactive "*p")
  (unless *icompletion-next*
	(setf *icompletion-next* t))
  (multiple-value-bind (from to tag)
	  (find-text-attribute 'complete+)
	(when (and from *complete+-case-fold*
			   ;prefixを除いた入力が全部小文字の時
			   (every #'(lambda (c)
						  (or (not (alpha-char-p c))
							  (lower-case-p c)))
					  (buffer-substring (length *complete-prefix*) (point))))
	  (let (str)
		(cond ((and (null (cdr *complete+-list*))
					(equalp (setf str (concat *complete-prefix* (car *complete+-list*)))
							(buffer-substring (point-min) (point-max)))
					(tail-is-slash str))
			   (delete-region (point-min) (point-max))
			   (insert str)
			   (apply 'set-text-attribute
					  from to 'complete+
					  *complete+-current-item-attribute*))
			  ; :smartならハイライト部分だけ小文字化
			  ((eq *complete+-case-fold* :smart)
			   (downcase-region (point) to))))))
  (do-completion+ (point-min) (point-max)
				  (minibuffer-completion-type)
				  (minibuffer-completion-list)
				  word
				  *last-command-char*
				  *minibuffer-popup-completion-list*)
  (setq *this-command* 'minibuffer-complete+))
(defun minibuffer-complete+-word ()
  (interactive "*")
  (minibuffer-complete+ t))
(defun minibuffer-exit+ ()
  (interactive)
  (and (cond ((and *complete+-create-new-file-check*
				   (member (minibuffer-completion-type)
						   '(:exist-file-name
							 :file-name
							 :file-name-list
							 :directory-name))
				   (eq *last-command* 'minibuffer-complete+))
			  (let ((file (buffer-substring (point-min) (point-max))))
				(or (or (file-exist-p file)
						(and (cygwin-mount-p)
							 (head-is-slash file)
							 (file-exist-p
							  (funcall (intern "cygwin-mount-resolve" "editor")
									   file)))
						(file-exist-p (namestring file)))
					(equalp *complete+-create-new-file* file)
					(progn (setf *complete+-create-new-file* file) nil))))
			 (t t))
	   (ed::minibuffer-exit-check)
	   (setf *complete+-create-new-file* "")
	   (exit-recursive-edit)))
(defun minibuffer-complete+-and-exit ()
  (interactive "*")
  (ed::minibuffer-exit-check)
  (let ((status (do-completion+-internal (point-min) (point-max)
					 (minibuffer-completion-type)
					 (minibuffer-completion-list)
					 t nil *minibuffer-popup-completion-list*)))
    (if (or (eq status :solo-match)
	    (eq status :not-unique))
	(exit-recursive-edit)
      (completion-message status))))
(defun do-completion+ (from to type &optional compl word last-char
							(popup-p *popup-completion-list-default*))
  (completion-message
   (if (eq type ':command-line)
	   (ed::complete-command-line from word)
	 (do-completion+-internal from to type compl nil word last-char popup-p))))
(defun print-completion+-list (list prefix &optional string popup-p from to)
  (unless *executing-macro*
	(let ((last-string ed::*completion-last-string*))
	  (setq ed::*completion-last-string* string)
	  (setq list (sort list #'string<))
	  (cond (*print-completion-list-hook*
			 (funcall *print-completion-list-hook* list prefix))
			((and (cond ((eq popup-p ':always) t)
						((eq popup-p ':never) nil)
						((eq *popup-completion-list-default* ':always) t)
						((eq *popup-completion-list-default* ':never) nil)
						(t popup-p))
				  from to)
			 (popup-completion+-list list (if prefix (+ from (length prefix)) from) to))
			((and (eq *last-command* 'minibuffer-complete+)
				  (equal string last-string)
				  (not *complete+-suppression-scroll*)
				  (ed::scroll-completion-list list prefix)))
			(t
			 (long-operation
			   (message "Making completion list...")
			   (let ((w (selected-window))
					 (buffer (selected-buffer)))
				 (unwind-protect
					 (with-output-to-temp-buffer (" *Completion*")
					   (setq ed::*completion-list* list)
					   (setq ed::*completion-related-buffer* buffer)
					   (setq ed::*completion-prefix* prefix)
					   (use-keymap ed::*completion-list-keymap*)
					   (cond ((< (apply #'max (or (mapcar #'length ed::*completion-list*) '(0))) 40)
							  (format t "Possible completions are:~%~%~{~A~^~39T ~A~%~}"
									  ed::*completion-list*)
							  (setq ed::*completion-list-column* 2))
							 (t
							  (format t "Possible completions are:~%~%~{~A~^~%~}"
									  ed::*completion-list*)
							  (setq ed::*completion-list-column* 1)))
					   (color-completion-buffer)
					   (setq buffer-read-only t))
				   (set-window w)
				   (unless (eq buffer (selected-buffer))
					 (pop-to-buffer buffer))))
			   (message "Making completion list...done")))))))
(defun color-completion-buffer ()
  (unless (local-variable-p 'regexp-keyword-list)
	(make-local-variable 'regexp-keyword-list))
  (setf regexp-keyword-list
		(union regexp-keyword-list *regexp-colorize-keyword-list* :test 'equal)))
(defvar *regexp-colorize-keyword-list*
  (compile-regexp-keyword-list
   '(("[^ \n]+/\\([ \n]\\|\\'\\)" nil (:color 13 0))
	 ("[^ \n]+\\.l\\([ \n]\\|\\'\\)" nil (:color 12 0))
	 )))
(defun do-completion+-internal (from to type &optional compl not-uniq-ok word last-char popup-p)
  (let ((string (buffer-substring from to)))
	(when (and (member type '(:file-name :exist-file-name
							  :file-name-list :directory-name))
			   (string-match "\\(^\\|[\\/]\\)\\.\\.[\\/]?$" string))
	  (let (winpath)
		(cond ((and (cygwin-mount-p)
					(head-is-slash string)
					(setf winpath (get-win-path string))
					(not (equal winpath string)))
			   (when (or (string-match "[\\/]$" winpath)
						 (null (directory (concat winpath "*") :count 1)))
				 (delete-region from to)
				 (insert (cygwin-mount-winpath-to-cygpath
						  (append-trail-slash (namestring winpath))))
				 (return-from do-completion+-internal t)))
			  (t
			   (when (or (string-match "[\\/]$" string)
						 (null (directory (concat string "*") :count 1)))
				 (delete-region from to)
				 (insert (append-trail-slash (namestring string)))
				 (return-from do-completion+-internal t))))))
	(long-operation
	  (multiple-value-bind (result list prefix)
		  (*do-completion+ string type word compl)
		(cond ((stringp result)
			   (cond ((eq string result)
					  (cond ((ed::completion-insert-self string list prefix last-char to)
							 t)
							(*completion-auto-help*
							 (print-completion+-list list prefix string popup-p from to)
							 't)
							(t
							 (setq ed::*completion-last-string* string)
							 :ambigous)))
					 (t
					  (delete-region from to)
					  (insert result)
					  't)))
			  ((eq result :not-unique)
			   (cond ((ed::completion-insert-self string list prefix last-char to)
					  t)
					 (t
					  (or not-uniq-ok
						  (print-completion-list list prefix string popup-p from to))
					  result)))
			  (t result))))))

(defun complete+-self-insert-command (&optional (arg 1))
  (interactive "*p")
  (call-interactively 'self-insert-command)
  (when (and (listen *keyboard*)
			 (eq (lookup-keymap (local-keymap)
								(peek-char nil *keyboard* nil nil nil))
				 *this-command*))
	(unless *executing-macro*
	  (refresh-screen))
	(return-from complete+-self-insert-command))
  (minibuffer-complete-input))
(defun complete+-backward-char (&optional (n 1))
  (interactive "p")
  (call-interactively 'ed::backward-char)
  (init-icompletion))
(defun complete+-delete-backward-char-or-selection (&optional (arg 1))
  (interactive "*p")
  (call-interactively 'ed::delete-backward-char-or-selection)
  (init-icompletion)
  (minibuffer-complete-input))
(defun complete+-backward-delete-char-untabify-or-selection (&optional (arg 1))
  (interactive "*p")
  (call-interactively 'ed::backward-delete-char-untabify-or-selection)
  (init-icompletion)
  (minibuffer-complete-input))
(defun minibuffer-complete-input (&optional (arg 1))
  (interactive "*p")
  (and *icompletion*
	   (minibuffer-window-p (selected-window))
	   (let ((*icompletion-internal* t))
		 (multiple-value-bind (from to tag)
			 (find-text-attribute 'complete+)
		   (when from
			 (delete-text-attributes 'complete+)
			 (delete-region (point) to)))
		 (when *icompletion-next*
		   (minibuffer-complete+))
		 
		 ;; *Completion*バッファの候補のマッチしてる部分を強調表示
		 (when *complete+-matched-string-attribute*
		   (let ((w (let ((buffer (find-buffer " *Completion*")))
					  (and buffer (get-buffer-window buffer))))
				 (string (remove-prefix *complete-result*
										*complete-prefix*)))
			 (when (and w
						(not-zero-string-p string))
			   (let ((ow (selected-window))
					 (buffer (selected-buffer)))
				 (unwind-protect
					 (let (list)
					   (set-window w)
					   (let (limit next)
						 (dolist (item *complete-matched-substring-list*)
						   (goto-char (point-min))
						   (next-line)
						   (loop
							 (or (and (scan-buffer (car item) :tail nil)
									  (setf limit (match-end 0))
									  (scan-buffer (cdr item)
												   :limit limit
												   :case-fold *complete+-case-fold*
												   :tail t)
									  (apply 'set-text-attribute
											 (match-beginning 0)
											 (match-end 0)
											 :complete+
											 *complete+-matched-string-attribute*))
								 (return))
							 (setf next (buffer-substring limit
														  (+ limit 1)))
							 (when (or (equal next "")
									   (equal (char next 0) #\LFD)
									   (equal (char next 0) #\SPC))
							   (return)))))
					   (goto-char (point-min)))
				   (set-window ow))))))
		 (setq *this-command* 'minibuffer-complete-input))))

(defun complete+-toggle-incremental (&optional (arg nil sv))
  "インクリメンタルな補完をトグル"
  (interactive "p")
  (ed::toggle-mode '*icompletion* arg sv)
  (when (minibuffer-window-p (selected-window))
	(let ((*icompletion-internal* t)
		  (*complete+-suppression-scroll* t))
	  (minibuffer-complete+)
	  (delete-highlight))))

(defun complete+-case-fold-ratate ()
  "case-foldを変更: nil -> t -> :smart"
  (interactive)
  (setf *complete+-case-fold*
		(cond ((eq *complete+-case-fold* nil)
			   t)
			  ((eq *complete+-case-fold* t)
			   :smart)
			  ((eq *complete+-case-fold* :smart)
			   nil)))
  (when (minibuffer-window-p (selected-window))
	(let ((*icompletion-internal* t)
		  (*complete+-suppression-scroll* t))
	  (minibuffer-complete+))))

(defun complete+-substring-match-rotate ()
  "部分一致を変更: always -> smart -> never"
  (interactive)
  (setf *complete+-substring-match*
		(case *complete+-substring-match*
		  (:always :smart)
		  (:smart  :never)
		  (:never  :always)))
  (when (minibuffer-window-p (selected-window))
	(let ((*icompletion-internal* t)
		  (*complete+-suppression-scroll* t))
	  (minibuffer-complete+))))

(defun complete+-skip-match-rotate ()
  "スキップマッチを変更: always -> smart -> never"
  (interactive)
  (setf *complete+-skip-match*
		(case *complete+-skip-match*
		  (:always :smart)
		  (:smart  :never)
		  (:never  :always)))
  (when (minibuffer-window-p (selected-window))
	(let ((*icompletion-internal* t)
		  (*complete+-suppression-scroll* t))
	  (minibuffer-complete+))))

(defun complete+-select-prev-item ()
  (interactive)
  (complete+-select-next-item t))
(defun complete+-select-next-item (&optional reverse)
  (interactive)
  (let ((w (let ((buffer (find-buffer " *Completion*")))
			 (and buffer (get-buffer-window buffer)))))
	(when w
	  (let ((ow (selected-window))
			(buffer (selected-buffer))
			word prefix)
		(unwind-protect
			(progn
			  (set-window w)
			  (setf prefix ed::*completion-prefix*)
			  (unless *completion-current-item*
				(setf *completion-current-item* -1))
			  (goto-char
			   (cond ((and reverse
						   (member *completion-current-item* '(0 -1)))
					  (point-max))
					 ((and (not reverse)
						   (= (length ed::*completion-list*)
							  (1+ *completion-current-item*)))
					  (point-min))
					 ((find-text-attribute :current))
					 ((if reverse (point-max) (point-min)))))
			  (setf *completion-current-item*
					(cond (reverse
						   (1- (if (< 0 *completion-current-item*)
								   *completion-current-item*
								 (length ed::*completion-list*))))
						  (t
						   (if (> (length ed::*completion-list*)
								  (1+ *completion-current-item*))
							   (1+ *completion-current-item*)
							 0))))
			  (delete-text-attributes :complete+)
			  (scan-buffer (concat "\\(?:^\\| \\)"
								   (regexp-quote
									(setf word
										  (nth *completion-current-item*
											   ed::*completion-list*)))
								   "\\(?:$\\| \\)")
						   :reverse reverse
						   :regexp t)
			  (apply 'set-text-attribute
					 (match-beginning 0)
					 (match-end 0)
					 :complete+
					 *complete+-current-item-attribute*))
		  (set-window ow))
		(stop-selection)
		(delete-region (point-min) (point-max))
		(when prefix
		  (insert prefix))
		(let ((pt (point)))
		  (insert word)
		  (goto-char pt))
		(selection-end-of-line)))))

;; complete+-{substring,skip}-match-rotateでprefixが変わっても選択できるように
;; *Completion* バッファで RET
(defun completion-list-copy ()
  (interactive)
  (let ((w (when ed::*completion-related-buffer*
			 (get-buffer-window ed::*completion-related-buffer*))))
	(unless w
	  (return-from completion-list-copy nil))
	(when (< (current-line-number) 3)
	  (plain-error))
	(let ((s (nth (if (= ed::*completion-list-column* 2)
					  (+ (* (- (current-line-number) 3) 2)
						 (if (< (current-column) 40) 0 1))
					(- (current-line-number) 3))
				  ed::*completion-list*)))
	  (unless (stringp s)
		(plain-error))
	  (when (stringp ed::*completion-prefix*)
		(setq s (concatenate 'string ed::*completion-prefix* s)))
	  (save-excursion
		(set-buffer ed::*completion-related-buffer*)
		;変更ここから
		(and (eq *complete+-substring-match* :never)
			 (eq *complete+-skip-match* :never)
			 (not (migemo-p))
			 (let ((o (buffer-substring (point-min) (point-max))))
			   (unless (eql (string-not-equal s o) (length o))
				 (plain-error))))
		;ここまで(なんか弊害があるかも)
		(delete-region (point-min) (point-max))
		(insert s))
	  (set-window w)
	  (goto-char (point-max)))))

(substitute-key-definition 'ed::completion-list-copy
			   'completion-list-copy
			   ed::*completion-list-keymap*)
;; popup-list で RET
(defun popup-completion+-list (list from &optional (to from))
  (let ((buffer (selected-buffer))
		(point (point)))
	(popup-list list #'(lambda (string)
						 (when (and (eq buffer (selected-buffer))
									(= point (point)))
						   (delete-highlight)
						   (cond ((and ed::*completion-last-string*
									   (> (length ed::*completion-last-string*) 0))
								  (scan-buffer ed::*completion-last-string*
											   :reverse t
											   :limit (save-excursion (goto-bol) (point)))
								  (delete-region (match-beginning 0) (match-end 0)))
								 (t
								  (let ((l (- to from)))
									(when (and (>= (length string) l)
											   (save-excursion
												 (goto-char from)
												 (looking-for (subseq string 0 l))))
									  (incf from l)
									  (setq string (subseq string l))))
								  (delete-region from to)))
						   (insert (or *complete-prefix* "") string)
						   (setf *complete-prefix* "")
						   (refresh-screen)))
				from)))

(defun init-icompletion (&optional buf his)
  (when *icompletion*
    (setf *icompletion-next* t)))
(add-hook '*enter-minibuffer-hook* 'init-icompletion)

(defun init-keybind ()
  (dolist (keymap (list minibuffer-local-completion-map
						minibuffer-local-must-match-map
						minibuffer-local-command-line-map))
	(do ((c #x21 (+ c 1)))
		((> c #x7e))
	  (define-key keymap (code-char c) 'complete+-self-insert-command))
	(substitute-key-definition 'backward-char
							   'complete+-backward-char
							   keymap *global-keymap*)
	(substitute-key-definition 'delete-backward-char-or-selection
							   'complete+-delete-backward-char-or-selection
							   keymap *global-keymap*)
	(substitute-key-definition 'backward-delete-char-untabify-or-selection
							   'complete+-backward-delete-char-untabify-or-selection
							   keymap *global-keymap*)
	(substitute-key-definition 'ed::minibuffer-exit
							   'minibuffer-exit+
							   keymap)
	(substitute-key-definition 'ed::minibuffer-complete
							   'minibuffer-complete+
							   keymap)
	(substitute-key-definition 'ed::minibuffer-complete-word
							   'minibuffer-complete+-word
							   keymap)
	(substitute-key-definition 'ed::minibuffer-complete-and-exit
							   'minibuffer-complete+-and-exit
							   keymap)
	))
(add-hook '*post-startup-hook* 'init-keybind)

#| --- Memo ---
ファイルの後ろに/付けたらエラー => 標準動作

--- Error ---

--- Scratch ---

(progn
  (pushnew :complete+ *features*)
  (pushnew :time *features*))

(progn
  (delete :complete+ *features*)
  (delete :time *features*))

>> (*do-completion "c:/data/music/uta" :file-name)
>> (*do-completion "//" :file-name)
>> (setf (symbol-function '*do-completion) #'complete+::*do-completion+)
>> (*do-completion "//" :file-name)
>> (*do-completion "c:/data/music/uta" :file-name)
>> (setf (symbol-function '*do-completion) #'complete+::*do-completion-)

|#

