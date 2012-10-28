(export 'ed::is-mode "ed")
(autoload 'is-mode "is-mode" t)
(pushnew '("\\.rul$" . is-mode) *auto-mode-alist* :test 'equal)
