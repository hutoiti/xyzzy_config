$Id: readme.txt 733 2006-09-02 03:55:11Z torihat $

 rss-mode

�� rss-mode �Ƃ́H

	RSS��ǂނ��߂̂ւȂ��傱�c�[���ł��B
	���p�������Ɋւ��ẮALICENSE.txt�������������B

�� �����

	xyzzy-0.2.2.233�ȍ~

	�ȉ��̊g�����K�v�ł��B

	- junk-library (�ŐV�Łj
	- xml-parser-modoki�i�ŐV�Łj
	- ���܂������������ browser.dll�g����
		http://www.osk.3web.ne.jp/~usitukai/
	- OHKUBO Hiroshi ����� browserex.l
		http://ohkubo.s53.xrea.com/

	- www-mode �i�I�v�V�����Bwww-mode�ŕ\������ꍇ�̂ݕK�v�B�j
	- hecmd �i�I�v�V�����BHyperEstraier�Ō�������ꍇ�̂ݕK�v�B�j

�� �C���X�g�[��

	�� �蓮�C���X�g�[���̏ꍇ
	1. �𓀂��� rss �t�H���_��site-lisp�ȉ��ɒu���Ă��������B

���ݒ�

	�� .xyzzy�Ȃǂւ̐ݒ�

	(autoload 'rss "rss/main" t)
	(autoload 'rss-toggle "rss/main" t)
	(autoload 'rss-add-feed "rss/main" t)

	�� ���̑��̐ݒ�� ~/.rss/config.l �ցB�i������ config.l �Q�Ɓj

���N��

	M-x rss

	�ŏ��͉�������܂���̂ŁA"Default" �� Enter �������A
	"a"��������URL�����ēo�^���Ă��������B

���L�[�o�C���h

	[�O���[�v]
		Enter	���̍s�̃O���[�v���J��
		Right	����
		Space	����
		Tab	���̖��ǂ�T���ĊJ��
		q	�I��
		R	�S�ẴO���[�v���X�V
		a	�O���[�v��ǉ�
		d	�O���[�v���폜
		i	OPML��ǂݍ���
		o	OPML�������o��
		C-k	�O���[�v��؂���
		C-y	�؂������O���[�v��\��t��
		b	�N���b�v�����G���g���ꗗ���J��
		h	�ŋߓǂ񂾃G���g���ꗗ���J��
		/	HyperEstraier�Ō���
		M-t	online/offline���g�O��

	[���j���[]
		Enter	���̍s�̃`���l�����J��
		Right	����
		Space	����
		Tab	���̖��ǂ�T���ĊJ��
		r	���̍s�̃`���l�����X�V���ĊJ��
		n	���̃`���l�����J��
		p	�O�̃`���l�����J��
		q	�O���[�v�ꗗ���J��
		Left	����
		a	URL�܂��̓��[�J���t�@�C������`���l����ǉ�
		d	���̍s�̃`���l�����폜
		C-k	���̍s�̃`���l����؂���
		C-y	�؂������`���l����\��t��
		o	���̍s�̃`���l�����u���E�U�ŊJ��
		m	���̍s�̃`���l���������X�V
		R	�S�`���l�����X�V
		v	���̍s�̃`���l�����|�b�v�A�b�v�\��
		V	���̍s�̃`���l�����|�b�v�A�b�v�\�� �{ �R�s�[
		M-Right	���̃O���[�v���J��
		M-Left	�O�̃O���[�v���J��
		b	�N���b�v�����G���g���ꗗ���J��
		h	�ŋߓǂ񂾃G���g���ꗗ���J��
		/	HyperEstraier�Ō���
		M-t	online/offline���g�O��

	[�`���l��]
		Enter	���݂̃G���g�����J��
		Right	����
		@	���݂̃G���g�����N���b�v
		Tab	���̖��ǂ�T���ĊJ��
		Down	���̃G���g���ֈړ�
		C-n	����
		Up	�O�̃G���g���ֈړ�
		C-p	����
		n	���̃G���g�����J��
		p	�O�̃G���g�����J��
		t	���݂̃G���g���̖��ǁ^���ǂ�؂�ւ���
		T	�S�ẴG���g���̓ǂ񂾂��Ƃɂ���
		d	Description�̕\���^��\����؂�ւ���
		o	���݂̃G���g�����O���u���E�U�ŊJ��
		q	�u���E�U�����^�`���l�������
		Left	����
		r	�`���l�����X�V
		R	�`���l���̃t�@�C�����폜���čĎ擾
		c	�u���E�U�����
		M-Down	���̃`���l�����J��
		M-Up	�O�̃`���l�����J��
		Space	���̍s�̃G���g�����J���^�u���E�U�����ɃX�N���[��
		C-Down	�u���E�U�����ɃX�N���[��
		C-Up	�u���E�U����ɃX�N���[��
		v	���̍s�̃G���g�����|�b�v�A�b�v�\��
		V	���̍s�̃G���g�����|�b�v�A�b�v�\�� �{ �R�s�[
		b	�N���b�v�����G���g���ꗗ���J��
		h	�ŋߓǂ񂾃G���g���ꗗ���J��
		/	HyperEstraier�Ō���
		M-t	online/offline���g�O��

	[�N���b�v�G���g���ꗗ]
		Enter	���݂̃G���g�����J��
		Right	����
		Down	���̃G���g���ֈړ�
		C-n	����
		Up	�O�̃G���g���ֈړ�
		C-p	����
		n	���̃G���g�����J��
		p	�O�̃G���g�����J��
		d	Description�̕\���^��\����؂�ւ���
		D	���݂̃G���g�����ꗗ����폜
		o	���݂̃G���g�����O���u���E�U�ŊJ��
		q	�N���b�v�G���g���ꗗ�����
		c	�u���E�U�����
		Space	���̍s�̃G���g�����J���^�u���E�U�����ɃX�N���[��
		C-Down	�u���E�U�����ɃX�N���[��
		C-Up	�u���E�U����ɃX�N���[��
		v	���̍s�̃G���g�����|�b�v�A�b�v�\��
		V	���̍s�̃G���g�����|�b�v�A�b�v�\�� �{ �R�s�[
		/	HyperEstraier�Ō���
		M-t	online/offline���g�O��

	[�G���g�������ꗗ]
		Enter	���݂̃G���g�����J��
		Right	����
		@	���݂̃G���g�����N���b�v
		Down	���̃G���g���ֈړ�
		C-n	����
		Up	�O�̃G���g���ֈړ�
		C-p	����
		n	���̃G���g�����J��
		p	�O�̃G���g�����J��
		d	Description�̕\���^��\����؂�ւ���
		o	���݂̃G���g�����O���u���E�U�ŊJ��
		q	�G���g�������ꗗ�����
		c	�u���E�U�����
		Space	���̍s�̃G���g�����J���^�u���E�U�����ɃX�N���[��
		C-Down	�u���E�U�����ɃX�N���[��
		C-Up	�u���E�U����ɃX�N���[��
		v	���̍s�̃G���g�����|�b�v�A�b�v�\��
		V	���̍s�̃G���g�����|�b�v�A�b�v�\�� �{ �R�s�[
		/	HyperEstraier�Ō���
		M-t	online/offline���g�O��

�� HyperEstraier�ł̌���

	config.l�Őݒ���s���ƁAHyperEstraier�𗘗p�����S���������s��
	���Ƃ��ł���悤�ɂȂ�܂��B�i�vhecmd�j

	�E�����o�^
		hook��ݒ肵�Ă����΁A�o�b�N�O���E���h�Ŏ����I�ɃC���f
		�b�N�X�ւ̓o�^���s���܂��B
		�ŏ��ɃC���f�b�N�X�o�^�����Ă��܂������ꍇ�́A�O���[�v
		�o�b�t�@�ŁArss::he-group-gather-all �����s���Ă��������B

	�E����
		�����̏������́AKaMailV3�Ƃ������������ł��B
		http://www7a.biglobe.ne.jp/~hat/xyzzy/kamail3/readme.html#search

	�E�o�[�W�����A�b�v
		HyperEstraier�̃o�[�W�����A�b�v�ŃC���f�b�N�X�̃t�H�[�}
		�b�g���ς��ꍇ�ɂ́A�ȉ��̎菇�ŃC���f�b�N�X���č\�z
		���Ă��������B

		1. rss::he-dump
		2. HyperEstraier���o�[�W�����A�b�v
		3. rss::he-restore

	�E�����h���t�g
		�e�G���g���̕����h���t�g�� ~.rss/hedraft �ȉ��ɕۑ�����
		�܂��B�C���f�b�N�X�o�^��͏����Ă��܂��Ă��\���܂��񂪁A
		�o�b�N�A�b�v���Ƃ��Ēu�������ꍇ�ɂ́A�K���ȃ^�C�~���O��
		rss::dump ���Ă������Ƃ��������߂��܂��B

	�E���̑��̃R�}���h

		rss::he-inform
			�C���f�b�N�X����\��
		rss::he-optimize
			�C���f�b�N�X���œK��
		rss::he-clear-draft-files
			�����h���t�g�t�@�C����S�č폜
		rss::he-regather-all
			�����h���t�g�t�@�C�����ēo�^

�� �ύX����

	[2006/09/02]
		rss-0.0.3.0beta1
		�E�L���b�V����n���܂ŕۑ�����I�v�V�����B�iconfig.l�Q�Ɓj
		�EHyper Estraier�Ō�������I�v�V�����B�iconfig.l�Q�Ɓj
		�E�f�[�^���擾�ł��Ȃ��ꍇ�ɂ��o�b�t�@��ݒ肷��悤�ɂ����B
		�E���[�J���t�@�C���Q�Ǝ��Ƀt�@�C���� *rss-directory* �ɃR�s�[����悤�ɂ����B

	[2006/02/11]
		rss-0.0.2.0beta11
		�E�ۑ�����t�H�[�}�b�g���ēx�ύX�B
		�E�f�t�H���g�ł�id/link�Ŋ��ǔ��肷��悤�ɕύX�B
		�E�����Ċ��ǂ̍X�V���ꂽ�G���g���𖢓ǈ����ɂ���I�v�V������ǉ��B
		�E�`���l����o�^����֐��Ƃ��B

	[2006/02/05]
		rss-0.0.2.0beta10
		�E�N�����ɃI�����C�����[�h�ɂ������ɃO���[�v���\������Ȃ��s����C���B
		rss-0.0.2.0beta9
		�E�N���b�v�����G���g�����폜���Ă��������Ă��܂��s����C���B

	[2006/02/04]
		rss-0.0.2.0beta8
		�E�ǂ񂾃G���g���̗����Ƃ��B

	[2006/02/03]
		rss-0.0.2.0beta7
		�E�G���g�����N���b�v����Ƃ��B
		�E�S�X�V���̃G���[���܂Ƃ߂ĕ\������悤�ɁB
		�ERSS2.0/Atom�̏ꍇ�ɂ�id��ۑ�����悤�ɂ����B�グ�čŏ��̍X�V���ɂ�
		�@�S�Ė��ǂɂȂ�̂Œ��ӂ��Ă��������B
		�E�`���l���폜���ɃL���b�V���������悤�ɁB

	[2006/02/01]
		rss-0.0.2.0beta6
		�E�o�b�t�@�������ɖ߂����B�s���ɂ������ꍇ�� config.l �ȂǂŐݒ肵
		�@�Ă��������B
		�Emode-line �X�V�����C���B

	[2006/01/31]
		rss-0.0.2.0beta5
		�E���삳��ɒ������u�t���[�����ő��̃o�b�t�@�ɐ؂�ւ��Ă��߂��悤�Ɂv
		�@�p�b�`����荞�݁B(__)
		�EDefault�O���[�v�̒��������Ă��܂��s��𑽕��������B

	[2006/01/29]
		rss-0.0.2.0beta4
		�E�`���l���o�^���̕s����C���B
		�E���ǂ�T���Ƃ��̏�����ύX�B

	[2006/01/28]
		rss-0.0.2.0beta3
		�E���̖��ǂ����������ꍇ�ɂ�����J�����ǂ����̐ݒ�Ƃ��B
		�E���j���[�ł̖��Ǖ\���Ƃ��B

	[2006/01/27]
		rss-0.0.2.0beta2
		�E�S�X�V��ɖ��ǂ����f����Ȃ��ꍇ���������̂��C���B
		rss-0.0.2.0beta
		�EOPML�����o�����Ɏ��̎Q�Ƃւ̕ϊ���Y��Ă����̂��C���B
		�EHTTP�A�N�Z�X��junk-library�ɐ؂�ւ��B
		�Eparse��̌��ʂ�ۑ�����悤�ɂ����B
		�E����/���ǊǗ��Ƃ��i�ւȂ��傱�j�B�����ĕ\������啝�ɕύX�B
		�Exyzzy Wiki��NANRI����́urss-mode��content:encoded��dc:date�ɑΉ�������v
		�@����荞�݁B(__)
		�E���ł�RSS1.0/RSS2.0/Atom0.3/Atom1.0��������x�ǂ߂�悤�ɁB

	[2006/01/24]
		rss-0.0.1.5
		�EOPML�ǂݍ��݁A�����o���B�i�ւȂ��傱�j
		�Eni-autoload ���̐ݒ�� autoload �ɕύX�B

	[2005/12/04]
		rss-0.0.1.4
		�Exyzzy Wiki�́utips/rss-mode�Ń`�����l���ꗗ��؂�ւ���v
		  ���Q�l�ɃO���[�v���j���[���쐬�B

	[2005/11/30]
		rss-0.0.1.3-3
		�ENANRI����ɒ�����patch����荞�݁B(__)

	[2005/11/29]
		rss-0.0.1.3-2
		�ENANRI����ɒ�����patch����荞�݁B(__)

	[2005/11/12]
		rss-0.0.1.3
		�E���C�Z���X��K�p�Ƃ��B

	[2003/05/01]
		rss-0.0.1.2
		�E�Ǐ��j���[�X�̎@�m����t�����ł�����悤�ɂ����B
		�Eautoload�p�t�@�C����ǉ��B

	[2003/04/07]
		rss-0.0.1.1
		�E�o�O�Ƃ�

	[2003/03/23]
		rss-0.0.1.0
		�E"~/.rss" �Ƃ������ĂĎ��ۂ� "(si:system-root)/.rss" �������̂𒼂����B
		�E���j���[�ɒǉ�����Ƃ��ɉ�ʂ����������Ȃ������̂𒼂����B

	[2003/03/22]
		rss-0.0.0.9
		�E�t�B���^�֐��̈�����ύX�B
		�EHTTP�]������gzip���k�ɑΉ��B
		�E�N������ ~/.rss/config.l[c] ������Γǂނ悤�ɂ����B
		�ELIRS�`���p�̃t�B���^��ǉ��B
		�Ehina-di�`���p�̃t�B���^��ǉ��B
		�Ehina.txt�`���p�̃t�B���^��ǉ��B
		�E�Ǐ��j���[�X�̓������ǂ߂Ȃ��Ȃ��Ă����̂�K���ɑΏ��B

	[2003/03/19]
		rss-0.0.0.8
		�E��/�O�̃`���l�����J���R�}���h�̒ǉ��B
		�EUser-Agent��ς��Ė����悤�ɂ����B

	[2003/03/15]
		rss-0.0.0.7
		�E�o�O�Ƃ�
		�E�`���l���A�A�C�e�����|�b�v�A�b�v�A�R�s�[����R�}���h�̒ǉ�
		�E���j���[����폜���鎞�ɁA�t�@�C�����폜���邩�ǂ��������悤�ɂ����B

	[2003/03/13]
		rss-0.0.0.6
		�E�擾�����t�@�C���ɁA�ݒ肵���t�B���^����������悤�ɂ���

	[2003/03/12]
		rss-0.0.0.5
		�E�L�[�o�C���h�̕ύX��
		�E���[�J���t�@�C�����ǂ߂�悤�ɂ���

	[2003/03/11]
		rss-0.0.0.4
		�Ewww-mode�ł������悤�ɂ���

	[2003/03/10]
		rss-0.0.0.3
		�E����
