$ readme.txt 2006-07-27 $

  restore for xyzzy

  by FUKAE Mitsuaki


■概要

  ポイント、色づけ、グローバルマークを保存するバッファを "表示(V)" メニューから
  指定できるようにします。


■はじめに

  これを使ってなんか問題が起きても責任は負えませんのでご了承ください。


■インストール

  1. restore.l を xyzzy/site-lisp 以下においてバイトコンパイルします。

  2. .xyzzy か、siteinit.l に以下のコードを付け加えます。

    (require "restore")
    (setq *restore-directory* "~/restore")

    また *restore-exceptional-tag-list* で指定されたタグの色づけは保存されなくな
    ります。
    例. (setq *restore-exceptional-tag-list* '(ed::paren))


■使い方

  "表示(V)" メニューに追加された "リストア(R)" をチェックすると
  現在のバッファに対して ポイント、色づけ、グローバルマークを保存するようになり
  ます。また、チェックを外すと保存されなくなります。


■更新履歴

  06/07/27 公開。


■ライセンス

  修正BSDライセンスとします。同梱の LICENSE.txt を参照ください。


■謝辞

  これを作成するにあたり、
  ・[xyzzy:05281]（山本 真二さん)
      http://hie.s64.xrea.com/xyzzy/ml/msg05280.html
  ・XYZZY の backup.l, session.l(亀井さん)
      http://www.jsdlab.co.jp/~kamei/
  
  を参考にさせていただきました。
  またいろいろな方々にご協力を頂きました。
  あらためて感謝のお礼を申し上げます。
