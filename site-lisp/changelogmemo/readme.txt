$ readme.txt 2006-03-08 $

  changelogmemo for xyzzy

  by FUKAE Mitsuaki


���T�v

  changelog �ŁA�������Ƃ�܂��B


���͂��߂�

  ������g���ĂȂ񂩖�肪�N���Ă��ӔC�͕����܂���̂ł��������������B


��Changelog �`���ɂ��āA�p��̐���

  -------------------------------------------------------------------
  2004-07-11 (Sun)  YOUR NAME  <your@email.address>
  
  * other-buffer [Xyzzy]: �ŋ�(?)�\������Ă����o�b�t�@�B
  
  -------------------------------------------------------------------
  �̂悤�ɋL�q���܂��B
  ���t�ƌ��ѕt����ꂽ�u���b�N���G���g���A�ЂƂ̃����̃u���b�N���A�C�e��
  �ƌĂт܂��B


���C���X�g�[��

  1. �t�@�C����W�J����

     site-lisp/changelogmemo/ �ȉ��ɒu���ĉ������B

  2. �ݒ�

     -- .xyzzy (�܂��� siteinit.l)
     ������ sample.xyzzy �̓��e��ǉ����ĉ������B

     -- config.l(��Őݒ肵���t�@�C��)
     ������ sample.config.l ���R�s�[���ĕҏW���ĉ������B

  3. xyzzy���ċN��

  �� �o�C�g�R���p�C�����Ȃ����������́A

     1. M-x load-library[Enter]
     2. Load library: changelogmemo/makefile[Enter]
     3. M-x cl-make-clean[Enter]
     4. M-x cl-make[Enter]

  �Ƃ��Ă��������B


���A���C���X�g�[�����̒���

  �c�[���o�[���g���Ă���ꍇ�́A
  Esc Esc (delete-command-bar 'cl-tool-bar) RET
  �����s���ăc�[���o�[���폜���Ă��������B


���g�����߂̏���(changlog file ���w��̏����ɕϊ�����)

  2003-04-14 �ňȑO�̂��̂ł́A�G���g���ɗj���������A�A�C�e���Ƀ^�u������
  -----------------------------------------
  * �J�e�S��: �E�E�J�e�S��: �^�C�g��: �{�� 
  -----------------------------------------
  �̂悤�ɋL�q���邱�Ƃ�z�肵�Ă��܂����B

  ������A�G���g���ɗj�������A�A�C�e���Ƀ^�u��������
  -------------------------------------------
  * �^�C�g�� [�J�e�S��] �E�E[�J�e�S��]: �{�� 
  -------------------------------------------
  �Ə����`���ɕϊ����܂��B

  �ȉ��̑���ł͌��t�@�C�������������܂��̂ŁA���s�̑O�Ƀo�b�N�A�b�v���Ƃ���
  �����Ă��������B(���ȐӔC�ł��肢�����܂�)

  ����:
  M-x cl::cl-convert �����s���āA�ϊ��O�̃t�@�C��������͂��A
  �ŏ��̎���� 2, ���̎���� 1, ���̎��̎���� 1 �Ɠ����āA
  "�j���L + �^�C�g�� [�J�e�S��]: + �^�u��" �̌`���ɕϊ����܂��B


���g����

����{�I�Ȏg����

�EC-x 4 @ �Ƒł��A�c�[���o�[���N���b�N�Ń������N�����܂��B
�E�ۑ��́AC-x C-s �ōs���܂��B
�EC-x k �Ńo�b�t�@�� kill ���邩�A�c�[���o�[���N���b�N�Ń������I���ł��܂��B
�ECtrl �������Ȃ���c�[���o�[���N���b�N����ƁA�ʃo�b�t�@�Ƀ������N�����܂��B


���������@

�EC-x 4 / �Ƃ���ƁAgoogle �̂悤�Ȋ����Ō������܂��B(�}�C�i�X�����A
  �t���[�Y��������)
�E�����o�b�t�@�� M-/ �Ƃ��邱�Ƃōi���������s���܂��B
�E���ɁA���K�\������(C-x 4 g), or ����(C-x 4 o), �J�e�S������(C-x 4 c),
  �N����(C-x 4 y), ������(C-x 4 m), ������(C-x 4 d), migemo ����(C-x 4 j)
  ���o���܂��B
�E������ʂ��璼�� �ҏW���ĕۑ�(C-x C-s)�ł��܂��B


�����̑�

�E������ CL�t�@�C�����g���Ƃ��́A*cl-config-file-alist* �ŕ����w�肵�܂��B
  C-x 4 \ �� CL�t�@�C����؂�ւ��Ďg���Ă��������B
�Econfig.l �� *chalow-command* ��ݒ肷��ƁAC-x 4 h �� chalow �̃R�}���h��
  ���s�ł��܂��B


���L�[���蓖��

[�����o�b�t�@]

  M-Down  : ���̃G���g���Ɉړ�
  M-Up    : ��̃G���g���Ɉړ�
  C-.     : �J�e�S���̕⊮
  C-j     : (��s�ŉ�����)�A�C�e����}��
  C-x j   : �G���g����}��
  C-x C-s : ������ۑ�

[�����o�b�t�@]

  M-/     : �i���� google ����
  M-o     : �i���� or ����
  M-g     : �i���ݐ��K�\������
  M-c     : �i���݃J�e�S������
  M-y     : �i���ݓ��t(�N)����
  M-m     : �i���ݓ��t(��)����
  M-d     : �i���ݓ��t(��)����
  M-Right : ���̌����ɐi��
  M-Left  : ��O�̌����ɖ߂�
  M-r     : �Č���(�X�V)
  M-f     : ���t�����Ŏ��̓��t�̌����Ɉړ�
  M-b     : ���t�����őO�̓��t�̌����Ɉړ�
  M-Down  : ���̃G���g���Ɉړ�
  M-Up    : ��̃G���g���Ɉړ�
  M-n     : ���̃����N�Ɉړ�
  M-p     : �O�̃����N�Ɉړ�
  TAB     : �J�e�S���Ԃ��ړ�
  RET     : �����N�̏�ŉ����ƁA�����N���ꂽ�����Ɉړ�����
  ESC RET : RET �Ƃقړ���(�J�e�S���̏�ŉ����ƍi�荞�܂Ȃ�)
  C-.     : �J�e�S���̕⊮
  C-j     : �A�C�e����}��
  C-x C-s : �ۑ�


�����_

�E�t�@�C�����傫���Ȃ�ƁA��������H�����삪�x���Ȃ�B
�E������ʂő�ʂ̕ҏW������ƕۑ��ł��Ȃ��d�l�B(�ۑ��Ɏ��Ԃ������肷���邽��)
�E�W���̊֐� ed::show-match, close-session �����������Ă���B
�E*scratch* �o�b�t�@�� undo ���Ƃ����X�g�A�ł��Ȃ��B
�E���̑��A���낢��B


���X�V����

  06/03/08
  �s���Ƀ^�u���Ȃ� chalow �p�̏���(* �^�C�g�� [�J�e�S��]�E�E[�J�e�S��]: �{��) 
  �ɂ����B
  C-x C-s �Ń�����ۑ�����悤�ɕς����B
  *scratch* �o�b�t�@�������o�b�t�@�Ƃ��Ďg���悤�ɂ����B
  �����̎�ނ��ӂ₵���B(google, ���K�\��, or, �J�e�S��, ���t, migemo)
  �i���݌����̂�����ύX�B
  ������ʂ��璼�ڕҏW�ł���悤�ɂ����B
  �J�e�S����ݒ肵�Ă����Ȃ��Ă��⊮�ł���悤�ɂ����B
  �c�[���o�[�Ń������Ƃ��悤�ɂ����B
  ������ CL�t�@�C���ɑΉ��B
  ���C�Z���X��K�p�B
  ���̑��A���낢��ς����B

  03/04/14
  Window �̑ޔ�@��ύX�B
  �������C���B

  03/04/01
  ��s�� C-j �������ƁA* : �������I�ɑ}�������悤�ɂ����B
  changelogmemo-mode �� C-. �ŃJ�e�S�����̕⊮�B
  ������ʂ� "*" ���_�u���N���b�N���Ă� jump ����悤�ɂ����B
  �i���݌����̐F�t����ύX�B

  03/01/16
  �I���ł��Ȃ��Ȃ��Ă����̂��C���B

  03/01/11
  Kamail, 2ch �Ȃǂ��痘�p���₷�������B
  ������ʂ��� jump �ł���悤�ɂ����B(���t�� F8, �_�u���N���b�N)

  02/11/25 �ׂ����C���B

  02/11/15 ���J�B


�����C�Z���X

  �C��BSD���C�Z���X�Ƃ��܂��B������ LICENSE.txt ���Q�Ƃ��������B


���ӎ�

  ������쐬����ɂ�����A
  
  �Echalow(�R���B�Y����)
      http://nais.to/~yto/tools/chalow/
  �Echangelog.l(��������)
      http://www7a.biglobe.ne.jp/~hat/xyzzy/misc.html
  �Ecalmemo(�Ђ�����)
      http://hie.s64.xrea.com/xyzzy/mylib/
  �Ehowm(��������)
      http://www.me.ics.saitama-u.ac.jp/~hira/emacs/howm/index-j.html
  �Ehowm-wrap(kimura ����)
      http://homepage3.nifty.com/~ko-ji/
  �EXYZZY �� session.l, textmode.l(�T�䂳��)
      http://www.jsdlab.co.jp/~kamei/
  �Eaddref.l(YAMAMOTO Taizo ����)
      http://www1.odn.ne.jp/ymtz/xyzzy.html
  �Eoutline-tree2(OHKUBO ����)
      http://ohkubo.s53.xrea.com/xyzzy/index.html
  �EUnix�̃����Z�p(���т���̋L��)
      http://www.namazu.org/~satoru/unimag/1/
  
  ���Q�l�ɂ����Ă��������܂����B
  �܂����낢��ȕ��X�ɂ����͂𒸂��܂����B
  ���炽�߂Ċ��ӂ̂����\���グ�܂��B
