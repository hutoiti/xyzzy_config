;; -*- Mode: lisp; outline-tree: user-regexp-lisp-dots; -*-
#|text
■機能
様々な文字の入力を、キーバインド・リージョン内の置換・abbrev風入力によ
って行います。

$XYZZY/.insert-character.sample を $XYZZY/.insert-character に名前を変
更するなどして、そこで設定してください。

sampleの設定ファイルとデフォルトのキーバインドでは、
  ・C-? a で α が入力できます。
  ・M-x texify-on をすると、\alpha と入力すると、α が入力されます。

■インストール
  $XYZZY/.insert-character.sample を $XYZZY/.insert-character に名前を
  変更してください。

  ni-autoload 使用している人は以下は不要です。
  site-lisp.l か .xyzzy に以下を追加してください。

    (require "insert-character")

  必要であれば、ダンプしてxyzzyを立ち上げなおして下さい。


■注意点
  あるモードでは、ステータスバーに表示されている候補を入力しても、入力
  を認識してくれないことがあります。これは、キーに割り当てられているコ
  マンドが self-insert-command ではないからです。この場合、関数内で
     (setq *this-command* 'ed::self-insert-command)
  を行い、self-insert-command に見せかけてください。

■ライセンス
 Copyright (C) 2008 Masahiro NAKANO <mnakano.gm あっと gmail.com>

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

■更新履歴
 on 2008-12-27
  ・公開

|#

(in-package "editor")
(export '(toggle-texify
	  texify-on
	  texify-off
	  insert-character-key-definition
	  texify-region
	  texify-buffer
	  texify-line
	  *character-keymap-key*
	  *character-key-definition*
	  *character-keymap*
	  ))

;;--------------------------------------------------------------------------
;;.                     debug
;;--------------------------------------------------------------------------
;; (pushnew :ic-debug *features*)
;; (setq *features* (delete :ic-debug *features*))
#+:ic-debug (progn
	      (defvar *ic-debug* nil)
	      (defun ic-set-debug-stream ()
		(let ((buffer (get-buffer-create "*ic debug*")))
		  (erase-buffer buffer)
		  (setup-temp-buffer buffer)
		  (setq *ic-debug* (make-buffer-stream buffer))))
	      (defun ic-scroll-debug-window ()
		(let ((buffer (find-buffer "*ic debug*")))
		  (if buffer
		      (let ((window (get-buffer-window buffer))
			    (swindow (selected-window)))
			(save-excursion
			  (set-buffer buffer)
			  (set-buffer-fold-type-none))
			(when window
			  (set-window window)
			  (goto-char (point-max))
			  (set-window swindow)
			  (refresh-screen)
			  )))))

	      (defun ic-unset-debug-stream ()
		(let ((buffer (find-buffer "*ic debug*")))
		  (when buffer
		    (delete-buffer buffer)
		    (setq buffer nil
			  *ic-debug* nil))))

	      (defun ic-toggle-debug-mode (&optional (arg nil sv))
		(interactive)
		(ed::toggle-mode '*ic-debug* arg sv)
		(if *ic-debug*
		    (progn
		      (ic-set-debug-stream)
		      (message "cc-tags debug mode on"))
		  (progn
		    (ic-unset-debug-stream)
		    (message "cc-tags debug mode off")
		    nil)))
	      (ic-toggle-debug-mode t)

	      (eval-when (:compile-toplevel :load-toplevel :execute)
		(defmacro icdbg (fmt &rest body)
		  `(if *ic-debug*
		       (format *ic-debug* ,fmt ,@body))))

	      )
#-:ic-debug (if (fboundp 'ic-toggle-debug-mode)
		(ic-toggle-debug-mode nil))


;;--------------------------------------------------------------------------
;;.                     character-key-definition
;;--------------------------------------------------------------------------

(defvar *character-keymap-key* #\DEL) ;; C-?
(defvar *character-key-definition* nil)
(defvar *character-keymap* nil)
(defvar *insert-chracter-show-candidates* t)
(defvar *insert-character-backward-delete-commands*
  '(undo
    delete-backward-char
    delete-backward-char-or-selection
    backward-delete-char-untabify
    backward-delete-char-untabify-or-selection
    ))

(defvar *insert-character-latex-command* nil)


(setf (symbol-function 'chkd-name)         #'car)
(setf (symbol-function 'chkd-string-or-code) #'cadr)
(setf (symbol-function 'chkd-keybind)      #'caddr)
(setf (symbol-function 'chkd-texcommand)   #'cadddr)


;;--------------------------------------------------------------------------
;;.                     update-character-keymap
;;--------------------------------------------------------------------------

(defun update-character-keymap ()
  (let ((keymap (make-sparse-keymap)))
    (dolist (x *character-key-definition*)
      (cond ((numberp (chkd-string-or-code x))
	     (setf (symbol-function (chkd-name x))
		   `(lambda ()
		      (interactive "*")
		      (insert ,(unicode-char (chkd-string-or-code x))))))
	    ((stringp (chkd-string-or-code x))
	     (setf (symbol-function (chkd-name x))
		   `(lambda ()
		      (interactive "*")
		      (insert ,(chkd-string-or-code x)))))
	    )
      (if (chkd-keybind x)
	  (define-key keymap (chkd-keybind x) (chkd-name x))))
    (define-key keymap #\/ 'texify-line)
    (define-key keymap #\C-/ 'texify-line)
    (setq *character-keymap* keymap)))


;;--------------------------------------------------------------------------
;;.                     update-character-latex-command
;;--------------------------------------------------------------------------
(defvar *insert-character-latex-commands-start-chars* nil)
(defun insert-character-add-latex-command (name insert-word commands)
  ;#+:ic-debug (icdbg "    adding: ~A\n" name)
  (let ((len (length name))
	(pointer commands)
	npointer ch)
    (dotimes (i len)
      (setq ch (schar name i))
      (setq npointer (assoc ch (cddr pointer) :test 'eql))
      (unless npointer
	(setq npointer (list ch nil))
	(push npointer (cddr pointer)))
      (setq pointer npointer))
    (if npointer
	(setf (cadr npointer) insert-word))
    commands))

(defun update-character-latex-command ()
  (let ((commands '(nil nil))
	com)
    (dolist (x *character-key-definition*)
      (when (and (setq com (chkd-texcommand x))
		 (stringp com)
		 (not (equal "" com)))
	(setq commands (insert-character-add-latex-command
			(regexp-to-string com) (chkd-string-or-code x) commands))))
    (labels ((commands-sort (commands)
	       (setf (cddr commands) (sort (cddr commands) 'char< :key 'car))
	       (dolist (item (cddr commands))
		 (commands-sort item))))
      (commands-sort commands)
      commands)))

(defun update-character-latex-commands-start-chars ()
  (format nil "~{~A~}" (mapcar #'car (cddr *insert-character-latex-command*))))

;;--------------------------------------------------------------------------
;;.                     insert-character-latex-command
;;--------------------------------------------------------------------------
(let (begin end input pointer buffer)
  (defun insert-character-latex-command ()
    (unless *texify-minor-mode*
      (return-from insert-character-latex-command))
    (unless (cddr *insert-character-latex-command*)
      (load-insert-character-config)
      (setq *insert-character-latex-command* (update-character-latex-command))
      (setq *insert-character-latex-commands-start-chars* (update-character-latex-commands-start-chars)))
    ;(popup-string (format nil "~w\n~w" *this-command* *last-command-char*) (point))
    (cond ((not (equal buffer (selected-buffer)))
	   #+:ic-debug (icdbg "cleared\n")
	   (setq begin nil
		 pointer nil
		 input nil
		 buffer (selected-buffer)))
	  ((eq *this-command* 'self-insert-command)
	   #+:ic-debug (icdbg "inserted: ~A\n" *last-command-char*)
	   (cond ((and begin
		       (setq pointer (assoc *last-command-char*
					    (if pointer
						(cddr pointer)
					      (cddr *insert-character-latex-command*))
					    :test 'eql)))
		  (setq end (point))
		  (push *last-command-char* input)
		  #+:ic-debug (icdbg "  pointer: ~w\n" pointer)
		  (and (cddr pointer)
		       *insert-chracter-show-candidates*
		       (insert-character-show-candidates pointer))
		  (if (cadr pointer)
		      (insert-latex-command (cadr pointer) begin end)))
		 ((find *last-command-char* *insert-character-latex-commands-start-chars* :test 'eql)
		  (setq begin (1- (point))
			buffer (selected-buffer)
			end (point)
			pointer (assoc *last-command-char*
				       (if pointer
					   (cddr pointer)
					 (cddr *insert-character-latex-command*))
				       :test 'eql)
			input (list *last-command-char*)
			)
		  (and (cddr pointer)
		       *insert-chracter-show-candidates*
		       (insert-character-show-candidates pointer))
		  #+:ic-debug (icdbg "  set begin: ~A\n" begin))
		 (t
		  #+:ic-debug (icdbg "cleared\n")
		  (setq begin nil
			pointer nil)
		  )))
	  ((and begin (find *this-command* *insert-character-backward-delete-commands*))
	   (setq input (cdr input)
		 end (point))
	   (cond ((<= end begin)
		 #+:ic-debug (icdbg "cleared\n")
		 (setq begin nil
		       pointer nil))
		 (t
		  #+:ic-debug (icdbg "back\n")
		  (setq pointer (insert-character-traverse-pointer (reverse input)))))
	   (and (cddr pointer)
		*insert-chracter-show-candidates*
		(insert-character-show-candidates pointer))
	   )
	  (t
	   #+:ic-debug (icdbg "cleared\n")
	   (setq begin nil
		 pointer nil)
	   )
	  )))

(defun insert-character-traverse-pointer (rinput)
  (let ((pointer *insert-character-latex-command*))
    (dolist (ch rinput)
      (setq pointer (find ch (cddr pointer) :test 'eql :key 'car))
      (or pointer
	  (return)))
    pointer))
  

(defun insert-character-show-candidates (pointer)
  (if (>= (insert-character-count-candidate pointer 3) 3)
      (message "~@[Or [~{~A~}~]]" (mapcar #'car (cddr pointer)) :test 'eql)
    (message "candidate: ~{~A~^ or ~}" (nreverse (insert-character-listup-candidate pointer)))))

(defun insert-character-count-candidate (pointer max)
  (let ((count 1))
    (labels ((cc (pointer)
	       (let ((len (length (cddr pointer))))
		 (setq count (+ count len (if (cadr pointer) 0 -1)))
		 (if (>= count max)
		     (return-from insert-character-count-candidate count))
		 (dolist (item (cddr pointer))
		   (cc item)))))
      (cc pointer)
      ;(popup-string (format nil "count: ~A" count) (point))
      count)))

(defun insert-character-listup-candidate (pointer)
  (let (cand)
    (labels ((cc (pointer chars)
	       (let ((len (length (cddr pointer))))
		 (if (cadr pointer)
		     (push chars cand))
		 #+:ic-debug (icdbg "  chars: ~A\n" chars)
		 (dolist (item (cddr pointer))
		   (cc item (cons (car item) chars))))))
      (cc pointer nil)
      (mapcar #'(lambda (x) (format nil "~{~A~}" (reverse x))) cand))))

(defun insert-latex-command (string-or-code begin end)
  (let ((opoint (point)))
    (when string-or-code
      #+:ic-debug (icdbg "delete-region ~A ~A\n" begin end)
      (delete-region begin end)
      (goto-char begin)
      (insert (if (numberp string-or-code)
		  (string (unicode-char string-or-code))
		string-or-code))
      (setq opoint (+ (- (point) begin) (- begin end) opoint)))
    (goto-char opoint)
    ))

;;---------------------------------------------------------
;;..                     minor-mode 

(defvar-local *texify-minor-mode* nil)

(defun toggle-texify (&optional (arg nil sv))
  (interactive)
  (ed::toggle-mode '*texify-minor-mode* arg sv)
  (update-mode-line t))

(pushnew '(*texify-minor-mode* . "Texify") *minor-mode-alist* :key #'car)

(defun texify-on ()
  (interactive)
  (toggle-texify t))

(defun texify-off ()
  (interactive)
  (toggle-texify nil))

(add-hook '*post-command-hook* 'insert-character-latex-command)

;; (insert-unicode-char-table)

;;--------------------------------------------------------------------------
;;.                     insert-character
;;--------------------------------------------------------------------------
(defun insert-character-key-definition ()
  (interactive)
  (set-buffer (get-buffer-create "*char*"))
  (erase-buffer (selected-buffer))
  (insert "*character-keymap*:\n")
  (let ((bind (command-keys *character-keymap* *global-keymap* (local-keymap) (minor-mode-map))))
    (if bind
	(cond ((consp bind)
	       (insert "~A" (format nil "binded:\n~{  ~A\n~}"
				    (mapcar #'(lambda (x) (if x (key-to-string x))) bind)))))))
  (insert "\n")
  (dolist (x *character-key-definition*)
    (let ((keys (chkd-keybind x)))
      (cond ((numberp (chkd-string-or-code x))
	     (if (consp keys)
		 (dolist (key keys)
		   (insert (key-to-string key) " "))
	       (if keys
		   (insert (key-to-string keys) " ")))
	     (insert ": " (unicode-char (chkd-string-or-code x)) "\n"))
	    ((stringp (chkd-string-or-code x))
	     (if (consp keys)
		 (dolist (key keys)
		   (insert (key-to-string key) " "))
	       (if keys
		   (insert (key-to-string keys) " ")))
	     (insert ": " (chkd-string-or-code x) "\n")))))
  (goto-char (point-min))
  (setq need-not-save t)
  (let ((keymap (make-sparse-keymap)))
    (define-key keymap #\q '(lambda ()
			     (interactive)
			     (kill-buffer (selected-buffer))))
    (use-keymap keymap)
    ))



;;--------------------------------------------------------------------------
;;.                     texify
;;--------------------------------------------------------------------------

(defun texify-region (from to &optional delp)
  (interactive "*r")
  (save-excursion
    (save-restriction
      (narrow-to-region from to)
      (if (> from to)
	  (rotatef from to))
      (let (command string-or-code)
	(dolist (elm *character-key-definition*)
	  (when (setq command (chkd-texcommand elm))
	    (goto-char from)
	    (setq string-or-code (chkd-string-or-code elm))
	    (replace-buffer command (if (stringp string-or-code)
					string-or-code
				      (string (unicode-char string-or-code)))
			    :regexp t)
	    )
	  )
	))))

(defun texify-buffer ()
  (interactive "*")
  (texify-region (point-min) (point-max)))

(defun texify-selection ()
  (interactive "*")
  (ed::map-selection #'texify-region))

(defun texify-line ()
  (interactive "*")
  (save-excursion
    (texify-region (progn (goto-bol) (point))
		   (progn (goto-eol) (point)))))

;;.
(defun regexp-to-string (regexp)
  (if (regexpp regexp)
      (setq regexp (compiled-regexp-source regexp)))
  (let* ((len (length regexp))
	 (s (make-vector len :element-type 'character))
	 (j 0)
	 (escape 0)
	 ch)
    (do ((i 0 (1+ i)))
	((>= i len))
      (setq ch (schar regexp i))
      (cond ((= escape 0)
	     (if (eql ch #\\)
		 (setq escape (1+ escape))
	       (progn
		 (setf (svref s j) ch)
		 (setq escape 0
		       j (1+ j)))))
	    ((= escape 1)
	     (case ch
	       ((#\< #\> #\b #\B #\w #\W #\` #\')
		(setq escape 0))
	       (#\_
		(if (and (< (1+ i) len)
			 (let ((nch (schar regexp (1+ i))))
			   (or (eql nch #\<)
			       (eql nch #\>))))
		    (setq i (1+ i)
			  escape 0)
		  (progn
		    (setf (svref s j) #\_)
		    (setq escape 0
			  j (1+ j)))))
	       ((#\s #\S)
		(setq i (1+ i))
		)
	       (t
		(setf (svref s j) #\\)
		(setq escape 0
		      j (1+ j)))
	       ))))
    (substring s 0 j)))

;;--------------------------------------------------------------------------
;;.                     insert-formated-number
;;--------------------------------------------------------------------------

(define-history-variable formated-number-history nil)
(setf (get 'formated-number-history 'ed::minibuffer-history-variable) 'formated-number-history)

(defun insert-formated-number (form initial end)
  (interactive "*sform: \nsinitial: \nnend: "
    :default1 "0"
    :history0 'formated-number-history)
  (or (integerp initial)
      (setq initial (parse-integer initial)))
  (let ((index 0)
	(cnt 0)
	seq)
    (while (setq index (string-matchp "~[ad]" form index))
      (setq cnt (1+ cnt))
      (setq index (1+ index)))
    (setq seq (make-list cnt))
    (do ((n initial (1+ n)))
	((>= n end))
      (mapl #'(lambda (x) (setf (car x) n)) seq)
      (insert (apply #'format nil form seq))
      )
    ))

;;---------------------------------------------------------
;;. キーマップ更新

;;.. 設定ファイル読み込み & 更新
(defun load-insert-character-config ()
  (let ((filename (merge-pathnames ".insert-character" (si:system-root))))
    (if (file-exist-p (concat filename ".lc"))
	(mc-load-library (concat filename ".lc") :no-suffix t)
      (mc-load-library filename :if-does-not-exist :skip :no-suffix t)))
  (setq *insert-character-latex-command* nil)
  (setq *insert-character-latex-commands-start-chars* nil)
  (update-character-keymap))

;;.. 更新
(load-insert-character-config)

(when (fboundp 'ed::popup-mode-memo-gen)
  (define-key *character-keymap* '#\C-F12 (popup-mode-memo-gen '#\DEL nil " ")))

(when (fboundp 'ed::local-bindings-box)
  (defun character-keymap-bindings-box ()
    (interactive)
    (ed::local-bindings-box *character-keymap*))
  (define-key *character-keymap* '#\C-S-F12 'character-keymap-bindings-box))

(global-set-key *character-keymap-key* *character-keymap*)
(define-key *character-keymap* '#\C-M-F12 'insert-character-key-definition)

;;
(provide "insert-character")

;; insert-character ends here
