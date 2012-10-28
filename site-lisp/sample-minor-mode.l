(provide "sample-minor-mode")
(defvar *sample-minor-mode* nil)
(in-package "user")
;; �}�C�i�[���[�h�p�̃L�[�}�b�v��ێ�����ϐ���錾
;; (defvar �Ő錾���ꂽ�ϐ��́A�O���[�o���ȃX�y�V�����ϐ��ɂȂ�)

(export '(*sample-minor-mode*
          sample-minor-mode))
;; �錾�����ϐ��ɃL�[�}�b�v���Z�b�g���� (����̓��W���[���[�h�Ɠ���)
;; ���̏����́A1�x�������s�����
(defvar *sample-minor-mode-map* nil)
(defun walk-up ()
  (interactive)
    (or (scroll-window -1)
    (previous-virtual-line 1)
    (goto-line (buffer-lines))))

(defun walk-down ()
  (interactive)
    (let ((goal (goal-column))
          (test (save-window-excursion (scroll-window (window-lines)))))
      (set-goal-column goal)
      (if test
          (scroll-window 1)
        (or (next-virtual-line 1)
            (goto-line 0)))))
(unless *sample-minor-mode-map*
  (setq *sample-minor-mode-map* (make-sparse-keymap))
  (define-key *sample-minor-mode-map* #\h 'previous-buffer)
  (define-key *sample-minor-mode-map* #\j 'walk-down)
  (define-key *sample-minor-mode-map* #\l #'(lambda() (interactive) (if (> (count-windows) 1) (other-window) (next-buffer))))
  (define-key *sample-minor-mode-map* #\k 'walk-up)
  (define-key *sample-minor-mode-map* #\g 'beginning-of-buffer)
  (define-key *sample-minor-mode-map* #\G 'end-of-buffer)
  (define-key *sample-minor-mode-map* #\i 'sample-minor-mode))

;; �}�C�i�[���[�h�̐؂�ւ����s���֐�
(defun sample-minor-mode (&optional (arg nil sv))
  (interactive "p")
  (ed::toggle-mode '*sample-minor-mode* arg sv)
  (update-mode-line t)
  (if *sample-minor-mode*
      (set-minor-mode-map *sample-minor-mode-map*)
    (unset-minor-mode-map *sample-minor-mode-map*))
  t)

;; �}�C�i�[���[�h��L���ɂ������́A���[�h���C���\���̐ݒ�
;; (���̗Ⴞ�ƁA"SampleMinor" �Ƃ��������񂪕\�������悤�ɂȂ�)
(pushnew
 '(*sample-minor-mode* . "SampleMinor") *minor-mode-alist* :key #'car)