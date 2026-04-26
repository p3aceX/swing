package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.NoSuchElementException;

/* JADX INFO: loaded from: classes.dex */
final class zzahp extends zzahr {
    private int zza = 0;
    private final int zzb;
    private final /* synthetic */ zzahm zzc;

    public zzahp(zzahm zzahmVar) {
        this.zzc = zzahmVar;
        this.zzb = zzahmVar.zzb();
    }

    @Override // java.util.Iterator
    public final boolean hasNext() {
        return this.zza < this.zzb;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahs
    public final byte zza() {
        int i4 = this.zza;
        if (i4 >= this.zzb) {
            throw new NoSuchElementException();
        }
        this.zza = i4 + 1;
        return this.zzc.zzb(i4);
    }
}
