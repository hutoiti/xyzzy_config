(provide "test")
(in-package "editor")
(export '(*test-mode-hook*
            *test-mode-map*
            ))

(defvar *test-mode-hook* nil
  "test-mode: ���[�h�t�b�N")
(defvar *test-mode-map* nil
  "test-mode: Local keymap")
(defun test-mode ()
  (interactive)
  (kill-all-local-variables)
  (setq buffer-mode 'test-mode)
  (setq mode-name "Test")
  (use-keymap *test-mode-map*);�g�p����L�[�}�b�v���w�肵�Ă���B
  ;;����(keymap)�ƂȂ��Ă���B
  (use-syntax-table *test-mode-syntax-table*);�g�p����V���^�b�N�X�e�[�u�������Ă��Ă���B
  (and *test-keyword-file*;Test
       (null *test-keyword-hash-table*);nil kara t
       (setq *test-keyword-hash-table*;test-keyword-hash-table���Ȃ���Ί��蓖�Ă�B
	     (load-keyword-file *test-keyword-file* t)));�L�[���[�h�t�@�C�������[�h����Btest-keyword-file�́Atest
  ;;and�́A�ォ�珇��nil�ғ����`�F�b�N�����s����
  ;;nil������΁A�I������
  (when *test-keyword-hash-table*
    (make-local-variable 'keyword-hash-table);�Ǝ��̒l�����Ă�悤�ɂ���
    (setq keyword-hash-table *test-keyword-hash-table*)
    )
  ;�t�b�N�̎��s
  (run-hooks '*test-mode-hook*))
;(keymap)�Ƃ������X�g��Ԃ��֐�

;test-mode
(defvar *test-mode-hook* nil)
;;�L�[�}�b�v
;*test-mode-map*
(unless *test-mode-map*
  (setq *test-mode-map* (make-sparse-keymap))
  (define-key *test-mode-map* #\C-7 'sample-insert-headstring)
  (define-key *test-mode-map* #\C-q 'page-incrimental-date)
  (define-key *test-mode-map* #\C-j #'(lambda () (interactive) (newline)(indent-relative)))
)
(defvar *test-keyword-hash-table* nil);����ɂ͍���*test-keyword-file*�̌��ʂ𓖂Ă͂߂�B
;*test-keyword-hash-table*
(defvar *test-keyword-file* "Test")

(defvar *test-mode-syntax-table* nil)
;*test-mode-syntax-table*

(defvar *test-mode-syntax-table* nil)
(unless *test-mode-syntax-table*
  (setq *test-mode-syntax-table* (make-syntax-table))
(do ((x #x21 (1+ x)))
      ((>= x #x7f))
    (let ((c (code-char x)))
      (unless (alphanumericp c)
	(set-syntax-punctuation *test-mode-syntax-table* c))))
  (set-syntax-string *test-mode-syntax-table* #\")
;  (set-syntax-string *test-mode-syntax-table* #\')
  (set-syntax-start-comment *test-mode-syntax-table* #\; t)
  (set-syntax-end-comment *test-mode-syntax-table* #\LFD nil t))

(defun sample-insert-headstring ()
  (interactive "*")
  (beginning-of-buffer)
  (replace-string "�B" "�D" t)
  (beginning-of-buffer)
  (replace-string "�A" "�C" t)
  (beginning-of-buffer)
  ;;�����̓����̗L���ŋ�؂��ς��鏈��
  (if
      (scan-buffer (format-date-string "%Y�N%m��%d��"))
      ;�����̓����������C�����t
    (progn
      (end-of-buffer)
	(if
	    (scan-buffer
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" :reverse t)
;	(beginning-of-line)--- �������猩�Ă��邩�ǂ���
	(progn;�������Ƃ���
	  (if
	    (equal (char-before(point)) #\");���̎��̋L�����_�u���N�H�[�e�[�V�����H
	      (progn (end-of-buffer)
	(insert
	 "\naaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\n")
	 (insert (format-date-string "%H��"))
	 (insert
       "\n�@"))
	  (progn (end-of-buffer)(insert
				 "\n\"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\"\n")
				 (insert (format-date-string "%H��"))
				 (insert
       "\n�@"))))))
    (progn
      (end-of-buffer)
      
	  (scan-buffer
    "\niiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii\n" :reverse t)
	  (char-after (point))
            (replace-regexp "^[ \t]*\n" "" t)
      (next-virtual-line)(next-virtual-line)(next-virtual-line)(beginning-of-line)
      ;�����ŁA��s�������܂ŁAnext-virtual-line���������B

	(end-of-buffer);���������J�[�\���ʒu�ɂ̓}�[�N��ݒ肵�܂��B
;      (copy-region-as-kill (mark) (point-max))
	(copy-region-to-clipboard (mark)(point-max))
	(unless
	    (call-process "evernote.exe /Task:PasteClipboard")
	  (insert "evernote error�ł��A���ϐ����A�������������Ă��Ȃ����̖�肾�ƍl��p���܂��B"))
      (insert
       "\niiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii\n")
      (insert (format-date-string "%Y�N%m��%d��"))
      (insert
       "\n�@"))))

(defun page-incrimental-date()
  (interactive "*")
  (if
      (scan-buffer "iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii" :reverse t)
      (backward-char)))


;(keymap)
;*test-mode-map*
;(keymap)
;�L�[���[�h�̐ݒ�
;�L�[���[�h�����łȂ��A�V���^�b�N�X�e�[�u�������[�h���Ƃɍ��K�v������炵��

;*test-keyword-file*
;�V���^�b�N�X

;  (set-syntax-start-comment *perl-mode-syntax-table* #\#)


;(set-menu nil)
;(global-set-key #\C-F8 'sample-insert-headstring);���L�p
; ; (defun sample-insert-headstring ()
; ;   (interactive "*")
; ;   (beginning-of-buffer)
; ;   (replace-string "�D" "�D" t)
; ;   (beginning-of-buffer)
; ;   (replace-string "�A" "�C" t)
; ;   (end-of-buffer)
; ;   (insert
; ;    "\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
; ;   (insert (format-date-string "%Y�N%m��%d��"))
; ;   (insert
; ;    "\n "))
; ; (defun sample-replace ()
; ;   (interactive "*")
; ;   (save-excursion
; ;     (beginning-of-buffer)
; ;     (replace-string "�D" "�D" t)
; ;     (beginning-of-buffer)
; ;     (replace-string "�A" "�C" t)))
; ; (global-set-key #\C-F6 'sample-replace);�D�ƁA���������ǂ��u��
; (global-set-key #\C-F7 'sample-insert-headstring2);���L�p
; (defun sample-insert-headstring2 ()
;   (interactive "*")
;   (beginning-of-buffer)
;   (replace-string "�D" "�D" t)
;   (beginning-of-buffer)
;   (replace-string "�A" "�C" t)
;   (end-of-buffer)
;   (insert
;    "\n***************************************************************************************\n"))
; (global-set-key #\C-F9 'sample-insert-headstring3);���L�p
; (defun sample-insert-headstring3 ()
;   (interactive "*")
;   (beginning-of-buffer)
;   (replace-string "�D" "�D" t)
;   (beginning-of-buffer)
;   (replace-string "�A" "�C" t)
;   (end-of-buffer)
;   (insert
;    "\n---------------------------------------------------------------------------------------\n"))
; (global-set-key #\C-F10 'sample-insert-headstring3);���L�p
; ; (defun sample-insert-headstring4 ()
; ;   (interactive "*")
; ;   (end-of-buffer)
; ;   (insert
; ;    "\n@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n"))
; (global-set-key #\C-F11 'sample-insert-headstring5);���L�p
; (defun sample-insert-headstring5 ()
;   (interactive "*")
;   (beginning-of-buffer)
;   (replace-string "�D" "�D" t)
;   (beginning-of-buffer)
;   (replace-string "�A" "�C" t)
;   (end-of-buffer)
;   (insert
;    "\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"))
;(defun test-mode ()
 ; (interactive)
  ;(switch-to-buffer "*Test*");������΃o�b�t�@���쐬����B
;  (kill-all-local-variables);�قƂ�ǂ̕ϐ������Z�b�g����
;  (setq buffer-mode 'test-mode)
;  (setq mode-name "Test")
 ; (use-keymap *test-mode-map*)
 ; (make-local-variable 'need-not-save);�J�����g�o�b�t�@�ŃV���{���̑���������
;  (setq need-not-save t);������V���{����t�����Ă���
;  (make-local-variable 'auto-save)
 ; (setq auto-save nil);������V���{����t�����Ă���
  ;(run-hooks '*test-mode-hook*));�t�b�N�����s����

;(unless *test-mode-syntax-table*
 ; (setq *test-mode-syntax-table* (make-syntax-table)))
;#<syntax-table 68817896>
;(unless *test-mode-syntax-table*
 ; (setq *test-mode-syntax-table* (make-syntax-table))
;  (set-syntax-start-comment *test-mode-syntax-table* #\/ t)
; (set-syntax-end-comment *test-mode-syntax-table* #\LFD t t)
;  )