;;; -*- Mode: Lisp; Package: WIN-USER -*-
;;
;; Last updated: <2003/01/19 14:02:48 +0900>
;;
;; Copyright (C) 2002 nonentity <nonentity@anet.ne.jp>
;;
;; based on wip/hellowin.l
;;
;;
;; �N���b�v�{�[�h�Ď��@�\��g�ݍ��ނ��߂̃p�b�P�[�W
;;
;;
;; �y�֐��zadd-clipboard-viewer-hook
;;
;;     �N���b�v�{�[�h�̒��g���ς��������
;;     �Ăяo���ė~�����t�b�N�֐���o�^����B
;;     ����Ɍ����Ȃ� window ����邩������Ȃ��B
;;
;; �y�֐��zdelete-clipboard-viewer-hook
;;
;;     add-clipboard-viewer-hook �œo�^����
;;     �t�b�N�֐���o�^��������B
;;     2�߂̈����� t �Ȃ�(���ꂪ�f�t�H���g)
;;     ����ɍ���������Ȃ� window ����邩������Ȃ��B
;;
;; �y�֐��zclose-clipboard-viewer
;;
;;     ����ɍ���������Ȃ� window �����B
;;     ������ nil �Ȃ�(���ꂪ�f�t�H���g)
;;     window ����Ȃ���������Ȃ��B
;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "wip/winapi"))

(provide "clipview")

;; winapi
(in-package "winapi")

(*define-dll-entry HWND SetClipboardViewer (HWND) "user32")
(*define-dll-entry BOOL ChangeClipboardChain (HWND HWND) "user32")
(*define-dll-entry HWND GetClipboardOwner () "user32")

(*define WM_CREATE #x0001)
(*define WM_DESTROY #x0002)
(*define WM_CLOSE #x0010)
(*define WM_SETTEXT #x000C)
(*define WM_DRAWCLIPBOARD #x0308)
(*define WM_CHANGECBCHAIN #x030D)

(*define WS_DISABLED #x08000000)

(*define SW_HIDE 0)

;; win-user
(in-package "win-user")

(export '(add-clipboard-viewer-hook delete-clipboard-viewer-hook
		  close-clipboard-viewer))

(defconstant clipboard-viewer-class "XyzzyClipboardViewer")

(defvar *ClipboardViewerHandle* 0)
(defvar *NextClipboardViewerHandle* 0)
(defvar *ClipboardViewerHook* nil)

;; ������]������ƁA�ȑO�� RegisterClass ���� WndProc �� GC ����ĂȂ�
;; �Ȃ��Ă��܂��B
;; �Ē�`����ꍇ�� UnregisterClass ���邩�Axyzzy �𗧂����������B
(unless (fboundp 'clipboard-viewer-wndproc)
  (defun-c-callable LRESULT clipboard-viewer-wndproc
					((HWND hwnd) (UINT msg) (WPARAM wparam) (LPARAM lparam))
					(cond ((= msg WM_CREATE)
						   (setq *NextClipboardViewerHandle*
								 (SetClipboardViewer hwnd)))
						  ((= msg WM_CHANGECBCHAIN)
						   (cond ((= *NextClipboardViewerHandle* wparam)
								  (setq *NextClipboardViewerHandle* lparam))
								 ((/= *NextClipboardViewerHandle* 0)
								  (SendMessage *NextClipboardViewerHandle*
											   msg wparam lparam))
								 )
						   (return-from clipboard-viewer-wndproc 0))
						  ((= msg WM_DRAWCLIPBOARD)
						   (editor::run-hooks '*ClipboardViewerHook*)
						   (SendMessage *NextClipboardViewerHandle* msg wparam lparam))
						  ((= msg WM_DESTROY)
						   (ChangeClipboardChain hwnd
												 *NextClipboardViewerHandle*)
						   (setq *ClipboardViewerHandle* 0))
						  ((= msg WM_NCDESTROY)
						   (setq break-loop t))
						  )
					(DefWindowProc hwnd msg wparam lparam)))

(defun add-clipboard-viewer-hook (fn)
  (if (= *ClipboardViewerHandle* 0)
	  (progn
		(let ((wc (make-WNDCLASS)))
		  (setf (WNDCLASS-style wc) (logior CS_HREDRAW CS_VREDRAW))
		  (setf (WNDCLASS-lpfnWndProc wc) #'clipboard-viewer-wndproc)
		  (setf (WNDCLASS-cbClsExtra wc) 0)
		  (setf (WNDCLASS-cbWndExtra wc) 0)
		  (setf (WNDCLASS-hInstance wc) (GetModuleHandle 0))
		  (setf (WNDCLASS-hIcon wc) (LoadIcon 0 (MAKEINTRESOURCE IDI_APPLICATION)))
		  (setf (WNDCLASS-hCursor wc) (LoadCursor 0 (MAKEINTRESOURCE IDC_ARROW)))
		  (setf (WNDCLASS-hbrBackground wc) (+ 1 COLOR_WINDOW))
		  (setf (WNDCLASS-lpszMenuName wc) 0)
		  (setf (WNDCLASS-lpszClassName wc) (si:make-string-chunk clipboard-viewer-class))
		  (RegisterClass wc))
		
		(let ((hwnd (CreateWindow (si:make-string-chunk clipboard-viewer-class)
								  (si:make-string-chunk clipboard-viewer-class)
								  ; WS_OVERLAPPEDWINDOW
								  (logior WS_CHILD WS_DISABLED)
								  CW_USEDEFAULT CW_USEDEFAULT
								  CW_USEDEFAULT CW_USEDEFAULT
								  (editor::get-window-handle)
								  0
								  (GetModuleHandle 0)
								  0)))
		  (setq *ClipboardViewerHandle* hwnd)
		  ; (ShowWindow hwnd SW_SHOW)
		  (ShowWindow hwnd SW_HIDE)
		  (UpdateWindow hwnd)
		  (let ((msg (make-MSG))
				(break-loop nil))
			(declare (special break-loop))
			#|
			;; �����Ń��C�����[�v���܂킵�Ă������񂾂��A
			;; editor���ŉ����o���Ȃ��Ȃ��Ă��܂��̂�
			(while (not break-loop)
			  (GetMessage msg 0 0 0)
			  (TranslateMessage msg)
			  (DispatchMessage msg))
			|#
			))))
  (editor::add-hook '*ClipboardViewerHook* fn)
  )

(defun delete-clipboard-viewer-hook (fn &optional (arg t))
  (editor::delete-hook '*ClipboardViewerHook* fn)
  (if (and arg
		   (= (length *ClipboardViewerHook*) 0)
		   (/= *ClipboardViewerHandle* 0))
	  (SendMessage *ClipboardViewerHandle* WM_CLOSE 0 0))
  )

(defun close-clipboard-viewer (&optional (arg nil))
  (if (or arg
		  (= (length *ClipboardViewerHook*) 0))
	  (progn
		(setq *ClipboardViewerHook* nil)
		(if (/= *ClipboardViewerHandle* 0)
			(SendMessage *ClipboardViewerHandle* WM_CLOSE 0 0)))))

;; ChangeLog
;; 2003-01-19  nonentity  <nonentity@anet.ne.jp>
;;         * *ClipboardViewerHandle* �� xyzzy �� child window ��
;;           �Ȃ�悤�ɂ����B
;;           thanx>���]����
;;         * ���ȏ��ǂ���� ChangeClipboardChain �� WM_DESTROY ��
;;           �󂯂����ɏ�������悤�ɂ����B
;;         * delete-clipboard-viewer-hook �� window ����Ȃ�
;;           �I�v�V������ǉ��B����ɔ�����window �����֐�
;;           close-clipboard-viewer ��ǉ��B
;; 2003-01-02  nonentity  <nonentity@anet.ne.jp>
;;         * �����Ɩ������Ă����T���v�����폜 (^^;;;
;;         * �����������Ă݂�