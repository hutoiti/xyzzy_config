;;-*- Mode: lisp; outline-tree: user-regexp-lisp-dots; -*-
#|text
���@�\
  �^�O�t�@�C���𐶐����鎞�Ɏw�肵���t�H���_���A�}�[�W�ΏۂȂ�A������
  ���^�O���}�[�W���܂��B

  *merge-tags-directory-alist* �̓f�B���N�g�����̑g�̃��X�g�ł��B
  (pushnew '("d:/test" "d:/test2") *merge-tags-directory-alist* :test 'equal)
  ��d:/test�ȉ��Ő��������^�O�� d:/test2 �̃^�O�t�@�C���ɂ܂Ƃ߂܂��B

  �f�t�H���g�ł́Asystem-root �ȉ��� XTAGS �����ׂāAsystem-root�ɂ܂�
  �߂܂��B��������ƁA site-lisp�t�H���_�ŏC���������Ă��Alisp�t�H���_
  �^�O���Đ�������K�v�������Ȃ�܂��B

  *make-tags-ignore-paths* �ɖ�������t�@�C���Ƀ}�b�`���鐳�K�\���̃�
  �X�g���w�肷�鎖���ł��܂��B


���C���X�g�[��
 .xyzzy �� siteinit.l �ɉ��̂������Ă��������D
  ni-autoload ���g�p���Ă���l�͕K�v����܂���B
 (require "merge-tags")

���g�p���@
  *merge-tags-directory-alist* ��ݒ肵�Ă��������B
  �^�O�t�@�C���𐶐����鎞�ɏ���Ɏg���܂��B

�����ӎ���
  make-tags-file, tags-setup-buffer ���C�����܂��B


��License
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


copyright 2006-2009   Masahiro Nakano <mnakano.gm@gmail.com>

��Todo
  �E�폜�����E�ړ������t�@�C���̃^�O���폜
  �E�����̃^�O����̏ꏊ�ɂ܂Ƃ߂�̂ł͂Ȃ��A��̃^�O�𕡐��̏ꏊ
    �Ƀ}�[�W������


���X�V����
 on 2009-01-10
  �E�f�B���N�g�����̔�r�� equalp �ł���悤�ɏC��

 on 2009-01-07
  �E����� default-directory ��ύX���Ă��܂��Ă����̂��C��
  �EXTAGS �̐������ɁA�o�b�t�@�T�C�Y���傫���Ȃ�Ƒ��x���x���Ȃ�̂ŁA
    �o�b�t�@�����T�C�Y�ŕ�������悤�ɕύX�B

 on 2009-01-04
  �E�^�O�t�@�C���̍쐬�Ɏ��s����ꍇ������̂��C��

 on 2008-12-11
  �Edebug�p�� �L�[���[�h�V���{����ύX

 on 2008-11-27
  �E�����X�V�̗������f�B���N�g�����ƂɎ��悤�ɏC���B

 on 2008-11-18
  �E�^�O�t�@�C���������ɃG���[���o��̂��C��

 on 2008-10-31
  �E*post-make-tags-hook* ��ǉ�

 on 2007/08/26
  �E*make-tags-ignore-paths* ���@�\���Ȃ��Ȃ��Ă����̂��C��

 on 2007/8/12
  �E�قڍ�蒼��
  �E�����X�V�ɑΉ�
  �E�[���̎w�肪 0 �ȊO�������������̂��C��

 on 2007/1/11
  �E��������p�X�̃}�b�`���O���Astring-looking-at ���� string-matchp 
    �ɕύX

 on 2006/12/10
  �E*make-tags-ignore-paths* ��ǉ��B

 on 2006/12/08
  �Eni-autoload �ł��܂����[�h�ł��Ă��Ȃ������̂��C��

 on 2006/11/21
  �E���J

|#

(provide "merge-tags")
(require "maketags")

(in-package "editor")

(export '(*merge-tags-directory-alist*
	  *make-tags-ignore-paths*
	  *merge-tags-pre-hook*
	  *merge-tags-post-hook*
	  ))

;;. variables

(defvar *merge-tags-directory-alist* `((,(si:system-root) . ,(si:system-root)))
  "�e�v�f��car���̃f�B���N�g���ȉ���XTAGS�� cdr����XTAGS�Ɠ�������B
���̂Ƃ� car���̃f�B���N�g���ɂ́A1�s #use �`�` �Ƃ��������Ă��� XTAGS �����������B")


;(defvar *copy-tags-directory-alist* nil
;  "cdr����XTAGS �������X�V�ł͂Ȃ���������Ƃ��ɁA
;�e�v�f��car���̃f�B���N�g�����g�p���� XTAGS �t�@�C�����R�s�[����B")


(defvar *merge-tags-pre-hook* nil)
(defvar *merge-tags-post-hook* nil)

(defvar *make-tags-ignore-paths* nil
  "�^�O�t�@�C���𐶐����Ȃ��p�X�̃��X�g")

(defvar user::make-tags-file-language "japanese"
  "language: english or japanese")


(defvar *make-tags-file-dialog-error-template* nil)
(define-history-variable *make-tags-file-history-diff-update* nil)
(define-history-variable *make-tags-file-diff-update* t)

;(add-hook '*merge-tags-pre-hook* 'init-merge-tags-directory-alist)


(defun merge-all-subdirectory-p ()
  (and (interactive-p)
       (eq *prefix-args* 'universal-argument)))

(defun get-force-file-buffer (filename)
  (save-excursion
    (if (valid-path-p filename)
	(find-file filename nil t)
      (set-buffer (create-file-buffer filename)))
    (selected-buffer)))

(defun check-merge-tags-directory-alist ()
  (let ((alist *merge-tags-directory-alist*))
    (if (listp alist)
	(dolist (item alist t)
	  (if (not (and (consp item)
			(stringp (car item))
			(stringp (cdr item))))
	      (return nil))))))



;;. �^�O�t�@�C������A�X�V����t�@�C���̃^�O���폜
(defun delete-tag-entries (delete-path-list dest-dir tagsbuffer depth)
  "tagsbuffer ���� delete-path-list �̃p�X���폜"
  #+:mtag-debug (format *mtag-debug* "�Edelete-tag-entries\n  deleting tags of
~{    ~A\n~}  from ~A\n"
		   delete-path-list (get-buffer-file-name tagsbuffer))
  (save-excursion
    (set-buffer tagsbuffer)
    (dolist (delete-path delete-path-list)
      (goto-char (point-min))
      (let ((path (compile-regexp (if (and depth
					   (/= depth 0))
				      (format nil "~A[^/]+" (regexp-quote delete-path))
				    (format nil "~A" (regexp-quote delete-path)))
				  t)))
	(while (scan-buffer path :regexp t)
	  (goto-bol)
	  (delete-region (point)
			 (progn
			   (next-line 1)
			   (point))))))))

;;. �X�V����t�@�C���ꗗ�̐���

(defun sub-directory-file-p (file parent)
  "file �� parent �̃T�u�f�B���N�g���ȉ��ɂ��鎞 t"
  (sub-directory-p (directory-namestring file) parent))

(defun delete-ignore-path (paths)
  "*make-tags-ignore-paths* �ɓo�^����Ă���p�X�� paths ����폜"
  (nreverse (set-difference paths *make-tags-ignore-paths* :test #'sub-directory-file-p)))

(defvar *tag-path-filters* '(delete-ignore-path))

(defun tag-uptodate-file-p (file)
  (let ((tagfile (merge-pathnames *tags-file-name* (directory-namestring file))))
    (file-newer-than-file-p tagfile file)))


(defun get-tag-updating-files (dir depth dest-tagfile &optional diff-update)
  "�^�O�t�@�C�����X�V����t�@�C��"
  (let ((len (length *maketags-list*))
	(default-directory (default-directory))
	(i 1)
	files)
    (message "creating file list to generate tags")
    (dolist (l *maketags-list*)
      (setq i (1+ i))
      (let ((dir-files (directory dir
				  :absolute t
				  :depth depth
				  :recursive (numberp depth)
				  :file-only t
				  :wild (cdr l)))
	    (carl (car l)))
	(if diff-update
	    (setq dir-files (delete-if #'tag-uptodate-file-p dir-files)))
	(dolist (filter *tag-path-filters*)
	  (setq dir-files (funcall filter dir-files)))
	(push (mapcar #'(lambda (x) (cons carl x))
		      (sort dir-files #'string<))
	      files)))
    (let ((ret (apply #'nconc (nreverse files))))
      #+:mtag-debug (format *mtag-debug* "�Eget-tag-obsolete-files\n~{  ~A\n~}" ret)
      ret)))





;;. �X�V��^�O�o�b�t�@�̍X�V

;;.. get-destination-tag-file
(defun get-destination-directory (dir)
  (let ((dirs (assoc-if #'(lambda (x) (sub-directory-p dir x))
			*merge-tags-directory-alist*)))
    (append-trail-slash (namestring (if dirs
					(cdr dirs)
				      dir)))))

#|
(let ((regexp (compile-regexp (format nil "[][^]*"))))
  (defun update-tag-path (path tagsbuffer)
    "tagsbuffer �̑��΃p�X�� path ��ǉ����Đ�΃p�X�֕ϊ�"
    (set-buffer tagsbuffer)
    (goto-char (point-min))
    (setq path (append-trail-slash path))
    (let ((rstring (format nil "\\0~A" path)))
      (while (scan-buffer regexp)
	(replace-match rstring)))
    (set-buffer-modified-p nil)))
|#

;;.. merge-tags-file
(defun merge-tags-file (dir dest-dir dest-buffer)
  "dir/.XTAGS ���Adest-buffer �ɒǉ�����B"
  #+:mtag-debug (format *mtag-debug* "�Emerge-tags-file\n")
  ;; merge����
  (let* ((filename (merge-pathnames (concat "." *tags-file-name*) dir))
	 dot-tags-buffer)
    (when (file-exist-p filename)
      (setq dot-tags-buffer (get-force-file-buffer filename))

      ;(update-tag-path (if (sub-directory-p dir dest-dir)
      ;                     (substring dir (length dest-dir))
      ;                   dir)
      ;                 dot-tags-buffer)
      (set-buffer dest-buffer)
      (insert-buffer dot-tags-buffer)
      (write-file (merge-pathnames *tags-file-name* dest-dir) t)
      ;#+:mtag-debug (format *mtag-debug* "�Emerged-contents\n~A\n\n"
      ;                 (save-excursion
      ;                   (set-buffer dot-tags-buffer)
      ;                   (buffer-substring (point-min) (point-max))))
      (delete-buffer dot-tags-buffer)
      (delete-file filename :if-does-not-exist :skip)

      (make-use-abs-path-tag-file dir dest-dir)
      t)))




;;. #USE �p�^�O�t�@�C���̐���
(defun make-use-tag-files (parent-dir fun-file-list)
  (let ((temp-buffer (create-new-buffer " *temp*")))
    (setq parent-dir (append-trail-slash parent-dir))
    (set-buffer temp-buffer)
    (mapc #'(lambda (d)
	      (setq d (append-trail-slash d))
	      (if (sub-directory-p d parent-dir)
		  (unless (= (length d) (length parent-dir))
		    (erase-buffer temp-buffer)
		    (insert "#USE ")
		    (dotimes (i (count #\/ d :start (length parent-dir)))
		      (insert "../"))
		    (insert "\n")
		    (write-file (merge-pathnames *tags-file-name* d) t)
		    (let ((buffer (find-tags-buffer d)))
		      (and buffer (delete-buffer buffer))))
		(progn
		  (erase-buffer temp-buffer)
		  (insert parent-dir))))
	  (delete-duplicates (mapcar #'(lambda (x)
					 (directory-namestring (cdr x)))
				     fun-file-list)
			     :test #'equal))
    (if temp-buffer (delete-buffer temp-buffer))
    ))

(defun make-use-abs-path-tag-file (dir dest-dir)
  (if (sub-directory-p dir dest-dir)
      (make-use-tag-files dest-dir (list (cons nil dir)))
    (let ((buffer (create-new-buffer "temp")))
      (save-excursion
	(set-buffer buffer)
	(insert "#USE " dest-dir "\n")
	(write-file (merge-pathnames *tags-file-name* dir) t)
	(delete-buffer buffer)))))

;;. make-tags-file ���C����������
(defun make-tags-file1 (dir fun-file-list output &optional depth diff-update)
  ".XTAGS�̐����B"
  (interactive "DMake TAGS file: \np")
  (long-operation
    #+:mtag-debug (format *mtag-debug* "�Emake-tags-file1 ~A,\n   size ~A, dest ~A, depth ~A, diff-update ~A\n"
		     dir (length fun-file-list) output depth diff-update)
    (let ((count 0))
      (save-excursion
	(let ((len-output (length output))
	      (threashold-size 1024000)
	      (temp-buffer (create-new-buffer "*MAKE-XTAGS*"))
	      (*standard-output* *standard-output*)
	      all-temp-buffers)
	  (setq *standard-output* (make-buffer-stream temp-buffer))
	  (push temp-buffer all-temp-buffers)
	  (let ((total-files (length fun-file-list))
		(current-file 0)
		(buffer nil))
	    (unwind-protect
		(progn
		  (setq buffer (create-new-buffer "XTAGS"))
		  (set-buffer buffer)
		  #+:mtag-debug (format *mtag-debug* "�EParsing files\n")
		  (dolist (fun-file fun-file-list)
		    (let ((file (cdr fun-file)))
		      #+:mtag-debug (format *mtag-debug* "  - ~A\n" file)
		      (erase-buffer buffer)
		      (insert-file-contents file t)
		      (setq current-file (1+ current-file))
		      (message "Parsing ~a...~d (~d of ~d files)"
			       file count current-file total-files)
		      (when (or (> (buffer-size temp-buffer) threashold-size)
				(and (> (buffer-size) threashold-size)
				     (> (buffer-size temp-buffer) (/ threashold-size 10))))
			;; temp-buffer �̕���
			(setq temp-buffer (create-new-buffer "*MAKE-XTAGS*"))
			#+:mtag-debug (format *mtag-debug* "buffer is too big!\n  next temp-buffer: ~A\n" temp-buffer)
			(setq *standard-output* (make-buffer-stream temp-buffer))
			(push temp-buffer all-temp-buffers))
		      ;; file �̃^�O�𐶐�
		      (ignore-errors
			(setq count (funcall (car fun-file)
					     (if (eql (string-not-equal output file)
						      len-output)
						 (substring file len-output)
					       file)
					     count)))))
		  (message "Parsed : ~d (~d of ~d files)"
			   count current-file total-files))
	      (progn
		(and buffer
		     (not (deleted-buffer-p buffer))
		     (delete-buffer buffer))))
	    #+:mtag-debug (format *mtag-debug* "�Efinished parsing\n")
	    ;(setq all-temp-buffers (nreverse all-temp-buffers))
	    ;(setq temp-buffer (car all-temp-buffers))
	    (dolist (temp all-temp-buffers)
	      (set-buffer temp)
	      (goto-char (point-min))
	      (perform-replace "[\n\t\f]" " " nil t nil t)
	      (goto-char (point-min))
	      (perform-replace "  +" " " nil t nil t)
	      (goto-char (point-min))
	      (perform-replace "\036" "\n" nil nil nil t))
	    ;; .XTAGS �ɏ����o��
	    #+:mtag-debug (format *mtag-debug* "�Ewriting ~A\n" (merge-pathnames (concat "." *tags-file-name*) dir))
	    (let ((dotxtags-file (merge-pathnames (concat "." *tags-file-name*) dir)))
	      (setq all-temp-buffers (nreverse all-temp-buffers)
		    temp-buffer (car all-temp-buffers))
	      (set-buffer temp-buffer)
	      (write-file dotxtags-file)
	      (dolist (temp (cdr all-temp-buffers))
		(set-buffer temp)
		(append-file dotxtags-file t)))
	    #+:mtag-debug (format *mtag-debug* "�Egenerated .XTAGS\n~A\n\n"
				  (buffer-substring (point-min) (point-max)))

	    (when (numberp depth)
	      (make-use-tag-files output fun-file-list))
	    )
	  (dolist (temp all-temp-buffers)
	    (and temp
		 (not (deleted-buffer-p temp))
		 (delete-buffer temp))))
	(let ((output-buffer (find-tags-buffer output)))
	  (and output-buffer (delete-buffer output-buffer))))
      #+:mtag-debug (format *mtag-debug* "�Eend of make-tags-file1, generated .XTAGS? ~A\n"
		       (file-exist-p (merge-pathnames (concat "." *tags-file-name*) output)))
      count)))

#|(defun make-tags-file1 (dir fun-file-list output &optional depth diff-update)
  ".XTAGS�̐����B"
  (interactive "DMake TAGS file: \np")
  (long-operation
    #+:mtag-debug (format *mtag-debug* "�Emake-tags-file1 ~A,\n   size ~A, dest ~A, depth ~A, diff-update ~A\n"
		     dir (length fun-file-list) output depth diff-update)
    (let ((count 0))
      (save-excursion
	(let ((len-output (length output))
	      (i 0)
	      temp-buffer)
	  (with-output-to-temp-buffer ("*MAKE-XTAGS*" nil)
	    (setq temp-buffer (buffer-stream-buffer *standard-output*))
	    (let ((total-files (length fun-file-list))
		  (current-file 0)
		  (buffer nil))
	      (unwind-protect
		  (progn
		    (setq buffer (create-new-buffer "XTAGS"))
		    (set-buffer buffer)
		    #+:mtag-debug (format *mtag-debug* "�EParsing files\n")
		    (dolist (fun-file fun-file-list)
		      (let ((file (cdr fun-file)))
			#+:mtag-debug (format *mtag-debug* "  - ~A\n" file)
			(erase-buffer buffer)
			(insert-file-contents file t)
			(setq current-file (1+ current-file))
			(message "Parsing ~a...~d (~d of ~d files)"
				 file count current-file total-files)
			;; file �̃^�O�𐶐�
			(ignore-errors
			     (setq count (funcall (car fun-file)
						  (if (eql (string-not-equal output file)
							   len-output)
						      (substring file len-output)
						    file)
						  count)))))
		    (message "Parsed : ~d (~d of ~d files)"
			     count current-file total-files))
		(progn
		  (and buffer
		       (not (deleted-buffer-p buffer))
		       (delete-buffer buffer))))
	      #+:mtag-debug (format *mtag-debug* "�Efinished parsing\n")

	      (set-buffer temp-buffer)
	      (goto-char (point-min))
	      (perform-replace "[\n\t\f]" " " nil t nil t)
	      (goto-char (point-min))
	      (perform-replace "  +" " " nil t nil t)
	      (goto-char (point-min))
	      (perform-replace "\036" "\n" nil nil nil t)
	      ;; .XTAGS �ɏ����o��
	      #+:mtag-debug (format *mtag-debug* "�Ewriting ~A\n" (merge-pathnames (concat "." *tags-file-name*) dir))
	      (write-file (merge-pathnames (concat "." *tags-file-name*) dir))
	      #+:mtag-debug (format *mtag-debug* "�Egenerated .XTAGS\n~A\n\n"
			       (buffer-substring (point-min) (point-max)))

	      (when (numberp depth)
		(make-use-tag-files output fun-file-list))
	      ))
	  (and temp-buffer
	       (not (deleted-buffer-p temp-buffer))
	       (delete-buffer temp-buffer)))
	(let ((output-buffer (find-tags-buffer output)))
	  (and output-buffer (delete-buffer output-buffer))))
      #+:mtag-debug (format *mtag-debug* "�Eend of make-tags-file1, generated .XTAGS? ~A\n"
		       (file-exist-p (merge-pathnames (concat "." *tags-file-name*) output)))
      count)))
|#


(defun kill-tags-buffers ()
  (let ((buffers (buffer-list)))
    (dolist (buffer buffers)
      (if (equalp " *TAGS*" (buffer-name buffer))
	  (delete-buffer buffer)))
    t))


;;. tags.l maketags.l �̊֐����Ē�`
;;.. tags-setup-buffer ���Ē�`
(defun tags-setup-buffer ()
  "�^�O�o�b�t�@�� #USE ������ǂ�A�ŏI�^�O�t�@�C���̃o�b�t�@��Ԃ��B
��΃p�X��������悤�ɏC��"
  (let ((file (merge-pathnames *tags-file-name* (default-directory))))
    (if (not (file-exist-p file))
        (return-from tags-setup-buffer)))
  (let ((buffer (or (find-tags-buffer)
                    (create-tags-buffer)))
	(goal-column (goal-column)))
    (save-excursion
      (loop
        (set-buffer buffer)
        (goto-char (point-min))
        (if (looking-at "#USE \\(.*\\)$")
	    (let ((d (namestring (match-string 1))))
	      (setq buffer (or (find-tags-buffer d)
                               (create-tags-buffer d)))
              (setq tags-use-buffer buffer)
              (set-buffer buffer)
              (goto-char (point-min)))
          (return))))
    (set-goal-column goal-column)
    buffer))

;;.. make-tags-file ���Ē�`
(defun make-tags-file (dir &optional depth diff-update)
  "make-tags-file + merge-tags-file"
  (interactive "DMake TAGS file: \np")
  (when (and (interactive-p)
	     (eq *prefix-args* 'universal-argument))
    (setq depth 0))
  (long-operation
    (save-excursion
      #+:mtag-debug (let ((buffer (get-buffer-create "*mtag-debug*")))
		 (save-excursion
		   (set-buffer buffer)
		   (lisp-mode)
		   (delete-region (point-min) (point-max))
		   (setq *mtag-debug* (make-buffer-stream buffer)))
		 (format *mtag-debug* "\n;;-------- by merge-tags -------\n�Emake-tags-file ~w ~w ~w\n"
			 dir depth diff-update)
		 )
      (unless (check-merge-tags-directory-alist)
	(msgbox "Error! *merge-tags-directory-alist* is invalid\n~{~A\n~}"
		*merge-tags-directory-alist*)
	(error "Invalid *merge-tags-directory-alist*"))
      ;(if (merge-all-subdirectory-p)
      ;    (setq depth 0))
      (setq dir (append-trail-slash (namestring dir)))
      (run-hooks '*merge-tags-pre-hook*)


      (let* ((fun-file-list (get-tag-updating-files
			     dir depth
			     (merge-pathnames *tags-file-name* dir)
			     diff-update))
	     (dest-dir (get-destination-directory dir))
	     (dest-buffer (get-force-file-buffer (merge-pathnames *tags-file-name* dest-dir)))
	     (len (length dest-dir))
	     (count 0))
	#+:mtag-debug (format *mtag-debug* "�Eupdating ~A directory to ~A\n" dir dest-dir)
	(unwind-protect
	    (let (file-paths)
	      ;; �X�V��^�O�t�@�C������Â��^�O�����폜
	      (if diff-update
		  (setq file-paths (mapcar #'cdr fun-file-list))
		(if (not (path-equal dir dest-dir))
		    (setq file-paths (delete-duplicates
					  (mapcar #'(lambda (x) (directory-namestring (cdr x)))
						  fun-file-list)
					  :test #'equal))))
	      (when file-paths
		(if (sub-directory-p dir dest-dir)
		    (setq file-paths (mapcar #'(lambda (x) (substring x len)) file-paths)))
		(delete-tag-entries file-paths dest-dir dest-buffer depth))

	      ;; �^�O�t�@�C���� .XTAGS �ɐ���
	      (setq count (make-tags-file1 dir fun-file-list dest-dir depth diff-update))

	      ;; XTAGS �̐���
	      (if (or diff-update
		      (not (path-equal dir dest-dir)))
		  (merge-tags-file dir dest-dir dest-buffer)
		(progn
		  #+:mtag-debug (format *mtag-debug* "�Emove .XTAGS XTAGS, ~A ~A\n"
				   (file-exist-p (merge-pathnames (concat "." *tags-file-name*) dir))
				   (file-exist-p (merge-pathnames *tags-file-name* dir)))

		  (rename-file (merge-pathnames (concat "." *tags-file-name*) dir)
			       (merge-pathnames *tags-file-name* dir)
			       :if-exists :overwrite)))
	      ;; copy����^�O�t�@�C����ǉ�
	      (unless diff-update
		
		)
	      #+:mtag-debug (format *mtag-debug* "Successfully finished\n")
	      )
	  (progn
	    (kill-tags-buffers)
	    (and dest-buffer
		 (not (deleted-buffer-p dest-buffer))
		 (delete-buffer dest-buffer))))
	(let ((total-files (length fun-file-list)))
	  (message "Parsed : ~d items (~d of ~d files)"
		   count total-files total-files)
	  (run-hooks '*merge-tags-post-hook*))
	t))))


(defun make-tags-file-dialog-template-english ()
  '(dialog 0 0 226 96
    (:caption "Make Tag Files")
    (:font 9 "MS UI Gothic")
    (:control
     (:static nil "&Source directory:" #x50020000 7 7 58 8)
     (:edit src nil #x50810080 7 19 148 14)
     (:button diff "Diff Update (&I)" #x50010003 7 48 130 10)
     (:button subdir "Also search in subdirectories(&U)" #x50010003 7 63 130 10)
     (:static nil "Search subdirectory &depth:" #x50020000 9 78 80 8)
     (:edit depth nil #x50810086 89 75 36 14)
     (:spin depthspin "Spin1" #x500000b6 119 70 9 14)
     (:static nil "(0 means unlimited)" #x50020000 129 78 60 8)
     (:button IDOK "OK" #x50010001 169 7 50 14)
     (:button IDCANCEL "Cancel" #x50010000 169 24 50 14)
     (:button ref "&Refer" #x50010000 169 41 50 14))))

(defun make-tags-file-dialog-error-message-english ()
  '((src :non-null "Input a source directory!" :enable (IDOK))
    (depth :type integer :min 0 :max 10000
	   :range-error "Depth is greater than or equal to 0"
	   :type-error "Input Number")
    (depthspin :min 0 :max 10000)
    (ref :related src :directory-name-dialog (:title "Reference"))))


(defun make-tags-file-dialog-template-japanese ()
  '(dialog 0 0 226 96
    (:caption "�^�O�t�@�C���̐���")
    (:font 9 "MS UI Gothic")
    (:control
     (:static nil "�\�[�X�f�B���N�g��(&S):" #x50020000 7 7 58 8)
     (:edit src nil #x50810080 7 19 148 14)
     (:button diff "�����X�V(&I)" #x50010003 7 48 102 10)
     (:button subdir "���łɃT�u�f�B���N�g����(&U)" #x50010003 7 63 102 10)
     (:static nil "��������K�w�̐[��(&D):" #x50020000 9 78 80 8)
     (:edit depth nil #x50810086 89 75 36 14)
     (:spin depthspin "Spin1" #x500000b6 119 70 9 14)
     (:static nil "(0�͖�����)" #x50020000 129 78 48 8)
     (:button IDOK "OK" #x50010001 169 7 50 14)
     (:button IDCANCEL "�L�����Z��" #x50010000 169 24 50 14)
     (:button ref "�Q��(&R)..." #x50010000 169 41 50 14))
    ))

(defun make-tags-file-dialog-error-message-japanese ()
  '((src :non-null "�\�[�X�f�B���N�g������͂���" :enable (IDOK))
    (depth :type integer :min 0 :max 10000
	   :range-error "�K�w�̐[��0�ȏ�ł�"
	   :type-error "���l����͂��Ă�������")
    (depthspin :min 0 :max 10000)
    (ref :related src :directory-name-dialog (:title "�Q��"))))


(cond ((equalp user::make-tags-file-language "english")
       (setq *make-tags-file-dialog-template* (make-tags-file-dialog-template-english))
       (setq *make-tags-file-dialog-error-template* (make-tags-file-dialog-error-message-english)))
      ((equalp user::make-tags-file-language "japanese")
       (setq *make-tags-file-dialog-template* (make-tags-file-dialog-template-japanese))
       (setq *make-tags-file-dialog-error-template* (make-tags-file-dialog-error-message-japanese)))
      (t
       (setq *make-tags-file-dialog-template* (make-tags-file-dialog-template-english))
       (setq *make-tags-file-dialog-error-template* (make-tags-file-dialog-error-message-english))))


;;.. diff-update �̃q�X�g���@�\
(defun get-diff-update-status (dir)
  (let ((status (assoc dir *make-tags-file-history-diff-update* :test 'equalp)))
    (if status
	(cdr status)
      *make-tags-file-diff-update*)))

(defun set-diff-update-status (dir val)
  (let ((status (assoc dir *make-tags-file-history-diff-update* :test 'equalp)))
    (if status
	(setf (cdr status) val)
      (push (cons dir val) *make-tags-file-history-diff-update*))))
;(setq *make-tags-file-history-diff-update* nil)
(setq *make-tags-file-history-diff-update*
      (delete-duplicates *make-tags-file-history-diff-update* :test 'equalp :key 'car))

;;.. make-tags-file-dialog �̍Ē�`
(defun make-tags-file-dialog ()
  (interactive)
  (multiple-value-bind (result data)
      (dialog-box *make-tags-file-dialog-template*
		  (list (cons 'src (default-directory))
			(cons 'diff (get-diff-update-status (default-directory)))
			(cons 'subdir *make-tags-file-subdir*)
			(cons 'depthspin
			      (if *make-tags-file-subdir*
				  *make-tags-file-depth*
				0)))
		  *make-tags-file-dialog-error-template*
		  )
    (when result
      (let* ((src (cdr (assoc 'src data)))
	     (diff (cdr (assoc 'diff data))))
	(set-diff-update-status src diff)
	(setq *make-tags-file-subdir* (cdr (assoc 'subdir data)))
	(setq *make-tags-file-depth* (cdr (assoc 'depth data)))
	(if (stringp *make-tags-file-depth*)
	    (setq *make-tags-file-depth* (parse-integer *make-tags-file-depth*)))
	(make-tags-file src
			(and *make-tags-file-subdir*
			     *make-tags-file-depth*)
			diff)))))

#| for debug

(let ((path "c:/melted/xyzzy"))
  (pushnew (cons path path) *merge-tags-directory-alist* :test 'equal :key 'car))

debug mode �œ������ꍇ�́A�ȉ��̃R�[�h�����s��A�ă��[�h�B
�o�C�g�R���p�C�����Ă���΁A�o�C�g�R���p�C�����Y�ꂸ�ɁB

(progn
  (pushnew :mtag-debug *features*)
  (defvar *mtag-debug* nil)
  (eval-buffer (selected-buffer)))

(setq *features* (delete :mtag-debug *features*))

|#

#|text

��diff-update or ���f�B���N�g���ւ�XTAGS�����o��
     �X�V��XTAGS�̎擾
     �^�O�X�V�K�v�t�@�C���擾
     ���݂̃^�O�t�@�C������A���̃G���g���[���폜
     �X�V�^�O�̐��� (.XTAGS)
     �}�[�W����


������ȊO
     �X�V��XTAGS�̎擾
     �^�O�X�V�K�v�t�@�C���擾
     ���݂̃^�O�t�@�C���͂��̂܂�
     �X�V�^�O�̐��� (.XTAGS)
     .XTAGS -> XTAGS

|#