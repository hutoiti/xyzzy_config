;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; save-place.l
;;;
;;; Last updated: <2007/12/30 14:52:49 +0900>
;;;
;;; by matsushita

#|

  �t�@�C�������Ƃ��Ƀt�@�C�����E�|�C���g�ʒu�E�������Ԃ��L�^�p�t�@�C���ɋL�^���A�ĂъJ���Ƃ��Ƀ|�C���g�ʒu�𕜌����܂��B
  �L�^�p�t�@�C���ɋL�^����Ă���t�@�C���̏����o�b�t�@�ɓW�J���A���̃t�@�C�����{���E�J�����Ƃ��o���܂��B


  save-place.l �͏C�� BSD ���C�Z���X�Ɋ�Â��ė��p�\�ł��B
  <http://www.xfree86.org/3.3.6/COPYRIGHT2.html#5>
  
  Copyright (C) 2006-2007 matsushita. All rights reserved.
  
  
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


  ���� lisp ���쐬����ɂ�����A$XYZZY/lisp �f�B���N�g���Ɋ܂܂�� files.l�i�T�䂳�� http://www.jsdlab.co.jp/~kamei/ �j
  ���Q�l�ɂ����Ē����܂����Bm(_ _)m


�� �g����

  �EM-x save-place-list-buffer �ŋL�^�p�t�@�C���ɋL�^����Ă���t�@�C���̏��� *save-place-list* �o�b�t�@�ɓW�J����B

  �EM-x toggle-save-place �Ō��݂̃o�b�t�@�ŁAM-x toggle-save-place-all-buffers �őS�Ẵo�b�t�@�ŁA
    save-place �̗L���E������؂�ւ���B

  �EM-x check-save-place-available �Ō��݂̃o�b�t�@�ł� save-place �̗L���E�����̃`�F�b�N�B


�� �L�[�o�C���h

  *save-place-list* �o�b�t�@

    RET     : �t�@�C�����J���ďI��
    SPC     : �t�@�C�����J��
    C-n     : ���̃t�@�C�����{��
    C-p     : �O�̃t�@�C�����{��
    t       : �������ԍ~���Ń\�[�g
    r t     : �������ԏ����Ń\�[�g
    w       : �t�@�C���̍X�V���ԍ~���Ń\�[�g
    r w     : �t�@�C���̍X�V���ԏ����Ń\�[�g
    f       : �t�@�C���������Ń\�[�g
    r f     : �t�@�C�����~���Ń\�[�g
    C-k     : �L�����b�g�s�܂��̓Z���N�V�������ݒ肳��Ă���s�̃t�@�C�������폜
    C-z     : undo
    C-y     : redo
    C-x C-s : �o�b�t�@�ɓW�J����Ă���t�@�C������ۑ�
    TAB     : *save-place-view* �o�b�t�@�Ɉړ�
    q       : �I��

  *save-place-view* �o�b�t�@

    RET     : �t�@�C�����J��
    TAB     : *save-place-list* �o�b�t�@�Ɉړ�
    q       : ����

|#

(provide "save-place")

(in-package "editor")

(export '(save-place-list-buffer
	  save-place-restore
	  save-place-toggle
	  save-place-toggle-all-buffers
	  save-place-available-check
	  *save-place-file-name*
	  *save-place-max*
	  *save-place-dir-list*
	  *save-place-exclude-regexp*
	  *save-place-filename-keyword-color*
	  *save-place-file-keyword-color*
	  *save-place-point-keyword-color*
	  *save-place-default-sort-method*
	  *save-place-filename-column*
	  *save-place-file-column*
	  *save-place-sep*
	  *save-place-recenter*
	  *save-place-available*
	  *save-place-local-available*
	  *save-place-hook*
	  *save-place-restore-hook*
	  *save-place-start-hook*
	  *save-place-quit-hook*
	  *save-place-view-mode-hook*
	  ))

(defvar *save-place-file-name* (merge-pathnames ".save-places" (si:system-root))) ;�|�C���g�ʒu�Ȃǂ��L�^����t�@�C��
(defvar *save-place-max* 100)                                                     ;�L�^����t�@�C�����̏��

(defvar *save-place-dir-list* nil)                                                ;�����Ŏw�肵���f�B���N�g���̔z���ɂ���t�@�C�����ꗗ�ɕ\������inil �Ȃ�S�ĕ\���j
; (setq *save-place-dir-list* '("C:/foo" "C:/bar")) �̂悤�Ƀ��X�g�`���Ŏw�肷��

(defvar *save-place-exclude-regexp* "\\.lc$\\|reference.xml$\\|\\.exe$")          ;����ۑ����Ȃ��t�@�C���𐳋K�\���Ŏw��
(defvar *save-place-filename-keyword-color* '(:color 10 0 :bold))                 ;�o�b�t�@�ɓW�J����t�@�C�����̐F���
(defvar *save-place-file-keyword-color* '(:color 4 0 :bold))                      ;�t�@�C���̐F���
(defvar *save-place-point-keyword-color* '(:color 1 0))                           ;�|�C���g�̐F���

(defvar *save-place-default-sort-method* 1)                                       ;�f�t�H���g�̃\�[�g���@
; 1=�������ԍ~�� 2=�������ԏ��� 3=�t�@�C���̍X�V���ԍ~�� 4=�X�V���ԏ��� 5=�t�@�C�������� 6=�t�@�C�����~��

(defvar *save-place-filename-column* 30)                                          ;�t�@�C�����𑵂��錅��
(defvar *save-place-file-column* 50)                                              ;�t�@�C���𑵂��錅��
(defvar *save-place-sep* "	")                                                ;�o�b�t�@�ɕ\�����鍀�ڂ���؂镶��
(defvar *save-place-recenter* nil)                                                ;�t�@�C�����J�����Ƃ��� recenter ���邩�ۂ�

(defvar *save-place-available* t)
(defvar-local *save-place-local-available* t)

(defvar *save-place-pframe* "save-place")
(defvar *save-place-list-buf* "*save-place-list*")
(defvar *save-place-view-buf* "*save-place-view*")
(defvar *save-place-regexp* (format nil "^\\(.+?\\) *~A\\(.+?\\) *~A\\([0-9]+\\)~A\\(\\| :not exist\\| :open\\)$" *save-place-sep* *save-place-sep* *save-place-sep*))
(defvar *save-place-last-pframe* nil)
(defvar *save-place-last-file-and-point* nil)
(defvar *save-place-hook* nil)
(defvar *save-place-restore-hook* nil)
(defvar *save-place-start-hook* nil)
(defvar *save-place-quit-hook* nil)
(defvar *save-place-view-mode-hook* nil)

(defvar *save-place-list-mode-map* (make-sparse-keymap))
(define-key *save-place-list-mode-map* #\RET 'save-place-find-and-quit)
(define-key *save-place-list-mode-map* #\SPC 'save-place-find-file)
(define-key *save-place-list-mode-map* #\C-n 'save-place-view-next)
(define-key *save-place-list-mode-map* #\C-p 'save-place-view-previous)
(define-key *save-place-list-mode-map* #\t 'save-place-sort-by-time)
(define-key *save-place-list-mode-map* '(#\r #\t) 'save-place-sort-by-time-reverse)
(define-key *save-place-list-mode-map* #\w 'save-place-sort-by-file-write-time)
(define-key *save-place-list-mode-map* '(#\r #\w) 'save-place-sort-by-file-write-time-reverse)
(define-key *save-place-list-mode-map* #\f 'save-place-sort-by-filename)
(define-key *save-place-list-mode-map* '(#\r #\f) 'save-place-sort-by-filename-reverse)
(define-key *save-place-list-mode-map* #\C-k 'save-place-kill-line)
(define-key *save-place-list-mode-map* #\C-z 'save-place-undo)
(define-key *save-place-list-mode-map* #\C-y 'save-place-redo)
(define-key *save-place-list-mode-map* '(#\C-x #\C-s) 'save-place-write-file)
(define-key *save-place-list-mode-map* #\TAB 'pop-to-save-place-view-buf)
(define-key *save-place-list-mode-map* #\q 'save-place-quit)

(defvar *save-place-view-mode-map* (make-sparse-keymap))
(define-key *save-place-view-mode-map* #\RET 'save-place-view-find-file)
(define-key *save-place-view-mode-map* #\TAB 'pop-to-save-place-list-buf)
(define-key *save-place-view-mode-map* #\q 'pop-to-save-place-list-buf)

(defun save-place-toggle (&optional (arg nil sv))
  (interactive)
  (toggle-mode '*save-place-local-available* arg sv)
  (when *save-place-local-available*
    (setq *save-place-available* t))
  (message "save-place ��~[�L��~;����~]�ɂ��܂���"
	   (if *save-place-local-available* 0 1)))

(defun save-place-toggle-all-buffers (&optional (arg nil sv))
  (interactive)
  (toggle-mode '*save-place-available* arg sv)
  (save-excursion
    (dolist (buf (delete "^ \\*Minibuf[0-9]+\\*$" (buffer-list)
			 :test #'string-match :key #'buffer-name))
      (set-buffer buf)
      (setq *save-place-local-available* *save-place-available*)))
  (message "save-place ��S�Ẵo�b�t�@��~[�L��~;����~]�ɂ��܂���"
	   (if *save-place-available* 0 1)))

(defun save-place-available ()
  (and *save-place-available*
       *save-place-local-available*))

(defun save-place-available-check ()
  (interactive)
  (message "save-place ��~[�L��~;����~]�ł�"
	   (if (save-place-available) 0 1)))

(defun save-place-data-read-from-file ()
  (let (contents)
    (with-open-file (s
		     *save-place-file-name*
		     :direction :input
		     :if-does-not-exist :create)
      (setq contents (read s nil)))
    contents))

(defun save-place-data-write-to-file (contents)
  (with-open-file (s
		   *save-place-file-name*
		   :direction :output
		   :if-exists :overwrite
		   :if-does-not-exist :create)
    (format s "~S" contents)))

(defun save-place-error-handle ()
  (delete-file *save-place-file-name*
	       :if-does-not-exist :skip
	       :if-access-denied :force)
  (plain-error "�G���[�����������̂Ńt�@�C�����폜���܂���: save-place"))

(defun save-place-excluded-list ()
  (delete *save-place-exclude-regexp* (save-place-data-read-from-file)
	  :test #'string-matchp :key #'car))

(defun save-place (buf)
  (when (save-place-available)
    (let ((file (get-buffer-file-name buf)))
      (and file
	   (file-exist-p file)
	   (not (string-matchp *save-place-exclude-regexp* file))
	   (handler-case
	       (let* ((cont (save-place-excluded-list))
		      (contents (delete file cont
					:test #'string-equal :key #'car)))
		 (save-excursion
		   (set-buffer buf)
		   (push (list file (point) (format-date-string "%y/%m/%d %H:%M:%S")) contents))
		 (let ((exceed (- (length contents) *save-place-max*)))
		   (when (> exceed 0)
		     (setq contents (nbutlast contents exceed))))
		 (save-place-data-write-to-file contents)
		 (run-hooks '*save-place-hook*))
	     (error ()
	       (save-place-error-handle))))))
  t)

(add-hook '*delete-buffer-hook* 'save-place)

(defun save-place-restore ()
  (interactive)
  (when (save-place-available)
    (let ((file (get-buffer-file-name (selected-buffer))))
      (and file
	   (file-exist-p file)
	   (not (string-matchp *save-place-exclude-regexp* file))
	   (handler-case
	       (let* ((contents (save-place-excluded-list))
		      (pos (or (second (assoc file contents :test #'string-equal)) 0)))
		 (goto-char pos)
		 (run-hooks '*save-place-restore-hook*))
	     (error ()
	       (save-place-error-handle)))))))

(add-hook '*find-file-hooks* 'save-place-restore)

(defun pop-to-save-place-list-buf ()
  (interactive)
  (when (find-buffer *save-place-list-buf*)
    (pop-to-buffer *save-place-list-buf*)))

(defun pop-to-save-place-view-buf ()
  (interactive)
  (when (find-buffer *save-place-view-buf*)
    (pop-to-buffer *save-place-view-buf*)))

(defun save-place-setup-buffer (buf)
  (set-buffer buf)
  (setq need-not-save t)
  (setq kept-undo-information nil)
  (setq auto-save nil)
  (setq buffer-read-only nil)
  (erase-buffer buf))

(defun save-place-find-file-process-params (params last-buffer) ;files.l ���
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

(defun save-place-list-buffer (&optional s)
  (interactive)
  (handler-case
      (let ((contents (save-place-excluded-list)))
	(unless *save-place-last-pframe*
	  (setq *save-place-last-pframe* (selected-pseudo-frame)))
	(select-pseudo-frame
	 (or (find-pseudo-frame *save-place-pframe*)
	     (new-pseudo-frame *save-place-pframe*)))
	(let ((buf (get-buffer-create *save-place-list-buf*)))
	  (save-place-setup-buffer buf)
	  (set-buffer-fold-width nil)
	  (set-local-window-flags (selected-buffer) *window-flag-newline* nil)
	  (use-keymap *save-place-list-mode-map*)
	  (setq s (or s *save-place-default-sort-method*))
	  (when *save-place-dir-list*
	    (setq contents (delete nil
				   (mapcar #'(lambda (x)
					       (dolist (dir *save-place-dir-list*)
						 (when (string-matchp
							(format nil "^~A" dir) (car x))
						   (return x))))
					   contents))))
	  (setq contents (sort contents
			       (case s
				 ((1 6) #'string-greaterp)
				 (3 #'>)
				 (4 #'<)
				 ((2 5) #'string-lessp))
			       :key (case s
				      ((1 2) #'third)
				      ((3 4) #'(lambda (x) (cond ((file-exist-p (car x))
								  (file-write-time (car x)))
								 (t 0))))
				      ((5 6) #'car))))
	  (with-output-to-buffer (buf)
	    (dolist (x contents)
	      (let ((file (car x))
		    (pos (second x)))
		(format t "~V@A~A~V@A~A~A~A~A~%"
			*save-place-filename-column*
			(file-namestring file)
			*save-place-sep*
			*save-place-file-column*
			file
			*save-place-sep*
			pos
			*save-place-sep*
			(cond ((not (file-exist-p file))
			       " :not exist")
			      ((get-file-buffer file)
			       " :open")
			      (t ""))))))
	  (kill-all-local-variables)
	  (make-local-variable 'regexp-keyword-list)
	  (setq regexp-keyword-list
		(compile-regexp-keyword-list
		 `((,*save-place-regexp* t ((1 . ,*save-place-filename-keyword-color*)
					    (2 . ,*save-place-file-keyword-color*)
					    (3 . ,*save-place-point-keyword-color*))))))
	  (setq buffer-mode 'save-place-list-mode)
	  (setq mode-name "save-place-list")
	  (goto-char (point-min))
	  (setq kept-undo-information 1000)
	  (setq buffer-read-only t)
	  (set-buffer-modified-p nil)
	  (run-hooks '*save-place-start-hook*)))
    (error ()
      (save-place-error-handle))))

(defun save-place-sort-by-time ()
  (interactive)
  (save-place-list-buffer 1))

(defun save-place-sort-by-time-reverse ()
  (interactive)
  (save-place-list-buffer 2))

(defun save-place-sort-by-file-write-time ()
  (interactive)
  (save-place-list-buffer 3))

(defun save-place-sort-by-file-write-time-reverse ()
  (interactive)
  (save-place-list-buffer 4))

(defun save-place-sort-by-filename ()
  (interactive)
  (save-place-list-buffer 5))

(defun save-place-sort-by-filename-reverse ()
  (interactive)
  (save-place-list-buffer 6))

(defun save-place-kill-line ()
  (interactive)
  (let (from to)
    (toggle-read-only nil)
    (if (pre-selection-p)
	(progn
	  (setf from (selection-mark))
	  (setf to (selection-point))
	  (if (> from to)
	      (rotatef from to))
	  (setf from (save-excursion (goto-char from) (goto-bol) (point)))
	  (setf to (save-excursion (goto-char to) (unless (bolp)
						    (goto-eol) (forward-char)) (point))))
      (progn
	(setf from (save-excursion (goto-bol) (point)))
	(setf to (save-excursion (goto-eol) (forward-char) (point)))))
    (delete-region from to)
    (toggle-read-only t)))

(defun save-place-undo ()
  (interactive)
  (toggle-read-only nil)
  (ignore-errors (undo))
  (toggle-read-only t))

(defun save-place-redo ()
  (interactive)
  (toggle-read-only nil)
  (ignore-errors (redo))
  (toggle-read-only t))

(defun save-place-write-file ()
  (interactive)
  (handler-case
      (let ((regexp (compile-regexp *save-place-regexp* t))
	    (cnt 0)
	    no-dup files contents)
	(save-excursion (goto-char (point-min))
	  (while (scan-buffer regexp
			      :no-dup no-dup)
	    (setq no-dup t)
	    (let ((file (match-string 2)))
	      (pushnew file files :test #'string-equal)
	      (incf cnt)
	      (when (= cnt *save-place-max*)
		(return)))))
	(setq contents (delete nil
			       (mapcar #'(lambda (x)
					   (let ((f (car x)))
					     (when (find f files :test #'string-equal)
					       (setq files (delete f files :test #'string-equal)) x)))
				       (save-place-excluded-list))))
	(save-place-data-write-to-file contents)
	(set-buffer-modified-p nil)
	(message "�ۑ����܂���"))
    (error ()
      (save-place-error-handle))))

(defun save-place-view-setup-buffer (file)
  (let ((sbuf (get-buffer-create *save-place-view-buf*))
	(buf (get-file-buffer file))
	(c (find "my-coloring" *modules* :test #'string=))
	attr)
    (save-place-setup-buffer sbuf)
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
		(clear-all-text-attributes)))))))
    (set-default-directory (directory-namestring file))
    (set-buffer-alternate-file-name file)
    (let ((params (find-file-scan-params)))
      (kill-all-local-variables)
      (save-place-find-file-process-params params (selected-buffer))
      (setq buffer-mode 'save-place-view-mode)
      (setq mode-name "save-place-view")
      (use-keymap *save-place-view-mode-map*)
      (setq buffer-read-only t)
      (set-buffer-modified-p nil)
      (run-hooks '*save-place-view-mode-hook*))))

(defun save-place-find-file (&optional v quit (n 1))
  (interactive)
  (let ((regexp (compile-regexp *save-place-regexp* t))
	file pos exist)
    (and (not quit)
	 (find *last-command* `(,'save-place-find-file
				,'save-place-view-next
				,'save-place-view-previous))
	 (next-line n))
    (save-excursion (goto-bol)
      (when (looking-at regexp)
	(setq file (match-string 2)
	      pos (or (parse-integer (match-string 3) :junk-allowed t) 0)))
      (and file
	   (file-exist-p file)
	   (setq exist t)
	   (if v
	       (save-place-view-setup-buffer file)
	     (let ((open " :open"))
	       (and (not quit)
		    (string/= (match-string 4) open)
		    (progn
		      (goto-char (match-beginning 4))
		      (looking-at ".*$")
		      (setq buffer-read-only nil)
		      (replace-match open)
		      (setq buffer-read-only t)
		      (set-buffer-modified-p nil)))
	       (find-file-internal file)
	       (add-history file '*minibuffer-file-name-history*)
	       (setq *save-place-last-file-and-point* (cons file pos))))))
    (and exist
	 (not quit)
	 (progn
	   (when (= (count-windows) 1)
	     (split-window (truncate (/ (window-height) 2)))
	     (refresh-screen))
	   (pop-to-buffer (if v *save-place-view-buf* (get-file-buffer file)))
	   (goto-char pos)
	   (set-mark)
	   (recenter)
	   (pop-to-save-place-list-buf)))
    (unless quit
      (set-mark)
      (recenter))
    (unless exist
      (plain-error "�Ȃ����B"))))

(defun save-place-view-next (&optional (n 1))
  (interactive)
  (save-place-find-file t nil n))

(defun save-place-view-previous ()
  (interactive)
  (save-place-view-next -1))

(defun save-place-view-find-file ()
  (interactive)
  (let ((pos (point))
	(file (get-buffer-alternate-file-name)))
    (and file
	 (file-exist-p file)
	 (let ((open " :open"))
	   (when (find-buffer *save-place-list-buf*)
	     (save-excursion
	       (set-buffer *save-place-list-buf*)
	       (goto-char (point-min))
	       (when (and (scan-buffer (compile-regexp
					(format nil "^\\(~A *~A~A *~A[0-9]+~A\\)\\(.*\\)$"
						(file-namestring file)
						*save-place-sep*
						file
						*save-place-sep*
						*save-place-sep*) t))
			  (not (string= (match-string 2) open)))
		 (setq buffer-read-only nil)
		 (replace-match (format nil "\\1~A" open))
		 (setq buffer-read-only t)
		 (set-buffer-modified-p nil))))
	   (find-file file)
	   (add-history file '*minibuffer-file-name-history*)
	   (goto-char pos)
	   (set-mark)
	   (recenter)))))

(defun save-place-quit ()
  (interactive)
  (let ((file (car *save-place-last-file-and-point*))
	(pos (cdr *save-place-last-file-and-point*))
	frame buffer)
    (dolist (buf `(,*save-place-list-buf* ,*save-place-view-buf*))
      (when (find-buffer buf)
	(delete-buffer buf)))
    (when (setq frame (find-pseudo-frame *save-place-pframe*))
      (delete-pseudo-frame frame))
    (refresh-screen) ;��������Ȃ��Ɓu�폜���ꂽ�E�B���h�E�ł��v�Ƃ����G���[���o��H
    (when *save-place-last-pframe*
      (select-pseudo-frame *save-place-last-pframe*))
    (and file
	 (setq buffer (get-file-buffer file))
	 (set-buffer buffer)
	 (goto-char pos)
	 (set-mark)
	 (when *save-place-recenter*
	   (refresh-screen)
	   (recenter)))
    (setq *save-place-last-pframe* nil
	  *save-place-last-file-and-point* nil)
    (run-hooks '*save-place-quit-hook*)))

(defun save-place-find-and-quit ()
  (interactive)
  (save-place-find-file nil t)
  (save-place-quit))

;;;