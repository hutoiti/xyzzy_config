= rimo.tv.xyzzy - Rimo �� xyzzy ��ɕ\������B

  * Author: MIYAMUKO Katsuyuki ((<URL:mailto:miyamuko (at) gmail.com>))
  * URL: ((<URL:http://miyamuko.s56.xrea.com/xyzzy/rimo.tv.xyzzy.html>))
  * Version: 0.1.1


== SYNOPSIS

  M-x rimo.tv.on
  M-x rimo.tv.off

== DESCRIPTION

rimo.tv.xyzzy �� ((<Rimo|URL:http://rimo.tv/>)) �� xyzzy ��ɕ\�����邽�߂̃\�t�g�E�F�A�ł��B

rimo.tv.xyzzy ���g���΃E�B���h�E�̋��� Rimo ��\�������Ȃ��� xyzzy �� hack �ł��܂��B


== INSTALL

((<NetInstaller|URL:http://www7a.biglobe.ne.jp/~hat/xyzzy/ni.html>)) �ŃC���X�g�[�������ꍇ�� 3 �ȍ~���A
NetInstaller + ni-autoload ���g���Ă���l�� 4 �ȍ~�� OK �ł��B

(1) �A�[�J�C�u���_�E�����[�h���܂��B

    ((<URL:http://miyamuko.s56.xrea.com/xyzzy/archives/rimo.tv.xyzzy.zip>))

(2) �A�[�J�C�u��W�J���āA$XYZZY/site-lisp �z���Ƀt�@�C�����R�s�[���܂��B

(3) ~/.xyzzy �܂��� $XYZZY/site-lisp/siteinit.l �Ɉȉ��̃R�[�h��ǉ����܂��B

        ;; rimo.tv.xyzzy
        (require "rimo.tv.xyzzy")
        (use-package :rimo)

(4) �ݒ�𔽉f�����邽�� xyzzy ���ċN�����Ă��������B

    ��siteinit.l �ɋL�q�����ꍇ�ɂ͍ă_���v���K�v�ł��B

(5) M-x rimo.tv.on �� Rimo �̉�ʂ�\�����܂��B

    �I������ɂ� M-x rimo.tv.off �����s���Ă��������B


== MODULE

=== PACKAGE

rimo.tv.xyzzy �͈ȉ��̃p�b�P�[�W�𗘗p���Ă��܂��B

  * rimo
  * rimo-ffi

=== EXPORT

rimo.tv.xyzzy �͈ȉ��̃V���{���� export ���Ă��܂��B

  * rimo �p�b�P�[�W

    * ((<*rimo-width*>))
    * ((<*rimo-height*>))
    * ((<*rimo-position*>))
    * ((<rimo.tv.on>))
    * ((<rimo.tv.off>))
    * ((<rimo.tv.show>))
    * ((<rimo.tv.hide>))
    * ((<rimo.tv.move x y pos>))
    * ((<rimo.tv.window>))

  * rimo-ffi �p�b�P�[�W

    �����p�b�P�[�W�Ȃ̂ŏȗ��B

=== VARIABLE

--- *rimo-width*

    Rimo ��\������q�E�B���h�E�̕����s�N�Z���P�ʂŎw�肵�܂��B
    �f�t�H���g�� 400 (px) �ł��B

--- *rimo-height*

    Rimo ��\������q�E�B���h�E�̍������s�N�Z���P�ʂŎw�肵�܂��B
    �f�t�H���g�� 300 (px) �ł��B

--- *rimo-position*

    Rimo ��\������q�E�B���h�E�̈ʒu���v���p�e�B���X�g�Ŏw�肵�܂��B
    ��{�I�� css �Ɠ����悤�Ɏw�肵�܂��B

      '((:top    . <xyzzy �E�B���h�E�̏ォ��̈ʒu>)
        (:bottom . <xyzzy �E�B���h�E�̉�����̈ʒu>)
        (:left   . <xyzzy �E�B���h�E�̍�����̈ʒu>)
        (:right  . <xyzzy �E�B���h�E�̉E����̈ʒu>))

    * :top �� :bottom �͂ǂ��炩�Е����w�肵�܂��B
      �����w�肵���ꍇ�� :top ���D�悳��܂��B
    * :left �� :right �͂ǂ��炩�Е����w�肵�܂��B
      �����w�肵���ꍇ�� :left ���D�悳��܂��B

    �f�t�H���g�͈ȉ��̂Ƃ���ł� (����������ʉE���ɕ\������܂�)�B

      '((:right  . 20)
        (:bottom . 60))

    ��)

      ;; rimo ���E��ɕ\��
      (setf rimo:*rimo-position* '((:top . 40)    ;; �c�[���o�[�Ƃ���\�����Ă���̂Ȃ�����Ƒ��߂�
                                   (:right . 20)))


=== COMMAND

--- rimo.tv.on

    Rimo �̃E�B���h�E��\�����܂��B
    ���łɕ\�����Ă���ꍇ�͉������܂���B

--- rimo.tv.off

    Rimo �̃E�B���h�E����܂��B
    ���łɕ��Ă���ꍇ�͉������܂���B

--- rimo.tv.show

    ((<rimo.tv.hide>)) �Ŕ�\���ɂ��� Rimo �̃E�B���h�E��\�����܂��B

--- rimo.tv.hide

    Rimo ���ꎞ�I�ɔ�\���ɂ��܂��B
    ��\���ɂ��邾���ōĐ��͑������܂� (�������o�܂�)�B

    �ēx�\������ɂ� ((<rimo.tv.show>)) �����s���Ă��������B


=== FUNCTION

--- rimo.tv.move x y pos

    Rimo �̃E�B���h�E���ړ����܂��B
    x, y, pos �̎w����@�͂��ꂼ��
    ((<*rimo-width*>))�A
    ((<*rimo-height*>))�A
    ((<*rimo-position*>)) �Ɠ����ł��B

--- rimo.tv.window

    Rimo �E�B���h�E�̃E�B���h�E�n���h�����擾���܂��B
    �E�B���h�E�����݂��Ȃ��ꍇ�� 0 ��Ԃ��܂��B


== TODO

* Window �̔�������
* xyzzy �̃E�B���h�E�̈ʒu�E�T�C�Y���ς������Ǐ]����
* ���j���[
* ����{�^��
* �E�B���h�E���ړ��ł���悤��
* �`�����l����{�����[���̕ύX�� xyzzy ����ł���悤�ɂ���
  (Flash Player �� API ���@����̂Ȃ�B��������?)


== KNOWN BUGS

* ����������Ǝ��X xyzzy ���Ɨ����邩������܂���
  (auto-save-buffers �̂����p�𐄏����Ă����܂�)�B


== AUTHOR

�݂�ނ� ���䂫 (((<URL:mailto:miyamuko (at) gmail.com>)))


== SEE ALSO

  : Rimo
        ((<URL:http://rimo.tv/>))

== COPYRIGHT

rimo.tv.xyzzy �� MIT/X ���C�Z���X�Ɋ�Â��ė��p�\�ł��B

See rimo.tv.xyzzy/docs/MIT-LICENSE for full license.

