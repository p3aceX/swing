package com.google.android.recaptcha.internal;

import B1.a;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class zzlm {
    private static final zzlm zza = new zzlm(0, new int[0], new Object[0], false);
    private int zzb;
    private int[] zzc;
    private Object[] zzd;
    private int zze;
    private boolean zzf;

    private zzlm(int i4, int[] iArr, Object[] objArr, boolean z4) {
        this.zze = -1;
        this.zzb = i4;
        this.zzc = iArr;
        this.zzd = objArr;
        this.zzf = z4;
    }

    public static zzlm zzc() {
        return zza;
    }

    public static zzlm zze(zzlm zzlmVar, zzlm zzlmVar2) {
        int i4 = zzlmVar.zzb + zzlmVar2.zzb;
        int[] iArrCopyOf = Arrays.copyOf(zzlmVar.zzc, i4);
        System.arraycopy(zzlmVar2.zzc, 0, iArrCopyOf, zzlmVar.zzb, zzlmVar2.zzb);
        Object[] objArrCopyOf = Arrays.copyOf(zzlmVar.zzd, i4);
        System.arraycopy(zzlmVar2.zzd, 0, objArrCopyOf, zzlmVar.zzb, zzlmVar2.zzb);
        return new zzlm(i4, iArrCopyOf, objArrCopyOf, true);
    }

    public static zzlm zzf() {
        return new zzlm(0, new int[8], new Object[8], true);
    }

    private final void zzm(int i4) {
        int[] iArr = this.zzc;
        if (i4 > iArr.length) {
            int i5 = this.zzb;
            int i6 = (i5 / 2) + i5;
            if (i6 >= i4) {
                i4 = i6;
            }
            if (i4 < 8) {
                i4 = 8;
            }
            this.zzc = Arrays.copyOf(iArr, i4);
            this.zzd = Arrays.copyOf(this.zzd, i4);
        }
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null || !(obj instanceof zzlm)) {
            return false;
        }
        zzlm zzlmVar = (zzlm) obj;
        int i4 = this.zzb;
        if (i4 == zzlmVar.zzb) {
            int[] iArr = this.zzc;
            int[] iArr2 = zzlmVar.zzc;
            int i5 = 0;
            while (true) {
                if (i5 >= i4) {
                    Object[] objArr = this.zzd;
                    Object[] objArr2 = zzlmVar.zzd;
                    int i6 = this.zzb;
                    for (int i7 = 0; i7 < i6; i7++) {
                        if (objArr[i7].equals(objArr2[i7])) {
                        }
                    }
                    return true;
                }
                if (iArr[i5] != iArr2[i5]) {
                    break;
                }
                i5++;
            }
        }
        return false;
    }

    public final int hashCode() {
        int i4 = this.zzb;
        int i5 = i4 + 527;
        int[] iArr = this.zzc;
        int iHashCode = 17;
        int i6 = 17;
        for (int i7 = 0; i7 < i4; i7++) {
            i6 = (i6 * 31) + iArr[i7];
        }
        int i8 = ((i5 * 31) + i6) * 31;
        Object[] objArr = this.zzd;
        int i9 = this.zzb;
        for (int i10 = 0; i10 < i9; i10++) {
            iHashCode = (iHashCode * 31) + objArr[i10].hashCode();
        }
        return i8 + iHashCode;
    }

    public final int zza() {
        int iZzy;
        int i4 = this.zze;
        if (i4 != -1) {
            return i4;
        }
        int iQ = 0;
        for (int i5 = 0; i5 < this.zzb; i5++) {
            int i6 = this.zzc[i5];
            int i7 = i6 >>> 3;
            int i8 = i6 & 7;
            if (i8 != 0) {
                if (i8 == 1) {
                    ((Long) this.zzd[i5]).getClass();
                    iZzy = zzhh.zzy(i7 << 3) + 8;
                } else if (i8 == 2) {
                    int i9 = i7 << 3;
                    zzgw zzgwVar = (zzgw) this.zzd[i5];
                    int i10 = zzhh.zzb;
                    int iZzd = zzgwVar.zzd();
                    iQ = a.q(i9, zzhh.zzy(iZzd) + iZzd, iQ);
                } else if (i8 == 3) {
                    int i11 = i7 << 3;
                    int i12 = zzhh.zzb;
                    int iZza = ((zzlm) this.zzd[i5]).zza();
                    int iZzy2 = zzhh.zzy(i11);
                    iZzy = iZzy2 + iZzy2 + iZza;
                } else {
                    if (i8 != 5) {
                        throw new IllegalStateException(zzje.zza());
                    }
                    ((Integer) this.zzd[i5]).getClass();
                    iZzy = zzhh.zzy(i7 << 3) + 4;
                }
                iQ = iZzy + iQ;
            } else {
                iQ = a.q(i7 << 3, zzhh.zzz(((Long) this.zzd[i5]).longValue()), iQ);
            }
        }
        this.zze = iQ;
        return iQ;
    }

    public final int zzb() {
        int i4 = this.zze;
        if (i4 != -1) {
            return i4;
        }
        int iZzy = 0;
        for (int i5 = 0; i5 < this.zzb; i5++) {
            int i6 = this.zzc[i5] >>> 3;
            zzgw zzgwVar = (zzgw) this.zzd[i5];
            int i7 = zzhh.zzb;
            int iZzd = zzgwVar.zzd();
            int iZzy2 = zzhh.zzy(iZzd) + iZzd;
            int iZzy3 = zzhh.zzy(16);
            int iZzy4 = zzhh.zzy(i6);
            int iZzy5 = zzhh.zzy(8);
            iZzy += zzhh.zzy(24) + iZzy2 + iZzy3 + iZzy4 + iZzy5 + iZzy5;
        }
        this.zze = iZzy;
        return iZzy;
    }

    public final zzlm zzd(zzlm zzlmVar) {
        if (zzlmVar.equals(zza)) {
            return this;
        }
        zzg();
        int i4 = this.zzb + zzlmVar.zzb;
        zzm(i4);
        System.arraycopy(zzlmVar.zzc, 0, this.zzc, this.zzb, zzlmVar.zzb);
        System.arraycopy(zzlmVar.zzd, 0, this.zzd, this.zzb, zzlmVar.zzb);
        this.zzb = i4;
        return this;
    }

    public final void zzg() {
        if (!this.zzf) {
            throw new UnsupportedOperationException();
        }
    }

    public final void zzh() {
        if (this.zzf) {
            this.zzf = false;
        }
    }

    public final void zzi(StringBuilder sb, int i4) {
        for (int i5 = 0; i5 < this.zzb; i5++) {
            zzkg.zzb(sb, i4, String.valueOf(this.zzc[i5] >>> 3), this.zzd[i5]);
        }
    }

    public final void zzj(int i4, Object obj) {
        zzg();
        zzm(this.zzb + 1);
        int[] iArr = this.zzc;
        int i5 = this.zzb;
        iArr[i5] = i4;
        this.zzd[i5] = obj;
        this.zzb = i5 + 1;
    }

    public final void zzk(zzmd zzmdVar) {
        for (int i4 = 0; i4 < this.zzb; i4++) {
            zzmdVar.zzw(this.zzc[i4] >>> 3, this.zzd[i4]);
        }
    }

    public final void zzl(zzmd zzmdVar) {
        if (this.zzb != 0) {
            for (int i4 = 0; i4 < this.zzb; i4++) {
                int i5 = this.zzc[i4];
                Object obj = this.zzd[i4];
                int i6 = i5 & 7;
                int i7 = i5 >>> 3;
                if (i6 == 0) {
                    zzmdVar.zzt(i7, ((Long) obj).longValue());
                } else if (i6 == 1) {
                    zzmdVar.zzm(i7, ((Long) obj).longValue());
                } else if (i6 == 2) {
                    zzmdVar.zzd(i7, (zzgw) obj);
                } else if (i6 == 3) {
                    zzmdVar.zzF(i7);
                    ((zzlm) obj).zzl(zzmdVar);
                    zzmdVar.zzh(i7);
                } else {
                    if (i6 != 5) {
                        throw new RuntimeException(zzje.zza());
                    }
                    zzmdVar.zzk(i7, ((Integer) obj).intValue());
                }
            }
        }
    }

    private zzlm() {
        this(0, new int[8], new Object[8], true);
    }
}
