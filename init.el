;;; MY CONFIGURATION FOR EMACS


;See https://emacs.stackexchange.com/questions/5828/why-do-i-have-to-add-each-package-to-load-path-or-problem-with-require-package
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
(add-to-list 'package-archives '("elpy" . "https://jorgenschaefer.github.io/packages/"))

;; Trick for melpa
(when (>= emacs-major-version 24)
  (require 'package)
  (package-initialize)
  (add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
  )


; Use "package" to install "use-package", a better package management and config system
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))


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
;; (use-package tex
;;   :ensure auctex
;;   :config
;;   (setq Tex-auto-save t)
;;   (setq Tex-parse-self t)
;;   (setq TeX-save-query nil)
;;   (add-hook 'LaTeX-mode-hook 'turn-on-reftex)
;;   (setq reftex-plug-into-AUCTeX t)
;;   (setq reftex-default-bibliography '("C:\texlive\texmf-local\bibtex\bib\locall\library.bib")))

(use-package tex-site
  :ensure auctex
  :mode ("\\.tex\\'" . latex-mode)
  :config
  (setq TeX-auto-save t)
  (setq TeX-parse-self t)
  (setq-default TeX-master nil)
  (add-hook 'LaTeX-mode-hook
            (lambda ()
              (rainbow-delimiters-mode)
              (company-mode)
              (smartparens-mode)
              (turn-on-reftex)
              (setq reftex-plug-into-AUCTeX t)
              (reftex-isearch-minor-mode)
              (setq TeX-PDF-mode t)
              (setq TeX-source-correlate-method 'synctex)
              (setq TeX-source-correlate-start-server t)))

;; Update PDF buffers after successful LaTeX runs
(add-hook 'TeX-after-TeX-LaTeX-command-finished-hook
	  #'TeX-revert-document-buffer)

;; to use pdfview with auctex
(add-hook 'LaTeX-mode-hook 'pdf-tools-install)

;; to use pdfview with auctex
(setq TeX-view-program-selection '((output-pdf "pdf-tools"))
       TeX-source-correlate-start-server t)
(setq TeX-view-program-list '(("pdf-tools" "TeX-pdf-tools-sync-view"))))


;; Tex compilation

;; Escape mode
(defun TeX-toggle-escape nil
  (interactive)
  "Toggle Shell Escape"
  (setq LaTeX-command
        (if (string= LaTeX-command "latex") "latex -shell-escape"
          "latex"))
  (message (concat "shell escape "
                   (if (string= LaTeX-command "latex -shell-escape")
                       "enabled"
                     "disabled"))
           )
  )
;;(add-to-list 'TeX-command-list
;;             '("Make" "make" TeX-run-command nil t))
(setq TeX-show-compilation nil)

;; Redine TeX-output-mode to get the color !
(define-derived-mode TeX-output-mode TeX-special-mode "LaTeX Output"
  "Major mode for viewing TeX output.
  \\{TeX-output-mode-map} "
  :syntax-table nil
  (set (make-local-variable 'revert-buffer-function)
       #'TeX-output-revert-buffer)

  (set (make-local-variable 'font-lock-defaults)
       '((("^!.*" . font-lock-warning-face) ; LaTeX error
          ("^-+$" . font-lock-builtin-face) ; latexmk divider
          ("^\\(?:Overfull\\|Underfull\\|Tight\\|Loose\\).*" . font-lock-builtin-face)
          ;; .....
          )))

  ;; special-mode makes it read-only which prevents input from TeX.
  (setq buffer-read-only nil))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; Themes

;(add-to-list 'load-path "~/.emacs.d/extra/")
;(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
(load-theme 'spacemacs-dark t)


;; Miscellany

(fset 'yes-or-no-p 'y-or-n-p)

;; Personal

(setq user-full-name "Jean Arreola")
(setq user-mail-address "jean.arreola@yahoo.com.mx")


;; Fill Mode

(use-package fill
  :ensure nil
  :bind
  ("C-c F" . auto-fill-mode)
  ;("C-c T" . toggle-truncate-lines)
  :init (add-hook 'org-mode-hook 'turn-on-auto-fill)
  :diminish auto-fill>-mode)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;          ORG MODE        ;;;;;;;;;;;;;;;;;;;;;

(global-set-key (kbd "C-c l") 'org-store-link)
(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c c") 'org-capture)
(setq org-log-done 'time)

(setq org-agenda-files (list "C:/Users/Jean/Documents/Agenda/Cimat.org"
                             "C:/Users/Jean/Documents/Agenda/Trabajo.org"
                             "C:/Users/Jean/Documents/Agenda/Personal.org"))

; Enable Languages

(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;          BASH ON WINDOWS ON EMACS        ;;;;;;;;;;;;;;;;;;;;;

;; (defun my-bash-on-windows-shell ()
;;   (let ((explicit-shell-file-name "C:/Windows/System32/bash.exe"))
;;     (shell)))
;; (my-bash-on-windows-shell)
; PS1='\u@\h:\w\$ '

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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Company  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package company
  :ensure t
  :diminish
  :init
  (setq company-dabbrev-ignore-case t
        company-show-numbers t)
  (add-hook 'after-init-hook 'global-company-mode)
  :config
  (add-to-list 'company-backends 'company-math-symbols-unicode)
  (setq company-idle-delay t)
  (setq company-tooltip-limit 10)
  (setq company-minimum-prefix-length 3)
  :bind ("C-:" . company-complete)  ; In case I don't want to wait
  )


(use-package company-quickhelp
  :ensure t
  :config
  (company-quickhelp-mode 1))

(use-package company-shell
  :ensure t
  :after company
  :config
  (add-to-list 'company-backends '(company-shell company-shell-env)))


(use-package company-statistics
  :after company
  :init
  (add-hook 'after-init-hook 'company-statistics-mode))


(use-package auctex-latexmk
  :ensure t
  :after auctex
  :init (add-hook 'LaTeX-mode-hook 'auctex-latexmk-setup))

(use-package company-auctex
  :ensure t
  :after (company auctex)
  :config
  (company-auctex-init))


(use-package company-bibtex
  :ensure t
  :after (company auctex)
  :config
  (add-to-list 'company-backends 'company-bibtex))


;; (use-package company-math
;;   :ensure t
;;   :after (company auctex)
;;   :config
;;   ;; global activation of the unicode symbol completion
;;   (add-to-list 'company-backends 'company-math-symbols-unicode))


;; Things done when a file is saved

;; No whitespaces at end

(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; Update changes (no emacs)

(global-auto-revert-mode t)

;; Last position

(save-place-mode 1)
(setq save-place-forget-unreadable-files t
      save-place-skip-check-regexp "\\`/\\(?:cdrom\\|floppy\\|mnt\\|/[0-9]\\|\\(?:[^@/:]*@\\)?[^@/:]*[^@/:.]:\\)")




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; UTF8

;; (when (fboundp 'set-charset-priority)
;;   (set-charset-priority 'unicode))
;; (prefer-coding-system 'utf-8)
;; (set-language-environment    'utf-8)
;; (setq locale-coding-system 'utf-8)
;; (set-default-coding-systems 'utf-8)
;; (set-terminal-coding-system 'utf-8)
;; (set-keyboard-coding-system 'utf-8)
;; (setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING))
;; (set-selection-coding-system 'utf-8)
;; (setq-default buffer-file-coding-system 'utf-8)
;; (set-input-method nil)



;; Accents

(load-library "iso-transl")


(tool-bar-mode -1)                                ; No quiero toolbar
(menu-bar-mode -1)                                ; O menubar
(unless (frame-parameter nil 'tty)                ; O scrollbar
    (scroll-bar-mode -1))
(blink-cursor-mode -1)                            ; No quiero que parpadee el cursor

;;;;;;;;;;;;;;;;;;;;;;;;;;;  Perspective    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package perspective
  :ensure t
  :init (persp-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;  Dashboard    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook))



; Update banner

;; Set the title
(setq dashboard-banner-logo-title "Welcome Jean!!!")
;; Set the banner
(setq dashboard-startup-banner 'logo)
;; Value can be 'official which displays the official emacs logo 'logo
;; which displays an alternative emacs logo 1, 2 or 3 which displays
;; one of the text banners "path/to/your/image.png" which displays
;; whatever image you would prefer

;; Content is not centered by default. To center, set
(setq dashboard-center-content t)

;; To disable shortcut "jump" indicators for each section, set
(setq dashboard-show-shortcuts nil)


; Customize which widgets are displayed

(setq dashboard-items '((recents  . 5)
                        (bookmarks . 5)
                        (projects . 5)
                        (agenda . 5)
                        (registers . 5)))


;; Custom widget

;; (defun dashboard-insert-custom (list-size)
;;   (insert "Custom text"))
;; (add-to-list 'dashboard-item-generators  '(custom . dashboard-insert-custom))
;; (add-to-list 'dashboard-items '(custom) t)


; Today's agenda

(add-to-list 'dashboard-items '(agenda) t)

; Agenda for upcoming seven days

(setq show-week-agenda-p t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  Windmove  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(when (fboundp 'windmove-default-keybindings)
  (windmove-default-keybindings))


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

;;;;;;;;;;;;;;;;;;;;;  Aggresive indent   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; (require 'aggressive-indent)
; (global-aggressive-indent-mode 1)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;  Restart Emacs  ;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package restart-emacs)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


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

;; https://github.com/chuvanan/dot-files/blob/master/emacs-init.el
(setq inferior-R-args "--no-restore-history --no-save")

;; syntax highlight
(setq ess-R-font-lock-keywords
      (quote
       ((ess-R-fl-keyword:modifiers . t)
        (ess-R-fl-keyword:fun-defs . t)
        (ess-R-fl-keyword:keywords . t)
        (ess-R-fl-keyword:assign-ops)
        (ess-R-fl-keyword:constants . t)
        (ess-fl-keyword:fun-calls . t)
        (ess-fl-keyword:numbers . t)
        (ess-fl-keyword:operators)
        (ess-fl-keyword:delimiters)
        (ess-fl-keyword:=)
        (ess-R-fl-keyword:F&T)
        (ess-R-fl-keyword:%op%))))

(setq inferior-ess-r-font-lock-keywords
      (quote
       ((ess-S-fl-keyword:prompt . t)
        (ess-R-fl-keyword:messages . t)
        (ess-R-fl-keyword:modifiers . t)
        (ess-R-fl-keyword:fun-defs . t)
        (ess-R-fl-keyword:keywords . t)
        (ess-R-fl-keyword:assign-ops)
        (ess-R-fl-keyword:constants . t)
        (ess-fl-keyword:matrix-labels)
        (ess-fl-keyword:fun-calls)
        (ess-fl-keyword:numbers)
        (ess-fl-keyword:operators)
        (ess-fl-keyword:delimiters)
        (ess-fl-keyword:=)
        (ess-R-fl-keyword:F&T))))

;; %>% operator
(defun anchu/isnet_then_R_operator ()
  "R - %>% operator or 'then' pipe operator"
  (interactive)
  (just-one-space 1)
  (insert "%>%")
  (reindent-then-newline-and-indent))

(define-key ess-mode-map (kbd "C-S-m") 'anchu/isnet_then_R_operator)
(define-key inferior-ess-mode-map (kbd "C-S-m") 'anchu/isnet_then_R_operator)


(defun anchu/ess-rmarkdown ()
  "Compile R markdown (.Rmd). Should work for any output type."
  (interactive)
  ;; Check if attached R-session
  (condition-case nil
      (ess-get-process)
    (error
     (ess-switch-process)))
  (let* ((rmd-buf (current-buffer)))
    (save-excursion
      (let* ((sprocess (ess-get-process ess-current-process-name))
             (sbuffer (process-buffer sprocess))
             (buf-coding (symbol-name buffer-file-coding-system))
             (R-cmd
              (format "library(rmarkdown); rmarkdown::render(\"%s\")"
                      buffer-file-name)))
        (message "Running rmarkdown on %s" buffer-file-name)
        (ess-execute R-cmd 'buffer nil nil)
        (switch-to-buffer rmd-buf)
        (ess-show-buffer (buffer-name sbuffer) nil)))))

(define-key polymode-mode-map "\M-ns" 'anchu/ess-rmarkdown)

(defun anchu/ess-rshiny ()
  "Compile R markdown (.Rmd). Should work for any output type."
  (interactive)
  ;; Check if attached R-session
  (condition-case nil
      (ess-get-process)
    (error
     (ess-switch-process)))
  (let* ((rmd-buf (current-buffer)))
    (save-excursion
      (let* ((sprocess (ess-get-process ess-current-process-name))
             (sbuffer (process-buffer sprocess))
             (buf-coding (symbol-name buffer-file-coding-system))
             (R-cmd
              (format "library(rmarkdown); rmarkdown::run(\"%s\")"
                      buffer-file-name)))
        (message "Running shiny on %s" buffer-file-name)
        (ess-execute R-cmd 'buffer nil nil)
        (switch-to-buffer rmd-buf)
        (ess-show-buffer (buffer-name sbuffer) nil)))))

(define-key polymode-mode-map "\M-nr" 'anchu/ess-rshiny)

(defun anchu/ess-publish-rmd ()
  "Publish R Markdown (.Rmd) to remote server"
  (interactive)
  ;; Check if attached R-session
  (condition-case nil
      (ess-get-process)
    (error
     (ess-switch-process)))
  (let* ((rmd-buf (current-buffer)))
    (save-excursion
      ;; assignment
      (let* ((sprocess (ess-get-process ess-current-process-name))
             (sbuffer (process-buffer sprocess))
             (buf-coding (symbol-name buffer-file-coding-system))
             (R-cmd
              (format "workflow::wf_publish_rmd(\"%s\")"
                      buffer-file-name)))
        ;; execute
        (message "Publishing rmarkdown on %s" buffer-file-name)
        (ess-execute R-cmd 'buffer nil nil)
        (switch-to-buffer rmd-buf)
        (ess-show-buffer (buffer-name sbuffer) nil)))))

(define-key polymode-mode-map "\M-np" 'anchu/ess-publish-rmd)

(defun anchu/insert-minor-section ()
  "Insert minor section heading for a snippet of R codes."
  (interactive)
  (insert "## -----------------------------------------------------------------------------\n")
  (insert "## "))

(define-key ess-mode-map (kbd "C-c C-a n") 'anchu/insert-minor-section)

(defun anchu/insert-r-code-chunk ()
  "Insert R Markdown code chunk."
  (interactive)
  (insert "```{r, include=FALSE}\n")
  (insert "\n")
  (save-excursion
    (insert "\n")
    (insert "\n")
    (insert "```\n")))

(define-key polymode-mode-map (kbd "C-c C-a c") 'anchu/insert-r-code-chunk)

(defun anchu/insert-major-section ()
  "Insert major section heading for a block of R codes."
  (interactive)
  (insert "## -----------------------------------------------------------------------------\n")
  (insert "## ")
  (save-excursion
    (insert "\n")
    (insert "## -----------------------------------------------------------------------------\n")))

(define-key ess-mode-map (kbd "C-c C-a m") 'anchu/insert-major-section)

(defun anchu/insert-resource-header ()
  "Insert yaml-like header for R script resources."
  (interactive)
  (insert "## -----------------------------------------------------------------------------\n")
  (insert "## code: ")
  (save-excursion
    (insert "\n")
    (insert "## description: \n")
    (insert "## author: \n")
    (insert (concat "## date: " (current-time-string) "\n"))
    (insert "## -----------------------------------------------------------------------------\n")))

(define-key ess-mode-map (kbd "C-c C-a r") 'anchu/insert-resource-header)

(defun anchu/insert-yalm-header ()
  "Insert Rmd header."
  (interactive)
  (insert "---\n")
  (insert "title: ")
  (save-excursion
    (newline)
    (insert "author: \n")
    (insert "date: \"`r format(Sys.time(), '%d-%m-%Y %H:%M:%S')`\"\n")
    (insert "runtime: shiny\n")
    (insert "output:\n")
    (indent-to-column 4)
    (insert "html_document:\n")
    (indent-to-column 8)
    (insert "theme: flatly\n")
    (insert "---")
    (newline)))

(define-key polymode-mode-map (kbd "C-c C-a y") 'anchu/insert-yalm-header)

(defun anchu/insert-named-comment (cmt)
  "Make comment header"
  (interactive "sEnter your comment: ")
  (let* ((user-cmt (concat "## " cmt " "))
         (len-user-cmt (length user-cmt))
         (len-hyphen (- 80 len-user-cmt)))
    (insert user-cmt (apply 'concat (make-list len-hyphen "-")))
    (newline)
    (newline)
    )
  )

(define-key ess-mode-map (kbd "C-c C-a d") 'anchu/insert-named-comment)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;,





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

;;;;;;;;;;;;;;;;;;;;;;;;   MAGIT   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;,,,,,

;; https://github.com/inkel/emacs-d/blob/master/init.el

;;;; magit
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;   PYTHON   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;,,,,,

;; Based on https://realpython.com/emacs-the-best-python-editor/

(add-to-list 'load-path
              "~/.emacs.d/plugins/yasnippet")
(require 'yasnippet)
(yas-global-mode 1)

(defvar myPackages
  '(better-defaults
    ein ;; add the ein package (Emacs ipython notebook)
    elpy
    ;;flycheck
    ;;py-autopep8
    material-theme))

(elpy-enable)
(setq python-shell-interpreter "ipython"
      python-shell-interpreter-args "-i --simple-prompt --pylab=inline")

;; Better Syntax Checking
;(when (require 'flycheck nil t)
;  (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
;  (add-hook 'elpy-mode-hook 'flycheck-mode))

;(setq flycheck-check-syntax-automatically '(mode-enabled save idle-change))
;(setq flycheck-highlighting-mode 'lines)
;(setq flycheck-indication-mode 'left-fringe)
;(setq flycheck-checker-error-threshold 2000)


;; PEP8 Compliance

;(add-to-list 'load-path
;              "~/.emacs.d/elpa/py-autopep8.el")
;(require 'py-autopep8)
;(add-hook 'elpy-mode-hook 'py-autopep8-enable-on-save)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;; Anaconda mode  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(add-to-list 'load-path "~/.emacs.d/anaconda-mode/anaconda-mode.el")
(add-hook 'python-mode-hook 'anaconda-mode)
(add-hook 'python-mode-hook 'anaconda-eldoc-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;; Dimmer  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Indicates which buffer is currently active

;; (use-package dimmer
;;   :ensure t)
;; (dimmer-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;; Emojify  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; (add-hook 'after-init-hook #'global-emojify-mode)

; Custom emojis

;; (setq emojify-user-emojis '((":trollface:" . (("name" . "Troll Face")
;;                                               ("image" . "~/.emacs.d/emojis/trollface.png")
;;                                               ("style" . "github")))
;;                             (":neckbeard:" . (("name" . "Neckbeard")
;;                                               ("image" . "~/.emacs.d/emojis/neckbeard.png")
;;                                               ("style" . "github")))))

;; If emojify is already loaded refresh emoji data
;; (when (featurep 'emojify)
;;   (emojify-set-emoji-data))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;; Nyan mode  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (require 'nyan-mode)
;; (nyan-mode)
;; (setq-default nyan-animate-nyancat nil)
;; (setq-default nyan-animation-frame-interval 0.2)
;; (setq-default nyan-bar-length 20)
;; (setq-default nyan-cat-face-number 1)
;; (setq-default nyan-wavy-trail t)
;; (setq-default nyan-minimum-window-width 50)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;  Mode - icons    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'mode-icons)
(mode-icons-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;  Discover my major    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'discover-my-major)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;  LILYPOND    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq load-path (append (list (expand-file-name "~/.emacs.d/lilypond")) load-path))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;  C ++  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(add-hook 'c++-mode-hook 'irony-mode)
(add-hook 'c-mode-hook 'irony-mode)

(defun my-irony-mode-hook ()
  (define-key irony-mode-map
      [remap completion-at-point] 'counsel-irony)
  (define-key irony-mode-map
      [remap complete-symbol] 'counsel-irony))
(add-hook 'irony-mode-hook 'my-irony-mode-hook)
(add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; IDO
(require 'ido)
(ido-mode t)

; syntax highlighting everywhere
(global-font-lock-mode 1)

; Add proper word wrapping
(global-visual-line-mode t)

;; Set the frame title as by http://www.emacswiki.org/emacs/FrameTitle
(setq frame-title-format (list "%b ☺ " (user-login-name) "@" (system-name) "%[ - GNU %F " emacs-version)
      icon-title-format (list "%b ☻ " (user-login-name) "@" (system-name) " - GNU %F " emacs-version))

;; Color parenthesis

(use-package rainbow-delimiters
  :ensure t
  :commands rainbow-delimiters-mode
  :init
  (add-hook 'prog-mode-hook #'rainbow-delimiters-mode)
  (add-hook 'LaTex-mode-hook #'rainbow-delimiters-mode)
  (add-hook 'org-mode-hook #'rainbow-delimiters-mode))

;; Visualize colors

(use-package rainbow-mode
  :ensure t
  :config
  (setq rainbow-x-colors nil)
  :hook (prog-mode . rainbow-delimiters-mode))

; which key for suggestions


(use-package which-key
  :ensure t
  :diminish which-key-mode
  :config
  ;; Reemplaza como KEY se muestra en pantalla
  ;;   KEY → FUNCTION
  ;; Eg: "C-c", display "right → winner-redo" as "▶ → winner-redo"
  (setq which-key-key-replacement-alist
        '(("<\\([[:alnum:]-]+\\)>" . "\\1")
          ("left"                  . "◀")
          ("right"                 . "▶")
          ("up"                    . "▲")
          ("down"                  . "▼")
          ("delete"                . "DEL") ; delete key
          ("\\`DEL\\'"             . "BS") ; backspace key
          ("next"                  . "PgDn")
          ("prior"                 . "PgUp"))

        ;; List of "special" keys for which a KEY is displayed as just
        ;; K but with "inverted video" face... not sure I like this.
        which-key-special-keys '("RET" "DEL" ; delete key
                                 "ESC" "BS" ; backspace key
                                 "SPC" "TAB")

        ;; Replacements for how part or whole of FUNCTION is replaced:
        which-key-description-replacement-alist
        '(("Prefix Command" . "prefix")
          ("\\`calc-"       . "") ; Hide "calc-" prefixes when listing M-x calc keys
          ("\\`projectile-" . "𝓟/")
          ("\\`org-babel-"  . "ob/"))

        ;; Underlines commands to emphasize some functions:
        which-key-highlighted-command-list
        '("\\(rectangle-\\)\\|\\(-rectangle\\)"
          "\\`org-"))


  (which-key-mode)
  (which-key-setup-minibuffer))



;; CSV

(use-package csv-mode
  :ensure t
  :mode "\\.[PpTtCc][Ss][Vv]\\'"

  :config
  (progn
    (setq csv-separators '("," ";" "|" " " "\t"))
    )
  )


;; Cursor hasta abajo

(setq scroll-down-aggressively 0.01)



(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(TeX-source-correlate-method (quote synctex))
 '(TeX-source-correlate-mode t)
 '(TeX-source-correlate-start-server t t)
 '(custom-safe-themes
   (quote
    ("bffa9739ce0752a37d9b1eee78fc00ba159748f50dc328af4be661484848e476" "bf3ec301ea82ab546efb39c2fdd4412d1188c7382ff3bbadd74a8ecae4121678" "d737a2131d5ac01c0b2b944e0d2cb0be1c76496bb4ed61be51ff0e5457468974" default)))
 '(inferior-STA-program-name "stata-se")
 '(package-selected-packages
   (quote
    (company-math company-statistics restart-emacs discover-my-major mode-icons nyan-mode emojify dashboard page-break-lines pdf-tools ein spacemacs-theme orgalist ztree highlight-indent-guides company-anaconda anaconda-mode flycheck markdown-mode pandoc-mode ess company-jedi helm-projectile projectile elpy auctex fill-column-indicator exec-path-from-shell use-package))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
