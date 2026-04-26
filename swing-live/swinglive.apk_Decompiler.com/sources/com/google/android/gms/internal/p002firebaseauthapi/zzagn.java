package com.google.android.gms.internal.p002firebaseauthapi;

import G0.c;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public final class zzagn {
    private final int zza;
    private List<String> zzb;

    public zzagn() {
        this(null);
    }

    public static zzagn zza() {
        return new zzagn(null);
    }

    public final List<String> zzb() {
        return this.zzb;
    }

    private zzagn(List<String> list) {
        this.zza = 1;
        this.zzb = new ArrayList();
    }

    public zzagn(int i4, List<String> list) {
        this.zza = 1;
        if (list != null && !list.isEmpty()) {
            for (int i5 = 0; i5 < list.size(); i5++) {
                list.set(i5, c.a(list.get(i5)));
            }
            this.zzb = Collections.unmodifiableList(list);
            return;
        }
        this.zzb = Collections.EMPTY_LIST;
    }
}
