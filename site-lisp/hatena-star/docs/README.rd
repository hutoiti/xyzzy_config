= hatena-star - �͂ĂȃX�^�[ API

  * Author: �݂�ނ� ���䂫 ((<URL:mailto:miyamuko@gmail.com>))
  * Home URL: ((<URL:http://miyamuko.s56.xrea.com/xyzzy/hatena-star/intro.htm>))
  * Version: 1.1.1


== SYNOPSIS

  (in-package :your-awesome-app)

  (require "hatena-star/api")
  (use-package :hatena-star.api)

  ;; RKS (���O�C���Z�b�V�������ƂɌŗL�� ID, add/delete �ŕK�v)
  (defvar *rks* nil)

  ;; �͂ĂȃX�^�[�J�E���g API
  (let ((blog (hatena-star-get-blog "http://d.hatena.ne.jp/hatenastar/")))
    ...)

  ;; �G���g���� RKS �̎擾
  (multiple-value-bind (entries rks)
      (hatena-star-get-entries '("http://d.hatena.ne.jp/hatenastar/20071129/1196290565"
                                 "http://d.hatena.ne.jp/hatenastar/20071124/1195896789"
                                 "http://d.hatena.ne.jp/hatenastar/20071115/1195092449"))
    (setf *rks* rks)
    (your-cool-show-hatena-star-entry
     (mapcar #'(lambda (entry)
                 ;; ���������ďȗ�����Ă�����Ď擾
                 (if (hatena-star-stars-all-p entry)
                     entry
                   (hatena-star-get-entry (hatena-star-entry-uri entry))))
             entries)))

  ;; �R�����g�̒ǉ�
  (when (hatena-star-entry-can-comment-p entry)
    (hatena-star-add-comment (hatena-star-entry-uri entry)
                             *rks*
                             :title title
                             :body (read-string "�R�����g: ")))

  ;; �I�𕶎�������p���ā��̒ǉ�
  (let ((title "�ق��ق�")
        (quote (selection-start-end (s e) (buffer-substring s e))))
    (let ((r (hatena-star-add-star (hatena-star-entry-uri entry)
                                   *rks* :title title :quote quote)))
      (cond ((null r)
             (values nil nil))  ; ���ǉ����s
            ((string= quote (hatena-star-star-quote r))
             (values t t))      ; ���ǉ� + ���p����
            (t
             (values t nil))))) ; ���ǉ����� + ���p���s

  ;; ���̍폜 (�w�肳�ꂽ entry �� star ���폜)
  (when (hatena-star-deletable-p (hatena-star-star-name star))
    (hatena-star-delete-star (hatena-star-entry-uri entry)
                             *rks*
                             :name (hatena-star-star-name star)
                             :quote (hatena-star-star-quote star)))


== DESCRIPTION

hatena-star �� ((<"�͂ĂȃX�^�["|URL:http://s.hatena.ne.jp/>)) API ��
xyzzy ������s���邽�߂̃��C�u�����ł��B

�ȉ��̂��Ƃ��ł��܂��B

  * �X�^�[�̎擾
  * �X�^�[�̒ǉ��E�폜
  * �R�����g�̒ǉ�
  * �͂ĂȃX�^�[�J�E���g

xml-http-request ���g���Ă���̂Ŕ񓯊��ɂ͂ĂȃX�^�[ API �����s�ł��܂��B


== INSTALL

=== NetInstaller �ŃC���X�g�[��

(1) ((<NetInstaller|URL:http://www7a.biglobe.ne.jp/~hat/xyzzy/ni.html>))
    �� hatena-star ���C���X�g�[�����܂��B

=== NetInstaller ���g�킸�ɃC���X�g�[��

(1) �A�[�J�C�u���_�E�����[�h���܂��B

    ((<URL:http://miyamuko.s56.xrea.com/xyzzy/archives/hatena-star.zip>))

(2) �A�[�J�C�u��W�J���āA$XYZZY/site-lisp �z���Ƀt�@�C�����R�s�[���܂��B


== MODULE

=== DEPENDS

hatena-star �͈ȉ��̃��W���[���Ɉˑ����Ă��܂��B�ʓr�C���X�g�[�����Ă��������B

  * ((<"xml-http-request"|URL:http://miyamuko.s56.xrea.com/xyzzy/xml-http-request/intro.htm>))
    1.1.1 �ȏ�
  * ((<"json"|URL:http://miyamuko.s56.xrea.com/xyzzy/json/intro.htm>))
    0.1.1 �ȏ�


=== PACKAGE

hatena-star �͈ȉ��̃p�b�P�[�W�𗘗p���Ă��܂��B

  * hatena-star.api

    nickname �͂���܂���B

=== VARIABLE

--- hatena-star.api:*hatena-star-base-uri*

    �͂ĂȃX�^�[�̃x�[�X URI ���w�肵�܂��B
    ��{�I�ɂ͕ύX�̕K�v�͂���܂���B

--- hatena-star.ui:*hatena-star-default-star-char*

    ((<hatena-star-make-stars-string|hatena-star.ui:hatena-star-make-stars-string COUNT &KEY STAR-CHAR INNER INNER-MIN>))
    �Ȃǂ̊֐��� STAR-CHAR ���ȗ������ꍇ�ɗ��p���� charcter �ł��B

    �f�t�H���g�� #\�� �ł��B

--- hatena-star.ui:*hatena-star-default-star-color*

    ((<hatena-star-stars-insert|hatena-star.ui:hatena-star-stars-insert ENTRY-OR-STARS &KEY TAG STAR-CHAR COLOR>))
    �Ł���`�悷��Ƃ��̐F�ł��B

    �f�t�H���g�� (:foreground 11) �ł��B

--- hatena-star.ui:*hatena-star-inner-count-min*

    ((<hatena-star-stars-insert|hatena-star.ui:hatena-star-stars-insert ENTRY-OR-STARS &KEY TAG STAR-CHAR COLOR>))
    �Ł���`�悷��Ƃ��ɁA�ȗ��`���ɂ���ŏ��́��̐��ł��B

    �f�t�H���g�� 16 �ł��B


=== CONSTANT

�Ȃ��B

=== CODITION

�Ȃ��B

=== COMMAND

�Ȃ��B

=== DATATYPE

--- BLOG-INFO

    BLOG-INFO �̓u���O�̂͂ĂȃX�^�[����ێ����܂��B
    BLOG-INFO ��
    ((<hatena-star-get-blog|hatena-star.api:hatena-star-get-blog BLOG-URI &KEY SINCE NOMSG CALLBACK FUTURE>))
    �Ŏ擾���܂��B

    BLOG-INFO ����͈ȉ��̊֐��ŏ����擾�ł��܂��B

    * ((<hatena-star-blog-uri|hatena-star.api:hatena-star-blog-uri BLOG-INFO>))
    * ((<hatena-star-blog-title|hatena-star.api:hatena-star-blog-title BLOG-INFO>))
    * ((<hatena-star-blog-star-count|hatena-star.api:hatena-star-blog-star-count BLOG-INFO>))

--- ENTRY-INFO

    ENTRY-INFO �̓u���O�G���g���̂͂ĂȃX�^�[����ێ����܂��B
    ENTRY-INFO ��
    ((<hatena-star-get-entries|hatena-star.api:hatena-star-get-entries PERMALINK-LIST &KEY SINCE NOMSG CALLBACK FUTURE>))
    �܂���
    ((<hatena-star-get-entry|hatena-star.api:hatena-star-get-entry ENTRY-OR-PERMALINK &KEY SINCE NOMSG CALLBACK FUTURE>))
    �Ŏ擾���܂��B

    ENTRY-INFO ����͈ȉ��̏����擾�ł��܂��B

    * ((<hatena-star-entry-can-comment-p|hatena-star.api:hatena-star-entry-can-comment-p ENTRY-INFO>))
    * ((<hatena-star-entry-uri|hatena-star.api:hatena-star-entry-uri ENTRY-INFO>))
    * ((<hatena-star-entry-stars|hatena-star.api:hatena-star-entry-stars ENTRY-INFO>))
    * ((<hatena-star-entry-comments|hatena-star.api:hatena-star-entry-comments ENTRY-INFO>))

--- STAR-LIST

    STAR-LIST �̓u���O�G���g���� ((<STAR-INFO>)) �̃��X�g�ł��B
    STAR-LIST ��
    ((<hatena-star-entry-stars|hatena-star.api:hatena-star-entry-stars ENTRY-INFO>))
    �Ŏ擾���܂��B

    STAR-LIST ����͈ȉ��̏����擾�ł��܂��B

    * ((<hatena-star-stars-all-p|hatena-star.api:hatena-star-stars-all-p ENTRY-OR-STARS>))
    * ((<hatena-star-stars-by-user-p|hatena-star.api:hatena-star-stars-by-user-p ENTRY-OR-STARS>))
    * ((<hatena-star-stars-inner-count-p|hatena-star.api:hatena-star-stars-inner-count-p ENTRY-OR-STARS>))
    * ((<hatena-star-stars-inner-count-values|hatena-star.api:hatena-star-stars-inner-count-values ENTRY-OR-STARS>))
    * ((<hatena-star-stars-count|hatena-star.api:hatena-star-stars-count ENTRY-OR-STARS>))

--- STAR-INFO

    STAR-INFO �̓u���O�G���g���́��̏���ێ����܂��B
    STAR-INFO �� ((<STAR-LIST>)) �̗v�f�ł��B

    STAR-INFO ����͈ȉ��̏����擾�ł��܂��B

    * ((<hatena-star-star-name|hatena-star.api:hatena-star-star-name STAR-INFO>))
    * ((<hatena-star-star-quote|hatena-star.api:hatena-star-star-quote STAR-INFO>))
    * ((<hatena-star-star-count|hatena-star.api:hatena-star-star-count STAR-INFO>))
    * ((<hatena-star-star-values|hatena-star.api:hatena-star-star-values STAR-INFO>))

--- COMMENT-INFO

    COMMENT-INFO �̓u���O�G���g���̃R�����g��ێ����܂��B
    COMMENT-INFO ��
    ((<hatena-star-entry-comments|hatena-star.api:hatena-star-entry-comments ENTRY-INFO>))
    �Ŏ擾���܂��B

    COMMENT-INFO ����͈ȉ��̏����擾�ł��܂��B

    * ((<hatena-star-comment-name|hatena-star.api:hatena-star-comment-name COMMENT-INFO>))
    * ((<hatena-star-comment-body|hatena-star.api:hatena-star-comment-body COMMENT-INFO>))
    * ((<hatena-star-comment-values|hatena-star.api:hatena-star-comment-values COMMENT-INFO>))


=== FUNCTION

--- hatena-star.api:hatena-star-get-blog BLOG-URI &KEY SINCE NOMSG CALLBACK FUTURE

    �w�肳�ꂽ BLOG-URI �̃u���O�̂͂ĂȃX�^�[�����擾���܂��B

    ((<BLOG-INFO>)) ��Ԃ��܂��B

    ��:
        (let ((blog (hatena-star-get-blog "http://d.hatena.ne.jp/hatenastar/")))
          (msgbox "~A�́���~D�ł��B~%~A"
                  (hatena-star-blog-title blog)
                  (hatena-star-blog-star-count blog)
                  (hatena-star-blog-uri blog)))

    * NOMSG �� non-nil ���w�肷��ƃ��b�Z�[�W���o�͂��܂���B

      nil �̏ꍇ���b�Z�[�W�̈�ɒʐM��Ԃ�\�����܂��B
      �f�t�H���g�� nil �ł��B

    * SINCE �ɂ͑��M���� If-Modified-Since �w�b�_���w�肵�܂��B

      SINCE �ɂ͈ȉ��̒l���w��ł��܂��B

      : :epoch
          Unix epoch (1970-01-01 00:00:00) �𑗐M���܂��B
          ���̒l���w�肷��ƃL���b�V�����g�킸�Ƀl�b�g���[�N����擾���܂��B

      : <���l>
          ���l���w�肵���ꍇ�̓��[�J�����Ԃ� universal-time �ƌ��Ȃ���
          ������ɕϊ����܂��B

      : <������>
          ��������w�肵���ꍇ�͂��̂܂ܑ��M���܂��B

    * CALLBACK ���w�肷��Ɣ񓯊��ʐM���s���܂��B

      �͂ĂȃX�^�[���̎擾�ɐ��������ꍇ�̓u���O���
      CALLBACK �̈����Ɏw�肵�Ăяo���܂��B

      ���s�����ꍇ�͕����񂪓n����܂��B

    * FUTURE �� non-nil ���w�肵���ꍇ�� xml-http-request �� Future �I�u�W�F�N�g��Ԃ��܂��B

      Future �I�u�W�F�N�g������擾����ɂ͈ȉ��̊֐����g�p���܂��B
      * ((<hatena-star-future-completed-p|hatena-star.api:hatena-star-future-completed-p FUTURE>))
      * ((<hatena-star-future-p|hatena-star.api:hatena-star-future-p OBJ>))
      * ((<hatena-star-future-value|hatena-star.api:hatena-star-future-value FUTURE &REST OPTIONS>))

--- hatena-star.api:hatena-star-blog-uri BLOG-INFO

    �u���O�� URI ��Ԃ��܂��B

--- hatena-star.api:hatena-star-blog-title BLOG-INFO

    �u���O�̃^�C�g����Ԃ��܂��B

--- hatena-star.api:hatena-star-blog-star-count BLOG-INFO

    �u���O�ɕt�������̐���Ԃ��܂��B

--- hatena-star.api:hatena-star-get-entries PERMALINK-LIST &KEY SINCE NOMSG CALLBACK FUTURE

    �w�肳�ꂽ PERMALINK-LIST �ɕt����ꂽ �͂ĂȃX�^�[�̏����擾���܂��B

    ((<ENTRY-INFO>)) �� RKS (�{���ҏ��) ���l�ŕԂ��܂��B

    ��:
        (defvar *rks* nil)
        (multiple-value-bind (entry rks)
            (hatena-star-get-entries "http://d.hatena.ne.jp/hatenastar/20071129/1196290565")
          (setf *rks* rks)
          (msgbox "~A~%~D" rks (hatena-star-stars-count entry)))

        (multiple-value-bind (entries _)
            (hatena-star-get-entries '("http://d.hatena.ne.jp/hatenastar/20071129/1196290565"
                                       "http://d.hatena.ne.jp/hatenastar/20071124/1195896789"
                                       "http://d.hatena.ne.jp/hatenastar/20071115/1195092449"
                                       "http://d.hatena.ne.jp/jkondo/20080130/1201642779"))
          (dolist (entry entries)
            (msgbox "~D: ~A"
                    (hatena-star-stars-count entry)
                    (hatena-star-entry-uri entry))))


    ���� 15 �ȏ�t�����G���g���́��̏�񂪏ȗ�����A
    �ꕔ�̏�� (�ŏ��́��A�Ԃ́��̐��A�Ō�́�) �����擾�ł��܂���B

    ���ׂẮ����擾�������ꍇ�͂����
    ((<hatena-star-get-entry|hatena-star.api:hatena-star-get-entry ENTRY-OR-PERMALINK &KEY SINCE NOMSG CALLBACK FUTURE>))
    ���Ăяo���K�v������܂��B

    * PERMALINK-LIST �ɂ͕����̃G���g���� permalink �����X�g�Ŏw�肵�܂��B

      �擾�������G���g����������Ȃ��ꍇ�́A���� permalink �𕶎���Ŏw�肵�Ă����܂��܂���
      (�v�f����̃��X�g�ɂ���K�v�͂���܂���)�B

      * permalink �����X�g�Ŏw�肵���ꍇ�A((<ENTRY-INFO>)) �̃��X�g��Ԃ��܂��B
      * permalink �𕶎���Ŏw�肵���ꍇ�A((<ENTRY-INFO>)) ���P�Ԃ��܂��i���X�g�ł͂Ȃ��j�B

    * CALLBACK, FUTURE ��
      ((<hatena-star-get-blog|hatena-star.api:hatena-star-get-blog BLOG-URI &KEY SINCE NOMSG CALLBACK FUTURE>))
      ���Q�Ƃ��Ă��������B

--- hatena-star.api:hatena-star-get-entry ENTRY-OR-PERMALINK &KEY SINCE NOMSG CALLBACK FUTURE

    �w�肳�ꂽ�G���g���ɕt�����͂ĂȃX�^�[�̃G���g�������擾���܂��B

    ((<ENTRY-INFO>)) ��Ԃ��܂��B

    ���� API �Ŏ擾�����ꍇ�A�u�ŏ��́��A�Ԃ́��̐��A�Ō�́��v�`���̏ȗ��͂���܂���B

    * ENTRY-OR-PERMALINK �ɂ� ((<ENTRY-INFO>)) �� permalink �𕶎���Ŏw�肵�܂��B

    * CALLBACK, FUTURE ��
      ((<hatena-star-get-blog|hatena-star.api:hatena-star-get-blog BLOG-URI &KEY SINCE NOMSG CALLBACK FUTURE>))
      ���Q�Ƃ��Ă��������B

--- hatena-star.api:hatena-star-entry-can-comment-p ENTRY-INFO

    ���̃G���g���ɃR�����g�����邱�Ƃ��ł��邩�Ԃ��܂��B

--- hatena-star.api:hatena-star-entry-uri ENTRY-INFO

    �G���g���� URI ��Ԃ��܂��B

--- hatena-star.api:hatena-star-entry-stars ENTRY-INFO

    �G���g�����灙���X�g���擾���܂��B

    ((<STAR-LIST>)) ��Ԃ��܂��B

    ��:
        (let* ((e (hatena-star-get-entry "http://d.hatena.ne.jp/hatenastar/20070707/1184453490"))
               (stars (hatena-star-entry-stars e)))
          (with-output-to-temp-buffer ("*Hatena:Star*")
            (format t "���̐�: ~D~%~A~%~%"
                    (hatena-star-stars-count stars)
                    (hatena-star-entry-uri e))
            (dolist (star stars)
              (multiple-value-bind (name quote _)
                  (hatena-star-star-values star)
                (format t "~A�u~A�v~%" name (or quote ""))))))

    ���̃��X�g�͏ȗ�����邱�Ƃ�����܂��B

    * ((<hatena-star-get-entries|hatena-star.api:hatena-star-get-entries PERMALINK-LIST &KEY SINCE NOMSG CALLBACK FUTURE>))
      �Ŏ擾�����ꍇ�F

      * ���� 15 �ȏ�t���Ă���ꍇ�́A�u�ŏ��́��A�Ԃ́��̐��A�Ō�́��v
        �������������擾�ł��܂���B

        �Ԃ́��̏�񂪂ق����ꍇ�� hatena-star-get-entry ���g���K�v������܂��B

        ���̌`���̏ȗ��`���ǂ�����
        ((<hatena-star-stars-inner-count-p|hatena-star.api:hatena-star-stars-inner-count-p ENTRY-OR-STARS>))
        �Ŕ���ł��܂��B

      * 15 �����̏ꍇ�͂��ׂĂ̏����擾�\�ł��B

        ���ׂĂ̏�񂪎擾�\���ǂ�����
        ((<hatena-star-stars-all-p|hatena-star.api:hatena-star-stars-all-p ENTRY-OR-STARS>))
        �Ŕ���ł��܂��B

    * ((<hatena-star-get-entry|hatena-star.api:hatena-star-get-entry ENTRY-OR-PERMALINK &KEY SINCE NOMSG CALLBACK FUTURE>))
      �Ŏ擾�����ꍇ�F

      * ���� 300 �ȏ�t���Ă���ꍇ�́A���[�U���Ƃɐ��̐����W�񂳂�܂��B

        �e���[�U���t�������̐���
        ((<hatena-star-star-count|hatena-star.api:hatena-star-star-count STAR-INFO>))
        �Ŏ擾�ł��܂��B

        ���̌`���̏ȗ��`���ǂ�����
        ((<hatena-star-stars-by-user-p|hatena-star.api:hatena-star-stars-by-user-p ENTRY-OR-STARS>))
        �Ŕ���ł��܂��B

      * 300 �����̏ꍇ�͂��ׂĂ̏����擾�\�ł��B

        ((<hatena-star-stars-all-p|hatena-star.api:hatena-star-stars-all-p ENTRY-OR-STARS>))
        �Ŕ���ł��܂��B

--- hatena-star.api:hatena-star-entry-comments ENTRY-INFO

    �G���g���ɕt�����R�����g�����X�g�ŕԂ��܂��B

    �R�����g����͈ȉ��̏����擾�ł��܂��B

--- hatena-star.api:hatena-star-comment-name COMMENT-INFO

    �R�����g�������l�̖��O���擾���܂��B

--- hatena-star.api:hatena-star-comment-body COMMENT-INFO

    �R�����g�̖{�����擾���܂��B�{�����Ȃ��ꍇ�� nil ��Ԃ��܂��B

--- hatena-star.api:hatena-star-comment-values COMMENT-INFO

    �R�����g�������l��
    ((<"���O"|hatena-star.api:hatena-star-comment-name COMMENT-INFO>))
    ��
    ((<�{�� |hatena-star.api:hatena-star-comment-body COMMENT-INFO>))
    �𑽒l�ŕԂ��܂��B

--- hatena-star.api:hatena-star-stars-all-p ENTRY-OR-STARS

    ���̃��X�g����؏ȗ�����Ă��Ȃ��Ȃ� t ��Ԃ��܂��B

    �G���g�����Ɓ����X�g�̗������w��ł��܂��B

--- hatena-star.api:hatena-star-stars-by-user-p ENTRY-OR-STARS

    ���̃��X�g�������������[�U���ƂɏW�񂳂�Ă���Ȃ� t ��Ԃ��܂��B

    �G���g�����Ɓ����X�g�̗������w��ł��܂��B

--- hatena-star.api:hatena-star-stars-inner-count-p ENTRY-OR-STARS

    ���̃��X�g���i�ŏ��́��A�Ԃ́��̐��A�Ō�́��j�݂̂̏ꍇ t ��Ԃ��܂��B

    �G���g�����Ɓ����X�g�̗������w��ł��܂��B

--- hatena-star.api:hatena-star-stars-by-user ENTRY-OR-STARS &KEY LIST-QUOTE

    ���̃��X�g�����[�U���ƂɏW�񂵂܂��B
    ���̊֐���
    ((<hatena-star-get-entry|hatena-star.api:hatena-star-get-entry ENTRY-OR-PERMALINK &KEY SINCE NOMSG CALLBACK FUTURE>))
    �Ŏ擾���������X�g���A���̐��ɂ�����炸�ɏW��`���ɂ������ꍇ�ɗ��p���܂��B

    * ���[�U���Ƃ̐��̐���
      ((<hatena-star-star-count|hatena-star.api:hatena-star-star-count STAR-INFO>))
      �Ŏ擾�ł��܂��B

    * LIST-QUOTE �� non-nil �̏ꍇ�A���p�������X�g�ŕԂ��܂��B
      nil �̏ꍇ�͍ŏ��̈��p���݂̂�Ԃ��܂��B

      �f�t�H���g�� nil �ł��B

    * ���� 300 �𒴂���ꍇ�͍ŏ����烆�[�U���ƂɏW�񂳂�Ă��܂��B

      (�������̂���) ���łɏW�񂳂�Ă��� LIST-QUOTE �� nil �̏ꍇ�͈��������̂܂ܕԂ��܂��B
      LIST-QUOTE �� non-nil �̏ꍇ�́A���X�g�ɂ��ĕԂ��܂��B

      �����Ӂ� ����āA�ȉ��̃R�[�h�͈��p�������X�g�ŕԂ��܂��B

          (let ((stars (hatena-star-stars-by-user stars :list-quote t)))
            (hatena-star-stars-by-user stars :list-quote nil))

    * inner count �`��
      (((<hatena-star-stars-inner-count-p|hatena-star.api:hatena-star-stars-inner-count-p ENTRY-OR-STARS>))
      �� t ��Ԃ�) �̏ꍇ type-error ��ʒm���܂��B

    �G���g�����Ɓ����X�g�̗������w��ł��܂��B

--- hatena-star.api:hatena-star-stars-inner-count-values ENTRY-OR-STARS

    ���̃��X�g����i�ŏ��́��A�Ԃ́��̐��A�Ō�́��j�𑽒l�Ŏ擾���܂��B

    ((<hatena-star-stars-inner-count-p|hatena-star.api:hatena-star-stars-inner-count-p ENTRY-OR-STARS>))
    �� nil �ł���L�`���Ŏ擾�ł��܂��B

    �G���g�����Ɓ����X�g�̗������w��ł��܂��B

--- hatena-star.api:hatena-star-stars-count ENTRY-OR-STARS

    ���̑������擾���܂��B�����ȗ�����Ă��Ă��������擾�\�ł��B

--- hatena-star.api:hatena-star-star-name STAR-INFO

    ���������l�̖��O���擾���܂��B

--- hatena-star.api:hatena-star-star-quote STAR-INFO

    ���̈��p�����擾���܂��B���p���Ă��Ȃ��ꍇ�� nil ��Ԃ��܂��B

--- hatena-star.api:hatena-star-star-count STAR-INFO

    ���������l���Ƃ́��̌���Ԃ��܂��B

    300 �ȏ�́��������G���g���i
    ((<hatena-star-stars-by-user-p|hatena-star.api:hatena-star-stars-by-user-p ENTRY-OR-STARS>))
    �� t ��Ԃ��j�̏ꍇ�̂ݒl��Ԃ��܂��B

    ���̐��� 300 �����̏ꍇ�� nil ��Ԃ��܂��B

--- hatena-star.api:hatena-star-star-values STAR-INFO

    ���������l��
    ((<"���O"|hatena-star.api:hatena-star-star-name STAR-INFO>))
    ��
    ((<"���p��"|hatena-star.api:hatena-star-star-quote STAR-INFO>))
    ��
    ((<"���̐�"|hatena-star.api:hatena-star-star-count STAR-INFO>))
    �𑽒l�ŕԂ��܂��B

--- hatena-star.api:hatena-star-add-star ENTRY-OR-PERMALINK RKS &KEY NOMSG CALLBACK FUTURE TOKEN TITLE QUOTE

    �w�肳�ꂽ�G���g���Ɂ������܂��B

    ���ۂɂ������� ((<STAR-INFO>)) ��Ԃ��܂��B

    * ENTRY-OR-PERMALINK �ɂ� ((<ENTRY-INFO>)) �� permalink �𕶎���Ŏw�肵�܂��B

    * RKS ��
      ((<hatena-star-get-entries|hatena-star.api:hatena-star-get-entries PERMALINK-LIST &KEY SINCE NOMSG CALLBACK FUTURE>))
      �Ŏ擾�ł��܂��B

    * TOKEN �ɂ̓T�C�g�ŗL�̎��ʎq���w�肵�܂��B

      �Ȃ��Ă������݂����ł��B

    * TITLE �ɂ̓G���g���̃^�C�g�����w�肵�܂��B

    * QUOTE �ɂ́��̈��p��������w�肵�܂��B

      ���̃y�[�W�Ɋ܂܂�Ă��Ȃ���������w�肷�邱�Ƃ͂ł��܂���B
      �w�肵���ꍇ�A���p������Ȃ��Ł����t���܂��B

      ���������p�ł������ǂ����͖߂�l�ŕ�����܂��B

    * CALLBACK, FUTURE ��
      ((<hatena-star-get-blog|hatena-star.api:hatena-star-get-blog BLOG-URI &KEY SINCE NOMSG CALLBACK FUTURE>))
      ���Q�Ƃ��Ă��������B

--- hatena-star.api:hatena-star-add-comment ENTRY-OR-PERMALINK RKS &KEY CALLBACK FUTURE TITLE BODY

    �w�肳�ꂽ URI �ɃR�����g�����܂��B
    �R�����g�̓X�^�[�t�����h�ɂ��������܂���B

    ((<COMMENT-INFO>)) ��Ԃ��܂��B

    * ENTRY-OR-PERMALINK �ɂ� ((<ENTRY-INFO>)) �� permalink �𕶎���Ŏw�肵�܂��B

    * RKS ��
      ((<hatena-star-get-entries|hatena-star.api:hatena-star-get-entries PERMALINK-LIST &KEY SINCE NOMSG CALLBACK FUTURE>))
      �Ŏ擾�ł��܂��B

    * TITLE �� BODY �ŃR�����g�̓��e���w�肵�܂��B

    * CALLBACK, FUTURE ��
      ((<hatena-star-get-blog|hatena-star.api:hatena-star-get-blog BLOG-URI &KEY SINCE NOMSG CALLBACK FUTURE>))
      ���Q�Ƃ��Ă��������B

--- hatena-star.api:hatena-star-deletable-p NAME-OR-STAR &KEY CALLBACK FUTURE

    �w�肵�����[�U�́����폜�ł���ꍇ t ��Ԃ��܂��B

    ��{�I�ɂ͎����� NAME �̏ꍇ�̂� t ��Ԃ��͂��ł��B
    �͂ĂȂɃ��O�C�����Ă��Ȃ��ꍇ�͎����� NAME �ł� nil ��Ԃ��܂��i���Ԃ�j�B

    * NAME-OR-STAR �ɂ̓��[�U���𕶎���Ŏw�肷�邩 ((<STAR-INFO>)) ���w�肵�܂��B

    * CALLBACK, FUTURE ��
      ((<hatena-star-get-blog|hatena-star.api:hatena-star-get-blog BLOG-URI &KEY SINCE NOMSG CALLBACK FUTURE>))
      ���Q�Ƃ��Ă��������B

--- hatena-star.api:hatena-star-delete-star ENTRY-OR-PERMALINK RKS &KEY CALLBACK FUTURE NAME QUOTE STAR

    �w�肵���G���g���ɕt���������폜���܂��B

    ���������ꍇ�� t ���A���s�����ꍇ�� nil ��Ԃ��܂��B

    * ENTRY-OR-PERMALINK �ɂ� ((<ENTRY-INFO>)) �� permalink �𕶎���Ŏw�肵�܂��B

    * RKS ��
      ((<hatena-star-get-entries|hatena-star.api:hatena-star-get-entries PERMALINK-LIST &KEY SINCE NOMSG CALLBACK FUTURE>))
      �Ŏ擾�ł��܂��B

    * CALLBACK, FUTURE ��
      ((<hatena-star-get-blog|hatena-star.api:hatena-star-get-blog BLOG-URI &KEY SINCE NOMSG CALLBACK FUTURE>))
      ���Q�Ƃ��Ă��������B

    * �폜���遙�� STAR �� NAME �� QUOTE �Ŏw�肵�܂��B

      * STAR �ɂ� ((<STAR-INFO>)) ���w�肵�܂��B

        �w�肵�� STAR �����̃��[�U�́��Ȃ�폜�ł��܂���B

      * NAME �� QUOTE �͕�����Ń��[�U���ƈ��p�����w�肵�܂��B

        NAME �͏ȗ��\�ł��B�ȗ������ꍇ�͎����́����ΏۂɂȂ�܂��B
        QUOTE ���ȗ������ꍇ�͈��p���Ȃ��́����ΏۂɂȂ�܂��B

    ��:

        ;; example.com �ɕt���������́�����폜
        (hatena-star-delete-star "http://example.com/" *rks*)

        ;; example.com �� "example" �����p���ĕt���������́�����폜
        (hatena-star-delete-star "http://example.com/" *rks* :quote "foo")

        ;; example.com �ɕt���Ă��鎩���́���S���폜
        (multiple-value-bind (entry rks)
            (hatena-star-get-entry "http://example.com/")
          (dolist (star (hatena-star-entry-stars entry))
            (when (hatena-star-deletable-p star) ; �蔲���B�B�Bdeletable-p �̌��ʂ̓L���b�V�����ׂ�
              (hatena-star-delete-star entry rks :star star))))


--- hatena-star.api:hatena-star-future-p OBJ

    �w�肳�ꂽ OBJ �� Future �I�u�W�F�N�g�Ȃ� non-nil ��Ԃ��܂��B

--- hatena-star.api:hatena-star-future-completed-p FUTURE

    �w�肳�ꂽ Future �I�u�W�F�N�g�̃��N�G�X�g���������Ă����� non-nil ��Ԃ��܂��B

--- hatena-star.api:hatena-star-future-value FUTURE &REST OPTIONS

    �w�肳�ꂽ Future �I�u�W�F�N�g���猋�ʂ��擾���܂��B
    ���N�G�X�g���������Ă��Ȃ��ꍇ�͊�����҂����킹�܂��B

    �����̏ڍׂ�
    ((<xml-http-request|URL:http://miyamuko.s56.xrea.com/xyzzy/xml-http-request.html>))
    �� (({xhr-future-value})) ���Q�Ƃ��Ă��������B

--- hatena-star.api:hatena-star-version

    �{���C�u�����̃o�[�W������Ԃ��܂��B
    �o�[�W������ major.minor.teeny �Ƃ����`���ł��B

    ���ꂼ��̔ԍ��͕K�� 1 ���ɂ���̂ŁA�ȉ��̂悤�ɔ�r���邱�Ƃ��ł��܂�

        (if (string<= "1.1.0" (hatena-star-version))
            '(1.1.0 �ȍ~�ŗL���ȏ���)
          '(1.1.0 ���O�̃o�[�W�����ł̏���))


--- hatena-star.ui:hatena-star-make-stars-string COUNT &KEY STAR-CHAR INNER INNER-MIN

    �w�肳�ꂽ COUNT ���́��𕶎���ŕԂ��܂��B

    ��F
         (hatena-star-make-stars-string 15)
         "������������������������������"
         (hatena-star-make-stars-string 16 :star-char #\��)
         "��14��"
         (hatena-star-make-stars-string 4 :inner-min 5)
         "��������"
         (hatena-star-make-stars-string 5 :inner-min 5)
         "��3��"
         (hatena-star-make-stars-string 3 :inner t)
         "��1��"

    * STAR-CHAR �ɂ́��ɑΉ����� charcter ���w�肵�܂��B
      �f�t�H���g�� ((<*hatena-star-default-star-char*|hatena-star.ui:*hatena-star-default-star-char*>))
      �ł��B

    * INNER �� non-nil �̏ꍇ�AINNER-MIN �̒l�ɂ�����炸�ȗ��`���ŕԂ��܂��B
      �������ACOUNT �� 2 �ȉ��̏ꍇ�͏ȗ��`���ɂ͂Ȃ�܂���B

      �f�t�H���g�� nil �ł��B

    * INNER-MIN �ɂ͏ȗ��`���ɂ���ŏ��̐����w�肵�܂��B
      ���̐��� INNER-MIN ��菭�Ȃ��ꍇ�͏ȗ��`���ɂ͂Ȃ�܂���B

      �f�t�H���g�� ((<*hatena-star-inner-count-min*|hatena-star.ui:*hatena-star-inner-count-min*>))
      �ł��B

--- hatena-star.ui:hatena-star-stars-to-string ENTRY-OR-STARS &KEY STAR-CHAR

    �w�肳�ꂽ ((<STAR-LIST>)) �����̕�����ɂ��܂��B

    * STAR-CHAR �ɂ́��ɑΉ����� charcter ���w�肵�܂��B
      �f�t�H���g�� ((<*hatena-star-default-star-char*|hatena-star.ui:*hatena-star-default-star-char*>))
      �ł��B

    * ���̐��� ((<*hatena-star-inner-count-min*|hatena-star.ui:*hatena-star-inner-count-min*>))
      �ȏ�̏ꍇ�͏ȗ��`���ɂȂ�܂��B

--- hatena-star.ui:hatena-star-stars-insert ENTRY-OR-STARS &KEY TAG STAR-CHAR COLOR

    �w�肳�ꂽ ((<STAR-LIST>)) �����̕�����ɂ��Č��݂̃o�b�t�@�ɑ}�����܂��B

    * TAG �ɂ̓e�L�X�g�̑������w�肵�܂��B�ڍׂ� set-text-attribute ���Q�Ƃ��Ă��������B

    * STAR-CHAR �ɂ́��ɑΉ����� charcter ���w�肵�܂��B
      �f�t�H���g�� ((<*hatena-star-default-star-char*|hatena-star.ui:*hatena-star-default-star-char*>))
      �ł��B

    * COLOR �ɂ́��̐F���w�肵�܂��B�ڍׂ� set-text-attribute ���Q�Ƃ��Ă��������B

      �f�t�H���g��
      ((<*hatena-star-default-star-color*|hatena-star.ui:*hatena-star-default-star-color*>))
      �Ŏw�肵�܂��B

    * ���̐��� ((<*hatena-star-inner-count-min*|hatena-star.ui:*hatena-star-inner-count-min*>))
      �ȏ�̏ꍇ�͏ȗ��`���ɂȂ�܂��B

    * TAG ����� COLOR �� nil �̏ꍇ�̓e�L�X�g�����͐ݒ肵�܂���B


=== MACRO

�Ȃ��B


== SAMPLE CODE

�J�[�\������ URL �̂͂ĂȃX�^�[�����o�b�t�@�ɕ\������T���v���B
URL �̎擾�� clickable-uri ���g���b�L�[�Ɏg���Ă܂��B

  (require "clickable-uri")
  (require "hatena-star/api")
  (use-package :hatena-star.api)

  (defun show-hatena-star-entry (entry)
    (when entry
      (macrolet ((puts (fmt &rest args)
                   `(insert (format nil ,fmt ,@args))))
        (with-output-to-temp-buffer ("*Hatena:Star*")
          (puts "���̐�: ~D~%~A~%~%"
                (hatena-star-stars-count entry)
                (hatena-star-entry-uri entry))
          (dolist (star (hatena-star-entry-stars entry))
            (multiple-value-bind (name quote count)
                (hatena-star-star-values star)
              (puts name)
              (when count
                (puts " (~D)" count))
              (when quote
                (indent-to 30)
                (puts " �u~A�v" quote))
              (puts "\n")))
          (goto-char (point-min))
          (refresh-screen)))))

  (defun show-hatena-star-uri-later (uri)
    (hatena-star-get-entry uri :callback #'show-hatena-star-entry))

  (defun show-current-link-hatena-star ()
    (interactive)
    (let ((*clickable-uri-open-command-alist*
           (acons "^https?://" #'show-hatena-star-uri-later nil))
          (*clickable-uri-keep-focus* nil))
      (clickable-uri-open)))

  (global-set-key '(#\C-c #\s) 'show-current-link-hatena-star)


== TODO

* RKS �̎����擾�E�ۑ�
* ���p���� HTML �^�O�̏����A���s�̓���
* get-entries �� URI ���� 2084 ���������̑Ώ�
  * �������ă��N�G�X�g�����ꍇ�Afuture �� callback �͂ǂ����邩�B
    * ����ԋA���Ă��Ă��犮��?
* hatena-star.ui
  * mouse
  * popup-hatena-star
  * clickable-star


== KNOWN BUGS

* IE �ł͂ĂȂɃ��O�C�����Ă��Ȃ��ƁAadd/delete �������Ȃ�


== AUTHOR

�݂�ނ� ���䂫 (((<URL:mailto:miyamuko@gmail.com>)))


== SEE ALSO

: Hatena: �͂ĂȃX�^�[�J�E���g API �Ƃ�
    ((<URL:http://d.hatena.ne.jp/keyword/%A4%CF%A4%C6%A4%CA%A5%B9%A5%BF%A1%BC%A5%AB%A5%A6%A5%F3%A5%C8API?kid=217860>))

: �����܂�Ȃ������̂�HatenaStar.js�����p���Ă���API�𒲂ׂĂ݂��B
    ((<URL:http://d.hatena.ne.jp/Yuichirou/20070802#1186070862>))

: HatenaStar.js
    ((<URL:http://s.hatena.ne.jp/js/HatenaStar.js>))


== COPYRIGHT

hatena-star �� MIT/X ���C�Z���X�ɏ]���Ė{�\�t�g�E�F�A���g�p�A�Ĕz�z���邱�Ƃ��ł��܂��B

See hatena-star/docs/MIT-LICENSE for full license.


== NEWS

<<<NEWS.rd
