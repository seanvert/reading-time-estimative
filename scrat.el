;; TODO colocar um esquema para marcar com o org-noter
(define-pdf-cache-function number-of-pages)
(define-pdf-cache-function outline)
(pdf-cache-outline)

(defun get-total-pages ()
  (progn (define-pdf-cache-function number-of-pages)
		 (setq number-of-pages (pdf-cache-number-of-pages))))
;; roda essa função no modo de pdf
;; TODO checa se existe outline
(defun get-outline ()
  (progn (define-pdf-cache-function outline)
		 (setq outline (pdf-cache-outline))))

(setq skip-start-chapters '("Cover" "Title Page" "Copyright"
							"Dedication" "About The Author"
							"Foreword" "Preface" "Contents"))

(setq skip-end-chapters '("References" "Index"))
	   
;; exemplo de um pedaço
;; (((depth . 1) (type . goto-dest) (title . "Chapter 21 - Progressing As A Cognitive Behavior Therapist") (page . 380) (top . 0)))

;; default do máximo que ele vai pra dentro no índice
(setq max-depth 1)

(defun teste (outline)
  "função que pega uma entrada do outline e retorna o nome e o número da página"
  ;; TODO checar se está de acordo com o default em depth
  (if (<= (cdr (assoc 'depth outline)) max-depth)
	  ;; check membership in chapters
	  ;; TODO tirar os end chapters e analisar só até a primeira entrada
	  (if (not (member (cdr (assoc 'title outline)) (append skip-start-chapters skip-end-chapters)))
		  ;; return values
		  (list (cdr (assoc 'title outline))
				(cdr (assoc 'page outline)))
		;; TODO arrumar isso daqui e pensar num jeito melhor pra ver isso
		;; acho que chegar o end chapters seria uma boa
		"fim")))

;; TODO get pages and subtract get the total per chapter
(defun get-total-per-chapter (outl acc)
  "get pages and subtract to get the total per chapter"
  (if (= 0 (length outl))
	  acc
	(get-total-per-chapter (cdr-safe outl) (cons (list (car (car outl))
													   (- (if (cdr-safe outl)
															  (car (cdr (car (cdr outl)))) ;; next element page number
															number-of-pages) ;; (get-total-pages)) ;; TODO CONSERTAR O NÚMERO MÁGICO
														  (car (cdr (car outl))) ;; first element page number
														  )) acc))))

(setq page-rate 3)
;; TODO ajeitar isso
(setq outlineum (mapcar #'teste outline))
(setq outlineum (remove nil (mapcar #'teste outline)))
(setq outlineum (remove "fim" outlineum))
(setq outlinedois (reverse (get-total-per-chapter outlineum '())))


;; (("Chapter 21 - Progressing As A Cognitive Behavior Therapist" 34) ("Chapter 20 - Problems In Therapy" 12) ("Chapter 19 - Treatment Planning" 14) ("Chapter 18 - Termination And Relapse Prevention" 16) ("Chapter 17 - Homework" 22) ("Chapter 16 - Imagery" 17) ("Chapter 15 - Additional Cognitive And Behavioral Techniques" 21) ("Chapter 14 - Identifying And Modifying Core Beliefs" 28) ("Chapter 13 - Identifying And Modifying Intermediate Beliefs" 30) ("Chapter 12 - Responding To Automatic Thoughts" 11) ("Chapter 11 - Evaluating Automatic Thoughts" 20) ("Chapter 10 - Identifying Emotions" 9) ("Chapter 9 - Identifying Automatic Thoughts" 21) ("Chapter 8 - Problems With Structuring The Therapy Session" 14) ("Chapter 7 - Session 2 And Beyond: Structure And Format" 23) ("Chapter 6 - Behavioral Activation" 20) ("Chapter 5 - Structure Of The First Therapy Session" 21) ("Chapter 4 - The Evaluation Session" 13) ("Chapter 3 - Cognitive Conceptualization" 17) ("Chapter 2 - Overview Of Treatment" 12) ("Chapter 1 - Introduction To Cognitive Behavior Therapy" 16))

(defun get-chapters-time (outline)
  "function that gets the rate and applies it to the time"
  (list (car outline)
		(* page-rate (car (cdr outline)))))

(mapcar* #'get-chapters-time outlinedois)

;; (("Chapter 1 - Introduction To Cognitive Behavior Therapy" 48) ("Chapter 2 - Overview Of Treatment" 36) ("Chapter 3 - Cognitive Conceptualization" 51) ("Chapter 4 - The Evaluation Session" 39) ("Chapter 5 - Structure Of The First Therapy Session" 63) ("Chapter 6 - Behavioral Activation" 60) ("Chapter 7 - Session 2 And Beyond: Structure And Format" 69) ("Chapter 8 - Problems With Structuring The Therapy Session" 42) ("Chapter 9 - Identifying Automatic Thoughts" 63) ("Chapter 10 - Identifying Emotions" 27) ("Chapter 11 - Evaluating Automatic Thoughts" 60) ("Chapter 12 - Responding To Automatic Thoughts" 33) ("Chapter 13 - Identifying And Modifying Intermediate Beliefs" 90) ("Chapter 14 - Identifying And Modifying Core Beliefs" 84) ("Chapter 15 - Additional Cognitive And Behavioral Techniques" 63) ("Chapter 16 - Imagery" 51) ("Chapter 17 - Homework" 66) ("Chapter 18 - Termination And Relapse Prevention" 48) ("Chapter 19 - Treatment Planning" 42) ("Chapter 20 - Problems In Therapy" 36) ("Chapter 21 - Progressing As A Cognitive Behavior Therapist" 102))

(teste (nth 8 outline))
(teste (nth 9 outline))
