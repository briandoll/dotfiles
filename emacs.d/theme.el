(add-to-list 'load-path "~/.emacs.d/vendor/color-theme")

(require 'color-theme)
(color-theme-initialize)
(load-file "~/.emacs.d/vendor/color-theme-twilight.el")
(color-theme-twilight)

(setq-default tab-width 2)
(setq-default indent-tabs-mode nil)
(setq color-theme-is-global t)

