;;; -*- mode: lisp -*-
;;; name:     snippet
;;; version:  2007.07.15
;;; author:   shiro
;;; category: Editing
;;; src:      http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fsnippet&openfile=
;;; changes:  10�ȏ�̓W�J���ł��Ȃ������̂��C��
;;; files:    site-lisp/snippet.l
;;;           site-lisp/snippet.lc
;;;           site-lisp/ni-autoload/silog/snippet.l

;; Copyright (C) 2007 shiro
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

;; �T�v:
;; 
;; Abbrev�œW�J������ɁA
;;   * �w�肵���ʒu�ɃW�����v
;;   * �ҏW���������𑼂̏ꏊ�ɔ��f
;; ���܂��B
;; �v���O������HTML�Ȃǂ̒�^�I�ȕ���ǂ����͂���l�ȊO�͂��܂���������Ȃ���������܂���B
;; 
;; TextMate�Řb��ɂȂ��Ă����̂Ő����Ŏ������܂����B
;; �ڍׂ��ǂ�������Ȃ��Ƃ����A��������l���ĂȂ��Ƃ��낪����̂ŁA
;; ���낢��Ɩ�肪���邩������܂���B
;; 
;; ac-mode�ƈꏏ�Ɏg�����Ƃ𐄏��B
;; 

;; �g�p���@:
;; 
;; abbrev�Ŏg�p����ݒ�����̂܂܎g���Ă��܂��B(�f�t�H���g�ł�~/.abbrev_defs)
;; ac-mode�𓱓����Ă������abbrev�̓W�J�O�̕�����̒����TAB�������Ă��������B
;; ac-mode�𓱓����Ă��Ȃ�����.xyzzy��
;;  (define-key ctl-x-map #\' 'snippet-expand)
;; ���ƃL�[�o�C���h���`���Aabbrev�̓W�J�O�̕�����̒���� C-x ' �������Ă��������B
;; 
;; TAB/C-x '�œW�J����ƁAsnippet-mode�ɓ���܂��B
;; snippet-mode�ł�C-n/C-p�ŃW�����v�ł��܂��B
;; C-n/C-p�ňړ�����悪�Ȃ��ꍇ��AC-g��������snippet-mode�𔲂��A
;; ���̏�Ԃɖ߂�܂��B
;; TextMate�ł�TAB�ŃW�����v����悤�ł����A
;; �W�����v���ĕҏW���Ă鎞��ac-mode�ŕ⊮�������̂ŁA
;; �W�����v��C-n/C-p�ōs���悤�ɂ��Ă��܂��B
;; (�Ȃ̂Ŗ߂邱�Ƃ��o���܂��B)


;; �g�p���@2:
;; 
;; abbrev/snippet���悭�������Ƃ����l��A�Ƃ肠���������Ă݂����l�p�B
;; 
;; 1. snippet.l��site-lisp�ɃR�s�[
;; 
;; 2. ~/.abbrev_defs�Ɉȉ��������ĕۑ�
;; 
;; (in-package "editor")
;; (define-abbrev-table '*global-abbrev-table* '(
;; ("class" "class ${1:ClassName} (${2:object}):
;;     def __init__(self${3:, arg}):
;;         \"\"\"${4:documentation}\"\"\"
;; ${3/, *\\([a-zA-Z][0-9a-zA-Z_]*\\)/        self.\\1 = \\1\n/g}
;;     $0")))
;; 
;; 3. .xyzzy�Ɉȉ���ǉ����ĕۑ���Axyzzy���ċN��
;; 
;; (quietly-read-abbrev-file)
;; (require "snippet")
;; (define-key ctl-x-map #\' 'snippet-expand)
;; 
;; 4. *scratch* �o�b�t�@�Ȃǂ� class �Ɠ��͂��A
;;    �L�����b�g�𓮂������� C-x ' �������Ă��������B
;;    �ȉ��̂悤�ɓW�J����AClassName��I�����Ă����Ԃ��Ǝv���܂��B
;; 
;; class ClassName (object):
;;     def __init__(self, arg):
;;         """documentation"""
;;         self.arg = arg
;; 
;; 5. �K���ɃN���X������͂��� C-n �������Ă��������B
;;    object�̕����ɃL�����b�g���W�����v�����Ǝv���܂��B
;;    ������x C-n �������A
;;    , arg
;;    ��
;;    , arg1, arg2, arg3
;;    �ȂǂɕҏW���Ă݂Ă��������B
;;    �ȉ��̂悤�ɂȂ�Ǝv���܂��B
;; 
;; class ClassName (object):
;;     def __init__(self, arg1, arg2, arg3):
;;         """documentation"""
;;         self.arg1 = arg1
;;         self.arg2 = arg2
;;         self.arg3 = arg3
;; 
;; 6. �Ō�܂� C-n �ŃW�����v���邩�A�r���� C-g ��������snippet-mode�𔲂��܂��B
;;    ���Ȃ݂ɁAsnippet-mode�̏�ԂȂ�ԈႦ�Ă� C-p �Ŗ߂�܂��B

;; �g�p���@3:
;; 
;; M-x snippet-select-and-expand
;; 
;; �܂���
;; 
;; (snippet-select-and-expand "defun")
;; �^���镶�����snippet�Ƃ��ēo�^��������

;; ����:
;; 
;; 1. ${[0-9]:default}
;;      �L�����b�g���ړ�����ʒu�B
;;      �f�t�H���g�l���w�肷��ƁA�W�����v�������ɑI����ԂɂȂ�B
;; 2. ${[0-9]/pattern/format/option}
;;      1�Ŏw�肳�ꂽ���̂Ɠ����������w�肷�邱�ƂŘA�����ĕω����镶����B
;;      pattern�ɐ��K�\�����w�肵�Aformat�ɑ}�����镶������w�肵�܂��B
;;      format�ɂ�\\1-\\9���w��\�ł��B
;;      option�ɂ͍��̂Ƃ���g�̂ݎw��\�ł��B(���x���}�b�`�����܂��B)
;;      /�𕶎��Ƃ��Ďw�肵�����Ƃ���\\/�ƃG�X�P�[�v���Ă��������B
;; 3. $[0-9]
;;      1�Ԗڂ̏����̃f�t�H���g�l���w�肵�Ȃ����̏ȗ��`�B
;;      �������A$0���Ō�ɏ�����snippet-mode�𔲂���(�W�����v�ł��Ȃ��Ȃ�)�̂Œ��ӂ��Ă��������B
;; 4. ${file:path}
;;      path�ɂ���t�@�C���̒��g��}�����܂��B
;;      (${file:~/.license}��${file:C:/doc/hoge.txt}�̂悤�Ɏg���܂�)
;;      1,2,3�̏�����W�J����O�ɑ}������̂ŁA�t�@�C������1,2,3�̏������g�����Ƃ��ł��܂��B
;;      ${file:path}���ӂ̐����ƃt�@�C�����̏����̐������d�����Ȃ��悤�ɂ��Ă��������B
;; 
;; ��̓I�ȗ�͎g�p���@2��1�����Ă��������B
;; 1-9�܂ł��w�肵���ꍇ�͐F���t���܂��B

;; ����1�Ɏg�p�ł���u���}�N��:
;; 
;;    XYZZY-SELECTION  �Z���N�V����
;; 
;; ����1�y��2��format���Ɏg�p�ł���u���}�N��:
;; 
;;    XYZZY-FILE-NAME                 �t���p�X
;;    XYZZY-FILE-DIRECTORY-NAMESTRING �f�B���N�g����
;;    XYZZY-FILE-NAMESTRING           �t�@�C����
;;    XYZZY-FILE-PATHNAME-NAME        �t�@�C�����i�g���q�����j
;;    XYZZY-FILE-PATHNAME-TYPE        �g���q
;;    XYZZY-FILE-PATHNAME-DEVICE      �h���C�u��
;; 
;; �s���Ɏg�p�ł���u���}�N��:
;; 
;;    $INDENT          mode-specific-indent-command�Ŏw�肳�ꂽ�C���f���g�R�}���h�ŃC���f���g

;; TODO:
;; 
;; - �C���f���g�֘A���܂Ƃ���
;; - 2�Ԗڂ̏����̊g���`�Ƃ��āA���K�\���ł͂Ȃ�lisp�ŕύX�ł���悤��
;; - �����̓���q������

;; ����:
;; 
;; 2007.07.15
;; - 10�ȏ�̓W�J���ł��Ȃ������̂��C��
;; 
;; 2007.04.14
;; - �I�𒼌�̃o�b�t�@�C���̋������C��
;; 
;; 2007.04.12
;; - �ԍ��Ƒ����̑Ή������߂�ϐ� *snippet-attribute-dict* ��ǉ�
;; - �t�@�C�����w�肵�đ}�����鏑����ǉ�
;; 
;; 2007.03.22
;; - �o�b�t�@�ύX�R�}���h���ǂ����̃t���O�����ɖ߂��^�C�~���O���C��
;; 
;; 2007.03.16
;; - ���K�\��������ɕύX
;; 
;; 2007.03.13
;; - �C���f���g���̋󔒂��Z���N�V�����Ɋ܂܂�Ă����̂��C��
;; 
;; 2007.03.12
;; - �o�b�t�@���C������R�}���h�������Ŕ��肷��悤�ɂ���
;; - ����ɔ�����snippet-modify-command��p�~
;; 
;; 2007.03.07
;; - �����paren.l�ւ̈ˑ����Ȃ���������
;; - ${1:/.*/\\0}��${1}�Əȗ��ł���悤�ɂ���
;; 
;; 2007.03.02
;; - �}�[�J�[($0�ȂǂŎg�p)�̈ʒu�ɕ�����}���������A�����Ƀ}�[�J�[�������悤�ɂ��������C��
;; - �V���{���̊J�n�ʒu������悤�ɂ���(1�����݂̂̒�`�������Ă��딚���Ȃ��悤��)
;; 
;; 2007.02.22
;; - $0������${1:hoge}�Ȃǂɂ������Ă�Ƃ��܂��W�����v�ł��Ȃ������̂��C��
;; 
;; 2007.02.19
;; - C-n�ŃW�����v�������ac-mode-complete-or-indent(TAB)
;;   �����s���ꂽ��I�𒆂̕�������폜����悤�ɂ���
;; - indent-region���g�킸�Ɉ�s���C���f���g����悤�ɂ���(�����̋󔒂�������邽��)
;; 
;; 2007.02.15
;; - �L�[�{�[�h�}�N���Ŏg����悤�ɂ���
;; 
;; 2007.02.09
;; - �Z���N�V�����֌W�̃o�O�C��
;; 
;; 2007.02.08
;; - �~�j�o�b�t�@����I������snippet��}������@�\��ǉ�
;; - XYZZY-SELECTION��ǉ�
;; - ����2�ɃX���b�V�����w��ł���悤�ɂ���(�G�X�P�[�v����K�v�L��) 
;; 
;; 2007.01.20
;; - ���������C���B
;; - �{��abbrev�œW�J�ł��Ȃ�����(�L�����܂܂�Ă�����)�ł��W�J�B
;; - �C���f���g����W�J�}�N��$INDENT(��)��ǉ��B
;; 
;; 2007.01.12
;; - ���̂������C��
;; 
;; 2007.01.10
;; - ����

(provide "snippet")

(in-package "editor")

(export '(snippet-expand
		  snippet-select-and-expand
		  *snippet-attribute-dict*))

;;; variable
(defvar-local snippet-mode-on nil)
(pushnew '(snippet-mode-on . "Snippet") *minor-mode-alist* :key #'car)

(defvar-local *snippet-current-tag* nil)
(defvar-local *snippet-begin* nil)
(defvar-local *snippet-end* nil)
(defvar-local *snippet-list* nil)
(defvar *snippet-select* nil)

(defvar-local *snippet-table* nil)

(defvar-local *snippet-last-paren-state* nil)

(defvar *snippet-before-alist* nil)
(defvar *snippet-after-alist* nil)

; ${1:foo}�̕����F��2�ɔw�i�F��3��,
; ${2:bar}�̕����F��10�ɔw�i�F��12�ɂ������ꍇ�͈ȉ��̂悤�ɁB
; '((1 (:foreground 2 :background 3))
;   (2 (:foreground 10 :background 12)))
(defvar *snippet-attribute-dict*
  '((1 :foreground 1)
	(2 :foreground 2)
	(3 :foreground 3)
	(4 :foreground 4)
	(5 :foreground 5)
	(6 :foreground 6)
	(7 :foreground 7)
	(8 :foreground 8)
	(9 :foreground 9)
	(10 :foreground 10)
	(11 :foreground 11)
	(12 :foreground 12)
	(13 :foreground 13)
	(14 :foreground 14)
	(15 :foreground 15)))

;;; structure
(defstruct snippet
  number default regexp format option from to)

;;; keymap
(defvar *snippet-mode-map* nil)
(unless *snippet-mode-map*
  (setf *snippet-mode-map* (make-sparse-keymap))
  (define-key *snippet-mode-map* #\Down 'snippet-next)
  (define-key *snippet-mode-map* #\Up 'snippet-prev)
  (define-key *snippet-mode-map* #\C-n 'snippet-next)
  (define-key *snippet-mode-map* #\C-p 'snippet-prev))

;;; function
(defun snippet-clear-variable ()
  (setf *snippet-current-tag* nil
		*snippet-begin* nil
		*snippet-end* nil
		*snippet-begin-number* nil
		*snippet-end-number* nil
		*snippet-before-alist* nil
		*snippet-after-alist* nil)
  (delete-text-attributes 'snippet-end))

;;; ����0�̑����������ꏊ�ɕ�������Ƃ��ɕ��������/������ݒ肷���2�ڈȍ~��������΍�
(defun snippet-hiddens-enqueue (item parent &key before after)
  (let (symbol alist before-children after-children)
	(cond (before
		   (setf symbol '*snippet-before-alist*
				 alist *snippet-before-alist*))
		  (after
		   (setf symbol '*snippet-after-alist*
				 alist *snippet-after-alist*)))
	(when symbol
	  (when alist; item�Ɏq�������parent�̎q�ɂ��Ƃ�
		(setf before-children (snippet-hiddens-get item :before t)
			  after-children (snippet-hiddens-get item :after t))
		(snippet-hiddens-delete-parent item :before t)
		
		#+:snippet
		(msgbox "item: ~S~%b-children : ~S~%achildren : ~S~%before:: ~S~%after:: ~S~%" item before-children after-children *snippet-before-alist* *snippet-after-alist*)
		
		(dolist (child before-children)
		  (snippet-hiddens-enqueue child parent :before before :after after))
		)
	  (cond ((first (last (assoc parent alist :test 'equal)))
			 (unless (find item (first (last (assoc parent alist :test 'equal))))
			   (push item (cdr (last (second (assoc parent alist :test 'equal))))))
			 
			 (car (last (assoc parent alist :test 'equal))))
			((null alist)
			 (let ((res (list item)))
			   (set symbol (list (list parent res)))
			   res))
			(t
			 (let ((res (list item)))
			   (set symbol (append (list (list parent res)) alist))
			   res)))
	  (when after-children; item�Ɏq�������parent�̎q�ɂ��Ƃ�
		(dolist (child after-children)
		  (snippet-hiddens-enqueue child parent :before before :after after))
		(snippet-hiddens-delete-parent item :after t)))))

(defun snippet-hiddens-delete-child (child &key before after)
  (let (symbol alist res)
	(cond (before
		   (setf symbol '*snippet-before-alist*
				 alist *snippet-before-alist*))
		  (after
		   (setf symbol '*snippet-after-alist*
				 alist *snippet-after-alist*)))
	(when alist
	  (dolist (lst alist)
		(let ((new (remove child (second lst) :test 'equal)))
		  (when new
			  (setf res (append res (list (append
										   (list (car lst))
										   (list new))))))))
	  (set symbol res))))

(defun snippet-hiddens-delete-parent (parent &key before after)
  (let (symbol alist)
	(cond (before
		   (setf symbol '*snippet-before-alist*
				 alist *snippet-before-alist*))
		  (after
		   (setf symbol '*snippet-after-alist*
				 alist *snippet-after-alist*)))
	(when alist
	  (set symbol (remove parent alist :key 'first :test 'equal)))))

(defun snippet-hiddens-get (parent &key before after)
  (cond (before
		 (second (assoc parent *snippet-before-alist* :test 'equal)))
		(after
		 (second (assoc parent *snippet-after-alist* :test 'equal)))))

(defun snippet-hiddens-get-from-number (number &key before after)
  (let (res)
	(dolist (elements (cond (before *snippet-before-alist*)
							(after *snippet-after-alist*))
					  res)
	  (let (tmp-children)
		(setf tmp-children (remove-if-not #'(lambda (x)
											  (= (ed::snippet-number x) number))
										  (second elements)))
		(when tmp-children
		  (setf tmp-children (list tmp-children))
		  (push (first elements) tmp-children)
		  (setf res (append res (list tmp-children))))))))

(defun snippet-get-snippet-attributes (&key parent child marker)
  (remove-if-not #'(lambda (x)
					 (when (snippet-p (third x))
					   (cond (parent
							  (snippet-default (third x)))
							 (child
							  (snippet-regexp (third x)))
							 (t t))))
				 (append (list-text-attributes)
						 (when marker
						   (mapcar #'(lambda (x)
									   (list (marker-point (first x))
											 (marker-point (first x))
											 (second x)))
								   snippet-markers)))))

(defun snippet-get-snippet-attribute-point (&key parent child point)
  (save-excursion
	(when point
	  (goto-char point))
	(remove-if-not #'(lambda (y)
					   (<= (first y) (point) (second y)))
				   (snippet-get-snippet-attributes :parent parent :child child))))

(defun snippet-get-w_ ()
  (let ((pt (point)) start end string)
	(save-excursion
	  (and (skip-syntax-spec-backward "w_")
		   (/= (point) pt)
		   (setf start (point)
				 string (buffer-substring start pt))
		   (skip-syntax-spec-forward "w_")
		   (setf end (point))))
	(values start end string)))

(defun snippet-get-abbrev ()
  (multiple-value-bind (start end string)
	  (snippet-get-w_)
	(or (and (integerp start)
			 (integerp end)
			 (setf *snippet-begin* start)
			 (or (and *local-abbrev-table*
					  (gethash-region start end *local-abbrev-table*))
				 (gethash-region start end *global-abbrev-table*)))
		(snippet-get-abbrev-include-non-symbol))))

(defun snippet-get-abbrev-include-non-symbol ()
  (let ((str (buffer-substring (save-excursion (goto-bol) (point))
							   (point)))
		(lst (append (make-list-from-keyword-table *local-abbrev-table*)
					 (make-list-from-keyword-table *global-abbrev-table*)))
		res)
	(some #'(lambda (key)
			  (when (string-match (format nil "\\_<~A$" (regexp-quote key)) str)
				key))
		  lst)))

(defun snippet-expand-abbrev ()
  (interactive "*")
  (let (abbrev start end)
	(run-hooks '*pre-abbrev-expand-hook*)
	(save-excursion
	  (let ((opoint (point)))
		(setq start (cond (*abbrev-prefix-location*
						   (goto-char *abbrev-prefix-location*)
						   (when (eql (following-char) #\-)
							 (delete-region (point) (+ (point) 1)))
						   (setq *abbrev-prefix-location* nil)
						   (point))
						  (t
						   (skip-syntax-spec-backward "w_")
						   (point))))
		(setq end (min opoint
					   (progn
						 (skip-syntax-spec-forward "w_")
						 (point))))
		(unless (>= start end)
		  (setq abbrev (or (and *local-abbrev-table*
								(gethash-region start end *local-abbrev-table*))
						   (gethash-region start end *global-abbrev-table*))))
		(unless abbrev
		  (let* ((str (snippet-get-abbrev-include-non-symbol)))
			(when str
			  (setq abbrev (or (and *local-abbrev-table*
									(gethash str *local-abbrev-table*))
							   (gethash str *global-abbrev-table*)))
			  (scan-buffer str :reverse t)
			  (setf *snippet-begin* (match-beginning 0))
			  (setf start (match-beginning 0)
					end (match-end 0)))))
		(unless abbrev
		  (return-from snippet-expand-abbrev nil))))
	(setq *last-abbrev-text* (buffer-substring start end))
	(delete-region start end)
	(goto-char start)
	(setq *last-abbrev* (car abbrev))
	(setq *last-abbrev-point* start)
	(incf (caddr abbrev))
	(insert (car abbrev))
	(cond ((string-match "^[A-Z]*$" *last-abbrev-text*)
		   (if (and (null *abbrev-all-caps*)
					(save-excursion
					  (> (progn
						   (forward-word -1)
						   (point))
						 (progn
						   (goto-char start)
						   (forward-word 1)
						   (point)))))
			   (capitalize-region start (point))
			 (upcase-region start (point))))
		  ((string-match "[A-Z]" *last-abbrev-text*)
		   (let ((p (point)))
			 (goto-char start)
			 (capitalize-word 1)
			 (goto-char p))))
	(when (cadr abbrev)
	  (funcall (cadr abbrev)))
	t))

(defun snippet-split-slash (str)
  (when (string= "" str)
	(return-from snippet-split-slash '(".*" "\\0")))
  (let ((begin 0)
		(d (match-data))
		lst)
	(when (equal "/" (substring str 0 1))
	  (setf str (substring str 1)))
	(while (string-match "\\([^\\]\\)/" str begin)
	  (let ((tmp (substring str begin (match-end 1)))
			(data (match-data)))
		(push (substitute-string tmp "\\\\/" "/") lst)
		(store-match-data data)
		(setf begin (match-end 0))))
	(unless (= begin (length str))
	  (push (substring str begin) lst))
	(store-match-data d)
	(reverse lst)))

(defvar-local snippet-selection nil)

(defun snippet-select-and-expand (&optional string)
  (interactive "*")
  (let ((lst (append (make-list-from-keyword-table *local-abbrev-table*)
					 (make-list-from-keyword-table *global-abbrev-table*))))
	(cond ((and string (not (find string lst :test 'equal)))
		   (error "snippet����`����Ă��܂���: ~A" string))
		  ((not string)
		   (setf string (completing-read "snippet: " lst
										 :case-fold t
										 :must-match t))))
	(unless string
	  (return-from snippet-select-and-expand))
	(cond ((get-selection-type)
		   (setf snippet-selection (buffer-substring (selection-mark) (selection-point)))
		   (delete-region (selection-mark) (selection-point))
		   (stop-selection))
		  (t (snippet-convert-xyzzy-selection)))
	(let ((*snippet-select* string))
	  (snippet-expand))))

(defvar-local snippet-markers nil)

(defun snippet-expand ()
  (interactive "*")
  (cond (snippet-mode-on
		 (snippet-next))
		(t
		 (cond (*snippet-select*
				(setf *snippet-begin* (point))
				(insert (car (or (and *local-abbrev-table*
									  (gethash *snippet-select* *local-abbrev-table*))
								 (gethash *snippet-select* *global-abbrev-table*)))))
			   ((snippet-get-abbrev)
				(snippet-expand-abbrev)
				(snippet-convert-xyzzy-selection))
			   (t (return-from snippet-expand)))
		 (clear-undo-boundary)
		 (forward-char)
		 (setf *snippet-end* (point-marker))
		 (funcall 'set-text-attribute
				  (point) (point) 'snippet-end)
		 (goto-char *snippet-begin*)
		 (save-excursion
		   (goto-char *snippet-end*)
		   (while (scan-buffer (format nil "\\(?:[^\\]\\|^\\)\\(${file:\\([^}]*\\)}\\)")
							   :regexp t :reverse t :no-dup t :limit *snippet-begin*)
			 (let ((path (match-string 2)))
			   (delete-region (match-beginning 1)
							  (match-end 1))
			   (insert-file path))))
		 (save-excursion
		   (goto-char *snippet-end*)
		   (while (scan-buffer "\\(?:[^\\]\\|^\\)\\($\\(?:\\([0-9]+\\)\\|{\\([0-9]+\\)\\(?::\\([^}]*\\)\\)}\\)\\)"
							   :regexp t :reverse t :no-dup t :limit *snippet-begin*)
			 (let (number previous-number
						  default previous-default
						  snippet)
			   (unless (setf number (match-string 2))
				 (setf number (match-string 3))
				 (when (match-string 4)
				   (setf default (snippet-convert-macro (match-string 4)))))
			   (setf snippet (make-snippet :number (parse-integer number)
										   :default (or default "")))
			   (push snippet *snippet-list*)
			   (delete-region (match-beginning 1)
							  (match-end 1))
			   
			   (cond ((and (or (not default)
							   (equal default ""))
						   (= (snippet-number snippet) 0))
					  (push (list (set-marker (make-marker) (point)) snippet) snippet-markers))
					 (t
					  (and default
						   ;(not (equal default ""))
						   (let ((marker (some #'(lambda (m)
												   (when (= (point) (marker-point (car m)))
													 m))
											   snippet-markers)))
							 (prog1
								 (insert default)
							   (when marker
								 (set-marker (car marker) (point))))))
					  (apply 'set-text-attribute
							 (match-beginning 1)
							 (point)
							 snippet
							 (cdr (assoc (snippet-number snippet) *snippet-attribute-dict*))))))))
		 (save-excursion
		   (dolist (snippet *snippet-list*)
			 (goto-char *snippet-end*)
			 (while (scan-buffer (format nil "${~A\\(\\(/[^/}]+\\)\\{,4\\}\\)}"
										 (snippet-number snippet))
								 :regexp t :reverse t :no-dup t :limit *snippet-begin*)
			   (let* ((from (match-beginning 0))
					  (to (match-end 0))
					  (default (snippet-default snippet))
					  (lst (snippet-split-slash (match-string 1)))
					  (tag (make-snippet :number (snippet-number snippet)
										 :regexp (first lst)
										 :format (second lst)
										 :option (third lst)))
					  (replacement (snippet-expand-meta-character default tag))
					  parent before after)
				 (cond ((and (equal replacement "")
							 (or (let ((parents (remove tag (snippet-get-snippet-attribute-point :point from)
														:key 'third :test 'equal)))
								   (and (setf parent (or (find-if 'snippet-default parents :key 'third)
														 (find from parents :key 'second :test 'equal)))
										(setf after t)))
								 (let ((parents (remove tag (snippet-get-snippet-attribute-point :point to)
														:key 'third :test 'equal)))
								   (and (setf parent (or (find-if 'snippet-default parents :key 'third)
														 (find to parents :key 'second :test 'equal)))
										(setf before t)))))
						(let ((before-children (snippet-hiddens-get tag :before t))
							  (after-children (snippet-hiddens-get tag :after t)))
						  (cond (before
								 (dolist (child before-children)
								   (snippet-hiddens-enqueue child (third parent) :before t))
								 (snippet-hiddens-enqueue tag (third parent) :before t)
								 (dolist (child after-children)
								   (snippet-hiddens-enqueue child (third parent) :before t)))
								(after
								 (dolist (child before-children)
								   (snippet-hiddens-enqueue child (third parent) :after t))
								 (snippet-hiddens-enqueue tag (third parent) :after t)
								 (dolist (child after-children)
								   (snippet-hiddens-enqueue child (third parent) :after t))))
						  (snippet-hiddens-delete-parent tag :before t)
						  (snippet-hiddens-delete-parent tag :after t))
						(delete-region from to))
					   (t
						(delete-region from to)
						(let ((begin (point)) end
							  (marker (some #'(lambda (m)
												(when (= (point) (marker-point (car m)))
												  m))
											snippet-markers)))
						  (insert replacement)
						  (when marker
							(set-marker (car marker) (point)))
						  (setf end (point))
						  (apply 'set-text-attribute
								 begin end tag
								 (cdr (assoc (snippet-number tag) *snippet-attribute-dict*))))))))))
		 (snippet-expand-indent)
		 (undo-boundary)
		 (cond ((null *snippet-list*)
				(goto-char *snippet-end*)
				(backward-char)
				(snippet-clear-variable))
			   ((and (null (cdr *snippet-list*))
					 (= (snippet-number (first *snippet-list*)) 0)
					 (equal "" (snippet-default (first *snippet-list*))))
				(snippet-mode-on)
				(snippet-next))
			   (*snippet-list*
				(goto-char *snippet-begin*)
				(snippet-mode-on)
				(snippet-next))))))

(defun snippet-expand-indent (&optional change); change *this-command*
  (let ((*snippet-begin* *snippet-begin*)
		pt)
	(save-excursion
	  (goto-char *snippet-begin*)
	  (unless (bolp)
		(backward-char))
	  (skip-white-backward)
	  (setf *snippet-begin* (point)))
	(save-excursion
	  (goto-char *snippet-end*)
	  (setf pt (point)))
	(save-excursion
	  (when (and pt
				 (or (si:*closurep mode-specific-indent-command)
					 (fboundp mode-specific-indent-command)))
		(goto-char pt)
		(save-excursion
		  (forward-char)
		  (while (< (point) (marker-point *snippet-end*))
			(funcall mode-specific-indent-command)
			(goto-eol)
			(forward-char)
			;(indent-region (1+ pt) *snippet-begin*)
			))
		(goto-char *snippet-begin*)
		(while (scan-buffer "^[ 	]*\\($INDENT\\)" :regexp t :no-dup t :reverse nil
							:limit (marker-point *snippet-end*))
		  (let ((begin (match-beginning 1)))
			(goto-char begin)
			(let ((att (remove-if-not #'(lambda (x) (= (first x) (second x)))
									  (snippet-get-snippet-attribute-point))))
			  (unless att
				(funcall mode-specific-indent-command)))
			(goto-char begin)
			(scan-buffer "^[ 	]*\\($INDENT\\)" :regexp t)
			(delete-region (match-beginning 1)
						   (match-end 1))
			))))
	(when change
	  (setf *this-command* 'indent-region))))

(defun snippet-hiddens-enqueue-point (parent &key after before)
  (dolist (tag (reverse (remove-if-not
						 #'(lambda (x)
							 (= (first x) (second x) (point)))
						 (snippet-get-snippet-attributes))))
	#+:snippet
	(msgbox "enqueue : ~S~%before:~S~%after:~S~%" (third tag) *snippet-before-alist* *snippet-after-alist*)
	
	(snippet-hiddens-enqueue (third tag) parent :after after :before before)))


(defvar *snippet-pre-check* nil)
(defvar *snippet-modify-check* nil)
(defvar *snippet-modify-position* nil)

(defun snippet-modify-check (buffer operation from to undo-p)
  (setf *snippet-modify-check* t
		*snippet-modify-position* (list from to))
  (enable-post-buffer-modified-hook nil)
  (delete-hook 'post-buffer-modified-hook 'snippet-modify-check))

(defvar *snippet-before-point* nil)

(defun snippet-before ()
  (when snippet-mode-on
	;; modify command?
	(setf *snippet-pre-check* t)
	(add-hook 'post-buffer-modified-hook 'snippet-modify-check)
	(enable-post-buffer-modified-hook t)
	
	(when (and (eq *last-command* 'snippet-expand)
			   (modulep "ac-mode")
			   (eq *this-command* (intern "ac-mode-complete-or-indent" "ed")))
	  (delete-region (selection-mark) (selection-point)))
	(let* ((lst (remove-if-not
				 #'(lambda (x)
					 (= (first x) (second x) (point)))
				 (snippet-get-snippet-attributes)))
		   (parent (third (car lst))))
	  (dolist (tag (reverse (cdr lst)))
		(snippet-hiddens-enqueue (third tag) parent :after t)))
	;; 	#+:snippet
	;; 	(msgbox "0 ~S~%before:~S~%after:~S~%" (snippet-get-snippet-attributes) *snippet-before-alist* *snippet-after-alist*)
	(setf *snippet-before-point* (point))
	(if snippet-mode-on
		(setf *snippet-current-tag* (first (snippet-get-snippet-attribute-point :parent t)))
	  (setf *snippet-current-tag* nil))))

(defun snippet-after ()
  (when snippet-mode-on
	(refresh-screen)
	(cond ((find *this-command* '(quit))
		   (snippet-mode-off))
		  ((and *snippet-modify-check*
				*snippet-pre-check*
				*snippet-current-tag*)
		   (let ((from (first *snippet-current-tag*))
				 (to (second *snippet-current-tag*))
				 (snippet (third *snippet-current-tag*)))
			 (unless *executing-macro*
			   (refresh-screen))
			 (when (get-selection-type)
			   (when (<= (selection-point) (selection-mark))
				 (save-excursion
				   (delete-selection)))
			   (stop-selection))
			 (dolist (marker snippet-markers)
			   (when (= *snippet-before-point* (marker-point (car marker)))
				 (set-marker (car marker) (point))))
			 (cond ((and (not (snippet-get-snippet-attribute-point :parent t)) ;; �����t���̍Ō���ŕ�����ǉ������ꍇ
						 (find-text-attribute snippet))
					(delete-text-attributes snippet :test 'equal)
					(apply 'set-text-attribute
						   from
						   (setf to (point))
						   snippet
						   (cdr (assoc (snippet-number snippet) *snippet-attribute-dict*))))
				   ((not (find-text-attribute snippet)) ;; �S���폜�����ꍇ
					(apply 'set-text-attribute
						   from
						   (setf to (point))
						   snippet
						   (cdr (assoc (snippet-number snippet) *snippet-attribute-dict*))))
				   ((and (not (find-text-attribute-point (point))) ;; �I����ŏ��̓���
						 (find-text-attribute snippet))
					(setf from (first *snippet-modify-position*)
						  to (second *snippet-modify-position*))
					)
				   )
			 #+:snippet
			 (msgbox "1 ~S~%before:~S~%after:~S~%" (snippet-get-snippet-attributes) *snippet-before-alist* *snippet-after-alist*)

			 (save-excursion
			   (let ((str (buffer-substring from to))
					 (attributes (snippet-get-snippet-attributes)))
				 (unless *executing-macro*
				   (refresh-screen))
				 ;; surface ...
				 (dolist (attr (remove-if-not
								#'(lambda (attr)
									(= (snippet-number (third attr))
									   (snippet-number snippet)))
								(sort (snippet-get-snippet-attributes :child t) '> :key 'first)))
				   (let* ((from (first attr))
						  (to (second attr))
						  (tag (third attr))
						  (replacement (snippet-expand-meta-character str tag))
						  parent before after)
					 (cond ((and (equal replacement "")
								 (or (let ((parents (remove tag (snippet-get-snippet-attribute-point :point from)
															:key 'third :test 'equal)))
									   (and (setf parent (or (find-if 'snippet-default parents :key 'third)
															 (find from parents :key 'second :test 'equal)))
											(setf after t)))
									 (let ((parents (remove tag (snippet-get-snippet-attribute-point :point to)
															:key 'third :test 'equal)))
									   (and (setf parent (or (find-if 'snippet-default parents :key 'third)
															 (find to parents :key 'second :test 'equal)))
											(setf before t)))))
							(cond (before (snippet-hiddens-enqueue tag (third parent) :before t))
								  (after (snippet-hiddens-enqueue tag (third parent) :after t)))
							(delete-region from to))
						   ((not (equal (buffer-substring from to) replacement))
							(goto-char from)
							(delete-region from to)
							(apply 'set-text-attribute
								   (point)
								   (setf to (progn (insert replacement) (point)))
								   tag
								   (cdr (assoc (snippet-number tag) *snippet-attribute-dict*))
								   )))))
				 ;; 				 #+:snippet
				 ;; 				 (msgbox "start hidden,  from here~%~S~%" attributes)

				 ;; hidden ...
				 (save-excursion
				   (dolist (tag (sort (copy-tree *snippet-after-alist*) '>
									  :key #'(lambda (x) (first (find (first x) attributes :test 'equal :key 'third)))))
					 (let ((pos (second (find (first tag) attributes :test 'equal :key 'third)))
						   (children (second tag))
						   tmp not-insert-list)
					   (dolist (child (reverse children))
						 (let ((replacement (snippet-expand-meta-character str child)))
						   (cond ((or (/= (snippet-number child)
										  (snippet-number snippet))
									  (equal replacement ""))
								  (push child not-insert-list))
								 (t
								  (goto-char pos)
								  (snippet-hiddens-delete-child child :after t)
								  (snippet-hiddens-enqueue-point child :after t)

								  (apply 'set-text-attribute
										 (point)
										 (progn (insert replacement) (point))
										 child
										 (cdr (assoc (snippet-number child) *snippet-attribute-dict*)))
								  (push (list child not-insert-list) tmp)
								  (setf not-insert-list nil)
								  ))))
					   (dolist (x tmp)
						 (let ((parent (first x))
							   (children (second x)))
						   (dolist (child children)
							 (snippet-hiddens-delete-child child :after t)
							 (snippet-hiddens-enqueue child parent :after t))))))
				   #+:snippet
				   (msgbox "2 ~S~%before:~S~%after:~S~%" (snippet-get-snippet-attributes) *snippet-before-alist* *snippet-after-alist*)

				   (dolist (tag (sort (copy-tree *snippet-before-alist*) '<
									  :key #'(lambda (x)
											   (second (find (first x) attributes :test 'equal :key 'third)))))
					 (let ((pos (first (find (first tag) attributes :test 'equal :key 'third)))
						   (children (second tag))
						   tmp not-insert-list)
					   #+:snippet
					   (unless pos
						 (msgbox "a ~S~%~S~%before:~S~%after:~S~%" tag (snippet-get-snippet-attributes) *snippet-before-alist* *snippet-after-alist*)
						 )

					   (goto-char pos)
					   (dolist (child children)
						 (let ((replacement (snippet-expand-meta-character str child)))
						   (cond ((or (/= (snippet-number child)
										  (snippet-number snippet))
									  (equal replacement ""))
								  (push child not-insert-list))
								 (t
								  (snippet-hiddens-enqueue-point child :before t)
								  (apply 'set-text-attribute
										 (point)
										 (progn (insert replacement) (point))
										 child
										 (cdr (assoc (snippet-number child) *snippet-attribute-dict*)))
								  (push (list child not-insert-list) tmp)
								  (setf not-insert-list nil)
								  (snippet-hiddens-delete-child child :before t)))))
					   (dolist (x tmp)
						 (let ((parent (first x))
							   (children (second x)))
						   (dolist (child children) ; reverse ?
							 (snippet-hiddens-delete-child child :after t)
							 (snippet-hiddens-enqueue child parent :after t))))))))))
		   (snippet-expand-indent t)
		   ;; 		   #+:snippet
		   ;; 		   (msgbox "3 ~S~%before:~S~%after:~S~%" (snippet-get-snippet-attributes) *snippet-before-alist* *snippet-after-alist*)

		   )
		  ((and snippet-mode-on
				(find *last-command* '(snippet-expand snippet-prev snippet-next))
				(not (find *this-command* '(snippet-prev snippet-next))))
		   (stop-selection))))
  ;reset modify command flag
  (setf *snippet-modify-check* nil
		*snippet-pre-check* nil)
  )

(defun snippet-expand-meta-character (str snippet)
  (when (and str (snippet-p snippet))
	(let (result
		  (regexp (snippet-regexp snippet))
		  (format (snippet-convert-macro (snippet-format snippet)))
		  (option (snippet-option snippet)))
	  (cond ((and regexp format option
				  (string-match "g" option))
			 (let ((start 0)
				   (tmp ""))
			   (while (string-match regexp str start)
				 (setf start (match-end 0)
					   tmp (concat tmp (string-replace-match str format))))
			   (setf result tmp)))
			((and regexp format
				  (string-match regexp str))
			 (setf result (string-replace-match str format)))
			(t
			 (setf result "")))
	  result)))

(defun snippet-convert-macro (str)
  (let ((match (match-data)))
	(when (and (get-buffer-file-name) str)
	  (setf str (substitute-string str "XYZZY-FILE-NAME"                 (or (get-buffer-file-name) ""))
			str (substitute-string str "XYZZY-FILE-NAMESTRING"           (or (file-namestring (get-buffer-file-name)) ""))
			str (substitute-string str "XYZZY-FILE-DIRECTORY-NAMESTRING" (or (directory-namestring (get-buffer-file-name)) ""))
			str (substitute-string str "XYZZY-FILE-PATHNAME-NAME"        (or (pathname-name (get-buffer-file-name)) ""))
			str (substitute-string str "XYZZY-FILE-PATHNAME-TYPE"        (or (pathname-type (get-buffer-file-name)) ""))
			str (substitute-string str "XYZZY-FILE-PATHNAME-DEVICE"      (or (pathname-device (get-buffer-file-name)) ""))
			))
	(when snippet-selection
	  (setf str (substitute-string str "XYZZY-SELECTION" snippet-selection)))
	(store-match-data match)
	str))

(defun snippet-convert-xyzzy-selection ()
  (save-excursion
	(cond ((get-selection-type)
		   )
		  ((scan-buffer "${\\([0-9]\\):XYZZY-SELECTION}" :regexp t :reverse t :limit *snippet-begin*)
		   (replace-match "$\\1")))))

;;; command
(defun snippet-next (&optional prev)
  (interactive "P")
  (let* ((list (sort (snippet-get-snippet-attributes :parent t :marker t)
					 (if prev '> '<)
					 :key 'first))
		 (item (find (point) list
					 :test (if prev '> '<)
					 :key 'first)))
	(cond (item
		   (goto-char (second item))
		   (start-selection 2)
		   (goto-char (first item))
		   (let ((last (first (last list))))
			 (and last
				  (equal last item)
				  (= (point) (first last) (second last))
				  (= 0 (snippet-number (third last)))
				  (snippet-mode-off))
			 t))
		  (t
		   (snippet-mode-off)))))

(defun snippet-prev ()
  (interactive)
  (snippet-next t))

(defun snippet-mode (&optional (arg nil sv))
  (interactive "p")
  (toggle-mode 'snippet-mode-on arg sv)
  (cond (snippet-mode-on
		 (add-hook '*pre-command-hook* 'snippet-before)
		 (add-hook '*post-command-hook* 'snippet-after)
		 (and (modulep "paren")
			  (setf *snippet-last-paren-state* *paren-status*)
			  (funcall (intern "turn-off-paren"))))
		(t
		 (when (get-selection-type)
		   (stop-selection))
		 (delete-hook '*pre-command-hook* 'snippet-before)
		 (delete-hook '*post-command-hook* 'snippet-after)
		 (and (modulep "paren")
			  *snippet-last-paren-state*
			  (funcall (intern "turn-on-paren")))
		 (delete-text-attributes t :test #'(lambda (x y) (snippet-p y)))
		 (setf *snippet-list* nil
			   snippet-selection nil
			   snippet-markers nil
			   *snippet-last-paren-state* nil)
		 (snippet-clear-variable)))
  (if snippet-mode-on
	  (set-minor-mode-map *snippet-mode-map*)
	(unset-minor-mode-map *snippet-mode-map*))
  (unless *executing-macro*
	(update-mode-line))
  t)

(defun snippet-mode-on ()
  (interactive)
  (snippet-mode t))

(defun snippet-mode-off ()
  (interactive)
  (snippet-mode nil))

;;; snippet.l ends here