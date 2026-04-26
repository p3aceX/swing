package com.google.android.gms.internal.auth;

import com.google.crypto.tink.shaded.protobuf.S;
import java.io.Serializable;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
final class zzdn implements Serializable, zzdj {
    final Object zza;

    public zzdn(Object obj) {
        this.zza = obj;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof zzdn)) {
            return false;
        }
        Object obj2 = this.zza;
        Object obj3 = ((zzdn) obj).zza;
        return obj2 == obj3 || obj2.equals(obj3);
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{this.zza});
    }

    public final String toString() {
        return S.g("Suppliers.ofInstance(", this.zza.toString(), ")");
    }

    @Override // com.google.android.gms.internal.auth.zzdj
    public final Object zza() {
        return this.zza;
    }
}
