;;-*- Mode: lisp; outline-tree: user-regexp-lisp-dots; -*-
#|text
■機能
  タグファイルを生成する時に指定したフォルダが、マージ対象なら、生成し
  たタグをマージします。

  *merge-tags-directory-alist* はディレクトリ名の組のリストです。
  (pushnew '("d:/test" "d:/test2") *merge-tags-directory-alist* :test 'equal)
  でd:/test以下で生成したタグを d:/test2 のタグファイルにまとめます。

  デフォルトでは、system-root 以下の XTAGS をすべて、system-rootにまと
  めます。こうすると、 site-lispフォルダで修正があっても、lispフォルダ
  タグを再生成する必要が無くなります。

  *make-tags-ignore-paths* に無視するファイルにマッチする正規表現のリ
  ストを指定する事ができます。


■インストール
 .xyzzy か siteinit.l に下のを書いてください．
  ni-autoload を使用している人は必要ありません。
 (require "merge-tags")

■使用方法
  *merge-tags-directory-alist* を設定してください。
  タグファイルを生成する時に勝手に使われます。

■注意事項
  make-tags-file, tags-setup-buffer を修正します。


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


copyright 2006-2009   Masahiro Nakano <mnakano.gm@gmail.com>

■Todo
  ・削除した・移動したファイルのタグを削除
  ・複数のタグを一つの場所にまとめるのではなく、一つのタグを複数の場所
    にマージさせる


■更新履歴
 on 2009-01-10
  ・ディレクトリ名の比較を equalp でするように修正

 on 2009-01-07
  ・誤って default-directory を変更してしまっていたのを修正
  ・XTAGS の生成時に、バッファサイズが大きくなると速度が遅くなるので、
    バッファを一定サイズで分割するように変更。

 on 2009-01-04
  ・タグファイルの作成に失敗する場合があるのを修正

 on 2008-12-11
  ・debug用の キーワードシンボルを変更

 on 2008-11-27
  ・差分更新の履歴をディレクトリごとに持つように修正。

 on 2008-11-18
  ・タグファイル生成時にエラーが出るのを修正

 on 2008-10-31
  ・*post-make-tags-hook* を追加

 on 2007/08/26
  ・*make-tags-ignore-paths* が機能しなくなっていたのを修正

 on 2007/8/12
  ・ほぼ作り直し
  ・差分更新に対応
  ・深さの指定が 0 以外おかしかったのを修正

 on 2007/1/11
  ・無視するパスのマッチングを、string-looking-at から string-matchp 
    に変更

 on 2006/12/10
  ・*make-tags-ignore-paths* を追加。

 on 2006/12/08
  ・ni-autoload でうまくロードできていなかったのを修正

 on 2006/11/21
  ・公開

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
  "各要素のcar部のディレクトリ以下のXTAGSは cdr部のXTAGSと統合する。
このとき car部のディレクトリには、1行 #use ～～ とだけ書いてある XTAGS が生成される。")


;(defvar *copy-tags-directory-alist* nil
;  "cdr部のXTAGS を差分更新ではなく生成するときに、
;各要素のcar部のディレクトリが使用する XTAGS ファイルをコピーする。")


(defvar *merge-tags-pre-hook* nil)
(defvar *merge-tags-post-hook* nil)

(defvar *make-tags-ignore-paths* nil
  "タグファイルを生成しないパスのリスト")

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



;;. タグファイルから、更新するファイルのタグを削除
(defun delete-tag-entries (delete-path-list dest-dir tagsbuffer depth)
  "tagsbuffer から delete-path-list のパスを削除"
  #+:mtag-debug (format *mtag-debug* "・delete-tag-entries\n  deleting tags of
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

;;. 更新するファイル一覧の生成

(defun sub-directory-file-p (file parent)
  "file が parent のサブディレクトリ以下にある時 t"
  (sub-directory-p (directory-namestring file) parent))

(defun delete-ignore-path (paths)
  "*make-tags-ignore-paths* に登録されているパスを paths から削除"
  (nreverse (set-difference paths *make-tags-ignore-paths* :test #'sub-directory-file-p)))

(defvar *tag-path-filters* '(delete-ignore-path))

(defun tag-uptodate-file-p (file)
  (let ((tagfile (merge-pathnames *tags-file-name* (directory-namestring file))))
    (file-newer-than-file-p tagfile file)))


(defun get-tag-updating-files (dir depth dest-tagfile &optional diff-update)
  "タグファイルを更新するファイル"
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
      #+:mtag-debug (format *mtag-debug* "・get-tag-obsolete-files\n~{  ~A\n~}" ret)
      ret)))





;;. 更新先タグバッファの更新

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
    "tagsbuffer の相対パスに path を追加して絶対パスへ変換"
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
  "dir/.XTAGS を、dest-buffer に追加する。"
  #+:mtag-debug (format *mtag-debug* "・merge-tags-file\n")
  ;; merge処理
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
      ;#+:mtag-debug (format *mtag-debug* "・merged-contents\n~A\n\n"
      ;                 (save-excursion
      ;                   (set-buffer dot-tags-buffer)
      ;                   (buffer-substring (point-min) (point-max))))
      (delete-buffer dot-tags-buffer)
      (delete-file filename :if-does-not-exist :skip)

      (make-use-abs-path-tag-file dir dest-dir)
      t)))




;;. #USE 用タグファイルの生成
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

;;. make-tags-file を修正したもの
(defun make-tags-file1 (dir fun-file-list output &optional depth diff-update)
  ".XTAGSの生成。"
  (interactive "DMake TAGS file: \np")
  (long-operation
    #+:mtag-debug (format *mtag-debug* "・make-tags-file1 ~A,\n   size ~A, dest ~A, depth ~A, diff-update ~A\n"
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
		  #+:mtag-debug (format *mtag-debug* "・Parsing files\n")
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
			;; temp-buffer の分割
			(setq temp-buffer (create-new-buffer "*MAKE-XTAGS*"))
			#+:mtag-debug (format *mtag-debug* "buffer is too big!\n  next temp-buffer: ~A\n" temp-buffer)
			(setq *standard-output* (make-buffer-stream temp-buffer))
			(push temp-buffer all-temp-buffers))
		      ;; file のタグを生成
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
	    #+:mtag-debug (format *mtag-debug* "・finished parsing\n")
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
	    ;; .XTAGS に書き出し
	    #+:mtag-debug (format *mtag-debug* "・writing ~A\n" (merge-pathnames (concat "." *tags-file-name*) dir))
	    (let ((dotxtags-file (merge-pathnames (concat "." *tags-file-name*) dir)))
	      (setq all-temp-buffers (nreverse all-temp-buffers)
		    temp-buffer (car all-temp-buffers))
	      (set-buffer temp-buffer)
	      (write-file dotxtags-file)
	      (dolist (temp (cdr all-temp-buffers))
		(set-buffer temp)
		(append-file dotxtags-file t)))
	    #+:mtag-debug (format *mtag-debug* "・generated .XTAGS\n~A\n\n"
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
      #+:mtag-debug (format *mtag-debug* "・end of make-tags-file1, generated .XTAGS? ~A\n"
		       (file-exist-p (merge-pathnames (concat "." *tags-file-name*) output)))
      count)))

#|(defun make-tags-file1 (dir fun-file-list output &optional depth diff-update)
  ".XTAGSの生成。"
  (interactive "DMake TAGS file: \np")
  (long-operation
    #+:mtag-debug (format *mtag-debug* "・make-tags-file1 ~A,\n   size ~A, dest ~A, depth ~A, diff-update ~A\n"
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
		    #+:mtag-debug (format *mtag-debug* "・Parsing files\n")
		    (dolist (fun-file fun-file-list)
		      (let ((file (cdr fun-file)))
			#+:mtag-debug (format *mtag-debug* "  - ~A\n" file)
			(erase-buffer buffer)
			(insert-file-contents file t)
			(setq current-file (1+ current-file))
			(message "Parsing ~a...~d (~d of ~d files)"
				 file count current-file total-files)
			;; file のタグを生成
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
	      #+:mtag-debug (format *mtag-debug* "・finished parsing\n")

	      (set-buffer temp-buffer)
	      (goto-char (point-min))
	      (perform-replace "[\n\t\f]" " " nil t nil t)
	      (goto-char (point-min))
	      (perform-replace "  +" " " nil t nil t)
	      (goto-char (point-min))
	      (perform-replace "\036" "\n" nil nil nil t)
	      ;; .XTAGS に書き出し
	      #+:mtag-debug (format *mtag-debug* "・writing ~A\n" (merge-pathnames (concat "." *tags-file-name*) dir))
	      (write-file (merge-pathnames (concat "." *tags-file-name*) dir))
	      #+:mtag-debug (format *mtag-debug* "・generated .XTAGS\n~A\n\n"
			       (buffer-substring (point-min) (point-max)))

	      (when (numberp depth)
		(make-use-tag-files output fun-file-list))
	      ))
	  (and temp-buffer
	       (not (deleted-buffer-p temp-buffer))
	       (delete-buffer temp-buffer)))
	(let ((output-buffer (find-tags-buffer output)))
	  (and output-buffer (delete-buffer output-buffer))))
      #+:mtag-debug (format *mtag-debug* "・end of make-tags-file1, generated .XTAGS? ~A\n"
		       (file-exist-p (merge-pathnames (concat "." *tags-file-name*) output)))
      count)))
|#


(defun kill-tags-buffers ()
  (let ((buffers (buffer-list)))
    (dolist (buffer buffers)
      (if (equalp " *TAGS*" (buffer-name buffer))
	  (delete-buffer buffer)))
    t))


;;. tags.l maketags.l の関数を再定義
;;.. tags-setup-buffer を再定義
(defun tags-setup-buffer ()
  "タグバッファの #USE 先をたどり、最終タグファイルのバッファを返す。
絶対パスも扱えるように修正"
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

;;.. make-tags-file を再定義
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
		 (format *mtag-debug* "\n;;-------- by merge-tags -------\n・make-tags-file ~w ~w ~w\n"
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
	#+:mtag-debug (format *mtag-debug* "・updating ~A directory to ~A\n" dir dest-dir)
	(unwind-protect
	    (let (file-paths)
	      ;; 更新先タグファイルから古いタグ情報を削除
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

	      ;; タグファイルを .XTAGS に生成
	      (setq count (make-tags-file1 dir fun-file-list dest-dir depth diff-update))

	      ;; XTAGS の生成
	      (if (or diff-update
		      (not (path-equal dir dest-dir)))
		  (merge-tags-file dir dest-dir dest-buffer)
		(progn
		  #+:mtag-debug (format *mtag-debug* "・move .XTAGS XTAGS, ~A ~A\n"
				   (file-exist-p (merge-pathnames (concat "." *tags-file-name*) dir))
				   (file-exist-p (merge-pathnames *tags-file-name* dir)))

		  (rename-file (merge-pathnames (concat "." *tags-file-name*) dir)
			       (merge-pathnames *tags-file-name* dir)
			       :if-exists :overwrite)))
	      ;; copyするタグファイルを追加
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
    (:caption "タグファイルの生成")
    (:font 9 "MS UI Gothic")
    (:control
     (:static nil "ソースディレクトリ(&S):" #x50020000 7 7 58 8)
     (:edit src nil #x50810080 7 19 148 14)
     (:button diff "差分更新(&I)" #x50010003 7 48 102 10)
     (:button subdir "ついでにサブディレクトリも(&U)" #x50010003 7 63 102 10)
     (:static nil "検索する階層の深さ(&D):" #x50020000 9 78 80 8)
     (:edit depth nil #x50810086 89 75 36 14)
     (:spin depthspin "Spin1" #x500000b6 119 70 9 14)
     (:static nil "(0は無制限)" #x50020000 129 78 48 8)
     (:button IDOK "OK" #x50010001 169 7 50 14)
     (:button IDCANCEL "キャンセル" #x50010000 169 24 50 14)
     (:button ref "参照(&R)..." #x50010000 169 41 50 14))
    ))

(defun make-tags-file-dialog-error-message-japanese ()
  '((src :non-null "ソースディレクトリを入力して" :enable (IDOK))
    (depth :type integer :min 0 :max 10000
	   :range-error "階層の深さ0以上です"
	   :type-error "数値を入力してください")
    (depthspin :min 0 :max 10000)
    (ref :related src :directory-name-dialog (:title "参照"))))


(cond ((equalp user::make-tags-file-language "english")
       (setq *make-tags-file-dialog-template* (make-tags-file-dialog-template-english))
       (setq *make-tags-file-dialog-error-template* (make-tags-file-dialog-error-message-english)))
      ((equalp user::make-tags-file-language "japanese")
       (setq *make-tags-file-dialog-template* (make-tags-file-dialog-template-japanese))
       (setq *make-tags-file-dialog-error-template* (make-tags-file-dialog-error-message-japanese)))
      (t
       (setq *make-tags-file-dialog-template* (make-tags-file-dialog-template-english))
       (setq *make-tags-file-dialog-error-template* (make-tags-file-dialog-error-message-english))))


;;.. diff-update のヒストリ機能
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

;;.. make-tags-file-dialog の再定義
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

debug mode で動かす場合は、以下のコードを実行後、再ロード。
バイトコンパイルしていれば、バイトコンパイルも忘れずに。

(progn
  (pushnew :mtag-debug *features*)
  (defvar *mtag-debug* nil)
  (eval-buffer (selected-buffer)))

(setq *features* (delete :mtag-debug *features*))

|#

#|text

■diff-update or 他ディレクトリへのXTAGS書き出し
     更新先XTAGSの取得
     タグ更新必要ファイル取得
     現在のタグファイルから、そのエントリーを削除
     更新タグの生成 (.XTAGS)
     マージ処理


■それ以外
     更新先XTAGSの取得
     タグ更新必要ファイル取得
     現在のタグファイルはそのまま
     更新タグの生成 (.XTAGS)
     .XTAGS -> XTAGS

|#
