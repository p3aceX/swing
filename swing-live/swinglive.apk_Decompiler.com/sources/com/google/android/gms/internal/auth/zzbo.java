package com.google.android.gms.internal.auth;

import D2.C;
import android.app.Activity;
import android.content.Context;
import com.google.android.gms.common.api.internal.AbstractC0273v;
import com.google.android.gms.common.api.internal.InterfaceC0270s;
import com.google.android.gms.common.api.k;
import com.google.android.gms.common.api.l;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import s0.AbstractC0661b;
import s0.C0662c;
import w0.C0699a;
import w0.C0700b;

/* JADX INFO: loaded from: classes.dex */
public final class zzbo extends l {
    public zzbo(Activity activity, C0662c c0662c) {
        super(activity, activity, AbstractC0661b.f6472a, c0662c == null ? C0662c.f6473b : c0662c, k.f3499c);
    }

    public final Task<String> getSpatulaHeader() {
        C cA = AbstractC0273v.a();
        cA.f159c = new InterfaceC0270s() { // from class: com.google.android.gms.internal.auth.zzbk
            @Override // com.google.android.gms.common.api.internal.InterfaceC0270s
            public final void accept(Object obj, Object obj2) {
                ((zzbh) ((zzbe) obj).getService()).zzd(new zzbn(this.zza, (TaskCompletionSource) obj2));
            }
        };
        cA.f158b = 1520;
        return doRead(cA.a());
    }

    public final Task<C0700b> performProxyRequest(final C0699a c0699a) {
        C cA = AbstractC0273v.a();
        cA.f159c = new InterfaceC0270s() { // from class: com.google.android.gms.internal.auth.zzbl
            @Override // com.google.android.gms.common.api.internal.InterfaceC0270s
            public final void accept(Object obj, Object obj2) {
                zzbo zzboVar = this.zza;
                C0699a c0699a2 = c0699a;
                ((zzbh) ((zzbe) obj).getService()).zze(new zzbm(zzboVar, (TaskCompletionSource) obj2), c0699a2);
            }
        };
        cA.f158b = 1518;
        return doWrite(cA.a());
    }

    public zzbo(Context context, C0662c c0662c) {
        super(context, null, AbstractC0661b.f6472a, c0662c == null ? C0662c.f6473b : c0662c, k.f3499c);
    }
}
