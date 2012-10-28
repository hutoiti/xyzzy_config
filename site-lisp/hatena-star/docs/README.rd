= hatena-star - はてなスター API

  * Author: みやむこ かつゆき ((<URL:mailto:miyamuko@gmail.com>))
  * Home URL: ((<URL:http://miyamuko.s56.xrea.com/xyzzy/hatena-star/intro.htm>))
  * Version: 1.1.1


== SYNOPSIS

  (in-package :your-awesome-app)

  (require "hatena-star/api")
  (use-package :hatena-star.api)

  ;; RKS (ログインセッションごとに固有の ID, add/delete で必要)
  (defvar *rks* nil)

  ;; はてなスターカウント API
  (let ((blog (hatena-star-get-blog "http://d.hatena.ne.jp/hatenastar/")))
    ...)

  ;; エントリと RKS の取得
  (multiple-value-bind (entries rks)
      (hatena-star-get-entries '("http://d.hatena.ne.jp/hatenastar/20071129/1196290565"
                                 "http://d.hatena.ne.jp/hatenastar/20071124/1195896789"
                                 "http://d.hatena.ne.jp/hatenastar/20071115/1195092449"))
    (setf *rks* rks)
    (your-cool-show-hatena-star-entry
     (mapcar #'(lambda (entry)
                 ;; ☆が多くて省略されていたら再取得
                 (if (hatena-star-stars-all-p entry)
                     entry
                   (hatena-star-get-entry (hatena-star-entry-uri entry))))
             entries)))

  ;; コメントの追加
  (when (hatena-star-entry-can-comment-p entry)
    (hatena-star-add-comment (hatena-star-entry-uri entry)
                             *rks*
                             :title title
                             :body (read-string "コメント: ")))

  ;; 選択文字列を引用して☆の追加
  (let ((title "ほげほげ")
        (quote (selection-start-end (s e) (buffer-substring s e))))
    (let ((r (hatena-star-add-star (hatena-star-entry-uri entry)
                                   *rks* :title title :quote quote)))
      (cond ((null r)
             (values nil nil))  ; ☆追加失敗
            ((string= quote (hatena-star-star-quote r))
             (values t t))      ; ☆追加 + 引用成功
            (t
             (values t nil))))) ; ☆追加成功 + 引用失敗

  ;; ☆の削除 (指定された entry の star を削除)
  (when (hatena-star-deletable-p (hatena-star-star-name star))
    (hatena-star-delete-star (hatena-star-entry-uri entry)
                             *rks*
                             :name (hatena-star-star-name star)
                             :quote (hatena-star-star-quote star)))


== DESCRIPTION

hatena-star は ((<"はてなスター"|URL:http://s.hatena.ne.jp/>)) API を
xyzzy から実行するためのライブラリです。

以下のことができます。

  * スターの取得
  * スターの追加・削除
  * コメントの追加
  * はてなスターカウント

xml-http-request を使っているので非同期にはてなスター API を実行できます。


== INSTALL

=== NetInstaller でインストール

(1) ((<NetInstaller|URL:http://www7a.biglobe.ne.jp/~hat/xyzzy/ni.html>))
    で hatena-star をインストールします。

=== NetInstaller を使わずにインストール

(1) アーカイブをダウンロードします。

    ((<URL:http://miyamuko.s56.xrea.com/xyzzy/archives/hatena-star.zip>))

(2) アーカイブを展開して、$XYZZY/site-lisp 配下にファイルをコピーします。


== MODULE

=== DEPENDS

hatena-star は以下のモジュールに依存しています。別途インストールしてください。

  * ((<"xml-http-request"|URL:http://miyamuko.s56.xrea.com/xyzzy/xml-http-request/intro.htm>))
    1.1.1 以上
  * ((<"json"|URL:http://miyamuko.s56.xrea.com/xyzzy/json/intro.htm>))
    0.1.1 以上


=== PACKAGE

hatena-star は以下のパッケージを利用しています。

  * hatena-star.api

    nickname はありません。

=== VARIABLE

--- hatena-star.api:*hatena-star-base-uri*

    はてなスターのベース URI を指定します。
    基本的には変更の必要はありません。

--- hatena-star.ui:*hatena-star-default-star-char*

    ((<hatena-star-make-stars-string|hatena-star.ui:hatena-star-make-stars-string COUNT &KEY STAR-CHAR INNER INNER-MIN>))
    などの関数で STAR-CHAR を省略した場合に利用する charcter です。

    デフォルトは #\★ です。

--- hatena-star.ui:*hatena-star-default-star-color*

    ((<hatena-star-stars-insert|hatena-star.ui:hatena-star-stars-insert ENTRY-OR-STARS &KEY TAG STAR-CHAR COLOR>))
    で☆を描画するときの色です。

    デフォルトは (:foreground 11) です。

--- hatena-star.ui:*hatena-star-inner-count-min*

    ((<hatena-star-stars-insert|hatena-star.ui:hatena-star-stars-insert ENTRY-OR-STARS &KEY TAG STAR-CHAR COLOR>))
    で☆を描画するときに、省略形式にする最小の☆の数です。

    デフォルトは 16 です。


=== CONSTANT

なし。

=== CODITION

なし。

=== COMMAND

なし。

=== DATATYPE

--- BLOG-INFO

    BLOG-INFO はブログのはてなスター情報を保持します。
    BLOG-INFO は
    ((<hatena-star-get-blog|hatena-star.api:hatena-star-get-blog BLOG-URI &KEY SINCE NOMSG CALLBACK FUTURE>))
    で取得します。

    BLOG-INFO からは以下の関数で情報を取得できます。

    * ((<hatena-star-blog-uri|hatena-star.api:hatena-star-blog-uri BLOG-INFO>))
    * ((<hatena-star-blog-title|hatena-star.api:hatena-star-blog-title BLOG-INFO>))
    * ((<hatena-star-blog-star-count|hatena-star.api:hatena-star-blog-star-count BLOG-INFO>))

--- ENTRY-INFO

    ENTRY-INFO はブログエントリのはてなスター情報を保持します。
    ENTRY-INFO は
    ((<hatena-star-get-entries|hatena-star.api:hatena-star-get-entries PERMALINK-LIST &KEY SINCE NOMSG CALLBACK FUTURE>))
    または
    ((<hatena-star-get-entry|hatena-star.api:hatena-star-get-entry ENTRY-OR-PERMALINK &KEY SINCE NOMSG CALLBACK FUTURE>))
    で取得します。

    ENTRY-INFO からは以下の情報を取得できます。

    * ((<hatena-star-entry-can-comment-p|hatena-star.api:hatena-star-entry-can-comment-p ENTRY-INFO>))
    * ((<hatena-star-entry-uri|hatena-star.api:hatena-star-entry-uri ENTRY-INFO>))
    * ((<hatena-star-entry-stars|hatena-star.api:hatena-star-entry-stars ENTRY-INFO>))
    * ((<hatena-star-entry-comments|hatena-star.api:hatena-star-entry-comments ENTRY-INFO>))

--- STAR-LIST

    STAR-LIST はブログエントリの ((<STAR-INFO>)) のリストです。
    STAR-LIST は
    ((<hatena-star-entry-stars|hatena-star.api:hatena-star-entry-stars ENTRY-INFO>))
    で取得します。

    STAR-LIST からは以下の情報を取得できます。

    * ((<hatena-star-stars-all-p|hatena-star.api:hatena-star-stars-all-p ENTRY-OR-STARS>))
    * ((<hatena-star-stars-by-user-p|hatena-star.api:hatena-star-stars-by-user-p ENTRY-OR-STARS>))
    * ((<hatena-star-stars-inner-count-p|hatena-star.api:hatena-star-stars-inner-count-p ENTRY-OR-STARS>))
    * ((<hatena-star-stars-inner-count-values|hatena-star.api:hatena-star-stars-inner-count-values ENTRY-OR-STARS>))
    * ((<hatena-star-stars-count|hatena-star.api:hatena-star-stars-count ENTRY-OR-STARS>))

--- STAR-INFO

    STAR-INFO はブログエントリの☆の情報を保持します。
    STAR-INFO は ((<STAR-LIST>)) の要素です。

    STAR-INFO からは以下の情報を取得できます。

    * ((<hatena-star-star-name|hatena-star.api:hatena-star-star-name STAR-INFO>))
    * ((<hatena-star-star-quote|hatena-star.api:hatena-star-star-quote STAR-INFO>))
    * ((<hatena-star-star-count|hatena-star.api:hatena-star-star-count STAR-INFO>))
    * ((<hatena-star-star-values|hatena-star.api:hatena-star-star-values STAR-INFO>))

--- COMMENT-INFO

    COMMENT-INFO はブログエントリのコメントを保持します。
    COMMENT-INFO は
    ((<hatena-star-entry-comments|hatena-star.api:hatena-star-entry-comments ENTRY-INFO>))
    で取得します。

    COMMENT-INFO からは以下の情報を取得できます。

    * ((<hatena-star-comment-name|hatena-star.api:hatena-star-comment-name COMMENT-INFO>))
    * ((<hatena-star-comment-body|hatena-star.api:hatena-star-comment-body COMMENT-INFO>))
    * ((<hatena-star-comment-values|hatena-star.api:hatena-star-comment-values COMMENT-INFO>))


=== FUNCTION

--- hatena-star.api:hatena-star-get-blog BLOG-URI &KEY SINCE NOMSG CALLBACK FUTURE

    指定された BLOG-URI のブログのはてなスター情報を取得します。

    ((<BLOG-INFO>)) を返します。

    例:
        (let ((blog (hatena-star-get-blog "http://d.hatena.ne.jp/hatenastar/")))
          (msgbox "~Aの☆は~D個です。~%~A"
                  (hatena-star-blog-title blog)
                  (hatena-star-blog-star-count blog)
                  (hatena-star-blog-uri blog)))

    * NOMSG に non-nil を指定するとメッセージを出力しません。

      nil の場合メッセージ領域に通信状態を表示します。
      デフォルトは nil です。

    * SINCE には送信時の If-Modified-Since ヘッダを指定します。

      SINCE には以下の値を指定できます。

      : :epoch
          Unix epoch (1970-01-01 00:00:00) を送信します。
          この値を指定するとキャッシュを使わずにネットワークから取得します。

      : <数値>
          数値を指定した場合はローカル時間の universal-time と見なして
          文字列に変換します。

      : <文字列>
          文字列を指定した場合はそのまま送信します。

    * CALLBACK を指定すると非同期通信を行います。

      はてなスター数の取得に成功した場合はブログ情報が
      CALLBACK の引数に指定し呼び出します。

      失敗した場合は文字列が渡されます。

    * FUTURE に non-nil を指定した場合は xml-http-request の Future オブジェクトを返します。

      Future オブジェクトから情報取得するには以下の関数を使用します。
      * ((<hatena-star-future-completed-p|hatena-star.api:hatena-star-future-completed-p FUTURE>))
      * ((<hatena-star-future-p|hatena-star.api:hatena-star-future-p OBJ>))
      * ((<hatena-star-future-value|hatena-star.api:hatena-star-future-value FUTURE &REST OPTIONS>))

--- hatena-star.api:hatena-star-blog-uri BLOG-INFO

    ブログの URI を返します。

--- hatena-star.api:hatena-star-blog-title BLOG-INFO

    ブログのタイトルを返します。

--- hatena-star.api:hatena-star-blog-star-count BLOG-INFO

    ブログに付いた☆の数を返します。

--- hatena-star.api:hatena-star-get-entries PERMALINK-LIST &KEY SINCE NOMSG CALLBACK FUTURE

    指定された PERMALINK-LIST に付けられた はてなスターの情報を取得します。

    ((<ENTRY-INFO>)) と RKS (閲覧者情報) 多値で返します。

    例:
        (defvar *rks* nil)
        (multiple-value-bind (entry rks)
            (hatena-star-get-entries "http://d.hatena.ne.jp/hatenastar/20071129/1196290565")
          (setf *rks* rks)
          (msgbox "~A~%~D" rks (hatena-star-stars-count entry)))

        (multiple-value-bind (entries _)
            (hatena-star-get-entries '("http://d.hatena.ne.jp/hatenastar/20071129/1196290565"
                                       "http://d.hatena.ne.jp/hatenastar/20071124/1195896789"
                                       "http://d.hatena.ne.jp/hatenastar/20071115/1195092449"
                                       "http://d.hatena.ne.jp/jkondo/20080130/1201642779"))
          (dolist (entry entries)
            (msgbox "~D: ~A"
                    (hatena-star-stars-count entry)
                    (hatena-star-entry-uri entry))))


    ☆が 15 個以上付いたエントリは☆の情報が省略され、
    一部の情報 (最初の☆、間の☆の数、最後の☆) しか取得できません。

    すべての☆を取得したい場合はさらに
    ((<hatena-star-get-entry|hatena-star.api:hatena-star-get-entry ENTRY-OR-PERMALINK &KEY SINCE NOMSG CALLBACK FUTURE>))
    を呼び出す必要があります。

    * PERMALINK-LIST には複数のエントリの permalink をリストで指定します。

      取得したいエントリが一つしかない場合は、その permalink を文字列で指定してもかまいません
      (要素が一つのリストにする必要はありません)。

      * permalink をリストで指定した場合、((<ENTRY-INFO>)) のリストを返します。
      * permalink を文字列で指定した場合、((<ENTRY-INFO>)) を１つ返します（リストではない）。

    * CALLBACK, FUTURE は
      ((<hatena-star-get-blog|hatena-star.api:hatena-star-get-blog BLOG-URI &KEY SINCE NOMSG CALLBACK FUTURE>))
      を参照してください。

--- hatena-star.api:hatena-star-get-entry ENTRY-OR-PERMALINK &KEY SINCE NOMSG CALLBACK FUTURE

    指定されたエントリに付いたはてなスターのエントリ情報を取得します。

    ((<ENTRY-INFO>)) を返します。

    この API で取得した場合、「最初の☆、間の☆の数、最後の☆」形式の省略はされません。

    * ENTRY-OR-PERMALINK には ((<ENTRY-INFO>)) か permalink を文字列で指定します。

    * CALLBACK, FUTURE は
      ((<hatena-star-get-blog|hatena-star.api:hatena-star-get-blog BLOG-URI &KEY SINCE NOMSG CALLBACK FUTURE>))
      を参照してください。

--- hatena-star.api:hatena-star-entry-can-comment-p ENTRY-INFO

    そのエントリにコメントをつけることができるか返します。

--- hatena-star.api:hatena-star-entry-uri ENTRY-INFO

    エントリの URI を返します。

--- hatena-star.api:hatena-star-entry-stars ENTRY-INFO

    エントリから☆リストを取得します。

    ((<STAR-LIST>)) を返します。

    例:
        (let* ((e (hatena-star-get-entry "http://d.hatena.ne.jp/hatenastar/20070707/1184453490"))
               (stars (hatena-star-entry-stars e)))
          (with-output-to-temp-buffer ("*Hatena:Star*")
            (format t "☆の数: ~D~%~A~%~%"
                    (hatena-star-stars-count stars)
                    (hatena-star-entry-uri e))
            (dolist (star stars)
              (multiple-value-bind (name quote _)
                  (hatena-star-star-values star)
                (format t "~A「~A」~%" name (or quote ""))))))

    ☆のリストは省略されることがあります。

    * ((<hatena-star-get-entries|hatena-star.api:hatena-star-get-entries PERMALINK-LIST &KEY SINCE NOMSG CALLBACK FUTURE>))
      で取得した場合：

      * ☆が 15 個以上付いている場合は、「最初の☆、間の☆の数、最後の☆」
        だけしか情報を取得できません。

        間の☆の情報がほしい場合は hatena-star-get-entry を使う必要があります。

        この形式の省略形かどうかは
        ((<hatena-star-stars-inner-count-p|hatena-star.api:hatena-star-stars-inner-count-p ENTRY-OR-STARS>))
        で判定できます。

      * 15 未満の場合はすべての情報を取得可能です。

        すべての情報が取得可能かどうかは
        ((<hatena-star-stars-all-p|hatena-star.api:hatena-star-stars-all-p ENTRY-OR-STARS>))
        で判定できます。

    * ((<hatena-star-get-entry|hatena-star.api:hatena-star-get-entry ENTRY-OR-PERMALINK &KEY SINCE NOMSG CALLBACK FUTURE>))
      で取得した場合：

      * ☆が 300 個以上付いている場合は、ユーザごとに星の数が集約されます。

        各ユーザが付けた星の数は
        ((<hatena-star-star-count|hatena-star.api:hatena-star-star-count STAR-INFO>))
        で取得できます。

        この形式の省略形かどうかは
        ((<hatena-star-stars-by-user-p|hatena-star.api:hatena-star-stars-by-user-p ENTRY-OR-STARS>))
        で判定できます。

      * 300 未満の場合はすべての情報を取得可能です。

        ((<hatena-star-stars-all-p|hatena-star.api:hatena-star-stars-all-p ENTRY-OR-STARS>))
        で判定できます。

--- hatena-star.api:hatena-star-entry-comments ENTRY-INFO

    エントリに付いたコメントをリストで返します。

    コメントからは以下の情報を取得できます。

--- hatena-star.api:hatena-star-comment-name COMMENT-INFO

    コメントをつけた人の名前を取得します。

--- hatena-star.api:hatena-star-comment-body COMMENT-INFO

    コメントの本文を取得します。本文がない場合は nil を返します。

--- hatena-star.api:hatena-star-comment-values COMMENT-INFO

    コメントをつけた人の
    ((<"名前"|hatena-star.api:hatena-star-comment-name COMMENT-INFO>))
    と
    ((<本文 |hatena-star.api:hatena-star-comment-body COMMENT-INFO>))
    を多値で返します。

--- hatena-star.api:hatena-star-stars-all-p ENTRY-OR-STARS

    ☆のリストが一切省略されていないなら t を返します。

    エントリ情報と☆リストの両方を指定できます。

--- hatena-star.api:hatena-star-stars-by-user-p ENTRY-OR-STARS

    ☆のリストが☆をつけたユーザごとに集約されているなら t を返します。

    エントリ情報と☆リストの両方を指定できます。

--- hatena-star.api:hatena-star-stars-inner-count-p ENTRY-OR-STARS

    ☆のリストが（最初の☆、間の☆の数、最後の☆）のみの場合 t を返します。

    エントリ情報と☆リストの両方を指定できます。

--- hatena-star.api:hatena-star-stars-by-user ENTRY-OR-STARS &KEY LIST-QUOTE

    ☆のリストをユーザごとに集約します。
    この関数は
    ((<hatena-star-get-entry|hatena-star.api:hatena-star-get-entry ENTRY-OR-PERMALINK &KEY SINCE NOMSG CALLBACK FUTURE>))
    で取得した☆リストを、☆の数にかかわらずに集約形式にしたい場合に利用します。

    * ユーザごとの星の数は
      ((<hatena-star-star-count|hatena-star.api:hatena-star-star-count STAR-INFO>))
      で取得できます。

    * LIST-QUOTE が non-nil の場合、引用文をリストで返します。
      nil の場合は最初の引用文のみを返します。

      デフォルトは nil です。

    * ☆が 300 個を超える場合は最初からユーザごとに集約されています。

      (高速化のため) すでに集約されていて LIST-QUOTE が nil の場合は引数をそのまま返します。
      LIST-QUOTE が non-nil の場合は、リストにして返します。

      ※注意※ よって、以下のコードは引用文をリストで返します。

          (let ((stars (hatena-star-stars-by-user stars :list-quote t)))
            (hatena-star-stars-by-user stars :list-quote nil))

    * inner count 形式
      (((<hatena-star-stars-inner-count-p|hatena-star.api:hatena-star-stars-inner-count-p ENTRY-OR-STARS>))
      が t を返す) の場合 type-error を通知します。

    エントリ情報と☆リストの両方を指定できます。

--- hatena-star.api:hatena-star-stars-inner-count-values ENTRY-OR-STARS

    ☆のリストから（最初の☆、間の☆の数、最後の☆）を多値で取得します。

    ((<hatena-star-stars-inner-count-p|hatena-star.api:hatena-star-stars-inner-count-p ENTRY-OR-STARS>))
    が nil でも上記形式で取得できます。

    エントリ情報と☆リストの両方を指定できます。

--- hatena-star.api:hatena-star-stars-count ENTRY-OR-STARS

    ☆の総数を取得します。☆が省略されていても正しく取得可能です。

--- hatena-star.api:hatena-star-star-name STAR-INFO

    ☆をつけた人の名前を取得します。

--- hatena-star.api:hatena-star-star-quote STAR-INFO

    ☆の引用文を取得します。引用していない場合は nil を返します。

--- hatena-star.api:hatena-star-star-count STAR-INFO

    ☆をつけた人ごとの☆の個数を返します。

    300 以上の☆がついたエントリ（
    ((<hatena-star-stars-by-user-p|hatena-star.api:hatena-star-stars-by-user-p ENTRY-OR-STARS>))
    が t を返す）の場合のみ値を返します。

    ☆の数が 300 未満の場合は nil を返します。

--- hatena-star.api:hatena-star-star-values STAR-INFO

    ☆をつけた人の
    ((<"名前"|hatena-star.api:hatena-star-star-name STAR-INFO>))
    と
    ((<"引用文"|hatena-star.api:hatena-star-star-quote STAR-INFO>))
    と
    ((<"☆の数"|hatena-star.api:hatena-star-star-count STAR-INFO>))
    を多値で返します。

--- hatena-star.api:hatena-star-add-star ENTRY-OR-PERMALINK RKS &KEY NOMSG CALLBACK FUTURE TOKEN TITLE QUOTE

    指定されたエントリに☆をつけます。

    実際につけた☆の ((<STAR-INFO>)) を返します。

    * ENTRY-OR-PERMALINK には ((<ENTRY-INFO>)) か permalink を文字列で指定します。

    * RKS は
      ((<hatena-star-get-entries|hatena-star.api:hatena-star-get-entries PERMALINK-LIST &KEY SINCE NOMSG CALLBACK FUTURE>))
      で取得できます。

    * TOKEN にはサイト固有の識別子を指定します。

      なくてもいいみたいです。

    * TITLE にはエントリのタイトルを指定します。

    * QUOTE には☆の引用文字列を指定します。

      元のページに含まれていない文字列を指定することはできません。
      指定した場合、引用文字列なしで☆が付きます。

      正しく引用できたかどうかは戻り値で分かります。

    * CALLBACK, FUTURE は
      ((<hatena-star-get-blog|hatena-star.api:hatena-star-get-blog BLOG-URI &KEY SINCE NOMSG CALLBACK FUTURE>))
      を参照してください。

--- hatena-star.api:hatena-star-add-comment ENTRY-OR-PERMALINK RKS &KEY CALLBACK FUTURE TITLE BODY

    指定された URI にコメントをつけます。
    コメントはスターフレンドにしかつけられません。

    ((<COMMENT-INFO>)) を返します。

    * ENTRY-OR-PERMALINK には ((<ENTRY-INFO>)) か permalink を文字列で指定します。

    * RKS は
      ((<hatena-star-get-entries|hatena-star.api:hatena-star-get-entries PERMALINK-LIST &KEY SINCE NOMSG CALLBACK FUTURE>))
      で取得できます。

    * TITLE と BODY でコメントの内容を指定します。

    * CALLBACK, FUTURE は
      ((<hatena-star-get-blog|hatena-star.api:hatena-star-get-blog BLOG-URI &KEY SINCE NOMSG CALLBACK FUTURE>))
      を参照してください。

--- hatena-star.api:hatena-star-deletable-p NAME-OR-STAR &KEY CALLBACK FUTURE

    指定したユーザの☆を削除できる場合 t を返します。

    基本的には自分の NAME の場合のみ t を返すはずです。
    はてなにログインしていない場合は自分の NAME でも nil を返します（たぶん）。

    * NAME-OR-STAR にはユーザ名を文字列で指定するか ((<STAR-INFO>)) を指定します。

    * CALLBACK, FUTURE は
      ((<hatena-star-get-blog|hatena-star.api:hatena-star-get-blog BLOG-URI &KEY SINCE NOMSG CALLBACK FUTURE>))
      を参照してください。

--- hatena-star.api:hatena-star-delete-star ENTRY-OR-PERMALINK RKS &KEY CALLBACK FUTURE NAME QUOTE STAR

    指定したエントリに付いた☆を削除します。

    成功した場合は t を、失敗した場合は nil を返します。

    * ENTRY-OR-PERMALINK には ((<ENTRY-INFO>)) か permalink を文字列で指定します。

    * RKS は
      ((<hatena-star-get-entries|hatena-star.api:hatena-star-get-entries PERMALINK-LIST &KEY SINCE NOMSG CALLBACK FUTURE>))
      で取得できます。

    * CALLBACK, FUTURE は
      ((<hatena-star-get-blog|hatena-star.api:hatena-star-get-blog BLOG-URI &KEY SINCE NOMSG CALLBACK FUTURE>))
      を参照してください。

    * 削除する☆は STAR か NAME と QUOTE で指定します。

      * STAR には ((<STAR-INFO>)) を指定します。

        指定した STAR が他のユーザの☆なら削除できません。

      * NAME と QUOTE は文字列でユーザ名と引用文を指定します。

        NAME は省略可能です。省略した場合は自分の☆が対象になります。
        QUOTE を省略した場合は引用文なしの☆が対象になります。

    例:

        ;; example.com に付けた自分の☆を一個削除
        (hatena-star-delete-star "http://example.com/" *rks*)

        ;; example.com に "example" を引用して付けた自分の☆を一個削除
        (hatena-star-delete-star "http://example.com/" *rks* :quote "foo")

        ;; example.com に付いている自分の☆を全部削除
        (multiple-value-bind (entry rks)
            (hatena-star-get-entry "http://example.com/")
          (dolist (star (hatena-star-entry-stars entry))
            (when (hatena-star-deletable-p star) ; 手抜き。。。deletable-p の結果はキャッシュすべき
              (hatena-star-delete-star entry rks :star star))))


--- hatena-star.api:hatena-star-future-p OBJ

    指定された OBJ が Future オブジェクトなら non-nil を返します。

--- hatena-star.api:hatena-star-future-completed-p FUTURE

    指定された Future オブジェクトのリクエストが完了していたら non-nil を返します。

--- hatena-star.api:hatena-star-future-value FUTURE &REST OPTIONS

    指定された Future オブジェクトから結果を取得します。
    リクエストが完了していない場合は完了を待ち合わせます。

    引数の詳細は
    ((<xml-http-request|URL:http://miyamuko.s56.xrea.com/xyzzy/xml-http-request.html>))
    の (({xhr-future-value})) を参照してください。

--- hatena-star.api:hatena-star-version

    本ライブラリのバージョンを返します。
    バージョンは major.minor.teeny という形式です。

    それぞれの番号は必ず 1 桁にするので、以下のように比較することができます

        (if (string<= "1.1.0" (hatena-star-version))
            '(1.1.0 以降で有効な処理)
          '(1.1.0 より前のバージョンでの処理))


--- hatena-star.ui:hatena-star-make-stars-string COUNT &KEY STAR-CHAR INNER INNER-MIN

    指定された COUNT 数の☆を文字列で返します。

    例：
         (hatena-star-make-stars-string 15)
         "★★★★★★★★★★★★★★★"
         (hatena-star-make-stars-string 16 :star-char #\☆)
         "☆14☆"
         (hatena-star-make-stars-string 4 :inner-min 5)
         "★★★★"
         (hatena-star-make-stars-string 5 :inner-min 5)
         "★3★"
         (hatena-star-make-stars-string 3 :inner t)
         "★1★"

    * STAR-CHAR には☆に対応する charcter を指定します。
      デフォルトは ((<*hatena-star-default-star-char*|hatena-star.ui:*hatena-star-default-star-char*>))
      です。

    * INNER が non-nil の場合、INNER-MIN の値にかかわらず省略形式で返します。
      ただし、COUNT が 2 以下の場合は省略形式にはなりません。

      デフォルトは nil です。

    * INNER-MIN には省略形式にする最小の数を指定します。
      ☆の数が INNER-MIN より少ない場合は省略形式にはなりません。

      デフォルトは ((<*hatena-star-inner-count-min*|hatena-star.ui:*hatena-star-inner-count-min*>))
      です。

--- hatena-star.ui:hatena-star-stars-to-string ENTRY-OR-STARS &KEY STAR-CHAR

    指定された ((<STAR-LIST>)) を☆の文字列にします。

    * STAR-CHAR には☆に対応する charcter を指定します。
      デフォルトは ((<*hatena-star-default-star-char*|hatena-star.ui:*hatena-star-default-star-char*>))
      です。

    * ☆の数が ((<*hatena-star-inner-count-min*|hatena-star.ui:*hatena-star-inner-count-min*>))
      以上の場合は省略形式になります。

--- hatena-star.ui:hatena-star-stars-insert ENTRY-OR-STARS &KEY TAG STAR-CHAR COLOR

    指定された ((<STAR-LIST>)) を☆の文字列にして現在のバッファに挿入します。

    * TAG にはテキストの属性を指定します。詳細は set-text-attribute を参照してください。

    * STAR-CHAR には☆に対応する charcter を指定します。
      デフォルトは ((<*hatena-star-default-star-char*|hatena-star.ui:*hatena-star-default-star-char*>))
      です。

    * COLOR には☆の色を指定します。詳細は set-text-attribute を参照してください。

      デフォルトは
      ((<*hatena-star-default-star-color*|hatena-star.ui:*hatena-star-default-star-color*>))
      で指定します。

    * ☆の数が ((<*hatena-star-inner-count-min*|hatena-star.ui:*hatena-star-inner-count-min*>))
      以上の場合は省略形式になります。

    * TAG および COLOR が nil の場合はテキスト属性は設定しません。


=== MACRO

なし。


== SAMPLE CODE

カーソル下の URL のはてなスター情報をバッファに表示するサンプル。
URL の取得に clickable-uri をトリッキーに使ってます。

  (require "clickable-uri")
  (require "hatena-star/api")
  (use-package :hatena-star.api)

  (defun show-hatena-star-entry (entry)
    (when entry
      (macrolet ((puts (fmt &rest args)
                   `(insert (format nil ,fmt ,@args))))
        (with-output-to-temp-buffer ("*Hatena:Star*")
          (puts "☆の数: ~D~%~A~%~%"
                (hatena-star-stars-count entry)
                (hatena-star-entry-uri entry))
          (dolist (star (hatena-star-entry-stars entry))
            (multiple-value-bind (name quote count)
                (hatena-star-star-values star)
              (puts name)
              (when count
                (puts " (~D)" count))
              (when quote
                (indent-to 30)
                (puts " 「~A」" quote))
              (puts "\n")))
          (goto-char (point-min))
          (refresh-screen)))))

  (defun show-hatena-star-uri-later (uri)
    (hatena-star-get-entry uri :callback #'show-hatena-star-entry))

  (defun show-current-link-hatena-star ()
    (interactive)
    (let ((*clickable-uri-open-command-alist*
           (acons "^https?://" #'show-hatena-star-uri-later nil))
          (*clickable-uri-keep-focus* nil))
      (clickable-uri-open)))

  (global-set-key '(#\C-c #\s) 'show-current-link-hatena-star)


== TODO

* RKS の自動取得・保存
* 引用文の HTML タグの除去、改行の統一
* get-entries で URI 長の 2084 文字制限の対処
  * 分割してリクエストした場合、future と callback はどうするか。
    * ぜんぶ帰ってきてから完了?
* hatena-star.ui
  * mouse
  * popup-hatena-star
  * clickable-star


== KNOWN BUGS

* IE ではてなにログインしていないと、add/delete が動かない


== AUTHOR

みやむこ かつゆき (((<URL:mailto:miyamuko@gmail.com>)))


== SEE ALSO

: Hatena: はてなスターカウント API とは
    ((<URL:http://d.hatena.ne.jp/keyword/%A4%CF%A4%C6%A4%CA%A5%B9%A5%BF%A1%BC%A5%AB%A5%A6%A5%F3%A5%C8API?kid=217860>))

: 何かつまらなかったのでHatenaStar.jsが利用しているAPIを調べてみた。
    ((<URL:http://d.hatena.ne.jp/Yuichirou/20070802#1186070862>))

: HatenaStar.js
    ((<URL:http://s.hatena.ne.jp/js/HatenaStar.js>))


== COPYRIGHT

hatena-star は MIT/X ライセンスに従って本ソフトウェアを使用、再配布することができます。

See hatena-star/docs/MIT-LICENSE for full license.


== NEWS

<<<NEWS.rd
