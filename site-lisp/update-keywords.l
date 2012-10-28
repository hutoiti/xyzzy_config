;; -*- Mode: lisp; PACKAGE : EDITOR; -*-
#|text

■機能
  正規表現キーワードではなく、キーワードファイルによる色指定を、
  lispで動的に追加・更新・指定解除できるようにします。

  また、ファイルの先頭で以下のようにすると、キーワードファイル xxx を
  メジャーモードのキーワードに追加して表示します。
    -*- keyword: xxx; -*- 

関数の使用例
  ; 単語を 40u で追加
  (setq keyword-hash-table (update-keywords ";**40u" "abc"))
  ; 複数の単語を キーワードカラー 2 で追加
  (setq keyword-hash-table (update-keywords ";*2" '("abc" "def" "ghi")))
  ; 単語のキーワードカラーを無指定に。
  (setq keyword-hash-table (update-keywords nil "abc"))

■インストール
  ;; ni-autoload を使用している人は不要です。

    (require "update-keywords")

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


copyright 2008   Masahiro Nakano

・Author                       @
    Masahiro Nakano <mnakano.gm gmail.com>

■History
 on 2008-12-26
  ・ファイルの先頭でキーワードファイルを指定できるように

 on 2008-07-07
  ・初版作成

|#


(provide "update-keywords")

(in-package "editor")
(export '(update-keywords))

(defun copy-hash-table (fromhash tohash)
  (maphash #'(lambda (key val) (setf (gethash key tohash) val))
	   fromhash)
  tohash)

(defun parse-keyword-color (color-indicator &optional condition)
  (if (null color-indicator)
      (return-from parse-keyword-color nil))
  (and condition
       (not (equal condition "*"))
       (setq condition (compile-regexp (concat (regexp-quote condition)
					       "[ \t]*$")
				       t)))
  (if (not (eql (schar color-indicator 0) #\;))
      (error "Wrong color specified: ~A" color-indicator))
  (let ((num #x400)
	(entity-ok 0)
	(valid t)
	(rest-str (substring color-indicator 1 3)))
    (cond ((string-equal "*+" color-indicator :start2 1 :end2 3)
	   (when (or (equal condition "*")
		     (string-match "[ \t]+$" color-indicator 3)
		     (and condition
			  (string-match condition color-indicator 3)))
	     (setq valid t)))
	  ((string-equal "*-" color-indicator :start2 1 :end2 3)
	   (when (or (string-match "[ \t]+$" color-indicator 3)
		     (and condition
			  (string-match condition 3)))
	     (setq valid nil)))
	  ((not valid))
	  ((string-equal "*&" color-indicator :start2 1 :end2 3)
	   (setq entity-ok 4)
	   (setq num (logior num 4)))
	  ((string-equal "*<" color-indicator :start2 1 :end2 3)
	   (setq entity-ok 0)
	   (setq num (logandc2 num 4)))
	  ((string-equal "**" color-indicator :start2 1 :end2 3)
	   (let* ((index 3)
		  (c (char color-indicator index)))
	     (when (and c (setq c (digit-char-p c 16)))
	       (setq num (+ (ash c 9) 1))
	       (setq index (1+ index))
	       (setq c (if (< index (length color-indicator))
			   (char color-indicator index)))
	       (when (and c (setq c (digit-char-p c 16)))
		 (incf num (ash c 17))
		 (setq num (parse-keyword-file-attributes-indicator num (substring color-indicator 5))))))
	   (setq num (logior num entity-ok)))
	  ((string-equal "*+" color-indicator :start2 1 :end2 3)
	   (let ((index 2))
	     (let ((c (if (< index (length color-indicator))
			  (schar color-indicator index))))
	       (when (and c (setq c (gethash c *keyword-translate-hash-table*)))
		 (setq num (parse-keyword-file-attributes-indicator c (substring color-indicator 5))))))
	   (setq num (logior num entity-ok)))
	  )
    num))

(defun parse-keyword-file-attributes-indicator (num indicator)
  (map nil #'(lambda (c)
	       (case (and c (char-downcase c))
		 (#\b
		  (setq num (logior num #x200000)))
		 (#\u
		  (setq num (logior num #x800000)))
		 (#\s
		  (setq num (logior num #x1000000)))
		 (#\l
		  (setq num (logior num 2)))
		 (t
		  (return-from parse-keyword-file-attributes-indicator num))))
       indicator)
  num)

(defun update-keywords (color keywords &optional icase (size 0) condition hash-table)
  (or hash-table
      (setq hash-table keyword-hash-table))
  (if (stringp keywords)
      (setq keywords (list keywords)))
  (let ((table (setup-keyword-hash hash-table icase size))
	(color-code (parse-keyword-color color condition)))
    (dolist (keyword keywords)
      (setf (gethash keyword table) color-code))
    ;(setq keyword-hash-table table)
    table
    ))

(defun setup-keyword-hash (table icase size)
  (if table
      (let ((to (make-hash-table :test (hash-table-test table)
                                 :size  (if (and size
                                                 (< (hash-table-size table) size))
                                            size
                                          (hash-table-size table))
                                 :rehash-size (hash-table-rehash-size table))))
      ;(let ((to (make-keyword-table icase (max (hash-table-size table) (truncate size 3/4)))))
	(copy-hash-table table to))
    (make-keyword-table icase (truncate size 3/4))))

(defun load-minor-keyword-file1 (file &optional icase size condition hash-table)
  "hash-table に キーワードファイル file 内のキーワード指定を追加した hash-table を返す。"
  (or hash-table
      (setq hash-table keyword-hash-table))
  (let ((buffer (create-new-buffer " *load keywords*"))
	(color (parse-keyword-color ";*1"))
	table)
    (save-excursion
      (set-buffer buffer)
      (insert-file-contents file)
      (goto-char (point-max))
      (if size
	  (if (< size (hash-table-size hash-table))
	      (setq size (hash-table-size hash-table)))
	(setq size (if hash-table (hash-table-size hash-table) 0)))
      (setq table (setup-keyword-hash hash-table icase (+ size (current-line-number))))
      (goto-char (point-min))
      (while (scan-buffer "^\\(;\\*+[0-9]+[lubs]*\\)\\|^\\([^;].*\\)" :regexp t :tail t)
	(if (match-beginning 1)
	    (setq color (parse-keyword-color (match-string 1)))
	  (setf (gethash (match-string 2) table) color))))
    (delete-buffer buffer)
    table))


(defvar minor-keyword-tables nil)
(defun load-minor-keyword-file (file &optional hash-table)
  (or hash-table
      (setq hash-table keyword-hash-table))
  (let* ((key (list hash-table file))
	 (table-file-merged-table (assoc key minor-keyword-tables :test 'equal))
	 (target-table (if table-file-merged-table
			   (cdr table-file-merged-table)
			 (load-minor-keyword-file1 file hash-table))))
    (or table-file-merged-table
	(push (cons key target-table) minor-keyword-tables))
    (setq keyword-hash-table target-table)
    target-table))
(defun clear-cached-minor-keyword-file ()
  (setq minor-keyword-tables nil))

(defun set-minor-keyword (name &optional hash-table)
  (let (filename)
    (dolist (d *keyword-load-path*
	       (unless (file-exist-p (setq filename
					   (merge-pathnames name (etc-path))))
		 (return-from set-minor-keyword nil)))
      (setq filename (merge-pathnames name d))
      (when (file-exist-p filename)
	(return)))
    (or hash-table
	(setq hash-table keyword-hash-table))
    (load-minor-keyword-file filename hash-table)))

;;.. *auto-mode-parameter-alist* に keyword を追加
(pushnew (cons "keyword" 'set-minor-keyword)
	 *auto-mode-parameter-alist* :key #'car :test #'equal)

