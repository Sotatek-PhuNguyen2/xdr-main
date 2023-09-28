// Copyright 2015 Stellar Development Foundation and contributors. Licensed
// under the Apache License, Version 2.0. See the COPYING file at the root
// of this distribution or at http://www.apache.org/licenses/LICENSE-2.0

%#include "xdr/ledger-entries-redeem.h"

namespace stellar
{

/* Creates, updates or deletes an redeem

Threshold: med

Result: ManageredeemResult

*/
//: ManageredeemOp is used to create or delete redeem
struct ManageredeemOp
{
    //: Balance for base asset of an redeem creator
    BalanceID baseBalance; 
    
    //: Balance for quote asset of an redeem creator
    BalanceID quoteBalance; 
    
    //: Direction of an redeem (to buy or to sell)
    bool isBuy;
    
    //: Amount in base asset to buy or sell (to delete an redeem, set 0)
    int64 amount; 
    
    //: Price of base asset in the ratio of quote asset
    int64 price;
    
    //: Fee in quote asset to pay 
    int64 fee;
    
    //: ID of an redeem to be managed. 0 to create a new redeem, otherwise to edit an existing redeem
    uint64 redeemID;
    
    //: ID of an orderBook to put an redeem in and to find a match in
    uint64 orderBookID;
     
    //: Reserved for future use
    union switch (LedgerVersion v)
    {
    case EMPTY_VERSION:
            void;
    }
    ext;
};

/******* Manageredeem Result ********/

enum ManageredeemResultCode
{
    // codes considered as "success" for the operation
    //: ManageredeemOp was successfully applied
    SUCCESS = 0,
    
    // codes considered as "failure" for the operation
    //: Either the quote amount is less than the fee or the new fee is less than the old one
    MALFORMED = -1,
    //: Asset pair does not allow creating redeems with it
    PAIR_NOT_TRADED = -2, 
    //: Source account of an operation does not owns one of the provided balances
    BALANCE_NOT_FOUND = -3,
    //: One of the balances does not hold the amount that it is trying to sell
    UNDERFUNDED = -4,
    //: redeem will cross with another redeem of the same user 
    CROSS_SELF = -5,
    //: Overflow happened during the quote amount or fee calculation
    redeem_OVERFLOW = -6,
    //: Either an asset pair does not exist or base and quote assets are the same
    ASSET_PAIR_NOT_TRADABLE = -7,
    //: redeem price violates the physical price restriction
    PHYSICAL_PRICE_RESTRICTION = -8,
    //: redeem price violates the current price restriction
    CURRENT_PRICE_RESTRICTION = -9,
    //: redeem with provided redeemID is not found
    NOT_FOUND = -10,
    //: Negative fee is not allowed
    INVALID_PERCENT_FEE = -11,
    //: Price is too small
    INSUFFICIENT_PRICE = -12,
    //: Order book with provided ID does not exist
    ORDER_BOOK_DOES_NOT_EXISTS = -13,
    //: Sale has not started yet
    SALE_IS_NOT_STARTED_YET = -14,
    //: Sale has already ended
    SALE_ALREADY_ENDED = -15,
    //: CurrentCap of sale + redeem amount will exceed the hard cap of the sale
    ORDER_VIOLATES_HARD_CAP = -16,
    //: redeem creator cannot participate in their own sale
    CANT_PARTICIPATE_OWN_SALE = -17,
    //: Sale assets and assets for specified balances are mismatched
    ASSET_MISMATCHED = -18,
    //: Sale price and redeem price are mismatched
    PRICE_DOES_NOT_MATCH = -19,
    //: Price must be positive
    PRICE_IS_INVALID = -20,
    //: redeem update is not allowed
    UPDATE_IS_NOT_ALLOWED = -21,
    //: Amount must be positive
    INVALID_AMOUNT = -22,
    //: Sale is not active
    SALE_IS_NOT_ACTIVE = -23,
    //: Source must have KYC in order to participate
    REQUIRES_KYC = -24,
    //: Source account is underfunded
    SOURCE_UNDERFUNDED = -25,
    //: Overflow happened during the balance lock
    SOURCE_BALANCE_LOCK_OVERFLOW = -26,
    //: Source account must be verified in order to participate
    REQUIRES_VERIFICATION = -27,
    //: Precision set in the system and precision of the amount are mismatched
    INCORRECT_AMOUNT_PRECISION = -28,
    //: Sale specific rule forbids to participate in sale for source account
    SPECIFIC_RULE_FORBIDS = -29,
    //: Amount must be less then pending issuance
    PENDING_ISSUANCE_LESS_THEN_AMOUNT = -30
};

enum ManageredeemEffect
{
    //: redeem created 
    CREATED = 0,
    //: redeem updated
    UPDATED = 1,
    //: redeem deleted
    DELETED = 2
};

/* This result is used when redeems are taken during an operation */
//: Used when redeems are taken during the operation
struct ClaimredeemAtom
{
    // emitted to identify the redeem
    //: ID of an account that created the matched redeem
    AccountID bAccountID;
    //: ID of the matched redeem
    uint64 redeemID;
    //: Amount in base asset taken during the match
    int64 baseAmount;
    //: Amount in quote asset taked during the match
    int64 quoteAmount;
    //: Fee paid by an redeem owner
    int64 bFeePaid;
    //: Fee paid by the source of an operation
    int64 aFeePaid;
    //: Balance in base asset of an redeem owner
    BalanceID baseBalance;
    //: Balance in quote asset of an redeem owner
    BalanceID quoteBalance;
    //: Match price
    int64 currentPrice;
    //: Reserved for future use
    union switch (LedgerVersion v)
    {
    case EMPTY_VERSION:
        void;
    }
    ext;
};
//: Contains details of successful operation application
struct ManageredeemSuccessResult
{

    //: redeems that matched a created redeem
    ClaimredeemAtom redeemsClaimed<>;
    //: Base asset of an redeem
    AssetCode baseAsset;
    //: Quote asset of an redeem
    AssetCode quoteAsset;
    
    //: Effect of operation
    union switch (ManageredeemEffect effect)
    {
    case CREATED:
    case UPDATED:
        //: Updated redeem entry
        redeemEntry redeem;
    default:
        void;
    }
    redeem;
    //: Reserved for future use
    union switch (LedgerVersion v)
    {
    case EMPTY_VERSION:
        void;
    }
    ext;
};

//: Result of `ManageredeemOp`
union ManageredeemResult switch (ManageredeemResultCode code)
{
case SUCCESS:
    ManageredeemSuccessResult success;
case PHYSICAL_PRICE_RESTRICTION:
    struct {
        //: Physical price of the base asset
        int64 physicalPrice;
        //: Reserved for future use
        union switch (LedgerVersion v)
        {
        case EMPTY_VERSION:
            void;
        }
        ext;
    } physicalPriceRestriction;
case CURRENT_PRICE_RESTRICTION:
    struct {
        //: Current price of the base asset
        int64 currentPrice;
        //: Reserved for future use
        union switch (LedgerVersion v)
        {
        case EMPTY_VERSION:
            void;
        }
        ext;
    } currentPriceRestriction;
default:
    void;
};

}

