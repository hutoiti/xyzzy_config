; -*- Mode: Lisp; Package: editor -*-

#|
= java-scrapbook - Java �̃R�[�h�Ђ����s����

* Author:  miyamuko ((<URL:mailto:miyamuko (at) mtb.biglobe.ne.jp>))
* URL: ((<URL:http://miyamuko.s56.xrea.com/xyzzy/java-scrapbook.html>))
* Version: $Id: java-scrapbook.l,v 1.11 2004/09/13 17:02:06 miyamuko Exp $


== ����

Java �̃R�[�h�Ђ����s���܂��B

������Ƃ����R�[�h�̎��s���ʂ�m�肽���ꍇ�ɕ֗��ł��B
���O������킩��Ƃ��� Eclipse �ɂ��� ScrapBook �̂ς���ł��B

== �ł��邱��

* �ȒP�� Java �\�[�X�𐶐����R���p�C�� �� ���s�ł���B
* import �����w��ł���B
* classpath ���w��ł���B
  * eclipse �� .classpath �ǂݍ��߂�B

== ���ꂩ���邩������Ȃ�����

* ���\�b�h��`
* �N���X��`
* package ���̎w��
* �o�b�t�@����炸�Ɏ��s���ʂ��J�[�\���ʒu�ɑ}������
  * �G���[�ɂȂ�����\������
* ������ jdk ���ȒP�ɐ؂�ւ��\�ɂ���
  * �����R�[�h�𕡐��� jdk �Ŏ��s���Č��ʂ�S���\��
    * ���s���ʂ̓o�[�W�������ƂɃo�b�t�@����邱�Ƃ��ł��� (diff ���₷��)

* package-list ��ǂݍ���Ń��C���h�J�[�h�� import �w��

== �C���X�g�[��

((<NetInstaller|URL:http://www.mirai.ne.jp/~gyo/xyzzy/ni.html>)) �ŃC���X�g�[�������ꍇ�� 3 �ȍ~���A
NetInstaller + (({ni-autoload})) ���g���Ă���l�� 4 �ȍ~�� OK �ł��B

(1) �A�[�J�C�u���_�E�����[�h���܂��B

    ((<URL:http://miyamuko.s56.xrea.com/xyzzy/archives/java-scrapbook.zip>))

(2) �A�[�J�C�u��W�J���āA$XYZZY/site-lisp �z���Ƀt�@�C�����R�s�[���܂��B

(3) ~/.xyzzy �܂��� $XYZZY/site-lisp/siteinit.l �Ɉȉ��̃R�[�h��ǉ����܂��B

        ;; java-scrapbook
        (require "java-scrapbook")

(4) �ݒ�𔽉f�����邽�� xyzzy ���ċN�����Ă��������B

    ��siteinit.l �ɋL�q�����ꍇ�ɂ͍ă_���v���K�v�ł��B

(5) ���s�������R�[�h�Ђ����[�W�����Ŏw�肵�� ((% M-x java-scrapbook-region %))�A
    �܂��� ((% M-x java-scrapbook-oneliner %))�A((% M-x java-scrapbook-display %))
    �Ń~�j�o�b�t�@�����s���͂��Ď��s���܂��B

    ��: �V�X�e���v���p�e�B��\������� (java-scrapbook-oneliner �œ���)�B

        System.getProperties().list(System.out);


== ���t�@�����X

=== �֐�

--- java-scrapbook-current-kill
    kill ring �̕������ java �R�[�h�ЂƂ��Ď��s���܂��B

--- java-scrapbook-clipboard
    �N���b�v�{�[�h�̕������ java �R�[�h�ЂƂ��Ď��s���܂��B

--- java-scrapbook-buffer
    �o�b�t�@�S�̂� Java �R�[�h�����s���܂��B

--- java-scrapbook-region
    ���[�W������ Java �R�[�h�����s���܂��B

--- java-scrapbook-oneliner
    �~�j�o�b�t�@���� Java �̃R�[�h����s���͂��Ď��s���܂��B

--- java-scrapbook-display
    �~�j�o�b�t�@���� Java �̎�����s���͂��Ă��̕]�����ʂ�\�����܂��B

    ���͂����l�͂��̂܂� System.out.println �̈����ɓn���܂��B
    ����ē��͂���̂� Java �̎��ł���K�v������܂��B
    (= �Z�~�R�����͂���Ȃ�)

=== �ϐ�

--- *java-scrapbook-template*
    ��������\�[�X�t�@�C���̃e���v���[�g���w�肵�܂��B

    �e���v���[�g�͈ȉ��̈�����^����� format ����܂��B

    (1) import �錾�̃��X�g

        ((<*java-scrapbook-import-list*>)) �Ŏw�肵�����X�g�ł��B

    (2) �R�[�h�В��ɏ����Ă��� import �錾�̃��X�g

    (3) �N���X��

    (4) ���s���� Java �R�[�h��

--- *java-scrapbook-import-list*
     import �錾�̃��X�g�ł��B

     �f�t�H���g�� Java 1.4 �� java. �Ŏn�܂�
     AWT �� Applet �ȊO�̃p�b�P�[�W�ł��B

     Java 1.2 or 1.3 �𗘗p���Ă���l�͈ȉ��̂悤�ɂ��Ă��������B

         (setf *java-scrapbook-import-list* *java-scrapbook-java1.3-import-list*)

     �V�����ǉ�����ꍇ�͈ȉ��̂悤�ɂ��Ă��������B

        (pushnew "javax.accessibility.*" *java-scrapbook-import-list* :test #'equal)
        (pushnew "javax.crypto.*" *java-scrapbook-import-list* :test #'equal)

--- *java-scrapbook-java1.3-import-list*
--- *java-scrapbook-java1.4-import-list*
    ���ꂼ�� Java 1.2/1.3 �� Java1.4 �� import �錾�̃��X�g�ł��B

--- *java-scrapbook-substitute-alist*
     �������� Java �R�[�h�̒u�����X�g�ł��B

     �f�t�H���g�ł� sout �� serr �����ꂼ��
     System.out.println �� System.err.println �ɒu�������悤��
     �Ȃ��Ă��܂��B

     �V�����ǉ�����ꍇ�͈ȉ��̂悤�ɂ��Ă��������B

         (pushnew '("regexp" . "replacement") *java-scrapbook-substitute-alist*)

     ��:

         (pushnew '("ae" . "assertEquals") *java-scrapbook-substitute-alist*)

--- *java-scrapbook-keep-file-p*
     �������� Java �t�@�C����ۑ��E�폜�����肷��t���O�ł��B

     ���������t�@�C�����폜���Ȃ��Ȃ�ȉ��̂悤�� ((|non-nil|)) ���w�肵�Ă��������B

         (setq *java-scrapbook-keep-file-p* t)

     ������͊��ϐ� ((|%Temp%|)) �z���i���Ԃ�j�� Scrap_�`.book
     �Ƃ����f�B���N�g���ł��B

     �f�t�H���g�� nil �i�폜����j�ł��B

--- *java-scrapbook-source-buffer-name*
--- *java-scrapbook-javac-buffer-name*
--- *java-scrapbook-java-buffer-name*
     ���ꂼ�ꐶ�������\�[�X�R�[�h�A�R���p�C�����ʁA���s���ʂ�
     �������ރo�b�t�@���ł��B

     �f�t�H���g�͂��ׂē����� ((|*Java Scrap*|)) �ł��B

--- *java-scrapbook-java-command*
--- *java-scrapbook-javac-command*

    Java �̎��s�R�}���h�ƃR���p�C���R�}���h���w�肵�܂��B

    ������ȊO���w�肷��ƓK���ɕ�����ɕϊ����܂��B
    �֐����w�肵���ꍇ funcall ����̂œ��I�ɒl��ύX�ł��܂��B

--- *java-scrapbook-before-java-hook*
--- *java-scrapbook-before-javac-hook*

    �Ȃ�ƂȂ��p�ӂ����t�b�N�ł��B
    �v���v���Z�b�T�ɒʂ������Ƃ� ajc �������Ƃ��Ɏg���邩���B

    ���ꂼ�� java �R�}���h�̑O�� javac �R�}���h�̑O��
    (({run-hook-with-args-while-success})) �Ŏ��s���܂��B
    �t�b�N�� ((|nil|)) ��Ԃ��Ƃ��̎��_�ł��ׂĂ̎��s�𒆒f���܂��B

    �t�b�N�̈����͎��̂Ƃ���ł��B

      (1) ���������\�[�X�t�@�C���̐�΃p�X
      (2) �N���X��

--- *java-scrapbook-search-eclipse-classpath-p*

    Eclipse �� .classpath �t�@�C����ǂݍ��ނ��ǂ������w�肵�܂��B
    ((|nil|)) ���w�肵���ꍇ�A�ǂݍ��݂܂���B

    .classpath �̌����̓J�����g�f�B���N�g�������ʂɒT���܂��B

--- *java-scrapbook-classpath*

    �N���X�p�X���w�肵�܂��B
    �f�t�H���g�l�͊��ϐ� CLASSPATH �̒l�ł��B

    ((< *java-scrapbook-search-eclipse-classpath-p* >)) �� ((|non-nil|))
    ���w�肵���ꍇ Eclipse �� .classpath �t�@�C����ǂݍ���ŃN���X�p�X��
    �擪�ɒǉ����܂��B

--- *java-scrapbook-erase-output-buffer*

    javac �R�}���h�� java �R�}���h���s�O�Ƀo�b�t�@�̓��e���폜����ꍇ t
    (�f�t�H���g ((|nil|)))�B


== ���C�Z���X

java-scrapbook �͏C�� BSD ���C�Z���X�Ɋ�Â��ė��p�\�ł��B

  Copyright (C) 2003-2004 MIYAMUKO Katsuyuki. All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  1 Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer as the first lines
    of this file unmodified.

  2 Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
  OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
  SUCH DAMAGE.
|#

(provide "java-scrapbook")
(in-package "editor")

(export '(java-scrapbook-current-kill
          java-scrapbook-clipboard
          java-scrapbook-buffer
          java-scrapbook-region
          java-scrapbook-oneliner
          java-scrapbook-display
          *java-scrapbook-template*
          *java-scrapbook-import-list*
          *java-scrapbook-java1.3-import-list*
          *java-scrapbook-java1.4-import-list*
          *java-scrapbook-substitute-alist*
          *java-scrapbook-keep-file-p*
          *java-scrapbook-source-buffer-name*
          *java-scrapbook-javac-buffer-name*
          *java-scrapbook-java-buffer-name*
          *java-scrapbook-java-command*
          *java-scrapbook-javac-command*
          *java-scrapbook-source-dir*
          *java-scrapbook-search-eclipse-classpath-p*
          *java-scrapbook-classpath*
          *java-scrapbook-erase-output-buffer*
          *java-scrapbook-before-java-hook*
          *java-scrapbook-before-javac-hook*
          ))


;; ----------------------------------------------------------------------
;; Hooks

(defvar *java-scrapbook-before-javac-hook* nil
  "java-scrapbook: �R���p�C���R�}���h�̑O�ɌĂ΂��B
����:
  1. �������� Java �\�[�X�̃t�@�C����
  2. �N���X��
nil ��Ԃ����ꍇ�����ŏ��������f����B")

(defvar *java-scrapbook-before-java-hook* nil
  "java-scrapbook: ���s�R�}���h�̑O�ɌĂ΂��B
����:
  1. �������� Java �\�[�X�̃t�@�C����
  2. �N���X��
nil ��Ԃ����ꍇ�����ŏ��������f����B")

;; ----------------------------------------------------------------------
;; variables

(defvar *java-scrapbook-template*
"~{import ~A; ~}

~{import ~A; ~}

public class ~A {
    public static void main(String[] args) throws Exception {
~A
    }
}
"
  "java-scrapbook: ��������\�[�X�t�@�C���̃e���v���[�g�B
   arguments: (import list) (local import list) class statements")

(defvar *java-scrapbook-java1.3-import-list*
  '("java.beans.*"
    "java.beans.beancontext.*"
    "java.io.*"
    "java.lang.*"
    "java.lang.ref.*"
    "java.lang.reflect.*"
    "java.math.*"
    "java.net.*"
    "java.rmi.*"
    "java.rmi.activation.*"
    "java.rmi.dgc.*"
    "java.rmi.registry.*"
    "java.rmi.server.*"
    "java.security.*"
    "java.security.acl.*"
    "java.security.cert.*"
    "java.security.interfaces.*"
    "java.security.spec.*"
    "java.sql.*"
    "java.text.*"
    "java.util.*"
    "java.util.jar.*"
    "java.util.zip.*")
  "java-scrapbook: Java2 SDK 1.2, 1.3 �� import �錾�̃��X�g")

(defvar *java-scrapbook-java1.4-import-list*
  (append *java-scrapbook-java1.3-import-list*
          '("java.nio.*"
            "java.nio.channels.*"
            "java.nio.channels.spi.*"
            "java.nio.charset.*"
            "java.nio.charset.spi.*"
            "java.util.logging.*"
            "java.util.prefs.*"
            "java.util.regex.*"))
  "java-scrapbook: Java2 SDK 1.4 �� import �錾�̃��X�g")

(defvar *java-scrapbook-import-list*
  *java-scrapbook-java1.4-import-list*
  "java-scrapbook: �\�[�X�𐶐�����Ƃ��� import �錾�̃��X�g")

(defvar *java-scrapbook-substitute-alist*
  '(("\\<sout\\>" . "System.out.println")
    ("\\<serr\\>" . "System.err.println"))
  "java-scrapbook: �u�����X�g")

(defvar *java-scrapbook-keep-file-p* nil
  "java-scrapbook: �������� java �\�[�X�t�@�C�����폜���Ȃ� t")

(defvar *java-scrapbook-source-buffer-name* "*Java Scrap*"
  "java-scrapbook: ���������\�[�X���������ވꎞ�o�b�t�@�̖��O")

(defvar *java-scrapbook-javac-buffer-name* "*Java Scrap*"
  "java-scrapbook: �R���p�C�����ʂ��������ވꎞ�o�b�t�@�̖��O")

(defvar *java-scrapbook-java-buffer-name* "*Java Scrap*"
  "java-scrapbook: ���s���ʂ��������ވꎞ�o�b�t�@�̖��O")

(defvar *java-scrapbook-java-command* "java"
  "java-scrapbook: java �R�}���h")

(defvar *java-scrapbook-javac-command* "javac"
  "java-scrapbook: javac �R�}���h")

(defvar *java-scrapbook-source-dir* nil
  "java-scrapbook: ���������\�[�X�̏o�͐�f�B���N�g���B
   nil ���w�肷��Ɗ��ϐ� %Temp% �𗘗p����B
   ���݂��Ă���f�B���N�g�����w�肷��K�v������B")

(defvar *java-scrapbook-classpath* (si:getenv "CLASSPATH")
  "java-scrapbook: �f�t�H���g�̃N���X�p�X�B
�f�t�H���g�͊��ϐ� CLASSPATH �̒l")

(defvar *java-scrapbook-search-eclipse-classpath-p* t
  "java-scrapbook: eclipse �� .classpath ����������Ȃ� t�B
���݂� directory �����ʂɌ������Ă���")

(defvar *java-scrapbook-erase-output-buffer* nil
  "java-scrapbook: �o�̓o�b�t�@�� javac, java �R�}���h���s�O�� erase-buffer ����Ȃ� t")


(defvar *java-scrapbook-class-name* "Scrap"
  "java-scrapbook: ��������\�[�X�̃N���X��")

(defvar *java-scrapbook-import-regexp* "^import[ \t]+\\([^;]+\\);?$"
  "java-scrapbook: import ���̃p�^�[��")

(defvar *java-scrapbook-temp-buffer-name* "*java scrapbook:temp"
  "java-scrapbook: �ꎞ�o�b�t�@�̖��O")

;; ----------------------------------------------------------------------
;; commands

(defun java-scrapbook-current-kill ()
  "java-scrapbook: kill ring �� java �R�[�h�����s����B"
  (interactive)
  (java-scrapbook (car (ed::current-kill 0))))

(defun java-scrapbook-clipboard ()
  "java-scrapbook: �N���b�v�{�[�h�� java �R�[�h�����s����B"
  (interactive)
  (java-scrapbook (get-clipboard-data)))

(defun java-scrapbook-region ()
  "java-scrapbook: �o�b�t�@�S�̂����s����B"
  (interactive)
  (java-scrapbook-region (point-min) (point-max)))

(defun java-scrapbook-region (start end)
  "java-scrapbook: ���[�W���������s����B"
  (interactive "r")
  (if (< end start) (rotatef start end))
  (java-scrapbook (buffer-substring start end)))

(defun java-scrapbook-oneliner (statement)
  "java-scrapbook: �~�j�o�b�t�@���� Java �̃R�[�h����s���͂��Ď��s����B"
  (interactive "sjava statement: ")
  (java-scrapbook statement))

(defun java-scrapbook-display (expression)
  "java-scrapbook: �~�j�o�b�t�@���� Java �̎�����s���͂��Ă��̕]�����ʂ�\������B"
  (interactive "sjava expression: ")
  (java-scrapbook (concat "System.out.println(" expression ");")))

;;
;; private
;;
(defun java-scrapbook (scrap)
  (let* ((dir (make-temp-file-name "Scrap_" "book" *java-scrapbook-source-dir* t))
         (file (merge-pathnames (concat *java-scrapbook-class-name* ".java") dir))
         (class *java-scrapbook-class-name*))

    (java-scrapbook-save-page file class scrap)
    (unwind-protect
        (and
         (run-hook-with-args-while-success
          '*java-scrapbook-before-javac-hook* file class)
         (zerop (java-scrapbook-execute-scrap
                 (java-scrapbook-command (java-scrapbook-javac-command)
                                         (java-scrapbook-classpath)
                                         file)
                 *java-scrapbook-javac-buffer-name*
                 dir))
         (run-hook-with-args-while-success
          '*java-scrapbook-before-java-hook* file class)
         (zerop (java-scrapbook-execute-scrap
                 (java-scrapbook-command (java-scrapbook-java-command)
                                         (java-scrapbook-classpath)
                                         class)
                 *java-scrapbook-java-buffer-name*
                 dir)))
      (unless *java-scrapbook-keep-file-p*
        (java-scrapbook-delete-directory-recursive dir)))
    ))

(defun java-scrapbook-command (exe classpath arg)
  (let ((cp (string-trim " \t\r\f\n" (or classpath ""))))
    (if (zerop (length cp))
        (format nil "~A ~A" exe arg)
      (format nil "~A -classpath ~A ~A" exe cp arg))))

(defun java-scrapbook-save-page (file class scrap)
  (with-output-to-temp-buffer (*java-scrapbook-source-buffer-name*)
    (insert (java-scrapbook-generate-src class scrap) #\LFD)
    (java-scrapbook-preprocess)
    (set-buffer (find-buffer *java-scrapbook-source-buffer-name*))
    (write-file file)))

(defun java-scrapbook-generate-src (class scrap)
  (multiple-value-bind (local-import rest)
      (java-scrapbook-parse scrap)
    (format nil *java-scrapbook-template*
            *java-scrapbook-import-list* local-import
            class rest)))

;; "foo;\nimport hoge.*;\nbar;\nimport baz.*"
;; => (values "foo;\n\nbar\n" ("hoge.*" "baz.*"))
(defun java-scrapbook-parse (scrap)
  (let (import-list (rest scrap))
    (setf rest (java-scrapbook-gsub *java-scrapbook-import-regexp*
                                    rest #'(lambda (s)
                                             (push (match-string 1) import-list)
                                             "")))
    (values import-list rest)))

(defun java-scrapbook-preprocess ()
  (save-excursion
    (goto-char (point-min))
    (java-scrapbook-substitute-buffer *java-scrapbook-substitute-alist*)))

(defun java-scrapbook-substitute-buffer (sub-alist)
  (when sub-alist
    (save-excursion
      (replace-buffer (caar sub-alist) (cdar sub-alist) :regexp t))
    (java-scrapbook-substitute-buffer (cdr sub-alist))))

(defun java-scrapbook-execute-scrap (command output dir &optional msg)
  (long-operation
    (progn
      (let ((buffer (get-buffer-create output)))
        (set-buffer buffer)
        (when *java-scrapbook-erase-output-buffer*
          (erase-buffer (selected-buffer)))
        (goto-char (point-max))
        (insert (format nil "> ~A~%" command))
        (message "~A" (or msg command))
        (make-process command :output buffer :exec-directory dir)
        (java-scrapbook-wait-for-exit-process (buffer-process buffer))))))

(defun java-scrapbook-wait-for-exit-process (proc &optional (interval 0.1))
  (while (eq (process-status proc) ':run)
    (sit-for interval))
  (process-exit-code proc))

(defun java-scrapbook-javac-command ()
  (java-scrapbook-as-string *java-scrapbook-javac-command*))

(defun java-scrapbook-java-command ()
  (java-scrapbook-as-string *java-scrapbook-java-command*))

;;
;; eclipse classpath
;;

(defun java-scrapbook-classpath ()
  (let ((classpath (list (java-scrapbook-as-string *java-scrapbook-classpath*))))
    (when *java-scrapbook-search-eclipse-classpath-p*
      (setf classpath (append (java-scrapbook-eclipse-classpath-entry
                               (java-scrapbook-eclipse-classpath-file))
                              classpath)))
    (java-scrapbook-join ";" classpath)))

;; <classpathentry kind="lib" path="D:/opt/java/junit3.8.1/junit.jar" sourcepath="D:/opt/java/junit3.8.1/src.jar"/>
;; <classpathentry kind="lib" path="lib/xsdlib.jar"/>
;; <classpathentry kind="output" path="build/classes"/>
(defun java-scrapbook-eclipse-classpath-entry (dot-classpath)
  (unless dot-classpath
    (return-from java-scrapbook-eclipse-classpath-entry))
  (let (buffer result)
    (unwind-protect
        (progn
          (setf buffer (create-new-buffer *java-scrapbook-temp-buffer-name*))
          (set-buffer buffer)
          (insert-file-contents dot-classpath)
          (goto-char (point-min))
          (while (scan-buffer "kind=\"\\(lib\\|output\\)\" +path=\"\\([^\"]+\\)\""
                              :regexp t :tail t)
            (push (match-string 2) result)))
      (delete-buffer buffer))
    ;; map to fullpath
    (mapcar #'(lambda (lib)
                (if (string-matchp "[a-z]:/" lib)
                    lib
                  (merge-pathnames lib (directory-namestring dot-classpath))))
            result)))

(defun java-scrapbook-eclipse-classpath-file
  (&optional (dir (directory-namestring (or (get-buffer-file-name) ""))))
  (when dir
    (if (file-exist-p (merge-pathnames ".classpath" dir))
        (merge-pathnames ".classpath" dir)
      (java-scrapbook-eclipse-classpath-file (java-scrapbook-parent-directory dir)))))

;;
;; util
;;

(defun java-scrapbook-as-string (something)
  (cond ((null something)
         "")
        ((stringp something)
         something)
        ((listp something)
         (format nil "~A" (mapcar #'java-scrapbook-as-string something)))
        ((functionp something)
         (java-scrapbook-as-string (funcall something)))
        ((characterp something)
         (format nil "~A" something))
        (t
         (format nil "~S" something))))

(defun java-scrapbook-gsub (re str fn)
  (unless (and re str)
    (return-from java-scrapbook-gsub str))
  (let ((result))
    (labels ((java-scrapbook-gsub-internal (re str fn start)
               (if (string-match re str start)
                   (progn
                     (push (substring str start (match-beginning 0)) result)
                     (if fn (push (funcall fn (match-string 0)) result))
                     (java-scrapbook-gsub-internal re str fn (match-end 0)))
                 (push (substring str start) result))))
      (java-scrapbook-gsub-internal re str fn 0))
    (format nil "~{~A~}" (reverse result))))

(defun java-scrapbook-parent-directory (dir)
  (multiple-value-bind (result count)
      (substitute-string (map-backslash-to-slash dir) "[^/]+/?$" "")
    (if (or (zerop count)
            (zerop (length result)))
        nil
      result)))

(defun java-scrapbook-delete-directory-recursive (dir)
  (dolist (file (directory dir))
    (if (file-directory-p file)
        (java-scrapbook-delete-directory-recursive file)
      (delete-file (merge-pathnames file dir))))
  (delete-directory dir))

(defun java-scrapbook-join (sep l)
  (format nil (concat "~A~{" sep "~A~}") (car l) (cdr l)))

;;
;; $Id: java-scrapbook.l,v 1.11 2004/09/13 17:02:06 miyamuko Exp $
;;