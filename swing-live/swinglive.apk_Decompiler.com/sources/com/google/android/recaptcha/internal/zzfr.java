package com.google.android.recaptcha.internal;

import java.util.Iterator;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
final class zzfr extends zzfm {
    final /* synthetic */ Iterable zza;
    final /* synthetic */ int zzb;

    public zzfr(Iterable iterable, int i4) {
        this.zza = iterable;
        this.zzb = i4;
    }

    @Override // java.lang.Iterable
    public final Iterator iterator() {
        Iterable iterable = this.zza;
        if (iterable instanceof List) {
            List list = (List) iterable;
            return list.subList(Math.min(list.size(), this.zzb), list.size()).iterator();
        }
        int i4 = this.zzb;
        Iterator it = iterable.iterator();
        it.getClass();
        zzff.zzb(i4 >= 0, "numberToAdvance must be nonnegative");
        for (int i5 = 0; i5 < i4 && it.hasNext(); i5++) {
            it.next();
        }
        return new zzfq(this, it);
    }
}
