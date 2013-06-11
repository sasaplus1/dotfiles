;---------------------------------------------------------------------
; 外観・動作
;---------------------------------------------------------------------

;;; インクリメンタルサーチ
(require "isearch")

;;; タイトルバーの変更
(setq title-bar-format "%p - %b")

;;; ステータスバーの変更
(setq *status-bar-format* "ut")

;;; バッファの移動をバッファバーの順番にする
(setq *next-buffer-in-tab-order* t)

;;; いちいち対応する括弧に飛ばない
(setq *show-matched-parenthesis* nil)

;---------------------------------------------------------------------
; ファイラ
;---------------------------------------------------------------------

;;; ごみ箱を使って削除
(setq *filer-use-recycle-bin* t)

;;; ネットワークドライブに接続
(define-key filer-keymap '(#\C-c #\c) 'network-connect-dialog)

;;; ネットワークドライブに切断
(define-key filer-keymap '(#\C-c #\d) 'network-disconnect-dialog)

;;; ファイラの初期マスク
(setq *filer-primary-file-mask* '("*"))
(setq *filer-secondary-file-mask* '("*"))

;;; ファイラのマスクリスト
(setq *filer-path-masks* '(("すべてのファイル" "*")))

;;; ファイラの初期ディレクトリ
(setq *filer-primary-directory* (get-special-folder-location :desktop))
(setq *filer-secondary-directory* (si:system-root))

;---------------------------------------------------------------------
; インデント
;---------------------------------------------------------------------

;;; c-modeのインデント設定
(setq c-indent-level 2)
(setq c-label-offset 0)
(setq c-continued-statement-offset 0)
(setq *c-indent-tabs-mode* nil)
(add-hook '*c-mode-hook* #'(lambda () (set-tab-columns 2)))

;;; c++-modeのインデント設定
(setq c++-indent-level 2)
(setq c++-label-offset 0)
(setq c++-continued-statement-offset 0)
(setq *c++-indent-tabs-mode* nil)
(add-hook '*c++-mode-hook* #'(lambda () (set-tab-columns 2)))

;;; java-modeのインデント設定
(in-package "editor")
(setq java-indent-level 2)
(setq java-label-offset 0)
(setq java-comment-indent 1)
(setq java-continued-statement-offset 0)
(setq *java-indent-tabs-mode* nil)
(add-hook '*java-mode-hook* #'(lambda () (set-tab-columns 2)))
(in-package "user")

;;; css-modeのインデント設定
(setq *css-indent-level* 8)
(setq *css-continued-statement-offset* 0)
(setq *css-indent-tabs-mode* t)
(add-hook '*css-mode-hook* #'(lambda () (set-tab-columns 8)))

;---------------------------------------------------------------------
; 追加機能
;---------------------------------------------------------------------

;;; xyzzy wiki
;;; パラメータですべてのエンコードを使用可能に
(do-symbols (i (find-package "editor"))
  (when (string-match "\\*encoding-\\(.*\\)\\*" (symbol-name i))
    (setf (gethash (match-string 1) *mime-charset-name-hash-table*)
	  (symbol-value i))))

;---------------------------------------------------------------------

;;; xyzzyの使い方が分からぬやし 励ましあえ その9 : 904
;;; 半角スペースでオートインデント
(defun newline-and-imitate-indent (&optional (arg 1))
  (interactive "*p")
  (let (indent)
    (save-excursion
      (goto-bol)
      (when (looking-at "^[ 　\t]+")
	(setq indent (match-string 0))))
    (dotimes (i arg)
      (insert "\n" (or indent "")))))

(global-set-key '(#\C-x #\LFD) 'newline-and-imitate-indent)

;---------------------------------------------------------------------

;;; xyzzy note2
;;; ウィンドウ分割時に他のバッファを表示
(defun my-split-window (&optional arg vertical)
  (interactive)
  (split-window arg vertical)
  (switch-to-buffer-other-window (other-buffer)))

(defun my-split-window-vertically (&optional arg)
  (interactive)
  (my-split-window arg t))

(define-key ctl-x-map #\2 'my-split-window)
(define-key ctl-x-map #\5 'my-split-window-vertically)

;---------------------------------------------------------------------

;;; xyzzy Part14
;;; 最近使ったファイルダイアログ改
(defvar *list-file-numbers* 100)
(defun list-file ()
  (interactive)
  (let ((hist (subseq *minibuffer-file-name-history* 0
		      (min (length *minibuffer-file-name-history*)
			   *list-file-numbers*)))) ;; リストの数
    (multiple-value-bind (result data)
	(dialog-box '(dialog 0 0 262 148
		      (:caption "最近使ったファイル") ;; ポップアップのキャプション
		      (:font 10 "ＭＳ Ｐゴシック") ;; フォント設定
		      (:control
		       (:listbox files nil #x50b10101 7 7 248 115)
		       (:button IDOK "OK" #x50010001 148 128 50 14)
		       (:button IDCANCEL "キャンセル" #x50010000 205 128 50 14)))
		    (list (cons 'files hist))
		    '((files :must-match t :enable (IDOK))))
      (when result
	(let ((file (cdar data)))
	  ;; ファイルを開く
	  (when (file-exist-p file)
	    (find-file file)
	    (add-history file '*minibuffer-file-name-history*)))))))

(global-set-key '(#\C-x #\l) 'list-file)

;---------------------------------------------------------------------

;;; xyzzy wiki 質問箱/42
;;; C-x C-k C-fでバッファの文字コードを変更
(global-set-key '(#\C-x #\C-k #\C-f) #'(lambda (encoding)
					 (interactive "zEncoding: ")
					 (revert-buffer encoding)))

;---------------------------------------------------------------------

;;; xyzzyの音
;;; 一画面ファイラの表示
(defun open-single-filer ()
  (interactive)
  (toggle-ime nil)
  (multiple-value-bind (files result)
      (filer nil t nil nil)
    (when result
      (dolist (f files t)
	(unless (file-directory-p f)
	  (find-file f)
	  (add-history f '*minibuffer-file-name-history*))))))

(global-set-key '(#\C-c #\f) 'open-single-filer)

;---------------------------------------------------------------------

;;; xyzzyの音
;;; *scratch*バッファを消す
(defun kill-scratch-buffer ()
  (interactive)
  (let ((*kill-buffer-kills-scratch* t))
    (switch-to-buffer "*scratch*")
    (delete-buffer (selected-buffer))))
; *scratch* バッファをつくる
(defun make-scratch-buffer ()
  (interactive)
  (set-buffer (switch-to-buffer "*scratch*"))
  (execute-extended-command 'lisp-interaction-mode)
  (setq need-not-save t))
; *scratch* バッファ表示切替え
(defun toggle-scratch-buffer ()
  (interactive)
  (let ((r nil))
    (dolist (buf (buffer-list))
      (when (string= (buffer-name buf) "*scratch*")
	(setq r t)))
    (if r (kill-scratch-buffer)
      (make-scratch-buffer))))

(global-set-key '(#\C-x #\C-\\) 'toggle-scratch-buffer)

;---------------------------------------------------------------------

;;; xyzzyの音
;;; lisp-modeの強調表示
(in-package "editor")
(defvar *lisp-keyword-hash-table* nil)

(defun use-lisp-keyword ()
  "キーワード色付け"
  (if (null *lisp-keyword-hash-table*)
      (setq *lisp-keyword-hash-table*
            (load-keyword-file "lisp")))
  (when *lisp-keyword-hash-table*
    (make-local-variable 'keyword-hash-table)
    (setq keyword-hash-table *lisp-keyword-hash-table*)))

(add-hook '*lisp-mode-hook*
	  #'(lambda ()
	      (use-lisp-keyword)
	      (define-key *lisp-mode-map* #\C-. 'lisp-complete-symbol)))

(add-hook '*lisp-interaction-mode-hook*
	  #'(lambda ()
	      (use-lisp-keyword)
	      (define-key *lisp-interaction-mode-map* #\C-. 'lisp-complete-symbol)))

(in-package "user")

;---------------------------------------------------------------------

;;; winapi
(require "wip/winapi")

(c:define-dll-entry winapi:BOOL SetWindowPos
  (winapi:HWND winapi:HWND c:int c:int c:int c:int winapi:UINT) "user32")

(c:define-dll-entry winapi:LONG GetWindowLong
  (winapi:HWND c:int) "user32" "GetWindowLongA")

;---------------------------------------------------------------------

;;; ウィンドウの位置を固定
(defun set-xyzzy-position ()
  (interactive)
  (SetWindowPos (get-window-handle) 0 0 0 800 600 0))

(global-set-key '(#\C-x #\W) 'set-xyzzy-position)

;---------------------------------------------------------------------

;;; ウィンドウの最前面化
(defun toggle-top-most-xyzzy ()
  (interactive)
  (if (zerop (logand (GetWindowLong (get-window-handle) -20) 8))
      (SetWindowPos (get-window-handle) -1 0 0 0 0 3)
    (SetWindowPos (get-window-handle) -2 0 0 0 0 3)))

(global-set-key '(#\C-x #\ESC #\ESC) 'toggle-top-most-xyzzy)
