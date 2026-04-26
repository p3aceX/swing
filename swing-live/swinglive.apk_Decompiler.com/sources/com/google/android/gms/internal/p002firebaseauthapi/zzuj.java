package com.google.android.gms.internal.p002firebaseauthapi;

/* JADX INFO: loaded from: classes.dex */
public enum zzuj implements zzajf {
    AEAD_UNKNOWN(0),
    AES_128_GCM(1),
    AES_256_GCM(2),
    CHACHA20_POLY1305(3),
    UNRECOGNIZED(-1);

    private static final zzaje<zzuj> zzf = new zzaje<zzuj>() { // from class: com.google.android.gms.internal.firebase-auth-api.zzul
    };
    private final int zzh;

    zzuj(int i4) {
        this.zzh = i4;
    }

    @Override // java.lang.Enum
    public final String toString() {
        StringBuilder sb = new StringBuilder("<");
        sb.append(zzuj.class.getName());
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

    public static zzuj zza(int i4) {
        if (i4 == 0) {
            return AEAD_UNKNOWN;
        }
        if (i4 == 1) {
            return AES_128_GCM;
        }
        if (i4 == 2) {
            return AES_256_GCM;
        }
        if (i4 != 3) {
            return null;
        }
        return CHACHA20_POLY1305;
    }
}
