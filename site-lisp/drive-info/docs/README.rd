=begin

= drive-info - �_���h���C�u�̏����擾���郉�C�u����

  * Author: MIYAMUKO Katsuyuki ((<URL:mailto:miyamuko (at) gmail.com>))
  * Home: ((<URL:http://miyamuko.s56.xrea.com/xyzzy/drive-info/intro.htm>))
  * Version: 1.1.0


== SYNOPSIS

=== API

  (require "drive-info/api")
  (use-package :drive-info.api)

  (get-logical-drive-letters)  ;; => (#\C #\D)
  (get-fixed-logical-drives)   ;; => ("C:\\")
  (get-drive-type #\d)         ;; => :cdrom
  (drive-exist-p "d")          ;; => t

  ;; �S�Œ�f�B�X�N�� �u�h���C�u��  �{�����[����  �t�@�C���V�X�e��  �󂫗̈�%�v��\��
  (labels ((x (alist &rest path)
             (reduce #'(lambda (node path)
                         (or (cdr (assoc path node))
                             (return-from x)))
                     path
                     :initial-value alist)))
    (dolist (drive (get-fixed-logical-drives))
      (let ((info (get-drive-info drive)))
        (with-output-to-temp-buffer ("*drive list*")
          (format t "~A  ~10A  ~10A  ~1F%~%"
                  (x info :drive :name)
                  (x info :volume :volume-name)
                  (x info :volume :file-system-name)
                  (x info :space :free-bytes%))))))


=== UI

  * �h���C�u�̋󂫗e�ʂ��|�b�v�A�b�v�\��

      M-x drive-info-popup-disk-free-space-kuma--


== DESCRIPTION

drive-info �̓h���C�u�����擾���郉�C�u�����ł��B
get-disk-usage �ł͎擾�ł��Ȃ������擾�\�ł��B

�ȉ��̋@�\�����p�ł��܂��B

  * �h���C�u�̈ꗗ���擾
  * ���p���Ă��Ȃ��h���C�u�̈ꗗ���擾
  * �Œ�f�B�X�N�̃h���C�u�̈ꗗ���擾
  * �h���C�u�����݂��邩�ǂ�������
  * �h���C�u�̃^�C�v (CD-ROM? �t���b�s�[? �n�[�h�f�B�X�N? �Ȃ�) ���擾
  * �h���C�u�̋󂫗e�ʁE�g�p�e�ʂ��擾
  * �h���C�u�̏ڍׂȏ����擾

��{�I�ɂ̓��C�u�����ł����ȒP�ȃt�����g�G���h������܂��B

  * �h���C�u�̋󂫗e�ʂ��|�b�v�A�b�v�\���ł��܂��B


== INSTALL

((<NetInstaller|URL:http://www7a.biglobe.ne.jp/~hat/xyzzy/ni.html>)) �ŃC���X�g�[�������ꍇ�� 4 �ȍ~���A
NetInstaller + (({ni-autoload})) ���g���Ă���l�� 5 �ȍ~�� OK �ł��B

(1) �A�[�J�C�u���_�E�����[�h���܂��B

    ((<URL:http://miyamuko.s56.xrea.com/xyzzy/archives/drive-info.zip>))

(2) �A�[�J�C�u��W�J���āA$XYZZY/site-lisp �z���Ƀt�@�C�����R�s�[���܂��B

(3) ~/.xyzzy �܂��� $XYZZY/site-lisp/siteinit.l �Ɉȉ��̃R�[�h��ǉ����܂��B

        ;; drive-info
        (require "drive-info")

(4) �ݒ�𔽉f�����邽�� xyzzy ���ċN�����Ă��������B

    ��siteinit.l �ɋL�q�����ꍇ�ɂ͍ă_���v���K�v�ł��B

(5) M-x drive-info-popup-disk-free-space-kuma-- �ŋ󂫗e�ʂ�\���ł��܂��B

(6) ���C�u�����Ƃ��ė��p����ꍇ�� drive-info.api �p�b�P�[�W��
    use ���Ă����� package prefix ���ȗ��ł��܂��B

      (require "drive-info")
      (in-package :your-cool-application)
      (use-package :drive-info.api)


== MODULE

=== PACKAGE

drive-info �͈ȉ��̃p�b�P�[�W�𗘗p���Ă��܂��B

  * drive-info.api

    ���C�u�����̒�`�B�ʖ� (nickname) �� drive�B

  * drive-info.ffi

    �����p�B

  * editor

    �t�����g�G���h�̒�`�B

=== EXPORT

  * drive-info.api

    * ((< drive-info-version >))
    * ((< drive-info-api-version >))
    * ((< get-drive-info >))
    * ((< get-logical-drives >))
    * ((< get-logical-drive-letters >))
    * ((< get-fixed-logical-drives >))
    * ((< get-fixed-logical-drive-letters >))
    * ((< get-free-logical-drives >))
    * ((< get-free-logical-drive-letters >))
    * ((< drive-exist-p >))
    * ((< get-drive-type >))
    * ((< get-volume-information >))
    * ((< get-disk-free-space >))
    * ((< drive-name >))
    * ((< drive-letter >))

  * editor

    * ((< drive-info-popup-disk-free-space-kuma-- >))

  * drive-info-ffi

    �����p�Ȃ̂ŏȗ��B�B�B


=== VARIABLE

�Ȃ��B


=== COMMAND

==== editor �p�b�P�[�W

--- drive-info-popup-disk-free-space-kuma--

    �h���C�u�̋󂫗e�ʂ��|�b�v�A�b�v���ăO���t�\�����܂��B


=== FUNCTION

==== drive-info.api �p�b�P�[�W

�ȉ��̊֐��͂��ׂ� drive-info.api �p�b�P�[�W�Œ�`���Ă��܂��B

�T���v���R�[�h�͂��ׂ� drive-info.api �� use ���Ă����Ƃ�O���
package prefix ���ȗ����Ă��܂��B

root-dir �������ɂƂ�֐��̓h���C�u�� (������ or ����) ��p�X���Ȃǂ��w��ł��܂��B
�ȉ��̌Ăяo���͂��ׂėL���ł��B

  (drive-exist-p #\x)
  (drive-exist-p #\Y)
  (drive-exist-p "z")
  (drive-exist-p "z:")
  (drive-exist-p "Y:/foo/bar")


--- drive-info-version

    drive-info �̃o�[�W������Ԃ��܂��B
    �o�[�W������ major.minor.teeny �Ƃ����`���ł��B

    ���ꂼ��̔ԍ��͕K�� 1 ���ɂ���̂ŁA�ȉ��̂悤�ɔ�r���邱�Ƃ��ł��܂�
    (Ruby �Ɠ����ł� :-)�B

        (if (string<= "1.1.0" (drive-info-version))
            (1.1.0 �ȍ~�ŗL���ȏ���)
          (1.1.0 ���O�̃o�[�W�����ł̏���))

    drive-info.api �𗘗p����A�v���P�[�V�����������Ă��āA
    ���� API ����������Ă��邩�ǂ����̔��肵�����ꍇ��
    ((<URL:drive-info.api:drive-info-api-version>))
    �𗘗p���Ă��������B

--- drive-info-api-version

    call-seq:
      (layered-window-api-version) => 1

    drive-info API �̃o�[�W������Ԃ��܂��B
    �o�[�W�����͒P���Ȑ��l�ł��B

    drive-info.api �p�b�P�[�W�Œ�`���Ă��� API �ɒǉ��E�ύX���������ꍇ��
    �C���N�������g���܂��B

--- get-logical-drives

    call-seq:
        (get-logical-drives) => (drive namess...)

    ���݂���S�h���C�u���̃��X�g���擾���܂��B
    �h���C�u�����͑啶���ł��B

      (get-logical-drives) 
      ;; => ("C:\\" "D:\\")

--- get-logical-drive-letters

    call-seq:
        (get-logical-drive-letters) => (drive letters...)

    ���݂���S�h���C�u�̃h���C�u�����̃��X�g���擾���܂��B
    �h���C�u�����͑啶���ł��B

      (get-logical-drive-letters) 
      ;; => (#\C #\D)

--- get-free-logical-drives

    call-seq:
        (get-free-logical-drives) => (drive namess...)

    ���݂��Ȃ��S�h���C�u���̃��X�g���擾���܂��B
    �h���C�u�����͑啶���ł��B

      (get-free-logical-drives)  
      ;; => ("A:\\" "B:\\" ... "Z:\\")

--- get-free-logical-drive-letters

    call-seq:
        (get-free-logical-drive-letters) => (drive letters...)

    ���݂���S�h���C�u�̃h���C�u�����̃��X�g���擾���܂��B
    �h���C�u�����͑啶���ł��B

      (get-free-logical-drive-letters) 
      ;; => (#\A #\B ... #\Z)

--- get-fixed-logical-drives

    call-seq:
        (get-fixed-logical-drives) => (drive namess...)

    ���݂���Œ�f�B�X�N�̃h���C�u���̃��X�g���擾���܂��B

      (get-fixed-logical-drives) 
      ;; => ("C:\\")

--- get-fixed-logical-drive-letters

    call-seq:
        (get-fixed-logical-drive-letters) => (drive letters...)

    ���݂���Œ�f�B�X�N�̃h���C�u�����̃��X�g���擾���܂��B

      (get-fixed-logical-drive-letters) 
      ;; => (#\C)

--- drive-exist-p

    call-seq:
        (drive-exist-p root-dir) => t or nil

    �w�肵���h���C�u�����݂��邩�ǂ������肵�܂��B

    �����ɂ̓h���C�u�����f�B���N�g�������w�肵�܂��B
    nil ���w�肷��� (default-directory) �̃h���C�u�̏����擾���܂��B

--- get-drive-info

    call-seq:
        (get-drive-info root-dir) => (alist)

    drive-info �Ŏ擾�\�ȑS�����擾���܂��B

    �����ɂ̓h���C�u�����f�B���N�g�������w�肵�܂��B
    nil ���w�肷��� (default-directory) �̃h���C�u�̏����擾���܂��B

    �ȉ��̂悤�ȃ��X�g��Ԃ��܂��B

      ((:drive
        (:name . <�h���C�u���^�[>)
        (:type . <�h���C�u�^�C�v>))

       (:volume
        (:volume-name . <�{�����[����>)
        (:volume-serial-number . <�{�����[���̃V���A���ԍ�>)
        (:maximum-component-length . <�t�@�C�����̍ő�̒���>)
        (:file-system-flags
         ((:case-sensitive-search . <t or nil>)
          (:case-preserved-names . <t or nil>)
          (:unicode-on-disk . <t or nil>)
          (:persistent-acls . <t or nil>)
          (:file-compression . <t or nil>)
          (:volume-quotas . <t or nil>)
          (:supports-sparse-files . <t or nil>)
          (:supports-reparse-points . <t or nil>)
          (:supports-remote-storage . <t or nil>)
          (:volume-is-compressed . <t or nil>)
          (:supports-object-ids . <t or nil>)
          (:supports-encryption . <t or nil>)
          (:named-streams . <t or nil>)
          (:read-only-volume . <t or nil>)))
        (:file-system-name . <�t�@�C���V�X�e����>))
       (:space
        (:free-bytes-available . <�Ăяo���������p�ł���o�C�g��>)
        (:total-number-of-bytes . <�f�B�X�N�S�̂̃o�C�g��>)
        (:total-number-of-free-bytes . <�f�B�X�N�S�̂̋󂫃o�C�g��>)
        (:total-number-of-used-bytes . <�f�B�X�N�S�̂̎g�p�o�C�g��>)
        (:free-bytes% . <�f�B�X�N�S�̂̋󂫗e��%>)
        (:used-bytes% . <�f�B�X�N�S�̂̎g�p�e��%>)))

    * �h���C�u���^�[:  "C:\\", "D:\\" �ȂǕ�����ŕԂ��B
    * �h���C�u�^�C�v: :unknown, :no-root-dir, :removable, :fixed, :remote, :cdrom, :ramdisk �̂ǂꂩ�B
    * �{�����[����: "���[�J�� �f�B�X�N" �ȂǁB�}�C�R���s���[�^�Ō��閼�O�B
    * �t�@�C���V�X�e����: "NTFS" �ȂǁB

--- get-drive-type

    call-seq:
        (get-drive-type root-dir) => :keyword

    �h���C�u�^�C�v���擾���܂��B

    �����ɂ̓h���C�u�����f�B���N�g�������w�肵�܂��B
    nil ���w�肷��� (default-directory) �̃h���C�u�̏����擾���܂��B

      (get-drive-type "C:")
      ;; => :fixed

      (get-drive-type #\d)
      ;; => :cdrom

    �h���C�u�^�C�v�͈ȉ��̃L�[���[�h�̂����ꂩ��Ԃ��܂��B

      : :unknown
            �h���C�u�̎�ނ𔻕ʂł��܂���ł����B
      : :no-root-dir
             �w��̃��[�g�f�B���N�g�������݂��܂���B
             ���Ƃ��΁A�p�X�Ƀ{�����[�����}�E���g����Ă��܂���
             �i���t�H�[�}�b�g��A���f�B�A���}������Ă��Ȃ��Ȃǁj�B
      : :removable
             ���̃f�B�X�N�́A�h���C�u������o���܂��B
      : :fixed
             ���̃f�B�X�N�́A�h���C�u������o���܂���B
      : :remote
             ���̃h���C�u�́A�����[�g�i�l�b�g���[�N�j�h���C�u�ł��B
      : :cdrom
             ���̃h���C�u�́ACD-ROM �h���C�u�ł��B
      : :ramdisk
             ���̃h���C�u�́ARAM �f�B�X�N�ł��B

--- get-volume-information

    call-seq:
        (get-volume-information root-dir) => (alist)

    �t�@�C���V�X�e���ƃ{�����[���Ɋւ�������擾���܂��B

    �����ɂ̓h���C�u�����f�B���N�g�������w�肵�܂��B
    nil ���w�肷��� (default-directory) �̃h���C�u�̏����擾���܂��B

    �ȉ��̂悤�ȃ��X�g��Ԃ��܂��B

      ((:volume-name . <�{�����[����>)
       (:volume-serial-number . <�{�����[���̃V���A���ԍ�>)
       (:maximum-component-length . <�t�@�C�����̍ő�̒���>)
       (:file-system-flags
        ((:case-sensitive-search . <t or nil>)
         (:case-preserved-names . <t or nil>)
         (:unicode-on-disk . <t or nil>)
         (:persistent-acls . <t or nil>)
         (:file-compression . <t or nil>)
         (:volume-quotas . <t or nil>)
         (:supports-sparse-files . <t or nil>)
         (:supports-reparse-points . <t or nil>)
         (:supports-remote-storage . <t or nil>)
         (:volume-is-compressed . <t or nil>)
         (:supports-object-ids . <t or nil>)
         (:supports-encryption . <t or nil>)
         (:named-streams . <t or nil>)
         (:read-only-volume . <t or nil>)))
       (:file-system-name . <�t�@�C���V�X�e����>))

    �t�@�C���V�X�e���I�v�V�����̈Ӗ��͈ȉ��̂Ƃ���ł��B

      : :case-sensitive-search
          �t�@�C�����̑啶���Ə������̋�ʂ��T�|�[�g���Ă��܂��B

      : :case-preserved-names
          �f�B�X�N�Ƀt�@�C�������L�^����Ƃ��ɁA�啶���Ə���������ʂ��ĕۑ����܂��B

      : :unicode-on-disk
          Unicode �̃t�@�C�������T�|�[�g���Ă��āA�f�B�X�N��ł��������\������܂��B

      : :persistent-acls
          ACL�i�A�N�Z�X���䃊�X�g�j�̕ۑ��ƓK�p���s���܂��B
          ���Ƃ��΁ANTFS �� ACL �̕ۑ��ƓK�p���s���܂����AFAT �� ACL ���T�|�[�g���Ă��܂���B

      : :file-compression
          �t�@�C���x�[�X�̈��k���T�|�[�g���Ă��܂��B

      : :volume-quotas
          �f�B�X�N�N�H�[�^�i�f�B�X�N�g�p�ʂ̊��蓖�ċ@�\�j���T�|�[�g���Ă��܂��B

      : :supports-sparse-files
          �X�p�[�X�t�@�C���i�a�ȃt�@�C���A���g�p�̗̈悪�����A�܂��͓����l�����������t�@�C���j
          ���T�|�[�g���Ă��܂��B

      : :supports-reparse-points
          �ĉ�̓|�C���g���T�|�[�g���Ă��܂��B

      : :supports-remote-storage
          �����[�g�X�g���[�W���T�|�[�g���Ă��܂��B

      : :volume-is-compressed
          �w�肳�ꂽ�{�����[���́A���k�{�����[���i���Ƃ��΁ADoubleSpace �̃{�����[���j�ł��B

      : :supports-object-ids
          �I�u�W�F�N�g���ʎq���T�|�[�g���Ă��܂��B

      : :supports-encryption
          �Í����t�@�C���V�X�e���iEFS�j���T�|�[�g���Ă��܂��B

      : :named-streams
          ���O�t���X�g���[�����T�|�[�g���Ă��܂��B

      : :read-only-volume
          �������ݕs�ł��B

--- get-disk-free-space

    call-seq:
        (get-disk-free-space root-dir) => (alist)

    �{�����[���̗e�ʂɊւ�������擾���܂��B

    �����ɂ̓h���C�u�����f�B���N�g�������w�肵�܂��B
    nil ���w�肷��� (default-directory) �̃h���C�u�̏����擾���܂��B

    �ȉ��̂悤�ȃ��X�g��Ԃ��܂��B

      ((:free-bytes-available . <�Ăяo���������p�ł���o�C�g��>)
       (:total-number-of-bytes . <�f�B�X�N�S�̂̃o�C�g��>)
       (:total-number-of-free-bytes . <�f�B�X�N�S�̂̋󂫃o�C�g��>)
       (:total-number-of-used-bytes . <�f�B�X�N�S�̂̎g�p�o�C�g��>)
       (:free-bytes% . <�f�B�X�N�S�̂̋󂫗e��%>)
       (:used-bytes% . <�f�B�X�N�S�̂̎g�p�e��%>))

--- drive-name

    call-seq:
        (drive-name root-dir) => drive name

    �w�肳�ꂽ�f�B���N�g���̃h���C�u�����擾���܂��B

      (drive-name "c:\\hoge")
      ;; => "C:\\"

      (drive-name #\C)
      ;; => "C:\\"

    �����ɂ̓h���C�u�����f�B���N�g�������w�肵�܂��B
    nil ���w�肷��� nil ��Ԃ��܂��B

    �ȉ��̓_�� pathname-device �Ƃ͈Ⴂ�܂��B

      * nil ���w�肷��� nil ��Ԃ��܂��B
        (pathname-device �̓G���[)�B
      * �A���t�@�x�b�g�ꕶ����n���ƃh���C�u���^�[�Ƃ��ĉ��߂��܂�
        (pathname-device �̓f�B���N�g�����Ƃ��ĉ��߂� default-directory �̃h���C�u����Ԃ�)�B
      * #\C �ȂǕ������w��\�ł��B
      * �h���C�u���^�[�͏�ɑ啶���B
      * ":\\" ���t���Ă���B

    ���̊֐��̓h���C�u�̑��݃`�F�b�N�͂��܂���B

--- drive-letter

    call-seq:
        (drive-letter root-dir) => drive letter

    �w�肳�ꂽ�f�B���N�g���̃h���C�u���^�[���擾���܂��B
    �K���啶���ŕԂ��܂��B

      (drive-letter "c:\\hoge")
      ;; => #\C

      (drive-letter #\c)
      ;; => #\C

    �����ɂ̓h���C�u�����f�B���N�g�������w�肵�܂��B
    nil ���w�肷��� nil ��Ԃ��܂��B

    ���̊֐��̓h���C�u�̑��݃`�F�b�N�͂��܂���B


=== EXPORT

==== editor

editor �p�b�P�[�W����͈ȉ��̃R�}���h�� export ���Ă��܂��B

* drive-info-popup-disk-free-space-kuma--

==== drive-info.api

drive-info.api �p�b�P�[�W����͈ȉ��̊֐��� export ���Ă��܂��B

* get-drive-info
* get-logical-drives
* get-drive-type
* get-volume-information
* get-disk-free-space
* drive-exist-p

* volume-name
* volume-serial-number
* maximum-component-length
* file-system-flags
* file-system-name

* free-bytes-available
* total-number-of-bytes
* total-number-of-free-bytes
* total-number-of-used-bytes
* free-bytes%
* used-bytes%


== TODO

* �����f�B�X�N�����擾
  * DeviceIoControl
  * Win32_DiskDrive


== KNOWN BUGS

�Ȃ��B


== AUTHORS

�݂�ނ� ���䂫 (((<URL:mailto:miyamuko (at) gmail.com>)))


== SEE ALSO

  : GetLogicalDrives
        ((<URL:http://msdn.microsoft.com/library/ja/jpfileio/html/_win32_getlogicaldrives.asp>))
  : GetDriveType
        ((<URL:http://msdn.microsoft.com/library/ja/jpfileio/html/_win32_getdrivetype.asp>))
  : GetVolumeInformation
        ((<URL:http://msdn.microsoft.com/library/ja/jpfileio/html/_win32_getvolumeinformation.asp>))
  : GetDiskFreespaceEx
        ((<URL:http://msdn.microsoft.com/library/ja/jpfileio/html/_win32_getdiskfreespaceex.asp>))
  
  : �u���̂`�`�ǂ��X���v�e���v���⏕�T�C�g
        ((<URL:http://dokoaa.com/kuma.html>))
  : AsciiArtHeadline ���� AA ���ڂ�� DB
        ((<URL:http://tecstar.ddo.jp/aa_video/aadb/select.cgi?page=10&rowcount=5&baa=1&word=%92%DE%82%E8>))


== COPYRIGHT

drive-info �� MIT/X ���C�Z���X�ɂ��������ė��p�\�ł��B

See drive-info/docs/MIT-LICENSE for full license.


== NEWS

<<<NEWS.rd

=end
