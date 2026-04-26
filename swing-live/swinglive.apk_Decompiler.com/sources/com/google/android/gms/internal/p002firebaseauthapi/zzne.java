package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.Objects;

/* JADX INFO: loaded from: classes.dex */
public final class zzne extends zzci {
    private final zzos zza;

    public zzne(zzos zzosVar) {
        this.zza = zzosVar;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof zzne)) {
            return false;
        }
        zzos zzosVar = ((zzne) obj).zza;
        return this.zza.zza().zzd().equals(zzosVar.zza().zzd()) && this.zza.zza().zzf().equals(zzosVar.zza().zzf()) && this.zza.zza().zze().equals(zzosVar.zza().zze());
    }

    public final int hashCode() {
        return Objects.hash(this.zza.zza(), this.zza.zzb());
    }

    public final String toString() {
        String strZzf = this.zza.zza().zzf();
        int i4 = zznh.zza[this.zza.zza().zzd().ordinal()];
        return "(typeUrl=" + strZzf + ", outputPrefixType=" + (i4 != 1 ? i4 != 2 ? i4 != 3 ? i4 != 4 ? "UNKNOWN" : "CRUNCHY" : "RAW" : "LEGACY" : "TINK") + ")";
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzci
    public final boolean zza() {
        return this.zza.zza().zzd() != zzvt.RAW;
    }

    public final zzos zzb() {
        return this.zza;
    }
}
