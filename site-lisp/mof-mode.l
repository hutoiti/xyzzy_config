#|
= mof-mode - MOF ファイルを編集したりする

* Author:  miyamuko ((<URL:mailto:miyamuko (at) mtb.biglobe.ne.jp>))
* URL: ((<URL:http://miyamuko.s56.xrea.com/xyzzy/mof-mode.html>))
* Version: $Id: mof-mode.l,v 1.16 2004/08/09 14:03:12 miyamuko Exp $


== 説明

((<MOF|URL:http://www.dmtf.org/education/mof>)) ファイルを編集するための
major mode です。

今のところ以下のことができます。

* MOF のキーワードと
  ((<"CIM Schema v2.9 Preliminary"|URL:http://www.dmtf.org/standards/cim/cim_schema_v29_prelim/>))
  で定義されている Core Qualifier の色づけ＆補完
* Qualifier を認識したインデント
* Qualifier 宣言もちゃんとインデント
* クラスと Qualifier のタグジャンプ
* Values と ValueMap Qualifier の対応付け
* MOF の構文要素を意識したカーソル移動・マーキング
* include ファイルのオープン
* 外部コマンドの登録
* CIM Specification v2.2 Appendix C で定義されている「単位」の補完＆挿入
* MOF の文字列だけを ispell。(主に Description を想定)


== インストール

((<NetInstaller|URL:http://www.mirai.ne.jp/~gyo/xyzzy/ni.html>)) でインストールした場合は 3 以降を、
NetInstaller + (({ni-autoload})) を使っている人は 4 以降で OK です。

(1) アーカイブをダウンロードします。

    ((<URL:http://miyamuko.s56.xrea.com/xyzzy/archives/mof-mode.zip>))

(2) アーカイブを展開して、$XYZZY/site-lisp 配下にファイルをコピーします。

(3) 拡張子が mof また mfl のファイルを開いたときに自動的に mof-mode になるように
    ~/.xyzzy または $XYZZY/site-lisp/siteinit.l に以下のコードを追加します。

        ;; mof-mode
        (require "mof-mode")
        (pushnew '("\\.\\(mof\\|mfl\\)$" . mof-mode) *auto-mode-alist* :test 'equal)

(4) 設定を反映させるには xyzzy を再起動してください。

    ※siteinit.l に記述した場合には再ダンプが必要です。


== リファレンス

=== キー割り当て

: ((%TAB%))
    インデントします。

    Qualifier 宣言を複数行にわたって書く場合は次のようにインデントします。

        Qualifier Key : boolean = false,
                        Scope(property, reference),
                        Flavor(DisableOverride);

: ((%RET%))
    改行＋インデント付け＋文字列を自動的に閉じたりします。

: ((%M-TAB%))
    キーワードと CIM の Core Qualifier を補完します。

    * 先行する文字があればその文字から始まるキーワードをツールチップで表示します。
      先行する文字がなければすべてのキーワードを表示します。

    * Units Qualifier の中で実行すると CIM Specification v2.2 Appendix C
      で定義されている単位を補完します。

: ((%F5%))
    現在のバッファを構文チェックします。

    構文チェック用のコマンドは ((|*mof-lint-command*|)) で変更できます。

: ((%Shift-F5%))
    現在のバッファをコンパイルする。

    コンパイル用のコマンドは ((|*mof-compiler-command*|)) で変更できます。

: ((%C-c RET%))
    (({#pragma include})) でインクルードしているファイルを開きます。

    カレントディレクトリを探し、見つからない場合は include ディレクトリを順に探します。
    include ディレクトリは ((|*mof-include-directory-list*|)) で追加できます。

    (({mof-find-include-file-dialog})) を使えば include
    しているファイルの一覧をダイアログから選択し開くことができます。

: ((%C-c C-c%))
    リージョンをコメントアウトします。

: ((%C-c C-u%))
    リージョンのコメントを解除します。

: ((%C-/%))
    行のコメント・非コメントを切り替えます。

: ((%C-c n%))
    現在の Namespace をツールチップで表示します。

    (({#pragma namespace})) がない場合は default namespace (\\root\cimv2) を表示します。

: ((%C-c v v%))
    Values と ValueMap Qualifier 上で実行すると、
    対応する値をツールチップで表示します。

    例
        ValueMap { "0", "1", "2", "3" },
        Values { "Deployable", "Installable", "Executable", "Running" }

    (({"2"})) の上で実行すると (({Installable})) をツールチップで表示します。

: ((%C-c v g%))
    Values と ValueMap Qualifier 上で実行すると、対応する値の先頭に移動します。

    例
        ValueMap { "0", "1", "2" },
        Values {
          "Pentium(R) III Processor with Intel(R) SpeedStep(TM) "
          "Technology", "Pentium(R) 4", "Intel(R) Xeon(TM)"
        },

    (({"0"})) に上で実行すると (({"Pentium(R) III Processor..."})) の先頭に移動します。
    連続する文字列もちゃんと考慮してます。

: ((%C-c v d%))
    一時バッファを作成して Values と ValueMap の対応を表示します。
    Qualifier の中で実行してください。

        ValueMap { "0", "1", "2", "3", "4" },
        Values { "Deployable", "Installable", "Executable", "Running" }

    実行例
        0 => Deployable
        1 => Installable
        2 => Executable
        3 => Running
        4 => nil

: ((%C-c v m%))
    ValueMap を自動生成しカーソル位置に挿入します。Qualifier の中で実行してください。

    使用前
        Values { "Deployable", "Installable", "Executable", "Running" }

    使用後
        ValueMap { "0", "1", "2", "3" },
        Values { "Deployable", "Installable", "Executable", "Running" }

    連番は 0 から始まります。0 以外ではじめたい場合はソースでもいじってください。

    65 桁を超える場合勝手に改行します。
    fold する桁数をかえたい場合、前置引数で指定します。

      C-u 70 C-c v m

: ((%C-M-Space%))
    直近のクラス、インスタンス、Qualifier 宣言をマークします。

: ((%C-M-f%))
: ((%C-M-b%))
    Qualifier list の開始点と終了点を行ったり来たりします。

: ((%C-M-n%))
: ((%C-M-p%))
    クラス、インスタンス、Qualifier 宣言、メソッド、プロパティを行ったり来たりします。

=== コマンド

--- mof-completion ()
    補完します。キー設定を変える場合は以下を .xyzzy に追加します。

        ;; 補完キーの設定を Ctrl + . にする（デフォルト M-TAB)
        (add-hook '*mof-mode-hook*
                  '(lambda ()
                       (local-set-key #\C-. 'mof-completion)))

--- mof-define-command (symbol command &key opts before-hook after-hook key name output dir)
    バッファのファイル名を引数に実行する外部コマンドを定義します。

    : symbol
        作成するコマンドのシンボルを指定します。

        関数名とかメニューのタグ名だったりします。

    : command
        オプションなしでコマンドを指定します。

    : opts
        コマンドのオプションをリストで指定します。

    : wait
        コマンドの実行が終了するのを待つ場合は ((|non-nil|)) を指定します。

    : key
        バインドするキーを指定します。

        ショートカットキーを指定しない場合は ((|nil|)) を指定します。

    : name
        メニューの項目名を指定します。

        メニューに追加しない場合は ((|nil|)) を指定します。

    : output
        コマンドの実行結果を出力するバッファ名を指定します。

        省略時は ((|*mof-command-buffer-name*|)) です。

    : dir
        コマンド実行時のディレクトリを指定します。

        省略時はコマンドが置いてあるディレクトリです。
        で、それも取れない場合は mof ファイルがあるディレクトリです。

    : before-hook
        コマンドの実行前に実行するフックを指定します。

        * フックの実行結果が ((|nil|)) の場合はコマンドを実行しません。
        * フックが指定されていない場合、フックの実行結果が ((|non-nil|))
          の場合はコマンドを実行します。

    : after-hook
        コマンドの実行後に実行するフックを指定します。

        フックは引数を一つとります。wait の値によって変わります。
        * wait が ((|non-nil|)) の場合: コマンドの終了ステータス。
        * wait が ((|nil|)) の場合: プロセス (make-process の戻り値)。

    例

        ;; wbemservices のコマンドを定義 (環境変数 WBEM_HOME を設定する必要があります。)
        ;; mof2html を実行し HTML を生成してブラウザで開く
        (mof-define-command 'ed::mof-to-html
                            (merge-pathnames "bin/mof2html.bat" (si:getenv "WBEM_HOME"))
                            :name "JWS mof2html"
                            :wait t
                            :after-hook '(lambda (exit)
                                          (when (zerop exit)
                                            (shell-execute (merge-pathnames "bin/xml/index.html" (si:getenv "WBEM_HOME"))))))
        ;; mof2bean を実行し Java ファイルを生成してファイラで開く
        (mof-define-command 'ed::mof-to-bean
                            (merge-pathnames "bin/mof2bean.bat" (si:getenv "WBEM_HOME"))
                            :opts (list "user" "pass" (merge-pathnames "bin/bean.txt" (si:getenv "WBEM_HOME")))
                            :name "JWS mof2bean"
                            :wait t
                            :after-hook '(lambda (exit)
                                          (when (zerop exit)
                                            (multiple-value-bind (files ok)
                                                (filer (merge-pathnames "bin/bean" (si:getenv "WBEM_HOME")) t)
                                              (when ok
                                                (find-file files))))))
        ;; mofcomp する。コマンドの終了は待たない。
        (mof-define-command 'ed::mof-compile-jws
                            (merge-pathnames "bin/mofcomp.bat" (si:getenv "WBEM_HOME"))
                            :key #\F6
                            :opts '("-u" "user" "-p" "pass")
                            :name "JWS mofcomp"
                            :before-hook '(lambda ()
                                           (yes-or-no-p "本当に mofcomp するの?")))

=== 変数

--- *mof-comment-column*
    (({indent-for-comment})) で挿入するコメントの開始位置。
    デフォルト値は 60 です。

        0    10    20    30    40     50     60
        class Win32_Sample                   // ←これを挿入する位置

--- *mof-indent-level*
    インデント幅を指定します。
    デフォルト値は 3 です。

--- *mof-qualifier-offset*
    Qualifier のオフセットを指定します。
    デフォルト値は 3 です。

--- *mof-compile-command*
    mofcomp 用コマンドを指定します。
    デフォルト値は "mofcomp" です。

--- *mof-lint-command*
    構文チェック用コマンドを指定します。
    デフォルト値は "mofcomp -check" です。

--- *mof-command-buffer-name*
    コマンド実行時の出力バッファ名。
    デフォルト値は "*MOF Command*" です。

--- *mof-include-directory-list*
    (({mof-find-include-file})) でファイルを探すディレクトリを指定します。

        ;; Include ディレクトリを追加
        (pushnew "D:/CIM_V28Prelim-MOFs/" *mof-include-directory-list*)


== コーディングスタイル

MOF のコーディングスタイル集です。
デフォルトは DMTF - CIM Schema v2.8 です。

=== DMTF - CIM Schema v2.8

* .xyzzy
    ;; CIM Schema v2.8 のインデントスタイル
    (setf *mof-indent-level* 3)
    (setf *mof-qualifier-offset* 3)

* style
    // comment
       [abstract]
    class Win32_LogicalDisk
    {
       // comment
          [read]
       string DriveLetter;
    }

=== DMTF - CIM Schema v2.7

* .xyzzy
    ;; CIM Schema v2.7 のインデントスタイル
    (setf *mof-indent-level* 4)
    (setf *mof-qualifier-offset* 4)

* style
    // comment
        [abstract]
    class Win32_LogicalDisk
    {
        // comment
            [read]
        string DriveLetter;
    }

=== Microsoft / SUN

* .xyzzy
    (setf *mof-indent-level* 4)
    (setf *mof-qualifier-offset* 0)

* style
    // comment
    [abstract]
    class Win32_LogicalDisk
    {
        // comment
        [read]
        string DriveLetter;
    }

=== DMTF - ((<"CIM Tutorial"|URL:http://www.dmtf.org/education/cimtutorial/extend/spec.php>))

* .xyzzy
    (setf *mof-indent-level* 8)
    (setf *mof-qualifier-offset* -4)

* style
    // comment
    [abstract]
    class Win32_LogicalDisk
    {
            // comment
        [read]
            string DriveLetter;
    }


== 既知のバグ

* mof-generate-java-constants は単純な int 型のみ。
  string や 1..4 のようなレンジには対応していない。

== これからやるかもしれないこと

* リファレンス。


== 関連するかもしれないページ

: Common Information Model (CIM) Standards
    ((<URL:http://www.dmtf.org/standards/standard_cim.php>))

: MOF Specification
    ((<URL:http://www.dmtf.org/standards/cim/cim_spec_v22/#_Toc453584969>))

: CIM Schema v2.8
    ((<URL:http://www.dmtf.org/standards/cim/cim_schema_v28>))

: CIM Schema v2.7
    ((<URL:http://www.dmtf.org/standards/cim/cim_schema_v27>))

: WMI CIM Schema
    %SystemRoot%\system32\wbem\cimwin32.mof

: Microsoft MOF Editor
    ((<URL:http://www.dmtf.org/members/tools>))


== ライセンス

mof-mode は修正 BSD ライセンスに基づいて利用可能です。

  Copyright (C) 2003-2004 MIYAMUKO Katsuyuki. All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  1 Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer as the first lines
  of this file unmodified.

  2 Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
  OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
  SUCH DAMAGE.
|#


(provide "mof-mode")
(in-package "editor")

(export '(*mof-mode-hook*
          *mof-mode-map*
          *mof-comment-column*
          *mof-indent-level*
          *mof-qualifier-offset*
          *mof-command-buffer-name*
          *mof-compile-command*
          *mof-lint-command*
          *mof-include-directory-list*

          mof-spell-check-string
          mof-spell-check-all-string
          mof-spell-check-directory
          mof-spell-check-dialog

          mof-find-include-file
          mof-find-include-file-dialog

          mof-list-current-class-function

          mof-comment-toggle-line
          mof-comment-region
          mof-uncomment-region

          mof-kill-current-string
          mof-current-string-output-to-buffer

          mof-what-namespace
          mof-what-corresponding-values-valuemap
          mof-goto-corresponding-values-valuemap
          mof-display-values-valuemap
          mof-generate-valuemap
          mof-generate-java-constants

          mof-mark-class
          mof-mark-feature
          mof-mark-qualifier-list

          mof-indent-dialog
          mof-indent-directory
          mof-indent-buffer
          mof-indent-class

          mof-forward-class
          mof-backward-class
          mof-forward-feature
          mof-backward-feature
          mof-forward-qualifier-list
          mof-backward-qualifier-list

          mof-menu-add-unit
          mof-menu-add-bookmark

          mof-define-command
          mof-make-command
          mof-completion
          mof-unit-completion
          mof-mode
          ))


; フック
(defvar *mof-mode-hook* nil
  "mof-mode: フック変数")

(defvar *mof-include-directory-list* nil
  "mof-mode: include ファイルを探すディレクトリ。")

; configuration
(defvar *mof-comment-column* 60
  "mof-mode: indent-for-comment で挿入するコメントの開始位置")
(defvar *mof-indent-level* 3
  "mof-mode: インデントレベル")
(defvar *mof-qualifier-offset* 3
  "mof-mode: Qualifier のインデントレベル")
(defvar *mof-compile-command* "mofcomp"
  "mof-mode: mofcomp 用コマンド")
(defvar *mof-lint-command* "mofcomp -check"
  "mof-mode: MOF 構文チェック用コマンド")
(defvar *mof-command-buffer-name* "*MOF Command*"
  "mof-mode: MOF コマンド実行時の出力バッファ名")
(defvar *mof-menu* nil
  "mof-mode: MOF メニュー")
(defvar *mof-menu-name* "&MOF"
  "mof-mode: メニュー文字列")
(defvar *mof-menu-position* 'ed::help
  "mof-mode: メニュー位置")
(defvar *mof-open-browser-function* nil
  "mof-mode: bookmark を開く関数。nil の場合 shell-execute で開く")
(defvar *mof-bookmark-list*
  '(("Common Information Model (CIM) Standards" . "http://www.dmtf.org/standards/standard_cim.php")
    ("CIM Specification (PDF)" . "http://www.dmtf.org/standards/documents/CIM/DSP0004.pdf")
    ("CIM Specification" . "http://www.dmtf.org/standards/cim/cim_spec_v22/")
    ("MOF Specification" . "http://www.dmtf.org/standards/cim/cim_spec_v22/#_Toc453584969")
    ("CIM Schema v2.8" . "http://www.dmtf.org/standards/cim/cim_schema_v28")
    ("CIM Schema v2.7" . "http://www.dmtf.org/standards/cim/cim_schema_v27")))

; map to c-*
(defvar *mof-continued-statement-offset* 0)
(defvar *mof-brace-offset* -4)
(defvar *mof-brace-imaginary-offset* 0)
(defvar *mof-argdecl-indent* 0)
(defvar *mof-label-offset* 0)


;; Appendix C VALUES FOR UNITS QUALIFIER
(defvar *mof-unit-list*
  '("Bits" "KiloBits" "MegaBits" "GigaBits"
    "Bits per Second"
    "Bytes" "KiloBytes" "MegaBytes" "GigaBytes" "Words" "DoubleWords" "QuadWords"
    "Degrees C" "Tenths of Degrees C" "Hundredths of Degrees C"
    "Degrees F" "Tenths of Degrees F" "Hundredths of Degrees F"
    "Degrees K" "Tenths of Degrees K" "Hundredths of Degrees K"
    "Color Temperature"
    "Volts" "MilliVolts" "Tenths of MilliVolts" "Amps" "MilliAmps" "Tenths of MilliAmps" "Watts"
    "MilliWattHours"
    "Joules" "Coulombs" "Newtons"
    "Lumen" "Lux" "Candelas"
    "Pounds" "Pounds per Square Inch"
    "Cycles" "Revolutions" "Revolutions per Minute" "Revolutions per Second"
    "Minutes" "Seconds" "Tenths of Seconds" "Hundredths of Seconds" "MicroSeconds"
    "MilliSeconds" "NanoSeconds"
    "Hours" "Days" "Weeks"
    "Hertz" "MegaHertz"
    "Pixels" "Pixels per Inch"
    "Counts per Inch"
    "Percent" "Tenths of Percent" "Hundredths of Percent"
    "Meters" "Centimeters" "Millimeters" "Cubic Meters" "Cubic Centimeters" "Cubic Millimeters"
    "Inches" "Feet" "Cubic Inches" "Cubic Feet Ounces" "Liters" "Fluid Ounces"
    "Radians" "Steradians" "Degrees"
    "Gravities" #|重複している "Pounds"|# "Foot-Pounds"
    "Gauss" "Gilberts" "Henrys" "MilliHenrys" "Farads" "MilliFarads" "MicroFarads" "PicoFarads"
    "Ohms" "Siemens"
    "Moles" "Becquerels" "Parts per Million"
    "Decibels" "Tenths of Decibels"
    "Grays" "Sieverts"))

; 正規表現

;; コメントと空白文字のパターン
(defvar *mof-comment-or-whitespace-regexp* nil)
(setf *mof-comment-or-whitespace-regexp*
      (concat "\\(?:"
              "//[^\n]*\\(?:\n\\|$\\)" ; // コメント
              "\\|"
              "/\\*[^*]*\\*+\\(?:[^/*][^*]*\\*+\\)*/" ; /* コメント */
              "\\|"
              "[ \t\r\f\n]+"
              "\\)+"))


;; MOF の data type のリスト
(defvar *mof-data-types*
  '("boolean" "datetime" "char16" "string"
    "sint[0-9]+" "uint[0-9]+" "real[0-9]+"))
;    "sint8" "sint16" "sint32" "sint64"
;    "uint8" "uint16" "uint32" "uint64"
;    "real32" "real64"))

;; MOF の識別子のパターン
(defvar *mof-identifier-regexp*
  "[a-zA-Z][a-zA-Z0-9_]*")

;; MOF の参照型のパターン
;; 他のパターンに埋め込むので compile-regexp しない。
;; 面度なので ref の前のコメントは考えない。
(defvar *mof-ref-type-regexp*
  (concat *mof-identifier-regexp* "[ \t\r\f\n]+" "ref"))

;; Qualifier 宣言のパターン
;; Qualifier type の : までにマッチする. グループはなし. case-fold.
;; 面倒なのでコメントは考えない。
;;   qualifierDeclaration = QUALIFIER qualifierName qualifierType scope [ defaultFlavor ] ";"
;;   qualifierName = IDENTIFIER
;;   qualifierType = ":" dataType [ array ] [ defaultValue ]
(defvar *mof-qualifier-declaration-regexp* nil)
(setf *mof-qualifier-declaration-regexp*
      (compile-regexp (format nil "^[ \t]*Qualifier[ \t]+~A[ \t]*:"
                              *mof-identifier-regexp*)
                      t))

;; 配列型のプロパティの "[0-9*]" にマッチする
(defvar *mof-array-regexp* "\\(?:\\[[0-9]*\\]\\)")

;; プロパティまたはメソッドにマッチする
;; $1=DataType, $2={Property,Method}Name. case-fold
(defvar *mof-class-feature-regexp* nil)
(setf *mof-class-feature-regexp*
      (compile-regexp (format nil "\\<\\(~{~A\\|~}~A\\)\\>~A\\(~A~A?\\)"
                              *mof-data-types*
                              *mof-ref-type-regexp*
                              *mof-comment-or-whitespace-regexp*
                              *mof-identifier-regexp*
                              *mof-array-regexp*)
                      t))

;; class、Qualifier または Instance の開始にマッチする。
;; $1=keyward, $1={Class,Qualifier}Name. case-fold。
;; 面倒なので行頭のコメントは考えない。
(defvar *mof-production-regexp* nil)
(setf *mof-production-regexp*
      (compile-regexp (concat "^[ \t]*\\(class\\|Qualifier\\|instance[ \t]+of\\)"
                              *mof-comment-or-whitespace-regexp*
                              "\\(" *mof-identifier-regexp* "\\)")
                      t))

;; class、Instance、Qualifier、プロパティまたはメソッドにマッチする。
(defvar *mof-statement-regexp* nil)
(setf *mof-statement-regexp*
      (compile-regexp (format nil "\\<\\(~{~A\\|~}~A\\)\\>~A\\(~A\\)"
                              (append (list "class" "Qualifier" "instance[ \t]+of")
                                      *mof-data-types*)
                              *mof-ref-type-regexp*
                              *mof-comment-or-whitespace-regexp*
                              *mof-identifier-regexp*)
                      t))

;; キーワード
(defvar *mof-completion-list* nil
  "mof-mode: 補完リストのポップアップ")

(defvar *mof-keyword-hash-table* nil)
(defvar *mof-keyword-file* "MOF") ; キーワードファイル名

(defvar *mof-pragma-color* '(:keyword 2)
  "mod-mode: pragma の色")

(defvar *mof-regexp-keyword-list* nil
  "mof-mode: 正規表現キーワードリスト")

(setf *mof-regexp-keyword-list*
      (compile-regexp-keyword-list
       `(
         ("^[ \t]*#pragma[ \t]+include" t ((0 . ,*mof-pragma-color*)))
         ("^[ \t]*#pragma[ \t]+instancelocale" t ((0 . ,*mof-pragma-color*)))
         ("^[ \t]*#pragma[ \t]+locale" t ((0 . ,*mof-pragma-color*)))
         ("^[ \t]*#pragma[ \t]+namespace" t ((0 . ,*mof-pragma-color*)))
         ("^[ \t]*#pragma[ \t]+nonlocal" t ((0 . ,*mof-pragma-color*)))
         ("^[ \t]*#pragma[ \t]+nonlocaltype" t ((0 . ,*mof-pragma-color*)))
         ("^[ \t]*#pragma[ \t]+source" t ((0 . ,*mof-pragma-color*)))
         ("^[ \t]*#pragma[ \t]+sourcetype" t ((0 . ,*mof-pragma-color*)))
         ("^[ \t]*#pragma" t ((0 . ,*mof-pragma-color*)))
         )))


; シンタックステーブル
(defvar *mof-mode-syntax-table* nil)
(unless *mof-mode-syntax-table*
  (setf *mof-mode-syntax-table* (make-syntax-table))
  (do ((x #x21 (1+ x)))((>= x #x7f))
    (let ((c (code-char x)))
      (unless (alphanumericp c)
        (set-syntax-punctuation *mof-mode-syntax-table* c))))
  ; 以下modeに合わせて設定
  (set-syntax-word *mof-mode-syntax-table* #\_)
  (set-syntax-escape *mof-mode-syntax-table* #\\)
  (set-syntax-string *mof-mode-syntax-table* #\")
  (set-syntax-symbol-prefix *mof-mode-syntax-table* #\$)
  (set-syntax-match *mof-mode-syntax-table* #\( #\)) ; 対応する()に飛ぶ
  (set-syntax-match *mof-mode-syntax-table* #\{ #\})
  (set-syntax-match *mof-mode-syntax-table* #\[ #\])
  (set-syntax-start-multi-comment *mof-mode-syntax-table* "/*")
  (set-syntax-end-multi-comment *mof-mode-syntax-table* "*/")
  (set-syntax-start-c++-comment *mof-mode-syntax-table* #\/)
  (set-syntax-end-c++-comment *mof-mode-syntax-table* #\LFD)
  )

; キーマップ
(defvar *mof-mode-map* nil)
(unless *mof-mode-map*
  (setf *mof-mode-map* (make-sparse-keymap))
  ; 以下キー割当
  (define-key *mof-mode-map* #\{ 'mof-electric-insert)
  (define-key *mof-mode-map* #\} 'mof-electric-close)
  (define-key *mof-mode-map* #\[ 'mof-electric-insert)
  (define-key *mof-mode-map* #\] 'mof-electric-close)
  (define-key *mof-mode-map* #\C-h 'backward-delete-char-untabify-or-selection)
  (define-key *mof-mode-map* #\TAB 'mof-indent-line)
  (define-key *mof-mode-map* #\RET 'mof-close-string-and-newline)
  (define-key *mof-mode-map* #\M-TAB 'mof-completion)
  (define-key *mof-mode-map* #\C-M-q 'indent-sexp)

  (define-key *mof-mode-map* '(#\C-c #\RET) 'mof-find-include-file)

  (define-key *mof-mode-map* '(#\C-c #\C-c) 'mof-comment-region)
  (define-key *mof-mode-map* '(#\C-c #\C-u) 'mof-uncomment-region)
  (define-key *mof-mode-map* #\C-/ 'mof-comment-toggle-line)

  (define-key *mof-mode-map* '(#\C-c #\n) 'mof-what-namespace)
  (define-key *mof-mode-map* '(#\C-c #\v #\v) 'mof-what-corresponding-values-valuemap)
  (define-key *mof-mode-map* '(#\C-c #\v #\g) 'mof-goto-corresponding-values-valuemap)
  (define-key *mof-mode-map* '(#\C-c #\v #\d) 'mof-display-values-valuemap)
  (define-key *mof-mode-map* '(#\C-c #\v #\m) 'mof-generate-valuemap)
  (define-key *mof-mode-map* '(#\C-c #\v #\j) 'mof-generate-java-constants)

  (define-key *mof-mode-map* #\M-NUL 'mof-mark-class)

  (define-key *mof-mode-map* #\C-M-f 'mof-forward-qualifier-list)
  (define-key *mof-mode-map* #\C-M-b 'mof-backward-qualifier-list)
  (define-key *mof-mode-map* #\C-M-n 'mof-forward-statement)
  (define-key *mof-mode-map* #\C-M-p 'mof-backward-statement)

  (define-key *mof-mode-map* #\MouseMove 'mof-lookup-current-string)
  )

;; ----------------------------------------------------------------------
(defun mof-electric-insert (&optional (arg 1))
  (interactive "*p")
  (self-insert-command arg)
  (mof-indent-line))

(defun mof-electric-close (&optional (arg 1))
  (interactive "*p")
  (self-insert-command arg)
  (mof-indent-line)
  (save-excursion
    (forward-char -1)
    (and (goto-matched-parenthesis)
         (show-matched-parenthesis)))
  t)

(defun mof-newline-and-indent (&optional (arg 1))
  (interactive "*p")
  (delete-trailing-spaces)
  (insert #\LFD arg)
  (mof-indent-line))

;; "hoge_ => "hoge "
;;           "_"
;; "hoge_" => "hoge "
;;            "_"
;; "hoge  _ => "hoge  "
;;             "_"
;; "hoge_hoge" => "hoge "
;;                "_hoge"
;; "_ =>
;;       "_"
;; "_" =>
;;        "_"
;; "_hoge" =>
;;            "_hoge"
(defun mof-close-string-and-newline (&optional (arg 1))
  (interactive "*p")
  (let ((open-string-char)
        (in-string-p (mof-in-string-p))
        (open-string-p (mof-open-string-p))
        (close-string-p (mof-close-string-p)))

    ;; 文字列の中で改行された
    (when in-string-p
      ;; 文字列の開始文字 (" or ') を取得
      (save-excursion
        (mof-goto-start-string)
        (setf open-string-char (following-char)))
      ;; 改行前の文字が (空白 or . or open-string-char or \n) 以外なら空白を挿入
      (unless (or (kanji-char-p (preceding-char))
                  (kana-char-p (preceding-char))
                  (char= (preceding-char) #\SPC)
                  (char= (preceding-char) #\TAB)
                  (char= (preceding-char) open-string-char)
                  (looking-back "\\n"))
        (insert #\SPC))
      ;; 文字列を閉じる
      (insert open-string-char))

    ;; 文字列の外で改行された場合、
    (unless in-string-p
      ;; 文字列が終端した直後なら終端文字 (" or ') を取得
      (save-excursion
        (save-restriction
          (mof-narrow-to-line)
          (mof-skip-comment-and-whitespace-backword)
          (backward-char)
          (if (mof-in-string-p)
              (setf open-string-char (following-char))))))

    ;; 空文字列なら削除. " だけ
    (if (looking-back "\"\"") (delete-char -2))

    ;; 改行する
    (mof-newline-and-indent)

    ;; 新しく文字列を始める
    (when open-string-char
      (if (and in-string-p close-string-p)
          (insert open-string-char)
        (progn
          (insert open-string-char 2)
          (backward-char))))))

; from c-indent-line
(defun mof-indent-line ()
  (interactive "*")
  ; (indent-region (point-min) (point-max)) とされた場合、
  ; 時間がかかって画面が白くなるのを防ぐ
  ; ただし、インデント作業中の画面が描画されることがあるがしかたない。
  (do-events)
  (if (or (not (interactive-p))
          *c-tab-always-indent*
          (save-excursion
            (skip-chars-backward " \t")
            (bolp)))
      (case (save-excursion
              (goto-bol)
              (parse-point-syntax))
        (:string)
        (:comment
         (let ((column (calc-c-comment-indent)))
           (when (integerp column)
             (smart-indentation column))))
        (t
         (let ((column (calc-mof-indent)))
           (when (integerp column)
             (smart-indentation column)))))
    (insert "\t"))
  t)

(defun mof-previous-line ()
  "空行じゃない行まで戻る"
  (while (forward-line -1)
    (unless (or (mof-space-line-p) (mof-comment-line-p))
      (return-from mof-previous-line t))))

(defun mof-space-line-p ()
  "空行なら t"
  (save-excursion
    (goto-bol)
    (looking-at "[ \t]*$")))

(defun mof-comment-line-p ()
  "// コメントなら t"
  (save-excursion
    (goto-bol)
    (looking-at "[ \t]*//")))

(defun mof-in-comment-p ()
  "コメントなら t"
  (eq (parse-point-syntax) :comment))

(defun mof-qualifier-declaration-beginning ()
  "Qualifier 宣言の開始にいるなら t"
  (save-excursion
    (goto-bol)
    (looking-at *mof-qualifier-declaration-regexp*)))

(defun mof-in-qualifier-declaration-p ()
  "Qualifier 宣言の途中にいるなら t"
  (save-excursion
    (while (mof-previous-line)
      (save-restriction
        (mof-narrow-to-line)
        (if (mof-ends-with ";")
            (return-from mof-in-qualifier-declaration-p nil))
        (if (mof-qualifier-declaration-beginning)
            (return-from mof-in-qualifier-declaration-p t))
        ))))

(defun calc-mof-indent ()
  "インデントする数を数える"
  (let ((column (calc-c-indent))
        (in-qualifier-declaration (mof-in-qualifier-declaration-p)))
    ;インデントしていない行だと calc-c-indent が t を返すことがある。
    (if (not (integerp column))
        (setf column 0))

;    (msgbox "c-calc-indent: ~D~%" column)
    ; 前の行を調べる
    (save-excursion
      (when (mof-previous-line)
;        (msgbox "previous line number: ~D~%" (current-line-number))
        (save-restriction
          (cond
           ; Qualifier 宣言の途中なら前の行のインデントをコピー
           (in-qualifier-declaration
;            (msgbox "qualifier-declaration")
            (goto-bol)
            ; 宣言の開始なら : の後の識別子までを読み飛ばす。
            (scan-buffer *mof-qualifier-declaration-regexp* :regexp t :tail t :reverse t)
            (skip-chars-forward " \t")
            (setf column (current-column)))
           ; Qualifier の終了なら
           ; Qualifier 開始時のインデント - *mof-qualifier-offset* する。
           ; calc-c-indent がメソッド中の Qualifier と他の Qualifier
           ; の後では返すインデントの幅が違うため [ まで戻る。
           ((and (mof-ends-with "]")
                 (not (mof-in-method-p)))
            (mof-backward-qualifier-list)
;            (msgbox "end qualifier ~D:~D: ~D - ~D~%"
;                    (current-line-number) (current-column)
;                    (current-column) *mof-qualifier-offset*)
            (setf column (- (current-column) *mof-qualifier-offset*)))
           ))
        ))
;    (msgbox "base indent ~D~%" column)
    ; 現在行を調べる
    (save-excursion
      (goto-bol)
      (skip-chars-forward " \t")
      ; Qualifier の開始なら + *mof-qualifier-offset* する
      ; メソッド中の Qualifier はインデントしない
      (when (and (looking-at "\\[")
                 (not (mof-in-method-p)))
;        (msgbox "begin qualifier: ~D + ~D~%" column *mof-qualifier-offset*)
        (incf column *mof-qualifier-offset*)))
;    (msgbox "result: ~D~%" column)
    column
    ))

;; ----------------------------------------------------------------------
;; menu from csv-mode
(defun mof-menu-add-unit (unit)
  (interactive)
  (let ((unit-menu (get-menu *mof-menu* 'unit)))
    (add-menu-item unit-menu nil unit
                   #'(lambda ()
                       (interactive "*")
                       (insert unit)))))

(defun mof-menu-add-bookmark (name url)
  (interactive)
  (let ((bookmark-menu (get-menu *mof-menu* 'bookmark)))
    (add-menu-item bookmark-menu nil name
                   #'(lambda ()
                       (interactive)
                       (mof-open-browser url)))))

(defun mof-open-browser (url)
  (if *mof-open-browser-function*
      (funcall *mof-open-browser-function* url)
    (shell-execute url t)))

(unless *mof-menu*
  (setf *mof-menu* (copy-menu-items
                    (define-popup-menu
                      (:popup 'command "外部ﾂｰﾙ(&T)") ;; mof-define-command で子要素を追加
                      (:popup 'unit "単位の挿入(&U)") ;; すぐ後で子要素を追加
                      (:item nil "ｸﾗｽ･ﾒｿｯﾄﾞ一覧(&L)..." 'list-function)
                      (:item nil "現在のｸﾗｽ･ﾒｿｯﾄﾞ一覧..." 'mof-list-current-class-function)
                      :sep
                      (:item nil "全MOFﾌｧｲﾙをｽﾍﾟﾙﾁｪｯｸする..." 'mof-spell-check-dialog)
                      (:item nil "全文字列をｽﾍﾟﾙﾁｪｯｸ(&S)" 'mof-spell-check-all-string)
                      (:item nil "直下の文字列をｽﾍﾟﾙﾁｪｯｸ" 'mof-spell-check-string)
                      :sep
                      (:item nil "直下のｲﾝｸﾙｰﾄﾞﾌｧｲﾙを開く" 'mof-find-include-file)
                      (:item nil "ｲﾝｸﾙｰﾄﾞﾌｧｲﾙを開く(&O)..." 'mof-find-include-file-dialog)
                      :sep
                      (:item nil "ﾘｰｼﾞｮﾝをｺﾒﾝﾄｱｳﾄ" 'mof-comment-region)
                      (:item nil "ﾘｰｼﾞｮﾝをｺﾒﾝﾄ解除" 'mof-uncomment-region)
                      (:item nil "ｺﾒﾝﾄをﾄｸﾞﾙ" 'mof-comment-toggle-line
                       '(lambda () (if (or (mof-in-comment-p)
                                           (mof-comment-line-p))
                                       :check)))
                      :sep
                      (:item nil "名前空間を表示(&)" 'mof-what-namespace)
                      (:item nil "対応するValues/ValueMapを表示(&V)" 'mof-what-corresponding-values-valuemap
                       '(lambda () (unless (mof-in-qualifier-list-p) :disable)))
                      (:item nil "対応するValues/ValueMapに移動(&G)" 'mof-goto-corresponding-values-valuemap
                       '(lambda () (unless (mof-in-qualifier-list-p) :disable)))
                      (:item nil "Values/ValueMapの対応を表示(&D)" 'mof-display-values-valuemap
                       '(lambda () (unless (mof-in-qualifier-list-p) :disable)))
                      (:item nil "ValueMap生成(&M)" 'mof-generate-valuemap
                       '(lambda () (unless (mof-in-qualifier-list-p) :disable)))
                      (:item nil "ValueMapに対応するJavaの定数を生成(てきとー)(J)" 'mof-generate-java-constants
                       '(lambda () (unless (mof-in-qualifier-list-p) :disable)))
                      :sep
                      (:item nil "全MOFﾌｧｲﾙをｲﾝﾃﾞﾝﾄする..." 'mof-indent-dialog)
                      (:item nil "ﾊﾞｯﾌｧをｲﾝﾃﾞﾝﾄする" 'mof-indent-buffer)
                      (:item nil "現在のｸﾗｽをｲﾝﾃﾞﾝﾄする" 'mof-indent-class)
                      :sep
                      (:item nil "ｸﾗｽをﾏｰｸする" 'mof-mark-class)
                      (:item nil "ﾌﾟﾛﾊﾟﾃｨとかをﾏｰｸする" 'mof-mark-feature)
                      (:item nil "ｸｵﾘﾌｧｲｱをﾏｰｸする" 'mof-mark-qualifier-list)
                      :sep
                      (:item nil "次のｸﾗｽ(&F)" 'forward-paragraph)
                      (:item nil "前のｸﾗｽ(&B)" 'backward-paragraph)
                      (:item nil "次のﾌﾟﾛﾊﾟﾃｨとか" 'mof-forward-statement)
                      (:item nil "前のﾌﾟﾛﾊﾟﾃｨとか" 'mof-backward-statement)
                      (:item nil "次のｸｵﾘﾌｧｲｱ" 'mof-forward-qualifier-list)
                      (:item nil "前のｸｵﾘﾌｧｲｱ" 'mof-backward-qualifier-list)
                      :sep
                      (:popup 'bookmark "お気に入り") ;; すぐ後で子要素を追加
                      )
                    (create-menu 'mof)))
  ;; setup unit menu
  (dolist (unit (sort *mof-unit-list* #'string<))
    (mof-menu-add-unit unit))
  ;; setup bookmark menu
  (dolist (bookmark *mof-bookmark-list*)
    (mof-menu-add-bookmark (car bookmark) (cdr bookmark))))

(defun insert-mof-menu (&key (menu (current-menu))
                             (position *mof-menu-position*)
                             (menu-name *mof-menu-name*))
  "mof-mode: MOF メニューを追加したローカルメニューの設定"
  (when (menup menu)
    (setq menu (copy-menu-items menu (create-menu 'mof)))
    (delete-mof-menu menu)
    (cond
     ((and (numberp position) (integerp position))
      (insert-popup-menu menu position *mof-menu* menu-name))
     ((and (symbolp position) (get-menu-position menu position))
      (insert-popup-menu menu (get-menu-position menu position)
                         *mof-menu* menu-name))
     (t
      (add-popup-menu menu *mof-menu* menu-name)))
    (use-local-menu menu)))

(defun delete-mof-menu (&optional (menu (current-menu)))
  "mof-mode: メニューを削除"
  (let (ret)
    (if (menup menu)
        (while (delete-menu menu 'ed::mof)
          (setq ret t)))
    ret))

(defun insert-mof-menu-all-buffers ()
  "mof-mode: 起動時のローカルメニューの設定"
  (save-excursion
    (dolist (buffer (buffer-list))
      (set-buffer buffer)
      (when (eq buffer-mode 'mof-mode)
        (insert-mof-menu)))))

(unless *app-menu*
  ;; local-menu は他のメニューが全て生成された後に変更すべきなので
  ;; *init-app-menus-hook* でなく *post-startup-hook* にしてみた。
  (add-hook '*post-startup-hook* 'insert-mof-menu-all-buffers))

;; ----------------------------------------------------------------------
;; command

; obsolute, use mof-define-command
(defun mof-make-command (symbol key command opts &optional name output dir)
  (mof-define-command symbol command opts :key key :name name :output output :dir dir))

(defun mof-define-command (symbol command
                                  &key opts before-hook after-hook
                                  wait key name output dir)
  (setf (symbol-function symbol)
        #'(lambda ()
            (interactive)
            (let (ret)
              (unwind-protect
                  (when (if before-hook (funcall before-hook) t)
                    (setf ret (mof-execute-command-with-current-buffer
                               command opts output dir wait)))
                (if after-hook
                    (funcall after-hook ret))))))
  (when name
    (let ((command-menu (get-menu *mof-menu* 'command)))
      ;; メニューに追加。
      (delete-menu command-menu symbol)
      (add-menu-item command-menu symbol (or name command) symbol
                     ;; ファイル名がない場合 disable
                     '(lambda ()
                       (unless (get-buffer-file-name)
                         :disable)))))
  (when (characterp key)
    (define-key *mof-mode-map* key symbol)))

;; mofcomp と mof check をメニューに追加
(mof-define-command 'mof-lint *mof-lint-command*
                    :key #\F5 :name "MOF Check")
(mof-define-command 'mof-compile *mof-compile-command*
                    :key #\S-F5 :name "MOF Compile"
                    :before-hook '(lambda ()
                                   (yes-or-no-p "本当に mofcomp する?")))

;; return <process> if not wait
;;        <exit status> if wait
(defun mof-execute-command-with-current-buffer (cmd opts &optional out dir wait)
  (if (buffer-modified-p)
      (save-buffer))
  (unless (get-buffer-file-name)
    (plain-error "ファイル名がないよん"))

  (let* ((command (format nil "~A ~{~A ~}\"~A\""
                          cmd opts (get-buffer-file-name)))
         (output (mof-command-buffer (or out "*MOF: Command*")))
         (directory (or dir (directory-namestring cmd)))
         (proc))
    (message command)
    (set-buffer output)
    (insert (format nil "~A> ~A~%" directory command))
    (setf proc (make-process (map-slash-to-backslash command)
                             :output output
                             :exec-directory directory))
    (if wait
        (let ((status (mof-wait proc)))
          (insert (format nil "> Exit Status: ~D~%" status))
          status)
      proc)))

;; buffer for execute command
(defun mof-command-buffer (buffname)
  (let (new)
    (unless (bufferp buffname)
      (setq buffname (or (find-buffer buffname)
                         (progn
                           (setq new t)
                           (create-new-buffer buffname)))))
    (erase-buffer buffname)
    (update-visited-file-modtime)
    (pop-to-buffer buffname t)
    (if new (setq need-not-save t))
    (set-buffer-modified-p nil)
    (selected-buffer)))

;; ----------------------------------------------------------------------
;; indent
(defun mof-indent-directory (dir &optional depth)
  (interactive "Indent mof files: \np")
  (mof-each-file dir depth 'mof-indent-buffer))

; dialog (maketag.l)
(defvar *mof-indent-dialog-template*
  '(dialog 0 0 226 81
    (:caption "MOFﾌｧｲﾙをｲﾝﾃﾞﾝﾄする")
    (:font 9 "ＭＳ Ｐゴシック")
    (:control
     (:static nil "ｿｰｽﾃﾞｨﾚｸﾄﾘ(&S):" #x50020000 7 7 58 8)
     (:edit src nil #x50810080 7 19 148 14)
     (:button subdir "ついでにｻﾌﾞﾃﾞｨﾚｸﾄﾘも(&U)" #x50010003 7 48 102 10)
     (:static nil "検索する階層の深さ(&D):" #x50020000 9 63 80 8)
     (:edit depth nil #x50810086 89 60 36 14)
     (:spin depthspin "Spin1" #x500000b6 119 55 9 14)
     (:static nil "(0は無制限)" #x50020000 129 63 48 8)
     (:button IDOK "OK" #x50010001 169 7 50 14)
     (:button IDCANCEL "ｷｬﾝｾﾙ" #x50010000 169 24 50 14)
     (:button ref "参照(&R)..." #x50010000 169 41 50 14))))

(define-history-variable *mof-indent-depth* 0)
(define-history-variable *mof-indent-subdir* nil)

(defun mof-indent-dialog ()
  (interactive)
  (multiple-value-bind (result data)
      (dialog-box *mof-indent-dialog-template*
                  (list (cons 'src (default-directory))
                        (cons 'subdir *mof-indent-subdir*)
                        (cons 'depthspin
                              (if *mof-indent-subdir*
                                  *mof-indent-depth*
                                0)))
                  '((src :non-null "ｿｰｽﾃﾞｨﾚｸﾄﾘを入力して" :enable (IDOK))
                    (depth :type integer :min 0 :max 10000
                           :range-error "階層の深さ0以上です"
                           :type-error "数値を入力してください")
                    (depthspin :min 0 :max 10000)
                    (ref :related src :directory-name-dialog (:title "参照"))))
    (when result
      (setq *mof-indent-subdir* (cdr (assoc 'subdir data)))
      (setq *mof-indent-depth* (cdr (assoc 'depth data)))
      (mof-indent-directory (cdr (assoc 'src data))
                            (and *mof-indent-subdir*
                                 *mof-indent-depth*)))))

(defun mof-indent-buffer ()
  (interactive "*")
  (save-excursion
    (indent-region (point-min) (point-max))))

(defun mof-indent-class ()
  (interactive "*")
  (save-excursion
    (multiple-value-bind (start end)
        (mof-class-points)
      (when (< start (point) end)
        (indent-region start end)
        (message "indent class")))))

;; ----------------------------------------------------------------------
;; comment
(defun mof-comment-toggle-line ()
  "mof-mode: 行のコメントをトグル"
  (interactive "*")
  (save-excursion
    (let ((start (progn (goto-bol) (point)))
          (end (progn (goto-eol) (point))))
      (if (mof-in-comment-p)
          (mof-uncomment-region start end)
        (mof-comment-region start end)))))

(defun mof-comment-region (start end)
  "mof-mode: リージョンをコメント"
  (interactive "*r")
  (if (< end start) (rotatef start end))

  (save-excursion
    (save-restriction
      (narrow-to-region (progn (goto-char end) (goto-eol) (point))
                        (progn (goto-char start) (goto-bol) (point)))
      (loop
        (goto-bol)
        (insert comment-start)
        (goto-eol)
        (insert comment-end)
        (unless (forward-line 1) (return)))
      )))

(defun mof-uncomment-region (start end)
  "mof-mode: リージョンをコメント"
  (interactive "*r")
  (if (< end start) (rotatef start end))
  (save-excursion
    (save-restriction
      (narrow-to-region (progn (goto-char end) (goto-eol) (point))
                        (progn (goto-char start) (goto-bol) (point)))
      (loop
        (goto-bol)
        (if (scan-buffer comment-start :regexp t)
            (delete-region (match-beginning 0) (match-end 0)))
        (goto-eol)
        (if (scan-buffer comment-end :regexp t :reverse t)
            (delete-region (match-beginning 0) (match-end 0)))
        (unless (forward-line 1) (return)))
      )))

;; ----------------------------------------------------------------------
;; list function

(defun mof-list-current-class-function ()
  (interactive)
  (save-restriction
    (mof-narrow-to-class)
    (if (not (boundp '*list-function-modified*))
        (list-function)
      (progn
        ;; list-function は build-summary-* の結果をキャッシュする。
        ;; キャッシュの有効性は buffer-modified-count を保存し判断している。
        (let ((modified-count *list-function-modified*)
              (modified-list *list-function-list*))
          (setf *list-function-modified* 0) ;; invalidate cache
          (unwind-protect
              (list-function)
            (setf *list-function-modified* modified-count)
            (setf *list-function-list* modified-list)))))))

;; ----------------------------------------------------------------------
;; include
(defvar *mof-include-file-regexp*
  "#pragma[ \t]+include[ \t]*([ \t]*\"\\([^\"]+\\)\"")

(defun mof-find-include-file ()
  (interactive)
  (let (filename)
    (save-excursion
      (save-restriction
        (mof-narrow-to-line)
        (goto-char (point-min))
        (unless (scan-mof *mof-include-file-regexp*)
          (plain-error "#pragma include の上でやってね"))
        (setf filename (match-string 1))))
    (mof-find-file filename)))

(defun mof-find-include-file-dialog ()
  (interactive)
  (let (include-list include-file)
    (save-excursion
      (save-restriction
        (goto-char (point-min))
        (while (scan-buffer *mof-include-file-regexp* :regexp t :tail t)
          (push (list (current-line-number) (match-string 1)) include-list))))
    (unless include-list
      (plain-error "include しているファイルはないっす"))
    (setf include-file (mof-select-list-dialog "include ファイル一覧"
                                               (reverse include-list)))
    (when include-file
      (mof-find-file (cadr include-file)))))

(defun mof-find-file (filename)
  (dolist (d (cons "." *mof-include-directory-list*))
    (when (file-exist-p (merge-pathnames filename d))
      (find-file (merge-pathnames filename d))
      (return-from mof-find-file t)))
  (plain-error (concat "ファイルが見つかりません。" filename)))

;; ----------------------------------------------------------------------
;; namespace
(defvar *mof-default-namespace*
  "\\\\root\\cimv2")
(defvar *mof-namespace-regexp*
  "#pragma[ \t]+namespace[ \t]*([ \t]*\"\\([^\"]+\\)\"")

(defun mof-what-namespace
  (&optional (fn '(lambda (x) (popup-string x (point)))))
  (interactive)
  (funcall fn (save-excursion
                (if (scan-mof *mof-namespace-regexp* :reverse t)
                    (match-string 1)
                  (concat *mof-default-namespace* " (Default namespace)")))))

;; ----------------------------------------------------------------------
;; values/valuemap
(defun mof-what-corresponding-values-valuemap
  (&optional (fn '(lambda (x) (popup-string x (point)))))
  (interactive)
  (funcall fn (cdr (mof-get-corresponding-values-valuemap))))

(defun mof-goto-corresponding-values-valuemap ()
  (interactive)
  (goto-char (car (mof-get-corresponding-values-valuemap))))

;; (start-point . "parameter")
(defun mof-get-corresponding-values-valuemap ()
  (unless (mof-in-qualifier-list-p)
    (plain-error "Qualifier の中でやってね"))
  (let ((values-or-value-map (mof-lookup-qualifier))
        src dst index)
    (unless (or (string-equal values-or-value-map "values")
                (string-equal values-or-value-map "valuemap"))
      (plain-error "Values/ValueMap の中でやってね"))

    (setf src (mof-qualifier-parameters values-or-value-map))
    (setf dst (mof-qualifier-parameters (if (string-equal values-or-value-map "values")
                                            "valuemap" "values")))
    (setf index (mof-index-of (mof-lookup-current-string0) (mapcar #'cdr src)))
    (unless (<= 0 index (1- (length (mapcar #'cdr dst))))
        (plain-error "対応する Values/ValueMap がないっす"))
    (nth index dst)))

(defun mof-generate-valuemap (&optional (fold-width 65))
  (interactive "*p")
  (unless (mof-in-qualifier-list-p)
    (plain-error "Qualifier の中でやってね"))
  (let ((value-len (length (mapcar #'cdr (mof-qualifier-parameters "Values")))))
    (when (= 0 value-len)
      (plain-error "Values がないっす"))
    (insert "ValueMap { ")
    (dotimes (i value-len)
      (insert (format nil "\"~D\"" i))
      (unless (= i (1- value-len)) ;unless last element
        (insert ", "))
      (when (< fold-width (current-column))
        (mof-newline-and-indent)))
    (insert " },")
    (mof-newline-and-indent)))

;; (format format-string <value> <property or method name> <javalized value> <valuemap>
(defvar *mof-java-template* "
   /**
    * ~A.~A: ~A
    */
   public static final int ~A = ~A;~%")

(defun mof-generate-java-constants (&optional (format-string *mof-java-template*)
                                              (filter 'mof-javalize))
  (interactive)
  (unless (mof-in-feature-p)
    (plain-error "メソッドかプロパティの中でやって"))
  (let ((feature-name (mof-current-class-feature-name))
        (class-name (mof-current-class-name)))
    ;; get method/property name
    (mof-display-each-values-valuemap
     #'(lambda (value value-map)
         (format t format-string
                 class-name
                 feature-name
                 value
                 (funcall filter (concat feature-name "_" value))
                 value-map)))))

(defun mof-display-values-valuemap (&optional (format-string "~A => ~A~%"))
  (interactive)
  (mof-display-each-values-valuemap
   #'(lambda (value value-map)
       (format t format-string value-map value))))

(defun mof-display-each-values-valuemap (fn)
  (interactive)
  (unless (mof-in-qualifier-list-p)
    (plain-error "Qualifier の中でやってね"))
  (let* ((value-list (mapcar #'cdr (mof-qualifier-parameters "values")))
         (value-map (mapcar #'cdr (mof-qualifier-parameters "valuemap"))))
    (unless (or value-list value-map)
      (plain-error "Values/ValueMap がないっす"))
    (with-output-to-temp-buffer ("*MOF Values*")
      (dotimes (i (max (length value-list) (length value-map)))
        (funcall fn (nth i value-list) (nth i value-map))))))

;; ----------------------------------------------------------------------
;; statement
(defun mof-forward-statement (&optional reverse)
  (interactive)
  (scan-mof *mof-statement-regexp* :no-dup t :reverse reverse))

(defun mof-backward-statement ()
  (interactive)
  (mof-forward-statement t))

;; ----------------------------------------------------------------------
;; class
(defun mof-forward-class (&optional reverse)
  (interactive)
  (scan-mof *mof-production-regexp* :no-dup t :reverse reverse))

(defun mof-backward-class ()
  (interactive)
  (mof-forward-class t))

(defun mof-start-class-p ()
  (looking-at *mof-production-regexp*))

(defun mof-class-points0 (reverse)
  (save-excursion
    ;; class の開始点にいないなら戻る
    (unless (mof-start-class-p)
      (mof-forward-class reverse))
    ;; qualifier があったらそれも戻る
    (mof-skip-qualifier-list-backward)
    (values (point)
            (progn
              ;; クラスの最後に行く
              (scan-mof "};" :tail t)
              (point)))))

(defun mof-class-points ()
  ;; 逆方向にクラスを検索
  (multiple-value-bind (start end)
      (mof-class-points0 t)
    (when (< start (point) end)
      (return-from mof-class-points (values start end))))
  ;; 順方向にクラスを検索
  (multiple-value-bind (start end)
      (mof-class-points0 nil)
    (when (< start (point) end)
      (return-from mof-class-points (values start end))))
  ;; クラス内にいない
  (values (point) (point)))

(defun mof-in-class-p ()
  (interactive)
  (multiple-value-bind (start end)
      (mof-class-points)
    (< start (point) end)))

(defun mof-mark-class ()
  (interactive)
  (multiple-value-bind (start end)
      (mof-class-points)
    (goto-char end)
    (set-mark-command)
    (goto-char start)))

(defun mof-narrow-to-class ()
  (interactive)
  (multiple-value-bind (start end)
      (mof-class-points)
    (narrow-to-region start end)))

(defun mof-current-class-name ()
  (save-excursion
    (save-restriction
      (mof-narrow-to-class)
      (goto-char (point-min))
      (when (scan-mof *mof-production-regexp*)
        (match-string 2)))))

;; ----------------------------------------------------------------------
;; class feature
(defun mof-forward-feature (&optional reverse)
  (interactive)
  (scan-mof *mof-class-feature-regexp* :no-dup t :reverse reverse))

(defun mof-backward-feature ()
  (interactive)
  (mof-forward-feature t))

(defun mof-start-feature-p ()
  (save-excursion
    (skip-chars-forward " \t\r\f\n")
    (looking-at *mof-class-feature-regexp*)))

(defun mof-feature-points (&optional reverse)
  (save-excursion
    ;; feature の開始点にいないなら戻る
    (unless (mof-start-feature-p)
      (mof-forward-feature reverse))
    ;; qualifier があったらそれも戻る
    (mof-skip-qualifier-list-backward)
    (values (point)
            (progn
              ;; クラスの最後に行く
              (scan-mof ";" :tail t)
              (point)))))

(defun mof-mark-feature ()
  (interactive)
  (unless (or (mof-in-feature-p)
              (mof-start-feature-p))
    (mof-forward-feature))
  (multiple-value-bind (start end)
      (mof-feature-points)
    (goto-char end)
    (set-mark-command)
    (goto-char start)))

(defun mof-narrow-to-feature ()
  (interactive)
  (multiple-value-bind (start end)
      (mof-feature-points)
    (narrow-to-region start end)))

(defun mof-in-feature-p ()
  (interactive)
  (multiple-value-bind (start end)
      (mof-feature-points)
    (< start (point) end)))

(defun mof-in-method-p ()
  (save-excursion
    (let ((opoint (point)))
      (when (scan-mof *mof-class-feature-regexp* :reverse t :tail t)
        (when (looking-back "(")
          (backward-char)
          (< (point) opoint (progn
                              (scan-mof ");") ; (goto-matched-parenthesis) は使えない
                              (point))))))))

(defun mof-method-first-argument-p ()
  (save-excursion
    (save-restriction
      (let ((opoint (point)))
        (when (scan-mof *mof-class-feature-regexp* :reverse t :tail t)
          (narrow-to-region (point) opoint)
          (goto-char (point-min))
          (not (scan-mof ",")))))))

(defun mof-current-class-feature-name ()
  (save-excursion
    (save-restriction
      (mof-narrow-to-feature)
      (goto-char (point-min))
      (when (scan-mof *mof-class-feature-regexp*)
        (match-string 2)))))

;; ----------------------------------------------------------------------
;; qualifier-list
(defun mof-forward-qualifier-list ()
  (interactive)
  (if (or (mof-in-qualifier-list-p)
          (save-excursion (forward-char) (mof-in-qualifier-list-p)))
      (mof-goto-end-qualifier-list)
    (mof-goto-start-qualifier-list)))

(defun mof-backward-qualifier-list ()
  (interactive)
  (if (or (mof-in-qualifier-list-p)
          (save-excursion (backward-char) (mof-in-qualifier-list-p)))
      (mof-goto-start-qualifier-list t)
    (mof-goto-end-qualifier-list t)))

(defun mof-skip-qualifier-list-backward ()
;  (msgbox "mof-skip-qualifier-list-backward")
  (when (save-excursion
          (mof-skip-comment-and-whitespace-backword)
          (looking-back "]"))
;    (msgbox "has Qualifier!")
    (mof-goto-start-qualifier-list t)))

(defun mof-goto-start-qualifier-list (&optional reverse)
;  (msgbox "mof-goto-start-qualifier-list")
  (scan-mof "\\[" :reverse reverse))

(defun mof-goto-end-qualifier-list (&optional reverse)
;  (msgbox "mof-goto-end-qualifier-list: ~D ~D" (current-line-number) (current-column))
  (scan-mof "\\]" :reverse reverse :tail t))

(defun mof-mark-qualifier-list ()
  (interactive)
  (multiple-value-bind (start end)
      (mof-qualifier-list-points)
    (goto-char end)
    (set-mark-command)
    (goto-char start)))

(defun mof-narrow-to-qualifier-list ()
  (interactive)
  (when (mof-in-qualifier-list-p)
    (multiple-value-bind (start end)
        (mof-qualifier-list-points)
      (narrow-to-region start end))))

(defun mof-in-qualifier-list-p ()
  (multiple-value-bind (start end)
      (mof-qualifier-list-points)
    (< start (point) end)))

(defun mof-qualifier-list-points ()
  (save-excursion
    (values-list
     (reverse (list
               (progn
                 (mof-goto-end-qualifier-list)
                 (point))
               (progn
                 (or (and (backward-char) (goto-matched-parenthesis))
                     (mof-goto-start-qualifier-list t))
                 (point)))))))

;; ----------------------------------------------------------------------
;; qualifier

;; (start-point . "parameter")
(defun mof-qualifier-parameters (qualifier-name)
  (let (result)
    (mof-each-qualifier-parameters
     qualifier-name
     #'(lambda (start param)
         (push (cons start param) result)))
    (reverse result)))

(defun mof-each-qualifier-parameters (qualifier-name fn)
  (unless (and (mof-in-qualifier-list-p) fn)
    (return-from mof-each-qualifier-parameters))
  (let (start tmp-list result)
    (save-excursion
      (save-restriction
        (when (mof-narrow-to-qualifier qualifier-name)
          (goto-char (point-min))
          ;; { "first value", "second " "value", ... "final value" }
          (while (scan-mof "\"\\([^\"]*\\)\"" :tail t)
            ;; 文字列が継続するかもしれないので、とりあえず tmp-list に push
            (push (match-string 1) tmp-list)
            (unless start
              (setf start (match-beginning 1)))
            ;; 文字列が継続しないなら tmp-list を結合して result に追加
            (unless (looking-at "[ \t\r\f\n]*\"")
              (funcall fn start (format nil "~{~A~}" (reverse tmp-list)))
              (setf tmp-list nil start nil)))
          )))))

(defun mof-narrow-to-qualifier (&optional (qualifier-name *mof-identifier-regexp*))
  (interactive)
  (unless (mof-in-qualifier-list-p)
    (plain-error "Qualifier の中でやってね"))
  (let (start end)
    (save-excursion
      (mof-narrow-to-qualifier-list)
      (goto-char (point-min))
      (when (scan-mof (format nil "\\<\\(~A\\)[ \t\r\f\n]*[],({]"
                              qualifier-name) :tail t)
        (setf start (match-beginning 1))
        (setf end (match-end 1))
        (backward-char)
        (if (and (looking-at "[({]") (goto-matched-parenthesis))
            (setf end (1+ (point))))
        (narrow-to-region start end)))))

(defun mof-lookup-qualifier ()
  (save-excursion
    (skip-chars-backward " \r\t\f\n")
    (when (and (mof-in-qualifier-list-p)
               (not (mof-in-string-p))
               (or (looking-back ",")
                   (looking-back "[")
                   (looking-at "[ \r\t\f\n]*[]}]")))
      (return-from mof-lookup-qualifier nil))
    (save-restriction
      (mof-narrow-to-qualifier-list)
      (when (scan-mof (format nil "\\<\\(~A\\)[ \t\r\f\n]*[]({,]"
                              *mof-identifier-regexp*)
                      :reverse t)
        (match-string 1)))))

;; ----------------------------------------------------------------------
;; spell check
(defvar *mof-spell-check-function* 'ispell-region)

(defun mof-spell-check-region (start end)
  (if *mof-spell-check-function*
      (funcall *mof-spell-check-function* start end)
    (ispell-region start end)))

(defun mof-spell-check-string ()
  (interactive)
  (when (mof-in-virtual-string-p)
    (save-excursion
      (let ((end (save-excursion (mof-goto-end-virtual-string) (point)))
            (start (save-excursion (mof-goto-start-virtual-string) (point))))
        (mof-spell-check-region start end)))))

(defun mof-spell-check-all-string ()
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (mof-each-string 'mof-spell-check-region)))

(defun mof-spell-check-directory (dir &optional depth)
  (interactive "Spell check mof files: \np")
  (mof-each-file dir depth 'mof-spell-check-all-string))

(defvar *mof-spell-check-dialog-template*
  '(dialog 0 0 226 81
    (:caption "MOFﾌｧｲﾙをｽﾍﾟﾙﾁｪｯｸする")
    (:font 9 "ＭＳ Ｐゴシック")
    (:control
     (:static nil "ｿｰｽﾃﾞｨﾚｸﾄﾘ(&S):" #x50020000 7 7 58 8)
     (:edit src nil #x50810080 7 19 148 14)
     (:button subdir "ついでにｻﾌﾞﾃﾞｨﾚｸﾄﾘも(&U)" #x50010003 7 48 102 10)
     (:static nil "検索する階層の深さ(&D):" #x50020000 9 63 80 8)
     (:edit depth nil #x50810086 89 60 36 14)
     (:spin depthspin "Spin1" #x500000b6 119 55 9 14)
     (:static nil "(0は無制限)" #x50020000 129 63 48 8)
     (:button IDOK "OK" #x50010001 169 7 50 14)
     (:button IDCANCEL "ｷｬﾝｾﾙ" #x50010000 169 24 50 14)
     (:button ref "参照(&R)..." #x50010000 169 41 50 14))))

(define-history-variable *mof-spell-check-depth* 0)
(define-history-variable *mof-spell-check-subdir* nil)

(defun mof-spell-check-dialog ()
  (interactive)
  (multiple-value-bind (result data)
      (dialog-box *mof-spell-check-dialog-template*
                  (list (cons 'src (default-directory))
                        (cons 'subdir *mof-spell-check-subdir*)
                        (cons 'depthspin
                              (if *mof-spell-check-subdir*
                                  *mof-spell-check-depth*
                                0)))
                  '((src :non-null "ｿｰｽﾃﾞｨﾚｸﾄﾘを入力して" :enable (IDOK))
                    (depth :type integer :min 0 :max 10000
                           :range-error "階層の深さ0以上です"
                           :type-error "数値を入力してください")
                    (depthspin :min 0 :max 10000)
                    (ref :related src :directory-name-dialog (:title "参照"))))
    (when result
      (setq *mof-spell-check-subdir* (cdr (assoc 'subdir data)))
      (setq *mof-spell-check-depth* (cdr (assoc 'depth data)))
      (mof-spell-check-directory (cdr (assoc 'src data))
                                 (and *mof-spell-check-subdir*
                                      *mof-spell-check-depth*)))))

;; ----------------------------------------------------------------------
;; string
(defun mof-kill-current-string ()
  (interactive)
  (ed::kill-new (mof-lookup-current-string0)))

(defun mof-each-string (fn)
  (while (scan-buffer "\"")
    (forward-char 1)
    (let ((end (save-excursion (mof-goto-end-virtual-string) (point)))
          (start (save-excursion (mof-goto-start-virtual-string) (point))))
      (when (and start end)
        (goto-char end)
        (funcall fn start end)))))

(defun mof-current-string-output-to-buffer ()
  (interactive)
  (let ((buffer (selected-buffer)))
    (with-output-to-temp-buffer ("*MOF String*")
      (save-window-excursion
        (set-buffer buffer)
        (format t (mof-lookup-current-string0))))))

(defun mof-in-string-p ()
  (eq (parse-point-syntax) :string))

(defun mof-in-virtual-string-p ()
  (when (mof-in-string-p)
    (return-from mof-in-virtual-string-p t))
  (let ((start (save-excursion (mof-goto-start-virtual-string) (point)))
        (end (save-excursion (mof-goto-end-virtual-string) (point))))
    (< start (point) end)))

(defun mof-close-string-p ()
  (when (mof-in-string-p)
    (let ((opoint (point)))
      (save-excursion
        (save-restriction
          (mof-narrow-to-line)
          (mof-goto-end-string)
          (and (not (= (point) opoint))
               (or (looking-back "'")
                   (looking-back "\""))))))))

(defun mof-open-string-p ()
  (when (mof-in-string-p)
    (not (mof-close-string-p))))

(defun mof-goto-start-string ()
  (while (and (mof-in-string-p)
              (or (skip-syntax-spec-backward "^\"")
                  (skip-syntax-spec-backward "\"")))))

(defun mof-goto-end-string ()
  (while (and (mof-in-string-p)
              (or (skip-syntax-spec-forward "^\"")
                  (skip-syntax-spec-forward "\"")))))

(defun mof-goto-start-virtual-string ()
  (while (and (mof-in-string-p)
              (or (skip-syntax-spec-backward "^\"")
                  (skip-chars-backward " \"\t\r\f\n"))))
  (skip-chars-forward " \t\r\f\n"))

(defun mof-goto-end-virtual-string ()
  (while (and (mof-in-string-p)
              (or (skip-syntax-spec-forward "^\"")
                  (skip-chars-forward " \"\t\r\f\n"))))
  (skip-chars-backward " \t\r\f\n"))

;;----------------------------------------------------------------------
;; util
(defun mof-javalize (str)
  (let ((result str))
    (setf result (substitute-string result "\\([a-z0-9_]\\)\\([A-Z]\\)" "\\1_\\2"))
    (setf result (substitute-string result "[^a-zA-Z0-9_$]" "_"))
    (setf result (substitute-string result "_+" "_"))
    (string-upcase result)))

(defun mof-each-file (dir depth fn)
  (save-window-excursion
    (let ((files (directory dir :recursive (not (null depth)) :depth depth :file-only t
                            :wild "*.mof"))
          (buffer)
          (i 0))
      (when (zerop (length files))
        (return-from mof-each-file))

      (long-operation
        (message "Processing ~D mof files..." (length files))
        (unwind-protect
            (progn
              (setf buffer (create-new-buffer "*MOF Temp*"))
              (set-buffer buffer)
              (mof-mode)
              (dolist (mof files)
                (do-events)
                (incf i)
                (message "~D/~D (~D%): ~A"
                         i (length files)
                         (round (* (/ i (length files)) 100))
                         mof)
                (erase-buffer buffer)
                (insert-file-contents (merge-pathnames mof dir))
                (set-buffer-modified-p nil)
                (funcall fn)
                (when (buffer-modified-p)
                  (write-file (merge-pathnames mof dir)))))
          (delete-buffer buffer))
        (message "Processing ~D mof files ... done" (length files)))
      ;; 開いていたファイルを変更したかもしれないので更新
      (verify-buffers-file-modtime))))

(defun mof-select-list-dialog (caption list)
  (interactive)
  (multiple-value-bind (result data)
      (dialog-box `(dialog 0 0 286 162
                           (:caption ,caption)
                           (:font 9 "ＭＳ Ｐゴシック")
                           (:control
                            (:listbox list nil #x50b10111 7 7 216 148)
                            (:button IDOK "OK" #x50010001 229 7 50 14)
                            (:button IDCANCEL "ｷｬﾝｾﾙ" #x50010000 229 24 50 14)))
                  (list (cons 'list list))
                  `((list :column (-6 ,(apply #'max (mapcar #'(lambda (x)
                                                                (length (cadr x)))
                                                            list)))
                          :must-match t :enable (IDOK) :label 1)))
    (when result
      (cdr (assoc 'list data)))))

(defun mof-ends-with (end-string)
  "mof-mode: 現在行がコメント、空白を無視して指定された文字列で終了していたら t"
  (goto-eol)
  (mof-skip-comment-and-whitespace-backword)
  (looking-back end-string))

(defun mof-skip-comment-and-whitespace-backword ()
  "mof-mode: コメントと空白文字を読み飛ばす"
  (while (or (mof-skip-comment-backword)
             (skip-chars-backward " \t\r\f\n"))))

(defun mof-skip-comment-backword ()
  "mof-mode: 現在のポイントからコメントを読み飛ばす。
読み飛ばしたら t。"
  (while (and (eq (parse-point-syntax) :comment)
              (backward-char))))

(defun mof-wait (proc &optional (interval 0.1))
  (while (eq (process-status proc) ':run)
    (sit-for interval))
  (process-exit-code proc))

(defun mof-index-of (v l)
  (dotimes (i (length l))
    (when (string= v (nth i l))
      (return-from mof-index-of i)))
  -1)

(defvar-local *mof-last-range-begin* 0)
(defvar-local *mof-last-range-end* 0)
(defun mof-lookup-current-string ()
  (interactive)
  (when t ;;;
    (with-selected-window
      (set-window *last-mouse-window*)
      (save-excursion
        (goto-last-mouse-point)
        (cond ((eolp)
               (setq *mof-last-range-begin* nil))
              ((and *mof-last-range-begin*
                    (<= *mof-last-range-begin* (point))
                    (< (point) *mof-last-range-end*))
               (continue-popup))
              ((mof-in-string-p)
               (let ((end (save-excursion (mof-goto-end-string) (point)))
                     (beg (save-excursion (mof-goto-start-string) (point))))
                 (setq *mof-last-range-begin* beg)
                 (setq *mof-last-range-end* end)
                 (if (= beg end)
                     (return-from mof-lookup-current-string nil))
                 (popup-string (mof-lookup-current-string0) beg))))))))

;; 4.11.1 String Constants
(defvar *mof-escape-sequence-map* nil)
(setf *mof-escape-sequence-map*
  '(("\\" . "\\")
    ("b" . "\b")
    ("t" . "\t")
    ("n" . "\n")
    ("f" . "\f")
    ("r" . "\r")
    ("\"" . "\"")
    ("'" . "'")))

(defun mof-eval-escape-sequence (s)
  (let (result)
    (while (string-match "\\\\\\(.\\)" s)
      (push (substring s 0 (match-beginning 0)) result)
      (push (or (cdr (find (match-string 1) *mof-escape-sequence-map* :key 'car :test 'string=))
                (match-string 1))
            result)
      (setf s (substring s (match-end 0))))
    (push s result)
    (format nil "~{~A~}" (reverse result))))

(defun mof-lookup-current-string0 ()
  (save-excursion
    (let (result)
      ;; 連続する文字列の最初に戻る
      (mof-goto-start-virtual-string)
      ;; 連続する文字列をあつめる
      (while (or (and (looking-at "\"\\(\\([^\"\\]\\|\\\\.\\)*\\)\"")
                      (push (match-string 1) result))
                 (looking-at "[ \t\r\f\n]+"))
        (goto-char (match-end 0)))
      (format nil "~{~A~}"
              (mapcar '(lambda (s)
                        (mof-eval-escape-sequence s))
                      (reverse result))))))

(defun scan-mof (pattern &key no-dup reverse tail limit)
  (let ((opoint (point)))
    ;; とりあえずマッチを試みる
    (while (scan-buffer pattern :regexp t :case-fold t
                        :no-dup no-dup :reverse reverse :tail tail :limit limit)
      ;; 文字列やコメント以外でマッチしたら OK
      (unless (or (mof-in-string-p)
                  (mof-in-comment-p))
        (return-from scan-mof t))
      ;; 同じところでマッチしないように移動
      (if reverse
          (goto-char (1- (match-beginning 0)))
        (goto-char (match-end 0))))
    ;; 最後までマッチしなかったら最初の位置に戻る
    (goto-char opoint)
    nil))

(defun mof-narrow-to-line ()
  (save-excursion
    (narrow-to-region (progn (goto-bol) (point))
                      (progn (goto-eol) (point)))))

;; ----------------------------------------------------------------------
;; 補完
;; addrev-table
(defvar *mof-mode-abbrev-table* nil)
(unless *mof-mode-abbrev-table*
  (define-abbrev-table '*mof-mode-abbrev-table*))

;; popup 補完
(defun mof-completion ()
  "mof-mode: 補完"
  (interactive "*")
  (cond ((and (string-equal (mof-lookup-qualifier) "Units")
              (mof-in-string-p))
         (mof-unit-completion))
        (t
         (mof-keyword-completion))))

(defun mof-unit-completion ()
  "mof-mode: Unit の補完"
  (interactive "*")
  (mof-do-completion *mof-unit-list* "w_ "))

(defun mof-keyword-completion ()
  "mof-mode: Unit の補完"
  (interactive "*")
  (unless *mof-completion-list*
    (or (setf *mof-completion-list*
              (make-list-from-keyword-table *mof-keyword-hash-table*))
        (return-from mof-keyword-completion nil)))
  (mof-do-completion *mof-completion-list*))

(defun mof-do-completion (completion-list &optional (skip-syntax "w_"))
  (let ((opoint (point)))
    (skip-syntax-spec-backward skip-syntax)
    (skip-syntax-spec-forward " ")
    (let ((from (min opoint (point))))
      (goto-char opoint)
      ; :list-ignore-case=補完で大文字小文字を区別しない, :list=する
      (do-completion from opoint :list-ignore-case completion-list
                     nil nil completion-list ; xyzzy 0.2.2.211以前を使う場合はコメントアウト
                     ))))

;; ----------------------------------------------------------------------
;; class、Qualifier、instance、メソッド、プロパティの一覧
(defun mof-build-summary-of-functions ()
  (let (result class)
    (save-excursion
      (goto-char (point-min))
      (while (scan-mof *mof-production-regexp* :tail t)
        (setf class (match-string 2))
        (push (list (current-line-number) class) result)
        (save-excursion
          (save-restriction
            (mof-narrow-to-class)
            (while (scan-mof *mof-class-feature-regexp* :tail t)
              (push (list (current-line-number)
                          (format nil "~A#~A: ~A" class (match-string 2) (match-string 1)))
                    result))))))
    (unless result
      (plain-error "ないっす"))
    (nreverse result)))

;; ----------------------------------------------------------------------
;; tag
(defun tags-find-mof-point (class name functionp point)
  (goto-char (- point *jump-tag-limit*))
  (and (scan-buffer (concat "^[ \t]*\\(class\\|Qualifier\\)[ \t\r\f\n]+"
                            (regexp-quote name)
                            "[ \t\r\f\n]*[:{]")
                    :regexp t :limit (+ point *jump-tag-limit*))
       (point)))

;; class と qualifier をタグ付け
;;   class name [: subclass] {
;;   Qualifier name : ...
(defun mof-maketags (file count)
  (goto-char (point-min))
  (while (scan-buffer "^[ \t]*\\(class\\|Qualifier\\)[ \t\r\f\n]+" :regexp t :tail t :case-fold t)
    (do-events)
    (let ((opoint (point)))
      (skip-chars-forward "A-Za-z0-9_")
      (unless (= opoint (point))
        (format t "~A~A~D" (buffer-substring opoint (point)) file opoint)
        (setf count (1+ count)))))
  count)

(pushnew '(mof-maketags "*.mof") *maketags-list* :key #'car)


;; ----------------------------------------------------------------------
;; modeの実行
(defun mof-mode ()
  "mof-mode"
  (interactive)
  (kill-all-local-variables)
  (setf mode-name "MOF")
  (setf buffer-mode 'mof-mode)
  (use-syntax-table *mof-mode-syntax-table*)
  (use-keymap *mof-mode-map*)

  ; 略語展開
  (setf *local-abbrev-table* *mof-mode-abbrev-table*)

  (make-local-variable 'paragraph-start)
  (setf paragraph-start *mof-production-regexp*) ; forward|backward-paragraph で移動する段落位置
  (make-local-variable 'paragraph-separate)
  (setf paragraph-separate paragraph-start)

  ; タグ関連
  (make-local-variable 'tags-find-target)
  (setf tags-find-target #'tags-find-target-simple)
  (make-local-variable 'tags-find-point)
  (setf tags-find-point #'tags-find-mof-point)

  ; list of class or qualifier
  (make-local-variable 'build-summary-function)
  (setf build-summary-function 'mof-build-summary-of-functions)

  ; indent
  (make-local-variable 'c-indent-level)
  (make-local-variable 'c-continued-statement-offset)
  (make-local-variable 'c-brace-offset)
  (make-local-variable 'c-brace-imaginary-offset)
  (make-local-variable 'c-argdecl-indent)
  (make-local-variable 'c-label-offset)
  (setf c-indent-level *mof-indent-level*)
  (setf c-continued-statement-offset *mof-continued-statement-offset*)
  (setf c-brace-offset *mof-brace-offset*)
  (setf c-brace-imaginary-offset *mof-brace-imaginary-offset*)
  (setf c-argdecl-indent *mof-argdecl-indent*)
  (setf c-label-offset *mof-label-offset*)

  (make-local-variable 'mode-specific-indent-command)
  (setf mode-specific-indent-command 'mof-indent-line)
  (make-local-variable 'mode-newline-and-indent-command)
  (setf mode-newline-and-indent-command 'mof-newline-and-indent)

  ; comment
  (setf comment-start "// " comment-end "") ; indent-for-commentで挿入される奴
  (setf comment-start-skip "//+[ \t]*")
  (setf comment-indent-function 'c-comment-indent) ; c-modeを流用
  (when *mof-comment-column*
    (setf comment-column *mof-comment-column*))

  ; keyword
  (and *mof-keyword-file*
       (null *mof-keyword-hash-table*)
       (setf *mof-keyword-hash-table*
             (load-keyword-file *mof-keyword-file* t))) ; t=大文字小文字を区別しない, nil=する
  (when *mof-keyword-hash-table*
    (make-local-variable 'keyword-hash-table)
    (setf keyword-hash-table *mof-keyword-hash-table*))
  (make-local-variable 'regexp-keyword-list)
  (setf regexp-keyword-list *mof-regexp-keyword-list*)

  ; ローカルメニューの設定
  (insert-mof-menu)

  ; フックの実行
  (run-hooks '*mof-mode-hook*))
