package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class zzame {
    private static final zzame zza = new zzame(0, new int[0], new Object[0], false);
    private int zzb;
    private int[] zzc;
    private Object[] zzd;
    private int zze;
    private boolean zzf;

    private zzame() {
        this(0, new int[8], new Object[8], true);
    }

    public static zzame zzc() {
        return zza;
    }

    public static zzame zzd() {
        return new zzame();
    }

    private final void zzf() {
        if (!this.zzf) {
            throw new UnsupportedOperationException();
        }
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null || !(obj instanceof zzame)) {
            return false;
        }
        zzame zzameVar = (zzame) obj;
        int i4 = this.zzb;
        if (i4 == zzameVar.zzb) {
            int[] iArr = this.zzc;
            int[] iArr2 = zzameVar.zzc;
            int i5 = 0;
            while (true) {
                if (i5 >= i4) {
                    Object[] objArr = this.zzd;
                    Object[] objArr2 = zzameVar.zzd;
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
        int i5 = (i4 + 527) * 31;
        int[] iArr = this.zzc;
        int iHashCode = 17;
        int i6 = 17;
        for (int i7 = 0; i7 < i4; i7++) {
            i6 = (i6 * 31) + iArr[i7];
        }
        int i8 = (i5 + i6) * 31;
        Object[] objArr = this.zzd;
        int i9 = this.zzb;
        for (int i10 = 0; i10 < i9; i10++) {
            iHashCode = (iHashCode * 31) + objArr[i10].hashCode();
        }
        return i8 + iHashCode;
    }

    public final int zza() {
        int iZze;
        int i4 = this.zze;
        if (i4 != -1) {
            return i4;
        }
        int iZza = 0;
        for (int i5 = 0; i5 < this.zzb; i5++) {
            int i6 = this.zzc[i5];
            int i7 = i6 >>> 3;
            int i8 = i6 & 7;
            if (i8 == 0) {
                iZze = zzaii.zze(i7, ((Long) this.zzd[i5]).longValue());
            } else if (i8 == 1) {
                iZze = zzaii.zza(i7, ((Long) this.zzd[i5]).longValue());
            } else if (i8 == 2) {
                iZze = zzaii.zza(i7, (zzahm) this.zzd[i5]);
            } else if (i8 == 3) {
                iZza = ((zzame) this.zzd[i5]).zza() + (zzaii.zzg(i7) << 1) + iZza;
            } else {
                if (i8 != 5) {
                    throw new IllegalStateException(zzajj.zza());
                }
                iZze = zzaii.zzb(i7, ((Integer) this.zzd[i5]).intValue());
            }
            iZza = iZze + iZza;
        }
        this.zze = iZza;
        return iZza;
    }

    public final int zzb() {
        int i4 = this.zze;
        if (i4 != -1) {
            return i4;
        }
        int iZzb = 0;
        for (int i5 = 0; i5 < this.zzb; i5++) {
            iZzb += zzaii.zzb(this.zzc[i5] >>> 3, (zzahm) this.zzd[i5]);
        }
        this.zze = iZzb;
        return iZzb;
    }

    public final void zze() {
        if (this.zzf) {
            this.zzf = false;
        }
    }

    private zzame(int i4, int[] iArr, Object[] objArr, boolean z4) {
        this.zze = -1;
        this.zzb = i4;
        this.zzc = iArr;
        this.zzd = objArr;
        this.zzf = z4;
    }

    public final void zzb(zzanb zzanbVar) {
        if (this.zzb == 0) {
            return;
        }
        if (zzanbVar.zza() == zzana.zza) {
            for (int i4 = 0; i4 < this.zzb; i4++) {
                zza(this.zzc[i4], this.zzd[i4], zzanbVar);
            }
            return;
        }
        for (int i5 = this.zzb - 1; i5 >= 0; i5--) {
            zza(this.zzc[i5], this.zzd[i5], zzanbVar);
        }
    }

    public final zzame zza(zzame zzameVar) {
        if (zzameVar.equals(zza)) {
            return this;
        }
        zzf();
        int i4 = this.zzb + zzameVar.zzb;
        zza(i4);
        System.arraycopy(zzameVar.zzc, 0, this.zzc, this.zzb, zzameVar.zzb);
        System.arraycopy(zzameVar.zzd, 0, this.zzd, this.zzb, zzameVar.zzb);
        this.zzb = i4;
        return this;
    }

    public static zzame zza(zzame zzameVar, zzame zzameVar2) {
        int i4 = zzameVar.zzb + zzameVar2.zzb;
        int[] iArrCopyOf = Arrays.copyOf(zzameVar.zzc, i4);
        System.arraycopy(zzameVar2.zzc, 0, iArrCopyOf, zzameVar.zzb, zzameVar2.zzb);
        Object[] objArrCopyOf = Arrays.copyOf(zzameVar.zzd, i4);
        System.arraycopy(zzameVar2.zzd, 0, objArrCopyOf, zzameVar.zzb, zzameVar2.zzb);
        return new zzame(i4, iArrCopyOf, objArrCopyOf, true);
    }

    private final void zza(int i4) {
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

    public final void zza(StringBuilder sb, int i4) {
        for (int i5 = 0; i5 < this.zzb; i5++) {
            zzakp.zza(sb, i4, String.valueOf(this.zzc[i5] >>> 3), this.zzd[i5]);
        }
    }

    public final void zza(int i4, Object obj) {
        zzf();
        zza(this.zzb + 1);
        int[] iArr = this.zzc;
        int i5 = this.zzb;
        iArr[i5] = i4;
        this.zzd[i5] = obj;
        this.zzb = i5 + 1;
    }

    public final void zza(zzanb zzanbVar) {
        if (zzanbVar.zza() == zzana.zzb) {
            for (int i4 = this.zzb - 1; i4 >= 0; i4--) {
                zzanbVar.zza(this.zzc[i4] >>> 3, this.zzd[i4]);
            }
            return;
        }
        for (int i5 = 0; i5 < this.zzb; i5++) {
            zzanbVar.zza(this.zzc[i5] >>> 3, this.zzd[i5]);
        }
    }

    private static void zza(int i4, Object obj, zzanb zzanbVar) {
        int i5 = i4 >>> 3;
        int i6 = i4 & 7;
        if (i6 == 0) {
            zzanbVar.zzb(i5, ((Long) obj).longValue());
            return;
        }
        if (i6 == 1) {
            zzanbVar.zza(i5, ((Long) obj).longValue());
            return;
        }
        if (i6 == 2) {
            zzanbVar.zza(i5, (zzahm) obj);
            return;
        }
        if (i6 != 3) {
            if (i6 == 5) {
                zzanbVar.zzb(i5, ((Integer) obj).intValue());
                return;
            }
            throw new RuntimeException(zzajj.zza());
        }
        if (zzanbVar.zza() == zzana.zza) {
            zzanbVar.zzb(i5);
            ((zzame) obj).zzb(zzanbVar);
            zzanbVar.zza(i5);
        } else {
            zzanbVar.zza(i5);
            ((zzame) obj).zzb(zzanbVar);
            zzanbVar.zzb(i5);
        }
    }
}
