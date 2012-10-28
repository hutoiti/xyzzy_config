;; colorprint.l
;;
;; Copyright (c) 2003 kazu.y <samba@pal.tok2.com>
;;
;; �� �T�v
;;   OHKUBO�����buf2html�𗘗p����xyzzy�ŃJ���[������܂��B
;;
;; �� �g����
;;  OHKUBO�����buf2html���C���X�g�[�����܂��B
;;    http://members.at.infoseek.co.jp/ohkubo/index.html
;;  site-lisp�t�H���_��colorprint.l��u���A
;;  .xyzzy �� siteinit.l �Ɉȉ��̃R�[�h��ǉ����܂��B
;;
;;     ; colorprint
;;     (setf *temp-html-file-path* "c:/colorprint.html")
;;     (require "colorprint")
;;
;;  M-x color-print �ŃJ���[����ł���悤�ɂɂȂ�܂��B
;;
;; �� ����
;;  ���s���A*temp-html-file-path*�Ŏw�肵��html�t�@�C���ƁA
;;  *temp-html-file-path*�Ɠ����t�H���_��xyzzy.css��
;;  �������܂��B���łɓ����̃t�@�C��������ꍇ
;;  �㏑������Ă��܂��̂Œ��ӂ��Ă��������B
;;
;; �� ����
;;  2004/01/02 ver.1.01���J
;;    ole���W���[����require���Ă��炸�A�ꕔ�̊��œ����Ȃ����������C���B
;;    ie�I�u�W�F�N�g�����܂ł��������Ɏc���Ă��܂��Ă��������C���B
;;
;;  2003/12/05 ver.1���J
;;


(require "ole")

(defvar *temp-html-file-path* "d:/colorprint.html")
(defvar *print-line-number* nil)
(defvar *print-dialog-title* "���")

(defun make-html (html-path &optional (line-number-p nil))
  (long-operation
    (let ((css-path (merge-pathnames "xyzzy.css" (directory-namestring html-path))))
      (delete-file css-path :if-does-not-exist :skip)
      (ini2css-file (or (and (let ((name (merge-pathnames "xyzzy.ini"
                                                          (user-config-path))))
                               (file-exist-p name) name))
                        ""))
      (set-buffer (find-buffer "*buf2html: CSS*"))
      (rename css-path)
      (save-buffer)
      (delete-buffer (selected-buffer))
      (delete-file html-path :if-does-not-exist :skip)
      (buf2html line-number-p)
      (set-buffer (find-buffer "*buf2html: HTML*"))
      (rename html-path)
      (save-buffer)
      (delete-buffer (selected-buffer)))))

(defun print-html (html-path)
  (let ((ie (ole-create-object "InternetExplorer.Application")))
    #{ie.navigate[html-path]}
    #{ie.document.parentWindow.print}))

(defun color-print ()
  "�J���[�������"
  (interactive)
  (make-html *temp-html-file-path* *print-line-number*)
  (print-html *temp-html-file-path*))