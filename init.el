; See https://emacs.stackexchange.com/questions/5828/why-do-i-have-to-add-each-package-to-load-path-or-problem-with-require-package
; Manually load package instead of waiting until after init.el is loaded
(package-initialize)
; Disable loading package again after init.el
(setq package-enable-at-startup nil)

; Enable "package", for installing packages
; Add some common package repositories
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/"))
;(add-to-list 'package-archives '("elpy" . "https://jorgenschaefer.github.io/packages/"))

; Use "package" to install "use-package", a better package management and config system
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

; Make OS shell path available in emacs exec path
;(use-package exec-path-from-shell
;  :ensure t
;  :config (exec-path-from-shell-copy-env "PATH"))


; Create a 80-character line marker
; With a work-around so that fill-column-indicator works with company mode
; https://emacs.stackexchange.com/questions/147/how-can-i-get-a-ruler-at-column-80
(use-package fill-column-indicator
  :ensure t
  :config
  (setq fci-rule-column 80)
  (add-hook 'prog-mode-hook 'fci-mode))

(defvar-local company-fci-mode-on-p nil)

(defun company-turn-off-fci (&rest ignore)
  (when (boundp 'fci-mode)
    (setq company-fci-mode-on-p fci-mode)
    (when fci-mode (fci-mode -1))))

(defun company-maybe-turn-on-fci (&rest ignore)
  (when company-fci-mode-on-p (fci-mode 1)))

(add-hook 'company-completion-started-hook 'company-turn-off-fci)
(add-hook 'company-completion-finished-hook 'company-maybe-turn-on-fci)
(add-hook 'company-completion-cancelled-hook 'company-maybe-turn-on-fci)

; Set up auctex for Latex in Emacs
; Point auctex to my central .bib file
(use-package tex
  :ensure auctex
  :config
  (setq Tex-auto-save t)
  (setq Tex-parse-self t)
  (setq TeX-save-query nil)
  (add-hook 'LaTeX-mode-hook 'turn-on-reftex)
  (setq reftex-plug-into-AUCTeX t)
  (setq reftex-default-bibliography '("C:\texlive\texmf-local\bibtex\bib\locall\library.bib")))

; Set up elpy for Python in Emacs
;(use-package elpy
;  :ensure t				
;  :pin elpy
;  :config
;  (elpy-enable)
  ;; Enable elpy in a Python mode
;  (add-hook 'python-mode-hook 'elpy-mode)
;  (setq elpy-rpc-backend "jedi")
  ;; Open the Python shell in a buffer after sending code to it
;  (add-hook 'inferior-python-mode-hook 'python-shell-switch-to-shell)
  ;; Use IPython as the default shell, with a workaround to accommodate IPython 5
  ;; https://emacs.stackexchange.com/questions/24453/weird-shell-output-when-using-ipython-5  (setq python-shell-interpreter "ipython")
;  (setq python-shell-interpreter-args "--simple-prompt -i")
  ;; Enable pyvenv, which manages Python virtual environments
;  (pyvenv-mode 1)
  ;; Tell Python debugger (pdb) to use the current virtual environment
  ;; https://emacs.stackexchange.com/questions/17808/enable-python-pdb-on-emacs-with-virtualenv
;:  (setq gud-pdb-command-name "python -m pdb "))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;          PROJECTILE        ;;;;;;;;;;;;;;;;;;;;;

; Set up projectile, i.e. package management + helm, i.e. autocomplete
; Tutorial - recommended: https://tuhdo.github.io/helm-projectile.html
(use-package projectile
  :ensure t
  :config
  (projectile-global-mode)
  (setq projectile-completion-system 'helm)
  (setq projectile-switch-project-action 'helm-projectile))

(use-package helm-projectile
  :ensure t
  :config
  (helm-projectile-on))

(use-package helm-config
  :ensure helm
  :config
  (helm-mode 1)
  (global-set-key (kbd "M-x") 'helm-M-x)
  (global-set-key (kbd "C-x C-f") 'helm-find-files))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Set up company, i.e. code autocomplete
(use-package company
  :ensure t
  :config
  ;; Enable company mode everywhere
  (add-hook 'after-init-hook 'global-company-mode)
  ;; Set up TAB to manually trigger autocomplete menu
  (define-key company-mode-map (kbd "TAB") 'company-complete)
  (define-key company-active-map (kbd "TAB") 'company-complete-common)
  ;; Set up M-h to see the documentation for items on the autocomplete menu
  (define-key company-active-map (kbd "M-h") 'company-show-doc-buffer))


; Set up company-jedi, i.e. tell elpy to use company autocomplete backend
;:(use-package company-jedi
;  :ensure t
;  :config
;  (defun my/python-mode-hook ()
;    (add-to-list 'company-backends 'company-jedi))
;  (add-hook 'python-mode-hook 'my/python-mode-hook))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;          ESS        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Set up ESS, i.e. Statistics in Emacs, R, Stata, etc.
(use-package ess-site
  :ensure ess
  :config
  (ess-toggle-underscore nil) ; http://stackoverflow.com/questions/2531372/how-to-stop-emacs-from-replacing-underbar-with-in-ess-mode
  (setq ess-fancy-comments nil) ; http://stackoverflow.com/questions/780796/emacs-ess-mode-tabbing-for-comment-region
  ; Make ESS use RStudio's indenting style
  (add-hook 'ess-mode-hook (lambda() (ess-set-style 'RStudio)))
  ; Make ESS use more horizontal screen
  ; http://stackoverflow.com/questions/12520543/how-do-i-get-my-r-buffer-in-emacs-to-occupy-more-horizontal-space
  (add-hook 'ess-R-post-run-hook 'ess-execute-screen-options) 
  (define-key inferior-ess-mode-map "\C-cw" 'ess-execute-screen-options))
  ; Add path to Stata to Emacs' exec-path so that Stata can be found
  ;(setq exec-path (append exec-path '("/usr/local/stata14"))))


; Move up through previous commands
(defun ess-readline ()
  "Move to previous command entered from script *or* R-process and copy 
   to prompt for execution or editing"
  (interactive)
  ;; See how many times function was called
  (if (eq last-command 'ess-readline)
      (setq ess-readline-count (1+ ess-readline-count))
    (setq ess-readline-count 1))
  ;; Move to prompt and delete current input
  (comint-goto-process-mark)
  (end-of-buffer nil) ;; tweak here
  (comint-kill-input)
  ;; Copy n'th command in history where n = ess-readline-count
  (comint-previous-prompt ess-readline-count)
  (comint-copy-old-input)
  ;; Below is needed to update counter for sequential calls
  (setq this-command 'ess-readline)
)
(global-set-key (kbd "\C-cp") 'ess-readline)


; Move back down again
(defun ess-readnextline ()
  "Move to next command after the one currently copied to prompt and copy 
   to prompt for execution or editing"
  (interactive)
  ;; Move to prompt and delete current input
  (comint-goto-process-mark)
  (end-of-buffer nil)
  (comint-kill-input)
  ;; Copy (n - 1)'th command in history where n = ess-readline-count
  (setq ess-readline-count (max 0 (1- ess-readline-count)))
  (when (> ess-readline-count 0)
      (comint-previous-prompt ess-readline-count)
  (comint-copy-old-input))
  ;; Update counter for sequential calls
  (setq this-command 'ess-readline)
)
(global-set-key (kbd "\C-cn") 'ess-readnextline)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;,




;;;;;;;;;;;;;;;;;;;;;;;     Markdown       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
; Set up markdown in Emacs
; Tutorial: http://jblevins.org/projects/markdown-mode/
(use-package pandoc-mode
  :ensure t
  :config
  (add-hook 'markdown-mode-hook 'pandoc-mode))

(add-hook 'text-mode-hook (lambda() (flyspell-mode 1)))

(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "pandoc"))

; C-n add new lines at the end of buffer
(setq next-line-add-newlines t)
; open emacs full screen
(add-to-list 'default-frame-alist '(fullscreen . maximized))
; Make Emacs highlight paired parentheses
(show-paren-mode 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;  polymode     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; polymode
(require 'poly-R)
(require 'poly-markdown)
(add-to-list 'auto-mode-alist '("\\.Rmd" . poly-markdown+r-mode))

;; markdown mode
(add-to-list 'auto-mode-alist '("\\.md" . poly-markdown-mode))

;; R modes
(add-to-list 'auto-mode-alist '("\\.Snw" . poly-noweb+r-mode))
(add-to-list 'auto-mode-alist '("\\.Rnw" . poly-noweb+r-mode))
(add-to-list 'auto-mode-alist '("\\.Rmd" . poly-markdown+r-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(TeX-source-correlate-method (quote synctex))
 '(TeX-source-correlate-mode t)
 '(TeX-source-correlate-start-server t)
 '(inferior-STA-program-name "stata-se")
 '(package-selected-packages
   (quote
    (markdown-mode pandoc-mode ess company-jedi helm-projectile projectile elpy auctex fill-column-indicator exec-path-from-shell use-package))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )



