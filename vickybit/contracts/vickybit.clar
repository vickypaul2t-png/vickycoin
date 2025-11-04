;; VickyBit (VBIT) - SIP-010 compatible fungible token


;; --------------------------------------------
;; Constants and data vars
;; --------------------------------------------
(define-constant ERR_UNAUTHORIZED u100)
(define-constant ERR_INSUFFICIENT_FUNDS u101)

(define-constant TOKEN_NAME "VickyBit")
(define-constant TOKEN_SYMBOL "VBIT")
(define-constant TOKEN_DECIMALS u6) ;; 6 decimal places

;; Contract owner is the deployer
(define-data-var owner principal tx-sender)

(define-data-var total-supply uint u0)

(define-map balances
  { account: principal }
  { balance: uint }
)

;; --------------------------------------------
;; Read-only SIP-010 functions
;; --------------------------------------------
(define-read-only (get-name)
  (ok TOKEN_NAME)
)

(define-read-only (get-symbol)
  (ok TOKEN_SYMBOL)
)

(define-read-only (get-decimals)
  (ok TOKEN_DECIMALS)
)

(define-read-only (get-total-supply)
  (ok (var-get total-supply))
)

(define-read-only (get-balance (who principal))
  (ok (get-balance-internal who))
)

;; --------------------------------------------
;; Public SIP-010 function
;; --------------------------------------------
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    ;; authorization: either the sender themselves, or the contract owner may move funds
    (asserts! (or (is-eq tx-sender sender) (is-eq tx-sender (var-get owner))) (err ERR_UNAUTHORIZED))
    (try! (debit sender amount))
    (credit recipient amount)
    (ok true)
  )
)

;; --------------------------------------------
;; Admin functions
;; --------------------------------------------
(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender (var-get owner)) (err ERR_UNAUTHORIZED))
    (var-set total-supply (+ (var-get total-supply) amount))
    (credit recipient amount)
    (ok true)
  )
)

(define-public (burn (amount uint) (from principal))
  (begin
    ;; allow holder to burn their own tokens, or owner to burn from any account
    (asserts! (or (is-eq tx-sender from) (is-eq tx-sender (var-get owner))) (err ERR_UNAUTHORIZED))
    (try! (debit from amount))
    (var-set total-supply (- (var-get total-supply) amount))
    (ok true)
  )
)

(define-public (set-owner (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get owner)) (err ERR_UNAUTHORIZED))
    (var-set owner new-owner)
    (ok true)
  )
)

;; --------------------------------------------
;; Private helpers
;; --------------------------------------------
(define-read-only (get-balance-internal (who principal))
  (default-to u0 (get balance (map-get? balances { account: who })))
)

(define-private (set-balance (who principal) (new-balance uint))
  (begin
    (if (is-eq new-balance u0)
        (map-delete balances { account: who })
        (map-set balances { account: who } { balance: new-balance }))
    true
  )
)

(define-private (credit (who principal) (amount uint))
  (let ((cur (get-balance-internal who)))
    (set-balance who (+ cur amount))
    true
  )
)

(define-private (debit (who principal) (amount uint))
  (let ((cur (get-balance-internal who)))
    (asserts! (>= cur amount) (err ERR_INSUFFICIENT_FUNDS))
    (set-balance who (- cur amount))
    (ok true)
  )
)

