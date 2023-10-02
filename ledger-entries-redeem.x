

%#include "xdr/types.h"

namespace stellar
{

/* RedeemEntry
    An redeem is the building block of the redeem book, they are automatically
    claimed by payments when the price set by the owner is met.

*/

struct RedeemDetail {
    AccountID ownerID;
	uint64 redeemID;
    uint64 offerID;
    BalanceID baseBalance; 
	BalanceID quoteBalance;
	uint64 baseAmount;
    int64 quoteAmount;
	uint64 currentAmount;
    uint64 createdAt;
	union switch (LedgerVersion v)
    {
    case EMPTY_VERSION:
        void;
    }
    ext;
};

struct RedeemEntry
{	
    uint64 redeemID;
	AccountID ownerID;
    AssetCode base; // A
    AssetCode quote;  // B
    BalanceID baseBalance; 
	BalanceID quoteBalance;
    uint64 totalAmountRedeem;
    int64 baseAmount;
	int64 quoteAmount;
	uint64 createdAt;
	int64 fee;

    int64 percentFee;
    RedeemDetail redeemDetails<100>;
	// price of A in terms of B
    int64 price;

    // reserved for future use
    union switch (LedgerVersion v)
    {
    case EMPTY_VERSION:
        void;
    }
    ext;
};

}
