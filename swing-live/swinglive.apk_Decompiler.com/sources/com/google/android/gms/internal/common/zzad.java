package com.google.android.gms.internal.common;

import java.util.Iterator;

/* JADX INFO: loaded from: classes.dex */
public final class zzad extends zzaa {
    public zzad() {
        super(4);
    }

    public final zzad zzb(Object obj) {
        zza(obj);
        return this;
    }

    public final zzad zzc(Iterator it) {
        while (it.hasNext()) {
            zza(it.next());
        }
        return this;
    }

    public zzad(int i4) {
        super(4);
    }
}
