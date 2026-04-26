package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.List;
import java.util.Objects;

/* JADX INFO: loaded from: classes.dex */
public final class zzrs {
    private final zzrl zza;
    private final List<zzru> zzb;
    private final Integer zzc;

    public final boolean equals(Object obj) {
        if (!(obj instanceof zzrs)) {
            return false;
        }
        zzrs zzrsVar = (zzrs) obj;
        return this.zza.equals(zzrsVar.zza) && this.zzb.equals(zzrsVar.zzb) && Objects.equals(this.zzc, zzrsVar.zzc);
    }

    public final int hashCode() {
        return Objects.hash(this.zza, this.zzb);
    }

    public final String toString() {
        return String.format("(annotations=%s, entries=%s, primaryKeyId=%s)", this.zza, this.zzb, this.zzc);
    }

    private zzrs(zzrl zzrlVar, List<zzru> list, Integer num) {
        this.zza = zzrlVar;
        this.zzb = list;
        this.zzc = num;
    }
}
