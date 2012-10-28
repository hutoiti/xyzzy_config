;;; -*- mode: lisp -*-
;;; name:     ac-mode-css
;;; version:  2007.07.30
;;; author:   shiro

;; Copyright (C) 2006-2007 shiro
;;
;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions
;; are met:
;;
;; 1. Redistributions of source code must retain the above copyright
;;    notice, this list of conditions and the following disclaimer.
;;
;; 2. Redistributions in binary form must reproduce the above copyright
;;    notice, this list of conditions and the following disclaimer in
;;    the documentation and/or other materials provided with the
;;    distribution.
;;
;; 3. The name of the author may not be used to endorse or promote
;;    products derived from this software without specific prior
;;    written permission.
;;
;; THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
;; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
;; PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
;; DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
;; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
;; OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
;; HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
;; STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
;; ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;; POSSIBILITY OF SUCH DAMAGE.

;;; Commentary:

;; 概要:
;; 
;; ac-mode + css-mode|css+-mode 用の設定を行う
;; 
;; まだ気休め程度

;; 設定:
;; 
;; (require "ac-mode-css")
;; 
;; ;;; css-mode用
;; (require "css-mode")
;; (add-hook '*css-mode-hook* 'ac-mode-css-init)
;; 
;; ;;; css+-mode用
;; (require "css+-mode")
;; (add-hook '*css+-mode-hook* 'ac-mode-css-init)

;;; Code:

(require "ac-mode")

(provide "ac-mode-css")

(in-package "editor")

(export '(ac-mode-css-init))

(defvar *ac-mode-css-block-elements*
  '("script" "address" "fieldset" "table" "hr" "form" "blockquote" "noscript" "div" "dl" "pre" "ol" "ul" "h6" "h5" "h4" "h3" "h2" "h1" "p" "ins" "del"))

(defvar *ac-mode-css-property*
  '("background" "background-attachment" "background-color" "background-image" "background-position" "background-repeat" "border" "border-bottom" "border-bottom-width" "border-color" "border-left" "border-left-width" "border-right" "border-right-width" "border-style" "border-top" "border-top-width" "border-width" "clear" "color" "display" "float" "font" "font-family" "font-size" "font-style" "font-variant" "font-weight" "height" "letter-spacing" "line-height" "list-style" "list-style-image" "list-style-position" "list-style-type" "margin" "margin-bottom" "margin-left" "margin-right" "margin-top" "padding" "padding-bottom" "padding-left" "padding-right" "padding-top" "text-align" "text-decoration" "text-indent" "text-transform" "vertical-align" "white-space" "width" "word-spacing"))

;; 宣言部分にいるかどうか。
(defun ac-mode-css-current-is-declaration-block (&optional (arg 1))
  (save-excursion
	(ac-mode-css-current-is-declaration-block1 arg)))

(defun ac-mode-css-current-is-declaration-block1 (&optional (arg 1))
  (and (if (eq :string (parse-point-syntax))
		   (goto-char (ed::ac-mode-get-beginning-of-string)) t)
	   (backward-up-list arg t)
	   (if (equal #\( (following-char))
		   (backward-up-list 1 t) t)
	   (equal #\{ (following-char))
	   (save-excursion
		 (handler-case
			 (while (backward-sexp 1)
			   (cond ((bobp)
					  (return t))
					 ((equal #\{ (following-char))
					  (return t))
					 ((equal #\@ (following-char))
					  (return nil))))
		   (simple-error (c) t)))))

;; コメントを取り除く
(defun ac-mode-css-omit-comment (str)
  (let ((match (match-data)))
	(setf str (substitute-string str
								 "\\([^/]*\\)\\(/\*\\(?:.\\|\n\\)*\*/\\)\\(.*\\)"
								 "\\1\\3"))
	(store-match-data match)
	str))

;; ブロックの中身を取得
(defun ac-mode-css-get-current-css ()
  (save-excursion
	(let ((opoint (point))
		  pos res point)
	  (when (ac-mode-css-current-is-declaration-block1)
		(forward-char)
		(setf pos (point))
		(while (scan-buffer "[:;}]" :regexp t :tail t)
		  (unless (eq :comment (parse-point-syntax))
			(let ((str (string-trim "\t\n:;}" (buffer-substring pos (point)))))
			  (setf str (ac-mode-css-omit-comment str))
			  (unless (string= str "")
				(setf str (string-trim " " str))
				(push str res)
				(cond ((< pos opoint (point))
					   (setf point (1- (length res))))
					  ((= opoint (point))
					   (setf point (length res)))))))
		  (setf pos (point))
		  (when (equal #\} (preceding-char))
			(return)))
		(values point (reverse res))))))

(defun ac-mode-css-get-value-position (position lst)
  (let ((opoint (point))
		(res 0) limit)
  (save-excursion
	(when (scan-buffer (nth position lst) :reverse t)
	  (setf limit (match-end 0))
	  (goto-char (match-beginning 0))
	  (while (< (point) limit)
		(skip-syntax-spec-forward "^ ")
		(when (<= opoint (point))
		  (return))
		(skip-syntax-spec-forward " ")
		(incf res)))
	res)))

(defun ac-mode-css-current-is-property (position)
  (evenp position))

(defun ac-mode-css-current-is-value (position)
  (oddp position))

(defun ac-mode-css-get-same-property-value (property &optional n)
  (let (lst)
	(save-excursion
	  (goto-char (point-min))
	  (while (scan-buffer (concat (regexp-quote property) "[ \n]*:[ \n]*\\([^;]*\\)" ) :regexp t :no-dup t)
		(let ((val (match-string 1)))
		  (when n
			(setf val (nth n (split-string val " "))))
		  (when (and (stringp val)
					 (not (string= "" val)))
			(pushnew val lst :test 'equal)))))
	(reverse lst)))

;;; -----------------------------------------------------------------
;;; complete
;;; -----------------------------------------------------------------
;; 2番目は何個目の値に取り得るか。tならどこでも。
(defvar *ac-mode-css-value-list*
  '(("display" 0 ("inline" "block" "list-item" "run-in" "compact" "marker" "table" "inline-table" "table-row-group" "table-header-group" "table-footer-group" "table-row" "table-column-group" "table-column" "table-cell" "table-caption" "none"))
	("position" 0 ("static" "relative" "absolute" "fixed"))
	("top" 0 ("auto"))
	("bottom" 0 ("auto"))
	("right" 0 ("auto"))
	("left" 0 ("auto"))
	("float" 0 ("left" "right" "none"))
	("clear" 0 ("none" "left" "right" "both"))
	("z-index" 0 ("auto"))
	("direction" 0 ("ltr" "rtl"))
	("unicode-bidi" 0 ("normal" "embed" "bidi-override"))
	("width" 0 ("auto"))
	("min-width" 0 ("inherit"))
	("max-width" 0 ("none"))
	("height" 0 ("auto"))
	("min-height" 0 ("inherit"))
	("max-height" 0 ("none"))
	("line-height" 0 ("normal"))
	("vertical-align" 0 ("baseline" "sub" "super" "top" "text-top" "middle" "bottom" "text-bottom"))
	("overflow" 0 ("visible" "hidden" "scroll" "auto"))
	("clip" 0 ("auto"))
	("visibility" 0 ("visible" "hidden" "collapse"))
	
	("text-indent" 0 ("inherit"))
	("text-align" 0 ("left" "right" "center" "justify"))
	("text-decoration" 0 ("none" "underline" "overline" "line-through" "blink"))
	("text-decoration" t ("underline" "overline" "line-through" "blink"))
	("text-shadow" 0 ("none"))
	("letter-spacing" 0 ("normal"))
	("word-spacing" 0 ("normal"))
	("text-transform" 0 ("capitalize" "uppercase" "lowercase" "none"))
	("white-space" 0 ("normal" "pre" "nowrap"))
	
	("color" 0 ("inherit"))
	("background-color" 0 ("transparent"))
	("background-image" 0 ("url()" "none"))
	("background-repeat" 0 ("repeat" "repeat-x" "repeat-y" "no-repeat"))
	("background-attachment" 0 ("scroll" "fixed"))
	("background-position" 0 ("top" "center" "bottom" "left" "right"))
	("background-position" t ("top" "center" "bottom" "left" "right"))
	; ("background") めんどい

	("font-style" 0 ("normal" "italic" "oblique"))
	("font-variant" 0 ("normal" "small-caps"))
	("font-weight" 0 ("normal" "bold" "bolder" "lighter" "100" "200" "300" "400" "500" "600" "700" "800" "900"))
	("font-stretch" 0 ("normal" "wider" "narrower" "ultra-condensed" "extra-condensed" "condensed" "semi-condensed" "semi-expanded" "expanded" "extra-expanded" "ultra-expanded"))
	("font-size-adjust" 0 ("none"))
	; ("font") めんどい
	("border-top-style" 0 ("none" "hidden" "dotted" "dashed" "groove" "ridge" "inset" "outset"))
	("border-right-style" 0 ("none" "hidden" "dotted" "dashed" "groove" "ridge" "inset" "outset"))
	("border-bottom-style" 0 ("none" "hidden" "dotted" "dashed" "groove" "ridge" "inset" "outset"))
	("border-left-style" 0 ("none" "hidden" "dotted" "dashed" "groove" "ridge" "inset" "outset"))
	
	("border-top" 1 ("none" "hidden" "dotted" "dashed" "groove" "ridge" "inset" "outset"))
	("border-right" 1 ("none" "hidden" "dotted" "dashed" "groove" "ridge" "inset" "outset"))
	("border-bottom" 1 ("none" "hidden" "dotted" "dashed" "groove" "ridge" "inset" "outset"))
	("border-left" 1 ("none" "hidden" "dotted" "dashed" "groove" "ridge" "inset" "outset"))

	("caption-side" 0 ("top" "bottom" "left" "right"))
	("table-layout" 0 ("auto" "fixed"))
	("border-collapse" 0 ("collapse" "separate"))
	("empty-cells" 0 ("show" "hide"))
	
	("list-style-type" 0 ("disc" "circle" "square" "decimal" "decimal-leading-zero" "lower-roman" "upper-roman" "lower-greek" "lower-alpha" "lower-latin" "upper-alpha" "upper-latin" "hebrew" "armenian" "georgian" "cjk-ideographic" "hiragana" "katakana" "hiragana-iroha" "katakana-iroha" "none"))
	("list-style-image" 0 ("url()" "none"))
	("list-style-position" 0 ("inside" "outside"))
	; ("list-style") めんどい
	
	("marker-offset" 0 ("auto"))
	
	("cursor" 0 ("auto" "crosshair" "default" "pointer" "move" "e-resize" "ne-resize" "nw-resize" "n-resize" "se-resize" "sw-resize" "s-resize" "w-resize" "text" "wait" "help" "url()"))
	("cursor" t ("url()"))

	("outline-color" 0 ("invert"))
	("outline-style" 0 ("none" "hidden" "dotted" "dashed" "groove" "ridge" "inset" "outset"))
	; ("outline") めんどい
	(t t ("!important"))
	))
(defun ac-mode-css-complete-value ()
  (multiple-value-bind (pos lst)
	  (ac-mode-css-get-current-css)
	(when (and pos (ac-mode-css-current-is-value pos))
	  (let ((property (nth (1- pos) lst))
			(n (ac-mode-css-get-value-position pos lst))
			lst)
		(setf lst (union (third (find-if #'(lambda (y)
											 (and (or (equal property (first y))
													  (eq t (first y)))
												  (or (eq t (second y))
													  (= n (second y)))))
										 *ac-mode-css-value-list*))
						 (ac-mode-css-get-same-property-value property)
						 :test 'equal))
		(when (= 0 n)
		  (pushnew "inherit" lst :test 'equal))
		(when lst
		  (push 'ac-mode-try-complete-list *ac-mode-use-syntax-modules*)
		  (setf *ac-mode-start-marker*
				(set-marker (make-marker)
							(save-excursion (skip-syntax-spec-backward "w_") (point)))
				*ac-mode-end+1-marker*
				(set-marker (make-marker)
							(save-excursion (skip-syntax-spec-forward "w_") (forward-char) (point)))
				*ac-mode-command* '(ac-mode-try-expand-snippet ac-mode-try-complete-list)
				*ac-mode-allow-empty-string-modules* '(ac-mode-try-complete-list)
				*ac-mode-use-complete+-modules* '(ac-mode-try-complete-list)
				*ac-mode-complete-user-list* lst
				*ac-mode-complete-type-list* "Value"))))))

;;; complete property
(defun ac-mode-css-complete-property-after ()
  (when (and (find *ac-mode-this-command*
				   '(ac-mode-self-insert
					 ac-mode-return
					 ac-mode-complete-string))
			 (eq *ac-mode-complete-module* 'ac-mode-try-complete-list))
	(insert ":;")
	(backward-char))
  (delete-hook '*ac-mode-complete-hook* 'ac-mode-css-complete-property-after))
(defun ac-mode-css-complete-property ()
  (multiple-value-bind (pos lst)
	  (ac-mode-css-get-current-css)
	(when (and pos (ac-mode-css-current-is-property pos))
	  (add-hook '*ac-mode-complete-hook* 'ac-mode-css-complete-property-after)
	  (setf *ac-mode-start-marker*
			(set-marker (make-marker)
						(save-excursion (skip-syntax-spec-backward "w_") (point)))
			*ac-mode-end+1-marker*
			(set-marker (make-marker)
						(save-excursion (skip-syntax-spec-forward "w_") (forward-char) (point)))
			*ac-mode-command* '(ac-mode-try-expand-snippet ac-mode-try-complete-list)
			*ac-mode-complete-user-list* *ac-mode-css-property*
			*ac-mode-allow-empty-string-modules* '(ac-mode-try-complete-list)
			*ac-mode-complete-type-list* "Keyword"))))

(defun ac-mode-css-init ()
  (dolist (symb '(ac-mode-css-complete-value
				  ac-mode-css-complete-property
				  ))
	(add-hook 'ac-mode-pre-completion-hook symb)))

;;; ac-mode-css.l ends here
