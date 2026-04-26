package com.google.android.gms.internal.auth;

import com.google.android.gms.common.api.internal.H;
import com.google.android.gms.common.api.o;
import com.google.android.gms.common.api.q;
import com.google.android.gms.common.internal.F;
import w0.C0699a;

/* JADX INFO: loaded from: classes.dex */
public final class zzbt {
    public final q getSpatulaHeader(o oVar) {
        F.g(oVar);
        return ((H) oVar).f3412b.doWrite(new zzbs(this, oVar));
    }

    public final q performProxyRequest(o oVar, C0699a c0699a) {
        F.g(oVar);
        F.g(c0699a);
        return ((H) oVar).f3412b.doWrite(new zzbq(this, oVar, c0699a));
    }
}
