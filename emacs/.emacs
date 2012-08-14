;;==============================================================================
;; Path settings
;;==============================================================================
;;; A quick & ugly PATH solution to Emacs on Mac OSX
(if (string-equal "darwin" (symbol-name system-type))
    (setenv "PATH" (concat "/opt/local/bin:/opt/local/sbin:/usr/local/bin:/Users/daniel/.lein/bin:" (getenv "PATH"))))

(add-to-list 'load-path
	     (car (file-expand-wildcards "~/.emacs.d")))
(add-to-list 'load-path
	     (car (file-expand-wildcards "~/git/tools/distel/elisp")))
(add-to-list 'load-path
	     (car (file-expand-wildcards "~/git/tools/rost-otp/lib/tools/emacs")))
(add-to-list 'load-path
	     (car (file-expand-wildcards "~/git/tools/evil")))
(add-to-list 'load-path
	     (car (file-expand-wildcards "~/git/tools/evil-surround")))
(add-to-list 'load-path
	     (car (file-expand-wildcards "~/git/tools/undo-tree")))
(add-to-list 'load-path
	     (car (file-expand-wildcards "~/.emacs.d/ess-5.14/lisp")))


;;==============================================================================
;; package.el
;;==============================================================================
(require 'package)
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/"))
(package-initialize)


;;==============================================================================
;; UTF-8 support
;;==============================================================================
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)


;;==============================================================================
;; Emulate VIM because we love it, we do
;; Also setup some key bindings
;;==============================================================================
(require 'evil)
(evil-mode 1)

;; Add surround support
(require 'surround)
(global-surround-mode 1)

;; Set C-p to act as ESC
(define-key evil-insert-state-map "\C-p" 'evil-normal-state)

;; It's easy to press Alt-K instead of Windows-K, so unbind it
(global-unset-key (kbd "M-k"))

;; The same goes for C-\ instead of C-', also toggle-input-method is shit
(global-set-key (kbd "C-\\") 'hippie-expand)

;; I don't like emacs-state, so no need to have a key for it
(global-unset-key (kbd "C-z"))
(global-unset-key "\C-z")

;; Space and backspace move 10 lines forward/backward
(define-key evil-normal-state-map (kbd "DEL")
  (lambda () (interactive) (evil-scroll-up 10)))
(define-key evil-normal-state-map (kbd "SPC")
  (lambda () (interactive) (evil-scroll-down 10)))
(define-key evil-visual-state-map (kbd "DEL")
  (lambda () (interactive) (evil-scroll-up 10)))
(define-key evil-visual-state-map (kbd "SPC")
  (lambda () (interactive) (evil-scroll-down 10)))

;; Let Distel have a couple of key bindings back
(define-key evil-normal-state-map (kbd "M-.") 'erl-find-source-under-point)
(define-key evil-normal-state-map (kbd "M-,") 'erl-find-source-unwind)


;;==============================================================================
;; Misc settings
;;==============================================================================

;; Turn off menubar, toolbar and scrollbar
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Set font, and more importantly, its size
(set-face-attribute 'default nil :height 110)

;; Use y/n instead of yes/no for questions
(defalias 'yes-or-no-p 'y-or-n-p)

;; Columns are nice
(column-number-mode 1)

;; Tabs are not
(setq indent-tabs-mode nil)

;; Mouse wheel
;(mouse-wheel-mode 1)

;; Turn on global font lock mode
(global-font-lock-mode 1)

;; Turn on hilighting of brackets
(show-paren-mode t)

;; Set my email address.
(setq user-mail-address "daniel.eliasson@klarna.com")

;; Set the shell emacs uses.
(setq explicit-shell-file-name "/bin/bash")

;; Dont show startup screen
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(inhibit-startup-screen t)
 '(jira-url "https://mal.hq.kred/jira/rpc/xmlrpc")
 '(safe-local-variable-values (quote ((allout-layout . t)
				      (erlang-indent-level . 4)
				      (erlang-indent-level . 2)))))

;; Automatically close compilation window if compilation succeeds
(setq compilation-scroll-output 'first-error)
(setq compilation-finish-functions 'compile-autoclose)
(defun compile-autoclose (buffer string)
  (cond ((string-match "finished" string)
	 (bury-buffer "*compilation*")
	 (winner-undo)
	 (message "Build successful."))
	(t
	 (message "Compilation exited abnormally: %s" string))))

;; Nuke trailing whitespace on saving
;(add-hook 'before-save-hook 'delete-trailing-whitespace)


;;==============================================================================
;; Color theme
;;==============================================================================
(require 'color-theme)
(load-file "~/.emacs.d/color-themes/color-theme-wombat.el")
(color-theme-wombat)
(setq color-theme-is-global t)


;===============================================================================
; Load custom modes
;===============================================================================

;; highlight lines with trailing whitespace or tab indentation or long lines
;; also ensure indent-tabs-mode is off
(defun general-programming-mode-hook (the-mode)
  (custom-set-faces
   '(my-tab-face            ((((class color)) (:background "#3f2020"))) t)
   '(my-trailing-space-face ((((class color)) (:background "#3f2020"))) t)
   '(my-long-line-face      ((((class color)) (:background "#3f2020"))) t))
  (font-lock-add-keywords
   the-mode
   '(("\t+"          (0 'my-tab-face t))
     ("[ \t]+$"      (0 'my-trailing-space-face t))
     ("^.\\{81,\\}$" (0 'my-long-line-face t))))
  (setq indent-tabs-mode nil))

;; C
(defun my-c-mode-hook ()
  (c-set-style "stroustrup")
  (setq c-basic-offset 4))
(add-hook 'c-mode-hook 'my-c-mode-hook)

;; clojure with slime
(require 'clojure-mode)
(require 'clojure-test-mode) ;; requires slime
(defun my-clojure-mode-hook ()
  (paredit-mode 1))
(add-hook 'clojure-mode-hook 'my-clojure-mode-hook)

;; css-mode
(defun my-css-mode-hook ()
  (general-programming-mode-hook 'css-mode)
  (setq css-indent-offset 2))
(add-to-list 'auto-mode-alist
	     '("[.]less$" . css-mode))
(add-hook 'css-mode-hook 'my-css-mode-hook)
(defun kill-this-buffer-and-window ()
  (interactive)
  (kill-this-buffer)
  (delete-window))
  

;; Distel
(require 'distel)
(distel-setup)
(setq erlookup-roots
      '("~/git/klarna/dev/lib"
	"~/git/klarna/otp_r14b03/install/lib"))
(setq erl-nodename-cache 'kred@afshansamani)
(setq erl-popup-on-output nil)
(require 'erlang-compile-server)
(setq erl-ecs-compile-if-ok nil)
(evil-define-key 'normal erl-who-calls-mode-map (kbd "q")   'kill-this-buffer-and-window)
(evil-define-key 'normal erl-who-calls-mode-map (kbd "RET") 'erl-goto-caller)
(evil-define-key 'normal erl-who-calls-mode-map (kbd "M-.") 'erl-goto-caller)
(evil-define-key 'normal erl-who-calls-mode-map (kbd "M-,") 'erl-find-source-unwind)


;; ESS mode, for R
(require 'ess-site)
(ess-toggle-underscore nil)

;; erlang
(defun my-erlang-mode-hook ()
  (general-programming-mode-hook 'erlang-mode)
  (setq-default compile-command "make -j12 -k")

  ;; Set default encodings
  (set-terminal-coding-system 'iso-8859-1)
  (set-keyboard-coding-system 'iso-8859-1)
  (setq default-buffer-file-coding-system 'iso-8859-1)
  (prefer-coding-system 'iso-8859-1)
  (set-language-environment "Latin-1")
  (setq file-buffer-coding 'iso-8859-1)
  (let ((mode (current-input-mode)))
    (setcar (cdr (cdr mode)) 8)
    (apply 'set-input-mode mode))

  (setq indent-tabs-mode nil)
  (setq erlang-indent-level 2)
  ;(setq erlang-indent-level 4)

 ; (if (and (locate-library "erlang-flymake")
 ;	   buffer-file-truename)
 ;     (progn
 ;	(load "erlang-flymake")
 ;	(flymake-mode)
 ;	(local-set-key (kbd "M-'") 'erlang-flymake-next-error)))
  )
(autoload 'erlang-mode "erlang.el" "" t)
(add-to-list 'auto-mode-alist
	     '(".[eh]rl$" . erlang-mode))
(add-to-list 'auto-mode-alist
	     '("[.]yaws$" . erlang-mode))
(add-to-list 'auto-mode-alist
	     '("[.]erl.in$" . erlang-mode))
(add-to-list 'auto-mode-alist
	     '("[.]eterm$" . erlang-mode))
(add-to-list 'auto-mode-alist
	     '("[.]app[.]src$" . erlang-mode))
(add-hook 'erlang-mode-hook 'my-erlang-mode-hook)

;; html-mode
(defun my-html-mode-hook ()
  (general-programming-mode-hook 'html-mode)
  (setq html-indent-level 4)
  (setq sgml-basic-offset 4))
(add-to-list 'auto-mode-alist
	     '("[.]ejs$" . html-mode))
(add-hook 'html-mode-hook 'my-html-mode-hook)

;; ido mode
(ido-mode 1)
(put 'ido-exit-minibuffer 'disabled nil)
(put 'narrow-to-region 'disabled nil)

;; js-mode
(defun my-js-mode-hook ()
  (general-programming-mode-hook 'js-mode)
  (setq js-indent-level 2))
(add-to-list 'auto-mode-alist
	     '("[.]json$" . js-mode))
(add-hook 'js-mode-hook 'my-js-mode-hook)

;; LaTeX mode
(setq latex-run-command "pdflatex")

;; Magit
;(require 'magit)

;; Matlab mode (actually Octave)
(add-to-list 'auto-mode-alist
	     '("\\.m$" . octave-mode))
(setq octave-indent-function t)
(setq octave-shell-command "matlab")

;; Org mode
(require 'org)
(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)

(defun always-insert-item ()
  (interactive)
  (if (not (org-in-item-p))
      (insert "\n- ")
    (org-insert-item)))

(evil-define-key 'normal org-mode-map (kbd "TAB") 'org-cycle)
(evil-define-key 'normal org-mode-map "O" (lambda ()
					    (interactive)
					    (end-of-line)
					    (org-insert-heading)
					    (evil-append nil)))
(evil-define-key 'normal org-mode-map "o" (lambda ()
					    (interactive)
					    (end-of-line)
					    (always-insert-item)
					    (evil-append nil)))
(evil-define-key 'normal org-mode-map "t" (lambda ()
					    (interactive)
					    (end-of-line)
					    (org-insert-todo-heading nil)
					    (evil-append nil)))
(evil-define-key 'normal org-mode-map (kbd "M-o") (lambda ()
						    (interactive)
						    (end-of-line)
						    (org-insert-heading)
						    (org-metaright)
						    (evil-append nil)))
(evil-define-key 'normal org-mode-map (kbd "M-t") (lambda ()
						    (interactive)
						    (end-of-line)
						    (org-insert-todo-heading nil)
						    (org-metaright)
						    (evil-append nil)))
(evil-define-key 'normal org-mode-map "T" 'org-todo) ; mark a TODO item as DONE
(evil-define-key 'normal org-mode-map ";a" 'org-agenda) ; access agenda buffer
(evil-define-key 'normal org-mode-map "-" 'org-cycle-list-bullet) ; change bullet style
;; end org-mode settings

;; ruby-mode
(defun my-ruby-mode-hook ()
  (general-programming-mode-hook 'ruby-mode))
(add-hook 'ruby-mode-hook 'my-ruby-mode-hook)

;; shell mode
(setq ansi-color-names-vector ; better contrast colors
      ["black" "red4" "green4" "yellow4"
       "blue3" "magenta4" "cyan4" "white"])
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

;; slime
;; let slime use emacs state, but make sure clojure windows don't
(defun my-slime-mode-hook ()
  (interactive)
  (save-window-excursion
    (dolist (buffer (buffer-list))
      (with-current-buffer buffer
        (when (eq major-mode 'slime-repl-mode)
          (evil-emacs-state))))))
(add-hook 'slime-mode-hook 'my-slime-mode-hook)

;; Smex
(require 'smex)
(smex-initialize)
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)
;;; This is your old M-x.
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)

; Uniquify to avoid files with same name getting same-named buffers
(require 'uniquify)
(setq uniquify-buffer-name-style 'reverse)
(setq uniquify-separator "/")
(setq uniquify-after-kill-buffer-p t)
(setq uniquify-ignore-buffers-re "^\\*")

;; winner mode
;; Undo/Redo for window management (undo = C-c left, redo = C-c right)
(winner-mode 1)


;===============================================================================
; Global key bindings
;===============================================================================
(fset 'nice-list-element
   [?\C-e ?\M-b ?\M-f ?\C-k ?\C-a ?\C-n ?\C-d tab backspace backspace ?, ? ])
(global-set-key [f8] 'nice-list-element)

;; Compile
(global-set-key "\C-cc" 'compile)
 ; TODO: Add cool compile + reload modules :D

;; Revert buffer
(global-set-key [f5] 'revert-buffer)

;; This lets you do M-zf to find a (grep)regexp in all kred-sources.
;; Then you can use next error to find the match in the code.
;; E.g. ^C-zf -> Find: OCRGIRO_BNO_START ^C-.
(defun kfind-at (path word)
  (grep-find
   (concat "find " path
	   (concat " -name '.svn' -prune -o -name '*~' -prune -o -name '*html' -prune -o -type f -print0 | xargs -0 -e grep -n -e " word))))

(defun kfind (word)
  (interactive "MFind: ")
  (kfind-at
   (concat
    (car (split-string (buffer-file-name) "lib"))
    "lib/")
   word))

(defun kred-compile (&optional arg)
  "Compile and reload modules"
  (interactive "p")
  (compile "make -j12" nil)
)

(setq ctrl-z-map (make-keymap))
(global-set-key "\C-z" ctrl-z-map)
(global-set-key "\C-zf" 'kfind)
(global-set-key "\C-zc" 'kred-compile)
(global-set-key "\C-zz" 'erl-who-calls)
(global-set-key "\C-zd" 'erl-fdoc-describe)
(global-set-key "\C-zm" 'erl-find-module)
;; flymake
(global-set-key "\C-ze" 'flymake-display-err-menu-for-current-line)
(global-set-key "\C-zn" 'flymake-goto-next-error)
(global-set-key "\C-zp" 'flymake-goto-prev-error)

(global-set-key "\C-za" 'align-regexp)
(global-set-key "\C-zg" 'magit-status)

;; key binding for auto complete
(global-set-key (kbd "C-'") 'hippie-expand)
;; auto-complete settings
(setq hippie-expand-try-functions-list '(try-expand-dabbrev
                                         try-expand-dabbrev-all-buffers
                                         try-expand-dabbrev-from-kill
                                         try-complete-file-name-partially
                                         try-complete-file-name
                                         try-expand-list
                                         try-expand-line))

;; arrange for effective window-switching
(global-set-key [M-up]    'windmove-up)
(global-set-key [M-down]  'windmove-down)
(global-set-key [M-left]  'windmove-left)
(global-set-key [M-right] 'windmove-right)

(global-set-key "\C-cu" 'winner-undo)
(global-set-key "\C-cr" 'winner-redo)

;; Make delete key behave
(normal-erase-is-backspace-mode 1)
