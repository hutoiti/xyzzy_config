;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   -*- Mode: Lisp -*-
;;   Last Modified: Sun, 29 Jul 2007 07:19:50
;;   Version: 1.0.3.0
;;   Name: todo
;;   Author: amefura
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Copyright (c) 2006, amefura
;;  All rights reserved.
;;
;;  Redistribution and use in source and binary forms, with or without
;;  modification, are permitted provided that the following conditions are
;;  met:
;;
;;  * Redistributions of source code must retain the above copyright notice,
;;  this list of conditions and the following disclaimer.
;;
;;  * Redistributions in binary form must reproduce the above copyright
;;  notice, this list of conditions and the following disclaimer in the
;;  documentation and/or other materials provided with the distribution.
;;
;;  * Neither the name of the <ORGANIZATION> nor the names of its
;;  contributors may be used to endorse or promote products derived from
;;  this software without specific prior written permission.
;;
;;  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
;;  IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
;;  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
;;  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
;;  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
;;  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
;;  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
;;  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
;;  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
;;  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;;  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; tw-mode の todo だけを抜き出したモードです。
;; tw-mode は結構重いので、todo だけを使いたい人用です。
;;
;;
;; setting
;; (require "todo")
;; 例 キーバインド
;; (global-set-key '(#\C-, #\,) 'todo::todo)
;;
;; *TODO* buffer で
;;  ? z /   todo-level-of-achievement
;;  i       更新
;;  q       閉じる
;;  RET     ファイルを開いて直接編集
;;  m       新しく Todo を作る。
;;
;; *tloa* buffer で
;;  SPC     グループ分けしたものを表示 toggle
;;  m       新しく Todo を作る。
;;  RET     ファイルを開いて直接編集
;;  q       閉じる
;;
;; バグ等発見されましたら以下まで報告下さい。
;; amefura@gmail.com
;;  by amefura
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package "todo")
	(defpackage "todo"
	  (:use "lisp" "editor" "user")
	  (:nicknames "td"))
	))

(provide "todo")
(in-package "todo")
(export '(todo))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar *done-max* 10
  "済み Done を表示する最大値 ")

(defvar *todo-memo-day-length* 60
  "memo 覚書は適当に消えて欲しいのでどのくらいまでか指定 default: 60 日 ")
; 一枚のファイルなのでどこでもいいか
(defvar *base-dir* "~/ToDo/"
  " メモを貯める基本のフォルダ ")

(defvar *todo-file* ".todo")
(defvar *todo-buffer* "*TODO*")

(defvar *todo-mark-list* '("!" "+" "-" "." "~" "x" "@"))

(defvar *todo-format* "%Y-%m-%d"
  "memo をとった時に ToDo 用の日付 ")

(defvar *schedule-margin-before* 7
  " 予定の表示し出す日の長さ default: 7 日前から表示 ")

(defvar *schedule-margin-over* 1
  " 予定の表示を止める日の長さ default:1 日後まで表示 ")

(defvar *index-todo-week* t
  "Todo の行頭に入れる曜日の表示 t: English nil: Japan ")

(defvar *paren-day* '("\\[" "\\]")
  "ID を囲む文字  :Regexp")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun paren(lst &optional pos);list
  "t: Begin  nil: End"
  (flet((paren(fab)
		  (format nil"~{~A~}" (split-string fab #\\))))
	(if pos(paren (car lst))(paren(cadr lst)))))

(defun str-paren(str lst)
  (concat (paren lst t) str (paren lst)))

(defun nowline-string()
  (save-excursion
	(buffer-substring(progn(goto-bol)(point))
					 (progn(goto-eol)(point)))))

(defun todo-sort(list)
  (let((lst list))
	(labels((properties(x)(todo-mark-to (nth x *todo-mark-list*) lst)))
	  (let*((limit  (properties 0))
			(limit@(sort(sort(schedule-list limit 0 (* 5 356))#'string<)
						#'string< :key #'(lambda(x)(car(split-string x #\> )))))
			(@limit(sort(schedule-list limit 7 -1 )#'string<));option number
			(todo (schedule-list (properties 1) 0 (* 5 356)));siteibi
			(memo (schedule-list (properties 2) 0 *todo-memo-day-length*));siteibi
			(todo&memo (sort(merge 'list todo memo  #'string-lessp)#'string<))
			(don (properties 3))
			(reserve (properties 4))
			(stop (properties 5))
			(schedule (properties 6))
			(limit&todo&memo(sort(merge 'list @limit todo&memo #'string-lessp)
								 #'< :key #'todo-rank-to))
			(limit&todo&memo&reserve(random-list limit&todo&memo reserve t))
			(done(subseq (random-list nil don) 0
						 (if(>= (length don)*done-max*)
							 *done-max*
						   (length don)))))
		(values limit@ limit&todo&memo&reserve done stop schedule)))))

(defun todo-list()
  (unless(file-exist-p *base-dir*)
	(create-directory  *base-dir*))
  (with-open-file(f (merge-pathnames *todo-file* *base-dir*)
					:if-does-not-exist :create)
	(let(line r)
	  (while(setq line(read-line f nil nil nil))
		(push line  r))r)))


(defun todo-mark-to(mark lst)
  (unless(atom lst)
	(let*((str(cadr
			   (split-string(car lst)
							(char(cadr *paren-day*)1))))
		  (mk(substring(string-left-trim " " str)0 1)))
	  (delete nil(cons(when(equal mark mk)(car lst))
					  (todo-mark-to mark(cdr lst)))))))

;;float sink Todo
(defun todo-day-list(str)
  "日付を分解"
  (subseq
   (split-string
	(car(split-string
		 (car(split-string
			  (string-left-trim " \t#" str);;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			  #\]))
		 #\[))
	#\-)
   0 3))

(defun string-to-time-lst(lst)
  (if(atom lst)nil
	(cons (parse-integer (car lst))(string-to-time-lst(cdr lst)))))

(defun todo-encode-universal-time(lst)
  "universal-timeを返す 日本"
  (let((jap -9)
	   (y (car lst))
	   (m (cadr lst))
	   (d (third lst)))
	(encode-universal-time 0 0 0 d m y jap)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun todo-option-number(str)
  "string-number to number"
  (let((a(substitute-string
		  (substring
		   (string-left-trim " "(cadr(split-string str #\])))
		   1 nil)
		  "^\\([0-9]+\\).*" "\\1")))
	(if(string-match "^[0-9]+" (if a a(setq a "0")))
		(parse-integer a)0)))

(defun todo-marks-to(str)
  (let((marks (substring(string-left-trim " "(cadr(split-string str #\])))0 1)))
	(car (member marks *todo-mark-list* :test 'equal))))

(defun todo-today()
  (todo-encode-universal-time
   (string-to-time-lst
	(todo-day-list(format-date-string *todo-format*)))))
; かなり微妙
(defun todo-rank(n marks lst)
  "universal-time"
  (let*((day(todo-encode-universal-time lst))
		(one 86400)
		(margin (* n one))
		(today (todo-today))
		(limit 7)
		(seven (* limit one)))
	(cond((equal marks (nth 0 *todo-mark-list*));!
		  (- (- day (-(*(decf limit) one) margin))(- today seven) 1))
		 ((equal marks (nth 1 *todo-mark-list*));+
		  (- (+ day (if (eq 0 margin)(decf limit)margin))today  2))
		 ((equal marks (nth 2 *todo-mark-list*));-
		  (- (- today (+ (if (eq 0 margin)(decf limit)(- margin seven)) seven))(+ day margin)  3))
		 )))

(defun todo-rank-to(str)
  (todo-rank (todo-option-number str)
			 (todo-marks-to str)
			 (string-to-time-lst(todo-day-list str))))

(defun schedule-check(str beg end)
  (let*((today(string-to-time-lst(todo-day-list(format-date-string *todo-format*))))
		(point-day(todo-encode-universal-time(string-to-time-lst(todo-day-list str))))
		(margin (todo-encode-universal-time
				 (list(car today)(cadr today)(-(third today) end))))
		(margin+ (todo-encode-universal-time
				  (list(car today)(cadr today)
					   (+(third today)
						 (if(< 0(todo-option-number str))
							 (if(< 0 beg)
								 (+ beg (todo-option-number str))beg)
						   beg))))))
	(and(>= point-day margin)
		(<= point-day margin+))))

(defun schedule-list(lst beg end)
  (unless(atom lst)
	(delete nil(cons(when(schedule-check(car lst) beg end)(car lst))
					(schedule-list(cdr lst)beg end)))))

(defun schedule()
  (todo-week
   (sort
	(schedule-list(todo-mark-to(nth 6 *todo-mark-list*)(todo-list))
				  *schedule-margin-before* *schedule-margin-over*)
	#'string<)))

;; 曜日をいれてみる
(defun todo-week(lst)
  (unless(atom lst)
	(let*((time(todo-encode-universal-time
				(string-to-time-lst(todo-day-list(car lst)))))
		  (today(todo-today))
		  (num (/ (- today time) 86400))); (* 60 60 24)
	  (cons (concat(format-date-string
					(concat " "
							(if *index-todo-week* "%a" "%v")
							(format nil (if (<= 999 num) "~A" "~4,' D")
									(if (<= 999 num) " ***" num);;; 999<***
									)"｜")time)(car lst))
			(todo-week (cdr lst))))))

(defun random-list(src lst &optional (row nil))
  (if(atom lst)src
	(let*((a (subseq src 0 (random(length src))))
		  (b (subseq src (length a) nil)))
	  (delete nil
			  (random-list(append(if row a b)(cons (car lst)(if row b a)))(cdr lst) row)))))
;;output
(defun todo()
  (interactive)
  (long-operation
	(let((buf *todo-buffer*))
	  (when(find-buffer buf)(delete-buffer buf))
	  (with-output-to-buffer ((switch-to-buffer buf))
		;;~&~60,,,'-@A を 3 回
		(format t "~&~60,,,'-@A~&~60,,,'-@A~&~60,,,'-@A~{~&~A~}~%~%~&~60,,,'-@A~&~60,,,'-@A~&~60,,,'-@A~{~&~A~}"
				"" "- SCHEDULE " ""
				(schedule)
				"" "- TODO " ""
				(multiple-value-bind (limit todo done)
					(todo-sort (todo-list))
				  (append(todo-week limit)
						 (todo-week todo)
						 (todo-week done)))))))
  (refresh-screen)
  (todo-mode)
  )


(defun add-todo(date todo str)
  (interactive "sDate: \nsToDo(! @ + - ~): \nsContents: "
	:default0 (format-date-string *todo-format*)
	:default1 "+"
	:default2 "*TAG*")
  (let((opt
		(read-string
		 "RET (Done)｜n (Repeat) : "))
	   (line  (format nil "~A~A ~A"(str-paren date *paren-day*) todo str))
	   (oldline (concat"\\(^.*?\\)\\(\\[" *todo-day* "\\]\\)\\(.*?\\)")))
	(flet((dn(item n &optional m)(parse-integer(subseq item n m))))
	  (unless(file-exist-p *base-dir*)
		(create-directory  *base-dir*))
	  (with-open-file(todo (merge-pathnames *todo-file* *base-dir*)
						   :if-does-not-exist :create
						   :direction :output
						   :if-exists :append)
		(cond ((equal "" opt)
			   (format todo "~&~A" line))
			  ((string-match "^[0-9]+" opt)
			   (let*((how(read-string "How?｜n (Width)｜d (Day)｜w (Week)｜m (month)｜y (Year): "
									  :default "d"))
					 (po(read-string "Pointing Day [基本となる日]yymmdd :"
									 :default
									 (format-date-string "%Y%m%d"(todo-encode-universal-time
																  (string-to-time-lst
																   (todo-day-list date))))))
					 (new (list (dn po 0 4)(dn po 4 6)(dn po 6 8)))
					 (time (todo-encode-universal-time new))
					 (n (cond((string-match "d" how) 1)
							 ((string-match "w" how) 7)
							 (t (parse-integer (if (string-match "[0-9]+" how) how "0"))))))
				 (when(< 1 (dn opt 0))
				   (dotimes(x (dn opt 0))
					 (format todo "~&~A~%"
							 (substitute-string line
												oldline
												(concat "\\1"
														(format-date-string
														 (str-paren *todo-format* *paren-day*)
														 (todo-encode-universal-time new))"\\3")))
					 (setq new (cond((string-match "m" how)
									 (if(<(cadr new) 12)
										 (list(car new)(1+(cadr new))(third new))
									   (list(1+(car new))1(third new))))
									((string-match "y" how)(list(1+(car new))(cadr new)(third new)))
									(t (list(car new)(cadr new)(+(third new)n)))))))))
			  )))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;todo-level-of-achievement
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; todo を主に使う方向に持って行くための仕組み
;  usage
;  [0000-00-00]+ hoge *TAG* foo
;  [0000-00-00]. hoge *TAG* foo
; *TAG* でグループに分けて達成度をつける
(defvar *tloa-member* nil)
(defvar *todo-tag-member* nil)
(defvar *tloa* nil)
(defvar *todo-member-content-begin* nil)
(defvar *todo-member-content-end* nil)
(defvar *tloa-deco* 30)
(defvar *tloa-buffer* "*tloa*")

(defun todo-scan-tag()
  (let((lst(todo-list)))
	(setq *tloa-member*
		  (make-hash-table :test #'equal))
	(setq *tloa*
		  (make-hash-table :test #'equal :size (length lst)))
	(dolist (x lst *todo-tag-member* )
	  (when (string-match "\\][ \t]*?[\\.\\+].*\\*\\(.+?\\)\\*" x)
		(pushnew (match-string 1) *todo-tag-member* :test 'equal)
		(setf (gethash x *tloa*)
			  (match-string 1))))))

(defun tloa(tag)
  (let(all done)
	(maphash #'(lambda (x y)
				 (when (string-match tag y)
				   (when(string-match "\\]\\." x)
					 (push x done))
				   (push x all)))
			 *tloa*)
	(when all
	  (let*((h 100)
			(alen (length all))
			(n (round (* h (/ (length done)
							  (if (= 0 alen) 1 alen))))))
		(and(< h n)(setq n h))
		;format
		(format t "~[@ ~;* ~;o ~:;  ~]~30,,@A[~20@A]~4@A%~&"
				(if(< *tloa-deco* alen)
					(cond((= h n) 0)
						 ((and(<= 90 n)(> h n)) 1)
						 ((and(<= 80 n)(> 90 n)) 2)
						 (t 3))
				  3)
				tag
				(make-sequence 'string (round (* 0.2 n));0.1なら10
							   :initial-element #\+)
				n))
	  (setf (gethash tag *tloa-member*)
			(sort all #'string<)))));old > new

(defmacro read-on-off (&rest arg)
  `(progn
	 (toggle-read-only nil)
	 ,@arg
	 (toggle-read-only t)
	 ))

(defun todo-member-content-view()
  (interactive)
  (save-excursion
	(if *todo-member-content-begin*
		(read-on-off
		 (delete-region *todo-member-content-begin* *todo-member-content-end*)
		 (setq *todo-member-content-begin* nil)
		 (setq *todo-member-content-end* nil))
	  (let*((f (progn(goto-bol)(forward-char)(skip-syntax-spec-forward "_ ")(point)))
			(e (progn(skip-syntax-spec-forward "_wxjk.")
				 (point)))
			(c (gethash (buffer-substring f e)*tloa-member*)))
		(when c
		  (read-on-off
		   (goto-eol)(forward-char)
		   (setq *todo-member-content-begin* (point))
		   (insert	(format nil "~{~A~&~}" c))
		   (setq *todo-member-content-end* (point))))))
	(set-buffer-modified-p nil)))

(defun tloa-buf-close()
  (interactive)
  (delete-buffer(find-buffer *tloa-buffer*))
  (setq *todo-member-content-begin* nil)
  (setq *todo-member-content-end* nil))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun tloa-jump()
  (interactive)
  (let((now (nowline-string)))
	(when(string-match "\\[[0-9]+" now)
	  (find-file (merge-pathnames *todo-file* *base-dir*))
	  (goto-char (point-min))
	  (scan-buffer (regexp-quote now) :regexp t)
	  (recenter)
	  (todo-file-mode))))

(defvar *tloa-mode-map* nil)
(unless *tloa-mode-map*
  (setf *tloa-mode-map* (make-sparse-keymap))
  (define-key *tloa-mode-map* #\SPC 'todo-member-content-view)
  (define-key *tloa-mode-map* #\m 'add-todo)
  (define-key *tloa-mode-map* #\RET 'tloa-jump)
  (define-key *tloa-mode-map* #\q 'tloa-buf-close))

(defvar-local tloa-mode nil )
(defun tloa-mode(&optional (arg nil sv))
  (interactive "p")
  (setq mode-name "level-of-achievement")
  (setq buffer-mode 'tloa-mode)
  (setq need-not-save t)
  (setq auto-save nil)
  (setq kept-undo-information nil)
  (set-buffer-modified-p nil)
  (ed::toggle-mode 'tloa-mode arg sv)
  ;;(use-keymap *tloa-mode-map*)
  (if tloa-mode
	  (set-minor-mode-map *tloa-mode-map*)
	(unset-minor-mode-map *tloa-mode-map*)))

;ここで一覧をbufferに吐き出す
(defun tloa-output()
  (interactive)
  (todo-scan-tag)
  (when (find-buffer *tloa-buffer*)
	(delete-buffer *tloa-buffer*)
	(setq *todo-member-content-begin* nil)
	(setq *todo-member-content-end* nil))
  (with-output-to-temp-buffer(*tloa-buffer*)
	(format t "~60,,,'-A~&~32,,,'-@A~28,,,'-@A~&~60,,,'-A~&"
			"" "- TAG Member " " Level of Achievement " "")
	(dolist (x (stable-sort *todo-tag-member* #'string<))
	  (tloa x))
	(toggle-read-only t))
  (delete-other-windows)
  (tloa-mode))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; todo-mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar *todo-important-face* '(:color 1 0))
(defvar *todo-todo-face* '(:color 2 0))
(defvar *todo-memo-face* '(:color 4 0))
(defvar *todo-done-face* '(:color 15 0))
(defvar *todo-reserve-face* '(:color 8 0))
(defvar *todo-stop-face* '(:color 0 0 :strike-out))
(defvar *todo-schedule-face* '(:color 3 0))

(defvar *priority-face* '(:color 9 0 :bold))
(defvar *todo-sunday-face* '(:color 1 0))
(defvar *todo-saturday-face* '(:color 4 0))
(defvar *todo-today-face* '(:color 0 14 :underline))
(defvar *id-paren-face* '(:color 11 0))
(defvar *id-face* '(:color 8 0 :underline))

(defun paren-regexp(lst str)
  (concat "\\(" (car lst) "\\)\\("
		  str
		  "\\)\\(" (cadr lst) "\\)"))

(defun paren-regexp-1(lst str)
  (concat "\\(" (car lst) "\\)\\([^"
		  (substring (paren lst) 0 1)
		  (substring (paren lst t) 0 1)
		  str
		  "\\)\\(" (cadr lst) "\\)"))

(defun list-regexp-to(x y)
  (if (atom x) y
	(delete nil(append(list (regexp-quote(car x))(car y))
					  (list-regexp-to (cdr x)(cdr y))))))

(defun mark-regexp(lst mes-lst)
  (format nil(concat (car mes-lst )"~{~A~}"(cadr mes-lst))
		  (list-regexp-to lst (make-list (1- (length lst)) :initial-element "\\|") )))

(defun id-regexp()
  (paren-regexp-1 *paren-day* " \t\n\"\*\+\~\=\$,#%&!{}<>\?]+?"))

(defun id-act-regexp(str)(paren-regexp *paren-day* str))

(defun todo-today-regexp()
  (concat".*?\\("(id-act-regexp(format-date-string *todo-format*))
		 " *?"(mark-regexp *todo-mark-list* '("\\(""\\)"))"\\{0,1\\}\\).*?"))

(defvar *todo-day* "[0-9]+-[0-9]+-[0-9]+\\(-[0-9]+\\)*?")

(defun todo-regexp()(id-act-regexp *todo-day*))

(defun todo-main-regexp()(concat "\\([ \t#]*?\\)\\("(todo-regexp) "\\) *"))

(defun todo-select-regexp(str)
  (concat (todo-main-regexp)"\\("(regexp-quote str)"\\) \\{0,\\}\\([0-9]+\\)\\{0,\\}"))

(defvar *todo-formats*
  (compile-regexp-keyword-list
   `(
	 (,(todo-today-regexp) nil ((1 . ,*todo-today-face*)))
	 (,(todo-select-regexp
		(nth 0 *todo-mark-list*)) nil ((1 . ,*priority-face*)
									   (2 . ,*todo-important-face*)
									   (7 . ,*todo-important-face*)
									   (8 . ,*todo-important-face*)))
	 (,(todo-select-regexp
		(nth 1 *todo-mark-list*)) nil ((1 . ,*priority-face*)
									   (2 . ,*todo-todo-face*)
									   (7 . ,*todo-todo-face*)
									   (8 . ,*todo-todo-face*)))
	 (,(todo-select-regexp
		(nth 2 *todo-mark-list*)) nil ((1 . ,*priority-face*)
									   (2 . ,*todo-memo-face*)
									   (7 . ,*todo-memo-face*)
									   (8 . ,*todo-memo-face*)))
	 (,(todo-select-regexp
		(nth 3 *todo-mark-list*)) nil ((1 . ,*priority-face*)
									   (2 . ,*todo-done-face*)
									   (7 . ,*todo-done-face*)
									   (8 . ,*todo-done-face*)))
	 (,(todo-select-regexp
		(nth 4 *todo-mark-list*)) nil ((1 . ,*priority-face*)
									   (2 . ,*todo-reserve-face*)
									   (7 . ,*todo-reserve-face*)
									   (8 . ,*todo-reserve-face*)))
	 (,(todo-select-regexp
		(nth 5 *todo-mark-list*)) nil ((1 . ,*priority-face*)
									   (2 . ,*todo-stop-face*)
									   (7 . ,*todo-stop-face*)
									   (8 . ,*todo-stop-face*)))
	 (,(todo-select-regexp
		(nth 6 *todo-mark-list*)) nil ((1 . ,*priority-face*)
									   (2 . ,*todo-schedule-face*)
									   (7 . ,*todo-schedule-face*)
									   (8 . ,*todo-schedule-face*)))
	 (,(id-regexp) nil   ((1 . ,*id-paren-face*)
						  (2 . ,*id-face*)
						  (3 . ,*id-paren-face*))); 順位
	 ("^ \\(\\(日\\|Sun\\)\\|\\(土\\|Sat\\)\\)" nil ((2 . ,*todo-sunday-face*)
													 (3 . ,*todo-saturday-face*)))
	 )))
(defvar *todo-buffer-close-hook* nil)

(defun todo-bufffer-close()
  (interactive)
  (while(stop-timer '*alternate-lighting-on*))
  (delete-buffer(find-buffer *todo-buffer*))
  (run-hooks '*todo-buffuer-close-hook*)
  )

(defun todo-jump()
  (interactive)
  (let((now (nowline-string)) line)
	(when(and(string-match "^ .*?｜\\(\\[[0-9]+.*\\)" now)
			 (setq line (match-string 1)))
	  (find-file (merge-pathnames *todo-file* *base-dir*))
	  (goto-char (point-min))
	  (scan-buffer (regexp-quote line) :regexp t)
	  (recenter)
	  (todo-file-mode))))

(defvar *todo-mode-map* nil)
(unless *todo-mode-map*
  (setf *todo-mode-map* (make-sparse-keymap))
  (define-key *todo-mode-map* #\? 'tloa-output)
  (define-key *todo-mode-map* #\z 'tloa-output)
  (define-key *todo-mode-map* #\/ 'tloa-output)
  (define-key *todo-mode-map* #\i 'todo)
  (define-key *todo-mode-map* #\q 'todo-bufffer-close)
  (define-key *todo-mode-map* #\RET 'todo-jump)
  (define-key *todo-mode-map* #\m 'add-todo)
  )

;; color
;; sun sat [yyyy-mm-dd] @+!.-~
(defvar *todo-mode-hook* nil)
(defvar-local todo-mode nil)
(defvar *todo-mode-hook* nil)
(defun todo-mode()
  (setq mode-name "todo")
  (toggle-ime nil)
  (setq buffer-mode 'todo-mode)
  (setq buffer-read-only t)
  (setq need-not-save t)
  (setq auto-save nil)
  (setq kept-undo-information nil)
  (set-buffer-modified-p nil)
  (use-keymap *todo-mode-map*)
  (make-local-variable 'regexp-keyword-list)
  (set-local-window-flags
   (selected-buffer)
   (+ *window-flag-line-number* ;*window-flag-ruler*
	  *window-flag-tab* *window-flag-newline*
	  ;*window-flag-vscroll-bar* *window-flag-mode-line*
	  *window-flag-hscroll-bar* *window-flag-eof*
	  *window-flag-fold-line* *window-flag-fold-mark*
	  ;*window-flag-cursor-line*
	  ) nil);option
  (set-buffer-fold-type-none);
  (setq regexp-keyword-list *todo-formats*)
  (run-hooks '*todo-mode-hook*))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar-local todo-file-mode nil)
(defun todo-file-mode()
  (setq mode-name "todo")
  (make-local-variable 'regexp-keyword-list)
  (setq regexp-keyword-list *todo-formats*))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;alternate-lighting お遊び
(defvar *alternate-lighting-list* nil)
(defvar *alternate-lighting-list-option* nil)
(defvar *alternate-lighting-rainbow-day* "[1]") ;1日前になると..
(defvar *alternate-lighting-option-day* "[2-3]")   ;三日前になると...
(setq alternate-lighting-char-list
	  `(,(nth 0 *todo-mark-list*)   ;!
		,(nth 6 *todo-mark-list*))) ;@

(defun alternate-lighting-point-list(&optional (before-day *alternate-lighting-rainbow-day*))
  (let(pos)
	(dolist (x alternate-lighting-char-list)
	  (save-excursion
		(goto-char(point-min))
		(while
			(scan-buffer
			 (concat "^ .*?  -\\(" before-day
					 "\\)｜\\(" (todo-regexp)
					 " *\\(" x "\\)\\)"):regexp t)
		  (forward-char)
		  (push(list(match-beginning 2)(match-end 2)x) pos))))
	(setq pos (delete-duplicates pos :test 'equal))
	(if (equal before-day *alternate-lighting-rainbow-day*)
		(setq *alternate-lighting-list* pos)
	  (setq *alternate-lighting-list-option* pos))
	))

(defun alternate-lighting-attribute(lstn &optional bold (background 0))
  (when(equal(buffer-name(selected-buffer))*todo-buffer*)
	(let((lst alternate-lighting-char-list))
	  (mapcar #'(lambda(x)
				  (set-text-attribute
				   (car x)(cadr x)
				   ;(quote
				   (if (equal lstn *alternate-lighting-list*) 'l 'lo);)
				   :foreground
				   (cond((equal(caddr x)(car lst))
						 (cadr *todo-important-face*))
						((equal(caddr x)(cdr lst))
						 (cadr *todo-schedule-face*))
						(t 0))
				   :bold bold
				   :background background
				   :underline background))
			  lstn))))
(defvar *alternate-lighting-on* nil)
(defun alternate-lighting-run()
  (let ((time 0)
		(background 0))
	(setf (symbol-function '*alternate-lighting-on*)
		  #'(lambda()
			  ;;(delete-text-attributes 'l)
			  (alternate-lighting-attribute *alternate-lighting-list*
											(oddp(incf time))
											(incf background))
			  ;;(delete-text-attributes 'lo)
			  (alternate-lighting-attribute *alternate-lighting-list-option*
											(oddp time) 0)
			  (refresh-screen)))
	)
  (start-timer 1 '*alternate-lighting-on*)
  )

(defun alternate-lighting()
  (alternate-lighting-point-list)
  (alternate-lighting-point-list *alternate-lighting-option-day*)
  (alternate-lighting-run)
  )

;; (defun delete-alternate-lighting()
;;   (let((buf(selected-buffer))
;; 	   (index *todo-buffer*))
;; 	(setq *alternate-lighting-list* nil)
;; 	(setq *alternate-lighting-list-option* nil)
;; 	(while(stop-timer '*alternate-lighting-on*)(message "delete"))
;; 	(when(find-buffer index)
;; 	  (switch-to-buffer index)
;; 	  (delete-text-attributes 'l)
;; 	  (delete-text-attributes 'lo))
;; 	;;(delete-buffer(tw-index-buffer))
;; 	(switch-to-buffer buf))
;;   )

(add-hook '*todo-mode-hook* 'alternate-lighting)
;;(add-hook '*todo-buffer-close-hook* 'delete-alternate-lighting)

(in-package "user")