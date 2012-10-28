;;; -*- MODE: Lisp; Package: EDITOR; -*-
;;;
;;; $HeadURL: file:///g:/repository/xyzzy/site-lisp/svn/release/0.0.2.0/svn-parse.l $
;;;
;;; $LastChangedDate: 2005-07-06 22:40:40 +0900 (Wed, 06 Jul 2005) $
;;;
;;; $LastChangedRevision: 175 $
;;;
;;; LKPTeam <ykaltenative@mue.biglobe.ne.jp>
;;;

;;;
;;; code
;;;

;; condition column color
(defvar *svn-parse-modified-color*    '(:keyword 1 :bold))
(defvar *svn-parse-add-color*         '(:keyword 2 :bold))
(defvar *svn-parse-delete-color*      '(:keyword 1 :line))
(defvar *svn-parse-conflict-color*    '(:keyword 1 :bold))
(defvar *svn-parse-ignored-color*     '(:keyword 0 :bold))
(defvar *svn-parse-no-version-color*  '(:color 10 0 :line))
(defvar *svn-parse-losted-item-color* '(:keyword 2 :bold))
(defvar *svn-parse-rep-item-color*    '(:keyword 2 :bold))
(defvar *svn-parse-rel-ext-def-color* '(:keyword 0 :bold :underline))
(defvar *svn-parse-old-color*         '(:color 1 0 :bold :line))
(defvar *svn-parse-locked-color*      '(:keyword 1 :bold))

;; file/direcotry column color
;; format
;;  '(TAG FOREGROUND BACKGROUND BOLD UNDERLINE STRIKE-OUT)
;; TAG        => 必須
;; FOREGROUND => 必須。色番号、またはnil
;; BACKGROUND => 色番号、またはnil(省略可)
;; BOLD       => t または nil(省略可)
;; UNDERLINE  => t または nil(省略可)
;; STRIKE-OUT => t または nil(省略可)
;;
;; FOREGROUNDを省略して、BACKGROUNDを指定する、というのは不可。
;; その場合はFOREGROUNDにnilを指定すること。順番大事。これ重要。
;;
(defvar *svn-parse-file-modified-color* '('modified 1 nil t))
(defvar *svn-parse-file-add-color*      '('add 2 nil t))
(defvar *svn-parse-file-conflict-color* '('conflict 6 nil t))
(defvar *svn-parse-file-ignored-color*  '('ignored 0 nil nil nil t))
(defvar *svn-parse-file-losted-color*   '('losted 10 nil t))
(defvar *svn-parse-file-locked-color*   '('locked 1 nil t))
(defvar *svn-parse-file-switched-color* '('switched 2 nil t))

(defvar *svn-status-1st-column-type*
  '((#\A . "ADD")
    (#\D . "DELETE")
    (#\M . "MODIFIED")
    (#\C . "CONFLICT")
    (#\I . "IGNORED")
    (#\? . "NO_VERSION")
    (#\! . "LOSTED_ITEM")
    (#\~ . "REP_ITEM")
    (#\X . "REL_EXT_DEF")
    (#\  . "NORMAL")))

(defvar *svn-status-2nd-column-type*
  '((#\  . "NORMAL")
    (#\M . "MODIFIED")
    (#\C . "CONFLICT")))

(defvar *svn-status-3rd-column-type*
  '((#\  . "NORMAL")
    (#\L . "LOCKED")))

(defvar *svn-status-4th-column-type*
  '((#\  . "NONE")
    (#\+ . "SCHED")))

(defvar *svn-status-5th-column-type*
  '((#\  . "NONE")
    (#\S . "SWIT")))

(defvar *svn-status-6th-column-type*
  '((#\  . nil)
    (#\K . t)
    (#\O . t)))

;;; using '--show-updates'
(defvar *svn-status-8th-column-type*
  '((#\  . "LATEST")
    (#\* . "OLD")))

(defmacro svn-parse-first-column-type (sequence)
  `(let ((type (character (schar ,sequence 0))))
     (cdr (assoc type *svn-status-1st-column-type* :test 'eql))))

(defmacro svn-parse-second-column-type (sequence)
  `(let ((type (character (schar ,sequence 1))))
     (cdr (assoc type *svn-status-2nd-column-type* :test 'eql))))

(defmacro svn-parse-third-column-type (sequence)
  `(let ((type (character (schar ,sequence 2))))
     (cdr (assoc type *svn-status-3rd-column-type* :test 'eql))))

(defmacro svn-parse-fourth-column-type (sequence)
  `(let ((type (character (schar ,sequence 3))))
     (cdr (assoc type *svn-status-4th-column-type* :test 'eql))))

(defmacro svn-parse-fifth-column-type (sequence)
  `(let ((type (character (schar ,sequence 4))))
     (cdr (assoc type *svn-status-5th-column-type* :test 'eql))))

(defmacro svn-parse-sixth-column-type (sequence)
  `(let ((type (character (schar ,sequence 5))))
     (cdr (assoc type *svn-status-6th-column-type* :test 'eql))))

(defmacro svn-parse-eighth-column-type (sequence)
  `(let ((type (character (schar ,sequence 7))))
     (cdr (assoc type *svn-status-8th-column-type* :test 'eql))))

(defvar *svn-status-normal-regexp*
  (compile-regexp "^\\(.......\\)\\(.+\\)$"))

(defvar *svn-status-su-regexp*
  (compile-regexp "^\\(........\\)\\([ ]+[0-9]+\\)?\\(.+\\)$"))

(defvar *svn-status-ext-regexp*
  (compile-regexp "^\\(........\\)\\([ ]+[0-9]+\\)?\\([ ]+[0-9?]+\\)?\\(.+\\)$"))

(defvar *svn-status-regexp-keyword-list* nil)
(unless *svn-status-regexp-keyword-list*
  (setq *svn-status-regexp-keyword-list*
    (compile-regexp-keyword-list
     `(
         ("MODIFIED"    nil ,*svn-parse-modified-color*    nil)
         ("ADD"         nil ,*svn-parse-add-color*         nil)
         ("DELETE"      nil ,*svn-parse-delete-color*      nil)
         ("CONFLICT"    nil ,*svn-parse-conflict-color*    nil)
         ("IGNORED"     nil ,*svn-parse-ignored-color*     nil)
         ("NO_VERSION"  nil ,*svn-parse-no-version-color*  nil)
         ("LOSTED_ITEM" nil ,*svn-parse-losted-item-color* nil)
         ("REP_ITEM"    nil ,*svn-parse-rep-item-color*    nil)
         ("REL_EXT_DEF" nil ,*svn-parse-rel-ext-def-color* nil)
         ("OLD"         nil ,*svn-parse-old-color*         nil)
         ("\\[K\\]"      nil ,*svn-parse-locked-color*      nil)
         ))))

(defun svn-get-regexp-pattern ()
  "return to compiled regular expression, and regexp-type:ext, normal, su"
  (let ((opt-list (get-enable-option-list)))
    (cond
       ((and (assoc
                "--show-updates" opt-list
                :test 'string= :key #'safe-car)
             (assoc
                "--verbose" opt-list
                :test 'string= :key #'safe-car))
        (values *svn-status-ext-regexp* "ext"))
       ((assoc
           "--show-updates" opt-list
           :test 'string= :key #'safe-car)
        (values *svn-status-su-regexp* "su"))
       ((assoc
           "--verbose" opt-list
           :test 'string= :key #'safe-car)
        (return-from svn-get-regexp-pattern
          (values *svn-status-ext-regexp* "ext")))
       (t (values *svn-status-normal-regexp* "normal"))
       )))
  
(defun svn-parse-status ()
  (interactive)
  (let (start end pattern type)
    (multiple-value-setq (pattern type)
      (svn-get-regexp-pattern))
    (set-buffer *svn-output-buffer*)
    (save-excursion
      (while (not (save-excursion (progn (goto-eol) (eobp))))
        (goto-bol)
        (setq start (point))
        (save-excursion
          (goto-eol)
          (setq end (point)))
        (save-excursion
          (save-restriction
            (narrow-to-region start end)
            (when (scan-buffer "状態の背景となるリビジョン:")
              (delete-region 0 (save-excursion
                               (goto-eol) (point))))
            (when (scan-buffer pattern
                               :no-dup nil :case-fold t
                               :regexp t)
              (svn-parse-status-1 (match-data) type)
              )))
        (forward-line 1))
      (goto-char (point-min))
      (cond
         ((string= type "normal")
          (insert "  CONDITION PROPERTY LOCK-C  SCHE SW-C  FILE/DIR\n")
          (insert "-----------------------------------------------\n"))
         ((string= type "ext")
          (insert "  CONDITION PROPERTY LOCK-C  SCHE SW-C LATEST   Rev/Last  AUTHOR     FILE/DIR\n")
          (insert "--------------------------------------------------------------------------------\n"))
         ((string= type "su")
          (insert "  CONDITION PROPERTY LOCK-C  SCHE SW-C LATEST   Rev   FILE/DIR\n")
          (insert "---------------------------------------------------------------\n"))
         )
      
      (make-local-variable 'regexp-keyword-list)
      (setq regexp-keyword-list *svn-status-regexp-keyword-list*)
      (while (not (save-excursion (progn (goto-eol) (eobp))))
        (setq start (point))
        (save-excursion
          (goto-eol)
          (setq end (point)))
        (save-excursion
          (save-restriction
            (narrow-to-region start end)
            (goto-bol)
            (cond
               ((scan-buffer "MODIFIED" :no-dup nil)
                (svn-set-color *svn-parse-file-modified-color*))
               ((scan-buffer "ADD" :no-dup nil)
                (svn-set-color *svn-parse-file-add-color*))
               ((scan-buffer "CONFLICT" :no-dup nil)
                (svn-set-color *svn-parse-file-conflict-color*))
               ((scan-buffer "IGNORED" :no-dup nil)
                (svn-set-color *svn-parse-file-ignored-color*))
               ((scan-buffer "LOSTED_ITEM" :no-dup nil)
                (svn-set-color *svn-parse-file-losted-color*))
               ((scan-buffer "LOCKED" :no-dup nil)
                (svn-set-color *svn-parse-file-locked-color*))
               ((scan-buffer "SWIT" :no-dup nil)
                (svn-set-color *svn-parse-file-switched-color*))
               )
            ))
        (forward-line 1))
      (set-buffer-modified-p nil)
      )))

(defmacro svn-set-color (optlist)
  `(let (fs fe tag fg bg bold underline strike-out)
     (setq tag (nth 0 ,optlist))
     (setq fg (nth 1 ,optlist))
     (setq bg (nth 2 ,optlist))
     (setq bold (nth 3 ,optlist))
     (setq underline (nth 4 ,optlist))
     (setq strike-out (nth 5 ,optlist))
     (save-excursion
       (goto-eol)
       (skip-chars-backward " \t")
       (setq fe (point))
       (skip-syntax-spec-backward "w_.")
       (setq fs (point))
       (set-text-attribute
          fs fe tag
          :foreground (if fg fg  0)
          :background (if bg bg 0)
          :bold (if bold t nil)
          :underline (if underline t nil)
          :strike-out (if strike-out t nil)))))

(defun svn-parse-status-1 (regdata type)
  (interactive)
  (let ((pattern (store-match-data regdata)))
    (cond
       ((string= type "normal")
        (let (column 1st file)
          (setq 1st (match-string 1))
          (setq file (string-trim " \t" (match-string 2)))
          (setq column
          (with-output-to-string (s)
            (format s "~11A " (svn-parse-first-column-type 1st))
            (format s "~8A " (svn-parse-second-column-type 1st))
            (format s "~6A " (svn-parse-third-column-type 1st))
            (format s "~5A " (svn-parse-fourth-column-type 1st))
            (format s "~4A " (svn-parse-fifth-column-type 1st))
            ))
          (unless (and
                     (scan-buffer "against revision:")
                     (scan-buffer "状態の背景となるリビジョン:"))
            (delete-region 0 (save-excursion
                               (goto-eol) (point)))
            (setq column (format nil "~A ~A" column
                                 (if (svn-parse-sixth-column-type 1st)
                                     (concat "[K]" file)
                                   file)))
            (insert column))
          ))
       ((string= type "ext")
        (let (column 1st 2nd 3rd seq author file line)
          (setq 1st (match-string 1))
          (setq 2nd (string-trim " \t" (match-string 2)))
          (setq 3rd (string-trim " \t" (match-string 3)))
          (setq line (string-trim " \t" (match-string 0)))
          (setq seq (reverse (match-string 4)))
          (when (string-match "^svn:.+is not under version control" line)
            (return-from svn-parse-status-1 nil))
          (when (string-match " " seq)
            (setq file (string-trim " " (reverse (subseq seq 0 (match-beginning 0)))))
            (setq author
                  (string-trim " "
                     (reverse (subseq seq (1+ (match-beginning 0)))))))
          (when (< 10 (length author))
            (setq author (format nil "~A~~" (subseq author 0 9))))
          (unless author
            (setq author (make-sequence 'string 10 :initial-element #\SPC)))
          (setq column
          (with-output-to-string (s)
            (format s "~11A " (svn-parse-first-column-type 1st))
            (format s "~8A " (svn-parse-second-column-type 1st))
            (format s "~6A " (svn-parse-third-column-type 1st))
            (format s "~5A " (svn-parse-fourth-column-type 1st))
            (format s "~4A " (svn-parse-fifth-column-type 1st))
            (format s "~6A" (if (svn-use-option-p "--show-updates")
                                (svn-parse-eighth-column-type 1st)
                              "------"))
            ))
          (unless (and
                     (scan-buffer "against revision:")
                     (scan-buffer "状態の背景となるリビジョン:"))
            (delete-region 0 (save-excursion
                               (goto-eol) (point)))
            (setq column (format nil "~A ~5A/~5@A ~10@A ~A"
                                 column 2nd 3rd author
                                 (if (svn-parse-sixth-column-type 1st)
                                     (concat "[K]" file)
                                   file)))
            (insert column))
          ))
       ((string= type "su")
        (let (column 1st 2nd file line)
          (setq 1st (match-string 1))
          (setq 2nd (string-trim " \t" (match-string 2)))
          (setq file (string-trim " \t" (match-string 3)))
          (setq line (string-trim " \t" (match-string 0)))
          (when (string-match "^svn:.+is not under version control" line)
            (return-from svn-parse-status-1 nil))          
          (setq column
          (with-output-to-string (s)
            (format s "~11A " (svn-parse-first-column-type 1st))
            (format s "~8A " (svn-parse-second-column-type 1st))
            (format s "~6A " (svn-parse-third-column-type 1st))
            (format s "~5A " (svn-parse-fourth-column-type 1st))
            (format s "~4A " (svn-parse-fifth-column-type 1st))
            (format s "~6A" (svn-parse-eighth-column-type 1st))
            ))
          (unless (and
                     (scan-buffer "against revision:")
                     (scan-buffer "状態の背景となるリビジョン:"))
            (delete-region 0 (save-excursion
                               (goto-eol) (point)))
            (setq column (format nil "~A ~5A   ~A"
                                 column 2nd
                                 (if (svn-parse-sixth-column-type 1st)
                                     (concat "[K]" file)
                                   file)))
            (insert column))
          ))
       (t nil)
       )))
