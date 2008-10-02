
;Allows syntax highlighting to work, among other things
(global-font-lock-mode 1)
;These lines are required for ECB
(add-to-list 'load-path "~/.emacs.d/vendor")
(add-to-list 'load-path "~/.emacs.d/vendor/eieio")
(add-to-list 'load-path "~/.emacs.d/vendor/speedbar")
(add-to-list 'load-path "~/.emacs.d/vendor/semantic")

(setq semantic-load-turn-everything-on t)
(require 'semantic-load)
; This installs ecb - it is activated with M-x ecb-activate
(add-to-list 'load-path "~/.emacs.d/vendor/ecb")
(require 'ecb-autoloads)

; ecb configuration
(setq ecb-layout-name "left14")
(setq ecb-layout-window-sizes (quote (("left14" (0.2564102564102564 . 0.6949152542372882) (0.2564102564102564 . 0.23728813559322035)))))

; default paths
(setq ecb-source-path (quote ("~/Documents/workspace" "~/bin")))

