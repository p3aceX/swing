package com.google.android.gms.internal.p002firebaseauthapi;

/* JADX INFO: loaded from: classes.dex */
final class zzahi {
    public static double zza(byte[] bArr, int i4) {
        return Double.longBitsToDouble(zzd(bArr, i4));
    }

    public static float zzb(byte[] bArr, int i4) {
        return Float.intBitsToFloat(zzc(bArr, i4));
    }

    public static int zzc(byte[] bArr, int i4) {
        return ((bArr[i4 + 3] & 255) << 24) | (bArr[i4] & 255) | ((bArr[i4 + 1] & 255) << 8) | ((bArr[i4 + 2] & 255) << 16);
    }

    public static int zzd(byte[] bArr, int i4, zzahl zzahlVar) {
        int i5 = i4 + 1;
        long j4 = bArr[i4];
        if (j4 >= 0) {
            zzahlVar.zzb = j4;
            return i5;
        }
        int i6 = i4 + 2;
        byte b5 = bArr[i5];
        long j5 = (j4 & 127) | (((long) (b5 & 127)) << 7);
        int i7 = 7;
        while (b5 < 0) {
            int i8 = i6 + 1;
            byte b6 = bArr[i6];
            i7 += 7;
            j5 |= ((long) (b6 & 127)) << i7;
            b5 = b6;
            i6 = i8;
        }
        zzahlVar.zzb = j5;
        return i6;
    }

    public static int zza(byte[] bArr, int i4, zzahl zzahlVar) throws zzajj {
        int iZzc = zzc(bArr, i4, zzahlVar);
        int i5 = zzahlVar.zza;
        if (i5 < 0) {
            throw zzajj.zzf();
        }
        if (i5 > bArr.length - iZzc) {
            throw zzajj.zzi();
        }
        if (i5 == 0) {
            zzahlVar.zzc = zzahm.zza;
            return iZzc;
        }
        zzahlVar.zzc = zzahm.zza(bArr, iZzc, i5);
        return iZzc + i5;
    }

    public static int zzb(byte[] bArr, int i4, zzahl zzahlVar) throws zzajj {
        int iZzc = zzc(bArr, i4, zzahlVar);
        int i5 = zzahlVar.zza;
        if (i5 < 0) {
            throw zzajj.zzf();
        }
        if (i5 == 0) {
            zzahlVar.zzc = "";
            return iZzc;
        }
        zzahlVar.zzc = zzaml.zzb(bArr, iZzc, i5);
        return iZzc + i5;
    }

    public static int zzc(byte[] bArr, int i4, zzahl zzahlVar) {
        int i5 = i4 + 1;
        byte b5 = bArr[i4];
        if (b5 < 0) {
            return zza(b5, bArr, i5, zzahlVar);
        }
        zzahlVar.zza = b5;
        return i5;
    }

    public static long zzd(byte[] bArr, int i4) {
        return ((((long) bArr[i4 + 7]) & 255) << 56) | (((long) bArr[i4]) & 255) | ((((long) bArr[i4 + 1]) & 255) << 8) | ((((long) bArr[i4 + 2]) & 255) << 16) | ((((long) bArr[i4 + 3]) & 255) << 24) | ((((long) bArr[i4 + 4]) & 255) << 32) | ((((long) bArr[i4 + 5]) & 255) << 40) | ((((long) bArr[i4 + 6]) & 255) << 48);
    }

    public static int zza(zzalc zzalcVar, byte[] bArr, int i4, int i5, int i6, zzahl zzahlVar) throws zzajj {
        Object objZza = zzalcVar.zza();
        int iZza = zza(objZza, zzalcVar, bArr, i4, i5, i6, zzahlVar);
        zzalcVar.zzc(objZza);
        zzahlVar.zzc = objZza;
        return iZza;
    }

    public static int zza(zzalc zzalcVar, byte[] bArr, int i4, int i5, zzahl zzahlVar) throws zzajj {
        Object objZza = zzalcVar.zza();
        int iZza = zza(objZza, zzalcVar, bArr, i4, i5, zzahlVar);
        zzalcVar.zzc(objZza);
        zzahlVar.zzc = objZza;
        return iZza;
    }

    public static int zza(zzalc<?> zzalcVar, int i4, byte[] bArr, int i5, int i6, zzajg<?> zzajgVar, zzahl zzahlVar) throws zzajj {
        int iZza = zza(zzalcVar, bArr, i5, i6, zzahlVar);
        zzajgVar.add(zzahlVar.zzc);
        while (iZza < i6) {
            int iZzc = zzc(bArr, iZza, zzahlVar);
            if (i4 != zzahlVar.zza) {
                break;
            }
            iZza = zza(zzalcVar, bArr, iZzc, i6, zzahlVar);
            zzajgVar.add(zzahlVar.zzc);
        }
        return iZza;
    }

    public static int zza(byte[] bArr, int i4, zzajg<?> zzajgVar, zzahl zzahlVar) throws zzajj {
        zzajd zzajdVar = (zzajd) zzajgVar;
        int iZzc = zzc(bArr, i4, zzahlVar);
        int i5 = zzahlVar.zza + iZzc;
        while (iZzc < i5) {
            iZzc = zzc(bArr, iZzc, zzahlVar);
            zzajdVar.zzc(zzahlVar.zza);
        }
        if (iZzc == i5) {
            return iZzc;
        }
        throw zzajj.zzi();
    }

    public static int zza(int i4, byte[] bArr, int i5, int i6, zzame zzameVar, zzahl zzahlVar) throws zzajj {
        if ((i4 >>> 3) == 0) {
            throw zzajj.zzc();
        }
        int i7 = i4 & 7;
        if (i7 == 0) {
            int iZzd = zzd(bArr, i5, zzahlVar);
            zzameVar.zza(i4, Long.valueOf(zzahlVar.zzb));
            return iZzd;
        }
        if (i7 == 1) {
            zzameVar.zza(i4, Long.valueOf(zzd(bArr, i5)));
            return i5 + 8;
        }
        if (i7 == 2) {
            int iZzc = zzc(bArr, i5, zzahlVar);
            int i8 = zzahlVar.zza;
            if (i8 >= 0) {
                if (i8 > bArr.length - iZzc) {
                    throw zzajj.zzi();
                }
                if (i8 == 0) {
                    zzameVar.zza(i4, zzahm.zza);
                } else {
                    zzameVar.zza(i4, zzahm.zza(bArr, iZzc, i8));
                }
                return iZzc + i8;
            }
            throw zzajj.zzf();
        }
        if (i7 != 3) {
            if (i7 == 5) {
                zzameVar.zza(i4, Integer.valueOf(zzc(bArr, i5)));
                return i5 + 4;
            }
            throw zzajj.zzc();
        }
        zzame zzameVarZzd = zzame.zzd();
        int i9 = (i4 & (-8)) | 4;
        int i10 = 0;
        while (true) {
            if (i5 >= i6) {
                break;
            }
            int iZzc2 = zzc(bArr, i5, zzahlVar);
            i10 = zzahlVar.zza;
            if (i10 == i9) {
                i5 = iZzc2;
                break;
            }
            i5 = zza(i10, bArr, iZzc2, i6, zzameVarZzd, zzahlVar);
        }
        if (i5 <= i6 && i10 == i9) {
            zzameVar.zza(i4, zzameVarZzd);
            return i5;
        }
        throw zzajj.zzg();
    }

    public static int zza(int i4, byte[] bArr, int i5, zzahl zzahlVar) {
        int i6 = i4 & 127;
        int i7 = i5 + 1;
        byte b5 = bArr[i5];
        if (b5 >= 0) {
            zzahlVar.zza = i6 | (b5 << 7);
            return i7;
        }
        int i8 = i6 | ((b5 & 127) << 7);
        int i9 = i5 + 2;
        byte b6 = bArr[i7];
        if (b6 >= 0) {
            zzahlVar.zza = i8 | (b6 << 14);
            return i9;
        }
        int i10 = i8 | ((b6 & 127) << 14);
        int i11 = i5 + 3;
        byte b7 = bArr[i9];
        if (b7 >= 0) {
            zzahlVar.zza = i10 | (b7 << 21);
            return i11;
        }
        int i12 = i10 | ((b7 & 127) << 21);
        int i13 = i5 + 4;
        byte b8 = bArr[i11];
        if (b8 >= 0) {
            zzahlVar.zza = i12 | (b8 << 28);
            return i13;
        }
        int i14 = i12 | ((b8 & 127) << 28);
        while (true) {
            int i15 = i13 + 1;
            if (bArr[i13] >= 0) {
                zzahlVar.zza = i14;
                return i15;
            }
            i13 = i15;
        }
    }

    public static int zza(int i4, byte[] bArr, int i5, int i6, zzajg<?> zzajgVar, zzahl zzahlVar) {
        zzajd zzajdVar = (zzajd) zzajgVar;
        int iZzc = zzc(bArr, i5, zzahlVar);
        zzajdVar.zzc(zzahlVar.zza);
        while (iZzc < i6) {
            int iZzc2 = zzc(bArr, iZzc, zzahlVar);
            if (i4 != zzahlVar.zza) {
                break;
            }
            iZzc = zzc(bArr, iZzc2, zzahlVar);
            zzajdVar.zzc(zzahlVar.zza);
        }
        return iZzc;
    }

    public static int zza(Object obj, zzalc zzalcVar, byte[] bArr, int i4, int i5, int i6, zzahl zzahlVar) throws zzajj {
        int iZza = ((zzako) zzalcVar).zza(obj, bArr, i4, i5, i6, zzahlVar);
        zzahlVar.zzc = obj;
        return iZza;
    }

    public static int zza(Object obj, zzalc zzalcVar, byte[] bArr, int i4, int i5, zzahl zzahlVar) throws zzajj {
        int iZza = i4 + 1;
        int i6 = bArr[i4];
        if (i6 < 0) {
            iZza = zza(i6, bArr, iZza, zzahlVar);
            i6 = zzahlVar.zza;
        }
        int i7 = iZza;
        if (i6 >= 0 && i6 <= i5 - i7) {
            int i8 = i7 + i6;
            zzalcVar.zza(obj, bArr, i7, i8, zzahlVar);
            zzahlVar.zzc = obj;
            return i8;
        }
        throw zzajj.zzi();
    }

    public static int zza(int i4, byte[] bArr, int i5, int i6, zzahl zzahlVar) throws zzajj {
        if ((i4 >>> 3) == 0) {
            throw zzajj.zzc();
        }
        int i7 = i4 & 7;
        if (i7 == 0) {
            return zzd(bArr, i5, zzahlVar);
        }
        if (i7 == 1) {
            return i5 + 8;
        }
        if (i7 == 2) {
            return zzc(bArr, i5, zzahlVar) + zzahlVar.zza;
        }
        if (i7 != 3) {
            if (i7 == 5) {
                return i5 + 4;
            }
            throw zzajj.zzc();
        }
        int i8 = (i4 & (-8)) | 4;
        int i9 = 0;
        while (i5 < i6) {
            i5 = zzc(bArr, i5, zzahlVar);
            i9 = zzahlVar.zza;
            if (i9 == i8) {
                break;
            }
            i5 = zza(i9, bArr, i5, i6, zzahlVar);
        }
        if (i5 > i6 || i9 != i8) {
            throw zzajj.zzg();
        }
        return i5;
    }
}
