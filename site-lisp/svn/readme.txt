
$HeadURL: file:///g:/repository/xyzzy/site-lisp/svn/release/0.0.2.0/readme.txt $
$Date: 2005-07-04 21:59:51 +0900 (Mon, 04 Jul 2005) $
$Rev: 171 $

��svn-mode for xyzzy

�E�߂��Ⴍ����K���ȊȈ�svn-mode�ł��B

���K�v�Ȋ�

�ESubversion�����ʂɓ��삷����i�p�X���ʂ��Ă���j

�Exml-parser-modoki���K�{�ł��B���g���ɂȂ�O�ɃC���X�g�[�����āA
�@���Ȃ��g����悤�ɂ��Ă����Ă��������B

���ݒ�

�E~/.xyzzy��$XYZZY/site-lisp/siteinit.l�Ɉȉ����L�q���ĕۑ����A
  xyzzy���ċN�����Ă�������

	(require "svn/svn")

�Esvn �T�u�R�}���h�ɓn���X�C�b�`�̎w��ɂ��ẮA~/.xyzzy ��
  $XYZZY/site-lisp/siteinit.l �Ɉȉ����L�q���Ă��������B

  �� ���[�UID�ƃp�X���[�h��ݒ肷��
	(svn-set-option "--username" "LKPTeam")
	(svn-set-option "--password" "hogehoge")

  �� --verbose�I�v�V������ݒ肷��
	(svn-set-option "--verbose")

  �\����
	(svn-set-option OPTION-NAME [OPTION-VALUE])
  �ƂȂ��Ă���A���[�UID��p�X���[�h���w�肷��Ƃ���OPTION-VALUE��
  �g���܂����A����ȊO��OPTION-NAME�����ōςނƎv���܂��B

  �g�p�ł���I�v�V�����̈ꗗ��svn-misc.l�ɂ���܂�(*svn-options*)�B

���ݒ�ł���I�v�V�����ꗗ

���O							�����l
*svn-use-completion* 			nil(���|�W�g�����X�g�̕⊮��L���ɂ��邩�ǂ���)
*svn-use-parse-status* 			nil(svn status�T�u�R�}���h�̏o�͌��ʂ�ύX���邩�ǂ���)
*svn-diff-color-new* 			'(:foreground 15 :background 7 :bold t)
*svn-diff-color-old*			'(:foreground 1 :background 3)
*svn-blame-color*				'(:foreground 8 :background 3 :bold t)
*svn-parse-modified-color*    	'(:keyword 1 :bold)
*svn-parse-add-color*         	'(:keyword 2 :bold)
*svn-parse-delete-color*      	'(:keyword 1 :line)
*svn-parse-conflict-color*    	'(:keyword 1 :bold)
*svn-parse-ignored-color*     	'(:keyword 0 :bold)
*svn-parse-no-version-color*  	'(:color 10 0 :line)
*svn-parse-losted-item-color* 	'(:keyword 2 :bold)
*svn-parse-rep-item-color*    	'(:keyword 2 :bold)
*svn-parse-rel-ext-def-color* 	'(:keyword 0 :bold :underline)
*svn-parse-old-color*         	'(:color 1 0 :bold :line)
*svn-parse-locked-color*        '(:keyword 1 :bold)
*svn-parse-file-modified-color*	'('modified 1 nil t)
*svn-parse-file-add-color*      '('add 2 nil t)
*svn-parse-file-conflict-color* '('conflict 6 nil t)
*svn-parse-file-ignored-color*  '('ignored 0 nil nil nil t)
*svn-parse-file-losted-color*   '('losted 10 nil t)
*svn-parse-file-locked-color*   '('locked 1 nil t)
*svn-parse-file-switched-color* '('switched 2 nil t)

*svn-parse-file����n�܂�ϐ��ɂ��Ă͈ȉ����Q��
;; file/direcotry column color
;; format
;;  '(TAG FOREGROUND BACKGROUND BOLD UNDERLINE STRIKE-OUT)
;; TAG        => �K�{
;; FOREGROUND => �K�{�B�F�ԍ��A�܂���nil
;; BACKGROUND => �F�ԍ��A�܂���nil(�ȗ���)
;; BOLD       => t �܂��� nil(�ȗ���)
;; UNDERLINE  => t �܂��� nil(�ȗ���)
;; STRIKE-OUT => t �܂��� nil(�ȗ���)
;;
;; FOREGROUND���ȗ����āABACKGROUND���w�肷��A�Ƃ����͕̂s�B
;; ���̏ꍇ��FOREGROUND��nil���w�肷�邱�ƁB���ԑ厖�B����d�v�B
;;

�����̑�

�E�T�|�[�g���Ă���svn�T�u�R�}���h��svn.l�̐擪�̕��ɋL�����Ă��܂�
�E������Ȃ�������\�[�X�ǂ�(��)
�Esvn-propedit�ɂ��āBPROPVALUE�̕ҏW���������鎞��C-c C-c�ł��B
  �R�~�b�g�̎��Ɠ����ł��ˁB�ꉞ������Ȃ��l�̂��߂ɏ����Ƃ��܂��B

--------------------------------------------------------------------------
