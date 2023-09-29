

%#include "xdr/types.h"

namespace stellar
{

/* RedeemEntry
    An redeem is the building block of the redeem book, they are automatically
    claimed by payments when the price set by the owner is met.

*/

struct RedeemDetails {
	uint64 redeemID;
    uint64 offerID;
	uint64 baseAmount;
	uint64 currentAmount;
    uint64 createdAt;
    uint64 updatedAt;
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
    int64 baseAmount;
	int64 quoteAmount;
	uint64 createdAt;
	int64 fee;

    int64 percentFee;

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
