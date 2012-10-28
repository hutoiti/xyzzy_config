;; refer-for.l - reference.xml���������ĎQ�Ƃ���
;; -*- mode:lisp; package:refer-for -*-
;;
;; $Rev: 226 $
;;
;;
;; License
;; =======
;;
;; Copyright (c) 2003-2006 kia
;;
;; Permission is hereby granted, free of charge, to any person obtaining a
;; copy of this software and associated documentation files (the "Software"),
;; to deal in the Software without restriction, including without
;; limitation the rights to use, copy, modify, merge, publish, distribute,
;; sublicense, and/or sell copies of the Software, and to permit persons to
;; whom the Software is furnished to do so, subject to the following
;; conditions:
;;
;; The above copyright notice and this permission notice shall be included
;; in all copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
;; OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
;; IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
;; CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
;; TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
;; SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
;;
;;
;; �C���X�g�[��
;; ============
;;
;; reference.xml���K�v�ł��̂œ��肵�Ă��������B
;; <http://xyzzy.s53.xrea.com/wiki/?%A5%EA%A5%D5%A5%A1%A5%EC%A5%F3%A5%B9>��
;; �����ł��܂��B
;;
;; MSXML3.0��������MSXML4.0���K�v�ł��̂Ŗ�����Γ��肵�ăC���X�g�[�����Ă�
;; �������B<http://msdn.microsoft.com/>���炽�ǂ�Γ���ł���ł��傤�B�Ȃ��A
;; IE6���C���X�g�[������Ă����MSXML3.0�������Ă�炵���ł��i���m�F�j�B
;;
;; refer-for.l�Ɠ����ɔz�z���Ă���refer-for.xsl��refer-for-search.xsl���K�v
;; �ł��Bxyzzy���C���X�g�[�������f�B���N�g����etc�f�B���N�g���ɂ���
;; refer-for.xsl��refer-for-search.xsl���R�s�[���Ă��������B
;;
;; xyzzy���C���X�g�[�������f�B���N�g����site-lisp�f�B���N�g���ɂ���
;; refer-for.l�����܂��B
;;
;; ~/.xyzzy��refer-for�����[�h���āAuse-package ����悤�ɂ��܂��B
;; ���Ƃ��Ύ��̂悤�ɋL�q���܂��B
;;
;;     (require "refer-for")
;;     (use-package "refer-for")
;;
;; autoload�Ń��[�h�������Ƃ��ɂ͏�̑���Ɏ��̂悤�ɏ����܂��B
;;
;;     (defpackage "refer-for" (:use "lisp"))
;;     (in-package "refer-for")
;;     (export '(refer-for refer-to-titles))
;;     (in-package "user")
;;     (use-package "refer-for")
;;     (autoload 'refer-for "refer-for" t)
;;     (autoload 'refer-to-titles "refer-for" t)
;;
;; �K�v�Ȃ烊�t�@�����X�t�@�C���̃p�X����ݒ肵�܂��B
;; �f�t�H���g�� (xyzzy���C���X�g�[�������f�B���N�g��)/etc/reference.xml �ł��B
;;
;;     (setq refer-for::*reference-file* "~/reference.xml")
;;
;; �K�v�Ȃ�X�^�C���t�@�C���̃p�X����ݒ肵�܂��B
;; �f�t�H���g�� (xyzzy���C���X�g�[�������f�B���N�g��)/etc/refer-for.xsl �ł��B
;;
;;     (setq refer-for::*style-file* "~/refer-for.xsl")
;;
;; �K�v�Ȃ琳�K�\�������p�̃X�^�C���t�@�C���̃p�X����ݒ肵�܂��B
;; �f�t�H���g�� (xyzzy���C���X�g�[�������f�B���N�g��)/etc/refer-for-search.xsl �ł��B
;;
;;     (setq refer-for::*style-file-for-search* "~/refer-for-search.xsl")
;;
;; ���΃p�X�ł̎w�肪���܂������Ȃ��Ƃ��͐�΃p�X�ŋL�q���Ă݂Ă��������B
;;
;; MSXML3.0���g���Ƃ��͎��̈�s��ǉ����Ă��������B
;;
;;     (setq refer-for::*msxml-prog-id* "Msxml2.DOMDocument.3.0")
;;
;; ���K�\���Ō������s��Ȃ��Ƃ��͎��̈�s��ǉ����Ă��������B
;;
;;     (setq refer-for::*regexp-search* nil)
;;
;; �������ʂ��\�[�g���Ȃ��Ƃ��͎��̈�s��ǉ����Ă��������B
;;
;;     (setq refer-for::*sort-alphabetically* nil)
;;
;; refer-for:*refer-for-reference-file* �͔p�~�\��ł��B
;; refer-for:*refer-for-style-file* �͔p�~�\��ł��B
;; refer-for:*refer-for-style-file-for-search* �͔p�~�\��ł��B
;; refer-for:*refer-for-buffer-name* �͔p�~�\��ł��B
;; refer-for:*refer-for-msxml-prog-id* �͔p�~�\��ł��B
;; refer-for:*refer-for-regexp* �͔p�~�\��ł��B
;;
;; refer-for::*prog-id* �͔p�~���܂����B
;; refer-for::*refer-for-keep-alive* �͔p�~���܂����B
;;
;;
;; �g����
;; ======
;;
;; �R�}���h�͓����܂��Brefer-for �� refer-to-titles �ł��B
;;
;; refer-for �� reference.xml �̊echaper�̒��g�S������������̂ɑ΂��A
;; refer-to-titles �� <title>�`</title>�̕���������Ώۂɂ��Č������܂��B
;;
;; �ǂ���̃R�}���h���~�j�o�b�t�@�œ��͂ł���悤�ɂȂ�܂�����A�K���ȃL�[
;; ���[�h����͂��Ă��������B�������ăe���|�����o�b�t�@�Ɍ��ʂ�\�����܂��B
;; ��������L�[���[�h�ɂ͐��K�\�����g���܂��B�����������ɂ�JScript�G���W��
;; ���g���܂��̂ŁAXyzzy��ł̐��K�\���Ƃ͕\�L���قȂ�܂��B
;;
;; �������ʂ�\�����Ă���o�b�t�@�ł́A�f�t�H���g�Ŏ��̂悤�ɃL�[�o�C���h��
;; �g���܂��B
;;
;; b              : �O�̃y�[�W
;; SPC            : ���̃y�[�W
;; j              : �X�N���[���A�b�v
;; k              : �X�N���[���_�E��
;; J or TAB       : ���̍���(chapter)�փJ�[�\�����ړ�
;; K              : �O�̍���(chapter)�փJ�[�\�����ړ�
;; B or l or C-h  : �ŐV�̗������̂ĂāA��O�̌�����������x���s
;; s              : ���������ꗗ�̃_�C�A���O����I�����Č���
;; q              : �o�b�t�@���\������Ă���E�B���h�E���폜
;; r              : refer-for�R�}���h�̎��s
;; R              : refer-to-titles�̎��s
;; RET            : �J�[�\����Seealso���ڂ̍s�̂Ƃ��A����Seealso�̓��e�Ō���
;;
;;
;; �A�h���X
;; ========
;;
;; kia <meshinsha@yahoo.co.jp>
;; http://www.geocities.jp/kiaswebsite/

(provide "refer-for")
(defpackage "refer-for" (:use "lisp"))
(in-package "refer-for")
(shadow '(refer-for
          refer-to-titles
          refer-for-last-search
          refer-for-search-seealso
          refer-for-select-search
          refer-for-next-chapter
          refer-for-previous-chapter
          refer-for-scroll-up
          refer-for-scroll-down
          refer-for-mode
          *refer-for-mode-hook*
          *refer-for-mode-map*
          *refer-for-reference-file*
          *refer-for-style-file*
          *refer-for-style-file-for-search*
          *refer-for-regexp*
          *refer-for-buffer-name*
          *refer-for-msxml-prog-id*
          *buffer-name*
          *msxml-prog-id*
          *reference-file*
          *regexp-search*
          *search-history*
          *sort-alphabetically*
          *style-file*
          *style-file-for-search*
          add-interactive-attr-and-result-number
          create-document-object
          if-not-bound
          load-xml-object
          load-searcher-object
          nodes2list
          output
          search
          set-history
          sort-alphabetically
          ))
(export '(refer-for
          refer-to-titles
          refer-for-last-search
          refer-for-search-seealso
          refer-for-select-search
          refer-for-next-chapter
          refer-for-previous-chapter
          refer-for-scroll-up
          refer-for-scroll-down
          refer-for-mode
          *refer-for-reference-file*
          *refer-for-style-file*
          *refer-for-style-file-for-search*
          *refer-for-regexp*
          *refer-for-buffer-name*
          *refer-for-msxml-prog-id*
          *refer-for-mode-hook*
          *refer-for-mode-map*
          ))
(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "ole"))

(defvar *buffer-name* "*Reference*")
(defvar *msxml-prog-id* "Msxml2.DOMDocument.4.0")
(defvar *reference-file* (merge-pathnames "reference/reference.xml" (si:system-root)))
(defvar *regexp-search* t)
(defvar *sort-alphabetically* t)
(defvar *search-history* nil)
(defvar *style-file* (merge-pathnames "etc/refer-for.xsl" (si:system-root)))
(defvar *style-file-for-search* (merge-pathnames "etc/refer-for-search.xsl" (si:system-root)))
(defvar *refer-for-mode-hook* nil)
(defvar *refer-for-mode-map* nil)
(unless *refer-for-mode-map*
  (setq *refer-for-mode-map* (ed:make-sparse-keymap))
  (ed:define-key *refer-for-mode-map* #\b 'ed:previous-page)
  (ed:define-key *refer-for-mode-map* #\B 'refer-for-last-search)
  (ed:define-key *refer-for-mode-map* #\j 'refer-for-scroll-up)
  (ed:define-key *refer-for-mode-map* #\k 'refer-for-scroll-down)
  (ed:define-key *refer-for-mode-map* #\l 'refer-for-last-search)
  (ed:define-key *refer-for-mode-map* #\q 'ed:delete-window)
  (ed:define-key *refer-for-mode-map* #\s 'refer-for-select-search)
  (ed:define-key *refer-for-mode-map* #\C-h 'refer-for-last-search)
  (ed:define-key *refer-for-mode-map* #\TAB 'refer-for-next-chapter)
  (ed:define-key *refer-for-mode-map* #\J 'refer-for-next-chapter)
  (ed:define-key *refer-for-mode-map* #\K 'refer-for-previous-chapter)
  (ed:define-key *refer-for-mode-map* #\SPC 'ed:next-page)
  (ed:define-key *refer-for-mode-map* #\r 'refer-for)
  (ed:define-key *refer-for-mode-map* #\R 'refer-to-titles)
  (ed:define-key *refer-for-mode-map* #\RET 'refer-for-search-seealso))

(defmacro if-not-bound (v1 v2)
  `(if (boundp ',v1) ,v1 ,v2))

(defun create-document-object ()
  (let ((obj (ed:ole-create-object (if-not-bound *refer-for-msxml-prog-id* *msxml-prog-id*))))
    (setf #{obj.async} nil)
    (setf #{obj.validateOnParse} t)
    #{obj.setProperty["SelectionLanguage"]["XPath"]}
    obj))

(defun load-xml-object (fn)
  (let ((obj (create-document-object)))
    (unless #{obj.load[(ed:map-slash-to-backslash (merge-pathnames fn))]}
      (let* ((pe #{obj.parseError})
             (line #{pe.line})
             (linepos #{pe.linepos})
             (reason #{pe.reason}))
        (error "�t�@�C�������[�h�ł��܂���~2%filename = ~A~%line = ~A~%linepos = ~A~%reason = ~A" fn line linepos reason)))
    obj))

(defun load-searcher-object (s by-title)
  (flet ((set-param (sobj name val)
           #{sobj.selectSingleNode[(format nil "//*[local-name()='param'][@name='~A']" name)].setAttribute["select"][val]}))
    (let ((obj (load-xml-object (if-not-bound *refer-for-style-file-for-search* *style-file-for-search*))))
      (set-param obj "pattern" (format nil "'~A'" s))
      (set-param obj "bytitle" (if by-title 1 0))
      obj)))

(defun add-interactive-attr-and-result-number (lst)
  (let ((fmt (format nil "~~D/~D" (length lst)))
        (count 0))
    (mapc #'(lambda (node)
              #{node.setAttribute["resultNumber"][(format nil fmt (incf count))]}
              (let ((title #{node.selectSingleNode["title"]})
                    (type #{node.selectSingleNode["type"]}))
                (if (and (string-equal #{type.text} "Function")
                         (ed:commandp (find-symbol #{title.text} "user")))
                    #{type.setAttribute["interactive"]["t"]})))
          lst)))

(defun nodes2list (nodes)
  (let (lst)
    (do ((n (1- #{nodes.length}) (1- n)))
        ((< n 0) lst)
      (setq lst (cons #{nodes.item[n]} lst)))))

(defun search (s &key by-title)
  (nodes2list
   (if (if-not-bound *refer-for-regexp* *regexp-search*)
       (let ((obj (load-xml-object (if-not-bound *refer-for-reference-file* *reference-file*)))
             (sobj (load-searcher-object s by-title))
             (result (create-document-object)))
         #{obj.transformNodeToObject[sobj][result]}
         #{result.documentElement.childNodes})
     (let ((obj (load-xml-object (if-not-bound *refer-for-reference-file* *reference-file*))))
       #{obj.documentElement.selectNodes[(format nil "//chapter[contains(~A, '~A')]" (if by-title "title" ".") s)]}))))

(defun set-history (str &optional by-title)
  (let ((p (cons str by-title)))
    (setq *search-history* (cons p (delete p *search-history* :test #'equal)))))

(defun output (lst)
  (flet ((remove-cr (s) (ed:substitute-string s "\r" "")))
    (let ((obj (load-xml-object (if-not-bound *refer-for-style-file* *style-file*))))
      (ed:with-output-to-temp-buffer ((if-not-bound *refer-for-buffer-name* *buffer-name*))
        (mapc #'(lambda (n) (princ (remove-cr #{n.transformNode[obj]}))) (add-interactive-attr-and-result-number (if *sort-alphabetically* (sort-alphabetically lst) lst))))
      (message "~D��������܂���" (length lst))
      (refer-for-mode))))

(defun sort-alphabetically (lst)
  (mapcar #'cdr (sort (mapcar #'(lambda (n) (cons #{n.selectSingleNode["title"].text} n)) lst) #'string< :key #'car)))

(defun refer-for (s)
  (ed:interactive (list (ed:read-string (format nil "refer-for~A: " (if (if-not-bound *refer-for-regexp* *regexp-search*) "(Regexp)" "")))))
  (let ((lst (search s)))
    (if lst
        (progn
          (output lst)
          (ed:refresh-screen)
          (refer-for-next-chapter)
          (set-history s))
      (message "�����񂪌�����܂���"))))

(defun refer-to-titles (s)
  (ed:interactive (list (ed:read-string (format nil "refer-to-titles~A: " (if (if-not-bound *refer-for-regexp* *regexp-search*) "(Regexp)" "")))))
  (let ((lst (search s :by-title t)))
    (if lst
        (progn
          (output lst)
          (ed:refresh-screen)
          (refer-for-next-chapter)
          (set-history s t))
      (message "�����񂪌�����܂���"))))

(defun refer-for-last-search ()
  (ed:interactive)
  (if (cadr *search-history*)
      (progn
        (pop *search-history*)
        (let ((last (car *search-history*)))
          (when last
            (if (cdr last)
                (refer-to-titles (car last))
              (refer-for (car last))))))
    (message "������O�̌��������͂���܂���")))

(defun refer-for-search-seealso ()
  (ed:interactive)
  (flet ((seealso-value ()
           (ed:save-excursion
             (ed:goto-eol)
             (let ((pnt (ed:point)))
               (ed:goto-bol)
               (if (ed:scan-buffer "^\\[See also   \\]: \\(.+\\)$" :regexp t :limit pnt)
                   (string-trim " \t" (ed:buffer-substring (ed:match-beginning 1) (ed:match-end 1))))))         ))
    (let ((str (seealso-value)))
      (when str
        (let ((str (if (if-not-bound *refer-for-regexp* *regexp-search*)
                       (format nil "^~A$" (ed:regexp-quote str))
                     str)))
          (output (search str :by-title t))
          (set-history str t))))))

(defun refer-for-select-search ()
  (ed:interactive)
  (if *search-history*
      (multiple-value-bind (result data)
          (ed:dialog-box '(ed:dialog 0 0 260 120
                           (:caption "refer-for: ���������ꗗ")
                           (:font 9 "MS UI Gothic")
                           (:control
                            (:listbox list nil #x50b10111 4 5 192 114)
                            (:button IDOK "OK" #x50010001 205 5 52 14)
                            (:button IDCANCEL "�L�����Z��" #x50010000 205 22 52 14)))
                         (list (cons 'list (mapcar #'(lambda (x)
                                                       (cons (ed:concat (car x) (if (cdr x) " <title>")) x))
                                                   *search-history*)))
                         '((list :must-match t :enable (IDOK))))
        (when result
          (let ((tmp (cddr (assoc 'list data))))
            (output (search (car tmp) :by-title (cdr tmp))))))
    (message "���������͂���܂���")))

(defun refer-for-next-chapter ()
  (ed:interactive)
  (unless (ed:scan-buffer "^��" :regexp t :no-dup t)
    (message "���ɍŌ�̍��ڂł�"))
  (ed:recenter 1))

(defun refer-for-previous-chapter ()
  (ed:interactive)
  (unless (ed:scan-buffer "^��" :regexp t :no-dup t :reverse t)
    (message "���ɍŏ��̍��ڂł�"))
  (ed:recenter 1))

(defun refer-for-scroll-up ()
  (ed:interactive)
  (ed:scroll-window 1))

(defun refer-for-scroll-down ()
  (ed:interactive)
  (ed:scroll-window -1))

(defun refer-for-mode ()
  (ed:interactive)
  (ed:kill-all-local-variables)
  (setq ed:mode-name "ReferFor")
  (setq ed:buffer-mode 'refer-for-mode)
  (setq ed:buffer-read-only t)
  (ed:use-keymap *refer-for-mode-map*)
  (ed:run-hooks '*refer-for-mode-hook*))

;;; refer-for.l �͂����܂�