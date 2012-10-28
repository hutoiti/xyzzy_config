;;; -*- MODE: Lisp; Package: EDITOR; -*-
;;;
;;; svn-misc.l
;;;
;;; $HeadURL: file:///g:/repository/xyzzy/site-lisp/svn/release/0.0.2.0/svn-misc.l $
;;;
;;; $LastChangedDate: 2005-07-07 00:09:00 +0900 (Thu, 07 Jul 2005) $
;;;
;;; $LastChangedRevision: 178 $
;;;
;;; LKPTeam <ykaltenative@mue.biglobe.ne.jp>
;;;

;;;
;;; code
;;;

(defvar
   *svn-options*
   '(
     ("--auto-props")
     ("--config-dir")                   
     ("--diff-cmd")
     ("--diff3-cmd")
     ("--dry-run")
     ("--encoding")
     (("--extensions" "-x"))
     (("--file" "-F"))
     ("--force")
     ("--force-log")
     (("--help" "-h" "-?"))
     ("--ignore-ancestry")
     ("--ignore-externals")
     ("--incremental")
     ("--limit")
     (("--message" "-m"))
     ("--new")
     ("--no-auth-cache")
     ("--no-diff-deleted")
     ("--no-ignore")
     ("--non-interactive")
     (("--non-recursive" "-N"))
     ("--notice-ancestry")
     ("--old")
     ("--password")
     (("--quiet" "-q"))
     (("--recursive" "-R"))
     ("--relocate")
     (("--revision" "-r"))
     ("--revprop")
     (("--show-updates" "-u"))
     ("--stop-on-copy")
     ("--strict")
     ("--targets")
     ("--username")
     (("--verbose" "-v"))
     ("--version")
     ("--xml"))
   "オプションのリスト")

(defconstant *svn-subcommand-effective-option-list*
      '(("add" ("--targets" "--non-recursive" "-N" "--quiet" "-q" "--config-dir" "auto-props" "--no-auto-props"))
        ("blame" ("--revision" "-r" "--username" "--password" "--no-auth-cache" "--non-interactive" "--config-dir"))
        ("cat" ("--revision" "-r" "--username" "--password" "--no-auth-cache" "--non-interactive" "--config-dir"))
        ("checkout" ("--revision" "-r" "--quiet" "-q" "--non-recursive" "-N" "--username" "--password" "--no-auth-cache" "--non-interactive" "--config-dir" "--ignore-externals"))
        ("cleanup" ("--diff3-cmd" "--config-dir"))
        ("commit" ("--quiet" "-q" "--non-recursive" "-N" "--targets" "--force-log" "--username" "--password" "--no-auth-cache" "--non-interactive" "--encoding" "--config-dir" "--no-unlock"))
        ("copy" ("--revision" "-r" "--quiet" "-q" "--username" "--password" "--no-auth-cache" "--non-interactive" "--encoding" "--config-dir"))
        ("delete" ("--force" "--force-log" "--quiet" "--targets" "--username" "--password" "--no-auth-cache" "--non-interactive" "--encoding"))
        ("diff" ("--revision" "-r" "--old" "--new" "--extensions" "-x" "--non-recursive" "--diff-cmd" "--notice-ancestry" "--username" "--password" "--no-auth-cache" "--non-interactive" "--no-diff-deleted" "--config-dir" "--force"))
        ("export" ("--revision" "--r" "--quiet" "-q" "--force" "--username" "--password" "--no-auth-cache" "--non-interactive" "--force-log" "--encoding" "--config-dir" "--auto-props" "--no-auto-props" "--non-recursive"))
        ("help" ())
        ("import" ("--quiet" "-q" "--non-recursive" "-N" "--username" "--password" "--no-auth-cache" "--non-interactive" "--force-log" "--encoding" "--config-dir"))
        ("info" ("--targets" "--recursive" "-R" "--config-dir" "--revision" "-r"))
        ("list" ("--revision" "-r" "--verbose" "-v" "--recursive" "-R" "--username" "--password" "--no-auth-cache" "--non-interactive" "--config-dir" "--xml"))
        ("lock" ("--targets" "-m" "--message" "--force-log" "--encoding" "--username" "--password" "--no-auth-cache" "--non-interactive" "config-dir" "--force"))
        ("log" ("--revision" "-r" "--quiet" "-q" "--verbose" "-v" "--targets" "--stop-on-copy" "--incremental" "--xml" "--username" "--password" "--no-auth-cache" "--non-interactive" "--strict" "--config-dir" "--limit"))
        ("merge" ("--revision" "-r" "--non-recursive" "-N" "--quiet" "-q" "--force" "--dry-run" "--diff3-cmd" "--ignore-ancestry" "--username" "--password" "--no-auth-cache" "--non-interactive" "--config-dir"))
        ("mkdir" ("--quiet" "-N" "--username" "--password" "--no-auth-cache" "--non-interactive" "--encoding" "--force-log" "--config-dir"))
        ("move" ("--revision" "-r" "--quiet" "-q" "--force" "--username" "--password" "--no-auth-cache" "--non-interactive" "--encoding" "--force-log"))
        ("propdel" ("--quiet" "-q" "--recursive" "-R" "--revision" "-r" "--revprop" "--username" "--password" "--no-auth-cache" "--non-interactive" "--config-dir"))
        ("propedit" ("--revision" "-r" "--revprop" "--username" "--password" "--no-auth-cache" "--non-interactive" "--encoding" "--config-dir"))
        ("propget" ("--recursive" "-R" "--revision" "-r" "--revprop" "--strict" "--username" "--password" "--no-auth-cache" "--non-interactive" "--config-dir"))
        ("proplist" ("--verbose" "-v" "--recursive" "-R" "--revision" "-r" "--quiet" "-q" "--revprop" "--username" "--password" "--no-auth-cache" "--non-interactive" "--config-dir"))
        ("propset" ("--quiet" "-q" "--revision" "-r" "--targets" "--recursive" "-R" "--revprop" "--username" "--password" "--no-auth-cache" "--non-interactive" "--encoding" "--force" "--config-dir" "--force"))
        ("resolved" ("--targets" "--recursive" "-R" "--quiet" "--config-dir"))
        ("revert" ("--recursive" "-R" "--quiet" "-q" "--config-dir"))
        ("status" ("--show-updates" "-u" "--verbose" "-v" "--non-recursive" "-N" "--quiet" "-q" "--no-ignore" "--username" "--password" "--no-auth-cache" "--non-interactive" "--force-log" "config-dir" "--ignore-externals"))
        ("switch" ("--revision" "-r" "--non-recursive" "-N" "--quiet" "-q" "--diff-cmd" "--relocate" "--username" "--password" "--no-auth-cache" "--non-interactive" "--config-dir"))
        ("unlock" ("--targets" "--username" "--password" "--no-auth-cache" "--non-interactive" "--config-dir" "--force"))
        ("update" ("--revision" "-r" "--non-recursive" "-R" "--quiet" "-q" "--diff3-cmd" "--username" "--password" "--no-auth-cache" "--non-interactive" "--config-dir" "--ignore-externals")))
  "svnの各サブコマンドで有効なオプションリスト"
  )

(defun svn-unset-option (option-name)
  "svn コマンドのオプションを解除する"
  (interactive)
  (dolist (i *svn-options*)
    (if (prog1
            (listp (safe-car i))
          (setq option (safe-car i)))
        (progn ; list
          (when (find option-name option :test 'string=)
            (setf (cdr i) nil)))
      (when (string= option-name (safe-car i))
        (setf (cdr i) nil))))
  t)

(defun svn-set-option (option-name &optional val)
  "svn コマンドのオプションを設定する"
  (interactive)
  (let ((result nil)
        (value (or val t))
        option)
    (dolist (i *svn-options*)
      (if (prog1
              (listp (safe-car i))
            (setq option (safe-car i)))
          (progn ; list
            (when (find option-name option :test 'string=)
              (setf (cdr i) value)))
        (when (string= option-name (safe-car i))
          (setf (cdr i) value))))
    t))

(defun svn-list-options (opt-list)
  "オプションのリストopt-listをリストにして返す"
  (interactive)
  (let ((options opt-list) option result)
    (dolist (i options (reverse result))
      (if (prog1
              (listp (safe-car i))
            (setq option (safe-car i))
            )
          (when (not (null (safe-cdr i)))
            (push (format nil " ~A ~A" (safe-car option)
                          (if (equal 't (safe-cdr i))
                              ""
                            (format nil "\"~A\"" (safe-cdr i))))
                  result))
        (when (not (null (safe-cdr i)))
          (push (format nil " ~A ~A" (safe-car i)
                        (if (equal 't (safe-cdr i))
                            ""
                          (format nil "\"~A\"" (safe-cdr i))))
                result))))))

(defun get-enable-option-list ()
  "設定されているオプションから有効なオプションをA-LISTにして返す"
  (let (result)
    (dolist (i *svn-options* (reverse result))
      (when (safe-cdr i)
        (push i result)))))

(defun svn-get-effective-subcommand-options (subcmd)
  "現在設定されているオプションの中から、
指定されたサブコマンドで有効なオプションのリストを返す"
  (let (op-list)
    (setq op-list (cadr (assoc subcmd
                               *svn-subcommand-effective-option-list*
                               :test 'string=)))
    (intersection
       (mapcar #'(lambda (x) (if (safe-caar x) (safe-caar x) (car x)))
               (get-enable-option-list))
       op-list :test 'string=)))

(defun svn-get-commandline-option (subcmd)
  "現在設定されているオプションから
サブコマンドで有効なオプションのみを抜き出した
リストを返す
(svn-get-commandline-option \"add\")
=> (((\"--non-recursive\" \"-N\") . t))"
  (let (cmdline)
    (dolist (i (get-enable-option-list) cmdline)
      (dolist (opt (svn-get-effective-subcommand-options subcmd))
        (if (listp (safe-car i))
            (progn
              (when (string= opt (safe-caar i))
                (push i cmdline)))
          (when (string= opt (car i))
            (push i cmdline)))))))

(defmacro svn-get-opt (subcmd)
  `(apply 'concat (svn-list-options (svn-get-commandline-option ,subcmd))))


(defmacro svn-with-set-option ((option) &body body)
 `(progn
    (mapcar #'(lambda (x)
                (funcall 'svn-set-option (car x) (safe-cadr x)))
            ,option)
    ,@body
    (mapcar #'(lambda (x)
                (funcall 'svn-unset-option (car x)))
            ,option)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmacro svn-use-option-p (opt)
  `(if (assoc ,opt (get-enable-option-list)
              :test 'equal
              :key #'(lambda (x) (if (listp x) (safe-car x) x)))
       t nil))

(defun svn-toggle-option (opt)
  (interactive)
  (if (svn-use-option-p opt)
      (svn-unset-option opt)
    (svn-set-option opt)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun svn-toggle-auto-props ()
  (interactive)
  (if (svn-use-option-p "--auto-props")
      (svn-unset-option "--auto-props")
    (svn-set-option "--auto-props")))

(defun svn-toggle-dry-run ()
  (interactive)
  (if (svn-use-option-p "--dry-run")
      (svn-unset-option "--dry-run")
    (svn-set-option "--dry-run")))

(defun svn-toggle-force ()
  (interactive)
  (if (svn-use-option-p "--force")
      (svn-unset-option "--force")
    (svn-set-option "--force")))

(defun svn-toggle-force-log ()
  (interactive)
  (if (svn-use-option-p "--force-log")
      (svn-unset-option "--force-log")
    (svn-set-option "--force-log")))

(defun svn-toggle-ignore-ancestry ()
  (interactive)
  (if (svn-use-option-p "--ignore-ancestry")
      (svn-unset-option "--ignore-ancestry")
    (svn-set-option "--ignore-ancestry")))

(defun svn-toggle-incremental ()
  (interactive)
  (if (svn-use-option-p "--incremental")
      (svn-unset-option "--incremental")
    (svn-set-option "--incremental")))

(defun svn-toggle-auth-cache ()
  (interactive)
  (if (svn-use-option-p "--auth-cache")
      (svn-unset-option "--auth-cache")
    (svn-set-option "--auth-cache")))

(defun svn-toggle-no-diff-deleted ()
  (interactive)
  (if (svn-use-option-p "--no-diff-deleted")
      (svn-unset-option "--no-diff-deleted")
    (svn-set-option "--no-diff-deleted")))

(defun svn-toggle-non-interactive ()
  (interactive)
  (if (svn-use-option-p "--non-interactive")
      (svn-unset-option "--non-interactive")
    (svn-set-option "--non-interactive")))

(defun svn-toggle-non-recursive ()
  (interactive)
  (if (svn-use-option-p "--non-recursive")
      (svn-unset-option "--non-recursive")
    (svn-set-option "--non-recursive")))

(defun svn-toggle-notice-ancestry ()
  (interactive)
  (if (svn-use-option-p "--notice-ancestry")
      (svn-unset-option "--notice-ancestry")
    (svn-set-option "--notice-ancestry")))

(defun svn-toggle-quiet ()
  (interactive)
  (if (svn-use-option-p "--quiet")
      (svn-unset-option "--quiet")
    (svn-set-option "--quiet")))

(defun svn-toggle-recursive ()
  (interactive)
  (if (svn-use-option-p "--recursive")
      (svn-unset-option "--recursive")
    (svn-set-option "--recursive")))

(defun svn-toggle-relocate ()
  (interactive)
  (if (svn-use-option-p "--relocate")
      (svn-unset-option "--relocate")
    (svn-set-option "--relocate")))

(defun svn-toggle-revprop ()
  (interactive)
  (if (svn-use-option-p "--revprop")
      (svn-unset-option "--revprop")
    (svn-set-option "--revprop")))

(defun svn-toggle-show-updates ()
  (interactive)
  (if (svn-use-option-p "--show-updates")
      (svn-unset-option "--show-updates")
    (svn-set-option "--show-updates")))

(defun svn-toggle-stop-on-copy ()
  (interactive)
  (if (svn-use-option-p "--stop-on-copy")
      (svn-unset-option "--stop-on-copy")
    (svn-set-option "--stop-on-copy")))

(defun svn-toggle-no-ignore ()
  (interactive)
  (if (svn-use-option-p "--no-ignore")
      (svn-unset-option "--no-ignore")
    (svn-set-option "--no-ignore")))

(defun svn-toggle-strict ()
  (interactive)
  (if (svn-use-option-p "--strict")
      (svn-unset-option "--strict")
    (svn-set-option "--strict")))

(defun svn-toggle-xml ()
  (interactive)
  (if (svn-use-option-p "--xml")
      (svn-unset-option "--xml")
    (svn-set-option "--xml")))

(defun svn-toggle-verbose ()
  (interactive)
  (if (svn-use-option-p "--verbose")
      (svn-unset-option "--verbose")
    (svn-set-option "--verbose")))

(defun svn-toggle-no-unlock ()
  (interactive)
  (if (svn-use-option-p "--no-unlock")
      (svn-unset-option "--no-unlock")
    (svn-set-option "--no-unlock")))

(defun svn-check-revert-status (&optional buf)
  (let ((buffer (or buf (selected-buffer)))
        status)
    (set-buffer buffer)
    (setq status (if (string= "" *status*) nil (character *status*)))
    (case status
      (#\* t)
      (#\* t)
      (#\+ t)
      (nil nil)
      (#\- nil))))
      
(defun svn-local-menu ()
  (let ((menu (create-menu nil))
        (lmenu (copy-menu-items *app-menu* (create-menu)))
        )
    (setq menu
 (define-menu
   (:popup 'svn-switch "Switches"
    (:item :tag-command "Auto props" 'svn-toggle-auto-props
     #'(lambda () (if (svn-use-option-p "--auto-props") :check t)))
    (:item :tag-command "Dry run" 'svn-toggle-dry-run
     #'(lambda () (if (svn-use-option-p "--dry-run") :check t)))
    (:item :tag-command "Force" 'svn-toggle-force
     #'(lambda () (if (svn-use-option-p "--force") :check t)))
    (:item :tag-command "Force log" 'svn-toggle-force-log
     #'(lambda () (if (svn-use-option-p "--force-log") :check t)))
    (:item :tag-command "Ignore ancestry" 'svn-toggle-ignore-ancestry
     #'(lambda () (if (svn-use-option-p "--ignore-ancestry") :check t)))
    (:item :tag-command "Notice ancestry" 'svn-toggle-notice-ancestry
     #'(lambda () (if (svn-use-option-p "--notice-ancestry") :check t)))
    (:item :tag-command "Incremental" 'svn-toggle-incremental
     #'(lambda () (if (svn-use-option-p "--incremental") :check t)))
    (:item :tag-command "Auth-cache" 'svn-toggle-auth-cache
     #'(lambda () (if (svn-use-option-p "--auth-cache") :check t)))
    (:item :tag-command "No diff deleted" 'svn-toggle-no-diff-deleted
     #'(lambda () (if (svn-use-option-p "--no-diff-deleted") :check t)))
    (:item :tag-command "Non interactive" 'svn-toggle-non-interactive
     #'(lambda () (if (svn-use-option-p "--non-interactive") :check t)))
    (:item :tag-command "Non recursive" 'svn-toggle-non-recursive
     #'(lambda () (if (svn-use-option-p "--non-recursive") :check t)))
    (:item :tag-command "Quiet" 'svn-toggle-quiet
     #'(lambda () (if (svn-use-option-p "--quiet") :check t)))
    (:item :tag-command "Recursive" 'svn-toggle-recursive
     #'(lambda () (if (svn-use-option-p "--recursive") :check t)))
    (:item :tag-command "Relocate" 'svn-toggle-relocate
     #'(lambda () (if (svn-use-option-p "--relocate") :check t)))
    (:item :tag-command "Revprop" 'svn-toggle-revprop
     #'(lambda () (if (svn-use-option-p "--revprop") :check t)))
    (:item :tag-command "Stop on copy" 'svn-toggle-stop-on-copy
     #'(lambda () (if (svn-use-option-p "--stop-on-copy") :check t)))
    (:item :tag-command "No unlock" 'svn-toggle-no-unlock
     #'(lambda () (if (svn-use-option-p "--no-unlock") :check t)))
    (:item :tag-command "Strict" 'svn-toggle-strict
     #'(lambda () (if (svn-use-option-p "--strict") :check t)))
    (:sep)
    (:item :tag-command "XML" 'svn-toggle-xml
     #'(lambda () (if (svn-use-option-p "--xml") :check t)))
    (:item :tag-command "Show updates" 'svn-toggle-show-updates
     #'(lambda () (if (svn-use-option-p "--show-updates") :check t)))
    (:item :tag-command "No ignore" 'svn-toggle-no-ignore
     #'(lambda () (if (svn-use-option-p "--no-ignore") :check t)))
    (:item :tag-command "Verbose" 'svn-toggle-verbose
     #'(lambda () (if (svn-use-option-p "--verbose") :check t)))
    )
   (:sep)
   (:item :tag-command "status(file)" 'svn-status-file
    #'(lambda () (if (boundp '*revision*) *revision* :disable)))
   (:item :tag-command "status(directory)" 'svn-status-directory
    #'(lambda () (if (boundp '*revision*) *revision* :disable)))
   (:sep)
   (:item :tag-command "commit" 'svn-commit
    #'(lambda () (if (string-equal "-" *status*) :disable t)))
   (:sep)
   (:item :tag-command "log" 'svn-log-file
    #'(lambda () (if (string-equal "-" *status*) :disable t)))
   (:item :tag-command "diff" 'svn-diff
    #'(lambda () (if (string-equal "-" *status*) :disable t)))
   (:item :tag-command "update" 'svn-update
    #'(lambda () (if (string-equal "-" *status*) :disable t)))
   (:sep)
   (:popup 'svn-information "informations"
    (:item :tag-command "cat"
     #'(lambda ()
         (interactive)
         (let ((rev (read-string "Revision: " :default *revision*)))
           (svn-cat nil rev)))
     #'(lambda ()
         (if (string-equal "-" *status*) :disable t)))
    (:item :tag-command "info" 'svn-info
     #'(lambda () (if (string-equal "-" *status*) :disable t)))
    (:item :tag-command "blame" 'svn-blame
     #'(lambda () (if (string-equal "-" *status*) :disable t)))
    (:item :tag-command "list" 'svn-list
     #'(lambda () (if (boundp '*revision*) *revision* :disable)))
    )
   (:sep)
   (:popup 'svn-operation "Operations"
    (:item :tag-command "add" 'svn-add
     #'(lambda () (if (string-equal "-" *status*) t :disable)))
    (:item :tag-command "delete" 'svn-delete
     #'(lambda () (if (string-equal "-" *status*) :disable t)))
    (:item :tag-command "copy" 'svn-copy
     #'(lambda () (if (string-equal "-" *status*) :disable t)))
    (:item :tag-command "move" 'svn-move
     #'(lambda () (if (boundp '*revision*) *revision* :disable)))
    (:item :tag-command "mkdir" 'svn-mkdir
     #'(lambda () (if (boundp '*revision*) *revision* :disable)))
    )
   (:item :tag-command "cleanup" 'svn-cleanup
    #'(lambda () (if (string-equal "-" *status*) :disable t)))
   (:item :tag-command "resolved" 'svn-resolved
    #'(lambda () (if (string-equal "-" *status*) :disable t)))
   (:item :tag-command "revert[file]" 'svn-revert-file
    #'(lambda () (if (not (svn-check-revert-status)) :disable t)))
   (:item :tag-command "revert[dir]" 'svn-revert-directory
    #'(lambda () (if (string-equal "-" *status*) :disable t)))
   (:sep)
   (:popup 'svn-etc "Etc"
    (:item :tag-command "checkout" 'svn-checkout
     #'(lambda () (if (string-equal "-" *status*) :disable t)))
    (:item :tag-command "export" 'svn-export
     #'(lambda () (if (string-equal "-" *status*) :disable t)))
    (:item :tag-command "import" 'svn-import
     #'(lambda () (if (boundp '*revision*) *revision* :disable)))
    )
   (:sep)
   (:popup 'svn-property "Properties"
    (:item :tag-command "propdel" 'svn-propdel
     #'(lambda () (if (string-equal "-" *status*) :disable t)))
    (:item :tag-command "propedit" 'svn-propedit
     #'(lambda () (if (string-equal "-" *status*) :disable t)))
    (:item :tag-command "propget" 'svn-propget
     #'(lambda () (if (string-equal "-" *status*) :disable t)))
    (:item :tag-command "proplist" 'svn-proplist
     #'(lambda () (if (string-equal "-" *status*) :disable t)))
    (:item :tag-command "propset" 'svn-propset
     #'(lambda () (if (string-equal "-" *status*) :disable t)))
    )
   (:sep)
   (:item :tag-command "help" 'svn-help)
   (:sep)
   (:item :tag-command *svn-mode-version* #'(lambda () (interactive) (msgbox "~A\n~TLKPTeam <ykaltenative@mue.biglobe.ne.jp>" *svn-mode-version*)) t)
   ))
    (insert-popup-menu lmenu (get-menu-position lmenu 'ed::help) menu "SVN")
    (use-local-menu lmenu)
    t))

(defun svn-enable-tool-bar ()
  (cond ((null *svn-mode*) :disable)
        (t t)))

(defun svn-tool-bar ()
  (create-tool-bar
     'svn-tool-bar
     (merge-pathnames "site-lisp/svn/svn-toolbar.bmp" (si:system-root))
     '(("Checkin" 7 svn-checkin svn-enable-tool-bar)
       ("Checkout" 6 svn-checkout)
       :sep
       ("Status" 2 svn-status-file svn-enable-tool-bar)
       ("Log" 3 svn-log-file svn-enable-tool-bar)
       ("Update" 18 svn-update svn-enable-tool-bar)
;       ("Cat" 4 svn-cat svn-enable-tool-bar)
       :sep
       ("Add" 8 svn-add-file svn-enable-tool-bar)
       ("Delete" 9 svn-delete svn-enable-tool-bar)
;       ("Move" 12 svn-mode svn-enable-tool-bar)
;       ("Copy" 13 svn-copy svn-enable-tool-bar)
       :sep
       ("diff" 5 svn-diff svn-enable-tool-bar)
       :sep
;       ("Import" 15 svn-import)
;       ("Export" 14 svn-export)
       )))

(define-command-bar 'svn-tool-bar "SVN(&S)")

