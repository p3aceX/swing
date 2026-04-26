package com.google.android.gms.internal.p002firebaseauthapi;

/* JADX INFO: loaded from: classes.dex */
final /* synthetic */ class zzkt {
    static final /* synthetic */ int[] zza;
    static final /* synthetic */ int[] zzb;
    static final /* synthetic */ int[] zzc;

    static {
        int[] iArr = new int[zztj.values().length];
        zzc = iArr;
        try {
            iArr[zztj.UNCOMPRESSED.ordinal()] = 1;
        } catch (NoSuchFieldError unused) {
        }
        try {
            zzc[zztj.DO_NOT_USE_CRUNCHY_UNCOMPRESSED.ordinal()] = 2;
        } catch (NoSuchFieldError unused2) {
        }
        try {
            zzc[zztj.COMPRESSED.ordinal()] = 3;
        } catch (NoSuchFieldError unused3) {
        }
        int[] iArr2 = new int[zztx.values().length];
        zzb = iArr2;
        try {
            iArr2[zztx.NIST_P256.ordinal()] = 1;
        } catch (NoSuchFieldError unused4) {
        }
        try {
            zzb[zztx.NIST_P384.ordinal()] = 2;
        } catch (NoSuchFieldError unused5) {
        }
        try {
            zzb[zztx.NIST_P521.ordinal()] = 3;
        } catch (NoSuchFieldError unused6) {
        }
        int[] iArr3 = new int[zzuc.values().length];
        zza = iArr3;
        try {
            iArr3[zzuc.SHA1.ordinal()] = 1;
        } catch (NoSuchFieldError unused7) {
        }
        try {
            zza[zzuc.SHA224.ordinal()] = 2;
        } catch (NoSuchFieldError unused8) {
        }
        try {
            zza[zzuc.SHA256.ordinal()] = 3;
        } catch (NoSuchFieldError unused9) {
        }
        try {
            zza[zzuc.SHA384.ordinal()] = 4;
        } catch (NoSuchFieldError unused10) {
        }
        try {
            zza[zzuc.SHA512.ordinal()] = 5;
        } catch (NoSuchFieldError unused11) {
        }
    }
}
