;;; -*- Mode: Lisp -*-
;;; --- xy-phrase ---
;;
;; Author: amefura <amefura@gmail.com>
;; Created: Tue Jun 15 13:38:12 2010
;; Last Modified:Tue, 22 Jun 2010 19:37:36
;;
;;    The MIT License
;;
;;    Copyright (c) <June 20, 2010> <copyright amefura>
;;
;;    Permission is hereby granted, free of charge, to any person obtaining a copy
;;    of this software and associated documentation files (the "xy-phrase"), to deal
;;    in the Software without restriction, including without limitation the rights
;;    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;;    copies of the Software, and to permit persons to whom the Software is
;;    furnished to do so, subject to the following conditions:
;;
;;    The above copyright notice and this permission notice shall be included in
;;    all copies or substantial portions of the Software.
;;
;;    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;;    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;;    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;;    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;;    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;;    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
;;    THE SOFTWARE.
;;
;;;;;
;;
;;  * M-x xy-phrase-mode  toggle
;;
;;    * xy-phrase-extent-expand
;;        リージョンまたはセレクションを囲む
;;    * xy-phrase-flashy
;;        確認しながら編集
;;            RET 決定
;;            SPC 展開しているものを snippet として作成
;;                key が空なら作成はしません
;;                xyzzy 終了するまでの間
;;                保存したい場合 xy-phrase-read-template [1] を空で実行
;;    * xy-phrase-read-template
;;        テンプレートを再読込、又は新しい snippet を作成
;;
;;
;;  * keybind
;;     M-SPC xy-phrase         展開、セレクションがある場合は minibuffer から
;;     M-/   xy-phrase-flashy  展開、確認しながら編集
;;     C-n                     次のポイントに移動
;;     C-p                     前のポイントに移動
;;
;;  * edit
;;    hoge.foo.bar hoge => foo => bar   $. の位置に展開される
;;    html-mode,xml-mode の場合は class="foo"
;;
;;    hoge#foo  hoge => foo   $# の位置に展開される
;;    html-mode,xml-mode の場合は id="foo"
;;
;;    hoge*3    => <hoge><hoge><hoge>   n 回展開される
;;
;;    hoge+foo  => <hoge><foo>          並びに展開される
;;
;;    hoge>foo  => <hoge><foo></hoge>   $> の位置に展開
;;    snippet に $> $. がない場合は無視されるので注意
;;
;;    ( group ) グループ
;;    複数回別の要素でリピートした場合にうまくいかない時はグループ化する
;;
;;    *n =>  n リピート
;;
;;    *  =>   Selection Multiline child
;;
;;    { item-??*2 } => item-01 item-02  serial number
;;
;;     > . # ! $ * + ( ) は \ でクォート ,  & は少し特殊
;;
;;    snippet がこの場合
;;    (("li" "<li>$>$1</li>\n")
;;    ("ol" "<ol>$>\n</ol>$1\n")
;;    ("a"  "<a>$1</a>"))
;;
;;    ol>(li*3>a) , ol>((li>a)*3) =>
;;     <ol>
;;       <li><a></a></li>
;;       <li><a></a></li>
;;       <li><a></a></li>
;;     </ol>
;;
;;  * expansion snippet
;;    { $> , $. , $# , $! , $& , $$ }:  この位置に要素を挿入する
;;
;;    { $0~$9 }     :   展開後の位置移動
;;
;;    format-date-string の fmt
;;    %f: ファイル名
;;    %F: フルパス
;;    %D: PATHNAMEのディレクトリ部分
;;    %n: ファイル名（拡張子無し）
;;    %x: 拡張子
;;    %t: ファイルの日付。
;;    %T: ファイルの時間。
;;    %c  クリップボード
;;    %k  yank
;;
;;  * Snippet List
;      make file
;;      "~/snippet/" "buffer-mode"
;;     write list
;;      ((key expansion &optional {before function} {after function})
;;          ......
;;       )
;;
;;  * execute mode
;;     (require "xy-phrase")
;;     (add-hook '*text-mode-hook* 'xy-phrase-mode)
;;
;;
;;; Code:
(require :xy-phrase/format-file)
(require :xy-phrase/format-snippet)
(in-package :editor)

(export '(xy-phrase-mode
		  xy-phrase-extent-expand
		  xy-phrase-flashy
		  xy-phrase-read-template
		  ))

(defvar *xy-phrase-mode-map* nil)
(unless *xy-phrase-mode-map*
  (setf *xy-phrase-mode-map* (make-sparse-keymap))
  (define-key *xy-phrase-mode-map* #\C-n   'xy-phrase-mode-next)
  (define-key *xy-phrase-mode-map* #\C-p   'xy-phrase-mode-previous)
  (define-key *xy-phrase-mode-map* #\M-/   'xy-phrase-flashy)
  (define-key *xy-phrase-mode-map* #\M-SPC 'xy-phrase))

(defvar *xy-phrase-dir* "~/site-lisp/xy-phrase/snippet/")

(defvar *xy-phrase-flashy-color* '(:underline t :bold t)
  "xy-phrase-flashy, Specifies the highlight color of text")

(defvar *xy-phrase-flashy-extended-area-color* nil
  "xy-phrase-flashy, Specifies the color of the extended portion, the list")

(defvar *xy-phrase-flashy-recenter* nil
  "xy-phrase-flashy, If you want to specify a number at recenter")

(defvar *xy-phrase-flashy-candidacy-popup* nil
  "xy-phrase-flashy, pop-up, t stop at")

(defvar *xy-phrase-format-snippet*  '((#\% ((#\c (get-clipboard-data))
											(#\k (caar *kill-ring*)))))
  "Extended replacement character")

(defvar *xy-phrase-buffer* (make-array 331 :element-type 'character))

(defvar *xy-phrase-table* (make-hash-table :test 'equal))

(defvar-local *xy-phrase-next-point-list* nil)
(defvar-local *xy-phrase-next-point-max* nil)
(defvar-local *xy-phrase-next-point-min* nil)
(defvar-local *xy-phrase-next-point-length* nil)

(defvar *xy-phrase-option-fn* nil)
(defvar *xy-phrase-temp-snippet* nil)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defvar *xy-phrase-items*		; not %
	'((#\> . "child")(#\. . "dot")(#\# . "numerical");(#\@ . "at")
	  (#\! . "exclamation")(#\$ . "dollar")(#\& . "ampersand"))))

(defun xy-phrase-circular-list(&rest elt)
  (setf (cdr (last elt)) elt))

(defun xy-phrase-member (str)
  (or (nth 1 (assoc str (gethash buffer-mode *xy-phrase-table*) :test 'equal))
	  str))

(defun xy-phrase-delete-item (str item rep)
  (multiple-value-bind (after n)
	  (substitute-string str item rep)
	(if (zerop n)
		(concat str rep)
	  after)))

(defun xy-phrase-set-mark (point)
  (set-marker (make-marker (buffer-name (selected-buffer))) point))

(defmacro def-xy-phrase (chars-names)
  `(progn
	 ,@(mapcar #'(lambda (x)
				   `(defun ,(intern (concat "xy-phrase-" (cdr x)) :editor)
					  (snippet str)
					  (xy-phrase-delete-item
					   (xy-phrase-member snippet)
					   ,(regexp-quote (concat "$" (string (car x))))
					   ,(case (car x)
						  (#\. `(if #1=(find buffer-mode
										  (list 'html-mode 'ed::html+-mode
												(if (find-package :xml)
													(intern "xml-mode" :xml))))
									(concat " class=\"" (xy-phrase-member str) "\"")
								  (xy-phrase-member str)))
						  (#\# `(if #1#
									(concat " id=\"" (xy-phrase-member str) "\"")
								  (xy-phrase-member str)))
						  (otherwise `(xy-phrase-member str))))))
			   chars-names)
	 (defvar *xy-phrase-separate-items*
	   ,(coerce (append (mapcar #'car chars-names) '(#\* #\+ #\( #\))) 'string))
	 (defvar *xy-phrase-erase-items*
	   ,(format nil "\\(~{~A~^\\|~}\\)"
				(mapcar #'(lambda (x)(regexp-quote (concat "$" (string (car x)))))
						chars-names)))))

(def-xy-phrase #.*xy-phrase-items*)

(defun xy-phrase-plus (snippet str)
  (concat (xy-phrase-delete-item (xy-phrase-member snippet)
								 *xy-phrase-erase-items* "")
		  (xy-phrase-member str)))

(defun xy-phrase-regexp-erase (snippet)
  (xy-phrase-delete-item snippet *xy-phrase-erase-items* ""))

(defun xy-phrase-insert (str)
  (let((p (point)))
	(or str (setf str ""))
	;This cost is considered a template
	(setf str (format-file-string str)
		  str (format-snippet-string str *xy-phrase-format-snippet*)
		  str (format-date-string str))
	(insert str)
	(if mode-specific-indent-command
		(indent-region p (point)))))

;; { *n } n Repeat { * } Selection Multiline child
;; { item-??*2 } => item-01 item-02  serial number
(defun xy-phrase-repeat (snippet n&str)
  (cond ((and (= (count-if #'(lambda (x)(find x "0123456789")) n&str)(length n&str))
			  (not (zerop (length n&str))))
		 (let ((acc))
		   (dotimes (x (parse-integer n&str) (apply #'concat (nreverse acc)))
			 (if (string-match "\\(\\?+\\)" snippet )
				 (push  (substitute-string
						 snippet "\\(\\?+\\)"
						 (format
						  nil (concat "~" (write-to-string (length (match-string 1)))
									  ",'0D")
						  (1+ x)))
						acc)
			   (push snippet acc)))))
		((not (zerop (length n&str)))
		 (let* ((items (split-string n&str #\LFD " \t"))
				(snippets (make-list (length items) :initial-element snippet)))
		   (apply #'concat
				  (mapcar #'(lambda (snippet item)
							  ; child restriction
							  (xy-phrase-child snippet (string-trim " \t" item)))
						  snippets items))))
		(t (concat snippet n&str))))

(defun xy-phrase-read-string (in test)
  (do ((ch #1=(read-char in nil nil) #1# )
	   (i 0 (1+ i))(yen))
	  ((or (if (not yen)(funcall test ch)(setf yen nil))(null ch))
	   (if ch (unread-char ch in))
	   (return (subseq *xy-phrase-buffer* 0 i)))
	(when (eql ch #\\)(setf yen t))
	(setf (aref *xy-phrase-buffer* i) ch)))

(defun xy-phrase-parse (str &optional extent)
  (with-input-from-string (in str)
	(let ((ch)(item)(snippet))
	  (labels ((read-str (input)
				 (xy-phrase-read-string
				  input #'(lambda (x)(find x *xy-phrase-separate-items*))))
			   (iter (input)
				 (let ((paren 0))
				   (concat
					(xy-phrase-parse
					 (xy-phrase-read-string
					  input #'(lambda (x)
								(cond ((eql x #\()(incf paren) nil)
									  ((eql x #\))
									   (if (zerop paren) t
										 (progn (decf paren) nil))))))
					 extent)
					(progn #1=(read-char input nil nil)(read-str input)))))
			   (switch (input)
				 (case (peek-char nil input nil)
				   (#\( #1# (iter input))
				   (otherwise (xy-phrase-member
							   (if (and extent (zerop (decf extent)))
								   (xy-phrase-read-string
									in #'(lambda (x)(if (eql #\* x) t (not x))))
								 (read-str input)))))))
		(macrolet((snippet-case (ch snippet in)
					`(case ,ch
					   ,@(mapcar #'(lambda (x)
									 `(,(car x)(,(intern (concat "xy-phrase-" (cdr x)))
												snippet (switch in))))
								 *xy-phrase-items*)
					   (#\+  (xy-phrase-plus snippet (switch in)))
					   (#\(  (iter in))
					   (#\*  (xy-phrase-repeat
							  snippet
							  (if extent
								  (xy-phrase-read-string in #'not)
								(read-str in)))))))
		  (setf item    (read-str in)
				snippet (xy-phrase-member item)
				snippet (xy-phrase-repeat snippet (read-str in)))
		  (unless *xy-phrase-option-fn*
			(setf *xy-phrase-option-fn*
				  (assoc item (gethash buffer-mode *xy-phrase-table*)
						 :test 'equal)))
		  (loop
			(unless (setf ch (read-char in nil nil))(return snippet))
			(setf snippet (snippet-case ch snippet in))))
		(minibuffer-message (setf *xy-phrase-temp-snippet* snippet))
		(xy-phrase-regexp-erase snippet)))))

(defun xy-phrase-collect-$item (from end)
  (let ((move-parameter 1000))
	(narrow-to-region from end)
	(goto-char from)
	(while (scan-buffer "\$\\([0-9]\\)" :regexp t :no-dup nil :limit end)
	  (push (cons (1+ (point))(parse-integer (match-string 1)))
			*xy-phrase-next-point-list*)
	  (delete-char 2))
	(widen)
	(when *xy-phrase-next-point-list*
	  (setf *xy-phrase-next-point-list*
			(mapcar #'car
					(sort *xy-phrase-next-point-list*
						  #'(lambda (x y)
							  (< (+ (car x)(* (cdr x) move-parameter))
								 (+ (car y)(* (cdr y) move-parameter))))))
			*xy-phrase-next-point-max*
			(xy-phrase-set-mark (apply #'max *xy-phrase-next-point-list*))
			*xy-phrase-next-point-min*
			(xy-phrase-set-mark (apply #'min *xy-phrase-next-point-list*))
			*xy-phrase-next-point-length* (length *xy-phrase-next-point-list*))
	  (goto-char (1- (marker-point *xy-phrase-next-point-min*)))
	  (if  (<= (length *xy-phrase-next-point-list*) 1)
		  (setf *xy-phrase-next-point-list* nil)
		(setf *xy-phrase-next-point-list*
			  (mapcar #'(lambda (x)(xy-phrase-set-mark x))
					  *xy-phrase-next-point-list*)
			  *xy-phrase-next-point-list*
			  (cdr (apply 'xy-phrase-circular-list
						  *xy-phrase-next-point-list*)))))
	(unless *xy-phrase-next-point-list*
	  (goto-char (1- end)))))

(defun xy-phrase-scan (&optional arg)
  (let ((p (point))(target))
	(save-excursion
	  (scan-buffer "\\([ \t]\\|^\\)" :reverse t :no-dup t :regexp t :tail t)
	  (setf target (buffer-substring (point) p))
	  (if arg (apply #'set-text-attribute (point) p 'flashy
					 *xy-phrase-flashy-color*)
		(delete-text-attributes 'flashy))
	  (if arg target
		(progn
		  (delete-char (length target))
		  (xy-phrase-parse target))))))

(defun xy-phrase-execute (snippet)
  (when snippet
	(if (eobp)(open-line))
	(let ((mark (xy-phrase-set-mark (1+ (point))))
		  (p (point)))
	  (if (nth 2 *xy-phrase-option-fn*)(funcall (nth 2 *xy-phrase-option-fn*)))
	  (xy-phrase-insert snippet)
	  (if (nth 3 *xy-phrase-option-fn*)(funcall (nth 3 *xy-phrase-option-fn*)))
	  (xy-phrase-collect-$item p (marker-point mark)))))

(defun xy-phrase ()
  (interactive)
  (setf *xy-phrase-next-point-list* nil
		*xy-phrase-option-fn*       nil)
  (if (pre-selection-p)
	  (call-interactively 'xy-phrase-extent-expand)
	(xy-phrase-execute (xy-phrase-scan))))

;; selection and region
(defun xy-phrase-extent-expand (ask)
  (interactive "sSnippet: ")
  (setf *xy-phrase-next-point-list* nil
		*xy-phrase-option-fn*       nil)
  (let  ((extent (if (< 0 (length ask))
					 (count-if #'(lambda (x)(find x (mapcar #'car *xy-phrase-items*))) ask)
				   (return-from xy-phrase-extent-expand)))
		 (str))
	(cond ((pre-selection-p)
		   (selection-start-end (start end)
			 (setf str (buffer-substring start end))
			 (delete-region start end)))
		  ((mark)
		   (setf str (buffer-substring (region-beginning)(region-end)))
		   (delete-region (region-beginning)(region-end)))
		  (t (return-from xy-phrase-extent-expand)))
	(setf str (concat ask (string-trim " \t" str)))
	(let ((*xy-phrase-buffer*
		   (make-array (1+ (length str)) :element-type 'character)))
	  (xy-phrase-execute
	   (xy-phrase-parse str extent)))))

;; While confirming the purpose of editing
(defun xy-phrase-flashy ()
  (interactive)
  (setf *xy-phrase-next-point-list* nil
		*xy-phrase-option-fn*       nil
		*xy-phrase-temp-snippet*    nil)
  (when *xy-phrase-flashy-recenter*
	(recenter *xy-phrase-flashy-recenter*))
  (let ((ch nil)(flashy nil))
	#1=(let ((snippet (xy-phrase-scan :scan-only)))
		 (delete-text-attributes 'b-fashy)
		 (save-excursion
		   #2=(when flashy
				(apply #'(lambda (x y)
						   (delete-region (1- (marker-point x))(marker-point y)))
					   flashy)
				(setf flashy nil))
		   (let ((fl (point)))
			 (insert #\LFD)
			 (xy-phrase-insert (xy-phrase-parse snippet))
			 (when mode-specific-indent-command (indent-region fl (point))
			   (apply #'set-text-attribute
					  (1+ fl)(point) 'b-fashy *xy-phrase-flashy-extended-area-color*)
			   (setf flashy (list (xy-phrase-set-mark (1+ fl))
								  (xy-phrase-set-mark (point)))))))
		 (refresh-screen))
	;; *post-command-hook* If undo is annoying
	(while (setf c (read-char *keyboard* nil nil))
	  (cond
	   ((find c '(#\RET #\LFD)) (return #2#))
	   ((eql c #\SPC)
		(xy-phrase-temporary-snippet))
	   ((graphic-char-p c) (insert c)
		(unless *xy-phrase-flashy-candidacy-popup*
		  (xy-phrase-flashy-candidacy-popup)))
	   (t
		(let ((ch (lookup-key-command c)))
		  (case ch
			((undo xy-phrase xy-phrase-flashy)
			 (message "This command does nothing when the ~S" ch))
			(otherwise
			 (if (and (symbolp ch)(fboundp ch))
				 (funcall ch)) #1#)))))
	  #1#))
  (xy-phrase-execute (xy-phrase-scan)))

(defun xy-phrase-temporary-snippet ()
  (message "If the key is empty, snippet not create")
  (let ((key (read-string "Set the temporary snippet. key?: "))
		(template (gethash buffer-mode *xy-phrase-table*)))
	(unless (zerop (length key))
	  (pushnew (list key *xy-phrase-temp-snippet*) template :test 'equal :key 'car)
	  (setf (gethash buffer-mode *xy-phrase-table*) template))))

(defun xy-phrase-flashy-candidacy-popup ()
  (save-excursion
	(let* ((p1 (point))
		   (p2 (progn (scan-buffer
					   (concat "[" (regexp-quote *xy-phrase-separate-items*)"]")
					   :reverse t :regexp t :tail t)
				 (point)))
		   (cand (buffer-substring p1 p2)))
	  (popup-string
	   (format nil "~{~{ ~10,,,' @A~^~}~^~%~}"
			   (multiple-value-bind (match list)
				   (*do-completion cand :list nil
								   (gethash buffer-mode ed::*xy-phrase-table*))
				 (let ((acc)(rec)(n 0))
				   (dolist (x list (nreverse (cons rec acc)))
					 (push x rec)
					 (when (= 5 (incf n))
					   (push (nreverse rec) acc)
					   (setf rec nil n 0))))))
	   (point)))))

;; Snippet, you can create, snippet reload again after editing
(defun xy-phrase-read-template (&optional (read 0))
  (interactive "nRead Template 0: create tempalte 1: ")
  (let ((file (merge-pathnames (string buffer-mode) *xy-phrase-dir*)))
	(unless (file-exist-p *xy-phrase-dir*)
	  (create-directory *xy-phrase-dir* :if-exists :skip))
	(let ((template (with-open-file(f file :if-does-not-exist :create)
					  (read f nil nil))))
	  (case read
		(1 (let ((key     (read-string "Target Key: "))
				 (snippet (read-string "Expand Snippet: ")))
			 (when (and (zerop (length key))(zerop (length snippet)))
			   (pushnew (list key snippet) template :test 'equal :key 'car)
			   (setf (gethash buffer-mode *xy-phrase-table*) template))
			 (with-open-file(f file
							   :direction :output
							   :if-does-not-exist :create
							   :if-exists :overwrite)
			   (princ "(\n" f)
			   (dolist (x (gethash buffer-mode *xy-phrase-table*))
				 (prin1 x f)(terpri f))
			   (princ ")" f))))
		(otherwise
		 (when template
		   (setf (gethash buffer-mode *xy-phrase-table*) template)))
		))))

;; MODE
(defvar-local xy-phrase-mode nil)

(pushnew '(xy-phrase-mode . "Phr") *minor-mode-alist* :key #'car)

(defun xy-phrase-mode (&optional (arg nil sv))
  (interactive "p")
  (ed::toggle-mode 'xy-phrase-mode arg sv)
  (update-mode-line t)
  (if xy-phrase-mode
	  (set-minor-mode-map *xy-phrase-mode-map*)
	(unset-minor-mode-map *xy-phrase-mode-map*))
  (unless (multiple-value-bind(val win)
			  (gethash buffer-mode *xy-phrase-table*) win)
	(xy-phrase-read-template 0)))

(defun xy-phrase-mode-point-check ()
  (if (and *xy-phrase-next-point-list*
		   (not (< (- (marker-point *xy-phrase-next-point-min*) 2)
				   (point)
				   (+ (marker-point *xy-phrase-next-point-max*) 2))))
	  (setq *xy-phrase-next-point-list* nil)))

(defun xy-phrase-mode-next (&optional (arg 1))
  (interactive "p")
  (xy-phrase-mode-point-check)
  (let ((pos))
	(if *xy-phrase-next-point-list*
		(progn
		  (dotimes (x arg)(setq pos (pop *xy-phrase-next-point-list*)))
		  (goto-char (1- (marker-point pos))))
	  (next-virtual-line arg))))

(defun xy-phrase-mode-previous (&optional (arg 1))
  (interactive "p")
  (xy-phrase-mode-point-check)
  (let ((pos))
	(if *xy-phrase-next-point-list*
		(progn
		  (dotimes(x (- *xy-phrase-next-point-length* arg))
			(setq pos (pop *xy-phrase-next-point-list*)))
		  (goto-char (1- (marker-point pos))))
	  (previous-virtual-line arg))))


(provide :xy-phrase)

;;; xy-phrase ends here
