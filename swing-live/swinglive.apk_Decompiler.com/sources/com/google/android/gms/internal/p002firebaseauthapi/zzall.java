package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.Iterator;

/* JADX INFO: loaded from: classes.dex */
final class zzall extends zzalt {
    private final /* synthetic */ zzalh zza;

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzalt, java.util.AbstractCollection, java.util.Collection, java.lang.Iterable, java.util.Set
    public final Iterator iterator() {
        return new zzalj(this.zza);
    }

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    private zzall(zzalh zzalhVar) {
        super(zzalhVar);
        this.zza = zzalhVar;
    }
}
