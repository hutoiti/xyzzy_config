;;;
;;;  winbatch-mode.l
;;;      Simple mode for Batch File Enhancer for Windows (WinBatchEh)
;;;

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
■ はじめに
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

これは、xyzzy で動作する WinBatchEh 用のモードです。 OHKUBO 
Hiroshi さんの bat-mode.l を始め、多くの方々のコードを参考にさ
せていただきました。感謝。

WinBatchEh および WBATCP は、清水 洋平さんのページ
(http://hp.vector.co.jp/authors/VA000007/) から別途入手下さい。
なくても動きますが、当然スクリプトの実行はできません。


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
■ はじめて xyzzy をつかわれる方へ
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

────────────────
● xyzzy のインストール
────────────────

とりあえず使うのであれば、以下の手順で良いと思います。

xyzzy からスクリプトを実行する場合は、あらかじめ .btw の関連付
けを行っておいて下さい。

  1. 亀井さんのページ (http://www.jsdlab.co.jp/~kamei/) から   
     xyzzy をダウンロードする。
  
  2. 適当なフォルダに xyzzy-version.lzh を展開する。
  
  3. 環境変数 XYZZYHOME にインストールしたフォルダを設定する。
  
     Win98 の場合、C:\AUTOEXEC.BAT に、以下の行を追加する。
  
       set XYZZYHOME=C:\utility\xyzzy
       (C:\utility\xyzzy にインストールした場合)
       
     WinNT の場合、コントロールパネル→「システム」→「環境」
     で設定。
     
     Win2k の場合、コントロールパネル→「システム」→「詳細」
     →「環境変数」で設定。

詳しくは、Toy さんのページ (http://www.carabiner-systems.com/xyzzy/) 
などを参考にして下さい。


────────────────
● winbatch-mode のインストール
────────────────

  1. winbatch-mode.l を ~/site-lisp に、WINBATCH を ~/etc に
     コピーする。
     
     xyzzy を c:\utility\xyzzy にインストールした場合は、
     
       winbatch-mode.l → c:\utility\xyzzy\site-lisp
       WINBATCH        → c:\utility\xyzzy\etc
       
     にコピーする。

  2. xyzzy をインストールしたフォルダに .xyzzy というファイル
     を以下の内容で作成する。(注)
       
       ;;; -*- Mode: Lisp -*-
       
       ;; winbatch-mode
       (export 'ed::winbatch-mode "ed")
       (autoload 'winbatch-mode "winbatch-mode" t)
       (pushnew '("\\.btw$" . winbatch-mode) *auto-mode-alist* :test 'equal)
       
       ;; 補完をポップアップ一覧表示
       (setq *popup-completion-list-default* :always)
  
  3. xyzzy を再起動する。
  
  (注) Explorer からは、.xyzzy というファイルを作成することは
  できないため、手慣らしに xyzzy から作成すると良いかも。

拡張子 .btw を winbat32.exe に関連付けしてない場合、もしくは、
winbatch-mode からスクリプトの起動ができない場合は、.xyzzy に、
以下の記述も追加して下さい。

以下は、c:\utility\winbatch\ にインストールしてある場合

       ;; WinBatchEh のインストールディレクトリ
       (setq ed::*winbatch-path* "c:/utility/winbatch/")


────────────────
● winbatch-mode の使い方
────────────────

拡張子が、.btw なファイルを xyzzy で開くと、自動的に 
winbatch-mode が起動します。

自分で意図的に winbatch-mode にしたい場合は、

  1. Esc x  （すると下に M-x: と表示されます）
  2. winbatch-mode と入力し、Enter

で winbatch-mode になります。

必要な操作は、とりあえず WinBatchEh(B) メニューから行って下さい。


────────────────
● xyzzy のカスタマイズ
────────────────

xyzzy は、Emacs ライクなキーバインドなので、つかい慣れない方は、
.xyzzy 以下を追記することにより、Windows 風なキーバインドにす
ることができます。

  (load-library "Gates")

ただし、この設定をすると、xyzzy で使える多くの便利なキーがつぶ
れてしまうため、C-c, C-x, C-v, C-z のみ Windows 風にするための
以下のような設定をすることができます。（こちらのほうがおススメ）

  (load-library "winkey")

この設定では、セレクションがあれば（マウスなどでハイライト表示
された部分がある状態）C-c でコピー、C-x で切り取りとなります。


────────────────
● その他
────────────────

その他の情報については、winbatch-mode.l のコメントなどをを参照
下さい。



━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HIE Masahiro <madoinu@ybb.ne.jp>
