$Id: readme.txt 822 2009-05-14 17:04:58Z torihat $

 blog-mode

�� blog-mode �Ƃ́H

	xyzzy �Ńu���O�Ƃ��̓ǂݏ���������ւȂ��傱���[�h�ł��B
	���p�������Ɋւ��ẮALICENSE.txt�������������B

�� �����

	xyzzy-0.2.2.235�ȍ~

	�ȉ��̊g���i�Ƃ��ꂪ�ˑ�����g���j���K�v�ł��B
		- xml-rpc-modoki
		- atom-modoki

�� �Ή��u���O

	��XML-RPC
		Movable Type�݊���API�ɑΉ�
		�E�ꉞ�e�X�g���Ă݂���
			- �R�R���O
			- Movable Type 3.2���{��� Release-2

	��Atom API
		livedoor Blog�Ƀe�X�g�Ή��B
			�E���p�ł���@�\�͌����܂��B���s�����ϊ��ݒ蓙��
			�@Web�Ǘ���ʂ���s���Ă��������B
			�E������/���J�̐��䂪�ł��܂���B�ۑ�����ƌ��J����
			�@�܂��̂Œ��ӂ��Ă��������B
			�E���e�ɃJ�e�S����ݒ肷�邱�Ƃ͂ł��܂����A�擾��
			�@�邱�Ƃ��ł��܂���B
		�͂Ăȃ_�C�A���[�Ƀe�X�g�Ή��B
			�E���p�ł���@�\�͌����܂��B
			�E�������̓T�|�[�g���Ă��܂���B

���C���X�g�[��

	�z�z�A�[�J�C�u�� system-root �ȉ��ɓW�J���Ă��������B

���ݒ�

	�E~/.xyzzy �Ȃǂɐݒ�
		(autoload 'blog-mode "blog/defs" t)
		(autoload 'blog-toggle "blog/defs" t)
	�� NetInstaller�o�R�ŃC���X�g�[������ ni-autoload �𗘗p���Ă���ꍇ
	�@ �ɂ͕K�v����܂���B

	�E���̑��̐ݒ�� ~/.blog/config.l �ōs���Ă��������B
		�i������ config.l.sample �Q�Ɓj

���A���C���X�g�[��

	�W�J�����t�@�C�����폜���Ă��������B

	�u���O�̐ݒ�Ȃǂ́A~/.blog �ȉ��ɕۑ�����Ă��܂��̂ŁA�Y�ꂸ�ɍ폜
	���Ă��������B

���N��

	M-x blog-mode		blog-mode���N��
	M-x blog-toggle		blog-mode���o������������߂��肷��

	�E�ŏ��̓u���O���o�^����Ă��܂���̂ŁA"a" �œo�^���s���Ă��������B
		�� "Type" �͈ȉ��̂ǂꂩ��I�����Ă��������B
			- MovableType
			- Cocolog
			- livedoorBlog
			- Hiki
			- FreeStyleWiki
			- HatenaDiary

���L�[�o�C���h

	[�u���O�ꗗ]
		Enter		�u���O�̓��e�ꗗ���J��
		Space		����
		a		�u���O��o�^
		p		���̍s�̃u���O�̐ݒ胁�j���[��\��
		d		���̍s�̃u���O���폜
		C-k		���̍s�̃u���O��؂���
		C-y		�؂������u���O��\��t��
		o		���̍s�̃u���O���u���E�U�ŊJ��
		q		�I��

	[���e�ꗗ]
		Enter		���̍s�̓��e���J��
		Space		����
		n		�V�K���e
		d		���̍s�̓��e���폜
		r		���e�ꗗ���X�V
		q		���e�ꗗ�����

	[���e�ڍ�]
		�E�N���b�N	���j���[��\��
		Enter		�J�[�\���ʒu�̍��ڂ�ҏW
		q		���e�ڍׂ����
		r		���e�ڍׂ��X�V
		n		�V�K���e
		o		���e���u���E�U�ŊJ��
		p		�ȈՃv���r���[
		u		�t�@�C���A�b�v���[�h
		g		����Ping���M
		C-x C-s		���e���T�[�o�[�ɕۑ�
		C-c C-c		���e���T�[�o�[�ɕۑ����Č��J
		d		���e���폜

			a	���e������ҏW�i�~�j�o�b�t�@�j
			A	���e���������݂ɂ���
			t	�^�C�g����ҏW�i�~�j�o�b�t�@�j
			e	�{����ҏW�i�ҏW��ʁj
			g	�T�v��ҏW�i�ҏW��ʁj
			k	�ǋL��ҏW�i�ҏW��ʁj
			b	TrackBack���M���ҏW�i�ҏW��ʁj
			c	�J�e�S���I���i���j���[�j

	[�ҏW���]
		C-x C-s		���e��ۑ����ĕҏW���I��
		C-c q		�ҏW��ۑ������ɏI��

�� TODO

	�E�ҏW�x���̂���₱���Ƃ��B
	�EAtom API�̑Ή����܂Ƃ��ɂ���Ƃ��B

�� �ύX����

	[2009/05/14]
		�E�͂Ăȃ_�C�A���[�̃e�X�g�T�|�[�g�B

	[2006/02/05]
		�EHiki�AFreeStyleWiki�̃e�X�g�T�|�[�g�B

	[2006/01/22]
		�E�R�R���O�̃^�C���X�^���v�̕␳
		�E����Ping���M

	[2006/01/19]
		�E�ȈՃv���r���[�@�\��ǉ�
		�E�t�@�C���A�b�v���[�h�@�\��ǉ�

	[2006/01/11]
		�E����
