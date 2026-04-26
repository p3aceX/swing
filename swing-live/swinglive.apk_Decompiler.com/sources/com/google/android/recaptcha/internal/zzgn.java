package com.google.android.recaptcha.internal;

import java.util.NoSuchElementException;

/* JADX INFO: loaded from: classes.dex */
final class zzgn extends zzgp {
    final /* synthetic */ zzgw zza;
    private int zzb = 0;
    private final int zzc;

    public zzgn(zzgw zzgwVar) {
        this.zza = zzgwVar;
        this.zzc = zzgwVar.zzd();
    }

    @Override // java.util.Iterator
    public final boolean hasNext() {
        return this.zzb < this.zzc;
    }

    @Override // com.google.android.recaptcha.internal.zzgr
    public final byte zza() {
        int i4 = this.zzb;
        if (i4 >= this.zzc) {
            throw new NoSuchElementException();
        }
        this.zzb = i4 + 1;
        return this.zza.zzb(i4);
    }
}
