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
  )

(in-package :drive-info.ffi)


(make-c-type-accessor DWORD)

;;;; GetDriveType flags

(c:*define DRIVE_UNKNOWN     #x0)
(c:*define DRIVE_NO_ROOT_DIR #x1)
(c:*define DRIVE_REMOVABLE   #x2)
(c:*define DRIVE_FIXED       #x3)
(c:*define DRIVE_REMOTE      #x4)
(c:*define DRIVE_CDROM       #x5)
(c:*define DRIVE_RAMDISK     #x6)


;;;; GetVolumeInformation flags

(c:*define FILE_CASE_SENSITIVE_SEARCH      #x00000001)
(c:*define FILE_CASE_PRESERVED_NAMES       #x00000002)
(c:*define FILE_UNICODE_ON_DISK            #x00000004)
(c:*define FILE_PERSISTENT_ACLS            #x00000008)
(c:*define FILE_FILE_COMPRESSION           #x00000010)
(c:*define FILE_VOLUME_QUOTAS              #x00000020)
(c:*define FILE_SUPPORTS_SPARSE_FILES      #x00000040)
(c:*define FILE_SUPPORTS_REPARSE_POINTS    #x00000080)
(c:*define FILE_SUPPORTS_REMOTE_STORAGE    #x00000100)
(c:*define FILE_VOLUME_IS_COMPRESSED       #x00008000)
(c:*define FILE_SUPPORTS_OBJECT_IDS        #x00010000)
(c:*define FILE_SUPPORTS_ENCRYPTION        #x00020000)
(c:*define FILE_NAMED_STREAMS              #x00040000)
(c:*define FILE_READ_ONLY_VOLUME           #x00080000)


;;;; ULARGE_INTEGER

(c:*define-c-struct ULARGE_INTEGER
  (DWORD LowPart)
  (DWORD HighPart))

(defun ULARGE_INTEGER-to-number (ularge)
  (logior (ash (ULARGE_INTEGER-HighPart ularge) 32)
          (ULARGE_INTEGER-LowPart ularge)))
(export '(ULARGE_INTEGER-to-number))


(provide "drive-info/ffi/types")

;;; End
