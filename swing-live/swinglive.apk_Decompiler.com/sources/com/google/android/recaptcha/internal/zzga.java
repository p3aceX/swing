package com.google.android.recaptcha.internal;

import K.k;
import java.math.RoundingMode;

/* JADX INFO: loaded from: classes.dex */
public final class zzga {
    public static int zza(int i4, int i5, RoundingMode roundingMode) {
        roundingMode.getClass();
        if (i5 == 0) {
            throw new ArithmeticException("/ by zero");
        }
        int i6 = i4 / i5;
        int i7 = i4 - (i5 * i6);
        if (i7 == 0) {
            return i6;
        }
        int i8 = ((i4 ^ i5) >> 31) | 1;
        switch (zzfz.zza[roundingMode.ordinal()]) {
            case 1:
                zzgc.zzb(false);
                return i6;
            case 2:
                return i6;
            case 3:
                if (i8 >= 0) {
                    return i6;
                }
                break;
            case 4:
                break;
            case 5:
                if (i8 <= 0) {
                    return i6;
                }
                break;
            case k.STRING_SET_FIELD_NUMBER /* 6 */:
            case k.DOUBLE_FIELD_NUMBER /* 7 */:
            case k.BYTES_FIELD_NUMBER /* 8 */:
                int iAbs = Math.abs(i7);
                int iAbs2 = iAbs - (Math.abs(i5) - iAbs);
                if (iAbs2 == 0) {
                    if (roundingMode != RoundingMode.HALF_UP) {
                        if ((i6 & 1 & (roundingMode != RoundingMode.HALF_EVEN ? 0 : 1)) == 0) {
                            return i6;
                        }
                    }
                } else if (iAbs2 <= 0) {
                    return i6;
                }
            default:
                throw new AssertionError();
        }
        return i6 + i8;
    }

    public static int zzb(int i4, RoundingMode roundingMode) {
        if (i4 <= 0) {
            throw new IllegalArgumentException("x (0) must be > 0");
        }
        switch (zzfz.zza[roundingMode.ordinal()]) {
            case 1:
                zzgc.zzb(((i4 + (-1)) & i4) == 0);
                break;
            case 2:
            case 3:
                break;
            case 4:
            case 5:
                return 32 - Integer.numberOfLeadingZeros(i4 - 1);
            case k.STRING_SET_FIELD_NUMBER /* 6 */:
            case k.DOUBLE_FIELD_NUMBER /* 7 */:
            case k.BYTES_FIELD_NUMBER /* 8 */:
                int iNumberOfLeadingZeros = Integer.numberOfLeadingZeros(i4);
                return (31 - iNumberOfLeadingZeros) + ((((-1257966797) >>> iNumberOfLeadingZeros) - i4) >>> 31);
            default:
                throw new AssertionError();
        }
        return 31 - Integer.numberOfLeadingZeros(i4);
    }
}
