; MY CONFIGURATION FOR EMACS

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

; Disable loading package again after init.el
(setq package-enable-at-startup nil)

; Enable "package", for installing packages
; Add some common package repositories
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/"))
(add-to-list 'package-archives '("elpy" . "https://jorgenschaefer.github.io/packages/"))


;; Trick for melpa
(when (>= emacs-major-version 24)
  ;(require 'package)
  ;(package-initialize)
  (add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
  )

;; Elpy

(use-package elpy
  :ensure t
  :init
  (elpy-enable))



; Enable installation of packages from MELPA
;(add-to-list 'package-archives
;             '("melpa-stable" . "https://stable.melpa.org/packages/") t)

(add-to-list 'package-archives `("melpa" . "https://melpa.org/packages/"))


; Use "package" to install "use-package", a better package management and config system
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))


; Install ESS
(use-package ess
 :ensure t
 :init (require 'ess-site))

(require 'ess-smart-underscore)

;; Active the R language in Babel
(org-babel-do-load-languages
 'org-babel-load-languages
 '((R . t)))

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

;; https://github.com/chuvanan/dot-files/blob/master/emacs-init.el
(setq inferior-R-args "--no-restore-history --no-save")


;; polymode
(use-package poly-R :ensure t) 
(require 'poly-R)
(require 'poly-markdown)
(add-to-list 'auto-mode-alist '("\\.Rmd" . poly-markdown+r-mode))

;; markdown mode
(add-to-list 'auto-mode-alist '("\\.md" . poly-markdown-mode))

;; R modes
(add-to-list 'auto-mode-alist '("\\.Snw" . poly-noweb+r-mode))
(add-to-list 'auto-mode-alist '("\\.Rnw" . poly-noweb+r-mode))
(add-to-list 'auto-mode-alist '("\\.Rmd" . poly-markdown+r-mode))



;;;; magit
;; https://github.com/inkel/emacs-d/blob/master/init.el

(use-package magit
  :ensure t
  :defer t
  :bind (("C-x g" . magit-status))
  :config
  (progn
    (defun inkel/magit-log-edit-mode-hook ()
      (setq fill-column 72)
      (flyspell-mode t)
      (turn-on-auto-fill))
    (add-hook 'magit-log-edit-mode-hook 'inkel/magit-log-edit-mode-hook)
    (defadvice magit-status (around magit-fullscreen activate)
      (window-configuration-to-register :magit-fullscreen)
      ad-do-it
      (delete-other-windows))))


;; Python

;; https://realpython.com/emacs-the-best-python-editor/

;; Installs packages
;;
;; myPackages contains a list of package names
(defvar myPackages
  '(;better-defaults                 ;; Set up some better Emacs defaults
   ;material-theme                  ;; Theme
   elpy
    )
  )

;; Scans the list in myPackages
;; If the package listed is not already installed, install it
(mapc #'(lambda (package)
          (unless (package-installed-p package)
            (package-install package)))
      myPackages)

(elpy-enable)

;; Ipython in PATH is required

(require 'anaconda-mode)
(setq python-shell-interpreter "ipython"
      python-shell-interpreter-args "-i --simple-prompt --pylab=inline"
      )

(add-hook 'python-mode-hook 'anaconda-mode)


;; Auto complete
(use-package auto-complete :ensure t)
(require 'auto-complete-config)
(ac-config-default)


;; Themes

;(add-to-list 'load-path "~/.emacs.d/extra/")
;(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
(load-theme 'spacemacs-dark t)


;; Miscellany

(fset 'yes-or-no-p 'y-or-n-p)

;; Personal

(setq user-full-name "Jean Arreola")
(setq user-mail-address "jean.arreola@yahoo.com.mx")


;; Restart emacs

(use-package restart-emacs :ensure t)


;; IDO
(require 'ido)
(ido-mode t)


;; Set the frame title as by http://www.emacswiki.org/emacs/FrameTitle
(setq frame-title-format (list "%b ☺ " (user-login-name) "@" (system-name) "%[ - GNU %F " emacs-version)
      icon-title-format (list "%b ☻ " (user-login-name) "@" (system-name) " - GNU %F " emacs-version))



;; CSV

(use-package csv-mode
  :ensure t
  :mode "\\.[PpTtCc][Ss][Vv]\\'"

  :config
  (progn
    (setq csv-separators '("," ";" "|" " " "\t"))
    )
  )


;; Scroll down

(setq scroll-down-aggressively 0.01)


;; no startup msg  
(setq inhibit-startup-message t)

; Set default directory 
;(setq default-directory "C://Users//jmarrtra//" )
(setq default-directory "C://Users//jeana//Documents//" )



(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(restart-emacs anaconda-mode polymode spacemacs-theme use-package ess-smart-underscore auto-complete)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
