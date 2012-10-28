;;
#|text
■機能
 lisp用のmaketagsを上書きします．
  元のコードとの差分は
 ・tag生成過程のエラー補足の追加．
 ・defstructへの対応
 ・defmethod defgeneric si::defun-builtin defsetf define-setf-method
   deftype defpred define-history-variable の追加
 ・defconstの追加
 ・let/progn 等の内側探索
 ・(si:*fset 'xxx yyy) / (setf (symbol-function 'xxx) yyy) の対応
となっています．

■インストール
 .xyzzy か siteini.l に下のを書いてください．
  ni-autoload を使用している人は必要ありません。
 (require "ext-lisp-maketags")

■使用方法
  メニューのTAGSファイルの作成の時に使われます。

■注意事項
 lisp-maketags を上書きします．

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


copyright 2006-2008   Masahiro Nakano

・Author 
    Masahiro Nakano <mnakano.gm@gmail.com>


■更新履歴
 on 2008-04-15
  ・ffiの関数に対応 (define-dll-entryなど)
  ・タグファイルの行頭に空白が入ってしまうバグを修正

 on 2008-01-8
  ・or の中もチェックするように変更

 on 2007-02-09
  ・setq-default もタグ付けするように (ただし、関数定義内等は対象外)

 on 2007-01-13
  ・define-history-variable に対応

 on 2006-12-08
  ・途中でパーズできないS式が出てきても無視して続けるように。
  ・ni-autoload でうまくロードできなかったのを修正。

 on 2006-11-21
  ・ライセンス条項追加
  ・autoload化
  ・細かな修正

 on 2006-11-21
  ・公開
|#

(provide "ext-lisp-maketags")
(require "lispfns")
(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "foreign"))

(in-package "editor")
(defun lisp-maketags (file count)
  (let (package within-acc)
    (unwind-protect
	(progn
	  (do ((i 0 (+ i 1)))
	      ((let ((name (format nil "MAKETAGS-~D" i)))
		 (unless (find-package name)
		   (setq package (make-package name :external-size 0))))))
	  (with-input-from-buffer ((selected-buffer) (point-min))
	    (let ((*package* package) struct stp concname tmp
		  (defvar-local (intern "defvar-local" package))
		  (define-history-variable (intern "define-history-variable" package))
		  (setq-default (intern "setq-default" package))
		  (with-accessors (intern "with-accessors" package)))
	      (labels ((parsing (form)
			 (cond ((or (atom form)
				    (atom (cdr form))
				    ;(not (symbolp (cadr form)))
				    ))
			       ((find (car form)
				      '(defun defmacro defmethod defgeneric si::defun-builtin
					defsetf define-setf-method deftype define-modify-macro)
				      :test #'eq)
				(format t "~A~A~D" (symbol-name (cadr form)) file
					(buffer-stream-point *standard-input*))
				(setq count (1+ count)))

			       ((find (car form) `(defvar defparameter defconstant defconst
						    ,defvar-local ,define-history-variable))
				(format t "~A~A~D" (symbol-name (cadr form)) file
					(buffer-stream-point *standard-input*))
				(setq count (1+ count)))
			       ;; let / let* / block / eval-when
			       ((find (car form) '(let let* eval-when block unless))
				(dolist (f (cddr form))
				  (parsing f)))
			       ;; progn / prog1 /prog2
			       ((find (car form) '(progn prog1 prog2 or if))
				(dolist (f (cdr form))
				  (parsing f)))
			       ;; si:*fset
			       ((eq (car form) 'si:*fset)
				(setq tmp (cadr form))
				(when (and (eq (car tmp) 'quote)
					   (symbolp (cadr tmp)))
				  (format t "~A~A~D" (symbol-name (cadr tmp)) file
					  (buffer-stream-point *standard-input*))
				  (setq count (1+ count))))
			       ((eq (car form) setq-default)
				(format t "~A~A~D" (cadr form) file
					(buffer-stream-point *standard-input*))
				(setq count (1+ count)))
			       ;; setf / setq-default
			       ((eq (car form) 'setf)
				(let ((cadrform (cadr form)))
				  (when (and (consp cadrform)
					     (eq (car cadrform) 'symbol-function)
					     (consp (cadr cadrform))
					     (eq (caadr cadrform) 'quote)
					     )
				    (format t "~A~A~D" (cadadr cadrform) file
					    (buffer-stream-point *standard-input*))
				    (setq count (1+ count)))))
			       ;; define-dll-entry系
			       ((find (car form) '(foreign:*define-dll-entry foreign:define-dll-entry
						   foreign:*defun-c-callable foreign:defun-c-callable))
				(let ((fname (third form)))
				  (format t "~A~A~D" fname file (buffer-stream-point *standard-input*))
				  (setq count (1+ count))
				  ))
			       ;; defstruct
			       ((eq (car form) 'defstruct)
				(setq tmp (cadr form)
				      stp (buffer-stream-point *standard-input*))
				(if (listp tmp)
				    (progn
				      (setq struct (symbol-name (car tmp))
					    concname (concat struct "-"))
				      (dolist (option (cdr tmp))
					(case (car option)
					  (|:include|)
					  ((|:predicate| |:copier| |:constructor|)
					   (when (cadr option)
					     (format t "~A~A~D" (cadr option) file stp)
					     (setq count (1+ count))))
					  (|:conc-name|
					   (setq concname (string-downcase (cadr option)))))))
				  (setq struct (symbol-name tmp)
					concname (concat (string-downcase struct) "-")))
				(format t "~A~A~D" struct file stp)
				(setq count (1+ count))
				; constructer
				(format t "make-~A~A~D" struct file stp)
				; struct-name-p
				(format t "~A-p~A~D"    struct file stp)
				; accessor
				(let ((acc-name (car within-acc))
				      slot-name type)
				  (dolist (slot (if (stringp (caddr form))
						    (cdddr form)
						  (cddr form)))
				    (if (listp slot)
					(progn
					  (setq slot-name (car slot))
					  (if (setq type (member :type slot))
					      (setq type (cadr type))))
				      (setq slot-name slot
					    type nil))

				    (if (listp slot-name)
					(setq slot-name  (car slot-name)))
				    (format t "~A~A~A~D~A" concname slot-name file stp
					    (if type (format nil "~A -> ~A" struct type) ""))
				    (setq count (1+ count))
				    (when acc-name
				      (format t "~A~A~A~A~D~A"
					      acc-name concname slot-name file stp
					      (if type (format nil "~A -> ~A" struct type) ""))
				      (setq count (1+ count))))))
			       ((eq (car form) with-accessors)
				(push (caadr form) within-acc)
				(dolist (f (cddr form))
				  (parsing f))
				(pop within-acc))
			       ;(t (msgbox "~W\n~A=?=~A" (car form)
			       ;           (symbol-package (car form))
			       ;           (symbol-package 'with-accessors)))

			       #|
; defclass (実装途中)
((eq (car form) 'defclass)
 (setq struct (symbol-name (cadr form))
       concname (concat struct "-")
       stp (buffer-stream-point *standard-input*))
 (format t "~A~A~D" struct file stp)
 (setq count (1+ count))
 ;; constructer
 (format t "make-~A~A~D" struct file stp)
 ;; struct-name-p
 (format t "~A-p~A~D"    struct file stp)
 ;; accessor
 (dolist (slot-name (cadddr form))
   (donlist ((kind funname) (cdar slot-name))
     (cond ((find kind '(|:accessor| |:writer| |:reader|))
	    (format t "~A~A~A~D" concname (car slot-name) file stp)
	    (setq count (1+ count)))
	   )))
 )
|#
			       ;((not (member (car form) '(eval eval-when provide define-key)))
			       ; (msgbox "~A" form))
			       )))
		(handler-case
		    (do ((form (ignore-errors (read nil nil '#1=#:eof))
			       (ignore-errors (read nil nil '#1#))))
			((eq form '#1#))
		      (do-events)
		      (parsing form))
		  (cell-error () nil) ;; handleするエラーを追加した
		  (type-error () nil) ;;
		  (package-error () nil)
		  (reader-error () nil))))))
      (when package
	(delete-package package))))
  count)
