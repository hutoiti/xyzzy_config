
$HeadURL: file:///g:/repository/xyzzy/site-lisp/svn/release/0.0.2.0/readme.txt $
$Date: 2005-07-04 21:59:51 +0900 (Mon, 04 Jul 2005) $
$Rev: 171 $

■svn-mode for xyzzy

・めちゃくちゃ適当な簡易svn-modeです。

■必要な環境

・Subversionが普通に動作する環境（パスが通っている）

・xml-parser-modokiが必須です。お使いになる前にインストールして、
　問題なく使えるようにしておいてください。

■設定

・~/.xyzzyか$XYZZY/site-lisp/siteinit.lに以下を記述して保存し、
  xyzzyを再起動してください

	(require "svn/svn")

・svn サブコマンドに渡すスイッチの指定については、~/.xyzzy や
  $XYZZY/site-lisp/siteinit.l に以下を記述してください。

  例 ユーザIDとパスワードを設定する
	(svn-set-option "--username" "LKPTeam")
	(svn-set-option "--password" "hogehoge")

  例 --verboseオプションを設定する
	(svn-set-option "--verbose")

  構文は
	(svn-set-option OPTION-NAME [OPTION-VALUE])
  となっており、ユーザIDやパスワードを指定するときはOPTION-VALUEを
  使いますが、それ以外はOPTION-NAMEだけで済むと思います。

  使用できるオプションの一覧がsvn-misc.lにあります(*svn-options*)。

■設定できるオプション一覧

名前							初期値
*svn-use-completion* 			nil(リポジトリリストの補完を有効にするかどうか)
*svn-use-parse-status* 			nil(svn statusサブコマンドの出力結果を変更するかどうか)
*svn-diff-color-new* 			'(:foreground 15 :background 7 :bold t)
*svn-diff-color-old*			'(:foreground 1 :background 3)
*svn-blame-color*				'(:foreground 8 :background 3 :bold t)
*svn-parse-modified-color*    	'(:keyword 1 :bold)
*svn-parse-add-color*         	'(:keyword 2 :bold)
*svn-parse-delete-color*      	'(:keyword 1 :line)
*svn-parse-conflict-color*    	'(:keyword 1 :bold)
*svn-parse-ignored-color*     	'(:keyword 0 :bold)
*svn-parse-no-version-color*  	'(:color 10 0 :line)
*svn-parse-losted-item-color* 	'(:keyword 2 :bold)
*svn-parse-rep-item-color*    	'(:keyword 2 :bold)
*svn-parse-rel-ext-def-color* 	'(:keyword 0 :bold :underline)
*svn-parse-old-color*         	'(:color 1 0 :bold :line)
*svn-parse-locked-color*        '(:keyword 1 :bold)
*svn-parse-file-modified-color*	'('modified 1 nil t)
*svn-parse-file-add-color*      '('add 2 nil t)
*svn-parse-file-conflict-color* '('conflict 6 nil t)
*svn-parse-file-ignored-color*  '('ignored 0 nil nil nil t)
*svn-parse-file-losted-color*   '('losted 10 nil t)
*svn-parse-file-locked-color*   '('locked 1 nil t)
*svn-parse-file-switched-color* '('switched 2 nil t)

*svn-parse-fileから始まる変数については以下を参照
;; file/direcotry column color
;; format
;;  '(TAG FOREGROUND BACKGROUND BOLD UNDERLINE STRIKE-OUT)
;; TAG        => 必須
;; FOREGROUND => 必須。色番号、またはnil
;; BACKGROUND => 色番号、またはnil(省略可)
;; BOLD       => t または nil(省略可)
;; UNDERLINE  => t または nil(省略可)
;; STRIKE-OUT => t または nil(省略可)
;;
;; FOREGROUNDを省略して、BACKGROUNDを指定する、というのは不可。
;; その場合はFOREGROUNDにnilを指定すること。順番大事。これ重要。
;;

■その他

・サポートしているsvnサブコマンドはsvn.lの先頭の方に記入しています
・分からなかったらソース読め(笑)
・svn-propeditについて。PROPVALUEの編集を完了する時はC-c C-cです。
  コミットの時と同じですね。一応分からない人のために書いときます。

--------------------------------------------------------------------------
