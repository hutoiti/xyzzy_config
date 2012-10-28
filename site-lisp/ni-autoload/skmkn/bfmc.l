(in-package "ed")
(export '(*bfmc-buffer-filters* *bfmc-frame-filters* *bfmc-no-delete-buffers* *bfmc-no-rename-frames* *bfmc-mode-hook*
		  *bfmc-substitute-buffer-name* *bfmc-wait* *bfmc-buffer-deleter* *bfmc-cursor-at-open* *bfmc-mode-map* bfmc-menu bfmc-menu-frame))
(autoload 'bfmc-menu "bfmc" t)
(autoload 'bfmc-menu-frame "bfmc" t)