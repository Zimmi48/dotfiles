;; Generic options

(electric-indent-mode -1) ; Disable eletric ident
(setq-default indent-tabs-mode nil) ; Never use tabs
(setq inhibit-startup-screen t) ; Do not show the startup screen
(tool-bar-mode -1) ; Disable the tool bar
(scroll-bar-mode -1) ; Disable the scroll bar
(setq column-number-mode t) ; Show the column number
(setq show-paren-mode t) ; Match parentheses
(setq save-abbrevs 'silently)

;; Packages
(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

;; Bootstrap `use-package'
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; Company-Mode for use with Merlin and Elm-Mode
(use-package company
  :ensure t
  :defer t
  :hook ((merlin-mode elm-mode) . company-mode)
  :config
  (add-to-list 'company-backends 'merlin-company-backend)
  (add-to-list 'company-backends 'company-elm))

;; 80-character mark
(use-package fill-column-indicator
  :ensure t
  :hook ((coq-mode elm-mode markdown-mode nix-mode tuareg-mode) . (lambda () (fci-mode 1)))
  :config (setq fci-rule-column 80))

;; Nix-Mode
(use-package nix-mode
  :ensure t
  :defer t)

;; Proof General and company-coq
(use-package proof-general
  :ensure t
  :defer t)

(use-package company-coq
  :ensure t
  :defer t
  :hook (coq-mode . company-coq-mode))

;; Tuareg
(use-package tuareg
  :ensure t
  :mode ("\\.ml[iylp4g]?$" . tuareg-mode))

(use-package merlin
  :if (executable-find "ocamlmerlin")
  :ensure t
  :init (setq merlin-command "ocamlmerlin")
  :hook (tuareg-mode . merlin-mode))

;; Elm-Mode
(use-package elm-mode
  :ensure t
  :defer t
  :init
  (setq elm-format-on-save t))

;; Markdown Mode
(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "pandoc"))

;; EditorConfig (for contributing to NixOS/nixpkgs notably)
(use-package editorconfig
  :ensure t
  :config (editorconfig-mode 1))

;; Dark theme
(use-package dracula-theme
  :ensure t)

;; Package for Coq development

(require 'coqdev nil t)
(add-to-list 'load-path "~/git/coq/dev/tools/")
(require 'coqdev)

(load "~/git/bot/dev.el")

;; Automatically added custom settings. Don't touch!

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (dracula-theme editorconfig markdown-mode elm-mode merlin tuareg company-coq proof-general nix-mode fill-column-indicator company use-package)))
 '(safe-local-variable-values
   (quote
    ((coq-prog-args "-coqlib" "../.." "-R" ".." "Coq" "-top" "Coq.Classes.CMorphisms")
     (coq-prog-args "-coqlib" "../.." "-R" ".." "Coq" "-top" "Coq.Classes.Morphisms")))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
