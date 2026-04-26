package com.google.android.recaptcha.internal;

import com.google.android.gms.common.api.f;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
final class zzgy extends zzhc {
    private final byte[] zze;
    private int zzf;
    private int zzg;
    private int zzh;
    private int zzi;
    private int zzj;

    public /* synthetic */ zzgy(byte[] bArr, int i4, int i5, boolean z4, zzgx zzgxVar) {
        super(null);
        this.zzj = f.API_PRIORITY_OTHER;
        this.zze = bArr;
        this.zzf = 0;
        this.zzh = 0;
    }

    private final void zzI() {
        int i4 = this.zzf + this.zzg;
        this.zzf = i4;
        int i5 = this.zzj;
        if (i4 <= i5) {
            this.zzg = 0;
            return;
        }
        int i6 = i4 - i5;
        this.zzg = i6;
        this.zzf = i4 - i6;
    }

    @Override // com.google.android.recaptcha.internal.zzhc
    public final void zzA(int i4) {
        this.zzj = i4;
        zzI();
    }

    public final void zzB(int i4) throws zzje {
        if (i4 >= 0) {
            int i5 = this.zzf;
            int i6 = this.zzh;
            if (i4 <= i5 - i6) {
                this.zzh = i6 + i4;
                return;
            }
        }
        if (i4 >= 0) {
            throw zzje.zzj();
        }
        throw zzje.zzf();
    }

    @Override // com.google.android.recaptcha.internal.zzhc
    public final boolean zzC() {
        return this.zzh == this.zzf;
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
            if (this.zzf - this.zzh < 10) {
                while (i6 < 10) {
                    if (zza() < 0) {
                        i6++;
                    }
                }
                throw zzje.zze();
            }
            while (i6 < 10) {
                byte[] bArr = this.zze;
                int i7 = this.zzh;
                this.zzh = i7 + 1;
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
        int i4 = this.zzh;
        if (i4 == this.zzf) {
            throw zzje.zzj();
        }
        byte[] bArr = this.zze;
        this.zzh = i4 + 1;
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
        return this.zzh;
    }

    @Override // com.google.android.recaptcha.internal.zzhc
    public final int zze(int i4) {
        if (i4 < 0) {
            throw zzje.zzf();
        }
        int i5 = i4 + this.zzh;
        if (i5 < 0) {
            throw zzje.zzg();
        }
        int i6 = this.zzj;
        if (i5 > i6) {
            throw zzje.zzj();
        }
        this.zzj = i5;
        zzI();
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
        int i4 = this.zzh;
        if (this.zzf - i4 < 4) {
            throw zzje.zzj();
        }
        byte[] bArr = this.zze;
        this.zzh = i4 + 4;
        int i5 = bArr[i4] & 255;
        int i6 = bArr[i4 + 1] & 255;
        int i7 = bArr[i4 + 2] & 255;
        return ((bArr[i4 + 3] & 255) << 24) | (i6 << 8) | i5 | (i7 << 16);
    }

    public final int zzj() {
        int i4;
        int i5 = this.zzh;
        int i6 = this.zzf;
        if (i6 != i5) {
            byte[] bArr = this.zze;
            int i7 = i5 + 1;
            byte b5 = bArr[i5];
            if (b5 >= 0) {
                this.zzh = i7;
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
                this.zzh = i8;
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
            this.zzi = 0;
            return 0;
        }
        int iZzj = zzj();
        this.zzi = iZzj;
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
        int i4 = this.zzh;
        if (this.zzf - i4 < 8) {
            throw zzje.zzj();
        }
        byte[] bArr = this.zze;
        this.zzh = i4 + 8;
        long j4 = bArr[i4];
        long j5 = (((long) bArr[i4 + 1]) & 255) << 8;
        long j6 = bArr[i4 + 2];
        long j7 = bArr[i4 + 3];
        return ((((long) bArr[i4 + 6]) & 255) << 48) | (j4 & 255) | j5 | ((j6 & 255) << 16) | ((j7 & 255) << 24) | ((bArr[i4 + 4] & 255) << 32) | ((bArr[i4 + 5] & 255) << 40) | ((((long) bArr[i4 + 7]) & 255) << 56);
    }

    public final long zzr() {
        long j4;
        long j5;
        int i4 = this.zzh;
        int i5 = this.zzf;
        if (i5 != i4) {
            byte[] bArr = this.zze;
            int i6 = i4 + 1;
            byte b5 = bArr[i4];
            if (b5 >= 0) {
                this.zzh = i6;
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
                this.zzh = i7;
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
    public final zzgw zzw() throws zzje {
        int iZzj = zzj();
        if (iZzj > 0) {
            int i4 = this.zzf;
            int i5 = this.zzh;
            if (iZzj <= i4 - i5) {
                zzgw zzgwVarZzm = zzgw.zzm(this.zze, i5, iZzj);
                this.zzh += iZzj;
                return zzgwVarZzm;
            }
        }
        if (iZzj == 0) {
            return zzgw.zzb;
        }
        if (iZzj > 0) {
            int i6 = this.zzf;
            int i7 = this.zzh;
            if (iZzj <= i6 - i7) {
                int i8 = iZzj + i7;
                this.zzh = i8;
                return new zzgt(Arrays.copyOfRange(this.zze, i7, i8));
            }
        }
        if (iZzj <= 0) {
            throw zzje.zzf();
        }
        throw zzje.zzj();
    }

    @Override // com.google.android.recaptcha.internal.zzhc
    public final String zzx() throws zzje {
        int iZzj = zzj();
        if (iZzj > 0) {
            int i4 = this.zzf;
            int i5 = this.zzh;
            if (iZzj <= i4 - i5) {
                String str = new String(this.zze, i5, iZzj, zzjc.zzb);
                this.zzh += iZzj;
                return str;
            }
        }
        if (iZzj == 0) {
            return "";
        }
        if (iZzj < 0) {
            throw zzje.zzf();
        }
        throw zzje.zzj();
    }

    @Override // com.google.android.recaptcha.internal.zzhc
    public final String zzy() throws zzje {
        int iZzj = zzj();
        if (iZzj > 0) {
            int i4 = this.zzf;
            int i5 = this.zzh;
            if (iZzj <= i4 - i5) {
                String strZzd = zzma.zzd(this.zze, i5, iZzj);
                this.zzh += iZzj;
                return strZzd;
            }
        }
        if (iZzj == 0) {
            return "";
        }
        if (iZzj <= 0) {
            throw zzje.zzf();
        }
        throw zzje.zzj();
    }

    @Override // com.google.android.recaptcha.internal.zzhc
    public final void zzz(int i4) throws zzje {
        if (this.zzi != i4) {
            throw zzje.zzb();
        }
    }
}
