;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; regrep.l
;;;
;;; Last updated: <2007/12/30 14:53:50 +0900>
;;;
;;; by matsushita

#|

  Grep結果に表示されているファイルを対象に再度Grepをかけます。


  regrep.l は修正 BSD ライセンスに基づいて利用可能です。
  <http://www.xfree86.org/3.3.6/COPYRIGHT2.html#5>
  
  Copyright (C) 2004-2006 matsushita. All rights reserved.
  
  
  Redistribution and use in source and binary forms, with or without modification,
  are permitted provided that the following conditions are met:
  
  
  1.Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
  
  2.Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.
  
  3.The name of the author may not be used to endorse or promote products derived
    from this software without specific prior written permission.
  
  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


  この lisp を作成するにあたり、$XYZZY/lisp ディレクトリに含まれる grep.l grepd.l files.l（亀井さん http://www.jsdlab.co.jp/~kamei/ ）と、
  こちら（http://snmsts.orz.hm/~sana/wiki/?%C6%FC%B5%AD%A4%C3%A4%DD%A4%AF%2F2004-05-15）で頂いた情報、
  及び OHKUBO Hiroshi さんの ggrep（http://ohkubo.s53.xrea.com/xyzzy/index.html#ggrep）を参考にさせて頂きました。m(_ _)m


■ インストール:

  1. regrep.l を $XYZZY/site-lispに保存する。

  2. 必要に応じてバイトコンパイルする。

  3. .xyzzy または siteinit.l に以下の記述を追加する。

  (require "regrep")

  4. siteinit.l に記述した場合は xyzzy を再ダンプする。


■ 使い方:

  ・Grep 関係バッファ・*NAMAZU SEARCH*・*HE SEARCH*バッファを選択して、M-x regrep で新たな検索語を入力すると、
    そのバッファに表示されているファイルを対象に再度Grepをかけて、*regrep* 又は *recompilation* バッファを出力します。

  ・*regrep* 又は *recompilation* バッファに対して再度 regrep がかけられます。

  ・後は通常のGrepと同じです。

  ・Grep 関係バッファで M-x regrep-open-file するとキャレット行のファイルを開きます。M-x regrep-view-file すると
    キャレット行のファイルを閲覧できます。


■ grep-mode.l（http://nazoking.s31.xrea.com:8080/k/grep-mode.l）と併用する場合の設定例

(defun grep-mode () 中の (run-hooks *grep-mode-hook*) を
(run-hooks '*grep-mode-hook*) に変更し、
.xyzzy などに以下のように記述する
(add-hook '*grep-mode-hook* #'(lambda ()
				(let ((keymap (copy-keymap (local-keymap))))
				  (define-key keymap #\C-F10 'regrep-open-file)
				  (define-key keymap #\C-n 'regrep-next-line-and-view)
				  (define-key keymap #\C-p 'regrep-previous-line-and-view)
				  (define-key keymap #\M-Down 'regrep-next-file)
				  (define-key keymap #\M-Up 'regrep-previous-file)
				  (define-key keymap #\C-M-n 'regrep-next-file-and-view)
				  (define-key keymap #\C-M-p 'regrep-previous-file-and-view)
				  (define-key keymap #\TAB 'regrep-goto-view-buffer)
				  (use-keymap keymap))))

|#

(provide "regrep")

(in-package "editor")

(export '(regrep
	  regrep-open-file
	  regrep-view-file
	  regrep-goto-view-buffer
	  regrep-next-line-and-view
	  regrep-previous-line-and-view
	  regrep-next-file
	  regrep-previous-file
	  regrep-next-file-and-view
	  regrep-previous-file-and-view
	  *regrep-buffer-fold-width*
	  *regrep-view-buffer-fold-width*
	  *regrep-view-mode-map*
	  ))

(defvar *regrep-grep-buffer-list* '(
				    "*grep*"
				    "*compilation*"
				    "*ggrep*"
				    "*regrep*"
				    "*recompilation*"
				    "*egrep*"
				    "*eregrep*"
				    "*namazu-grep*"
				    "*HE-grep*"
				    ))

(defvar *regrep-search-buffer-list* '(
				      "*NAMAZU SEARCH*"
				      "*HE SEARCH*"
				      ))

(defvar *regrep-target-buffer-list* (append *regrep-search-buffer-list* *regrep-grep-buffer-list*))

(defvar *regrep-buffer-fold-width* nil)
(defvar *regrep-view-buffer-fold-width* nil)

(defvar *regrep-view-mode-map* (make-sparse-keymap))
(define-key *regrep-view-mode-map* #\f 'regrep-find-file)
(define-key *regrep-view-mode-map* #\RET 'regrep-other-window)
(define-key *regrep-view-mode-map* #\TAB 'regrep-other-window)
(defvar *regrep-view-buffer* "*regrep-view*")

(defvar *regrep-target-files* nil)
(define-history-variable *regrep-sort-by-filename* nil)
(defvar *regrep-open-hook* nil)
(defvar *regrep-view-hook* nil)
(defvar *regrep-count-matches* 0)

(defun regrep-target-bufferp (buffer buffer-list)
  (find buffer buffer-list :test #'string=))

(defun regrep-scan-regexp (egrep-bufferp)
  (let ((regexp (compile-regexp
		 (if egrep-bufferp
		     "^.\\(.+?\\):\\([1-9][0-9]*\\):"
		   "^\\(.+?\\):\\([1-9][0-9]*\\):") t)))
    regexp))

(defun regrep-filep (file)
  (and (file-exist-p file)
       (not (file-directory-p file))))

(defun regrep-target-list (buffer)
  (message "ターゲットリスト作成中...")
  (let* ((egrep-bufferp (or (string= buffer "*egrep*")
			    (string= buffer "*eregrep*")))
	 (regexp (unless (regrep-target-bufferp buffer *regrep-search-buffer-list*)
		   (regrep-scan-regexp egrep-bufferp)))
	 target-list target file buf)
    (flet ((get-target ()
	     (setq target (if (looking-at regexp)
			      (match-string 1)
			    (buffer-substring (point)
					      (save-excursion (goto-eol) (point)))))))
      (save-excursion
	(set-buffer buffer)
	(if (not regexp)
	    (let* ((NAMAZU (string= buffer "*NAMAZU SEARCH*"))
		   (tag (if NAMAZU 'user::namazu-file 'HE-file)))
	      (setq *regrep-target-files* t)
	      (dolist (x (list-text-attributes))
		(when (eq (caddr x) tag)
		  (let ((beg (first x))
			(end (second x)))
		    (setq file (buffer-substring beg end))
		    (when NAMAZU
		      (setq file (string-trim "[/ \t]" (substitute-string file "|/" ":/"))))
		    (when (regrep-filep file)
		      (pushnew file target-list :test #'string-equal))))))
	  (let ((defdir (default-directory)))
	    (goto-char (point-min))
	    (while (get-target)
	      (let (regexp-1)
		(flet ((forward ()
			 (if (forward-line) t (return))))
		  (when (string/= target "")
		    (setq regexp-1 (compile-regexp
				    (format nil (if egrep-bufferp "^.~A" "^~A")
					    (regexp-quote target)) t))
		    (if (string-match "^<\\(.+\\)>$" target)
			(when (find-buffer (setq buf (match-string 1)))
			  (pushnew buf target-list :test #'string-equal))
		      (and (setq file (merge-pathnames target defdir))
			   (regrep-filep file)
			   (pushnew file target-list :test #'string-equal)
			   (setq *regrep-target-files* t))))
		  (forward)
		  (while (and regexp-1 (looking-at regexp-1) (forward)))))))))
      (if *regrep-sort-by-filename*
	  (sort target-list #'string-lessp)
	(nreverse target-list)))))

(defun regrep (pattern &optional arg)
  (interactive "sregrep: \np" :default0 (or (selection-start-end (start end)
					      (buffer-substring start end))
					    (car *minibuffer-search-string-history*) "")
    :history0 'search)
  (when arg
    (let* ((reply-list '("yes" "no"))
	   (reply
	    (completing-read
	     (format nil "ファイル名順にソートする？ (~A): "
		     (format nil "~{~A~^ ~}" reply-list))
	     reply-list
	     :case-fold t
	     :default (if *regrep-sort-by-filename* "yes" "no")
	     :must-match t)))
      (setq *regrep-sort-by-filename* (string-equal reply "yes"))))
  (let ((bufname (buffer-name (selected-buffer))))
    (if (regrep-target-bufferp bufname *regrep-target-buffer-list*)
	(if (> (length pattern) 0)
	    (regrep1 pattern bufname)
	  (plain-error "文字列が入力されていません。"))
      (plain-error "grep 関係バッファを選択してください。"))))

(defun regrep-initialize-buffer (buffer)
  (set-buffer buffer)
  (setq need-not-save t)
  (setq kept-undo-information nil)
  (setq auto-save nil)
  (setq buffer-read-only nil))

(defun regrep-xdoc2p (file)
  (dotimes (x 2 t)
    (let ((func (if (zerop x) 'xdoc2txt-enable-p 'xdoc2txt-file-matchp)))
      (unless (and (fboundp func) (funcall func file)) (return)))))

(defun regrep-scan-file (file scanner)
  (let ((found nil))
    (while (funcall scanner)
      (setq found t)
      (incf *regrep-count-matches*)
      (let ((beg (progn (goto-bol) (point)))
	    (end (progn (goto-eol) (point))))
	(format t "~A:~D:~A~%" file (current-line-number) (buffer-substring beg end))
	(when (and *grep-highlight-match*
		   (buffer-stream-p *standard-output*))
	  (save-excursion
	    (set-buffer (buffer-stream-buffer *standard-output*))
	    (let ((p (- (buffer-stream-point *standard-output*) end 1)))
	      (apply #'set-text-attribute (+ (match-beginning 0) p) (+ (match-end 0) p)
		     'regrep *grep-highlight-match*)
	      (goto-char (+ (match-beginning 0) p))
	      (while (and (forward-char) (funcall scanner))
		(incf *regrep-count-matches*)
		(apply #'set-text-attribute (match-beginning 0) (match-end 0)
		       'regrep *grep-highlight-match*))))))
      (or (forward-char 1)
	  (return)))
    found))

(defun regrep1 (pattern bufname)
  (long-operation
    (let* ((tlist (regrep-target-list bufname))
	   (common-path (when *regrep-target-files* (glob-common-path tlist)))
	   (sbuffer (get-buffer-create (if *regrep-target-files* "*regrep*" "*recompilation*"))))
      (unless tlist
	(plain-error "ないよん"))
      (when *grep-understand-escape-sequences*
	(setq pattern (decode-escape-sequence pattern *grep-regexp-search*)))
      (when *grep-regexp-search*
	(setq pattern (compile-regexp pattern *grep-case-fold-search*)))
      (with-output-to-buffer (sbuffer)
	(let ((scanner (grep-scanner pattern *grep-case-fold-search* *grep-word-search*)))
	  (save-excursion
	    (regrep-initialize-buffer sbuffer)
	    (erase-buffer sbuffer)
	    (set-buffer-fold-width *regrep-buffer-fold-width*)
	    (when *regrep-target-files* (set-default-directory common-path))
	    (make-local-variable '*find-error-scanner*)
	    (setq *find-error-scanner* scanner)
	    (setq *regrep-count-matches* 0)
	    (if *regrep-target-files*
		(let ((temp (create-new-buffer "*regrep temp*")))
		  (regrep-initialize-buffer temp)
		  (message "scanning ...")
		  (dolist (file tlist)
		    (let ((file-buffer (get-file-buffer file))
			  (xdoc2 (regrep-xdoc2p file))
			  (fn (subseq file (length common-path))))
		      (if file-buffer
			  (set-buffer file-buffer)
			(if xdoc2
			    (xdoc2txt file temp t)
			  (progn
			    (set-buffer temp)
			    (erase-buffer temp)
			    (ignore-errors (insert-file-contents file)))))
		      (save-excursion
			(goto-char (point-min))
			;(message "scanning (~A)" fn)
			(regrep-scan-file fn scanner))))
		  (delete-buffer temp))
	      (dolist (buffer tlist)
		(unless (regrep-target-bufferp buffer (append '("*regrep-view*") *regrep-target-buffer-list*))
		  ;(message "Scanning (~A)" buffer)
		  (set-buffer buffer)
		  (save-excursion
		    (goto-char (point-min))
		    (regrep-scan-file (concatenate 'string "<" buffer ">") scanner))))))))
      (set-buffer sbuffer)
      (goto-char (point-min))
      (set-buffer-modified-p nil))
    (if *regrep-target-files*
	(progn
	  (setq *regrep-target-files* nil)
	  (run-hooks '*grepd-hook*)
	  (message "done ~A hit" *regrep-count-matches*))
      (progn
	(run-hooks '*grep-hook*)
	(message "completed. ~A hit" *regrep-count-matches*)))))

(defun regrep-find-file-process-params (params last-buffer) ;files.l より
  (let ((auto-mode nil))
    (declare (special auto-mode))
    (when (and (symbolp *find-file-auto-mode-function*)
	       (fboundp *find-file-auto-mode-function*))
      (funcall *find-file-auto-mode-function*)
      (setq auto-mode t))
    (mapc #'(lambda (x)
	      (let ((f (cdr (assoc (car x) *auto-mode-parameter-alist*
				   :test #'string-equal))))
		(when f
		  (unless (and auto-mode (get f 'find-file-auto-mode))
		    (when (and (funcall f (cdr x))
			       (get f 'find-file-auto-mode))
		      (setq auto-mode t))))))
	  params)
    (unless auto-mode
      (let ((filename (get-buffer-alternate-file-name))
	    (*auto-mode-last-buffer* last-buffer))
	(dolist (x *auto-mode-alist*)
	  (when (string-matchp (car x) filename)
	    (funcall (cdr x))
	    (return)))))))

(defun regrep-view-setup-buffer (file buf)
  (let* ((sbuf (get-buffer-create *regrep-view-buffer*))
	 (xdoc2 (and file (regrep-xdoc2p file)))
	 (name (or file (buffer-name buf)))
	 (differ (or (not (find *last-command* `(,'regrep-view-file
						 ,'regrep-next-line-and-view
						 ,'regrep-previous-line-and-view)))
		     (string/= (get-buffer-alternate-file-name sbuf) name)))
	 (c (find "my-coloring" *modules* :test #'string=))
	 attr)
    (regrep-initialize-buffer sbuf)
    (set-buffer-fold-width *regrep-view-buffer-fold-width*)
    (set-buffer-alternate-file-name name)
    (when differ
      (if xdoc2
	  (xdoc2txt file sbuf t)
	(progn
	  (erase-buffer sbuf)
	  (if buf
	      (save-excursion
		(insert (save-excursion (set-buffer buf)
			  (when c
			    (setq attr (coloring-target-list)))
			  (buffer-substring (point-min) (point-max))))
		(and c attr
		     (dolist (x attr)
		       (apply #'set-text-attribute x))))
	    (progn
	      (insert-file-contents file)
	      (when c
		(let ((col (concat file ".col")) is)
		  (handler-case
		      (with-open-file (is col :direction :input)
			(setq attr (read is))
			(dolist (x attr)
			  (apply #'set-text-attribute x)))
		    (error ()
		      (clear-all-text-attributes)))))))))
      (when file (set-default-directory (directory-namestring file)))
      (let ((params (find-file-scan-params)))
	(kill-all-local-variables)
	(regrep-find-file-process-params params (selected-buffer))
	(setq buffer-mode 'regrep-view-mode)
	(setq mode-name "regrep-view")
	(use-keymap *regrep-view-mode-map*)))
    (setq buffer-read-only t)
    (set-buffer-modified-p nil)
    sbuf))

(defun regrep-reverse-region (&optional temp)
  (reverse-region (save-excursion (goto-bol) (point))
		  (save-excursion (goto-eol) (point)) temp)
  (recenter))

(defun regrep-open-file (&optional v)
  (interactive)
  (let ((buffer (buffer-name (selected-buffer))))
    (if (regrep-target-bufferp buffer *regrep-grep-buffer-list*)
	(let* ((egrep-bufferp (or (string= buffer "*egrep*")
				  (string= buffer "*eregrep*")))
	       (regexp (regrep-scan-regexp egrep-bufferp))
	       target lnum file buf sbuf)
	  (flet ((none ()
		   (plain-error "ないよん")))
	    (save-excursion
	      (goto-bol)
	      (if (looking-at regexp)
		  (setq target (match-string 1)
			lnum (parse-integer (match-string 2) :junk-allowed t))
		(setq target (buffer-substring (point) (save-excursion (goto-eol) (point)))))
	      (cond ((string= target "")
		     (none))
		    ((and (string-match "^<\\(.+\\)>$" target)
			  (setq buf (find-buffer (match-string 1))))
		     (if v
			 (setq sbuf (regrep-view-setup-buffer (and (setq file (get-buffer-file-name buf))
								   (regrep-filep file) file) buf))
		       (setq sbuf buf)))
		    ((regrep-filep (setq file (merge-pathnames target (default-directory))))
		     (if v
			 (setq sbuf (regrep-view-setup-buffer file nil))
		       (progn
			 (find-file-internal file)
			 (setq sbuf (get-file-buffer file)))))
		    (t (none))))
	    (when (= (count-windows) 1)
	      (split-window (truncate (/ (window-height) 2)))
	      (refresh-screen))
	    (other-window 1)
	    (set-buffer sbuf)
	    (if (and (not (eq *prefix-args* 'universal-argument)) lnum)
		(progn
		  (goto-line lnum)
		  (regrep-reverse-region t))
	      (goto-char (point-min)))
	    (if v
		(run-hooks '*regrep-view-hook*)
	      (run-hooks '*regrep-open-hook*))
	    (other-window -1)
	    (regrep-reverse-region)))
      (plain-error "grep 関係バッファを選択してください。"))))

(defun regrep-view-file ()
  (interactive)
  (regrep-open-file t))

(defun regrep-goto-view-buffer ()
  (interactive)
  (when (find-buffer *regrep-view-buffer*)
    (pop-to-buffer *regrep-view-buffer*)))

(defun regrep-other-window ()
  (interactive)
  (other-window -1))

(defun regrep-find-file ()
  (interactive)
  (let ((file (get-buffer-alternate-file-name))
	(lnum (current-line-number)))
    (and file
	 (regrep-filep file)
	 (find-file file)
	 (goto-line lnum)
	 (recenter))))

(defun regrep-next-line-and-view (&optional (p 1))
  (interactive)
  (when (or (eq *last-command* 'regrep-next-line-and-view)
	    (eq *last-command* 'regrep-previous-line-and-view))
    (next-line p))
  (regrep-view-file))

(defun regrep-previous-line-and-view ()
  (interactive)
  (regrep-next-line-and-view -1))

(defun regrep-next-file (&optional (p 1) v)
  (interactive)
  (let* ((buffer (buffer-name (selected-buffer)))
	 (egrep-bufferp (or (string= buffer "*egrep*")
			    (string= buffer "*eregrep*")))
	 (regexp (regrep-scan-regexp egrep-bufferp)))
    (flet ((get-target ()
	     (if (looking-at regexp)
		 (match-string 1)
	       (buffer-substring (point) (save-excursion (goto-eol) (point))))))
      (goto-bol)
      (let ((target (get-target)))
	(forward-line p)
	(when (string/= target "")
	  (let ((regexp-1 (compile-regexp
			   (format nil (if egrep-bufferp "^.~A" "^~A")
				   (regexp-quote target)) t)))
	    (while (and (looking-at regexp-1)
			(forward-line p))))))
      (unless v
	(recenter)))))

(defun regrep-previous-file ()
  (interactive)
  (regrep-next-file -1))

(defun regrep-next-file-and-view (&optional (p 1))
  (interactive)
  (regrep-next-file p t)
  (regrep-view-file))

(defun regrep-previous-file-and-view ()
  (interactive)
  (regrep-next-file-and-view -1))

(defun regrep-uninstall ()
  (let ((history-variables
	 '(*regrep-sort-by-filename*)))
    (dolist (variable history-variables)
      (unregister-history-variable variable))))

;;;
