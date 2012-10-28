= cygwin-mount - Cygwin のパスを指定してファイルを開く

  * Author: みやむこ かつゆき ((<URL:mailto:miyamuko@gmail.com>))
  * Home URL: ((<URL:http://miyamuko.s56.xrea.com/xyzzy/cygwin-mount/intro.htm>))
  * Version: 1.1.0


== DESCRIPTION

Cygwin のマウント情報を解釈してファイル名を変換します。
find-file やコマンドライン引数に cygwin のパスを指定して xyzzy でファイルを開くことができます。


== INSTALL

=== NetInstaller でインストール

(1) ((<NetInstaller|URL:http://www7a.biglobe.ne.jp/~hat/xyzzy/ni.html>))
    で cygwin-mount をインストールします。

(2) ((*ni-autoload を利用していない場合*)) は、
    ~/.xyzzy または $XYZZY/site-lisp/siteinit.l に以下のコードを追加します。

        ;; cygwin-mount
        (require "cygwin-mount")
        (cygwin-mount-activate)

    ※ ni-autoload を利用している場合は設定は不要です。

(3) 設定を反映させるため xyzzy を再起動してください。

    ※siteinit.l に記述した場合には再ダンプが必要です。


=== NetInstaller を使わずにインストール

(1) アーカイブをダウンロードします。

    ((<URL:http://miyamuko.s56.xrea.com/xyzzy/archives/cygwin-mount.zip>))

(2) アーカイブを展開して、$XYZZY/site-lisp 配下にファイルをコピーします。

(3) ~/.xyzzy または $XYZZY/site-lisp/siteinit.l に以下のコードを追加します。

        ;; cygwin-mount
        (require "cygwin-mount")
        (cygwin-mount-activate)

(4) 設定を反映させるため xyzzy を再起動してください。

    ※siteinit.l に記述した場合には再ダンプが必要です。


== MODULE

=== PACKAGE

cygwin-mount は以下のパッケージを利用しています。

  * editor
  * cygwin-mount
    * nickname は cygmount

=== VARIABLE

--- cygwin-mount:*cygwin-mount-reg-section*

    cygwin のマウント情報が記録されているレジストリのキー名を指定します。
    デフォルトは SOFTWARE\Cygnus Solutions\Cygwin\mounts v2 です。


=== COMMAND

--- editor:cygwin-mount-activate

    ファイルを開くときに cygwin のパスを自動的に Windows のパスに読み替えるように
    設定します。

    これで cygwin のパスを指定してファイルを開くことができます。

    (詳しい説明: *before-find-file-hook* に
    ed::cygwin-mount-before-find-file-hook を追加します。)

--- editor:cygwin-mount-deactivate

    ファイルを開くときに cygwin のパスを変換しないようにします。

--- editor:cygwin-mount-toggle

    cygwin のパス変換の有効・無効を切り替えます。

--- editor:cygwin-mount-show-mount-point

    cygwin のマウント情報を表示します。

=== FUNCTION

--- editor:cygwin-mount-active-p

    ファイルを開くときに cygwin のパスを変換する場合 non-nil を返します。

--- cygwin-mount:cygdrive-prefix

    cygdrive prefix を返します。

        (cygwin-mount:cygdrive-prefix)
        ;;=> "/cygdrive"

--- cygwin-mount:cygmount-cygpath->winpath CYGPATH

    Cygwin のパスを Windows のパスに変換します。

        (cygwin-mount:cygmount-cygpath->winpath "/bin/cygwin1.dll")
        ;;=> "c:\cygwin\bin\cygwin1.dll"

        (cygwin-mount:cygmount-cygpath->winpath "/cygdrive/c/Windows")
        ;;=> "c:\Windows"

--- cygwin-mount:cygmount-winpath->cygpath WINPATH

    Windows のパスを Cygwin のパスに変換します。

        (cygwin-mount:cygmount-winpath->cygpath "c:\\Windows")
        ;;=> "/cygdrive/c/Windows"

        (cygwin-mount:cygmount-winpath->cygpath "c:\\Cygwin\\bin")
        ;;=> "/usr/bin"

--- cygwin-mount:cygmount-point-info &KEY TYPE PATH

    Cygwin のマウント情報のリストを取得します。

      (cygmount::cygmount-point-info :type :system)
      ;;=> (("/usr/lib" "C:\\cygwin\\lib" 10 :system)
      ;;    ("/usr/bin" "C:\\cygwin\\bin" 10 :system)
      ;;    ("/" "C:\\cygwin" 10 :system))

    引数の TYPE には :system か :user を指定します。

      * :system を指定すると system wide なマウント情報を取得します。
      * :user を指定すると user only なマウント情報を取得します。
      * 指定しない場合は両方のマウント情報を返します。

    PATH を指定するとそのパスに関連するマウント情報だけを返します。

      (cygmount::cygmount-point-info :type :system :path "/usr/bin")
      ;;=> (("/usr/bin" "C:\\cygwin\\bin" 10 :system)
      ;;    ("/" "C:\\cygwin" 10 :system))

--- cygwin-mount:cygmount-point-cygpath MOUNT-INFO

    ((<cygmount-point-info|cygwin-mount:cygmount-point-info &KEY TYPE PATH>))
    で取得したマウント情報から Cygwin のパスを取得します。

--- cygwin-mount:cygmount-point-winpath MOUNT-INFO

    ((<cygmount-point-info|cygwin-mount:cygmount-point-info &KEY TYPE PATH>))
    で取得したマウント情報から Windows のパスを取得します。

--- cygwin-mount:cygmount-point-flags MOUNT-INFO

    ((<cygmount-point-info|cygwin-mount:cygmount-point-info &KEY TYPE PATH>))
    で取得したマウント情報からマウントフラグを取得します。

        (let ((mount-table (cygwin-mount:cygmount-point-info)))
          (cygwin-mount:cygmount-point-flags (car mount-table)))
        ;;=> (:binmode :notexec)

    マウントフラグは以下のキーワードのリストで返します。

      * :textmode
      * :binmode
      * :exec
      * :cygexec
      * :notexec
      * :managed

    フラグの詳細は man mount してください。

--- cygwin-mount:cygmount-point-type MOUNT-INFO

    ((<cygmount-point-info|cygwin-mount:cygmount-point-info &KEY TYPE PATH>))
    で取得したマウント情報からマウントタイプを取得します。

        (let ((mount-table (cygwin-mount:cygmount-point-info)))
          (cygwin-mount:cygmount-point-flags (car mount-table)))
        ;;=> :system

    マウントタイプは :system または :user を返します。

=== OBSOLETE FUNCTION

--- editor:cygwin-mount-resolve cygpath

    Cygwin のパスを Windows のパスに変換します。

    これは互換性のために用意されています。
    代わりに
    ((<cygmount-cygpath->winpath|cygwin-mount:cygmount-cygpath->winpath CYGPATH>))
    を利用してください。


== TODO

* なし


== KNOWN BUGS

* cygwin のパスを指定してもファイルを正しく開けない場合があります。

  コマンドラインからファイルを指定し束愛、xyzzy の *before-find-file-hook*
  に来るまでに勝手にドライブ文字が追加されます。
  そのため、意図しないファイルを開いてしまう可能性があります。

  たとえば、以下のようなディレクトリ構成の場合:

      D:/
       ├ cygwin/
       │ ├ etc/
       │ │ ├ foo
       │ │ └ bar
       │ ├ bin/
       │ └ sbin/
       └ etc
          └ foo

  cygwin での /etc は d:/cygwin/etc にマウントしているとします。

  ここで cygwin から xyzzy /etc/foo として起動した場合、*before-find-file-hook*
  には d:/etc/foo が渡されます。

  本来は d:/cygwin/etc/foo を開きたいところですが、
  cygwin から /etc/foo を指定されたのか、Windows から d:/etc/foo を
  指定されたかは判断できないので、この場合 d:/etc/foo が開かれます。

  一方、cygwin から xyzzy /etc/bar で起動した場合 d:/etc/bar が
  渡されます。しかし、d:/etc/bar は存在しないのでこの場合、
  cygwin-mount ではドライブ文字を削除して /etc/bar が渡されたとみなし
  cygwin のパスを Windows のパスに変換して d:/cygwin/etc/bar を開きます。

  と、このように動作が怪しいのでなるべく cygwin 側で cygpath を使って
  変換した上で xyzzy に渡したほうが確実だと思います。


== AUTHOR

みやむこ かつゆき (((<URL:mailto:miyamuko@gmail.com>)))


== SEE ALSO

: cygwin-mount.el
    ((<URL:http://www.emacswiki.org/elisp/cygwin-mount.el>))

: cygwin-mount-mw32
    ((<URL:http://www4.kcn.ne.jp/~boochang/emacs/elisp.html>))


== COPYRIGHT

cygwin-mount は MIT/X ライセンスに従って本ソフトウェアを使用、再配布することができます。

See cygwin-mount/docs/MIT-LICENSE for full license.


== NEWS

<<<NEWS.rd
