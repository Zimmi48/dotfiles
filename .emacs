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
  :config
  (add-to-list 'company-backends 'merlin-company-backend)
  (add-to-list 'company-backends 'company-elm))

(use-package fill-column-indicator
  :ensure t
  :init
  (add-hook 'tuareg-mode-hook (lambda () (fci-mode 1)))
  (add-hook 'coq-mode-hook (lambda () (fci-mode 1)))
  (add-hook 'elm-mode-hook (lambda () (fci-mode 1)))
  (add-hook 'markdown-mode-hook (lambda () (fci-mode 1)))
  :config (setq fci-rule-column 80))

;; Nix-Mode
(use-package nix-mode
  :ensure t
  :defer t)

;; Proof General is not in MELPA yet
(load "~/.emacs.d/lisp/PG/generic/proof-site")

(use-package company-coq
  :ensure t
  :defer t
  :init
  (add-hook 'coq-mode-hook #'company-coq-mode))

;; Tuareg
(use-package tuareg
  :ensure t
  :mode ("\\.ml[iylp4]?$" . tuareg-mode)
  :config
  (add-hook 'tuareg-mode-hook 'merlin-mode))

;; Merlin is installed with Nix
(use-package merlin
  :init
  (setq merlin-command "ocamlmerlin")
  :config
  (add-hook 'merlin-mode-hook #'company-mode))

;; Elm-Mode
(use-package elm-mode
  :ensure t
  :defer t
  :init
  (setq elm-format-on-save t)
  (setq elm-format-command "elm-format-0.18")
  :config
  (add-hook 'elm-mode-hook #'company-mode))

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
  :config
  (editorconfig-mode 1))

;; Dark theme
(use-package dracula-theme
  :ensure t)

;; Automatically added custom settings. Don't touch!

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (editorconfig elm-mode tuareg company-coq nix-mode fill-column-indicator company use-package)))
 '(safe-local-variable-values
   (quote
    ((coq-prog-args "-coqlib" "../.." "-R" ".." "Coq" "-top" "Coq.Classes.Morphisms")
     (coq-prog-args "-coqlib" "../.." "-R" ".." "Coq" "-top" "Coq.Classes.CMorphisms")
     (TeX-master . "Reference-Manual")
     (eval let
           ((default-directory
              (locate-dominating-file buffer-file-name ".dir-locals.el")))
           (setq-local coq-prog-args
                       (\`
                        ("-coqlib"
                         (\,
                          (expand-file-name ".."))
                         "-R"
                         (\,
                          (expand-file-name "."))
                         "Coq")))
           (setq-local coq-prog-name
                       (expand-file-name "../bin/coqtop")))
     (eval progn
           (let
               ((coq-root-directory
                 (when buffer-file-name
                   (locate-dominating-file buffer-file-name ".dir-locals.el")))
                (coq-project-find-file
                 (and
                  (boundp
                   (quote coq-project-find-file))
                  coq-project-find-file)))
             (set
              (make-local-variable
               (quote tags-file-name))
              (concat coq-root-directory "TAGS"))
             (setq camldebug-command-name
                   (concat coq-root-directory "dev/ocamldebug-coq"))
             (unless coq-project-find-file
               (set
                (make-local-variable
                 (quote compile-command))
                (concat "make -C " coq-root-directory))
               (set
                (make-local-variable
                 (quote compilation-search-path))
                (cons coq-root-directory nil)))
             (when coq-project-find-file
               (setq default-directory coq-root-directory))))))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
