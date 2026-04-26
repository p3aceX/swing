package com.google.android.recaptcha.internal;

import java.util.Iterator;
import java.util.List;
import x3.AbstractC0726f;
import x3.AbstractC0728h;
import x3.p;

/* JADX INFO: loaded from: classes.dex */
public final class zzef {
    private List zza = p.f6784a;

    public final long zza(long[] jArr) {
        Iterator it = AbstractC0728h.c0(this.zza, AbstractC0726f.m0(jArr)).iterator();
        if (!it.hasNext()) {
            throw new UnsupportedOperationException("Empty collection can't be reduced.");
        }
        Object next = it.next();
        while (it.hasNext()) {
            next = Long.valueOf(((Number) next).longValue() ^ ((Number) it.next()).longValue());
        }
        return ((Number) next).longValue();
    }

    public final void zzb(long[] jArr) {
        this.zza = AbstractC0726f.m0(jArr);
    }
}
