package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.Objects;

/* JADX INFO: loaded from: classes.dex */
final class zzpd {
    private final Class<?> zza;
    private final Class<? extends zzow> zzb;

    public final boolean equals(Object obj) {
        if (!(obj instanceof zzpd)) {
            return false;
        }
        zzpd zzpdVar = (zzpd) obj;
        return zzpdVar.zza.equals(this.zza) && zzpdVar.zzb.equals(this.zzb);
    }

    public final int hashCode() {
        return Objects.hash(this.zza, this.zzb);
    }

    public final String toString() {
        return this.zza.getSimpleName() + " with serialization type: " + this.zzb.getSimpleName();
    }

    private zzpd(Class<?> cls, Class<? extends zzow> cls2) {
        this.zza = cls;
        this.zzb = cls2;
    }
}
