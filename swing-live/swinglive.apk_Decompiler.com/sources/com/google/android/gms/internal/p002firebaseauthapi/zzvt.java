package com.google.android.gms.internal.p002firebaseauthapi;

/* JADX INFO: loaded from: classes.dex */
public enum zzvt implements zzajf {
    UNKNOWN_PREFIX(0),
    TINK(1),
    LEGACY(2),
    RAW(3),
    CRUNCHY(4),
    UNRECOGNIZED(-1);

    private static final zzaje<zzvt> zzg = new zzaje<zzvt>() { // from class: com.google.android.gms.internal.firebase-auth-api.zzvs
    };
    private final int zzi;

    zzvt(int i4) {
        this.zzi = i4;
    }

    @Override // java.lang.Enum
    public final String toString() {
        StringBuilder sb = new StringBuilder("<");
        sb.append(zzvt.class.getName());
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

    public static zzvt zza(int i4) {
        if (i4 == 0) {
            return UNKNOWN_PREFIX;
        }
        if (i4 == 1) {
            return TINK;
        }
        if (i4 == 2) {
            return LEGACY;
        }
        if (i4 == 3) {
            return RAW;
        }
        if (i4 != 4) {
            return null;
        }
        return CRUNCHY;
    }
}
