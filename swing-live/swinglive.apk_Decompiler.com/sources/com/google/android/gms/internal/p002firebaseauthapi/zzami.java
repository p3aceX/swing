package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.Iterator;

/* JADX INFO: loaded from: classes.dex */
final class zzami implements Iterator<String> {
    private Iterator<String> zza;
    private final /* synthetic */ zzamg zzb;

    public zzami(zzamg zzamgVar) {
        this.zzb = zzamgVar;
        this.zza = zzamgVar.zza.iterator();
    }

    @Override // java.util.Iterator
    public final boolean hasNext() {
        return this.zza.hasNext();
    }

    @Override // java.util.Iterator
    public final /* synthetic */ String next() {
        return this.zza.next();
    }

    @Override // java.util.Iterator
    public final void remove() {
        throw new UnsupportedOperationException();
    }
}
