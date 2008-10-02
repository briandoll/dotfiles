;;; ecb-symboldef.el --- ECB displayor for symbol-definitions

;;; Copyright (C) 2005 Hauke Jans

;; Author: Hauke Jans, <hauke.jans@sesa.de>, <hauke.jans@t-online.de>
;; Maintainer: Hauke Jans, <hauke.jans@sesa.de>, <hauke.jans@t-online.de>
;;             Klaus Berndl <klaus.berndl@sdm.de>
;; Keywords: browser, code, programming, symbol-definition
;; Created: 2005

;; This program is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by the Free
;; Software Foundation; either version 2, or (at your option) any later
;; version.

;; This program is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;; FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
;; more details.

;; You should have received a copy of the GNU General Public License along
;; with GNU Emacs; see the file COPYING. If not, write to the Free Software
;; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

;; $Id: ecb-symboldef.el,v 1.1 2005/05/23 15:36:15 berndl Exp $

;;; Commentary:
;;
;; Define an ecb-buffer which shows in a special ecb buffer the semantic
;; context of the definition of a current symbol under point.
;;

;;; Usage
;;
;; Either use the layout "left-symboldef" (e.g. via [C-c . l c]) or create a
;; new ecb-layout via the command `ecb-create-new-layout' and add a buffer of
;; type "other" and name "symboldef" into this new layout.

;;; History
;;
;; For the ChangeLog of this file see the CVS-repository. For a complete
;; history of the ECB-package see the file NEWS.

;;; Code:


(require 'ecb-util)
(require 'ecb-layout)
(require 'ecb-common-browser)
(require 'ecb-semantic-wrapper)

(eval-when-compile
  (require 'silentcomp))

;; XEmacs-stuff
(silentcomp-defun function-arglist)
(silentcomp-defun function-documentation)
(silentcomp-defun find-tag-internal)
;; Emacs stuff
(silentcomp-defun find-tag-noselect)

;; TODO: Klaus Berndl <klaus.berndl@sdm.de>:
;; 1. Add all necessary documentation to the info-manual (texi)
;; 2. Add this preferences group to the menu in ecb.el
(defgroup ecb-symboldef nil
  "Settings for the symbol-definition-buffer in the Emacs code browser."
  :group 'ecb
  :prefix "ecb-")

(defcustom ecb-symboldef-buffer-name " *ECB Symboldefinition*"
  "*Name of the ECB-symbol-definition buffer.
Because it is not a normal buffer for editing you should enclose the name with
stars, e.g. \"*ECB Symboldefinition*\".

If it is necessary for you you can get emacs-lisp access to the buffer-object
of the ECB-symbol-definition-buffer by this name, e.g. by a call of
`set-buffer'.

Changes for this option at runtime will take affect only after deactivating and
then activating ECB again!"
  :group 'ecb-symboldef
  :type 'string)

(defcustom ecb-symboldef-find-functions
  '((lisp-interaction-mode . ecb-symboldef-find-lisp-doc)
    (lisp-mode . ecb-symboldef-find-lisp-doc)
    (emacs-lisp-mode . ecb-symboldef-find-lisp-doc)
    (default . ecb-symboldef-find-definition))
    "*Funtions to find the definition for current symbol under point.
This functionality is set on a major-mode base, i.e. for every major-mode a
different setting can be used. The value of this option is a list of
cons-cells:
- The car is either a major-mode symbol or the special symbol 'default which
  means if no setting for a certain major-mode is defined then the cdr of
  the 'default cons-cell is used.
- The car is a function intended to find the definition of a certain symbol
  for files of this major-mode. Such a function will be called with two
  arguments, the first is the symbol-name as string for which the definition
  should be displayed and the second the current edit-buffer as buffer-object,
  i.e. the current buffer of the current edit-window. The function will be
  called with the special ecb-symbol-definition-buffer as current buffer
  whereas this buffer is empty. The function has to insert everything
  necessary to display the symbol-definition and is also responsible to format
  the displayed text. The buffer-local variable `fill-column is already preset
  to the window-width of the special ecb-window minus 1. The function is
  responsible to set the buffer-local variable `truncate-lines' appropriate.
  The function can either return nil or a string which will be integrated in
  the modeline-display of this ecb-window.

There are two prefined functions `ecb-symboldef-find-lisp-doc' and
`ecb-symboldef-find-definition' whereas the latter on is used a default
find-function."
  :group 'ecb-symboldef
  :type '(repeat (cons (symbol :tag "Major-mode")
                       (function :tag "Find function"))))

;; TODO: Klaus Berndl <klaus.berndl@sdm.de>: This option is an example how the
;; user could determine which backends should be used for finding a definition
;; and also in which order the backends should be tried...
(defcustom ecb-symboldef-find-backends '(semanticdb etags)
  "*Feature currently not implemented!"
  :group 'ecb-symboldef
  :type '(repeat (choice :tag "Backends"
                         :menu-tag "Backends"
                         (const :tag "semanticdb" :value semanticdb)
                         (const :tag "etags" :value etags)
                         (symbol :tag "Other"))))

;; ---- internal variables -----------

(defvar ecb-symboldef-last-symbol nil
  "Holds the previous symbol under cursor")

(defun ecb-symboldef-get-find-function ()
  "Returns the symbol find function to use according to major-mode"
  (let ((mode-function (cdr (assoc major-mode ecb-symboldef-find-functions)))
	(default-function (cdr (assoc 'default ecb-symboldef-find-functions))))
    (or mode-function
        default-function
        'ecb-symboldef-find-null)))

(defun ecb-symboldef-find-null (symbol-name edit-buffer)
  "Empty symbol-definition find function. 
Only prints mode and info but does not find any symbol-definition."
  (let ((symboldef-window-height (ecb-window-full-height
                                  (get-buffer-window (current-buffer)))))
    (dotimes (i (/ symboldef-window-height 2)) (insert "\n"))
    (insert  "*  No symbol definition function for current mode *\n"
             "*  See variable `ecb-symboldef-find-functions' *")))

(defun ecb-symboldef-get-elisp-arglist (function)
  "Return the argument-list of FUNCTION as a string in the format:
\(FUNCTION ARG1 ARG2...ARGn)."
  (if ecb-running-xemacs
      ;; XEmacs does not return an arglist for builtins (test by subrp)! So if
      ;; the documentation itself does not contain the arglist there is no way
      ;; to get it (e.g. call C-h f for `append', `list'...).
      (function-arglist function)
    ;; GNU Emacs - mechanism stolen from `describe-function-1'...
    (let (;; resolve alias-chains
          (def (indirect-function function))
          (arglist nil))
      ;; If def is a macro, find the function inside it.
      (if (eq (car-safe def) 'macro)
          (setq def (cdr def)))
      (setq arglist (cond ((byte-code-function-p def)
                           (car (append def nil)))
                          ((eq (car-safe def) 'lambda)
                           (nth 1 def))
                          ((and (eq (car-safe def) 'autoload)
                                (not (eq (nth 4 def) 'keymap)))
                           (concat "[Arg list not available until "
                                   "function definition is loaded.]"))
                          (t t)))
      (cond ((listp arglist)
             (prin1-to-string
              (cons (if (symbolp function) function "anonymous")
                    (mapcar (lambda (arg)
                              (if (memq arg '(&optional &rest))
                                  arg
                                (intern (upcase (symbol-name arg)))))
                            arglist))))
            ((stringp arglist)
             (format "(%s %s)" function arglist))))))

(defun ecb-symboldef-find-lisp-doc (symbol-name edit-buffer)
  "Insert the lisp-documentation of symbol with name SYMBOL-NAME."
  (setq truncate-lines nil)
  (let ((symbol (intern symbol-name))
        (retval nil)
        (args nil))
    (when (fboundp symbol)
      (insert (format "%s\t%s\n\n" symbol
                      (if (commandp symbol)
                          (let ((keys (where-is-internal symbol)))
                            (if keys
                                (concat
                                 "is a command with keys: "
                                 (mapconcat 'key-description
                                            keys ", "))
                              "is a command with no keys"))
                        "is a function")))
      (insert (format "%s\n\n" (or (documentation symbol)
                                   "Not documented")))
      (setq args (ecb-symboldef-get-elisp-arglist symbol))
      ;; KB: We display the arglist AFTER the documentation because in GNU
      ;; Emacs the documentation of subr's (test by subrp) contains the
      ;; arglist at the end of the documentation so we display it at the same
      ;; place for all other functions. The internal help of GNU Emacs has an
      ;; ugly hack for its function-help (see `describe-function-1' in
      ;; help.el) which searches for the arglist of subr's in the docu,
      ;; removes it from the end and inserts it again at beginning of the
      ;; documentation. I'm to lazy to do the same here because it's a clumsy
      ;; hack...but if you want the arglist in front of the docu-text you have
      ;; to do this here too (how to do it can be seen in
      ;; `describe-function-1').
      (and args (insert (format "%s\n\n" args)))
      (setq retval (format "Lisp %s"
                           (if (commandp symbol)
                               "Command"
                             "Function"))))
    (when (boundp symbol)
      (insert (format "%s\t%s\n\n%s\n\nValue: %s\n\n" symbol
                      (if (user-variable-p symbol)
                          "Option " "Variable")
                      (or (documentation-property
                           symbol 'variable-documentation)
                          "not documented")
                      (symbol-value symbol)))
      (setq retval "Lisp Variable"))
    (fill-region (point-min) (point-max) 'left)
    retval))

;; TODO: Klaus Berndl <klaus.berndl@sdm.de>: Replace the semantic-calls with
;; ecb--* wrappers
(defun ecb-symboldef-find-tag-by-semanticdb (symbol-name edit-buffer)
  "Function to find a semantic-tag by SYMBOL-NAME.
Returns nil if not found otherwise a list \(tag-buffer tag-begin tag-end)"
  (save-excursion
    (set-buffer edit-buffer)
    (let* ((mytag-list (semanticdb-brute-deep-find-tags-by-name symbol-name
                                                                nil t))
	   (mytag (if mytag-list 
                      (car (ecb--semanticdb-find-result-nth
                            mytag-list
                            (1- (ecb--semanticdb-find-result-length mytag-list))))))
	   (mytag-ovr (if mytag (semantic-tag-bounds mytag)))
	   (mytag-min (if mytag-ovr (car mytag-ovr)))
	   (mytag-max (if mytag-ovr (car (cdr mytag-ovr))))
	   (mytag-buf (if mytag (semantic-tag-buffer mytag))))
      (if mytag-buf
          (list mytag-buf mytag-min mytag-max)))))

(defun ecb-symboldef-find-tag-by-etags (symbol-name edit-buffer)
  "Try to find the definition of SYMBOL-NAME via etags.
Returns nil if not found otherwise a list \(tag-buffer tag-begin tag-end)
whereas tag-end is currently always nil."
  (if ecb-running-xemacs
      (let ((result (ignore-errors (find-tag-internal (list symbol-name)))))
	(if result
	    (list (car result) (cdr result) nil)))
    ;; else gnu emacs:
    (let* ((result-buf (ignore-errors (find-tag-noselect symbol-name)))
	   (result-point (if result-buf 
                             (with-current-buffer result-buf
                               (point)))))
      (if result-buf
	  (list result-buf result-point nil)))))

(defun ecb-symboldef-find-definition (symbol-name edit-buffer)
  "Inserts the definition of symbol with name SYMBOL-NAME.
Fill the upper-half of the special ecb-window with text preceding the
symbol-definition in the definition-file. First tries to find the definition
with semanticdb and then - if no success - with current etags-file."
  (let* ((symboldef-window-height (ecb-window-full-height
                                   (get-buffer-window (current-buffer))))
         ;; first lookup via semnaticdb, then via etags:
         (result (or (ecb-symboldef-find-tag-by-semanticdb symbol-name edit-buffer)
                     (ecb-symboldef-find-tag-by-etags symbol-name edit-buffer)
                     (list nil nil nil)))
         (num-tag-lines (- (/ symboldef-window-height 2) 0))
         (tag-buf (nth 0 result))
         (tag-point (nth 1 result))
         (tag-point-max (nth 2 result))
         (extend-point-min nil)
         (extend-point-max nil)
         (hilight-point-min nil)
         (hilight-point-max nil))
    (setq truncate-lines t)
    (when tag-buf
      (save-excursion
        (set-buffer tag-buf)
        (goto-char tag-point)
        (forward-line (- num-tag-lines))
        (setq extend-point-min (point))
        (forward-line num-tag-lines)
        (forward-line num-tag-lines)
        (setq extend-point-max (point)))
      (insert (ecb-buffer-substring extend-point-min extend-point-max tag-buf))
      (goto-char (+ (- tag-point extend-point-min) 1))
      (setq hilight-point-min (point))
      (if tag-point-max 
          (goto-char (+ (- tag-point-max extend-point-min) 1))
        (end-of-line))
      (setq hilight-point-max (point))
      (add-text-properties hilight-point-min hilight-point-max
                           '(face highlight ))
      ;; return value
      (buffer-name tag-buf))))

;; buffer update function:
(defun ecb-symboldef-update (edit-buffer symboldef-buffer symboldef-window)
  "Runs the finder of `ecb-symboldef-find-functions' for current symbol.
Displays the found text in the buffer SYMBOLDEF-BUFFER which is displayed in
window SYMBOLDEF-WINDOW. EDIT-BUFFER is the current buffer of the current
edit-window."
  (let ((modeline-display nil)
        (current-symbol
         ;; check if point is not at start, since
         ;; buggy thingatpt yields error then:
         ;; TODO: Klaus Berndl <klaus.berndl@sdm.de>: i can not believe this
         (if (> (point) (point-min))
             (ecb-thing-at-point 'symbol)
           nil))
        ;; find tag search function according to mode:
        (find-func (ecb-symboldef-get-find-function)))
    ;; TODO: Klaus Berndl <klaus.berndl@sdm.de>: make an option for this
    ;; min-length 
    ;; only use tags with a minimal length:
    (setq current-symbol (if (> (length current-symbol) 3)
                             current-symbol))
    ;; buggy thingatpt returns whole buffer if on empty line:
    (setq current-symbol (if (< (length current-symbol) 80)
                             current-symbol))
    ;; research tag only if different from last and not empty: 
    (when (and current-symbol
               (not (equal current-symbol ecb-symboldef-last-symbol)))
      (ecb-with-readonly-buffer symboldef-buffer
        (setq ecb-symboldef-last-symbol current-symbol)
        (erase-buffer)
        (setq fill-column (1- (window-width symboldef-window)))
        (setq modeline-display
              (or (funcall find-func
                           current-symbol
                           edit-buffer)
                  ""))
        ;; TODO: Klaus Berndl <klaus.berndl@sdm.de>: replace this by
        ;; a ecb-mode-line-format - if possible?!
        (ecb-mode-line-set (buffer-name symboldef-buffer)
                           (selected-frame)
                           (format "* Def %s <<%s>> *"
                                   modeline-display current-symbol)
                           nil t)
        ))))

(defecb-window-dedicator ecb-set-symboldef-buffer
    (buffer-name (get-buffer-create ecb-symboldef-buffer-name))
  "Set the buffer in the current window to the tag-definition-buffer and make
this window dedicated for this buffer."
  (switch-to-buffer (get-buffer-create ecb-symboldef-buffer-name))
  (add-hook 'ecb-current-buffer-sync-hook 'ecb-symboldef-sync))

(defun ecb-symboldef-sync ()
  "Synchronizes the symbol-definition buffer with current source if changed.
Can be called interactively but normally this should not be necessary because
it will be called autom. with `ecb-current-buffer-sync-hook'."
  (interactive)
  (ecb-do-if-buffer-visible-in-ecb-frame 'ecb-symboldef-buffer-name
    (save-excursion
      (ecb-symboldef-update (current-buffer) visible-buffer visible-window))))

(defun ecb-maximize-window-symboldef ()
  "Maximize the ECB-symbol-defnition window.
I.e. delete all other ECB-windows, so only one ECB-window and the
edit-window\(s) are visible \(and maybe a compile-window). Works also if the
ECB-symboldefinition-window is not visible in current layout."
  (interactive)
  (ecb-maximize-ecb-buffer ecb-symboldef-buffer-name t))

(defun ecb-goto-window-symboldef ()
  "Make the ECB-symbol-definition window the current window."
  (interactive)
  (ecb-goto-ecb-window ecb-symboldef-buffer-name))

(silentcomp-provide 'ecb-symboldef)

;;; ecb-symboldef.el ends here
