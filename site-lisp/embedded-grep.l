;;; -*- Mode: Lisp; Package: EDITOR -*-
#| embedded grep for xyzzy-0.2.2.235

Copyright (c) 2008-2009 knenet <kneneglect_std(^o^)yahoo.co.jp>

■概要
テキストに埋め込んだ正規検索表現を実行します。
検索範囲の指定ができ、結果が単一であれば自動で飛びます。

■導入
(require "embedded-grep")

を.xyzzyに書くなどして読み込みます。
netinstallerを用いてインストールした場合は不要です。

(define-key esc-map #\C-l 'eg-run)
(global-set-key '(#\C-c #\C-l) 'eg-goto-run-exp)
(global-set-key '(#\C-c #\l) 'eg-release-run-exp)

などと好みに応じてキーバインドします。

アンインストールはこのファイルとembededd-grep.lcを削除して
上記設定等を消せばいいです。

■使用法
○基本
任意のテキストに
:|検索語句|:
のように記述し、キャレットを合わせてeg-runを実行します。
検索語句 の部分は正規表現になります。

|>>検索語句
とすると、検索語句に等しい行を検索します(^検索語句[ \t].*$ 相当)。

検索結果が1つであれば、該当部分にカーソルが移動します。
   〃   が複数あれば、該当付近を列挙するバッファを開きます。
   〃   がなければ、ファイルの末尾に移動し、テンプレートを挿入します。

文章中に書く場合は :|検索語句|: と手前に半角スペースをおいて下さい。

eg-goto-run-expを実行すると、前回実行した場所へ戻ります。
*eg-marker-ring*に全部記録しているので何回でも戻れます。

一つずつ戻るのがたるい場合はeg-release-run-expを実行すると全て表示されます。
*eg-marker-ring*は消去されます。universal-argumentがある場合は消去しません。

○詳細
:||: |>>
どちらでも、手前にスペースを挟まずに、下記の書式に沿って記述すると
動作の設定が行えます。

path|>>word
pathのファイル、もしくはディレクトリから検索します。
ワイルドカードが利用できます。
pathに半角スペースが含まれる場合は""で括ってください。
pathがないなら、pathを作ってテンプレートを挿入します。
ワイルドカードを使っている場合、適当にファイルを作ります。

path|>>
pathを開きます。ディレクトリであればファイルを列挙します。

<buffer>|>>
バッファに移動します。バッファがない場合は何もしません。

|integer|>>word
wordを検索し、integer番目の結果を表示します。
pathがない場合も左端の|が必要です。
|の右側に書くものを特性子と呼びます。

|integer|>>
integer行目にカーソルを移動します。

path|integer|>>
pathのinteger行目にカーソルを移動します。
pathに複数のファイルが含まれる場合、integer番目のファイルを開きます。

|>|>>word
検索結果をソートして表示します。降順(<)と昇順(>)が指定できます。
ファイルを列挙する場合 path|>|:||:

path|r|>>
pathのサブディレクトリも検索します。

path1|path2||>>
pathを複数指定できます。特性子がない場合も右端の|を書く必要があります。

|>:integer|>>word
特性子を列挙する場合は:で区切ります。
この場合は、wordで検索した結果を昇順でソートし、integer番目を表示します。

path1|...|pathN|r:<:num1:num2|>>
特性子は4つが最高(多分)です。
path1～pathNまでを再帰的に展開し(重複は気にしない)、ソートした後、
num1番目のファイルを開き、num2行目に移動します。

■設定
コードの始めの方にあるdefvarされた変数の値をsetqして変更できます。
例えば、eg-runをC-lではなく、F12などに設定し、検索表記がないところで
recenterする必要がない場合は、
(setq *eg-capture-command* nil)
と.xyzzyなどに書きます。
それぞれの変数の意味は宣言部を参照してください。


■既知の問題
元からあるバッファ(*scratch*など)に色づけが反映されません。

十分にテストしていないのでバグが多くある可能性があります。
検索を実行するときはファイルを保存してからの方がいいでしょう。

■Ｑ & Ａ
Ｑ．書式が変すぎじゃないですか？
Ａ．上手い方法考えてください。

Ｑ．同じ行に複数 path:|word|:を書いて検索しようとすると、
　　なぜか意図と違うものを検索してしまう
Ａ．pathの上で実行すると、手前の:|word|:が優先されます。仕様です。

Ｑ．eg-goto-run-expが仕事をしません。
Ａ．eg-runと異なり、閉じたファイルは開き直しません。
　　見返すつもりがあるなら、バッファを閉じないようにしましょう。

■ライセンス
MITライセンスに準拠します。著作者を明らかにすれば適当に使って良いです。
このソフトの使用によって生じた損益について、著作者は一切責任を持ちません。

Copyright (c) 2008-2009 knenet \kneneglect_std(^o^)yahoo.co.jp/

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


■履歴
001 2009-07-01 23:17 できた。
002 2009-07-02 08:59 綴りミスの修正。
003 2009-07-02 13:20 実行したポイントへ戻れるようにした。うるさくした。
004 2009-07-03 19:19 ファイルを作るときwordがなければテンプレートを挿入しないように。
005 2009-07-06 12:15 |>> と :||: の役割入れ替え
006 2009-07-20 11:20 バッファ名指定で検索した後、該当行に飛べないバグを修正。

|#

(provide "embedded-grep")
(in-package "editor")

(defvar *eg-keyword-color* '(:color 10 0 :bold)
  "検索表現の色")
(defvar *eg-keyword-highlight* '(:color 1 3)
  "検索結果表示でのマッチ語句の色")
(defvar *eg-capture-command* 'recenter
  "検索表現が見つからなかった場合の動作")
(defvar *eg-buffer* "*egrep*"
  "embedded-grepが用いるバッファの名前")
(defvar *eg-show-line-number* 2
  "検索結果表示で後方へ何行表示するか")
(defvar *eg-denominate-new-file* (lambda (num) (format nil "~D.txt" num))
  "新規ファイルの命名規則")
(defvar *eg-template*
  (lambda (word) (insert (format nil "~%●~A~%" (string-trim "^$[] \t.*" word))))
  "挿入テンプレート")
(defvar *eg-verbose* t
  "embedded-grepのステータスバーへの表示を切り替える。nil 0 1 2 3 t で tが一番うるさい。")

(export '(*eg-keyword-color* *eg-keyword-highlight* *eg-capture-command*
		  *eg-buffer* *eg-show-line-number* *eg-denominate-new-file* *eg-template*
		  *eg-verbose*
		  eg-run eg-goto-run-exp eg-release-run-exp))

(defvar *eg-marker-ring* nil)

(defvar eg-heading (compile-regexp "|>> *\\(.*\\)" t))
(defvar eg-inside (compile-regexp ":|\\(.*?\\)|:" t))


(setq eg-regexp-keyword-list
	  (compile-regexp-keyword-list
	   `((,eg-heading t ,*eg-keyword-color* t)
		 (,eg-inside t ,*eg-keyword-color* t))))

(make-local-variable 'regexp-keyword-list)
(setq-default regexp-keyword-list
			  (if (boundp 'regexp-keyword-list)
				  (append regexp-keyword-list eg-regexp-keyword-list)
				eg-regexp-keyword-list))
(global-set-key #\C-l 'eg-run)

(defun eg-run ()
  "embedded-grepを実行する。"
  (interactive)
  (macrolet ((scan (&rest args)
					`(save-excursion (scan-buffer ,@args)))
			 (app (&rest args)
				   `(multiple-value-call 'eg-grep (eg-get-attr ,@args))))
	(cond ((or
			(scan eg-heading :reverse t :limit #1=(save-excursion (goto-bol) (point)))
			(scan eg-heading :limit #2=(save-excursion (goto-eol) (point))))
		   (app (match-beginning 0)
				(if (zerop (- (match-end 1) (match-beginning 1)))
					"" (concat "^" (match-string 1) "[ \t]*$"))))
		  ((or
			(scan eg-inside :reverse t :limit #1#)
			(scan eg-inside :limit #2#))
		   (app (match-beginning 0) (match-string 1)))
		  (t (if *eg-capture-command* (call-interactively *eg-capture-command*))))))


(defun eg-get-attr (limit word)
  "表現の手前のpathとかattrを取得して返す"
  (save-excursion
	(goto-char limit)
	(macrolet ((scan ()
				 `(let (inside)
					(loop
					  (if (scan-buffer "\\([ \t\"]\\|$\\)" :regexp t :reverse t :no-dup t)
						  (if (equal (char-after (point)) #\")
							  (setq inside (not inside))
							(if (not inside) (return (1+ (point)))))
						(return 0))))))
	  (let ((attr (split-string (concat (buffer-substring (scan) limit) "|") #\| t)))
		(values
		 (if (zerop (length word)) nil word)
		 (remove "" (if (cdr attr) (butlast attr) attr) :test 'string=)
		 (if (cdr attr) (split-string (car (last attr)) #\:)))))))

(defun eg-sort-predicate (attr)
  (cond ((string= attr ">") 'string>)
		((string= attr "<") 'string<)
		(t nil)))

(defun eg-grep (word path attr)
  "eg-runの動作部分"
  (let ((arg (and (car attr) (string= "%" (car attr)))))
	(if arg (setq attr (cdr attr))
	  (push (cons (eg-get-buffer-name) (current-line-number)) *eg-marker-ring*)))
  (if path
	  (let ((r (and (car attr) (string= (car attr) "r"))))
		(eg-grep-path-exist path word (if r (cdr attr) attr) r))
	(eg-grep-here word attr)))

#|
(defun eg-grep (word path attr)
  (msgbox "word:~S~%path:~S~%attr:~S" word path attr))
|#

(defun eg-bufferp (name)
  (equal #\< (char name 0)))

(defun eg-grep-path-exist (path word attr recursive)
  "有効なpathが指定されている場合"
  (let ((files
		 (mapcan (lambda (x)
				   (let ((name (string-trim "\"" x)))
					 (cond ((eg-bufferp name) (list name))
						   (t (let ((d (directory-namestring name))
									(f (file-namestring name)))
								(directory d :wild f
										   :file-only t :absolute t :recursive recursive))))))
				 path)))
	(if files
		(if (cdr files)
			(eg-grep-files-exist path word attr files)
		  (if (eg-set-buffer (car files))
			  (eg-grep-here word attr)))
	  (eg-new-file (car path) word))))

(defun eg-grep-files-exist (path word attr files)
  "有効なfileかbufferが指定されている場合"
  (let ((p (eg-sort-predicate (car attr))))
	(if word
		(eg-scan-files word p (if p (cdr attr) attr) path files)
	  (eg-files-exist-no-word
	   (if p (cdr attr) attr)
	   (if p (stable-sort files p) files)))))

(defun eg-scan-files (word predicate attr path files)
  "複数ファイルをスキャン"
  (let* ((regexp (compile-regexp word t))
		 (res (long-operation
			   (let (l)
				 (handler-case
				  (dolist (a files (apply 'append l))
					(if (eg-read-file a) (push (eg-scan-1 regexp a) l))
					(do-events))
				  (quit (c) (apply 'append l)))))))
	(if res
		(if (cdr res)
			(eg-show-result
			 word
			 (if predicate (stable-sort res predicate :key 'car)
			   (reverse res))
			 attr)
		  (progn (eg-set-buffer (cadar res))
			(goto-line (caddar res))
			(eg-message 3 "特定した。")))
	  (eg-new-file (car path) word))))

(defun eg-scan-1 (regexp name &aux l)
  "検索の本体"
  (save-excursion
	(goto-char (point-min))
	(while (scan-buffer regexp :tail t)
	  (push (list (match-string 0) name (current-line-number) (eg-skim-lines))
			l)))
  l)

(defun eg-skim-lines ()
  (buffer-substring (save-excursion (goto-bol) (point))
					(save-excursion
					  (next-line *eg-show-line-number*) (goto-eol) (point))))

(defun eg-get-buffer-name ()
  "バッファのファイル名か名前を取得"
  (or (get-buffer-file-name)
	  (concat "<" (buffer-name (selected-buffer)) ">")))

(defun eg-scan-here (word predicate attr)
  "現在のバッファのみをスキャン"
  (let ((res (eg-scan-1 (compile-regexp word t)
						(eg-get-buffer-name))))
	(if res
		(if (cdr res)
			(eg-show-result
			 word
			 (if predicate (stable-sort res predicate :key 'car)
			   (reverse res))
			 attr
			 (syntax-table)
			 (if (boundp 'keyword-hash-table)
				 keyword-hash-table))
		  (progn (goto-line (caddar res)) (eg-message 3 "特定した。")))
	  (eg-insert-template word))))

(defun eg-set-buffer (name)
  "バッファに移動"
  (let ((buff (if (eg-bufferp name)
				  (find-buffer (string-trim "<>" name))
				(or (get-file-buffer name)
					(ed::find-file-internal name)))))
	(if buff (set-buffer buff)
	  (eg-message 2 "なかったよ→ ~A" name))))

(defun eg-read-file (name &aux (r t))
  "検索ファイルを読み込む。バッファがあれば移動する。"
  (let ((buff (if (eg-bufferp name)
				  (find-buffer (string-trim "<>" name))
				(or (get-file-buffer name)
					(setq r nil)
					(get-buffer-create (concat " " *eg-buffer*))))))
	(when buff
	  (set-buffer buff)
	  (unless r
		(erase-buffer (selected-buffer))
		(insert-file-contents name))
	  (eg-message 1 "見てる ~A" name))
	buff))

(defun eg-files-exist-no-word (attr files)
  "fileが存在し、wordが指定されていない場合"
  (let ((arg (if (car attr) (parse-integer (car attr) :junk-allowed t))))
	(if (and arg (elt files arg))
		(if (eg-set-buffer (elt files arg))
			(eg-no-word (cdr attr)))
	  (eg-show-files files))))

(defun eg-new-file (path word)
  "ファイルを作る"
  (set-buffer
   (ed::find-file-internal
	(if (string-match "[\\*\\?<>|:\"]" (file-namestring path))
		(let ((num 0))
		  (loop
			(let ((file (merge-pathnames
						 (funcall *eg-denominate-new-file* num)
						 (directory-namestring path))))
			  (if (file-exist-p file) (incf num) (return file)))))
	  path)))
  (when word (eg-insert-template word))
  (set-buffer-modified-p nil))

(defun eg-grep-here (word attr)
  "現在のバッファを対象に検索"
  (if word
	  (let ((p (eg-sort-predicate (car attr))))
		(eg-scan-here word p (if p (cdr attr) attr)))
	(eg-no-word attr)))

(defun eg-no-word (attr)
  "wordがない場合。番号特性があれば行移動する"
  (let ((arg (if (car attr) (parse-integer (car attr) :junk-allowed t))))
	(and arg (progn (goto-line arg) (recenter))))
  (eg-message t "移動してみた。"))

(defun eg-show-result (word res attr &optional syntax keyword)
  "複数結果があった場合"
  (let ((arg (if (car attr) (parse-integer (car attr) :junk-allowed t))))
	(if (and arg (elt res arg))
		(if (eg-set-buffer (cadr (elt res arg)))
			(goto-line (caddr (elt res arg))))
	  (let ((buff (get-buffer-create *eg-buffer*)))
		(set-buffer buff)
		(erase-buffer buff)
		(setup-temp-buffer buff)
		(kill-all-local-variables)
		(when syntax (use-syntax-table syntax))
		(when keyword
		  (make-local-variable 'keyword-hash-table)
		  (setf keyword-hash-table keyword))
		(make-local-variable 'regexp-keyword-list)
		(let ((key (compile-regexp-keyword-list
					`((,(compile-regexp word) t ,*eg-keyword-highlight* t)))))
		  (setq regexp-keyword-list
				(if (boundp 'regexp-keyword-list)
					(append regexp-keyword-list key)
				  key)))
		(format (make-buffer-stream buff) "~{~{~*\"~A\"|~A|>>~%~A~%~%~}~}~%~A件みつけた。"
				res (length res)))))
  (eg-message 3 "いろいろあった。"))

(defun eg-show-files (files)
  "ファイルの内容を示す"
  (let ((buff (get-buffer-create *eg-buffer*)))
	(set-buffer buff)
	(erase-buffer buff)
	(setup-temp-buffer buff)
	(fundamental-mode)
	(kill-all-local-variables)
	(with-output-to-buffer (buff)
	  (dolist (a files)
		(format t "~A|>>~%" a)
		(if (eg-bufferp a)
			(let ((s (make-buffer-stream ((find-buffer a) (point-min)))))
			  (eg-show-content s))
		  (with-open-file (s a)
			(eg-show-content s)))
		(format t "~%"))))
  (eg-message 3 "並べてみた。"))

(defun eg-show-content (input-stream &aux l)
  (dotimes (N/A *eg-show-line-number*)
	(setq l (read-line input-stream nil nil))
	(if l (format t "~A~%" l) (return))))

(defun eg-insert-template (word)
  (interactive "s項目名: ")
  (goto-char (point-max))
  (funcall *eg-template* word)
  (eg-message t "何か書いて。" ))

(defun eg-message (threshold &rest args)
  (if (or
	   (null threshold)
	   (and (numberp threshold)
			(numberp *eg-verbose*)
			(>= *eg-verbose* threshold))
	   (eq t *eg-verbose*))
	  (apply 'message args))
  nil)

(defun eg-goto-run-exp (&optional (pop t))
  "embedded-grepの検索した位置に戻る。"
  (interactive)
  (let ((marker (if pop (pop *eg-marker-ring*) (car *eg-marker-ring*))))
	(and (if marker t
		   (eg-message 2 "もうないよ"))
		 (eg-set-buffer (car marker))
		 (goto-line (cdr marker))
		 (eg-message t "戻った。 (残り~A)" (length *eg-marker-ring*)))))

(defun eg-release-run-exp ()
  (interactive)
  (let ((buff (get-buffer-create *eg-buffer*)))
	(set-buffer buff)
	(erase-buffer buff)
	(setup-temp-buffer buff)
	(fundamental-mode)
	(kill-all-local-variables)
	(with-output-to-buffer (buff)
	  (dolist (a *eg-marker-ring*)
		(if (string/= (car a) (concat "<" *eg-buffer* ">"))
			(format t "~A|%:~A|>>~%~A~%~%"
					(car a) (cdr a) (save-excursion (eg-goto-run-exp nil) (eg-skim-lines))))))
	(let ((buff (find-buffer (concat " " *eg-buffer*))))
	  (if buff (delete-buffer buff)))
	(if *prefix-args*
		(eg-message 2 "表示してみた。")
		(progn (setq *eg-marker-ring* nil)
		  (eg-message t "リセットした。")))))

;;; end of embedded-grep.l