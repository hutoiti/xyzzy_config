;;; -*- mode: lisp -*-
;;; name:     ac-mode-lisp
;;; version:  2007.04.13
;;; author:   shiro

;; Copyright (C) 1996-2005 Tetsuya Kamei
;; Copyright (C) 2006-2007 shiro
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
;; ac-mode + lisp-mode 用の補完の設定を行う

;; 設定:
;; 
;; ac-mode側からは設定しないので、
;; 初期化ファイルに以下を追加してください。
;; 
;; (require "ac-mode-lisp")

;; 内容:
;; 
;; - in-package delete-package find-package package-use-list内でのパッケージ名
;; - 関数/マクロ定義時に&keyが指定されている場合そのキー
;; - concatenate  make-sequence concatenate merge map *do-completion
;;   do-completion start-selection start-selection dde-request
;;   archiver-dll-version archiver-dll-config-dialog
;;   get-special-folder-location get-next-buffer
;;   の引数
;; - :if-exists :case-fold :if-access-denied :if-exists :share
;;   :if-does-not-exist :encoding :direction :element-type :show
;;   の値
;; - message-box のSTYLE
;;   eval-when のSITUATION
;; - define-condition のPARENT-TYPE
;;   defpackage のOPTIONS
;;   handler-case のエラーのシンボル
;; - with-open-file のOPTIONS
;; - *lisp-popup-completion-list* *popup-completion-list-default* *minibuffer-popup-completion-list*
;;   をsetqまたはsetfしようとする時の値
;; - interactive の:defaultN,:historyN,:titleN
;; - defstruct のOPTIONS
;; - require,load-library 等のライブラリ名
;; - defun/defmacroのlambda-list-keywords
;; - format
;; の補完
;; 
;; - キー(#\C-aなど)
;; の挿入

;; 設定:
;; 
;; abbrev/snippet
;;   &keyの展開は末尾に半角スペースを付けてください。
;;   
;;   e.g.
;;   (":regexp " ":regexp t" nil 0)

;; 履歴:
;; 
;; 2007.03.16
;; - defun/defmacroのlambda-list-keywordsを追加
;; - *ac-mode-lisp-key-list*に関数追加
;; - handler-caseのエラーのシンボルを少し増やした
;; - format追加
;; - キーの挿入を追加
;; 
;; 2007.03.14
;; - ac-mode-lisp-complete-libraryのバグ修正
;; 
;; 2007.03.02
;; - abbrevで定義されている&keyは補完後に展開するようにした
;;   (snippetが導入されていればsnippetの展開)
;; - ライブラリ名の補完追加

;;; Code:

(require "ac-mode")

(provide "ac-mode-lisp")

(in-package "editor")

;; 括弧の中かどうか。
(defun ac-mode-lisp-not-toplevel (&optional (arg 1))
  (save-excursion
	(backward-up-list arg t)))

;; トップレベルかどうか。括弧の中じゃない場合t。こことか。
(defun ac-mode-lisp-toplevel (&optional (arg 1))
  (save-excursion
   (not (backward-up-list arg t))))

;; strが与えられたらトップレベルまでの間にその関数があるかを返す
;; 
;; strなしで呼ばれたら関数名のリストを返す
;; 何度も(ac-mode-lisp-function str)するなら引数無しで呼んだほうがいい
;; 
;; levelが与えられたらその階層分だけ上に
(defun ac-mode-lisp-function (&optional str level)
  (let (res lst (n 0))
	(save-excursion
	  (while (cond ((eq (parse-point-syntax) :string)
					(skip-syntax-spec-backward "^\"")
					(backward-char)
					(backward-up-list 1 t))
				   (t (backward-up-list 1 t)))
		(save-excursion
		  (forward-char)
		  (cond ((and (not level)
					  str)
				 (when (looking-at str)
				   (setf res t)
				   (return)))
				((and level
					  (= n level)
					  str)
				 (when (looking-at str)
				   (setf res t)
				   (return)))
				(t
				 (when (if level (= n level) t)
				   (push (buffer-substring
						  (point)
						  (progn (skip-syntax-spec-forward "w_")
							(point)))
						 lst)))))
		(setf n (1+ n))))
	(if str res lst)))

;; (in-package str) ここは良い
;; (in-package other) ここは駄目
;; 
;; strが与えられなかったらおそらく現在のパッケージを返す
(defun ac-mode-lisp-package (&optional str)
  (let (res not-found)
	(save-excursion
	  (while (not (cond ((scan-buffer "(in-package *\"\\([^\"]*\\)\" *)" :regexp t :reverse t :no-dup t)
						 (setf res (match-string 1))
						 (and (not (ac-mode-get-syntax ":comment"))
							  (not (ac-mode-get-syntax ":string"))))
						(t (setf not-found t) t))))
	  (cond ((and res str (not not-found))
			 (let ((p (find-package res)))
			   (find str (append (list (package-name p)) (package-nicknames p))
					 :test 'equal)))
			((and res (not not-found))
			 (let ((p (find-package res)))
			   (if str
				   (find str (append (list (package-name p)) (package-nicknames p))
						 :test 'equal)
				 (package-name p))))
			(t
			 (let ((p (or *buffer-package* "user")))
			   (cond (str (let ((lst (append (list p) (package-nicknames (find-package p)))))
							(find str lst :test 'equal)))
					 (t p))))))))

;; キャレットがn番目の引数かどうか
;; (の直後が0番目
;; 現在のキャレットの位置で何か入力したら第何引数になるかを考えてnを指定する
;; 
;; nが与えられなかったor負数なら現在何番目の引数かを返す。
;; levelが与えられたらその数だけup-listしてから。
;; (level回上に行けなかったらorlevel回上がトップレベルならnilを返す)
;; 何度も(ac-mode-lisp-nth-arg n)するなら引数無しで呼んでfindした方が良いと思う。
(defun ac-mode-lisp-nth-arg (&optional n level)
  (labels ((count ()
			 (cond ((syntax-open-p (preceding-char)) -1)
				   (t (backward-sexp) (+ 1 (count))))))
	(save-excursion
	  (when level
		(unless (up-list level t)
		  (return-from ac-mode-lisp-nth-arg))
		(when (ac-mode-lisp-toplevel)
		  (return-from ac-mode-lisp-nth-arg)))
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
		(when level
		  (setf number (1- number)))
		(if (and (numberp n) (<= 0 n)) (= number n) number)))))

;; n番目までの引数をリストで返す
;; (の直後が0番目
(defun ac-mode-lisp-get-nth-arg (n)
  (save-excursion
	(when (backward-up-list 1 t)
	  (down-list 1 t)
	  (let (lst)
		(dotimes (x (1+ n) lst)
		  (push (string-trim
				 " \t\n"
				 (buffer-substring
				  (point)
				  (progn (forward-sexp 1 t) (point))))
				lst))
		(nreverse lst)))))

;; エラーのシンボルを返す (handler-case用?)
(defun ac-mode-lisp-get-conditions ()
  (let (lst)
	(do-symbols (sym)
	  (and (not (fboundp sym))
		   (not (boundp sym))
		   (subtypep sym 'condition)
		   (push sym lst)))
	lst))

;; 関数の引数を返す
(defvar *ac-mode-lisp-key-list* ;;; 宣言された引数と実際の引数が異なるので
  '((pushnew ITEM PLACE &key :test :test-not :key)
	(scan-buffer PATTERN &key :no-dup :case-fold :reverse :tail :regexp :limit :left-bound :right-bound :last-match)
	(create-shortcut SRC DEST &key :description :arguments :working-directory :show)
	(create-shortcut-to-desktop PATH &key :description :arguments :working-directory :show)
	(load-library FILENAME &key :no-suffix :if-does-not-exist :no-message)
	(substitute NEWITEM OLDITEM SEQUENCE &key :from-end :test :test-not :start :end :count :key)
	(substitute-if NEWITEM TEST SEQUENCE &key :from-end :start :end :count :key)
	(substitute-if-not NEWITEM TEST SEQUENCE &key :from-end :start :end :count :key)
	(nsubstitute-if-not NEWITEM TEST SEQUENCE &key :from-end :start :end :count :key)
	(count-if-not TEST SEQUENCE &key :from-end :start :end :key)
	(glob PATH &key absolute callback)
	(sort SEQUENCE PREDICATE &key :key)
	;; このへんからは定義に&keyがないので (builtin.l)
	(rename-file file new-name &key :if-exists :if-access-denied)
	(copy-file file new-file &key :if-exists :copy-attributes :if-access-denied)
	(file-name-dialog &key :char-encoding :eol-code :filter :filter-index :title :default :extension :save :multiple :must-exist :explorer :hide-read-only :initial-directory)
	(directory-name-dialog &key :title :default)
	(make-iso2022-encoding name display-name &key :g0 :g1 :g2 :g3 :ascii-eol :ascii-control :7bits :locking-shift :short-form :no-escape :cjk :use-cns11643 :vender)
	(make-utf16-encoding name display-name &key :signature :byte-order :windows :cjk)
	(make-utf8-encoding name display-name &key :signature :windows :cjk)
	(make-utf7-encoding name display-name &key :windows :imap4 :white :set-o :cjk)
	(make-utf5-encoding name display-name &key :windows :imap4 :white :set-o :cjk)
	(parse-char-encoding-string accept-char-encoding string &key :start :end)
	))
;; from help.l
(defun ac-mode-lisp-get-args (symbol)
  (let ((def (symbol-function symbol))
		args a)
	(cond ((setf a (find symbol *ac-mode-lisp-key-list* :key 'car))
		   (setf args (cdr a)))
		  ((si:*builtin-function-p def)
		   (setq args (get symbol 'si::builtin-function-argument)))
		  (t
		   (if (si:*closurep def)
			   (setq def (si:closure-body def)))
		   (when (or (eq (safe-car def) 'lambda)
					 (eq (safe-car def) 'macro))
			 (setq args (safe-cadr def)))))
	args))

;;; -----------------------------------------------------------------
;;; complete
;;; -----------------------------------------------------------------

;;; complete package name
(defun ac-mode-lisp-complete-package-name ()
  (when (and (ac-mode-get-syntax ":string")
			 (find (first (ac-mode-lisp-function nil 0))
				   '("in-package" "delete-package" "find-package" "package-use-list")
				   :test 'equal)
			 (ac-mode-lisp-nth-arg 1))
	(setf *ac-mode-start-marker* ;; ここから
		  (set-marker (make-marker) (1+ (ac-mode-get-beginning-of-string)))
		  *ac-mode-end+1-marker* ;; ここまでの文字を補完対象とみなす
		  (set-marker (make-marker) (1+ (ac-mode-get-end-of-string)))
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

;;; complete &key
(defun ac-mode-lisp-complete-key-after ()
  (when (and (find *ac-mode-this-command*
				   '(ac-mode-self-insert
					 ac-mode-return
					 ac-mode-complete-string))
			 (eq *ac-mode-complete-module* 'ac-mode-try-complete-list))
	(let ((str (save-excursion
				 (backward-char)
				 (buffer-substring
				  (progn (skip-syntax-spec-backward "w_") (point))
				  (progn (skip-syntax-spec-forward "w_") (1+ (point)))))))
	  (cond ((gethash str *local-abbrev-table*)
			 (cond ((modulep "snippet")
					(let ((fn (intern "snippet-expand" "editor")))
					  (setf *this-command* fn)
					  (funcall fn)))
				   (t (expand-abbrev)))))))
  (delete-hook '*ac-mode-complete-hook* 'ac-mode-lisp-complete-key-after))
(defun ac-mode-lisp-complete-key ()
  (when (ac-mode-lisp-not-toplevel)
	(let ((pkg (ac-mode-lisp-package))
		  func arg pos arg-list position old)
	  (when (and (find-package pkg)
				 (setf func (find-symbol (first (ac-mode-lisp-function nil 0)) pkg))
				 (fboundp func)
				 (progn
				   (setf arg (ac-mode-lisp-get-args func)
						 start (position &key arg))
				   (numberp start))
				 (progn
				   ;; &key があるのに &rest もある関数がいくつかあるのでその対策
				   (when (find &rest arg)
					 (setf start (- start 2))
					 (setf arg (nthcdr 2 arg)))
				   (incf start)
				   (setf pos (ac-mode-lisp-nth-arg))
				   (= 0 (rem (- pos start) 2)))
				 (progn
				   (setf arg-list (mapcar #'(lambda (x)
											  (cond ((and (consp x)
														  (consp (cdr x)))
													 (format nil ":~A "
															 (first x)))
													((and (consp x)
														  (stringp (cdr x)))
													 (cons (format nil ":~A " (first x)) (cdr x)))
													((format nil ":~A " x))))
										  (nthcdr start arg))
						 old (ac-mode-lisp-get-nth-arg pos))
				   ;; :test と :test-not は排他的
				   (flet ((key (x)
							(if (consp x) (car x) x)))
					 (cond ((find ":test" old :test 'equal :key #'key)
							(setf arg-list (remove ":test-not " arg-list :test 'equal :key #'key)))
						   ((find ":test-not" old :test 'equal :key #'key)
							(setf arg-list (remove ":test " arg-list :test 'equal :key #'key)))))
				   (<= start pos (+ start (* 2 (1- (length arg-list))))))
				 (setf arg-list (set-difference
								 arg-list old
								 :test #'(lambda (x y)
										   (equal (string-right-trim " " (if (consp x) (car x) x)) y)))))
		(add-hook '*ac-mode-complete-hook* 'ac-mode-lisp-complete-key-after)
		(setf *ac-mode-start-marker*
			  (set-marker (make-marker)
						  (save-excursion (skip-syntax-spec-backward "w_") (point)))
			  *ac-mode-end+1-marker*
			  (set-marker (make-marker)
						  (save-excursion (skip-syntax-spec-forward "w_") (forward-char) (point)))
			  *ac-mode-command* '(ac-mode-try-indent ac-mode-try-expand-snippet ac-mode-try-complete-list)
			  *ac-mode-allow-empty-string-modules* '(ac-mode-try-complete-list)
			  *ac-mode-use-complete+-modules* '(ac-mode-try-complete-list)
			  *ac-mode-complete-user-list* arg-list
			  *ac-mode-complete-type-list* "Key")))))

;;; complete nth argument
(defvar *ac-mode-lisp-complete-nth-arg*
  ;; function          n name   candidate
  `((read-registry     3 "Root" ("nil" ":current-user" ":classes-root" ":local-machine" ":users"))
	(list-registry-key 2 "Root" ("nil" ":current-user" ":classes-root" ":local-machine" ":users"))
;; ↑とどちらかで。
;; 	(read-registry   3 "Root" (("nil"            . "HKCU\\Software\\Free Software\\Xyzzy")
;; 							   (":current-user"  . "HKEY_CURRENT_USER")
;; 							   (":classes-root"  . "HKEY_CLASSES_ROOT")
;; 							   (":local-machine" . "HKEY_LOCAL_MACHINE")
;; 							   (":users"         . "HKEY_USERS")))
;; 	(list-registry-key 2 "Root" (("nil"            . "HKCU\\Software\\Free Software\\Xyzzy")
;; 								 (":current-user"  . "HKEY_CURRENT_USER")
;; 								 (":classes-root"  . "HKEY_CLASSES_ROOT")
;; 								 (":local-machine" . "HKEY_LOCAL_MACHINE")
;; 								 (":users"         . "HKEY_USERS")))
	(make-sequence   1 "Type"    ("'list" "'vector" "'simple-vector" "'string" "'simple-string"))
	(concatenate     1 "Result Type" ("'list" "'vector" "'simple-vector" "'string" "'simple-string"))
	(merge           1 "Result Type" ("'list" "'vector" "'simple-vector" "'string" "'simple-string"))
	(map             1 "Result Type" ("'list" "'vector" "'simple-vector" "'string" "'simple-string" "nil"))
	(*do-completion  2 "Completion Type" (":symbol-name" ":function-name" ":command-name" ":variable-name" ":non-trivial-symbol-name" ":exist-file-name" ":file-name" ":file-name-list" ":directory-name" ":buffer-name" ":exist-buffer-name" ":list" ":list-ignore-case"))
	(do-completion   3 "Completion Type" (":symbol-name" ":function-name" ":command-name" ":variable-name" ":non-trivial-symbol-name" ":exist-file-name" ":file-name" ":file-name-list" ":directory-name" ":buffer-name" ":exist-buffer-name" ":list" ":list-ignore-case"))
	(start-selection 1 "Selection Type" (("1" . "line") ("2" . "char") ("3" . "rectangle")))
	(start-selection 2 "Temporary?" ("t" "nil"))
	(dde-request     3 "Result Type" (":text" ":binary" ":int8" ":int16" ":int32"))
	(archiver-dll-version        1 "DLL name" ,(mapcar #'(lambda (x) (concat ":" (symbol-name x))) *archiver-dll-list*))
	(archiver-dll-config-dialog  1 "DLL name" ,(mapcar #'(lambda (x) (concat ":" (symbol-name x))) *archiver-dll-list*))
	(get-special-folder-location 1 "Place" (":start-menu" ":send-to" ":desktop" ":personal" ":programs" ":recent" ":startup" ":templates"))
	(get-next-buffer 1 "Buffer" (":top" ":bottom"))
	))
(defun ac-mode-lisp-complete-nth-arg ()
  (when (ac-mode-lisp-not-toplevel)
	(let* ((func (first (ac-mode-lisp-function nil 0)))
		   (nth (ac-mode-lisp-nth-arg))
		   (res (find-if #'(lambda (x)
							 (and (equal func (symbol-name (first x)))
								  (equal nth (second x))))
						 *ac-mode-lisp-complete-nth-arg*)))
	  (when res
		(push 'ac-mode-try-complete-list *ac-mode-use-syntax-modules*)
		(setf *ac-mode-start-marker*
			  (set-marker (make-marker)
						  (save-excursion (skip-syntax-spec-backward "w_") (point)))
			  *ac-mode-end+1-marker*
			  (set-marker (make-marker)
						  (save-excursion (skip-syntax-spec-forward "w_") (forward-char) (point)))
			  *ac-mode-command* '(ac-mode-try-indent ac-mode-try-expand-snippet ac-mode-try-complete-list)
			  *ac-mode-allow-empty-string-modules* '(ac-mode-try-complete-list)
			  *ac-mode-use-complete+-modules* '(ac-mode-try-complete-list)
			  *ac-mode-complete-user-list* (fourth res)
			  *ac-mode-complete-type-list* (third res))))))

;;; complete value of key
(defvar *ac-mode-lisp-complete-value-of-key*
  ;; key        function           candidate
  '((:if-exists (create-directory) (":error" ":skip"))
	(:case-fold nil (":smart" "t" "nil"))
	(:if-access-denied nil (":error" ":skip" ":force"))
	(:if-exists (rename-file copy-file) (":error" ":skip" ":overwrite" ":newer"))
	(:if-exists (open) (":error" ":skip" ":append" ":overwrite" ":new-version" ":supersede" ":rename" ":rename-and-delete"))
	(:if-does-not-exist (delete-directory delete-file) (":error" ":skip"))
	(:if-does-not-exist (mc-load-library si:*load-library) (":error"))
	(:if-does-not-exist (open) (":error" ":create"))
	(:encoding (open) (":binary" ":text" ":canonical" ":raw"))
	(:direction nil (":input" ":output" ":io" ":probe"))
	(:element-type (make-vector) ("t" "'character" "'base-character" "'standard-char" "'extended-character"))
	(:show (call-process) (":show" ":no-active" ":minimize" ":maximize" ":hide"))
	(:show (*create-shortcut create-shortcut create-shortcut-to-desktop) (":show" ":maximize" ":minimize"))
	(:share nil (":read" ":write" ":read-write"))))
(defun ac-mode-lisp-complete-value-of-key ()
  (when (ac-mode-lisp-not-toplevel)
	(let* ((pos (ac-mode-lisp-nth-arg))
		   arg-just-before)
	  (unless (<= 2 pos)
		(return-from ac-mode-lisp-complete-value-of-key))
	  (let* ((key (first (last (ac-mode-lisp-get-nth-arg (1- pos)))))
;; 			 (func (cond ((ac-mode-lisp-function "with-open-file" 1)
;; 						  '("open"))
;; 						 (t (first (ac-mode-lisp-function nil 0)))))
			 (func (first (ac-mode-lisp-function nil 0)))
			 (res (find-if #'(lambda (x)
							   (and (equal key (format nil ":~a" (first x)))
									(or (not (second x))
										(find func (second x) :key 'symbol-name :test 'equal))))
						   *ac-mode-lisp-complete-value-of-key*)))
		(when res
		  (push 'ac-mode-try-complete-list *ac-mode-use-syntax-modules*)
		  (setf *ac-mode-start-marker*
				(set-marker (make-marker)
							(save-excursion (skip-syntax-spec-backward "w_") (point)))
				*ac-mode-end+1-marker*
				(set-marker (make-marker)
							(save-excursion (skip-syntax-spec-forward "w_") (forward-char) (point)))
				*ac-mode-command* '(ac-mode-try-indent ac-mode-try-complete-list)
				*ac-mode-allow-empty-string-modules* '(ac-mode-try-complete-list)
				*ac-mode-use-complete+-modules* '(ac-mode-try-complete-list)
				*ac-mode-complete-user-list* (third res)
				*ac-mode-complete-type-list* (concat "Value of " key)))))))

;;; complete by paret
(defvar *ac-mode-lisp-complete-by-parent*
  ;; parent-function nth name
  `((message-box     3   "Styles" (":ok" ":ok-cancel" ":yes-no" ":yes-no-cancel" ":abort-retry-ignore" ":information" ":exclamation" ":question" ":button1" ":button2" ":button3" ":button4" ":button5"))
	;; 説明有版。↑とどっちかで。popup-stringが等幅フォントじゃないとズレて汚い。
	;; 	(message-box     3   "Styles" ((":ok"                 . "[OK] を表示します。")
	;; 								   (":ok-cancel"          . "[OK][キャンセル] を表示します。")
	;; 								   (":yes-no"             . "[はい][いいえ] を表示します。")
	;; 								   (":yes-no-cancel"      . "[はい][いいえ][キャンセル] を表示します。")
	;; 								   (":abort-retry-ignore" . "[中止][再試行][無視] を表示します。")
	;; 								   (":information"        . "(i) インフォメーションマークを表示します。")
	;; 								   (":exclamation"        . "(!) 感嘆符を表示します。")
	;; 								   (":question"           . "(?) 疑問符を表示します。")
	;; 								   (":button1"            . "ボタン 1 をデフォルト選択にします。")
	;; 								   (":button2"            . "ボタン 2 をデフォルト選択にします。")
	;; 								   (":button3"            . "ボタン 3 をデフォルト選択にします。")
	;; 								   (":button4"            . "ボタン 4 をデフォルト選択にします。")
	;; 								   (":button5"            . "ボタン 5 をデフォルト選択にします。")))
	(eval-when        1  "Situation" (":compile-toplevel" ":load-toplevel" ":execute"))
	(defun            2  "lambda list keyword" ,lambda-list-keywords)
	(defmacro         2  "lambda list keyword" ,lambda-list-keywords)
	))
(defun ac-mode-lisp-complete-by-parent ()
  (when (ac-mode-lisp-not-toplevel 2)
	(let ((func (first (ac-mode-lisp-function nil 1)))
		  (pos (ac-mode-lisp-nth-arg nil 1))
		  res)
	  (when (and func pos
				 (setf res (find-if #'(lambda (x)
										(and (equal (symbol-name (first x)) func)
											 (= pos (second x))))
									*ac-mode-lisp-complete-by-parent*)))
		(push 'ac-mode-try-complete-list *ac-mode-use-syntax-modules*)
		(setf *ac-mode-start-marker*
			  (set-marker (make-marker)
						  (save-excursion (skip-syntax-spec-backward "w_") (point)))
			  *ac-mode-end+1-marker*
			  (set-marker (make-marker)
						  (save-excursion (skip-syntax-spec-forward "w_") (forward-char) (point)))
			  *ac-mode-command* '(ac-mode-try-indent ac-mode-try-expand-snippet ac-mode-try-complete-list)
			  *ac-mode-allow-empty-string-modules* '(ac-mode-try-complete-list)
			  *ac-mode-use-complete+-modules* '(ac-mode-try-complete-list)
			  *ac-mode-complete-user-list* (fourth res)
			  *ac-mode-complete-type-list* (third res))))))

;;; complete by parent1
(defvar *ac-mode-lisp-complete-by-parent1*
  `(("handler-case"     "Condition" 2 ,(mapcar #'(lambda (x) (format nil "~a " x))
											   (append (ac-mode-lisp-get-conditions)
													   '(error
														 quit
														 check-type-error
														 plain-error
														 xml-http-request-error
														 spi-error
														 ))))
	("defpackage"       "Option"    2 (":external-size " ":internal-size " ":export " ":intern " ":import-from " ":use " ":shadow " ":shadowing-import-from "))
	("define-condition" "Option"    4 (":documentation " ":report " ":important "))
	))
(defun ac-mode-lisp-complete-by-parent1 ()
  (when (and (ac-mode-lisp-not-toplevel)
			 (ac-mode-lisp-nth-arg 0))
	(let ((res (find (first (ac-mode-lisp-function nil 1)) *ac-mode-lisp-complete-by-parent1*
					 :test 'equal :key 'car)))
	  (when (and res
				 (let ((pos (ac-mode-lisp-nth-arg nil 1)))
				   (and pos
						(<= (third res) pos))))
		(push 'ac-mode-try-complete-list *ac-mode-use-syntax-modules*)
		(setf *ac-mode-start-marker*
			  (set-marker (make-marker)
						  (save-excursion (skip-syntax-spec-backward "w_") (point)))
			  *ac-mode-end+1-marker*
			  (set-marker (make-marker)
						  (save-excursion (skip-syntax-spec-forward "w_") (forward-char) (point)))
			  *ac-mode-command* '(ac-mode-try-indent ac-mode-try-expand-snippet ac-mode-try-complete-list)
			  *ac-mode-allow-empty-string-modules* '(ac-mode-try-complete-list)
			  *ac-mode-use-complete+-modules* '(ac-mode-try-complete-list)
			  *ac-mode-complete-user-list* (fourth res)
			  *ac-mode-complete-type-list* (second res))))))

;;; complete defstruct option
(defun ac-mode-lisp-complete-defstruct ()
  (when (and (ac-mode-lisp-not-toplevel)
			 (ac-mode-lisp-nth-arg 0)
			 (ac-mode-lisp-nth-arg 1 2)
			 (<= 1 (ac-mode-lisp-nth-arg nil 1))
			 (ac-mode-lisp-function "defstruct" 2))
	(push 'ac-mode-try-complete-list *ac-mode-use-syntax-modules*)
	(setf *ac-mode-start-marker*
		  (set-marker (make-marker)
					  (save-excursion (skip-syntax-spec-backward "w_") (point)))
		  *ac-mode-end+1-marker*
		  (set-marker (make-marker)
					  (save-excursion (skip-syntax-spec-forward "w_") (forward-char) (point)))
		  *ac-mode-command* '(ac-mode-try-indent ac-mode-try-expand-snippet ac-mode-try-complete-list)
		  *ac-mode-allow-empty-string-modules* '(ac-mode-try-complete-list)
		  *ac-mode-use-complete+-modules* '(ac-mode-try-complete-list)
		  *ac-mode-complete-user-list* '(":conc-name " ":constructor " ":copier " ":predicate " ":include " ":print-function ")
		  *ac-mode-complete-type-list* "Option")))

;;; complete key at with-open-file
(defun ac-mode-lisp-complete-key-at-with-open-file ()
  (when (and (ac-mode-lisp-not-toplevel)
			 (ac-mode-lisp-nth-arg 1 1)
			 (ac-mode-lisp-function "with-open-file" 1))
	(let ((pos (ac-mode-lisp-nth-arg))
		  (args (ac-mode-lisp-get-nth-arg (1- (ac-mode-lisp-nth-arg))))
		  key type lst)
	  (when (<= 2 pos)
		(cond ((evenp pos)
			   (setf lst (set-difference
						  (mapcar #'(lambda (x) (format nil ":~a " x))
								  (cddr (ac-mode-lisp-get-args 'open))) args
						  :test #'(lambda (x y)
									(equal (string-right-trim " " (if (consp x) (car x) x)) y)))
					 type "Key"))
			  (t
			   (setf key (first (last args)))
			   (let ((res (find-if #'(lambda (x)
									   (and (equal key (format nil ":~a" (first x)))
											(or (not (second x))
												(find "open" (second x) :key 'symbol-name :test 'equal))))
								   *ac-mode-lisp-complete-value-of-key*)))
				 (when res
				   (setf lst (third res)
						 type (concat "Value of " key))))))
		(when (and lst type)
		  (add-hook '*ac-mode-complete-hook* 'ac-mode-lisp-complete-key-after)
		  (push 'ac-mode-try-complete-list *ac-mode-use-syntax-modules*)
		  (setf *ac-mode-start-marker*
				(set-marker (make-marker)
							(save-excursion (skip-syntax-spec-backward "w_") (point)))
				*ac-mode-end+1-marker*
				(set-marker (make-marker)
							(save-excursion (skip-syntax-spec-forward "w_") (forward-char) (point)))
				*ac-mode-command* '(ac-mode-try-indent ac-mode-try-complete-list)
				*ac-mode-allow-empty-string-modules* '(ac-mode-try-complete-list)
				*ac-mode-use-complete+-modules* '(ac-mode-try-complete-list)
				*ac-mode-complete-user-list* lst
				*ac-mode-complete-type-list* type))))))

;;; complete popup?
(defun ac-mode-lisp-complete-popup ()
  (when (and (ac-mode-lisp-not-toplevel)
			 (ac-mode-lisp-nth-arg 2))
	(let ((lst (ac-mode-lisp-get-nth-arg 1)))
	  (when (and (find (first lst) '("setq" "setf") :test 'equal)
				 (find (second lst) '("*lisp-popup-completion-list*"
									  "*popup-completion-list-default*"
									  "*minibuffer-popup-completion-list*")
					   :test 'equal))
		(setf *ac-mode-start-marker*
			  (set-marker (make-marker)
						  (save-excursion (skip-syntax-spec-backward "w_") (point)))
			  *ac-mode-end+1-marker*
			  (set-marker (make-marker)
						  (save-excursion (skip-syntax-spec-forward "w_") (forward-char) (point)))
			  *ac-mode-command* '(ac-mode-try-indent ac-mode-try-expand-snippet ac-mode-try-complete-list)
			  *ac-mode-allow-empty-string-modules* '(ac-mode-try-complete-list)
			  *ac-mode-use-complete+-modules* '(ac-mode-try-complete-list)
			  *ac-mode-complete-user-list* '(":always" ":never" "nil")
			  *ac-mode-complete-type-list* "Use popup-list?")))))

;;; complete argument of interactive
(defun ac-mode-lisp-complete-interactive ()
  (when (and (ac-mode-lisp-not-toplevel)
			 (ac-mode-lisp-function "interactive" 0))
	(let ((pos (ac-mode-lisp-nth-arg))
		  args (default 0) (history 0) (title 0))
	  (when (and (<= 2 pos) (evenp pos))
		(setf args (ac-mode-lisp-get-nth-arg (1- pos)))
		(dolist (arg args)
		  (cond ((string-match ":default\\([0-9]+\\)" arg)
				 (let ((n (parse-integer (match-string 1))))
				   (when (< default (1+ n))
					 (setf default (1+ n)))))
				((string-match ":history\\([0-9]+\\)" arg)
				 (let ((n (parse-integer (match-string 1))))
				   (when (< history (1+ n))
					 (setf history (1+ n)))))
				((string-match ":title\\([0-9]+\\)" arg)
				 (let ((n (parse-integer (match-string 1))))
				   (when (< title (1+ n))
					 (setf title (1+ n)))))))
		(push 'ac-mode-try-complete-list *ac-mode-use-syntax-modules*)
		(setf *ac-mode-start-marker*
			  (set-marker (make-marker)
						  (save-excursion (skip-syntax-spec-backward "w_") (point)))
			  *ac-mode-end+1-marker*
			  (set-marker (make-marker)
						  (save-excursion (skip-syntax-spec-forward "w_") (forward-char) (point)))
			  *ac-mode-command* '(ac-mode-try-indent ac-mode-try-expand-snippet ac-mode-try-complete-list)
			  *ac-mode-allow-empty-string-modules* '(ac-mode-try-complete-list)
			  *ac-mode-use-complete+-modules* '(ac-mode-try-complete-list)
			  *ac-mode-complete-user-list*
			  (list (format nil ":default~D " default)
					(format nil ":history~D " history)
					(format nil ":title~D " title))
			  *ac-mode-complete-type-list* "Interactive")))))

;;; complete library name
(defvar *ac-mode-lisp-complete-library-list*
  '((require 1)
	(load-library 1)
	(mc-load-library 1)
	(autoload 2)
	(mc-autoload 2)))
(defun ac-mode-lisp-complete-library ()
  (when (ac-mode-get-syntax ":string")
	(let ((res (find (car (ac-mode-lisp-function nil 0))
					 *ac-mode-lisp-complete-library-list*
					 :key #'(lambda (x) (symbol-name (car x)))
					 :test 'equal))
		  lst)
	  (when (and res (ac-mode-lisp-nth-arg (second res)))
		(dolist (path *load-path*)
		  (setf lst (union lst (mapcar 'pathname-name (directory path :absolute t :wild "*.l" :file-only t))
						   :test 'equal)))
		(setf *ac-mode-start-marker*
			  (set-marker (make-marker) (1+ (ac-mode-get-beginning-of-string)))
			  *ac-mode-end+1-marker*
			  (set-marker (make-marker) (1+ (ac-mode-get-end-of-string)))
			  *ac-mode-command* '(ac-mode-try-indent ac-mode-try-expand-snippet ac-mode-try-complete-list)
			  *ac-mode-allow-empty-string-modules* '(ac-mode-try-complete-list)
			  *ac-mode-use-complete+-modules* '(ac-mode-try-complete-list)
			  *ac-mode-complete-user-list* lst
			  *ac-mode-complete-type-list* "Library")))))

;;; complete format control string
(defvar *ac-mode-lisp-complete-format-control-string-function-list*
  '((msgbox 1)
	(message 1)
	(format 2)
	(y-or-n-p 1)
	(yes-or-no-p 1)
	(no-or-yes-p 1)
	(yes-no-or-cancel-p 1)
	(minibuffer-prompt 1)
	(minibuffer-message 1)))
(defvar *ac-mode-lisp-complete-format-control-string-list*
  '("~a" "~s" "~%" "~&" "~|" "~~" "~t" "~*" "~?" "~d"
	"~b" "~o" "~x" "~r" "~p" "~c" "~f" "~e" "~g" "~$"
	"~(" "~)" "~[" "~]" "~{" "~}" "~^"))
(defvar *ac-mode-lisp-complete-format-control-string-pair-list*
  '(("~(" "~)")
	("~[" "~]")
	("~{" "~}")))
(defun ac-mode-lisp-complete-format-control-string-after ()
  (when (and (find *ac-mode-this-command*
				   '(ac-mode-self-insert
					 ac-mode-return
					 ac-mode-complete-string))
			 (eq *ac-mode-complete-module* 'ac-mode-try-complete-list))
	(dolist (x *ac-mode-lisp-complete-format-control-string-pair-list*)
	  (when (looking-back (first x))
		(save-excursion
		  (insert (second x)))
		(return))))
  (delete-hook '*ac-mode-complete-hook* 'ac-mode-lisp-complete-format-control-string-after))
(defun ac-mode-lisp-complete-format-control-string ()
  (when (ac-mode-get-syntax ":string")
	(let ((res (find (car (ac-mode-lisp-function nil 0))
					 *ac-mode-lisp-complete-format-control-string-function-list*
					 :key #'(lambda (x) (symbol-name (car x)))
					 :test 'equal)))
	  (when (and res (ac-mode-lisp-nth-arg (second res)))
		(add-hook '*ac-mode-complete-hook* 'ac-mode-lisp-complete-format-control-string-after)
		(setf *ac-mode-start-marker* 
			  (set-marker (make-marker)
						  (save-excursion (skip-chars-backward "~") (point)))
			  *ac-mode-end+1-marker* (save-excursion (forward-char) (point-marker))
			  *ac-mode-command* '(ac-mode-try-complete-list)
			  *ac-mode-allow-empty-string-modules* '(ac-mode-try-complete-list)
			  *ac-mode-use-complete+-modules* '(ac-mode-try-complete-list)
			  *ac-mode-complete-user-list* *ac-mode-lisp-complete-format-control-string-list*
			  *ac-mode-complete-type-list* "Format Control String")))))

;;; insert key sequence
(defvar *ac-mode-lisp-insert-key-sequence-list*
  '((global-set-key 1 *global-keymap*)
	(define-key 2 1)
	(undefine-key 2 1)
	(local-set-key 1 nil)
	(local-unset-key 1 nil)))
(defun ac-mode-lisp-insert-key-sequence ()
  (when (ac-mode-lisp-not-toplevel)
	(let ((res (find (car (ac-mode-lisp-function nil 0))
					 *ac-mode-lisp-insert-key-sequence-list*
					 :key #'(lambda (x) (symbol-name (car x)))
					 :test 'equal))
		  key)
	  (when (and res (ac-mode-lisp-nth-arg (second res)))
		(setf key
			  (mapcar (lambda (x) (format nil "~a~s" (if (consp x) "'" "") x))
					  (cond ((numberp (third res))
							 (let* ((n (third res))
									(keymap (find-symbol
											 (nth n (ac-mode-lisp-get-nth-arg n))
											 (ac-mode-lisp-package))))
							   (when (and keymap (keymapp (eval keymap)))
								 (list (read-key-sequence (eval keymap) nil nil "Key: ")))))
							((keymapp (third res))
							 (when (keymapp (eval (third res)))
							   (list (read-key-sequence (eval (third res)) nil nil "Key: "))))
							(t (interactive-read-key-sequence "Key: ")))))
		(setf *ac-mode-start-marker*
			  (set-marker (make-marker)
						  (save-excursion (skip-syntax-spec-backward "w_") (point)))
			  *ac-mode-end+1-marker*
			  (set-marker (make-marker)
						  (save-excursion (skip-syntax-spec-forward "w_") (forward-char) (point)))
			  *ac-mode-command* '(ac-mode-try-indent ac-mode-try-complete-list)
			  *ac-mode-allow-empty-string-modules* '(ac-mode-try-complete-list)
			  *ac-mode-use-complete+-modules* '(ac-mode-try-complete-list)
			  *ac-mode-complete-user-list* key
			  *ac-mode-complete-type-list* "Key")))))

(defun ac-mode-lisp-init ()
  (dolist (symb '(ac-mode-lisp-complete-package-name
				  ac-mode-lisp-complete-key
				  ac-mode-lisp-complete-nth-arg
				  ac-mode-lisp-complete-value-of-key
				  ac-mode-lisp-complete-by-parent
				  ac-mode-lisp-complete-by-parent1
				  ac-mode-lisp-complete-key-at-with-open-file
				  ac-mode-lisp-complete-popup
				  ac-mode-lisp-complete-interactive
				  ac-mode-lisp-complete-defstruct
				  ac-mode-lisp-complete-library
				  ac-mode-lisp-complete-format-control-string
				  ac-mode-lisp-insert-key-sequence))
	(add-hook 'ac-mode-pre-completion-hook symb)))

(add-hook '*lisp-mode-hook* 'ac-mode-lisp-init)
(add-hook '*lisp-interaction-mode-hook* 'ac-mode-lisp-init)

#|
改良の余地がありそうなあたり(でも面倒)

- interactive (第一引数の文字列)
- compile-regexp-keyword-list
- with-package-iterator

|#
;;; ac-mode-lisp.l ends here
