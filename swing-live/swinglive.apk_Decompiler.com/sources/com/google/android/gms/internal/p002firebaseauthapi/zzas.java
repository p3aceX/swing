package com.google.android.gms.internal.p002firebaseauthapi;

/* JADX INFO: loaded from: classes.dex */
final class zzas<E> extends zzak<E> {
    private final zzaq<E> zza;

    public zzas(zzaq<E> zzaqVar, int i4) {
        super(zzaqVar.size(), i4);
        this.zza = zzaqVar;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzak
    public final E zza(int i4) {
        return this.zza.get(i4);
    }
}
