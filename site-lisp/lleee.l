;;;
;;;  lleee.l : �����A�K�p�R�}���h
;;;
;;;  written by sugi <y_sugi@anet.ne.jp> (November 16, 2004)

(provide "lleee")

(in-package "editor")

(export '(lleee *lleee-file-name* *lleee-line-num* *lleee-char-num* *lleee-default-tag*))

; �ǂݍ��ރt�@�C����
(defvar *lleee-file-name* "~/lleee.txt")

; �\������s��
(defvar *lleee-line-num* 3)

; 1 �s������̕�����
(defvar *lleee-char-num* 10)

; �擪�ɂ��̕����񂪂���s�����ǂݍ���
(defvar *lleee-default-tag* "LR")

; ���̕������擪�ɂ���s�̓R�����g�Ƃ݂Ȃ�
(defvar *lleee-comment-char* #\#)

; �t�@�C����ǂݍ��݁A������ string �Ƃ��ĕԂ�
; filename:  �ǂݍ��ރt�@�C����
; read-tag: ���̕������擪�ɂ���s�����ǂݍ���
(defun read-kanji (filename read-tag)
  ; filename ���I�[�v��(�ǂݍ���)
  (with-open-file (input_file filename :direction :input)
	; buff: ��s���̃o�b�t�@
	; line_list: ���܂œǂݍ��񂾓��e
	; read-regexp: �}�b�`�����鐳�K�\��
	(let (buff line-list read-regexp)
	  ; ���K�\���𐶐�(�X�y�[�X�܂ł� \1, �X�y�[�X�オ \2 �ɓ���)
	  (setq read-regexp (concat "^\\(.*" read-tag ".*\\) \\(.*\\)"))
	  ; EOF �܂ň�s���ǂݍ���
	  (while (setq buff (read-line input_file nil))
		; read-regexp �Ƀ}�b�`����s�̂ݓǂݍ���(�R�����g�s�͓ǂ܂Ȃ�)
		(if (and (string-match read-regexp buff) (not (eq (char buff 0) *lleee-comment-char*))) 
			;(and 
			; �ǂݍ��񂾃f�[�^��A������(head-str �͍폜����)
			(setq line-list	(concat line-list (string-replace-match buff "\\2")))))
	  ; �󔒂ƃ^�u���폜����
	  (setq line-list
			(remove-if #'(lambda (char) (find char '(#\SPC #\TAB #\�@))) line-list))
	  line-list)))

; ���X�g����A�����_���� pickup-num �̊����𒊏o����
; ���X�g�ɓ����Ă���� pickup-num ��菭�Ȃ����͑S�����o����
; kanji-list: ���̕����񂩂�ǂݍ���
; pickup-num: ���̐��������o����
(defun get-rand-list (kanji-list pickup-num)
  ; ���X�g���Ȃ��Ȃ邩�A�������o���Ȃ��Ă��悢�� nil ��Ԃ�
  (if (or (eq (length kanji-list) 0) (eq pickup-num 0))
	  nil
	; selected-char: ���X�g���烉���_���ɑI�񂾕���
	(let (selected-char)
	  ; ���X�g���烉���_���� 1 �������o
	  (setq selected-char (char kanji-list (random (length kanji-list))))
	  ; ���X�g���璊�o�����������폜
	  (setq kanji-list (delete selected-char kanji-list))
	  ; ���o���������Ǝc�������X�g���烉���_���� pickup-num - 1 ���o�����̂��Ȃ��ĕԂ�
	  (concat (list selected-char) (get-rand-list  kanji-list (1- pickup-num))))))

; ������𐮌`���ăo�b�t�@�ɏ�������
; rand-list: �������ޕ�����
; line-num: ���̍s����������
; char-num: ��s������̕�����
(defun write-kanji (rand-list line-num char-num)
  ; 1 �s���o�b�t�@�ɏ�������
  (dotimes (i line-num)
	(let (current-line start end)
	  ; 1 �s���̊J�n�ʒu�ƏI���ʒu���v�Z����
	  (setq start (* i char-num))
	  ; �I���ʒu�� start ���� char-num ���(���X�g�̏I�[�͒����Ȃ�)
	  (setq end (min (+ start char-num)	(length rand-list)))
	  ; 1 �s�����쐬����
	  (setq current-line (subseq rand-list start end))
	  ; 1 �s�o�b�t�@�ɏ�������
	  (insert (format nil "~A~%~%" current-line))
	  ; ���X�g�̍Ō�܂ŏ�������I��
	  (if (eq end (length rand-list))
		  (return)))))

; �������K�p�R�}���h
; head-str: �擪�����̕�����̍s�̂ݓǂݍ���
; filename: �ǂݍ��ރt�@�C����
; line-num: ���s�o�͂��邩
; char-num: 1 �s�����艽�����o�͂��邩
(defun lleee (read-tag &optional (filename *lleee-file-name*) (line-num *lleee-line-num*) (char-num *lleee-char-num*))
  ; �R�}���h�Ƃ��Ē�`
  (interactive "sread-tag:" :default0 *lleee-default-tag*)
  ; kanji-list: �g�p���銿��������
  (let (kanji-list rand-list)
	; �t�@�C����ǂݍ��݁A�������X�g���擾
	(setq kanji-list (read-kanji filename read-tag))
	;read-tag �ɉ��������ĂȂ���΁A�S�Ă̍s�����
	(if (equal (length read-tag) 0)
		(setq read-tag ".*"))
	; �����̃V�[�h��ݒ�
	(setq *random-state* (make-random-state t))
	; �����_���Ȋ������X�g���擾
	(setq rand-list (get-rand-list kanji-list (* line-num char-num)))
	; �V�����o�b�t�@���쐬����
	(with-output-to-temp-buffer ("*lleee*")
	  ; �o�b�t�@�ɏ�������
	  (write-kanji rand-list line-num char-num)))
  ; �J�[�\�����o�b�t�@�̐擪��
  (goto-char (point-min))
  ; ��s���ɃJ�[�\���ړ�
  (forward-line))