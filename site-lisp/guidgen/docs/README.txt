= guidgen - GUID を生成するライブラリとツール

  * Author: MIYAMUKO Katsuyuki ((<URL:mailto:miyamuko (at) gmail.com>))
  * URL: ((<URL:http://miyamuko.s56.xrea.com/xyzzy/guidgen.html>))
  * Version: 1.0.0


== SYNOPSIS

  * ライブラリ

      (require "guidgen")

      (let ((guid (guidgen:guidgen)))
        (msgbox "GUID: ~A" guid))

      (let ((guid (guidgen:guidgen :downcase t)))
        (msgbox "GUID: ~A" guid))

      (use-package :guidgen)
      (multiple-value-bind (guid-str guid-list)
          (guidgen :downcase t)
        (msgbox "GUID: ~A (~{#x~x ~})" guid-str guid-list))

  * フロントエンド

      M-x guidgen-copy-to-clipboard
      M-x guidgen-copy-to-kill-ring

      M-x guidgen-insert
      M-x guidgen-replace
      M-x guidgen-replace-or-insert

      M-x guidgen-insert-implement-olecreate
      M-x guidgen-insert-define-guid
      M-x guidgen-insert-static-const-guid
      M-x guidgen-insert-registry
      M-x guidgen-insert-urn

      M-x guidgen-track-popup-menu
      M-x guidgen-setup-app-menu
      M-x guidgen-setup-app-popup-menu
      M-x guidgen-remove-app-menu
      M-x guidgen-remove-app-popup-menu


== DESCRIPTION

guidgen は GUID を生成するためのツールです。
Microsoft の guidgen.exe と同じアルゴリズム (というか CoCreateGuid) で GUID を生成します。

guidgen は以下の形式で GUID を生成することができます。

  * IMPLEMENT_OLECREATE マクロ
  * DEFINE_GUID マクロ
  * static const GUID
  * レジストリ形式 ({xxxxxxxx-...})
  * urn 形式 (urn:uuid:xxxxxxxx-...)
  * 無変換 (xxxxxxxx-...)

また、前置引数に対応しているので GUID を大量に生成することも可能です。

    C-u M-x guidgen-insert
    C-u M-x guidgen-insert-implement-olecreate
    C-u M-x guidgen-insert-define-guid
    C-u M-x guidgen-insert-static-const-guid
    C-u M-x guidgen-insert-registry
    C-u M-x guidgen-insert-urn


== INSTALL

((<NetInstaller|URL:http://www7a.biglobe.ne.jp/~hat/xyzzy/ni.html>)) でインストールした場合は 3 以降を、
NetInstaller + ni-autoload を使っている人は 4 以降で OK です。

(1) アーカイブをダウンロードします。

    ((<URL:http://miyamuko.s56.xrea.com/xyzzy/archives/guidgen.zip>))

(2) アーカイブを展開して、$XYZZY/site-lisp 配下にファイルをコピーします。

(3) ~/.xyzzy または $XYZZY/site-lisp/siteinit.l に以下のコードを追加します。

        ;; guidgen
        (require "guidgen")

(4) 設定を反映させるため xyzzy を再起動してください。

    ※siteinit.l に記述した場合には再ダンプが必要です。

(5) ni-autoload を使っている場合、バッファの右クリックメニューに「GUID生成」が追加されます。

    ni-autoload を使っていない場合は、以下のコードを .xyzzy か siteinit.l に追加することをお勧めします。

      ;; 「ツール」メニューに「GUID生成」というメニューを追加します。
      (guidgen-setup-app-menu)

      ;; 右クリックメニューに「GUID生成」というメニューを追加します。
      (guidgen-setup-app-popup-menu)


== MODULE

=== PACKAGE

guidgen は以下のパッケージを利用しています。

  * guidgen
  * guidgen-ffi
  * editor

=== EXPORT

guidgen は以下のシンボルを export しています。

  * guidgen パッケージ

    * *guidgen-version*
    * guidgen

  * guidgen-ffi

    内部用なので省略。

  * editor パッケージ

    * guidgen-copy-to-clipboard
    * guidgen-copy-to-kill-ring
    * guidgen-insert
    * guidgen-insert-define-guid
    * guidgen-insert-implement-olecreate
    * guidgen-insert-registry
    * guidgen-insert-static-const-guid
    * guidgen-insert-urn
    * guidgen-remove-app-menu
    * guidgen-remove-app-popup-menu
    * guidgen-replace
    * guidgen-replace-or-insert
    * guidgen-setup-app-menu
    * guidgen-setup-app-popup-menu
    * guidgen-track-popup-menu


=== VARIABLE

--- *guidgen-version*

    本ライブラリのバージョンを保持する定数です。
    バージョンは major.minor.teeny という形式です。
    それぞれの番号は必ず 1 桁にするので、以下のように比較することができます
    (Ruby と同じです :-)。

        (if (string<= "1.1.0" guidgen:*guidgen-version*)
            (1.1.0 以降で有効な処理)
          (1.1.0 より前のバージョンでの処理))


=== COMMAND

--- guidgen-copy-to-clipboard

    GUID を生成してクリップボードにコピーします。

    形式は無変換 (xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx) です。

--- guidgen-copy-to-kill-ring

    GUID を生成して kill ring にコピーします。

    形式は無変換 (xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx) です。

--- guidgen-insert

    GUID を生成してカーソル下に挿入します。

    形式は無変換 (xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx) です。

--- guidgen-replace

    カーソル下の GUID を置換します。

    カーソル下に GUID っぽい文字列が無い場合は何もしません。

--- guidgen-replace-or-insert

    カーソル下の GUID を置換します。

    カーソル下に GUID っぽい文字列が無い場合は新たに挿入します。

    前置引数に対応しています。

--- guidgen-insert-implement-olecreate

    IMPLEMENT_OLECREATE マクロ形式でカーソル下に GUID を挿入します。

    ex)
        // {82E6BCA9-3AA9-478F-A9BC-E682A93A8F47}
        IMPLEMENT_OLECREATE(<<class>>, <<external_name>>,
        0x82e6bca9, 0x3aa9, 0x478f, 0xa9, 0xbc, 0xe6, 0x82, 0xa9, 0x3a, 0x8f, 0x47);

    前置引数に対応しています。

--- guidgen-insert-define-guid

    DEFINE_GUID マクロ形式でカーソル下に GUID を挿入します。

    ex)
        // {045E9D7A-2947-475D-7A9D-5E0447295D47}
        DEFINE_GUID(<<name>>,
        0x045e9d7a, 0x2947, 0x475d, 0x7a, 0x9d, 0x5e, 0x04, 0x47, 0x29, 0x5d, 0x47);

    前置引数に対応しています。

--- guidgen-insert-static-const-guid

    GUID 構造体形式でカーソル下に GUID を挿入します。

    ex)
        // {6EAC24CD-4E4F-4420-CD24-AC6E4F4E2044}
        static const GUID <<name>> = {
            0x6eac24cd, 0x4e4f, 0x4420, { 0xcd, 0x24, 0xac, 0x6e, 0x4f, 0x4e, 0x20, 0x44 }
        };

    前置引数に対応しています。

--- guidgen-insert-registry

    レジストリ形式でカーソル下に GUID を挿入します。

    ex)
        {AEB3A288-457B-47DA-88A2-B3AE7B45DA47}

    前置引数に対応しています。

--- guidgen-insert-urn

    urn 形式でカーソル下に GUID を挿入します。

    ex)
        urn:uuid:CA02D532-7FDC-4111-32D5-02CADC7F1141

    前置引数に対応しています。

--- guidgen-track-popup-menu

    GUID を生成するためのメニューをポップアップして表示します。

--- guidgen-setup-app-menu

    「ツール」メニューに「GUID生成」というメニューを追加します。

--- guidgen-setup-app-popup-menu

    右クリックメニューに「GUID生成」というメニューを追加します。

--- guidgen-remove-app-menu

    「ツール」メニューから「GUID生成」メニューを削除します。

--- guidgen-remove-app-popup-menu

    右クリックメニューから「GUID生成」メニューを削除します。


=== FUNCTION

--- guidgen:guidgen &key downcase

    GUID を生成します。
    生成した GUID を多値で返します。
    (1) GUID の文字列表現
    (2) GUID の各フィールドを数値にした list

    ex)
        (guidgen:guidgen)
        "14DF2874-0B1E-4E62-7428-DF141E0B624E"
        (350169204 2846 20066 116 40 223 20 30 11 98 78)

    downcase に non-nil を指定すると小文字の 16 進数で GUID を生成します。

        (car (multiple-value-list (guidgen:guidgen :downcase t)))
        "c26ff9d9-aac2-4c2b-d9f9-6fc2c2aa2b4c"


== EXPERIMENTAL FEATURE

guidgen のライブラリ部分は clisp に実験的に対応しています。

    xyzzy/site-lisp> clisp --silent -i guidgen\guidgen.l
    ;; Loading file guidgen\guidgen.l ...
    ;;  Loading file guidgen\package.l ...
    ;;  Loaded file guidgen\package.l
    ;;  Loading file guidgen\guidgen-ffi.l ...
    ;;  Loaded file guidgen\guidgen-ffi.l
    ;; Loaded file guidgen\guidgen.l
    [1]> (guidgen:guidgen)
    "7D518485-5F3E-4CCC-A05B-359F07179636" ;
    (2102494341 24382 19660 160 91 53 159 7 23 150 54)
    [2]> (use-package :guidgen)
    T
    [3]> (car (multiple-value-list (guidgen :downcase t)))
    "048085b7-6ecd-4849-9585-2a6f23af95ac"
    [4]> *guidgen-version*
    "1.0.0"
    [5]> (lisp-implementation-version)
    "2.38 (2006-01-24) (built on stnt067 [192.168.0.1])"
    [6]>

== TODO

なし。


== KNOWN BUGS

なし。


== AUTHOR

みやむこ かつゆき (((<URL:mailto:miyamuko (at) gmail.com>)))


== SEE ALSO

  : Microsoft Exchange Server GUID Generator
        ((<URL:http://www.microsoft.com/downloads/details.aspx?FamilyId=94551F58-484F-4A8C-BB39-ADB270833AFC>))

  : UUID
        ((<URL:http://msdn.microsoft.com/library/default.asp?url=/library/en-us/rpc/rpc/uuid_1.asp>))

  : CoCreateGuid
        ((<URL:http://msdn.microsoft.com/library/default.asp?url=/library/en-us/com/html/8d5cedea-8c2b-4918-99db-1a000989f178.asp>))


== COPYRIGHT

guidgen は MIT/X ライセンスに基づいて利用可能です。

See guidgen/docs/MIT-LICENSE for full license.

