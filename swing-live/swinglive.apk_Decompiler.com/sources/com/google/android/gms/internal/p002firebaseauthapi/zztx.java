package com.google.android.gms.internal.p002firebaseauthapi;

/* JADX INFO: loaded from: classes.dex */
public enum zztx implements zzajf {
    UNKNOWN_CURVE(0),
    NIST_P256(2),
    NIST_P384(3),
    NIST_P521(4),
    CURVE25519(5),
    UNRECOGNIZED(-1);

    private static final zzaje<zztx> zzg = new zzaje<zztx>() { // from class: com.google.android.gms.internal.firebase-auth-api.zztz
    };
    private final int zzi;

    zztx(int i4) {
        this.zzi = i4;
    }

    @Override // java.lang.Enum
    public final String toString() {
        StringBuilder sb = new StringBuilder("<");
        sb.append(zztx.class.getName());
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
            return this.zzi;
        }
        throw new IllegalArgumentException("Can't get the number of an unknown enum value.");
    }

    public static zztx zza(int i4) {
        if (i4 == 0) {
            return UNKNOWN_CURVE;
        }
        if (i4 == 2) {
            return NIST_P256;
        }
        if (i4 == 3) {
            return NIST_P384;
        }
        if (i4 == 4) {
            return NIST_P521;
        }
        if (i4 != 5) {
            return null;
        }
        return CURVE25519;
    }
}
