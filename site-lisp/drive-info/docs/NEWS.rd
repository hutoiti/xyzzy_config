=begin

=== 2007-06-02 / 1.1.0

drive-info 1.1.0 リリース!

: 新規機能

    * 以下の関数を追加。
      * drive-info.api:drive-info-version
      * drive-info.api:drive-info-api-version

: 非互換を含む変更点

    * *drive-info-version* を export するのをやめました。

    * パッケージ名の変更

      * drive-info → drive-info.api
      * drive-info-ffi → drive-info.ffi

    * ファイル構成を変更

: バグ修正

    * drive-info を require したあとに api を require すると
      エラーが出ていたのを修正。

: その他

    * editor パッケージに依存しないようにした。


=== 2007-01-12 / 1.0.0

drive-info 1.0.0 リリース!


=end
