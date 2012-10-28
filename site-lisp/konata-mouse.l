;;; -*- Mode: Lisp -*-
;;; konata-mouse.l --- �K���ȃ}�E�X�J�[�\���ړ�

;; Copyright (C) 2001 OHKUBO Hiroshi <konata_o@hotmail.com>

;; Author: OHKUBO Hiroshi <konata_o@hotmail.com>
;; Time-stamp: <2001/12/21 02:42:37 +0900>

;;; Code:

(provide "konata-mouse")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "wip/winapi"))

(in-package "winapi")

(*define-dll-entry int GetWindowRect (HWND (RECT *)) "user32")
(*define-dll-entry BOOL SetCursorPos (int int) "user32")
(*define-dll-entry BOOL GetCursorPos ((POINT *)) "user32")

(in-package "win-user")

(export '(over-client-cursor-p
          over-client-point-p
          move-cursor-window-lt
	  move-cursor-window-lt2
          move-hindrance-cursor-window-lt
          move-hindrance-cursor-desktop-corner
          move-hindrance-cursor-window-outside))

(defun over-client-cursor-p ()
  "�}�E�X�J�[�\���� xyzzy ��ɂ��邩"
  (let ((cp (make-POINT)))
    (GetCursorPos cp)
    (over-client-point-p (POINT-x cp) (POINT-y cp))))

(defun over-client-point-p (x y)
  "�|�C���g (x y) �� xyzzy ��ɂ��邩"
  (let ((wr (make-RECT)))
    (GetWindowRect (ed:get-window-handle) wr)
    (if (and (<= (RECT-left wr) x)
             (>= (RECT-right wr) x)
             (<= (RECT-top wr) y)
             (>= (RECT-bottom wr) y))
        t
      nil)))

(defun move-cursor-window-lt ()
  "�}�E�X�J�[�\���� xyzzy �̍�����Ɉړ�"
  (ed:interactive)
  (let ((wr (make-RECT)))
    (GetWindowRect (ed:get-window-handle) wr)
    (SetCursorPos (RECT-left wr) (RECT-top wr))))

(defun move-cursor-window-lt2 ()
  "�}�E�X�J�[�\���� xyzzy �̍�����Ɉړ�"
  (ed:interactive)
  (let ((wr (make-RECT)))
    (GetWindowRect (ed:get-window-handle) wr)
    (SetCursorPos (RECT-left wr) (RECT-bottom wr))))

(defun move-hindrance-cursor-window-lt ()
  "�}�E�X�J�[�\���� xyzzy ��ɂ���ꍇ xyzzy �̍�����Ɉړ�"
  (ed:interactive)
  (if (over-client-cursor-p)
      (move-cursor-window-lt2)))

(defun move-hindrance-cursor-desktop-corner ()
  "�}�E�X�J�[�\���� xyzzy ��ɂ���ꍇ�f�X�N�g�b�v�̊p�Ɉړ�"
  (ed:interactive)
  (when (over-client-cursor-p)
    (let ((right (1- (GetSystemMetrics SM_CXSCREEN)))
          (bottom (1- (GetSystemMetrics SM_CYSCREEN)))
          x y)
      ;; (left, top), (right, top), (left, bottom) (right, bottom) �̏�
      (cond
       ((not (over-client-point-p 0 0))
        (setq x 0 y 0))
       ((not (over-client-point-p right 0))
        (setq x right y 0))
       ((not (over-client-point-p 0 bottom))
        (setq x 0 y bottom))
       ((not (over-client-point-p right bottom))
        (setq x right y bottom)))
      (if (and x y)
          (SetCursorPos x y)))))

(defun move-hindrance-cursor-window-outside ()
  "�}�E�X�J�[�\���� xyzzy ��ɂ���ꍇ xyzzy �̎��ӂɈړ�"
  (ed:interactive)
  (when (over-client-cursor-p)
    (let ((wr (make-RECT))
          (cp (make-POINT))
          (right (1- (GetSystemMetrics SM_CXSCREEN)))
          (bottom (1- (GetSystemMetrics SM_CYSCREEN)))
          x y)
      (GetWindowRect (ed:get-window-handle) wr)
      (GetCursorPos cp)
      ;; left, top. right, bottom �̏�
      (cond
       ((> (RECT-left wr) 0)
        (setq x (1- (RECT-left wr))
              y (POINT-y cp)))
       ((> (RECT-top wr) 0)
        (setq x (POINT-x cp)
              y (1- (RECT-top wr))))
       ((< (RECT-right wr) right)
        (setq x (1+ (RECT-right wr))
              y (POINT-y cp)))
       ((< (RECT-bottom wr) bottom)
        (setq x (POINT-x cp)
              y (1+ (RECT-bottom wr)))))
      (if (and x y)
          (SetCursorPos x y)
        (move-hindrance-cursor-desktop-corner)))))

;;; konata-mouse.l ends here