Todo list
----
### DGPS Token contract
- ~~Total supply 10k times less than total supply of DGPT - OK~~ 
- ~~DGPT to DGPS exchange rate is 10k:1 - OK~~
- DGPS are not transferrable anywhere besides the smart contract where they came from
- Upgradable smart contract
- ~~Payouts from smart contract happen 4 times per month (every week), but each DGPS holder can receive payout only once in 30 day cycle~~
- If user pull out DGPT before the billing cycle, nothing is being sent over as profit
- ~~DGPT tokens are locked in the smart contract until they are interchanged back to DGPS~~
- ~~25% of the profits are kept as the income for the company and those funds are diverted to the company wallet.~~

### Storage provider contract
- Receives DGPT once per month
- ~~Refill of ETH is being performed manually~~


### Main smart contract
- ~~Accept ETH/EUR/BTC/USD through 3rd party API~~ function `remotePurchase()`
- API success puts buy order on the selected exchanges
- ~~Immediately give tokens from our own supply on 10% lower exchange rate (so we have margin for trading)~~ **integrate price!**
- Min 1k EUR equiv. In DGPT is being sent each month to storage providers
- Once the storage provider profit share surpasses 1000 EUR equiv. 10% from the amount over the 1000 are being diverted to the company token pool, until the company token pool once again has 25% from the total token supply
- DGPT 50% are being exchanged to the ETH for DGPS profit share and Gas price coverage
- ~~75% of ETH received on the smart contract are being sent over to DGPS smart contract as profit share, while 25% are sent to the wallet which operates with the smart contract for gas cost coverage for 30 days.~~ After 30 days the remainder of “25% Gas ETH” is also sent as profit sharing.


Results
----

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
