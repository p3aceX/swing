package com.google.android.gms.internal.p001authapiphone;

import D2.C;
import android.app.Activity;
import android.content.Context;
import com.google.android.gms.common.api.internal.AbstractC0273v;
import com.google.android.gms.common.api.internal.InterfaceC0270s;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import v0.AbstractC0693a;
import z0.C0773d;

/* JADX INFO: loaded from: classes.dex */
public final class zzab extends AbstractC0693a {
    public zzab(Activity activity) {
        super(activity);
    }

    public final Task<Void> startSmsRetriever() {
        C cA = AbstractC0273v.a();
        cA.f159c = new InterfaceC0270s() { // from class: com.google.android.gms.internal.auth-api-phone.zzx
            @Override // com.google.android.gms.common.api.internal.InterfaceC0270s
            public final void accept(Object obj, Object obj2) {
                ((zzh) ((zzw) obj).getService()).zzg(new zzz(this.zza, (TaskCompletionSource) obj2));
            }
        };
        cA.f160d = new C0773d[]{zzac.zzc};
        cA.f158b = 1567;
        return doWrite(cA.a());
    }

    public final Task<Void> startSmsUserConsent(final String str) {
        C cA = AbstractC0273v.a();
        cA.f159c = new InterfaceC0270s() { // from class: com.google.android.gms.internal.auth-api-phone.zzy
            @Override // com.google.android.gms.common.api.internal.InterfaceC0270s
            public final void accept(Object obj, Object obj2) {
                ((zzh) ((zzw) obj).getService()).zzh(str, new zzaa(this.zza, (TaskCompletionSource) obj2));
            }
        };
        cA.f160d = new C0773d[]{zzac.zzd};
        cA.f158b = 1568;
        return doWrite(cA.a());
    }

    public zzab(Context context) {
        super(context);
    }
}
