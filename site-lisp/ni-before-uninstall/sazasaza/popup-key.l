(unless (find *this-command*
	      '(ni::app-install-current
		ni::app-install-marked))
  (require "popup-key")
  (ed::popup-key-uninstall))