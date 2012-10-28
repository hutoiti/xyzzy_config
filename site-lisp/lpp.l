;; -*- Mode: lisp; Package: Editor; -*-
#|text
■機能
  ・C-j や C-x C-e での評価を ファイル中の直近の
    in-package で指定されたパッケージ内で評価するように。
  ・eval-last-sexp で #S(...) や #1= などで始まるS式を、
    #の部分から適切に評価するように。

    (上記、2つの機能は常に有効です。)

  ・マクロ展開や評価時に、結果を整形して出力するコマンド
    pprint-eval-print-last-sexp を用意。

    Shidoさんの pme と比べて、よりきれいに出力できるかもし
    れませんが、その分バグを含んでいる可能性も高いです。

    ※ 循環リストは整形表示しません。

  ・pretty-print-list は、バッファに出力されたリストを整形します。
    pprint-eval-print-last-sexp のように、 lisp の構文情報に基づ
    くのではなく、桁位置や開き括弧、閉じ括弧に基づいて行います。
    pprint-eval-print-last-sexp では整形できない循環リストや、
    lispプログラムでない、複雑なリストを整形するときに利用してく
    ださい。 xml-parser-modoki などの結果を整形するのに利用できます。


■インストール
 .xyzzy か siteini.l に下のを書いてください．
  ni-autoload を使用している人は必要ありません。
  (require "lpp")

  また、Shido さんの lispmode.l を導入する事で、
  整形出力が多少早くなると思います。 (推奨)

  キーバインドは各自設定してください。
  ;;例1
  (define-key *lisp-interaction-mode* #\LFD 'pprint-eval-print-last-sexp)

  ;;例2
  (define-key *lisp-interaction-mode* #\LFD
	      (x-key-macro 16 'eval-print-last-sexp 'pprint-eval-print-last-sexp))

  ;;例3
  (define-key *lisp-interaction-mode* #\C-o
	      (x-key-macro 16 'open-line 'pretty-print-list))


■注意事項
  eval-print-last-sexp eval-region を修正しています。
  
  副作用として、C-j や C-x C-e の実行ごとにパッケージが
  実行前に戻されます。*package*を変更したい時は、
  eval-expression (Esc Esc) で変更してください。


■License
Permission is hereby granted, free of charge, to any person obtaining 
a copy of this software and associated documentation files (the 
"Software"), to deal in the Software without restriction, including 
without limitation the rights to use, copy, modify, merge, publish, 
distribute, sublicense, and/or sell copies of the Software, and to 
permit persons to whom the Software is furnished to do so, subject to 
the following conditions:

The above copyright notice and this permission notice shall be 
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


copyright 2006-2007   Masahiro Nakano

・Author 
    Masahiro Nakano <mnakano.gm@gmail.com>

■更新履歴
 on 2007-11-11
  ・ pretty-print-list を追加。
     整形処理したいリストの先頭の開き過去の上で実行する。

 on 2007-2-18
  ・*pprint-linebreak-list* を追加。

 on 2007-1-26
  ・文字列中の \t, \n を評価しないオプション *pprint-string-no-eval* を追加。デフォルトは off.

 on 2007-1-24
  ・lambda式でおかしかったのを修正

 on 2007-1-24
  ・ドット対の表示がおかしかったのを修正

 on 2007-1-17
  ・cond, case の展開を改善
  ・出力のし方を eval-print-last-sexp に合わせた
  ・eval-last-print-sexp で #1= が先頭にあるときはそれも含めて評価するように修正
  ・循環リストで *print-circle* が t の場合に、無限ループに落ちるので
    その場合は通常通りの出力に修正。
  ・(let (x) ・・・) や (let () ・・・) でおかしかったのを修正。

 on 2006-12-31
  ・空リストの出力がおかしかったのを修正

 on 2006-12-13
  ・defunの展開がおかしかったのを修正
  ・do, do* の展開を改善
  ・時々、空行ができてしまうのを修正
  ・lpp のマクロ定義がおかしかったのを修正

 on 2006-12-08
  ・keyword-package ～ というエラーが出るのを修正

 on 2006-12-08
  ・公開

|#



(in-package "editor")
(provide "lpp")

(export '(pprint-eval-print-last-sexp
	  *pprint-eval-region*
	  *pprint-string-no-eval*
	  *pprint-linebreak-list*
	  pretty-print-list
	  lpp))

(defvar *pprint-eval-region* nil)
(defvar *pprint-string-no-eval* nil
  "t で文字列中のエスケープシーケンスによるタブ文字・改行文字をなるべく変えないようにします。")
; (push :debug *features*)

(defvar *pprint-linebreak-list* nil
  "インデントが与えられていないリストの要素での改行の仕方
    nil : 改行しない。
    non-nil : 積極的に改行する。")

#+:debug
(progn
  (defvar *pp-debug* nil)
  (if (or (null *pp-debug*)
	  (deleted-buffer-p (buffer-stream-buffer *pp-debug*)))
      (let ((buffer (get-buffer-create "*pp debug*")))
	(setq *pp-debug* (make-buffer-stream buffer)))))

(defun set-indent-type-function ()
  (if (boundp '*lisp-indent-hook*)
      (defun get-indent-type (symbol)
	(gethash symbol *lisp-indent-hook*))
    (defun get-indent-type (symbol)
      (get symbol 'lisp-indent-hook))))
(set-indent-type-function)

(defun pprint-2 (s0)
  (long-operation
      (save-restriction
	(let ((opoint (point)))
	  (backward-sexp)
	  (narrow-to-region (point) opoint)
	  (goto-char opoint)
	  (if (and *print-circle*
		   (null (list-length s0)))
	      (prin1 s0)
	    (pp-loop1 s0))
	  (terpri)
	  (indent-region opoint (point-max))
	  (goto-char (point-max))))))
 
(defun pp-body-list (cdrs0)
  (pp-loop1 (car cdrs0))
  (dolist (element (cdr cdrs0))
    (terpri)
    (pp-loop1 element t)))

(defun pp-symbol-other-list (cdrs0)
  "() or (symbol elm .. elm)"
  (cond ((null cdrs0)
	 (princ "()"))
	((consp cdrs0)
	 (princ "(")
	 (prin1 (car cdrs0)) ;; symbol
	 (dolist (elm (cdr cdrs0))
	   (princ #\SPC)
	   (pp-loop1 elm))
	 (princ ")"))
	(t
	 (pp-loop1 cdrs0))))

(defun pp-let-arg (arg)
  ;(msgbox "let ~A" arg)
  (flet ((print-one-kind (cdrs0)
	   (cond ((symbolp (car cdrs0))
		  (prin1 (car cdrs0))
		  (setq cdrs0 (cdr cdrs0))
		  (let ((tmp (car cdrs0)))
		    (while (and tmp (symbolp tmp))
		      (princ #\SPC)
		      (princ tmp)
		      (setq cdrs0 (cdr cdrs0)
			    tmp (car cdrs0)))))
		 ((consp (car cdrs0))
		  (pp-symbol-other-list (car cdrs0))
		  (setq cdrs0 (cdr cdrs0))
		  (while (consp (car cdrs0))
		    (terpri)
		    (pp-symbol-other-list (car cdrs0))
		    (setq cdrs0 (cdr cdrs0)))))
	   cdrs0))
    (princ "(")
    (if arg
	(setq arg (print-one-kind arg)))
    (while arg
      (terpri)
      (setq arg (print-one-kind arg)))
    (princ ")")))

(defun pp-cond-body1 (body)
  (princ "(")
  (if (consp body)
      (progn
	(pp-loop1 (car body))
	(if (or (consp (safe-cddr body))
		(consp (safe-cadr body)))
	    (dolist (element (cdr body))
	      (terpri)
	      (pp-loop1 element t))
	  (progn
	    (princ #\SPC)
	    (pp-loop1 (cadr body)))))
    (pp-loop1 body))
  (princ ")"))

(defun pp-cond (sym body)
  (princ "(")
  (prin1 sym)
  (princ #\SPC)
  (if (consp body)
      (progn
	(pp-cond-body1 (car body))
	(dolist (elm (cdr body))
	  (terpri)
	  (pp-cond-body1 elm)))
    (pp-loop1 body))
  (princ ")"))

(defun pp-case (body)
  (dolist (elm body)
    (terpri)
    (pp-cond-body1 elm)))

(defun pp-quote (cars0 cdrs0 &optional refreshed)
  (if (eq cars0 'quote)
      (princ #\')
    (progn
      (if (not refreshed)
	  (if (consp (car cdrs0))
	      (terpri)))
      (princ "#'")))
  (when (consp (car cdrs0))
    (pp-loop1 (car cdrs0))
    (setq cdrs0 (cdr cdrs0)))
  (if cdrs0
      (pp-body-list cdrs0)))

(defun pp-setf (cars0 cdrs0)
  (princ "(")
  (prin1 cars0)
  (princ #\SPC)
  (pp-loop1 (car cdrs0))
  (princ #\SPC)
  (pp-loop1 (cadr cdrs0))
  (setq cdrs0 (cddr cdrs0))
  (while cdrs0
    (terpri)
    (pp-loop1 (car cdrs0) t)
    (princ #\SPC)
    (pp-loop1 (cadr cdrs0))
    (setq cdrs0 (cddr cdrs0)))
  (princ ")"))

(let ((keyword-package (find-package "keyword")))
  (defun lpp-set-keyword-package ()
    (setq keyword-package (find-package "keyword")))
  (add-hook '*post-startup-hook* 'lpp-set-keyword-package)
  
  (defun simple-data-p (obj)
    (or (symbolp obj)
	(stringp obj)
	(numberp obj)
	(functionp obj)
	(regexpp obj)))

  (defun pp-keyword-list-indent (cdrs0 &optional linebreak)
    (let ((simple-data (and (eq linebreak :smart)
                            (every #'simple-data-p cdrs0)))
          last-keyword)
      (if simple-data
          (format *standard-output* "~{ ~W~}" cdrs0)
        (dolist (elem cdrs0)
	  (cond ((simple-data-p elem)
		 (terpri)
		 (prin1 elem))
		((and (symbolp elem)
		      (equal (symbol-package elem) keyword-package))
                 (terpri)
                 (setq last-keyword t)
                 (pp-loop1 elem t))
                ((or (not linebreak) last-keyword)
                 (princ #\SPC)
                 (setq last-keyword nil)
                 (pp-loop1 elem))
                (t
                 (terpri)
                 (setq last-keyword nil)
                 (pp-loop1 elem t)))))))


  (defun pp-other-indent (cars0 cdrs0)
    (princ "(")
    (prin1 cars0)
    (cond ((find cars0 '(and or))
           (when cdrs0
             (princ #\SPC)
	     (pp-body-list cdrs0)))
	  ((null cdrs0))
          ((consp cdrs0)
	   (pp-keyword-list-indent cdrs0 *pprint-linebreak-list*))
	  (t
           (princ " . ")
           (pp-loop1 cdrs0)))
    (princ ")"))

  ;(defun pp-other-indent (cars0 cdrs0)
  ;  (princ "(")
  ;  (prin1 cars0)
  ;  (cond ((find cars0 '(and or))
  ;         (when cdrs0
  ;           (princ #\SPC)
  ;           (pp-body-list cdrs0)))
  ;        ((consp cdrs0)
  ;         (dolist (elem cdrs0)
  ;           (if (and (symbolp elem)
  ;                    (equal (symbol-package elem) keyword-package))
  ;               (progn
  ;                 (terpri)
  ;                 (pp-loop1 elem t))
  ;             (progn
  ;               (princ #\SPC)
  ;               (pp-loop1 elem)))))
  ;        (t
  ;         (princ " . ")
  ;         (pp-loop1 cdrs0)))
  ;  (princ ")"))

  )

(defun pp-defun (cars0 cdrs0 &optional no-print-cars0)
  (princ "(")
  (unless no-print-cars0
    (prin1 cars0)
    (princ #\SPC))
  (prin1 (car cdrs0))
  (princ #\SPC)
  (pp-symbol-other-list (cadr cdrs0))
  (dolist (element (cddr cdrs0))
    (terpri)
    (pp-loop1 element))
  (princ ")"))

(defun pp-number-indent (indent cars0 cdrs0)
  (princ "(")
  (prin1 cars0)
  (unless (= indent 0)
    (princ #\SPC)
    (if (and (find cars0 '(let let* do do*))
	     (listp cdrs0)
	     (listp (car cdrs0)))
	(pp-let-arg (car cdrs0))
      (pp-loop1 (car cdrs0)))
    (setq cdrs0 (cdr cdrs0)))
  (if (eql cars0 'case)
      (pp-case cdrs0)
    (dolist (element cdrs0)
      (terpri)
      (pp-loop1 element t)))
  (princ ")"))

(defun pp-structure (s0)
  (let ((sdef (si:*structure-definition s0)))
    (princ "#S(")
    (prin1 (si:*structure-definition-name sdef))
    (dotimes (n (si:*structure-definition-nslots sdef))
      (terpri)
      (princ (si:*structure-definition-slot-description sdef n))
      (princ #\SPC)
      (pp-loop1 (si:*index-slot-value s0 n)))
    (princ ")")
    ))

(defun pp-loop1 (s0 &optional refresh)
  ;#+:debug (msgbox "pp-loop1 ~A" s0)
  (cond ((consp s0)
	 (let ((cars0 (car s0)))
	   #+:debug (format *pp-debug* "・cons : ~A\n" cars0)
	   (cond  ((symbolp cars0)
		   (let ((indent (get-indent-type cars0))
			 (cdrs0 (cdr s0)))
		     (cond ;; number
			  ((numberp indent)
			   #+:debug (format *pp-debug* "  ・number indent : ~A (level: ~A)\n"
					    cars0 indent)
			   (pp-number-indent indent cars0 cdrs0)
			   )
			  ;; defun
			  ((eq 'defun indent)
			   #+:debug (format *pp-debug* "  ・defun indent : ~A\n" cars0)
			   (pp-defun cars0 cdrs0)
			   )
			  ;; null indent
			  ((null indent)
			   #+:debug (format *pp-debug* "  ・null indent : ~A\n" cars0)
			   (cond ;; quote
				((or (eq cars0 'quote)
				     (eq cars0 'function))
				 (pp-quote cars0 cdrs0))
				;; setf/setq
				((find cars0 '(setf setq psetq psetf))
				 (pp-setf cars0 cdrs0))
				((eq cars0 'cond)
				 (pp-cond cars0 cdrs0))
				;; other indent
				(t
				 (pp-other-indent cars0 cdrs0))))
			  (t
			   (prin1 s0)))))
		  (*pprint-linebreak-list*
		   #+:debug (format *pp-debug* "・not-symbol : ~S\n" cars0)
		   (pp-other-indent cars0 (cdr s0)))
		  (t
		   #+:debug (format *pp-debug* "・not-symbol : ~A\n" cars0)
		   (prin1 s0)))))
	((si:*structurep s0)
	 #+:debug (format *pp-debug* "・structure :\n")
	 (pp-structure s0)
	 )
	((and *pprint-string-no-eval*
	      (stringp s0))
	 (let ((sbuffer (selected-buffer)))
	   #+:debug (format *pp-debug* "・string : ~a\n" s0)
	   (set-buffer (buffer-stream-buffer *standard-output*))
	   (let ((opoint (point))
		 (len (+ (length s0) 2)))
	     (goto-char (buffer-stream-point *standard-output*))
	     (insert #\")
	     (map nil #'(lambda (x)
			  (cond ((eql x #\TAB)
				 (insert "\\t")
				 (incf len))
				((eql x #\LFD)
				 (insert "\\n")
				 (incf len))
				(t
				 (insert x))))
		  s0)
	     (insert #\")
	     (buffer-stream-set-point *standard-output*
				      (+ (buffer-stream-point *standard-output*) len))
	     (goto-char opoint)
	     (set-buffer sbuffer)
	     ))
	 )
	(t
	 #+:debug (format *pp-debug* "・all the other : ~A\n" s0)
	 (prin1 s0)))
  t)



;;. eval-print-last-sexp を pretty print で整形して出力
(defun pprint-eval-print-last-sexp ()
  (interactive "*")
  (let ((*pprint-eval-region* t))
    (eval-print-last-sexp)))

(defmacro lpp (macro)
  `(pprint-2 (macroexpand ',macro)))


;;-----------------------------------------------------------------------------

(defun eval-last-print-sexp1 (stream from to &optional pprint)
  (save-excursion
    (and (save-excursion
	   (scan-buffer "^[ \t]*(in-package[ \t\n]+\"\\([^\"]+\\)" :regexp t :reverse t))
	 (setq package (find-package (match-string 1)))
	 (setq *package* package))
    (unwind-protect
	(eval-region from to
		     (cond ((or (streamp stream)
				(bufferp stream))
			    stream)
			   (stream
			    (selected-buffer))
			   (t nil))))))

;; 実行するとき，直前の (in-package ～) を探して，そのパッケージで実行
;; #S(...) だったら、#Sも含めて評価
;; #1=(...) などだったら、#1=も含めて評価
;; 副作用として、実行ごとにパッケージが元に戻されます。
;; 変更したい時は、eval-expression (Esc Esc) で変更してください。
(defun eval-last-sexp (&optional stream)
  (interactive "p")
  (let ((syntab (syntax-table)))
    (let ((*package* *package*)
	  from to package)
      (declare (special *package*))
      (cond ((selection-start-end (start end)
	       (setq from start
		     to end)))
	    (t
	     (use-syntax-table *lisp-mode-syntax-table*)
	     (unwind-protect
		 (let ((opoint (point)))
		   (backward-sexp)
		   (setq from (if (looking-back "#S")
				  (- (point) 2)
				(point)))
		   (if (equal #\= (preceding-char))
		       (save-excursion
			 (forward-char -1)
			 (and (skip-chars-backward "1234567890")
			      (equal #\# (preceding-char))
			      (setq from (1- (point))))))
		   (forward-sexp)
		   (setq to (point))
		   (goto-char (max opoint to)))
	       (use-syntax-table syntab))))
      (eval-last-print-sexp1 stream from to))))



(defun eval-last-sexp-and-quoted-hook (&optional stream)
  (interactive "p")
  (let ((syntab (syntax-table)))
    (let ((*package* *package*)
	  from to package quotedp)
      (declare (special *package*))
      (cond ((selection-start-end (start end)
	       (setq from start
		     to end)))
	    (t
	     (use-syntax-table *lisp-mode-syntax-table*)
	     (unwind-protect
		 (let ((opoint (point)))
		   (backward-sexp)
		   (setq from (if (looking-back "#S")
				  (- (point) 2)
				(point)))
		   (if (eql (following-char) #\')
		       (setq quotedp t))
		   (if (equal #\= (preceding-char))
		       (save-excursion
			 (forward-char -1)
			 (and (skip-chars-backward "1234567890")
			      (equal #\# (preceding-char))
			      (setq from (1- (point))))))
		   (forward-sexp)
		   (setq to (point))
		   (when quotedp
		     (if (eql (preceding-char) #\*)
			 (forward-char -1))
		     (if (or (looking-back "-hook")
			     (looking-back "-list"))
			 (incf from)))
		   (goto-char (max opoint to)))
	       (use-syntax-table syntab))))
      (let ((*pprint-eval-region* t))
	(popup-string
	     (format nil "\n ~A \n" (eval-last-print-sexp1 stream from to))
	     (point))))))
  

(defun eval-region (from to &optional stream)
  (interactive "r")
  (let ((result nil))
    (when (> from to)
      (rotatef from to))
    (let ((s (make-buffer-stream (selected-buffer) from to)))
      (handler-case
	  (let ((*package* *package*))
	    (while (< (buffer-stream-point s) to)
	      (let ((form (read s nil '#1=#:eof)))
		(when (eq form '#1#)
		  (return))
		(setq result (multiple-value-list (eval form))))))
	((or error reader-error quit) (c)
	  (when (<= (buffer-stream-point s) to)
	    (goto-char (buffer-stream-point s))
	    (when stream
	      (eval-region-print stream
		(format t "~A~%" c)))
	    (let ((si:*trace-on-error* nil))
	      (error c))))))
    (eval-region-print stream
      (if (null stream)
	  (message "~s" (car result))
	(if *pprint-eval-region*
	    (dolist (elem result)
	      (pprint-2 elem))
	  (format t "~{~S~%~}" result))))
    (values-list result)))


;;-----------------------------------------------------------------------------
;;  pretty-print-list

(defvar *max-column* 80)
(defvar *linebreak-threshold-length* 30)
(defun pretty-print-list ()
  "バッファ内のリストを桁位置・括弧により整形処理する。
整形処理したいリストの先頭の開き過去の上で実行する"
  (interactive "*")
  (long-operation
    (save-excursion
      (let* ((from (point))
	     (to (progn
		   (forward-sexp)
		   (point))))
	(save-restriction
	  (narrow-to-region from to)
	  (goto-char from)
	  (pretty-print-list1))))))

(defun pretty-print-list1 ()
  (let ((pbegin (point)))
    (while (forward-sexp)
      ;; sexp内のインデント処理
      (and (syntax-close-p (preceding-char))
	   (or (> (current-line-columns) *max-column*)
	       (save-excursion
		 (let ((opoint (point)))
		   (forward-sexp -1)
		   (> (- opoint (point)) *max-column*))))
	   (let ((omarker (set-marker (make-marker))))
	     (forward-sexp -1)
	     (forward-char 1)
	     (pretty-print-list1)
	     (goto-marker omarker)
	     (unset-marker omarker)))

      ;; sexp 後の区切り
      (delete-trailing-spaces)
      (let ((ch1 (following-char))
	    (ch2 (char-after (1+ (point)))))
	(cond ((eolp)
	       (forward-char))
	      ((syntax-close-p ch1)
	       (forward-char 1)
	       (return))
	      ((or (syntax-open-p ch1)
		   (syntax-open-p ch2))
	       (insert #\LFD))
	      (t
	       (let ((tpoint (point)))
		 (forward-sexp)
		 (if (> (current-column) *max-column*)
		     (progn
		       (goto-char tpoint)
		       (insert #\LFD))
		   (goto-char tpoint))))
	      ))
      (lisp-indent-line)

      (setq pbegin (point))
      ))

  ;; 後処理
  (if (syntax-close-p (char-after (1+ (point))))
      (forward-char))
  ;(next-line))
  )

