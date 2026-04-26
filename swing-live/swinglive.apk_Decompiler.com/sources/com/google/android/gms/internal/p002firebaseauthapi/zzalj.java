package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.Iterator;
import java.util.List;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
final class zzalj implements Iterator {
    private int zza;
    private Iterator zzb;
    private final /* synthetic */ zzalh zzc;

    private final Iterator zza() {
        if (this.zzb == null) {
            this.zzb = this.zzc.zzf.entrySet().iterator();
        }
        return this.zzb;
    }

    @Override // java.util.Iterator
    public final boolean hasNext() {
        int i4 = this.zza;
        return (i4 > 0 && i4 <= this.zzc.zzb.size()) || zza().hasNext();
    }

    @Override // java.util.Iterator
    public final /* synthetic */ Object next() {
        if (zza().hasNext()) {
            return (Map.Entry) zza().next();
        }
        List list = this.zzc.zzb;
        int i4 = this.zza - 1;
        this.zza = i4;
        return (Map.Entry) list.get(i4);
    }

    @Override // java.util.Iterator
    public final void remove() {
        throw new UnsupportedOperationException();
    }

    private zzalj(zzalh zzalhVar) {
        this.zzc = zzalhVar;
        this.zza = zzalhVar.zzb.size();
    }
}
