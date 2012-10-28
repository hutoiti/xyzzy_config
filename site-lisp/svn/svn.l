;;; -*- MODE: Lisp; Package: EDITOR; -*-
;;;
;;; $HeadURL: file:///g:/repository/xyzzy/site-lisp/svn/release/0.0.2.0/svn.l $
;;;
;;; $LastChangedDate: 2005-07-07 22:26:12 +0900 (Thu, 07 Jul 2005) $
;;;
;;; $LastChangedRevision: 187 $
;;;
;;; LKPTeam <ykaltenative@mue.biglobe.ne.jp>
;;;

;;;
;;; svn-mode - めちゃくちゃ適当簡易svn-mode
;;;

;;; 作成に当たって、中田さんのcvs.lを参考にさせて頂きました。この場をお借りしてお礼申し上げます。
;;;   checkin周りはほとんど流用してたりして……(^^;

;;;
;;; 実装状況
;;;
;;;    svn add       完了
;;;    svn blame     完了（作業コピーと、開いているファイルのリポジトリに対して可能）
;;;    svn cat       完了（URLの指定はまだできない）
;;;    svn checkout  完了
;;;    svn cleanup   完了
;;;    svn commit    完了
;;;    svn copy      完了
;;;    svn delete    完了
;;;    svn diff      完了（＠構文の使用はまだできない、外部diffコマンドの使用もまだできない）
;;;    svn export    完了（まともに動かないかも）
;;;    svn help      完了
;;;    svn import    完了
;;;    svn info      完了
;;;    svn list      完了
;;;    svn lock      完了
;;;    svn log       完了（作業コピーのみ）
;;;    svn merge     まだ
;;;    svn mkdir     完了
;;;    svn move      完了
;;;    svn propdel   完了（作業コピー、ファイルに対してのみ）
;;;    svn propedit  完了（C-u付きで呼べばカレントディレクトリに対して）
;;;    svn propget   完了（作業コピーのみ）
;;;    svn proplist  完了（作業コピーのみ）
;;;    svn propset   完了（作業コピー、ファイルに対してのみ）
;;;    svn resolved  完了
;;;    svn revert    完了（作業コピーのみ）
;;;    svn status    完了（作業コピーのみ）
;;;    svn switch    まだ
;;;    svn unlock    完了
;;;    svn update    完了
;;;
;;;    これらは予定はないかも
;;;    svnadmin      まだ
;;;    svnlock       まだ
;;;

;;;
;;; 初期設定とか
;;;
;;; ・~/.xyzzyか$XYZZY/site-lisp/siteinit.lに以下を記述して保存し、
;;;   xyzzyを再起動してください
;;;
;;;	(require "svn/svn")
;;;
;;;
;;; code

(provide "svn-mode")

(export '(*svn-diff-color-new*
          *svn-diff-color-old*
          *svn-blame-color*
          *svn-mode-prefix-key*
		  svn-mode
          ))

(require "xml-parser-modoki")
(require "svn/svn-parse.l")
(require "svn/svn-misc.l")
(require "svn/svn-dired.l")

(define-history-variable *svn-src-files-history* nil)
(define-history-variable *svn-dst-files-history* nil)
(define-history-variable *svn-rev-history* nil)
(define-history-variable *svn-msg-history* nil)
(define-history-variable *svn-keywords-history* nil)
(define-history-variable *svn-keyvalue-history* nil)

(defvar-local *svn-mode* nil)
(defvar-local *mode-line* nil)
;(defvar-local *svn-window-conf* nil)

(defvar *svn-debug* nil "svn debug-mode. If 't', command line is displayed on a status bar.")
(defvar *svn-output-buffer* " *svn-out*" "The buffer which displays a svn sub-command result.")
(defvar *svn-dir* ".svn" "svn directory")
;(defvar *svn-verbose* nil "svn command verbose switch.")
(defvar *revert-work-file-function* nil)
(defvar *svn-use-completion* nil)
(defvar *svn-use-parse-status* nil)

(defvar *svn-diff-color-new* '(:foreground 15 :background 7 :bold t) "Color for diff new file.")
(defvar *svn-diff-color-old* '(:foreground 1 :background 3) "Color for diff old file.") ; 少し見づらくなるけど :strike-out t もありかな
(defvar *svn-blame-color* '(:foreground 8 :background 3 :bold t) "svn-blame color.")

(defvar *svn-mode-prefix-key* '(#\C-c))

(defvar *svn-log-mode-map* nil "Keymap for svn-log-mode.")
(unless *svn-log-mode-map*
  (setq *svn-log-mode-map* (make-sparse-keymap))
  (define-key *svn-log-mode-map* `(,@*svn-mode-prefix-key* #\C-c) 'svn-log-checkin)
  )

(defvar *svn-propedit-mode-map* nil "Keymap for svn-propedit-mode,")
(unless *svn-propedit-mode-map*
  (setq *svn-propedit-mode-map* (make-sparse-keymap))
  (define-key *svn-propedit-mode-map* `(,@*svn-mode-prefix-key* #\C-c) 'svn-pedit))


(defconstant *svn-mode-version*
  (progn
    (string-match
       "/svn/\\(.+\\)/svn.l \\$"
       "$HeadURL: file:///g:/repository/xyzzy/site-lisp/svn/release/0.0.2.0/svn.l $")
    (concat "svn-mode " (substitute-string (match-string 1) "/" " " :count 1))))

(defconstant *svn-log-buffer-name* "* SVN-log for ~A:~A *")
(defconstant *svn-propedit-buffer-name* "* SVN-propedit for ~A[~A] *")

(defconstant *svn-local-variables*
  '(*revision*
    *mode-line*
    *svn-repository-directory*
    *status*
    *lock*))

(defconstant *svn-log-local-variables*
  '(*file-buffer*
    *checkin-type*
    ))

(defvar *svn-mode-map* nil "Keymap for svn-mode.")
(unless *svn-mode-map*
  (setq *svn-mode-map* (make-sparse-keymap))
  (define-key *svn-mode-map* `(,@*svn-mode-prefix-key* #\C-c) 'svn-checkout)
  (define-key *svn-mode-map* `(,@*svn-mode-prefix-key* #\i) 'svn-checkin)
  (define-key *svn-mode-map* `(,@*svn-mode-prefix-key* #\I) 'svn-checkin-directory)
  (define-key *svn-mode-map* `(,@*svn-mode-prefix-key* #\`) 'svn-import)
  (define-key *svn-mode-map* `(,@*svn-mode-prefix-key* #\u) 'svn-update)
  (define-key *svn-mode-map* `(,@*svn-mode-prefix-key* #\U) 'svn-unlock)
  (define-key *svn-mode-map* `(,@*svn-mode-prefix-key* #\]) 'svn-cat)
  (define-key *svn-mode-map* `(,@*svn-mode-prefix-key* #\=) 'svn-copy)
  (define-key *svn-mode-map* `(,@*svn-mode-prefix-key* #\") 'svn-delete)
  (define-key *svn-mode-map* `(,@*svn-mode-prefix-key* #\k) 'svn-mkdir)
  (define-key *svn-mode-map* `(,@*svn-mode-prefix-key* #\K) 'svn-lock)
  (define-key *svn-mode-map* `(,@*svn-mode-prefix-key* #\-) 'svn-move)
  (define-key *svn-mode-map* `(,@*svn-mode-prefix-key* #\m) 'svn-merge)
  (define-key *svn-mode-map* `(,@*svn-mode-prefix-key* #\b) 'svn-blame)
  (define-key *svn-mode-map* `(,@*svn-mode-prefix-key* #\d) 'svn-diff)
  (define-key *svn-mode-map* `(,@*svn-mode-prefix-key* #\D) 'svn-diff-with-xyzzy-diff-mode)
  (define-key *svn-mode-map* `(,@*svn-mode-prefix-key* #\a) 'svn-add-file)
  (define-key *svn-mode-map* `(,@*svn-mode-prefix-key* #\A) 'svn-add-directory)
  (define-key *svn-mode-map* `(,@*svn-mode-prefix-key* #\r) 'svn-revert-file)
  (define-key *svn-mode-map* `(,@*svn-mode-prefix-key* #\R) 'svn-revert-directory)
  (define-key *svn-mode-map* `(,@*svn-mode-prefix-key* #\!) 'svn-resolved)
  (define-key *svn-mode-map* `(,@*svn-mode-prefix-key* #\l) 'svn-log-file)
  (define-key *svn-mode-map* `(,@*svn-mode-prefix-key* #\L) 'svn-log-directory)
  (define-key *svn-mode-map* `(,@*svn-mode-prefix-key* #\;) 'svn-list)
  (define-key *svn-mode-map* `(,@*svn-mode-prefix-key* #\x) 'svn-export)
  (define-key *svn-mode-map* `(,@*svn-mode-prefix-key* #\') 'svn-info)
  (define-key *svn-mode-map* `(,@*svn-mode-prefix-key* #\s) 'svn-status-file)
  (define-key *svn-mode-map* `(,@*svn-mode-prefix-key* #\S) 'svn-status-directory)
  (define-key *svn-mode-map* `(,@*svn-mode-prefix-key* #\p) 'svn-proplist)
  (define-key *svn-mode-map* `(,@*svn-mode-prefix-key* #\P) 'svn-propedit)
  ;(define-key *svn-mode-map* `(,@*svn-mode-prefix-key* #\P) 'svn-proplist-directory)
  (define-key *svn-mode-map* `(,@*svn-mode-prefix-key* #\g) 'svn-propget)
  (define-key *svn-mode-map* `(,@*svn-mode-prefix-key* #\h) 'svn-help)
  ;(define-key *svn-mode-map* `(,@*svn-mode-prefix-key* #\p) 'svn-propset-keywords)
  (define-key *svn-mode-map* `(,@*svn-mode-prefix-key* #\/) 'svn-toggle-verbose)
  )

(defun svn-mode (&optional (arg nil sv))
  "svn-mode"
  (interactive "*p")
  (ed::toggle-mode '*svn-mode* arg sv)
  (if *svn-mode*
      (progn
        (set-minor-mode-map *svn-mode-map*)
        (mapc 'make-local-variable *svn-local-variables*)
        (add-hook '*after-save-buffer-hook* 'update-modeline)
        (setq *revert-work-file-function* ed::revert-buffer-function)
        (setq ed::revert-buffer-function #'revert-work-file)
        (update-modeline)
        (svn-local-menu)
        )
    (progn
      (setq ed::revert-buffer-function *revert-work-file-function*)
      (mapc 'kill-local-variable *svn-local-variables*)
      (unset-minor-mode-map *svn-mode-map*)
      (use-local-menu nil)
      ))
  (update-mode-line t))

(pushnew '(*svn-mode* . *mode-line*) *minor-mode-alist* :key #'car)
  
(defun svn-list (&optional pathname)
  "svn list command. Listing directory entry for repository(*svn-repository-directory*'s value)."
  (interactive)
  (let ((current-win (window-buffer (selected-window)))
        (buf (selected-buffer)))
    (if (not pathname)
        (setq pathname (read-string "URL: " :default *svn-repository-directory*
                                    :history (or *svn-src-files-history* nil))))
    (add-history pathname '*svn-src-files-history*)
    (svn (concat "list "
         (apply 'concat (svn-list-options (svn-get-commandline-option "list"))))
         pathname (directory-namestring
                     (or (get-buffer-file-name)
                         (default-directory))))
    (switch-to-buffer-other-window buf)
    (svn-switch-buffer *svn-output-buffer* (format nil "* SVN-list ~A *" (pathname-name pathname)))
    ))

(defmacro svn-switch-buffer (buf bufname)
  `(save-excursion
     (set-buffer ,buf)
     (rename-buffer ,bufname ,buf)
     (setq *svn-output-buffer* (selected-buffer))))

(defun svn-log-file (&optional pathname exec-dir)
  "svn log command. Listing log to svn file.
svn log コマンド. ファイルの履歴を表示する."
  (interactive)
  (let ((file (or pathname (file-namestring (get-buffer-file-name))))
        (dir (or exec-dir (directory-namestring (get-buffer-file-name))))
        (buf (selected-buffer))
        (revision
           (or (if *prefix-args*
                   (read-string "Revision: "
                                :history (or *svn-rev-history* nil)
                                :default
                                (format nil "~A" *prefix-value*)))
                      nil))
        opt)
    (unless (svn-check-path (get-buffer-file-name) dir)
      (return-from svn-log-file nil))
    (when revision
      (add-history revision '*svn-rev-history*)
      (svn-set-option "--revision" revision))
    (setq opt (svn-get-opt "log"))
    (svn (concat "log " opt) file dir)
    (when revision (svn-unset-option "--revision"))
    (switch-to-buffer-other-window buf)
    (svn-switch-buffer *svn-output-buffer*
                       (concat "* SVN-log " (or revision "HEAD") " *"))
    ))

(defun svn-log-directory (&optional pathname exec-dir)
  "svn log command. Listing logs in svn working copy directory.
svn log コマンド. svnワーキングコピーディレクトリ中のファイルの履歴を表示する."
  (interactive)
  (let ((dir (or pathname (directory-namestring (get-buffer-file-name))))
        (buf (or exec-dir (selected-buffer)))
        (revision (or (if *prefix-args*
                          (read-string
                             "Revision: "
                             :history (or *svn-rev-history* nil)
                             :default (format nil "~A" *prefix-value*)))
                      nil))
        opt)
    (unless (svn-check-path (get-buffer-file-name) dir)
      (return-from svn-log-directory nil))
    (when revision
      (add-history revision '*svn-rev-history*)
      (svn-set-option "--revision" revision))
    (setq opt (svn-get-opt "log"))
    (svn (concat "log " opt) "." dir)
    (when revision (svn-unset-option "--revision"))
    (switch-to-buffer-other-window buf)
    (svn-switch-buffer *svn-output-buffer*
                       (concat "* SVN-log " (or revision "HEAD") " *"))
    ))

(defun svn-status-file (&optional pathname)
  "svn status command. Listing file status to svn working copy."
  (interactive)
  (let ((file (or pathname (file-namestring (get-buffer-file-name))))
        (dir (directory-namestring (get-buffer-file-name)))
        (buf (selected-buffer))
        (show-updates (if *prefix-args* t nil))
        opt)
    (unless (svn-check-path (get-buffer-file-name) dir)
      (return-from svn-status-file nil))
    (when show-updates
        (svn-set-option "--show-updates"))
    (setq opt (svn-get-opt "status"))
    (svn (concat "status " opt) file dir)
    (when show-updates (svn-unset-option "--show-updates"))
    (when *svn-use-parse-status* (svn-parse-status))
    (switch-to-buffer-other-window buf)
    (svn-switch-buffer *svn-output-buffer*
                       (format nil "* SVN-status ~A ~A *"
                               (or (when show-updates "--show-updates")
                                   "WCBASE") file))
    ))

(defun svn-status-directory (&optional pathname)
  "svn status command. Listing file status to svn working copy.
svn status コマンド. ワーキングコピーディレクトリ中のファイル全てのステータスを表示"
  (interactive)
  (let ((dir (or pathname (directory-namestring (get-buffer-file-name))))
        (buf (selected-buffer))
        (show-updates (if *prefix-args* t nil))
        opt)
    (unless (svn-check-path (get-buffer-file-name) dir)
      (return-from svn-status-directory nil))
    (when show-updates
        (svn-set-option "--show-updates"))
    (setq opt (svn-get-opt "status"))
    (svn (concat "status " opt) "." dir)
    (when show-updates (svn-unset-option "--show-updates"))
    (when *svn-use-parse-status* (svn-parse-status))
    (switch-to-buffer-other-window buf)
    (svn-switch-buffer *svn-output-buffer*
                       (format nil "* SVN-status ~A ~A *"
                               (or (when show-updates "--show-updates")
                                   "WCBASE")
                               dir))))

(defun svn (cmd pathname exec-dir)
  "execute svn command."
  (when *svn-debug*
    (message (format nil "svn ~A ~A ~A" cmd pathname exec-dir)))
   (ignore-errors
     (when (deleted-buffer-p *svn-output-buffer*)
       (setq *svn-output-buffer* (get-buffer-create "*svn-out*"))
       (set-buffer *svn-output-buffer*)
       (mapc 'make-local-variable '(auto-save need-not-save))
       (setq auto-save nil)
       (setq need-not-save t)
       (set-local-window-flags (selected-buffer) *window-flag-line-number* nil)
       (set-local-window-flags (selected-buffer) *window-flag-newline* nil)
       (set-local-window-flags (selected-buffer) *window-flag-eof* nil)
       ))
  (execute-shell-command
     (format nil "svn ~A ~A" cmd pathname)
     nil *svn-output-buffer*
     nil exec-dir)
  (set-buffer *svn-output-buffer*)
  (set-local-window-flags (selected-buffer) *window-flag-line-number* nil)
  (set-local-window-flags (selected-buffer) *window-flag-newline* nil)
  (set-local-window-flags (selected-buffer) *window-flag-eof* nil)
  (clear-all-text-attributes)
  (setq regexp-keyword-list nil)
  (set-buffer-modified-p nil)
  )

(defun svn-add-file (&optional pathname)
  "svn add command. Adds file to your working copy and schedules them for addition to the repository.
They will be uploaded and added to the repository on you next commit."
  (interactive)
  (let* ((file (or pathname (file-namestring (get-buffer-file-name))))
         (dir (directory-namestring (get-buffer-file-name)))
         (buf (selected-buffer))
         (parentdir (get-parent-directory dir))
         opt)
    (setq opt (svn-get-opt "add"))
    (if (and (not (svn-check-path (get-buffer-file-name) dir t))
             (svn-check-path (get-buffer-file-name) parentdir t))
        (svn-add-directory (pathname-name dir) parentdir)
      (svn (concat "add " opt) file dir))
    (switch-to-buffer-other-window buf)
    (update-modeline)
    ))

(defun svn-add-directory (&optional add-dir exec-dir)
  "svn add command. Adds directory to your working copy and schedules them for addition to the repository.
They will be uploaded and added to the repository on you next commit."
  (interactive)
  (let* ((pathname (or add-dir (pathname-name (directory-namestring (get-buffer-file-name)))))
         (dir (or exec-dir (directory-namestring (get-buffer-file-name))))
         (buf (selected-buffer))
         opt)
    (setq opt (svn-get-opt "add"))
    (if add-dir
        (svn (concat "add " opt) add-dir exec-dir)
      (progn
        (unless (or (svn-check-path (get-buffer-file-name) dir t)
                    (not (svn-check-path
                            (get-buffer-file-name)
                            (get-parent-directory dir) t)))
          (svn (concat "add " opt)
               (pathname-name dir) (get-parent-directory dir)))))
    (switch-to-buffer-other-window buf)
    (update-modeline)))

(defun svn-resolved ()
  "svn resolved command. Remove \"conflicted\" state on working copy files or directories."
  (interactive)
  (let* ((file (file-namestring (get-buffer-file-name)))
         (dir (directory-namestring (get-buffer-file-name)))
         (cmd-str "resolved")
         opt
         (buf (selected-buffer)))
    (unless (svn-check-path file dir)
      (return-from svn-resolved nil))
    (when *prefix-args*
      (setq file (pathname-name (directory-namestring (get-buffer-file-name))))
      (setq dir (get-parent-directory
                   (directory-namestring (get-buffer-file-name)))))
    (setq opt (svn-get-opt "resolved"))
    (svn (concat cmd-str " " opt) file dir)
    (switch-to-buffer-other-window buf)
    (update-modeline)
    (svn-switch-buffer *svn-output-buffer*
                       (format nil "* SVN-resolved ~A *" file))
    ))

(defun svn-revert-file (&optional pathname exec-dir)
  "svn revert command. Reverts any local changes to a file and resolves any conflicted states."
  (interactive)
  (let* ((file (or pathname (file-namestring (get-buffer-file-name))))
         (dir (or exec-dir (directory-namestring (get-buffer-file-name))))
         (buf (selected-buffer))
         opt)
    (setq opt (svn-get-opt "revert"))
    (if (y-or-n-p "Undo all local edits, ok? [~A]" file)
        (progn
          (svn (concat "revert " opt) file dir)
          (switch-to-buffer-other-window buf)
          (revert-buffer))
      (message "Cancel revert file. [~A]" file))
    ))

(defun svn-revert-directory (&optional rev-dir exec-dir)
  "svn revert command. Reverts any local changes to a directory and resolves any conflicted states."
  (interactive)
  (let* ((file (or rev-dir (file-namestring (get-buffer-file-name))))
         (dir (or exec-dir (directory-namestring (get-buffer-file-name))))
         (buf (selected-buffer))
         opt)
    (if rev-dir
        (progn
          (when (and (check-valid-pathname (merge-pathnames rev-dir exec-dir))
                     (check-valid-pathname
                        (merge-pathnames
                           (concat rev-dir "/.svn") exec-dir)))
            (if (y-or-n-p "Undo all local edits, ok? [~A]" rev-dir)
                (progn
                  (svn-with-set-option ('(("--recursive")))
                    (setq opt (svn-get-opt "revert"))
                    (svn (concat "revert " opt) rev-dir exec-dir)))
              (message "Cancel revert direcotry. [~A]" file))))
      (progn
        (if (y-or-n-p "Undo all local edits, ok? [~A]" (pathname-name dir))
            (progn
              (svn-with-set-option ('(("--recursive")))
                 (setq opt (svn-get-opt "revert"))
                 (svn (concat "revert " opt) dir (get-parent-directory dir)))
              (switch-to-buffer-other-window buf)
              (revert-buffer))
          (message "Cancel revert directory. [~A]" (pathname-name dir)))))
    ))

(defun svn-diff ()
  "svn diff command. Display the differences between two paths."
  (interactive)
  (let* ((file (file-namestring (get-buffer-file-name)))
         (dir (directory-namestring (get-buffer-file-name)))
         (revision (if *prefix-args*
                       (read-string "Revision: " :history (or *svn-rev-history* nil))
                     nil))
         opt
         (buf (selected-buffer)))
    (unless (svn-check-path (get-buffer-file-name) dir)
      (return-from svn-diff nil))
    (when revision
      (add-history revision '*svn-rev-history*)
      (svn-set-option "--revision" revision))
    (setq opt (svn-get-opt "diff"))
    (svn (concat "diff " opt) file dir)
    (when revision (svn-unset-option "--revision"))
    (save-excursion
      (set-buffer buf)
      (let* ((rev (if revision revision *revision*))
             (llist nil)
             (plus-line-color *svn-diff-color-new*)
             (minus-line-color *svn-diff-color-old*) 
             (plus-line "^\\+.*$")
             (minus-line "^\\-.*$")
             (buffer-encoding nil)) 
        (set-buffer *svn-output-buffer*)
        (setq buffer-encoding (buffer-fileio-encoding))
        (save-excursion
          (let ((str nil))
            (goto-char (point-min))
            (when (scan-buffer "^+++.*" :regexp t)
              (setq str (match-string 0))
              (delete-region (point) (progn (goto-eol) (point)))
              (insert
                 (convert-encoding-from-internal
                    buffer-encoding
                    (convert-encoding-to-internal
                       *encoding-utf8* str))))))
        (save-excursion
          (let ((str nil))
            (goto-char (point-min))
            (when (scan-buffer "^---.*" :regexp t)
              (setq str (match-string 0))
              (delete-region (point) (progn (goto-eol) (point)))
              (insert
                 (convert-encoding-from-internal
                    buffer-encoding
                    (convert-encoding-to-internal
                       *encoding-utf8* str))))))        
        (mapcar #'(lambda (x y)
                    (goto-char (point-min))
                    (while (scan-buffer x :case-fold nil
                                        :regexp t
                                        :limit (point-max) :regexp t)
                      (apply #'set-text-attribute
                             (append (list (match-beginning 0)
                                           (progn (goto-eol) (point))
                                           llist)
                                     y))
                      (forward-line)))
                (list plus-line minus-line)
                (list plus-line-color minus-line-color))))
    (switch-to-buffer-other-window buf)
    (svn-switch-buffer
       *svn-output-buffer*
       (format nil "* SVN-diff ~{~A:~} *"
               (if (and revision)
                   (if (string-match ".+:.+" revision)
                       (mapcar #'(lambda (x) (concat "r" x))
                               (split-string revision ":"))
                     (list (concat "r" revision) "WC"))
                 (list "WCBASE"))))
    ))

(defun svn-diff-with-xyzzy-diff-mode ()
  "svn diff command. Display the differences between two paths with xyzzy diff-mode."
  (interactive)
  (let ((file (file-namestring (get-buffer-file-name)))
        (dir (directory-namestring (get-buffer-file-name)))
        (buf (selected-buffer))
        (temp (make-temp-file-name "___svn" "tmp"))
        )
    (unless (svn-check-path (get-buffer-file-name) dir)
      (return-from svn-diff-with-xyzzy-diff-mode nil))
    (save-excursion
      (svn-cat (get-buffer-file-name))
      (with-open-file (s temp :direction :output)
        (write (buffer-substring (point-min) (point-max))
               :stream s :escape nil :radably nil))
      (delete-buffer *svn-output-buffer*)
      )
    (ed:diff (get-buffer-file-name) temp)
    (delete-file temp)
    ))

(defun svn-cat (&optional pathname rev)
  "svn cat command. Outputs the contetns of the specified files or URLs.
C-uつきで呼び出した場合、表示するリビジョンの指定が出来ます。"
  (interactive)
  (let* ((file (if pathname
                   (file-namestring pathname)
                 (file-namestring (get-buffer-file-name))))
         (dir (if pathname
                  (directory-namestring pathname)
                (directory-namestring (get-buffer-file-name))))
         (revision (if *prefix-args*
                       (read-string "Revision: " :history (or *svn-rev-history* nil))
                     (progn (if rev rev nil))))
         opt
         (buf (selected-buffer))
         )
    (unless (svn-check-path (if pathname pathname (get-buffer-file-name)) dir)
      (return-from svn-cat nil))
    (when revision
      (add-history revision '*svn-rev-history*)
      (svn-set-option "--revision" revision))
    (setq opt (svn-get-opt "cat"))
    (svn (concat "cat " opt) file dir)
    (when revision (svn-unset-option "--revision"))
    (unless pathname
      (switch-to-buffer-other-window buf)
      (let ((rev (or revision *revision*)))
        (svn-switch-buffer *svn-output-buffer* (concat "* SVN-cat r" rev "*")))
      )))

(defun svn-info ()
  "svn info command. Print information about paths in your working copy, including:
Path, Name, URL, Revision, Node Kind,
Last Changed Author, Last Changed Revision, Last Changed Date,
Text Last Updated, Properties Last Updated, Checksum.
普通にバインドされたキーを押せばカレントバッファのファイルについての情報を、
C-u 付きでコマンドを呼べばカレントバッファのファイルのあるディレクトリについての情報を、
C-u 0 付きでコマンドを呼べば、カレントバッファのファイルのあるディレクトリ以下の全ての
ファイル、ディレクトリについての情報を表示します。"
  (interactive)
  (let ((file (if *prefix-args*
                  (pathname-name (directory-namestring (get-buffer-file-name)))
                (file-namestring (get-buffer-file-name))))
        (dir (if *prefix-args*
                 (get-parent-directory (directory-namestring (get-buffer-file-name)))
               (directory-namestring (get-buffer-file-name))))
        (buf (selected-buffer))
        opt)
    (if *prefix-args*
        (unless (or (not (svn-check-path
                            (get-buffer-file-name)
                            (directory-namestring (get-buffer-file-name))))
                    (sub-directory-p dir (get-parent-directory dir)))
          (message "~A is not svn working copy." file)
          (return-from svn-info nil))
      (unless (svn-check-path file dir)
        (return-from svn-info nil)))
    (when (and *prefix-args*
               (= 0 *prefix-value*))
      (svn-set-option "--recursive"))
    (when (and *prefix-args*
               (= 1 *prefix-value*))
      (setq file (svn-get-repository-url (file-namestring (get-buffer-file-name))
                                         (directory-namestring (get-buffer-file-name)))))
    (setq opt (svn-get-opt "info"))
    (svn (concat "info " opt) file dir)
    (when (and *prefix-args*
               (= 0 *prefix-value*))
      (svn-unset-option "--recursive"))
    (switch-to-buffer-other-window buf)
    (svn-switch-buffer *svn-output-buffer* (concat "* SVN-info " file "*"))
    ))

(defun svn-import ()
  "svn import command. Recursively commit a copy of PATH to URL.
カレントディレクトリをリポジトリにインポートします"
  (interactive)
  (let* ((src (pathname-name (directory-namestring (get-buffer-file-name))))
         (dir (get-parent-directory (directory-namestring (get-buffer-file-name))))
         (dst (read-string "Repository: "))
#|                               (mapcar #'(lambda (x)
                                           (concat
                                              (append-trail-slash *svn-repository-directory*)
                                              (remove-trail-slash x)))
                                       (get-repository-list *svn-repository-directory*))
                               :default "DST item name" :must-match nil))
|#
         (buf (selected-buffer))
         (comment (read-string
                     "Commit msg: "
                     :default
                     (format nil
                             "Initial import [~A] for svn-mode.[~A]"
                             (directory-namestring (get-buffer-file-name))
                             *svn-mode-version*)))
         (cmd-str (format nil "import -m \"~A\"" comment))
         opt)
    (setq opt (svn-get-opt "import"))
    (svn (concat cmd-str " " opt) (format nil "~A ~A" src dst) dir)
    (switch-to-buffer-other-window buf)))

(defun svn-cleanup (&optional pathname)
  "svn cleanup command."
  (interactive)
  (let ((buf (selected-buffer))
        (dirname
           (if pathname
               (directory-namestring (pathname))
             (directory-namestring (get-buffer-file-name)))))
    (svn (concat "cleanup " (svn-get-opt "cleanup")) "." dirname)
    (switch-to-buffer-other-window buf)))

(defun svn-checkin ()
  "Call svn-log-init function."
  (interactive)
  (let* ((buf (selected-buffer))
         (name (buffer-name buf))
         (log (get-buffer-create
                 (format nil *svn-log-buffer-name* (buffer-name buf)
                         (get-revision (file-namestring (get-buffer-file-name))
                                       (directory-namestring (get-buffer-file-name)))))))
    (set-buffer log)
    (svn-log-init buf)
    (pop-to-buffer buf t nil)
    (switch-to-buffer-other-window log)))

(defun svn-checkin-directory ()
  "Call svn-log-init function."
  (interactive)
  (let* ((buf (selected-buffer))
         (name (buffer-name buf))
         (log (get-buffer-create
                 (format nil *svn-log-buffer-name*
                         (directory-namestring (get-buffer-file-name buf))
                         (get-revision (file-namestring (get-buffer-file-name))
                                       (directory-namestring (get-buffer-file-name)))))))
    (set-buffer log)
    (svn-log-init buf :type t)
    (pop-to-buffer buf t nil)
    (switch-to-buffer-other-window log)))

(defun svn-log-init (buf &optional &key type)
  "Create comment log buffer."
  (use-keymap *svn-log-mode-map*)
  (mapcar 'make-local-variable *svn-log-local-variables*)
  (setq *file-buffer* buf)
  (if type (setq *checkin-type* type))
  (insert ";;;\n;;;\n;;; SVN-log-checkin: ")
  (insert (format nil "\n;;; svn commit message for [~A]"
                  (progn
                    (string-match
                       "^\\(.+\\):\\([0-9]*\\|nil\\)$"
                       (nth 3 (split-string (buffer-name (selected-buffer))
                                            " " nil " ")))
                    (match-string 1))))
  (insert "\n;;;\n;;; 行頭が ; で始まる行は自動的に削除されます\n;;;\n;;; \n")
  (set-text-attribute 0 (1- (point-max)) 'comment :bold t)
  (set-buffer-modified-p nil)
  )

(defun svn-log-checkin ()
  "Wrapper to svn checkin command."
  (interactive)
  (let ((comment nil)
        (buf *file-buffer*)
        (checkin-type *checkin-type*))
    (setq comment (buffer-substring
                     (progn
                       (let ((firstp nil))
                         (save-excursion
                           (goto-char (point-min))
                           (while (scan-buffer "^;.*$" :no-dup t
                                               :case-fold nil :tail t
                                               :limit (point-max) :regexp t)
                             (setq firstp (1+ (match-end 0)))))
                         firstp))
                     (point-max)))
    (svn-commit buf comment checkin-type)
    (delete-buffer (selected-buffer))
    (switch-to-buffer *svn-output-buffer*)
    (switch-to-buffer-other-window buf)
    (revert-buffer)
    (update-modeline)
    ))
  
(defun svn-commit (buf comment checkin-type)
  "svn checkin command. commit with current comment."
  (let* ((temp (make-temp-file-name))
         (dirname nil))
    (with-open-file (s temp :direction :output :encoding :raw)
      (write comment :stream s :escape nil :radably nil))
    (if buf
        (unwind-protect
            (save-excursion
              (switch-to-buffer buf)               
              (setq dirname (directory-namestring (get-buffer-file-name buf)))
              (execute-shell-command
                 (format nil "svn commit ~A -F ~A ~A"
                         (svn-get-opt "commit")
                         temp
                         (if checkin-type
                             (pathname-name dirname)
                           (file-namestring (get-buffer-file-name))))
                 nil *svn-output-buffer*
                 nil (if checkin-type (get-parent-directory dirname) dirname)
                 ))
          (delete-file temp))
      (switch-to-buffer-other-window buf)
      )))

(defun svn-checkout (&optional repository local-dir exec-dir)
  "svn checkout command. Check out a working copy from a repository."
  (interactive)
  (let* ((src (or repository
                  (read-string "URL: ")))
#|         (src (or repository
                  (completing-read "URL: "
                                   (mapcar #'(lambda (x)
                                               (concat
                                                  (append-trail-slash *svn-repository-directory*)
                                                  (remove-trail-slash x)))
                                           (get-repository-list *svn-repository-directory*))
                                   :default *svn-repository-directory*
                                   :must-match t)))
|#
         (dst (or local-dir
                  (svn-get-local-path "Local Directory: "
                                      (merge-pathnames (pathname-name src) (default-directory)))))
         (cmd-str "checkout")
         (revision (if *prefix-args*
                       (read-string "Revision: " :history (or *svn-rev-history* nil))
                    nil))
         opt
         (buf (selected-buffer)))
    (add-history dst '*svn-dst-files-history*)
    (when revision
      (add-history revision '*svn-rev-history*)
      (svn-set-option "--revision" revision))
    (setq opt (svn-get-opt "checkout"))
    (svn cmd-str (format nil "~A ~A ~A" opt src dst)
               (directory-namestring (default-directory)))
    (when revision (svn-unset-option "--revision" revision))
    (switch-to-buffer-other-window buf)
    ))

(defun svn-update (&optional pathname exec-dir)
  "svn update command. Brings changes from the repository into your working copy.
If no revision given, it brings your working copy up-to-date with the HEAD revision."
  (interactive)
  (let ((file (or pathname (file-namestring (get-buffer-file-name))))
        (dir (or exec-dir (directory-namestring (get-buffer-file-name))))
        (buf (selected-buffer))
        (revision
           (or
              (if *prefix-args*
                  (read-string "Revision: "
                               :history (or *svn-rev-history* nil)
                               :default (format nil "~A" *prefix-value*)))
                      nil))
        (cmd-str "update")
        opt)
    (unless (svn-check-path (get-buffer-file-name) dir)
      (return-from svn-update nil))
    (when revision
      (add-history revision '*svn-rev-history*)
      (svn-set-option "--revision" revision))
    (setq opt (svn-get-opt "update"))
    (svn (concat cmd-str " " opt) "." dir)
    (when revision (svn-unset-option "--revision"))
    (switch-to-buffer-other-window buf)
    (revert-work-files-under (directory-namestring (get-buffer-file-name)))
    ))

(defun svn-blame ()
  "svn blame command. Shows author and revision information in-line for the specified files or URLs.
Each line of text is annotated at the begnning with the author(username)
and the revision number for the last change to that line."
  (interactive)
  (let* ((file (file-namestring (get-buffer-file-name)))
         (dir (directory-namestring (get-buffer-file-name)))
         (revision (if (and *prefix-args*
                            (= 0 *prefix-value*))
                       (read-string "Revision: " :history (or *svn-rev-history* nil))))
         opt 
         (buf (selected-buffer)))
    (unless (svn-check-path (get-buffer-file-name) dir)
      (return-from svn-blame nil))
    (when revision
      (add-history revision '*svn-rev-history*)
      (svn-set-option "--revision" revision))
    (when (and *prefix-args*
               (= 1 *prefix-value*))
      (setq file (svn-get-repository-url file dir)))
    (setq opt (svn-get-opt "blame"))
    (svn (concat "blame " opt) file dir)
    (when revision (svn-unset-option "--revision"))
    (save-excursion
      (set-buffer buf)
      (let* ((rev (if revision revision *revision*))
             (llist nil)
             (line-color *svn-blame-color*)
             (first-rev (ed::compile-regexp (format nil "^[ \\t]+~A +.+$" rev))))
        (set-buffer *svn-output-buffer*)
        (goto-char (point-min))
        (while (scan-buffer first-rev :case-fold nil :regexp t :limit (point-max))
          (apply #'set-text-attribute (append (list (match-beginning 0)
                                                    (progn (goto-eol) (point))
                                                    llist) line-color))
          (forward-line))))
    (switch-to-buffer-other-window buf)
    (svn-switch-buffer
       *svn-output-buffer*
       (format nil "* SVN-blame ~A*"
               (or (when revision
                     (concat "-r " revision))
                   "WCBASE")))
    ))

(defun svn-propedit ()
  "Call svn-progedit-init function."
  (interactive)
  (let* ((buf (selected-buffer))
         (name (buffer-name buf))
         (propname (read-string "PROPNAME: " :history (or *svn-keywords-history* nil)))
         (log (get-buffer-create
                 (format nil *svn-propedit-buffer-name*
                         (if *prefix-args*
                             (pathname-name (directory-namestring (get-buffer-file-name)))
                           (buffer-name buf))
                         propname))))
    (if *prefix-args*
        (svn-propget (pathname-name (directory-namestring (get-buffer-file-name)))
                     propname
                     (directory-namestring (get-buffer-file-name)))
      (svn-propget (file-namestring (get-buffer-file-name))
                   propname
                   (directory-namestring (get-buffer-file-name))))
    (set-buffer log)
    (add-history propname '*svn-keywords-history*)
    (insert-buffer-substring *svn-output-buffer*)
    ;(delete-buffer *svn-output-buffer*)
    (if *prefix-args*
        (svn-propedit-init buf :type t)
      (svn-propedit-init buf))
    (switch-to-buffer log)))

(defun svn-propedit-init (buf &optional &key type)
  "Create propedit buffer."
  (use-keymap *svn-propedit-mode-map*)
  (mapcar 'make-local-variable *svn-log-local-variables*)
  (make-local-variable 'need-not-save)
  (setq need-not-save t)
  (setq *file-buffer* buf)
  (if type (setq *checkin-type* type))
  )

(defun svn-pedit ()
  "Wrapper to svn propedit command."
  (interactive)
  (let ((propvalue (buffer-substring (point-min) (point-max)))
        (propname nil)
        (buf *file-buffer*)
        (checkin-type *checkin-type*)
        )
    (progn
      (string-match "\\[\\(.+\\)\\]" (caddr (split-string (buffer-name (selected-buffer)) " ")))
      (setq propname (substring (caddr (split-string (buffer-name (selected-buffer)) " "))
                                (match-beginning 1) (match-end 1))))
    (svn-propedit-exec buf propname propvalue checkin-type)
    (delete-buffer (selected-buffer))
    (switch-to-buffer *svn-output-buffer*)
    (switch-to-buffer-other-window buf)))

(defun svn-propedit-exec (buf propname propvalue checkin-type)
  "svn propedit wrapper."
  (let* ((temp (make-temp-file-name))
         (dirname nil)
         opt)
    (setq opt (svn-get-opt "propset"))
    (with-open-file (s temp :direction :output :encoding :raw)
      (write propvalue :stream s :escape nil :radably nil))
    (if buf
        (unwind-protect
            (save-excursion
              (switch-to-buffer buf)
              (setq dirname (directory-namestring (get-buffer-file-name buf)))
              (cond
                 ((and checkin-type)
                  (svn (format nil "propset ~A ~A -F ~A" opt propname temp)
                             (pathname-name (directory-namestring (get-buffer-file-name buf)))
                       (get-parent-directory dirname)))
                 (t
                    (svn (format nil "propset ~A ~A -F ~A" opt propname temp)
                               (file-namestring (get-buffer-file-name))
                         dirname))
                 ))
          (delete-file temp))
      (switch-to-buffer-other-window buf))
    ))

(defun svn-propset-working-copy ()
  "svn propset command. Set PROPNAME to PROPVAL on files, directories.
Synopsis
svn propset PROPNAME [PROPVAL | -F VALFILE] PATH ...
svn propset PROPNAME --revprop -r REV [PROPVAL | -F VALFILE] [URL]
一つ目の構文しかサポートしません"
  (interactive)
  (let ((file nil) (dir (directory-namestring (get-buffer-file-name)))
        (cmd-str "propset") (buf (selected-buffer))
        (propname nil) (propvalue nil) opt)
    (setq file
          (completing-read
             "SRC item: "
             (append
                '(".")
                (mapcar 'remove-trail-slash
                        (directory (directory-namestring (get-buffer-file-name))
                                   :recursive nil :show-dots nil :files-only t))
                (mapcar #'(lambda (x) (concat
                                         (append-trail-slash *svn-repository-directory*)
                                         (remove-trail-slash x)))
                        (get-repository-entry-all *svn-repository-directory*)))
             :default (file-namestring (get-buffer-file-name))
             :history (or *svn-src-files-history* nil)
             :must-match t))
    (when (string-equal "." file)
      (setq file (pathname-name (directory-namestring (get-buffer-file-name))))
      (setq dir (get-parent-directory (directory-namestring (get-buffer-file-name)))))
    (add-history file '*svn-src-files-history*)
    (setq propname (read-string "PROPNAME: " :history (or *svn-keywords-history* nil)))
    (add-history propname '*svn-keywords-history*)
    (setq propvalue (read-string "PROPVALUE: " :history (or *svn-keywords-history* nil)))
    (add-history propvalue '*svn-keyvalue-history*)
    (setq opt (svn-get-opt "propset"))
    (svn (format nil "~A ~A ~A \"~A\"" cmd-str opt propname propvalue) file dir)
    (switch-to-buffer-other-window buf)
    ))

(defun svn-propdel-working-copy (&optional name)
  "svn propdel command. Delete PROPNAME's value."
  (interactive)
  (let ((file (file-namestring (get-buffer-file-name)))
        (dir (directory-namestring (get-buffer-file-name)))
        (buf (selected-buffer))
        (propname (if name
                      name
                    (read-string "PROPNAME: " :history (or *svn-keywords-history* nil))))
        opt)
    (add-history propname '*svn-keywords-history*)
    (when (svn-check-path (get-buffer-file-name) dir)
      (setq opt (svn-get-opt "propdel"))
      (svn (concat " " opt " propdel " propname) file dir)
      (switch-to-buffer-other-window buf)
      )))

(defun svn-proplist ()
  "svn proplist command. Listing all PROPNAME current file.
If use '-v' option(svn-toggle-verbose), list all PROPNAME and PROPVALUE."
  (interactive)
  (let ((file (file-namestring (get-buffer-file-name)))
        (dir (directory-namestring (get-buffer-file-name)))
        (buf (selected-buffer))
        opt)
    (unless (svn-check-path (get-buffer-file-name) dir)
      (return-from svn-proplist nil))
    (setq opt (svn-get-opt "proplist"))
    (if *prefix-args*
        (svn (concat opt " proplist") "." dir)
      (svn (concat opt " proplist") file dir))
    (switch-to-buffer-other-window buf)
    (svn-switch-buffer *svn-output-buffer* (format nil "* SVN-proplist ~A*" file))
    ))

(defun svn-proplist-directory ()
  "svn proplist command. Listing all PROPNAME current directory.
If use '-v' option(svn-toggle-verbose), list all PROPNAME and PROPVALUE."
  (interactive)
  (let ((file (file-namestring (get-buffer-file-name)))
        (dir (directory-namestring (get-buffer-file-name)))
        (buf (selected-buffer))
        opt)
    (unless (svn-check-path (get-buffer-file-name) dir)
      (return-from svn-proplist-directory nil))
    (setq opt (svn-get-opt "proplist"))
    (svn (concat opt " proplist") "." dir)
    (switch-to-buffer-other-window buf)
    (svn-switch-buffer *svn-output-buffer* (format nil "* SVN-proplist ~A*" (pathname-name dir)))
    ))

(defun svn-propget (&optional src name exec-dir)
  "svn propget command. Prints the value of a property."
  (interactive)
  (let* ((file (or src (file-namestring (get-buffer-file-name))))
         (dir (or exec-dir (directory-namestring (get-buffer-file-name))))
         (cmd-str (if name
                      (concat "propget " name)
                    (concat "propget "
                            (read-string "PROPNAME: " :history (or *svn-keywords-history* nil)))))
         (buf (selected-buffer))
         opt)
    (setq opt (svn-get-opt "propget"))
    (if *prefix-args*
        (progn
          (setq file (pathname-name dir))
          (setq dir (get-parent-directory dir))))
    (svn (concat cmd-str " " opt) file dir)
    (unless src
      (switch-to-buffer-other-window buf)
      (svn-switch-buffer *svn-output-buffer* (format nil "* SVN-propget ~A*" file))
      )
    ))

(defun svn-propset-keywords ()
  "svn propset with svn:keywords command. set to keywords:
Id, HeadURL, URL, LastChangedDate, Date, LastChangedBy,
Author, LastChangedRevision, Rev."
  (interactive)
  (let ((file (file-namestring (get-buffer-file-name)))
        (dir (directory-namestring (get-buffer-file-name)))
        (temp (make-temp-file-name))
        (output nil))
    (when (svn-check-path (get-buffer-file-name) dir)
      (call-process (concat "svn propset svn:keywords \""
                            "Id HeadURL URL LastChangedBy Author LastChangedDate "
                            "Date LastChangedRevision Rev\" "
                            file)
                    :output temp
                    :exec-directory dir
                    :show :minimize
                    :wait t)
      (save-window-excursion
        (unwind-protect
            (with-open-file (fp temp)
              (let ((line nil))
                (while (setq line (read-line fp nil nil nil))
                  (push line output))))
          (delete-file temp)))
      (message "~{~A~}" output))))

(defun svn-copy (&optional source dest)
  "svn copy command. Copy a file or directory in a working copy or in the repository.
Description
Copy a file in a working copy or in the repository.
SRC and DST can each be either a working copy(WC) path or URL.

WC -> WC
 Copy and schedule an item(current buffer's file) for addition(with history).

WC -> URL
Immediately commit a copy of WC of URL.

URL -> WC
Check out URL into WC, and schedule it for addition.

URL -> URL
Complete server-side copy. This is usually used to branch and tag."
  (interactive)
  (let* ((src (or source
    (completing-read "SRC item: "
      (append
         (remove ".svn"
                 (append '(".")
                         (mapcar 'remove-trail-slash
                                 (directory
                                    (directory-namestring (get-buffer-file-name)))))
                 :test #'string=)
         (mapcar #'(lambda (x)
                     (format nil "~A~A"
                             (append-trail-slash *svn-repository-directory*)
                             x))
                 (get-repository-entry-all *svn-repository-directory*)))
                     :default (file-namestring (get-buffer-file-name))
                     :hisotry (or *svn-src-files-history* nil)
                     :must-match nil)))
         (dst (or dest (svn-get-local-path "DST file name: " (format nil "~A_DST" src))))
#|         (dst (or dest (read-string "DST file name: " :default (format nil "~A_DST" src)
                                    :history (or *svn-dst-files-history* nil))))|#
         (rev (if *prefix-args* (read-string "Revision: " :default *revision*
                                             :history (or *svn-rev-history* nil)) nil))
         (dir (directory-namestring (get-buffer-file-name)))
         (buf (selected-buffer))
         )
    (if (string-equal "." src)
        (progn
          (setq dir (get-parent-directory dir))
          (setq src (pathname-name (directory-namestring (get-buffer-file-name))))
          (set-default-directory dir)
          ))
    (add-history src '*svn-src-files-history*)
    (add-history dst '*svn-dst-files-history*)
    (when rev (add-history rev '*svn-rev-history*))
    (cond
       ; svn copy WC -> WC
       ((and (file-exist-p src)
             (valid-path-p dst)
             (not (string-match "^file\\|http" dst)))
        (svn-copy-without-comment src dst dir rev))
       ; svn copy WC -> URL
       ((and (file-exist-p src)
             (string-match "^file\\|http" dst))
        (svn-copy-with-comment src dst dir rev))
       ; svn copy URL -> URL
       ((and (string-match "^file\\|http" src)
             (string-match "^file\\|http" dst))
        (svn-copy-with-comment src dst dir rev))
       ; svn copy URL -> WC
       ((and (string-match "^file\\|http" src)
             (valid-path-p dst))
        (svn-copy-without-comment src dst dir rev))
       ; unknown error.
       (t
          (error "unknown error. SRC: ~A\nDST: ~A\nexec-dir: ~A" src dst dir)))
    (switch-to-buffer-other-window buf)
    ))

(defun svn-copy-without-comment (src dst exec-dir &optional rev)
  "svn copy wrapper. Copy command without comment."
  (let ((revision rev)
        (cmd-str "copy")
        opt)
    (if (equal revision *revision*) (setq revision nil))
    (when revision
      (svn-set-option "--revision" revision))
    (setq opt (svn-get-opt "copy"))
    (svn cmd-str (format nil " ~A ~A ~A" opt src dst) exec-dir)
    (when revision (svn-unset-option "--revision"))
      ))

(defun svn-copy-with-comment (src dst exec-dir &optional rev)
  "svn copy wrapper. Copy command with comment."
  (let* ((revision rev)
         (comment (read-string "Commit messages: "
                               :default (format nil "copy files. revision ~A [~A]."
                                                *revision* src)
                               :history (or *svn-msg-history* nil)))
         (cmd-str "copy")
         opt)
    (add-history comment '*svn-msg-history*)
    (if (equal revision *revision*) (setq revision nil))
    (when revision
      (svn-set-opsion "--revision" revision))
    (setq opt (svn-get-opt "copy"))
    (svn cmd-str (format nil " ~A ~A ~A -m \"~A\"" opt src dst comment) exec-dir)
    (when revision (svn-unset-option "--revision"))
      ))

(defun svn-delete ()
  "svn delete command. Delete an item from a working copy or the repository.
デフォルトでカレントバッファに表示しているファイルを削除予告。
C-u付きで呼び出せば、default-directoryの中のファイルやディレクトリを対象に、
C-u 0 付きで呼び出せば、リポジトリ内のディレクトリを対象に。
リポジトリ内のディレクトリを削除する場合はコミットメッセージが必要になります。"
  (interactive)
  (let* ((file (file-namestring (get-buffer-file-name)))
         (dir (directory-namestring (get-buffer-file-name)))
         (d-list nil)
         (cmd-str "delete")
         (buf (selected-buffer))
         opt)
    (setq opt (svn-get-opt "delete"))
    (cond
       ;; delete other files or directory
       ((and *prefix-args*
             (not (equal 0 *prefix-value*)))
        ;; code here.
        (setq d-list (directory (directory-namestring (get-buffer-file-name))))
        (setq d-list (remove-if #'(lambda (x) (string-equal ".svn" (remove-trail-slash x))) d-list))
        (setq file (remove-trail-slash (completing-read "Delete item: " d-list :must-match t)))
        )
       ;; delete svn repository.
       ((and *prefix-args*
             (equal 0 *prefix-value*))
        ;; code here.
        (let ((fname nil))
          (setq d-list (get-repository-list
                          *svn-repository-directory*))
          (setq fname (remove-trail-slash
                         (completing-read "Delete item: " d-list :must-match nil)))
          (setq file (format nil "~A~A"
                             (append-trail-slash *svn-repository-directory*)
                             fname))
          (setq cmd-str (concat "delete -m \""
                                (read-string
                                   (format nil "Commit msg [~A] : " fname)
                                   :default (format nil "Deleted for revision ~A. [~A]"
                                                    *revision* fname))
                                "\""))
          ))
       (t
          (unless (svn-check-path (get-buffer-file-name) dir)
            (return-from svn-delete nil))))
    (svn (concat opt " " cmd-str) file dir)
    (switch-to-buffer-other-window buf)))

(defun svn-mkdir ()
  "svn mkdir command. Create a new directory under version control."
  (interactive)
  (let* ((file (read-string "Directory: " :history (or *svn-src-files-history* nil)))
         (dir (directory-namestring (get-buffer-file-name)))
         (buf (selected-buffer))
         (cmd-str "mkdir")
         opt)
    (setq opt (svn-get-opt "mkdir"))
    (add-history file '*svn-src-files-history*)
    (cond
       ;; Create directory in current working copy.
       ((and (valid-path-p (merge-pathnames file dir))
             (not (string-match "^file\\|http" file)))
        ;; code here
        ;; nothing
        )
       ;; Create directory in repository.
       ((and (string-match "^file\\|http" file))
        (let ((msg nil))
          (setq msg (read-string "Commit message: "
                                 :default (format nil "Create directory for rivision ~A. [~A]"
                                                  *revision* file)
                                 :history (or *svn-msg-history* nil)))
          (add-history msg '*svn-msg-history*)
          (setq cmd-str (concat cmd-str " -m \"" msg "\""))))
       )
    (svn (concat opt " " cmd-str) file dir)
    (switch-to-buffer-other-window buf)
    ))

(defun svn-move (&optional source dest comment)
  "svn move command. Move a file or directory.
This command moves a file or directory in your working copy or in the repository.
Warning
Subversion does not support moving between working copies and URLs. In addition,
you can only move files within a single repository--Subversion does not support cross-repository moving."
  (interactive)
  (let* ((src (if source
                  source
                (completing-read
                   "SRC item: "
                   (mapcar #'(lambda (x)
                               (format nil "~A~A"
                                       (append-trail-slash *svn-repository-directory*) x))
                           (get-repository-entry-all *svn-repository-directory*))
                   :default (file-namestring (get-buffer-file-name))
                   :history (or *svn-src-files-history* nil)
                   :must-match nil)))
         (dst (if dest
                  dest
                (read-string "DST item name: "
                             :default (format nil "~A~A.~A" (pathname-name src) "_dst" (pathname-type src))
                             :history (or *svn-dst-files-history* nil))))
         (buf (selected-buffer))
         (revision (if *prefix-args* (read-string "Revision :" :history (or *svn-rev-history* nil)) nil))
         (cmd-str "move")
         opt
         (dir (directory-namestring (get-buffer-file-name))))
    (when revision
      (add-history revision '*svn-rev-history*)
      (svn-set-option "--revision" revision))
    (add-history src '*svn-src-files-history*)
    (add-history dst '*svn-dst-files-history*)
    (setq opt (svn-get-opt "move"))
    (when (and (string-match "^file\\|http" dst))
      (setq cmd-str (concat cmd-str
                            (format nil " -m \"~A\""
                                    (read-string "Commit message: "
                                                 :default (format nil "~A is move. [revision ~A]"
                                                                  src *revision*)))))
      )
    (let ((regstr (ed::compile-regexp "^file\\|http")))
      (cond
         ;WC-URL check
         ((and
             (not (string-match regstr src))
             (string-match regstr dst))
          (error "Not support move: working copy -> repository\nSRC item: ~A\nDST item: ~A" src dst))
         ;URL->WC check
         ((and
             (string-match regstr src)
             (not (string-match regstr dst)))
          (error "Not support move: repository -> working copy.\nSRC item: ~A\nDST item: ~A" src dst))))
    (svn (concat cmd-str " " opt) (format nil "~A ~A" src dst) dir)
    (when revision (svn-unset-option "--revision"))
    (switch-to-buffer-other-window buf)))

(defun svn-export ()
  "svn export command. Exports a clean directory tree.
2つある構文のうち、
svn export [-r REV] URL [PATH]
こちらの構文のみをサポートします。"
  (interactive)
  (let* ((src nil)
         (dst nil)
         (revision (if *prefix-args* (read-string "Revision: " :default *revision*
                                                  :history (or *svn-rev-history* nil)) nil))
         (buf (selected-buffer))
         (cmd-str "export")
         (dir (get-repository-root-path))
         (root-dir (get-root-entry dir))
         (repo-list nil)
         opt)
    (when *svn-use-completion*
      (setq repo-list
            (mapcar #'(lambda (x)
                        (format nil "~A~A"
                                (append-trail-slash root-dir)
                                x))
                    (get-repository-list
                       (get-root-entry dir)))))
    (setq src (completing-read "Repo or WC dir: " repo-list :default *svn-repository-directory*
                               :history (or *svn-src-files-history* nil) :must-match nil))
    (add-history src '*svn-src-files-history*)
    (setq dst (svn-get-local-path
                 "Export dir(full-path): "
                 (remove-trail-slash
                    (merge-pathnames
                       (pathname-name src) (default-directory)))))
    (add-history dst '*svn-dst-files-history*)
    (when revision
      (add-history revision '*svn-rev-history*)
      (svn-set-option "--revision" revision))
    (setq opt (svn-get-opt "export"))
;    (unless (string-match "^[a-zA-Z]:.+$" src)
;      (setq src (format nil "~A~A" (append-trail-slash *svn-repository-directory*) src)))
    (svn (concat cmd-str " " opt) (format nil " ~A ~A" src dst) (default-directory))
    (when revision (svn-unset-option "--revision"))
    (switch-to-buffer-other-window buf)
    ))

(defun svn-merge (&optional start end target)
  "svn merge command. Apply the difference between two sources to a working copy path.

svn merge sourceURL1@N sourceURL2@M WCPATH

In the first form, the source URLs are specified at revision N and M.
These are the two sources to be compared. The revision default to HEAD if omitted.

WCPATH is the working copy path that will receive the changes. If WCPATH is omitted, a default
value of '.' is assumed, unless the sources have identical basenames thas match a file within
'.' in which case, the differences will be applied to that file.

Unlike svn diff, the merge command takes the ancestry of a file into consideration when
performing a merge operation. This is very important when you're merging changes
from one branch into another and you've renamed a file on one branch but not the other."
  (interactive)
  (let* ((base (or start nil))
         (final (or end nil))
         (target-wc (or target nil))
         (cmd-str "merge")
         (buf (selected-buffer))
         opt)
    (message "svn merge")
    (setq opt (svn-get-opt cmd-str))
    (unless base
      (setq base (read-string "Base URL: ")))
    (unless final
      (setq final (read-string "Last URL: ")))
    (unless target-wc
      (setq target-wc (read-string "Target: " :default (remove-trail-slash (directory-namestring (get-buffer-file-name))))))
    (svn (concat opt " " cmd-str)
         (format nil "\"~A\" \"~A\" \"~A\"" base final target-wc)
         (directory-namestring (get-buffer-file-name)))
    (switch-to-buffer-other-window buf)
    (revert-work-files-under (directory-namestring (get-buffer-file-name)))
    (update-modeline)))

(defun svn-lock ()
  "svn lock command."
  (interactive)
  (when *lock*
    (message "Locked file.")
    (return-from svn-lock nil))
  (let* ((file (file-namestring (get-buffer-file-name)))
         (dir (directory-namestring (get-buffer-file-name)))
         (buf (selected-buffer))
         (cmd-str (concat "lock -m \""
                          (read-string
                             (format nil "Lock Message [~A] : " (buffer-name (selected-buffer)))
                             :default "Lock")
                          "\""))
         opt)
    (setq opt (svn-get-opt "lock"))
    (unless (svn-check-path (get-buffer-file-name) dir)
      (return-from svn-lock nil))
    (svn (concat opt " " cmd-str) file dir)
    (switch-to-buffer-other-window buf)
    (update-modeline)
    ))

(defun svn-unlock ()
  (interactive)
  (unless *lock*
    (unless (svn-use-option-p "--force")
      (message "Unlocked file.")
      (return-from svn-unlock nil)))
  (let* ((file (file-namestring (get-buffer-file-name)))
         (dir (directory-namestring (get-buffer-file-name)))
         (buf (selected-buffer))
         (cmd-str "unlock")
         opt)
    (setq opt (svn-get-opt "unlock"))
    (unless (svn-check-path (get-buffer-file-name) dir)
      (return-from svn-unlock nil))
    (svn (concat opt " " cmd-str) file dir)
    (switch-to-buffer-other-window buf)
    (update-modeline)
    ))
    
(defun svn-help (&optional cmd)
  "svn help command. Display command help."
  (interactive)
  (let ((cmd-str "help")
        (buf (selected-buffer))
        (sub-cmd (if *prefix-args* (read-string "subcommand: ") (or cmd "")))
        (dir (directory-namestring (get-buffer-file-name)))
        )
    (svn (concat cmd-str " " (svn-get-opt "help")) sub-cmd dir)
    (switch-to-buffer-other-window buf)
    (svn-switch-buffer *svn-output-buffer* (concat "* SVN-help " sub-cmd " *"))
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; support functions
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun svn-check-path (pathname dir &optional nowarn)
  "Check the file is existing, and confirm current directory is 'svn working copy'."
  (if (not (file-exist-p pathname))
      (progn
        (unless nowarn
          (message "~A is not exist." pathname))
        (return-from svn-check-path nil)))
  (if (not (file-directory-p (merge-pathnames *svn-dir* dir)))
      (progn
        (unless nowarn
          (message "~A is not svn working copy." dir))
        (return-from svn-check-path nil)))
  t)

(defun get-repository-list (repository-root-path)
  "リポジトリ内のディレクトリの一覧を返す"
  (let ((r-list nil)
        (line nil)
        (dir-regexp (ed::compile-regexp "^.+/$")))
    (save-excursion
      (execute-shell-command (format nil "svn list -R ~A" repository-root-path)
                             nil *svn-output-buffer*)
      (set-buffer *svn-output-buffer*)
      (setq line (buffer-substring (point-min) (point-max)))
      (delete-region (point-min) (point-max))
      (dolist (item (split-string line "\n")) (when (string-match dir-regexp item) (push item r-list))))
    (mapcar 'remove-trail-slash r-list)))

(defun get-repository-entry-all (repository-root-path)
  "Get repository file entry"
  (let* ((r-list nil)
         (line nil))
    (save-excursion
      (execute-shell-command (format nil "svn list -R ~A" repository-root-path)
                             nil *svn-output-buffer*)
      (set-buffer *svn-output-buffer*)
      (setq line (buffer-substring (point-min) (point-max)))
      (delete-region (point-min) (point-max)))
    (mapcar 'remove-trail-slash (split-string line "\n"))))

(defun get-repository-root-path (&optional dir)
  (interactive)
  (let ((curdir
           (or dir
         (directory-namestring
            (get-buffer-file-name (selected-buffer)))))
        )
    (when (file-exist-p
             (merge-pathnames
                ".svn/"
                (get-parent-directory curdir)))
      (return-from get-repository-root-path
        (get-repository-root-path (get-parent-directory curdir))))
    (when (file-exist-p (merge-pathnames ".svn/" curdir))
      (return-from get-repository-root-path curdir))
    ))

(defun get-root-entry (dir)
  (interactive)
  (let (entries root-entry)
    (unless (or (not (file-directory-p dir))
                (file-exist-p (merge-pathnames ".svn/entries" dir)))
      (return-from get-root-entry nil))
    (setq entries (first (xmlpm-parse-file (merge-pathnames ".svn/entries" dir))))
    (dolist (item entries)
      (when (and (equal "entry" (safe-car item))
                 (equal "dir" (cdr (assoc "kind" (second item) :test 'equal)))
                 (assoc "url" (second item) :test 'equal)
                 (equal "" (cdr (assoc "name" (second item) :test 'equal))))
        (setq root-entry (cdr (assoc "url" (second item) :test 'equal)))))
    root-entry))

;;; new parent directory function
(defun get-parent-directory (dir)
  "Get parent directory."
  (concat (pathname-device dir)
          ":/"
          (apply 'concat
                 (mapcar 'append-trail-slash
                         (pathname-directory dir)))))

(defun get-entry (file dir)
  "Get file entry from 'entries' file into '.svn' directory"
  (let ((entries nil) (rev nil) (tm nil) (status nil) (lock nil))
    (unless (or (not (file-directory-p dir))
                (file-exist-p (merge-pathnames ".svn/entries" dir)))
      (return-from get-entry nil))
    (setq entries (first (xmlpm-parse-file (merge-pathnames ".svn/entries" dir))))
    (dolist (item entries)
      (when (and (equal "entry" (safe-car item))
                 (equal "dir" (cdr (assoc "kind" (second item) :test 'equal)))
                 (assoc "url" (second item) :test 'equal))
        (setq *svn-repository-directory* (cdr (assoc "url" (second item) :test 'equal))))
      (when (and (equal "entry" (safe-car item))
                 (equal "file" (cdr (assoc "kind" (second item) :test 'equal)))
                 (equal file (cdr (assoc "name" (second item) :test 'equal))))
        (if (assoc "schedule" (second item) :test 'equal)
            (setq rev "0")
          (progn
            (setq rev (cdr (assoc "committed-rev" (second item) :test 'equal)))
            (setq tm (cdr (assoc "text-time" (second item) :test 'equal)))
            (when (and
                     (assoc "lock-owner" (second item) :test 'equal)
                     (assoc "lock-comment" (second item) :test 'equal)
                     (assoc "lock-creation-date" (second item) :test 'equal)
                     (assoc "lock-token" (second item) :test 'equal))
              (setq lock t))
            (if (not tm)
                (setq tm (svn-parse-time (cdr (assoc "committed-date" (second item) :test 'equal))))
              (setq tm (svn-parse-time (cdr (assoc "text-time" (second item) :test 'equal)))))))
        (if (assoc "conflict-wrk" (second item) :test 'equal)
            (setq status ":Conflict"))
        ))
    (values rev tm status lock)))

(defun svn-get-repository-url (filespec dirspec)
  (let ((url nil) (entries nil))
    (unless (or (not (file-directory-p dirspec))
                (file-exist-p (merge-pathnames ".svn/entries" dirspec)))
      (return-from svn-get-repository-url nil))
    (setq entries (first (xmlpm-parse-file (merge-pathnames ".svn/entries" dirspec))))
    (dolist (item entries url)
      (when (and (equal "entry" (safe-car item))
                 (equal "dir" (cdr (assoc "kind" (second item) :test 'equal)))
                 (assoc "url" (second item) :test 'equal))
        (setq url (cdr (assoc "url" (second item) :test 'equal)))))
    (concat (append-trail-slash (map-backslash-to-slash url)) filespec)))

(defun get-revision (file dir)
  "Get revision from 'entries' file into '.svn' directory."
  (let ((entries nil) (rev nil))
    (unless (or (not (file-directory-p dir))
                (file-exist-p (merge-pathnames ".svn/entries" dir)))
      (return-from get-revision nil))
    (setq entries (first (xmlpm-parse-file (merge-pathnames ".svn/entries" dir))))
    (dolist (item entries rev)
      (when (and (equal "entry" (safe-car item))
                 (equal "file" (cdr (assoc "kind" (second item) :test 'equal)))
                 (equal file (cdr (assoc "name" (second item) :test 'equal))))
        (setq rev (cdr (assoc "committed-rev" (second item) :test 'equal)))))
    rev))

(defun get-last-commit-time (file dir)
  "Get last commit time."
  (let ((entries nil) (tm nil))
    (unless (or (not (file-directory-p dir))
                (file-exist-p (merge-pathnames ".svn/entries" dir)))
      (return-from get-last-commit-time nil))
    (setq entries (first (xmlpm-parse-file (merge-pathnames ".svn/entries" dir))))
    (dolist (item entries tm)
      (when (and (equal "entry" (safe-car item))
                 (equal "file" (cdr (assoc "kind" (second item) :test 'equal)))
                 (equal file (cdr (assoc "name" (second item) :test 'equal))))
        (setq tm (cdr (assoc "committed-date" (second item) :test 'equal)))))
    tm))

(defvar *svn-time-format*
  (ed::compile-regexp "\\([0-9]\\{4\\}\\)-\\([0-9]\\{2\\}\\)-\\([0-9]\\{2\\}\\)T\\([0-9]\\{2\\}\\):\\([0-9]\\{2\\}\\):\\([0-9]\\{2\\}\\)\\.[0-9]\\{6\\}."))

(defun svn-parse-time (x)
  "Parse time-format."
  (interactive)
  (if (string-match *svn-time-format* x)
      (let* ((tm (mapcar #'(lambda (i) (substring x (match-beginning i) (match-end i)))
                         '(6 5 4 3 2 1))))
        (do ((i 0 (+ i 1)))
            ((null (nth i tm)))
          (or (integerp (nth i tm)) (setf (nth i tm) (parse-integer (nth i tm)))))
        (apply #'encode-universal-time (append tm '(0))))
    x))

(defun update-modeline ()
  "Update the modeline."
  (interactive)
  (unless (get-buffer-file-name)
    (return-from update-modeline nil))
  (let ((rev nil) (tm nil) (status nil) (lock nil) (mod nil))
    (multiple-value-setq (rev tm status lock)
      (get-entry (file-namestring (get-buffer-file-name))
                 (directory-namestring (get-buffer-file-name))))
    (cond ((not (stringp rev))
           ; not controlled with Subversion.
           (setq *revision* nil *status* "-" *lock* lock))
          ((string-equal rev "0")
           ; new file
           (setq *revision* nil *status* "+" *lock* lock))
          ((not (setq mod (file-write-time (get-buffer-file-name))))
           ; no file
           (setq *revision* rev *status* "-" *lock* lock))
          ((or (not (integerp tm)) (< tm mod))
           ; locally modified
           (setq *revision* rev *status* (concat "*" status) *lock* lock))
          (t ;up-to-date
             (setq *revision* rev *status* "" *lock* lock)))
    (setq *mode-line* (concat "SVN:rev" *revision* *status* (if lock "[K]" "")))))

(defun revert-work-file (&optional buffer)
  (save-excursion
    (when buffer (set-buffer buffer))
    (if *revert-work-file-function*
        (funcall *revert-work-file-function*))
    (if *svn-mode*
        (update-modeline)
      (svn-mode))))

(defun revert-work-files-under (dir)
  (let (name (len (length dir)))
    (dolist (buf (buffer-list))
      (and (setq name (get-buffer-file-name buf))
           (path-equal (directory-namestring name) dir)
           (revert-work-file buf)))))

(defun svn-open-file ()
  (interactive)
  (if (file-directory-p (merge-pathnames ".svn" (directory-namestring (get-buffer-file-name))))
      (if (not *svn-mode*)
          (svn-mode t))
    nil))

(defun svn-custom-completion ()
  (interactive)
  (goto-eol)
  (do-completion (point-min) (point) :directory-name))

(defun svn-get-local-path (prompt &optional default)
  (let ((obind (lookup-keymap minibuffer-local-map #\TAB))
        (path (or default (default-directory))))
    (define-key minibuffer-local-map #\TAB 'svn-custom-completion)
    (prog1
        (read-string prompt :default path :history (or *svn-dst-files-history* nil))
      (if obind
          `(define-key minibuffer-local-map #\TAB ',obind)
        (undefine-key minibuffer-local-map #\TAB)))))
    
(add-hook 'ed::*find-file-hooks* 'svn-open-file)

