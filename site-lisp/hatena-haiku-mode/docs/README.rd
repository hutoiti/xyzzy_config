= hatena-haiku-mode - はてなハイク専用ブラウザ

  * Author: みやむこ かつゆき ((<URL:mailto:miyamuko@gmail.com>))
  * Home URL: ((<URL:http://miyamuko.s56.xrea.com/xyzzy/hatena-haiku-mode/intro.htm>))
  * Version: 0.3.2


== SYNOPSIS

  M-x haiku-recent-entries-pane       ; 最近の Entries

  M-x haiku-my-entries-pane           ; 自分の Entries
  M-x haiku-my-following-pane         ; 自分の Following
  M-x haiku-my-profile-pane           ; 自分の Profile

  M-x haiku-user-entries-pane         ; あるユーザの Entries
  M-x haiku-user-following-pane       ; あるユーザの Following
  M-x haiku-user-profile-pane         ; あるユーザの Profile

  M-x haiku-keyword-entries-pane      ; あるキーワードの Entries

  M-x haiku-keyword-list-pane         ; キーワードの一覧

  M-x haiku-show-new-entry-pane       ; バッファを開いて投稿
  M-x haiku-post-minibuffer           ; ミニバッファから投稿
  C-u M-x haiku-post-minibuffer       ; 投稿元のクライアント (from) を指定してミニバッファから投稿

  M-x haiku-show                      ; z で一時的に隠したハイクバッファを再表示


== DESCRIPTION

hatena-haiku-mode は ((<"はてなハイク"|URL:http://h.hatena.ne.jp/>)) を
xyzzy 上で閲覧・投稿するための専用ブラウザです。

以下のことができます。

  * 最近のエントリの表示
  * ユーザエントリの表示
  * キーワードエントリの表示
  * キーワード一覧の表示
  * キーワードの検索
  * 新規投稿
  * 返信
  * ブラウザの履歴みたいに戻る・進む
  * 更新
  * はてなスター
  * ホットキーワード
  * エントリの削除
  * 投稿元のクライアントの変更 (デフォルトは hatena-haiku-mode)

以下はまだできません。

  * 返信を展開
  * その他いろいろ...


== INSTALL

((<NetInstaller|URL:http://www7a.biglobe.ne.jp/~hat/xyzzy/ni.html>)) でインストールした場合は 3 以降を、
NetInstaller + ni-autoload を使っている人は 4 以降で OK です。

(1) アーカイブをダウンロードします。

    ((<URL:http://miyamuko.s56.xrea.com/xyzzy/archives/hatena-haiku-mode.zip>))

(2) アーカイブを展開して、$XYZZY/site-lisp 配下にファイルをコピーします。

(3) ~/.xyzzy または $XYZZY/site-lisp/siteinit.l に以下のコードを追加します。

        ;; hatena-haiku-mode
        (require "hatena-haiku-mode")

(4) 設定を反映させるため xyzzy を再起動してください。

    ※siteinit.l に記述した場合には再ダンプが必要です。

(5) M-x haiku-recent-entries-pane で起動します。


== DEPENDS

hatena-haiku-mode は以下のライブラリに依存しています。

  * ((<"xml-http-request"|URL:http://miyamuko.s56.xrea.com/xyzzy/xml-http-request/intro.htm>))
    1.1.1 以上
  * ((<"hatena-star"|URL:http://miyamuko.s56.xrea.com/xyzzy/hatena-star/intro.htm>))
    1.1.0 以上
  * ((<"json"|URL:http://miyamuko.s56.xrea.com/xyzzy/json/intro.htm>))
    0.1.1 以上


== KEYBIND

=== バッファ共通 (投稿バッファを除く)

  /                   キーワードの検索
  q                   はてなハイクモードを終了
  z                   ハイクバッファを一時的に隠す (ボスが来た)

  T                   最新エントリー (Recent Entries) を表示
  M                   自分の Following ページを表示
  L                   キーワードリストを表示
  H                   ホットキーワードを表示

  SPC                 次のページへ移動 (ページ自動読み込み付き)

  C-h                 戻る (BackSpace)
  ESC Left            戻る (Alt ←)
  ESC Right           進む (Alt →)

  F5                  最新に更新
  S-F5                全更新

=== キーワードリストバッファ

  j                   次のキーワードへ移動 (ページ自動読み込み付き)
  k                   前のキーワードへ移動 (ページ自動読み込み付き)
  C-n                 次の行へ移動 (ページ自動読み込み付き)
  C-v                 次のページへ移動 (ページ自動読み込み付き)

  RET                 カーソル下のキーワードを表示
  t                   同上
  v                   カーソル下のキーワードをブラウザで表示

=== エントリ一覧バッファ

  E                   Entries ページを表示 (ユーザエントリのみ)
  F                   Following ページを表示 (ユーザエントリのみ)
  P                   Profile ページを表示 (ユーザエントリのみ)

  K                   エントリのキーワードの一覧の表示・非表示をトグル
  U                   エントリのユーザの一覧の表示・非表示をトグル

  N                   新規投稿バッファを開く
  R                   カーソル下のエントリへの返信バッファを開く
  S                   カーソル下のエントリに☆を付ける
  D                   カーソル下のエントリを削除

  j                   次のエントリへ移動 (ページ自動読み込み付き)
  k                   前のエントリへ移動 (ページ自動読み込み付き)
  C-n                 次の行へ移動 (ページ自動読み込み付き)
  C-v                 次のページへ移動 (ページ自動読み込み付き)

  RET                 カーソル下のエントリのキーワードを表示
  t                   同上
  u                   カーソル下のエントリのユーザを表示
  v                   カーソル下のエントリをブラウザで表示

  h G                 カーソル下のユーザのはてなグラフを表示
  h a                 同はてなアンテナ
  h b                 同はてなブックマーク
  h d                 同はてなダイアリ
  h f                 同はてなフォトライフ
  h g                 同はてなグループ
  h h                 同はてなハイク
  h i                 同はてなアイデア
  h m                 同はてなマップ
  h q                 同はてなクエスチョン
  h r                 同はてな RSS
  h s                 同はてなスター
  h w                 同はてなワールド

=== エントリのユーザ一覧バッファ

  j                   次のユーザへ移動
  k                   前のユーザへ移動

  RET                 カーソル下のエントリのユーザを表示
  u                   同上
  t                   カーソル下のエントリのキーワードを表示 (キーワードページのみ)
  v                   カーソル下のエントリのユーザをブラウザで表示

  h G                 カーソル下のユーザのはてなグラフを表示
  h a                 同はてなアンテナ
  h b                 同はてなブックマーク
  h d                 同はてなダイアリ
  h f                 同はてなフォトライフ
  h g                 同はてなグループ
  h h                 同はてなハイク
  h i                 同はてなアイデア
  h m                 同はてなマップ
  h q                 同はてなクエスチョン
  h r                 同はてな RSS
  h s                 同はてなスター
  h w                 同はてなワールド

=== エントリのキーワード一覧バッファ

  j                   次のキーワードへ移動
  k                   前のキーワードへ移動

  RET                 カーソル下のエントリのキーワードを表示
  t                   同上
  v                   カーソル下のエントリのキーワードをブラウザで表示

=== 新規投稿・返信バッファ

  C-c C-c            投稿する
  C-u C-c C-c        投稿元のクライアント (from) を指定して投稿する
  C-x k              閉じる


== MODULE

=== PACKAGE

hatena-haiku-mode は以下のパッケージを利用しています。

  * hatena-haiku.util
  * hatena-haiku.api
  * hatena-haiku.ui

=== EXPORT

hatena-haiku-mode は以下のシンボルを export しています。

  * hatena-haiku.ui パッケージ

    * SYNOPSIS 見て

  * hatena-haiku.api パッケージ

    * いろいろ

  * hatena-haiku.util パッケージ

    * 内部パッケージなので省略


=== VARIABLE

--- *haiku-default-source*

    投稿元のクライアント (from 欄) を設定します。
    デフォルトは hatena-haiku-mode です。

    前置引数を指定することで投稿時にも変更できます (C-u C-c C-c)。

--- *haiku-post-buffer-height-ratio*

    投稿バッファの高さの比率を 0 ～ 1 で指定します。
    デフォルトは 0.3 (= 全体の 30% の高さ) です。

--- *haiku-disable-color*

    non-nil なら色づけを一切しません。

--- *haiku-page-title-color*

    エントリページのタイトルの色を指定します。
    色の指定方法は set-text-attribute のリファレンスを参照してください。

      ;; 青反転
      (setf *haiku-page-title-color* '(:bold t :foreground 7 :background 12))

--- *haiku-page-subtitle-color*

    エントリページのサブタイトルの色を指定します。

--- *haiku-entry-title-color*

    エントリのタイトルの色を指定します。

--- *haiku-entry-meta-color*

    エントリのユーザ情報などの色を指定します。

--- *haiku-entry-meta-text-color*

    エントリのユーザ情報部分のテキストの色を指定します。

--- *haiku-star-color*

    ☆の色を指定します。

--- *haiku-keyword-color*

    キーワード一覧でのキーワードの色を指定します。

--- *haiku-user-color*

    ユーザ一覧でのユーザ名の色を指定します。

--- *haiku-post-title-color*

    投稿バッファでのタイトルの色を指定します。

--- *haiku-post-description-color*

    投稿バッファでの説明の色を指定します。

--- *haiku-hot-keyword-color-list*

    hot keyword の色をリストで指定します。

    hot keyword はキーワードのホット度(?)に応じて 1 ～ 7 の数値を持っています。
    7 が一番ホットなキーワードです。

    *haiku-hot-keyword-color-list* には
    ホット度に対応する色を 1 ～ 7 の順に指定します。

        (setf *haiku-hot-keyword-color-list*
          '((:foreground 15)                      ; ホット度が 1 (クールな話題)
            (:foreground 14)                      ; ホット度が 2
            (:foreground 10)                      ; ホット度が 3
            (:foreground 10)                      ; ホット度が 4
            (:foreground 10 :bold t)              ; ホット度が 5
            (:foreground 10 :bold t)              ; ホット度が 6
            (:foreground 10 :bold t :underline t) ; ホット度が 7 (一番熱い話題)
            ))

    個別に設定したい場合は
    ((<haiku-set-hot-keyword-color|hatena-haiku.ui:haiku-set-hot-keyword-color CLOUD &REST COLOR>))
    を利用します。


=== COMMAND

あとでね。


=== FUNCTION

--- hatena-haiku.ui:haiku-set-hot-keyword-color CLOUD &REST COLOR

    ホットキーワードの色をホット度ごとに設定します。
    以下で設定したい場合は((<*haiku-hot-keyword-color-list*>)) に直接設定してください。

        ;; 一番ホットな話題は緑反転にする
        (haiku-set-hot-keyword-color 7 :bold t :foreground 7 :background 10)

--- hatena-haiku.api:hatena-haiku-mode-version

    hatena-haiku-mode のバージョンを返します。


== TODO

* はいくバッファを隠しバッファにする設定
* 新着順
* 人気順
* ヒストリに全部保存
* login
* Reply 展開
* reply link
* auto reload
* star
  * popup star comment
  * star comment view
* 非同期
  * 通信中の modeline の表示
* buffer-modified
  * F5 すると modified
  * 読むと not modified
* hook
  * エントリのフィルタhook
    * NG user, NG word
  * 各バッファの hook
* ロード処理の見直し
  * keyword-list, entry での処理の統一
  * カーソル移動系すべてでロード
  * 非同期
  * 重複の排除
* エントリをコピー, kill
* 統計情報
  * 読んだキーワード数
  * 時間
    * 1分間操作が無かったらタイマ停止
    * csv 出力
    * hatena graph
  * 作成したキーワード
  * 投稿したキーワード
* keyword-list 一覧 API で根こそぎ取得
* 投稿
  * id:自分のページにメモ
  * 特定のページにメモ
  * キーワードページ以外では投稿時にカーソル下のエントリのタイトルを自動挿入
  * 自動的に空行にスペースを一個入れる

* リンクのプレビュー
  * JaneStyle みたいに
  * 画像、YouTube
* アイコンプレビュー
* はてな記法リンク
* お絵かき
* 既読判定
  * qdbm? sexp?
* 新着通知
  * dialog
  * menu (livedoor-reader-notifier のように)
  * niconico
* offline mode
* お気に入り
  * スレッド・発言
  * 巡回
* ダイアリを開く
* 縦置きでながらハイクモード
  * 自動ロード
* マウスクリック
* 逆順表示(下が新しい)
  * ページ数はキーワード一覧から分かる
  * ダイレクトで表示されたら困る
* はてな☆ページにあるような「◯◯さんのサイト一覧」
* permalink
  * pin
  * tumblr
  * hatebu
  * plaggable にする


== KNOWN BUGS

* F5 で更新した後に次のページをロードするとエントリが重複するかも


== AUTHOR

みやむこ かつゆき (((<URL:mailto:miyamuko@gmail.com>)))


== SEE ALSO

  : はてなハイク
        ((<URL:http://h.hatena.ne.jp/>))


== COPYRIGHT

hatena-haiku-mode は MIT/X ライセンスに従って本ソフトウェアを使用、再配布することができます。

See hatena-haiku-mode/docs/MIT-LICENSE for full license.


== NEWS

<<<NEWS.rd
