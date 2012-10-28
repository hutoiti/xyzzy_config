;;; -*- mode: lisp -*-
;;; name:     snippet
;;; version:  2007.07.15
;;; author:   shiro
;;; category: Editing
;;; src:      http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fsnippet&openfile=
;;; changes:  10個以上の展開ができなかったのを修正
;;; files:    site-lisp/snippet.l
;;;           site-lisp/snippet.lc
;;;           site-lisp/ni-autoload/silog/snippet.l

;; Copyright (C) 2007 shiro
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
;; Abbrevで展開した後に、
;;   * 指定した位置にジャンプ
;;   * 編集した部分を他の場所に反映
;; します。
;; プログラムやHTMLなどの定型的な文を良く入力する人以外はあまり美味しくないかもしれません。
;; 
;; TextMateで話題になっていたので勢いで実装しました。
;; 詳細が良く分からないところや、しっかり考えてないところがあるので、
;; いろいろと問題があるかもしれません。
;; 
;; ac-modeと一緒に使うことを推奨。
;; 

;; 使用方法:
;; 
;; abbrevで使用する設定をそのまま使っています。(デフォルトでは~/.abbrev_defs)
;; ac-modeを導入している方はabbrevの展開前の文字列の直後でTABを押してください。
;; ac-modeを導入していない方は.xyzzyに
;;  (define-key ctl-x-map #\' 'snippet-expand)
;; 等とキーバインドを定義し、abbrevの展開前の文字列の直後で C-x ' を押してください。
;; 
;; TAB/C-x 'で展開すると、snippet-modeに入ります。
;; snippet-modeではC-n/C-pでジャンプできます。
;; C-n/C-pで移動する先がない場合や、C-gを押すとsnippet-modeを抜け、
;; 元の状態に戻ります。
;; TextMateではTABでジャンプするようですが、
;; ジャンプして編集してる時にac-modeで補完したいので、
;; ジャンプはC-n/C-pで行うようにしています。
;; (なので戻ることも出来ます。)


;; 使用方法2:
;; 
;; abbrev/snippetがよく分からんという人や、とりあえず試してみたい人用。
;; 
;; 1. snippet.lをsite-lispにコピー
;; 
;; 2. ~/.abbrev_defsに以下を書いて保存
;; 
;; (in-package "editor")
;; (define-abbrev-table '*global-abbrev-table* '(
;; ("class" "class ${1:ClassName} (${2:object}):
;;     def __init__(self${3:, arg}):
;;         \"\"\"${4:documentation}\"\"\"
;; ${3/, *\\([a-zA-Z][0-9a-zA-Z_]*\\)/        self.\\1 = \\1\n/g}
;;     $0")))
;; 
;; 3. .xyzzyに以下を追加して保存後、xyzzyを再起動
;; 
;; (quietly-read-abbrev-file)
;; (require "snippet")
;; (define-key ctl-x-map #\' 'snippet-expand)
;; 
;; 4. *scratch* バッファなどで class と入力し、
;;    キャレットを動かさずに C-x ' を押してください。
;;    以下のように展開され、ClassNameを選択している状態だと思います。
;; 
;; class ClassName (object):
;;     def __init__(self, arg):
;;         """documentation"""
;;         self.arg = arg
;; 
;; 5. 適当にクラス名を入力して C-n を押してください。
;;    objectの部分にキャレットがジャンプしたと思います。
;;    もう一度 C-n を押し、
;;    , arg
;;    を
;;    , arg1, arg2, arg3
;;    などに編集してみてください。
;;    以下のようになると思います。
;; 
;; class ClassName (object):
;;     def __init__(self, arg1, arg2, arg3):
;;         """documentation"""
;;         self.arg1 = arg1
;;         self.arg2 = arg2
;;         self.arg3 = arg3
;; 
;; 6. 最後まで C-n でジャンプするか、途中で C-g を押すとsnippet-modeを抜けます。
;;    ちなみに、snippet-modeの状態なら間違えても C-p で戻れます。

;; 使用方法3:
;; 
;; M-x snippet-select-and-expand
;; 
;; または
;; 
;; (snippet-select-and-expand "defun")
;; 与える文字列はsnippetとして登録したもの

;; 書式:
;; 
;; 1. ${[0-9]:default}
;;      キャレットが移動する位置。
;;      デフォルト値を指定すると、ジャンプした時に選択状態になる。
;; 2. ${[0-9]/pattern/format/option}
;;      1で指定されたものと同じ数字を指定することで連動して変化する文字列。
;;      patternに正規表現を指定し、formatに挿入する文字列を指定します。
;;      formatには\\1-\\9が指定可能です。
;;      optionには今のところgのみ指定可能です。(何度もマッチさせます。)
;;      /を文字として指定したいときは\\/とエスケープしてください。
;; 3. $[0-9]
;;      1番目の書式のデフォルト値を指定しない時の省略形。
;;      ただし、$0を最後に書くとsnippet-modeを抜ける(ジャンプできなくなる)ので注意してください。
;; 4. ${file:path}
;;      pathにあるファイルの中身を挿入します。
;;      (${file:~/.license}や${file:C:/doc/hoge.txt}のように使います)
;;      1,2,3の書式を展開する前に挿入するので、ファイル内に1,2,3の書式を使うことができます。
;;      ${file:path}周辺の数字とファイル内の書式の数字が重複しないようにしてください。
;; 
;; 具体的な例は使用方法2の1を見てください。
;; 1-9までを指定した場合は色も付きます。

;; 書式1に使用できる置換マクロ:
;; 
;;    XYZZY-SELECTION  セレクション
;; 
;; 書式1及び2のformat部に使用できる置換マクロ:
;; 
;;    XYZZY-FILE-NAME                 フルパス
;;    XYZZY-FILE-DIRECTORY-NAMESTRING ディレクトリ名
;;    XYZZY-FILE-NAMESTRING           ファイル名
;;    XYZZY-FILE-PATHNAME-NAME        ファイル名（拡張子無し）
;;    XYZZY-FILE-PATHNAME-TYPE        拡張子
;;    XYZZY-FILE-PATHNAME-DEVICE      ドライブ名
;; 
;; 行頭に使用できる置換マクロ:
;; 
;;    $INDENT          mode-specific-indent-commandで指定されたインデントコマンドでインデント

;; TODO:
;; 
;; - インデント関連をまともに
;; - 2番目の書式の拡張形として、正規表現ではなくlispで変更できるように
;; - 書式の入れ子を解釈

;; 履歴:
;; 
;; 2007.07.15
;; - 10個以上の展開ができなかったのを修正
;; 
;; 2007.04.14
;; - 選択直後のバッファ修正の挙動を修正
;; 
;; 2007.04.12
;; - 番号と属性の対応を決める変数 *snippet-attribute-dict* を追加
;; - ファイルを指定して挿入する書式を追加
;; 
;; 2007.03.22
;; - バッファ変更コマンドかどうかのフラグを元に戻すタイミングを修正
;; 
;; 2007.03.16
;; - 正規表現を微妙に変更
;; 
;; 2007.03.13
;; - インデント分の空白がセレクションに含まれていたのを修正
;; 
;; 2007.03.12
;; - バッファを修正するコマンドを自動で判定するようにした
;; - それに伴ってsnippet-modify-commandを廃止
;; 
;; 2007.03.07
;; - 特定のparen.lへの依存をなくしたつもり
;; - ${1:/.*/\\0}を${1}と省略できるようにした
;; 
;; 2007.03.02
;; - マーカー($0などで使用)の位置に文字を挿入した時、同時にマーカーも動くようにあちこち修正
;; - シンボルの開始位置を見るようにした(1文字のみの定義があっても誤爆しないように)
;; 
;; 2007.02.22
;; - $0が他の${1:hoge}などにくっついてるとうまくジャンプできなかったのを修正
;; 
;; 2007.02.19
;; - C-nでジャンプした後にac-mode-complete-or-indent(TAB)
;;   が実行されたら選択中の文字列を削除するようにした
;; - indent-regionを使わずに一行ずつインデントするようにした(末尾の空白が消されるため)
;; 
;; 2007.02.15
;; - キーボードマクロで使えるようにした
;; 
;; 2007.02.09
;; - セレクション関係のバグ修正
;; 
;; 2007.02.08
;; - ミニバッファから選択してsnippetを挿入する機能を追加
;; - XYZZY-SELECTIONを追加
;; - 書式2にスラッシュを指定できるようにした(エスケープする必要有り) 
;; 
;; 2007.01.20
;; - あちこち修正。
;; - 本来abbrevで展開できない文字(記号が含まれていたり)でも展開。
;; - インデントする展開マクロ$INDENT(仮)を追加。
;; 
;; 2007.01.12
;; - ものすごく修正
;; 
;; 2007.01.10
;; - 初版

(provide "snippet")

(in-package "editor")

(export '(snippet-expand
		  snippet-select-and-expand
		  *snippet-attribute-dict*))

;;; variable
(defvar-local snippet-mode-on nil)
(pushnew '(snippet-mode-on . "Snippet") *minor-mode-alist* :key #'car)

(defvar-local *snippet-current-tag* nil)
(defvar-local *snippet-begin* nil)
(defvar-local *snippet-end* nil)
(defvar-local *snippet-list* nil)
(defvar *snippet-select* nil)

(defvar-local *snippet-table* nil)

(defvar-local *snippet-last-paren-state* nil)

(defvar *snippet-before-alist* nil)
(defvar *snippet-after-alist* nil)

; ${1:foo}の文字色を2に背景色を3に,
; ${2:bar}の文字色を10に背景色を12にしたい場合は以下のように。
; '((1 (:foreground 2 :background 3))
;   (2 (:foreground 10 :background 12)))
(defvar *snippet-attribute-dict*
  '((1 :foreground 1)
	(2 :foreground 2)
	(3 :foreground 3)
	(4 :foreground 4)
	(5 :foreground 5)
	(6 :foreground 6)
	(7 :foreground 7)
	(8 :foreground 8)
	(9 :foreground 9)
	(10 :foreground 10)
	(11 :foreground 11)
	(12 :foreground 12)
	(13 :foreground 13)
	(14 :foreground 14)
	(15 :foreground 15)))

;;; structure
(defstruct snippet
  number default regexp format option from to)

;;; keymap
(defvar *snippet-mode-map* nil)
(unless *snippet-mode-map*
  (setf *snippet-mode-map* (make-sparse-keymap))
  (define-key *snippet-mode-map* #\Down 'snippet-next)
  (define-key *snippet-mode-map* #\Up 'snippet-prev)
  (define-key *snippet-mode-map* #\C-n 'snippet-next)
  (define-key *snippet-mode-map* #\C-p 'snippet-prev))

;;; function
(defun snippet-clear-variable ()
  (setf *snippet-current-tag* nil
		*snippet-begin* nil
		*snippet-end* nil
		*snippet-begin-number* nil
		*snippet-end-number* nil
		*snippet-before-alist* nil
		*snippet-after-alist* nil)
  (delete-text-attributes 'snippet-end))

;;; 長さ0の属性が同じ場所に複数あるときに文字を入力/属性を設定すると2つ目以降が消える対策
(defun snippet-hiddens-enqueue (item parent &key before after)
  (let (symbol alist before-children after-children)
	(cond (before
		   (setf symbol '*snippet-before-alist*
				 alist *snippet-before-alist*))
		  (after
		   (setf symbol '*snippet-after-alist*
				 alist *snippet-after-alist*)))
	(when symbol
	  (when alist; itemに子があればparentの子にしとく
		(setf before-children (snippet-hiddens-get item :before t)
			  after-children (snippet-hiddens-get item :after t))
		(snippet-hiddens-delete-parent item :before t)
		
		#+:snippet
		(msgbox "item: ~S~%b-children : ~S~%achildren : ~S~%before:: ~S~%after:: ~S~%" item before-children after-children *snippet-before-alist* *snippet-after-alist*)
		
		(dolist (child before-children)
		  (snippet-hiddens-enqueue child parent :before before :after after))
		)
	  (cond ((first (last (assoc parent alist :test 'equal)))
			 (unless (find item (first (last (assoc parent alist :test 'equal))))
			   (push item (cdr (last (second (assoc parent alist :test 'equal))))))
			 
			 (car (last (assoc parent alist :test 'equal))))
			((null alist)
			 (let ((res (list item)))
			   (set symbol (list (list parent res)))
			   res))
			(t
			 (let ((res (list item)))
			   (set symbol (append (list (list parent res)) alist))
			   res)))
	  (when after-children; itemに子があればparentの子にしとく
		(dolist (child after-children)
		  (snippet-hiddens-enqueue child parent :before before :after after))
		(snippet-hiddens-delete-parent item :after t)))))

(defun snippet-hiddens-delete-child (child &key before after)
  (let (symbol alist res)
	(cond (before
		   (setf symbol '*snippet-before-alist*
				 alist *snippet-before-alist*))
		  (after
		   (setf symbol '*snippet-after-alist*
				 alist *snippet-after-alist*)))
	(when alist
	  (dolist (lst alist)
		(let ((new (remove child (second lst) :test 'equal)))
		  (when new
			  (setf res (append res (list (append
										   (list (car lst))
										   (list new))))))))
	  (set symbol res))))

(defun snippet-hiddens-delete-parent (parent &key before after)
  (let (symbol alist)
	(cond (before
		   (setf symbol '*snippet-before-alist*
				 alist *snippet-before-alist*))
		  (after
		   (setf symbol '*snippet-after-alist*
				 alist *snippet-after-alist*)))
	(when alist
	  (set symbol (remove parent alist :key 'first :test 'equal)))))

(defun snippet-hiddens-get (parent &key before after)
  (cond (before
		 (second (assoc parent *snippet-before-alist* :test 'equal)))
		(after
		 (second (assoc parent *snippet-after-alist* :test 'equal)))))

(defun snippet-hiddens-get-from-number (number &key before after)
  (let (res)
	(dolist (elements (cond (before *snippet-before-alist*)
							(after *snippet-after-alist*))
					  res)
	  (let (tmp-children)
		(setf tmp-children (remove-if-not #'(lambda (x)
											  (= (ed::snippet-number x) number))
										  (second elements)))
		(when tmp-children
		  (setf tmp-children (list tmp-children))
		  (push (first elements) tmp-children)
		  (setf res (append res (list tmp-children))))))))

(defun snippet-get-snippet-attributes (&key parent child marker)
  (remove-if-not #'(lambda (x)
					 (when (snippet-p (third x))
					   (cond (parent
							  (snippet-default (third x)))
							 (child
							  (snippet-regexp (third x)))
							 (t t))))
				 (append (list-text-attributes)
						 (when marker
						   (mapcar #'(lambda (x)
									   (list (marker-point (first x))
											 (marker-point (first x))
											 (second x)))
								   snippet-markers)))))

(defun snippet-get-snippet-attribute-point (&key parent child point)
  (save-excursion
	(when point
	  (goto-char point))
	(remove-if-not #'(lambda (y)
					   (<= (first y) (point) (second y)))
				   (snippet-get-snippet-attributes :parent parent :child child))))

(defun snippet-get-w_ ()
  (let ((pt (point)) start end string)
	(save-excursion
	  (and (skip-syntax-spec-backward "w_")
		   (/= (point) pt)
		   (setf start (point)
				 string (buffer-substring start pt))
		   (skip-syntax-spec-forward "w_")
		   (setf end (point))))
	(values start end string)))

(defun snippet-get-abbrev ()
  (multiple-value-bind (start end string)
	  (snippet-get-w_)
	(or (and (integerp start)
			 (integerp end)
			 (setf *snippet-begin* start)
			 (or (and *local-abbrev-table*
					  (gethash-region start end *local-abbrev-table*))
				 (gethash-region start end *global-abbrev-table*)))
		(snippet-get-abbrev-include-non-symbol))))

(defun snippet-get-abbrev-include-non-symbol ()
  (let ((str (buffer-substring (save-excursion (goto-bol) (point))
							   (point)))
		(lst (append (make-list-from-keyword-table *local-abbrev-table*)
					 (make-list-from-keyword-table *global-abbrev-table*)))
		res)
	(some #'(lambda (key)
			  (when (string-match (format nil "\\_<~A$" (regexp-quote key)) str)
				key))
		  lst)))

(defun snippet-expand-abbrev ()
  (interactive "*")
  (let (abbrev start end)
	(run-hooks '*pre-abbrev-expand-hook*)
	(save-excursion
	  (let ((opoint (point)))
		(setq start (cond (*abbrev-prefix-location*
						   (goto-char *abbrev-prefix-location*)
						   (when (eql (following-char) #\-)
							 (delete-region (point) (+ (point) 1)))
						   (setq *abbrev-prefix-location* nil)
						   (point))
						  (t
						   (skip-syntax-spec-backward "w_")
						   (point))))
		(setq end (min opoint
					   (progn
						 (skip-syntax-spec-forward "w_")
						 (point))))
		(unless (>= start end)
		  (setq abbrev (or (and *local-abbrev-table*
								(gethash-region start end *local-abbrev-table*))
						   (gethash-region start end *global-abbrev-table*))))
		(unless abbrev
		  (let* ((str (snippet-get-abbrev-include-non-symbol)))
			(when str
			  (setq abbrev (or (and *local-abbrev-table*
									(gethash str *local-abbrev-table*))
							   (gethash str *global-abbrev-table*)))
			  (scan-buffer str :reverse t)
			  (setf *snippet-begin* (match-beginning 0))
			  (setf start (match-beginning 0)
					end (match-end 0)))))
		(unless abbrev
		  (return-from snippet-expand-abbrev nil))))
	(setq *last-abbrev-text* (buffer-substring start end))
	(delete-region start end)
	(goto-char start)
	(setq *last-abbrev* (car abbrev))
	(setq *last-abbrev-point* start)
	(incf (caddr abbrev))
	(insert (car abbrev))
	(cond ((string-match "^[A-Z]*$" *last-abbrev-text*)
		   (if (and (null *abbrev-all-caps*)
					(save-excursion
					  (> (progn
						   (forward-word -1)
						   (point))
						 (progn
						   (goto-char start)
						   (forward-word 1)
						   (point)))))
			   (capitalize-region start (point))
			 (upcase-region start (point))))
		  ((string-match "[A-Z]" *last-abbrev-text*)
		   (let ((p (point)))
			 (goto-char start)
			 (capitalize-word 1)
			 (goto-char p))))
	(when (cadr abbrev)
	  (funcall (cadr abbrev)))
	t))

(defun snippet-split-slash (str)
  (when (string= "" str)
	(return-from snippet-split-slash '(".*" "\\0")))
  (let ((begin 0)
		(d (match-data))
		lst)
	(when (equal "/" (substring str 0 1))
	  (setf str (substring str 1)))
	(while (string-match "\\([^\\]\\)/" str begin)
	  (let ((tmp (substring str begin (match-end 1)))
			(data (match-data)))
		(push (substitute-string tmp "\\\\/" "/") lst)
		(store-match-data data)
		(setf begin (match-end 0))))
	(unless (= begin (length str))
	  (push (substring str begin) lst))
	(store-match-data d)
	(reverse lst)))

(defvar-local snippet-selection nil)

(defun snippet-select-and-expand (&optional string)
  (interactive "*")
  (let ((lst (append (make-list-from-keyword-table *local-abbrev-table*)
					 (make-list-from-keyword-table *global-abbrev-table*))))
	(cond ((and string (not (find string lst :test 'equal)))
		   (error "snippetが定義されていません: ~A" string))
		  ((not string)
		   (setf string (completing-read "snippet: " lst
										 :case-fold t
										 :must-match t))))
	(unless string
	  (return-from snippet-select-and-expand))
	(cond ((get-selection-type)
		   (setf snippet-selection (buffer-substring (selection-mark) (selection-point)))
		   (delete-region (selection-mark) (selection-point))
		   (stop-selection))
		  (t (snippet-convert-xyzzy-selection)))
	(let ((*snippet-select* string))
	  (snippet-expand))))

(defvar-local snippet-markers nil)

(defun snippet-expand ()
  (interactive "*")
  (cond (snippet-mode-on
		 (snippet-next))
		(t
		 (cond (*snippet-select*
				(setf *snippet-begin* (point))
				(insert (car (or (and *local-abbrev-table*
									  (gethash *snippet-select* *local-abbrev-table*))
								 (gethash *snippet-select* *global-abbrev-table*)))))
			   ((snippet-get-abbrev)
				(snippet-expand-abbrev)
				(snippet-convert-xyzzy-selection))
			   (t (return-from snippet-expand)))
		 (clear-undo-boundary)
		 (forward-char)
		 (setf *snippet-end* (point-marker))
		 (funcall 'set-text-attribute
				  (point) (point) 'snippet-end)
		 (goto-char *snippet-begin*)
		 (save-excursion
		   (goto-char *snippet-end*)
		   (while (scan-buffer (format nil "\\(?:[^\\]\\|^\\)\\(${file:\\([^}]*\\)}\\)")
							   :regexp t :reverse t :no-dup t :limit *snippet-begin*)
			 (let ((path (match-string 2)))
			   (delete-region (match-beginning 1)
							  (match-end 1))
			   (insert-file path))))
		 (save-excursion
		   (goto-char *snippet-end*)
		   (while (scan-buffer "\\(?:[^\\]\\|^\\)\\($\\(?:\\([0-9]+\\)\\|{\\([0-9]+\\)\\(?::\\([^}]*\\)\\)}\\)\\)"
							   :regexp t :reverse t :no-dup t :limit *snippet-begin*)
			 (let (number previous-number
						  default previous-default
						  snippet)
			   (unless (setf number (match-string 2))
				 (setf number (match-string 3))
				 (when (match-string 4)
				   (setf default (snippet-convert-macro (match-string 4)))))
			   (setf snippet (make-snippet :number (parse-integer number)
										   :default (or default "")))
			   (push snippet *snippet-list*)
			   (delete-region (match-beginning 1)
							  (match-end 1))
			   
			   (cond ((and (or (not default)
							   (equal default ""))
						   (= (snippet-number snippet) 0))
					  (push (list (set-marker (make-marker) (point)) snippet) snippet-markers))
					 (t
					  (and default
						   ;(not (equal default ""))
						   (let ((marker (some #'(lambda (m)
												   (when (= (point) (marker-point (car m)))
													 m))
											   snippet-markers)))
							 (prog1
								 (insert default)
							   (when marker
								 (set-marker (car marker) (point))))))
					  (apply 'set-text-attribute
							 (match-beginning 1)
							 (point)
							 snippet
							 (cdr (assoc (snippet-number snippet) *snippet-attribute-dict*))))))))
		 (save-excursion
		   (dolist (snippet *snippet-list*)
			 (goto-char *snippet-end*)
			 (while (scan-buffer (format nil "${~A\\(\\(/[^/}]+\\)\\{,4\\}\\)}"
										 (snippet-number snippet))
								 :regexp t :reverse t :no-dup t :limit *snippet-begin*)
			   (let* ((from (match-beginning 0))
					  (to (match-end 0))
					  (default (snippet-default snippet))
					  (lst (snippet-split-slash (match-string 1)))
					  (tag (make-snippet :number (snippet-number snippet)
										 :regexp (first lst)
										 :format (second lst)
										 :option (third lst)))
					  (replacement (snippet-expand-meta-character default tag))
					  parent before after)
				 (cond ((and (equal replacement "")
							 (or (let ((parents (remove tag (snippet-get-snippet-attribute-point :point from)
														:key 'third :test 'equal)))
								   (and (setf parent (or (find-if 'snippet-default parents :key 'third)
														 (find from parents :key 'second :test 'equal)))
										(setf after t)))
								 (let ((parents (remove tag (snippet-get-snippet-attribute-point :point to)
														:key 'third :test 'equal)))
								   (and (setf parent (or (find-if 'snippet-default parents :key 'third)
														 (find to parents :key 'second :test 'equal)))
										(setf before t)))))
						(let ((before-children (snippet-hiddens-get tag :before t))
							  (after-children (snippet-hiddens-get tag :after t)))
						  (cond (before
								 (dolist (child before-children)
								   (snippet-hiddens-enqueue child (third parent) :before t))
								 (snippet-hiddens-enqueue tag (third parent) :before t)
								 (dolist (child after-children)
								   (snippet-hiddens-enqueue child (third parent) :before t)))
								(after
								 (dolist (child before-children)
								   (snippet-hiddens-enqueue child (third parent) :after t))
								 (snippet-hiddens-enqueue tag (third parent) :after t)
								 (dolist (child after-children)
								   (snippet-hiddens-enqueue child (third parent) :after t))))
						  (snippet-hiddens-delete-parent tag :before t)
						  (snippet-hiddens-delete-parent tag :after t))
						(delete-region from to))
					   (t
						(delete-region from to)
						(let ((begin (point)) end
							  (marker (some #'(lambda (m)
												(when (= (point) (marker-point (car m)))
												  m))
											snippet-markers)))
						  (insert replacement)
						  (when marker
							(set-marker (car marker) (point)))
						  (setf end (point))
						  (apply 'set-text-attribute
								 begin end tag
								 (cdr (assoc (snippet-number tag) *snippet-attribute-dict*))))))))))
		 (snippet-expand-indent)
		 (undo-boundary)
		 (cond ((null *snippet-list*)
				(goto-char *snippet-end*)
				(backward-char)
				(snippet-clear-variable))
			   ((and (null (cdr *snippet-list*))
					 (= (snippet-number (first *snippet-list*)) 0)
					 (equal "" (snippet-default (first *snippet-list*))))
				(snippet-mode-on)
				(snippet-next))
			   (*snippet-list*
				(goto-char *snippet-begin*)
				(snippet-mode-on)
				(snippet-next))))))

(defun snippet-expand-indent (&optional change); change *this-command*
  (let ((*snippet-begin* *snippet-begin*)
		pt)
	(save-excursion
	  (goto-char *snippet-begin*)
	  (unless (bolp)
		(backward-char))
	  (skip-white-backward)
	  (setf *snippet-begin* (point)))
	(save-excursion
	  (goto-char *snippet-end*)
	  (setf pt (point)))
	(save-excursion
	  (when (and pt
				 (or (si:*closurep mode-specific-indent-command)
					 (fboundp mode-specific-indent-command)))
		(goto-char pt)
		(save-excursion
		  (forward-char)
		  (while (< (point) (marker-point *snippet-end*))
			(funcall mode-specific-indent-command)
			(goto-eol)
			(forward-char)
			;(indent-region (1+ pt) *snippet-begin*)
			))
		(goto-char *snippet-begin*)
		(while (scan-buffer "^[ 	]*\\($INDENT\\)" :regexp t :no-dup t :reverse nil
							:limit (marker-point *snippet-end*))
		  (let ((begin (match-beginning 1)))
			(goto-char begin)
			(let ((att (remove-if-not #'(lambda (x) (= (first x) (second x)))
									  (snippet-get-snippet-attribute-point))))
			  (unless att
				(funcall mode-specific-indent-command)))
			(goto-char begin)
			(scan-buffer "^[ 	]*\\($INDENT\\)" :regexp t)
			(delete-region (match-beginning 1)
						   (match-end 1))
			))))
	(when change
	  (setf *this-command* 'indent-region))))

(defun snippet-hiddens-enqueue-point (parent &key after before)
  (dolist (tag (reverse (remove-if-not
						 #'(lambda (x)
							 (= (first x) (second x) (point)))
						 (snippet-get-snippet-attributes))))
	#+:snippet
	(msgbox "enqueue : ~S~%before:~S~%after:~S~%" (third tag) *snippet-before-alist* *snippet-after-alist*)
	
	(snippet-hiddens-enqueue (third tag) parent :after after :before before)))


(defvar *snippet-pre-check* nil)
(defvar *snippet-modify-check* nil)
(defvar *snippet-modify-position* nil)

(defun snippet-modify-check (buffer operation from to undo-p)
  (setf *snippet-modify-check* t
		*snippet-modify-position* (list from to))
  (enable-post-buffer-modified-hook nil)
  (delete-hook 'post-buffer-modified-hook 'snippet-modify-check))

(defvar *snippet-before-point* nil)

(defun snippet-before ()
  (when snippet-mode-on
	;; modify command?
	(setf *snippet-pre-check* t)
	(add-hook 'post-buffer-modified-hook 'snippet-modify-check)
	(enable-post-buffer-modified-hook t)
	
	(when (and (eq *last-command* 'snippet-expand)
			   (modulep "ac-mode")
			   (eq *this-command* (intern "ac-mode-complete-or-indent" "ed")))
	  (delete-region (selection-mark) (selection-point)))
	(let* ((lst (remove-if-not
				 #'(lambda (x)
					 (= (first x) (second x) (point)))
				 (snippet-get-snippet-attributes)))
		   (parent (third (car lst))))
	  (dolist (tag (reverse (cdr lst)))
		(snippet-hiddens-enqueue (third tag) parent :after t)))
	;; 	#+:snippet
	;; 	(msgbox "0 ~S~%before:~S~%after:~S~%" (snippet-get-snippet-attributes) *snippet-before-alist* *snippet-after-alist*)
	(setf *snippet-before-point* (point))
	(if snippet-mode-on
		(setf *snippet-current-tag* (first (snippet-get-snippet-attribute-point :parent t)))
	  (setf *snippet-current-tag* nil))))

(defun snippet-after ()
  (when snippet-mode-on
	(refresh-screen)
	(cond ((find *this-command* '(quit))
		   (snippet-mode-off))
		  ((and *snippet-modify-check*
				*snippet-pre-check*
				*snippet-current-tag*)
		   (let ((from (first *snippet-current-tag*))
				 (to (second *snippet-current-tag*))
				 (snippet (third *snippet-current-tag*)))
			 (unless *executing-macro*
			   (refresh-screen))
			 (when (get-selection-type)
			   (when (<= (selection-point) (selection-mark))
				 (save-excursion
				   (delete-selection)))
			   (stop-selection))
			 (dolist (marker snippet-markers)
			   (when (= *snippet-before-point* (marker-point (car marker)))
				 (set-marker (car marker) (point))))
			 (cond ((and (not (snippet-get-snippet-attribute-point :parent t)) ;; 属性付きの最後尾で文字を追加した場合
						 (find-text-attribute snippet))
					(delete-text-attributes snippet :test 'equal)
					(apply 'set-text-attribute
						   from
						   (setf to (point))
						   snippet
						   (cdr (assoc (snippet-number snippet) *snippet-attribute-dict*))))
				   ((not (find-text-attribute snippet)) ;; 全部削除した場合
					(apply 'set-text-attribute
						   from
						   (setf to (point))
						   snippet
						   (cdr (assoc (snippet-number snippet) *snippet-attribute-dict*))))
				   ((and (not (find-text-attribute-point (point))) ;; 選択後最初の入力
						 (find-text-attribute snippet))
					(setf from (first *snippet-modify-position*)
						  to (second *snippet-modify-position*))
					)
				   )
			 #+:snippet
			 (msgbox "1 ~S~%before:~S~%after:~S~%" (snippet-get-snippet-attributes) *snippet-before-alist* *snippet-after-alist*)

			 (save-excursion
			   (let ((str (buffer-substring from to))
					 (attributes (snippet-get-snippet-attributes)))
				 (unless *executing-macro*
				   (refresh-screen))
				 ;; surface ...
				 (dolist (attr (remove-if-not
								#'(lambda (attr)
									(= (snippet-number (third attr))
									   (snippet-number snippet)))
								(sort (snippet-get-snippet-attributes :child t) '> :key 'first)))
				   (let* ((from (first attr))
						  (to (second attr))
						  (tag (third attr))
						  (replacement (snippet-expand-meta-character str tag))
						  parent before after)
					 (cond ((and (equal replacement "")
								 (or (let ((parents (remove tag (snippet-get-snippet-attribute-point :point from)
															:key 'third :test 'equal)))
									   (and (setf parent (or (find-if 'snippet-default parents :key 'third)
															 (find from parents :key 'second :test 'equal)))
											(setf after t)))
									 (let ((parents (remove tag (snippet-get-snippet-attribute-point :point to)
															:key 'third :test 'equal)))
									   (and (setf parent (or (find-if 'snippet-default parents :key 'third)
															 (find to parents :key 'second :test 'equal)))
											(setf before t)))))
							(cond (before (snippet-hiddens-enqueue tag (third parent) :before t))
								  (after (snippet-hiddens-enqueue tag (third parent) :after t)))
							(delete-region from to))
						   ((not (equal (buffer-substring from to) replacement))
							(goto-char from)
							(delete-region from to)
							(apply 'set-text-attribute
								   (point)
								   (setf to (progn (insert replacement) (point)))
								   tag
								   (cdr (assoc (snippet-number tag) *snippet-attribute-dict*))
								   )))))
				 ;; 				 #+:snippet
				 ;; 				 (msgbox "start hidden,  from here~%~S~%" attributes)

				 ;; hidden ...
				 (save-excursion
				   (dolist (tag (sort (copy-tree *snippet-after-alist*) '>
									  :key #'(lambda (x) (first (find (first x) attributes :test 'equal :key 'third)))))
					 (let ((pos (second (find (first tag) attributes :test 'equal :key 'third)))
						   (children (second tag))
						   tmp not-insert-list)
					   (dolist (child (reverse children))
						 (let ((replacement (snippet-expand-meta-character str child)))
						   (cond ((or (/= (snippet-number child)
										  (snippet-number snippet))
									  (equal replacement ""))
								  (push child not-insert-list))
								 (t
								  (goto-char pos)
								  (snippet-hiddens-delete-child child :after t)
								  (snippet-hiddens-enqueue-point child :after t)

								  (apply 'set-text-attribute
										 (point)
										 (progn (insert replacement) (point))
										 child
										 (cdr (assoc (snippet-number child) *snippet-attribute-dict*)))
								  (push (list child not-insert-list) tmp)
								  (setf not-insert-list nil)
								  ))))
					   (dolist (x tmp)
						 (let ((parent (first x))
							   (children (second x)))
						   (dolist (child children)
							 (snippet-hiddens-delete-child child :after t)
							 (snippet-hiddens-enqueue child parent :after t))))))
				   #+:snippet
				   (msgbox "2 ~S~%before:~S~%after:~S~%" (snippet-get-snippet-attributes) *snippet-before-alist* *snippet-after-alist*)

				   (dolist (tag (sort (copy-tree *snippet-before-alist*) '<
									  :key #'(lambda (x)
											   (second (find (first x) attributes :test 'equal :key 'third)))))
					 (let ((pos (first (find (first tag) attributes :test 'equal :key 'third)))
						   (children (second tag))
						   tmp not-insert-list)
					   #+:snippet
					   (unless pos
						 (msgbox "a ~S~%~S~%before:~S~%after:~S~%" tag (snippet-get-snippet-attributes) *snippet-before-alist* *snippet-after-alist*)
						 )

					   (goto-char pos)
					   (dolist (child children)
						 (let ((replacement (snippet-expand-meta-character str child)))
						   (cond ((or (/= (snippet-number child)
										  (snippet-number snippet))
									  (equal replacement ""))
								  (push child not-insert-list))
								 (t
								  (snippet-hiddens-enqueue-point child :before t)
								  (apply 'set-text-attribute
										 (point)
										 (progn (insert replacement) (point))
										 child
										 (cdr (assoc (snippet-number child) *snippet-attribute-dict*)))
								  (push (list child not-insert-list) tmp)
								  (setf not-insert-list nil)
								  (snippet-hiddens-delete-child child :before t)))))
					   (dolist (x tmp)
						 (let ((parent (first x))
							   (children (second x)))
						   (dolist (child children) ; reverse ?
							 (snippet-hiddens-delete-child child :after t)
							 (snippet-hiddens-enqueue child parent :after t))))))))))
		   (snippet-expand-indent t)
		   ;; 		   #+:snippet
		   ;; 		   (msgbox "3 ~S~%before:~S~%after:~S~%" (snippet-get-snippet-attributes) *snippet-before-alist* *snippet-after-alist*)

		   )
		  ((and snippet-mode-on
				(find *last-command* '(snippet-expand snippet-prev snippet-next))
				(not (find *this-command* '(snippet-prev snippet-next))))
		   (stop-selection))))
  ;reset modify command flag
  (setf *snippet-modify-check* nil
		*snippet-pre-check* nil)
  )

(defun snippet-expand-meta-character (str snippet)
  (when (and str (snippet-p snippet))
	(let (result
		  (regexp (snippet-regexp snippet))
		  (format (snippet-convert-macro (snippet-format snippet)))
		  (option (snippet-option snippet)))
	  (cond ((and regexp format option
				  (string-match "g" option))
			 (let ((start 0)
				   (tmp ""))
			   (while (string-match regexp str start)
				 (setf start (match-end 0)
					   tmp (concat tmp (string-replace-match str format))))
			   (setf result tmp)))
			((and regexp format
				  (string-match regexp str))
			 (setf result (string-replace-match str format)))
			(t
			 (setf result "")))
	  result)))

(defun snippet-convert-macro (str)
  (let ((match (match-data)))
	(when (and (get-buffer-file-name) str)
	  (setf str (substitute-string str "XYZZY-FILE-NAME"                 (or (get-buffer-file-name) ""))
			str (substitute-string str "XYZZY-FILE-NAMESTRING"           (or (file-namestring (get-buffer-file-name)) ""))
			str (substitute-string str "XYZZY-FILE-DIRECTORY-NAMESTRING" (or (directory-namestring (get-buffer-file-name)) ""))
			str (substitute-string str "XYZZY-FILE-PATHNAME-NAME"        (or (pathname-name (get-buffer-file-name)) ""))
			str (substitute-string str "XYZZY-FILE-PATHNAME-TYPE"        (or (pathname-type (get-buffer-file-name)) ""))
			str (substitute-string str "XYZZY-FILE-PATHNAME-DEVICE"      (or (pathname-device (get-buffer-file-name)) ""))
			))
	(when snippet-selection
	  (setf str (substitute-string str "XYZZY-SELECTION" snippet-selection)))
	(store-match-data match)
	str))

(defun snippet-convert-xyzzy-selection ()
  (save-excursion
	(cond ((get-selection-type)
		   )
		  ((scan-buffer "${\\([0-9]\\):XYZZY-SELECTION}" :regexp t :reverse t :limit *snippet-begin*)
		   (replace-match "$\\1")))))

;;; command
(defun snippet-next (&optional prev)
  (interactive "P")
  (let* ((list (sort (snippet-get-snippet-attributes :parent t :marker t)
					 (if prev '> '<)
					 :key 'first))
		 (item (find (point) list
					 :test (if prev '> '<)
					 :key 'first)))
	(cond (item
		   (goto-char (second item))
		   (start-selection 2)
		   (goto-char (first item))
		   (let ((last (first (last list))))
			 (and last
				  (equal last item)
				  (= (point) (first last) (second last))
				  (= 0 (snippet-number (third last)))
				  (snippet-mode-off))
			 t))
		  (t
		   (snippet-mode-off)))))

(defun snippet-prev ()
  (interactive)
  (snippet-next t))

(defun snippet-mode (&optional (arg nil sv))
  (interactive "p")
  (toggle-mode 'snippet-mode-on arg sv)
  (cond (snippet-mode-on
		 (add-hook '*pre-command-hook* 'snippet-before)
		 (add-hook '*post-command-hook* 'snippet-after)
		 (and (modulep "paren")
			  (setf *snippet-last-paren-state* *paren-status*)
			  (funcall (intern "turn-off-paren"))))
		(t
		 (when (get-selection-type)
		   (stop-selection))
		 (delete-hook '*pre-command-hook* 'snippet-before)
		 (delete-hook '*post-command-hook* 'snippet-after)
		 (and (modulep "paren")
			  *snippet-last-paren-state*
			  (funcall (intern "turn-on-paren")))
		 (delete-text-attributes t :test #'(lambda (x y) (snippet-p y)))
		 (setf *snippet-list* nil
			   snippet-selection nil
			   snippet-markers nil
			   *snippet-last-paren-state* nil)
		 (snippet-clear-variable)))
  (if snippet-mode-on
	  (set-minor-mode-map *snippet-mode-map*)
	(unset-minor-mode-map *snippet-mode-map*))
  (unless *executing-macro*
	(update-mode-line))
  t)

(defun snippet-mode-on ()
  (interactive)
  (snippet-mode t))

(defun snippet-mode-off ()
  (interactive)
  (snippet-mode nil))

;;; snippet.l ends here
