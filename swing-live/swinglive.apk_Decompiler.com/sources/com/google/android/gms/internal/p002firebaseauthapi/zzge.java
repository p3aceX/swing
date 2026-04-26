package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.crypto.tink.shaded.protobuf.S;
import java.util.Objects;

/* JADX INFO: loaded from: classes.dex */
public final class zzge extends zzdc {
    private final String zza;

    private zzge(String str) {
        this.zza = str;
    }

    public final boolean equals(Object obj) {
        if (obj instanceof zzge) {
            return ((zzge) obj).zza.equals(this.zza);
        }
        return false;
    }

    public final int hashCode() {
        return Objects.hash(zzge.class, this.zza);
    }

    public final String toString() {
        return S.g("LegacyKmsAead Parameters (keyUri: ", this.zza, ")");
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzci
    public final boolean zza() {
        return false;
    }

    public final String zzb() {
        return this.zza;
    }

    public static zzge zza(String str) {
        return new zzge(str);
    }
}
