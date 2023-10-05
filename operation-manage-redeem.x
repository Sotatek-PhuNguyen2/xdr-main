// Copyright 2015 Stellar Development Foundation and contributors. Licensed
// under the Apache License, Version 2.0. See the COPYING file at the root
// of this distribution or at http://www.apache.org/licenses/LICENSE-2.0

%#include "xdr/ledger-entries-redeem.h"

namespace stellar
{

/* Creates, updates or deletes an redeem

Threshold: med

Result: ManageRedeemResult

*/
//: ManageRedeemOp is used to create redeem
struct ManageRedeem

{
    AccountID ownerID;

    //: Balance for base asset of an offer creator
    BalanceID baseBalance; 

    //: Balance for quote asset of an offer creator
    BalanceID quoteBalance; 

    //: Base amount in base asset to buy or sell
    int64 baseAmount; 
    
     //: Current amount 
    int64 currentAmount; 
    
    //: Price of base asset in the ratio of quote asset
    int64 price;
    
    //: Fee in quote asset to pay 
    int64 fee;
    
    //: ID of an offer to be managed. 0 to create a new offer, otherwise to edit an existing offer
    uint64 offerID;
    
    //: ID of an redeem to be managed. 0 to create a new redeem, otherwise to edit an existing redeem
    uint64 redeemID;
};

struct ManageRedeemOp
{
    ManageRedeem manageRedeems<100>;

    //: ID of an account that created the matched offer
    AccountID bAccountID;

    //: ID of an redeem to be managed. 0 to create a new redeem, otherwise to edit an existing redeem
    uint64 redeemID;
     
    //: Balance for base asset of an offer creator
    BalanceID baseBalance; 

    //: Balance for quote asset of an offer creator
    BalanceID quoteBalance; 
    
     //: amount 
    int64 amount; 
    
    //: Price of base asset in the ratio of quote asset
    int64 price;
    
    //: Fee in quote asset to pay 
    int64 fee;

    //: Reserved for future use
    union switch (LedgerVersion v)
    {
    case EMPTY_VERSION:
            void;
    }
    ext;
};

/******* ManageRedeem Result ********/

enum ManageRedeemResultCode
{
    // codes considered as "success" for the operation
    //: ManageRedeemOp was successfully applied
    SUCCESS = 0,
    
    // codes considered as "failure" for the operation
    //: Either the quote amount is less than the fee or the new fee is less than the old one
    MALFORMED = -1,
    //: Asset pair does not allow creating offers with it
    PAIR_NOT_TRADED = -2, 
    //: Source account of an operation does not owns one of the provided balances
    BALANCE_NOT_FOUND = -3,
    //: One of the balances does not hold the amount that it is trying to sell
    UNDERFUNDED = -4,
    //: Redeem will cross with another redeem of the same user 
    CROSS_SELF = -5,
    //: Overflow happened during the quote amount or fee calculation
    OFFER_OVERFLOW = -6,
    //: Redeem price violates the physical price restriction
    PHYSICAL_PRICE_RESTRICTION = -7,
    //: Redeem price violates the current price restriction
    CURRENT_PRICE_RESTRICTION = -8,
    //: Redeem with provided redeemID is not found
    NOT_FOUND = -9,
    //: Negative fee is not allowed
    INVALID_PERCENT_FEE = -10,
    //: Price is too small
    INSUFFICIENT_PRICE = -11,
    //: Order book with provided ID does not exist
    ORDER_BOOK_DOES_NOT_EXISTS = -12,
    //: Sale has not started yet
    SALE_IS_NOT_STARTED_YET = -13,
    //: Sale has already ended
    SALE_ALREADY_ENDED = -14,
    //: CurrentCap of sale + redeem amount will exceed the hard cap of the sale
    ORDER_VIOLATES_HARD_CAP = -15,
    //: Redeem creator cannot participate in their own sale
    CANT_PARTICIPATE_OWN_SALE = -16,
    //: Sale assets and assets for specified balances are mismatched
    ASSET_MISMATCHED = -17,
    //: Sale price and redeem price are mismatched
    PRICE_DOES_NOT_MATCH = -18,
    //: Price must be positive
    PRICE_IS_INVALID = -19,
    //: Redeem update is not allowed
    UPDATE_IS_NOT_ALLOWED = -20,
    //: Amount must be positive
    INVALID_AMOUNT = -21,
    //: Sale is not active
    SALE_IS_NOT_ACTIVE = -22,
    //: Source must have KYC in order to participate
    REQUIRES_KYC = -23,
    //: Source account is underfunded
    SOURCE_UNDERFUNDED = -24,
    //: Overflow happened during the balance lock
    SOURCE_BALANCE_LOCK_OVERFLOW = -25,
    //: Source account must be verified in order to participate
    REQUIRES_VERIFICATION = -26,
    //: Precision set in the system and precision of the amount are mismatched
    INCORRECT_AMOUNT_PRECISION = -27,
    //: Sale specific rule forbids to participate in sale for source account
    SPECIFIC_RULE_FORBIDS = -28,
    //: Amount must be less then pending issuance
    PENDING_ISSUANCE_LESS_THEN_AMOUNT = -29
};

enum ManageRedeemEffect
{
    //: Redeem created 
    CREATED = 0,
    //: Redeem updated
    UPDATED = 1,
    //: Redeem deleted
    DELETED = 2
};

/* This result is used when redeems are taken during an operation */
//: Used when redeems are taken during the operation
struct ClaimRedeemAtom
{
    // emitted to identify the redeem
    //: ID of an account that created the matched redeem
    AccountID bAccountID;
    //: ID of the matched offer
    uint64 offerID;
    //: ID of the matched redeem
    uint64 redeemID;
    //: Amount in base asset taken during the match
    int64 baseAmount;
    //: Current Amount 
    int64 currentAmount;
    //: Reserved for future use
    union switch (LedgerVersion v)
    {
    case EMPTY_VERSION:
        void;
    }
    ext;
};
//: Contains details of successful operation application
struct ManageRedeemSuccessResult
{

    //: Offers that matched a created offer
    ClaimRedeemAtom redeemsClaimed<>;
    //: Base asset of an offer
    AssetCode baseAsset;
    //: Quote asset of an offer
    AssetCode quoteAsset;
    
    //: Effect of operation
    union switch (ManageRedeemEffect effect)
    {
    case CREATED:
    case UPDATED:
        //: Updated redeem entry
        RedeemEntry redeem;
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

//: Result of `ManageRedeemOp`
union ManageRedeemResult switch (ManageRedeemResultCode code)
{
case SUCCESS:
    ManageRedeemSuccessResult success;
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

