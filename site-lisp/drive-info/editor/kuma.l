;;; -*- mode: lisp; package: editor -*-
;;;
;;; File: drive-info/editor/kuma.l
;;;
;;; License:
;;;
;;;   Copyright (c) 2007 MIYAMUKO Katsuyuki.
;;;
;;;   drive-info is released under an MIT license.
;;;   See drive-info/docs/MIT-LICENSE for full license.
;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "drive-info/api"))

(in-package :editor)

(export '(drive-info-popup-disk-free-space-kuma--))

(defparameter *drive-info-no-such-drive-kuma-template* "
　　　　　 ∩＿＿＿∩
　　　　　 | ノ　 _,　　,_ ヽ　　　　~A~Aクマ――
　　　　　/　　●　　　● |
　　　　 |　　　　( _●_)　 ミ　＿　(⌒)
　　　　彡､　　　|∪|　　ノ
⊂⌒ヽ　/　　　 ヽノ　 ヽ /⌒つ
　 ＼　ヽ　 /　　 　 　　 ヽ　/
　　　＼_,,ノ　　　　　　|､＿ノ ")

(defparameter *drive-info-kuma-template* "
　　　　　　　　　　　　　0　　　　　　　 25　　　　　　　 50　　　　　　　 75　　　　　　100%
　　　　　　　　　　　　　┝━━━━━┿━━━━━┿━━━━━┿━━━━━┥
_　　 ∩＿＿＿∩　　　/)
_　　 | ノ　　　　　 ヽ　 ( i )))
_　　/　　●　　　● | /　/
_　 |　　　　( _●_)　 |ﾉ　/　　　ここクマ――！！
_　彡､　　　|∪|　　　　,/
_ ／＿＿　 ヽノ　　 /´
_(＿＿＿）　　　　 /")

(defparameter *drive-info-kuma-canvas-width* 36)
(defparameter *drive-info-kuma-ruler-offset* 13)

(define-history-variable *drive-info-last-drive* "C:\\")

(defconstant *drive-info-byte-ice-units* '("" "Ki" "Mi" "Gi" "Ti" "Pi" "Ei"))

(defun drive-info-find-unit (n)
  (drive-info-find-unit0 n 1 *drive-info-byte-ice-units*))

(defun drive-info-find-unit0 (n base units)
  (if (or (zerop (floor (/ n base 1024)))
          (null (cdr units)))
      (cons base (car units))
    (drive-info-find-unit0 n (* base 1024) (cdr units))))


(defmacro drive-info-check-argument (arg message)
  `(unless ,arg
     (popup-string (format nil *drive-info-no-such-drive-kuma-template*
                           drive ,message)
                   (point))
     (return-from drive-info-popup-disk-free-space-kuma--)))

(defun drive-info-popup-disk-free-space-kuma-- (root-dir)
  (interactive "sDrive: " :default0 *drive-info-last-drive* :history0 'drive-info)
  (let* ((drive (drive:drive-name root-dir))
         (info (drive:get-drive-info drive))
         (space (cdr (assoc :space info))))
    (flet ((make-ws (w)
             (make-sequence 'string w :initial-element #\　)))
      (drive-info-check-argument info "ドライブなんて存在しない")
      (drive-info-check-argument space "ドライブにディスクが入っていない")
      (setf *drive-info-last-drive* drive)
      (let* ((free-size (cdr (assoc :total-number-of-free-bytes space)))
             (total-size (cdr (assoc :total-number-of-bytes space)))
             (free% (cdr (assoc :free-bytes% space)))
             (w (floor (* *drive-info-kuma-canvas-width* (/ free% 100))))
             (unit (drive-info-find-unit total-size))
             (kuma))
        (setf kuma (substitute-string
                    *drive-info-kuma-template*
                    "^_" (make-ws w)))
        (setf kuma (substitute-string
                    kuma
                    (concat "^" (make-ws (min w *drive-info-kuma-ruler-offset*)))
                    ""))
        (setf kuma (concat (format nil "~Aドライブのディスク空き容量は ~1,F~AB/~1,F~AB (~1,F%) だクマ――"
                                   drive
                                   (/ free-size (car unit))
                                   (cdr unit)
                                   (/ total-size (car unit))
                                   (cdr unit)
                                   free%)
                           kuma))
        (popup-string kuma (point))))))


(provide "drive-info/editor/kuma")

;;; End
