 GHCi mode for xyzzy Ver 0.1 alpha
 	by IMAI Takeo <usitukai@osk.3web.ne.jp>
	2006/05/06

�� �͂��߂�
o    - �����N�����Ă��ӔC���Ă܂���
    - GHC 6.4.1 �œ�����m�F���Ă��܂��B

�� �����

     Haskell�R���p�C�� GHC (http://www.haskell.org/ghc/) �̃C���^�v���^��
�@�@�ł���GHCi���Axyzzy��ŋN�����āA�t�@�C�������[�h���āc�Ƃ���邽�߂�
    �}�C�i�[���[�h�B

     �L�[���[�h�̃n�C���C�g�\����I�[�g�C���f���g�܂ł͂��܂���B
     ��������Ƃ� (http://www.geocities.jp/shido_takafumi/index.html) ��
    hs-mode ���Ƃ̕��p�������߂��܂��B

�� �C���X�g�[��

    1. $XYZZY/site-lisp �ȉ��� ghci.l ������

    2. .xyzzy �������� site-init.l �ɐݒ������
      ���̂悤�ɏ����ƁA.hs �Ƃ����g���q�̃t�@�C����ǂݍ��񂾂Ƃ��ɁA
      hs-mode �� ghci-mode �𓯎��N���ł��܂��B

	(load-library "hs-mode")
	(load-library "ghci")
	(push '("\\.hs$" . (lambda ()
		     (hs-mode)
		     (ghci-mode))) *auto-mode-alist*)

       �܂��A�f�t�H���g�ł� "ghci" �Ƃ����R�}���h�ŋN�����܂��̂ŁAghci 
     �ւ̃p�X��PATH���ϐ��ɐݒ肵�Ă������A���邢��

        (setq editor::*ghci-command* "c:/hogehoge/ghci")

     �Ȃǂ̂悤�ɁA�t���p�X��ϐ� *ghci-command* �ɐݒ肵�Ă��������B
     �R�}���h���C���I�v�V������^����ꍇ�����l�ɁB

    �����Z�Ƃ��āA������ hugs �̃p�X�������Ă݂�ƁAhugs �ł����삷����ۂ��ł��B


    3. xyzzy���ċN��


�� ������@
  ���ʏ��ʁ�
    C-c l	GHCi�N���{�t�@�C�����[�h
		���ł�GHCi���N�����Ă���ꍇ�́A�t�@�C���������[�h���܂��B
    C-c q	GHCi�I��

  ��GHCi�N����ʁ�
    GHCi��̑���E�R�}���h�����̂܂ܗ��p�ł��܂��i���Ԃ�j�B


�� TODO�Ƃ�����
- �����I�ɋN�����Ȃ����R�}���h
- ghc �̃R���p�C�����N��


�� ���p����
    ���̃\�t�g�E�F�A�͏C��BSD�X�^�C�����C�Z���X�Œ񋟂��Ă��܂��B
    �ڂ����� license.txt ���Q�l�̂��ƁB


�ȏ�
