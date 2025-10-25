;; VickyCoin - a simple SIP-010-like fungible token implementation

(define-constant ERR-UNAUTHORIZED u100)
(define-constant ERR-INSUFFICIENT-BALANCE u101)
(define-constant ERR-ZERO-TRANSFER u102)

(define-constant TOKEN-NAME "VickyCoin")
(define-constant TOKEN-SYMBOL "VICKY")
(define-constant TOKEN-DECIMALS u6)

(define-data-var owner principal tx-sender)
(define-data-var total-supply uint u0)
(define-map balances { owner: principal } { balance: uint })

(define-private (balance-of (who principal))
  (get balance (default-to { balance: u0 } (map-get? balances { owner: who }))))

(define-private (credit (who principal) (amount uint))
  (let ((new (+ (balance-of who) amount)))
    (begin
      (map-set balances { owner: who } { balance: new })
      true)))

(define-private (debit (who principal) (amount uint))
  (let ((current (balance-of who)))
    (begin
      (asserts! (>= current amount) (err ERR-INSUFFICIENT-BALANCE))
      (let ((new (- current amount)))
        (begin
          (if (is-eq new u0)
              (map-delete balances { owner: who })
              (map-set balances { owner: who } { balance: new }))
          (ok true))))))

(define-read-only (get-name)
  (ok TOKEN-NAME))

(define-read-only (get-symbol)
  (ok TOKEN-SYMBOL))

(define-read-only (get-decimals)
  (ok TOKEN-DECIMALS))

(define-read-only (get-total-supply)
  (ok (var-get total-supply)))

(define-read-only (get-balance (who principal))
  (ok (balance-of who)))

(define-read-only (get-token-uri)
  (ok none))

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (> amount u0) (err ERR-ZERO-TRANSFER))
    (asserts! (is-eq tx-sender sender) (err ERR-UNAUTHORIZED))
    (try! (debit sender amount))
    (credit recipient amount)
    (ok true)))

(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (> amount u0) (err ERR-ZERO-TRANSFER))
    (asserts! (is-eq tx-sender (var-get owner)) (err ERR-UNAUTHORIZED))
    (var-set total-supply (+ (var-get total-supply) amount))
    (credit recipient amount)
    (ok true)))

(define-public (burn (amount uint) (sender principal))
  (begin
    (asserts! (> amount u0) (err ERR-ZERO-TRANSFER))
    (asserts! (is-eq tx-sender sender) (err ERR-UNAUTHORIZED))
    (try! (debit sender amount))
    (var-set total-supply (- (var-get total-supply) amount))
    (ok true)))

(define-public (set-owner (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get owner)) (err ERR-UNAUTHORIZED))
    (var-set owner new-owner)
    (ok true)))
