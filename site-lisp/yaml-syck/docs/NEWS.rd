=begin

=== 2008-02-03 / 0.1.0

yaml-syck 0.1.0 �����[�X!

: �V�K�@�\

    * �Ȃ�

: ��݊����܂ޕύX�_

    * �Ȃ�

: �o�O�C��

    * �N���b�V�����ɂ�����������B


=== 2008-01-22 / 0.0.3

yaml-syck 0.0.3 �����[�X!

: �V�K�@�\

    * dll �̃A�����[�h���ł���悤�ɂ����B
      * (yaml-syck-ffi:syck-unload-dll): dll ���J��
      * (yaml-syck-ffi:syck-reload-dll): dll ���J�����čēǂݍ��݂���

: ��݊����܂ޕύX�_

    * �Ȃ�

: �o�O�C��

    * syck-load �Ɏw�肵�������񂩂� si:make-string-chunk �Ŋm�ۂ����������̈悪
      GC ����Ă��܂��N���b�V�����Ă����̂��C���B


=== 2007-04-22 / 0.0.2

yaml-syck 0.0.2 �����[�X!

: �V�K�@�\
    * syck-load-documents �� :from �I�v�V������ :filename �̑��� :file ���w��ł���悤�ɂ��܂����B
    * timestamp �̃t�H�[�}�b�g�� :iso8601 ��ǉ����܂����B
      iso8601 �`���̕�����ɕϊ����܂��B
    * �p�[�T�I�v�V������ :hash-table-test ��ǉ����܂����B

      �p�[�T�I�v�V���� :map �� :hash-table ���w�肵���Ƃ��ɕԂ�
      hash-table �̃e�X�g�֐����w��ł��܂��B

: ��݊����܂ޕύX�_
    * hash-table �̃e�X�g�֐��̃f�t�H���g�� equalp ���� equal �ɕύX���܂����B

      hash-table-test �� #'equalp ���w�肷�邱�Ƃŏ]���ʂ�̓���ɂȂ�܂��B

        (syck-load "{a: b}" :map :hash-table :hash-table-test #'equalp)

: �o�O�C��
    * xyzzy �_���v��� xyzzy �̃p�X���ς�����ꍇ�� dll �̃��[�h�����s����̂��C�����܂����B

      (USB �������ɓ���Ď����^�ԏꍇ�Ȃ�) �p�X���Œ肳��Ȃ����ł����Ȃ����p�ł��܂��B


=== 2007-03-25 / 0.0.1

yaml-syck 0.0.1 �����[�X!

=end
