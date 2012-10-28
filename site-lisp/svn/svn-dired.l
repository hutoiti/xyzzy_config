;;; -*- MODE: Lisp; Package: EDITOR; -*-
;;;
;;; svn-dired.l
;;;
;;; $HeadURL: file:///g:/repository/xyzzy/site-lisp/svn/release/0.0.2.0/svn-dired.l $
;;;
;;; $LastChangedDate: 2005-07-04 21:59:51 +0900 (Mon, 04 Jul 2005) $
;;;
;;; $LastChangedRevision: 171 $
;;;
;;; LKPTeam <ykaltenative@mue.biglobe.ne.jp>
;;;

;;;
;;; code
;;;

(provide "svn-dired")


(defvar *svn-list-command* "svn list -v")
(defvar *svn-dired-mode-name* "SVN-Dired")

(defvar *svn-dired-file-color* '(:color 0 0))
(defvar *svn-dired-dir-color*  '(:keyword 1 :bold))
(defvar *svn-dired-up-dir-color* '(:keyword 0 :bold))

(defconstant *svn-dired-prefix* "SVN-dired")
(defconstant *svn-dired-up-dir* "<UP-DIRECTORY>")

(defvar *svn-dired-mode-hook* nil)

(defvar *svn-dired-local-variables*
  '(svn-repository-name
    need-not-save
    auto-save
    mode-line-format
    regexp-keyword-list
    ))

(defvar *svn-dired-mode-map* nil)
(unless *svn-dired-mode-map*
  (setq *svn-dired-mode-map* (make-keymap))
  (define-key *svn-dired-mode-map* #\RET 'svn-dired-enter)
  (define-key *svn-dired-mode-map* #\SPC 'svn-dired-enter)
  (define-key *svn-dired-mode-map* #\] 'svn-dired-cat)
  (define-key *svn-dired-mode-map* #\q 'svn-dired-exit)
  (define-key *svn-dired-mode-map* #\c 'svn-dired-checkout)
  (define-key *svn-dired-mode-map* #\u 'svn-dired-up-dir)
  (define-key *svn-dired-mode-map* #\l 'svn-dired-log)
  (define-key *svn-dired-mode-map* #\' 'svn-dired-info)
  (define-key *svn-dired-mode-map* #\e 'svn-dired-export)
  (define-key *svn-dired-mode-map* #\E 'svn-dired-export-force)
  (define-key *svn-dired-mode-map* #\k 'svn-dired-mkdir)
  (define-key *svn-dired-mode-map* #\r 'svn-dired-reload-list)
  (define-key *svn-dired-mode-map* #\" 'svn-dired-delete)
  (define-key *svn-dired-mode-map* #\= 'svn-dired-copy)
  (define-key *svn-dired-mode-map* #\b 'svn-dired-blame)
  (define-key *svn-dired-mode-map* #\m 'svn-dired-move)
  (define-key *svn-dired-mode-map* #\d 'svn-dired-diff)
  (define-key *svn-dired-mode-map* #\p 'svn-dired-proplist)
  )

(defvar *svn-dired-regexp-keyword-list* nil)
(unless *svn-dired-regexp-keyword-list*
  (setq *svn-dired-regexp-keyword-list*
     (compile-regexp-keyword-list
       `(
           (".+/$"            nil ,*svn-dired-dir-color* nil)
           (".+\\<UP-DIRECTORY\\>." nil ,*svn-dired-up-dir-color* nil)
           (".+[^/]$"         nil ,*svn-dired-file-color* nil))))) 

(defun svn-dired-count-num ()
  (let ((num 1))
    #'(lambda () (if (= 1 num)
                     (prog1 ""
                       (setq num (1+ num)))
                   (prog1
                       (format nil "<~A>" num)
                     (setq num (1+ num)))))))

(defvar *svn-dired-buf-count* (svn-dired-count-num))

(defun svn-dired (&optional repo)
  (interactive)
  (let* ((repository (or repo (read-string "Repository: ")))
         ;(buf (concat *svn-dired-prefix*
         ;             (format nil "~D" (svn-count-dired))))
         (buf (format nil "~A~A" *svn-dired-prefix* (funcall *svn-dired-buf-count*)))

        )
    (when (svn-dired-execute-svn-list repository buf)
      (let ((lst (svn-dired-make-list-from-svnlist buf)))
        (set-buffer buf)
        (delete-region (point-min) (point-max))
        (goto-char (point-min))
        (mapc 'make-local-variable *svn-dired-local-variables*)
        (setq need-not-save t)
        (setq auto-save nil)
        (setq regexp-keyword-list *svn-dired-regexp-keyword-list*)
        (setq svn-repository-name (append-trail-slash repository))
        (insert (svn-dired-output-list lst))
        (svn-dired-update-modeline)
        (setq buffer-mode *svn-dired-mode-name*)
        (set-local-window-flags (selected-buffer) *window-flag-line-number* nil)
        (set-local-window-flags (selected-buffer) *window-flag-newline* nil)
        (set-local-window-flags (selected-buffer) *window-flag-eof* nil)
        (use-keymap *svn-dired-mode-map*)
        (setq mode-name *svn-dired-mode-name*)
        (set-buffer-modified-p nil)
        (setq buffer-read-only t)
        (goto-char (point-min))
        (svn-local-menu)
        (run-hooks '*svn-dired-mode-hook*)
        ))))

(defun svn-dired-enter ()
  (interactive)
  (case (svn-dired-check-type)
    (:FILE nil)
    (:DIR (svn-dired-enter-1))
    (:UPDIR
     (svn-dired-up-directory
        (progn
          (when (string-match "\\(.+/\\)[^/]+/$" svn-repository-name)
            (match-string 1)))))
    (t nil)))

(defun svn-dired-get-current-line-file-name ()
  (save-excursion
    (goto-eol)
    (buffer-substring (point)
                      (save-excursion
                        (skip-syntax-spec-backward "_w.")
                        (point)))))

(defun svn-dired-cat ()
  (interactive)
  (let ((buf (selected-buffer))
        (name nil))
    (case (svn-dired-check-type)
      (:FILE
       (setq name (concat
                     svn-repository-name
                     (svn-dired-get-current-line-file-name)))
       (if *prefix-args*
           (progn
             (let ((rev (read-string "Revision: ")))
               (svn-with-set-option ((list (list "--revision" rev)))
                  (svn (concat "cat " (svn-get-opt "cat")) name (default-directory)))
               ))
         (progn
           (svn (concat "cat " (svn-get-opt "cat")) name (default-directory))))
       (switch-to-buffer-other-window buf))
      ((:DIR :UPDIR) nil)
      (t nil))))

(defun svn-dired-checkout ()
  (interactive)
  (case (svn-dired-check-type)
    ((:FILE :UPDIR) nil)
    (:DIR
     ;;; something
     (let ((buf (selected-buffer))
           (name
              (svn-get-local-path "Local-PATH: "
                                  (merge-pathnames (svn-dired-get-current-line-file-name)
                                                   (default-directory)))))
       (svn (concat "checkout " (svn-get-opt "checkout"))
            (format nil "~A ~A"
                    (concat svn-repository-name (svn-dired-get-current-line-file-name))
                    name)
            (default-directory))
       (switch-to-buffer-other-window buf)
       ))
    (t nil)))

(defun svn-dired-up-dir ()
  (interactive)
  (svn-dired-up-directory
     (progn
       (when (string-match "\\(.+/\\)[^/]+/$" svn-repository-name)
         (match-string 1)))))

(defun svn-dired-log ()
  (interactive)
  (case (svn-dired-check-type)
    ((:FILE :DIR)
     (let ((name (concat svn-repository-name (svn-dired-get-current-line-file-name)))
           (buf (selected-buffer)))
       (svn (concat "log " (svn-get-opt "log"))
            name (default-directory))
       (switch-to-buffer-other-window buf)))
    (:UPDIR nil)
    (t nil)))

(defun svn-dired-info ()
  (interactive)
  (case (svn-dired-check-type)
    ((:FILE :DIR)
     (let ((name (concat svn-repository-name (svn-dired-get-current-line-file-name)))
           (buf (selected-buffer)))
       (svn (concat "info " (svn-get-opt "info"))
            name (default-directory))
       (switch-to-buffer-other-window buf)))
    (:UPDIR nil)
    (t nil)))

(defun svn-dired-export (&optional revision)
  (interactive)
  (case (svn-dired-check-type)
    ((:FILE :UPDIR) nil)
    (:DIR
     (let* ((name (svn-dired-get-current-line-file-name))
            (buf (selected-buffer))
            (local (svn-get-local-path "(export)Local-PATH: " (merge-pathnames name (default-directory))))
            (rev (or revision
                     (when *prefix-args*
                       (read-integer "Revision: ")))))
       (if rev
           (progn
             (svn-with-set-option ((list (list "--revision" rev)))
                (svn (concat "export " (svn-get-opt "export"))
                     (format nil " ~A ~A"
                             (concat svn-repository-name name)
                             local)
                     (default-directory))))
         (svn (concat "export " (svn-get-opt "export"))
              (format nil " ~A ~A"
                      (concat svn-repository-name name)
                      local)
              (default-directory)))
       (switch-to-buffer-other-window buf)))
    (t nil)))

(defun svn-dired-export-force (&optional rev)
  (interactive "p")
  (svn-set-option "--force")
  (svn-dired-export rev)
  (svn-unset-option "--force"))

(defun svn-dired-mkdir ()
  (interactive)
  (let* ((buf (selected-buffer))
         (name (read-string "(mkdir)Dir: "
                            :default svn-repository-name))
         (msg (read-string
                 "(mkdir)message: "
                 :default (format nil
                                  "<CREATE>[~A] was created by ~A."
                                  name *svn-dired-mode-name*))))
    (svn (concat (svn-get-opt "mkdir") " mkdir -m \"" msg "\"")
         name (default-directory))
    (switch-to-buffer-other-window buf)))

(defun svn-dired-reload-list ()
  (interactive)
  (setq buffer-read-only nil)
  (when (svn-dired-execute-svn-list svn-repository-name (selected-buffer))
    (let ((lst (svn-dired-make-list-from-svnlist (selected-buffer))))
      (delete-region (point-min) (point-max))
      (goto-char (point-min))
      (insert (svn-dired-output-list lst))
      (svn-dired-update-modeline)
      (set-buffer-modified-p nil)
      (setq buffer-read-only t)
      (goto-char (point-min))
      )))

(defun svn-dired-delete ()
  (interactive)
  (case (svn-dired-check-type)
    ((:FILE :DIR)
     (let* ((buf (selected-buffer))
            (name (svn-dired-get-current-line-file-name))
            (msg (read-string
                    "(delete)message: "
                    :default (format nil "<DELETE>[~A] was deleted by ~A."
                                     name *svn-dired-mode-name*))))
       (svn (concat (svn-get-opt "delete") " delete -m \"" msg "\"")
            (concat svn-repository-name name)
            (default-directory))
       (switch-to-buffer-other-window buf)))
    (:UPDIR nil)
    (t nil)))

(defun svn-dired-copy ()
  (interactive)
  (case (svn-dired-check-type)
    ((:FILE :DIR)
     (let* ((buf (selected-buffer))
            (name (svn-dired-get-current-line-file-name))
            (rev (if *prefix-args*
                     (read-integer "(copy)Revision: ")
                   nil))
            (dst (read-string
                    "(copy)DST-path: "
                    :default svn-repository-name))
            (msg (read-string
                    "(copy)message: "
                    :default (format nil "<COPY>[~A]~A was copied by ~A."
                                     name
                                     (if rev
                                         (format nil "(Revision ~A)" rev)
                                       "")
                                     *svn-dired-mode-name*))))
       (when rev (svn-set-option "--revision" rev))
       (svn (concat (svn-get-opt "copy") " copy -m \"" msg "\"")
            (format nil "~A ~A" (concat svn-repository-name name) dst)
            (default-directory))
       (when rev (svn-unset-option "--revision"))
       (switch-to-buffer-other-window buf)))
    (:UPDIR nil)
    (t nil)))

(defun svn-dired-get-current-line-revision (buf)
  (goto-bol)
  (skip-chars-forward " \t")
  (buffer-substring (point)
                    (save-excursion
                      (skip-syntax-spec-forward "_w")
                      (point))))

(defun svn-dired-blame ()
  (interactive)
  (case (svn-dired-check-type)
    (:FILE
     (let* ((buf (selected-buffer))
            (name (svn-dired-get-current-line-file-name))
            (rev (if *prefix-args*
                     (read-integer "(blame)Revision: ")
                   nil)))
       (save-excursion
         (when rev (svn-set-option "--revision" rev))
         (svn (concat (svn-get-opt "blame") " blame")
              (concat svn-repository-name name)
              (default-directory))
         (when rev (svn-unset-option "--revision")))
       (let* ((revision (if rev rev (svn-dired-get-current-line-revision buf)))
              (llist nil)
              (line-color *svn-blame-color*)
              (first-rev (ed::compile-regexp (format nil "^[ \\t]+~A +.+$" revision))))
         (set-buffer *svn-output-buffer*)
         (goto-char (point-min))
         (save-excursion
           (while (scan-buffer first-rev :case-fold nil :regexp t :limit (point-max))
             (apply #'set-text-attribute (append (list (match-beginning 0)
                                                       (progn (goto-eol) (point))
                                                       llist) line-color))
             (forward-line))))
       (switch-to-buffer-other-window buf)))
    ((:DIR :UPDIR) nil)
    (t nil)))

;;; revisionオプションは未サポート
(defun svn-dired-move ()
  (interactive)
  (case (svn-dired-check-type)
    ((:FILE :DIR)
     (let* ((buf (selected-buffer))
            (name (svn-dired-get-current-line-file-name))
            (dst (read-string "(move)dst-path: "
                              :default (concat svn-repository-name name)))
            (msg (read-string "(move)message: "
                              :default (format nil "<MOVE> [~A] was moved by ~A."
                                               name *svn-dired-mode-name*))))
       (svn (concat (svn-get-opt "move") " move -m \"" msg "\"")
            (format nil "~A ~A" (concat svn-repository-name name) dst)
            (default-directory))
       (switch-to-buffer-other-window buf)))
    (:UPDIR nil)
    (t nil)))

(defun svn-dired-diff ()
  (interactive)
  (case (svn-dired-check-type)
    ((:DIR :FILE)
     (let* ((buf (selected-buffer))
            (name (svn-dired-get-current-line-file-name))
            (n-rev (read-string "(diff)<N-rev> [<N-rev>:<M-rev>]: "))
            (m-rev (read-string (format nil "(diff)<M-rev> [~A:<M-rev>]: " n-rev))))
       (svn (format nil "diff ~A -r ~A:~A"
                    (svn-get-opt "diff") n-rev m-rev)
            (concat svn-repository-name name) (default-directory))
       (save-excursion
         (let* ((llist nil)
                (plus-line-color *svn-diff-color-new*)
                (minus-line-color *svn-diff-color-old*) 
                (plus-line "^\\+.*$")
                (minus-line "^\\-.*$")) 
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
       ))
    (:UPDIR nil)
    (t nil)))

(defun svn-dired-proplist ()
  (interactive)
  (case (svn-dired-check-type)
    ((:FILE :DIR)
     (let* ((buf (selected-buffer))
            (name (svn-dired-get-current-line-file-name))
            (rev (if *prefix-args*
                     (read-integer "(proplist)Revision: ")
                   nil)))
       (when rev (svn-set-option "--revision" rev))
       (svn (concat (svn-get-opt "proplist") " proplist")
            (concat svn-repository-name name)
            (default-directory))
       (when rev (svn-unset-option "--revision"))
       (switch-to-buffer-other-window buf)
       ))
    (:UPDIR nil)
    (t nil)))

(defun svn-dired-exit ()
  (interactive)
  (delete-buffer (selected-buffer))
  (delete-other-windows)
  )

(defun svn-dired-check-repository (dir)
  (let ((out (get-buffer-create " *svn-dired-check-result* ")))
    (save-window-excursion
      (if (= 1 (execute-shell-command
                  (concat "svn "
                          (svn-get-opt "list")
                          " list " dir) nil out))
          (prog1 nil
            (delete-buffer out))
        t))))

(defun svn-dired-up-directory (dir)
  (when (svn-dired-check-repository dir)
    (setq svn-repository-name dir)
    (setq buffer-read-only nil)
    (when (svn-dired-execute-svn-list svn-repository-name (selected-buffer))
      (let ((lst (svn-dired-make-list-from-svnlist (selected-buffer))))
        (delete-region (point-min) (point-max))
        (goto-char (point-min))
        (insert (svn-dired-output-list lst))
        (svn-dired-update-modeline)
        (set-buffer-modified-p nil)
        (setq buffer-read-only t)
        (goto-char (point-min))
        ))))

(defun svn-dired-enter-1 (&optional dirname)
  (let ((dir (or dirname
                 (save-excursion
                   (goto-eol)
                   (buffer-substring
                      (point)
                      (save-excursion
                        (skip-syntax-spec-backward "._w")
                        (point)))))))
    (setq svn-repository-name (concat
                                 (append-trail-slash svn-repository-name)
                                 dir))
    (setq buffer-read-only nil)
    (when (svn-dired-execute-svn-list svn-repository-name (selected-buffer))
      (let ((lst (svn-dired-make-list-from-svnlist (selected-buffer))))
        (delete-region (point-min) (point-max))
        (goto-char (point-min))
        (insert (svn-dired-output-list lst))
        (svn-dired-update-modeline)
        (set-buffer-modified-p nil)
        (setq buffer-read-only t)
        (goto-char (point-min))
        ))))
                                      

(defun svn-dired-update-modeline ()
  (setq mode-line-format
        (format nil "---- [%M] -- ~A ~A"
                *svn-dired-prefix* svn-repository-name)))

(defun svn-dired-check-type ()
  (let (name type)
    (save-excursion
      (goto-eol)
      (setq name
            (buffer-substring (point)
                              (save-excursion
                                (skip-syntax-spec-backward "._w")
                                (point))))
      (cond
         ((string-match ".+/" name) (setq type :DIR))
         ((string-match *svn-dired-up-dir* name) (setq type :UPDIR))
         (t (setq type :FILE)))
      type)))

(defun svn-count-dired ()
  (length
     (remove-if
        #'(lambda (x) (string/= *svn-dired-mode-name*
                                (save-excursion
                                  (set-buffer x)
                                  mode-name)))
        (buffer-list))))

(defun svn-dired-execute-svn-list (repo buf)
  (let ((buffer (selected-buffer)))
    (if (not (zerop (execute-shell-command
           (concat *svn-list-command* " " repo)
                       nil buf)))
        (prog1 nil
          (switch-to-buffer buffer)
          (delete-other-windows)
          (delete-buffer buf))
      t)))
      
(defun svn-dired-parse-line (line)
  (let ((rev (string-trim " " (subseq line 0 7)))
        (author (string-trim " " (subseq line 8 16)))
        (size (string-trim " " (subseq line 17 27)))
        (time (subseq line 28 40))
        (name (subseq line 41)))
    (values rev author size time name)))

(defun svn-dired-make-list-from-svnlist (buf)
  (interactive)
  (let (lst)
    (set-buffer buf)
    (goto-char (point-min))
    (while (/= (current-line-number)
              (save-excursion (goto-char (point-max)) (current-line-number)))
      (goto-bol)
      (multiple-value-bind (rev author size time name)
          (svn-dired-parse-line
             (buffer-substring (point) (progn (goto-eol) (point))))
        (push (list name author rev size time) lst))
      (forward-line 1))
    lst))

(defun svn-dired-output-list (lst)
  (let (output)
    (dolist (i (stable-sort lst #'string< :key #'car))
      (setq output
            (concat output 
                    (with-output-to-string (s)
                      (format s "~7A ~8A ~11A ~12A ~A\n"
                              (nth 2 i) (nth 1 i)
                              (nth 3 i) (nth 4 i)
                              (nth 0 i))))))
    ;;;
    ;;; このアイデアは不採用。親ディレクトリがない場合でも
    ;;; *svn-dired-up-dir*が出力されるけど、毎回毎回リポジトリに
    ;;; アクセスするよりはいいはず
    ;(when (svn-dired-check-repository
    ;         (progn
    ;           (when (string-match "\\(.+/\\)[^/]+/$" svn-repository-name)
    ;             (match-string 1)))))
      (setq output
            (format nil "~41A ~A\n~A"
                    (make-sequence 'string 41 :initial-element #\SPC)
                    *svn-dired-up-dir*
                    output))
    output))


#|
(let (res)
  (dolist (i (make-list-from-svnlist) res)
    (when (string= "" (nth 3 i))
      (push i res)))
  (set-buffer (get-buffer-create "make-list"))
  (insert (output-list res))
  (setq res nil)
  (dolist (i (make-list-from-svnlist) res)
    (unless (string= "" (nth 3 i))
      (push i res)))
  (set-buffer (get-buffer-create "make-list"))
  (insert (output-list res))
  )
|#
