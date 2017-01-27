
;; Manually added options

(electric-indent-mode -1) ; Disable eletric ident

(setq-default indent-tabs-mode nil) ; Never use tabs

;; MELPA

;(package-initialize)

;; I can avoid MELPA entirely by simply installing packages from emacsPackagesNg with nix-env

;; Modes

;; Load Tuareg with .ml4 files
(setq auto-mode-alist
  (cons '("\\.ml[iylp4]?$" . tuareg-mode) auto-mode-alist))

;; Merlin
(autoload 'merlin-mode "merlin" "Merlin mode" t)
(add-hook 'tuareg-mode-hook 'merlin-mode)
(add-hook 'caml-mode-hook 'merlin-mode)
(add-hook 'merlin-mode-hook #'company-mode)
(with-eval-after-load 'company
  (add-to-list 'company-backends 'merlin-company-backend))

;; Proof General (installed with the command: nix-env -f "<unstable>" -iA emacsPackages.proofgeneral)
(load "ProofGeneral/generic/proof-site")

;; Load Company-Coq with .v files
(add-hook 'coq-mode-hook #'company-coq-mode)

;; elm-mode customization
(setq elm-format-on-save t)
(setq elm-format-command "elm-format-0.18")
(add-hook 'elm-mode-hook #'company-mode)
(with-eval-after-load 'company
  (add-to-list 'company-backends 'company-elm))

;; Automatically added custom settings. Don't touch!

(custom-set-variables
 '(inhibit-startup-screen t)
 '(safe-local-variable-values
   (quote
    ((eval progn
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
(custom-set-faces)
