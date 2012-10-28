$ readme.txt 2006-07-27 $

  psearch for xyzzy

  by FUKAE Mitsuaki


■概要

  popup-list を使って検索を行います。


■はじめに

  これを使ってなんか問題が起きても責任は負えませんのでご了承ください。


■インストール

  1. psearch.l を xyzzy/site-lisp 以下においてバイトコンパイルします。

  2. .xyzzy か、siteinit.l に以下のコードを付け加えます。
     使いやすいように適当に編集してください。

    (require "psearch")
    (global-set-key #\C-] 'psearch-popup-string-list)
    (global-set-key #\M-] 'psearch-popup-list-again)
    (global-set-key #\C-: 'psearch-popup-string-list-word-search)
    (global-set-key #\M-: 'psearch-popup-list-again-word-search)
    (global-set-key #\C-M-] 'psearch-goto-return-point)

    (setq *psearch-string-synchronization* t)
    と設定すると M-](M-:)では、C-](C-:) で
    最後に検索された語(= ed::*psearch-last-search-string*)ではなく、
    最後に検索された語(= ed::*last-search-string*) が再検索されるようになります。

    (global-set-key '(#\C-c #\:) 'psearch-popup-list-again-regexp)
    と設定すると C-c : で 最後に検索された正規表現(= ed::*last-search-regexp*)
    を再検索するようになります。

    (setq *psearch-coloring* t)
    (global-set-key '(#\C-c #\]) 'psearch-delete-attributes)
    (add-hook '*show-match-hook* 'psearch-coloring)
    と設定すると、マッチしたものに色付けするようになります。
    また色を消したい時は C-c ] とします。

    インクリメンタルサーチ使用時に C-], C-: を使う時は、下のコードを加えてくだ
    さい。

    (define-key *isearch-map* #\C-] 'psearch-popup-string-list-isearch)
    (define-key *isearch-map* #\C-: 'psearch-popup-string-list-word-search-isearch)


■使い方

  検索したい語の上で、C-] と押します。
  範囲を自分で指定して検索したい場合は、セレクションを指定してC-] とするか
  リージョンを指定して C-u C-] としてください。
  また、M-] とすると C-](C-:) で最後に検索された語を再検索します。

  C-:, M-: では単語単位の検索を行います。

  C-M-] で C-](C-:)したポイント位置に戻ります。


■更新履歴

  06/07/27
  isearch 用の設定を変更。
  その他、細かい修正。

  06/03/08
  C-:(M-:) で単語単位で検索するようにした。
  色づけるオプションを加えた。
  psearch-popup-list-again-regexp, *psearch-string-synchronization*,
  *psearch-hook* を追加。
  それに伴う設定の変更。
  ライセンスを適用。
  その他、細かい修正。

  05/08/21
  細かい修正。

  05/08/05
  C-u C-] でリージョンを検索するようにした。
  その他、細かい修正。

  05/03/05
  M-] を *psearch-string* を捜すよう元に戻した。
  その他、細かい修正。

  05/01/15
  M-] で *last-search-string* を捜すように変えた。
  dsearch.l をまねて検索語、ヒット数をmessageで表示するようにした。
  その他、細かい修正。

  04/12/09
  *psearch-word-search* をなくした。その他、細かい修正。

  04/03/25
  psearch-popup-dabbrev-list(C-:), psearch-popup-list-last(M-:), psearch-mbuf
  を削除。

  03/03/29
  「行番号は表示行」のチェックを外した状態の時に 行の最初の文字列ではなく
  表示行の最初の文字列にヒットするように修正。
  関数の名前変更 (そのため以前の設定では動かなくなりました。すみません。) 。
  psearch-popup-list-mbuf を追加。
  その他、細かい修正。

  03/03/22
  「行番号は表示行」のチェックを外した状態の時に行番号が正しく表示されない
  のを修正。

  03/03/09
  make-psearch-list が interactive になっていたのを修正。
  インクリメンタルサーチ使用時に C-] を使う設定を増やした。

  03/02/26
  M-] の動作を変更。
  C-] の selection のあるときへの対応。
  M-: で ed::*last-search-string* の検索結果を popup。
  インクリメンタルサーチ使用時に C-] を使う設定の追加。
  その他、細かい修正。

  03/02/03
  historyをとる機能削除。
  その他、細かい修正。

  02/10/23 
  高速化、動的補完を経ずに検索(#\C-])、history(#\C-x #\: #\h)。

  02/10/02 公開。


■ライセンス

  修正BSDライセンスとします。同梱の LICENSE.txt を参照ください。


■謝辞

  これを作成するにあたり、
  
  ・XYZZY の dabbrev.l, search.l(亀井さん)
      http://www.jsdlab.co.jp/~kamei/
  ・dsearch.l(matsushita さん)
      http://homepage2.nifty.com/kimagurenixyzzy/dsearch.html
  ・pickup-pattern.l(OHKUBO さん)
      http://ohkubo.s53.xrea.com/xyzzy/index.html
  
  を参考にさせていただきました。
  またいろいろな方々にご協力を頂きました。
  あらためて感謝のお礼を申し上げます。
