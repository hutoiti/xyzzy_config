;;; -*- mode: lisp; package: drive-info.ffi -*-
;;;
;;; File: drive-info/ffi/kernel32.l
;;;
;;; License:
;;;
;;;   Copyright (c) 2007 MIYAMUKO Katsuyuki.
;;;
;;;   drive-info is released under an MIT license.
;;;   See drive-info/docs/MIT-LICENSE for full license.
;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "drive-info/ffi/package")
  (require "drive-info/ffi/macros")
  (require "drive-info/ffi/types")
  )

(in-package :drive-info.ffi)

(c:*define-dll-entry
  LONG
  GetDriveType ((char *)  ;; lpRootPathName   // ���[�g�f�B���N�g��
                )
  "kernel32" "GetDriveTypeA")

(c:*define-dll-entry
  BOOL
  GetVolumeInformation (LPCSTR    ;; lpRootPathName,             // ���[�g�f�B���N�g��
                        LPCSTR    ;; lpVolumeNameBuffer,         // �{�����[�����o�b�t�@
                        DWORD     ;; nVolumeNameSize,            // ���O�o�b�t�@�̃T�C�Y
                        (DWORD *) ;; lpVolumeSerialNumber,       // �{�����[���̃V���A���ԍ�
                        (DWORD *) ;; lpMaximumComponentLength,   // �t�@�C�����̍ő�̒���
                        (DWORD *) ;; lpFileSystemFlags,          // �t�@�C���V�X�e���̃I�v�V����
                        LPCSTR    ;; lpFileSystemNameBuffer,     // �t�@�C���V�X�e�������i�[����o�b�t�@
                        DWORD     ;; nFileSystemNameSize         // �t�@�C���V�X�e�������i�[����o�b�t�@�̃T�C�Y
                        )
  "kernel32" "GetVolumeInformationA")

(c:*define-dll-entry
  DWORD
  GetLogicalDrives ()
  "kernel32" "GetLogicalDrives")

(c:*define-dll-entry
  BOOL
  GetDiskFreeSpaceEx (LPCSTR              ;; lpDirectoryName,         // �f�B���N�g����
                      (ULARGE_INTEGER *)  ;; lpFreeBytesAvailable,    // �Ăяo���������p�ł���o�C�g��
                      (ULARGE_INTEGER *)  ;; lpTotalNumberOfBytes,    // �f�B�X�N�S�̂̃o�C�g��
                      (ULARGE_INTEGER *)  ;; lpTotalNumberOfFreeBytes // �f�B�X�N�S�̂̋󂫃o�C�g��
                      )
  "kernel32" "GetDiskFreeSpaceExA")


(provide "drive-info/ffi/kernel32")

;;; End