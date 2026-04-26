package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.Iterator;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
final class zzalr implements Iterator {
    private int zza;
    private boolean zzb;
    private Iterator zzc;
    private final /* synthetic */ zzalh zzd;

    private final Iterator zza() {
        if (this.zzc == null) {
            this.zzc = this.zzd.zzc.entrySet().iterator();
        }
        return this.zzc;
    }

    @Override // java.util.Iterator
    public final boolean hasNext() {
        return this.zza + 1 < this.zzd.zzb.size() || (!this.zzd.zzc.isEmpty() && zza().hasNext());
    }

    @Override // java.util.Iterator
    public final /* synthetic */ Object next() {
        this.zzb = true;
        int i4 = this.zza + 1;
        this.zza = i4;
        return i4 < this.zzd.zzb.size() ? (Map.Entry) this.zzd.zzb.get(this.zza) : (Map.Entry) zza().next();
    }

    @Override // java.util.Iterator
    public final void remove() {
        if (!this.zzb) {
            throw new IllegalStateException("remove() was called before next()");
        }
        this.zzb = false;
        this.zzd.zzg();
        if (this.zza >= this.zzd.zzb.size()) {
            zza().remove();
            return;
        }
        zzalh zzalhVar = this.zzd;
        int i4 = this.zza;
        this.zza = i4 - 1;
        zzalhVar.zzc(i4);
    }

    private zzalr(zzalh zzalhVar) {
        this.zzd = zzalhVar;
        this.zza = -1;
    }
}
