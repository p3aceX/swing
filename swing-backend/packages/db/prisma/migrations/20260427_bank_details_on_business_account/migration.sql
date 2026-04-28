ALTER TABLE "business_accounts" ADD COLUMN IF NOT EXISTS "beneficiaryName" TEXT;
ALTER TABLE "business_accounts" ADD COLUMN IF NOT EXISTS "accountNumber" TEXT;
ALTER TABLE "business_accounts" ADD COLUMN IF NOT EXISTS "ifscCode" TEXT;
ALTER TABLE "business_accounts" ADD COLUMN IF NOT EXISTS "upiId" TEXT;
