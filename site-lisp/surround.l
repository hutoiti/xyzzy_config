;;; -*- mode: lisp -*-
;;; name:     surround
;;; version:  2008.01.15
;;; author:   snj14
;;; category: Editing
;;; src:      http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fsurround&openfile=
;;; changes:  surround-delete-horizontal-spaces追加
;;;           surround-mode-init-keybindを実行するタイミングの調整
;;; files:    site-lisp/surround.l
;;;           site-lisp/surround.lc
;;;           site-lisp/ni-autoload/silog/surround.l

;; Copyright (C) 2007 snj14
;;
;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions
;; are met:
;;
;; 1. Redistributions of source code must retain the above copyright
;;    notice, this list of conditions and the following disclaimer.
;;
;; 2. Redistributions in binary form must reproduce the above copyright
;;    notice, this list of conditions and the following disclaimer in
;;    the documentation and/or other materials provided with the
;;    distribution.
;;
;; 3. The name of the author may not be used to endorse or promote
;;    products derived from this software without specific prior
;;    written permission.
;;
;; THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
;; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
;; PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
;; DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
;; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
;; OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
;; HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
;; STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
;; ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;; POSSIBILITY OF SUCH DAMAGE.

;;; Commentary:

;; 概要:
;; 
;; 選択操作を便利に。
;; 選択した後の操作も便利に。

;; 設定:
;;
;; NetInstallerで導入した方は 1 は不要です
;;
;;   1 $XYZZY/site-lisp/ 以下にコピーし、バイトコンパイルしてください。
;;   2 .xyzzy や siteinit.l に以下を参考に記述し、
;;     siteinit.lに記述した方は再ダンプしてください。
;;   (require "surround") ; ni-autoloadしている人は不要
;;   (global-set-key #\NUL 'set-mark-surround) ; マークはC-SPCでやりたい人用

;; 使い方:
;; 
;; M-sしてください。
;; その後は↓の操作等をしてください。

;; 共通操作:
;; 
;; *付きの操作は*surround-mode-key-replace*がnon-nilかつ
;; .xyzzy等でキーバインドを変更していれば、そのキーバインドになります。多分。
;; 
;; - M-s      選択開始 or 通常選択→矩形選択→行選択の切り替え
;; - M-h      選択範囲をそれっぽく増加
;; - M-d      選択範囲を左右それぞれ1文字ずつ縮める
;; - M-g      選択中の文字列で 現在開いているファイルの拡張子のファイルを、
;;            作業ディレクトリからgrepします
;; - C-i      snippet.lがあればsnippetを挿入し、なければ選択範囲をインデント
;; - C-u C-i  選択範囲をインデント
;; - C-x C-x *マーク位置とキャレット位置の入れ替え
;; - M-\     *選択中の文字列をーつの行に連結し、連続する空白を削除する (delete-horizontal-spaces)
;; - M-/     *選択中の文字列を一つの行に連結し、連続する空白を１つにまとめる (just-one-space)
;; - C-h     *選択中の文字列を削除 (delete-backward-char-or-selection / backward-delete-char-untabify-or-selection)
;; - C-u C-h *直前にM-hで()、[]、{}、''、""で囲まれた範囲を選択していれば囲っている文字だけ削除
;; - C-d     *選択中の文字列を削除 (delete-backward-char-or-selection / backward-delete-char-untabify-or-selection)
;; - C-u C-d *直前にM-hで()、[]、{}、''、""で囲まれた範囲を選択していれば中身だけ削除
;; - M-r     *選択中の文字列で確認無しの置換 (replace-string)
;; - M-C-r   *選択中の文字列で確認有りの置換 (query-replace)
;; - F5      *選択中の文字列で前方再検索 (repeat-forward-search)
;; - S-F5    *選択中の文字列で後方再検索 (repeat-backward-search)
;; - C-s     *選択中の文字列で前方インクリメンタルサーチ (search-forward-again / isearch-repeat-forward)
;; - C-r     *選択中の文字列で後方インクリメンタルサーチ (search-backward-again / isearch-repeat-backward)
;;            (igsearch-forwardに割り当てられていれば、即igsearch-repeat-forward/backward)
;; - (        選択中の文字列を()で囲む
;; - [        選択中の文字列を[]で囲む
;; - {        選択中の文字列を{}で囲む
;; - '        選択中の文字列を''で囲む
;; - "        選択中の文字列を""で囲む

;; 矩形選択状態の操作:
;; 
;; - C-w     *矩形切り取り
;; - C-y     *矩形貼り付け
;;            矩形領域の開始位置と終了位置の桁が同じなら挿入 (yank-rectangle)
;;            矩形領域の開始位置と終了位置の桁が異なるなら
;;            矩形領域の左上から上書き (overwrite-rectangle)
;; - M-w     *矩形コピー
;; - C-h     *矩形内削除
;;            矩形領域の開始位置と終了位置の桁が同じならその左側を削除
;; - C-x C-x *左上又は右下の角にキャレット移動
;; - C-x C-l *矩形領域の大文字を小文字に変換 (downcase-region)
;; - C-x C-u *矩形領域の小文字を大文字に変換 (upcase-region)
;; - C-f     *右に移動(行末かつgoal-columnを増やせるようならgoal-columnのみ増加)
;; - Right        〃
;; - C-b     *左に移動(current-columnよりgoal-columnの方が大きければgoal-columnを減少)
;; - Left         〃
;; - C-e     *リージョン内の一番桁数の多い行が選択されるようにgoal-columnを設定
;; - C-Right      〃
;; - SPC      矩形領域の開始位置と終了位置の桁が同じなら全ての行にスペースを入力し、
;;            異なれば矩形領域をスペースで上書き(clear-rectangle)
;; - 修飾キーなしの文字
;;            開始位置と終了位置の桁が異なれば文字削除し、
;;            全ての行に同じ内容を入力

;; 列モード選択状態の操作:
;; 
;; - C-w  *切り取り (反転表示させている列)
;; - M-w  *コピー   (反転表示させている列)

;; M-h の詳細:
;; 
;; 1. キャレット位置に属性(set-text-attribute)が付いていれば、その範囲
;; 2. キャレット位置が
;;    漢字/ひらがな/カタカナ/半角カタカナ/全角数字/全角アルファベット
;;    の場合はその種類の文字(漢字なら漢字)の連続する部分
;; 3. clickable-uriが導入されている場合はclickable-uriで強調表示している部分
;; 4. シンタックスのw_に該当する部分(英数、シンボルに含まれる記号)
;; 5. シンタックスの"に囲まれた部分(クォート・ダブルクォート自体も含む)
;; 6. (と)に囲まれた部分(開き括弧、閉じ括弧自体も含む)
;;    ただし、クォートされている場合とコメント部分と文字列部分にある場合は無視する。
;; 6. [と]に囲まれた部分(開き括弧、閉じ括弧自体も含む)
;;    ただし、クォートされている場合とコメント部分と文字列部分にある場合は無視する。
;; 6. {と}に囲まれた部分(開き括弧、閉じ括弧自体も含む)
;;    ただし、クォートされている場合とコメント部分と文字列部分にある場合は無視する。
;; 6. surround-modeを開始した段落
;; 7. バッファ全体
;; 
;; の順に選択範囲を広げていきます。
;; 最後までいくと一番最初の位置に戻ります。
;; 
;; 数字が同じ場合は範囲の大きさによって変わります。

;; カスタマイズ:
;; 
;; 
;; ;;; surround range for css
;; (defun surround-range-css-mode-init ()
;;   ;; foo: bar;
;;   (setf surround-range-css-declaration
;; 		(make-surround-range
;; 		 :begin #'(lambda ()
;; 					(let ((pt1 (save-excursion
;; 								 (when (surround-skip-syntax ";" :regexp nil :reverse t :tail nil :ignore-escape t :ignore-string t :ignore-comment t)
;; 								   (point))))
;; 						  (pt2 (save-excursion
;; 								 (when (surround-skip-syntax "{" :regexp nil :reverse t :tail nil :ignore-escape t :ignore-string t :ignore-comment t)
;; 								   (point)))))
;; 					  (goto-char (1+ (cond ((not pt1) pt2)
;; 										   ((< pt1 pt2) pt2)
;; 										   (t pt1))))
;; 					  (skip-white-forward)))
;; 		 :end #'(lambda (begin str end)
;; 				  (backward-char)
;; 				  (surround-skip-syntax ";" :regexp nil :tail nil :no-dup nil :ignore-escape t :ignore-string t :ignore-comment t))
;; 		 :name "css-declaration"))
;;   (setf surround-expand-range-list
;; 		(list surround-range-string-double
;; 			  surround-range-string-single
;; 			  surround-range-parenthesis
;; 			  surround-range-braces
;; 			  surround-range-brackets
;; 			  surround-range-paragraph
;; 			  surround-range-css-declaration)))
;; (add-hook 'ed::*css+-mode-hook* 'surround-range-css-mode-init)
;; 
;; 
;; 
;; ;;; surround range for html
;; (defun surround-range-html-mode-init ()
;;   ;; foo = "bar"
;;   (setf surround-range-html-element
;; 		(make-surround-range
;; 		 :begin #'(lambda ()
;; 					(let (res a b c)
;; 					  (setf res (when (save-excursion
;; 										(scan-buffer "[ \t\n]\\(\\(\\sw\\|\\s_\\)+[ \t\n]*=[ \t\n]*\\(\\s\"\\)\\)"
;; 													 :regexp t :reverse t))
;; 								  (setf a (match-beginning 3)
;; 										b (match-string 3)
;; 										c (match-end 3))
;; 								  (goto-char (match-beginning 1))))
;; 					  (values res a b c)))
;; 		 :end #'(lambda (begin str end)
;; 				  (backward-char)
;; 				  (unless (eq (parse-point-syntax) :string)
;; 					(surround-skip-syntax str :tail t :ignore-escape t))
;; 				  (surround-skip-syntax str :tail t :ignore-escape t))
;; 		 :condition #'(lambda () (eq (parse-point-syntax) :tag))
;; 		 :name "html-element"))
;; 
;;   ;; this function require html+-mode.l
;;   ;; <foo><bar>baz</bar></foo>
;;   (defvar-local surround-range-html-tag-position nil)
;;   (setf surround-range-html-tag
;; 		(make-surround-range
;; 		 :begin #'(lambda ()
;; 					(multiple-value-bind (res pos tag) (ed::uplevel-tag)
;; 					  (when res (goto-char pos) (values res pos tag))))
;; 		 :end #'(lambda (begin str end)
;; 				  (multiple-value-bind (res a b c)
;; 					  (surround-skip-syntax
;; 					   (concat "</" str  ">") :tail t :ignore-comment t :ignore-string t :check
;; 					   #'(lambda (pt begin1 str begin2)
;; 						   (setf surround-range-html-tag-position begin2)
;; 						   (goto-char begin2)
;; 						   (multiple-value-bind (res pos tag)
;; 							   (ed::uplevel-tag)
;; 							 (cond ((or (not res)
;; 										(and res (not (= begin pos))))
;; 									nil)
;; 								   (t t)))))
;; 					(when res
;; 					  (goto-char surround-range-html-tag-position)
;; 					  (setf surround-range-html-tag-position nil))
;; 					(values res a b c)))
;; 		 :condition #'(lambda () (not (eq (parse-point-syntax) :tag)))
;; 		 :name "html-tag"))
;;   (setf surround-expand-range-list
;; 		(list surround-range-string-double
;; 			  surround-range-string-single
;; 			  surround-range-parenthesis
;; 			  surround-range-braces
;; 			  surround-range-brackets
;; 			  surround-range-lt-gt
;; 			  surround-range-html-element
;; 			  surround-range-html-tag)))
;; (add-hook '*html+-mode-hook* 'surround-range-html-mode-init)
;; 
;; ;; 現在の列を選択する
;; (global-set-key #\M-C-l 'surround-mode-select-line)

;; 既知の問題:
;; 
;; 1 矩形選択状態で日本語を入力しても全ての行に入力出来ない
;;   日本語の入力は直接self-insert-commandを使っているわけではないらしく、対策を思いつかない。
;; 2 M-hの6番の(),[],{}は、コメント部分でもないのにparen.lの様子がおかしいような場所は
;;   だいたいおかしな動作をする。(jscript-modeで行末に\をいれて次の行に書いたりとか)
;; 3 M-hで選択範囲の先頭と末尾のどっちにマークが行くか分からない
;; 4 M-hが勝手に選択範囲を広げるのでmulti-major-modeとの相性が悪い
;;   (surround-modeがすぐoffになる)
;; 5 C-u C-d と C-u C-h はどっちがどっちか覚えにくい気がスル…orz

;; 履歴:
;; 
;; 2008.01.15
;; - surround-delete-horizontal-spaces追加
;; - surround-mode-init-keybindを読み込むタイミングの調整
;; 
;; 2007.03.02
;; - 現在の列を選択するコマンド追加
;; 
;; 2007.02.15
;; - 各行の異なる桁位置を編集できる機能を追加(貧弱注意)
;; - Grepする時のデフォルトの拡張子をある程度カスタマイズできるようにした
;; - replace-string query-replaceで置換後の文字が保存されていなかったのを修正
;; - キーボードマクロ中に止まらないようにした
;; 
;; 2007.02.08
;; - C-iでsnippetを挿入し、C-u C-iでインデントを行うようにした
;; - C-hでgoal-columnが保存されていなかったのを修正
;; - デフォルトでキー置き換え(substitute-key-definition)をしないようにした
;; - キー定義の直後にhookを仕込んだ
;; - *post-command-hook*と*post-startup-hook*を間違えていたのを修正 orz
;; 
;; 2007.02.04
;; - M-hに属性(色付きの文字列とか)を追加
;; - M-hに段落を追加
;; - M-hに<>で囲まれた場所を追加
;; 
;; 2007.01.29
;; - 初版

;;; Code:

(require "grepd")

(provide "surround")

(in-package "editor")

(export '(surround-skip-syntax
		  set-mark-surround
		  surround-mode-select-line
		  make-surround-range
		  surround-expand-range-list
		  surround-range-string-double
		  surround-range-string-single
		  surround-range-parenthesis
		  surround-range-braces
		  surround-range-brackets
		  surround-range-lt-gt
		  surround-range-paragraph
		  *surround-mode-map*
		  *surround-mode-key-replace*
		  *surround-mode-hook*
		  *surround-mode-init-keybind-hook*))

(defvar-local surround-mode-on nil)
(defvar-local surround-type "Word")
(defvar-local surround-change-position-flag nil)
(defvar-local surround-start-point nil)
(defvar-local surround-last-undo-command nil)
(pushnew '(surround-mode-on . surround-type) *minor-mode-alist* :key #'car)

(defvar *surround-search-command*
  '(isearch-forward
	isearch-backward
	igsearch-forward
	igsearch-backward
	search-forward
	search-backward
	search-forward-again
	search-backward-again
	repeat-forward-search
	repeat-backward-search)
  "これらのコマンド実行時は*last-search-string*に選択範囲の文字列を入れてsurround-mode終了。")

(defvar-local surround-edit-each-line-command
			  '(surround-self-insert-command
				surround-backward-char
				surround-forward-char
				surround-backward-delete-char
				surround-delete-char
				forward-word backward-word undo redo goto-eol goto-bol)
			  "各行編集中にこれら以外のコマンドが実行されたらsurround-mode終了。")

(defvar *surround-exit-command-regexp*
  "\\(region$\\|tabify\\|.+selection\\)"
  "ここで指定したコマンド実行後はsurround-modeを終了する。")

;;; キーバインドが設定された直後に実行される
(defvar *surround-mode-init-keybind-hook* nil)
;;; surround-modeの最後で実行される
(defvar *surround-mode-hook* nil)

;;; grep[M-g]のオプション
(defvar *surround-grep-case-fold* :smart)   ; 大文字小文字を区別する
(defvar *surround-grep-word-search* nil)    ; 単語単位で検索する
(defvar *surround-grep-regexp* t)           ; 正規表現
(defvar *surround-grep-escape-sequences* t) ; エスケープシーケンスを理解しろ
(defvar *surround-grep-subdir* t)           ; ついでにサブディレクトリも
(defvar *surround-grep-async* t)            ; 非同期でgrep
(defvar *surround-grep-name-only* nil)      ; ファイル名だけ出力
;;; grep[M-g]のデフォルトの拡張子
(defvar *surround-grep-ext-alist*           ; (パスにマッチする正規表現 . 拡張子)
  '((".xyzzy$" .  "*.l")                    ;  ファイルでない場合はバッファ名を使用する
    ("\*Trace Output\*" . "*.l")
	("\*scratch\*" . "*.l")))


;;; 選択した部分の先頭に"を入力したら末尾にも"を入力とか。
(defvar *surround-pair*
  '(("("  . ")")
	("{"  . "}")
	("["  . "]")
	("\"" . "\"")
	("'"  . "'")
	))

(defun surround-skip-syntax (syntax &key regexp check reverse tail no-dup ignore-string ignore-comment ignore-escape (same-mark-begin t) (same-mark-end t) pt)
  (let ((pt-tmp (point))
		match-string match-end match-beginning data flag)
	(save-excursion
	  (scan-buffer syntax :regexp regexp :reverse reverse :tail tail :no-dup no-dup)
	  (setf match-beginning (match-beginning 0)
			match-string (match-string 0)
			match-end (match-end 0)
			data (match-data))
;; 	  (when (find :surround *features* :test 'equal)
;; 		(refresh-screen)
;; 		(msgbox "1 \"~A\"~% ~S~%:direction ~S~%:ignore-string ~S~%:ignore-comment ~S~%:ignore-escape ~S~%:no-dup ~S~%:tail ~S~%"
;; 				(surround-get-current-strings)
;; 				syntax (if reverse "backward" "forward") ignore-string ignore-comment ignore-escape no-dup tail))
	  )
	(let ((res
		   (cond ((not match-beginning)
				  nil)
				 ((or (when (or (and ignore-string
									 (save-excursion
									   (goto-char match-beginning)
									   (eq (parse-point-syntax) :string)))
								(and ignore-comment
									 (save-excursion
									   (goto-char match-beginning)
									   (eq (parse-point-syntax) :comment)))
								(and ignore-escape
									 (save-excursion
									   (goto-char match-beginning)
									   (backward-char)
									   (syntax-escape-p (following-char)))))
						(goto-char match-beginning)
						(unless pt
						  (setf pt pt-tmp))
						t)
					  (and check
						   (prog1 (funcall check pt match-beginning match-string match-end)
							 (when pt
							   (setf pt nil)))))
				  (multiple-value-bind (res a b c)
					  (surround-skip-syntax syntax :regexp regexp :reverse reverse :check check :tail tail :no-dup t
											:ignore-string  ignore-string
											:ignore-comment ignore-comment
											:ignore-escape  ignore-escape
											:pt pt)
					(when pt
					  (setf match-beginning a match-string b match-end c))
					res))
				 (t
				  (goto-char match-beginning)
				  (unless reverse
					(forward-char))
				  t))))
	  (values res match-beginning match-string match-end))))

(defstruct surround-range
  begin     ;; 開始位置
  end       ;; 終了位置
  condition ;; 探索前にチェック
  name)

(defun surround-get-current-strings ()
  (concat (buffer-substring (- (point) 5) (point)) "■" (buffer-substring (1+ (point)) (+ 6 (point)))))

(defvar surround-range-string-double
  (make-surround-range :begin #'(lambda () (surround-skip-syntax "\"" :regexp nil :reverse t :tail nil :ignore-escape t))
					   :end #'(lambda (begin str end) (surround-skip-syntax str :tail t :ignore-escape t))
					   :condition #'(lambda ()
									  (and (eq (parse-point-syntax) :string)
										   (syntax-string-p #\")
										   (save-excursion
											 (goto-char (mark))
											 (eq (parse-point-syntax) :string))))
					   :name "string-double"))

(defvar surround-range-string-single
  (make-surround-range :begin #'(lambda () (surround-skip-syntax "'" :regexp nil :reverse t :tail nil :ignore-escape t))
					   :end #'(lambda (begin str end) (surround-skip-syntax str :tail t :ignore-escape t))
					   :condition #'(lambda ()
									  (and (eq (parse-point-syntax) :string)
										   (syntax-string-p #\')
										   (save-excursion
											 (goto-char (mark))
											 (eq (parse-point-syntax) :string))))
					   :name "string-single"))

(defvar surround-range-parenthesis
  (make-surround-range
   :begin #'(lambda ()
			  (multiple-value-bind (res a b c)
				  (surround-skip-syntax
				   "(" :regexp nil :reverse t :no-dup t :tail nil :ignore-escape t :ignore-string t :ignore-comment t :check
				   #'(lambda (pt begin1 str begin2)
					   (let ((end (save-excursion
									(when pt (goto-char pt))
									(multiple-value-bind (res b s e)
										(surround-skip-syntax ")"
															  :reverse t :no-dup t :ignore-comment t :ignore-string t :ignore-escape t)
									  b))))
						 (cond ((or (not end) (< end begin1))
								(goto-char begin1) nil)
							   ((< begin1 end)
								(goto-char end)
								(goto-matched-parenthesis))
							   (t (goto-char begin1) nil)))))
				(values res a b c)))
   :end #'(lambda (arg-begin arg-str arg-end)
			(multiple-value-bind (res a b c)
				(surround-skip-syntax
				 ")" :tail t :ignore-escape t :ignore-string t :ignore-comment t
				 :check #'(lambda (pt begin1 str begin2)
							(let ((end (save-excursion
										 (when pt (goto-char pt))
										 (multiple-value-bind (res b s e)
											 (surround-skip-syntax "("
																   :tail t :ignore-comment t :ignore-string t :ignore-escape t)
										   b))))
							  (cond ((not end)
									 (goto-char begin1) nil)
									((< end begin1)
									 (goto-char end)
									 (goto-matched-parenthesis))
									(t
									 (goto-char begin1)
									 nil)))))
			  (values res a b c)))
   :condition #'(lambda () (syntax-open-p #\())
   :name "parenthesis"))

(defvar surround-range-braces
  (make-surround-range
   :begin #'(lambda ()
			  (multiple-value-bind (res a b c)
				  (surround-skip-syntax
				   "{" :regexp nil :reverse t :no-dup t :tail nil :ignore-escape t :ignore-string t :ignore-comment t :check
				   #'(lambda (pt begin1 str begin2)
					   (let ((end (save-excursion
									(when pt (goto-char pt))
									(multiple-value-bind (res b s e)
										(surround-skip-syntax "}" :reverse t :no-dup t :ignore-comment t :ignore-string t :ignore-escape t)
									  b))))
						 (cond ((or (not end) (< end begin1))
								(goto-char begin1) nil)
							   ((< begin1 end)
								(goto-char end)
								(goto-matched-parenthesis))
							   (t (goto-char begin1) nil)))))
				(values res a b c)))
   :end #'(lambda (arg-begin arg-str arg-end)
			(multiple-value-bind (res a b c)
				(surround-skip-syntax
				 "}" :tail t :ignore-escape t :ignore-string t :ignore-comment t
				 :check #'(lambda (pt begin1 str begin2)
							(let ((end (save-excursion
										 (when pt (goto-char pt))
										 (multiple-value-bind (res b s e)
											 (surround-skip-syntax "{" :tail t :ignore-comment t :ignore-string t :ignore-escape t)
										   b))))
							  (cond ((not end)
									 (goto-char begin1) nil)
									((< end begin1)
									 (goto-char end)
									 (goto-matched-parenthesis))
									(t
									 (goto-char begin1)
									 nil)))))
			  (values res a b c)))
   :condition #'(lambda () (syntax-open-p #\{))
   :name "braces"))

(defvar surround-range-brackets
  (make-surround-range
   :begin #'(lambda ()
			  (multiple-value-bind (res a b c)
				  (surround-skip-syntax
				   "[" :regexp nil :reverse t :no-dup t :tail nil :ignore-escape t :ignore-string t :ignore-comment t :check
				   #'(lambda (pt begin1 str begin2)
					   (let ((end (save-excursion
									(when pt (goto-char pt))
									(multiple-value-bind (res b s e)
										(surround-skip-syntax "]" :reverse t :no-dup t :ignore-comment t :ignore-string t :ignore-escape t)
									  b))))
						 (cond ((or (not end) (< end begin1))
								(goto-char begin1) nil)
							   ((< begin1 end)
								(goto-char end)
								(goto-matched-parenthesis))
							   (t (goto-char begin1) nil)))))
				(values res a b c)))
   :end #'(lambda (arg-begin arg-str arg-end)
			(multiple-value-bind (res a b c)
				(surround-skip-syntax
				 "]" :tail t :ignore-escape t :ignore-string t :ignore-comment t
				 :check #'(lambda (pt begin1 str begin2)
							(let ((end (save-excursion
										 (when pt (goto-char pt))
										 (multiple-value-bind (res b s e)
											 (surround-skip-syntax "[" :tail t :ignore-comment t :ignore-string t :ignore-escape t)
										   b))))
							  (cond ((not end)
									 (goto-char begin1) nil)
									((< end begin1)
									 (goto-char end)
									 (goto-matched-parenthesis))
									(t
									 (goto-char begin1)
									 nil)))))
			  (values res a b c)))
   :condition #'(lambda () (syntax-open-p #\[))
   :name "brackets"))

(defvar surround-range-lt-gt
  (make-surround-range
   :begin #'(lambda ()
			  (multiple-value-bind (res a b c)
				  (surround-skip-syntax
				   "<" :regexp nil :reverse t :no-dup t :tail nil :ignore-escape t :ignore-string t :ignore-comment t :check
				   #'(lambda (pt begin1 str begin2)
					   (let ((end (save-excursion
									(when pt (goto-char pt))
									(multiple-value-bind (res b s e)
										(surround-skip-syntax ">" :reverse t :no-dup t :ignore-comment t :ignore-string t :ignore-escape t)
									  b))))
						 (cond ((or (not end) (< end begin1))
								(goto-char begin1) nil)
							   ((< begin1 end)
								(goto-char end)
								(goto-matched-parenthesis))
							   (t (goto-char begin1) nil)))))
				(values res a b c)))
   :end #'(lambda (arg-begin arg-str arg-end)
			(multiple-value-bind (res a b c)
				(surround-skip-syntax
				 ">" :tail t :ignore-escape t :ignore-string t :ignore-comment t
				 :check #'(lambda (pt begin1 str begin2)
							(let ((end (save-excursion
										 (when pt (goto-char pt))
										 (multiple-value-bind (res b s e)
											 (surround-skip-syntax "<" :tail t :ignore-comment t :ignore-string t :ignore-escape t)
										   b))))
							  (cond ((not end)
									 (goto-char begin1) nil)
									((< end begin1)
									 (goto-char end)
									 (goto-matched-parenthesis))
									(t
									 (goto-char begin1)
									 nil)))))
			  (values res a b c)))
   :condition #'(lambda () (and (syntax-open-tag-p #\<)
								(eq (parse-point-syntax) :tag)))
   :name "lt-gt"))

(defvar surround-range-paragraph
  (make-surround-range
   :begin #'(lambda () (goto-char surround-start-point) (backward-paragraph))
   :end #'(lambda (arg-begin arg-str arg-end) (goto-char surround-start-point) (forward-paragraph))
   :name "paragraph"))

(defvar surround-range-line
  (make-surround-range
   :begin #'(lambda () (goto-char surround-start-point) (goto-bol))
   :end #'(lambda (arg-begin arg-str arg-end) (goto-char surround-start-point) (goto-eol))
   :name "line"))

(defvar-local surround-expand-range-list
			  (list surround-range-string-double
					surround-range-string-single
					surround-range-parenthesis
					surround-range-braces
					surround-range-brackets
					surround-range-lt-gt
					surround-range-paragraph))

;;; keymap
(defvar *surround-mode-map* nil)
(defvar *surround-mode-key-replace* nil)

(defun surround-mode-init-keybind ()
  (unless *surround-mode-map*
	(setf *surround-mode-map* (make-sparse-keymap))
	(substitute-key-definition
	 'self-insert-command 'surround-self-insert-command
	 *surround-mode-map* *global-keymap*)
	(cond (*surround-mode-key-replace*
		   (substitute-key-definition
			'just-one-space 'surround-just-one-space
			*surround-mode-map* *global-keymap*)
		   (substitute-key-definition
			'upcase-region 'surround-upcase-region
			*surround-mode-map* *global-keymap*)
		   (substitute-key-definition
			'downcase-region 'surround-downcase-region
			*surround-mode-map* *global-keymap*)
		   (substitute-key-definition
			'exchange-point-and-mark 'surround-translate-position
			*surround-mode-map* *global-keymap*)
		   (substitute-key-definition
			'forward-char 'surround-forward-char
			*surround-mode-map* *global-keymap*)
		   (substitute-key-definition
			'backward-char 'surround-backward-char
			*surround-mode-map* *global-keymap*)
		   (substitute-key-definition
			'end-of-line 'surround-end-of-line
			*surround-mode-map* *global-keymap*)
		   (substitute-key-definition
			'query-replace 'surround-query-replace
			*surround-mode-map* *global-keymap*)
		   (substitute-key-definition
			'replace-string 'surround-replace-string
			*surround-mode-map* *global-keymap*)
		   (substitute-key-definition
			'kill-region 'surround-kill-region
			*surround-mode-map* *global-keymap*)
		   (substitute-key-definition
			'copy-region-as-kill 'surround-copy-region
			*surround-mode-map* *global-keymap*)
		   (substitute-key-definition
			'yank 'surround-yank
			*surround-mode-map* *global-keymap*)
		   (substitute-key-definition
			'backward-delete-char-untabify-or-selection 'surround-backward-delete-char
			*surround-mode-map* *global-keymap*)
		   (substitute-key-definition
			'delete-backward-char-or-selection 'surround-backward-delete-char
			*surround-mode-map* *global-keymap*)
		   (substitute-key-definition
			'delete-char-or-selection 'surround-delete-char
			*surround-mode-map* *global-keymap*)
		   (substitute-key-definition
			'delete-horizontal-spaces 'surround-delete-horizontal-spaces
			*surround-mode-map* *global-keymap*))
		  (t
		   (define-key *surround-mode-map* '(#\C-x #\C-u) 'surround-upcase-region)
		   (define-key *surround-mode-map* '(#\C-x #\C-l) 'surround-downcase-region)
		   (define-key *surround-mode-map* '(#\C-x #\C-x) 'surround-translate-position)
		   (define-key *surround-mode-map* #\M-/    'surround-just-one-space)
		   (define-key *surround-mode-map* #\M-\\   'surround-delete-horizontal-spaces)
		   (define-key *surround-mode-map* #\C-t    'surround-translate-position)
		   (define-key *surround-mode-map* #\M-t    'surround-translate-position)
		   (define-key *surround-mode-map* #\C-d    'surround-delete-char)
		   (define-key *surround-mode-map* #\Delete 'surround-delete-char)
		   (define-key *surround-mode-map* #\C-h    'surround-backward-delete-char)
		   (define-key *surround-mode-map* #\C-y    'surround-yank)
		   (define-key *surround-mode-map* #\M-w    'surround-copy-region)
		   (define-key *surround-mode-map* #\C-w    'surround-kill-region)
		   (define-key *surround-mode-map* #\M-r    'surround-replace-string)
		   (define-key *surround-mode-map* #\C-M-r  'surround-query-replace)
		   (define-key *surround-mode-map* #\C-e    'surround-end-of-line)
		   (define-key *surround-mode-map* #\C-b    'surround-backward-char)
		   (define-key *surround-mode-map* #\Left   'surround-backward-char)
		   (define-key *surround-mode-map* #\C-f    'surround-forward-char)
		   (define-key *surround-mode-map* #\Right  'surround-forward-char)))
	(define-key *surround-mode-map* #\C-m 'surround-mode-exit)
	(define-key *surround-mode-map* #\C-g 'surround-mode-quit)
	(define-key *surround-mode-map* #\M-h 'surround-expand-width)
	(define-key *surround-mode-map* #\M-d 'surround-reduce-width)
	(define-key *surround-mode-map* #\M-g 'surround-grep)
	(define-key *surround-mode-map* #\C-t 'surround-translate-position)
	(define-key *surround-mode-map* #\M-t 'surround-translate-position)
	(define-key *surround-mode-map* #\C-i 'surround-insert-snippet-or-indent)
	(run-hooks '*surround-mode-init-keybind-hook*)
	))
(if *app-menu*
	(surround-mode-init-keybind)
  (add-hook '*post-startup-hook* 'surround-mode-init-keybind))

(defun surround-mode-quit ()
  (interactive)
  (when surround-start-point
	(goto-char surround-start-point))
  (surround-mode-off))

(defun surround-mode-exit ()
  (interactive)
  (surround-mode-off))

(defun surround-delete-horizontal-spaces ()
  (interactive)
  (let ((begin (region-beginning)))
	(goto-char (region-end))
	(when (bolp)
	  (backward-char))
	(goto-bol)
	(while (< begin (point))
	  (delete-backward-char)
	  (delete-horizontal-spaces)
	  (goto-bol))
	(surround-mode-off)))

(defun surround-just-one-space ()
  (interactive)
  (let ((begin (region-beginning)))
	(goto-char (region-end))
	(when (bolp)
	  (backward-char))
	(goto-bol)
	(while (< begin (point))
	  (delete-backward-char)
	  (just-one-space)
	  (goto-bol))
	(surround-mode-off)))

(defun surround-copy-region ()
  (interactive)
  (let ((type (get-selection-type)))
	(cond ((= type 1)
		   (copy-region-as-kill (save-excursion
								  (goto-char (region-beginning))
								  (goto-bol)
								  (point))
								(save-excursion
								  (goto-char (region-end))
								  (goto-bol)
								  (backward-char)
								  (point))))
		  ((= type 3)
		   (operate-on-rectangle (mark) (point) nil (goal-column) :copy t))
		  (t
		   (call-interactively 'copy-region-as-kill)))
	(surround-mode-off)))

(defun surround-kill-region ()
  (interactive "*")
  (let ((type (get-selection-type)))
	(cond ((= type 1)
		   (kill-region (save-excursion
						  (goto-char (region-beginning))
						  (goto-bol)
						  (point))
						(save-excursion
						  (goto-char (region-end))
						  (goto-bol)
						  (backward-char)
						  (point))))
		  ((= type 3)
		   (operate-on-rectangle (mark) (point) nil (goal-column) :copy t :delete t))
		  (t
		   (call-interactively 'kill-region)))
		(surround-mode-off)))

(defun surround-yank ()
  (interactive "*")
  (let ((type (get-selection-type)))
	(cond ((and (= type 3)
				(/= (save-excursion
					  (goto-char (region-beginning))
					  (current-column))
					(save-excursion
					  (goto-char (region-end))
					  (current-column))))
		   (let ((from (region-beginning))
				 (end (region-end))
				 col1 col2)
			 (save-excursion
			   (goto-char from)
			   (setf col1 (current-virtual-column))
			   (goto-char end)
			   (setf col2 (current-virtual-column)))
			 (when (> col1 col2)
			   (rotatef col1 col2))
			 (goto-char from)
			 (goto-virtual-column col1)
			 (call-interactively 'overwrite-rectangle)))
		  ((= type 3)
		   (call-interactively 'yank-rectangle))
		  (t
		   (call-interactively 'yank)))
		(surround-mode-off)))

(defun surround-point-is-begin ()
  (= (point) (region-beginning)))
(defun surround-point-is-end ()
  (= (point) (region-end)))

(defun surround-backward-delete-char (&optional arg)
  (interactive "*p")
  (let ((type (get-selection-type))
		(beginp (surround-point-is-begin))
		(pt (point))
		(goal (goal-column)))
	(cond ((surround-edit-each-line-p)
		   (let ((dif (surround-edit-each-line-get-diff)))
			 (dolist (x surround-insert-point-alist)
			   (goto-virtual-line (car x))
			   (goto-column (+ (cdr x) dif))
			   (delete-backward-char))))
		  ((= type 3)
		   (let* ((col1 (current-virtual-column))
				  (col2 (save-excursion (goto-char (mark)) (current-virtual-column)))
				  pt)
			 (set-goal-column goal)
			 (cond ((and (= col1 col2 (goal-column))
						 (/= 0 col1))
					(delete-rectangle (1- (region-beginning)) (region-end))
					(setf pt (point))
					(goto-char (mark))
					(set-mark)
					(start-selection type)
					(goto-char pt))
				   (t
					(operate-on-rectangle (region-beginning) (region-end)
										  (if (< col1 col2) col1 col2)
										  (goal-column) :delete t)))))
		  ((and arg (eq surround-last-expand-type :scope)); C-u C-h
		   (when beginp
			 (exchange-point-and-mark))
		   (delete-backward-char)
		   (exchange-point-and-mark)
		   (delete-char)
		   (unless beginp
			 (exchange-point-and-mark))
		   (surround-mode-off))
		  ((/= (region-beginning) (region-end))
		   (delete-region (region-beginning) (region-end))
		   (surround-mode-off))
		  (t
		   (backward-delete-char-untabify-or-selection)))))

(defun surround-delete-char (&optional arg)
  (interactive "*p")
  (let ((type (get-selection-type))
		(beginp (surround-point-is-begin))
		(pt (point)))
	(cond ((surround-edit-each-line-p)
		   (let ((dif (surround-edit-each-line-get-diff)))
			 (dolist (x surround-insert-point-alist)
			   (goto-virtual-line (car x))
			   (goto-column (+ (cdr x) dif))
			   (delete-char))))
		  ((and arg (eq surround-last-expand-type :scope))
		   (delete-region (1+ (region-beginning))
						  (1- (region-end)))
		   (surround-mode-off))
		  ((/= (region-beginning) (region-end))
		   (delete-region (region-beginning) (region-end))
		   (surround-mode-off))
		  (t
		   (delete-char-or-selection)))))

(defun surround-upcase-region ()
  (interactive)
  (let ((type (get-selection-type))
		(beginp (surround-point-is-begin)))
	(cond ((= type 3)
		   (let ((col1 (current-virtual-column))
				 (col2 (save-excursion (goto-char (mark)) (current-virtual-column)))
				 begin)
			 (when (> col1 col2)
			   (rotatef col1 col2))
			 (save-excursion
			   (setf begin (region-beginning))
			   (goto-char (region-end))
			   (while (<= begin (point))
				 (upcase-region (progn (goto-virtual-column col1) (point))
								(progn (goto-virtual-column col2) (point)))
				 (goto-bol)
				 (backward-char)))))
		  (t (call-interactively 'upcase-region)))))

(defun surround-downcase-region ()
  (interactive)
  (let ((type (get-selection-type))
		(beginp (surround-point-is-begin)))
	(cond ((= type 3)
		   (let ((col1 (current-virtual-column))
				 (col2 (save-excursion (goto-char (mark)) (current-virtual-column)))
				 begin)
			 (when (> col1 col2)
			   (rotatef col1 col2))
			 (save-excursion
			   (setf begin (region-beginning))
			   (goto-char (region-end))
			   (while (<= begin (point))
				 (downcase-region (progn (goto-virtual-column col1) (point))
								  (progn (goto-virtual-column col2) (point)))
				 (goto-bol)
				 (backward-char)))))
		  (t (call-interactively 'downcase-region)))))

(defvar-local surround-edit-each-line-mode nil)
(defvar-local surround-insert-point-alist nil)

(defun surround-edit-each-line-get-diff ()
  (- (current-column)
	 (cdr (assoc (current-virtual-line-number) surround-insert-point-alist))))
;(surround-edit-each-line-get-diff)
;(surround-edit-each-line-p)

(defun surround-edit-each-line-p ()
  (let ((type (get-selection-type)))
	(when (and surround-edit-each-line-mode
			   surround-insert-point-alist)
	  (unless (assoc (current-virtual-line-number) surround-insert-point-alist)
		(setf surround-insert-point-alist
			  (acons (current-virtual-line-number) (current-virtual-column)
					 surround-insert-point-alist)))
	  t)))

(defun surround-self-insert-command (&optional arg)
  (interactive "*p")
  (let ((pair (assoc (string *last-command-char*) *surround-pair* :test 'equal))
		(beginp (surround-point-is-begin))
		(type (get-selection-type))
		(pt (point))
		(goal (goal-column)))
	(cond ((surround-edit-each-line-p)
		   (let ((dif (surround-edit-each-line-get-diff)))
			 (dolist (x surround-insert-point-alist)
			   (goto-virtual-line (car x))
			   (goto-column (+ (cdr x) dif))
			   (insert *last-command-char*))))
		  ((and type
				(= type 3);; 矩形選択 + Space入力
				(/= (save-excursion
					  (goto-char (region-beginning))
					  (current-column))
					(save-excursion
					  (goto-char (region-end))
					  (current-column)))
				(equal " " (string *last-command-char*)))
		   (let ((col (current-column)))
			 (call-interactively 'clear-rectangle)
			 (goto-column col)))
		  ((and type (= type 3));; 矩形選択 + 通常入力
		   (let* ((col1 (current-virtual-column))
				  (col2 (save-excursion (goto-char (mark)) (current-virtual-column)))
				  (col (if (< col1 col2) col1 col2))
				  begin)
			 (set-goal-column goal)
			 (when (/= col1 col2)
			   (operate-on-rectangle (region-beginning) (region-end) nil (goal-column) :delete t))
			 (save-excursion
			   (setf begin (region-beginning))
			   (goto-char (region-end))
			   (while (<= begin (point))
				 (goto-virtual-column col)
				 (insert *last-command-char*)
				 (goto-bol)
				 (backward-char)))
			 (setf pt (point))
			 (goto-char (mark))
			 (forward-char)
			 (set-mark)
			 (start-selection type)
			 (goto-char pt)
			 (forward-char)))
		  ((and type pair)
		   (cond ((= (mark) (region-beginning))
				  (insert (cdr pair))
				  (goto-char (mark))
				  (insert (car pair))
				  (goto-char (+ 2 pt)))
				 ((= (mark) (region-end))
				  (goto-char (mark))
				  (insert (cdr pair))
				  (set-mark)
				  (start-selection type)
				  (goto-char pt)
				  (insert (car pair))
				  (backward-char))))
		  (t
		   (setf *this-command* 'self-insert-command)
		   (call-interactively 'self-insert-command)))))

(defun surround-exchange-point (point type) ;; p1 to p2
  (set-mark)
  (stop-selection)
  (start-selection type)
  (goto-char point))

(defun surround-exchange-point-and-mark (&optional (type (get-selection-type)))
  (surround-exchange-point (mark) type))

(defun surround-reduce-width ()
  (interactive "p")
  (surround-increase-width t))

(defun surround-increase-width (&optional arg)
  (interactive "p")
  (let ((type (get-selection-type)))
	(when type
	  (save-excursion
		(cond ((= (mark) (region-end))
			   (goto-char (mark))
			   (if arg
				   (backward-char)
				 (forward-char)))
			  (t
			   (goto-char (mark))
			   (if arg
				   (forward-char)
				 (backward-char))))
		(start-selection type)
		(set-mark))
	  (if (= (point) (region-end))
		  (if arg
			  (backward-char)
			(forward-char))
		(if arg
			(forward-char)
		  (backward-char))))))

(defun surround-count-mark (from end mark)
  (cond ((= 1 (length mark))
		 (count (char mark 0) (buffer-substring from end) :test 'equal))
		(t
		 (let ((str (buffer-substring from end))
			   (start 0)
			   (count 0))
		   (while (string-match mark str start)
			 (incf count)
			 (setf start (match-end 0)))
		   count))))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun surround-symb (&rest args)
	(intern (apply #'(lambda (&rest args)
					   (with-output-to-string (s)
						 (dolist (a args) (princ a s))))
				   args)
			(find-package "editor"))))
(defmacro with-structure ((name . fields) struct &body body)
  (let ((g (gensym)))
	`(let ((,g ,struct))
	   (let ,(mapcar #'(lambda (f)
						 `(,f (,(surround-symb name f) ,g)))
					 fields)
		 ,@body))))

;; :string :uri :w_ :scope :whole-buffer :original-position
(defvar-local surround-last-expand-type nil)

(defun surround-expand-width (&optional arg)
  (interactive "p")
  (unless surround-mode-on
	(when surround-start-point
	  (goto-char surround-start-point))
	(return-from surround-expand-width))
  (let ((type (get-selection-type))
		(beginp (surround-point-is-begin))
		begin end)
	(cond ((let (tag1)
			 (save-excursion
			   (multiple-value-bind (from to tag)
				   (find-text-attribute-point (1- (region-end)))
				 (setf tag1 tag))
			   (multiple-value-bind (from to tag foreground background bold underline strike)
				   (find-text-attribute-point (region-beginning))
				 (when (and from to (equal tag tag1)
							(or foreground background bold underline strike))
				   (setf begin from end to)
				   (or (and (<= begin (region-beginning))
							(< (region-end) end))
					   (and (< begin (region-beginning))
							(<= (region-end) end)))))))
		   (goto-char begin)
		   (set-mark)
		   (start-selection type)
		   (goto-char end)
		   (setf surround-last-expand-type :attribute))
		  ((and (or (not surround-last-expand-type)
					(find surround-last-expand-type '(:string :original-position)))
				(dolist (regexp '(("[亜-龠]"      "[^亜-龠][亜-龠]+"           "[亜-龠]+")
								  ("[ぁ-ん]"      "[^ぁ-ん][ぁ-ん]+"           "[ぁ-ん]+")
								  ("[ァ-ヴー]"    "[^ァ-ヴー][ァ-ヴー]+"       "[ァ-ヴー]+")
								  ("[ｧ-ﾝﾞ]"       "[^-ｧ-ﾝﾞ][-ｧ-ﾝﾞ]+"           "[-ｧ-ﾝﾞ]+")
								  ("[０-９]"      "[^０-９][0-9０-９]+"        "[０-９]+")
								  ("[ａ-ｚＡ-Ｚ]" "[^ａ-ｚＡ-Ｚ][ａ-ｚＡ-Ｚ]+" "[ａ-ｚＡ-Ｚ]+")))
				  (and (string-match (first regexp) (string (following-char)))
					   (setf begin (save-excursion
									 (goto-char (region-beginning))
									 (when (scan-buffer (second regexp) :regexp t :reverse t)
									   (1+ (match-beginning 0)))))
					   (setf end (save-excursion
								   (goto-char (region-end))
								   (when (scan-buffer (third regexp) :regexp t)
									 (match-end 0))))
					   (string-match (third regexp) (buffer-substring begin end))
					   (equal (match-string 0) (buffer-substring begin end))
					   (or (and (<= begin (region-beginning))
								(< (region-end) end))
						   (and (< begin (region-beginning))
								(<= (region-end) end)))
					   (return t))))
		   (goto-char begin)
		   (set-mark)
		   (start-selection type)
		   (goto-char end)
		   (setf surround-last-expand-type :string))
		  ((and (modulep "clickable-uri")
				(let ((regexp (eval (intern "*clickable-uri-regexp*" "editor")))
					  pt eol)
				  (and regexp
					   (save-excursion
						 (setf pt (point)
							   eol (save-excursion (goto-eol) (point)))
						 (goto-bol)
						 (while (scan-buffer regexp :tail t :limit eol)
						   (setf begin (match-beginning 0)
								 end (match-end 0))
						   (when (or (and (<= begin (region-beginning))
										  (< (region-end) end))
									 (and (< begin (region-beginning))
										  (<= (region-end) end)))
							 (return t)))))))
		   (goto-char begin)
		   (set-mark)
		   (start-selection type)
		   (goto-char end)
		   (setf surround-last-expand-type :uri))
		  ((and (or (not surround-last-expand-type)
					(find surround-last-expand-type '(:w_ :uri :string :original-position)))
			   (progn
				 (setf begin (save-excursion
							   (goto-char (region-beginning))
							   (skip-syntax-spec-backward "@w_")
							   (point)))
				 (setf end (save-excursion
							 (goto-char (region-end))
							 (skip-syntax-spec-forward "@w_")
							 (point)))
				 (or (and (<= begin (region-beginning))
						  (< (region-end) end))
					 (and (< begin (region-beginning))
						  (<= (region-end) end)))))
		   (goto-char begin)
		   (set-mark)
		   (start-selection type)
		   (goto-char end)
		   (setf surround-last-expand-type :w_))
		  ((surround-expand-width-by-range)
		   (setf surround-last-expand-type :scope))
		  ((not (equal surround-last-expand-type :whole-buffer))
		   ;全部選択
		   (cond (beginp
				  (goto-char (point-max))
				  (set-mark)
				  (start-selection type)
				  (goto-char (point-min)))
				 (t
				  (goto-char (point-min))
				  (set-mark)
				  (start-selection type)
				  (goto-char (point-max))))
		   (setf surround-last-expand-type :whole-buffer))
		  (t
		   ;元の場所に戻る
		   (goto-char surround-start-point)
		   (set-mark)
		   (start-selection type)
		   (setf surround-last-expand-type :original-position)))
	;(message "expand: ~A" surround-last-expand-type)
	))

(defun surround-expand-width-by-range ()
  (let ((type (get-selection-type))
		(beginp (surround-point-is-begin))
		(endp (surround-point-is-end))
		(from (region-beginning))
		(to (region-end))
		(from1 (region-beginning))
		(to1 (region-end))
		res)
	(dolist (range surround-expand-range-list)
	  (with-structure
	   (surround-range- condition begin end name) range
	   (let ((mark-point (mark)))
		 (when (let (match-beginning match-string match-end res)
				 (save-excursion
				   (and (or (not condition)
							(funcall condition))
						(or (not begin)
							(progn
							  (unless beginp
								(surround-exchange-point-and-mark))
							  (multiple-value-setq (res match-beginning match-string match-end)
								(funcall begin))
							  (unless beginp
								(surround-exchange-point-and-mark))
							  res))
						(or (not end)
							(progn
							  (when beginp
								(surround-exchange-point-and-mark))
							  (multiple-value-setq (res match-beginning match-string match-end)
								(funcall end match-beginning match-string match-end))
							  (when beginp
								(surround-exchange-point-and-mark))
							  res))
						(or (and (<= (region-beginning) from)
								 (< to (region-end)))
							(and (< (region-beginning) from)
								 (<= to (region-end))))
						(setf from (region-beginning)
							  to (region-end))
						range)))
		   (push (list from to) res)
		   (setf from from1 to to1))
		 (exchange-point-and-mark)
		 (goto-char mark-point)
		 (exchange-point-and-mark))))
	(when res
	  (setf res (reverse res))
	  (if (cdr res) ; 候補が2つ以上あるとき
		  (let ((tmp (car res)))
			(dolist (x (cdr res))
			  (when (or (and (<= (first tmp) (first x))
							 (> (second tmp) (second x)))
						(and (< (first tmp) (first x))
							 (>= (second tmp) (second x))))
				(setf tmp x)))
			(setf res tmp))
		(setf res (car res)))
	  (setf from (first res)
			to (second res))
	  (cond ((and beginp (not endp))
			 (goto-char from)
			 (surround-exchange-point-and-mark)
			 (goto-char to)
			 (surround-exchange-point-and-mark))
			(t
			 (surround-exchange-point-and-mark)
			 (goto-char from)
			 (surround-exchange-point-and-mark)
			 (goto-char to)))
	  t)))

(defun surround-translate-position ()
  (interactive)
  (unless surround-mode-on
	(exchange-point-and-mark)
	(return-from surround-translate-position))
  (unless surround-change-position-flag
	(setf surround-change-position-flag t))
  (let ((type (get-selection-type)))
	(case (get-selection-type)
	  (3
	   ; 矩形選択範囲の頂点を右回りに。左上と右上を主に。
	   (let ((from (region-beginning))
			 (end (region-end))
			 (goal (goal-column))
			 col1 col2
			 left-top left-bottom
			 right-top right-bottom)
		 (save-excursion
		   (goto-char from)
		   (setf col1 (current-virtual-column))
		   (goto-char end)
		   (setf col2 (current-virtual-column)))
		 (when (> col1 col2)
		   (rotatef col1 col2))
		 (save-excursion
		   ; left-top
		   (goto-char from)
		   (goto-virtual-column col1)
		   (setf left-top (point))
		   ; left-bottom
		   (goto-char end)
		   (goto-virtual-column col1)
		   (setf left-bottom (point))
		   ; right-top
		   (goto-char from)
		   (goto-virtual-column col2)
		   (setf right-top (point))
		   ; right-bottom
		   (goto-char end)
		   (goto-virtual-column col2)
		   (setf right-bottom (point)))
		 (cond ((= left-top (point))
				(surround-exchange-point right-bottom type))
			   ((= left-bottom (point))
				(goto-char right-bottom)
				(surround-exchange-point left-top type))
			   ((= right-top (point))
				(goto-char left-top)
				(surround-exchange-point right-bottom type))
			   ((= right-bottom (point))
				(surround-exchange-point left-top type)))
		 (set-goal-column goal)))
	  (t
	   (surround-exchange-point (mark) type)))))

(defun surround-search-forward-again ()
  (interactive)
  (setf *last-search-string* (buffer-substring (point) (mark)))
  (surround-mode-off)
  (call-interactively 'search-forward-again))

(defun surround-search-backward-again ()
  (interactive)
  (setf *last-search-string* (buffer-substring (point) (mark)))
  (surround-mode-off)
  (call-interactively 'search-backward-again))

(defun surround-get-max-column-region ()
  (let ((goal (goal-column))
		(res (current-virtual-column))
		(begin (= (point) (region-beginning))))
	(save-excursion
	  (narrow-to-region (point) (mark))
	  (goto-char (point-min))
	  (while (/= (point) (point-max))
		(goto-eol)
		(when (< res (current-virtual-column))
		  (setf res (current-virtual-column)))
		(forward-char)))
	(widen)
	(set-goal-column goal)
	res))

(defun surround-end-of-line ()
  (interactive)
  (cond ((and (realp (get-selection-type))
			  (= 3 (get-selection-type))
			  (/= (progn (goto-eol) (current-column))
				  (surround-get-max-column-region)))
		 (set-goal-column (surround-get-max-column-region)))
		(t
		 (call-interactively 'end-of-line))))

(defun surround-forward-char ()
  (interactive)
  (cond ((and (realp (get-selection-type))
			  (= 3 (get-selection-type))
			  (virtual-eolp)
			  (< (goal-column) (surround-get-max-column-region)))
		 (set-goal-column (1+ (goal-column))))
		(t
		 (setf *this-command* 'forward-char)
		 (forward-char))))

(defun surround-backward-char ()
  (interactive)
  (cond ((and (realp (get-selection-type))
			  (= 3 (get-selection-type))
			  (= (current-column) (goal-column))
			  (virtual-bolp))
		 (backward-char)
		 (when (virtual-eolp)
		   (set-goal-column (surround-get-max-column-region))))
		((and (realp (get-selection-type))
			  (= 3 (get-selection-type))
			  (< (current-column) (goal-column)))
		 (set-goal-column (1- (goal-column))))
		(t
		 (setf *this-command* 'backward-char)
		 (call-interactively 'backward-char))))

(defun surround-insert-snippet-or-indent (&optional arg)
  (interactive "*P")
  (let ((begin (region-beginning))
		(end (region-end)))
	(cond ((and (not arg)
				(modulep "snippet"))
		   (surround-mode-off)
		   (goto-char begin)
		   (start-selection 2 t)
		   (goto-char end)
		   (funcall (intern "snippet-select-and-expand" "editor")))
		  ((and (boundp 'mode-specific-indent-command)
				(or (si:*closurep mode-specific-indent-command)
					(fboundp mode-specific-indent-command)))
		   (indent-region (save-excursion (goto-char begin) (previous-line) (point))
						  end)))))

(defun surround-grep ()
  (interactive)
  (let* ((bfn (get-buffer-file-name))
		 ext pattern file dir
		 *minibuffer-default-history*
		 (*grep-word-search* *surround-grep-word-search*)
		 (*grep-case-fold-search* *surround-grep-case-fold*)
		 (*grep-regexp-search* *surround-grep-regexp*)
		 (*grep-subdir* *surround-grep-subdir*)
		 (*grep-name-only* *surround-grep-name-only*)
		 (*grep-understand-escape-sequences* *surround-grep-escape-sequences*))
	(setf ext (cdr (assoc (or bfn (buffer-name (selected-buffer))) *surround-grep-ext-alist*
						  :test #'(lambda (x y)
									(string-match y x)))))
	(setf *minibuffer-default-history* *minibuffer-search-string-history*
		  pattern (completing-read "Grep: "
								   *minibuffer-search-string-history*
								   :default (buffer-substring (region-beginning) (region-end)))
		  *minibuffer-default-history* *grep-file-history*
		  file (completing-read "Files: "
								*grep-file-history*
								:default (or ext (if bfn (concat "*." (pathname-type bfn)) "*.*")))
		  *minibuffer-default-history* *grep-directory-history*
		  dir (read-directory-name "Directory: "
								   :default (default-directory)
								   :history '*grep-directory-history*))
	(surround-mode-off)
	(add-history pattern '*minibuffer-search-string-history*)
	(add-history file '*grep-file-history*)
	(add-history dir '*grep-directory-history*)
	(ed::scan-files pattern (split-string file #\; t " ") dir *surround-grep-async*)))

(defun surround-replace-string (replacement &optional noerror)
  (interactive "*swith: "
	:default0 (cond ((equal *last-replace-string* "")
					 (buffer-substring (region-beginning) (region-end)))
					(t *last-replace-string*))
	:history0 'search)
  (surround-mode-off)
  (unless (surround-point-is-begin)
	(exchange-point-and-mark))
  (perform-replace (buffer-substring (region-beginning) (region-end))
				   replacement nil nil (interactive-p) noerror))

(defun surround-query-replace (replacement &optional noerror)
  (interactive "*swith: "
	:default0 (cond ((equal *last-replace-string* "")
					 (buffer-substring (region-beginning) (region-end)))
					(t *last-replace-string*))
	:history0 'search)
  (surround-mode-off)
  (unless (surround-point-is-begin)
	(exchange-point-and-mark))
  (perform-replace (buffer-substring (region-beginning) (region-end))
				   replacement t nil (interactive-p) noerror))

(defun surround-before ()
  (if surround-mode-on
	  (progn
		(cond ((find *this-command* *surround-search-command* :test 'equal)
			   (setf *last-search-regexp-p* nil)
			   (when (/= (point) (mark))
				 (setf *last-search-string* (buffer-substring (point) (mark))))
			   (surround-mode-off)
			   (when (modulep "igsearch")
				 (setf *igsearch-repeat-soon* t)))
			  ((and surround-edit-each-line-mode
					(find *this-command* '(next-virtual-line) :test 'equal))
			   (let (res)
				 (cond ((setf res (assoc (current-virtual-line-number) surround-insert-point-alist))
						(setf (cdr res) (current-column)))
					   (t
						(setf surround-insert-point-alist
							  (acons (current-virtual-line-number) (current-column) surround-insert-point-alist))))))
			  ((and surround-edit-each-line-mode
					(not (find *this-command* surround-edit-each-line-command :test 'equal)))
			   (surround-mode-off))
			  (t nil))
		(setf surround-goal-column (goal-column)))
	(surround-mode-off)))

(defun surround-after ()
  (when surround-mode-on
	(cond ((string-match *surround-exit-command-regexp* (string *this-command*))
		   (surround-mode-off))
		  ((equal *this-command* 'exchange-point-and-mark)
		   (let ((pt (point)))
			 (goto-char (mark))
			 (surround-exchange-point-and-mark (get-selection-type))))
		  (t nil))))

(defun surround-mode (&optional (arg nil sv))
  (interactive "p")
  (let ((before surround-mode-on))
	(toggle-mode 'surround-mode-on arg sv)
	(cond ((and (not before)
				surround-mode-on)
		   (setf surround-start-point (point))
		   (set-mark)
		   (start-selection 2)
		   (setf surround-type "Word"))
		  ((and before surround-mode-on)
		   (let ((type (get-selection-type)))
			 ;; 文字 → 矩形 → 行 → 各行編集
			 (cond ((equal type 1)
					(stop-selection)
					(setf surround-type "Edit Each-line"
						  surround-edit-each-line-mode t))
				   ((equal type 2)
					(set-selection-type 3)
					(setf surround-type "Rectangle"))
				   ((equal type 3)
					(set-selection-type 1)
					(setf surround-type "Line"))
				   (t
					(start-selection 2)
					(setf surround-type "Word"
						  surround-insert-point-alist nil
						  surround-edit-each-line-mode nil))))
;; 		   (case (get-selection-type)
;; 			 (1 (set-selection-type 2)
;; 				(setf surround-type "Word"))
;; 			 (2 (set-selection-type 3)
;; 				(setf surround-type "Rectangle"))
;; 			 (3 (set-selection-type 1)
;; 				(setf surround-type "Line"
;; 					  surround-insert-point-alist nil
;; 					  surround-edit-each-line-mode nil))
;; 			 (t (start-selection 2)))
		   )))
  (cond (surround-mode-on
		 (setf surround-change-position-flag nil
			   surround-last-expand-type nil)
		 (update-mode-line)
		 (set-minor-mode-map *surround-mode-map*)
		 (add-hook '*pre-command-hook* 'surround-before)
		 (add-hook '*post-command-hook* 'surround-after))
		(t
		 (unset-minor-mode-map *surround-mode-map*)
		 (setf surround-insert-point-alist nil
			   surround-edit-each-line-mode nil)
		 (stop-selection)
		 (delete-hook '*pre-command-hook* 'surround-before)
		 (delete-hook '*post-command-hook* 'surround-after)))
  (update-mode-line)
  (run-hooks '*surround-mode-hook*)
  t)

(defun surround-mode-select-line ()
  (interactive)
  (unless surround-mode-on
	(surround-mode-on))
  (let ((surround-expand-range-list (list surround-range-line)))
	(declare (special surround-expand-range-list))
	(when (surround-expand-width-by-range)
	  (setf surround-last-expand-type :scope))))

(defun surround-mode-on ()
  (interactive)
  (surround-mode t))

(defun surround-mode-off ()
  (interactive)
  (surround-mode nil))

(defun set-mark-surround ()
  (interactive)
  (surround-mode-on))

(global-set-key #\M-s 'set-mark-surround)
;(global-set-key #\M-C-l 'surround-mode-select-line)

;;; surround.l ends here
