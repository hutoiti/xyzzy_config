;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: ruby.l,v 1.1.1.1 2005/11/25 13:06:17 torihat Exp $
;
; ruby-mode for xyzzy
;
; by HATTORI Masashi

(provide "ruby")

(in-package "editor")

(export '(ruby-mode
	  *ruby-prog*
	  *ruby-keyword-file* *ruby-mode-hook*
	  *ruby-mode-syntax-table* *ruby-mode-map*
	  *ruby-mode-abbrev-table* *ruby-block-beg-re*
	  *ruby-indent-beg-re* *ruby-modifier-re*
	  *ruby-block-mid-re* *ruby-block-op-re*
	  *ruby-indent-column* *ruby-block-end-re*))

(defvar *ruby-prog* "ruby")

(defvar *ruby-mode-hook* nil)
(defvar *ruby-comment-column* nil)

(defvar *ruby-keyword-hash-table* nil)
(defvar *ruby-keyword-file* "Ruby")
(defvar *ruby-completion-list* nil)

;;ruby-mode.elより
(defvar *ruby-block-beg-re*
  "class\\|module\\|def\\|if\\|unless\\|case\\|while\\|until\\|for\\|begin\\|do")

(defvar *ruby-modifier-re*
  "\\(if\\|unless\\|while\\|until\\)")

(defvar *ruby-block-mid-re*
  "then\\|else\\|elsif\\|when\\|rescue\\|ensure")

(defvar *ruby-block-op-re*
  "and\\|or\\|not")

(defvar *ruby-block-end-re* "end")

(defvar *ruby-indent-column* 2
  "インデントで入れるスペースの数（で、いいのかな？）")

(defvar *ruby-mode-syntax-table* nil)
(unless *ruby-mode-syntax-table*
  (setq *ruby-mode-syntax-table* (make-syntax-table))
  (do ((x #x21 (1+ x)))
      ((>= x #x7f))
    (let ((c (code-char x)))
      (unless (alphanumericp c)
	(set-syntax-punctuation *ruby-mode-syntax-table* c)))
  )
  (set-syntax-string *ruby-mode-syntax-table* #\")
  (set-syntax-string *ruby-mode-syntax-table* #\')
  (set-syntax-escape *ruby-mode-syntax-table* #\\)
  (set-syntax-symbol *ruby-mode-syntax-table* #\_)
  (set-syntax-symbol *ruby-mode-syntax-table* #\?)
  (set-syntax-symbol *ruby-mode-syntax-table* #\=)
  (set-syntax-symbol-prefix *ruby-mode-syntax-table* #\$)
  (set-syntax-match *ruby-mode-syntax-table* #\( #\))
  (set-syntax-match *ruby-mode-syntax-table* #\{ #\})
  (set-syntax-match *ruby-mode-syntax-table* #\[ #\])
  (set-syntax-start-comment *ruby-mode-syntax-table* #\# t)
  (set-syntax-end-comment *ruby-mode-syntax-table* #\LFD nil t)
)

(defvar *ruby-mode-map* nil)
(unless *ruby-mode-map*
  (setq *ruby-mode-map* (make-sparse-keymap))
  (define-key *ruby-mode-map* #\{ 'ruby-electric-insert)
  (define-key *ruby-mode-map* #\: 'ruby-electric-insert)
  (define-key *ruby-mode-map* #\F1 'ruby-info-index)
  ;  (define-key *ruby-mode-map* #\# 'c-electric-insert)
  (define-key *ruby-mode-map* #\} 'ruby-electric-close)
  (define-key *ruby-mode-map* #\C-h 'backward-delete-char-untabify-or-selection)
  (define-key *ruby-mode-map* #\TAB 'ruby-indent-line)
  (define-key *ruby-mode-map* #\M-TAB 'ruby-completion)
  (define-key *ruby-mode-map* #\C-M-q 'c-indent-exp)
  (define-key *ruby-mode-map* #\RET 'ruby-newline-and-indent)
  (define-key *ruby-mode-map* '(#\C-c #\l) 'list-function)
)

(defvar *ruby-mode-abbrev-table* nil)
(unless *ruby-mode-abbrev-table*
  (define-abbrev-table '*ruby-mode-abbrev-table*))

(defun ruby-newline-and-indent (&optional (arg 1))
  (interactive "*p")
  (delete-trailing-spaces)
  (insert #\LFD arg)
  (ruby-indent-line))

(defun ruby-electric-insert (&optional (arg 1))
  (interactive "*p")
  (self-insert-command arg)
  (ruby-indent-line))

(defun ruby-electric-close (&optional (arg 1))
  (interactive "*p")
  (self-insert-command arg)
  (ruby-indent-line)
  (save-excursion
    (forward-char -1)
    (and (goto-matched-parenthesis)
	 (show-matched-parenthesis)))
  t)

; c-indent-lineから
(defun ruby-indent-line ()
  (interactive "*")
  (if (or (not (interactive-p))
	  *c-tab-always-indent*
	  (save-excursion
	    (skip-chars-backward " \t")
	    (bolp)))
      ; ここを変えただけ
      (let ((column (calc-ruby-indent)))
	(when (integerp column)
	  (save-excursion
	    (goto-bol)
	    (delete-region (point)
			   (progn
			     (skip-chars-forward " \t")
			     (point)))
	    (indent-to column)))
	(if (and (bolp) column)
	    (skip-chars-forward " \t")))
    (insert "\t"))
  t)

(defun ruby-previous-line ()
  "空行じゃない行まで戻る"
  (while (forward-line -1)
    ;(message-box (format nil "=> ~D" (current-line-number)))
    (unless (ruby-space-line)
      (if (looking-at "=end"); =begin ... =end を飛ばす
	  (while (forward-line -1)
	    (when (looking-at "=begin")
	      ;(message-box (format nil "==> ~D" (current-line-number)))
	      (forward-line -1)
	      (return)))
	(return-from ruby-previous-line t)))))

(defun ruby-space-line ()
  "空行かどうか（ってこうやって調べるものなのか？）"
  (save-excursion
    (goto-bol)
    (looking-at "[ \t]*$")))

(defun calc-ruby-indent ()
  "インデントする数を数える"
  (let ((column 0) (curp (point)))
    (save-excursion
      ;前の行を調べる
      (when (ruby-previous-line)
	(goto-bol)
	(skip-chars-forward " \t")
	; インデント数
	(setq column (current-column))
	;(message-box (format nil "column1: ~D" column))
	(save-restriction
	  (narrow-to-region (progn (goto-eol) (point))
			    (progn (goto-bol) (point)))
	  (skip-chars-forward " \t")
	  ; 開きものがあればインデント数を増やす
	  (cond
	   ((looking-at *ruby-block-beg-re*)
	    (setq column (+ column *ruby-indent-column*)))
	   ((looking-at *ruby-block-mid-re*)
	    (setq column (+ column *ruby-indent-column*)))
	   ((scan-buffer "\\<do\\>" :regexp t)
	    (setq column (+ column *ruby-indent-column*)))
	   ((and (scan-buffer "\{" :regexp t) (not (scan-buffer "\}" :regexp t)))
	    (setq column (+ column *ruby-indent-column*)))
	   ((and (scan-buffer "\(" :regexp t) (not (scan-buffer "\)" :regexp t)))
	    (setq column (+ column *ruby-indent-column*)))
	  )
	)))
    ;(message-box (format nil "column2: ~D" column))
    ; 現在の行を調べる
    (save-excursion
      (save-restriction
	(narrow-to-region (progn (goto-eol) (point))
			  (progn (goto-bol) (point)))
	(goto-bol)
	(skip-chars-forward " \t")
	; 閉じものがあればインデント数を減らす
	(cond
	 ((looking-at "^=\\(begin\\|end\\)")
	  (setq column 0))
	 ((looking-at "\}")
	  (setq column (- column *ruby-indent-column*)))
	 ((looking-at "\)")
	  (setq column (- column *ruby-indent-column*)))
	 ((looking-at *ruby-block-end-re*)
	  (setq column (- column *ruby-indent-column*)))
	 ((looking-at *ruby-block-mid-re*)
	  (setq column (- column *ruby-indent-column*)))
	)))
    column
  ))

(defun ruby-completion ()
  "キーワードから補完"
  (interactive)
  (or *ruby-completion-list*
      (setq *ruby-completion-list* (make-list-from-keyword-table *ruby-keyword-hash-table*))
      (return-from ruby-completion nil))
  (let ((opoint (point)))
    (when (skip-syntax-spec-backward "w_")
      (let ((from (point)))
	(goto-char opoint)
	(do-completion from opoint :list *ruby-completion-list*)))))

(defun ruby-info-index ()
  "info.lのREADMEから"
  (interactive)
  (let (beg end)
     (save-excursion
      (setq end (prog2 (skip-syntax-spec-forward "w_j") (point)))
      (setq beg (prog2 (skip-syntax-spec-backward "w_j") (point))))
    (unless (= beg end)
      (let ((index-command (buffer-substring beg end)))
	(info "ruby-jp")
	(ed::info-index index-command)))))

(defun tags-find-ruby-point (class name functionp point)
  "タグジャンプ"
  (goto-char (- point *jump-tag-limit*))
  (and (scan-buffer (concat "^[ \t]*\\(def\\|class\\|module\\|attr\\)[ \t]+"
			    (regexp-quote name)
			    "\\($\\|[ \t\r\n\f#]\\)")
		    :regexp t :limit (+ point *jump-tag-limit*))
       (point)))

(defun ruby-comment-start-skip ()
  "コメントが既にあるかどうか"
  (let ((eol (save-excursion (goto-eol) (point))))
    (while (scan-buffer "\\(^\\|[ \t]\\)\\(#+\\)[ \t]*"
			:regexp t :limit eol :tail t)
      (unless (eq (parse-point-syntax (match-end 2)) :string)
	(goto-char (match-beginning 2))
	(return-from ruby-comment-start-skip (match-end 0)))))
  (goto-eol)
  nil)

(defun ruby-comment-indent ()
  "コメント用インデントコマンド"
  (generic-comment-indent "#" #'calc-ruby-indent))

(defun ruby-build-summary-of-functions ()
  "関数一覧表示"
  (let ((result nil))
    (save-excursion
      (goto-char (point-min))
      (while (scan-buffer "^[ \t]*\\(def\\|class\\|module\\)[ \t]+\\([^ \t\n{(]+\\)"
			  :regexp t :tail t)
	(push (list (current-line-number) (match-string 2)) result)))
    (nreverse result)))

(defun ruby-mode ()
  (interactive)
  (kill-all-local-variables)
  (setq mode-name "ruby")
  (setq buffer-mode 'ruby-mode)
  (use-syntax-table *ruby-mode-syntax-table*)
  (use-keymap *ruby-mode-map*)
  (make-local-variable 'mode-specific-indent-command)
  (setq mode-specific-indent-command #'ruby-indent-line)
  (make-local-variable 'paragraph-start)
  (setq paragraph-start "^$\\|\f")
  (make-local-variable 'paragraph-separate)
  (setq paragraph-separate paragraph-start)
  (make-local-variable 'indent-tabs-mode)
  (setq indent-tabs-mode nil)
  (make-local-variable 'tags-find-target)
  (setq tags-find-target #'tags-find-target-simple)
  (make-local-variable 'tags-find-point)
  (setq tags-find-point #'tags-find-ruby-point)
  (make-local-variable 'build-summary-function)
  (setq build-summary-function 'ruby-build-summary-of-functions)
  (and *ruby-keyword-file*
       (null *ruby-keyword-hash-table*)
       (setq *ruby-keyword-hash-table*
	     (load-keyword-file *ruby-keyword-file*)))
  (when *ruby-keyword-hash-table*
    (make-local-variable 'keyword-hash-table)
    (setq keyword-hash-table *ruby-keyword-hash-table*))
  (make-local-variable 'regexp-keyword-list)
  (setq regexp-keyword-list *ruby-variables-regexp*)
  (setq *local-abbrev-table* *ruby-mode-abbrev-table*)
  (setq comment-start "# ")
  (setq comment-end "")
  (setq comment-start-skip-function 'ruby-comment-start-skip)
  (setq comment-indent-function 'ruby-comment-indent)
  (when *ruby-comment-column*
    (setq comment-column *ruby-comment-column*))
  (run-hooks '*ruby-mode-hook*)
)

(pushnew '(ruby-maketags "*.rb") *maketags-list* :key #'car)

(defun ruby-maketags (file count)
  (goto-char (point-min))
  (while (scan-buffer "^[ \t]*\\(def\\|class\\|module\\|attr\\)[ \t]+" :regexp t :tail t)
    (do-events)
    (let ((type (match-string 1))
	  (opoint (point)))
      (when (and (string= type "attr")
		 (looking-at "[ \t]+:"))
	(goto-char (match-end 0))
      )
      (skip-chars-forward "A-Za-z0-9_")
      (unless (= opoint (point))
	(format t "~A~A~D" (buffer-substring opoint (point)) file opoint)
	(setq count (1+ count)))))
  count)

(defvar *ruby-variables-regexp*
      (compile-regexp-keyword-list
       '(
	 ("\$[0-9_\x7f-\xff]"
	  t (:keyword 1 :bold))
	 ("\$[a-zA-Z_][a-zA-Z0-9_]+"
	  t (:keyword 1))
	 ("@[a-zA-Z0-9_]+"
	  t (:keyword 2)))))
