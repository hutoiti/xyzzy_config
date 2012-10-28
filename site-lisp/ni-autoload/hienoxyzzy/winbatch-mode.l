(export 'ed::winbatch-mode "ed")
(autoload 'winbatch-mode "winbatch-mode" t)
(pushnew '("\\.btw$" . winbatch-mode) *auto-mode-alist* :test 'equal)
