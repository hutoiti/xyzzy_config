= hatena-haiku-mode - �͂Ăȃn�C�N��p�u���E�U

  * Author: �݂�ނ� ���䂫 ((<URL:mailto:miyamuko@gmail.com>))
  * Home URL: ((<URL:http://miyamuko.s56.xrea.com/xyzzy/hatena-haiku-mode/intro.htm>))
  * Version: 0.3.2


== SYNOPSIS

  M-x haiku-recent-entries-pane       ; �ŋ߂� Entries

  M-x haiku-my-entries-pane           ; ������ Entries
  M-x haiku-my-following-pane         ; ������ Following
  M-x haiku-my-profile-pane           ; ������ Profile

  M-x haiku-user-entries-pane         ; ���郆�[�U�� Entries
  M-x haiku-user-following-pane       ; ���郆�[�U�� Following
  M-x haiku-user-profile-pane         ; ���郆�[�U�� Profile

  M-x haiku-keyword-entries-pane      ; ����L�[���[�h�� Entries

  M-x haiku-keyword-list-pane         ; �L�[���[�h�̈ꗗ

  M-x haiku-show-new-entry-pane       ; �o�b�t�@���J���ē��e
  M-x haiku-post-minibuffer           ; �~�j�o�b�t�@���瓊�e
  C-u M-x haiku-post-minibuffer       ; ���e���̃N���C�A���g (from) ���w�肵�ă~�j�o�b�t�@���瓊�e

  M-x haiku-show                      ; z �ňꎞ�I�ɉB�����n�C�N�o�b�t�@���ĕ\��


== DESCRIPTION

hatena-haiku-mode �� ((<"�͂Ăȃn�C�N"|URL:http://h.hatena.ne.jp/>)) ��
xyzzy ��ŉ{���E���e���邽�߂̐�p�u���E�U�ł��B

�ȉ��̂��Ƃ��ł��܂��B

  * �ŋ߂̃G���g���̕\��
  * ���[�U�G���g���̕\��
  * �L�[���[�h�G���g���̕\��
  * �L�[���[�h�ꗗ�̕\��
  * �L�[���[�h�̌���
  * �V�K���e
  * �ԐM
  * �u���E�U�̗����݂����ɖ߂�E�i��
  * �X�V
  * �͂ĂȃX�^�[
  * �z�b�g�L�[���[�h
  * �G���g���̍폜
  * ���e���̃N���C�A���g�̕ύX (�f�t�H���g�� hatena-haiku-mode)

�ȉ��͂܂��ł��܂���B

  * �ԐM��W�J
  * ���̑����낢��...


== INSTALL

((<NetInstaller|URL:http://www7a.biglobe.ne.jp/~hat/xyzzy/ni.html>)) �ŃC���X�g�[�������ꍇ�� 3 �ȍ~���A
NetInstaller + ni-autoload ���g���Ă���l�� 4 �ȍ~�� OK �ł��B

(1) �A�[�J�C�u���_�E�����[�h���܂��B

    ((<URL:http://miyamuko.s56.xrea.com/xyzzy/archives/hatena-haiku-mode.zip>))

(2) �A�[�J�C�u��W�J���āA$XYZZY/site-lisp �z���Ƀt�@�C�����R�s�[���܂��B

(3) ~/.xyzzy �܂��� $XYZZY/site-lisp/siteinit.l �Ɉȉ��̃R�[�h��ǉ����܂��B

        ;; hatena-haiku-mode
        (require "hatena-haiku-mode")

(4) �ݒ�𔽉f�����邽�� xyzzy ���ċN�����Ă��������B

    ��siteinit.l �ɋL�q�����ꍇ�ɂ͍ă_���v���K�v�ł��B

(5) M-x haiku-recent-entries-pane �ŋN�����܂��B


== DEPENDS

hatena-haiku-mode �͈ȉ��̃��C�u�����Ɉˑ����Ă��܂��B

  * ((<"xml-http-request"|URL:http://miyamuko.s56.xrea.com/xyzzy/xml-http-request/intro.htm>))
    1.1.1 �ȏ�
  * ((<"hatena-star"|URL:http://miyamuko.s56.xrea.com/xyzzy/hatena-star/intro.htm>))
    1.1.0 �ȏ�
  * ((<"json"|URL:http://miyamuko.s56.xrea.com/xyzzy/json/intro.htm>))
    0.1.1 �ȏ�


== KEYBIND

=== �o�b�t�@���� (���e�o�b�t�@������)

  /                   �L�[���[�h�̌���
  q                   �͂Ăȃn�C�N���[�h���I��
  z                   �n�C�N�o�b�t�@���ꎞ�I�ɉB�� (�{�X������)

  T                   �ŐV�G���g���[ (Recent Entries) ��\��
  M                   ������ Following �y�[�W��\��
  L                   �L�[���[�h���X�g��\��
  H                   �z�b�g�L�[���[�h��\��

  SPC                 ���̃y�[�W�ֈړ� (�y�[�W�����ǂݍ��ݕt��)

  C-h                 �߂� (BackSpace)
  ESC Left            �߂� (Alt ��)
  ESC Right           �i�� (Alt ��)

  F5                  �ŐV�ɍX�V
  S-F5                �S�X�V

=== �L�[���[�h���X�g�o�b�t�@

  j                   ���̃L�[���[�h�ֈړ� (�y�[�W�����ǂݍ��ݕt��)
  k                   �O�̃L�[���[�h�ֈړ� (�y�[�W�����ǂݍ��ݕt��)
  C-n                 ���̍s�ֈړ� (�y�[�W�����ǂݍ��ݕt��)
  C-v                 ���̃y�[�W�ֈړ� (�y�[�W�����ǂݍ��ݕt��)

  RET                 �J�[�\�����̃L�[���[�h��\��
  t                   ����
  v                   �J�[�\�����̃L�[���[�h���u���E�U�ŕ\��

=== �G���g���ꗗ�o�b�t�@

  E                   Entries �y�[�W��\�� (���[�U�G���g���̂�)
  F                   Following �y�[�W��\�� (���[�U�G���g���̂�)
  P                   Profile �y�[�W��\�� (���[�U�G���g���̂�)

  K                   �G���g���̃L�[���[�h�̈ꗗ�̕\���E��\�����g�O��
  U                   �G���g���̃��[�U�̈ꗗ�̕\���E��\�����g�O��

  N                   �V�K���e�o�b�t�@���J��
  R                   �J�[�\�����̃G���g���ւ̕ԐM�o�b�t�@���J��
  S                   �J�[�\�����̃G���g���Ɂ���t����
  D                   �J�[�\�����̃G���g�����폜

  j                   ���̃G���g���ֈړ� (�y�[�W�����ǂݍ��ݕt��)
  k                   �O�̃G���g���ֈړ� (�y�[�W�����ǂݍ��ݕt��)
  C-n                 ���̍s�ֈړ� (�y�[�W�����ǂݍ��ݕt��)
  C-v                 ���̃y�[�W�ֈړ� (�y�[�W�����ǂݍ��ݕt��)

  RET                 �J�[�\�����̃G���g���̃L�[���[�h��\��
  t                   ����
  u                   �J�[�\�����̃G���g���̃��[�U��\��
  v                   �J�[�\�����̃G���g�����u���E�U�ŕ\��

  h G                 �J�[�\�����̃��[�U�̂͂ĂȃO���t��\��
  h a                 ���͂ĂȃA���e�i
  h b                 ���͂Ăȃu�b�N�}�[�N
  h d                 ���͂Ăȃ_�C�A��
  h f                 ���͂Ăȃt�H�g���C�t
  h g                 ���͂ĂȃO���[�v
  h h                 ���͂Ăȃn�C�N
  h i                 ���͂ĂȃA�C�f�A
  h m                 ���͂Ăȃ}�b�v
  h q                 ���͂ĂȃN�G�X�`����
  h r                 ���͂Ă� RSS
  h s                 ���͂ĂȃX�^�[
  h w                 ���͂Ăȃ��[���h

=== �G���g���̃��[�U�ꗗ�o�b�t�@

  j                   ���̃��[�U�ֈړ�
  k                   �O�̃��[�U�ֈړ�

  RET                 �J�[�\�����̃G���g���̃��[�U��\��
  u                   ����
  t                   �J�[�\�����̃G���g���̃L�[���[�h��\�� (�L�[���[�h�y�[�W�̂�)
  v                   �J�[�\�����̃G���g���̃��[�U���u���E�U�ŕ\��

  h G                 �J�[�\�����̃��[�U�̂͂ĂȃO���t��\��
  h a                 ���͂ĂȃA���e�i
  h b                 ���͂Ăȃu�b�N�}�[�N
  h d                 ���͂Ăȃ_�C�A��
  h f                 ���͂Ăȃt�H�g���C�t
  h g                 ���͂ĂȃO���[�v
  h h                 ���͂Ăȃn�C�N
  h i                 ���͂ĂȃA�C�f�A
  h m                 ���͂Ăȃ}�b�v
  h q                 ���͂ĂȃN�G�X�`����
  h r                 ���͂Ă� RSS
  h s                 ���͂ĂȃX�^�[
  h w                 ���͂Ăȃ��[���h

=== �G���g���̃L�[���[�h�ꗗ�o�b�t�@

  j                   ���̃L�[���[�h�ֈړ�
  k                   �O�̃L�[���[�h�ֈړ�

  RET                 �J�[�\�����̃G���g���̃L�[���[�h��\��
  t                   ����
  v                   �J�[�\�����̃G���g���̃L�[���[�h���u���E�U�ŕ\��

=== �V�K���e�E�ԐM�o�b�t�@

  C-c C-c            ���e����
  C-u C-c C-c        ���e���̃N���C�A���g (from) ���w�肵�ē��e����
  C-x k              ����


== MODULE

=== PACKAGE

hatena-haiku-mode �͈ȉ��̃p�b�P�[�W�𗘗p���Ă��܂��B

  * hatena-haiku.util
  * hatena-haiku.api
  * hatena-haiku.ui

=== EXPORT

hatena-haiku-mode �͈ȉ��̃V���{���� export ���Ă��܂��B

  * hatena-haiku.ui �p�b�P�[�W

    * SYNOPSIS ����

  * hatena-haiku.api �p�b�P�[�W

    * ���낢��

  * hatena-haiku.util �p�b�P�[�W

    * �����p�b�P�[�W�Ȃ̂ŏȗ�


=== VARIABLE

--- *haiku-default-source*

    ���e���̃N���C�A���g (from ��) ��ݒ肵�܂��B
    �f�t�H���g�� hatena-haiku-mode �ł��B

    �O�u�������w�肷�邱�Ƃœ��e���ɂ��ύX�ł��܂� (C-u C-c C-c)�B

--- *haiku-post-buffer-height-ratio*

    ���e�o�b�t�@�̍����̔䗦�� 0 �` 1 �Ŏw�肵�܂��B
    �f�t�H���g�� 0.3 (= �S�̂� 30% �̍���) �ł��B

--- *haiku-disable-color*

    non-nil �Ȃ�F�Â�����؂��܂���B

--- *haiku-page-title-color*

    �G���g���y�[�W�̃^�C�g���̐F���w�肵�܂��B
    �F�̎w����@�� set-text-attribute �̃��t�@�����X���Q�Ƃ��Ă��������B

      ;; ���]
      (setf *haiku-page-title-color* '(:bold t :foreground 7 :background 12))

--- *haiku-page-subtitle-color*

    �G���g���y�[�W�̃T�u�^�C�g���̐F���w�肵�܂��B

--- *haiku-entry-title-color*

    �G���g���̃^�C�g���̐F���w�肵�܂��B

--- *haiku-entry-meta-color*

    �G���g���̃��[�U���Ȃǂ̐F���w�肵�܂��B

--- *haiku-entry-meta-text-color*

    �G���g���̃��[�U��񕔕��̃e�L�X�g�̐F���w�肵�܂��B

--- *haiku-star-color*

    ���̐F���w�肵�܂��B

--- *haiku-keyword-color*

    �L�[���[�h�ꗗ�ł̃L�[���[�h�̐F���w�肵�܂��B

--- *haiku-user-color*

    ���[�U�ꗗ�ł̃��[�U���̐F���w�肵�܂��B

--- *haiku-post-title-color*

    ���e�o�b�t�@�ł̃^�C�g���̐F���w�肵�܂��B

--- *haiku-post-description-color*

    ���e�o�b�t�@�ł̐����̐F���w�肵�܂��B

--- *haiku-hot-keyword-color-list*

    hot keyword �̐F�����X�g�Ŏw�肵�܂��B

    hot keyword �̓L�[���[�h�̃z�b�g�x(?)�ɉ����� 1 �` 7 �̐��l�������Ă��܂��B
    7 ����ԃz�b�g�ȃL�[���[�h�ł��B

    *haiku-hot-keyword-color-list* �ɂ�
    �z�b�g�x�ɑΉ�����F�� 1 �` 7 �̏��Ɏw�肵�܂��B

        (setf *haiku-hot-keyword-color-list*
          '((:foreground 15)                      ; �z�b�g�x�� 1 (�N�[���Șb��)
            (:foreground 14)                      ; �z�b�g�x�� 2
            (:foreground 10)                      ; �z�b�g�x�� 3
            (:foreground 10)                      ; �z�b�g�x�� 4
            (:foreground 10 :bold t)              ; �z�b�g�x�� 5
            (:foreground 10 :bold t)              ; �z�b�g�x�� 6
            (:foreground 10 :bold t :underline t) ; �z�b�g�x�� 7 (��ԔM���b��)
            ))

    �ʂɐݒ肵�����ꍇ��
    ((<haiku-set-hot-keyword-color|hatena-haiku.ui:haiku-set-hot-keyword-color CLOUD &REST COLOR>))
    �𗘗p���܂��B


=== COMMAND

���ƂłˁB


=== FUNCTION

--- hatena-haiku.ui:haiku-set-hot-keyword-color CLOUD &REST COLOR

    �z�b�g�L�[���[�h�̐F���z�b�g�x���Ƃɐݒ肵�܂��B
    �ȉ��Őݒ肵�����ꍇ��((<*haiku-hot-keyword-color-list*>)) �ɒ��ڐݒ肵�Ă��������B

        ;; ��ԃz�b�g�Șb��͗Δ��]�ɂ���
        (haiku-set-hot-keyword-color 7 :bold t :foreground 7 :background 10)

--- hatena-haiku.api:hatena-haiku-mode-version

    hatena-haiku-mode �̃o�[�W������Ԃ��܂��B


== TODO

* �͂����o�b�t�@���B���o�b�t�@�ɂ���ݒ�
* �V����
* �l�C��
* �q�X�g���ɑS���ۑ�
* login
* Reply �W�J
* reply link
* auto reload
* star
  * popup star comment
  * star comment view
* �񓯊�
  * �ʐM���� modeline �̕\��
* buffer-modified
  * F5 ����� modified
  * �ǂނ� not modified
* hook
  * �G���g���̃t�B���^hook
    * NG user, NG word
  * �e�o�b�t�@�� hook
* ���[�h�����̌�����
  * keyword-list, entry �ł̏����̓���
  * �J�[�\���ړ��n���ׂĂŃ��[�h
  * �񓯊�
  * �d���̔r��
* �G���g�����R�s�[, kill
* ���v���
  * �ǂ񂾃L�[���[�h��
  * ����
    * 1���ԑ��삪����������^�C�}��~
    * csv �o��
    * hatena graph
  * �쐬�����L�[���[�h
  * ���e�����L�[���[�h
* keyword-list �ꗗ API �ō��������擾
* ���e
  * id:�����̃y�[�W�Ƀ���
  * ����̃y�[�W�Ƀ���
  * �L�[���[�h�y�[�W�ȊO�ł͓��e���ɃJ�[�\�����̃G���g���̃^�C�g���������}��
  * �����I�ɋ�s�ɃX�y�[�X��������

* �����N�̃v���r���[
  * JaneStyle �݂�����
  * �摜�AYouTube
* �A�C�R���v���r���[
* �͂ĂȋL�@�����N
* ���G����
* ���ǔ���
  * qdbm? sexp?
* �V���ʒm
  * dialog
  * menu (livedoor-reader-notifier �̂悤��)
  * niconico
* offline mode
* ���C�ɓ���
  * �X���b�h�E����
  * ����
* �_�C�A�����J��
* �c�u���łȂ���n�C�N���[�h
  * �������[�h
* �}�E�X�N���b�N
* �t���\��(�����V����)
  * �y�[�W���̓L�[���[�h�ꗗ���番����
  * �_�C���N�g�ŕ\�����ꂽ�獢��
* �͂Ăȁ��y�[�W�ɂ���悤�ȁu��������̃T�C�g�ꗗ�v
* permalink
  * pin
  * tumblr
  * hatebu
  * plaggable �ɂ���


== KNOWN BUGS

* F5 �ōX�V������Ɏ��̃y�[�W�����[�h����ƃG���g�����d�����邩��


== AUTHOR

�݂�ނ� ���䂫 (((<URL:mailto:miyamuko@gmail.com>)))


== SEE ALSO

  : �͂Ăȃn�C�N
        ((<URL:http://h.hatena.ne.jp/>))


== COPYRIGHT

hatena-haiku-mode �� MIT/X ���C�Z���X�ɏ]���Ė{�\�t�g�E�F�A���g�p�A�Ĕz�z���邱�Ƃ��ł��܂��B

See hatena-haiku-mode/docs/MIT-LICENSE for full license.


== NEWS

<<<NEWS.rd
