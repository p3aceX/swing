package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.common.api.f;

/* JADX INFO: loaded from: classes.dex */
final class zzaia extends zzaib {
    private final byte[] zze;
    private final boolean zzf;
    private int zzg;
    private int zzh;
    private int zzi;
    private int zzj;
    private int zzk;
    private int zzl;

    private final void zzaa() {
        int i4 = this.zzg + this.zzh;
        this.zzg = i4;
        int i5 = i4 - this.zzj;
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
        int i4 = this.zzi;
        if (i4 == this.zzg) {
            throw zzajj.zzi();
        }
        byte[] bArr = this.zze;
        this.zzi = i4 + 1;
        return bArr[i4];
    }

    private final int zzw() throws zzajj {
        int i4 = this.zzi;
        if (this.zzg - i4 < 4) {
            throw zzajj.zzi();
        }
        byte[] bArr = this.zze;
        this.zzi = i4 + 4;
        return ((bArr[i4 + 3] & 255) << 24) | (bArr[i4] & 255) | ((bArr[i4 + 1] & 255) << 8) | ((bArr[i4 + 2] & 255) << 16);
    }

    private final int zzx() {
        int i4;
        int i5 = this.zzi;
        int i6 = this.zzg;
        if (i6 != i5) {
            byte[] bArr = this.zze;
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
            throw zzajj.zzi();
        }
        byte[] bArr = this.zze;
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
            byte[] bArr = this.zze;
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
        return this.zzi - this.zzj;
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
            this.zzk = 0;
            return 0;
        }
        int iZzx = zzx();
        this.zzk = iZzx;
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

    /* JADX WARN: Removed duplicated region for block: B:15:0x0031  */
    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaib
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final com.google.android.gms.internal.p002firebaseauthapi.zzahm zzq() throws com.google.android.gms.internal.p002firebaseauthapi.zzajj {
        /*
            r3 = this;
            int r0 = r3.zzx()
            if (r0 <= 0) goto L19
            int r1 = r3.zzg
            int r2 = r3.zzi
            int r1 = r1 - r2
            if (r0 > r1) goto L19
            byte[] r1 = r3.zze
            com.google.android.gms.internal.firebase-auth-api.zzahm r1 = com.google.android.gms.internal.p002firebaseauthapi.zzahm.zza(r1, r2, r0)
            int r2 = r3.zzi
            int r2 = r2 + r0
            r3.zzi = r2
            return r1
        L19:
            if (r0 != 0) goto L1e
            com.google.android.gms.internal.firebase-auth-api.zzahm r0 = com.google.android.gms.internal.p002firebaseauthapi.zzahm.zza
            return r0
        L1e:
            if (r0 <= 0) goto L31
            int r1 = r3.zzg
            int r2 = r3.zzi
            int r1 = r1 - r2
            if (r0 > r1) goto L31
            int r0 = r0 + r2
            r3.zzi = r0
            byte[] r1 = r3.zze
            byte[] r0 = java.util.Arrays.copyOfRange(r1, r2, r0)
            goto L37
        L31:
            if (r0 > 0) goto L41
            if (r0 != 0) goto L3c
            byte[] r0 = com.google.android.gms.internal.p002firebaseauthapi.zzajc.zzb
        L37:
            com.google.android.gms.internal.firebase-auth-api.zzahm r0 = com.google.android.gms.internal.p002firebaseauthapi.zzahm.zzb(r0)
            return r0
        L3c:
            com.google.android.gms.internal.firebase-auth-api.zzajj r0 = com.google.android.gms.internal.p002firebaseauthapi.zzajj.zzf()
            throw r0
        L41:
            com.google.android.gms.internal.firebase-auth-api.zzajj r0 = com.google.android.gms.internal.p002firebaseauthapi.zzajj.zzi()
            throw r0
        */
        throw new UnsupportedOperationException("Method not decompiled: com.google.android.gms.internal.p002firebaseauthapi.zzaia.zzq():com.google.android.gms.internal.firebase-auth-api.zzahm");
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaib
    public final String zzr() throws zzajj {
        int iZzx = zzx();
        if (iZzx > 0) {
            int i4 = this.zzg;
            int i5 = this.zzi;
            if (iZzx <= i4 - i5) {
                String str = new String(this.zze, i5, iZzx, zzajc.zza);
                this.zzi += iZzx;
                return str;
            }
        }
        if (iZzx == 0) {
            return "";
        }
        if (iZzx < 0) {
            throw zzajj.zzf();
        }
        throw zzajj.zzi();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaib
    public final String zzs() throws zzajj {
        int iZzx = zzx();
        if (iZzx > 0) {
            int i4 = this.zzg;
            int i5 = this.zzi;
            if (iZzx <= i4 - i5) {
                String strZzb = zzaml.zzb(this.zze, i5, iZzx);
                this.zzi += iZzx;
                return strZzb;
            }
        }
        if (iZzx == 0) {
            return "";
        }
        if (iZzx <= 0) {
            throw zzajj.zzf();
        }
        throw zzajj.zzi();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaib
    public final boolean zzt() {
        return this.zzi == this.zzg;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaib
    public final boolean zzu() {
        return zzz() != 0;
    }

    private zzaia(byte[] bArr, int i4, int i5, boolean z4) {
        super();
        this.zzl = f.API_PRIORITY_OTHER;
        this.zze = bArr;
        this.zzg = i5 + i4;
        this.zzi = i4;
        this.zzj = i4;
        this.zzf = z4;
    }

    private final void zzf(int i4) throws zzajj {
        if (i4 >= 0) {
            int i5 = this.zzg;
            int i6 = this.zzi;
            if (i4 <= i5 - i6) {
                this.zzi = i6 + i4;
                return;
            }
        }
        if (i4 >= 0) {
            throw zzajj.zzi();
        }
        throw zzajj.zzf();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaib
    public final int zza(int i4) throws zzajj {
        if (i4 < 0) {
            throw zzajj.zzf();
        }
        int iZzc = i4 + zzc();
        if (iZzc < 0) {
            throw zzajj.zzg();
        }
        int i5 = this.zzl;
        if (iZzc > i5) {
            throw zzajj.zzi();
        }
        this.zzl = iZzc;
        zzaa();
        return i5;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaib
    public final void zzb(int i4) throws zzajj {
        if (this.zzk != i4) {
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
                byte[] bArr = this.zze;
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
            zzf(8);
            return true;
        }
        if (i5 == 2) {
            zzf(zzx());
            return true;
        }
        if (i5 != 3) {
            if (i5 == 4) {
                return false;
            }
            if (i5 != 5) {
                throw zzajj.zza();
            }
            zzf(4);
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
}
