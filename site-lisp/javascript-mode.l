;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;; ===============================================
;;  XX    XX YY    YY ZZZZZZZZ ZZZZZZZZ YY    YY
;;   XX  XX   YY  YY       ZZ       ZZ   YY  YY
;;     XXX     YYYY       ZZ       ZZ     YYYY
;;    XXX       YY      ZZ       ZZ        YY
;;   XX  XX     YY     ZZ       ZZ         YY
;;  XX    XX    YY    ZZZZZZZZ ZZZZZZZZ    YY
;; -----------------------------------------------
;;       j a v a s c r i p t - m o d e . l
;; ===============================================
;;                                        ver 2.1
;; contributed by:
;;    �r�X�|�����H��C���C�� <eige002@yahoo.com>
;;
;; last update: <02 Mar 2005 18:19:09 +0900>
;;;
;;=============================================================================
;;;
;;;���T�v
;;;�@Major mode for editing Javascript (ECMA-357).
;;;�@#######################################################################
;;;�@�L�[���[�h��t�@�C���͂��̃t�@�C���̖����ɖ��ߍ���ł���̂ŁA�؂�����
;;;�@"javascript+DOM" �Ƃ������O�ŕۑ����Aetc �f�B���N�g���ɒu���Ă��������B
;;;�@#######################################################################
;;;
;;;���g����
;;;�@<< TAB >> �œ��͕⊮���܂��B<< . >> ��łƂ�����Property�Ȃǂ̌���\��
;;;�@���܂��B
;;;�@
;;;�@�t�@�C�����J�����Ƃ��A"var ... ;" �Ő錾���ꂽ�ϐ��̖��O�����W���܂��B����
;;;�@��A"var ... ;" ���L�q����邽�тɁA���̕ϐ��̖��O�����X�g�ɒǉ����܂��B
;;;�@���̃��X�g�� << TAB >> �ŋN������⊮���͂Ŏg���܂��B
;;;
;;;�@�X�N���v�g�̓��e��啝�ɕύX����Ȃǂ�����ł́A���͕⊮���ɂ��łɑ��݂�
;;;�@�Ȃ��ϐ������o�Ă���Ǝv���܂��B��������ɕێ�����Ă���ϐ��̃��X�g���X�V
;;;�@�������Ƃ��́A�o�b�t�@�̐擪�Ɉړ����āA<< M-x javascript-init-hook RET >>
;;;�@�Ƃ���Ă��������B
;;;
;;;�@<< C-x t >> �ŁAfor �� switch �̃e���v���[�g��}���ł��܂��B�~�j�o�b�t�@��
;;;�@�ǂ̃e���v���[�g��}�����邩�w�肵�܂��B�����Ǝ�ނ𑝂₵����A�ύX������
;;;�@�́A����ɂ��Ă��������B
;;;�@
;;;�@<< C-x j >> �ŁA�o�b�t�@���̔C�ӂ� function �u���b�N�ɃW�����v�ł��܂��B
;;;�@�~�j�o�b�t�@�łǂ� function �ɃW�����v���邩�w�肵�܂��B
;;;�@
;;;�@<< C-/ >> �ŁA�Z���N�V�����܂��̓��[�W�������R�����g�A�E�g�ł��܂��B�R����
;;;�@�g�u���b�N�̒��Ŏ��s�����ꍇ�̓R�����g�A�E�g���������܂��B
;;;�@�Z���N�V������������΃��[�W�������̗p���A�����������ΒP�� "/* */" ��}��
;;;�@���܂��B�t�ɁA���[�W�����𖳎����� "/* */" ��}���������Ƃ��́A<< M-; >> ��
;;;�@c-comment-indent ���g���܂��B
;;;�@- NOTE -------------------------------------------------------------------
;;;�@�@"/** ... */" �Ƃ����`���̃R�����g�u���b�N�̒��ł�������s����ƁA
;;;�@�@���̃u���b�N�S�̂��폜���܂��B
;;;�@--------------------------------------------------------------------------
;;;
;;;�����̑�
;;;�@�R�����g�u���b�N���ŉ��s����ƃA�X�^���X�N���������Ă���ꍇ�� << C-j >>
;;;�@�ŉ��s����ΏI���܂��B
;;;�@
;;;�@�ϐ��錾�̎��W�ŁA"var ... ;" �ƍs���̊Ԃɋ󔒕����ȊO�̉���������ꍇ��A
;;;�@�s���܂����ł�ꍇ�́A�X���[����܂��B
;;;�@
;;;�@���������ϐ��錾�̎��W�Ȃǂ���Ȃ���� *javascript-no-var-completion* �� t
;;;�@�ɂ��Ă��������B
;;=============================================================================

(provide "javascript")

(in-package "editor")

(export '(javascript-mode
		  *javascript-keyword-file*         *javascript-keyword-hash-list*
		  *javascript-mode-hook*            *javascript-mode-syntax-table*
		  *javascript-mode-map*             *javascript-mode-abbrev-table*
		  *javascript-regexp-keyword-list*  *javascript-indent-level*
		  *javascript-indent-tabs-mode*     *javascript-no-var-completion*
		  *javascript-var-color*            
		  javascript-indent-line            javascript-newline-and-indent
		  javascript-init-hook              javascript-toggle-comment))

(defvar *javascript-mode-hook*
  nil
  "javascript-mode hook list.")

(defvar *javascript-keyword-file*
  "javascript+DOM"
  "The name of keyword-file used in javascript-mode.")

(defvar *javascript-indent-level*
  4
  "The number of columns by which respective statement blocks could be shifted to
one lower level.")

(defvar *javascript-indent-tabs-mode*
  t
  "Non-nil (default) means javascript-mode uses tabs in place of multiple spaces
for indentation.")

(defvar *javascript-no-var-completion*
  nil
  "If non-nil, the function javascript-completion pops up the list without any
*buffer-known* variables.")

(defvar *javascript-completion-list*
  nil
  "The list literal for the keyword-(and var)-completion.")

(defvar *javascript-is-javascript*
  'montag
  "A sort of Global to hold a temporary tag.")

(defvar *javascript-var-color*
  '(:foreground 2) 
  "The text attribute of the one-off highlighting of variables which occurs to each
var definition. Non-nil means no highlighting.")

(defvar *js-dot-notation-list*
  '(("";; common. ; �����ɂ悭�g�� method �� property ��ǉ����Ă�
	 . ("addEventListener(" "appendChild(" "attachEvent(" "charAt(" "childNodes"
		"getAttribute(" "length" "removeChild(" "setAttribute(" "style" "substr("
		"substring("))
	("document";; document.<>
	 . ("createElement(" "createElementNS(" "createTextNode(" "getElementById("
		"getElementsByTagName(" "styleSheets" "write("))
	("window";; window.<>
	 . ("alert(" "confirm(" "prompt(" "location.href"))
	("navigator";; navigator.<>
	 . ("appName" "appVersion" "platform" "userAgent"))
	("style";; style.<> ; w3c DOM-CSS-2 Properties.
	 . ("azimuth" "background" "backgroundAttachment" "backgroundColor"
	"backgroundImage" "backgroundPosition" "backgroundRepeat"
	"border" "borderCollapse" "borderColor" "borderSpacing"
	"borderStyle" "borderTop" "borderRight" "borderBottom"
	"borderLeft" "borderTopColor" "borderRightColor" "borderBottomColor"
	"borderLeftColor" "borderTopStyle" "borderRightStyle" "borderBottomStyle"
	"borderLeftStyle" "borderTopWidth" "borderRightWidth" "borderBottomWidth"
	"borderLeftWidth" "borderWidth" "bottom" "captionSide" "clear" "clip"
	"color" "content" "counterIncrement" "counterReset" "cue" "cueAfter"
	"cueBefore" "cursor" "direction" "display" "elevation"
	"emptyCells" "cssFloat" "font" "fontFamily" "fontSize" "fontSizeAdjust"
	"fontStretch" "fontStyle" "fontVariant" "fontWeight" "height" "left"
	"letterSpacing" "lineHeight" "listStyle" "listStyleImage" "listStylePosition"
	"listStyleType" "margin""marginTop" "marginRight" "marginBottom"
	"marginLeft" "markerOffset" "marks" "maxHeight" "maxWidth" "minHeight"
	"minWidth" "orphans" "outline" "outlineColor" "outlineStyle" "outlineWidth"
	"overflow" "padding" "paddingTop" "paddingRight" "paddingBottom" "paddingLeft"
	"page" "pageBreakAfter" "pageBreakBefore" "pageBreakInside" "pause" "pauseAfter"
	"pauseBefore" "pitch" "pitchRange" "playDuring" "position" "quotes"
	"richness" "right" "size" "speak" "speakHeader" "speakNumeral"
	"speakPunctuation" "speechRate" "stress" "tableLayout" "textAlign" "textDecoration"
	"textIndent" "textShadow" "textTransform" "top" "unicodeBidi" "verticalAlign"
	"visibility" "voiceFamily" "volume" "whiteSpace" "widows" "width"
	  "wordSpacing" "zIndex")))
  "The assoc-array literal for the function javascript-dot-notation.")

(defvar *javascript-keyword-hash-list* nil)
(and *javascript-keyword-file* (null *javascript-keyword-hash-list*)
	 (setq *javascript-keyword-hash-list*
		   (load-keyword-file *javascript-keyword-file*)))

(defvar *javascript-mode-syntax-table* nil)
(unless *javascript-mode-syntax-table*
  (setq *javascript-mode-syntax-table* (make-syntax-table))
  (do ((x #x21 (1+ x)))
      ((>= x #x7f))
    (let ((c (code-char x)))
      (unless (alphanumericp c)
		(set-syntax-punctuation *javascript-mode-syntax-table* c))))
  (set-syntax-string *javascript-mode-syntax-table* #\")
  (set-syntax-string *javascript-mode-syntax-table* #\')
  (set-syntax-escape *javascript-mode-syntax-table* #\\)
  (set-syntax-symbol *javascript-mode-syntax-table* #\_)
  (set-syntax-match *javascript-mode-syntax-table* #\( #\))
  (set-syntax-match *javascript-mode-syntax-table* #\{ #\})
  (set-syntax-match *javascript-mode-syntax-table* #\[ #\])
  (set-syntax-start-multi-comment *javascript-mode-syntax-table* "/*")
  (set-syntax-end-multi-comment *javascript-mode-syntax-table* "*/")
  (set-syntax-start-c++-comment *javascript-mode-syntax-table* #\/)
  (set-syntax-end-c++-comment *javascript-mode-syntax-table* #\LFD))

(defvar *javascript-mode-map* nil)
(unless *javascript-mode-map*
  (setq *javascript-mode-map* (make-sparse-keymap))
  ;(define-key *javascript-mode-map* #\{ 'javascript-electric-insert)
  (define-key *javascript-mode-map* #\; 'javascript-check-new-variable)
  (define-key *javascript-mode-map* #\} 'javascript-electric-close)
  (define-key *javascript-mode-map* #\RET 'javascript-newline-and-indent)
  (define-key *javascript-mode-map* #\TAB 'javascript-completion)
  (define-key *javascript-mode-map* #\. 'javascript-dot-notation)
  (define-key *javascript-mode-map* #\C-h 'backward-delete-char-untabify-or-selection)
  (define-key *javascript-mode-map* #\C-M-q 'indent-sexp)
  (define-key *javascript-mode-map* '(#\C-x #\j) 'javascript-goto-function)
  (define-key *javascript-mode-map* '(#\C-x #\t) 'javascript-yank-from-template)
  (define-key *javascript-mode-map* #\C-\/ 'javascript-toggle-comment))

(defvar *javascript-mode-abbrev-table*
  nil
  "")
(unless *javascript-mode-abbrev-table*
  (define-abbrev-table '*javascript-mode-abbrev-table*))

(defvar *javascript-regexp-keyword-list*
  (compile-regexp-keyword-list '(("Packages\.\\(java\\|netscape\\|sun\\)\\W"
								  nil 1 nil 9 1)
								 ("Math\.\\(abs\\|acos\\|asin\\|atan\\|atan2\\|ceil\
\\|cos\\|exp\\|floor\\|log\\|max\\|min\\|pow\\|random\\|round\\|sin\\|sqrt\\|tan\\)\\W"
								  nil 1 nil 5 1)
								 ))
  "The regexp-keyword-list of javascript-mode (in an xyzzy fashion.)")

;;; __mode__
(defun javascript-mode ()
  "Major mode for editing JavaScript (ECMA-357).
feat:
- Integrated completion of keywords, Object's props and methods, and variables.
  Try just hitting TAB if you were fed up with entering a whole *camel* things like
  document.getElementsByTagName.
- Hitting comma immediately pops up the completion list of appropriate props and
  methods.
- Jump function, means a function to jump to the function, is available. (C-x j)
- Template function is available, that seems pretty good for a for statement. (C-x t)
- Getting along with comment blocks. It senses the target in a context, region or
  selection or caret, which one should be enclosed with /* and */."
  (interactive)
  (kill-all-local-variables)
  (setq mode-name "javascript")
  (setq buffer-mode 'javascript-mode)
  (use-syntax-table *javascript-mode-syntax-table*)
  (use-keymap *javascript-mode-map*)
  (make-local-variable 'mode-specific-indent-command)
  (setq mode-specific-indent-command 'javascript-indent-line)
  (make-local-variable 'c-indent-level)
  (setq c-indent-level *javascript-indent-level*)
  (make-local-variable 'paragraph-start)
  (setq paragraph-start "^$\\|\f")
  (make-local-variable 'paragraph-separate)
  (setq paragraph-separate paragraph-start)
  (make-local-variable 'indent-tabs-mode)
  (setq indent-tabs-mode *javascript-indent-tabs-mode*)
  (when *javascript-keyword-hash-list*
	(make-local-variable 'keyword-hash-table)
	(setq keyword-hash-table *javascript-keyword-hash-list*))
  (setq *local-abbrev-table* *javascript-mode-abbrev-table*)
  (make-local-variable 'regexp-keyword-list)
  (setq regexp-keyword-list *javascript-regexp-keyword-list*)
  (setq comment-start "/* ")
  (setq comment-end " */")
  (setq comment-start-skip "/\\(\\*+\\|/\\)[ \t]*")
  (setq comment-indent-function 'c-comment-indent)
  (setq comment-column 0)
  (run-hooks '*javascript-mode-hook*))

(defun javascript-init-hook ()
  "When openning file, javascript-mode tries to build its completion list from
the keyword-hash-list. Also, unless no-var-completion ain't be true, it should
collect the every defined variable for later completion jobs."
  (interactive)
  (setf *javascript-completion-list*
		(make-list-from-keyword-table *javascript-keyword-hash-list*))
  (unless *javascript-no-var-completion*
	(save-excursion
	  (while (next-line)
		(unless (parse-point-syntax)
		  (goto-bol) (javascript-var-collection))))))

(add-hook '*javascript-mode-hook* 'javascript-init-hook)

;;=============================================================================
;; Indentation Related:

(defun javascript-indent-line ()
  (interactive)
  (if (or (not (interactive-p))
		  (save-excursion
			(skip-chars-backward " \t")
			(bolp)))
	  (case (save-excursion
			  (goto-bol)
			  (parse-point-syntax))
		(:string)
		(:comment (insert (javascript-comment-indent-string)))
		(t
		 (let ((column (calc-c-indent)))
		   (when (integerp column)
			 (smart-indentation column)))))
	(insert "\t")))

(defun javascript-newline-and-indent (&optional (arg 1))
  "Open a new line with deleting any trailing spaces of the current line, and
indent appropriately."
  (interactive "*")
  (delete-trailing-spaces)
  (insert #\LFD arg)
  (javascript-indent-line))

(defun javascript-electric-insert (&optional (arg 1))
  "Insert the given charactor(s) as a builtin command, and if it's been invoked
within a plain code block, indent the line appropriately."
  (interactive "*p")
  (unless (prog1 (parse-point-syntax) (self-insert-command arg))
	(javascript-indent-line))
  t)

(defun javascript-electric-close (&optional (arg 1))
  "Insert the given charactor(s) as a builtin command and notify the matched
parenthesis immediately. Also, If it's been invoked within a plain code block,
indent the line appropriately."
  (interactive "*p")
  (unless (prog1 (parse-point-syntax) (self-insert-command arg))
	(javascript-indent-line))
  (save-excursion
	(forward-char -1)
	(and (goto-matched-parenthesis)
		 (show-matched-parenthesis)))
  t)

;;=============================================================================
;; Completion Related:

;; javascript-completion: << TAB >>
(defun javascript-completion (&optional (complist *javascript-completion-list*))
  "Pop up the list of suggested (key)words. If it seems to be currently in a job
of completing some properties or methods of javascript's dot notation, the
list got to be the selected one that is associated with the name of the
parent object (eg, 'document', 'window', etc.) Otherwise, it just works
as a generic keyword completion."
  (interactive "*")
  (save-excursion
	(setq from (progn (skip-syntax-spec-backward "w_") (point)))
	(and (char= (preceding-char) #\.)
		 (backward-char)
		 (setq complist (javascript-get-complist))))
  (do-completion from (point) :list complist nil t))

;; javascript-dot-notation: << . >>
(defun javascript-dot-notation ();; v2.0
  "Insert one dot and invoke the function javascript-completion."
  (interactive "*")
  (insert ".")
  (unless (parse-point-syntax) (javascript-completion)))

#|
(defun javascript-dot-notation ();; v1.7
  ""
  (interactive "*")
  (if (parse-point-syntax) (insert ".")
	(let ((p (point)) (node "") a)
	  (save-excursion
		(cond ((char= (preceding-char) #\])
			   (scan-buffer "[" :reverse t))
			  ((char= (preceding-char) #\))
			   (scan-buffer "(" :reverse t))
			  ((skip-syntax-spec-backward "w_")
			   (if (member-if
					#'(lambda (x) (string-equal x (buffer-substring (point) p)))
					'("document" "window" "navigator" "style"))
				   (setq node (buffer-substring (point) p)))))
		(setq a (completing-read (concat (buffer-substring (point) p) ".")
								 (cdr (assoc-if
									   #'(lambda (x) (string-equal x node))
									   *js-dot-notation-list*))
								 :default "")))
	  (insert (concat "." a)))))
|#

(defun javascript-get-complist ()
  "Return the list of sugggested words sucked from *js-dot-notation-list*."
  (let ((p (point)) (node ""))
	(save-excursion
	  (cond ((char= (preceding-char) #\])
			 (scan-buffer "[" :reverse t))
			((char= (preceding-char) #\))
			 (scan-buffer "(" :reverse t))
			((skip-syntax-spec-backward "w_")
			 (if (member-if
				  #'(lambda (x) (string-equal x (buffer-substring (point) p)))
				  '("document" "window" "navigator" "style"))
				 (setq node (buffer-substring (point) p)))))
	  (cdr (assoc-if
			#'(lambda (x) (string-equal x node))
			*js-dot-notation-list*)))))

;;=============================================================================
;; Variable-collection Related:
(defvar *javascript-var-re*
  (compile-regexp
   (concat "^[ \t]*" (regexp-quote "var") "[ ]\\([a-zA-Z_][a-zA-Z0-9_]*\\)"))
  "Matches 'fooBar' of 'var fooBar' as javascript code, for example.")
(defvar *javascript-var-rere*
  (compile-regexp "[,][ ]?\\([a-zA-Z_][a-zA-Z0-9_]*\\)")
  "Matches 'zooCar' of 'var fooBar, zooCar' as javascript code, for example.")

(defun javascript-var-collection ()
  "Subroutine to find and register any variables defined at the current line
as javascript code. This expects being invoked where the point is at the
beginning of line."
  (unless (looking-at *javascript-var-re*)
	(return-from javascript-var-collection nil))
  (pushnew (match-string 1) *javascript-completion-list*)
  (if *javascript-var-color*
	  (apply #'set-text-attribute
			 (match-beginning 1) (match-end 1)
			 *javascript-is-javascript* *javascript-var-color*))
  (scan-buffer *javascript-var-re* :tail t :regexp t)
  (while (looking-at *javascript-var-rere*)
	(pushnew (match-string 1) *javascript-completion-list*)
	(if *javascript-var-color*
		(apply #'set-text-attribute
			   (match-beginning 1) (match-end 1)
			   *javascript-is-javascript* *javascript-var-color*))
	(scan-buffer *javascript-var-rere* :tail t :regexp t)))

;; javascript-check-new-variable: << ; >>
(defun javascript-check-new-variable ()
  "When user hit semi-colon, if that was a var definition statement,
launch the function javascript-var-collection (if needed) immediately after
inserting the semi-colon."
  (interactive)
  (javascript-electric-insert)
  (or *javascript-no-var-completion* (parse-point-syntax)
	  (save-excursion
		(goto-bol)
		(javascript-var-collection))))

;; #### stolen code from html+-mode. ####
(defun javascript-resume-var-color ()
  (if *javascript-var-color*
      (delete-text-attributes *javascript-is-javascript*)))

(unless *javascript-no-var-completion*
  (add-hook '*pre-command-hook* 'javascript-resume-var-color))

;;=============================================================================
;; Jump Related:
(defvar *javascript-function-re*
  (compile-regexp (concat "^[ \t]*" (regexp-quote "function ")
						  "\\([a-zA-Z_][^)]*[)]\\)[ {]?"))
  "Matches 'funcaDelic ()' of 'function funcaDelic () {' as javascript code,
for example.")

;; goto-function: << C-x j >>
(defun javascript-goto-function ()
  "Build a list of function blocks, prompt user where to go, and go."
  (interactive)
  (let (tmp tmp1)
	(save-excursion
	  (goto-line 2)
	  (while (next-line);; starting from line 3...
		(goto-bol)
		(when (looking-at *javascript-function-re*)
		  (pushnew (cons (match-string 1) (current-line-number)) tmp1)
		  (scan-buffer "{")
		  (forward-sexp))))
	(setq tmp (completing-read "Go to function: " tmp1 :default "" :must-much t))
	(goto-line (cdr (assoc-if
				  #'(lambda (x) (string-equal x tmp))
				  tmp1)))))

;;=============================================================================
;; Template Related:

;; javascript-yank-from-template: << C-x t >>
(defun javascript-yank-from-template (key)
  "Insert a cold template."
  (interactive (list (completing-read "insert template: "
									  '("for" "switch")
									  :default "for")))
  (cond
   ;; "for" statement: parenthesis unclosed.
   ((string-equal key "for")
	(progn
	  (insert "for (var i = 0; i < ")
	  (save-excursion;; using save-excursion.
		(insert "; i++) {")
		(javascript-newline-and-indent))))
   ;; "switch" statement: parenthesis unclosed.
   ((string-equal key "switch")
	(progn
	  (insert "switch (")
	  (setq p (point));; remember point...
	  (insert ") {")
	  (javascript-newline-and-indent)
	  (insert "case :")
	  (javascript-newline-and-indent)
	  (insert "break;")
	  (goto-char p)));; and go(back)to-char
   (t
	(message "('c_')"))))
  
;;=============================================================================
;; Comment Related:

;; #### based on the stolen code from xml-mode #### << C-/ >>
(defun javascript-toggle-comment ()
  "Toggle comment-out and resume for the region, selection, or finally, carret."
  (interactive)
  (if (eq (parse-point-syntax) :comment)
	  (save-excursion
		(scan-buffer "/*" :reverse t :tail t)
		(kill-region (match-beginning 0) (match-end 0))
		(cond ((string-equal (following-char) " ")
			   (delete-char))
			  ((string-equal (following-char) #\LFD)
			   (delete-char))
			  ;; delete a whole block if it was a "/** */" style comment.
			  ((string-equal (following-char) "*")
			   (let ((p (point)))
				 (scan-buffer "*/" :tail t)
				 (delete-region p (point))
				 (return-from javascript-toggle-comment t)))
			  ;;
			  )
		(scan-buffer "[ ]?\\*/" :regexp t :tail t)
		(kill-region (match-beginning 0) (match-end 0)))
	(let ((m (if (pre-selection-p) (selection-mark) (or (mark t) (point))))
		  (p (point)))
	  (and (= m p)
		   (insert comment-end) (goto-char p) (insert comment-start)
		   (return-from javascript-toggle-comment nil))
	  (goto-char (max m p))
	  (insert comment-end)
	  (save-excursion
		(goto-char (min m p))
		(insert comment-start)))))

;; #### stolen code from php-mode ####
(defun javascript-comment-indent-string ()
  ""
  (save-excursion
	(previous-line)
	(goto-bol)
	(cond
	 ((looking-at "^\\([ \t]*\\)/\\*\\*")                           ;  /**
	  (format nil "~V@{~A~:*~} * " (length (match-string 1)) " "))
	 ((looking-at "^\\([ \t]*\\)/\\*")                              ;  /*
	  (format nil "~V@{~A~:*~}" (length (match-string 1)) " "))
	 ((looking-at "^\\([ \t]*[*][ \t]*\\)")                         ;   *
	  (match-string 1))
	 ((looking-at "^\\([ \t]*\\)")                                  ;
	  (match-string 1))
	 (t
	  ""))))
;;=============================================================================
;;__END__