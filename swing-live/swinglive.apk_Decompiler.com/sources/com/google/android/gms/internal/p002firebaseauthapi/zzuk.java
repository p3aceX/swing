package com.google.android.gms.internal.p002firebaseauthapi;

/* JADX INFO: loaded from: classes.dex */
public enum zzuk implements zzajf {
    KDF_UNKNOWN(0),
    HKDF_SHA256(1),
    HKDF_SHA384(2),
    HKDF_SHA512(3),
    UNRECOGNIZED(-1);

    private static final zzaje<zzuk> zzf = new zzaje<zzuk>() { // from class: com.google.android.gms.internal.firebase-auth-api.zzun
    };
    private final int zzh;

    zzuk(int i4) {
        this.zzh = i4;
    }

    @Override // java.lang.Enum
    public final String toString() {
        StringBuilder sb = new StringBuilder("<");
        sb.append(zzuk.class.getName());
        sb.append('@');
        sb.append(Integer.toHexString(System.identityHashCode(this)));
        if (this != UNRECOGNIZED) {
            sb.append(" number=");
            sb.append(zza());
        }
        sb.append(" name=");
        sb.append(name());
        sb.append('>');
        return sb.toString();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzajf
    public final int zza() {
        if (this != UNRECOGNIZED) {
            return this.zzh;
        }
        throw new IllegalArgumentException("Can't get the number of an unknown enum value.");
    }

    public static zzuk zza(int i4) {
        if (i4 == 0) {
            return KDF_UNKNOWN;
        }
        if (i4 == 1) {
            return HKDF_SHA256;
        }
        if (i4 == 2) {
            return HKDF_SHA384;
        }
        if (i4 != 3) {
            return null;
        }
        return HKDF_SHA512;
    }
}
