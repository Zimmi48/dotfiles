;; Generic options

(electric-indent-mode -1) ; Disable eletric ident
(setq-default indent-tabs-mode nil) ; Never use tabs
(setq inhibit-startup-screen t)
(setq column-number-mode t)

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

(use-package column-marker
  :ensure t
  :init
  (add-hook 'tuareg-mode-hook
            (lambda () (interactive) (column-marker-1 80))))

;; Nix-Mode

(use-package nix-mode
  :ensure t
  :defer t)

;; Proof General is installed with Nix
(load "ProofGeneral/generic/proof-site")

(use-package company-coq
  :ensure t
  :defer t
  :init
  (add-hook 'coq-mode-hook #'company-coq-mode))

;; Company-Mode for use with Merlin and Elm-Mode
(use-package company
  :ensure t
  :defer t
  :config
  (add-to-list 'company-backends 'merlin-company-backend)
  (add-to-list 'company-backends 'company-elm))

;; Tuareg
(use-package tuareg
  :ensure t
  :mode ("\\.ml[iylp4]?$" . tuareg-mode)
  :config
  (add-hook 'tuareg-mode-hook 'merlin-mode))

;; Merlin is installed with Nix
(use-package merlin
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

;; Automatically added custom settings. Don't touch!

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages (quote (use-package)))
 '(safe-local-variable-values
   (quote
    ((coq-prog-args "-coqlib" "../.." "-R" ".." "Coq" "-top" "Coq.Classes.CMorphisms")
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
