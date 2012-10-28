;;; -*- mode: lisp; package: editor -*-
;;; name:     scope
;;; version:  2007.02.22
;;; author:   shiro
;;; category: Utilities
;;; src:      http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fscope&openfile=
;;; changes:  いろいろ調整
;;;           lisp-modeでのac-modeとの連携追加
;;; files:    site-lisp/scope.l
;;;           site-lisp/scope.lc
;;;           site-lisp/ni-autoload/silog/scope.l

;; Copyright (C) 1996-2005 Tetsuya Kamei
;; Copyright (C) 2006 shiro
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
;; 指定された条件に合う場合のみ、グローバルマップやローカルマップより
;; 優先されるキーバインドの設定をすることができます。
;; 条件に合わなければローカルマップやグローバルマップで
;; 設定されたコマンドが実行されます。
;; 
;; あとライブラリ的に。というかac-modeの補佐的に。
;; (こっちがメインかも)
;; 

;; 使い方:
;; 
;; 何か設定しないと何もできません。
;; 設定例を参考に設定してください。

;; 設定:
;;
;; define-scope-key
;;   スコープ用のdefine-keyの様なものです。
;;    (define-scope-key '(#\C-x #\C-f) 'function 'condition "string")
;;   のように設定します。
;;   function
;;    - ラムダ式や関数を指定できます。
;;    - call-interactivelyで呼ばれるので(interactive)を指定してください。
;;   condition
;;    - ラムダ式か関数か文字列を指定できます。
;;    - conditionが非nilを返したらfunctionが実行されます。
;;    - conditionが文字列の時はscope-rulesを参照して対応するS式を評価した値をみます。
;;   string
;;    - 複数のconditionにマッチした時にメニューに表示される文字列です。
;;    - functionにラムダ式を指定する場合は必ず指定して下さい。
;;    - この文字で(equalを使って)重複チェックもしています。
;;   全てのconditionがnilを返したらローカルマップやグローバルマップを参照します。

;; 設定例:
;; 
;; 1. lisp-modeで行頭に;;や;;;がある時にRETを押したら次の行も同じ数のセミコロンを自動挿入
;; 
;; (add-hook '*lisp-mode-hook* 'scope-lisp-mode-init)
;; (defun scope-lisp-mode-init ()
;;   (define-scope-key #\RET
;;                     #'(lambda () (interactive)
;;                         (save-excursion
;;                           (goto-bol) (scan-buffer "^[ \t]*;\\{2,3\\}[ \t]*" :regexp t))
;;                         (newline) (insert (match-string 0)))
;;                     #'(lambda () (unless (bolp)
;;                                    (scope-get-match "^;\\{2,3\\}[^;]\\(.\\|[ 　\t]\\)*$")))
;;                     "newline with &;"))
;; 
;; 2. php-modeで
;;    /*
;;     *
;;     */
;;    みたいになってるところでRETを押したら次の行も*と適当な量の空白を挿入
;; 
;; (add-hook '*lisp-mode-hook* 'scope-lisp-mode-init)
;; (defun scope-php-mode-init ()
;;   (define-scope-key #\RET
;;                     #'(lambda () (interactive)
;;                         (save-excursion
;;                           (goto-bol) (scan-buffer "^[ \t]*\\*[ \t]*" :regexp t))
;;                         (newline) (insert (match-string 0)))
;;                     #'(lambda () (and (not (bolp))
;;                                       (scope-get-syntax ":comment")
;;                                       (scope-get-match "^[ \t]*\\*\\([ 　\t]\\|.\\)*$")
;;                                       (scope-get-match "/\\*\\([ 　\t\n\r]\\|.\\)*?\\*/")))
;;                     "newline with &*"))

;; カスタマイズ:
;; 
;; scope-rules
;;   define-scope-keyのconditionに文字列を指定した時に参照するS式を定義します。
;;   (setf scope-rules
;;         '((":string" (scope-get-syntax ":string"))
;;           (":comment" (scope-get-syntax ":comment"))))
;;   と定義してconditionに":string"を指定した場合、(scope-get-syntax ":string")がevalされます。
;; 

;; 履歴
;; 
;; 2007.02.22
;; - いろいろ調整
;; - lisp-modeでのac-modeとの連携追加
;; 
;; 2007.02.19
;; - 初版

;;; Code:

(require "ac-mode")

(provide "scope")

(in-package "editor")

(export '(scope-check
		  scope-get-syntax
		  scope-get-match
		  scope-get-begin
		  scope-get-end
		  scope-rules
		  define-scope-key))

(defvar-local scope-rules
			  '((":string" (scope-get-syntax ":string"))
				(":comment" (scope-get-syntax ":comment"))))

;; :string nilにすると正規表現にマッチした場所が
;; 文字列ならマッチしていないとみなして再度検索する。
;; :comment nilにすると正規表現にマッチした場所が
;; コメントならマッチしていないとみなして再度検索する。
;; 
;; 例えば <img alt="</a>"> のalt属性の中をaタグの終了だと誤判定しないために。
(defun scope-get-match (str &key (string t) (comment t))
  (save-excursion
	(let ((pt (point)))
	  (forward-char)
	  (and (not (while (not (if (scan-buffer str :regexp t :reverse t :no-dup t)
								(and (setf state (match-data))
									 (or string
										 (not (scope-get-syntax ":string")))
									 (or comment
										 (not (scope-get-syntax ":comment"))))
							  (return-from scope-get-match)))))
		   (<= (point) pt)
		   (store-match-data state) (<= pt (match-end 0))
		   (match-beginning 0)))))

(defun scope-get-begin (str &key (string t) (comment t))
  (let ((pt (point)))
	(save-excursion
	  (and (not (while (not (if (scan-buffer str :regexp t :reverse t :no-dup t)
								(and (setf state (match-data))
									 (or string
										 (not (scope-get-syntax ":string")))
									 (or comment
										 (not (scope-get-syntax ":comment"))))
							  (return-from scope-get-begin)))))
		   (< (point) (match-end 0))
		   (<= (match-end 0) pt)
		   (match-beginning 0)))))

(defun scope-get-end (str &key (string t) (comment t))
  (save-excursion
	(let ((pt (point)))
	  (and (not (while (not (if (scan-buffer str :regexp t :no-dup t)
								(and (setf state (match-data))
									 (or string
										 (not (scope-get-syntax ":string")))
									 (or comment
										 (not (scope-get-syntax ":comment"))))
							  (return-from scope-get-end)))))
		   (< pt (point))
		   (<= (point) (match-end 0))
		   (match-beginning 0)))))

(defun scope-get-syntax (str)
  (when (save-excursion (forward-char))
	(let ((ch (char (buffer-substring (point) (1+ (point))) 0)))
	  (cond ((equal str ":string")
			 (eq (parse-point-syntax) :string))
			((equal str ":comment")
			 (eq (parse-point-syntax) :comment))
			((equal str ":tag")
			 (eq (parse-point-syntax) :tag))
			((equal str "c++-comment")
			 (syntax-c++-comment-p ch))
			((equal str "close")
			 (syntax-close-p ch))
			((equal str "close-tag")
			 (syntax-close-tag-p ch))
			((equal str "end-c++-comment")
			 (syntax-end-c++-comment-p ch))
			((equal str "end-comment")
			 (syntax-end-comment-p ch))
			((equal str "end-multi-comment-1")
			 (syntax-end-multi-comment-1-p ch))
			((equal str "end-multi-comment-2")
			 (syntax-end-multi-comment-2-p ch))
			((equal str "escape")
			 (syntax-escape-p ch))
			((equal str "junk")
			 (syntax-junk-p ch))
			((equal str "math")
			 (syntax-math-p ch))
			((equal str "open")
			 (syntax-open-p ch))
			((equal str "open-tag")
			 (syntax-open-tag-p ch))
			((equal str "punctuation")
			 (syntax-punctuation-p ch))
			((equal str "quote")
			 (syntax-quote-p ch))
			((equal str "start-column-comment")
			 (syntax-start-column-comment-p ch))
			((equal str "start-comment")
			 (syntax-start-comment-p ch))
			((equal str "start-multi-comment-1")
			 (syntax-start-multi-comment-1-p ch))
			((equal str "start-multi-comment-2")
			 (syntax-start-multi-comment-2-p ch))
			((equal str "string")
			 (syntax-string-p ch))
			((equal str "symbol")
			 (syntax-symbol-p ch))
			((equal str "symbol-prefix")
			 (syntax-symbol-prefix-p ch))
			((equal str "whitespace")
			 (syntax-whitespace-p ch))
			((equal str "word")
			 (syntax-word-p ch))))))

(defun scope-get-current-scope-list ()
  (mapcar 'car (remove-if-not
				#'(lambda (rule)
					(eval (second rule)))
				scope-rules)))

(defun scope-check ()
  "カーソル位置のスコープを確認する"
  (interactive)
  (let ((rules (scope-get-current-scope-list)))
	(when rules
	  (popup-string
	   (format nil "Scopes:~%~{~%~A~}" rules)
	   (point)))))


;;; -----------------------------------------------------------------
;;; Scope Keymap
;;; -----------------------------------------------------------------

;;; マイナーモードのキーマップとして登録されるキーマップ
(defvar *scope-map* nil)
(unless *scope-map*
  (setf *scope-map* (make-sparse-keymap)))

; >> (ed::scope-create-symbol '(#\C-x #\C-f))
; editor::scope-C-xC-f-functions
(defun scope-create-symbol (key)
  (let* ((str (key-to-string key))
		 (symbol (intern (concat "scope-"
								 (substitute-string str " " "")
								 "-functions")
						 (find-package "editor"))))
	(unless (boundp symbol)
	  (eval `(defvar-local ,symbol nil (concat "(condition . function) alist for " ',str)))
	  (eval `(defun ,symbol ()
			   (interactive)
			   (scope-call-function ',key ',symbol)))
	  (setf (get symbol 'lisp::function-documentation) "Call function at scope."))
	(set-minor-mode-map *scope-map*)
	(unless (lookup-keymap *scope-map* key)
	  (define-key *scope-map* key symbol))
	symbol))

(defun define-scope-key (key command &optional condition name)
  "キーマップにキーを定義する"
  (and (not name)
	   (functionp command)
	   (error "Specify documentation for menu."))
  (let ((symbol (scope-create-symbol key)))
	(eval `(pushnew (list ',command ',condition ',name) ,symbol :test 'equal :key 'third))
	symbol))

(defun scope-call-function (key symbol)
  (let (rule func name res)
	(dolist (el (eval symbol))
	  (setf rule (second el)
			func (first el)
			name (third el))
	  (cond ((functionp rule)
			 (when (funcall rule)
			   (push el res)))
			((stringp rule)
			 (eval (second (assoc ":comment" scope-rules :test 'equal))))
			((consp rule)
			 (when (eval rule)
			   (push el res)))
			((and (fboundp rule)
				  (symbolp rule))
			 (when (funcall rule)
			   (push el res)))
			((symbolp rule)
			 (when (eval rule)
			   (push el res)))))
	(cond ((cdr res)
		   (let ((menu (create-popup-menu :scope-menu)))
			 (dolist (item res)
			   (let* ((func (first item))
					  (name (or (third item)
								(when (symbolp func)
								  (or (documentation func 'function)
									  (string func))))))
				 (add-menu-item menu nil name func)))
			 (track-popup-menu menu)))
		  (res
		   (call-interactively (first (car res))))
		  (t
		   (let ((bound (mapcar #'(lambda (x)
									(when (keymapp x)
									  (lookup-keymap x key)))
								(append (list (local-keymap))
										(list *global-keymap*)))))
			 (call-interactively (or (find-if-not #'keymapp bound)
									 (find-if #'identity bound))))))))

(export '(scope-get-beginning-of-string
		  scope-get-end-of-string))

(defun scope-get-beginning-of-string ()
  (when (scope-get-syntax ":string")
	(save-excursion
	  (while (and (scan-buffer "\\s\"" :regexp t :reverse t :no-dup t)
				  (equal (parse-point-syntax
						  (1- (match-beginning 0)))
						 :string)))
	  (point))))

(defun scope-get-end-of-string ()
  (when (scope-get-syntax ":string")
	(save-excursion
	  (while (and (scan-buffer "\\s\"" :regexp t :tail t)
				  (equal (parse-point-syntax
						  (1+ (match-beginning 0)))
						 :string)))
	  (backward-char)
	  (point))))

;;; -----------------------------------------------------------------
;;; Lisp
;;; -----------------------------------------------------------------
(export '(scope-lisp-not-toplevel
		  scope-lisp-toplevel
		  scope-lisp-function
		  scope-lisp-recursive
		  scope-lisp-package
		  scope-lisp-nth-arg
		  scope-lisp-get-nth-arg
		  ))

;; 括弧の中かどうか。
(defun scope-lisp-not-toplevel ()
  (save-excursion
	(backward-up-list 1 t)))

;; トップレベルかどうか。括弧の中じゃない場合t。こことか。
(defun scope-lisp-toplevel ()
  (save-excursion
   (not (backward-up-list 1 t))))


;; (str ここだけ (ここは駄目))
;; 
;; 引数なしで呼ばれたら関数名を返す
;; 何度も(scope-lisp str)するなら引数無しで呼んでfindした方が良いと思う。
(defun scope-lisp-function (&optional str)
  (save-excursion
	(backward-up-list 1 t)
	(down-list 1 t)
	(cond (str (looking-at str))
		  (t
		   (buffer-substring
			(point)
			(progn (skip-syntax-spec-forward "w_")
			  (point)))))))

;; (str ここも (ここも (ここも)))
;; 
;; 引数なしで呼ばれたら関数名のリストを返す
;; 何度も(scope-lisp-recursive str)するなら引数無しで呼んだほうがいい
;; ただ、↓で言えば(cond (strのstrも返すように
;; あんまり賢くないので、しっかりやる必要があるなら
;; (remove-if-not 'macro-function (mapcar #'(lambda (x) (intern x)) (scope-lisp-recursive)))
;; とか適当にやる必要がある、かも。
(defun scope-lisp-recursive (&optional str)
  (or (and str (scope-lisp str))
	  (let (res lst)
		(save-excursion
		  (while (cond ((eq (parse-point-syntax) :string)
						(skip-syntax-spec-backward "^\"")
						(backward-char))
					   (t (backward-up-list 1 t)))
			(save-excursion
			  (forward-char)
			  (cond (str
					 (when (looking-at str)
					   (setf res t)
					   (return)))
					(t
					 (push (buffer-substring
							(point)
							(progn (skip-syntax-spec-forward "w_")
							  (point)))
						   lst))))))
		(or res lst))))

; (in-package str) ここは良い
; (in-package other) ここは駄目
(defun scope-lisp-package (str)
  (let (res)
	(save-excursion
	  (when (while (not (and (scan-buffer "(in-package" :reverse t :no-dup t)
							 (not (scope-get-syntax ":comment"))
							 (not (scope-get-syntax ":string")))))
		(let ((limit (save-excursion (while (forward-sexp 1 t)) (point))))
		  (when (scan-buffer str :regexp t :limit limit)
			(setf res t)))))
	res))

;; キャレットがn番目の引数かどうか
;; (の直後が0番目
;; 現在のキャレットの位置で何か入力したら第何引数になるかを考えてnを指定する
;; 
;; nが与えられなかったら現在何番目の引数を返す。
;; 何度も(scope-lisp-nth-arg n)するなら引数無しで呼んでfindした方が良いと思う。
(defun scope-lisp-nth-arg (&optional n)
  (labels ((count ()
			 (cond ((syntax-open-p (preceding-char)) -1)
				   (t (backward-sexp) (+ 1 (count))))))
	(save-excursion
	  (when (eq (parse-point-syntax) :string)
		(while (or (not (syntax-string-p (preceding-char)))
				   (eq (parse-point-syntax (1- (point))) :string))
		  (backward-sexp))
		(backward-char))
	  (let ((point (point))
			(number (save-excursion (count))))
		(when (save-excursion
				(skip-syntax-spec-backward "w_")
				(= point (point)))
		  (setf number (1+ number)))
		(if n (= number n) number)))))

;; n番目までの引数をリストで返す
;; (の直後が0番目
(defun scope-lisp-get-nth-arg (n)
  (save-excursion
	(when (backward-up-list 1 t)
	  (down-list 1 t)
	  (let (lst)
		(dotimes (x (1+ n) lst)
		  (push (string-left-trim
				 " "
				 (buffer-substring
				  (point)
				  (progn (forward-sexp 1 t) (point))))
				lst))
		(nreverse lst)))))

;;; for ac-mode
(defvar *scope-lisp-key-list*
  '((("find-if" "find-if-not" "position-if" "position-if-not" "count-if" "count-if-not") ;関数名
	 (":from-end " ":start " ":end " ":key ") ; key
	 (3 5 7 9)) ; 何番目の引数で↑を補完する?
	(("set-text-attribute")
	 (":foreground " ":background " ":bold " ":underline " ":strike-out " ":prefix " ":extend ")
	 (4 6 8 10 12 14 16))
	(("modify-text-attributes-if" "modify-text-attributes-if-not")
	 (":foreground " ":background " ":bold " ":underline " ":strike-out " ":prefix " ":extend " ":start " ":end " ":key ")
	 (2 4 6 8 10 12 14 16 18 20))
	(("modify-text-attributes")
	 (":foreground " ":background " ":bold " ":underline " ":strike-out " ":prefix " ":extend " ":start " ":end " ":test " ":test-not " ":key ")
	 (2 4 6 8 10 12 14 16 18 20 22 24))
	(("substitute" "nsubstitute")
	 (":from-end " ":test " ":test-not " ":start " ":end " ":count " ":key ")
	 (4 6 8 10 12 14 16))
	(("delete" "remove")
	 (":from-end " ":test " ":test-not " ":start " ":end " ":count " ":key ")
	 (3 5 7 9 11 13 15))
	(("find" "count" "position")
	 (":from-end " ":test " ":test-not " ":start " ":end " ":key ")
	 (3 5 7 9 11 13))
	(("adjoin" "pushnew" "subst" "nsubst" "assoc" "rassoc" "member" "sublis" "nsublis"
	  "union" "nunion" "subsetp" "intersection" "nintersection" "set-difference"
	  "nset-difference" "set-exclusive-or" "nset-exclusive-or")
	 (":test " ":test-not " ":key ")
	 (3 5 7))
	(("string>=" "string>" "string=" "string<=" "string<" "string/="
	  "string-not-lessp" "string-not-greaterp" "string-not-equal"
	  "string-lessp" "string-greaterp" "string-equal" "replace")
	 (":start1 " ":end1 " ":start2 " ":end2 ")
	 (3 5 7 9))
	(("scan-buffer")
	 (":no-dup " ":case-fold " ":reverse " ":tail " ":regexp " ":limit " ":left-bound " ":right-bound " ":last-match ")
	 (2 4 6 8 10 12 14 16 18))
	))

(defun scope-lisp-create-key (function argument position)
  #'(lambda ()
	  (let (pos)
		(when (and (scope-lisp-not-toplevel)
				   (setf pos (find (scope-lisp-nth-arg) position))
				   (find (scope-lisp-function) function :test 'equal))
		  (setf *ac-mode-start-marker*
				(set-marker (make-marker)
							(save-excursion (skip-syntax-spec-backward "w_") (point)))
				*ac-mode-end+1-marker*
				(set-marker (make-marker)
							(save-excursion (skip-syntax-spec-forward "w_") (forward-char) (point)))
				*ac-mode-command* '(ac-mode-try-expand-snippet ac-mode-try-complete-list)
				*ac-mode-allow-empty-string-modules* '(ac-mode-try-complete-list)
				*ac-mode-use-complete+-modules* '(ac-mode-try-complete-list)
				*ac-mode-complete-user-list*
				(set-difference
				 argument (scope-lisp-get-nth-arg pos)
				 :test #'(lambda (x y)
						   (equal (string-right-trim " " x) y)))
				*ac-mode-complete-type-list*
				"Key")))))

;; complete package name
(defun scope-lisp-package-name ()
  (when (and (scope-get-syntax ":string")
			 (find (scope-lisp-function)
				   '("in-package" "delete-package" "find-package" "package-use-list")
				   :test 'equal)
			 (scope-lisp-nth-arg 1))
	(setf *ac-mode-start-marker* ;; ここから
		  (set-marker (make-marker) (1+ (scope-get-beginning-of-string)))
		  *ac-mode-end+1-marker* ;; ここまでの文字を補完対象とみなす
		  (set-marker (make-marker) (1+ (scope-get-end-of-string)))
		  ;; 使用する補完の種類
		  ;; 順番も関係あり。前から試して駄目なら次へ。
		  *ac-mode-command*
		  '(ac-mode-try-expand-snippet ac-mode-try-complete-list)
		  ;; 空白文字もおっけーの補完の種類をリストで
		  *ac-mode-allow-empty-string-modules*
		  '(ac-mode-try-complete-list)
		  ;; complete+があれば使う補完の種類をリストで
		  ;; (部分一致が欲しいときとか)
		  *ac-mode-use-complete+-modules*
		  '(ac-mode-try-complete-list)
		  ;; 補完にac-mode-try-complete-list(自分でリストを指定して補完)
		  ;; を使う場合はここで指定する
		  *ac-mode-complete-user-list*
		  (mapcar 'package-name (list-all-packages))
		  ;; popup-stringに表示される文字列
		  ;; 補完の種類の判別用(?)
		  *ac-mode-complete-type-list*
		  "Package name")))

(defun ac-mode-scope-lisp ()
  (dolist (x *scope-lisp-key-list*)
	(add-hook 'ac-mode-pre-completion-hook
			  (scope-lisp-create-key
			   (first x) (second x) (third x))))
  (add-hook 'ac-mode-pre-completion-hook 'scope-lisp-package-name))
(add-hook '*lisp-mode-hook* 'ac-mode-scope-lisp)
(add-hook '*lisp-interaction-mode-hook* 'ac-mode-scope-lisp)

#|
.xyzzyに書いてlisp-modeのバッファで
C-;をあちこちで押しまくると雰囲気がつかめるかも。

(global-set-key #\C-\; 'scope-check)

(dolist (hook '(*lisp-mode-hook* *lisp-interaction-mode-hook*))
  (add-hook hook 'scope-init-lisp))
(defun scope-init-lisp ()
  (setf scope-rules
    (append scope-rules
        '(("interactive" (and (scope-lisp-function "interactive")
							  (scope-lisp-nth-arg 1)))
          ("defun-r"     (scope-lisp-recursive "defun"))
          ("editor"      (scope-lisp-package "\\(ed\\|editor\\)"))
          ("zero-arg"    (scope-lisp-nth-arg 0))
          ("first-arg"   (scope-lisp-nth-arg 1))
          ("second-arg"  (scope-lisp-nth-arg 2))
          ("third-arg"   (scope-lisp-nth-arg 3))
          ("fourth-arg"  (scope-lisp-nth-arg 4))
          ))))
|#

;;; -----------------------------------------------------------------
;;; HTML
;;; -----------------------------------------------------------------
(export '(scope-html-any-open-tag
		  scope-html-any-close-tag
		  scope-html-inner-any-tag
		  scope-html-inner-any-attribute
		  scope-html-inner-any-string-attribute
		  scope-html-uplevel-tag
		  scope-html-get-doctype
		  *scope-html-doctype-alist*
		  ))

(defun scope-html-any-open-tag (&optional tag)
  (scope-get-match
   (format nil "<~A[^>]*" (if (stringp tag) tag "[^/]"))
   :string nil :comment nil))

(defun scope-html-any-close-tag (&optional tag)
  (scope-get-match
   (format nil "</~A[^>]*" (if (stringp tag) tag ""))
   :string nil :comment nil))

(defun scope-html-inner-any-tag (&optional tag)
  (let ((tag1 (if (stringp tag) tag "[^/]"))
		(tag2 (if (stringp tag) tag "")))
	(and (> (or (scope-get-begin (format nil "<~A[^>]*>" tag1) :string nil :comment nil) 0)
			(or (scope-get-begin (format nil "</~A[^>]*>" tag2) :string nil :comment nil) 0))
		 (scope-get-end (format nil "</~A[^>]*>" tag2)))))

(defun scope-html-inner-any-attribute (&optional attribute)
  (if attribute
	  (scope-get-match (format nil "~A[ \t\r\n]*=[ \t\r\n]*\"[^\"]*" attribute))
	(let ((pos (scope-get-match "[^ \t\r\n]+[ \t\r\n]*=[ \t\r\n]*\"[^\"]*")))
	  (when pos
		(save-excursion
		  (goto-char pos)
		  (buffer-substring
		   (progn (skip-syntax-spec-backward "w_") (point))
		   (progn (skip-syntax-spec-forward "w_") (point))))))))

(defun scope-html-inner-any-string-attribute (&optional attribute)
  (and (scope-get-syntax ":string")
	   (scope-html-inner-any-attribute attribute)))

(defun scope-html-uplevel-tag (&optional tag)
  (multiple-value-bind (res pos tag1)
	  (uplevel-tag)
	(when res
	  (cond (tag
			 (equalp tag tag1))
			(t tag1)))))

(defvar *scope-html-doctype-alist*
  '(("-//W3C//DTD HTML 4.01//EN"              . "4.01-strict")
	("-//W3C//DTD HTML 4.01 Transitional//EN" . "4.01-transitional")
	("-//W3C//DTD HTML 4.01 Frameset//EN"     . "4.01-frameset")
	("-//W3C//DTD HTML 4.0//EN"               . "4.0-strict")
	("-//W3C//DTD HTML 4.0 Transitional//EN"  . "4.0-transitional")
	("-//W3C//DTD HTML 4.0 Frameset//EN"      . "4.0-frameset")
	("-//W3C//DTD HTML 3.2//EN"               . "3.2")
	))
(defun scope-html-get-doctype (&optional type)
  (when (save-excursion
		  (scan-buffer "<!doctype html public *\"\\([^\"]*\\)\""
					   :case-fold t :regexp t :reverse t))
	(let ((match (match-string 1)) res)
	  (when (setf res (cdr (assoc match *scope-html-doctype-alist* :test 'equalp)))
		(if type (equal type res) res)))))

#|

.xyzzyに書いてhtml+-modeでHTMLを開いて
C-;をあちこちで押しまくると雰囲気がつかめるかも。

(global-set-key #\C-\; 'scope-check)
(add-hook '*html+-mode-hook* 'scope-html-init)
(defun scope-html-init ()
  (setf scope-rules
        (append scope-rules
                '(("any-open-tag" (scope-html-any-open-tag))     ; <ここ>
                  ("any-close-tag" (scope-html-any-close-tag))   ; </ここ>
                  ("html" (scope-html-inner-any-tag "html"))     ; <html>ここ</html>
                  ("head" (scope-html-inner-any-tag "head"))     ; <head>ここ</head>
                  ("body" (scope-html-inner-any-tag "body"))     ; <body>ここ</body>
                  ("ul" (and (scope-html-inner-any-tag "ul")     ; <ul>ここ</ul>
                               (not (scope-get-match "/??ul[^>]*?"))))
                  ("form" (scope-html-inner-any-tag "form"))               ; <form>ここ</form>
                  ("src" (scope-html-inner-any-string-element "src"))      ; <hoge src="ここ">
                  ("type" (scope-html-inner-any-string-element "type"))    ; <hoge type="ここ">
                  ("id" (scope-html-inner-any-string-element "id"))        ; <hoge id="ここ">
                  ("class" (scope-html-inner-any-string-element "class"))  ; <hoge class="ここ">
                  ("anchor-open" (scope-html-any-open-tag "a"))            ; <a ここ>
                  ("anchor-href" (and (scope-html-inner-any-string-element "href") ; <a href="ここ">
                                      (scope-html-any-open-tag "a")))
                  ))))

href src codebase data cite usemap classid longdesc profile action background
の直後の=""のダブルクォートの間でTAB押すとURIを補完

(defun scope-html-uri ()
  (when (and (scope-get-syntax ":string")
			 (find (scope-html-inner-any-attribute)
				   '("href" "src" "codebase" "data" "cite" "usemap" "classid" "longdesc" "profile" "action" "background")
				   :test 'equal))
	(setf *ac-mode-start-marker* (set-marker (make-marker) (1+ (scope-get-beginning-of-string)))
		  *ac-mode-end+1-marker* (set-marker (make-marker) (1+ (scope-get-end-of-string)))
		  *ac-mode-allow-empty-string-modules* '(ac-mode-try-complete-URI)
		  *ac-mode-use-complete+-modules* '(ac-mode-try-complete-URI)
		  *ac-mode-command* '(ac-mode-try-complete-file ac-mode-try-complete-URI))))
(defun ac-mode-scope-html ()
  (add-hook 'ac-mode-pre-completion-hook 'scope-html-uri)
  )
(add-hook '*html+-mode-hook* 'ac-mode-scope-html)

|#


;;; -----------------------------------------------------------------
;;; CSS
;;; -----------------------------------------------------------------
;;; 
;;; selector:defined-class { property:value; }
;;; .class
;;; #id
(export '(scope-css-inner-css
		  scope-css-any-property
		  scope-css-any-value
		  scope-css-any-selector
		  scope-css-any-defined-class
		  scope-css-any-class
		  scope-css-any-id
		  ))

(defun scope-css-inner-css ()
  (and (< (or (scope-get-begin "}" :string nil :comment nil) 0)
		  (or (scope-get-begin "{" :string nil :comment nil) 0))
	   (scope-get-end "}")))

(defun scope-css-any-selector ()
  (not (scope-css-inner-css)))

(defun scope-css-any-defined-class ()
  (and (scope-css-any-selector)
	   (scope-get-match ":[^,\n ]+")))

(defun scope-css-any-class ()
  (and (scope-css-any-selector)
	   (scope-get-match "\\.[^,\n ]+")))

(defun scope-css-any-id ()
  (and (scope-css-any-selector)
	   (scope-get-match "#[^,\n ]+")))

(defun scope-css-any-property ()
  (and (scope-css-inner-css)
	   (or (< (or (scope-get-begin ":" :string nil :comment nil) 0)
			  (scope-get-begin "{" :string nil :comment nil))
		   (< (or (scope-get-begin ":" :string nil :comment nil) 0)
			  (or (scope-get-begin ";" :string nil :comment nil) 0)))
	   (scope-get-end ":")))

(defun scope-css-any-value (&optional property)
  (let ((p (or (scope-get-begin (format nil "~A:" (if (stringp property) property ""))
								:string nil :comment nil) 0)))
	(and (scope-css-inner-css)
		 (< (or (scope-get-begin ";" :string nil :comment nil) 0) p)
		 (< (scope-get-begin "{" :string nil :comment nil) p)
		 (or (scope-get-end ";") (scope-get-end "}")))))

#|
(global-set-key #\C-\; 'scope-check)
(add-hook '*css+-mode-hook* 'scope-css-init)
(defun scope-css-init ()
  (setf scope-rules
        (append scope-rules
                '(("css-inner-css" (scope-css-inner-css))
				  ("css-any-proprety " (scope-css-any-property))
				  ("css-any-value" (scope-css-any-value))
                  ))))
|#
