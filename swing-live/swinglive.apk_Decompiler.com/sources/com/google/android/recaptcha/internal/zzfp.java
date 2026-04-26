package com.google.android.recaptcha.internal;

import java.util.Collection;
import java.util.Queue;

/* JADX INFO: loaded from: classes.dex */
public abstract class zzfp extends zzfn implements Queue {
    @Override // java.util.Queue
    public final Object element() {
        return zzd().element();
    }

    public boolean offer(Object obj) {
        return zzd().offer(obj);
    }

    @Override // java.util.Queue
    public final Object peek() {
        return zzd().peek();
    }

    @Override // java.util.Queue
    public final Object poll() {
        return zzd().poll();
    }

    @Override // java.util.Queue
    public final Object remove() {
        return zzd().remove();
    }

    @Override // com.google.android.recaptcha.internal.zzfn
    public /* bridge */ /* synthetic */ Collection zzc() {
        throw null;
    }

    public abstract Queue zzd();
}
