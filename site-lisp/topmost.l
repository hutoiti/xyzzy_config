;;; -*- Mode: Lisp; Package: EDITOR -*-
;;; topmost.l --- xyzzy �̍őO�ʕ\���̐ݒ�E����

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Time-stamp: <2005/10/08 10:35:01 +0900>

;;; Commentary:

;; Description:
;;
;;  xyzzy �̍őO�ʕ\���̐ݒ�E�������\�ɂ��܂��B
;;
;;  �c�[���o�[�ɓo�^�����̂ŁA�\����K���Ȉʒu�ɐݒ肵�Ă��������B
;;  �őO�ʕ\���ɐݒ肵���ꍇ�A���[�h���X�� xyzzy �� filer �� xyzzy �̌���
;;  �B��܂��B
;;

;; Installation:
;;
;;      1. �A�[�J�C�u��W�J���� topmost.l �� $XYZZY/site-lisp ��
;;         �R�s�[���܂��B
;;         toolbar-topmost.bmp �� $XYZZY/etc �ɃR�s�[���܂��B
;;
;;      2. �o�C�g�R���p�C�����܂��B
;;
;;              M-x byte-compile-file
;;              Byte compile file: $XYZZY/site-lisp/topmost.l
;;
;;      3. ~/.xyzzy �܂��� $XYZZY/site-lisp/siteinit.l �Ɉȉ��̃R�[�h��
;;         �ǉ����܂��B
;;
;;              (require "topmost")
;;
;;      4. ��L�̐ݒ�𔽉f�����邽�߂ɁAxyzzy ���ċN�����܂��B
;;         siteinit.l �ɋL�q�����ꍇ�� Ctrl �L�[�� Shift �L�[�������Ȃ���
;;         xyzzy ���ċN�����A�_���v�t�@�C�����č\�z���܂��B
;;
;;      5. ���j���[�́u�\���v���u�c�[���o�[�v�ɒǉ�����Ă���
;;         �u�őO�ʕ\���v���`�F�b�N���A�c�[���o�[��\�����܂��B
;;

;; Uninstallation:
;;
;;      1. ESC ESC (ed::topmost-uninstall) �ƃ^�C�v���A
;;         topmost.l �֘A�̏��� xyzzy ����폜���܂��B
;;
;;      2. topmost.l �Ɋւ���L�q���폜���܂��B
;;
;;      3. siteinit.l �ɋL�q���Ă����ꍇ�� Ctrl �L�[�� Shift �L�[������
;;         �Ȃ��� xyzzy ���ċN�����A�_���v�t�@�C�����č\�z���܂��B
;;

;; Setting example:
;;
;;      ;; �L�[�{�[�h�ł̑���ݒ��
;;      (require "topmost")
;;      (global-set-key #\S-C-F9 'topmost-xyzzy)
;;      (set-function-bar-label #\S-C-F9 "top")
;;      (global-set-key #\S-C-F10 'notopmost-xyzzy)
;;      (set-function-bar-label #\S-C-F10 "notop")
;;      (global-set-key #\S-C-F11 'toggle-topmost-xyzzy)
;;      (set-function-bar-label #\S-C-F11 "toggle top")
;;

;; Changes:
;;
;;      Sat, 08 Oct 2005 10:16:16 +0900
;;        �E���[���A�h���X��ύX�B
;;        �E���C�Z���X����(�C��BSD���C�Z���X)���L�ځB
;;
;;      Sat, 12 Jun 2004 23:33:03 +0900
;;        �E�摜�t�@�C���ύX�B
;;        �E�摜�t�@�C�����ύX�B
;;        �ENetInstaller �Ή��B
;;
;;      Tue, 25 Dec 2001 12:00:00 +0900
;;        �E�c�[���o�[������ Tips ����i�グ�B
;;

;; Licence:
;;
;;    topmost �͏C��BSD���C�Z���X�Ɋ�Â��ė��p�\�ł��B
;;    <http://www.opensource.org/licenses/bsd-license.php>
;;
;;
;;    Copyright (C) 2001-2005, OHKUBO Hiroshi.  All rights reserved.
;;
;;    Redistribution and use in source and binary forms, with or without
;;    modification, are permitted provided that the following conditions
;;    are met:
;;
;;    1. Redistributions of source code must retain the above copyright
;;       notice, this list of conditions and the following disclaimer.
;;
;;    2. Redistributions in binary form must reproduce the above copyright
;;       notice, this list of conditions and the following disclaimer in
;;       the documentation and/or other materials provided with the
;;       distribution.
;;
;;    3. Neither the name of the University nor the names of its
;;       contributors may be used to endorse or promote products derived
;;       from this software without specific prior written permission.
;;
;;    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
;;    ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
;;    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
;;    A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
;;    OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
;;    SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
;;    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
;;    DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
;;    THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
;;    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
;;    OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;;

;;; Code:

(provide "topmost")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "wip/winapi"))

(in-package "winapi")

(*define SWP_NOSIZE         #x0001)
(*define SWP_NOMOVE         #x0002)
(*define SWP_NOZORDER       #x0004)
(*define SWP_NOREDRAW       #x0008)
(*define SWP_NOACTIVATE     #x0010)
(*define SWP_FRAMECHANGED   #x0020)
(*define SWP_SHOWWINDOW     #x0040)
(*define SWP_HIDEWINDOW     #x0080)
(*define SWP_NOCOPYBITS     #x0100)
(*define SWP_NOOWNERZORDER  #x0200)
(*define SWP_NOSENDCHANGING #x0400)

(*define SWP_DRAWFRAME      SWP_FRAMECHANGED)
(*define SWP_NOREPOSITION   SWP_NOOWNERZORDER)

(*define SWP_DEFERERASE     #x2000)
(*define SWP_ASYNCWINDOWPOS #x4000)

(*define HWND_TOP        0)
(*define HWND_BOTTOM     1)
(*define HWND_TOPMOST   -1)
(*define HWND_NOTOPMOST -2)

(*define-dll-entry BOOL SetWindowPos (HWND HWND int int int int UINT) "user32")

(*define GWL_WNDPROC     -4)
(*define GWL_HINSTANCE   -6)
(*define GWL_HWNDPARENT  -8)
(*define GWL_STYLE      -16)
(*define GWL_EXSTYLE    -20)
(*define GWL_USERDATA   -21)
(*define GWL_ID         -12)

(*define WS_EX_DLGMODALFRAME  #x00000001)
(*define WS_EX_NOPARENTNOTIFY #x00000004)
(*define WS_EX_TOPMOST        #x00000008)
(*define WS_EX_ACCEPTFILES    #x00000010)
(*define WS_EX_TRANSPARENT    #x00000020)

(*define-dll-entry LONG GetWindowLong (HWND int) "user32" "GetWindowLongA")

(in-package "editor")

(export '(topmost-xyzzy
          notopmost-xyzzy
          topmost-xyzzy-p
          toggle-topmost-xyzzy
          topmost-tool-bar))

(defun topmost-xyzzy ()
  (interactive)
  (winapi::SetWindowPos (get-window-handle) winapi:HWND_TOPMOST 0 0 0 0
                        (logior winapi:SWP_NOSIZE winapi:SWP_NOMOVE winapi:SWP_SHOWWINDOW)))

(defun notopmost-xyzzy ()
  (interactive)
  (winapi::SetWindowPos (get-window-handle) winapi:HWND_NOTOPMOST 0 0 0 0
                        (logior winapi:SWP_NOSIZE winapi:SWP_NOMOVE winapi:SWP_SHOWWINDOW)))

(defun topmost-xyzzy-p ()
  (interactive)
  (if (zerop (logand (winapi::GetWindowLong (get-window-handle) winapi:GWL_EXSTYLE)
                     winapi:WS_EX_TOPMOST))
      nil
    t))

(defun toggle-topmost-xyzzy ()
  (interactive)
  (if (topmost-xyzzy-p)
      (notopmost-xyzzy)
    (topmost-xyzzy)))

;; tool-bar
(defun tool-bar-update-topmost ()
  (and (topmost-xyzzy-p) :check))

(defun topmost-tool-bar ()
  (create-tool-bar
   'topmost-tool-bar
   (merge-pathnames "toolbar-topmost.bmp" (etc-path))
   '(("��Ɏ�O�ɕ\��" 0 toggle-topmost-xyzzy tool-bar-update-topmost))))

(define-command-bar 'topmost-tool-bar "�őO�ʕ\��(&T)")

;; uninstall
(defun topmost-uninstall ()
  (delete-command-bar 'topmost-tool-bar))

;;; topmost.l ends here