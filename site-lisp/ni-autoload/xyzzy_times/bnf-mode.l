(export 'ed::bnf-mode "ed")
(autoload 'bnf-mode "bnf-mode" t)
(pushnew '("\\.[ae]?bnf$" . bnf-mode) *auto-mode-alist* :test 'equal)
