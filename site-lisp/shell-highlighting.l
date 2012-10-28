(in-package :editor)

(defvar *shell-mode-keyword-file* "Shell")
(defvar *shell-mode-keyword-table* nil)

(defun shell-mode-enable-highlighting ()
  (when *shell-mode-keyword-file*
    (unless *shell-mode-keyword-table*
      (setq *shell-mode-keyword-table*
(load-keyword-file *shell-mode-keyword-file*)))
    (make-local-variable 'keyword-hash-table)
    (setq highlight-keyword t ; <- ����
keyword-hash-table *shell-mode-keyword-table*)))
