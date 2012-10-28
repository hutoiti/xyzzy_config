;;; -*- mode: lisp; package: drive-info.api -*-
;;;
;;; File: drive-info/api/drive-info.l
;;;
;;; License:
;;;
;;;   Copyright (c) 2007 MIYAMUKO Katsuyuki.
;;;
;;;   drive-info is released under an MIT license.
;;;   See drive-info/docs/MIT-LICENSE for full license.
;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "drive-info/api/package")
  (require "drive-info/ffi"))

(in-package :drive-info.api)

(export '(get-drive-info
          get-logical-drives
          get-logical-drive-letters
          get-fixed-logical-drives
          get-fixed-logical-drive-letters
          get-free-logical-drives
          get-free-logical-drive-letters
          drive-exist-p
          get-drive-type
          get-volume-information
          get-disk-free-space
          drive-name
          drive-letter
          ))

(defconstant *drive-type-alist*
  (list (cons DRIVE_NO_ROOT_DIR :no-root-dir)
        (cons DRIVE_REMOVABLE   :removable)
        (cons DRIVE_FIXED       :fixed)
        (cons DRIVE_REMOTE      :remote)
        (cons DRIVE_CDROM       :cdrom)
        (cons DRIVE_RAMDISK     :ramdisk)))

(defconstant *file-system-flags-alist*
  (list (cons FILE_CASE_SENSITIVE_SEARCH   :case-sensitive-search)
        (cons FILE_CASE_PRESERVED_NAMES    :case-preserved-names)
        (cons FILE_UNICODE_ON_DISK         :unicode-on-disk)
        (cons FILE_PERSISTENT_ACLS         :persistent-acls)
        (cons FILE_FILE_COMPRESSION        :file-compression)
        (cons FILE_VOLUME_QUOTAS           :volume-quotas)
        (cons FILE_SUPPORTS_SPARSE_FILES   :supports-sparse-files)
        (cons FILE_SUPPORTS_REPARSE_POINTS :supports-reparse-points)
        (cons FILE_SUPPORTS_REMOTE_STORAGE :supports-remote-storage)
        (cons FILE_VOLUME_IS_COMPRESSED    :volume-is-compressed)
        (cons FILE_SUPPORTS_OBJECT_IDS     :supports-object-ids)
        (cons FILE_SUPPORTS_ENCRYPTION     :supports-encryption)
        (cons FILE_NAMED_STREAMS           :named-streams)
        (cons FILE_READ_ONLY_VOLUME        :read-only-volume)))

(defparameter *get-volume-information-names*
  '(:volume-name
    :volume-serial-number
    :maximum-component-length
    :file-system-flags
    :file-system-name))

(defparameter *get-disk-free-space-names*
  '(:free-bytes-available
    :total-number-of-bytes
    :total-number-of-free-bytes
    :total-number-of-used-bytes
    :free-bytes%
    :used-bytes%))



(defun get-drive-info (root-dir)
  (let ((drive (drive-name root-dir)))
    (when (drive-exist-p drive)
      (list (cons :drive (list (cons :name drive)
                               (cons :type (get-drive-type drive))))
            (cons :volume (get-volume-information drive))
            (cons :space (get-disk-free-space drive))))))

(defun drive-exist-p (root-dir)
  (not (null (member (drive-letter root-dir) (get-logical-drive-letters)
                     :test #'char-equal))))

(defun get-logical-drive-letters ()
  (mapcar #'car (select #'cdr (get-logical-drives0))))

(defun get-logical-drives ()
  (mapcar #'drive-name (get-logical-drive-letters)))

(defun get-free-logical-drive-letters ()
  (mapcar #'car (select #'(lambda (e)
                            (not (cdr e)))
                        (get-logical-drives0))))

(defun get-free-logical-drives ()
  (mapcar #'drive-name (get-free-logical-drive-letters)))

(defun get-fixed-logical-drive-letters ()
  (select #'(lambda (e)
              (eq (get-drive-type e) :fixed))
          (get-logical-drive-letters)))

(defun get-fixed-logical-drives ()
  (mapcar #'drive-name (get-fixed-logical-drive-letters)))

(defun get-logical-drives0 ()
  (let ((bitmap (GetLogicalDrives))
        (A (char-code #\A))
        (Z (char-code #\Z))
        (r))
    (dotimes (i (1+ (- Z A)))
      (push (cons (code-char (+ A i))
                  (not (zerop (logand (ash 1 i) bitmap))))
            r))
    (reverse r)))

(defun get-drive-type (root-dir)
  (let ((type (get-drive-type0 root-dir)))
    (cdr (or (assoc type *drive-type-alist*)
             (cons nil :unknown)))))

(defun get-drive-type0 (root-dir)
  (GetDriveType (make-drive-chunk root-dir)))


(defun get-volume-information (root-dir)
  (let ((info (get-volume-information0 root-dir)))
    (when info
      (setf (cadddr info) (list (map-file-system-flags (cadddr info))))
      (zip *get-volume-information-names* info))))

(defun get-volume-information0 (root-dir)
  (let* ((size 1000)
         (volume-name (si:make-chunk nil size))
         (serial-number (make-DWORD-chunk))
         (max-component (make-DWORD-chunk))
         (file-system-flags (make-DWORD-chunk))
         (file-system-name (si:make-chunk nil size)))
    (when (not (zerop (GetVolumeInformation (make-drive-chunk root-dir)
                                            volume-name size
                                            serial-number
                                            max-component
                                            file-system-flags
                                            file-system-name size)))
      (list (si:unpack-string volume-name 0 size)
            (unpack-DWORD serial-number)
            (unpack-DWORD max-component)
            (unpack-DWORD file-system-flags)
            (si:unpack-string file-system-name 0 size)))))

(defun map-file-system-flags (fs-flags)
  (let ((result))
    (dolist (flag *file-system-flags-alist*)
      (push (cons (cdr flag)
                  (not (zerop (logand fs-flags (car flag)))))
            result))
    (reverse result)))

(defun get-disk-free-space (root-dir)
  (let ((space (get-disk-free-space0 root-dir)))
    (when space
      (let* ((total (cadr space))
             (free (caddr space))
             (used (if (zerop total) 0 (- total free))))
        (zip *get-disk-free-space-names*
             (list (car space)
                   total
                   free
                   used
                   (if (zerop total) 0 (float (* 100 (/ free total))))
                   (if (zerop total) 0 (float (* 100 (/ used total))))))))))

(defun get-disk-free-space0 (root-dir)
  (let ((free-bytes (make-ULARGE_INTEGER))
        (total-bytes (make-ULARGE_INTEGER))
        (total-free-bytes (make-ULARGE_INTEGER)))
    (when (not (zerop (GetDiskFreeSpaceEx (make-drive-chunk root-dir)
                                          free-bytes
                                          total-bytes
                                          total-free-bytes)))
      (list (ULARGE_INTEGER-to-number free-bytes)
            (ULARGE_INTEGER-to-number total-bytes)
            (ULARGE_INTEGER-to-number total-free-bytes)))))


(defun drive-name (drive)
  (when drive
    (format nil "~A:\\" (drive-letter drive))))

(defun drive-letter (drive)
  (when drive
    (cond ((and (characterp drive)
                (alpha-char-p drive))
           (char-upcase drive))
          ((stringp drive)
           (let ((drive (string-upcase drive)))
             (case (length drive)
               (0 nil)
               (1 (drive-letter (elt drive 0)))
               (t (when (eq (elt drive 1) #\:)
                    (drive-letter (elt drive 0)))))))
          ((symbolp drive)
           (drive-letter (string drive))))))


;;;; Util

(defun make-drive-chunk (root-dir)
  (let ((drive (drive-name root-dir)))
    (if drive
        (si:make-string-chunk drive)
      0)))

(defun zip (a b)
  (mapcar #'cons a b))

(defun select (predicate lst)
  (remove-if-not predicate lst))


(provide "drive-info/api/drive-info")

;;; End
