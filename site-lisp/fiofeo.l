#|
version  2007.10.10
category Utilities

■説明
なんかこうファイルリストを readme.txt/hoge/c:/ みたいに変換して
ミニバッファで補完しながら入力するような感じのもの。

■なんか
もともとは自作の補完ポップアップ(未公開)と組み合わせるために作ったんだが
xyzzy 標準の補完でも使えなくともないようなので公開することにした。

■手動インストール方法
1. fiofeo.l と fiofeo.lc を ~/site-lisp に移動。
2. ~/.xyzzy か ~/site-lisp/siteinit.l に次の一文を追加。
   (require "fiofeo")
3. xyzzy を再起動。
   ~/site-lisp/siteinit.l に書いたのなら
   Ctrl と Shift を押しながら xyzzy を起動して再ダンプ。

■アンインストール方法
NetInstaller で インストールしたときは、
NetInstaller 内で fiofeo を選択して d を押す。

手動でインストールしたときは、
1. ESC ESC と入力。
2. (fiofeo-uninstall) と入力。
3. .xyzzy か siteinit.l に書いた (require "fiofeo") を削除。
4. ~/site-lisp の fiofeo.l と fiofeo.lc を削除。
5. 必要があればCtrl と Shift を押しながら xyzzy を起動して再ダンプ。

■使い方
M-xかキーバインドで使えるコマンド。
いろいろあるが便利なのは fiofeo-find-file-history だけかも。

□履歴シリーズ

共通設定 -> いろいろ -> 保存するヒストリの個数は低くとも 500 は欲しい。

・fiofeo-find-file-history
  最近使ったファイルを fiofeo で選んで開く。
・fiofeo-session-file-history
  最近使ったセッションを fiofeo で選んで開く。
・fiofeo-shell-execute-history
  *fiofeo-shell-execute-history* を fiofeo で選んで実行。
  詳しくは下記の fiofeo-shell-execute のあたりを参照。

使い方がわからんという人は fiofeo-find-file-history をしたあと
tab を押せばだいたい意味がわかる。

□ディレクトリの中身を fiofeo で選んで○○するシリーズ

*fiofeo-なんとか-test* で non-nil を返したものだけを候補にする。
でも補完機能で正規表現を使えれば全部を候補にしちゃっても
問題にならんね冷静になると。

・fiofeo-find-file
  ディレクトリの中身を fiofeo で選んで開く。
  *fiofeo-find-file-test* で non-nil を返したものだけを候補にする。
  標準では、モードに関連付けられているファイルだけを候補にする。
  表示したい拡張子を増やすなら .xyzzy などで↓のようになさい。
  (pushnew '("\\.xxx" . (lambda ())) *auto-mode-alist* :test #'equalp)
・fiofeo-shell-execute
  ディレクトリの中身を fiofeo で選んで実行。
  *fiofeo-shell-execute-test* で non-nil を返したものだけを候補にする。
  標準では、すべてのものを候補にする。

作ってはみたがいまいちかもしれん。
ダイアログにするのがいいんだろうけどな。
dirbar.l と組み合わせるとまあまあ使える。
なんらかのディレクトリ選択システムと組み合わせよう。

fiofeo-shell-execute-history は
fiofeo-shell-execute でヒストリに追加してから実行する形になる。
ヒストリに追加するには fiofeo-shell-execute1 を使うか、
(add-history "ファイル名" '*fiofeo-shell-execute-history*) でもよし。
素直にランチャ使った方が楽やね。

□そのた
・fiofeo-ra
  各種履歴から存在しないファイルを消す。

□ほか
・インストールすると、find-file したファイルはすべて
  *minibuffer-file-name-history* に入るようにする。
・\n を区切りと判断して複数のファイルとして扱う機能があったりとか。
・補完機能には、次の機能があると便利である気がする。
  a.残り候補のすべてで先頭一致している文字列を入力するコマンド
  b.次の一文字を残り候補の多数決で決めて入力する機能
  c.aをしたあとbをしてaをするコマンド
・ミニバッファに入った瞬間に補完リストを表示すると便利かも。
  さらに *fiofeo-hook* で渡されたリストを使うようにするとよい。
  自分は *enter-minibuffer-hook* と start-timer と
  *fiofeo-hook* を組み合わせた補完機能を使っている。

■todo
□ファイル操作関連のコマンド。リネームとか移動とか。
□ランチャのfenrirの機能をパクりたいが、
  自作の補完だとファイル数が膨大になると遅すぎる。どうしたもんだか。

■更新履歴
2007.10.10 細かいとこ
2007.01.24 *before-find-file-hook* に追加する関数を修正。
2006.10.20 公開。

■ライセンス
Copyright (c) 2006, sazasaza.  All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in
   the documentation and/or other materials provided with the
   distribution.

3. Neither the name of the University nor the names of its
   contributors may be used to endorse or promote products derived
   from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
|#

(in-package "editor")
(provide "fiofeo")

(export '(fiofeo-encode
	  fiofeo-decode
	  fiofeo-encode-list
	  fiofeo-decode-list
	  fiofeo-split
	  fiofeo-read
	  fiofeo
	  fiofeo-directory-1
	  fiofeo-directory
	  fiofeo-define-dc
	  fiofeo-ff
	  fiofeo-mode-alist-regexp
	  fiofeo-find-file-test
	  fiofeo-do-shell-execute
	  fiofeo-shell-execute-test
	  fiofeo-find-file-history
	  fiofeo-session-file-history
	  fiofeo-shell-execute-history
	  fiofeo-ra
	  fiofeo-uninstall
	  *fiofeo-slash*
	  *fiofeo-separator*
	  *fiofeo-directory-count*
	  *fiofeo-auto-ra*
	  *fiofeo-ra-list*
	  *fiofeo-hook*
	  *fiofeo-history*
	  *fiofeo-find-file-test*
	  *fiofeo-shell-execute-test*
	  *fiofeo-shell-execute-history*))

;設定

(defvar *fiofeo-slash* "/"
  "\\ か /")
(defvar *fiofeo-separator* "\n"
  "複数パスの区切り文字。")

(defvar *fiofeo-directory-count* nil
  "directory で表示するファイル数の上限")

(defvar *fiofeo-auto-ra* t
  "fiofeo-rename-file などのとき勝手に fiofeo-ra するか")

(defvar *fiofeo-ra-list* '((*fiofeo-shell-execute-history*
			    *minibuffer-file-name-history*
			    *session-file-history*)
			   (*fiofeo-history*))
  "fiofeo-ra で掃除する履歴のシンボルたち。secondはfiofeo状態になってるもの")

(defvar *fiofeo-hook* nil)

(define-history-variable *fiofeo-history* nil)
(setf (get '*fiofeo-history* 'history-ignore-case) t)
(setf (get :fiofeo 'minibuffer-history-variable) '*fiofeo-history*)

(defvar *fiofeo-find-file-test* 'fiofeo-find-file-test)
(defvar *fiofeo-shell-execute-test* 'fiofeo-shell-execute-test)

;

(defun fiofeo-encode (filename)
  "c:/hoge/readme.txt -> readme.txt/hoge/c:/"
  (apply #'concat
	 (nreverse (cons (if (pathname-device filename)
			     nil
			   *fiofeo-slash*)
			 (mapcar (lambda (x)
				   (concat x *fiofeo-slash*))
				 (split-string (map-backslash-to-slash filename) #\/))))))

(defun fiofeo-decode (fiofeo)
  "readme.txt/hoge/c:/ -> c:/hoge/readme.txt"
  (setq fiofeo (map-backslash-to-slash fiofeo))
  (subseq (apply #'concat
		 (and (char= #\/ (char fiofeo (- (length fiofeo) 2)))
		      (char= #\/ (char fiofeo (- (length fiofeo) 1)))
		      (concat *fiofeo-slash* *fiofeo-slash*))
		 (nreverse (mapcar (lambda (x)
				     (concat *fiofeo-slash* x))
				   (split-string fiofeo #\/))))
	  1))

(defun fiofeo-encode-list (filename-list)
  "(mapcar #'fiofeo-encode filename-list)"
  (mapcar #'fiofeo-encode filename-list))

(defun fiofeo-decode-list (fiofeo-list)
  "(mapcar #'fiofeo-decode fiofeo-list)"
  (mapcar #'fiofeo-decode fiofeo-list))

(defun fiofeo-split (fiofeo)
  (split-string fiofeo *fiofeo-separator*))

(defun fiofeo-read (fiofeo-list &key prompt must-match (history :fiofeo) callback)
  "結果はリストで返す。callback にもリストで渡す。"
  (unless prompt
    (setq prompt "fiofeo: "))
  (run-hook-with-args '*fiofeo-hook*
		      fiofeo-list
		      :prompt prompt
		      :must-match must-match
		      :history history
		      :callback callback)
  (let* ((string (completing-read prompt
				  fiofeo-list
				  :case-fold t
				  :must-match must-match
				  :history history))
	 (list (fiofeo-split string))
	 (result (fiofeo-decode-list list))
	 (history-variable (if history
			       (get history 'minibuffer-history-variable))))
    (when history-variable
      (set history-variable (delete string (symbol-value history-variable) :test #'equalp))
      (mapc #'(lambda (item) (add-history item history-variable))
	    list))
    (if callback
	(funcall callback result)
      result)
    ))

(defun fiofeo (filelist &rest prompt+must-match+history+callback)
  "結果はリストで返す。callback にもリストで渡す。"
  (apply #'fiofeo-read
	 (fiofeo-encode-list filelist)
	 prompt+must-match+history+callback))

;

(defun fiofeo-directory-1 (pathname &rest rest)
  "(directory pathname :absolute t :count *fiofeo-directory-count* ,@rest)"
  (apply #'directory pathname :absolute t :count *fiofeo-directory-count* rest))

(defun fiofeo-directory (&key directory depth test wild sort-predicate sort-key (file-only t))
  "sort 関連は標準の補完では意味が無いかも。test はリストごと渡します。"
  (let ((f (fiofeo-encode-list (funcall (or test
					    #'identity)
					(fiofeo-directory-1 (or directory
								(read-directory-name "directory: "))
							    :recursive t :file-only file-only
							    :depth (or depth
								       (read-integer "深さ: "))
							    :wild wild)))))
    (if sort-predicate
	(sort f sort-predicate :key sort-key)
      f)))

(defmacro fiofeo-define-dc (name &key
				 (doc "")
				 prompt
				 history
				 callback
				 default-directory
				 default-depth
				 default-test
				 default-wild
				 default-sort-predicate
				 default-sort-key
				 (file-only t))
  "sort 関連は標準の補完では意味が無いかも。test はリストごと渡します。"
  `(export (defun ,name (&key (directory ,default-directory)
			      (depth ,default-depth)
			      (test ,default-test)
			      (wild ,default-wild)
			      (sort-predicate ,default-sort-predicate)
			      (sort-key ,default-sort-key))
	     ,doc
	     (interactive)
	     (fiofeo-read (fiofeo-directory :directory directory
					    :depth depth
					    :wild wild
					    :file-only ,file-only
					    :test test
					    :sort-predicate sort-predicate
					    :sort-key sort-key)
			  :prompt ,prompt
			  :history ,history
			  :callback ,callback))))

(defun fiofeo-ff (function)
  "mapcする関数を返す"
  #'(lambda (l) (mapc function l)))

;

(defun fiofeo-mode-alist-regexp (&optional (ama *auto-mode-alist*))
  (if (null ama)
      ""
    (compile-regexp (let ((ama (reverse ama)))
		      (if (cdr ama)
			  (format nil "~{\\(~A\\)\\|~}\\(~A\\) " (mapcar #'car (cdr ama)) (caar ama))
			(if (car ama)
			    (caar ama))))
		    )))

(defun fiofeo-find-file-test (filelist)
  (let ((regexp (fiofeo-mode-alist-regexp)))
    (delete-if-not #'(lambda (filename)
		       (string-matchp regexp filename))
		   filelist)))

(fiofeo-define-dc fiofeo-find-file
		  :doc "ディレクトリの中身を fiofeo で選んで開く"
		  :prompt "Find file: "
		  :callback (fiofeo-ff #'find-file)
		  :default-test *fiofeo-find-file-test*)

(define-history-variable *fiofeo-shell-execute-history* nil
			 "fiofeo で最近実行したファイル")

(defun fiofeo-do-shell-execute (filename)
  "add-history + shell-execute"
  (interactive "fShell execute: ")
  (when (file-exist-p filename)
    (add-history filename '*fiofeo-shell-execute-history*)
    (shell-execute filename)))

(defun fiofeo-shell-execute-test (filelist)
  filelist)

(fiofeo-define-dc fiofeo-shell-execute
		  :doc "ディレクトリの中身を fiofeo で選んで実行"
		  :prompt "Shell execute: "
		  :callback (fiofeo-ff #'fiofeo-do-shell-execute)
		  :default-test *fiofeo-shell-execute-test*)

;

(defun fiofeo-find-file-history ()
  "最近使ったファイルを fiofeo で選んで開く"
  (interactive)
  (fiofeo *minibuffer-file-name-history*
	  :prompt "Find file history: "
	  :callback (fiofeo-ff #'find-file)))

(defun fiofeo-session-file-history ()
  "最近使ったセッションを fiofeo で選んで開く"
  (interactive)
  (fiofeo *session-file-history*
	  :prompt "Session file history: "
	  :callback #'(lambda (l) (load-session (car l)))))

(defun fiofeo-shell-execute-history ()
  "*fiofeo-shell-execute-history* を fiofeo で選んで実行"
  (interactive)
  (fiofeo *fiofeo-shell-execute-history*
	  :prompt "Shell execute history: "
	  :callback (fiofeo-ff #'fiofeo-do-shell-execute)))

;

(defun fiofeo-ra (&optional h)
  "履歴から存在しないファイルを消す"
  (interactive)
  (let ((test (if h
		  #'(lambda (file)
		      (if file
			  (file-exist-p file)))
		#'(lambda (file)
		    (if file
			(or (pathname-host file)
			    (file-exist-p file)))))))
    (labels ((del (symbol &key (key #'identity))
	       (set symbol (remove-if-not test
					  (symbol-value symbol)
					  :key key))
	       ))
      (mapc #'del
	    (car *fiofeo-ra-list*))
      (mapc #'(lambda (list)
		(del list
		     :key #'(lambda (file)
			      (ignore-errors (fiofeo-decode file)))))
	    (second *fiofeo-ra-list*))
      t
      )))

;find-file したのはすべて履歴に入れる。ただし、前回の起動時から開いてたのは入れない。
(add-hook '*post-startup-hook*
	  #'(lambda ()
	      (add-hook '*before-find-file-hook*
			#'(lambda (x)
			    (if (file-exist-p x)
				(if (not (file-directory-p x))
				    (add-history (map-backslash-to-slash (truename x))
						 '*minibuffer-file-name-history*)))
			    nil))))

(defun fiofeo-uninstall ()
  (mapc #'unregister-history-variable
	'(*fiofeo-history*
	  *fiofeo-shell-execute-history*)))
