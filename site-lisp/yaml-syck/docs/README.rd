=begin

= yaml-syck - ������������ YAML 1.0 �p�[�T

  * Author: �݂�ނ� ���䂫 ((<URL:mailto:miyamuko@gmail.com>))
  * Home URL: ((<URL:http://miyamuko.s56.xrea.com/xyzzy/yaml-syck/intro.htm>))
  * Version: 0.1.0


== NAME

yaml-syck - ������������ YAML 1.0 �p�[�T


== SYNOPSIS

  (require "yaml-syck")
  (use-package :yaml-syck)

  (syck-load "
  xyzzy:
    author: Tetsuya Kamei
    lang: common lisp
  emacs:
    author: RMS
    lang: emacs lisp
  ")

  (syck-load-file "config.yaml"
                  :null nil
                  :true t
                  :false nil
                  :nan 0
                  :inf (symbol-value 'most-positive-long-float)
                  :neginf (symbol-value 'most-negative-long-float)
                  :seq :sexp
                  :map :sexp
                  :timestamp :universal-time
                  :implicit-keyword-p nil
                  :implicit-typing-p t)

  (let ((opts (make-syck-parser-option :seq :array)))
    (syck-load-documents "config.yaml"
                         :from :filename
                         :option opts
                         :callback #'(lambda (y)
                                       (msgbox "~S" v))))


== DESCRIPTION

yaml-syck �� ((<syck|URL:http://code.whytheluckystiff.net/syck/>))
�𗘗p���� YAML �p�[�T�ł��B

* YAML �t�@�C�����p�[�X�� S ���ɕϊ��ł��܂��B
* YAML �� sequence �� S ���܂��� array �ɕϊ����邱�Ƃ��ł��܂��B
* YAML �� map �� S ���܂��� hash-table �ɕϊ����邱�Ƃ��ł��܂��B
* YAML �� timestamp �� S ���܂��� universal-time �ɕϊ����邱�Ƃ��ł��܂��B
* �r���h�ς݂� syck 0.61 + a �𓯍����Ă��܂��B


== INSTALL

((<NetInstaller|URL:http://www7a.biglobe.ne.jp/~hat/xyzzy/ni.html>))
�ŃC���X�g�[�������ꍇ�� 3 �ȍ~�� OK �ł��B

(1) �A�[�J�C�u���_�E�����[�h���܂��B

    ((<URL:http://miyamuko.s56.xrea.com/xyzzy/archives/yaml-syck.zip>))

(2) �A�[�J�C�u��W�J���āA$XYZZY/site-lisp �z���Ƀt�@�C�����R�s�[���܂��B

(3) yaml-syck �̓��C�u�����ł��B
    �A�v���P�[�V�����͈ȉ��̃R�[�h�� yaml-syck �𗘗p���邱�Ƃ��ł��܂��B

      (require "yaml-syck")
      (use-package :yaml-syck)

    use-package ����Ƃ������̃V���{�����p�b�P�[�W�C���q�Ȃ��ŎQ�Ƃł���悤�ɂȂ�܂����A
    editor �� user �ł� use-package ���Ȃ��ق��������ł��傤�B


== MODULE

=== PACKAGE

yaml-syck �͈ȉ��̃p�b�P�[�W�𗘗p���Ă��܂��B

  * yaml-syck
  * yaml-syck-util
  * yaml-syck-ffi

nickname �͂���܂���B

=== EXPORT

yaml-syck �͈ȉ��̃V���{���� export ���Ă��܂��B

  * yaml-syck �p�b�P�[�W

    [API]
    * ((< syck-load >))
    * ((< syck-load-file >))
    * ((< syck-load-documents >))

    [�p�[�T�I�v�V����]
    * syck-parser-option
    * ((< make-syck-parser-option >))

    * syck-parser-option-null
    * syck-parser-option-no
    * syck-parser-option-yes
    * syck-parser-option-inf
    * syck-parser-option-neginf
    * syck-parser-option-nan

    * syck-parser-option-seq
    * syck-parser-option-map
    * syck-parser-option-timestamp

    * syck-parser-option-implicit-keyword-p
    * syck-parser-option-implicit-typing-p

    [�o�[�W����]
    * ((< syck-xyzzy-binding-version >))
    * ((< syck-version >))
    * ((< syck-yaml-version >))
    * ((< syck-yaml-major-version >))
    * ((< syck-yaml-minor-version >))
    * ((< syck-yaml-domain >))

    [��O]
    * ((<syck-simple-error>))[-*]
    * ((<syck-argument-error>))[-*]
    * ((<syck-runtime-error>))[-*]
    * ((<syck-parse-error>))[-*]
    * ((<syck-compose-error>))[-*]
    * ((<syck-bad-alias-error>))[-*]
    * ((<syck-invalid-merge-node-error>))[-*]

  * yaml-syck-util �p�b�P�[�W

    * �����p�p�b�P�[�W�Ȃ̂ŏȗ�

  * yaml-syck-ffi �p�b�P�[�W

    * �����p�p�b�P�[�W�Ȃ̂ŏȗ�


=== CONDITION

yaml-syck �Œ�`���Ă����O�̌p���֌W�͈ȉ��̂Ƃ���ł��B

* simple-error
  * ((< syck-simple-error >))
    * ((< syck-runtime-error >))
    * ((< syck-argument-error >))
    * ((< syck-parse-error >))
    * ((< syck-compose-error >))
      * ((< syck-bad-alias-error >))
      * ((< syck-invalid-merge-node-error >))

--- syck-simple-error

    yaml-syck �֘A�̂��ׂė�O�̐e�R���f�B�V�����B

--- syck-runtime-error

    �Ӑ}���Ȃ��G���[�����������ꍇ�ɒʒm������O�B

--- syck-argument-error

    �s���Ȉ������w�肵���ꍇ�ɒʒm������O�B

--- syck-parse-error

    YAML �̃p�[�X�G���[�������������ɒʒm������O�B

    syck-parse-error �͈ȉ��̃����o��ێ����Ă��܂��B

    * source:

      �p�[�X�Ώۂ�Ԃ��܂��B
      �p�[�X�Ώۂ��t�@�C���̏ꍇ�̓t�@�C�������A������̏ꍇ�� "(string)" ��Ԃ��܂��B

        (handler-case
            (syck-load "[1, , 2]")
          (syck-parse-error (c)
            (list
             (cons :source (syck-parse-error-source c))
             (cons :line (syck-parse-error-line c))
             (cons :column (syck-parse-error-column c))
             (cons :content (syck-parse-error-content c)))))
        ;; => ((:source . "(string)")
        ;;     (:line . 1)
        ;;     (:column . 5)
        ;;     (:content . "[1, , 2]"))

    * line:

      �p�[�X�G���[�����������s�ԍ���Ԃ��܂��B

    * column

      �p�[�X�G���[�����������J������Ԃ��܂��B

    * content

      �p�[�X�G���[�����������ӏ��� YAML �𕶎���ŕԂ��܂��B

--- syck-compose-error

    S���̍\�z���ɃG���[�ɂȂ����ꍇ�ɒʒm������O�ł��B

    syck-compose-error �͈ȉ��̗�O�̐e�R���f�B�V�����ł��B
    syck-compose-error ���̂��������邱�Ƃ͂���܂���B

--- syck-bad-alias-error

    ����`�̃A���J�[���Q�Ƃ����ꍇ�ɒʒm������O�ł��B

      (syck-load "*foo")  ;; => yaml-syck: bad alias error: found undefined alias `foo'.

--- syck-invalid-merge-node-error

    �}�[�W�L�[�̒l���F
    * map
    * map �� sequence
    �ȊO�̏ꍇ�ɒʒm������O�ł��B

      (syck-load "
      - << : hoge
      ")
      ;; => yaml-syck: invalid merge node, expected a mapping or list of mappings: "hoge"

      (syck-load "
      - << : [hoge]
      ")
      ;; => yaml-syck: invalid merge node, expected a mapping or list of mappings: ("hoge")


=== VARIABLE

�Ȃ��B


=== COMMAND

�Ȃ��B


=== FUNCTION

--- syck-load

    call-seq:
        (syck-load str [options...])  =>  S expression

    YAML �h�L�������g��ǂݍ��� S ���ɕϊ����܂��B
    �ŏ��� YAML �h�L�������g�̂ݕԂ��܂��B

    * ���� str �ɂ� YAML �h�L�������g�𕶎���Ŏw�肵�܂��B
    * ������ȊO���w�肵���ꍇ�� type-error ��O��ʒm���܂�
    * ���� options �̓p�[�T�I�v�V�������w�肵�܂��B
      �p�[�T�I�v�V������ syck-parser-option �\���̂܂��̓L�[���[�h���X�g�Ŏw�肵�܂��B

      �ȉ��� 2 �̌Ăяo���͓����ł��B

        (syck-load "foo: [null, null]" :seq :array :map :hash-table)

        (let ((opts (make-syck-parser-option :seq :array)))
          (setf (syck-parser-option-map opts) :hash-table)
          (syck-load "foo: [null, null]" opts))

    �ȉ��̃I�v�V�������w��\�ł��B

    * ((< null >))
    * ((< true >))
    * ((< false >))
    * ((< nan >))
    * ((< inf >))
    * ((< neginf >))
    * ((< seq >))
    * ((< map >))
    * ((< timestamp >))
    * ((< hash-table-test >))
    * ((< implicit-typing-p >))
    * ((< implicit-keyword-p >))

    : null
        ((<"YAML �� NULL"|URL:http://yaml.org/type/null.html>)) �ɑΉ����� lisp �̒l���w�肵�܂��B

        �f�t�H���g�l�� nil �ł��B

          (syck-load "name: null" :null "null �Ł[��")
          ;; => (("name" . "null �Ł[��"))

    : true
        ((<"YAML �� true"|URL:http://yaml.org/type/bool.html>)) �ɑΉ����� lisp �̒l���w�肵�܂��B

        �f�t�H���g�l�� t �ł��B

          (syck-load "
          answer: NO
          logical: True
          option: on
          " :true "�n�C!")
          ;; => (("answer") ("logical" . #1="�n�C!") ("option" . #1#))

    : false
        ((<"YAML �� false"|URL:http://yaml.org/type/bool.html>)) �ɑΉ����� lisp �̒l���w�肵�܂��B

        �f�t�H���g�l�� nil �ł��B

          (syck-load "
          answer: NO
          logical: True
          option: on
          " :false "�Ⴄ��B�S�R�Ⴄ��B")
          ;; => (("answer" . "�Ⴄ��B�S�R�Ⴄ��B") ("logical" . t) ("option" . t))

    : nan
        ((<"YAML �� NaN"|URL:http://yaml.org/type/float.html>)) �ɑΉ����� lisp �̒l���w�肵�܂��B

        �f�t�H���g�l�� 0 �ł��B

          (defstruct not-a-number)
          (syck-load "not a number: .NaN" :nan (make-not-a-number))
          ;; => (("negative infinity" . -1.797693134862316d308) ("not a number" . #S(not-a-number)))

    : inf
        ((<"YAML �� +��"|URL:http://yaml.org/type/float.html>)) �ɑΉ����� lisp �̒l���w�肵�܂��B

        �f�t�H���g�l�� most-positive-long-float �ł��B

          (syck-load "infinity: .Inf" :inf :��)
          ;; => (("infinity" . :��))

    : neginf
        ((<"YAML �� -��"|URL:http://yaml.org/type/float.html>)) �ɑΉ����� lisp �̒l���w�肵�܂��B

        �f�t�H���g�l�� most-negative-long-float �ł��B

          (syck-load "negative infinity: .Inf" :inf :-��)
          ;; => (("negative infinity" . :-��))

    : seq
        ((<"YAML �� sequence"|URL:http://yaml.org/type/seq.html>)) �̃}�b�s���O���@���w�肵�܂��B

        * ������ :sexp �܂��� :array ���w�肵�܂��B
        * :sexp ���w�肵���ꍇ�̓��X�g�Ƀ}�b�s���O���܂��B
        * :array ���w�肵���ꍇ�͔z��Ƀ}�b�s���O���܂��B

        �f�t�H���g�l��:sexp �ł��B

          (syck-load "[1, 2, 3]" :seq :sexp)
          ;; => (1 2 3)

          (syck-load "[1, 2, 3]" :seq :array)
          ;; => #(1 2 3)

    : map
        ((<"YAML �� map"|URL:http://yaml.org/type/map.html>)) �̃}�b�s���O���@���w�肵�܂��B

        * ������ :sexp �܂��� :hash-table ���w�肵�܂��B
        * :sexp ���w�肵���ꍇ�͊֘A���X�g�Ƀ}�b�s���O���܂��B
        * :hash-table ���w�肵���ꍇ�� hashtable �Ƀ}�b�s���O���܂��B

        �f�t�H���g�l��:sexp �ł��B

          (syck-load "{xyzzy: common lisp, emacs: emacs lisp}" :map :sexp)
          ;; => (("xyzzy" . "common lisp") ("emacs" . "emacs lisp"))

          (setf h (syck-load "{xyzzy: common lisp, emacs: emacs lisp}" :map :hash-table))
          ;; => #<hashtable 52893588>
          (gethash "xyzzy" h)
          ;; => "common lisp"
          ;;    t
          (gethash "emacs" h)
          ;; => "emacs lisp"
          ;;    t

        ((<hash-table-test>)) ���Q�Ƃ��Ă��������B

    : timestamp
        ((<"YAML �� timestamp"|URL:http://yaml.org/type/timestamp.html>)) �̃}�b�s���O���@���w�肵�܂��B

        * �����ɂ͈ȉ��̒l���w��\�ł��B
          * :sexp
          * :universal-time
          * :string
          * :iso8601

        * :sexp ���w�肵���ꍇ�̓��X�g�Ƀ}�b�s���O���܂��B

          * ���X�g�̗v�f���� decode-universal-time �Ɠ���ł��B
              (SECOND MINUTE HOUR DAY MONTH YEAR TIME-ZONE)
          * �������ASECOND �� TIME-ZONE �͏����ɂȂ�ꍇ������̂ŁA
            ���̂܂܁Aencode-universal-time �� apply ���邱�Ƃ͂ł��܂���B

        * :universal-time ���w�肵���ꍇ�̓��j�o�[�T���^�C���ɕϊ����܂��B
        * :string ���w�肵���ꍇ�͕ϊ������ɕ�����̂܂ܕԂ��܂��B
        * :iso8601 ���w�肵���ꍇ�� iso8601 �`���̕�����ŕԂ��܂��B

        �f�t�H���g�l��:universal-time �ł��B

          (syck-load "2007-03-24T22:10:43.1Z" :timestamp :sexp)
          ;; => (43.1 10 22 24 3 2007 0)

          (syck-load "2007-03-24T22:10:43.1Z" :timestamp :universal-time)
          ;; => 3383763043

          (syck-load "2007-03-24T22:10:43.1Z" :timestamp :string)
          ;; =>"2007-03-24T22:10:43.1Z"

          (syck-load "2007-03-24T22:10:43.1Z" :timestamp :iso8601)
          ;; => 2007-03-25T07:10:43+0900

          (syck-load "2007-03-24" :timestamp :iso8601)
          ;; => 2007-03-24T00:00:00+0900

    : hash-table-test
        hash-table �̃e�X�g�֐����w�肵�܂��B

        * ((<map>)) �� :hash-table ���w�肵���Ƃ��̂ݗL���ȃI�v�V�����ł��B
        * �w��\�Ȋ֐��� eq, eql, equal, equalp �ł��B

        �f�t�H���g�� equal �ł��B

          (setf h (syck-load "{name: hogehoge}" :map :hash-table))
          ;; => #<hashtable 52893564>
          (hash-table-test h)
          ;; => equal
          (gethash "name" h)
          ;; => "hogehoge"
          ;;    t
          (gethash "NaME" h)
          ;; => nil
                nil

          (setf h (syck-load "{name: hogehoge}" :map :hash-table :hash-table-test #'equalp))
          ;; => #<hashtable 52893180>
          (hash-table-test h)
          ;; => equalp
          (gethash "name" h)
          ;; => "hogehoge"
          ;;    t
          (gethash "NaME" h)
          ;; => "hogehoge"
          ;;    t

    : implicit-typing-p
        ���l����t��ϊ����邩�ǂ������w�肵�܂��B

        * non-nil ���w�肷��ƌ^�ϊ����܂��B
        * nil ���w�肷��ƕϊ������ɕ�����̂܂ܕԂ��܂��B

        �f�t�H���g�l�� t �ł��B

          (syck-load "
          date: 2007-03-24T22:10:43.1Z
          bool: true
          number: 123
          " :implicit-typing-p t)
          ;; => (("date" . 3383763043) ("bool" . t) ("number" . 123))

          (syck-load "
          date: 2007-03-24T22:10:43.1Z
          bool: true
          number: 123
          " :implicit-typing-p nil)
          ;; => (("date" . "2007-03-24T22:10:43.1Z") ("bool" . "true") ("number" . "123"))

    : implicit-keyword-p
        �R�����Ŏn�܂镶������L�[���[�h�ɕϊ� (keyword �p�b�P�[�W���� intern)
        ���邩�ǂ������w�肵�܂��B

        * non-nil ���w�肷��� keyword �ɕϊ����܂��B
        * nil ���w�肷��ƕϊ������ɕ�����̂܂ܕԂ��܂��B
        * ���̈����� ((<implicit-typing-p>)) �� non-nil �̏ꍇ�̂ݗL���ł��B

        �f�t�H���g�l�� nil �ł��B

          (syck-load "
          :date: 2007-03-24T22:10:43.1Z
          :bool: true
          :number: 123
          " :implicit-keyword-p t)
          ;; => ((:date . 3383763043) (:bool . t) (:number . 123))

        �� YAML �̎d�l�ɂ͂Ȃ��g���ł��B


--- syck-load-file

    call-seq:
         (syck-load-file filename [options...])  =>  S expression

    YAML �t�@�C����ǂݍ��� S ���ɕϊ����܂��B
    �ŏ��� YAML �h�L�������g�̂ݕԂ��܂��B

    filename �ɕs���Ȓl���w�肵���ꍇ�͈ȉ��̗�O���ʒm����܂��B
    * ������ȊO���w�肵���ꍇ�� type-error
    * ���݂��Ȃ��t�@�C�������ꍇ�� file-not-found
    * �t�@�C���� open �Ɏ��s�����ꍇ�� file-error

--- syck-load-documents

    call-seq:
        (syck-load-documents str
                             :from :string
                             :option '(:seq :map ...)
                             :callback #'(lambda (ydoc) ...))
        => nil or list of yaml documents.

    YAML �h�L�������g���ЂƂ��ǂݍ��݁A�w�肳�ꂽ callback �����s���܂��B

    * callback ���w�肵�Ȃ��ꍇ�͂��ׂẴh�L�������g��ǂݍ��݃��X�g�ŕԂ��܂��B
    * �t�@�C������ǂݍ��ޏꍇ�� :from �� :file �܂��� :filename ���w�肵�܂��B
    * ������ǂݍ��ޏꍇ�� :from �� :string ���w�肵�܂� (�f�t�H���g)�B
    * �p�[�T�I�v�V������ :option �����ɃL�[���[�h���X�g�܂��� syck-parser-option �\���̂Ŏw�肵�܂��B

    ((<syck-load>)) �� ((<syck-load-file>)) �͍ŏ��� YAML �h�L�������g�����ǂݍ��݂܂���B
    ������ YAML �h�L�������g��ǂݍ��݂����ꍇ�͂��̊֐��𗘗p���Ă��������B

      (syck-load-documents "config.yaml"
                           :from :filename
                           :callback #'(lambda (y)
                                         (msgbox "~S" y)))
      nil

      (syck-load-documents "
      ---
      - name: xyzzy
        lang: common lisp
      ---
      - name: emacs
        lang: emacs lisp
      " :option '(:seq :array :map :hash-table))
      (#(#<hashtable 52893156>) #(#<hashtable 52893108>))

--- make-syck-parser-option

    call-seq:
        (make-syck-parser-option
         :null nil
         :true t
         :false nil
         :nan 0
         :inf (symbol-value 'most-positive-long-float)
         :neginf (symbol-value 'most-negative-long-float)
         :seq :sexp
         :map :sexp
         :timestamp :universal-time
         :implicit-keyword-p nil
         :implicit-typing-p t)
        => syck-parser-option

    syck-parser-option �\���̂��쐬���܂��B
    �p�[�T�I�v�V�����ɂ��Ă� ((<syck-load>)) ���Q�Ƃ��Ă��������B

--- syck-xyzzy-binding-version

    call-seq:
        (syck-xyzzy-binding-version)  =>  "majar.minor.teeny"

    syck �� xyzzy �o�C���f�B���O (�{���C�u�����̂���) �̃o�[�W������Ԃ��܂��B

    �o�[�W������ major.minor.teeny �Ƃ����`���ł��B
    ���ꂼ��̔ԍ��͕K�� 1 ���ɂ���̂ŁA�ȉ��̂悤�ɔ�r���邱�Ƃ��ł��܂�
    (Ruby �Ɠ����ł� :-)�B

        (if (string<= "1.1.0" (syck-xyzzy-binding-version))
            (1.1.0 �ȍ~�ŗL���ȏ���)
          (1.1.0 ���O�̃o�[�W�����ł̏���))

--- syck-version

    call-seq:
        (syck-version)  =>  "major.minor"

    syck ���̂̃o�[�W������Ԃ��܂��B

--- syck-yaml-version

    call-seq:
        (syck-yaml-version)  =>  "major.minor"

    syck ���������Ă��� YAML �d�l�̃o�[�W�����𕶎���ŕԂ��܂��B
    �o�[�W������ "major.minor" �Ƃ����`���ł��B

--- syck-yaml-major-version

    call-seq:
        (syck-yaml-major-version)  =>  major version number

    syck ���������Ă��� YAML �d�l�̃��W���[�o�[�W�����𐔒l�ŕԂ��܂��B

--- syck-yaml-minor-version

    call-seq:
        (syck-yaml-minor-version)  =>  minor version number

    syck ���������Ă��� YAML �d�l�̃}�C�i�[�o�[�W�����𐔒l�ŕԂ��܂��B

--- syck-yaml-domain

    call-seq:
        (syck-yaml-domain)  =>  "yaml domain"

    syck ���������Ă��� YAML �d�l�̃h���C����Ԃ��܂��B


== LIMITATIONS

* YAML �`���ł� dump �̓T�|�[�g���Ă��܂���B

* map �� default �̓T�|�[�g���Ă��܂���B

  �ȉ��̂悤�� default �l�̎w��͒P���ɖ�������܂��B

    ---
    = : 10
    x : 20
    y : 30

* YPath �̓T�|�[�g���Ă��܂���B

* syck ���T�|�[�g���Ă��� YAML �̃o�[�W������ 1.0 �����ł��B
  �������̃f�[�^�^�͐������F������܂���B


== KNOWN BUGS

* �z�Q�Ƃ��܂� list �� format ���悤�Ƃ���� xyzzy �������܂��B
  �z�Q�Ƃ��܂� YAML �� syck-load �����Ƃ��͒��ӂ��Ă��������B

  �Č��R�[�h (���s����� xyzzy �������܂�)�F

    (setf recursive-node '(1))
    ;; => (1)
    (setf (nth 0 recursive-node) recursive-node)
    ;; => #1=(#1#)
    (format nil "~A" recursive-node)
    ;; => �N���b�V��

  �� xyzzy ���̂̃o�O�ł��B

* ((< syck-parse-error >)) �����������ꍇ content ���s���ɂȂ�ꍇ������܂��B

  �Č��R�[�h�F

    (handler-case
        (syck-load "[1, 2")
      (syck-parse-error (c)
        (syck-parse-error-content c)))

  �� syck ���̂̃o�O�ł��B

* yaml-syck �܂��� syck ���̂̃o�O�ɂ�� xyzzy ���ƃN���b�V������\��������̂�
  auto-save-buffers ���g���Ă��������B�B�B


== TODO

* sexp->yaml �_���v�̃T�|�[�g (emitter)�B
* syck.dll �ŃG���[�ɂȂ��Ă� xyzzy ���Ɨ����Ȃ��悤�ɂ���B
* ���� lisp �����n�̃T�|�[�g�B
* parse ���� Ctrl-g �Ŏ~�߂��悤�ɂ���B
* mingw �ȊO�ŃR���p�C���B
* �o�b�t�@���� load (load-documents :from :buffer)
* �X�g���[������ load-documents :from :stream
* default �̃T�|�[�g (�Ǝ��\����?)
* c-enum �̐���
  * (yaml-syck-ffi::syck-kind-tag-enum-name 4)
    nil
    => range error
  * (yaml-syck-ffi::syck-kind-tag-enum)
    => �p�~
  * (yaml-syck-ffi::syck-kind-tag-enum-name :syck-str-kind)
    nil
    => :syck-str-kind


== AUTHOR

�݂�ނ� ���䂫 (((<URL:mailto:miyamuko (at) gmail.com>)))


== SEE ALSO

  : Rubyist Magazine - �v���O���}�[�̂��߂� YAML ���� (������)
        ((<URL:http://jp.rubyist.net/magazine/?0009-YAML>))

  : ( Syck ): YAML for Ruby, Python, PHP and OCaml
        ((<URL:http://whytheluckystiff.net/syck/>))

  : syck trunk
        ((<URL:http://code.whytheluckystiff.net/syck/browser>))

  : YAML Specification
        ((<URL:http://www.yaml.org/spec/>))

  : YAML Version 1.1
        ((<URL:http://yaml.org/spec/cvs/current.html>))

  : libyaml
        ((<URL:http://pyyaml.org/wiki/LibYAML>))

  : 1 ���ł킩�� YAML �O�j
        ((<URL:http://www.rubycolor.org/maki/d/200305b.html#11_t1>))

  : Perl����/YAML/PyYAML��Perl�ڐA�v���W�F�N�g�i2006.08�j - Walrus, Digit.
        ((<URL:http://digit.que.ne.jp/work/index.cgi?Perl%e3%83%a1%e3%83%a2%2fYAML%2fPyYAML%e3%81%aePerl%e7%a7%bb%e6%a4%8d%e3%83%97%e3%83%ad%e3%82%b8%e3%82%a7%e3%82%af%e3%83%88%ef%bc%882006%2e08%ef%bc%89>))

  : YAML �p�[�T�̃x���`�}�[�N
        ((<URL:http://d.hatena.ne.jp/miyamuko/20070401/>))


== COPYRIGHT

=== yaml-syck (this library)

yaml-syck �� MIT/X ���C�Z���X�ɂ��������ė��p�\�ł��B

See yaml-syck/docs/MIT-LICENSE for full license.

=== syck

syck �� "why the lucky stiff" �ɂ��쐬����A
BSD style ���C�Z���X�Ń����[�X����Ă܂��B

See yaml-syck/docs/COPYING-SYCK for full license.


=== syck.dll

�{���C�u�����ɓ������Ă��� syck.dll ��
((<PySyck|URL:http://pyyaml.org/wiki/PySyck>))
�̍�҂� Kirill Simonov ���ɂ�胊���[�X����Ă���
unofficial ��
((<"syck-0.61+svn231+patches.tar.gz"|URL:http://pyyaml.org/download/pysyck/syck-0.61+svn231+patches.tar.gz>))
�𗘗p���Ă��܂��B


== NEWS

<<<NEWS.rd

=end
