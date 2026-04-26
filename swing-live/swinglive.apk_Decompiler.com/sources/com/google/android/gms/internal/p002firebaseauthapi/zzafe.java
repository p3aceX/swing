package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public final class zzafe {
    private List<zzafb> zza;

    public zzafe() {
        this.zza = new ArrayList();
    }

    public final List<zzafb> zza() {
        return this.zza;
    }

    public zzafe(List<zzafb> list) {
        this.zza = Collections.unmodifiableList(list);
    }
}
