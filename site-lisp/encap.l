;;; encap.l --- �w�肵���֐��̋@�\��u���������i��񋟂��܂��B
;;
;; $Id: encap.l 102 2005-03-10 14:04:41Z kia $
;;
;;
;;; ����
;;
;; ���̃X�N���v�g���g�p�������ƂŔ����������Q�ɑ΂���ӔC�͕������˂܂��B
;; ���̃X�N���v�g���g�p����O�ɂ́A�K���t�@�C���̃o�b�N�A�b�v�����ȂǁA
;; ������񕜂����i���m�ۂ�����Ŋe���̐ӔC�ɂ����Ďg�p���Ă��������B
;;
;;
;;; �A�h���X
;;
;; kia <meshinsha@yahoo.co.jp>
;; http://www.geocities.jp/kiaswebsite/

(provide "encap")
(in-package "editor")
(export '(encapsulate
          unencapsulate
          encapsulated-p
          basic-definition
          argument-list))

(defvar *encap-hash-table* nil)
(unless *encap-hash-table*
  (setq *encap-hash-table* (make-hash-table :test #'eq)))


;; (encapsulate SYMBOL TYPE BODY)
;;
;; �V���{��SYMBOL�̊֐���`��ۑ����ABODY�Ŏ������V������`�ɒu�������܂��B
;; BODY�͈�̎����A���邢�͎��̃��X�g�ł��BTYPE�͒u�������̎��ʂɎg�p����
;; �邾���̃I�u�W�F�N�g�ŁAeq�Ŕ�r����܂��B�ʏ�͉����K���ȃV���{����n��
;; �Ă����Ηǂ��ł��傤�B
;;
;; �V�����֐��Ƃ���BODY���]�������Ƃ��Aargument-list��basic-definition��
;; ������̋Ǐ��ϐ����o�C���h����܂��Bargument-list�͊֐��ɓn���ꂽ����
;; �����X�g�ɂ������̂ł��Bbasic-definition�́A�V������`�ɒu����������O
;; �̌Â��֐���\���Ă��܂��B
;;
;; ��:
;;     (encapsulate 'c-mode
;;                  'msgbox
;;                  '((interactive)
;;                    (msgbox "c-mode�Ł`���B")
;;                    (apply basic-definition argument-list)))
;;
(defun encapsulate (symbol type body)
  (let ((new-dholder (gensym))
        (new-pholder (gensym))
        (old-def (symbol-function symbol)))
    (setf (symbol-function new-dholder) old-def)
    (setf (get new-pholder 'encap-type) type)
    (setf (get new-pholder 'encap-next) new-dholder)
    (encap-set-pholder new-dholder (encap-get-pholder symbol))
    (encap-set-pholder symbol new-pholder)
    (unless (consp (car body))
      (setq body (list body)))
    (setf (symbol-function symbol)
          `(lambda (&rest
                    argument-list
                    &aux
                    (basic-definition ,#'(lambda (&rest args)
                                           (apply (symbol-function new-dholder) args))))
             ,@body))
    symbol))


;; (unencapsulate SYMBOL TYPE)
;;
;; �V���{��SYMBOL�ɑ΂���encapsulate�������̂ɂ��āA����TYPE�������̂�
;; �����ł��V�������̂��������܂��B
;;
;; �������ׂ����̂�������� nil�A�����łȂ���� t ���Ԃ�܂��B
;;
(defun unencapsulate (symbol type)
  (do ((dholder symbol (encap-next dholder)))
      ((null (encap-get-pholder dholder)) nil)
    (if (eq type (encap-type dholder))
        (let ((next-dholder (encap-next dholder)))
          (setf (symbol-function dholder)
                (symbol-function next-dholder))
          (encap-set-pholder dholder (encap-get-pholder next-dholder))
          (remhash next-dholder *encap-hash-table*)
          (return-from unencapsulate t)))))


;; (encapsulated-p SYMBOL TYPE)
;;
;; �V���{��SYMBOL�ɑ΂��āA����TYPE�����u�����������݂��邩�ǂ����𒲂ׂ܂��B
;;
;; ���݂��Ȃ���� nil�A�����łȂ���� t ���Ԃ�܂��B
;;
(defun encapsulated-p (symbol type)
  (do ((dholder symbol (encap-next dholder)))
      ((null (encap-get-pholder dholder)) nil)
    (if (eq type (encap-type dholder))
        (return-from encapsulated-p t))))


;; PRIVATE

(defun encap-type (dholder)
  (get (encap-get-pholder dholder) 'encap-type))

(defun encap-next (dholder)
  (get (encap-get-pholder dholder) 'encap-next))

(defun encap-get-pholder (dholder)
  (gethash dholder *encap-hash-table*))

(defun encap-set-pholder (dholder pholder)
  (setf (gethash dholder *encap-hash-table*) pholder))

;;; encap.l �͂����܂�