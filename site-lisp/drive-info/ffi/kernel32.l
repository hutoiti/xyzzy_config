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
  GetDriveType ((char *)  ;; lpRootPathName   // ルートディレクトリ
                )
  "kernel32" "GetDriveTypeA")

(c:*define-dll-entry
  BOOL
  GetVolumeInformation (LPCSTR    ;; lpRootPathName,             // ルートディレクトリ
                        LPCSTR    ;; lpVolumeNameBuffer,         // ボリューム名バッファ
                        DWORD     ;; nVolumeNameSize,            // 名前バッファのサイズ
                        (DWORD *) ;; lpVolumeSerialNumber,       // ボリュームのシリアル番号
                        (DWORD *) ;; lpMaximumComponentLength,   // ファイル名の最大の長さ
                        (DWORD *) ;; lpFileSystemFlags,          // ファイルシステムのオプション
                        LPCSTR    ;; lpFileSystemNameBuffer,     // ファイルシステム名を格納するバッファ
                        DWORD     ;; nFileSystemNameSize         // ファイルシステム名を格納するバッファのサイズ
                        )
  "kernel32" "GetVolumeInformationA")

(c:*define-dll-entry
  DWORD
  GetLogicalDrives ()
  "kernel32" "GetLogicalDrives")

(c:*define-dll-entry
  BOOL
  GetDiskFreeSpaceEx (LPCSTR              ;; lpDirectoryName,         // ディレクトリ名
                      (ULARGE_INTEGER *)  ;; lpFreeBytesAvailable,    // 呼び出し側が利用できるバイト数
                      (ULARGE_INTEGER *)  ;; lpTotalNumberOfBytes,    // ディスク全体のバイト数
                      (ULARGE_INTEGER *)  ;; lpTotalNumberOfFreeBytes // ディスク全体の空きバイト数
                      )
  "kernel32" "GetDiskFreeSpaceExA")


(provide "drive-info/ffi/kernel32")

;;; End
