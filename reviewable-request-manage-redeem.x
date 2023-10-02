%#include "xdr/operation-manage-redeem.h"

namespace stellar 
{

struct ManageRedeemRequest 
{
    ManageRedeemOp op;

    union switch (LedgerVersion v)
    {
    case EMPTY_VERSION:
        void;
    case MOVEMENT_REQUESTS_DETAILS:
        longstring creatorDetails;
    } ext;
};
}