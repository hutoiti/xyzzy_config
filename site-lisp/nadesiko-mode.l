;;; -*- Mode: Lisp; Package: USER; Last modified: "2007/12/31 01:12:21"; -*-
;;;
;;; This file is not part of xyzzy.
;;;
;;;   nadesiko-mode.l --- なでしこモード
;;;
;;;     by HIE Masahiro <madoinu@ybb.ne.jp>
#|

■概要

  日本語プログラミング言語 なでしこ (http://nadesi.com/) 編集用の
  メジャーモードです。


■インストール

  1. nadesiko-mode.l を site-lisp にコピーする。

  2. 必要に応じ，バイトコンパイルする。

       M-x byte-compile-file

  3. .xyzzy か siteinit.l に以下の記述を追加する。

      (require "nadesiko-mode")
      (pushnew '("\\.nako" . nadesiko-mode) *auto-mode-alist* :test 'equal)

  4. xyzzy を再起動し，設定を反映させる。
     siteinit.l に記述した場合は再ダンプもする。


■キーバインド



■設定例

  ;;; なでしこを C:/nadesiko/ にインストールした場合
  (defvar *nadesiko-path* "C:/nadesiko/")


■注意事項

・メニューの [実行] は，バッファのデータが保存されている必要があります。
  未保存時に実行すると「ファイルに保存する？」と問いかけます。ここで "い
  いえ" を選択すると実行されません。ただし，[選択範囲または1行実行]を使
  用すると，未保存の状態でも実行することができます。

・なでしこエディタで開いて編集する場合は，[排他制御] を "しない" か 
  "編集してるときだけ" にしておかないと駄目です。

・文字列の区切り文字として「」や『』を使うと，\ によるエスケープが効きま
  せん。そんな場合は， "" か `` を使ってください。

・インデントなんてむつかしいことはできません。RET(newline) と 
  LFD(newline-and-indent) が入れ替えてあるだけです。


■更新履歴:

  [Version 1.04] 2007-12-31 (月)
  ・MITライセンスにした。
  ・色付け時に，助詞より先に予約語をマッチさせるようにした。

  [Version 1.03] いつ？
  ・半角スペースを含むパスの処理が不味かったのを修正した。
  ・存在しない対話式実行を削除した。

  [Version 1.02]
  ・require して使うようにした。
  ・関数名をいろいろと変更した。
  ・半角スペース 4 つでインデントするようにした。
  ・TAB キーでインデントできるようにした。

  [Version 1.01] 2005-03-03 (Thu)
  ・タブでインデントするようにした。
  ・shift-selection, unshift-selection をそれぞれ M-i, M-u にバインドした。

  [Version 1.00] 2005-03-01 (Tue)
  ・つくった。


■ライセンス

  nadesiko-mode.l はMITライセンスに基づいて利用可能です。
  <http://www.opensource.org/licenses/mit-license.php>

Copyright (c) 2007 HIE Masahiro

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

|#

(provide "nadesiko-mode")

(defconstant *nadesiko-mode-version* "1.03")

;;; ──────────────────────────────────── ;;;
;;;  ■ 変数設定（適当にカスタマイズするあたり）
;;; ──────────────────────────────────── ;;;

;;; インストールパス
(defvar *nadesiko-path* "C:/usr/local/nadesiko/")

;;; 実行ファイル名
(defvar *nadesiko-execute-file* "vnako.exe")

;;; なでしこ Web Site
(defvar *nadesiko-home-url* "http://nadesi.com/")

;;; 正規表現色付け用表示色
(defvar *nadesiko-comment-color* '(:keyword :comment)) ; コメント
(defvar *nadesiko-syntax-keyword-color* '(:color 12 0))	; 構文キーワード
(defvar *nadesiko-reserve-word-color* '(:color 12 0)) ; 予約語
(defvar *nadesiko-josi-color* '(:color 9 0)) ; 助詞
(defvar *nadesiko-brackets-color* '(:keyword :string)) ; 括弧（文字列）
(defvar *nadesiko-integer-color* '(:color 12 0)) ; 数値
(defvar *nadesiko-label-color* '(:color 5 0)) ; ラベル
(defvar *nadesiko-operator-color* '(:color 4 0)) ; 演算子
(defvar *nadesiko-punc-color* '(:color 14 0)) ; 句読点
(defvar *nadesiko-misc-color* '(:color 14 0)) ; いろいろ

;;; インデント桁数
(defvar *nadesiko-indent-columns* 4)

;;; タブでインデント
(defvar *nadesiko-indent-tabs-mode* nil)

(defvar *nadesiko-menu-name*  "なでしこ(&N)")


;;; ──────────────────────────────────── ;;;
;;;  ■ その他の変数設定
;;; ──────────────────────────────────── ;;;

(defvar *nadesiko-app-menu* nil)
(defvar *nadesiko-command-menu* nil)
(defvar *nadesiko-mode-hook* nil)
(defvar *nadesiko-regexp-keyword-list* nil)

(defvar *nadesiko-mode-map* nil)
(unless *nadesiko-mode-map*
  (setq *nadesiko-mode-map* (make-sparse-keymap))
  (define-key *nadesiko-mode-map* #\RET 'newline-and-indent)
  (define-key *nadesiko-mode-map* #\LFD 'newline)
  (define-key *nadesiko-mode-map* #\TAB 'nadesiko-indent-line)
  (define-key *nadesiko-mode-map* '(#\C-c #\e) 'nadesiko-editor)
  (define-key *nadesiko-mode-map* '(#\C-c #\x) 'nadesiko-file-execute)
  (define-key *nadesiko-mode-map* '(#\C-c #\p) 'nadesiko-command-menu)
  (define-key *nadesiko-mode-map* '(#\C-c #\C-x) 'nadesiko-execute-partly)
  (define-key *nadesiko-mode-map* '(#\C-c #\?) 'nadesiko-version))

(defvar *nadesiko-mode-syntax-table* nil)
(unless *nadesiko-mode-syntax-table*
  (setq *nadesiko-mode-syntax-table* (make-syntax-table))
  (set-syntax-match *nadesiko-mode-syntax-table* #\( #\))
  (set-syntax-match *nadesiko-mode-syntax-table* #\( #\))
  (set-syntax-escape *nadesiko-mode-syntax-table* #\\)
  (set-syntax-string *nadesiko-mode-syntax-table* #\")
  (set-syntax-string *nadesiko-mode-syntax-table* #\`)
  (set-syntax-start-comment *nadesiko-mode-syntax-table* #\#)
  (set-syntax-end-comment *nadesiko-mode-syntax-table* #\LFD nil t)
  (set-syntax-start-multi-comment *nadesiko-mode-syntax-table* "/*")
  (set-syntax-end-multi-comment *nadesiko-mode-syntax-table* "*/")
  )

(setq *nadesiko-regexp-keyword-list*
      (compile-regexp-keyword-list
       `(
	 ;;コメント
	 ("\\(※\\|’\\|'\\|//\\|＃\\).*" t ((0 . ,*nadesiko-comment-color*)))
	 ;;構文キーワード
	 ("\\(違えば\\|繰り返す\\|繰り返し\\|戻る\\|抜ける\\|続ける\\|終わる\\|終わり\\)"
	  t ((1 . ,*nadesiko-syntax-keyword-color*)))
	 ;;予約語
	 (,(concat "\\(表示\\|言\\|代入\\|はい\\|いいえ\\|ここまで\\|キャンセル\\|オン\\|オフ"
		   "\\|それ\\|ナデシコ\\|文字列\\|数値\\|整数\\|実数\\|変数\\|配列\\|実数"
		   "\\|ハッシュ\\|グループ\\|変数宣言\\|必要\\|不要\\|もし\\|なら\\|ならば"
		   "\\|違\\|間\\|反復\\|繰\\|エラー\\|監視\\|条件分岐\\|ループ"
		   "\\|抜\\|戻\\|おわり\\|おわる\\)")
	  t ((0 . ,*nadesiko-reserve-word-color*)))
	 ;;助詞
	 (,(concat "\\(でなければ\\|について\\|ならば\\|として\\|くらい\\|なのか\\|までを"
		   "\\|なら\\|より\\|から\\|まで\\|ほど\\|して\\|だけ\\|など\\|とは\\|って"
		   "\\|で\\|を\\|の\\|が\\|に\\|へ\\|と\\|は\\|て\\)")
	  t ((0 . ,*nadesiko-josi-color*)))
	 ("\\(?:\\([0-9０-９]+\\)\\(回\\)\\|[})）]\\(回\\)\\)"
	  t ((1 . ,*nadesiko-integer-color*) (2 . ,*nadesiko-reserve-word-color*)
	     (3 . ,*nadesiko-reserve-word-color*)))
	 ;;ラベル
	 ("^[＊●■].*" t ((0 . ,*nadesiko-label-color*)))
	 ;;句読点
	 ("[][、，。;]" t ((0 . ,*nadesiko-punc-color*)))
	 ;;いろいろ
	 ("[][()（）#＃\\￥@＠！～←→]" t ((0 . ,*nadesiko-misc-color*)))
	 ;;演算子
	 ("[＋－×÷／≦≧≠＜＞％＾!|&＆=＝]" t ((0 . ,*nadesiko-operator-color*)))
	 ("\\([ 　0-9０-９]+\\)\\([<>*/+^-]\\)\\([ 　0-9０-９]+\\)" t
	  ((1 . ,*nadesiko-integer-color*) (2 . ,*nadesiko-operator-color*) (3 . ,*nadesiko-integer-color*)))
	 ;;括弧（文字列の区切り文字）
	 ("\\(「[^」]*」\\|『[^』]*』\\)" t ((0 . ,*nadesiko-brackets-color*)))
	 ;;数値
	 ;("[^a-zA-Z]+\\([0-9]+\\)[^a-zA-Z]+" t ((1 . ,*nadesiko-integer-color*)))
	 ("[0-9０-９]+" t ((0 . ,*nadesiko-integer-color*)))
	 )))


;;; ──────────────────────────────────── ;;;
;;;  ■ なでしこモード
;;; ──────────────────────────────────── ;;;

(defun nadesiko-mode ()
  (interactive)
  (kill-all-local-variables)
  (setq buffer-mode 'nadesiko-mode)
  (setq mode-name "Nadesiko")
  (use-keymap *nadesiko-mode-map*)
  (use-syntax-table *nadesiko-mode-syntax-table*)
  (make-local-variable 'regexp-keyword-list)
  (setq regexp-keyword-list *nadesiko-regexp-keyword-list*)
  (make-local-variable 'indent-tabs-mode)
  (setq indent-tabs-mode *nadesiko-indent-tabs-mode*)
  (nadesiko-menu-update)
  (run-hooks '*nadesiko-mode-hook*))

;;; なでしこエディタで開く
(defun nadesiko-editor (&optional file)
  (interactive)
  (when (or (not (buffer-modified-p))
	    (and (yes-or-no-p "ファイルを保存しますよ。")
		 (save-buffer)))
    (call-process (concat (merge-pathnames "nakopad.exe" *nadesiko-path*) " \""
			  (map-slash-to-backslash (or file (get-buffer-file-name))) "\""))))

;;; なでしこファイル実行
(defun nadesiko-file-execute (&optional file wait)
  (interactive)
  (if (or file
	  (not (buffer-modified-p))
	  (and (yes-or-no-p "ファイルを保存しますよ。")
	       (save-buffer)))
      (call-process (concat (merge-pathnames *nadesiko-execute-file* *nadesiko-path*) " \""
			    (map-slash-to-backslash (or file (get-buffer-file-name))) "\"")
		    :wait wait)
    (message "実行を中止した。")))

;;; なでしこ実行
(defun nadesiko-execute (data &optional file)
  (interactive "sなでしこ命令: ")
  (let ((f (make-temp-file-name "_" "nako" "~/")))
    (with-open-file (s f
		       :direction :output
		       :if-exists :overwrite
		       :if-does-not-exist :create)
      (format s "~A~%" data))
    (when (file-exist-p f)
      (nadesiko-file-execute f t)
      (sit-for 1)
      (delete-file f))))

;;; について
(defun nadesiko-about ()
  (interactive)
  (message "なでしこモード for xyzzy version ~A" *nadesiko-mode-version*)
  (nadesiko-file-execute (merge-pathnames "tools/about.nako" *nadesiko-path*)))

;;; なでしこ部分実行
(defun nadesiko-execute-partly ()
  (interactive)
  (let (s e code)
    (if (pre-selection-p)
	(selection-start-end (start end)
	  (setf s start
		e end))
      (save-excursion
	(setf s (progn (goto-bol) (point))
	      e (progn (goto-eol) (point)))))
    (reverse-region s e t)
    (next-line)
    (setf code (buffer-substring s e))
    (nadesiko-execute code)))

;;; マニュアル表示
(defun nadesiko-manual ()
  (interactive)
  (shell-execute (merge-pathnames "index.htm" (merge-pathnames "doc" *nadesiko-path*))))

;;; ホームページ表示
(defun nadesiko-home ()
  (interactive)
  (shell-execute *nadesiko-home-url* t))

;;; インチキインデント
(defun nadesiko-indent-line (&optional arg)
  (interactive "p")
  (if (pre-selection-p)
      (if arg
	  (unshift-selection *nadesiko-indent-columns*)
	(shift-selection *nadesiko-indent-columns*))
    (let ((p (bolp))
	  (x (if arg -1 1)))
      (save-excursion
	(shift-region (progn (goto-bol) (point))
		      (progn (goto-eol) (point))
		      (* x *nadesiko-indent-columns*)))
      (when p (back-to-indentation)))))


;;; ──────────────────────────────────── ;;;
;;;  ■ なでしこコマンドメニュー
;;; ──────────────────────────────────── ;;;

;;; コマンドメニュー表示
(defun nadesiko-command-menu ()
  (interactive)
  (unless *nadesiko-command-menu*
    (nadesiko-create-popup-menu))
  (track-popup-menu *nadesiko-command-menu*))

;;; command.txt からポップアップメニューを作成
(defun nadesiko-create-popup-menu ()
  (long-operation
    (let ((b (get-buffer-create "*nadesiko-cmd*")))
      (set-buffer b)
      (insert-file-contents
       (merge-pathnames "command.txt" (merge-pathnames "tools" *nadesiko-path*)))
      (goto-char (point-min))
      (let ((menu (create-popup-menu)) m1 m2)
	(while (not (eobp))
	  (message "なでしこメニュー作成中 ... ~D" (current-line-number))
	  (when (looking-at "^+")
	    (setf m1 (create-popup-menu))
	    (add-popup-menu menu m1
			    (buffer-substring (progn (forward-char 1) (point))
					      (progn (goto-eol) (point)))))
	  (when (looking-at "^-")
	    (setf m2 (create-popup-menu))
	    (add-popup-menu m1 m2
			    (buffer-substring (progn (forward-char 1) (point))
					      (progn (goto-eol) (point)))))
	  (when (looking-at "^|")
	    (let ((c (buffer-substring (progn (forward-char 1) (point))
				       (progn (scan-buffer ",\"") (point))))
		  (s (buffer-substring (progn (scan-buffer "\",\"" :no-dup t :tail t) (point))
				       (progn (scan-buffer "\",") (point)))))
	      (add-menu-item m2 nil (concat c "	" s)
			     #'(lambda () (interactive) (insert c)))))
	  (next-line)
	  (goto-bol))
	(delete-buffer b)
	(setf *nadesiko-command-menu* menu)))))


;;; ──────────────────────────────────── ;;;
;;;  ■ なでしこアプリメニュー
;;; ──────────────────────────────────── ;;;

(defun nadesiko-menu-update ()
  (interactive)
  (use-local-menu (nadesiko-add-menu)))

(defun nadesiko-add-menu ()
  (let ((menu (copy-menu-items *app-menu* (create-menu))))
    (insert-popup-menu menu (get-menu-position menu 'ed::help)
                       *nadesiko-app-menu*
                       *nadesiko-menu-name*)
    menu))

(add-hook
 '*init-app-menus-hook*
 #'(lambda ()
     (unless *nadesiko-app-menu*
       (setq *nadesiko-app-menu*
	     (let ((menu (create-popup-menu)))
	       (add-menu-item menu nil "なでしこエディタで開く(&E)" 'nadesiko-editor)
	       (add-menu-item menu nil "なでしこコマンドメニュー(&P)" 'nadesiko-command-menu)
	       (add-menu-separator menu)
	       (add-menu-item menu nil "実行(&X)" 'nadesiko-file-execute)
	       (add-menu-item menu nil "選択範囲または1行だけ実行(&L)" 'nadesiko-execute-partly)
	       (add-menu-separator menu)
	       (add-popup-menu menu
			       (define-popup-menu
				 (:item nil "標準GUI - vnako.exe(&G)"
				  #'(lambda () (interactive) (nadesiko-toggle-execute-file "vnako.exe"))
				  #'(lambda () (when (equal *nadesiko-execute-file* "vnako.exe") :check)))
				 (:item nil "簡易GUI - gnako.exe(&U)"
				  #'(lambda () (interactive) (nadesiko-toggle-execute-file "gnako.exe"))
				  #'(lambda () (when (equal *nadesiko-execute-file* "gnako.exe") :check)))
				 (:item nil "コンソール - cnako.exe(&C)"
				  #'(lambda () (interactive) (nadesiko-toggle-execute-file "cnako.exe"))
				  #'(lambda () (when (equal *nadesiko-execute-file* "cnako.exe") :check)))
				 ) "なでしこ実行方式(&Y)")

	  (add-menu-separator menu)
	  (add-menu-item menu nil "マニュアル(&H)" 'nadesiko-manual)
	  (add-menu-item menu nil "なでしこのページ(&H)" 'nadesiko-home)
	  (add-menu-item menu nil "について(&A)..."  'nadesiko-about)
	  menu)))))

(defun nadesiko-toggle-execute-file (&optional file)
  (interactive)
  (setf *nadesiko-execute-file*
	(or file (cond ((equal *nadesiko-execute-file* "vnako.exe") "gnako.exe")
		       ((equal *nadesiko-execute-file* "gnako.exe") "cnako.exe")
		       (t "vnako.exe")))))


;;; nadesiko-mode.l は，ここまで。
