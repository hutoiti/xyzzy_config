=begin

= guidgen - GUID �𐶐����郉�C�u�����ƃc�[��

  * Author: �݂�ނ� ���䂫 ((<URL:mailto:miyamuko@gmail.com>))
  * Home URL: ((<URL:http://miyamuko.s56.xrea.com/xyzzy/guidgen/intro.htm>))
  * Version: 1.1.0


== SYNOPSIS

  * ���C�u����

      (require "guidgen")

      (let ((guid (guidgen:guidgen)))
        (msgbox "GUID: ~A" guid))

      (let ((guid (guidgen:guidgen :downcase t)))
        (msgbox "GUID: ~A" guid))

      (use-package :guidgen)
      (multiple-value-bind (guid-str guid-list)
          (guidgen :downcase t)
        (msgbox "GUID: ~A (~{#x~x ~})" guid-str guid-list))

  * �t�����g�G���h

      M-x guidgen-copy-to-clipboard
      M-x guidgen-copy-to-kill-ring

      M-x guidgen-toggle-use-last-guid

      M-x guidgen-insert
      M-x guidgen-replace
      M-x guidgen-replace-or-insert

      M-x guidgen-replace-all-buffer
      M-x guidgen-replace-buffer
      M-x guidgen-replace-region
      M-x guidgen-replace-selection

      M-x guidgen-replace-history-clear
      M-x guidgen-replace-history-show

      M-x guidgen-insert-implement-olecreate
      M-x guidgen-insert-define-guid
      M-x guidgen-insert-static-const-guid
      M-x guidgen-insert-registry
      M-x guidgen-insert-urn

      M-x guidgen-track-popup-menu
      M-x guidgen-setup-app-menu
      M-x guidgen-setup-app-popup-menu
      M-x guidgen-remove-app-menu
      M-x guidgen-remove-app-popup-menu


== DESCRIPTION

guidgen �� GUID �𐶐����邽�߂̃c�[���ł��B
Microsoft �� guidgen.exe �Ɠ����A���S���Y�� (�Ƃ����� CoCreateGuid) �� GUID �𐶐����܂��B

guidgen �͈ȉ��̌`���� GUID �𐶐����邱�Ƃ��ł��܂��B

  * IMPLEMENT_OLECREATE �}�N��
  * DEFINE_GUID �}�N��
  * static const GUID
  * ���W�X�g���`�� ({xxxxxxxx-...})
  * urn �`�� (urn:uuid:xxxxxxxx-...)
  * ���ϊ� (xxxxxxxx-...)

�܂��A�O�u�����ɑΉ����Ă���̂� GUID ���ʂɐ������邱�Ƃ��\�ł��B

    C-u M-x guidgen-insert
    C-u M-x guidgen-insert-implement-olecreate
    C-u M-x guidgen-insert-define-guid
    C-u M-x guidgen-insert-static-const-guid
    C-u M-x guidgen-insert-registry
    C-u M-x guidgen-insert-urn


== INSTALL

((<NetInstaller|URL:http://www7a.biglobe.ne.jp/~hat/xyzzy/ni.html>)) �ŃC���X�g�[�������ꍇ�� 3 �ȍ~���A
NetInstaller + ni-autoload ���g���Ă���l�� 4 �ȍ~�� OK �ł��B

(1) �A�[�J�C�u���_�E�����[�h���܂��B

    ((<URL:http://miyamuko.s56.xrea.com/xyzzy/archives/guidgen.zip>))

(2) �A�[�J�C�u��W�J���āA$XYZZY/site-lisp �z���Ƀt�@�C�����R�s�[���܂��B

(3) ~/.xyzzy �܂��� $XYZZY/site-lisp/siteinit.l �Ɉȉ��̃R�[�h��ǉ����܂��B

        ;; guidgen
        (require "guidgen")

(4) �ݒ�𔽉f�����邽�� xyzzy ���ċN�����Ă��������B

    ��siteinit.l �ɋL�q�����ꍇ�ɂ͍ă_���v���K�v�ł��B

(5) ni-autoload ���g���Ă���ꍇ�A�o�b�t�@�̉E�N���b�N���j���[�ɁuGUID�����v���ǉ�����܂��B

    ni-autoload ���g���Ă��Ȃ��ꍇ�́A�ȉ��̃R�[�h�� .xyzzy �� siteinit.l �ɒǉ����邱�Ƃ������߂��܂��B

      ;; �u�c�[���v���j���[�ɁuGUID�����v�Ƃ������j���[��ǉ����܂��B
      (guidgen-setup-app-menu)

      ;; �E�N���b�N���j���[�ɁuGUID�����v�Ƃ������j���[��ǉ����܂��B
      (guidgen-setup-app-popup-menu)


== MODULE

=== PACKAGE

guidgen �͈ȉ��̃p�b�P�[�W�𗘗p���Ă��܂��B

  * guidgen
  * guidgen-ffi
  * editor

=== EXPORT

guidgen �͈ȉ��̃V���{���� export ���Ă��܂��B

  * guidgen �p�b�P�[�W

    * *guidgen-version*
    * guidgen

  * guidgen-ffi

    �����p�Ȃ̂ŏȗ��B

  * editor �p�b�P�[�W

    * guidgen-copy-to-clipboard
    * guidgen-copy-to-kill-ring
    * guidgen-toggle-use-last-guid
    * guidgen-use-last-guid-p
    * guidgen-insert
    * guidgen-insert-define-guid
    * guidgen-insert-implement-olecreate
    * guidgen-insert-registry
    * guidgen-insert-static-const-guid
    * guidgen-insert-urn
    * guidgen-remove-app-menu
    * guidgen-remove-app-popup-menu
    * guidgen-replace
    * guidgen-replace-or-insert
    * guidgen-replace-all-buffer
    * guidgen-replace-buffer
    * guidgen-replace-region
    * guidgen-replace-selection
    * guidgen-replace-history-clear
    * guidgen-replace-history-show
    * guidgen-setup-app-menu
    * guidgen-setup-app-popup-menu
    * guidgen-track-popup-menu


=== VARIABLE

--- *guidgen-version*

    �{���C�u�����̃o�[�W������ێ�����萔�ł��B
    �o�[�W������ major.minor.teeny �Ƃ����`���ł��B
    ���ꂼ��̔ԍ��͕K�� 1 ���ɂ���̂ŁA�ȉ��̂悤�ɔ�r���邱�Ƃ��ł��܂�
    (Ruby �Ɠ����ł� :-)�B

        (if (string<= "1.1.0" guidgen:*guidgen-version*)
            (1.1.0 �ȍ~�ŗL���ȏ���)
          (1.1.0 ���O�̃o�[�W�����ł̏���))


=== COMMAND

--- guidgen-copy-to-clipboard

    GUID �𐶐����ăN���b�v�{�[�h�ɃR�s�[���܂��B

    �`���͖��ϊ� (xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx) �ł��B

--- guidgen-copy-to-kill-ring

    GUID �𐶐����� kill ring �ɃR�s�[���܂��B

    �`���͖��ϊ� (xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx) �ł��B

--- guidgen-toggle-use-last-guid

    ���O�� GUID ���J��Ԃ����ǂ�����؂�ւ��܂��B

--- guidgen-use-last-guid-p

    ���O�� GUID ���J��Ԃ��ꍇ non-nil ��Ԃ��܂��B

--- guidgen-insert

    GUID �𐶐����ăJ�[�\�����ɑ}�����܂��B

    �`���͖��ϊ� (xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx) �ł��B

--- guidgen-replace

    �J�[�\������ GUID ��u�����܂��B

    �J�[�\������ GUID ���ۂ������񂪖����ꍇ�͉������܂���B

--- guidgen-replace-or-insert

    �J�[�\������ GUID ��u�����܂��B

    �J�[�\������ GUID ���ۂ������񂪖����ꍇ�͐V���ɑ}�����܂��B

    �O�u�����ɑΉ����Ă��܂��B

--- guidgen-replace-region

    ���[�W�������� GUID �������u�����܂��B

    �ȉ��̃p�^�[���Ƀ}�b�`����������� GUID �Ƃ݂Ȃ��܂� (X �� 16 �i��)�B

      XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX

    �Ȃ��A���� GUID �͓����l�ɒu������܂��B

    ��:
      ;; �u���O
      28EBC579-69EE-4A96-79C5-EB28EE69964A
      2EB4C86B-1854-4C82-6BC8-B42E5418824C
      BE7359FB-62F4-4880-FB59-73BEF4628048
      BE7359FB-62F4-4880-FB59-73BEF4628048

      ;; �u����
      32DF4C88-46E0-412B-884C-DF32E0462B41
      7A210592-E915-48EB-9205-217A15E9EB48
      71CF1453-6FD2-4009-5314-CF71D26F0940
      71CF1453-6FD2-4009-5314-CF71D26F0940

    ������

    �ȉ��̂悤�� XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX �ȊO�̌`���� GUID �ɂ͑Ή����Ă��܂���B

      DEFINE_GUID(<<name>>,
      0x045e9d7a, 0x2947, 0x475d, 0x7a, 0x9d, 0x5e, 0x04, 0x47, 0x29, 0x5d, 0x47);

--- guidgen-replace-selection

    �Z���N�V�������� GUID �������u�����܂��B

    �ڍׂ� ((<guidgen-replace-region>)) ���Q�Ƃ��Ă��������B

--- guidgen-replace-buffer

    �o�b�t�@���� GUID �������u�����܂��B

    �ڍׂ� ((<guidgen-replace-region>)) ���Q�Ƃ��Ă��������B

--- guidgen-replace-all-buffer

    �S�o�b�t�@���� GUID �������u�����܂��B

    �ڍׂ� ((<guidgen-replace-region>)) ���Q�Ƃ��Ă��������B

--- guidgen-replace-history-clear

    GUID �̒u���������N���A���܂��B

--- guidgen-replace-history-show

    GUID �̒u���������Q�Ƃ��܂��B

    �o�͗�:
      28EBC579-69EE-4A96-79C5-EB28EE69964A => 32DF4C88-46E0-412B-884C-DF32E0462B41
      2EB4C86B-1854-4C82-6BC8-B42E5418824C => 7A210592-E915-48EB-9205-217A15E9EB48
      BE7359FB-62F4-4880-FB59-73BEF4628048 => 71CF1453-6FD2-4009-5314-CF71D26F0940

--- guidgen-insert-implement-olecreate

    IMPLEMENT_OLECREATE �}�N���`���ŃJ�[�\������ GUID ��}�����܂��B

    ex)
        // {82E6BCA9-3AA9-478F-A9BC-E682A93A8F47}
        IMPLEMENT_OLECREATE(<<class>>, <<external_name>>,
        0x82e6bca9, 0x3aa9, 0x478f, 0xa9, 0xbc, 0xe6, 0x82, 0xa9, 0x3a, 0x8f, 0x47);

    �O�u�����ɑΉ����Ă��܂��B

--- guidgen-insert-define-guid

    DEFINE_GUID �}�N���`���ŃJ�[�\������ GUID ��}�����܂��B

    ex)
        // {045E9D7A-2947-475D-7A9D-5E0447295D47}
        DEFINE_GUID(<<name>>,
        0x045e9d7a, 0x2947, 0x475d, 0x7a, 0x9d, 0x5e, 0x04, 0x47, 0x29, 0x5d, 0x47);

    �O�u�����ɑΉ����Ă��܂��B

--- guidgen-insert-static-const-guid

    GUID �\���̌`���ŃJ�[�\������ GUID ��}�����܂��B

    ex)
        // {6EAC24CD-4E4F-4420-CD24-AC6E4F4E2044}
        static const GUID <<name>> = {
            0x6eac24cd, 0x4e4f, 0x4420, { 0xcd, 0x24, 0xac, 0x6e, 0x4f, 0x4e, 0x20, 0x44 }
        };

    �O�u�����ɑΉ����Ă��܂��B

--- guidgen-insert-registry

    ���W�X�g���`���ŃJ�[�\������ GUID ��}�����܂��B

    ex)
        {AEB3A288-457B-47DA-88A2-B3AE7B45DA47}

    �O�u�����ɑΉ����Ă��܂��B

--- guidgen-insert-urn

    urn �`���ŃJ�[�\������ GUID ��}�����܂��B

    ex)
        urn:uuid:CA02D532-7FDC-4111-32D5-02CADC7F1141

    �O�u�����ɑΉ����Ă��܂��B

--- guidgen-track-popup-menu

    GUID �𐶐����邽�߂̃��j���[���|�b�v�A�b�v���ĕ\�����܂��B

--- guidgen-setup-app-menu

    �u�c�[���v���j���[�ɁuGUID�����v�Ƃ������j���[��ǉ����܂��B

--- guidgen-setup-app-popup-menu

    �E�N���b�N���j���[�ɁuGUID�����v�Ƃ������j���[��ǉ����܂��B

--- guidgen-remove-app-menu

    �u�c�[���v���j���[����uGUID�����v���j���[���폜���܂��B

--- guidgen-remove-app-popup-menu

    �E�N���b�N���j���[����uGUID�����v���j���[���폜���܂��B


=== FUNCTION

--- guidgen:guidgen &key downcase

    GUID �𐶐����܂��B
    �������� GUID �𑽒l�ŕԂ��܂��B
    (1) GUID �̕�����\��
    (2) GUID �̊e�t�B�[���h�𐔒l�ɂ��� list

    ex)
        (guidgen:guidgen)
        "14DF2874-0B1E-4E62-7428-DF141E0B624E"
        (350169204 2846 20066 116 40 223 20 30 11 98 78)

    downcase �� non-nil ���w�肷��Ə������� 16 �i���� GUID �𐶐����܂��B

        (car (multiple-value-list (guidgen:guidgen :downcase t)))
        "c26ff9d9-aac2-4c2b-d9f9-6fc2c2aa2b4c"


== EXPERIMENTAL FEATURE

guidgen �̃��C�u���������� clisp �Ɏ����I�ɑΉ����Ă��܂��B

    xyzzy/site-lisp> clisp --silent -i guidgen\guidgen.l
    ;; Loading file guidgen\guidgen.l ...
    ;;  Loading file guidgen\package.l ...
    ;;  Loaded file guidgen\package.l
    ;;  Loading file guidgen\guidgen-ffi.l ...
    ;;  Loaded file guidgen\guidgen-ffi.l
    ;; Loaded file guidgen\guidgen.l
    [1]> (guidgen:guidgen)
    "7D518485-5F3E-4CCC-A05B-359F07179636" ;
    (2102494341 24382 19660 160 91 53 159 7 23 150 54)
    [2]> (use-package :guidgen)
    T
    [3]> (car (multiple-value-list (guidgen :downcase t)))
    "048085b7-6ecd-4849-9585-2a6f23af95ac"
    [4]> *guidgen-version*
    "1.0.0"
    [5]> (lisp-implementation-version)
    "2.38 (2006-01-24) (built on stnt067 [192.168.0.1])"
    [6]>

== TODO

�Ȃ��B


== KNOWN BUGS

�Ȃ��B


== AUTHOR

�݂�ނ� ���䂫 (((<URL:mailto:miyamuko (at) gmail.com>)))


== SEE ALSO

  : Microsoft Exchange Server GUID Generator
        ((<URL:http://www.microsoft.com/downloads/details.aspx?FamilyId=94551F58-484F-4A8C-BB39-ADB270833AFC>))

  : UUID
        ((<URL:http://msdn.microsoft.com/library/default.asp?url=/library/en-us/rpc/rpc/uuid_1.asp>))

  : CoCreateGuid
        ((<URL:http://msdn.microsoft.com/library/default.asp?url=/library/en-us/com/html/8d5cedea-8c2b-4918-99db-1a000989f178.asp>))


== COPYRIGHT

guidgen �� MIT/X ���C�Z���X�Ɋ�Â��ė��p�\�ł��B

See guidgen/docs/MIT-LICENSE for full license.


== NEWS

<<<NEWS.rd

=end
