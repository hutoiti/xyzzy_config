; $Id: readme.txt 749 2007-03-13 15:48:27Z torihat $

 php-mode for xyzzy

 by Masashi Hattori

�� php-mode �Ƃ́H

	xyzzy�p��PHP�������[�h�ł��B
	�قƂ��c++-mode�̒u���ł��B

	-- �L�[���[�h��F����
	-- TAB�ȂǂŎ����C���f���g
	-- �^�O�W�����v
	-- �֐��̈ꗗ�\��
	-- �L�[���[�h�̕⊮
	-- �}�j���A���A�w���v�փW�����v
	-- �f�o�b�O

	�Ȃǂ��ł�����ł��Ȃ������肵�܂��B

	���p�������Ɋւ��ẮALICENSE.txt�������������B

�� �C���X�g�[��

    1. �t�@�C����W�J����B

	-- php-mode.l, php-misc.l, php-xdebug.l ��xyzzy/site-lisp �ɒu����
	   �o�C�g�R���p�C�����ĉ������B
	-- PHP �� xyzzy/etc �ɒu���ĉ������B

    2. .xyzzy�Ȃǂɐݒ�

	(load-library "php-mode")
	(pushnew '("\\.php$" . php-mode) *auto-mode-alist*)
	;; php-misc���g���ꍇ
	(load-library "php-misc")
	(setq *php-html-help-path* "C:/xyzzy/etc/php_manual_ja.chm")

�� �g����

	��{�I�Ȏg�����́Axyzzy�̑��̌��ꃂ�[�h�ƕς��܂���B

	[��{�I�ȃL�[�o�C���h]
		Enter			���s �{ �C���f���g
		TAB			�C���f���g
		ESC TAB			�L�[���[�h�⊮
		F4			�^�O�W�����v
		S-F4			�^�O�W�����v��߂�

	[���̑�]
		M-x list-function	�֐��ꗗ�̕\�� ("listfn.l"�����[�h����Ă���ꍇ)

	[php-misc]
		F1			www.php.net �̃}�j���A���\�� (�ݒ�Ń��[�J�������̏ꏊ���j
		S-F1			HTML Help�Ń}�j���A���\��
		C-c s			PHPUnit.php �p�̃X�P���g������

	[php-xdebug]
		�� �ݒ�Ɋւ��Ă͈ȉ���"Xdebug"�����Ă��������B
		F5			�f�o�b�O�J�n�^�I��
		F6			�u���[�N�|�C���g�܂ŁA�܂��͍Ō�܂Ŏ��s
		F7			�u���[�N�|�C���g��ݒ�^����
		C-F7			�u���[�N�|�C���g��S�ĉ���
		F8			�ϐ���\��
		F9			�ϐ���\���i�l�̂݁j
		F10			step over
		F11			step into
		C-F11			step out
		F12			URL���w�肵�ău���E�U���N��

�� Xdebug

	Xdebug <http://www.xdebug.org/>�𗘗p���ă����[�g�f�o�b�O���s�������ł��܂��B
	�v���g�R����DBGp�̂ݑΉ����Ă��܂��B

	�܂��A�����[�g�Ƃ͂������̂Ƃ��냍�[�J���R���s���[�^�[��Apache���PHP����
	�f�o�b�O�ł��܂���B(*1)

	PHP���ňȉ��̂悤�Ȑݒ������Xdebug�̃����[�g�f�o�b�O��L���ɂ��Ă��������B

	zend_extension_ts = "path_to_php_xdebug.dll"
	xdebug.remote_enable = On
	max_execution_time = 0    ; �f�o�b�O���ɏI������Ȃ�����

	����ɂ�Xdebug�Ŕz�z����Ă����debugclient.exe���K�v�ł��B���肵�ăp�X�̒ʂ���
	�Ƃ���ɒu���Ă��������B

	xyzzy���ł� .xyzzy �ȂǂɈȉ��̐ݒ���s���Ă��������B�܂��Axml-parser-modoki
	���K�v�ł��̂ŁA�ʓr�C���X�g�[�����Ă����Ă��������B

	;; php-xdebug���g���ꍇ
	(load-library "php-xdebug")
	;; php�̓����R�[�h�ݒ�
	(setq *php-xdebug-encoding* *encoding-euc-jp*)  ; EUC-JP�̏ꍇ
	;(setq *php-xdebug-encoding* *encoding-utf8n*)  ; UTF-8�̏ꍇ

	��L�̐ݒ���PHP�t�@�C�����J���āAPHP-Xdebug�}�C�i�[���[�h���L���ɂȂ��Ă���
	�̂��m�F���Ă��������B

	�f�o�b�O�͈ȉ��̂悤�ɍs���܂��B

	1. F5 ��debugclient ���N���B
	2. F12 ��URL����͂��ău���E�U���N����(*2)�Axyzzy�ɖ߂�B
	3. �X�e�b�v���s�������ꍇ�͂܂�F11�������B
	4. �u���[�N�|�C���g��ݒ肵�Ă����܂Ői�߂�ꍇ�́A
		- �ݒ肵�����ꏊ�ŁAF7������
		- F6������
	5. �ϐ��̓��e��\���������ꍇ�ɂ�F8�܂���F9�������ĕϐ�������́B
	6. stopped �ƕ\�����ꂽ����s�͏I�����Ă��܂��̂ŁA�u���E�U�𑀍삵�čēx�J�n�B
	7. �f�o�b�O���I�����鎞��F5�������B

	(*1) �ȉ��̊֐����`���ă��[�J���ƃ����[�g�̃p�X���}�b�s���O���Ă��΁A
	     ������������܂���B
		- php-xdebug-map-remote-to-local
		- php-xdebug-map-local-to-remote
	(*2) �u���E�U�Œ���URL����͂��Ă��\���܂��񂪁A���̏ꍇ�ɂ�URL�Ɉȉ��̃p�����[�^
	     ��ǉ����Ă��������B

		XDEBUG_SESSION_START=xyzzy_php_xdebug


�� ���̑�

	�E�L�[���[�h�t�@�C���́Aphp-4.2.2 + ������keyword.php �Ő����������̂ł��B
	  ���̃o�[�W�������K�v�ȏꍇ�ɂ́Akeyword.php ���g���Đ������Ă��������B

�� Changelog

	[2007/03/14]
	-- �L�[���[�h�t�@�C����PHP5�̃L�[���[�h��K���ɒǉ��B
	-- php-xdebug.l ��ǉ��B

	[2005/11/25]
	-- ���C�Z���X��K�p�Ƃ��B

	[2004/04/10]
	-- php-misc.l �� www.php.net �̃}�j���A���\���̕ύX�ɒǐ��B
	-- browserex.l �����[�h���Ă���ꍇ�ɂ͂�����ŕ\������悤�ɂ����B
	-- �L�[���[�h�t�@�C�������X�N���v�g�T���v���𓯍��B

	[2003/03/17]
	-- php-misc.l��HTML Help�p�R�[�h��ǉ��B

	[2003/02/03]
	-- �L�[���[�h�t�@�C���������A�b�v�f�[�g�B

	[2001/12/01]
	-- ���q���񂩂璸�����L�[���[�h�t�@�C���ɍ����ւ��B(__)
	-- php-misc.l�𓯍��B

	[2001/11/11]
	-- �R�����g�Ƃ���������Ƃ��������B
	-- �L�[���[�h����⊮�Ƃ��B

	[2000/05/22]
	-- xyzzy-0.2.1.143��indent-for-comment�Ή��B

	[1999/11/20]
	-- xyzzy-0.1.1.111�Ή��B
	-- list-function���g����悤�ɂ����B
