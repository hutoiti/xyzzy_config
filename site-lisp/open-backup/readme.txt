$ readme.txt 2006-07-27 $

  open-backup for xyzzy

  by FUKAE Mitsuaki


���T�v

  �o�b�N�A�b�v�t�@�C�����J���܂��B


���͂��߂�

  ������g���ĂȂ񂩖�肪�N���Ă��ӔC�͕����܂���̂ł��������������B


������

  �K�w������ăo�b�N�A�b�v�����l�ɂ����Ή����Ă���܂���B

  �K�w������ăo�b�N�A�b�v�����ɂ́A.xyzzy �� siteinit.l ��

    (require "backup")
    (setq *backup-directory* "~/TextBackUp/")
    (setq *hierarchic-backup-directory* t)

  �ȂǂƂ����Ă��������B


���C���X�g�[��

  1. open-backup.l �� xyzzy/site-lisp �ȉ��ɂ����ăo�C�g�R���p�C�����܂��B

  2. .xyzzy ���Asiteinit.l �Ɉȉ��̃R�[�h��t�������܂��B
     �g���₷���悤�ɓK���ɕҏW���Ă��������B

    (require "open-backup")
    (global-set-key '(#\C-x #\o #\1) 'open-backup-file-new)
    (global-set-key '(#\C-x #\o #\d) 'open-backup-dialog)

  �� ��. ��̃L�[�ݒ�� C-x o ���Ԃ��܂��B

    (setq *open-backup-no-date-duplication* t)
    �Ɛݒ肷��ƁA�_�C�A���O�ɓ��t�̓������̂��\������Ȃ��Ȃ�܂��B
    "�t�@�C����ۑ��������Ƀo�b�N�A�b�v�����" �ݒ�ɂ��Ă��鎞�Ȃǂ�
    �����߂ł��B


���g����

  (�t�@�C���Ɋ֘A�t����ꂽ)�o�b�t�@��� C-x o 1 �Ƃ��܂��ƁA
  �ł��V�����o�b�N�A�b�v�t�@�C�����J����܂��B
  �܂��AC-x o d �Ƃ��܂��ƁA�_�C�A���O�Ƀo�b�N�A�b�v�t�@�C���̈ꗗ���\������܂��B

  �J���ꂽ�o�b�N�A�b�v�t�@�C���� n(p) �������܂��ƁA��(�O)�̃o�b�N�A�b�v�t�@�C��
  ���J����܂��B�o�b�N�A�b�v�t�@�C����ł̃L�[���蓖�Ă͈ȉ��̒ʂ�ł��B

  �L�[            �@�\
  ---             -------
  n               ���̃o�b�N�A�b�v�t�@�C�����J��
  p               �O�̃o�b�N�A�b�v�t�@�C�����J��
  M-n             ���̓��t�̃o�b�N�A�b�v�t�@�C�����J��
  M-p             �O�̓��t�̃o�b�N�A�b�v�t�@�C�����J��
  N               �ł��V�����o�b�N�A�b�v�t�@�C�����J��
  P               �ł��Â��o�b�N�A�b�v�t�@�C�����J��
  q               �o�b�N�A�b�v�t�@�C�������


���X�V����

  06/07/27
  �S�폜�̃��b�Z�[�W��ύX�B

  06/03/08
  *open-backup-no-date-duplication* ��ǉ��B
  *backup-directory* ���֐��Ŏw�肵�Ă���ꍇ�ɑΉ������B
  �o�b�N�A�b�v�t�@�C����� M-n(M-p) �� ��(�O) �̓��t�� �o�b�N�A�b�v�t�@�C�����J
  ���悤�ɂ����B
  ���C�Z���X��K�p�B

  05/08/05
  *backup-directory* ��A�z���X�g�Ŏw�肵���ꍇ�ɑΉ������B
  ���̑��A�ׂ����C���B

  05/03/05
  �l�b�g���[�N���L��̃t�@�C��(//hoge/foo/bar.txt �Ƃ�) �̃o�b�N�A�b�v�t�@�C��
  ���J���Ȃ��̂��C���B(�Ђ�����A"���w�E + ��փR�[�h" Thx �ł�)

  05/01/15
  open-backup-dialog �ł� list �Ƀo�b�N�A�b�v�̍X�V������\������悤�ɂ����B
  (2ch�uxyzzy�̎g������������ʂ₵ ��܂����� ����5�v�X���� 944 ����̃A�C�f�A)
  ���̑��A�ׂ����C���B

  04/12/09
  diff �Ȃǂ̋@�\���폜�B

  04/03/25
  �ׂ����C���B

  04/03/21
  open-backup-file-vertically-new, open-backup-file-horizontally-new ��ǉ��B
  �o�b�N�A�b�v�t�@�C����� n(p) �� ��(�O) �� �o�b�N�A�b�v�t�@�C�����J���悤��
  �����Bq �ŏI���B

  03/04/01
  �o�b�N�A�b�v�t�@�C����S�폜����@�\�������B

  03/02/03
  �w�i�F�̐ݒ����߂ɂ����B

  03/01/16
  �_�C�A���O����I������悤�ɂ����B
  ���̑� ���낢��ς����B

  02/07/31 ���J�B


�����C�Z���X

  �C��BSD���C�Z���X�Ƃ��܂��B������ LICENSE.txt ���Q�Ƃ��������B


���ӎ�

  ������쐬����ɂ�����A
  
  �EXYZZY �� backup.l(�T�䂳��)
      http://www.jsdlab.co.jp/~kamei/
  
  ���Q�l�ɂ����Ă��������܂����B
  �܂����낢��ȕ��X�ɂ����͂𒸂��܂����B
  ���炽�߂Ċ��ӂ̂����\���グ�܂��B
