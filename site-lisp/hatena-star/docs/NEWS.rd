=begin

=== 2008-07-12 / 1.1.1

hatena-star 1.1.1 リリース!

: 新規機能

    * なし

: 非互換を含む変更点

    * なし

: バグ修正

    * なし

: その他

    * ライセンスファイルを同梱


=== 2008-03-09 / 1.1.0

hatena-star 1.1.0 リリース!

: 新規機能

    * hatena-star-delete-star に :star キーワード引数を追加

    * 以下の関数で permalink を指定するところは entry も指定できるようにした
      * hatena-star-get-entry
      * hatena-star-add-star
      * hatena-star-add-comment
      * hatena-star-deletable-p
      * hatena-star-delete-star

    * ui 作成支援 API を追加
      * *hatena-star-default-star-char*
      * *hatena-star-default-star-color*
      * *hatena-star-inner-count-min*
      * hatena-star-make-stars-string
      * hatena-star-stars-to-string
      * hatena-star-stars-insert

: 非互換を含む変更点

    * RKS が nil の場合 type-error を通知するようにした

: バグ修正

    * なし

: その他

    * 独自の User-Agent を設定するようにした


=== 2008-03-03 / 1.0.3 / ひなまつり

hatena-star 1.0.3 リリース!

: 新規機能

    * hatena-star-stars-by-user を追加。
      ☆リストをユーザごとに集約します。

: 非互換を含む変更点

    * なし

: バグ修正

    * 引用文に + が含まれる場合、+ が空白文字になってしまう問題を修正。


=== 2008-02-24 / 1.0.2

hatena-star 1.0.2 リリース!

: 新規機能

    * なし

: 非互換を含む変更点

    * なし

: バグ修正

    * 星の省略が変な形式になる場合があるのに対応。

      普通は (("naoya" "hoge") 10 ("jkondo" "hoge")) となるが、
      最初の☆がない場合 (10 ("jkondo" "")) があった。


=== 2008-02-23 / 1.0.1

hatena-star 1.0.1 リリース!

: 新規機能

    * json 0.1.1 に対応

    * 各リクエスト関数に nomsg キーワード引数を追加。

      * nomsg に non-nil を指定するとメッセージを出力しません。

: 非互換を含む変更点

    * なし

: バグ修正

    * なし


=== 2008-02-17 / 1.0.0

hatena-star 1.0.0 リリース!

: 新規機能

    * json-syck を捨てたので高速かつ安全になりました。

    * get 系の関数に If-Modified-Since を指定できるように since 引数を追加。
      * hatena-star-get-blog
      * hatena-star-get-entries
      * hatena-star-get-entry

    * 引用文やコメント本文がない場合、空文字列ではなく nil を返すようにした。

: 非互換を含む変更点

    * なし

: バグ修正

    * なし

=== 2008-02-11 / 0.1.0 / 建国記念の日

hatena-star 0.1.0 リリース!

このリリースは人柱er 向けプレビューです (ときどき xyzzy がクラッシュするので)。

=end
