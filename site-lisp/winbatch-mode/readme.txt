;;;
;;;  winbatch-mode.l
;;;      Simple mode for Batch File Enhancer for Windows (WinBatchEh)
;;;

��������������������������������������������������������������
�� �͂��߂�
��������������������������������������������������������������

����́Axyzzy �œ��삷�� WinBatchEh �p�̃��[�h�ł��B OHKUBO 
Hiroshi ����� bat-mode.l ���n�߁A�����̕��X�̃R�[�h���Q�l�ɂ�
���Ă��������܂����B���ӁB

WinBatchEh ����� WBATCP �́A���� �m������̃y�[�W
(http://hp.vector.co.jp/authors/VA000007/) ����ʓr���艺�����B
�Ȃ��Ă������܂����A���R�X�N���v�g�̎��s�͂ł��܂���B


��������������������������������������������������������������
�� �͂��߂� xyzzy �����������
��������������������������������������������������������������

��������������������������������
�� xyzzy �̃C���X�g�[��
��������������������������������

�Ƃ肠�����g���̂ł���΁A�ȉ��̎菇�ŗǂ��Ǝv���܂��B

xyzzy ����X�N���v�g�����s����ꍇ�́A���炩���� .btw �̊֘A�t
�����s���Ă����ĉ������B

  1. �T�䂳��̃y�[�W (http://www.jsdlab.co.jp/~kamei/) ����   
     xyzzy ���_�E�����[�h����B
  
  2. �K���ȃt�H���_�� xyzzy-version.lzh ��W�J����B
  
  3. ���ϐ� XYZZYHOME �ɃC���X�g�[�������t�H���_��ݒ肷��B
  
     Win98 �̏ꍇ�AC:\AUTOEXEC.BAT �ɁA�ȉ��̍s��ǉ�����B
  
       set XYZZYHOME=C:\utility\xyzzy
       (C:\utility\xyzzy �ɃC���X�g�[�������ꍇ)
       
     WinNT �̏ꍇ�A�R���g���[���p�l�����u�V�X�e���v���u���v
     �Őݒ�B
     
     Win2k �̏ꍇ�A�R���g���[���p�l�����u�V�X�e���v���u�ڍׁv
     ���u���ϐ��v�Őݒ�B

�ڂ����́AToy ����̃y�[�W (http://www.carabiner-systems.com/xyzzy/) 
�Ȃǂ��Q�l�ɂ��ĉ������B


��������������������������������
�� winbatch-mode �̃C���X�g�[��
��������������������������������

  1. winbatch-mode.l �� ~/site-lisp �ɁAWINBATCH �� ~/etc ��
     �R�s�[����B
     
     xyzzy �� c:\utility\xyzzy �ɃC���X�g�[�������ꍇ�́A
     
       winbatch-mode.l �� c:\utility\xyzzy\site-lisp
       WINBATCH        �� c:\utility\xyzzy\etc
       
     �ɃR�s�[����B

  2. xyzzy ���C���X�g�[�������t�H���_�� .xyzzy �Ƃ����t�@�C��
     ���ȉ��̓��e�ō쐬����B(��)
       
       ;;; -*- Mode: Lisp -*-
       
       ;; winbatch-mode
       (export 'ed::winbatch-mode "ed")
       (autoload 'winbatch-mode "winbatch-mode" t)
       (pushnew '("\\.btw$" . winbatch-mode) *auto-mode-alist* :test 'equal)
       
       ;; �⊮���|�b�v�A�b�v�ꗗ�\��
       (setq *popup-completion-list-default* :always)
  
  3. xyzzy ���ċN������B
  
  (��) Explorer ����́A.xyzzy �Ƃ����t�@�C�����쐬���邱�Ƃ�
  �ł��Ȃ����߁A�芵�炵�� xyzzy ����쐬����Ɨǂ������B

�g���q .btw �� winbat32.exe �Ɋ֘A�t�����ĂȂ��ꍇ�A�������́A
winbatch-mode ����X�N���v�g�̋N�����ł��Ȃ��ꍇ�́A.xyzzy �ɁA
�ȉ��̋L�q���ǉ����ĉ������B

�ȉ��́Ac:\utility\winbatch\ �ɃC���X�g�[�����Ă���ꍇ

       ;; WinBatchEh �̃C���X�g�[���f�B���N�g��
       (setq ed::*winbatch-path* "c:/utility/winbatch/")


��������������������������������
�� winbatch-mode �̎g����
��������������������������������

�g���q���A.btw �ȃt�@�C���� xyzzy �ŊJ���ƁA�����I�� 
winbatch-mode ���N�����܂��B

�����ňӐ}�I�� winbatch-mode �ɂ������ꍇ�́A

  1. Esc x  �i����Ɖ��� M-x: �ƕ\������܂��j
  2. winbatch-mode �Ɠ��͂��AEnter

�� winbatch-mode �ɂȂ�܂��B

�K�v�ȑ���́A�Ƃ肠���� WinBatchEh(B) ���j���[����s���ĉ������B


��������������������������������
�� xyzzy �̃J�X�^�}�C�Y
��������������������������������

xyzzy �́AEmacs ���C�N�ȃL�[�o�C���h�Ȃ̂ŁA��������Ȃ����́A
.xyzzy �ȉ���ǋL���邱�Ƃɂ��AWindows ���ȃL�[�o�C���h�ɂ�
�邱�Ƃ��ł��܂��B

  (load-library "Gates")

�������A���̐ݒ������ƁAxyzzy �Ŏg���鑽���֗̕��ȃL�[����
��Ă��܂����߁AC-c, C-x, C-v, C-z �̂� Windows ���ɂ��邽�߂�
�ȉ��̂悤�Ȑݒ�����邱�Ƃ��ł��܂��B�i������̂ق������X�X���j

  (load-library "winkey")

���̐ݒ�ł́A�Z���N�V����������΁i�}�E�X�ȂǂŃn�C���C�g�\��
���ꂽ�����������ԁjC-c �ŃR�s�[�AC-x �Ő؂���ƂȂ�܂��B


��������������������������������
�� ���̑�
��������������������������������

���̑��̏��ɂ��ẮAwinbatch-mode.l �̃R�����g�Ȃǂ����Q��
�������B



��������������������������������������������������������������
HIE Masahiro <madoinu@ybb.ne.jp>
