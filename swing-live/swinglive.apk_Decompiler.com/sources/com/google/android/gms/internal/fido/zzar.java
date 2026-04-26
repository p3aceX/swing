package com.google.android.gms.internal.fido;

/* JADX INFO: loaded from: classes.dex */
final class zzar extends zzao {
    private final zzat zza;

    public zzar(zzat zzatVar, int i4) {
        super(zzatVar.size(), i4);
        this.zza = zzatVar;
    }

    @Override // com.google.android.gms.internal.fido.zzao
    public final Object zza(int i4) {
        return this.zza.get(i4);
    }
}
