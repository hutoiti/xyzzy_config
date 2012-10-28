;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;;    shell-alt.l : shell-mode �� X68000���C�N�Ɋg��   by �V�o�^
;;
;;�y�ړI�z
;;  X68000 + command.x + history.x �ō�҂����i�g���Ă���@�\(�̂�)����������B
;;  ������ Windows98SE + command.com �� WindowsXP(SP2) + cmd.exe (2006/04�ȍ~)
;;            ���ϐ� PROMPT=$p$g �O��
;;
;;  �Q�l�ɂ��� ���������� shell3.l �Ƃ̍ő�̈Ⴂ�́A�t�@�C����/�q�X�g���̕⊮���A
;;  ��₪���������Ă� X68000 �̗l�ɁA
;;         �E�E�E�E
;;  1�����t���\�����鏊�i���̏�ōēx�⊮�L�[�������Ǝ�����\���j
;;    ���̃h���C�u�E�f�B���N�g�����T���ɂ����܂�
;;
;;���y�L�[�o�C���h�z �t�@�C��/�q�X�g���⊮�̓���ڍׂ͊e�֐���`�̃R�����g���Q�Ƃ̂���
;;  TAB 	�t�@�C������⊮ �� shell-complete-file
;;  C-w 	�q�X�g���⊮ �ŐV���珇�Ɍ��� �� shell-history-search  (shell3 �ł� C-r)
;;  C-e 	�q�X�g���⊮ �ŌÂ��珇�Ɍ���
;;      �q�X�g���⊮���� C-w/C-e �ŕ����]���\
;;
;; �ȉ��� shell3 ��� �V�K�ǉ��@�\�ior �@�\�ύX�j
;;  C-a 	���ݍs�̃R�}���h�s��(�v�����v�g����) or ���s���v���O�����̍ŏI�\���ʒu �Ɉړ�
;;  C-Up	shell�o�b�t�@��ŁA�ЂƂO�̃R�}���h�s �s���փW�����v
;;  F3      �J�[�\���ȑO�܂ł̓��͎͂c���āA�ȍ~�ɑO��R�}���h����������Ԃ���
;;           �R�}���h�s�ɂ��Ȃ��ꍇ�̓W�����v���Ċ����͕��͑S�č폜���đO��R�}���h
;;           �������\��(X68000�ł����u�e���v���[�g�v�B�A�����L�[�Ƃ̘A�W�͂Ȃ�)
;;  End 	�O��̃R�}���h���Ď��s (Redo)  �R�}���h�s�ɂ��Ȃ��Ă����s��
;;
;;      ���֐�����ׁ̈A�O�񕪂Ƃ��ċL������镶����� �v�����v�g �� ��v�����v�g ��
;;      ��ʂ���܂����A�q�X�g���o�b�t�@�ɂ��Ă͋�������(X68000�͂���������)
;;
;;  M-l 	�q�X�g����\��(PopUp) / M-x shell-show-history<ret> �ő��o�b�t�@�֑}�����\
;;
;;  shell3 �� C-r������ C-w �ɂȂ��Ă�̂� X68000 �̃L�[�o�C���h�ɍ��킹��ׂł�
;;  �J�[�\���㉺ �̓R�s�y�ׂ̈Ƀo�b�t�@�������R�ɓ������������̂� �@�\���O���܂���
;;
;;    ���Abash �Ƃ��͎g�������Ƃ��Ȃ��̂őΉ����e�X�g�����Ă��܂���
;;
;;���y�������@�z
;;  shell3.l �̓������@�Ɠ����ł�
;;  (1)$XYZZY/site-lisp �� shell-alt.l ��u��
;;  (2).xyzzy �Ɉȉ��̂悤�ɋL�q�i���̕��@�͂悭������܂���j
;;    (require "shell3")
;;    (require "shell-alt")
;;  �� shell3 ������ɏ���
;;  ( shell3.l �𓱓����Ă��Ȃ��l�́A��ڂ� "shell" �ł� OK�݂����ł� )
;;
;;  (3) shell�N�����@�� shell3.l �Ɠ����ł� : M-x shell<ret>
;;
;; tips
;;  (1)���炩���߁A�悭�g���R�}���h���q�X�g���ɓo�^���Ă����܂�
;;    ��  .xyzzy �� (shell-add-history "C:\\STOOL\\xyzzy\\xyzzycli.exe " )
;;   �irequire �錾����ɋL�q���邱�ƁB�J��Ԃ��� �����o�^���\�j
;;  (2)�⊮����t�@�C�����g���q�ǉ��� *shell-add-suffixes* ���������Ă�������
;;
;;  ��Ashell������s�����R���\�[���A�v�����L�[���͂����߂�ꍇ�Axyzzy�� ����
;;  ���삵�Ă��������Ȃ��ꍇ�A�ʓr����Ă��� Dos�����A�N�e�B�u�ɂ��ăL�[��
;;  �����Ɣ�������ꍇ������܂��i����ł��ʖڂ�������AWindowsXP�ł͓�������
;;  98SE�ł͑ʖڂȃP�[�X������܂�)�B
;;
;;  STDOUT(�W���o��)�� 512byte���x�o�b�t�@�����O����� xyzzy ���ɒx���\��
;;  �����̂ŁA�g�����ɂȂ�Ȃ��R���\�[���A�v��������܂��B
;;  STDERR(�W���G���[�o��)�͑����\�������̂ŁA�R���\�[���A�v�������삵�Ďg���Ȃ�
;;  �S�� STDERR �o�͂ō��������܂��B
;;
;;#TAB 4
;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

(export '(shell-send-input-history
		  shell-show-history  shell-add-history  *skip-hyphen-chars*
		  shell-sync-path  *shell-add-suffixes*  *shell-input-max* ))


(setq *shell-prompt-regexp* "^[A-Z]:[^#$%>?\n]*[#$%>?] *" )
; ���K�\����ύX����̂́A�O����ł����������������}�b�`�����邽�߁B
; �Ⴆ�� shell-preline �ők�낤�Ƃ���ƌ��̂܂܂ł� dir�R�}���h���o�͂���
; "<DIR>" �ɂ��}�b�`���Ă��܂�(���̐��K�\���̓���͂悭�������ĂȂ�)

;----------------------------------------------------------------------
;  �t�@�C���⊮/�q�X�g���Ɏg�������ϐ�
; ���J(export)���ĂȂ����̂� *scratch* ����Ⴆ�� ed::*last-cmd* (C-j)
; �Ƃ���ΎQ�Ƃł���
;----------------------------------------------------------------------
(defvar *his-mode*    nil)  ; switch �q�X�g����� nil = OFF
(defvar *last-cmd*    "")   ; �O��� commandline /  nil ���Ƃ����Ȃ� Redo �̎� Error
(defvar *last-input*  "")   ; �O��� ����
(defvar *his-lastpos* nil)  ; �O��� ���\���I���ʒu
(defvar *his-lastcmd* nil)  ; �O��� ���commandline

(defvar *his-word*  nil)    ; �⊮����P�� / ���ɖ߂�������
(defvar *hresult*   nil)    ; for debug
(defvar *hlist-new* nil)    ; �c����list �V������
(defvar *hlist-old* nil)    ; �c����list �Â���
(defvar *hlist-org* nil)    ; for debug / �Smatch���ۑ��p
(defvar *hprefix*   nil)    ; for debug
(defvar *history-buffer* nil)  ; �q�X�g��������L�^���X�g

; ---- for �t�@�C�����⊮ ----
(defvar *fcompmode* nil )  ; switch �⊮��� nil = OFF
(defvar *fnword*   "" )    ; �⊮���錳�̒P�� �` ��n��������
(defvar *add-word* "" )    ; �⊮�֐��ɓn�� path������
(defvar *cur-ep*    nil )  ; �s���ʒu(=�P�ꖖ)
(defvar *fresult*   nil )  ; for debug
(defvar *flist*     nil )  ; �c����list
(defvar *flist-org* nil )  ; for debug / �S�}�b�`���
(defvar *fprefix*   nil )  ; for debug / �t�@�C���̃p�X��
(defvar *lastpos*   nil )  ; �t�@�C���\����̃J�[�\���ʒu

(defvar *shell-curdir* nil) ; shell��̃J�����g�f�B���N�g�������� Drive�t
(defvar *shell-curdrv* nil) ; *shell-curdir* ����h���C�u�ԍ� "@:" ���������o��������
(defvar *add-path*     nil) ; �⊮�ptemp�ϐ�
(defvar *bgn-pos*      nil) ; ���\���J�n�ʒu
(defvar *skip-pos*     nil) ; �X�C�b�`skip���[�h '-' �������Ă��炵���ꍇ�̃J�[�\���ʒu

; �ȉ��A���J�ϐ�
(defvar *skip-hyphen-chars* 2)  ; '-'�̌ジ�炷������  0�ŃI�t
(defvar *shell-add-suffixes* '( "*.exe" ) ) ; �ǉ��⊮����g���q���X�g
(defvar *shell-input-max*  256) ; �q�X�g���ɋL�^����ő���͕�����


;------------------------------------------------------------
;  shell3.l �̃L�[�}�b�v�ꕔ����(shell-history-search �ɓ���)
;------------------------------------------------------------
(undefine-key *shell-mode-map* #\Up)   ;'shell-history-previous
(undefine-key *shell-mode-map* #\C-p)  ;'shell-history-previous
(undefine-key *shell-mode-map* #\Down) ;'shell-history-next
(undefine-key *shell-mode-map* #\C-n)  ;'shell-history-next
(undefine-key *shell-mode-map* #\C-r ) ;'shell-history-search-backward

;------------------------------------------------------------
;  shell-alt.l �L�[�}�b�v���Ȃ���
;------------------------------------------------------------
(define-key *shell-mode-map* #\RET  'shell-send-input-history)
(define-key *shell-mode-map* #\TAB  'shell-complete-file)
(define-key *shell-mode-map* #\C-a  'shell-goto-bop)
;(define-key *shell-mode-map* #\C-w  'shell-history-search)
;(define-key *shell-mode-map* #\C-e  #'(lambda () (interactive)(shell-history-search t)) )
;                     �����t���邽�߂̍׍H  ��
(define-key *shell-mode-map* #\End  'shell-redo)
(define-key *shell-mode-map* #\C-Up 'shell-preline)
(define-key *shell-mode-map* #\M-l  'shell-show-history)
;(define-key *shell-mode-map* #\C-Down 'input-filename)  ; �����łȂ̂ō폜
(define-key *shell-mode-map* #\F3   'shell-tiny-F3)



;;======================================================================
;;  ���ݍs���� shell�v�����v�g�� curdir�i�J�����g�f�B���N�g���j
;;    ��������擾���� *shell-curdir* �ɃZ�b�g
;;
;; 2005/09/23(Fri) �@�\����
;; 2006/08/27(Sun) �J�[�\���ʒu�ۑ� +
;;      ���s���Ă� *shell-curdir* �Ɏg������̂�������(Non-prompt�Ή�)
;;======================================================================
(defun shell-get-curdir ()
  (interactive)
  (let ( (curp (point))  bgn  (tempdir "") (retval nil) )
	(goto-bol)
	(setq bgn (point))
	(skip-chars-forward "^>" )	; '>'�ȊO��skip
	(setq tempdir (buffer-substring bgn (point)) )  ; curdir��╶����擾
	(if (eq 0 (string-match "^[a-zA-Z]:" tempdir) )  ; �擪������check
	  (setq retval t)  ; then 
	  (setq tempdir (default-directory)) ; else
	)
; --- ��������� '\' '/' �ŏI���l�ɉ��H(root�̎����� '\' �����Ă邩��) -----
    (message (concat "curdir [" tempdir "]" ))  ; for debug
	(setq *shell-curdir* (append-trail-slash tempdir) )
	(goto-char curp)
	retval
  )
)


;;================================================================================
;;  �����D�݂̃t�@�C�����⊮( X68000 command.x + history.x �w�� )
;;    �쐬/������ Windows98SE + command.com  ���ϐ� PROMPT=$p$g(�� "C:\>" "C:\temp>" )
;;
;;�y�d�l:X68000 �Ɏ������_�z(�L�[�o�C���h�� TAB�ȊO�ɕύX�\)
;;�ETAB�������Ƃ��ɁA�s�̈�ԍŌ�̒P��ɂ��ăt�@�C�����⊮����
;;  �s���ړ���A�J�[�\�������v�����v�g('>') or SPC �Ȃ�A�J�����g�f�B���N�g��
;;  (�ȉ� curdir)���̃t�@�C���������Ώ�
;;  curdir�� shell ���\�����Ă���v�����v�g�����񂩂�擾
;;    (cd ���Ă� xyzzy��̃J�����g�f�B���N�g���͕ω����Ă��Ȃ�����)
;;
;;�E�J�[�\���ړ����Ă��Ȃ���΁A2��ڈȍ~ TAB���������тɎ��̌���\������
;;  xyzzy�̒ʏ�⊮���@�ƈقȂ�A���t�@�C�����́y�Ō�܂Łz�\������
;;  ��₪�Ȃ��Ȃ�����ŏ��ɕ\������Ă���������ɖ߂�(�A���A'/' �� '\'��
;;  �ύX�����܂�)
;;
;;�y�d�l:X68000 �ƈႤ�����z
;;�E�X�e�[�^�X�s�����Ɏc���␔���\�������
;;
;;�E*do-completion �̎d�l�H�ɂ��A����̊g���q�̃t�@�C���͕\������Ȃ�
;;  ��҂��K�{�Ǝv���Ă�����s�t�@�C��(*.EXE)�͒ǉ������l�ɍ׍H��
;;  default �� "*.exe" => �ϐ� *shell-add-suffixes* �ŕύX�E�ǉ��\
;
;;�E�⊮�������P�ꖖ���� '*' �� '?' �ɂ��Ă����ƁA�ǉ��g���q�t�@�C��
;;  ���������\������ (��L�׍H�ɂ����镛��p)
;;
;;�E�f�B���N�g�������\�������ꍇ�͖����� '\' ����
;;  ���̉���T���ɍs�������ꍇ�͈�U�J�[�\�������ɓ������Ă��� TAB
;;  �i���������������Ă���Ȃ� '\'�ɑ����ē��͂��Ă��� TAB�j�B
;;  X68000�� '\' ���t���Ȃ��̂ŕ\�����ꂽ�̂��f�B���N�g���Ȃ̂��A�g���q
;;  �̂Ȃ��t�@�C���Ȃ̂����ʂł��Ȃ��B�������̕���������₷����
;;
;;�E�⊮����P��擪�� '-'�̏ꍇ�A�R�}���h���C���̃X�C�b�`�ƌ��Ȃ���
;;  �ϐ� *skip-hyphen-chars* �Ŏw�肵��������������΂����ʒu��P��擪�Ƃ���
;;  �i -f<filename> ���A�̃X�C�b�`�ɑ����ăt�@�C�����w�肷��ꍇ�ɕ֗��j
;;  '/'�̓p�X��؂�Ɖ��߂��� '\'�ɕϊ�����̂ŃX�C�b�`�w��� '/'���g�p����l��
;;  ���ӂ��邱��
;;
;;�y���̑��z
;;�E�J�[�\���� shell�v�����v�g�s�ɂȂ��ꍇ��v�����v�g�����񂪔j��
;;  ����Ă��鎞�̓���͖��ۏ�
;
;;�E�⊮��₪�ЂƂ��Ȃ����ɃG���[�E�B���h�E(Dialog)���\�������ꍇ������
;;
;;�Eshell��Ńh���C�u�ړ������ꍇ�A�ʃh���C�u�� curdir�� shell�� xyzzy��
;;  �Ǘ����Ă�����̂���v����Ƃ͌���Ȃ��̂Œ��Ӂi���������ꍇ�AR:\�` ��
;;  ��Ύw�肵�������悢�j
;;  �܂��A�h���C�u�ړ��Ɏ����Ǐ]����Ɓi�����[�o�u�����f�B�A�n�j���o�����Ȃ̂ŁA
;;  xyzzy�̊Ǘ����Ă��� (default-directory) �͕ύX���Ă��Ȃ�
;;  �s��v�ׂ̈Ƀ^�O�W�����v�������Ȃ��ꍇ�� �� M-x shell-sync-path ��
;;  shell�� curdir �ɍ��킹�邱�Ƃ��ł���
;;
;;
;;�E�����̓s����A�O��̕⊮�Ɠ����J�[�\���ʒu�� TAB�������Ƒ����Ƃ݂Ȃ���
;;  ������\������̂ŁA�F�X�ҏW��ɋ��R�J�[�\���ʒu�������ɂȂ����ꍇ�A
;;  �Ӑ}���Ȃ�����ɂȂ邱�Ƃ�����
;;
;;�ESPC���܂�ł���t�@�C������f�B���N�g�����ɂ��Ă͑z��O
;;  �Ή�������\��S���Ȃ�
;;
;;�E���̑��A��҂����i�g���ĂȂ��z��O�̑��� �ɂ��Ė��ۏ�
;;  �s��s�s���������玩���̍D�݂ɉ������邱��
;;
;; 2005/09/06(Tue) begin
;; 2005/09/08(Thu) ���Ȃ芮��
;; 2005/09/10(Sat) .xyzzy ����ړ�
;;================================================================================
(defun shell-complete-file ()
  (interactive)
  (unless (eq *lastpos* (point) )  ; �J�[�\���������Ă�����ŏ�����
	(setq *fcompmode* nil)
	(message " differ CURSOR") ; for debug
  )

  (unless *fcompmode*
	(shell-get-curdir)	; �J�����g�f�B���N�g��������擾

	(setq *fcompmode* t)
	(setq *shell-curdrv* (substring *shell-curdir* 0 2) )	; �ŏ���2���� '@:'
	(setq *add-path* *shell-curdir*)	; ��� *fnword* ���e�ɂ���ĕω�

; --- �s���ɂ��� �P���get -----
	(setq *fnword* "" )
	(goto-eol)
	(setq *cur-ep* (point) )
	(unless (bolp)		; �s���łȂ���� �P��get
	  (let ((bchar (char-after (- (point) 1 ) ) ))  ; �J�[�\�����̕���get
		(unless (or (eq bchar #\>) (eq bchar #\SPC ) )
		  (skip-chars-backward "^[ >]" )	; spc/�v�����v�g������܂ō���
		  (setq *fnword* (buffer-substring (point) *cur-ep* ) )
		)
	  )
	)
;--- *fnword* �擪�����`�F�b�N ---
	(setq *skip-pos* 0)  ; buffer�擪�ɂ͂��Ȃ���
	(when (and (string-match "^-"  *fnword*) ( >= (length *fnword*) *skip-hyphen-chars*) )
	  (setq *fnword* (substring *fnword* *skip-hyphen-chars*))
	  (goto-char (+ (point) *skip-hyphen-chars*))  ; switch����skip
	  (setq *skip-pos* (point))  ; skip��̈ʒu�L�^
	)

; ---- { '/ '�̂܂܂ł� DOS�������s����̂ŋ����I�E�s�t�I�� '\' �ɕύX ----
	(setq *fnword* (map-slash-to-backslash *fnword*) )
	(kill-line)
	(insert *fnword*)   ; } �����܂ŁB '/' �� OK�� shell �Ȃ�s�v

;------------------------------------------------------------
;  �P�� *fnword* ���� Drv / dir(path)�w��̗L��chk
;  �L���ŐF�X�����ς��Ȃ��Ƃ����Ȃ�
;------------------------------------------------------------
	(cond
		( (equal *fnword* "" ) t )

		( (string-match "^[\\/]"  *fnword*)	; �����Ȃ� root�w��(��Ύw��)
			(setq *add-path* *shell-curdrv*) ) ; '@:' �����ɂ���

		( (string-match "^[a-zA-Z]:[\\/]"  *fnword*)  ; Drv+root�w��(��Ύw��)
			(setq *add-path* "") ) ; *fnword* �����ŕ⊮

		( (string-match "^[a-zA-Z]:"  *fnword*)	; Drv�w��t�� ���Ύw��
			(if ( string-equal *shell-curdrv* (substring *fnword* 0 2) )
			  (setq *fnword* (substring *fnword* 2) ) ; ��Drv�Ȃ� *fnword*����'@:'�폜
			  (setq *add-path* "")  ; else  ��Drv�Ȃ� *fnword* �ŕ⊮
			) )
	)
;---- ���\���ʒu�̒��� ----
	(goto-eol)
	(skip-chars-backward "^[ >:\\/]" )	; ��납��T��
	(setq *bgn-pos* (max (point) *skip-pos*) ) ; ���ʒu�� '-' skip��ŁA��̕����

	(setq *add-word* (concat *add-path* *fnword* ) )  ; �⊮�̈���������쐬
	(setq *fnword* (buffer-substring *bgn-pos* *cur-ep*) ) ; �ŏI�߂�������Ƃ��čĐݒ�

;--------------------------------------------------
;  *add-word* �Ƀ}�b�`����t�@�C���������擾
;--------------------------------------------------
	(multiple-value-bind ( result lists prefix )
	  (*do-completion *add-word* :exist-file-name )
	  (setq *fresult*  result )  ; for debug
	  (setq *flist-org* lists )  ; lists �̓t�@�C���������̃��X�g
	  (setq *flist*     lists )
	  (setq *fprefix*  prefix )  ; for debug
	)

;----------------------------------------------------------------------
;  �t�@�C�������擾���̂Q
; *do-completion �͏E���Ă���Ȃ��t�@�C����(�g���q)������A���v�̂���
; ���s�t�@�C������ǉ����邽�߁Adirectory���R�[��
; directory �� directory �ŁA���삪�኱�قȂ�̂ŁA��i�K�\���ɂȂ���
; *shell-add-suffixes* �Ŋg���q�ǉ��\
;----------------------------------------------------------------------
	(let ( (extlist *shell-add-suffixes*) (sext) )
	  (while (< 0 (length extlist) )
		(setq sext (pop extlist) )
		(when (string-match "^*\."  sext ) ; �擪�� "*."�ɂȂ��ĂȂ��͖̂���
		  (setq sext (concat *add-word* sext) )
		  (setq *flist* (append *flist* (directory sext :FILE-ONLY t) ) ) )
	  )    ; --- �ulist+list(=list)�v �� append, �ulist �ɗv�f��ǉ��v�� push
	)
  )


;------------------------------------------------------------
;	�⊮�Q��ڈȍ~�i������ォ�獇���j
; �\���̍ۂ� path��؂� '/' -> '\' ���K�v
;------------------------------------------------------------
  (goto-char *bgn-pos*)
  (kill-line)	; �J�[�\���ȍ~�̍s���܂ō폜 = �O�������
  (if *flist*
	(progn  ;  ��₠��  '\' �g�����\���Ńt�@�C�����}��
	  (insert (map-slash-to-backslash (pop *flist*) ) )
	  (message (format nil "file�c���� ~D" (length *flist*)) )
	)

	(progn  ;  ���Ȃ� OFF & ���̕�����ɖ߂�
	  (setq *fcompmode* nil)
	  (insert *fnword*)
	)
  )
  (setq *lastpos* (point))	; �V�����J�[�\���ʒu�L�^
)


;;============================================================
;;  ���ݍs���v�����v�g�s���ǂ����𔻒肷��
;;  �����Ȃ� �v�����v�g�̎��ʒu��Ԃ� else nil��Ԃ�
;;    �q�X�g���L�^��ؑ֗p
;;
;; 2006/08/27(Sun)  Non-prompt�Ή��̂��߂ɐݒu
;;============================================================
(defun shell-is-prompt ()
  (interactive)
  (let ( (curp (point)) (retval nil) )

	(goto-bol)
	(when (looking-at *shell-prompt-regexp*)  ; prompt�Ȃ� '>'�ȊO��skip
;;	  (skip-chars-forward "^>" )   ; �ėp�ɂ���Ȃ� "^>" �� "^[#$%>]" ?
;;	  (forward-char)
;;	  (setq retval (point))
	  (setq retval (match-end 0))  ; ���3�s�Ɠ�������炵��
	)

	(goto-char curp)  ; �J�[�\���ʒu���ɖ߂�
	retval
  )
)


;;============================================================
;;  ���݃J�[�\���ʒu�� shell �ŏI�\���ʒu����Ȃ�
;;  �ŏI�\���ʒu(���l)��Ԃ� else nil��Ԃ�
;;
;; 2006/08/27(Sun)  Non-prompt�Ή��̂��߂ɐݒu
;;    shell-send-input �̖`�����Q�l��
;;============================================================
(defun shell-is-lastpos ()
  (interactive)
  (let ((process (buffer-process (selected-buffer)))) ; ��buffer�̃v���Z�X�����
	(if (and process (eq (process-status process) :run)   ; �v���Z�X�L && shell���s�� &&
		  (>= (point) (marker-point (process-marker process))))  ; ���݈ʒu�� �ŏI�\���ʒu �����

		(marker-point (process-marker process))  ; then �ŏI�\���ʒu��Ԃ�l��
    )  ; else �߂Ȃ����� nil��Ԃ� => �Ԃ�l
  )
)


;;============================================================
;;  ���ݍs�� �v�����v�g������΃J�[�\���� > �̎��̈ʒu�Ɉړ�
;;   or �ŏI�\���s�Ȃ�ŏI�\���ʒu�Ɉړ�
;;  (bop == Begin-Of-Prompt)
;;
;; 2006/08/27(Sun) Non-prompt�Ή��ɏC�� ��������
;;============================================================
(defun shell-goto-bop ()
  (interactive)
  (let ( (target (shell-is-lastpos)) )

	(unless target (setq target (shell-is-prompt)) )

	(if target (goto-char target) )
  )
)


;;================================================================================
;;  ���s���R�}���h���C�����M�̑�֏���
;;    shell3 �Ƃ̕����̂��߁A�q�X�g���������ɂ���Ă��� shell-send-input �ɓn��
;;
;; 2006/12/30(Sat)  shell3 �Ƃ̕����̂��ߐV��
;;================================================================================
(defun shell-send-input-history ()
  (interactive)
  (let ( (curp (point)) start end  (cmd ""))
	(shell-goto-bop) (setq start (point))  ; �v�����v�g�J�npos get
	(goto-eol)       (setq end   (point))  ; �s��pos get
	(goto-char curp)  ; ���̈ʒu�ɖ߂�

	(setq cmd (buffer-substring start end))  ; ���ꂪ���炭�R�}���h���C��
;------------------------------------------------------------
;  �q�X�g���o�^���
;    ���D�݂� �udelete ��Ɏ��s�v�u�`��Ɏ��s���Ȃ��v ������
;------------------------------------------------------------
	(when ( < 1 (length cmd) *shell-input-max* )  ; ������ 2�ȏ� *shell-input-max* �����Ȃ�o�^
	  (unless (equalp *last-input* cmd)  ; �O��Ɠ����Ȃ�o�^���Ȃ�
		(setq *last-input* cmd)
		(if (shell-is-prompt) (setq *last-cmd* cmd))  ; �^�̃R�}���h���C���Ȃ�L�^
		(if (equalp *his-lastcmd* cmd) (delete cmd *history-buffer*  :test 'equalp) ) ; ���ꕨ������

		(push cmd *history-buffer*)  ; ���X�g�擪�ɓo�^(���Ȃ���)
	  )
	)
;  (�Ȃ��Ă�����) �A�z�قǒ���������ُ�Ɣ��f���đ��M���Ȃ�
	(if ( < (length cmd) *shell-input-max* ) (shell-send-input) )
  )
)




;;============================================================
;;  '�\���� �]�����Ɏg�����߂̃J�v�Z���֐�
;;    *his-word* 2�����ڂ���̕�����ŃT�[�`
;;    string-matchp �͑啶����������ʂ��Ȃ��� ���K�\���L
;;============================================================
(defun sub-shell-findstr (str)
  (let ( (fstr (substring *his-word* 1) ) )
	(string-matchp fstr str) )
)


;;================================================================================
;; X68000 command.x + history.x ��^�����q�X�g������
;;  �쐬/������ Windows98SE + command.com  ���ϐ� PROMPT=$p$g(�� "C:\>" "C:\temp>" )
;;
;;  �q�X�g�����ŐV����k���ĒT�� (shell3 �ł� C-r����)
;;      ���� dirsw = nil or �ȗ����A dirsw = t�ł� �ŌÂ���t�����ɒT��
;;
;;�y�d�l:X68000 �Ɏ������_�z(�L�[�o�C���h�� C-w�ȊO�ɕύX�\)
;;�E�R�}���h�s�ɑł�����(�s���܂ł�)������ɍ��v������̂��A�q�X�g���̐V����
;;  ���̂��珇�ɕ⊮�i���̓[���Ȃ�q�X�g���S�������) 
;;  ������̑啶���������͋�ʂ��Ȃ����A�u�ł����񂾕�����Ŏn�܂�v���̂łȂ���
;;  �}�b�`���Ȃ�
;;  ���ꃂ�[�h�Ƃ��āA���͍s1�����ڂ� ' '(SPC) �ɂ����ꍇ�A
;;  �u2�����ڈȍ~�̕�������܂ށv�q�X�g����V����������T��
;
;;�E�J�[�\���ړ����Ă��Ȃ���΁A2��ڈȍ~ C-w���������тɎ��̌���\������
;;  C-e �ŋt�ɖ߂邱�Ƃ��\ (C-e����n�߂��ꍇ�͌Â�������⊮)
;;
;;�y�d�l:X68000 �ƈႤ�����z
;;�E�X�e�[�^�X�s�����Ɏc���␔���\�������
;;
;;�E�擪�� ' ' �ɂ����Ƃ��̕�������߂� ���K�\�� �ƂȂ�i�啶����������
;;  ��ʂ��Ȃ����A�t�@�C�����Ɋ܂܂�� '\' �Ƃ� '.' �̈Ӗ����ς�̂Œ��Ӂj
;;  �i���x�����֐���������Ȃ������� �� sub-shell-findstr �ŏ��� �j
;;
;;�E�q�X�g�������̃X�������ׁ̈A�Ăяo�����q�X�g����ҏW�����Ɏ��s�����ꍇ�A
;;  �q�X�g���������瓯����e�͏�������čŐV�ɓo�^���������B
;;  �]���Đ^�̈Ӗ��ł̃R�}���h���s���L�^�ɂ͂Ȃ�Ȃ��B
;;  shell-send-input-history �̃q�X�g���L�^�������C������ΕύX�\
;;
;;�y���̑��z
;;�E�J�[�\���� shell�v�����v�g�s�ɂȂ��ꍇ��v�����v�g�����񂪔j��
;;  ����Ă��鎞�̓���͖��ۏ�
;;
;;�E�����̓s����A�O��̕⊮�Ɠ����J�[�\���ʒu�� C-w�������Ƒ����Ƃ݂Ȃ���
;;  ������\������̂ŁA�F�X�ҏW��ɋ��R�J�[�\���ʒu�������ɂȂ����ꍇ�A
;;  �Ӑ}���Ȃ�����ɂȂ邱�Ƃ�����
;;
;;�E���̑��A��҂����i�g���ĂȂ��z��O�̑��� �ɂ��Ė��ۏ�
;;================================================================================
(defun shell-history-search ( &optional dirsw )
  (interactive)
  (unless (eq *his-lastpos* (point) )  ; �J�[�\���������Ă�����ŏ�����
	(setq *his-mode* nil)
	(message " [HIS] differ CURSOR")  ; for debug
  )
  (unless *his-mode*
    (setq *his-mode* t)
    (goto-eol)
    (let ( (curp (point)) )
	  (shell-goto-bop)
	  (setq *his-word* (buffer-substring (point) curp) )
	)

	(cond
	  ( (or (equal *his-word* "") (not (eq (schar *his-word* 0) #\SPC)) )
;--------------------------------------------------
;  *his-word* �Ƀ}�b�`��������擾
;--------------------------------------------------
		(multiple-value-bind ( result lists prefix )
		  (*do-completion *his-word*  :list-ignore-case nil *history-buffer*)
		  (setq *hresult*   result )	; for debug
		  (setq *hlist-org* lists  )	; �������� ������Â���
		  (setq *hprefix*   prefix )	; for debug
		) )

; --- �擪�� ' ' �Ȃ�P��T�[�`�ɐؑ�  �]�����͎���\��
		(t (setq *hlist-org*  (remove-if-not 'sub-shell-findstr *history-buffer*) )
		   (setq *hlist-org* (reverse *hlist-org*) ) )  ; *do-complete �Ƌt���Ȃ̂ō��킹��
	)
	(setq *his-lastcmd* nil)	; �� ���񓮍�ׂ̈ɏd�v
	(if dirsw
	  (progn	; --- from old
		(setq *hlist-new* nil )
		(setq *hlist-old* *hlist-org* ) )
	  (progn	; --- from new
		(setq *hlist-new* (reverse *hlist-org*) )  ; �v�f���ԂЂ�����Ԃ�
		(setq *hlist-old* nil) )
	)
	(unless *hlist-org*  (message "his no match") )
  )

;------------------------------------------------------------
;  �Q��ڈȍ~�i������ォ�獇���j
;------------------------------------------------------------
  (shell-goto-bop)
  (kill-line)
  (when (if dirsw *hlist-old* *hlist-new* )  ; ��₪����Ȃ�
	(if dirsw
	  (progn	; --- old / ��(push nil nil�ϐ�) => (nil) <nil�ɔ�> �ɂȂ�̂����
		(if *his-lastcmd*  (push *his-lastcmd* *hlist-new*) )
		(setq *his-lastcmd* (pop *hlist-old*))
		(message (format nil "his�c���� ~D" (length *hlist-old*)) ) )

	  (progn	; --- new
		(if *his-lastcmd*  (push *his-lastcmd* *hlist-old*) )
		(setq *his-lastcmd* (pop *hlist-new*))
		(message (format nil "his�c���� ~D" (length *hlist-new*)) ) )
	)
	(insert *his-lastcmd*)
	(setq *his-lastpos* (point))	; �V�����J�[�\���ʒu�L�^
	(return-from shell-history-search)
  )
; ---- ���Ȃ� ----
  (setq *his-mode* nil)
  (setq *his-lastcmd* "")
  (insert *his-word* )
)



;;======================================================================
;;  ���ݍs���v�����v�g�s�Ȃ�s���Ɉړ�����
;;  �Ⴄ�Ȃ�1�s�O�ɖ߂��ČJ��Ԃ�  �o�b�t�@�擪�܂ŗ������~
;;
;; 2005/09/23(Fri) ����
;;======================================================================
(defun shell-goto-pline ()
  (interactive)
	(while (not (bobp))
	  (goto-bol)
	  (if  (looking-at *shell-prompt-regexp*) (return t))
	  (previous-line)
	)
	(goto-eol)
)


;;======================================================================
;;  �q�X�g���̏�����p�i(shell���[�h�Ŏg�p)
;;  ���ݍs���O�̃v�����v�g�s �̍s���Ɉړ�����
;;  �Ȃ���΃o�b�t�@�擪�Œ�~
;;
;; 2005/08/28(Sun)
;; 2005/09/10(Sat) .xyzzy ����ړ�
;; 2005/09/23(Fri) ���앪��
;;======================================================================
(defun shell-preline ()
  (interactive)
  (previous-line)
  (shell-goto-pline)
)




;;============================================================
;;  �Ō�Ɏ��s�����R�}���h�����s
;; ���o�b�t�@�����Ɉړ����A�Ō�ɓ��͂����R�}���h�����s(���s�t)
;;
;; 2005/09/10(Sat) �I�}�P
;; 2005/09/24(Sat) �v�����v�g�s�ւ̈ړ������������܂��߂�
;; 2006/08/27(Sun) shell-last-cmd �ƕ��� for Non-prompt�Ή�
;;============================================================
(defun shell-redo ()
  (interactive)

  (shell-last-cmd)
  (shell-send-input)
)


;;============================================================
;;  (�K��)�o�b�t�@�����Ɉړ����A
;;  (������������)�Ō�ɓ��͂����R�}���h��\��
;;    ���ɓ��͂���Ă���������͏��������
;;
;; 2006/08/27(Sun) ���� + Non-prompt�Ή�
;;============================================================
(defun shell-last-cmd ()
  (interactive)
  (let (target)
	(goto-char (point-max))           ;; �o�b�t�@�ŏI�Ɉړ�
	(setq target (shell-is-lastpos))  ;; �ŏI�ʒu�ȍ~�̔�����
	(when target
	  (goto-char target)
	  (kill-line)
	  (insert (if (shell-is-prompt) *last-cmd*  *last-input* ))
	)
  )
)


;;============================================================
;;  command.x Tiny F3
;;    �o�b�t�@�����ō�ƒ��Ȃ�v�����v�g����J�[�\����O�܂ł�
;;    ���͂��c���Ĉȍ~�� �O����s�R�}���h�ŕ⊮
;;    �����Ə�ɖ߂��Ă��鎞�Ɏ��s����ꍇ�� shell-last-cmd ��
;; 2006/08/27(Sun) Non-prompt�Ή��Ŏ���
;;============================================================
(defun shell-tiny-F3 ()
  (interactive)
  (let  ( (target (shell-is-lastpos) )
		  (basestr (if (shell-is-prompt) *last-cmd*  *last-input*)))

	(if (and target (> (length basestr) (- (point) target)))
	  (progn (kill-line) (insert (substring basestr (- (point) target)))) ; then

	  (shell-last-cmd)  ; else
	)
  )
)



;;============================================================
;;  �o�^����Ă���q�X�g����V�������ɕ\��
;;    shell-mode ����Ă񂾏ꍇ�� PopUp�\�� (M-l)
;;
;; 2005/09/10(Sat) �I�}�P
;; 2005/09/23(Fri) shell���� PopUp �\�� �ɕύX
;;============================================================
(defun shell-show-history ()
  (interactive)
  (let ( (hismsg (format nil "====== �q�X�g�� ���� ======\n~{~A\n~}" *history-buffer*)) )
	(if (equalp mode-name "Shell")
	  (popup-string  hismsg (point) ) ; shell-mode �Ȃ� Popup
	  (insert hismsg) )  ; �ȊO�Ȃ�o�b�t�@�ɑ���
  )
)



;;======================================================================
;;  ������������Ȃ�΃q�X�g���ɃR�}���h���C���ǉ�����
;;    �O��������ݒ肷��ׂ̃I�}�P
;;
;; 2005/09/12(Mon)
;;======================================================================
(defun shell-add-history (cmd)
  (if (stringp cmd)
	  (push cmd *history-buffer*) )  ; ���X�g�擪�ɓo�^
)


;;======================================================================
;;  shell-mode�o�b�t�@�� curdir�� shell(command.com)�̂���Ɉ�v������
;;    �R���p�C���������̃G���[���b�Z�[�W�s�Ɉړ����� TAG�W�����v�ł��Ȃ�
;;    (file���������Ȃ��̂� '�G���[�͂���܂���' �Əo�� )���Ɏg��
;;    shell�N��������ŕʃf�B���N�g����cd ���ăR���p�C������ƋN����H
;;
;;    shell-mode �̃o�b�t�@���炵���@�\�����Ȃ�
;;    �J�[�\���ʒu���A�� save-excursion �ł��ł���͂�
;;
;; 2005/09/23(Fri)
;;======================================================================
(defun shell-sync-path ()
  (interactive)
  (let ( ( savepos (point) ) )
	(when (equalp mode-name "Shell")
	  (goto-char (point-max))
	  (shell-goto-pline)	; ��Ԍ��(�ŐV)�̃v�����v�g�s�Ɉړ�
	  (shell-get-curdir)
	  (cd *shell-curdir*)

	  (goto-char savepos)  ) ; ���̈ʒu�ɖ߂�
  )
)



;;======================================================================
;;  �t�@�C�����⊮���͂̏�����p�i(shell���[�h�Ŏg�p)
;;
;; 2005/08/28(Sun)
;; 2005/09/10(Sat) .xyzzy ����ړ��Apath�폜���O����
;;   xyzzy�g�݂��݋@�\���g�p���Ă���̂ňꕔ�g���q�̃t�@�C���͌����Ȃ�
;; 2005/09/20(Tue) �s�g�p��
;;======================================================================
(defun input-filename (fname)
  (interactive "fFname:" )

  (insert (map-slash-to-backslash (namestring fname) ))
)


;;================================================================================
;; $HISTORY �y�����z
;; 2005/09/10(Sat)  �t�@�C�����⊮���g���郌�x���ɂȂ����̂� shell4.l �����グ
;; 2005/09/12(Mon)  shell-add-history �ǉ�
;; 2005/09/13(Tue)  *skip-hyphen-chars* *shell-add-suffixes* �ǉ�
;; 2005/09/16(Fri)  �`4 �𖼏����̏o���ł��Ȃ��̂� shell-alt.l �ɖ��O�ύX
;; 2005/09/17(Sat)  �q�X�g���T�[�`�𗼕����ړ��\�Ɋg���B
;;      X68000 �Ŏg�������ƂȂ��������ǁA�擪SPC �̃T�[�` �\��
;; 2005/09/19(Mon)  *word* �ϐ����ύX '-'�X�L�b�v�����X�}�[�g��
;; 2005/09/20(Tue)  input-filename ���L�[�o�C���h����O��
;; 2005/09/23(Fri)  M-l (ESC L) �� shell-show-history ���蓖�� + PopUp��
;;      shell-sync-path �ǉ�
;;
;; ----- ��������쐬�E�e�X�g���� WindowsXP + cmd.exe �Ɉڍs ------
;;
;; 2006/08/06(Sun)  cmd(�R�}���h���C��)�Ƀy�[�X�g�Ȃǂňُ�ɒ��������񂪓n����
;;      ���܂������Ƀq�X�g���L�^��shell���s���֎~���� (�萔 *shell-input-max*)
;; 2006/08/27(Sun)  shell-mode����ł��Ȃ�Ƃ����p�\�� DOS���Θb�^�v���O������
;;      �q�X�g���y�уt�@�C�����⊮ �����퓮�삷��l�ɏC��(�yNon-prompt�Ή��z)
;;
;; 2006/12/30(Sat)  shell3.l �ƕ������āA�ォ��p�b�`���Ă���`�ɏC��
;;      1�����R�}���h�̓q�X�g���ɗ��܂�΂���Ȃ̂ŁA�L�^���Ȃ��悤�ɂ���
;;      http://www.geocities.jp/altshibabou/ �Ō��J
;;================================================================================