=begin

= drive-info - 論理ドライブの情報を取得するライブラリ

  * Author: MIYAMUKO Katsuyuki ((<URL:mailto:miyamuko (at) gmail.com>))
  * Home: ((<URL:http://miyamuko.s56.xrea.com/xyzzy/drive-info/intro.htm>))
  * Version: 1.1.0


== SYNOPSIS

=== API

  (require "drive-info/api")
  (use-package :drive-info.api)

  (get-logical-drive-letters)  ;; => (#\C #\D)
  (get-fixed-logical-drives)   ;; => ("C:\\")
  (get-drive-type #\d)         ;; => :cdrom
  (drive-exist-p "d")          ;; => t

  ;; 全固定ディスクの 「ドライブ名  ボリューム名  ファイルシステム  空き領域%」を表示
  (labels ((x (alist &rest path)
             (reduce #'(lambda (node path)
                         (or (cdr (assoc path node))
                             (return-from x)))
                     path
                     :initial-value alist)))
    (dolist (drive (get-fixed-logical-drives))
      (let ((info (get-drive-info drive)))
        (with-output-to-temp-buffer ("*drive list*")
          (format t "~A  ~10A  ~10A  ~1F%~%"
                  (x info :drive :name)
                  (x info :volume :volume-name)
                  (x info :volume :file-system-name)
                  (x info :space :free-bytes%))))))


=== UI

  * ドライブの空き容量をポップアップ表示

      M-x drive-info-popup-disk-free-space-kuma--


== DESCRIPTION

drive-info はドライブ情報を取得するライブラリです。
get-disk-usage では取得できない情報も取得可能です。

以下の機能が利用できます。

  * ドライブの一覧を取得
  * 利用していないドライブの一覧を取得
  * 固定ディスクのドライブの一覧を取得
  * ドライブが存在するかどうか判定
  * ドライブのタイプ (CD-ROM? フロッピー? ハードディスク? など) を取得
  * ドライブの空き容量・使用容量を取得
  * ドライブの詳細な情報を取得

基本的にはライブラリですが簡単なフロントエンドがあります。

  * ドライブの空き容量をポップアップ表示できます。


== INSTALL

((<NetInstaller|URL:http://www7a.biglobe.ne.jp/~hat/xyzzy/ni.html>)) でインストールした場合は 4 以降を、
NetInstaller + (({ni-autoload})) を使っている人は 5 以降で OK です。

(1) アーカイブをダウンロードします。

    ((<URL:http://miyamuko.s56.xrea.com/xyzzy/archives/drive-info.zip>))

(2) アーカイブを展開して、$XYZZY/site-lisp 配下にファイルをコピーします。

(3) ~/.xyzzy または $XYZZY/site-lisp/siteinit.l に以下のコードを追加します。

        ;; drive-info
        (require "drive-info")

(4) 設定を反映させるため xyzzy を再起動してください。

    ※siteinit.l に記述した場合には再ダンプが必要です。

(5) M-x drive-info-popup-disk-free-space-kuma-- で空き容量を表示できます。

(6) ライブラリとして利用する場合は drive-info.api パッケージを
    use しておくと package prefix を省略できます。

      (require "drive-info")
      (in-package :your-cool-application)
      (use-package :drive-info.api)


== MODULE

=== PACKAGE

drive-info は以下のパッケージを利用しています。

  * drive-info.api

    ライブラリの定義。別名 (nickname) は drive。

  * drive-info.ffi

    内部用。

  * editor

    フロントエンドの定義。

=== EXPORT

  * drive-info.api

    * ((< drive-info-version >))
    * ((< drive-info-api-version >))
    * ((< get-drive-info >))
    * ((< get-logical-drives >))
    * ((< get-logical-drive-letters >))
    * ((< get-fixed-logical-drives >))
    * ((< get-fixed-logical-drive-letters >))
    * ((< get-free-logical-drives >))
    * ((< get-free-logical-drive-letters >))
    * ((< drive-exist-p >))
    * ((< get-drive-type >))
    * ((< get-volume-information >))
    * ((< get-disk-free-space >))
    * ((< drive-name >))
    * ((< drive-letter >))

  * editor

    * ((< drive-info-popup-disk-free-space-kuma-- >))

  * drive-info-ffi

    内部用なので省略。。。


=== VARIABLE

なし。


=== COMMAND

==== editor パッケージ

--- drive-info-popup-disk-free-space-kuma--

    ドライブの空き容量をポップアップしてグラフ表示します。


=== FUNCTION

==== drive-info.api パッケージ

以下の関数はすべて drive-info.api パッケージで定義しています。

サンプルコードはすべて drive-info.api を use していことを前提に
package prefix を省略しています。

root-dir を引数にとる関数はドライブ名 (文字列 or 文字) やパス名などを指定できます。
以下の呼び出しはすべて有効です。

  (drive-exist-p #\x)
  (drive-exist-p #\Y)
  (drive-exist-p "z")
  (drive-exist-p "z:")
  (drive-exist-p "Y:/foo/bar")


--- drive-info-version

    drive-info のバージョンを返します。
    バージョンは major.minor.teeny という形式です。

    それぞれの番号は必ず 1 桁にするので、以下のように比較することができます
    (Ruby と同じです :-)。

        (if (string<= "1.1.0" (drive-info-version))
            (1.1.0 以降で有効な処理)
          (1.1.0 より前のバージョンでの処理))

    drive-info.api を利用するアプリケーションを書いていて、
    ある API が実装されているかどうかの判定したい場合は
    ((<URL:drive-info.api:drive-info-api-version>))
    を利用してください。

--- drive-info-api-version

    call-seq:
      (layered-window-api-version) => 1

    drive-info API のバージョンを返します。
    バージョンは単純な数値です。

    drive-info.api パッケージで定義している API に追加・変更があった場合に
    インクリメントします。

--- get-logical-drives

    call-seq:
        (get-logical-drives) => (drive namess...)

    存在する全ドライブ名のリストを取得します。
    ドライブ文字は大文字です。

      (get-logical-drives) 
      ;; => ("C:\\" "D:\\")

--- get-logical-drive-letters

    call-seq:
        (get-logical-drive-letters) => (drive letters...)

    存在する全ドライブのドライブ文字のリストを取得します。
    ドライブ文字は大文字です。

      (get-logical-drive-letters) 
      ;; => (#\C #\D)

--- get-free-logical-drives

    call-seq:
        (get-free-logical-drives) => (drive namess...)

    存在しない全ドライブ名のリストを取得します。
    ドライブ文字は大文字です。

      (get-free-logical-drives)  
      ;; => ("A:\\" "B:\\" ... "Z:\\")

--- get-free-logical-drive-letters

    call-seq:
        (get-free-logical-drive-letters) => (drive letters...)

    存在する全ドライブのドライブ文字のリストを取得します。
    ドライブ文字は大文字です。

      (get-free-logical-drive-letters) 
      ;; => (#\A #\B ... #\Z)

--- get-fixed-logical-drives

    call-seq:
        (get-fixed-logical-drives) => (drive namess...)

    存在する固定ディスクのドライブ名のリストを取得します。

      (get-fixed-logical-drives) 
      ;; => ("C:\\")

--- get-fixed-logical-drive-letters

    call-seq:
        (get-fixed-logical-drive-letters) => (drive letters...)

    存在する固定ディスクのドライブ文字のリストを取得します。

      (get-fixed-logical-drive-letters) 
      ;; => (#\C)

--- drive-exist-p

    call-seq:
        (drive-exist-p root-dir) => t or nil

    指定したドライブが存在するかどうか判定します。

    引数にはドライブ名かディレクトリ名を指定します。
    nil を指定すると (default-directory) のドライブの情報を取得します。

--- get-drive-info

    call-seq:
        (get-drive-info root-dir) => (alist)

    drive-info で取得可能な全情報を取得します。

    引数にはドライブ名かディレクトリ名を指定します。
    nil を指定すると (default-directory) のドライブの情報を取得します。

    以下のようなリストを返します。

      ((:drive
        (:name . <ドライブレター>)
        (:type . <ドライブタイプ>))

       (:volume
        (:volume-name . <ボリューム名>)
        (:volume-serial-number . <ボリュームのシリアル番号>)
        (:maximum-component-length . <ファイル名の最大の長さ>)
        (:file-system-flags
         ((:case-sensitive-search . <t or nil>)
          (:case-preserved-names . <t or nil>)
          (:unicode-on-disk . <t or nil>)
          (:persistent-acls . <t or nil>)
          (:file-compression . <t or nil>)
          (:volume-quotas . <t or nil>)
          (:supports-sparse-files . <t or nil>)
          (:supports-reparse-points . <t or nil>)
          (:supports-remote-storage . <t or nil>)
          (:volume-is-compressed . <t or nil>)
          (:supports-object-ids . <t or nil>)
          (:supports-encryption . <t or nil>)
          (:named-streams . <t or nil>)
          (:read-only-volume . <t or nil>)))
        (:file-system-name . <ファイルシステム名>))
       (:space
        (:free-bytes-available . <呼び出し側が利用できるバイト数>)
        (:total-number-of-bytes . <ディスク全体のバイト数>)
        (:total-number-of-free-bytes . <ディスク全体の空きバイト数>)
        (:total-number-of-used-bytes . <ディスク全体の使用バイト数>)
        (:free-bytes% . <ディスク全体の空き容量%>)
        (:used-bytes% . <ディスク全体の使用容量%>)))

    * ドライブレター:  "C:\\", "D:\\" など文字列で返す。
    * ドライブタイプ: :unknown, :no-root-dir, :removable, :fixed, :remote, :cdrom, :ramdisk のどれか。
    * ボリューム名: "ローカル ディスク" など。マイコンピュータで見る名前。
    * ファイルシステム名: "NTFS" など。

--- get-drive-type

    call-seq:
        (get-drive-type root-dir) => :keyword

    ドライブタイプを取得します。

    引数にはドライブ名かディレクトリ名を指定します。
    nil を指定すると (default-directory) のドライブの情報を取得します。

      (get-drive-type "C:")
      ;; => :fixed

      (get-drive-type #\d)
      ;; => :cdrom

    ドライブタイプは以下のキーワードのいずれかを返します。

      : :unknown
            ドライブの種類を判別できませんでした。
      : :no-root-dir
             指定のルートディレクトリが存在しません。
             たとえば、パスにボリュームがマウントされていません
             （未フォーマットや、メディアが挿入されていないなど）。
      : :removable
             このディスクは、ドライブから取り出せます。
      : :fixed
             このディスクは、ドライブから取り出せません。
      : :remote
             このドライブは、リモート（ネットワーク）ドライブです。
      : :cdrom
             このドライブは、CD-ROM ドライブです。
      : :ramdisk
             このドライブは、RAM ディスクです。

--- get-volume-information

    call-seq:
        (get-volume-information root-dir) => (alist)

    ファイルシステムとボリュームに関する情報を取得します。

    引数にはドライブ名かディレクトリ名を指定します。
    nil を指定すると (default-directory) のドライブの情報を取得します。

    以下のようなリストを返します。

      ((:volume-name . <ボリューム名>)
       (:volume-serial-number . <ボリュームのシリアル番号>)
       (:maximum-component-length . <ファイル名の最大の長さ>)
       (:file-system-flags
        ((:case-sensitive-search . <t or nil>)
         (:case-preserved-names . <t or nil>)
         (:unicode-on-disk . <t or nil>)
         (:persistent-acls . <t or nil>)
         (:file-compression . <t or nil>)
         (:volume-quotas . <t or nil>)
         (:supports-sparse-files . <t or nil>)
         (:supports-reparse-points . <t or nil>)
         (:supports-remote-storage . <t or nil>)
         (:volume-is-compressed . <t or nil>)
         (:supports-object-ids . <t or nil>)
         (:supports-encryption . <t or nil>)
         (:named-streams . <t or nil>)
         (:read-only-volume . <t or nil>)))
       (:file-system-name . <ファイルシステム名>))

    ファイルシステムオプションの意味は以下のとおりです。

      : :case-sensitive-search
          ファイル名の大文字と小文字の区別をサポートしています。

      : :case-preserved-names
          ディスクにファイル名を記録するときに、大文字と小文字を区別して保存します。

      : :unicode-on-disk
          Unicode のファイル名をサポートしていて、ディスク上でも正しく表示されます。

      : :persistent-acls
          ACL（アクセス制御リスト）の保存と適用を行います。
          たとえば、NTFS は ACL の保存と適用を行いますが、FAT は ACL をサポートしていません。

      : :file-compression
          ファイルベースの圧縮をサポートしています。

      : :volume-quotas
          ディスククォータ（ディスク使用量の割り当て機能）をサポートしています。

      : :supports-sparse-files
          スパースファイル（疎なファイル、未使用の領域が多い、または同じ値が長く続くファイル）
          をサポートしています。

      : :supports-reparse-points
          再解析ポイントをサポートしています。

      : :supports-remote-storage
          リモートストレージをサポートしています。

      : :volume-is-compressed
          指定されたボリュームは、圧縮ボリューム（たとえば、DoubleSpace のボリューム）です。

      : :supports-object-ids
          オブジェクト識別子をサポートしています。

      : :supports-encryption
          暗号化ファイルシステム（EFS）をサポートしています。

      : :named-streams
          名前付きストリームをサポートしています。

      : :read-only-volume
          書き込み不可です。

--- get-disk-free-space

    call-seq:
        (get-disk-free-space root-dir) => (alist)

    ボリュームの容量に関する情報を取得します。

    引数にはドライブ名かディレクトリ名を指定します。
    nil を指定すると (default-directory) のドライブの情報を取得します。

    以下のようなリストを返します。

      ((:free-bytes-available . <呼び出し側が利用できるバイト数>)
       (:total-number-of-bytes . <ディスク全体のバイト数>)
       (:total-number-of-free-bytes . <ディスク全体の空きバイト数>)
       (:total-number-of-used-bytes . <ディスク全体の使用バイト数>)
       (:free-bytes% . <ディスク全体の空き容量%>)
       (:used-bytes% . <ディスク全体の使用容量%>))

--- drive-name

    call-seq:
        (drive-name root-dir) => drive name

    指定されたディレクトリのドライブ名を取得します。

      (drive-name "c:\\hoge")
      ;; => "C:\\"

      (drive-name #\C)
      ;; => "C:\\"

    引数にはドライブ名かディレクトリ名を指定します。
    nil を指定すると nil を返します。

    以下の点が pathname-device とは違います。

      * nil を指定すると nil を返します。
        (pathname-device はエラー)。
      * アルファベット一文字を渡すとドライブレターとして解釈します
        (pathname-device はディレクトリ名として解釈し default-directory のドライブ名を返す)。
      * #\C など文字を指定可能です。
      * ドライブレターは常に大文字。
      * ":\\" が付いている。

    この関数はドライブの存在チェックはしません。

--- drive-letter

    call-seq:
        (drive-letter root-dir) => drive letter

    指定されたディレクトリのドライブレターを取得します。
    必ず大文字で返します。

      (drive-letter "c:\\hoge")
      ;; => #\C

      (drive-letter #\c)
      ;; => #\C

    引数にはドライブ名かディレクトリ名を指定します。
    nil を指定すると nil を返します。

    この関数はドライブの存在チェックはしません。


=== EXPORT

==== editor

editor パッケージからは以下のコマンドを export しています。

* drive-info-popup-disk-free-space-kuma--

==== drive-info.api

drive-info.api パッケージからは以下の関数を export しています。

* get-drive-info
* get-logical-drives
* get-drive-type
* get-volume-information
* get-disk-free-space
* drive-exist-p

* volume-name
* volume-serial-number
* maximum-component-length
* file-system-flags
* file-system-name

* free-bytes-available
* total-number-of-bytes
* total-number-of-free-bytes
* total-number-of-used-bytes
* free-bytes%
* used-bytes%


== TODO

* 物理ディスク情報も取得
  * DeviceIoControl
  * Win32_DiskDrive


== KNOWN BUGS

なし。


== AUTHORS

みやむこ かつゆき (((<URL:mailto:miyamuko (at) gmail.com>)))


== SEE ALSO

  : GetLogicalDrives
        ((<URL:http://msdn.microsoft.com/library/ja/jpfileio/html/_win32_getlogicaldrives.asp>))
  : GetDriveType
        ((<URL:http://msdn.microsoft.com/library/ja/jpfileio/html/_win32_getdrivetype.asp>))
  : GetVolumeInformation
        ((<URL:http://msdn.microsoft.com/library/ja/jpfileio/html/_win32_getvolumeinformation.asp>))
  : GetDiskFreespaceEx
        ((<URL:http://msdn.microsoft.com/library/ja/jpfileio/html/_win32_getdiskfreespaceex.asp>))
  
  : 「あのＡＡどこスレ」テンプレ補助サイト
        ((<URL:http://dokoaa.com/kuma.html>))
  : AsciiArtHeadline あの AA きぼんぬ DB
        ((<URL:http://tecstar.ddo.jp/aa_video/aadb/select.cgi?page=10&rowcount=5&baa=1&word=%92%DE%82%E8>))


== COPYRIGHT

drive-info は MIT/X ライセンスにしたがって利用可能です。

See drive-info/docs/MIT-LICENSE for full license.


== NEWS

<<<NEWS.rd

=end
