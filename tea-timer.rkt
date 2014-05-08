#lang racket/gui

; Format seconds to [m]m:ss
(define (time-format t)
  (let ([min (floor (/ t 60))]
        [sec (modulo t 60)])
    (string-append (number->string min) ":" (~a sec #:min-width 2 #:align 'right #:pad-string "0"))))

(define tea-alarm
  (lambda ()
    (let loop ()
      (play-sound "C:\\Windows\\Media\\notify.wav" #f)
      (loop))))

(define (create-button p l s)
  (new button%
       [parent p]
       [label l]
       [callback (lambda (button event)
                   (set! diff s)
                   (set! begin (+ (current-seconds) diff))
                   (send timer start 10))]))

; Create the window
(define frame (new frame%
                   [label "Tea Timer"]
                   [width 400]
                   [height 250]))

(define top-panel (new horizontal-panel% [parent frame] [alignment '(center top)]))

; Show initial message
(define msg (new message%
                 [parent top-panel]
                 [label "Choose a timer"]
                 [min-width 200]
                 [font (make-object font% 16 'default)]))

(define hpanel (new horizontal-panel% [parent frame]))
(define vpanel-left (new vertical-panel% [parent hpanel] [alignment '(center top)]))
(define vpanel-center (new vertical-panel% [parent hpanel] [alignment '(center top)]))
(define vpanel-right (new vertical-panel% [parent hpanel] [alignment '(right bottom)]))

(define begin 0)
(define diff 0)
(define tea-alarm-thread (void))

; Timer callback
(define timer (new timer%
                   [notify-callback (lambda ()
                                      (set! diff (- begin (current-seconds)))
                                      (cond
                                        [(>= diff 0)
                                         (send msg set-label (time-format diff))]
                                        [else (send timer stop)
                                              (send msg set-label "Your tea is ready!")
                                              (set! tea-alarm-thread (thread tea-alarm))]))]
                   [interval #f]))

; Stop button
(new button%
     [parent vpanel-right]
     [label "STOP"]
     [font (make-object font% 18 'default)]
     [min-width 100]
     [min-height 80]
     [callback (lambda (button event)
                 (with-handlers
                     ([exn:fail? void])
                   (kill-thread tea-alarm-thread))
                 (send timer stop)
                 (send msg set-label "Choose a timer"))])

; Timer buttons
(create-button vpanel-left "30 seconds" 30)
(create-button vpanel-left "1 minute" 60)
(create-button vpanel-left "2 minutes" 120)
(create-button vpanel-left "3 minutes" 180)
(create-button vpanel-left "4 minutes" 240)
(create-button vpanel-center "Coconut Oolong" 180)
(create-button vpanel-center "White Tea" 180)
(create-button vpanel-center "Yellow Tea" 180)

; Pause button
(new button%
     [parent vpanel-right]
     [label "Pause"]
     [callback (lambda (button event)
                 (send timer stop))])

; Resume button
(new button%
     [parent vpanel-right]
     [label "Resume"]
     [callback (lambda (button event)
                 (set! begin (+ (current-seconds) diff))
                 (send timer start 10))])

; Reset button
(new button%
     [parent vpanel-right]
     [label "Reset"]
     [callback (lambda (button event)
                 (send timer stop)
                 (send msg set-label "Choose a timer"))])

; show window
(send frame show #t)