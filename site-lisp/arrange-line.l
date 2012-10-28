;;; -*- Mode: Lisp; Package: USER; Last modified: "2005/03/09 00:07:19"; -*-
;;;
;;; This file is not part of xyzzy.
;;;
;;;   arrange-line.l --- �s�𑵂���
;;;
;;;     by HIE Masahiro <madoinu@ybb.ne.jp>

#|

���T�v

  �s������E�⒆���ɑ����܂��B�c�[���o�[���B


���C���X�g�[��

  1. arrange-line.l �� site-lisp �ɃR�s�[����B

  2. �K�v�ɉ����C�o�C�g�R���p�C������B

       M-x byte-compile-file

  3. .xyzzy �� siteinit.l �Ɉȉ��̋L�q��ǉ�����B

      (require "arrange-line")

  4. xyzzy ���ċN�����C�ݒ�𔽉f������B
     siteinit.l �ɋL�q�����ꍇ�͍ă_���v������B


���A���C���X�g�[��

  1. �c�[���o�[�����폜����B

       M-x arrange-uninstall-tool-bar

  2. �������t�@�C������ݒ���폜����B
     siteinit.l �ɋL�q���Ă����ꍇ�͍ă_���v����B

  3. ���̃t�@�C�� arrange-line.l�i����� arrange-line.lc�j���폜����B


���g����

  �c�[���o�[����g���ɂ́C���j���[��[�\��(V)]��[�c�[���o�[(O)]��
  [arranges(A)] ��I�����܂��B

  ���̑��C

    M-x arrange-left-selection      ; �I��͈͂�������
    M-x arrange-center-selection    ; �I��͈͂𒆉�����
    M-x arrange-right-selection     ; �I��͈͂��E����

  �Ƃ��B


�� ���C�Z���X

  himawari-mode.l �� NYSL Version 0.9982 �ɏ]���܂��B

    NYSL - http://www.kmonos.net/nysl/

  A. �{�\�t�g�E�F�A�� Everyone'sWare �ł��B���̃\�t�g����ɂ�����l��l���A
     �������̍�������̂������̂Ɠ����悤�ɁA���R�ɗ��p���邱�Ƃ��o���܂��B

    A-1. �t���[�E�F�A�ł��B��҂���͎g�p������v�����܂���B
    A-2. �L��������}�̂̔@�����킸�A���R�ɓ]�ځE�Ĕz�z�ł��܂��B
    A-3. �����Ȃ��ނ� ���ρE���v���O�����ł̗��p ���s���Ă��\���܂���B
    A-4. �ύX�������̂╔���I�Ɏg�p�������̂́A���Ȃ��̂��̂ɂȂ�܂��B
         ���J����ꍇ�́A���Ȃ��̖��O�̉��ōs���ĉ������B

  B. ���̃\�t�g�𗘗p���邱�Ƃɂ���Đ��������Q���ɂ��āA��҂�
     �ӔC�𕉂�Ȃ����̂Ƃ��܂��B�e���̐ӔC�ɂ����Ă����p�������B

  C. ����Ґl�i���� HIE Masahiro �ɋA�����܂��B���쌠�͕������܂��B

  D. �ȏ�̂R���́A�\�[�X�E���s�o�C�i���̑o���ɓK�p����܂��B


���X�V����:

  [Version 1.01] 2005-03-09 (Wed)
  �E�������݋֎~�o�b�t�@�ł́C�c�[���o�[�̑��삪�ł��Ȃ��悤�ɁB

  [Version 1.00] 2005-03-08 (Tue)
  �E�������B

|#

(provide "arrange-line")

;;; ������
;;; 0: center, 1:left, 2:right
(defun arrange-center-line (&optional (arg 0))
  (interactive "*")
  (save-excursion
    (goto-bol)
    (delete-region (point)
		   (progn
		     (skip-chars-forward " \t�@")
		     (point)))
    (goto-eol)
    (delete-region (point)
		   (progn
		     (skip-chars-backward " \t�@")
		     (point)))
    (unless (eq arg 1)
      (let ((n (- fill-column (current-column))))
	(when (zerop arg)
	  (setq n (truncate n 2)))
	(when (plusp n)
	  (goto-bol)
	  (or (eolp)
	      (indent-to n)))))
    (untabify (progn (goto-eol) (point))
	      (progn (goto-bol) (point)))))

;;; ����
(defun arrange-left-line ()
  (interactive "*")
  (arrange-center-line 1))

;;; �E��
(defun arrange-right-line ()
  (interactive "*")
  (arrange-center-line 2))


;;; �I��͈͂𒆉���
(defun arrange-center-selection (&optional (arg 0))
  (interactive "*")
  (save-restriction
    (selection-start-end (start end)
      (narrow-to-region start end)
      (goto-char (point-min))
      (while (not (eobp))
	(case arg
	  (0 (arrange-center-line))
	  (1 (arrange-left-line))
	  (2 (arrange-right-line)))
	(goto-bol)
	(unless (forward-line 1)
	  (return))))))

;;; �I��͈͂�����
(defun arrange-left-selection ()
  (interactive "*")
  (arrange-center-selection 1))

;;; �I��͈͂��E��
(defun arrange-right-selection ()
  (interactive "*")
  (arrange-center-selection 2))

(defun arrange-tool-bar-update ()
  (when buffer-read-only :disable))

;;; �c�[���o�[��`
(defun arrange-tool-bar ()
  (create-tool-bar 'arrange-tool-bar
		   (merge-pathnames "toolbar.bmp" (etc-path))
		   '(("������" 33 arrange-left-line arrange-tool-bar-update)
		     ("��������" 35 arrange-center-line arrange-tool-bar-update)
		     ("�E����" 32 arrange-right-line arrange-tool-bar-update))))

;;; �c�[���o�[�o�^
(define-command-bar 'arrange-tool-bar "arranges(&A)")

;;; �c�[���o�[�폜
(defun arrange-uninstall-tool-bar ()
  (delete-command-bar 'arrange-tool-bar))


;;; arrange-line.l �́C�����܂ŁB