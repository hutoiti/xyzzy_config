;;; encap.l --- 指定した関数の機能を置きかえる手段を提供します。
;;
;; $Id: encap.l 102 2005-03-10 14:04:41Z kia $
;;
;;
;;; 注意
;;
;; このスクリプトを使用したことで発生した損害に対する責任は負いかねます。
;; このスクリプトを使用する前には、必ずファイルのバックアップを取るなど、
;; 原状を回復する手段を確保した上で各自の責任において使用してください。
;;
;;
;;; アドレス
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
;; シンボルSYMBOLの関数定義を保存し、BODYで示される新しい定義に置き換えます。
;; BODYは一つの式か、あるいは式のリストです。TYPEは置き換えの識別に使用され
;; るだけのオブジェクトで、eqで比較されます。通常は何か適当なシンボルを渡し
;; ておけば良いでしょう。
;;
;; 新しい関数としてBODYが評価されるとき、argument-listとbasic-definitionと
;; いう二つの局所変数がバインドされます。argument-listは関数に渡された引数
;; をリストにしたものです。basic-definitionは、新しい定義に置きかえられる前
;; の古い関数を表しています。
;;
;; 例:
;;     (encapsulate 'c-mode
;;                  'msgbox
;;                  '((interactive)
;;                    (msgbox "c-modeで～す。")
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
;; シンボルSYMBOLに対してencapsulateしたものについて、同じTYPEを持つものの
;; うち最も新しいものを取り消します。
;;
;; 取り消すべきものが無ければ nil、そうでなければ t が返ります。
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
;; シンボルSYMBOLに対して、同じTYPEを持つ置き換えが存在するかどうかを調べます。
;;
;; 存在しなければ nil、そうでなければ t が返ります。
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

;;; encap.l はここまで
