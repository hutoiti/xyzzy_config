$Id: readme.txt,v 1.4 2005/11/24 15:12:27 torihat Exp $

 www-mode for xyzzy

 by HATTORI Masashi


�� www-mode �Ƃ́H

	xyzzy��œ����ւȂ��傱WWW Browser�ł��B
	�����Ȃ�������A�܂�����ĂȂ����������X����܂��B
	���p�������Ɋւ��ẮALICENSE.txt�������������B

�� �����

	xyzzy-0.2.0.160�ȍ~

�� �C���X�g�[��

    1. �t�@�C����W�J����B

	-- *.l �� xyzzy/site-lisp/www/ �ȉ��ɒu���ĉ������B
	-- bookmark.html �� xyzzy/etc �ɒu���ĉ������B

    2. �o�C�g�R���p�C������

	-- www/makefile.l�����[�h���Ă��� M-x www-make���ĉ������B

		�o�[�W�����A�b�v���ăG���[���o�����ɂ́A��x www/*.lc�������Ă���
		xyzzy���ċN�����ăo�C�g�R���p�C�����ĉ������B

    3. �ݒ�

	-- ~/.xyzzy		������sample.xyzzy�����ĉ������B
	-- ~/.www		������sample.www�����ĉ������B

    4. M-x www �ȂǂƂ��ċN������B

�� ������@

	------------------------------------------------------------------
	[�\�����]

	(�L�[�ꗗ)

	Enter		�J�[�\���ʒu�̃����N����J��
			�܂��̓t�H�[���I�u�W�F�N�g�̑���
	�N���b�N	����
	Space		���y�[�W
	n		����
	b		�O�y�[�W
	g		URL���w�肵�ĊJ��
	f		���[�J���t�@�C�����J��
	s		�����N����_�E�����[�h
	C-u s		�����N����_�E�����[�h(Pragma: no-cache�t)
	w		�����N���wget�Ń_�E�����[�h
	L		�����N���URL��\��
	TAB		���̃����N�ʒu�܂��̓t�H�[���I�u�W�F�N�g�ֈړ�
	M-Down		����
	M-Up		�O�̃����N�ʒu�܂��̓t�H�[���I�u�W�F�N�g�ֈړ�
	M-Left		�߂�
	M-Right		�i��
	h		�y�[�W�̃��X�g���|�b�v�A�b�v���đI��
	C-F10		����
	R		�ēǍ�
	r		�����R�[�h���w�肵�čĕ\��
	O		���݂̃y�[�W��W���̃u���E�U�ŊJ��
	o		�����N��W���̃u���E�U�ŊJ��
	S		�y�[�W�̃\�[�X��\��
	B		bookmark���J��
	A		���݂̃y�[�W��bookmark�ɒǉ�
	u		�y�[�W�X�V�ꗗ���J��
	U		���݂̃y�[�W���X�V�ꗗ�ɒǉ�
	q		www-mode���I������i�m�F����j
	Q		www-mode���I������i�m�F�Ȃ��j

	------------------------------------------------------------------
	[�\�[�X�\�����]

	(�L�[�ꗗ)

	Enter		�\����ʂ֖߂�
	q		www-mode���I������i�m�F����j
	Q		www-mode���I������i�m�F�Ȃ��j

	------------------------------------------------------------------

�� �y�[�W�X�V�ꗗ

	�o�^���Ă������y�[�W�̍X�V�����𒲂ׂĕ��בւ��Ĉꗗ�\�����܂��B

	�L�^�t�@�C����*www-update-data-file*�i�����l��update.html�j�ł��B
	M-x www-update-convert-from-bookmark �ŁAbookmark����ϊ����邩�A
	�y�[�W���J���Ă����āA"U" �Œǉ����邩�A���ڊJ���ĕҏW���č쐬����
	�������B

	�X�V����ɂ� M-x www-update-pages ���ĉ������B�iwww-mode���� "u"�j

	�� Last-modified �w�b�_�[��Ԃ��Ȃ��y�[�W�͍X�V�������擾�ł��܂���B

�� ���̑�

	��Internet Explorer�̂��C�ɓ����bookmark.html�ɃC���|�[�g

		M-x load-library[Enter]
		Load-library: www/import-favorites[Enter]
		M-x www-import-favorites[Enter]

�� ���_

	-- ���낢�낽������

	���[�v�ɓ����đ�����󂯕t���Ȃ��Ȃ����Ƃ��ɂ́Axyzzy���I�����ĉ������B

�� �ł����炢���ȂƎv���Ă��邱��

	-- table�̕`��
	-- frame������

	-- ���̑����낢��

�� �ӎ�

	������쐬����ɂ������āAxyzzy �̍�ҋT�䂳����͂��߁A���낢��ȕ��X
	�ɃA�h�o�C�X�A�p�b�`�Ȃǂ̂����͂𒸂��܂����B���肪�Ƃ��������܂����B
