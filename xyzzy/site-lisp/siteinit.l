;---------------------------------------------------------------------
; �O�ρE����
;---------------------------------------------------------------------

;;; �C���N�������^���T�[�`
(require "isearch")

;;; �^�C�g���o�[�̕ύX
(setq title-bar-format "%p - %b")

;;; �X�e�[�^�X�o�[�̕ύX
(setq *status-bar-format* "ut")

;;; �o�b�t�@�̈ړ����o�b�t�@�o�[�̏��Ԃɂ���
(setq *next-buffer-in-tab-order* t)

;;; ���������Ή����銇�ʂɔ�΂Ȃ�
(setq *show-matched-parenthesis* nil)

;---------------------------------------------------------------------
; �t�@�C��
;---------------------------------------------------------------------

;;; ���ݔ����g���č폜
(setq *filer-use-recycle-bin* t)

;;; �l�b�g���[�N�h���C�u�ɐڑ�
(define-key filer-keymap '(#\C-c #\c) 'network-connect-dialog)

;;; �l�b�g���[�N�h���C�u�ɐؒf
(define-key filer-keymap '(#\C-c #\d) 'network-disconnect-dialog)

;;; �t�@�C���̏����}�X�N
(setq *filer-primary-file-mask* '("*"))
(setq *filer-secondary-file-mask* '("*"))

;;; �t�@�C���̃}�X�N���X�g
(setq *filer-path-masks* '(("���ׂẴt�@�C��" "*")))

;;; �t�@�C���̏����f�B���N�g��
(setq *filer-primary-directory* (get-special-folder-location :desktop))
(setq *filer-secondary-directory* (si:system-root))

;---------------------------------------------------------------------
; �C���f���g
;---------------------------------------------------------------------

;;; c-mode�̃C���f���g�ݒ�
(setq c-indent-level 2)
(setq c-label-offset 0)
(setq c-continued-statement-offset 0)
(setq *c-indent-tabs-mode* nil)
(add-hook '*c-mode-hook* #'(lambda () (set-tab-columns 2)))

;;; c++-mode�̃C���f���g�ݒ�
(setq c++-indent-level 2)
(setq c++-label-offset 0)
(setq c++-continued-statement-offset 0)
(setq *c++-indent-tabs-mode* nil)
(add-hook '*c++-mode-hook* #'(lambda () (set-tab-columns 2)))

;;; java-mode�̃C���f���g�ݒ�
(in-package "editor")
(setq java-indent-level 2)
(setq java-label-offset 0)
(setq java-comment-indent 1)
(setq java-continued-statement-offset 0)
(setq *java-indent-tabs-mode* nil)
(add-hook '*java-mode-hook* #'(lambda () (set-tab-columns 2)))
(in-package "user")

;;; css-mode�̃C���f���g�ݒ�
(setq *css-indent-level* 8)
(setq *css-continued-statement-offset* 0)
(setq *css-indent-tabs-mode* t)
(add-hook '*css-mode-hook* #'(lambda () (set-tab-columns 8)))

;---------------------------------------------------------------------
; �ǉ��@�\
;---------------------------------------------------------------------

;;; xyzzy wiki
;;; �p�����[�^�ł��ׂẴG���R�[�h���g�p�\��
(do-symbols (i (find-package "editor"))
  (when (string-match "\\*encoding-\\(.*\\)\\*" (symbol-name i))
    (setf (gethash (match-string 1) *mime-charset-name-hash-table*)
	  (symbol-value i))))

;---------------------------------------------------------------------

;;; xyzzy�̎g������������ʂ₵ ��܂����� ����9 : 904
;;; ���p�X�y�[�X�ŃI�[�g�C���f���g
(defun newline-and-imitate-indent (&optional (arg 1))
  (interactive "*p")
  (let (indent)
    (save-excursion
      (goto-bol)
      (when (looking-at "^[ �@\t]+")
	(setq indent (match-string 0))))
    (dotimes (i arg)
      (insert "\n" (or indent "")))))

(global-set-key '(#\C-x #\LFD) 'newline-and-imitate-indent)

;---------------------------------------------------------------------

;;; xyzzy note2
;;; �E�B���h�E�������ɑ��̃o�b�t�@��\��
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
;;; �ŋߎg�����t�@�C���_�C�A���O��
(defvar *list-file-numbers* 100)
(defun list-file ()
  (interactive)
  (let ((hist (subseq *minibuffer-file-name-history* 0
		      (min (length *minibuffer-file-name-history*)
			   *list-file-numbers*)))) ;; ���X�g�̐�
    (multiple-value-bind (result data)
	(dialog-box '(dialog 0 0 262 148
		      (:caption "�ŋߎg�����t�@�C��") ;; �|�b�v�A�b�v�̃L���v�V����
		      (:font 10 "�l�r �o�S�V�b�N") ;; �t�H���g�ݒ�
		      (:control
		       (:listbox files nil #x50b10101 7 7 248 115)
		       (:button IDOK "OK" #x50010001 148 128 50 14)
		       (:button IDCANCEL "�L�����Z��" #x50010000 205 128 50 14)))
		    (list (cons 'files hist))
		    '((files :must-match t :enable (IDOK))))
      (when result
	(let ((file (cdar data)))
	  ;; �t�@�C�����J��
	  (when (file-exist-p file)
	    (find-file file)
	    (add-history file '*minibuffer-file-name-history*)))))))

(global-set-key '(#\C-x #\l) 'list-file)

;---------------------------------------------------------------------

;;; xyzzy wiki ���┠/42
;;; C-x C-k C-f�Ńo�b�t�@�̕����R�[�h��ύX
(global-set-key '(#\C-x #\C-k #\C-f) #'(lambda (encoding)
					 (interactive "zEncoding: ")
					 (revert-buffer encoding)))

;---------------------------------------------------------------------

;;; xyzzy�̉�
;;; ���ʃt�@�C���̕\��
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

;;; xyzzy�̉�
;;; *scratch*�o�b�t�@������
(defun kill-scratch-buffer ()
  (interactive)
  (let ((*kill-buffer-kills-scratch* t))
    (switch-to-buffer "*scratch*")
    (delete-buffer (selected-buffer))))
; *scratch* �o�b�t�@������
(defun make-scratch-buffer ()
  (interactive)
  (set-buffer (switch-to-buffer "*scratch*"))
  (execute-extended-command 'lisp-interaction-mode)
  (setq need-not-save t))
; *scratch* �o�b�t�@�\���ؑւ�
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

;;; xyzzy�̉�
;;; lisp-mode�̋����\��
(in-package "editor")
(defvar *lisp-keyword-hash-table* nil)

(defun use-lisp-keyword ()
  "�L�[���[�h�F�t��"
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

;;; �E�B���h�E�̈ʒu���Œ�
(defun set-xyzzy-position ()
  (interactive)
  (SetWindowPos (get-window-handle) 0 0 0 800 600 0))

(global-set-key '(#\C-x #\W) 'set-xyzzy-position)

;---------------------------------------------------------------------

;;; �E�B���h�E�̍őO�ʉ�
(defun toggle-top-most-xyzzy ()
  (interactive)
  (if (zerop (logand (GetWindowLong (get-window-handle) -20) 8))
      (SetWindowPos (get-window-handle) -1 0 0 0 0 3)
    (SetWindowPos (get-window-handle) -2 0 0 0 0 3)))

(global-set-key '(#\C-x #\ESC #\ESC) 'toggle-top-most-xyzzy)