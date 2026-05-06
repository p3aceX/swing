-- CreateTable
CREATE TABLE "BookingPayment" (
    "id" TEXT NOT NULL,
    "bookingId" TEXT NOT NULL,
    "amountPaise" INTEGER NOT NULL,
    "paymentMode" TEXT NOT NULL,
    "payerName" TEXT NOT NULL,
    "payerTeamId" TEXT,
    "payerPhone" TEXT,
    "recordedByOwnerId" TEXT NOT NULL,
    "recordedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "reference" TEXT,
    "notes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "BookingPayment_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "BookingPayment_bookingId_idx" ON "BookingPayment"("bookingId");

-- AddForeignKey
ALTER TABLE "BookingPayment" ADD CONSTRAINT "BookingPayment_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "SlotBooking"("id") ON DELETE CASCADE ON UPDATE CASCADE;
