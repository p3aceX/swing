package com.google.android.gms.internal.p002firebaseauthapi;

/* JADX INFO: loaded from: classes.dex */
final /* synthetic */ class zzlb {
    static final /* synthetic */ int[] zza;

    static {
        int[] iArr = new int[zzum.values().length];
        zza = iArr;
        try {
            iArr[zzum.DHKEM_X25519_HKDF_SHA256.ordinal()] = 1;
        } catch (NoSuchFieldError unused) {
        }
        try {
            zza[zzum.DHKEM_P256_HKDF_SHA256.ordinal()] = 2;
        } catch (NoSuchFieldError unused2) {
        }
        try {
            zza[zzum.DHKEM_P384_HKDF_SHA384.ordinal()] = 3;
        } catch (NoSuchFieldError unused3) {
        }
        try {
            zza[zzum.DHKEM_P521_HKDF_SHA512.ordinal()] = 4;
        } catch (NoSuchFieldError unused4) {
        }
    }
}
