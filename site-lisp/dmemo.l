;;; -*- Mode: Lisp -*-
;;;
;;; dmemo.l
;;;
;;; Last updated: <2006/05/25 01:06:05 +0900>
;;;
;;; by matsushita

#|

  メモを保存してダイアログボックスで表示するなどします。


  dmemo.l は修正 BSD ライセンスに基づいて利用可能です。
  <http://www.xfree86.org/3.3.6/COPYRIGHT2.html#5>
  
  Copyright (C) 2006 matsushita. All rights reserved.
  
  
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


■ 使い方

  ・M-x dmemo-create でファイル名を指定してメモを作成する（*dmemo-path* で指定したディレクトリに保存）。

  ・M-x dmemo-delete でファイル名を指定してメモを削除する。

  ・M-x dmemo-dialog で現在のメモをダイアログボックスで表示する。

  ・M-x dmemo-list-dialog でメモを一覧表示する。

  ・M-x dmemo-show で現在のメモを開く。

  ・M-x dmemo-add-from-clipboard でクリップボードの文字列を現在のメモに追加する。

  ・メモバッファで C-x C-s でメモを保存、C-c C-q でメモを閉じる。


■ アンインストール:
  M-x dmemo-uninstall した後で dmemo.l に関する記述・ファイルを削除して下さい
  （siteinit.l に記述していた場合は再ダンプが必要）。

|#

(provide "dmemo")

(defvar *dmemo-path* (merge-pathnames "memo" (si:system-root))) ;メモを保存するディレクトリ
(defvar *dmemo-excluded-regexp* "\\.\\(col\\|jpg\\)$")          ;ダイアログに表示しない拡張子を正規表現で指定
(defvar *dmemo-side-position* 220)                              ;dmemo-dialog の横位置
(defvar *dmemo-vertical-position* -30)                          ;dmemo-dialog の縦位置
(defvar *dmemo-fold-line* 30)                                   ;dmemo-dialog で折り返す文字列数
(defvar *dmemo-view-length* 255)                                ;dmemo-dialog の表示部分の長さ
(defvar *dmemo-font-size* 10)                                   ;dmemo-dialog のフォントサイズ

(define-history-variable *dmemo-filename* nil)                  ;現在のメモのファイル名
(define-history-variable *dmemo-fold* t)                        ;dmemo-dialog で折り返すか否か

(defvar *dmemo-num* nil)
(defvar *dmemo-save-hook* nil)
(defvar *dmemo-mode-map* nil)

(defun dmemo-set-keymap ()
  (setq *dmemo-mode-map* (copy-keymap (local-keymap)))
  (define-key *dmemo-mode-map* '(#\C-x #\C-s) 'dmemo-save)
  (define-key *dmemo-mode-map* '(#\C-c #\C-q)
	      #'(lambda () (interactive) (delete-buffer (selected-buffer))))
  (use-keymap *dmemo-mode-map*))

(defun dmemo-save ()
  (interactive)
  (save-buffer)
  (let ((params (ed::find-file-scan-params)))
    (ed::find-file-process-params params (selected-buffer))
    (dmemo-set-keymap)
    (run-hooks '*dmemo-save-hook*)))

(defun dmemo-create-dir ()
  (unless (file-directory-p *dmemo-path*)
    (if (yes-or-no-p "~a~%ディレクトリがないけど作る？" *dmemo-path*)
	(create-directory *dmemo-path*)
      (quit))))

(defun dmemo-filep (file)
  (and file
       (file-exist-p file)
       (not (file-directory-p file))))

(defun dmemo-file-existp (file)
  (unless (dmemo-filep file)
    (plain-error "ファイルがありません")))

(defun dmemo-set-filename ()
  (unless (dmemo-filep *dmemo-filename*)
    (let ((file (car (sort (delete *dmemo-excluded-regexp*
				   (directory *dmemo-path*
					      :file-only t)
				   :test #'string-matchp)
			   #'string-lessp))))
      (when file
	(setq *dmemo-filename* (merge-pathnames file *dmemo-path*))))))

(defun dmemo-create ()
  (interactive)
  (let ((fn (read-string "メモ: ")))
    (when (zerop (length fn))
      (plain-error "ファイル名を入力してください"))
    (setq *dmemo-filename* (merge-pathnames fn *dmemo-path*))
    (when (file-directory-p *dmemo-filename*)
      (plain-error "ディレクトリは指定できません"))
    (dmemo-create-dir)
    (find-file *dmemo-filename*)
    (unless (file-exist-p *dmemo-filename*)
      (write-file *dmemo-filename*)
      (update-visited-file-modtime))
    (dmemo-set-keymap)))

(defun dmemo-delete (&optional fn)
  (interactive "sメモ: ")
  (when fn
    (setq *dmemo-filename* (merge-pathnames fn *dmemo-path*)))
  (dmemo-file-existp *dmemo-filename*)
  (setq fn (file-namestring *dmemo-filename*))
  (when (yes-or-no-p "~A を削除しますか？" fn)
    (delete-file *dmemo-filename*)
    (when (find-buffer fn)
      (kill-buffer fn))
    (message "削除しました")))

(defun dmemo-show ()
  (interactive)
  (dmemo-create-dir)
  (dmemo-set-filename)
  (dmemo-file-existp *dmemo-filename*)
  (find-file *dmemo-filename*)
  (dmemo-set-keymap))

(defun dmemo-add-from-clipboard ()
  (interactive)
  (let ((str (get-clipboard-data)))
    (when (and str
	       (dmemo-show))
      (goto-char (point-max))
      (unless (bobp) (insert "\n"))
      (with-output-to-selected-buffer
	(format t "~A\n" str)))))

(defun dmemo-next-file (&optional p)
  (let ((flist (sort (delete *dmemo-excluded-regexp*
			     (directory *dmemo-path*
					:file-only t)
			     :test #'string-matchp)
		     (if p #'string-greaterp #'string-lessp)))
	(filename (file-namestring *dmemo-filename*)) pos fn)
    (and
     (block match ()
       (dolist (l flist)
	 (when (equal l filename)
	   (setq pos (position l flist))
	   (return-from match t))))
     (setq fn (nth (1+ pos) flist))
     (setq *dmemo-filename* (merge-pathnames fn *dmemo-path*))))
  (dmemo-dialog))

(defun dmemo-data-read-from-file ()
  (let (flist file fcontents str (num 0))
    (setq *dmemo-num* nil)
    (dolist (fn (sort (delete *dmemo-excluded-regexp*
			      (directory *dmemo-path*
					 :file-only t)
			      :test #'string-matchp)
		      #'string-lessp))
      (setq file (merge-pathnames fn *dmemo-path*))
      (with-open-file (s
		       file
		       :direction :input)
	(setq fcontents (format nil "~A" (read-line s nil ""))))
      (setq str (string-left-trim '(#\SPC #\TAB #\　) fcontents))
      (when (equal file *dmemo-filename*)
	(setq *dmemo-num* num))
      (push (list fn str num) flist)
      (setq num (1+ num)))
    (nreverse flist)))

(defun dmemo-list-dialog ()
  (interactive)
  (dmemo-create-dir)
  (let ((list (dmemo-data-read-from-file)))
    (multiple-value-bind (result data)
	(dialog-box
	 '(dialog 0 0 260 125
	   (:caption "メモ一覧")
	   (:font 10 "MS UI Gothic")
	   (:control
	    (:listbox list nil #x50a10011 4 5 193 115)
	    (:button open "開く(&O)" #x50030001 203 5 52 14)
	    (:button add "追加(&A)" #x50030000 203 22 52 14)
	    (:button delete "削除(&D)" #x50030000 203 39 52 14)
	    (:button view "表示(&V)" #x50030000 203 56 52 14)
	    (:button IDCANCEL "キャンセル" #x50030000 203 73 52 14)))
	 (list (cons 'list list)
	       (cons 'list (find *dmemo-num* list :key #'caddr)))
	 '((list :column (20 128 0) :must-match t :enable (open delete))
	   (add :no-result t)))
      (when result
	(let ((fn (cadr (assoc 'list data))))
	  (cond ((eq result 'open)
		 (setq *dmemo-filename* (merge-pathnames fn *dmemo-path*))
		 (dmemo-show))
		((eq result 'add)
		 (dmemo-create))
		((eq result 'delete)
		 (dmemo-delete fn))
		((eq result 'view)
		 (setq *dmemo-filename* (merge-pathnames fn *dmemo-path*))
		 (dmemo-dialog))
		))))))

(defun dmemo-dialog ()
  (interactive)
  (dmemo-create-dir)
  (dmemo-set-filename)
  (dmemo-file-existp *dmemo-filename*)
  (multiple-value-bind (result data)
      (dialog-box
       `(dialog ,*dmemo-side-position* ,*dmemo-vertical-position*
		,(+ *dmemo-view-length* 60) 200
		(:caption ,(file-namestring *dmemo-filename*))
		(:font ,*dmemo-font-size* "ＭＳ ゴシック")
		(:control
		 (:button open "開く(&O)" #x50030001 ,(+ *dmemo-view-length* 6) 5 50 14)
		 (:button add "追加(&A)" #x50030000 ,(+ *dmemo-view-length* 6) 22 50 14)
		 (:button delete "削除(&D)" #x50030000 ,(+ *dmemo-view-length* 6) 39 50 14)
		 (:button previous "前(&P)" #x50030000 ,(+ *dmemo-view-length* 6) 56 50 14)
		 (:button next "次(&N)" #x50030000 ,(+ *dmemo-view-length* 6) 73 50 14)
		 (:button fold ,(if *dmemo-fold* "折返なし(&F)" "折り返す(&F)")
		  #x50030000 ,(+ *dmemo-view-length* 6) 90 50 14)
		 (:button list "一覧(&L)" #x50030000 ,(+ *dmemo-view-length* 6) 107 50 14)
		 (:button IDCANCEL "キャンセル" #x50030000 ,(+ *dmemo-view-length* 6) 124 50 14)
		 (:edit edit nil #x50b110c4 4 5 ,*dmemo-view-length* 190)))
       (list (cons 'edit
		   (unwind-protect
		       (save-excursion
			 (let ((buffer (create-new-buffer "*dmemo-temp*")))
			   (set-buffer buffer)
			   (insert-file-contents *dmemo-filename*)
			   (when (and *dmemo-fold* (integerp *dmemo-fold-line*))
			     (goto-char (point-min))
			     (while (not (eobp))
			       (if (> (- (save-excursion (goto-eol) (point))
					 (save-excursion (goto-bol) (point))) *dmemo-fold-line*)
				   (progn
				     (goto-bol)
				     (goto-char (+ (point) *dmemo-fold-line*))
				     (insert "\n"))
				 (progn
				   (goto-eol)
				   (forward-char)))))
			   (goto-char (point-min))
			   (replace-buffer "\n" "\r\n")
			   (prog1
			       (buffer-substring (point-min) (point-max))
			     (delete-buffer buffer))
			   )))))
       nil)
    (when result
      (let ((fn (cadr (assoc 'list data))))
	(cond ((eq result 'open)
	       (dmemo-show))
	      ((eq result 'add)
	       (dmemo-create))
	      ((eq result 'delete)
	       (dmemo-delete))
	      ((eq result 'previous)
	       (dmemo-next-file t))
	      ((eq result 'next)
	       (dmemo-next-file))
	      ((eq result 'fold)
	       (setq *dmemo-fold* (not *dmemo-fold*))
	       (dmemo-dialog))
	      ((eq result 'list)
	       (dmemo-list-dialog))
	      )))))

(defun dmemo-uninstall ()
  (interactive)
  (let ((variable-list
	 '(*dmemo-filename*
	   *dmemo-fold*
	   )))
    (dolist (x variable-list)
      (unregister-history-variable x))))

;;;
