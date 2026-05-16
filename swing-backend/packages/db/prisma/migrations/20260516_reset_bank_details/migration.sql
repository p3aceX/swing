-- Clear all bank account details from existing users (Cashfree migration)
UPDATE "business_accounts"
SET
  "accountNumber"        = NULL,
  "ifscCode"             = NULL,
  "beneficiaryName"      = NULL,
  "upiId"                = NULL,
  "routeEnabled"         = false,
  "razorpayAccountId"    = NULL,
  "razorpayFundAccountId" = NULL;
