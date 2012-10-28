;;; -*- Mode: Lisp; Package: EDITOR -*-
#| embedded grep for xyzzy-0.2.2.235

Copyright (c) 2008-2009 knenet <kneneglect_std(^o^)yahoo.co.jp>

���T�v
�e�L�X�g�ɖ��ߍ��񂾐��K�����\�������s���܂��B
�����͈͂̎w�肪�ł��A���ʂ��P��ł���Ύ����Ŕ�т܂��B

������
(require "embedded-grep")

��.xyzzy�ɏ����Ȃǂ��ēǂݍ��݂܂��B
netinstaller��p���ăC���X�g�[�������ꍇ�͕s�v�ł��B

(define-key esc-map #\C-l 'eg-run)
(global-set-key '(#\C-c #\C-l) 'eg-goto-run-exp)
(global-set-key '(#\C-c #\l) 'eg-release-run-exp)

�ȂǂƍD�݂ɉ����ăL�[�o�C���h���܂��B

�A���C���X�g�[���͂��̃t�@�C����embededd-grep.lc���폜����
��L�ݒ蓙�������΂����ł��B

���g�p�@
����{
�C�ӂ̃e�L�X�g��
:|�������|:
�̂悤�ɋL�q���A�L�����b�g�����킹��eg-run�����s���܂��B
������� �̕����͐��K�\���ɂȂ�܂��B

|>>�������
�Ƃ���ƁA�������ɓ������s���������܂�(^�������[ \t].*$ ����)�B

�������ʂ�1�ł���΁A�Y�������ɃJ�[�\�����ړ����܂��B
   �V   ����������΁A�Y���t�߂�񋓂���o�b�t�@���J���܂��B
   �V   ���Ȃ���΁A�t�@�C���̖����Ɉړ����A�e���v���[�g��}�����܂��B

���͒��ɏ����ꍇ�� :|�������|: �Ǝ�O�ɔ��p�X�y�[�X�������ĉ������B

eg-goto-run-exp�����s����ƁA�O����s�����ꏊ�֖߂�܂��B
*eg-marker-ring*�ɑS���L�^���Ă���̂ŉ���ł��߂�܂��B

����߂�̂����邢�ꍇ��eg-release-run-exp�����s����ƑS�ĕ\������܂��B
*eg-marker-ring*�͏�������܂��Buniversal-argument������ꍇ�͏������܂���B

���ڍ�
:||: |>>
�ǂ���ł��A��O�ɃX�y�[�X�����܂��ɁA���L�̏����ɉ����ċL�q�����
����̐ݒ肪�s���܂��B

path|>>word
path�̃t�@�C���A�������̓f�B���N�g�����猟�����܂��B
���C���h�J�[�h�����p�ł��܂��B
path�ɔ��p�X�y�[�X���܂܂��ꍇ��""�Ŋ����Ă��������B
path���Ȃ��Ȃ�Apath������ăe���v���[�g��}�����܂��B
���C���h�J�[�h���g���Ă���ꍇ�A�K���Ƀt�@�C�������܂��B

path|>>
path���J���܂��B�f�B���N�g���ł���΃t�@�C����񋓂��܂��B

<buffer>|>>
�o�b�t�@�Ɉړ����܂��B�o�b�t�@���Ȃ��ꍇ�͉������܂���B

|integer|>>word
word���������Ainteger�Ԗڂ̌��ʂ�\�����܂��B
path���Ȃ��ꍇ�����[��|���K�v�ł��B
|�̉E���ɏ������̂�����q�ƌĂт܂��B

|integer|>>
integer�s�ڂɃJ�[�\�����ړ����܂��B

path|integer|>>
path��integer�s�ڂɃJ�[�\�����ړ����܂��B
path�ɕ����̃t�@�C�����܂܂��ꍇ�Ainteger�Ԗڂ̃t�@�C�����J���܂��B

|>|>>word
�������ʂ��\�[�g���ĕ\�����܂��B�~��(<)�Ə���(>)���w��ł��܂��B
�t�@�C����񋓂���ꍇ path|>|:||:

path|r|>>
path�̃T�u�f�B���N�g�����������܂��B

path1|path2||>>
path�𕡐��w��ł��܂��B�����q���Ȃ��ꍇ���E�[��|�������K�v������܂��B

|>:integer|>>word
�����q��񋓂���ꍇ��:�ŋ�؂�܂��B
���̏ꍇ�́Aword�Ō����������ʂ������Ń\�[�g���Ainteger�Ԗڂ�\�����܂��B

path1|...|pathN|r:<:num1:num2|>>
�����q��4���ō�(����)�ł��B
path1�`pathN�܂ł��ċA�I�ɓW�J��(�d���͋C�ɂ��Ȃ�)�A�\�[�g������A
num1�Ԗڂ̃t�@�C�����J���Anum2�s�ڂɈړ����܂��B

���ݒ�
�R�[�h�̎n�߂̕��ɂ���defvar���ꂽ�ϐ��̒l��setq���ĕύX�ł��܂��B
�Ⴆ�΁Aeg-run��C-l�ł͂Ȃ��AF12�Ȃǂɐݒ肵�A�����\�L���Ȃ��Ƃ����
recenter����K�v���Ȃ��ꍇ�́A
(setq *eg-capture-command* nil)
��.xyzzy�Ȃǂɏ����܂��B
���ꂼ��̕ϐ��̈Ӗ��͐錾�����Q�Ƃ��Ă��������B


�����m�̖��
�����炠��o�b�t�@(*scratch*�Ȃ�)�ɐF�Â������f����܂���B

�\���Ƀe�X�g���Ă��Ȃ��̂Ńo�O����������\��������܂��B
���������s����Ƃ��̓t�@�C����ۑ����Ă���̕��������ł��傤�B

���p & �`
�p�D�������ς�������Ȃ��ł����H
�`�D��肢���@�l���Ă��������B

�p�D�����s�ɕ��� path:|word|:�������Č������悤�Ƃ���ƁA
�@�@�Ȃ����Ӑ}�ƈႤ���̂��������Ă��܂�
�`�Dpath�̏�Ŏ��s����ƁA��O��:|word|:���D�悳��܂��B�d�l�ł��B

�p�Deg-goto-run-exp���d�������܂���B
�`�Deg-run�ƈقȂ�A�����t�@�C���͊J�������܂���B
�@�@���Ԃ����肪����Ȃ�A�o�b�t�@����Ȃ��悤�ɂ��܂��傤�B

�����C�Z���X
MIT���C�Z���X�ɏ������܂��B����҂𖾂炩�ɂ���ΓK���Ɏg���ėǂ��ł��B
���̃\�t�g�̎g�p�ɂ���Đ��������v�ɂ��āA����҂͈�ؐӔC�������܂���B

Copyright (c) 2008-2009 knenet \kneneglect_std(^o^)yahoo.co.jp/

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.


������
001 2009-07-01 23:17 �ł����B
002 2009-07-02 08:59 �Ԃ�~�X�̏C���B
003 2009-07-02 13:20 ���s�����|�C���g�֖߂��悤�ɂ����B���邳�������B
004 2009-07-03 19:19 �t�@�C�������Ƃ�word���Ȃ���΃e���v���[�g��}�����Ȃ��悤�ɁB
005 2009-07-06 12:15 |>> �� :||: �̖�������ւ�
006 2009-07-20 11:20 �o�b�t�@���w��Ō���������A�Y���s�ɔ�ׂȂ��o�O���C���B

|#

(provide "embedded-grep")
(in-package "editor")

(defvar *eg-keyword-color* '(:color 10 0 :bold)
  "�����\���̐F")
(defvar *eg-keyword-highlight* '(:color 1 3)
  "�������ʕ\���ł̃}�b�`���̐F")
(defvar *eg-capture-command* 'recenter
  "�����\����������Ȃ������ꍇ�̓���")
(defvar *eg-buffer* "*egrep*"
  "embedded-grep���p����o�b�t�@�̖��O")
(defvar *eg-show-line-number* 2
  "�������ʕ\���Ō���։��s�\�����邩")
(defvar *eg-denominate-new-file* (lambda (num) (format nil "~D.txt" num))
  "�V�K�t�@�C���̖����K��")
(defvar *eg-template*
  (lambda (word) (insert (format nil "~%��~A~%" (string-trim "^$[] \t.*" word))))
  "�}���e���v���[�g")
(defvar *eg-verbose* t
  "embedded-grep�̃X�e�[�^�X�o�[�ւ̕\����؂�ւ���Bnil 0 1 2 3 t �� t����Ԃ��邳���B")

(export '(*eg-keyword-color* *eg-keyword-highlight* *eg-capture-command*
		  *eg-buffer* *eg-show-line-number* *eg-denominate-new-file* *eg-template*
		  *eg-verbose*
		  eg-run eg-goto-run-exp eg-release-run-exp))

(defvar *eg-marker-ring* nil)

(defvar eg-heading (compile-regexp "|>> *\\(.*\\)" t))
(defvar eg-inside (compile-regexp ":|\\(.*?\\)|:" t))


(setq eg-regexp-keyword-list
	  (compile-regexp-keyword-list
	   `((,eg-heading t ,*eg-keyword-color* t)
		 (,eg-inside t ,*eg-keyword-color* t))))

(make-local-variable 'regexp-keyword-list)
(setq-default regexp-keyword-list
			  (if (boundp 'regexp-keyword-list)
				  (append regexp-keyword-list eg-regexp-keyword-list)
				eg-regexp-keyword-list))
(global-set-key #\C-l 'eg-run)

(defun eg-run ()
  "embedded-grep�����s����B"
  (interactive)
  (macrolet ((scan (&rest args)
					`(save-excursion (scan-buffer ,@args)))
			 (app (&rest args)
				   `(multiple-value-call 'eg-grep (eg-get-attr ,@args))))
	(cond ((or
			(scan eg-heading :reverse t :limit #1=(save-excursion (goto-bol) (point)))
			(scan eg-heading :limit #2=(save-excursion (goto-eol) (point))))
		   (app (match-beginning 0)
				(if (zerop (- (match-end 1) (match-beginning 1)))
					"" (concat "^" (match-string 1) "[ \t]*$"))))
		  ((or
			(scan eg-inside :reverse t :limit #1#)
			(scan eg-inside :limit #2#))
		   (app (match-beginning 0) (match-string 1)))
		  (t (if *eg-capture-command* (call-interactively *eg-capture-command*))))))


(defun eg-get-attr (limit word)
  "�\���̎�O��path�Ƃ�attr���擾���ĕԂ�"
  (save-excursion
	(goto-char limit)
	(macrolet ((scan ()
				 `(let (inside)
					(loop
					  (if (scan-buffer "\\([ \t\"]\\|$\\)" :regexp t :reverse t :no-dup t)
						  (if (equal (char-after (point)) #\")
							  (setq inside (not inside))
							(if (not inside) (return (1+ (point)))))
						(return 0))))))
	  (let ((attr (split-string (concat (buffer-substring (scan) limit) "|") #\| t)))
		(values
		 (if (zerop (length word)) nil word)
		 (remove "" (if (cdr attr) (butlast attr) attr) :test 'string=)
		 (if (cdr attr) (split-string (car (last attr)) #\:)))))))

(defun eg-sort-predicate (attr)
  (cond ((string= attr ">") 'string>)
		((string= attr "<") 'string<)
		(t nil)))

(defun eg-grep (word path attr)
  "eg-run�̓��암��"
  (let ((arg (and (car attr) (string= "%" (car attr)))))
	(if arg (setq attr (cdr attr))
	  (push (cons (eg-get-buffer-name) (current-line-number)) *eg-marker-ring*)))
  (if path
	  (let ((r (and (car attr) (string= (car attr) "r"))))
		(eg-grep-path-exist path word (if r (cdr attr) attr) r))
	(eg-grep-here word attr)))

#|
(defun eg-grep (word path attr)
  (msgbox "word:~S~%path:~S~%attr:~S" word path attr))
|#

(defun eg-bufferp (name)
  (equal #\< (char name 0)))

(defun eg-grep-path-exist (path word attr recursive)
  "�L����path���w�肳��Ă���ꍇ"
  (let ((files
		 (mapcan (lambda (x)
				   (let ((name (string-trim "\"" x)))
					 (cond ((eg-bufferp name) (list name))
						   (t (let ((d (directory-namestring name))
									(f (file-namestring name)))
								(directory d :wild f
										   :file-only t :absolute t :recursive recursive))))))
				 path)))
	(if files
		(if (cdr files)
			(eg-grep-files-exist path word attr files)
		  (if (eg-set-buffer (car files))
			  (eg-grep-here word attr)))
	  (eg-new-file (car path) word))))

(defun eg-grep-files-exist (path word attr files)
  "�L����file��buffer���w�肳��Ă���ꍇ"
  (let ((p (eg-sort-predicate (car attr))))
	(if word
		(eg-scan-files word p (if p (cdr attr) attr) path files)
	  (eg-files-exist-no-word
	   (if p (cdr attr) attr)
	   (if p (stable-sort files p) files)))))

(defun eg-scan-files (word predicate attr path files)
  "�����t�@�C�����X�L����"
  (let* ((regexp (compile-regexp word t))
		 (res (long-operation
			   (let (l)
				 (handler-case
				  (dolist (a files (apply 'append l))
					(if (eg-read-file a) (push (eg-scan-1 regexp a) l))
					(do-events))
				  (quit (c) (apply 'append l)))))))
	(if res
		(if (cdr res)
			(eg-show-result
			 word
			 (if predicate (stable-sort res predicate :key 'car)
			   (reverse res))
			 attr)
		  (progn (eg-set-buffer (cadar res))
			(goto-line (caddar res))
			(eg-message 3 "���肵���B")))
	  (eg-new-file (car path) word))))

(defun eg-scan-1 (regexp name &aux l)
  "�����̖{��"
  (save-excursion
	(goto-char (point-min))
	(while (scan-buffer regexp :tail t)
	  (push (list (match-string 0) name (current-line-number) (eg-skim-lines))
			l)))
  l)

(defun eg-skim-lines ()
  (buffer-substring (save-excursion (goto-bol) (point))
					(save-excursion
					  (next-line *eg-show-line-number*) (goto-eol) (point))))

(defun eg-get-buffer-name ()
  "�o�b�t�@�̃t�@�C���������O���擾"
  (or (get-buffer-file-name)
	  (concat "<" (buffer-name (selected-buffer)) ">")))

(defun eg-scan-here (word predicate attr)
  "���݂̃o�b�t�@�݂̂��X�L����"
  (let ((res (eg-scan-1 (compile-regexp word t)
						(eg-get-buffer-name))))
	(if res
		(if (cdr res)
			(eg-show-result
			 word
			 (if predicate (stable-sort res predicate :key 'car)
			   (reverse res))
			 attr
			 (syntax-table)
			 (if (boundp 'keyword-hash-table)
				 keyword-hash-table))
		  (progn (goto-line (caddar res)) (eg-message 3 "���肵���B")))
	  (eg-insert-template word))))

(defun eg-set-buffer (name)
  "�o�b�t�@�Ɉړ�"
  (let ((buff (if (eg-bufferp name)
				  (find-buffer (string-trim "<>" name))
				(or (get-file-buffer name)
					(ed::find-file-internal name)))))
	(if buff (set-buffer buff)
	  (eg-message 2 "�Ȃ������恨 ~A" name))))

(defun eg-read-file (name &aux (r t))
  "�����t�@�C����ǂݍ��ށB�o�b�t�@������Έړ�����B"
  (let ((buff (if (eg-bufferp name)
				  (find-buffer (string-trim "<>" name))
				(or (get-file-buffer name)
					(setq r nil)
					(get-buffer-create (concat " " *eg-buffer*))))))
	(when buff
	  (set-buffer buff)
	  (unless r
		(erase-buffer (selected-buffer))
		(insert-file-contents name))
	  (eg-message 1 "���Ă� ~A" name))
	buff))

(defun eg-files-exist-no-word (attr files)
  "file�����݂��Aword���w�肳��Ă��Ȃ��ꍇ"
  (let ((arg (if (car attr) (parse-integer (car attr) :junk-allowed t))))
	(if (and arg (elt files arg))
		(if (eg-set-buffer (elt files arg))
			(eg-no-word (cdr attr)))
	  (eg-show-files files))))

(defun eg-new-file (path word)
  "�t�@�C�������"
  (set-buffer
   (ed::find-file-internal
	(if (string-match "[\\*\\?<>|:\"]" (file-namestring path))
		(let ((num 0))
		  (loop
			(let ((file (merge-pathnames
						 (funcall *eg-denominate-new-file* num)
						 (directory-namestring path))))
			  (if (file-exist-p file) (incf num) (return file)))))
	  path)))
  (when word (eg-insert-template word))
  (set-buffer-modified-p nil))

(defun eg-grep-here (word attr)
  "���݂̃o�b�t�@��ΏۂɌ���"
  (if word
	  (let ((p (eg-sort-predicate (car attr))))
		(eg-scan-here word p (if p (cdr attr) attr)))
	(eg-no-word attr)))

(defun eg-no-word (attr)
  "word���Ȃ��ꍇ�B�ԍ�����������΍s�ړ�����"
  (let ((arg (if (car attr) (parse-integer (car attr) :junk-allowed t))))
	(and arg (progn (goto-line arg) (recenter))))
  (eg-message t "�ړ����Ă݂��B"))

(defun eg-show-result (word res attr &optional syntax keyword)
  "�������ʂ��������ꍇ"
  (let ((arg (if (car attr) (parse-integer (car attr) :junk-allowed t))))
	(if (and arg (elt res arg))
		(if (eg-set-buffer (cadr (elt res arg)))
			(goto-line (caddr (elt res arg))))
	  (let ((buff (get-buffer-create *eg-buffer*)))
		(set-buffer buff)
		(erase-buffer buff)
		(setup-temp-buffer buff)
		(kill-all-local-variables)
		(when syntax (use-syntax-table syntax))
		(when keyword
		  (make-local-variable 'keyword-hash-table)
		  (setf keyword-hash-table keyword))
		(make-local-variable 'regexp-keyword-list)
		(let ((key (compile-regexp-keyword-list
					`((,(compile-regexp word) t ,*eg-keyword-highlight* t)))))
		  (setq regexp-keyword-list
				(if (boundp 'regexp-keyword-list)
					(append regexp-keyword-list key)
				  key)))
		(format (make-buffer-stream buff) "~{~{~*\"~A\"|~A|>>~%~A~%~%~}~}~%~A���݂����B"
				res (length res)))))
  (eg-message 3 "���낢�날�����B"))

(defun eg-show-files (files)
  "�t�@�C���̓��e������"
  (let ((buff (get-buffer-create *eg-buffer*)))
	(set-buffer buff)
	(erase-buffer buff)
	(setup-temp-buffer buff)
	(fundamental-mode)
	(kill-all-local-variables)
	(with-output-to-buffer (buff)
	  (dolist (a files)
		(format t "~A|>>~%" a)
		(if (eg-bufferp a)
			(let ((s (make-buffer-stream ((find-buffer a) (point-min)))))
			  (eg-show-content s))
		  (with-open-file (s a)
			(eg-show-content s)))
		(format t "~%"))))
  (eg-message 3 "���ׂĂ݂��B"))

(defun eg-show-content (input-stream &aux l)
  (dotimes (N/A *eg-show-line-number*)
	(setq l (read-line input-stream nil nil))
	(if l (format t "~A~%" l) (return))))

(defun eg-insert-template (word)
  (interactive "s���ږ�: ")
  (goto-char (point-max))
  (funcall *eg-template* word)
  (eg-message t "���������āB" ))

(defun eg-message (threshold &rest args)
  (if (or
	   (null threshold)
	   (and (numberp threshold)
			(numberp *eg-verbose*)
			(>= *eg-verbose* threshold))
	   (eq t *eg-verbose*))
	  (apply 'message args))
  nil)

(defun eg-goto-run-exp (&optional (pop t))
  "embedded-grep�̌��������ʒu�ɖ߂�B"
  (interactive)
  (let ((marker (if pop (pop *eg-marker-ring*) (car *eg-marker-ring*))))
	(and (if marker t
		   (eg-message 2 "�����Ȃ���"))
		 (eg-set-buffer (car marker))
		 (goto-line (cdr marker))
		 (eg-message t "�߂����B (�c��~A)" (length *eg-marker-ring*)))))

(defun eg-release-run-exp ()
  (interactive)
  (let ((buff (get-buffer-create *eg-buffer*)))
	(set-buffer buff)
	(erase-buffer buff)
	(setup-temp-buffer buff)
	(fundamental-mode)
	(kill-all-local-variables)
	(with-output-to-buffer (buff)
	  (dolist (a *eg-marker-ring*)
		(if (string/= (car a) (concat "<" *eg-buffer* ">"))
			(format t "~A|%:~A|>>~%~A~%~%"
					(car a) (cdr a) (save-excursion (eg-goto-run-exp nil) (eg-skim-lines))))))
	(let ((buff (find-buffer (concat " " *eg-buffer*))))
	  (if buff (delete-buffer buff)))
	(if *prefix-args*
		(eg-message 2 "�\�����Ă݂��B")
		(progn (setq *eg-marker-ring* nil)
		  (eg-message t "���Z�b�g�����B")))))

;;; end of embedded-grep.l