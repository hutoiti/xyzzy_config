(export 'ed::properties-mode "ed")
(autoload 'properties-mode "properties-mode" t)
(pushnew '("\\.properties$" . properties-mode) *auto-mode-alist* :test 'equal)
