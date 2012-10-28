 GHCi mode for xyzzy Ver 0.1 alpha
 	by IMAI Takeo <usitukai@osk.3web.ne.jp>
	2006/05/06

■ はじめに
o    - 何が起こっても責任もてません
    - GHC 6.4.1 で動作を確認しています。

■ これは

     Haskellコンパイラ GHC (http://www.haskell.org/ghc/) のインタプリタ版
　　であるGHCiを、xyzzy上で起動して、ファイルをロードして…とかやるための
    マイナーモード。

     キーワードのハイライト表示やオートインデントまではしません。
     紫藤さんとこ (http://www.geocities.jp/shido_takafumi/index.html) の
    hs-mode 等との併用をお勧めします。

■ インストール

    1. $XYZZY/site-lisp 以下に ghci.l をおく

    2. .xyzzy もしくは site-init.l に設定を書く
      次のように書くと、.hs という拡張子のファイルを読み込んだときに、
      hs-mode と ghci-mode を同時起動できます。

	(load-library "hs-mode")
	(load-library "ghci")
	(push '("\\.hs$" . (lambda ()
		     (hs-mode)
		     (ghci-mode))) *auto-mode-alist*)

       また、デフォルトでは "ghci" というコマンドで起動しますので、ghci 
     へのパスをPATH環境変数に設定しておくか、あるいは

        (setq editor::*ghci-command* "c:/hogehoge/ghci")

     などのように、フルパスを変数 *ghci-command* に設定してください。
     コマンドラインオプションを与える場合も同様に。

    ※裏技として、ここに hugs のパスを書いてみると、hugs でも動作するっぽいです。


    3. xyzzyを再起動


■ 操作方法
  ＜通常画面＞
    C-c l	GHCi起動＋ファイルロード
		すでにGHCiが起動している場合は、ファイルをリロードします。
    C-c q	GHCi終了

  ＜GHCi起動画面＞
    GHCi上の操作・コマンドがそのまま利用できます（たぶん）。


■ TODOというか
- 強制的に起動しなおすコマンド
- ghc のコンパイラ側起動


■ 利用許諾
    このソフトウェアは修正BSDスタイルライセンスで提供しています。
    詳しくは license.txt を参考のこと。


以上
