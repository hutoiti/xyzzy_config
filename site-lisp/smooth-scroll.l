#|

�����C�u�����T�v
�X���[�X�X�N���[���c�[��

http://www2.ocn.ne.jp/~cheerful/script/index.html
TKI

���@�\
�}�ȓ������ɗ͗}���āA�X���[�Y��window�X�N���[�����������܂��B
��ʂ��}�ɕς��悤�ȎG�ȓ����͂Ȃ��A��������ړ��������Ƃ��͑����A�X�N���[���I���ԍۂ͂������X�N���[�����܂��B

FireFox �A�h�I���� �uYet Another Smooth Scrolling�v�ɋ߂��ł��B

���e��

mouse-wheel-handler�̐ݒ��u�������܂��B
default:mouse-wheel-scroll
��    ��    ��
���̃c�[���F my-mouse-scroll

���ˑ��֌W
xyzzy�̕W���@�\�ő��v�Ȃ͂�

���o�b�e�B���O
�z�C�[�� �X�N���[���n�� lisp������Ă���l�͂��̕ϐ����`�F�b�N���Ă݂Ă��������B
�g���Ă�����o�b�e�B���O����̂ŁA���܂����b�s���O���Ă��������B
mouse-wheel-handler

���̕W�����W���[���̏㏑��
"page"���W���[��  "editor"�p�b�P�[�W next-page


���u�����Ď~�܂�Ȃ��Ƃ��A�Ȃ񂩃X�N���[�����Ȃ��Ƃ�
M-x smooth-scroll-reset
�Ɖ����Ə�񂪃��Z�b�g����Ď~�܂�͂�

�ꉞlimit�t���Ă��܂��B


�����Ȃ݂Ƀ}�E�X�̃z�C�[���ݒ�ł�
����windows��9���ݒ肳��Ă��܂��B

���C���X�g�[��

site-lisp/�z���� .l�t�@�C����u��
.xyzzy �� (lood-library "smooth-scroll.l")�Ƃ��邾���B
���Ƃ̓z�C�[���ŃX�N���[�����Ă݂Ă��������B


���J�X�^�}�C�Y�\�ϐ�

*scroll-smoothly-property-list*
�f�t�H���g�ł�4�ݒ�p�^�[�����X�g����`����Ă��܂��B
���ꂼ��̃��X�g�̒��̈Ӗ��͈ȉ��̂Ƃ���

;1.�X���[�X�ɓ������p�x(sec) �������قǂ��傱�܂�
;2.�X�N���[���ʕ���   �傫���قǂ��傱�܂�
;3.�X���[�X�ɓ�����������   �������قǂ��傱�܂�
;4.�X���[�X�ɓ������ŏI��(�Ō�ɃJ�`�b�ƂȂ�)   �������قǂ��傱�܂�
;5.���x�� (���D���Ȃ悤��)


���L�[�ɂ��X�N���[��(�u������)
�ȉ���"page"���W���[����u��������� C-v , M-v , PageDown ,PageUp���X���[�X�ɂȂ�܂��B
ed::next-page �F �u����������Ȃ��l�͏���������Ă��������B

���A���C���X�g�[��
�Ƃ肠�����A��ʓI�ȍ폜�ȊO�ł�

�ȉ��̃X�N���[���̐ݒ��߂��Ă����Ă��������B
(setq-default mouse-wheel-handler 'mouse-wheel-scroll )


������
2010/09/11 ����window���X�N���[������o�O���C��
           �}�E�X�A�N�V�������Ȃ���������popup�����Ȃ��悤�ɂ����B
2010/09/08 window���Ȃ��Ȃ��Ă����̑Ώ���ǉ�
2010/09/06 �s�܂�Ԃ��̎��A�o�E���X���������Ă��܂��o�O�Ή�
�o�b�t�@���؂�ւ�����炷���I���������B
2020/08/16 �����x�ϐ����t���B
2020/08/13 �o�E���X���Ȃ��ϐ����t���B
2020/08/13 �o�E���X������悤�ɂ����B
2020/08/11 �ړ����^�C�v��p�ӂ����B
2020/08/11 �ړ�����ς�����悤�ɂ����B
2020/08/11 �쐬

|#
;--------------------------------------------------------------------------------------------------------

(provide "smooth-scroll")

(require "page")
(require "mouse")

(in-package "editor")

(export '(
          *scroll-smoothly-property-list* *scroll-smoothly-bounce* *scroll-smoothly-accel*
          ;*scroll-smoothly-interval* *scroll-smoothlyness* *scroll-initial-smoothlyness* *scroll-last-smoothlyness*
          my-mouse-scroll smooth-scroll-start smooth-scroll-reset smooth-scroll-property-toggle smooth-scroll-property-print
          ))


;---------------------------------------------
;�����ϐ�(�J�X�^�}�C�Y��)


(defvar *scroll-smoothly-property-list*
  (list '(0.03  8 3 1 'default)
        '(0.02  3 3 2  'speedy)
        '(0.01 12 2 1  'sligtly)
        '(0.3   3 6 3  'clearyView )))
;�����̈Ӗ��͍����珇�ɉ��L�Q��

;��̃��X�g�ŏ㏑������܂��B
;1.�X���[�X�ɓ������p�x(sec) �������قǂ��傱�܂�
;2.�X�N���[���ʕ���   �傫���قǂ��傱�܂�
;3.�X���[�X�ɓ�����������   �������قǂ��傱�܂�
;4.�X���[�X�ɓ������ŏI��(�Ō�ɃJ�`�b�ƂȂ�)   �������قǂ��傱�܂�
;5.���x�� (���D���Ȃ悤��)

;�[�����ɗ����Ƃ��o�E���X�����邩�ǂ���
(defvar *scroll-smoothly-bounce* t)

;�}�E�X������  n�{
(defvar *scroll-smoothly-accel* 1)

;---------------------------------------------
;�����ϐ�
(defvar *scroll-smoothly* 0)
(defvar *scroll-smoothly-window* nil)
(defvar *scroll-smoothly-number* 0)
(defvar *scroll-smoothly-property-type* 0)

;�X���[�X�ɓ������p�x(sec) �������قǂ��傱�܂�
(defvar *scroll-smoothly-interval* 0.03)
;�X�N���[���ʕ���   �傫���قǂ��傱�܂�
(defvar *scroll-smoothlyness* 8)
;�X���[�X�ɓ�����������   �������قǂ��傱�܂�
(defvar *scroll-initial-smoothlyness* 3)
;�X���[�X�ɓ������ŏI��(�Ō�ɃJ�`�b�ƂȂ�)   �������قǂ��傱�܂�
(defvar *scroll-last-smoothlyness* 1);���܂菬�����ƃu���u�����Ď������Ȃ�����
(defvar *scroll-type-label* 'default)

;--------------------------------------------------------------------------------------------------------
;�֐��Q

;����C�x���g�N�����̃X�N���[��������
;(�W���֐��̌`�قڂ��̂܂�)
(defun my-mouse-scroll (window n lines)
  (or lines
      (setq lines (window-lines window)))

  (smooth-scroll-start window (* n lines *scroll-smoothly-accel*))
  (continue-pre-selection)
  t)

;����C�x���g�N����(��L�̃T�u�֐�)
;���ɋN�����Ă��邩�A�w��Ȃ����̏���
(defun smooth-scroll-start (&optional window arg)
  (interactive)

  (if (= 0 *scroll-smoothly*)
      ;timer �N�����Ă��Ȃ�
    (progn
      (setq *scroll-smoothly-number* 0);limitter
      (smooth-scroll window arg)
      ;�����c�肪����
      (if (/= 0 *scroll-smoothly*)
          (progn
            (setq *scroll-smoothly-window* window)
            (start-timer *scroll-smoothly-interval* 'smooth-scroll nil))))
    ;timer �N����
    (progn
      (if (equal *scroll-smoothly-window* window)
          (setq *scroll-smoothly* (+ *scroll-smoothly* arg))))))

;���ۂ̃X�N���[�����������镔��
;(����(smooth-scroll-start)�ƁA�p�����쒆(timer)�ɌĂ΂��)
(defun smooth-scroll (&optional window arg)
  (unless window (setq window *scroll-smoothly-window*))
  (unless arg (setq arg 0))

  ;window���ς�������~
  (if (and *scroll-smoothly-window* 
           (not (eq *scroll-smoothly-window* (selected-window))))
      (progn
       (ignore-errors
        (if (windowp *scroll-smoothly-window*)
         (smooth-scroll-window *scroll-smoothly-window* *scroll-smoothly*)))
        (smooth-scroll-reset)))

  (setq *scroll-smoothly* (+ arg *scroll-smoothly*))

  (let ((cl (current-virtual-line-number)))
    (let ((sc))
      ;scroll size
      (setq sc
            (cond
             ;����
             ((< *scroll-smoothly-number* 2)
              (floor (* (+ (/ *scroll-smoothly-number* 3) *scroll-initial-smoothlyness*) (if (> 0 *scroll-smoothly*) -1 1))))
             ;�r��(�����オ��)
             ((< *scroll-smoothly-number* (/ *scroll-smoothlyness* 2))
              (floor (/ *scroll-smoothly* (+ *scroll-smoothlyness* (/ *scroll-smoothly-number* 3)))))
             ;�r��
             ((> (abs *scroll-smoothly*) *scroll-last-smoothlyness*)
              (floor (/ *scroll-smoothly* *scroll-smoothlyness*)))
             ;�Ō�:�c��S��
             (t  *scroll-smoothly*)))
      (if (= 0 sc) (setq sc (if (> 0 *scroll-smoothly*) -1 1)))

      ;scroll
      (smooth-scroll-window window sc)
      (setq *scroll-smoothly* (- *scroll-smoothly* sc)))

    ;����-------------------------------
    ;limitter
    (setq *scroll-smoothly-number* (+ 1 *scroll-smoothly-number*))
    (if (> *scroll-smoothly-number* 300)
        (let (time-over-sc)
          (setq time-over-sc (* (if (> 0 *scroll-smoothly*) -1 1) (min 3 (abs *scroll-smoothly*))))
          (progn(smooth-scroll-window window time-over-sc)(setq *scroll-smoothly* (- *scroll-smoothly* time-over-sc)))))

    ;�����`�F�b�N
    (if (= 0 *scroll-smoothly*)
        (stop-timer 'smooth-scroll))

    ;���ƒ[�����ɂ���I��[�o�E���X]������Ƃ�
    (if (= cl (current-virtual-line-number))
        (setq *scroll-smoothly*
              (if *scroll-smoothly-bounce*
                  (floor (* *scroll-smoothly*
                            (if (< 0 *scroll-smoothly*) -0.3
                              (if (< *scroll-smoothly* -11) -0.04 -0.2))))
                0))))
  (refresh-screen)
  (continue-pre-selection))


;�X���[�X�X�N���[�����Z�b�^�[
(defun smooth-scroll-reset ()
  (interactive)
  (stop-timer 'smooth-scroll)
  (setq *scroll-smoothly* 0
        *scroll-smoothly-number* 0))

(defun smooth-scroll-window (window size)
  (with-selected-window
    (set-window window)
    (scroll-window size)))

(defun smooth-scroll-property-toggle()
  (interactive)
  (let ((li))
    (setq li (nth *scroll-smoothly-property-type* *scroll-smoothly-property-list*))
    (setq *scroll-smoothly-interval* (first li)
          *scroll-smoothlyness*(second li)
          *scroll-initial-smoothlyness* (third li)
          *scroll-last-smoothlyness*  (fourth li)
          *scroll-type-label* (fifth li))

    (message "smooth scroll property changed[~A]:~A" *scroll-smoothly-property-type* *scroll-type-label*)
    (setq *scroll-smoothly-property-type* (mod (+ 1 *scroll-smoothly-property-type*) (length *scroll-smoothly-property-list*)))))

;���񂾂��Z�b�g����B
(if (not (boundp '*scroll-smoothly-interval*))
    (smooth-scroll-property-toggle))

(defun smooth-scroll-property-print ()
  (interactive)
  (message "smooth scroll property changed[~A]:~A" *scroll-smoothly-property-type* *scroll-type-label*))


;page ���W���[���̒u������

(defun ed::next-page (&optional (arg 1))
  (interactive)
  (cond ((smooth-scroll-start (selected-window)(* (max (if *page-scroll-half-window*
                                                           (truncate (window-height) 2)
                                                         (- (window-height) *next-screen-context-lines*))
                                                       1)
                                                  arg)))
        ((or *page-scroll-keep-window-position*
             (zerop arg)
             (if (plusp arg) (eobp) (bobp)))
         nil)
        (t
         (goto-char (if (plusp arg) (point-max) (point-min))))))


;�����ݒ�(xyzzy����̃C�x���g�N����) ;���܂������Ă��Ȃ�
;(or (boundp 'mouse-wheel-handler)
(setq-default mouse-wheel-handler 'ed::my-mouse-scroll) ;���܂������Ă��Ȃ��B






