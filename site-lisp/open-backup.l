;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; open-backup.l
;;;
;;; Last updated: "2006-07-27"
;;;

(provide "open-backup")

(in-package "editor")

(export '(open-backup-file-new open-backup-dialog
	  *open-backup-no-date-duplication*))

(defvar *open-backup-no-date-duplication* nil)

(defun open-backup-get-alist (file no-dup)
  (let ((list (open-backup-get-list file no-dup)) column alist day)
    (when list
      (setq col (length (pathname-type (car list))))
      (dolist (f list (nreverse alist))
	(let* ((type (pathname-type f))
	       (time (file-write-time f))
	       (s1 (format nil " ~A~A:"
			   (make-sequence 'string (- col (length type))
					  :initial-element #\0)
			   (substring type 0 -1)))
	       (s2 (format-date-string "%Y-%m-%d" time))
	       (s3 (format-date-string "%H:%M:%S" time)) s)
	  (if (string/= day s2)
	      (progn
		(setq day s2)
		(setq s (format nil "~A  ~A   ~A" s1 s2 s3)))
	    (setq s (format nil "~A                    ~A" s1 s3)))
	  (push (list s f) alist))))))

(defun open-backup-get-list (file no-dup)
  (let ((dir (open-backup-get-dir file)))
    (unless dir (setq dir (directory-namestring file)))
    (open-backup-get-list-dir dir file no-dup)))

;;; lisp/backup.l の make-backup-directory-hook のコードを借用
(defun open-backup-get-dir (file)
  (let* ((dir (directory-namestring file))
	 (templ nil)
	 (backup (cond ((null *backup-directory*)
			(return-from open-backup-get-dir nil))
		       ((stringp *backup-directory*)
			*backup-directory*)
		       ((consp *backup-directory*)
			(dolist (x *backup-directory*
				   (return-from open-backup-get-dir nil))
			  (setq templ (car x))
			  (when (and (>= (length dir) (length templ))
				     (string-equal templ dir
						   :end2 (length templ)))
			    (when (null (cdr x))
			      (return-from open-backup-get-dir nil))
			    (return (cdr x)))))
		       (t
			(or (funcall *backup-directory* file)
			    (return-from open-backup-get-dir nil))))))
    (when (prog1
	      (find #\/ backup)
	    (setq backup (append-trail-slash (merge-pathnames backup dir))))
      (setq backup (format nil "~A~{~A/~}" backup
			   (split-string (subseq dir (length templ)) "/:"))))
    backup))

(defun open-backup-get-list-dir (dir file no-dup)
  (let ((olist (sort
		(delete nil
			(mapcar #'(lambda (f)
				    (and (string-equal (pathname-name f)
						       (file-namestring file))
					 (string-match (compile-regexp
							"\\.\\([0-9]+\\)~$")
						       f)
					 f))
				(directory dir :absolute t :file-only t)))
		#'string>=
		:key #'(lambda (f)
			 (and (string-match (compile-regexp "\\.\\([0-9]+\\)~$")
					    f)
			      (format nil "~3A" (match-string 1))))))
	day)
    (if no-dup
	(let (list)
	  (dolist (f olist (nreverse list))
	    (let ((s (format-date-string "%Y-%m-%d" (file-write-time f))))
	      (and (string/= day s) (setq day s) (push f list)))))
      olist)))

(defun open-backup-file-new ()
  (interactive)
  (or (file-visited-p) (error "ファイル名がありません"))
  (let ((file (get-buffer-file-name)) list)
    (and (string-match (compile-regexp "\\.[0-9]+~$") file)
	 (setq file (open-backup-get-target-file file)))
    (if (setq list (open-backup-get-list file nil))
	(open-backup-file (car list))
      (msgbox "バックアップはありません"))))

(defun open-backup-file (file)
  (let ((buffer (buffer-name (selected-buffer)))
	(mode buffer-mode)
	(ln (current-line-number))
	(wln (get-window-line)))
    (find-file-internal file)
    (switch-to-buffer (get-file-buffer file))
    (funcall mode)
    (open-backup-mode t)
    (setq open-backup-buffer buffer)
    (goto-line ln)
    (recenter wln)))

(defun open-backup-template (type file)
  (let ((len (length type)) width)
    (case len
      (2 (setq width 159))
      (3 (setq width 162))
      (4 (setq width 165)))
    `(dialog 0 0 ,width 123
	     (:caption ,(format nil "~A のバックアップ" (file-namestring file)))
	     (:font 9 "MS UI Gothic")
	     (:control
	      (:listbox list nil #x50a10011 4 5 ,(- width 68) 114)
	      (:button open "開く(&O)" #x50030001 ,(- width 55) 5 52 14)
	      (:button clear "全削除(&C)" #x50030000 ,(- width 55) 22 52 14)
	      (:button IDCANCEL "キャンセル" #x50030000 ,(- width 55) 39 52 14)))))

(defun open-backup-dialog ()
  (interactive)
  (open-backup-dialog-1 *open-backup-no-date-duplication*))

(defun open-backup-dialog-1 (no-dup)
  (or (file-visited-p) (error "ファイル名がありません"))
  (let* ((ofile (get-buffer-file-name)) (file ofile) alist)
    (if (string-match (compile-regexp "\\.[0-9]+~$") file)
	(progn
	  (setq file (open-backup-get-target-file file))
	  (if no-dup
	      (let ((al (open-backup-get-alist file t))
		    (f (get-buffer-file-name)))
		(cond ((null al) ;バックアップファイル上で全削除した場合
		       (setq alist nil))
		      ((find f al :test #'string-equal :key #'cadr)
		       (setq alist al))
		      (t
		       (let* ((type (pathname-type f))
			      (s1 (format nil " ~A~A:"
					  (make-sequence
					   'string
					   (- (length (pathname-type (cadar al)))
					      (length type))
					   :initial-element #\0)
					  (substring type 0 -1)))
			      (s2 (format-date-string "%H:%M:%S"
						      (file-write-time f))))
			 (push (list (format nil "~A                    ~A"
					     s1 s2)
				     f)
			       al)
			 (setq alist (sort al #'string>= :key #'car))))))
	    (setq alist (open-backup-get-alist file nil))))
      (setq alist (open-backup-get-alist file no-dup)))
    (if alist
	(multiple-value-bind (result data)
	    (dialog-box (open-backup-template (pathname-type (cadar alist))
					      file)
			(list (cons 'list alist)
			      (cons 'list
				    (find ofile alist
					  :test #'string-equal :key #'cadr)))
			'((list :must-match t
				:enable (open))
			  (clear :no-result t)))
	  (cond
	   ((eq result 'open)
	    (open-backup-file (caddr (assoc 'list data))))
	   ((eq result 'clear)
	    (if *open-backup-no-date-duplication*
		(open-backup-clear file (open-backup-get-list file nil))
	      (open-backup-clear file (mapcar #'cadr alist))))))
      (msgbox "バックアップはありません"))
    ))

(defun open-backup-get-target-file (file)
  (cond ((null *backup-directory*)
	 (open-backup-get-target-file-1 file))
	((stringp *backup-directory*)
	 (open-backup-get-target-file-2 file))
	((consp *backup-directory*)
	 (open-backup-get-target-file-3 file))
	((or (symbolp *backup-directory*) (functionp *backup-directory*))
	 (open-backup-get-target-file-4 file))))

(defun open-backup-get-target-file-1 (file)
  (concat (directory-namestring file) (pathname-name file)))

(defun open-backup-get-target-file-2 (file)
  (open-backup-get-target-file-string file *backup-directory*))

(defun open-backup-get-target-file-string (file string)
  (when (string-matchp (concat (remove-trail-slash (truename string))
			       "/\\([^/]+\\)\\(/.+\\)\\.[0-9]+~$")
		       file)
    (let ((s1 (match-string 1)) (s2 (match-string 2)))
      (if (file-directory-p (concat s1 ":/"))
	  (format nil "~A:~A" s1 s2)
	(format nil "//~A~A" s1 s2)))))

(defun open-backup-get-target-file-3 (file)
  (let ((mem (find (directory-namestring file) *backup-directory*
		   :test #'(lambda (d1 d2)
			     (if (< 0 (length (cdr d2)))
				 (sub-directory-p d1 (cdr d2))
			       (sub-directory-p d1 (car d2)))))))
    (when mem
      (if (< 0 (length (car mem)))
	  (if (< 0 (length (cdr mem)))
	      (open-backup-get-target-file-string-1 file (car mem) (cdr mem))
	    (open-backup-get-target-file-string-1 file (car mem) (car mem)))
	(if (< 0 (length (cdr mem)))
	    (open-backup-get-target-file-string file (cdr mem))
	  (open-backup-get-target-file-1 file))
	))
    ))

(defun open-backup-get-target-file-string-1 (file str1 str2)
  (when (string-matchp (concat (remove-trail-slash (truename str2))
			       "\\(/.+\\)\\.[0-9]+~$")
		       file)
    (concat (remove-trail-slash (truename str1)) (match-string 1))))

(defun open-backup-get-target-file-4 (file)
  (let ((dir (directory-namestring file)) (str "") target)
    (while (string-matchp (concat str "[^/\n]+/") file)
      (let ((s (match-string 0)))
	(setq target (open-backup-get-target-file-string file s))
	(and target
	     (string-equal (open-backup-get-dir target);nil になることもある
			   (truename dir))
	     (return-from open-backup-get-target-file-4 target))
	(setq str s)))
    (setq target (open-backup-get-target-file-1 file))
    (and (null (open-backup-get-dir target)) target)))

(defun open-backup-clear (file list)
  (when (yes-or-no-p "~A のバックアップを全削除しますか?"
		     (file-namestring file))
    (dolist (f list)
      (message "deleting ~A" f)
      (delete-file f
		   :if-does-not-exist :skip
		   :recycle  *filer-use-recycle-bin*)
      (message "deleting ~A...done" f))
    (message "全部削除しました")))

(defvar-local open-backup-mode nil)

(defvar *open-backup-mode-map*
  (let ((keymap (make-sparse-keymap)))
    (define-key keymap #\n 'open-backup-file-next)
    (define-key keymap #\p 'open-backup-file-previous)
    (define-key keymap #\M-n 'open-backup-file-next-date)
    (define-key keymap #\M-p 'open-backup-file-previous-date)
    (define-key keymap #\N 'open-backup-file-latest)
    (define-key keymap #\P 'open-backup-file-oldest)
    (define-key keymap #\q 'open-backup-file-quit)
    keymap))

(defun open-backup-mode (&optional (arg nil sv))
  (interactive "p")
  (toggle-mode 'open-backup-mode arg sv)
  (if open-backup-mode
      (progn
	(setq buffer-read-only t)
	(make-local-variable 'mode-line-format)
	(open-backup-mode-line-format (get-buffer-file-name))
	(make-local-variable 'open-backup-buffer)
	(set-minor-mode-map *open-backup-mode-map*))
    (progn
      (setq buffer-read-only nil)
      (setq mode-line-format "--%*- %b (%M) [%k:%l] %P %f")
      (unset-minor-mode-map *open-backup-mode-map*)))
  (update-mode-line t))

(defun open-backup-mode-line-format (file)
  (when file
    (let ((time (format-date-string "%Y-%m-%d %H:%M:%S" (file-write-time file))))
      (setq mode-line-format (format nil "--%*- %b ~A (%M) [%k:%l] %P %f"
				     time)))))

(pushnew '(open-backup-mode . "OpenBackup") *minor-mode-alist* :key #'car)

(defun open-backup-file-next (&optional (arg 1))
  (interactive "p")
  (let* ((file (get-buffer-file-name))
	 (list (open-backup-get-list-dir
		(directory-namestring file)
		(substring file 0 (string-match (compile-regexp "\\.[0-9]+~$")
						file))
		nil))
	 (pos (position file list :test #'string-equal))
	 (ln (current-line-number))
	 (wln (get-window-line)))
    (when list
      (if (plusp arg)
	  (let ((new (if (plusp pos) (nth (1- pos) list))))
	    (if new
		(open-backup-insert-file new ln wln)
	      (message "次のはないっす")))
	(let ((old (nth (1+ pos) list)))
	  (if old
	      (open-backup-insert-file old ln wln)
	    (message "前のはないっす")))))
    ))

(defun open-backup-insert-file (file ln wln)
  (let ((buffer-read-only nil))
    (declare (special buffer-read-only))
    (rename file t)
    (open-backup-mode-line-format file)
    (delete-region (point-min) (point-max))
    (insert-file file)
    (goto-line ln)
    (recenter wln)
    (set-buffer-modified-p nil)))

(defun open-backup-file-previous (&optional (arg 1))
  (interactive "p")
  (open-backup-file-next (- arg)))

(defun open-backup-file-next-date (&optional (arg 1))
  (interactive "p")
  (let* ((file (get-buffer-file-name))
	 (alist (open-backup-get-alist-dir
		 (directory-namestring file)
		 (substring file 0 (string-match (compile-regexp "\\.[0-9]+~$")
						 file))))
	 (pos (position (format-date-string "%Y-%m-%d"
					    (file-write-time file))
			alist :test #'string= :key #'cdr))
	 (ln (current-line-number))
	 (wln (get-window-line)))
    (when alist
      (if (plusp arg)
	  (let ((f1 (car (nth pos alist)))
		(f2 (if (plusp pos) (car (nth (1- pos) alist)))))
	    (if (string= f1 file)
		(if f2
		    (open-backup-insert-file f2 ln wln)
		  (message "次の日付はないっす"))
	      (open-backup-insert-file f1 ln wln)))
	(let ((old (nth (1+ pos) alist)))
	  (if old
	      (open-backup-insert-file (car old) ln wln)
	    (message "前の日付はないっす")))))
    ))

(defun open-backup-get-alist-dir (dir file)
  (let (list day)
    (dolist (f (sort
		(delete nil
			(mapcar #'(lambda (f)
				    (and (string-equal (pathname-name f)
						       (file-namestring file))
					 (string-match (compile-regexp
							"\\.\\([0-9]+\\)~$")
						       f)
					 f))
				(directory dir :absolute t :file-only t)))
		#'string>=
		:key #'(lambda (f)
			 (and (string-match (compile-regexp "\\.\\([0-9]+\\)~$")
					    f)
			      (format nil "~3A" (match-string 1)))))
	       (nreverse list))
      (let ((s (format-date-string "%Y-%m-%d" (file-write-time f))))
	(and (string/= day s) (setq day s) (push (cons f s) list))))))

(defun open-backup-file-previous-date (&optional (arg 1))
  (interactive "p")
  (open-backup-file-next-date (- arg)))

(defun open-backup-file-latest (&optional (arg 1))
  (interactive "p")
  (let* ((file (get-buffer-file-name))
	 (list (open-backup-get-list-dir
		(directory-namestring file)
		(substring file 0 (string-match (compile-regexp "\\.[0-9]+~$")
						file))
		nil))
	 (ln (current-line-number))
	 (wln (get-window-line)))
    (when list
      (if (plusp arg)
	  (let ((latest (car list)))
	    (open-backup-insert-file latest ln wln)
	    (message "一番先のバックアップファイル"))
	(let ((oldest (car (last list))))
	  (open-backup-insert-file oldest ln wln)
	  (message "一番前のバックアップファイル"))))
    ))

(defun open-backup-file-oldest (&optional (arg 1))
  (interactive "p")
  (open-backup-file-latest (- arg)))

(defun open-backup-file-quit ()
  (interactive)
  (let ((buffer open-backup-buffer))
    (kill-buffer (selected-buffer))
    (and buffer (find-buffer buffer) (set-buffer buffer))))

(defun open-backup-set-mode ()
  (let ((file (get-buffer-file-name)) mode)
    (when (string-match (compile-regexp "\\.[0-9]+~$") file)
      (setq mode (cdr (find (pathname-name file) *auto-mode-alist*
			    :test #'(lambda (s r) (string-match r s))
			    :key #'car)))
      (and mode (unless (eq buffer-mode mode) (funcall mode)))
      (open-backup-mode t))))

(add-hook '*find-file-hooks* 'open-backup-set-mode)

;;;
