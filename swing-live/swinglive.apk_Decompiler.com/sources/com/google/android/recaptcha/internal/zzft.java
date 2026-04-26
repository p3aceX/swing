package com.google.android.recaptcha.internal;

import com.google.crypto.tink.shaded.protobuf.S;
import java.math.RoundingMode;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
final class zzft {
    final int zza;
    final int zzb;
    final int zzc;
    final int zzd;
    private final String zze;
    private final char[] zzf;
    private final byte[] zzg;
    private final boolean[] zzh;
    private final boolean zzi;

    /* JADX WARN: Illegal instructions before constructor call */
    public zzft(String str, char[] cArr) {
        byte[] bArr = new byte[128];
        Arrays.fill(bArr, (byte) -1);
        for (int i4 = 0; i4 < cArr.length; i4++) {
            char c5 = cArr[i4];
            boolean z4 = true;
            zzff.zzc(c5 < 128, "Non-ASCII character: %s", c5);
            if (bArr[c5] != -1) {
                z4 = false;
            }
            zzff.zzc(z4, "Duplicate character: %s", c5);
            bArr[c5] = (byte) i4;
        }
        this(str, cArr, bArr, false);
    }

    public final boolean equals(Object obj) {
        if (obj instanceof zzft) {
            zzft zzftVar = (zzft) obj;
            boolean z4 = zzftVar.zzi;
            if (Arrays.equals(this.zzf, zzftVar.zzf)) {
                return true;
            }
        }
        return false;
    }

    public final int hashCode() {
        return Arrays.hashCode(this.zzf) + 1237;
    }

    public final String toString() {
        return this.zze;
    }

    public final char zza(int i4) {
        return this.zzf[i4];
    }

    public final int zzb(char c5) throws zzfw {
        if (c5 > 127) {
            throw new zzfw("Unrecognized character: 0x".concat(String.valueOf(Integer.toHexString(c5))));
        }
        byte b5 = this.zzg[c5];
        if (b5 != -1) {
            return b5;
        }
        if (c5 <= ' ' || c5 == 127) {
            throw new zzfw("Unrecognized character: 0x".concat(String.valueOf(Integer.toHexString(c5))));
        }
        throw new zzfw("Unrecognized character: " + c5);
    }

    public final boolean zzc(int i4) {
        return this.zzh[i4 % this.zzc];
    }

    public final boolean zzd(char c5) {
        return this.zzg[61] != -1;
    }

    private zzft(String str, char[] cArr, byte[] bArr, boolean z4) {
        this.zze = str;
        cArr.getClass();
        this.zzf = cArr;
        try {
            int length = cArr.length;
            int iZzb = zzga.zzb(length, RoundingMode.UNNECESSARY);
            this.zzb = iZzb;
            int iNumberOfTrailingZeros = Integer.numberOfTrailingZeros(iZzb);
            int i4 = 1 << (3 - iNumberOfTrailingZeros);
            this.zzc = i4;
            this.zzd = iZzb >> iNumberOfTrailingZeros;
            this.zza = length - 1;
            this.zzg = bArr;
            boolean[] zArr = new boolean[i4];
            for (int i5 = 0; i5 < this.zzd; i5++) {
                zArr[zzga.zza(i5 * 8, this.zzb, RoundingMode.CEILING)] = true;
            }
            this.zzh = zArr;
            this.zzi = false;
        } catch (ArithmeticException e) {
            throw new IllegalArgumentException(S.d(cArr.length, "Illegal alphabet length "), e);
        }
    }
}
