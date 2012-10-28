(provide "test")
(defvar *test-mode-hook* nil)

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
;test-mode
(defun sample-insert-headstring ()
  (interactive "*")
  (beginning-of-buffer)
  (replace-string "�B" "�A" t)
  (beginning-of-buffer)
  (replace-string "�C" "�C" t)
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
	(end-of-buffer)
;      (copy-region-as-kill (mark) (point-max))
	(copy-region-to-clipboard (mark)(point-max))
	(unless
	    (call-process "evernote.exe /Task:PasteClipboard")
	  (insert "evernote error�ł��A���ϐ����A�������������Ă��Ȃ����̖�肾�ƍl�����܂��B"))
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

;;�L�[�}�b�v
(defvar *test-mode-map* nil)
;*test-mode-map*
(unless *test-mode-map*
  (setq *test-mode-map* (make-sparse-keymap))
  (define-key *test-mode-map* #\C-7 'sample-insert-headstring)
  (define-key *test-mode-map* #\C-q 'page-incrimental-date)
);(keymap)�Ƃ������X�g��Ԃ��֐�
;(keymap)
;*test-mode-map*
;(keymap)
;�L�[���[�h�̐ݒ�
;�L�[���[�h�����łȂ��A�V���^�b�N�X�e�[�u�������[�h���Ƃɍ��K�v������炵��
(defvar *test-keyword-hash-table* nil);����ɂ͍���*test-keyword-file*�̌��ʂ𓖂Ă͂߂�B
;*test-keyword-hash-table*
(defvar *test-keyword-file* "Test")
;*test-keyword-file*
;�V���^�b�N�X
(defvar *test-mode-syntax-table* nil)
;*test-mode-syntax-table*
;(unless *test-mode-syntax-table*
 ; (setq *test-mode-syntax-table* (make-syntax-table)))
;#<syntax-table 68817896>
;(unless *test-mode-syntax-table*
 ; (setq *test-mode-syntax-table* (make-syntax-table))
;  (set-syntax-start-comment *test-mode-syntax-table* #\/ t)
 ; (set-syntax-end-comment *test-mode-syntax-table* #\LFD t t)
;  )
(defvar *test-mode-syntax-table* nil)
(unless *test-mode-syntax-table*
  (setq *test-mode-syntax-table* (make-syntax-table))
(do ((x #x21 (1+ x)))
      ((>= x #x7f))
    (let ((c (code-char x)))
      (unless (alphanumericp c)
	(set-syntax-punctuation *test-mode-syntax-table* c))))
  (set-syntax-start-comment *test-mode-syntax-table* #\# t)
  (set-syntax-string *test-mode-syntax-table* #\")
  (set-syntax-end-comment *test-mode-syntax-table* #\LFD nil t))
;  (set-syntax-start-comment *perl-mode-syntax-table* #\#)
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
