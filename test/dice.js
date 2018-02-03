var Dice = artifacts.require('./Dice.sol');

contract('Dice', function (accounts) {
  it('rejects bets below the minimum', function () {
    return Dice.deployed().then(function (dice) {
      return dice.fund({ from: accounts[0], value: web3.toWei(10, 'ether') })
        .then(function () {
          return dice.roll(3, { from: accounts[1], value: web3.toWei(0.001, 'ether') });
        })
        .then(assert.fail)
        .catch(function (err) {
          assert(err.message.indexOf('revert') >= 0, 'expected a revert');
        });
    });
  });

  it('rejects bets larger than the cap', function () {
    return Dice.deployed().then(function (dice) {
      return dice.roll(3, { from: accounts[1], value: web3.toWei(5, 'ether') })
        .then(assert.fail)
        .catch(function (err) {
          assert(err.message.indexOf('revert') >= 0, 'expected a revert');
        });
    });
  });
});
