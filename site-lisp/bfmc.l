
(provide "bfmc")
(in-package "editor")

(defun bfmc-version nil
  (interactive)
  (and (interactive-p)
       (message "bfmc lapse ~A on 2010-11-13 18:30" (bfmc-version)))
  "007")

#| buffer frame marker controller for xyzzy-0.2.2.235

Copyright (c) 2008-2010 knenet \kneneglect_std(^o^)yahoo.co.jp/

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

MIT���C�Z���X�ł��B����҂𖾂炩�ɂ���ΓK���Ɏg���ėǂ��ł��B
���̃\�t�g�̎g�p�ɂ���Đ��������v�ɂ��āA����҂͈�ؐӔC�������܂���B

���T�v

list-buffers��pseudo-frame-selector�����킹���悤�Ȃ��̂ł��B
���ł�pseudo-frame�̑��삪�o���܂��B�}�[�J�]�X�͖������ł��B

������

(require "bfmc")

��.xyzzy�ɏ����Ȃǂ��ēǂݍ��݂܂��B
netinstaller��p���ăC���X�g�[�������ꍇ�͕s�v�ł��B

(define-key esc-map #\C-j 'bfmc-menu)
(define-key esc-map #\J 'bfmc-menu-frame)

�ȂǂƍD�݂ɉ����ăL�[�o�C���h���܂��B

�A���C���X�g�[���͂��̃t�@�C�����폜���ď�L�ݒ蓙�������΂����ł��B

���g�p���@

bfmc-menu�ŌĂяo���܂��Bbfmc-menu-frame��pseudo-frame�s����n�܂邾���ł��B
�I���������o�b�t�@��t���[�����\������Ă�s�ɍ��킹��C-m��j�őI�����܂��B
�\���̌����͈ȉ��̒ʂ�ł��B

�E�o�b�t�@�s
�I���o�b�t�@(>) �폜�\��(!) �ǂݎ���p�^�v�ۑ�(%*)
�o�b�t�@�� ���[�h �s�� ������ �i���[�C���O ��ƃf�B���N�g��

�E�t���[���s
�I���t���[��(>) �폜�\��(!) �t���[���� ... �֘A�o�b�t�@(<�I���o�b�t�@>)

���ɁA��G�c�ȃL�[�����������܂��B
C-m C-j j ���ڂ�I������bfmc�𔲂��܂��B
g �\������Ă����Ԃ�bfmc�𔲂��܂��B
q ��Ƃ𒆒f����bfmc�𔲂��܂��B
p n �㉺�s�Ɉړ����܂��B
f b �t���[���E�o�b�t�@�Ɉړ����܂��B
    Universal Argment�őI���s���瑊�ΓI�ɍs�w��ł��܂��B
l �o�b�t�@��I�����܂��B
o �E�B���h�E��S�ĕ��đI���o�b�t�@�Ɉړ����܂��B
v h �����A�����ɃE�B���h�E�𕪊����Ă���I���o�b�t�@�Ɉړ����܂��B
u d �I���t���[���ŃE�B���h�E��O��Ɉړ����܂��B
t �I���t���[���Ō��݂̃E�B���h�E����܂��B
w ���݂̃t���[���̕���������đI�����܂��B
x �I���t���[���̏�Ԃ�\�����܂��B
i ���݂̍s�̃o�b�t�@�����ȗ������Ƀ|�b�v�A�b�v�ŕ\�����܂��B
k �폜�\���؂�ւ��܂��B�폜�\��(!)�̂����A�C�e����bfmc�I�����ɍ폜����܂��B
  �o�b�t�@�폜�͕W���ł�kill-buffer�Ȃ̂ŁA�ۑ����K�v�Ȃ炻�̂Ƃ��Ɋm�F����܂��B
R �폜�\������s���܂��B
z Z c C ���ꂼ��E�B���h�E���c�Ɋg��k���A���Ɋg��k�����܂��B
        Universal Argument�ŕψʂ��w��ł��A�����A�����Ƃɕψʗʂ�ۑ����܂��B

�t���[������͈�x�t���[���Ɉړ����܂��B�m�F���K�v�Ȃ��悤�ȏꍇ���\������܂����A
����͎d�l�ł��B

�����̑��ݒ�

�O���[�o���ϐ���֐�������Ε�����Ǝv���܂����A���肻���Ȃ��̂������������Ă����܂��B

�E�Ȃ����݃o�b�t�@�^�t���[������n�܂�Ȃ��H
*bfmc-cursor-at-open* �ŊJ�n�s��␳���Ă��܂��B0�ɂ���ƌ��݂̍��ڂ���n�܂�܂��B

�E�\�������o�b�t�@��t���[���𐧌䂵�����B
*bfmc-buffer-filters* *bfmc-frame-filters* ���t�B���^�̃��X�g�ɂȂ��Ă܂��B
���K�\���ň�v����A�C�e����\������O���܂��B
pushnew������Ő��K�\������ǉ�����Ɨǂ��ł��B
���O�̈ꕔ���ȗ��������ꍇ�� *bfmc-substitute-buffer-name* �Œu�����܂��B

(setq *bfmc-tbf* (list '("^\\*bfmc\\*$" "^ ") '("^\\*bfmc\\*$")))
(setf (cdr (last *bfmc-tbf*)) *bfmc-tbf*)

(defun bfmc-toggle-buffer-filters ()
  "�o�b�t�@�\���t�B���^��؂�ւ���"
  (interactive)
  (setq *bfmc-buffer-filters* (pop *bfmc-tbf*))
  (ed::bfmc-refresh))

�͂��D�݂ŁB

�E�C���N�������^���T�[�`�������B
(defun bfmc-isearch-buffer ()
  (interactive)
  (ed::bfmc-move-to-buffer 1)
  (isearch-forward))
(defun bfmc-isearch-frame ()
  (interactive)
  (ed::bfmc-move-to-frame 1)
  (isearch-forward))

�Ƃł������܂��B

�E����t���[���������Ȃ��B�Ԉ���ď����Ă��܂��o�b�t�@������B
*bfmc-no-rename-frames* *bfmc-no-delete-buffers*
�ő��삵�Ȃ��t���[���A�폜�\�񂵂Ȃ��o�b�t�@���Ǘ����Ă��܂��B
string=�Ŋm�F���Ă���̂ŁAremove��pushnew�Œ������Ă��������B
�܂��A�o�b�t�@��*bfmc-buffer-deleter*�ō폜�֐����w��ł��܂��B


netinstaller�ł�autoload���Ă���̂ŁA*bfmc-mode-map*�ւ̒ǉ���

(defun bfmc-load-strap ()
  (define-key *bfmc-mode-map* #\e 'bfmc-toggle-buffer-filters)
  (define-key *bfmc-mode-map* #\s 'bfmc-isearch-buffer)
  (define-key *bfmc-mode-map* #\S 'bfmc-isearch-frame)
  (delete-hook '*bfmc-mode-hook* 'bfmc-load-strap))
(add-hook '*bfmc-mode-hook*  'bfmc-load-strap)

�Ƃł������ĉ������B

�����m�̃o�O
�E�B���h�E���������ƁA�u�폜���ꂽ�E�B���h�E�ł��v�Ƃ������b�Z�[�W��
�ł邱�Ƃ�����܂��B���̉���̂��߂ɑ���Ώۂ̃t���[����\�����Ă����
�ł����A����ł��o�Ă��܂����Ƃ�����܂��B
���̏ꍇ�́A�K���Ƀt���[���ړ����邩�AM-x�ȂǂŃ~�j�o�b�t�@�Ɉړ������
����悤�ł��B�m���ȉ����@������΋����Ă�����������

���X�V����
007 2010-11-13 18:30 �t���[���쐬�̋����ύX
�@�@�@�@�@�@�@�@�@�@ �o�b�t�@�̕\�����@��ύX
�@�@�@�@�@�@�@�@�@�@ �E�B���h�E�����R�}���h(t)��ǉ�
�@�@�@�@�@�@�@�@�@�@ �o�b�t�@����\������R�}���h(i)��ǉ�
�@�@�@�@�@�@�@�@�@�@ �t���[���ړ��̃o�O�����������������
006 2009-08-14 09:50 buggy�������̂�macro�̈ʒu��ύX�B
005 2009-08-13 22:55 �I�𓙂̑��������Ƃ��񂲂��X�y�[�X���\�������o�O���C���B
003 2009-01-03 21:12 �����Ƃ�ni-autoload�Ƃ���netinstaller�ɑΉ������B
002 2008-12-23 22:14 ���O��u������t�B���^��t�����B�\����܂�Ԃ��Ȃ��悤�ɂ����B
�@�@�@�@�@�@�@�@�@�@ �o���邾���\��������Ȃ��悤�ɂ����B
001 2008-12-22 08:56 �ł����B

���������|#

(defvar *bfmc-buffer* "*bfmc*" "bfmc menu�̃o�b�t�@��")
(defvar *bfmc-frame* "bfmc" "bfmc menu�̃t���[����")
(defvar *bfmc-buffer-filters* '("^\\*bfmc\\*$" "^ ") "bfmc�ŕ\�����Ȃ��o�b�t�@(regexp)")
(defvar *bfmc-frame-filters* '("^bfmc$") "bfmc�ŕ\�����Ȃ��t���[��(regexp)")
(defvar *bfmc-no-delete-buffers* '("*scratch*") "bfmc�ō폜���Ȃ��o�b�t�@")
(defvar *bfmc-no-rename-frames* '("Den8" "2ch") "bfmc�Ń��l�[�����Ȃ��t���[��")
(defvar *bfmc-wait* 0.5 "�t���[����\�����鎞��")
(defvar *bfmc-buffer-deleter* 'kill-buffer "bfmc�Ńo�b�t�@���폜����R�}���h")
(defvar *bfmc-cursor-at-open* 1 "bfmc���N������Ƃ��̑I���s�␳")
(defvar *bfmc-mode-hook* nil)
(defvar *bfmc-substitute-buffer-name* '(("^ " "MINIBUF:")) "bfmc�ŕ\������o�b�t�@���̒u�����X�g")
(defvar *bfmc-buffer-bar-order* t "bfmc�̕\�����o�b�t�@�o�[�ɍ��킹�邩�ǂ���")

(export '(*bfmc-buffer-filters* *bfmc-frame-filters* *bfmc-no-delete-buffers* *bfmc-no-rename-frames* *bfmc-mode-hook*
		  *bfmc-substitute-buffer-name* *bfmc-wait* *bfmc-buffer-deleter* *bfmc-cursor-at-open* *bfmc-mode-map*
		  *bfmc-buffer-bar-order*
		  bfmc-menu bfmc-menu-frame))
;��̐����Ŗ��O�o�����̂����B����hook�B

(defvar *bfmc-mode-map* nil)
(unless *bfmc-mode-map*
  (setq *bfmc-mode-map* (make-sparse-keymap))
  (define-key *bfmc-mode-map* #\g 'bfmc-g)
  (define-key *bfmc-mode-map* #\LFD 'bfmc-enter)
  (define-key *bfmc-mode-map* #\RET 'bfmc-enter)
  (define-key *bfmc-mode-map* #\j 'bfmc-enter)
  (define-key *bfmc-mode-map* #\p 'bfmc-previous-line)
  (define-key *bfmc-mode-map* #\n 'bfmc-next-line)
  (define-key *bfmc-mode-map* #\f 'bfmc-move-to-frame)
  (define-key *bfmc-mode-map* #\b 'bfmc-move-to-buffer)
  (define-key *bfmc-mode-map* #\w 'bfmc-new-frame)
  (define-key *bfmc-mode-map* #\k 'bfmc-kill-toggle)
  (define-key *bfmc-mode-map* #\d 'bfmc-next-window)
  (define-key *bfmc-mode-map* #\u 'bfmc-previous-window)
  (define-key *bfmc-mode-map* #\t 'bfmc-close-window)
  (define-key *bfmc-mode-map* #\l 'bfmc-select)
  (define-key *bfmc-mode-map* #\R 'bfmc-refresh)
  (define-key *bfmc-mode-map* #\o 'bfmc-select-alone)
  (define-key *bfmc-mode-map* #\v 'bfmc-select-vertical)
  (define-key *bfmc-mode-map* #\h 'bfmc-select-horizontal)
  (define-key *bfmc-mode-map* #\x 'bfmc-preview)
  (define-key *bfmc-mode-map* #\r 'bfmc-rename-frame)
  (define-key *bfmc-mode-map* #\q 'bfmc-quit)
  (define-key *bfmc-mode-map* #\i 'bfmc-popup-info)
  (define-key *bfmc-mode-map* #\Z 'bfmc-shrink-window-vertical)
  (define-key *bfmc-mode-map* #\z 'bfmc-enlarge-window-vertical)
  (define-key *bfmc-mode-map* #\C 'bfmc-shrink-window-horizontal)
  (define-key *bfmc-mode-map* #\c 'bfmc-enlarge-window-horizontal))

(setq bfmc-table nil bfmc-cur-buffer nil bfmc-cur-frame nil bfmc-last-buffer nil bfmc-last-frame nil
	  bfmc-count nil bfmc-fp nil bfmc-delete-buffer-list nil bfmc-delete-frame-list nil
	  bfmc-cur-buffer-line 0 bfmc-cur-frame-line 0
	  bfmc-frame nil bfmc-buffer nil)

(eval-when (:compile-toplevel :execute)
(defmacro bfmc-force-write (&rest arg)
  (let ((r (gensym)))
	`(let ((,r buffer-read-only))
	   (setq buffer-read-only nil)
	   (prog1 (progn ,@arg)
		 (setq buffer-read-only ,r)))))

(defmacro bfmc-kill-toggle-sub (line N rimbo &optional except)
  (let ((target (gensym))
		(p (gensym)))
	`(let* ((,target (gethash ,line bfmc-table))
			(,p (if (or (eq ,N t) (eq ,N nil)) ,N
				  (if (= ,N 0) (not (member ,target ,rimbo))
					(> N 0)))))
	   (if ,p ,(if except `(if (member-if-not 'null (map 'list (lambda (x) (funcall (bfmc-match-name-func 'buffer-name x) ,target)) ,except))
							   (message "~A �͏����Ȃ���" (bfmc-substituted-buffer-name ,target))
							  (pushnew ,target ,rimbo))
				 `(pushnew ,target ,rimbo))
		 (setq ,rimbo (delete ,target ,rimbo)))
	   (bfmc-rewrite ,line))))

(defmacro bfmc-with-current (item &rest arg)
  ; ���ڂ��擾���Ă����B
  `(let ((,item (gethash (current-line-number) bfmc-table)))
	 ,@arg))

(defmacro bfmc-sel-frame (item)
 ; "���ڂ��t���[������Ȃ��Ƃ���bfmc-cur-frame��"
  `(if (not (pseudo-frame-p ,item)) (setq ,item bfmc-cur-frame)))

(defmacro bfmc-with-frame (frame &rest arg)
  ; �t���[���ɑ΂��鑀��
  (let ((cur (gensym)))
	`(let ((,cur (selected-pseudo-frame)))
	   (prog2
		   (select-pseudo-frame ,frame)
		   (progn ,@arg)
		 (refresh-screen) (sit-for *bfmc-wait*) ; �o�O�����炵���O���Ȃ��̂ł��B
		 (select-pseudo-frame ,cur))))))

(defun bfmc-menu (&optional N)
  "bfmc-mode ���j���[���J��"
  (interactive "p")
  (bfmc-menu-sub 0 N))

(defun bfmc-menu-frame (&optional N)
  "bfmc-mode ���j���[���J��"
  (interactive "p")
  (bfmc-menu-sub 1 N))

(defun bfmc-menu-sub (index displacement)
  ;���j���[�\��
  (or (eq bfmc-buffer (selected-buffer))
	  (eq bfmc-frame (selected-pseudo-frame))
	  (setq bfmc-cur-buffer (selected-buffer)
			bfmc-cur-frame (selected-pseudo-frame)
			bfmc-last-buffer bfmc-cur-buffer
			bfmc-last-frame bfmc-cur-frame))
  (if displacement nil (setq displacement *bfmc-cursor-at-open*))
  (if (setq bfmc-frame (find-pseudo-frame *bfmc-frame*))
	  (select-pseudo-frame bfmc-frame)
	(setq bfmc-frame (new-pseudo-frame *bfmc-frame*)))
  (or (setq bfmc-buffer (find-buffer *bfmc-buffer*))
	  (setq bfmc-buffer (get-buffer-create *bfmc-buffer*)))
  (set-buffer bfmc-buffer)
  (kill-all-local-variables)
  (make-local-variable 'buffer-read-only)
  (make-local-variable 'need-not-save)
  (make-local-variable 'kept-undo-information)
  (make-local-variable 'auto-save)
  (setq buffer-read-only t ; ����������Ƃ�����nil�ɁB
		need-not-save t
		kept-undo-information nil
		auto-save nil)
  (set-local-window-flags bfmc-buffer *window-flag-cursor-line* t)
  (set-buffer-fold-width nil bfmc-buffer)
  (setf buffer-mode 'bfmc-mode)
  (setf mode-name "bfmc-mode")
  (use-keymap *bfmc-mode-map*)
  (bfmc-construct-menu)
  (case index
	(0 (bfmc-move-to-buffer (+ bfmc-cur-buffer-line displacement) t))
	(1 (bfmc-move-to-frame (+ bfmc-cur-frame-line displacement) t)))
  (run-hooks '*bfmc-mode-hook*))

(defun bfmc-apply-filter (-name data-list filter-list)
  "(alias -> name) list:alias list:regexp -> list:alias"
  (reduce (lambda (data-list regexp) (remove-if (bfmc-match-name-func -name regexp) data-list))
		  (append (list data-list) filter-list)))

(defun bfmc-match-name-func (-name regexp)
  "(alias -> name) regexp -> (alias -> bool)"
  (lambda (x) (string-match regexp (funcall -name x))))

(defun bfmc-goto-line (n from to)
  "���[�v�d�l"
  (goto-line (- n (* (floor (- n from) (- to from)) (- to from)))))

(defun bfmc-add-frame (frame)
  "�t���[���s�ǉ�"
  (setf (gethash bfmc-count bfmc-table) frame)
  (if (equal bfmc-cur-frame frame) (setq bfmc-cur-frame-line bfmc-count))
  (bfmc-frame-format 'bfmc-line bfmc-fp frame))

(defun bfmc-add-buffer (buffer)
  "�o�b�t�@�s�\��"
  (setf (gethash bfmc-count bfmc-table) buffer)
  (if (equal bfmc-cur-buffer buffer) (setq bfmc-cur-buffer-line bfmc-count))
  (bfmc-buffer-format 'bfmc-line bfmc-fp buffer))

(defun bfmc-rewrite (line)
  "�s��������"
  (let ((obj (gethash line bfmc-table)))
	(cond
	 ((bufferp obj)
	  (bfmc-buffer-format (bfmc-force-format) (bfmc-rewrite-line-stream line) obj))
	 ((pseudo-frame-p obj)
	  (bfmc-frame-format (bfmc-force-format) (bfmc-rewrite-line-stream line) obj)))))


(defun bfmc-force-format ()
  (lambda (&rest arg) (bfmc-force-write (apply 'format arg))))

(defun bfmc-rewrite-line-stream (line)
  (save-excursion
	(set-buffer bfmc-buffer)
	(goto-line line)
	(bfmc-delete-line)
	(make-buffer-stream bfmc-buffer (point))))

(defun bfmc-delete-line ()
  (bfmc-force-write (delete-region (progn (goto-bol) (point)) (progn (goto-eol)(point)))))

(defun frame-buffers-format (cur-window window-list)
  ;�t���[���s�̃o�b�t�@
  (apply 'concat (map 'list #'(lambda (x) (concat " " (frame-buffer-format (cadr x) (eq cur-window (car x)))))
					  window-list)))

(defun bfmc-line (fp str &rest format)
  ;�\���s�𐔂���format
  (incf bfmc-count)
  (push (concat str "~%") format)
  (push fp format)
  (apply (bfmc-force-format) format))

(defun frame-buffer-format (buffer current-p)
  ;�t���[���s�̃o�b�t�@1��
  (let ((bn (if (deleted-buffer-p buffer)
				"deleted" (bfmc-substituted-buffer-name buffer))))
	(if current-p (concat "<" bn ">") bn)))

(defun bfmc-substituted-buffer-name (buffer)
  "���O�Ƀt�B���^�������āA�ȗ�����B"
  (abbreviate-display-string
   (reduce (lambda (str filter) (substitute-string str (car filter) (cadr filter)))
			   (append (list (buffer-name buffer)) *bfmc-substitute-buffer-name*))
   33))

(defun bfmc-buffer-info (buffer)
  (save-excursion
	(set-buffer buffer)
	(values (format nil "~A~{/~A~}" mode-name
					(map 'list #'(lambda (x) (if (symbolp (cdr x)) (symbol-value (cdr x)) (cdr x)))
						 (remove 'nil *minor-mode-alist* :key #'(lambda (x) (symbol-value (car x))))))
			buffer-read-only
			(need-buffer-save-p buffer)
			(- (buffer-size) (- (point-max) (point-min)))
			(point-min)
			(point-max)
			(format nil "~33A" (if (deleted-buffer-p buffer) "|deleted|"
								 (bfmc-substituted-buffer-name buffer)))
			(default-directory))))

(defun bfmc-buffer-format (func fp buffer)
  "�o�b�t�@�s�̌`��"
  (multiple-value-bind
	  (mode ro ns narrowp pmin pmax bname bpath)
	  (bfmc-buffer-info buffer)
	(let* ((diff-length (- 57 (count-column bname) (count-column mode)))
		   (lines (format nil "~vD"
					(max (+ 8 (min diff-length 0)) 1)
					(buffer-lines buffer)))
		   (size (format nil "~vD"
				   (max (+ 10 (min diff-length 0) (- 8 (length lines))) 1)
				   (buffer-size buffer))))
	  (funcall func fp "~:[ ~;>~]~:[ ~;!~]~A ~A ~@vT~A ~A ~A~A ~A"
			   (eq bfmc-cur-buffer buffer)
			   (member buffer bfmc-delete-buffer-list)
			   (if ro "%" (if ns "*" " "))
			   ;
			   bname
			   (max diff-length 0)
			   mode
			   lines
			   size
			   (if (= narrowp 0) "" (format nil " (~A-~A)" pmin pmax))
			   bpath))))

(defun bfmc-frame-format (func fp frame)
  "�t���[���s�̌`��" format
  (funcall func fp "~:[ ~;>~]~:[ ~;!~] ~15A .~A"
		   (equal bfmc-cur-frame frame)
		   (member frame bfmc-delete-frame-list)
		   (pseudo-frame-name frame)
		   (frame-buffers-format (cadr (pseudo-frame-winconf frame))
								 (caddr (pseudo-frame-winconf frame)))))

(defun bfmc-construct-menu ()
  "bfmc menu�\���X�V"
  (setq bfmc-table (make-hash-table :size 11)
		bfmc-count 1
		bfmc-fp (make-buffer-stream bfmc-buffer 0))
  (erase-buffer bfmc-buffer)
  (bfmc-line bfmc-fp "cks~@23Tbuffer-name~@10Tmode/minor-mode~@4Tlines~@7Tsize (narrow) directory")
  (setq buffer-start-line bfmc-count)
  (dolist (buffer (bfmc-apply-filter 'buffer-name
									 (buffer-list :buffer-bar-order *bfmc-buffer-bar-order*)
									 *bfmc-buffer-filters*))
	(bfmc-add-buffer buffer))
  (setq buffer-end-line bfmc-count)
  (bfmc-line bfmc-fp "")
  (bfmc-line bfmc-fp  "ck~@6Tframe-name~@3Tbuffers-of-frame" )
  (setq frame-start-line bfmc-count)
  (dolist (frame (bfmc-apply-filter 'pseudo-frame-name *pseudo-frame-list* *bfmc-frame-filters*))
	(bfmc-add-frame frame))
  (setq frame-end-line bfmc-count))

(defun bfmc-refresh (&optional (N 1))
  "�Ƃ肠�����������肳����B"
  (interactive "p")
  (map nil 'delete-pseudo-frame bfmc-delete-frame-list)
  (map nil *bfmc-buffer-deleter* bfmc-delete-buffer-list)
  (setq bfmc-delete-frame-list nil bfmc-delete-buffer-list nil)
  (bfmc-construct-menu)
  (if (> N 0)(bfmc-move-to-buffer)(bfmc-move-to-frame)))

(defun bfmc-enter ()
  "�I���o�b�t�@�E�t���[���Ɉړ�"
  (interactive)
  (bfmc-with-current target
	(cond
	 ((bufferp target) (bfmc-exit bfmc-cur-frame target))
	 ((pseudo-frame-p target) (bfmc-exit target))
	 (t (error "�Ȃ���B")))))

(defun bfmc-new-frame ()
  "�t���[�����쐬���đI��"
  (interactive)
  (let ((line (current-line-number))
		(winconf (bfmc-with-frame bfmc-cur-frame
				   (copy-list (pseudo-frame-winconf bfmc-cur-frame)))))
	(setq bfmc-cur-frame (call-interactively 'new-pseudo-frame))
	(set-window-configuration winconf)
	(select-pseudo-frame bfmc-frame)
	(bfmc-construct-menu)
	(goto-line line)))

(defun bfmc-move-to-buffer (&optional N ab)
  "�o�b�t�@�s�Ɉړ�"
  (interactive "p")
  (bfmc-goto-line (if N (if ab N (+ buffer-start-line N -1)) bfmc-cur-buffer-line)
				  buffer-start-line buffer-end-line))

(defun bfmc-move-to-frame (&optional N ab)
  "�t���[���s�Ɉړ�"
  (interactive "p")
  (bfmc-goto-line (if N (if ab N (+ frame-start-line N -1)) bfmc-cur-frame-line)
				  frame-start-line frame-end-line))

(defun bfmc-rename-frame ()
  "�t���[���̖��O��ς���"
  (interactive)
  (bfmc-with-current sel
	(bfmc-sel-frame sel)
	(if (member (pseudo-frame-name sel) *bfmc-no-rename-frames* :test 'string=)
		(error "~A �͕ς��Ȃ���B" (pseudo-frame-name sel))
	  (let ((n (read-string "�t���[����: " :default (pseudo-frame-name sel))))
		(if (member n *bfmc-no-rename-frames* :test 'string=)
			(error "~A �͗\�񂳂�Ă��B" n)
		  (progn (bfmc-with-frame sel (trap-errors (rename-pseudo-frame n)))
			(bfmc-rewrite (if (eq sel bfmc-cur-frame) bfmc-cur-frame-line (current-line-number)))))))))

(defun bfmc-kill-toggle (&optional (N 0))
  "�A�C�e���폜�t���O�̐؂�ւ�" ;0�Ńg�O������
  (interactive "p")
  (bfmc-with-current sel
	(cond
	 ((bufferp sel) (bfmc-kill-toggle-sub (current-line-number) N bfmc-delete-buffer-list *bfmc-no-delete-buffers*))
	 ((pseudo-frame-p sel) (bfmc-kill-toggle-sub (current-line-number) N bfmc-delete-frame-list))
	 (t (error "�Ȃ���B"))))
  (bfmc-next-line))

(defun bfmc-next-line ()
  "�K���ɐ܂�Ԃ�"
  (interactive)
  (cond
   ((eq (current-line-number) (1- buffer-end-line)) (goto-line buffer-start-line))
   ((eq (current-line-number) (1- frame-end-line)) (goto-line frame-start-line))
   (t (next-line))))

(defun bfmc-previous-line ()
  "�K���ɐ܂�Ԃ�"
  (interactive)
  (cond
   ((eq (current-line-number) buffer-start-line) (goto-line (1- buffer-end-line)))
   ((eq (current-line-number) frame-start-line) (goto-line (1- frame-end-line)))
   (t (previous-line))))

(defun bfmc-select ()
  "�I������B"
  (interactive)
  (bfmc-with-current sel
	(cond ((bufferp sel)
		   (setq bfmc-cur-buffer sel)
		   (bfmc-rewrite bfmc-cur-buffer-line)
		   (bfmc-rewrite (setq bfmc-cur-buffer-line (current-line-number)))
;		   (bfmc-with-frame bfmc-cur-frame (set-buffer bfmc-cur-buffer))
		   (bfmc-rewrite bfmc-cur-frame-line))
		  ((pseudo-frame-p sel)
		   (setq bfmc-cur-frame sel)
		   (bfmc-rewrite bfmc-cur-frame-line)
		   (bfmc-rewrite (setq bfmc-cur-frame-line (current-line-number)))
		   (bfmc-move-to-buffer))
		  (t (message "�Ȃ���")))))

(defun bfmc-select-vertical (&optional N)
  "���������ɕ������đI��"
	(interactive "p")
  (bfmc-with-current sel
	(bfmc-with-frame (if (pseudo-frame-p sel) sel bfmc-cur-frame)
	  (trap-errors (split-window N t)) (set-buffer (if (bufferp sel) sel bfmc-cur-buffer)))
	(bfmc-rewrite (if (pseudo-frame-p sel) (current-line-number) bfmc-cur-frame-line))))

(defun bfmc-select-horizontal (&optional N)
  "���������ɕ������đI��"
	(interactive "p")
  (bfmc-with-current sel
	(bfmc-with-frame (if (pseudo-frame-p sel) sel bfmc-cur-frame)
	  (trap-errors (split-window N nil)) (set-buffer (if (bufferp sel) sel bfmc-cur-buffer)))
	(bfmc-rewrite (if (pseudo-frame-p sel) (current-line-number) bfmc-cur-frame-line))))

(let ((arg 4))
  (defun bfmc-enlarge-window-vertical (&optional N)
	"�E�B���h�E���c�Ɋg��"
	(interactive "p")
	(if N (setq arg N))
	(bfmc-with-current sel (bfmc-with-frame (if (pseudo-frame-p sel) sel bfmc-cur-frame) (trap-errors (enlarge-window arg)))))

  (defun bfmc-shrink-window-vertical (&optional N)
	"�E�B���h�E���c�ɏk��"
	(interactive "p")
	(if N (setq arg N))
	(bfmc-with-current sel (bfmc-with-frame (if (pseudo-frame-p sel) sel bfmc-cur-frame) (trap-errors (shrink-window arg))))))

(let ((arg 4))
  (defun bfmc-enlarge-window-horizontal (&optional N)
	"�E�B���h�E�����Ɋg��"
	(interactive "p")
	(if N (setq arg N))
	(bfmc-with-current sel (bfmc-with-frame (if (pseudo-frame-p sel) sel bfmc-cur-frame) (trap-errors (enlarge-window-horizontally arg)))))

  (defun bfmc-shrink-window-horizontal (&optional N)
	"�E�B���h�E�����ɏk��"
	(interactive "p")
	(if N (setq arg N))
	(bfmc-with-current sel (bfmc-with-frame (if (pseudo-frame-p sel) sel bfmc-cur-frame) (trap-errors (shrink-window-horizontally arg))))))


(defun bfmc-select-alone ()
  "���̃E�B���h�E����đI��"
  (interactive)
  (bfmc-with-current sel
	(bfmc-with-frame (if (pseudo-frame-p sel) sel bfmc-cur-frame)
	  (delete-other-windows) (set-buffer (if (bufferp sel) sel bfmc-cur-buffer)))
	(bfmc-rewrite (if (pseudo-frame-p sel) (current-line-number) bfmc-cur-frame-line))))


(defun bfmc-preview ()
  "�I���t���[����\��"
  (interactive)
  (bfmc-with-current sel
	(bfmc-with-frame (if (pseudo-frame-p sel) sel bfmc-cur-frame)
	  (sit-for 0.5))))

(defun bfmc-next-window ()
  "�I���E�B���h�E��i�߂�"
  (interactive)
  (bfmc-with-current sel
	(bfmc-sel-frame sel)
	(bfmc-with-frame sel (other-window 1 t))
	(bfmc-rewrite (if (eq sel bfmc-cur-frame) bfmc-cur-frame-line (current-line-number)))))

(defun bfmc-previous-window ()
  "�I���E�B���h�E��߂�"
  (interactive)
  (bfmc-with-current sel
	(bfmc-sel-frame sel)
	(bfmc-with-frame sel (other-window -1 t))
	(bfmc-rewrite (if (eq sel bfmc-cur-frame) bfmc-cur-frame-line (current-line-number)))))

(defun bfmc-close-window (&optional N)
  "�E�B���h�E�����"
  (interactive)
  (bfmc-with-current sel
	(bfmc-sel-frame sel)
	(bfmc-with-frame sel (trap-errors (delete-window)))
	(bfmc-rewrite (if (eq sel bfmc-cur-frame) bfmc-cur-frame-line (current-line-number)))))

(defun bfmc-g ()
  "bfmc menu�����B"
  (interactive)
  (bfmc-exit bfmc-cur-frame bfmc-cur-buffer)
  (message "�ł��B"))

(defun bfmc-exit (frame &optional buffer)
  ;bfmc menu���甲����
  (delete-buffer bfmc-buffer)
  (map nil 'delete-pseudo-frame (adjoin bfmc-frame bfmc-delete-frame-list))
  (map nil *bfmc-buffer-deleter* bfmc-delete-buffer-list)
  (setq bfmc-frame nil bfmc-buffer nil bfmc-fp nil bfmc-delete-frame-list nil bfmc-delete-buffer-list nil)
  (select-pseudo-frame frame)
  (if buffer (set-buffer buffer))
  (refresh-screen))

(defun bfmc-quit ()
  "bfmc �\�񂵂Ă����Ƃ��~�߂ďI������B"
  (interactive)
  (delete-buffer bfmc-buffer)
  (delete-pseudo-frame bfmc-frame)
  (setq bfmc-frame nil bfmc-buffer nil bfmc-fp nil bfmc-delete-frame-list nil bfmc-delete-buffer-list nil)
  (select-pseudo-frame bfmc-last-frame)
  (message "��߂��B"))

(defun bfmc-popup-info ()
  "���݂̍s�̃o�b�t�@�����|�b�v�A�b�v�ŕ\������"
  (interactive)
  (bfmc-with-current sel
	(if (bufferp sel)
		(popup-string
		 (buffer-name sel)
		 (point)))))

; end of file bfmc.l  