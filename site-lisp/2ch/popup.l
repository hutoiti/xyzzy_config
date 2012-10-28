; $Id: popup.l 3 2003-01-25 20:35:51Z torihat $

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "2ch/macro"))

(provide "2ch/popup")

(in-package "2ch")

(defvar *popup-menu-list*
  '((2ch-menu popup-buffer-menu nil)
    (2ch-board popup-buffer-board nil)
    (2ch-search popup-buffer-search nil)
    (2ch-tracking popup-buffer-tracking nil)
    (2ch-thread popup-buffer-thread nil)
    (2ch-view popup-buffer-view nil)
    (2ch-grep popup-buffer-grep nil)
    (2ch-bookmark popup-buffer-bookmark nil)
    (2ch-history popup-buffer-history nil)
    (2ch-form popup-buffer-form nil)
    (2ch-form-new popup-buffer-form-new nil)
    (2ch-http popup-buffer-http nil)))

(defun 2ch-mouse-right-press ()
  (interactive)
  (set-window *last-mouse-window*)
  (continue-pre-selection)
  (goto-last-mouse-point)
  ;(refresh-screen)
  (popup-menu-popup))

(defun thread-popup ()
  (interactive)
  (set-window *last-mouse-window*)
  (continue-pre-selection)
  (goto-last-mouse-point)
  (refresh-screen)
  (let ((menu (thread-popup-menu)))
    (when menu
      (track-popup-menu menu))))

(defun thread-popup-menu ()
  (let* ((attr (multiple-value-list (find-text-attribute-point (point))))
	 (number (thread-current-number))
	 (type (attr-tag attr))
	 (menu (popup-menu))
	 pos)
    (unless menu
      (return-from thread-popup-menu))
    (while (delete-menu menu 'thread-history))
    (while (delete-menu menu 'thread-aborn))
    (while (delete-menu menu 'thread-attr))
    (while (delete-menu menu 'thread-link))
    (while (delete-menu menu 'thread-anchor))
    (setq pos (get-menu-position menu 'thread-update))
    (unless pos
      (return-from thread-popup-menu menu))
    (when *thread-history*
      (insert-menu-item menu pos 'thread-history
			"�߂�"
			'thread-history-back)
      (incf pos)
      (insert-menu-separator menu pos 'thread-history)
      (incf pos))
    (when number
      (let ((aborn-p (thread-aborn-p number)))
	(insert-menu-item menu pos 'thread-aborn
			  "���ځ[��"
			  'thread-aborn-add
			  #'(lambda () (and aborn-p :disable)))
	(incf pos)
	(insert-menu-item menu pos 'thread-aborn
			  "���ځ[�����"
			  'thread-aborn-del
			  #'(lambda () (or aborn-p :disable)))
	(incf pos)
	(insert-menu-separator menu pos 'thread-attr)
	(incf pos)))
    (cond ((eq type 'anchor)
	   (insert-popup-menu menu pos (popup-menu-anchor) "�ԍ��̔���")
	   (insert-menu-separator menu (1+ pos) 'thread-attr))
	  ((eq type 'link)
	   (insert-popup-menu menu pos (popup-menu-link) "����URL��")
	   (insert-menu-separator menu (1+ pos) 'thread-attr))
    )
    menu))

(defun popup-menu-anchor ()
  (let ((menu (create-popup-menu 'thread-anchor)))
    (add-menu-item menu nil "�փW�����v"
		   'thread-jump)
    (add-menu-item menu nil "���|�b�v�A�b�v"
		   'thread-anchor-popup)
    (add-menu-item menu nil "���_�C�A���O�\��"
		   'thread-anchor-popup-msgbox)
    menu))

(defun popup-menu-link ()
  (let ((menu (create-popup-menu 'thread-link)))
    (add-menu-item menu nil "�J��"
		   'thread-jump)
    (add-menu-item menu nil "�u���E�U�ŊJ��"
		   'thread-jump-in-browser)
    (add-menu-item menu nil "�R�s�["
		   'thread-link-copy)
    menu))

(defun popup-menu-popup ()
  (let ((menu (popup-menu)))
    (unless menu
      (return-from popup-menu-popup))
    (track-popup-menu menu)))

(defun popup-menu (&optional force)
  (let ((menu (popup-menu-menu (popup-menu-list buffer-mode)))
	func)
    (when (or force
	      (not menu))
      (when (setq func (popup-menu-func (popup-menu-list buffer-mode)))
	(setq menu (funcall func))
	(setf (popup-menu-menu (popup-menu-list buffer-mode)) menu)))
    (or menu *app-popup-menu*)))

(defun popup-menu-add (menu)
  (add-menu-separator menu nil)
  (add-popup-menu menu *app-popup-menu* "���̑�")
  (add-menu-separator menu nil)
  (add-popup-menu menu (popup-menu-bookmark) "�u�b�N�}�[�N")
  (add-popup-menu menu (popup-menu-history) "����")
  (add-menu-separator menu nil)
  (add-menu-item menu nil
		 "...�ɂ���"
		 'version)
  (add-menu-item menu nil "2ch�g�b�v�y�[�W"
		 'open-browser-index)
  (add-menu-separator menu nil)
  (add-menu-item menu nil "�X�����N���[���A�b�v"
		 'thread-clean-dat)
  (add-menu-item menu nil "�I�����C�����[�h"
		 'toggle-online
		 #'(lambda () (when *online* :check)))
  (add-menu-item menu nil "�I��"
		 'exit)
  menu)

(defun popup-menu-bookmark ()
  (let ((menu (create-popup-menu '2ch-bookmark)))
    (add-menu-item menu nil "�J��"
		   'bookmark-open
		   #'(lambda () (unless *bookmark-list* :disable)))
    (add-menu-separator menu nil)
    (add-menu-item menu nil "�i��"
		   'bookmark-next
		   #'(lambda () (unless *bookmark-list* :disable)))
    (add-menu-item menu nil "�߂�"
		   'bookmark-previous
		   #'(lambda () (unless *bookmark-list* :disable)))
    menu))

(defun popup-menu-history ()
  (let ((menu (create-popup-menu '2ch-history)))
    (add-menu-item menu nil "�J��"
		   'history-open
		   #'(lambda () (unless (or *history-back* *history-forward*) :disable)))
    (add-menu-separator menu nil)
    (add-menu-item menu nil "�i��"
		   'history-next
		   #'(lambda () (unless *history-forward* :disable)))
    (add-menu-item menu nil "�߂�"
		   'history-previous
		   #'(lambda () (unless *history-back* :disable)))
    menu))

(defun popup-buffer-menu ()
  (let ((menu (create-popup-menu '2ch-menu)))
    (add-menu-item menu nil "�I��"
		   'menu-select)
    (add-menu-item menu nil "�J�e�S���֖߂�"
		   'menu-back-category)
    (add-menu-item menu nil "�J�e�S�����J��"
		   'menu-category-open)
    (add-menu-item menu nil "�J�e�S�������"
		   'menu-category-close)
    (add-menu-item menu nil "���X�g���X�V"
		   'menu-update)
    (add-menu-item menu nil "���X�g���ēǍ�"
		   'menu-reload)
    (add-menu-separator menu nil)
    (add-menu-item menu nil (format nil "~A�O���[�v������X�V" *tracking-name*)
		   'menu-tracking-update)
    (add-menu-item menu nil (format nil "~A������X�V" *tracking-name*)
		   'tracking-update-full)
    (add-menu-item menu nil "�X�V���ꂽ�X�����ꗗ�\��"
		   'tracking-show-updated
		   #'(lambda () (unless *tracking-uplist* :disable)))
    (add-menu-item menu nil "���̍X�V���ꂽ�X�����J��"
		   'menu-tracking-uplist-next
		   #'(lambda () (unless *tracking-uplist* :disable)))
    (add-menu-separator menu nil)
    (add-menu-item menu nil (format nil "~A�̃O���[�v��ǉ�" *tracking-name*)
		   'menu-tracking-add)
    (add-menu-item menu nil (format nil "~A�ɔ�ǉ�" *favorits-name*)
		   'menu-favorits-add)
    (add-menu-item menu nil (format nil "~A��URL����ǉ�" *favorits-name*)
		   'favorits-add-from-url)
    (add-menu-item menu nil (format nil "�O���[�v���폜")
		   'menu-del)
    (add-menu-item menu nil (format nil "~A�̔�؂���" *favorits-name*)
		   'menu-cut)
    (add-menu-item menu nil (format nil "~A�ɔ�\��t��" *favorits-name*)
		   'menu-paste)
    (add-menu-separator menu nil)
    (add-menu-item menu nil (format nil "~A�̃X���ꗗ���X�V" *favorits-name*)
		   'favorits-update)
    (add-menu-item menu nil "�J�e�S���̃X���ꗗ���X�V"
		   'menu-category-board-update)
    (add-menu-item menu nil "�S�̃X���ꗗ���X�V"
		   'menu-category-board-update-all)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "�J�e�S����S�ĊJ��"
		   'menu-category-open-all)
    (add-menu-item menu nil "�J�e�S����S�ĕ���"
		   'menu-category-close-all)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "���u���E�U�ŊJ��"
		   'menu-board-open-browser)
    (add-menu-item menu nil "��URL���R�s�["
		   'menu-board-url-copy)
    (add-menu-item menu nil "�����R�s�["
		   'menu-board-name-copy)
    (add-menu-item menu nil "����URL���R�s�["
		   'menu-board-url-name-copy)
    (add-menu-item menu nil "���̔ɂ���..."
		   'menu-board-rule)
    (add-menu-separator menu nil)
    (add-popup-menu menu (popup-buffer-menu-search) "�X���^�C�g������")
    (setq menu (popup-menu-add menu))
    menu))

(defun popup-buffer-menu-search ()
  (let ((menu (create-popup-menu '2ch-menu-search)))
    (add-menu-item menu nil "�S����"
		   'menu-all-search)
    (add-menu-item menu nil "�S����+�X�V"
		   'menu-all-search-reload)
    (add-menu-item menu nil "�S����+�擾"
		   'menu-all-search-force)
    (add-menu-item menu nil "�S����+�擾+�X�V"
		   'menu-all-search-force-reload)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "�J�e�S������"
		   'menu-category-search)
    (add-menu-item menu nil "�J�e�S������+�X�V"
		   'menu-category-search-reload)
    (add-menu-item menu nil "�J�e�S������+�擾"
		   'menu-category-search-force)
    (add-menu-item menu nil "�J�e�S������+�擾+�X�V"
		   'menu-category-search-force-reload)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "����"
		   'menu-board-search)
    menu))

(defun popup-buffer-board ()
  (let ((menu (create-popup-menu '2ch-menu-board)))
    (add-menu-item menu nil "�X�����J��"
		   'board-select)
    (add-menu-item menu nil "�X�����J��(�����w��)"
		   'board-select-lines)
    (add-menu-item menu nil (format nil "�X����~A�ɒǉ�" *tracking-name*)
		   'board-tracking-add-dialog)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "���u���E�U�ŊJ��"
		   'board-open-browser)
    (add-menu-item menu nil "��URL���R�s�["
		   'board-url-copy)
    (add-menu-item menu nil "�����R�s�["
		   'board-name-copy)
    (add-menu-item menu nil "����URL���R�s�["
		   'board-url-name-copy)
    (add-menu-item menu nil "���̔ɂ���..."
		   'board-rule)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "�X�����u���E�U�ŊJ��"
		   'tracking-thread-open-browser)
    (add-menu-item menu nil "�X����URL���R�s�["
		   'tracking-thread-url-copy)
    (add-menu-item menu nil "�X���^�C�g�����R�s�["
		   'tracking-thread-title-copy)
    (add-menu-item menu nil "�X���^�C�g����URL���R�s�["
		   'tracking-thread-url-title-copy)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "�X���ꗗ���X�V"
		   'board-update)
    (add-menu-item menu nil "�X���ꗗ���ēǂݍ���"
		   'board-reload)
;    (add-menu-separator menu nil)
;    (add-menu-item menu nil "�V�X�������Ă�"
;		   'board-form)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "�X���f�[�^���폜"
		   'tracking-thread-delete-dat)
    (add-menu-item menu nil "�X���f�[�^���폜�i���S�j"
		   'tracking-thread-delete-dat-tbk)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "�X���^�C�g������..."
		   'board-search)
    (add-menu-item menu nil "������..."
		   'board-grep-dialog)
    (add-menu-item menu nil "�����X���ꗗ"
		   'board-show-read-dat)
    (add-menu-item menu nil "�����X���ꗗ�i�ߋ����O���j"
		   'board-show-read-dat-kako)
    (add-menu-item menu nil "..���Ԃ̐V�X���ꗗ"
		   'board-new-show)
    (add-menu-separator menu nil)
    (add-popup-menu menu (popup-menu-mark-set) "�}�[�N��t����")
    (add-popup-menu menu (popup-menu-mark-unset) "�}�[�N���O��")
    (add-popup-menu menu (popup-menu-mark-cmd-search) "�}�[�N�����X����")
    (add-menu-separator menu nil)
    (add-menu-item menu nil "����"
		   'board-close)
    (popup-menu-add menu)))

(defun popup-buffer-tracking ()
  (let ((menu (create-popup-menu '2ch-menu-tracking)))
    (add-menu-item menu nil "�X�����J��"
		   'tracking-select)
    (add-menu-item menu nil "���̍X�V�X�����J��"
		   'tracking-next-updated)
    (add-menu-item menu nil "���̔ŃX�����J��"
		   'tracking-open-in-board)
    (add-menu-item menu nil "�X�����폜"
		   'tracking-del)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "�X�����u���E�U�ŊJ��"
		   'tracking-thread-open-browser)
    (add-menu-item menu nil "�X����URL���R�s�["
		   'tracking-thread-url-copy)
    (add-menu-item menu nil "�X���^�C�g�����R�s�["
		   'tracking-thread-title-copy)
    (add-menu-item menu nil "�X���^�C�g����URL���R�s�["
		   'tracking-thread-url-title-copy)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "�X���ꗗ���X�V"
		   'tracking-reload)
    (add-menu-item menu nil "���̃X�����X�V"
		   'tracking-update-current)
    (add-menu-item menu nil "�X����S�čX�V"
		   'tracking-update-all)
    (add-menu-item menu nil "�X������ёւ�"
		   'tracking-sort-dialog)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "�X�����ߋ����O�ɂ���"
		   'tracking-change-kako)
    (add-menu-item menu nil "�X����ʏ탍�O�ɂ���"
		   'tracking-change-dat)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "�X����؂���"
		   'tracking-cut)
    (add-menu-item menu nil "�X�����R�s�["
		   'tracking-copy)
    (add-menu-item menu nil "�X����\��t��"
		   'tracking-paste)
    (add-menu-separator menu nil)
    (add-popup-menu menu (popup-menu-mark-set) "�}�[�N��t����")
    (add-popup-menu menu (popup-menu-mark-unset) "�}�[�N���O��")
    (add-popup-menu menu (popup-menu-mark-cmd) "�}�[�N�����X����")
    (add-menu-separator menu nil)
    (add-menu-item menu nil "�X���f�[�^���폜"
		   'tracking-thread-delete-dat)
    (add-menu-item menu nil "�X���f�[�^���폜�i���S�j"
		   'tracking-thread-delete-dat-tbk)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "����"
		   'tracking-quit)
    (popup-menu-add menu)))

(defun popup-menu-mark-set ()
  (let ((menu (create-popup-menu '2ch-menu-mark-set)))
    (add-menu-item menu nil "����"
		   'tracking-mark-set)
    (add-menu-item menu nil "�S��"
		   'tracking-mark-set-all)
    (add-menu-item menu nil "���]"
		   'tracking-mark-set-reverse)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "�ߋ����O"
		   'tracking-mark-set-kako)
    (add-menu-item menu nil "�ǂ������X��"
		   'tracking-mark-set-tracking)
    (add-menu-item menu nil "�ǂ������X���ȊO"
		   'tracking-mark-set-tracking-reverse)
    (add-menu-item menu nil "�X�V���Ȃ��X��..."
		   'tracking-mark-set-old)
    (add-menu-item menu nil "�J���Ă��Ȃ��X��..."
		   'tracking-mark-set-nouse)
    (add-menu-item menu nil "���K�\��..."
		   'tracking-mark-set-query)
    menu))

(defun popup-menu-mark-unset ()
  (let ((menu (create-popup-menu '2ch-menu-mark-unset)))
    (add-menu-item menu nil "����"
		   'tracking-mark-unset
		   #'(lambda () (unless board-mark :disable)))
    (add-menu-item menu nil "�S��"
		   'tracking-mark-unset-all
		   #'(lambda () (unless board-mark :disable)))
    menu))

(defun popup-menu-mark-cmd ()
  (let ((menu (create-popup-menu '2ch-menu-cmd)))
    (add-menu-item menu nil "�ꗗ����폜"
		   'tracking-del-marked
		   #'(lambda () (unless board-mark :disable)))
    (add-menu-item menu nil "�؂���"
		   'tracking-cut-marked
		   #'(lambda () (unless board-mark :disable)))
    (add-menu-item menu nil "�R�s�["
		   'tracking-copy-marked
		   #'(lambda () (unless board-mark :disable)))
    (add-menu-item menu nil "����..."
		   'tracking-send-marked-dialog
		   #'(lambda () (unless board-mark :disable)))
    (add-menu-item menu nil "�X�V"
		   'tracking-update-marked
		   #'(lambda () (unless board-mark :disable)))
    (add-menu-item menu nil "�X���f�[�^���폜"
		   'tracking-thread-delete-marked-dat
		   #'(lambda () (unless board-mark :disable)))
    (add-menu-item menu nil "�X���f�[�^���폜�i���S�j"
		   'tracking-thread-delete-marked-dat-tbk
		   #'(lambda () (unless board-mark :disable)))
    menu))

(defun popup-menu-mark-cmd-search ()
  (let ((menu (create-popup-menu '2ch-menu-cmd)))
    (add-menu-item menu nil "�R�s�["
		   'tracking-copy-marked
		   #'(lambda () (unless board-mark :disable)))
    (add-menu-item menu nil "����..."
		   'search-send-marked-dialog
		   #'(lambda () (unless board-mark :disable)))
    (add-menu-item menu nil "�X���f�[�^���폜"
		   'tracking-thread-delete-marked-dat
		   #'(lambda () (unless board-mark :disable)))
    (add-menu-item menu nil "�X���f�[�^���폜�i���S�j"
		   'tracking-thread-delete-marked-dat-tbk
		   #'(lambda () (unless board-mark :disable)))
    menu))

(defun popup-buffer-search ()
  (let ((menu (create-popup-menu '2ch-menu-search)))
    (add-menu-item menu nil "�X�����J��"
		   'search-select)
    (add-menu-item menu nil "�X�����J��(�����w��)"
		   'search-select-lines)
    (add-menu-item menu nil (format nil "�X����~A�ɒǉ�" *tracking-name*)
		   'board-tracking-add-dialog)
    (add-menu-item menu nil (format nil "�ꗗ��~A�Ƃ��ĕۑ�" *tracking-name*)
		   'search-save-as-tracking)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "�X�����u���E�U�ŊJ��"
		   'tracking-thread-open-browser)
    (add-menu-item menu nil "�X����URL���R�s�["
		   'tracking-thread-url-copy)
    (add-menu-item menu nil "�X���^�C�g�����R�s�["
		   'tracking-thread-title-copy)
    (add-menu-item menu nil "�X���^�C�g����URL���R�s�["
		   'tracking-thread-url-title-copy)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "�X���f�[�^���폜"
		   'tracking-thread-delete-dat)
    (add-menu-item menu nil "�X���f�[�^���폜�i���S�j"
		   'tracking-thread-delete-dat-tbk)
    (add-menu-separator menu nil)
    (add-popup-menu menu (popup-menu-mark-set) "�}�[�N��t����")
    (add-popup-menu menu (popup-menu-mark-unset) "�}�[�N���O��")
    (add-popup-menu menu (popup-menu-mark-cmd-search) "�}�[�N�����X����")
    (add-menu-separator menu nil)
    (add-menu-item menu nil "����"
		   'board-close)
    (popup-menu-add menu)))

(defun popup-buffer-thread ()
  (let ((menu (create-popup-menu '2ch-menu-thread)))
    (add-menu-item menu 'thread-update "�X�����X�V"
		   'thread-update)
    (add-menu-item menu nil "�X�����ēǂݍ���"
		   'thread-reload)
    (add-menu-separator menu nil)
    (add-popup-menu menu (popup-thread-move) "�ړ�")
    (add-menu-separator menu nil)
    (add-menu-item menu nil "�L�����_�C�A���O�ŊJ��"
		   'thread-view-current)
    (add-menu-item menu nil "�L�����_�C�A���O�ŊJ��(�͈͎w��)"
		   'thread-view-range)
    (add-menu-item menu nil "�L�����u���E�U�ŊJ��"
		   'thread-view-current-in-browser)
    (add-menu-item menu nil "�L�����u���E�U�ŊJ��(�͈͎w��)"
		   'thread-view-range-in-browser)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "����"
		   'thread-form)
    (add-menu-item menu nil "�ԐM"
		   'thread-reply)
    (add-menu-item menu nil "�܂Ƃ߂ĕԐM"
		   'thread-reply-range)
    (add-menu-item menu nil "�������݂�\��"
		   'view-show)
    (add-menu-separator menu nil)
    (add-menu-item menu nil (format nil "�X����~A�ɒǉ�" *tracking-name*)
		   'thread-tracking-add-dialog)
    (add-menu-item menu nil "�X����URL���R�s�["
		   'thread-url-copy)
    (add-menu-item menu nil "�X���^�C�g�����R�s�["
		   'thread-title-copy)
    (add-menu-item menu nil "�X���^�C�g����URL���R�s�["
		   'thread-url-title-copy)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "�X�����u���E�U�ŊJ��"
		   'thread-open-browser)
    (add-menu-item menu nil "�X����URL�Ŏw��"
		   'thread-open-2ch-url)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "�|�b�v�A�b�v���[�h"
		   'thread-popup-mode
		   #'(lambda () (when *thread-popup-mode* :check)))
    (add-menu-item menu nil "���̔ɂ���..."
		   'thread-board-rule)
    (add-menu-item menu nil "����"
		   'thread-quit)
    (popup-menu-add menu)))

(defun popup-thread-move ()
  (let ((menu (create-popup-menu 'thread-move)))
    (add-menu-item menu nil "���y�[�W"
		   'thread-next-page)
    (add-menu-item menu nil "�O�y�[�W"
		   'thread-previous-page)
    (add-menu-item menu nil "���̔���"
		   'thread-next-article)
    (add-menu-item menu nil "�O�̔���"
		   'thread-previous-article)
    (add-menu-item menu nil "���̃^�O"
		   'thread-next-tag)
    (add-menu-item menu nil "�O�̃^�O"
		   'thread-previous-tag)
    (add-menu-item menu nil "�ԍ��փW�����v"
		   'thread-goto)
    menu))

(defun popup-buffer-view ()
  (let ((menu (create-popup-menu '2ch-menu-view)))
    (add-menu-item menu 'view-update "�\�����X�V"
		   'view-update)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "�W�����v"
		   'view-jump)
    (add-menu-item menu nil "�߂�"
		   'thread-history-back)
    (add-menu-item menu nil "�����̃X�����J��"
		   'view-open-thread)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "���y�[�W"
		   'next-page)
    (add-menu-item menu nil "�O�y�[�W"
		   'previous-page)
    (add-menu-item menu nil "���̔���"
		   'view-next-article)
    (add-menu-item menu nil "�O�̔���"
		   'view-previous-article)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "�������폜"
		   'view-delete-current)
    (add-menu-item menu nil "�������t�H�[���ŊJ��"
		   'view-create-form)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "����"
		   'view-quit)
    (popup-menu-add menu)))

(defun popup-buffer-grep ()
  (let ((menu (create-popup-menu '2ch-menu-grep)))
    (add-menu-item menu nil "�W�����v"
		   'grep-jump)
    (add-menu-item menu nil "�����̃X�����J��"
		   'grep-open-thread)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "���y�[�W"
		   'next-page)
    (add-menu-item menu nil "�O�y�[�W"
		   'previous-page)
    (add-menu-item menu nil "���̔���"
		   'view-next-article)
    (add-menu-item menu nil "�O�̔���"
		   'view-previous-article)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "���̃}�b�`"
		   'grep-next-match)
    (add-menu-item menu nil "�O�̃}�b�`"
		   'grep-previous-match)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "����"
		   'grep-quit)
    (popup-menu-add menu)))

(defun popup-buffer-form ()
  (let ((menu (create-popup-menu '2ch-menu-form)))
    (add-menu-item menu nil "�����𑗐M"
		   'form-post)
    (add-menu-item menu nil "������sage���M"
		   'form-post-sage)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "������ۑ�"
		   'form-save)
    (add-menu-item menu nil "�O�̔���"
		   'form-article-saved-previous)
    (add-menu-item menu nil "���̔���"
		   'form-article-saved-next)
    (add-menu-item menu nil "�������폜"
		   'form-article-current-del)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "sage�ɂ���"
		   'form-sage)
    (add-menu-item menu nil "���O��I��"
		   'popup-form-name-menu)
    (add-menu-item menu nil "���[����I��"
		   'popup-form-addr-menu)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "���O��o�^"
		   'form-name-add)
    (add-menu-item menu nil "���[����o�^"
		   'form-addr-add)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "���p�L���t��yank"
		   'form-cite-yank)
    (add-menu-item menu nil "���p�L���t���\��t��"
		   'form-cite-paste)
    (add-menu-item menu nil "�X�y�[�X��ϊ�"
		   'form-body-convert)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "�X���֖߂�"
		   'form-back)
    (add-menu-item menu nil "���̔ɂ���..."
		   'form-board-rule)
    (add-menu-item menu nil "����"
		   'form-delete)
    (popup-menu-add menu)))

(defun popup-buffer-form-new ()
  (let ((menu (create-popup-menu '2ch-menu-form-new)))
    (add-menu-item menu nil "�����𑗐M"
		   'form-post-new)
    (add-menu-item menu nil "������sage���M"
		   'form-post-new-sage)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "������ۑ�"
		   'form-save-new)
    (add-menu-item menu nil "�O�̔���"
		   'form-article-saved-new-previous)
    (add-menu-item menu nil "���̔���"
		   'form-article-saved-new-next)
    (add-menu-item menu nil "�������폜"
		   'form-article-current-del-new)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "sage�ɂ���"
		   'form-sage)
    (add-menu-item menu nil "���O��I��"
		   'popup-form-name-menu)
    (add-menu-item menu nil "���[����I��"
		   'popup-form-addr-menu)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "���O��o�^"
		   'form-name-add)
    (add-menu-item menu nil "���[����o�^"
		   'form-addr-add)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "���p�L���t��yank"
		   'form-cite-yank)
    (add-menu-item menu nil "���p�L���t���\��t��"
		   'form-cite-paste)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "�X���֖߂�"
		   'form-back)
    (add-menu-item menu nil "����"
		   'form-delete)
    (popup-menu-add menu)))

(defun popup-buffer-http ()
  (let ((menu (create-popup-menu '2ch-menu-http)))
    (add-menu-item menu nil "�w�b�_��\��"
		   'http-show-status)
    (add-menu-item menu nil "����"
		   'http-quit)
    (popup-menu-add menu)))

(defun popup-buffer-bookmark ()
  (let ((menu (create-popup-menu '2ch-menu-bookmark)))
    (add-menu-item menu nil "�u�b�N�}�[�N�փW�����v"
		   'bookmark-select)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "�u�b�N�}�[�N���폜"
		   'bookmark-delete)
    (add-menu-item menu nil "�u�b�N�}�[�N��؂���"
		   'bookmark-cut)
    (add-menu-item menu nil "�u�b�N�}�[�N��\��t��"
		   'bookmark-paste)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "����"
		   'bookmark-quit)
    (popup-menu-add menu)))

(defun popup-buffer-history ()
  (let ((menu (create-popup-menu '2ch-menu-history)))
    (add-menu-item menu nil "�W�����v"
		   'history-select)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "���̗������폜"
		   'history-delete)
    (add-menu-item menu nil "�������N���A�["
		   'history-clear)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "����"
		   'bookmark-quit)
    (popup-menu-add menu)))