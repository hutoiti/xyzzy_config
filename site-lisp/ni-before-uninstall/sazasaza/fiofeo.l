(unless (find *this-command*
              '(ni::app-install-current
                ni::app-install-marked))
  (require "fiofeo")
  (ed::fiofeo-uninstall))