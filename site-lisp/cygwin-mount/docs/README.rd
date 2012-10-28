= cygwin-mount - Cygwin �̃p�X���w�肵�ăt�@�C�����J��

  * Author: �݂�ނ� ���䂫 ((<URL:mailto:miyamuko@gmail.com>))
  * Home URL: ((<URL:http://miyamuko.s56.xrea.com/xyzzy/cygwin-mount/intro.htm>))
  * Version: 1.1.0


== DESCRIPTION

Cygwin �̃}�E���g�������߂��ăt�@�C������ϊ����܂��B
find-file ��R�}���h���C�������� cygwin �̃p�X���w�肵�� xyzzy �Ńt�@�C�����J�����Ƃ��ł��܂��B


== INSTALL

=== NetInstaller �ŃC���X�g�[��

(1) ((<NetInstaller|URL:http://www7a.biglobe.ne.jp/~hat/xyzzy/ni.html>))
    �� cygwin-mount ���C���X�g�[�����܂��B

(2) ((*ni-autoload �𗘗p���Ă��Ȃ��ꍇ*)) �́A
    ~/.xyzzy �܂��� $XYZZY/site-lisp/siteinit.l �Ɉȉ��̃R�[�h��ǉ����܂��B

        ;; cygwin-mount
        (require "cygwin-mount")
        (cygwin-mount-activate)

    �� ni-autoload �𗘗p���Ă���ꍇ�͐ݒ�͕s�v�ł��B

(3) �ݒ�𔽉f�����邽�� xyzzy ���ċN�����Ă��������B

    ��siteinit.l �ɋL�q�����ꍇ�ɂ͍ă_���v���K�v�ł��B


=== NetInstaller ���g�킸�ɃC���X�g�[��

(1) �A�[�J�C�u���_�E�����[�h���܂��B

    ((<URL:http://miyamuko.s56.xrea.com/xyzzy/archives/cygwin-mount.zip>))

(2) �A�[�J�C�u��W�J���āA$XYZZY/site-lisp �z���Ƀt�@�C�����R�s�[���܂��B

(3) ~/.xyzzy �܂��� $XYZZY/site-lisp/siteinit.l �Ɉȉ��̃R�[�h��ǉ����܂��B

        ;; cygwin-mount
        (require "cygwin-mount")
        (cygwin-mount-activate)

(4) �ݒ�𔽉f�����邽�� xyzzy ���ċN�����Ă��������B

    ��siteinit.l �ɋL�q�����ꍇ�ɂ͍ă_���v���K�v�ł��B


== MODULE

=== PACKAGE

cygwin-mount �͈ȉ��̃p�b�P�[�W�𗘗p���Ă��܂��B

  * editor
  * cygwin-mount
    * nickname �� cygmount

=== VARIABLE

--- cygwin-mount:*cygwin-mount-reg-section*

    cygwin �̃}�E���g��񂪋L�^����Ă��郌�W�X�g���̃L�[�����w�肵�܂��B
    �f�t�H���g�� SOFTWARE\Cygnus Solutions\Cygwin\mounts v2 �ł��B


=== COMMAND

--- editor:cygwin-mount-activate

    �t�@�C�����J���Ƃ��� cygwin �̃p�X�������I�� Windows �̃p�X�ɓǂݑւ���悤��
    �ݒ肵�܂��B

    ����� cygwin �̃p�X���w�肵�ăt�@�C�����J�����Ƃ��ł��܂��B

    (�ڂ�������: *before-find-file-hook* ��
    ed::cygwin-mount-before-find-file-hook ��ǉ����܂��B)

--- editor:cygwin-mount-deactivate

    �t�@�C�����J���Ƃ��� cygwin �̃p�X��ϊ����Ȃ��悤�ɂ��܂��B

--- editor:cygwin-mount-toggle

    cygwin �̃p�X�ϊ��̗L���E������؂�ւ��܂��B

--- editor:cygwin-mount-show-mount-point

    cygwin �̃}�E���g����\�����܂��B

=== FUNCTION

--- editor:cygwin-mount-active-p

    �t�@�C�����J���Ƃ��� cygwin �̃p�X��ϊ�����ꍇ non-nil ��Ԃ��܂��B

--- cygwin-mount:cygdrive-prefix

    cygdrive prefix ��Ԃ��܂��B

        (cygwin-mount:cygdrive-prefix)
        ;;=> "/cygdrive"

--- cygwin-mount:cygmount-cygpath->winpath CYGPATH

    Cygwin �̃p�X�� Windows �̃p�X�ɕϊ����܂��B

        (cygwin-mount:cygmount-cygpath->winpath "/bin/cygwin1.dll")
        ;;=> "c:\cygwin\bin\cygwin1.dll"

        (cygwin-mount:cygmount-cygpath->winpath "/cygdrive/c/Windows")
        ;;=> "c:\Windows"

--- cygwin-mount:cygmount-winpath->cygpath WINPATH

    Windows �̃p�X�� Cygwin �̃p�X�ɕϊ����܂��B

        (cygwin-mount:cygmount-winpath->cygpath "c:\\Windows")
        ;;=> "/cygdrive/c/Windows"

        (cygwin-mount:cygmount-winpath->cygpath "c:\\Cygwin\\bin")
        ;;=> "/usr/bin"

--- cygwin-mount:cygmount-point-info &KEY TYPE PATH

    Cygwin �̃}�E���g���̃��X�g���擾���܂��B

      (cygmount::cygmount-point-info :type :system)
      ;;=> (("/usr/lib" "C:\\cygwin\\lib" 10 :system)
      ;;    ("/usr/bin" "C:\\cygwin\\bin" 10 :system)
      ;;    ("/" "C:\\cygwin" 10 :system))

    ������ TYPE �ɂ� :system �� :user ���w�肵�܂��B

      * :system ���w�肷��� system wide �ȃ}�E���g�����擾���܂��B
      * :user ���w�肷��� user only �ȃ}�E���g�����擾���܂��B
      * �w�肵�Ȃ��ꍇ�͗����̃}�E���g����Ԃ��܂��B

    PATH ���w�肷��Ƃ��̃p�X�Ɋ֘A����}�E���g��񂾂���Ԃ��܂��B

      (cygmount::cygmount-point-info :type :system :path "/usr/bin")
      ;;=> (("/usr/bin" "C:\\cygwin\\bin" 10 :system)
      ;;    ("/" "C:\\cygwin" 10 :system))

--- cygwin-mount:cygmount-point-cygpath MOUNT-INFO

    ((<cygmount-point-info|cygwin-mount:cygmount-point-info &KEY TYPE PATH>))
    �Ŏ擾�����}�E���g��񂩂� Cygwin �̃p�X���擾���܂��B

--- cygwin-mount:cygmount-point-winpath MOUNT-INFO

    ((<cygmount-point-info|cygwin-mount:cygmount-point-info &KEY TYPE PATH>))
    �Ŏ擾�����}�E���g��񂩂� Windows �̃p�X���擾���܂��B

--- cygwin-mount:cygmount-point-flags MOUNT-INFO

    ((<cygmount-point-info|cygwin-mount:cygmount-point-info &KEY TYPE PATH>))
    �Ŏ擾�����}�E���g��񂩂�}�E���g�t���O���擾���܂��B

        (let ((mount-table (cygwin-mount:cygmount-point-info)))
          (cygwin-mount:cygmount-point-flags (car mount-table)))
        ;;=> (:binmode :notexec)

    �}�E���g�t���O�͈ȉ��̃L�[���[�h�̃��X�g�ŕԂ��܂��B

      * :textmode
      * :binmode
      * :exec
      * :cygexec
      * :notexec
      * :managed

    �t���O�̏ڍׂ� man mount ���Ă��������B

--- cygwin-mount:cygmount-point-type MOUNT-INFO

    ((<cygmount-point-info|cygwin-mount:cygmount-point-info &KEY TYPE PATH>))
    �Ŏ擾�����}�E���g��񂩂�}�E���g�^�C�v���擾���܂��B

        (let ((mount-table (cygwin-mount:cygmount-point-info)))
          (cygwin-mount:cygmount-point-flags (car mount-table)))
        ;;=> :system

    �}�E���g�^�C�v�� :system �܂��� :user ��Ԃ��܂��B

=== OBSOLETE FUNCTION

--- editor:cygwin-mount-resolve cygpath

    Cygwin �̃p�X�� Windows �̃p�X�ɕϊ����܂��B

    ����͌݊����̂��߂ɗp�ӂ���Ă��܂��B
    �����
    ((<cygmount-cygpath->winpath|cygwin-mount:cygmount-cygpath->winpath CYGPATH>))
    �𗘗p���Ă��������B


== TODO

* �Ȃ�


== KNOWN BUGS

* cygwin �̃p�X���w�肵�Ă��t�@�C���𐳂����J���Ȃ��ꍇ������܂��B

  �R�}���h���C������t�@�C�����w�肵�����Axyzzy �� *before-find-file-hook*
  �ɗ���܂łɏ���Ƀh���C�u�������ǉ�����܂��B
  ���̂��߁A�Ӑ}���Ȃ��t�@�C�����J���Ă��܂��\��������܂��B

  ���Ƃ��΁A�ȉ��̂悤�ȃf�B���N�g���\���̏ꍇ:

      D:/
       �� cygwin/
       �� �� etc/
       �� �� �� foo
       �� �� �� bar
       �� �� bin/
       �� �� sbin/
       �� etc
          �� foo

  cygwin �ł� /etc �� d:/cygwin/etc �Ƀ}�E���g���Ă���Ƃ��܂��B

  ������ cygwin ���� xyzzy /etc/foo �Ƃ��ċN�������ꍇ�A*before-find-file-hook*
  �ɂ� d:/etc/foo ���n����܂��B

  �{���� d:/cygwin/etc/foo ���J�������Ƃ���ł����A
  cygwin ���� /etc/foo ���w�肳�ꂽ�̂��AWindows ���� d:/etc/foo ��
  �w�肳�ꂽ���͔��f�ł��Ȃ��̂ŁA���̏ꍇ d:/etc/foo ���J����܂��B

  ����Acygwin ���� xyzzy /etc/bar �ŋN�������ꍇ d:/etc/bar ��
  �n����܂��B�������Ad:/etc/bar �͑��݂��Ȃ��̂ł��̏ꍇ�A
  cygwin-mount �ł̓h���C�u�������폜���� /etc/bar ���n���ꂽ�Ƃ݂Ȃ�
  cygwin �̃p�X�� Windows �̃p�X�ɕϊ����� d:/cygwin/etc/bar ���J���܂��B

  �ƁA���̂悤�ɓ��삪�������̂łȂ�ׂ� cygwin ���� cygpath ���g����
  �ϊ�������� xyzzy �ɓn�����ق����m�����Ǝv���܂��B


== AUTHOR

�݂�ނ� ���䂫 (((<URL:mailto:miyamuko@gmail.com>)))


== SEE ALSO

: cygwin-mount.el
    ((<URL:http://www.emacswiki.org/elisp/cygwin-mount.el>))

: cygwin-mount-mw32
    ((<URL:http://www4.kcn.ne.jp/~boochang/emacs/elisp.html>))


== COPYRIGHT

cygwin-mount �� MIT/X ���C�Z���X�ɏ]���Ė{�\�t�g�E�F�A���g�p�A�Ĕz�z���邱�Ƃ��ł��܂��B

See cygwin-mount/docs/MIT-LICENSE for full license.


== NEWS

<<<NEWS.rd
