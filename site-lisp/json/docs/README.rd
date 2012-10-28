= json - ���S�ō����� JSON �p�[�T

  * Author: �݂�ނ� ���䂫 ((<URL:mailto:miyamuko@gmail.com>))
  * Home URL: ((<URL:http://miyamuko.s56.xrea.com/xyzzy/json/intro.htm>))
  * Version: 0.1.2


== SYNOPSIS

  (require "json")
  (use-package :json)

  (json-decode
   "{\"title\":\"\\u306f\\u3066\\u306a\\u30b9\\u30bf\\u30fc\\u65e5\\u8a18\",
     \"uri\":\"http://d.hatena.ne.jp/hatenastar/\",
     \"star_count\":\"75630\"}")
  ;;=> (("title" . "�͂ĂȃX�^�[���L")
  ;;    ("uri" . "http://d.hatena.ne.jp/hatenastar/")
  ;;    ("star_count" . "75630"))

  (json-decode
   (xhr-get (concat "http://api.awasete.com/showjson.phtml?u="
                    (si:www-url-encode "http://blog.myrss.jp/"))
            :key 'xhr-response-text)
   :strict nil)
  ;;=> ((("title" . "CSS HappyLife")
  ;;     ("url" . "http://css-happylife.com/")
  ;;     ("favicon" . "http://faviapi.sidetools.com/?url=http%3A%2F%2Fcss-happylife.com%2F&c=4c8a5890")
  ;;     ("navigation" . "http://awasete.com/bar.phtml?u=http%3A%2F%2Fcss-happylife.com%2F&p=http%3A%2F%2Fblog.myrss.jp%2F")
  ;;     ("more" . "http://awasete.com/show.phtml?u=http%3A%2F%2Fcss-happylife.com%2F"))
  ;;    (("title" . "���`�x�[�V�����͊y�����n������")
  ;;     ("url" . "http://d.hatena.ne.jp/favre21/")
  ;;     ("favicon" . "http://faviapi.sidetools.com/?url=http%3A%2F%2Fd.hatena.ne.jp%2Ffavre21%2F&c=e1c17aea")
  ;;     ("navigation" . "http://awasete.com/bar.phtml?u=http%3A%2F%2Fd.hatena.ne.jp%2Ffavre21%2F&p=http%3A%2F%2Fblog.myrss.jp%2F")
  ;;     ("more" . "http://awasete.com/show.phtml?u=http%3A%2F%2Fd.hatena.ne.jp%2Ffavre21%2F"))
  ;;    ;; �ȗ�
  ;;    )


== DESCRIPTION

json �� xyzzy Lisp �݂̂Ŏ������� JSON �p�[�T�ł��B
json-syck ��荂���ł��O�����C�u�����𗘗p���Ă��Ȃ��̂ň��S�i�N���b�V�����邱�Ƃ��Ȃ��j�ł��B

json �̓��C�u�����ł��B
�A�v���P�[�V�����͈ȉ��̃R�[�h��ǉ����邱�Ƃ� json �𗘗p���邱�Ƃ��ł��܂��B

  (in-package :you-awesome-app)
  (require "json")
  (use-package :json)

  (your beautiful code)


== INSTALL

=== NetInstaller �ŃC���X�g�[��

(1) ((<NetInstaller|URL:http://www7a.biglobe.ne.jp/~hat/xyzzy/ni.html>))
    �� json ���C���X�g�[�����܂��B

=== NetInstaller ���g�킸�ɃC���X�g�[��

(1) �A�[�J�C�u���_�E�����[�h���܂��B

    ((<URL:http://miyamuko.s56.xrea.com/xyzzy/archives/json.zip>))

(2) �A�[�J�C�u��W�J���āA$XYZZY/site-lisp �z���Ƀt�@�C�����R�s�[���܂��B


== MODULE

=== DEPENDS

�ˑ����C�u�����͂���܂���B


=== PACKAGE

json �͈ȉ��̃p�b�P�[�W�𗘗p���Ă��܂��B

  * json


=== VARIABLE

�Ȃ��B


=== CONSTANT

�Ȃ��B


=== CODITION

--- json:json-simple-error

    json-parse-error, json-argument-error �̐e�R���f�B�V�����ł��B

    ���̃R���f�B�V�������̂��ʒm����邱�Ƃ͂���܂���B

--- json:json-parse-error

    �s���� json text ���w�肵���ꍇ�ɒʒm������O�ł��B

--- json:json-argument-error

    json-decode �ɕs���Ȉ������w�肵���ꍇ�ɒʒm������O�ł��B


=== COMMAND

�Ȃ��B

=== FUNCTION

--- json:json-decode JSON-TEXT &REST OPTIONS

    JSON �e�L�X�g��ǂݍ��� S ���ɕϊ����܂��B

    * JSON-TEXT �ɂ� JSON �𕶎���Ŏw�肵�܂��B
    * ������ȊO���w�肵���ꍇ�� type-error ��O��ʒm���܂�
    * ���� OPTIONS �̓p�[�T�I�v�V�������w�肵�܂��B
      �p�[�T�I�v�V������ �L�[���[�h���X�g�Ŏw�肵�܂��B

    �ȉ��̃I�v�V�������w��\�ł��B

    * ((< strict >))
    * ((< json-null >))
    * ((< json-true >))
    * ((< json-false >))
    * ((< json-array >))
    * ((< json-object >))
    * ((< hash-table-test >))

    : strict
        ������ JSON ���p�[�X���邩�ǂ����w�肵�܂��B

        * strict �� non-nil �Ȃ� RFC �ɏ������Č����Ƀp�[�X���܂��B
        * strict �� nil �Ȃ�ȉ��̂悤�� RFC �ɏ������Ă��Ȃ� JSON ���󂯕t���܂��B
          * �N�H�[�g����Ă��Ȃ�������
              (json-decode "{lang:lisp}" :strict t)
              ;;=> json parse error: bare word not allowed.
              (json-decode "{lang:lisp}" :strict nil)
              ;;=> (("lang" . "lisp"))
          * �V���O���N�H�[�g�ň͂܂ꂽ������
              (json-decode "{'lang':'lisp'}" :strict t)
              ;;=> json parse error: single quoted string not allowed.
              (json-decode "{'lang':'lisp'}" :strict nil)
              ;;=> (("lang" . "lisp"))
          * Objects, Arrays �̍Ō�ɗ]�v�ȃJ���}
              (json-decode "{\"lang\":[\"lisp\",\"ruby\",],}" :strict t)
              ;;=> json parse error: unexpected ']', expecting json value.
              (json-decode "{\"lang\":[\"lisp\",\"ruby\",],}" :strict nil)
              ;;=> (("lang" "lisp" "ruby"))
          * �g�b�v���x���� Objects, Arrays �̎��ӂɃS�~������
              (json-decode "JSONP({\"lang\":\"lisp\"})" :strict t)
              ;;=> json parse error: bare word not allowed.
              (json-decode "JSONP({\"lang\":\"lisp\"})" :strict nil)
              ;;=> (("lang" . "lisp"))
          * �g�b�v���x���� Objects, Arrays �ȊO�ł��󂯕t����
              (json-decode "true" :strict t)
              ;;=> json parse error: unexpected bare word, expecting object or array.
              (json-decode "true" :strict nil)
              ;;=> t
              (json-decode "\"hoge\"" :strict t)
              ;;=> json parse error: unexpected string, expecting object or array.
              (json-decode "\"hoge\"" :strict nil)
              ;;=> "hoge"

        �f�t�H���g�� t �ł��B

    : json-null
        JSON �� null �ɑΉ����� lisp �̒l���w�肵�܂��B

        �f�t�H���g�l�� nil �ł��B

          (json-decode "{\"name\": null}" :json-null :NULL)
          ;; => (("name" . :NULL))

    : json-true
        JSON �� true �ɑΉ����� lisp �̒l���w�肵�܂��B

        �f�t�H���g�l�� t �ł��B

          (json-decode "{\"xyzzy\": true}" :json-true :TRUE)
          ;; => (("xyzzy" . :TRUE))

    : json-false
        JSON �� false �ɑΉ����� lisp �̒l���w�肵�܂��B

        �f�t�H���g�l�� nil �ł��B

          (json-decode "{\"xyzzy\": false}" :json-false :FALSE)
          ;; => (("xyzzy" . :FALSE))

    : json-array
        JSON �� Arrays �̃}�b�s���O���@���w�肵�܂��B

        * ������ :list �܂��� :array ���w�肵�܂��B
        * :list ���w�肵���ꍇ�̓��X�g�Ƀ}�b�s���O���܂��B
        * :array ���w�肵���ꍇ�͔z��Ƀ}�b�s���O���܂��B

        �f�t�H���g�l�� :list �ł��B

          (json-decode "[1, 2, 3]" :json-array :list)
          ;; => (1 2 3)

          (json-decode "[1, 2, 3]" :json-array :array)
          ;; => #(1 2 3)

    : json-object
        JSON �� Objects �̃}�b�s���O���@���w�肵�܂��B

        * ������ :alist �܂��� :hash-table ���w�肵�܂��B
        * :alist ���w�肵���ꍇ�͊֘A���X�g�Ƀ}�b�s���O���܂��B
        * :hash-table ���w�肵���ꍇ�� hashtable �Ƀ}�b�s���O���܂��B

        �f�t�H���g�l�� :alist �ł��B

          (json-decode "{\"xyzzy\": \"common lisp\", \"emacs\": \"emacs lisp\"}" :json-object :alist)
          ;; => (("xyzzy" . "common lisp") ("emacs" . "emacs lisp"))

          (setf h (json-decode "{\"xyzzy\": \"common lisp\", \"emacs\": \"emacs lisp\"}" :json-object :hash-table))
          ;; => #<hashtable 52893588>
          (gethash "xyzzy" h)
          ;; => "common lisp"
          ;;    t
          (gethash "emacs" h)
          ;; => "emacs lisp"
          ;;    t

        ((<hash-table-test>)) ���Q�Ƃ��Ă��������B

    : hash-table-test
        hash-table �̃e�X�g�֐����w�肵�܂��B

        * ((<json-object>)) �� :hash-table ���w�肵���Ƃ��̂ݗL���ȃI�v�V�����ł��B
        * �w��\�Ȋ֐��� eq, eql, equal, equalp �ł��B

        �f�t�H���g�� equal �ł��B

          (setf h (json-decode "{\"name\": \"hogehoge\"}" :json-object :hash-table))
          ;; => #<hashtable 52893564>
          (hash-table-test h)
          ;; => equal
          (gethash "name" h)
          ;; => "hogehoge"
          ;;    t
          (gethash "NaME" h)
          ;; => nil
                nil

          (setf h (json-decode "{\"name\": \"hogehoge\"}" :json-object :hash-table :hash-table-test #'equalp))
          ;; => #<hashtable 52893180>
          (hash-table-test h)
          ;; => equalp
          (gethash "name" h)
          ;; => "hogehoge"
          ;;    t
          (gethash "NaME" h)
          ;; => "hogehoge"
          ;;    t

--- json:json-decode-file FILENAME &REST OPTIONS

    �w�肳�ꂽ�t�@�C������ JSON �����[�h���܂��B

    OPTIONS �̎w����@��
    ((<json-decode|json:json-decode JSON-TEXT &REST OPTIONS>))
    ���Q�Ƃ��Ă��������B

--- json:json-version

    �{���C�u�����̃o�[�W������Ԃ��܂��B
    �o�[�W������ major.minor.teeny �Ƃ����`���ł��B

    ���ꂼ��̔ԍ��͕K�� 1 ���ɂ���̂ŁA�ȉ��̂悤�ɔ�r���邱�Ƃ��ł��܂��B

        (if (string<= "1.1.0" (json:json-version))
            '(1.1.0 �ȍ~�ŗL���ȏ���)
          '(1.1.0 ���O�̃o�[�W�����ł̏���))

=== MACRO

�Ȃ��B


== TODO

* �G���[���b�Z�[�W�ɍs���E�J��������\��
* strict ���ׂ����w��
  * single-quote-allowed
  * bare-word-allowed
  * extra-comma-allowed
  * padding-allowed (junk-allowed)
* emitter
* json path
* json-decode-from-stream
* ����ɍ�����


== KNOWN BUGS

* ����Ȑ��l�͈����܂���B

    (json:json-decode "[23456789012E666]")
    ;;=> json parse error: invalid number: "23456789012E666" (�I�[�o�[�t���[���܂���)


== AUTHOR

�݂�ނ� ���䂫 (((<URL:mailto:miyamuko@gmail.com>)))


== SEE ALSO

  : JSON �̏Љ�
      ((<URL:http://www.json.org/json-ja.html>))

  : RFC 4627 The application/json Media Type for JavaScript Object Notation (JSON)
      ((<URL:http://tools.ietf.org/html/rfc4627>))

  : Introducing json.el
      ((<URL:http://emacsen.org/2006/03/26-json>))

  : CL-JSON A JSON parser and generator in Common-Lisp.
      ((<URL:http://common-lisp.net/project/cl-json/>))


== COPYRIGHT

json �� MIT/X ���C�Z���X�Ɋ�Â��ė��p�\�ł��B

See json/docs/MIT-LICENSE for full license.


== NEWS

<<<NEWS.rd
