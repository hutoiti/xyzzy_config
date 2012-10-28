$Id: readme.txt,v 1.1.1.1 2005/11/25 13:06:17 torihat Exp $

 ruby-mode for xyzzy

 by Masashi Hattori

�� ruby-mode �Ƃ́H

	xyzzy�p��ruby�������[�h�ł��B
	c-mode, c++-mode���̑�����p���[�h���Q�l�ɍ��܂����B

	-- �L�[���[�h��F����
	-- TAB�ȂǂŎ����C���f���g
	-- �^�O�W�����v
	-- �N���X�A�֐��̈ꗗ�\��
	-- �N���X���A�֐����̕⊮

	�Ȃǂ��ł�����ł��Ȃ������肵�܂��B

	���p�������� LICENSE.txt �������������B

�� �C���X�g�[��

    1. �t�@�C����W�J����B

	-- *.l�� xyzzy/site-lisp �ɒu���ĉ������B
	-- Ruby �� xyzzy/etc �ɒu���ĉ������B

    2. �o�C�g�R���p�C������

	-- *.l���o�C�g�R���p�C���B

    3. .xyzzy�Ȃǂɐݒ�

	(load-library "ruby")
	(push '("\\.rb$" . ruby-mode) *auto-mode-alist*)
	; �C���f���g�ʂ�ς���
	;(setq *ruby-indent-column* 3)
	(load-library "ruby-lister")
	; rtags.rb�܂ł̃p�X
	(setq *ruby-lister-rtags-path* "C:/ruby/rtags.rb")
	(load-library "ruby-debug")	;debug���[�h���g���Ȃ�
	(load-library "ruby-doc")	;rd���[�h���g���Ȃ�
	(load-library "ruby-misc")	;���̑����g���Ȃ�
	; ri.rb�܂ł̃p�X
	(setq *ruby-information-command* "C:/cygwin/usr/local/bin/ri.rb")

�� ���_

	-- �C���f���g�����܂������Ȃ��ꍇ���X����

�� Changelog

	[2005/11/25]
	-- ���C�Z���X��K�p�Ƃ��B

	[2001/11/11]
	-- �L�[���[�h��������Ƃ�������
	-- ruby-misc.l�ǉ��B

	[2000/06/18]
	-- �ւȂ��傱RD�p���[�h��ǉ��B
	   �Ȃ�RD���̂܂��悭�킩���ĂȂ����ǁB

	   �L�[�o�C���h��
		C-c d	=>	RD���[�h
		C-x d	=>	�f�o�b�O���[�h
	   �ɕς��܂����B

	[2000/06/04]
	-- �ւȂ��傱�f�o�b�O���[�h��ǉ��B

	[2000/05/22]
	-- xyzzy-0.2.1.143�Œǉ����ꂽindent-for-comment�ɑΉ��B

	[2000/01/28]
	-- ESC TAB�ŃL�[���[�h����⊮�ł���悤�ɂ����B

	[1999/11/19]
	-- xyzzy-0.1.1.111�ɑΉ��Bmaketags.l��������Ȃ��Ă��ǂ��Ȃ����B

	[1999/11/16]
	-- info��1.4��info�Ή��ɕύX�B

	[1999/10/15]
	-- �����C���f���g���� "=begin ... =end" �𖳎�����悤�ɂ����i���Ԃ�j�B
	-- �L�[���[�h�ݒ��������ƕύX�B

	[1999/10/12]
	-- rtags.rb��TAGS�t�@�C���𗘗p�����N���X�A�֐��c���[�\����������B

	[1999/10/08]
	-- �v���Ԃ�Ɏg�����Ƃ�����C���f���g���S�R�ł��Ȃ��Ȃ��Ă����̂�
	   �������B
	-- readme.txt���������B
	-- CVS�ŊǗ�����悤�ɂ����B
	-- ML�ŗ��ꂽ�T�䂳��̊֐��ꗗ�}�N���p�ɃR�[�h��ǉ������B

�� ���̑�

	�� [F1] �� info���猟���ł���悤�ɂ���B

		1. �R�{����̂Ƃ��납��info.l�������ė��ē����B
			<http://www1.neweb.ne.jp/wa/sinj/xyzzy/>
		2. ruby-texi-1.4.tar.gz������Ă���info.l����ǂ߂�悤�ɂ���B
			<ftp://ftp.netlab.co.jp/pub/lang/ruby/doc/>�Ȃ�

	�� �֐��ꗗ�\�����ăW�����v

		1. M-x list-function (C-c l)

	�� �N���X�A�֐����c���[�\��

		1. rtags.rb��TAGS�t�@�C�������
			-- rtags.rb ��irb�Ɋ܂܂�Ă��܂��B
				http://raa.ruby-lang.org/list.rhtml?name=irb-tools
			-- ruby-mode����Ȃ� M-x ruby-lister-make-rtags (C-c m)�B
		2. M-x ruby-lister (C-F4)

	�� �f�o�b�O���[�h

		M-x ruby-debug (C-x d)�Ńf�o�b�O���[�h�ɓ���B

		�L�[�o�C���h

		Enter		�R�}���h�Ȃǂ����
		Y		(y/n)�Ƃ���y�����
		N		(y/n)�Ƃ���n�����
		q		�f�o�b�O���[�h���I��
		Q		�f�o�b�O���[�h���I���i�m�F�Ȃ��j
		b		���ݍs��break point��ݒ�
		B		�ݒ肳��Ă���break point��\��
		w		���ݍs��watch point��ݒ�
		d		���ݍs�ɐݒ肳��Ă���point������
		D		�ݒ肳��Ă���point�����ׂĉ���
		e		display��ݒ�
		E		�ݒ肳��Ă���display��\��
		u		display������
		U		display�����ׂĉ���
		c		���s
		s		step
		C-u s		step�i�����́j
		n		next
		C-u n		next�i�����́j
		h		where
		C-Up		up
		C-Down		down
		f		finish
		p		p�R�}���h

	�� RD�p���[�h

		M-x ruby-doc-minor-mode (C-c d)�Ń��[�h�ɓ���

		�L�[�o�C���h

		Enter		���s���ăC���f���g
		TAB		�C���f���g
		M-Left		�C���f���g�����炷
		M-Right		�C���f���g�𑝂₷
		C-c f e		Insert Inline Emphasis
		C-c f c		Insert Inline Code
		C-c f v		Insert Inline Var
		C-c f k		Insert Inline Keyboard
		C-c f i		Insert Inline Index
		C-c f r		Insert Inline Reference
		c-c f u		Insert Inline URL
		C-c f f		Insert Inline Footnote
		C-c f b		Insert Inline Verb

	�� ���̑�

		ruby-misc.l�����[�h

		�L�[�o�C���h
		C-c x		�X�N���v�g�𑖂点��
		C-c w		�X�N���v�g�̃G���[�`�F�b�N
		S-F1		ri�ň���
