# eth-dice

Small dice game contract. Pick a number 1-6, bet at least 0.01 ETH, get 5x
back if it comes up. The house keeps the rest; the owner funds the bankroll.

    npm install -g truffle@4.1.5
    truffle develop
    truffle(develop)> test

Deploying to Rinkeby: add a network to `truffle.js` with your provider and
`truffle migrate --network rinkeby`.

## How the roll works

`placeBet` records the block number, `settle` can be called two blocks later
and uses the hash of the block after the bet. Miners could in theory withhold
a block to avoid a losing roll, so this is only fine for small stakes. Bets
that nobody settles within 250 blocks can be refunded (older blockhashes
return zero).

Payout is 5x on a 1 in 6 chance so the house edge is about 17%.
