package com.google.android.gms.internal.p001authapiphone;

import D2.C;
import android.app.Activity;
import android.content.Context;
import com.google.android.gms.common.api.a;
import com.google.android.gms.common.api.e;
import com.google.android.gms.common.api.h;
import com.google.android.gms.common.api.i;
import com.google.android.gms.common.api.internal.AbstractC0273v;
import com.google.android.gms.common.api.internal.InterfaceC0270s;
import com.google.android.gms.common.api.k;
import com.google.android.gms.common.api.l;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import z0.C0773d;

/* JADX INFO: loaded from: classes.dex */
public final class zzv extends l {
    private static final h zza;
    private static final a zzb;
    private static final i zzc;

    static {
        h hVar = new h();
        zza = hVar;
        zzt zztVar = new zzt();
        zzb = zztVar;
        zzc = new i("SmsCodeBrowser.API", zztVar, hVar);
    }

    public zzv(Activity activity) {
        super(activity, activity, zzc, e.f3381j, k.f3499c);
    }

    public final Task<Void> startSmsCodeRetriever() {
        C cA = AbstractC0273v.a();
        cA.f160d = new C0773d[]{zzac.zzb};
        cA.f159c = new InterfaceC0270s() { // from class: com.google.android.gms.internal.auth-api-phone.zzs
            @Override // com.google.android.gms.common.api.internal.InterfaceC0270s
            public final void accept(Object obj, Object obj2) {
                ((zzh) ((zzw) obj).getService()).zzf(new zzu(this.zza, (TaskCompletionSource) obj2));
            }
        };
        cA.f158b = 1566;
        return doWrite(cA.a());
    }

    public zzv(Context context) {
        super(context, null, zzc, e.f3381j, k.f3499c);
    }
}
