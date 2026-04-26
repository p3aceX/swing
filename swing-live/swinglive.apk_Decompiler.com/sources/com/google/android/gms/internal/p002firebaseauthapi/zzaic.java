package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import com.google.android.gms.common.api.f;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
final class zzaic extends zzaib {
    private final InputStream zze;
    private final byte[] zzf;
    private int zzg;
    private int zzh;
    private int zzi;
    private int zzj;
    private int zzk;
    private int zzl;
    private zzaif zzm;

    private final void zzaa() {
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

    private final byte zzv() throws zzajj {
        if (this.zzi == this.zzg) {
            zzg(1);
        }
        byte[] bArr = this.zzf;
        int i4 = this.zzi;
        this.zzi = i4 + 1;
        return bArr[i4];
    }

    private final int zzw() throws zzajj {
        int i4 = this.zzi;
        if (this.zzg - i4 < 4) {
            zzg(4);
            i4 = this.zzi;
        }
        byte[] bArr = this.zzf;
        this.zzi = i4 + 4;
        return ((bArr[i4 + 3] & 255) << 24) | (bArr[i4] & 255) | ((bArr[i4 + 1] & 255) << 8) | ((bArr[i4 + 2] & 255) << 16);
    }

    private final int zzx() {
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
        return (int) zzm();
    }

    private final long zzy() throws zzajj {
        int i4 = this.zzi;
        if (this.zzg - i4 < 8) {
            zzg(8);
            i4 = this.zzi;
        }
        byte[] bArr = this.zzf;
        this.zzi = i4 + 8;
        return ((((long) bArr[i4 + 7]) & 255) << 56) | (((long) bArr[i4]) & 255) | ((((long) bArr[i4 + 1]) & 255) << 8) | ((((long) bArr[i4 + 2]) & 255) << 16) | ((((long) bArr[i4 + 3]) & 255) << 24) | ((((long) bArr[i4 + 4]) & 255) << 32) | ((((long) bArr[i4 + 5]) & 255) << 40) | ((((long) bArr[i4 + 6]) & 255) << 48);
    }

    private final long zzz() {
        long j4;
        long j5;
        long j6;
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
                        i7 = i9;
                    } else {
                        int i11 = i4 + 4;
                        int i12 = i10 ^ (bArr[i9] << 21);
                        if (i12 < 0) {
                            long j7 = (-2080896) ^ i12;
                            i7 = i11;
                            j4 = j7;
                        } else {
                            long j8 = i12;
                            i7 = i4 + 5;
                            long j9 = j8 ^ (((long) bArr[i11]) << 28);
                            if (j9 >= 0) {
                                j6 = 266354560;
                            } else {
                                int i13 = i4 + 6;
                                long j10 = j9 ^ (((long) bArr[i7]) << 35);
                                if (j10 < 0) {
                                    j5 = -34093383808L;
                                } else {
                                    i7 = i4 + 7;
                                    j9 = j10 ^ (((long) bArr[i13]) << 42);
                                    if (j9 >= 0) {
                                        j6 = 4363953127296L;
                                    } else {
                                        i13 = i4 + 8;
                                        j10 = j9 ^ (((long) bArr[i7]) << 49);
                                        if (j10 < 0) {
                                            j5 = -558586000294016L;
                                        } else {
                                            i7 = i4 + 9;
                                            long j11 = (j10 ^ (((long) bArr[i13]) << 56)) ^ 71499008037633920L;
                                            if (j11 < 0) {
                                                int i14 = i4 + 10;
                                                if (bArr[i7] >= 0) {
                                                    i7 = i14;
                                                }
                                            }
                                            j4 = j11;
                                        }
                                    }
                                }
                                j4 = j10 ^ j5;
                                i7 = i13;
                            }
                            j4 = j9 ^ j6;
                        }
                    }
                }
                this.zzi = i7;
                return j4;
            }
        }
        return zzm();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaib
    public final double zza() {
        return Double.longBitsToDouble(zzy());
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaib
    public final float zzb() {
        return Float.intBitsToFloat(zzw());
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaib
    public final int zzc() {
        return this.zzk + this.zzi;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaib
    public final int zzd() {
        return zzx();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaib
    public final int zze() {
        return zzw();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaib
    public final int zzf() {
        return zzx();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaib
    public final int zzg() {
        return zzw();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaib
    public final int zzh() {
        return zzaib.zze(zzx());
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaib
    public final int zzi() throws zzajj {
        if (zzt()) {
            this.zzj = 0;
            return 0;
        }
        int iZzx = zzx();
        this.zzj = iZzx;
        if ((iZzx >>> 3) != 0) {
            return iZzx;
        }
        throw zzajj.zzc();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaib
    public final int zzj() {
        return zzx();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaib
    public final long zzk() {
        return zzy();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaib
    public final long zzl() {
        return zzz();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaib
    public final long zzm() throws zzajj {
        long j4 = 0;
        for (int i4 = 0; i4 < 64; i4 += 7) {
            byte bZzv = zzv();
            j4 |= ((long) (bZzv & 127)) << i4;
            if ((bZzv & 128) == 0) {
                return j4;
            }
        }
        throw zzajj.zze();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaib
    public final long zzn() {
        return zzy();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaib
    public final long zzo() {
        return zzaib.zza(zzz());
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaib
    public final long zzp() {
        return zzz();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaib
    public final zzahm zzq() throws IOException {
        int iZzx = zzx();
        int i4 = this.zzg;
        int i5 = this.zzi;
        if (iZzx <= i4 - i5 && iZzx > 0) {
            zzahm zzahmVarZza = zzahm.zza(this.zzf, i5, iZzx);
            this.zzi += iZzx;
            return zzahmVarZza;
        }
        if (iZzx == 0) {
            return zzahm.zza;
        }
        byte[] bArrZzj = zzj(iZzx);
        if (bArrZzj != null) {
            return zzahm.zza(bArrZzj);
        }
        int i6 = this.zzi;
        int i7 = this.zzg;
        int length = i7 - i6;
        this.zzk += i7;
        this.zzi = 0;
        this.zzg = 0;
        List<byte[]> listZzf = zzf(iZzx - length);
        byte[] bArr = new byte[iZzx];
        System.arraycopy(this.zzf, i6, bArr, 0, length);
        for (byte[] bArr2 : listZzf) {
            System.arraycopy(bArr2, 0, bArr, length, bArr2.length);
            length += bArr2.length;
        }
        return zzahm.zzb(bArr);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaib
    public final String zzr() throws zzajj {
        int iZzx = zzx();
        if (iZzx > 0) {
            int i4 = this.zzg;
            int i5 = this.zzi;
            if (iZzx <= i4 - i5) {
                String str = new String(this.zzf, i5, iZzx, zzajc.zza);
                this.zzi += iZzx;
                return str;
            }
        }
        if (iZzx == 0) {
            return "";
        }
        if (iZzx > this.zzg) {
            return new String(zza(iZzx, false), zzajc.zza);
        }
        zzg(iZzx);
        String str2 = new String(this.zzf, this.zzi, iZzx, zzajc.zza);
        this.zzi += iZzx;
        return str2;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaib
    public final String zzs() throws IOException {
        byte[] bArrZza;
        int iZzx = zzx();
        int i4 = this.zzi;
        int i5 = this.zzg;
        if (iZzx <= i5 - i4 && iZzx > 0) {
            bArrZza = this.zzf;
            this.zzi = i4 + iZzx;
        } else {
            if (iZzx == 0) {
                return "";
            }
            i4 = 0;
            if (iZzx <= i5) {
                zzg(iZzx);
                bArrZza = this.zzf;
                this.zzi = iZzx;
            } else {
                bArrZza = zza(iZzx, false);
            }
        }
        return zzaml.zzb(bArrZza, i4, iZzx);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaib
    public final boolean zzt() {
        return this.zzi == this.zzg && !zzi(1);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaib
    public final boolean zzu() {
        return zzz() != 0;
    }

    private zzaic(InputStream inputStream, int i4) {
        super();
        this.zzl = f.API_PRIORITY_OTHER;
        this.zzm = null;
        zzajc.zza(inputStream, "input");
        this.zze = inputStream;
        this.zzf = new byte[4096];
        this.zzg = 0;
        this.zzi = 0;
        this.zzk = 0;
    }

    private static int zza(InputStream inputStream) throws zzajj {
        try {
            return inputStream.available();
        } catch (zzajj e) {
            e.zzj();
            throw e;
        }
    }

    private final List<byte[]> zzf(int i4) throws IOException {
        ArrayList arrayList = new ArrayList();
        while (i4 > 0) {
            int iMin = Math.min(i4, 4096);
            byte[] bArr = new byte[iMin];
            int i5 = 0;
            while (i5 < iMin) {
                int i6 = this.zze.read(bArr, i5, iMin - i5);
                if (i6 == -1) {
                    throw zzajj.zzi();
                }
                this.zzk += i6;
                i5 += i6;
            }
            i4 -= iMin;
            arrayList.add(bArr);
        }
        return arrayList;
    }

    private final void zzg(int i4) throws zzajj {
        if (zzi(i4)) {
            return;
        }
        if (i4 <= (this.zzc - this.zzk) - this.zzi) {
            throw zzajj.zzi();
        }
        throw zzajj.zzh();
    }

    private final void zzh(int i4) throws zzajj {
        int i5 = this.zzg;
        int i6 = this.zzi;
        if (i4 <= i5 - i6 && i4 >= 0) {
            this.zzi = i6 + i4;
            return;
        }
        if (i4 < 0) {
            throw zzajj.zzf();
        }
        int i7 = this.zzk;
        int i8 = i7 + i6 + i4;
        int i9 = this.zzl;
        if (i8 > i9) {
            zzh((i9 - i7) - i6);
            throw zzajj.zzi();
        }
        this.zzk = i7 + i6;
        int i10 = i5 - i6;
        this.zzg = 0;
        this.zzi = 0;
        while (i10 < i4) {
            try {
                long j4 = i4 - i10;
                long jZza = zza(this.zze, j4);
                if (jZza >= 0 && jZza <= j4) {
                    if (jZza == 0) {
                        break;
                    } else {
                        i10 += (int) jZza;
                    }
                } else {
                    throw new IllegalStateException(String.valueOf(this.zze.getClass()) + "#skip returned invalid result: " + jZza + "\nThe InputStream implementation is buggy.");
                }
            } finally {
                this.zzk += i10;
                zzaa();
            }
        }
        if (i10 >= i4) {
            return;
        }
        int i11 = this.zzg;
        int i12 = i11 - this.zzi;
        this.zzi = i11;
        zzg(1);
        while (true) {
            int i13 = i4 - i12;
            int i14 = this.zzg;
            if (i13 <= i14) {
                this.zzi = i13;
                return;
            } else {
                i12 += i14;
                this.zzi = i14;
                zzg(1);
            }
        }
    }

    private final byte[] zzj(int i4) throws zzajj {
        if (i4 == 0) {
            return zzajc.zzb;
        }
        if (i4 < 0) {
            throw zzajj.zzf();
        }
        int i5 = this.zzk;
        int i6 = this.zzi;
        int i7 = i5 + i6 + i4;
        if (i7 - this.zzc > 0) {
            throw zzajj.zzh();
        }
        int i8 = this.zzl;
        if (i7 > i8) {
            zzh((i8 - i5) - i6);
            throw zzajj.zzi();
        }
        int i9 = this.zzg - i6;
        int i10 = i4 - i9;
        if (i10 >= 4096 && i10 > zza(this.zze)) {
            return null;
        }
        byte[] bArr = new byte[i4];
        System.arraycopy(this.zzf, this.zzi, bArr, 0, i9);
        this.zzk += this.zzg;
        this.zzi = 0;
        this.zzg = 0;
        while (i9 < i4) {
            int iZza = zza(this.zze, bArr, i9, i4 - i9);
            if (iZza == -1) {
                throw zzajj.zzi();
            }
            this.zzk += iZza;
            i9 += iZza;
        }
        return bArr;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaib
    public final void zzb(int i4) throws zzajj {
        if (this.zzj != i4) {
            throw zzajj.zzb();
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaib
    public final void zzc(int i4) {
        this.zzl = i4;
        zzaa();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaib
    public final boolean zzd(int i4) throws zzajj {
        int iZzi;
        int i5 = i4 & 7;
        int i6 = 0;
        if (i5 == 0) {
            if (this.zzg - this.zzi < 10) {
                while (i6 < 10) {
                    if (zzv() < 0) {
                        i6++;
                    }
                }
                throw zzajj.zze();
            }
            while (i6 < 10) {
                byte[] bArr = this.zzf;
                int i7 = this.zzi;
                this.zzi = i7 + 1;
                if (bArr[i7] < 0) {
                    i6++;
                }
            }
            throw zzajj.zze();
            return true;
        }
        if (i5 == 1) {
            zzh(8);
            return true;
        }
        if (i5 == 2) {
            zzh(zzx());
            return true;
        }
        if (i5 != 3) {
            if (i5 == 4) {
                return false;
            }
            if (i5 != 5) {
                throw zzajj.zza();
            }
            zzh(4);
            return true;
        }
        do {
            iZzi = zzi();
            if (iZzi == 0) {
                break;
            }
        } while (zzd(iZzi));
        zzb(((i4 >>> 3) << 3) | 4);
        return true;
    }

    private final boolean zzi(int i4) throws zzajj {
        do {
            int i5 = this.zzi;
            int i6 = i5 + i4;
            int i7 = this.zzg;
            if (i6 > i7) {
                int i8 = this.zzc;
                int i9 = this.zzk;
                if (i4 > (i8 - i9) - i5 || i9 + i5 + i4 > this.zzl) {
                    return false;
                }
                if (i5 > 0) {
                    if (i7 > i5) {
                        byte[] bArr = this.zzf;
                        System.arraycopy(bArr, i5, bArr, 0, i7 - i5);
                    }
                    this.zzk += i5;
                    this.zzg -= i5;
                    this.zzi = 0;
                }
                InputStream inputStream = this.zze;
                byte[] bArr2 = this.zzf;
                int i10 = this.zzg;
                int iZza = zza(inputStream, bArr2, i10, Math.min(bArr2.length - i10, (this.zzc - this.zzk) - i10));
                if (iZza == 0 || iZza < -1 || iZza > this.zzf.length) {
                    throw new IllegalStateException(String.valueOf(this.zze.getClass()) + "#read(byte[]) returned invalid result: " + iZza + "\nThe InputStream implementation is buggy.");
                }
                if (iZza <= 0) {
                    return false;
                }
                this.zzg += iZza;
                zzaa();
            } else {
                throw new IllegalStateException(a.l("refillBuffer() called when ", i4, " bytes were already available in buffer"));
            }
        } while (this.zzg < i4);
        return true;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaib
    public final int zza(int i4) throws zzajj {
        if (i4 >= 0) {
            int i5 = this.zzk + this.zzi + i4;
            int i6 = this.zzl;
            if (i5 <= i6) {
                this.zzl = i5;
                zzaa();
                return i6;
            }
            throw zzajj.zzi();
        }
        throw zzajj.zzf();
    }

    private static int zza(InputStream inputStream, byte[] bArr, int i4, int i5) throws zzajj {
        try {
            return inputStream.read(bArr, i4, i5);
        } catch (zzajj e) {
            e.zzj();
            throw e;
        }
    }

    private static long zza(InputStream inputStream, long j4) throws zzajj {
        try {
            return inputStream.skip(j4);
        } catch (zzajj e) {
            e.zzj();
            throw e;
        }
    }

    private final byte[] zza(int i4, boolean z4) throws IOException {
        byte[] bArrZzj = zzj(i4);
        if (bArrZzj != null) {
            return bArrZzj;
        }
        int i5 = this.zzi;
        int i6 = this.zzg;
        int length = i6 - i5;
        this.zzk += i6;
        this.zzi = 0;
        this.zzg = 0;
        List<byte[]> listZzf = zzf(i4 - length);
        byte[] bArr = new byte[i4];
        System.arraycopy(this.zzf, i5, bArr, 0, length);
        for (byte[] bArr2 : listZzf) {
            System.arraycopy(bArr2, 0, bArr, length, bArr2.length);
            length += bArr2.length;
        }
        return bArr;
    }
}
