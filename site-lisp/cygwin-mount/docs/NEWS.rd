=begin

=== 2008-07-12 / 1.1.0

cygwin-mount 1.1.0 リリース!

: 新規機能

    * (cygmount-point-info): path 引数で mount 情報を取得するパスを指定できるようにした

: 非互換を含む変更点

    * なし

: バグ修正

    * なし

: その他

    * ライセンスファイルを同梱


=== 2008-05-31 / 1.0.0

cygwin-mount 1.0.0 リリース!


: 新規機能

    * (cygmount-winpath->cygpath): Windows のパスを Cygwin のパスに変換

    * (cygmount-cygpath->winpath): Cygwin のパスを Windows のパスに変換

    * (cygmount-point-info): Cygwin のマウント情報のリストを取得

    * (cygwin-mount-active-p): cygwin-mount がアクティブかどうかを返す

    * (cygwin-mount-toggle): cygwin-mount の有効・無効をトグル

    * (cygwin-mount-show-mount-point): cygwin のマウント情報を表示

    * (cygwin-mount:cygdrive-prefix): cygdrive prefix を返す

    * マウントフラグも取得するようにした

    * cygwin-mount package を導入・ソースを整理

: 非互換を含む変更点

    * マウント情報をキャッシュするのをやめた

: バグ修正

    * ユーザごとのマウント情報 (mount --user) に対応

    * (ed::cygwin-mount-table) を実行しないと動かなかったのを修正

    * /usr/lib2 が c:\cygwin\lib\2 になってしまう問題を修正
      (本来は c:\cygwin\usr\lib2)

: その他

    * ライセンスを修正 BSD から MIT/X に変更


=== 2005-12-02 / 0.0.1

cygwin-mount 0.0.1 リリース!

=end
