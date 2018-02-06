```
Contract: Main contract functions testing
    √ should create the main contract and have 5 Ether in contract (1803ms)
    √ should send 75% of funds to DGPS profit sharing and 25% to operational wallet for gas (1064ms)
    √ Main contract should have 0 DGPT tokens. Call / approve for 20k DGPT  (115ms)
    √ We should now should be able to deposit 10000 tokens to meta contract as funding (81ms)
    √ fastExchange should give us tokens at -10% of the price straight away (153ms)

  Contract: DGPS approval, deposit and exchange functions
    √ should create the DGPS contract and have 500 DGPS tokens in contract (968ms)
    √ DGPS contract should have 0 DGPT tokens  (56ms)
    √ DGPT should be able to approve DGPS to spend 20.000 tokens
    √ Verify if DGPS has allowance on DGPT contract (41ms)
    √ Account 0 should now should be able to deposit 10001 tokens to DGPS contract (123ms)
    √ DGPS contract should now have 10001 DGPT tokens
    √ Account 0 should have received 1.0001 DGPS tokens instead
    √ User's ProfitBalance should be 0 at this point
    √ Move 4 weeks and update balances. Auto payout should kick in. (200ms)
    √ Payout has been made automatically, profitbalance should be 0 again.
    √ Withdraw DGPT. Accounts should have the funds back (141ms)

  Contract: Test with fake balances and fake accounts
    √ should create the DGPS contract and have 500 DGPS tokens in contract (1398ms)
    √ DGPS contract should have 0 DGPT tokens  (53ms)
    √ Adding fake accounts with 10k DGPT to the contract (84ms)
    √ User's ProfitBalance should be 0 at this point
    √ Move 4 weeks and update balances. (97ms)
    √ Payout has been made automatically, profitbalance should be 0 again. (96ms)

  Contract: Storage provider contract
    √ Store new vault (69ms)
    √ Get newly stored vault by ID. Should return all keys by the ID. (42ms)
    √ Should return an object for web3 and frontend use case


  25 passing (7s)
```
