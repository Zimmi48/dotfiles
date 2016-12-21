
;; Manually added options

(electric-indent-mode -1) ; Disable eletric ident

(setq-default indent-tabs-mode nil) ; Never use tabs

;; MELPA

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
(package-initialize)

;; Modes

;; Proof General (manually compiled)
(load "~/.emacs.d/lisp/PG/generic/proof-site")

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
