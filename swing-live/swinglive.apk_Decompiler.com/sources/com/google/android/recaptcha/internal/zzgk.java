package com.google.android.recaptcha.internal;

/* JADX INFO: loaded from: classes.dex */
final class zzgk {
    public static int zza(byte[] bArr, int i4, zzgj zzgjVar) throws zzje {
        int iZzi = zzi(bArr, i4, zzgjVar);
        int i5 = zzgjVar.zza;
        if (i5 < 0) {
            throw zzje.zzf();
        }
        if (i5 > bArr.length - iZzi) {
            throw zzje.zzj();
        }
        if (i5 == 0) {
            zzgjVar.zzc = zzgw.zzb;
            return iZzi;
        }
        zzgjVar.zzc = zzgw.zzm(bArr, iZzi, i5);
        return iZzi + i5;
    }

    public static int zzb(byte[] bArr, int i4) {
        int i5 = bArr[i4] & 255;
        int i6 = bArr[i4 + 1] & 255;
        int i7 = bArr[i4 + 2] & 255;
        return ((bArr[i4 + 3] & 255) << 24) | (i6 << 8) | i5 | (i7 << 16);
    }

    public static int zzc(zzkr zzkrVar, byte[] bArr, int i4, int i5, int i6, zzgj zzgjVar) throws Throwable {
        Object objZze = zzkrVar.zze();
        int iZzm = zzm(objZze, zzkrVar, bArr, i4, i5, i6, zzgjVar);
        zzkrVar.zzf(objZze);
        zzgjVar.zzc = objZze;
        return iZzm;
    }

    public static int zzd(zzkr zzkrVar, byte[] bArr, int i4, int i5, zzgj zzgjVar) throws zzje {
        Object objZze = zzkrVar.zze();
        int iZzn = zzn(objZze, zzkrVar, bArr, i4, i5, zzgjVar);
        zzkrVar.zzf(objZze);
        zzgjVar.zzc = objZze;
        return iZzn;
    }

    public static int zze(zzkr zzkrVar, int i4, byte[] bArr, int i5, int i6, zzjb zzjbVar, zzgj zzgjVar) throws zzje {
        int iZzd = zzd(zzkrVar, bArr, i5, i6, zzgjVar);
        zzjbVar.add(zzgjVar.zzc);
        while (iZzd < i6) {
            int iZzi = zzi(bArr, iZzd, zzgjVar);
            if (i4 != zzgjVar.zza) {
                break;
            }
            iZzd = zzd(zzkrVar, bArr, iZzi, i6, zzgjVar);
            zzjbVar.add(zzgjVar.zzc);
        }
        return iZzd;
    }

    public static int zzf(byte[] bArr, int i4, zzjb zzjbVar, zzgj zzgjVar) throws zzje {
        zziu zziuVar = (zziu) zzjbVar;
        int iZzi = zzi(bArr, i4, zzgjVar);
        int i5 = zzgjVar.zza + iZzi;
        while (iZzi < i5) {
            iZzi = zzi(bArr, iZzi, zzgjVar);
            zziuVar.zzg(zzgjVar.zza);
        }
        if (iZzi == i5) {
            return iZzi;
        }
        throw zzje.zzj();
    }

    public static int zzg(byte[] bArr, int i4, zzgj zzgjVar) throws zzje {
        int iZzi = zzi(bArr, i4, zzgjVar);
        int i5 = zzgjVar.zza;
        if (i5 < 0) {
            throw zzje.zzf();
        }
        if (i5 == 0) {
            zzgjVar.zzc = "";
            return iZzi;
        }
        zzgjVar.zzc = new String(bArr, iZzi, i5, zzjc.zzb);
        return iZzi + i5;
    }

    public static int zzh(int i4, byte[] bArr, int i5, int i6, zzlm zzlmVar, zzgj zzgjVar) throws zzje {
        if ((i4 >>> 3) == 0) {
            throw zzje.zzc();
        }
        int i7 = i4 & 7;
        if (i7 == 0) {
            int iZzl = zzl(bArr, i5, zzgjVar);
            zzlmVar.zzj(i4, Long.valueOf(zzgjVar.zzb));
            return iZzl;
        }
        if (i7 == 1) {
            zzlmVar.zzj(i4, Long.valueOf(zzp(bArr, i5)));
            return i5 + 8;
        }
        if (i7 == 2) {
            int iZzi = zzi(bArr, i5, zzgjVar);
            int i8 = zzgjVar.zza;
            if (i8 < 0) {
                throw zzje.zzf();
            }
            if (i8 > bArr.length - iZzi) {
                throw zzje.zzj();
            }
            if (i8 == 0) {
                zzlmVar.zzj(i4, zzgw.zzb);
            } else {
                zzlmVar.zzj(i4, zzgw.zzm(bArr, iZzi, i8));
            }
            return iZzi + i8;
        }
        if (i7 != 3) {
            if (i7 != 5) {
                throw zzje.zzc();
            }
            zzlmVar.zzj(i4, Integer.valueOf(zzb(bArr, i5)));
            return i5 + 4;
        }
        int i9 = (i4 & (-8)) | 4;
        zzlm zzlmVarZzf = zzlm.zzf();
        int i10 = 0;
        while (true) {
            if (i5 >= i6) {
                break;
            }
            int iZzi2 = zzi(bArr, i5, zzgjVar);
            i10 = zzgjVar.zza;
            if (i10 == i9) {
                i5 = iZzi2;
                break;
            }
            i5 = zzh(i10, bArr, iZzi2, i6, zzlmVarZzf, zzgjVar);
        }
        if (i5 > i6 || i10 != i9) {
            throw zzje.zzg();
        }
        zzlmVar.zzj(i4, zzlmVarZzf);
        return i5;
    }

    public static int zzi(byte[] bArr, int i4, zzgj zzgjVar) {
        int i5 = i4 + 1;
        byte b5 = bArr[i4];
        if (b5 < 0) {
            return zzj(b5, bArr, i5, zzgjVar);
        }
        zzgjVar.zza = b5;
        return i5;
    }

    public static int zzj(int i4, byte[] bArr, int i5, zzgj zzgjVar) {
        byte b5 = bArr[i5];
        int i6 = i5 + 1;
        int i7 = i4 & 127;
        if (b5 >= 0) {
            zzgjVar.zza = i7 | (b5 << 7);
            return i6;
        }
        int i8 = i7 | ((b5 & 127) << 7);
        int i9 = i5 + 2;
        byte b6 = bArr[i6];
        if (b6 >= 0) {
            zzgjVar.zza = i8 | (b6 << 14);
            return i9;
        }
        int i10 = i8 | ((b6 & 127) << 14);
        int i11 = i5 + 3;
        byte b7 = bArr[i9];
        if (b7 >= 0) {
            zzgjVar.zza = i10 | (b7 << 21);
            return i11;
        }
        int i12 = i10 | ((b7 & 127) << 21);
        int i13 = i5 + 4;
        byte b8 = bArr[i11];
        if (b8 >= 0) {
            zzgjVar.zza = i12 | (b8 << 28);
            return i13;
        }
        int i14 = i12 | ((b8 & 127) << 28);
        while (true) {
            int i15 = i13 + 1;
            if (bArr[i13] >= 0) {
                zzgjVar.zza = i14;
                return i15;
            }
            i13 = i15;
        }
    }

    public static int zzk(int i4, byte[] bArr, int i5, int i6, zzjb zzjbVar, zzgj zzgjVar) {
        zziu zziuVar = (zziu) zzjbVar;
        int iZzi = zzi(bArr, i5, zzgjVar);
        zziuVar.zzg(zzgjVar.zza);
        while (iZzi < i6) {
            int iZzi2 = zzi(bArr, iZzi, zzgjVar);
            if (i4 != zzgjVar.zza) {
                break;
            }
            iZzi = zzi(bArr, iZzi2, zzgjVar);
            zziuVar.zzg(zzgjVar.zza);
        }
        return iZzi;
    }

    public static int zzl(byte[] bArr, int i4, zzgj zzgjVar) {
        long j4 = bArr[i4];
        int i5 = i4 + 1;
        if (j4 >= 0) {
            zzgjVar.zzb = j4;
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
        zzgjVar.zzb = j5;
        return i6;
    }

    public static int zzm(Object obj, zzkr zzkrVar, byte[] bArr, int i4, int i5, int i6, zzgj zzgjVar) throws Throwable {
        int iZzc = ((zzkh) zzkrVar).zzc(obj, bArr, i4, i5, i6, zzgjVar);
        zzgjVar.zzc = obj;
        return iZzc;
    }

    public static int zzn(Object obj, zzkr zzkrVar, byte[] bArr, int i4, int i5, zzgj zzgjVar) throws zzje {
        int iZzj = i4 + 1;
        int i6 = bArr[i4];
        if (i6 < 0) {
            iZzj = zzj(i6, bArr, iZzj, zzgjVar);
            i6 = zzgjVar.zza;
        }
        int i7 = iZzj;
        if (i6 < 0 || i6 > i5 - i7) {
            throw zzje.zzj();
        }
        int i8 = i7 + i6;
        zzkrVar.zzi(obj, bArr, i7, i8, zzgjVar);
        zzgjVar.zzc = obj;
        return i8;
    }

    public static int zzo(int i4, byte[] bArr, int i5, int i6, zzgj zzgjVar) throws zzje {
        if ((i4 >>> 3) == 0) {
            throw zzje.zzc();
        }
        int i7 = i4 & 7;
        if (i7 == 0) {
            return zzl(bArr, i5, zzgjVar);
        }
        if (i7 == 1) {
            return i5 + 8;
        }
        if (i7 == 2) {
            return zzi(bArr, i5, zzgjVar) + zzgjVar.zza;
        }
        if (i7 != 3) {
            if (i7 == 5) {
                return i5 + 4;
            }
            throw zzje.zzc();
        }
        int i8 = (i4 & (-8)) | 4;
        int i9 = 0;
        while (i5 < i6) {
            i5 = zzi(bArr, i5, zzgjVar);
            i9 = zzgjVar.zza;
            if (i9 == i8) {
                break;
            }
            i5 = zzo(i9, bArr, i5, i6, zzgjVar);
        }
        if (i5 > i6 || i9 != i8) {
            throw zzje.zzg();
        }
        return i5;
    }

    public static long zzp(byte[] bArr, int i4) {
        return (((long) bArr[i4]) & 255) | ((((long) bArr[i4 + 1]) & 255) << 8) | ((((long) bArr[i4 + 2]) & 255) << 16) | ((((long) bArr[i4 + 3]) & 255) << 24) | ((((long) bArr[i4 + 4]) & 255) << 32) | ((((long) bArr[i4 + 5]) & 255) << 40) | ((((long) bArr[i4 + 6]) & 255) << 48) | ((((long) bArr[i4 + 7]) & 255) << 56);
    }
}
