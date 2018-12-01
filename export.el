;; install.el で入れたパッケージを有効にする
(require 'package)
(package-initialize)



;;; バックアップファイルを作らない設定
(setq make-backup-files nil)
(setq auto-save-default nil)

;; bibtex2html のインストールが必要
(add-to-list 'load-path nil)
(require 'ox-bibtex)
(setq org-html-htmlize-output-type 'css)

;; スタイルシートなどヘッダーの設定
(setq org-html-head
"<link rel=\"stylesheet\" type=\"text/css\" href=\"css/org.css\"/>
 <link href=\"css/code.css\" rel=\"stylesheet\">
 <script async src=\"https://www.googletagmanager.com/gtag/js?id=UA-123741131-1\"></script>
 <script>window.dataLayer = window.dataLayer || []; function gtag(){dataLayer.push(arguments);} gtag('js', new Date()); gtag('config', 'UA-123741131-1'); </script>
"
)

