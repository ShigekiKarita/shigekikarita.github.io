#!emacs --script

(require 'package)

;; MELPA
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Org
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)

(package-initialize)
(package-refresh-contents)

(defvar my/favorite-packages
  '(
    d-mode
    cuda-mode
    lua-mode
    yaml-mode
    org-plus-contrib

    htmlize
    spacemacs-theme
    ))

;; my/favorite-packages
(dolist (package my/favorite-packages)
  (unless (package-installed-p package)
    (package-install package)))

