package com.google.android.recaptcha.internal;

import B1.a;
import com.google.android.gms.common.api.f;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
final class zzha extends zzhc {
    private final InputStream zze;
    private final byte[] zzf;
    private int zzg;
    private int zzh;
    private int zzi;
    private int zzj;
    private int zzk;
    private int zzl;

    public /* synthetic */ zzha(InputStream inputStream, int i4, zzgz zzgzVar) {
        super(null);
        this.zzl = f.API_PRIORITY_OTHER;
        byte[] bArr = zzjc.zzd;
        this.zze = inputStream;
        this.zzf = new byte[4096];
        this.zzg = 0;
        this.zzi = 0;
        this.zzk = 0;
    }

    private final List zzI(int i4) throws IOException {
        ArrayList arrayList = new ArrayList();
        while (i4 > 0) {
            int iMin = Math.min(i4, 4096);
            byte[] bArr = new byte[iMin];
            int i5 = 0;
            while (i5 < iMin) {
                int i6 = this.zze.read(bArr, i5, iMin - i5);
                if (i6 == -1) {
                    throw zzje.zzj();
                }
                this.zzk += i6;
                i5 += i6;
            }
            i4 -= iMin;
            arrayList.add(bArr);
        }
        return arrayList;
    }

    private final void zzJ() {
        int i4 = this.zzg + this.zzh;
        this.zzg = i4;
        int i5 = this.zzk + i4;
        int i6 = this.zzl;
        if (i5 <= i6) {
            this.zzh = 0;
            return;
        }
        int i7 = i5 - i6;
        this.zzh = i7;
        this.zzg = i4 - i7;
    }

    private final void zzK(int i4) throws zzje {
        if (zzL(i4)) {
            return;
        }
        if (i4 <= (f.API_PRIORITY_OTHER - this.zzk) - this.zzi) {
            throw zzje.zzj();
        }
        throw zzje.zzi();
    }

    private final boolean zzL(int i4) throws IOException {
        int i5 = this.zzi;
        int i6 = i5 + i4;
        int i7 = this.zzg;
        if (i6 <= i7) {
            throw new IllegalStateException(a.l("refillBuffer() called when ", i4, " bytes were already available in buffer"));
        }
        int i8 = this.zzk;
        if (i4 > (f.API_PRIORITY_OTHER - i8) - i5 || i8 + i5 + i4 > this.zzl) {
            return false;
        }
        if (i5 > 0) {
            if (i7 > i5) {
                byte[] bArr = this.zzf;
                System.arraycopy(bArr, i5, bArr, 0, i7 - i5);
            }
            i8 = this.zzk + i5;
            this.zzk = i8;
            i7 = this.zzg - i5;
            this.zzg = i7;
            this.zzi = 0;
        }
        try {
            int i9 = this.zze.read(this.zzf, i7, Math.min(4096 - i7, (f.API_PRIORITY_OTHER - i8) - i7));
            if (i9 == 0 || i9 < -1 || i9 > 4096) {
                throw new IllegalStateException(String.valueOf(this.zze.getClass()) + "#read(byte[]) returned invalid result: " + i9 + "\nThe InputStream implementation is buggy.");
            }
            if (i9 <= 0) {
                return false;
            }
            this.zzg += i9;
            zzJ();
            if (this.zzg >= i4) {
                return true;
            }
            return zzL(i4);
        } catch (zzje e) {
            e.zzk();
            throw e;
        }
    }

    private final byte[] zzM(int i4, boolean z4) throws IOException {
        byte[] bArrZzN = zzN(i4);
        if (bArrZzN != null) {
            return bArrZzN;
        }
        int i5 = this.zzi;
        int i6 = this.zzg;
        int i7 = i6 - i5;
        this.zzk += i6;
        this.zzi = 0;
        this.zzg = 0;
        List<byte[]> listZzI = zzI(i4 - i7);
        byte[] bArr = new byte[i4];
        System.arraycopy(this.zzf, i5, bArr, 0, i7);
        for (byte[] bArr2 : listZzI) {
            int length = bArr2.length;
            System.arraycopy(bArr2, 0, bArr, i7, length);
            i7 += length;
        }
        return bArr;
    }

    private final byte[] zzN(int i4) throws IOException {
        if (i4 == 0) {
            return zzjc.zzd;
        }
        if (i4 < 0) {
            throw zzje.zzf();
        }
        int i5 = this.zzk;
        int i6 = this.zzi;
        int i7 = i5 + i6 + i4;
        if ((-2147483647) + i7 > 0) {
            throw zzje.zzi();
        }
        int i8 = this.zzl;
        if (i7 > i8) {
            zzB((i8 - i5) - i6);
            throw zzje.zzj();
        }
        int i9 = this.zzg - i6;
        int i10 = i4 - i9;
        if (i10 >= 4096) {
            try {
                if (i10 > this.zze.available()) {
                    return null;
                }
            } catch (zzje e) {
                e.zzk();
                throw e;
            }
        }
        byte[] bArr = new byte[i4];
        System.arraycopy(this.zzf, this.zzi, bArr, 0, i9);
        this.zzk += this.zzg;
        this.zzi = 0;
        this.zzg = 0;
        while (i9 < i4) {
            try {
                int i11 = this.zze.read(bArr, i9, i4 - i9);
                if (i11 == -1) {
                    throw zzje.zzj();
                }
                this.zzk += i11;
                i9 += i11;
            } catch (zzje e4) {
                e4.zzk();
                throw e4;
            }
        }
        return bArr;
    }

    @Override // com.google.android.recaptcha.internal.zzhc
    public final void zzA(int i4) {
        this.zzl = i4;
        zzJ();
    }

    public final void zzB(int i4) throws zzje {
        int i5 = this.zzg;
        int i6 = this.zzi;
        int i7 = i5 - i6;
        if (i4 <= i7 && i4 >= 0) {
            this.zzi = i6 + i4;
            return;
        }
        if (i4 < 0) {
            throw zzje.zzf();
        }
        int i8 = this.zzk;
        int i9 = i8 + i6;
        int i10 = this.zzl;
        if (i9 + i4 > i10) {
            zzB((i10 - i8) - i6);
            throw zzje.zzj();
        }
        this.zzk = i9;
        this.zzg = 0;
        this.zzi = 0;
        while (i7 < i4) {
            try {
                long j4 = i4 - i7;
                try {
                    long jSkip = this.zze.skip(j4);
                    if (jSkip < 0 || jSkip > j4) {
                        throw new IllegalStateException(String.valueOf(this.zze.getClass()) + "#skip returned invalid result: " + jSkip + "\nThe InputStream implementation is buggy.");
                    }
                    if (jSkip == 0) {
                        break;
                    } else {
                        i7 += (int) jSkip;
                    }
                } catch (zzje e) {
                    e.zzk();
                    throw e;
                }
            } catch (Throwable th) {
                this.zzk += i7;
                zzJ();
                throw th;
            }
        }
        this.zzk += i7;
        zzJ();
        if (i7 >= i4) {
            return;
        }
        int i11 = this.zzg;
        int i12 = i11 - this.zzi;
        this.zzi = i11;
        zzK(1);
        while (true) {
            int i13 = i4 - i12;
            int i14 = this.zzg;
            if (i13 <= i14) {
                this.zzi = i13;
                return;
            } else {
                i12 += i14;
                this.zzi = i14;
                zzK(1);
            }
        }
    }

    @Override // com.google.android.recaptcha.internal.zzhc
    public final boolean zzC() {
        return this.zzi == this.zzg && !zzL(1);
    }

    @Override // com.google.android.recaptcha.internal.zzhc
    public final boolean zzD() {
        return zzr() != 0;
    }

    @Override // com.google.android.recaptcha.internal.zzhc
    public final boolean zzE(int i4) throws zzje {
        int iZzm;
        int i5 = i4 & 7;
        int i6 = 0;
        if (i5 == 0) {
            if (this.zzg - this.zzi < 10) {
                while (i6 < 10) {
                    if (zza() < 0) {
                        i6++;
                    }
                }
                throw zzje.zze();
            }
            while (i6 < 10) {
                byte[] bArr = this.zzf;
                int i7 = this.zzi;
                this.zzi = i7 + 1;
                if (bArr[i7] < 0) {
                    i6++;
                }
            }
            throw zzje.zze();
            return true;
        }
        if (i5 == 1) {
            zzB(8);
            return true;
        }
        if (i5 == 2) {
            zzB(zzj());
            return true;
        }
        if (i5 != 3) {
            if (i5 == 4) {
                return false;
            }
            if (i5 != 5) {
                throw zzje.zza();
            }
            zzB(4);
            return true;
        }
        do {
            iZzm = zzm();
            if (iZzm == 0) {
                break;
            }
        } while (zzE(iZzm));
        zzz(((i4 >>> 3) << 3) | 4);
        return true;
    }

    public final byte zza() throws zzje {
        if (this.zzi == this.zzg) {
            zzK(1);
        }
        byte[] bArr = this.zzf;
        int i4 = this.zzi;
        this.zzi = i4 + 1;
        return bArr[i4];
    }

    @Override // com.google.android.recaptcha.internal.zzhc
    public final double zzb() {
        return Double.longBitsToDouble(zzq());
    }

    @Override // com.google.android.recaptcha.internal.zzhc
    public final float zzc() {
        return Float.intBitsToFloat(zzi());
    }

    @Override // com.google.android.recaptcha.internal.zzhc
    public final int zzd() {
        return this.zzk + this.zzi;
    }

    @Override // com.google.android.recaptcha.internal.zzhc
    public final int zze(int i4) throws zzje {
        if (i4 < 0) {
            throw zzje.zzf();
        }
        int i5 = this.zzk + this.zzi;
        int i6 = this.zzl;
        int i7 = i4 + i5;
        if (i7 > i6) {
            throw zzje.zzj();
        }
        this.zzl = i7;
        zzJ();
        return i6;
    }

    @Override // com.google.android.recaptcha.internal.zzhc
    public final int zzf() {
        return zzj();
    }

    @Override // com.google.android.recaptcha.internal.zzhc
    public final int zzg() {
        return zzi();
    }

    @Override // com.google.android.recaptcha.internal.zzhc
    public final int zzh() {
        return zzj();
    }

    public final int zzi() throws zzje {
        int i4 = this.zzi;
        if (this.zzg - i4 < 4) {
            zzK(4);
            i4 = this.zzi;
        }
        byte[] bArr = this.zzf;
        this.zzi = i4 + 4;
        int i5 = bArr[i4] & 255;
        int i6 = bArr[i4 + 1] & 255;
        int i7 = bArr[i4 + 2] & 255;
        return ((bArr[i4 + 3] & 255) << 24) | (i6 << 8) | i5 | (i7 << 16);
    }

    public final int zzj() {
        int i4;
        int i5 = this.zzi;
        int i6 = this.zzg;
        if (i6 != i5) {
            byte[] bArr = this.zzf;
            int i7 = i5 + 1;
            byte b5 = bArr[i5];
            if (b5 >= 0) {
                this.zzi = i7;
                return b5;
            }
            if (i6 - i7 >= 9) {
                int i8 = i5 + 2;
                int i9 = (bArr[i7] << 7) ^ b5;
                if (i9 < 0) {
                    i4 = i9 ^ (-128);
                } else {
                    int i10 = i5 + 3;
                    int i11 = (bArr[i8] << 14) ^ i9;
                    if (i11 >= 0) {
                        i4 = i11 ^ 16256;
                    } else {
                        int i12 = i5 + 4;
                        int i13 = i11 ^ (bArr[i10] << 21);
                        if (i13 < 0) {
                            i4 = (-2080896) ^ i13;
                        } else {
                            i10 = i5 + 5;
                            byte b6 = bArr[i12];
                            int i14 = (i13 ^ (b6 << 28)) ^ 266354560;
                            if (b6 < 0) {
                                i12 = i5 + 6;
                                if (bArr[i10] < 0) {
                                    i10 = i5 + 7;
                                    if (bArr[i12] < 0) {
                                        i12 = i5 + 8;
                                        if (bArr[i10] < 0) {
                                            i10 = i5 + 9;
                                            if (bArr[i12] < 0) {
                                                int i15 = i5 + 10;
                                                if (bArr[i10] >= 0) {
                                                    i8 = i15;
                                                    i4 = i14;
                                                }
                                            }
                                        }
                                    }
                                }
                                i4 = i14;
                            }
                            i4 = i14;
                        }
                        i8 = i12;
                    }
                    i8 = i10;
                }
                this.zzi = i8;
                return i4;
            }
        }
        return (int) zzs();
    }

    @Override // com.google.android.recaptcha.internal.zzhc
    public final int zzk() {
        return zzi();
    }

    @Override // com.google.android.recaptcha.internal.zzhc
    public final int zzl() {
        return zzhc.zzF(zzj());
    }

    @Override // com.google.android.recaptcha.internal.zzhc
    public final int zzm() throws zzje {
        if (zzC()) {
            this.zzj = 0;
            return 0;
        }
        int iZzj = zzj();
        this.zzj = iZzj;
        if ((iZzj >>> 3) != 0) {
            return iZzj;
        }
        throw zzje.zzc();
    }

    @Override // com.google.android.recaptcha.internal.zzhc
    public final int zzn() {
        return zzj();
    }

    @Override // com.google.android.recaptcha.internal.zzhc
    public final long zzo() {
        return zzq();
    }

    @Override // com.google.android.recaptcha.internal.zzhc
    public final long zzp() {
        return zzr();
    }

    public final long zzq() throws zzje {
        int i4 = this.zzi;
        if (this.zzg - i4 < 8) {
            zzK(8);
            i4 = this.zzi;
        }
        byte[] bArr = this.zzf;
        this.zzi = i4 + 8;
        long j4 = bArr[i4];
        long j5 = (((long) bArr[i4 + 1]) & 255) << 8;
        long j6 = bArr[i4 + 2];
        long j7 = bArr[i4 + 3];
        return ((((long) bArr[i4 + 6]) & 255) << 48) | (j4 & 255) | j5 | ((j6 & 255) << 16) | ((j7 & 255) << 24) | ((bArr[i4 + 4] & 255) << 32) | ((bArr[i4 + 5] & 255) << 40) | ((((long) bArr[i4 + 7]) & 255) << 56);
    }

    public final long zzr() {
        long j4;
        long j5;
        int i4 = this.zzi;
        int i5 = this.zzg;
        if (i5 != i4) {
            byte[] bArr = this.zzf;
            int i6 = i4 + 1;
            byte b5 = bArr[i4];
            if (b5 >= 0) {
                this.zzi = i6;
                return b5;
            }
            if (i5 - i6 >= 9) {
                int i7 = i4 + 2;
                int i8 = (bArr[i6] << 7) ^ b5;
                if (i8 < 0) {
                    j4 = i8 ^ (-128);
                } else {
                    int i9 = i4 + 3;
                    int i10 = (bArr[i7] << 14) ^ i8;
                    if (i10 >= 0) {
                        j4 = i10 ^ 16256;
                    } else {
                        int i11 = i4 + 4;
                        int i12 = i10 ^ (bArr[i9] << 21);
                        if (i12 < 0) {
                            long j6 = (-2080896) ^ i12;
                            i7 = i11;
                            j4 = j6;
                        } else {
                            i9 = i4 + 5;
                            long j7 = (((long) bArr[i11]) << 28) ^ ((long) i12);
                            if (j7 >= 0) {
                                j4 = j7 ^ 266354560;
                            } else {
                                i7 = i4 + 6;
                                long j8 = (((long) bArr[i9]) << 35) ^ j7;
                                if (j8 < 0) {
                                    j5 = -34093383808L;
                                } else {
                                    int i13 = i4 + 7;
                                    long j9 = j8 ^ (((long) bArr[i7]) << 42);
                                    if (j9 >= 0) {
                                        j4 = j9 ^ 4363953127296L;
                                    } else {
                                        i7 = i4 + 8;
                                        j8 = j9 ^ (((long) bArr[i13]) << 49);
                                        if (j8 < 0) {
                                            j5 = -558586000294016L;
                                        } else {
                                            i13 = i4 + 9;
                                            long j10 = (j8 ^ (((long) bArr[i7]) << 56)) ^ 71499008037633920L;
                                            if (j10 < 0) {
                                                i7 = i4 + 10;
                                                if (bArr[i13] >= 0) {
                                                    j4 = j10;
                                                }
                                            } else {
                                                j4 = j10;
                                            }
                                        }
                                    }
                                    i7 = i13;
                                }
                                j4 = j8 ^ j5;
                            }
                        }
                    }
                    i7 = i9;
                }
                this.zzi = i7;
                return j4;
            }
        }
        return zzs();
    }

    public final long zzs() throws zzje {
        long j4 = 0;
        for (int i4 = 0; i4 < 64; i4 += 7) {
            byte bZza = zza();
            j4 |= ((long) (bZza & 127)) << i4;
            if ((bZza & 128) == 0) {
                return j4;
            }
        }
        throw zzje.zze();
    }

    @Override // com.google.android.recaptcha.internal.zzhc
    public final long zzt() {
        return zzq();
    }

    @Override // com.google.android.recaptcha.internal.zzhc
    public final long zzu() {
        return zzhc.zzG(zzr());
    }

    @Override // com.google.android.recaptcha.internal.zzhc
    public final long zzv() {
        return zzr();
    }

    @Override // com.google.android.recaptcha.internal.zzhc
    public final zzgw zzw() throws IOException {
        int iZzj = zzj();
        int i4 = this.zzg;
        int i5 = this.zzi;
        if (iZzj <= i4 - i5 && iZzj > 0) {
            zzgw zzgwVarZzm = zzgw.zzm(this.zzf, i5, iZzj);
            this.zzi += iZzj;
            return zzgwVarZzm;
        }
        if (iZzj == 0) {
            return zzgw.zzb;
        }
        byte[] bArrZzN = zzN(iZzj);
        if (bArrZzN != null) {
            return zzgw.zzm(bArrZzN, 0, bArrZzN.length);
        }
        int i6 = this.zzi;
        int i7 = this.zzg;
        int i8 = i7 - i6;
        this.zzk += i7;
        this.zzi = 0;
        this.zzg = 0;
        List<byte[]> listZzI = zzI(iZzj - i8);
        byte[] bArr = new byte[iZzj];
        System.arraycopy(this.zzf, i6, bArr, 0, i8);
        for (byte[] bArr2 : listZzI) {
            int length = bArr2.length;
            System.arraycopy(bArr2, 0, bArr, i8, length);
            i8 += length;
        }
        return new zzgt(bArr);
    }

    @Override // com.google.android.recaptcha.internal.zzhc
    public final String zzx() throws zzje {
        int iZzj = zzj();
        if (iZzj > 0) {
            int i4 = this.zzg;
            int i5 = this.zzi;
            if (iZzj <= i4 - i5) {
                String str = new String(this.zzf, i5, iZzj, zzjc.zzb);
                this.zzi += iZzj;
                return str;
            }
        }
        if (iZzj == 0) {
            return "";
        }
        if (iZzj > this.zzg) {
            return new String(zzM(iZzj, false), zzjc.zzb);
        }
        zzK(iZzj);
        String str2 = new String(this.zzf, this.zzi, iZzj, zzjc.zzb);
        this.zzi += iZzj;
        return str2;
    }

    @Override // com.google.android.recaptcha.internal.zzhc
    public final String zzy() throws IOException {
        byte[] bArrZzM;
        int iZzj = zzj();
        int i4 = this.zzi;
        int i5 = this.zzg;
        if (iZzj <= i5 - i4 && iZzj > 0) {
            bArrZzM = this.zzf;
            this.zzi = i4 + iZzj;
        } else {
            if (iZzj == 0) {
                return "";
            }
            i4 = 0;
            if (iZzj <= i5) {
                zzK(iZzj);
                bArrZzM = this.zzf;
                this.zzi = iZzj;
            } else {
                bArrZzM = zzM(iZzj, false);
            }
        }
        return zzma.zzd(bArrZzM, i4, iZzj);
    }

    @Override // com.google.android.recaptcha.internal.zzhc
    public final void zzz(int i4) throws zzje {
        if (this.zzj != i4) {
            throw zzje.zzb();
        }
    }
}
