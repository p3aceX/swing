package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.crypto.tink.shaded.protobuf.S;
import java.util.Objects;

/* JADX INFO: loaded from: classes.dex */
public final class zzfo extends zzdc {
    private final zza zza;

    public static final class zza {
        public static final zza zza = new zza("TINK");
        public static final zza zzb = new zza("CRUNCHY");
        public static final zza zzc = new zza("NO_PREFIX");
        private final String zzd;

        private zza(String str) {
            this.zzd = str;
        }

        public final String toString() {
            return this.zzd;
        }
    }

    private zzfo(zza zzaVar) {
        this.zza = zzaVar;
    }

    public static zzfo zza(zza zzaVar) {
        return new zzfo(zzaVar);
    }

    public final boolean equals(Object obj) {
        return (obj instanceof zzfo) && ((zzfo) obj).zza == this.zza;
    }

    public final int hashCode() {
        return Objects.hash(zzfo.class, this.zza);
    }

    public final String toString() {
        return S.g("ChaCha20Poly1305 Parameters (variant: ", String.valueOf(this.zza), ")");
    }

    public final zza zzb() {
        return this.zza;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzci
    public final boolean zza() {
        return this.zza != zza.zzc;
    }
}
