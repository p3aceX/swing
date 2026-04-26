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
import com.google.android.gms.common.internal.F;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import z0.C0773d;

/* JADX INFO: loaded from: classes.dex */
public final class zzr extends l {
    private static final h zza;
    private static final a zzb;
    private static final i zzc;

    static {
        h hVar = new h();
        zza = hVar;
        zzn zznVar = new zzn();
        zzb = zznVar;
        zzc = new i("SmsCodeAutofill.API", zznVar, hVar);
    }

    public zzr(Activity activity) {
        super(activity, activity, zzc, e.f3381j, k.f3499c);
    }

    public final Task<Integer> checkPermissionState() {
        C cA = AbstractC0273v.a();
        cA.f160d = new C0773d[]{zzac.zza};
        cA.f159c = new InterfaceC0270s() { // from class: com.google.android.gms.internal.auth-api-phone.zzk
            @Override // com.google.android.gms.common.api.internal.InterfaceC0270s
            public final void accept(Object obj, Object obj2) {
                ((zzh) ((zzw) obj).getService()).zzc(new zzp(this.zza, (TaskCompletionSource) obj2));
            }
        };
        cA.f158b = 1564;
        return doRead(cA.a());
    }

    public final Task<Boolean> hasOngoingSmsRequest(final String str) {
        F.g(str);
        F.a("The package name cannot be empty.", !str.isEmpty());
        C cA = AbstractC0273v.a();
        cA.f160d = new C0773d[]{zzac.zza};
        cA.f159c = new InterfaceC0270s() { // from class: com.google.android.gms.internal.auth-api-phone.zzl
            @Override // com.google.android.gms.common.api.internal.InterfaceC0270s
            public final void accept(Object obj, Object obj2) {
                ((zzh) ((zzw) obj).getService()).zzd(str, new zzq(this.zza, (TaskCompletionSource) obj2));
            }
        };
        cA.f158b = 1565;
        return doRead(cA.a());
    }

    public final Task<Void> startSmsCodeRetriever() {
        C cA = AbstractC0273v.a();
        cA.f160d = new C0773d[]{zzac.zza};
        cA.f159c = new InterfaceC0270s() { // from class: com.google.android.gms.internal.auth-api-phone.zzm
            @Override // com.google.android.gms.common.api.internal.InterfaceC0270s
            public final void accept(Object obj, Object obj2) {
                ((zzh) ((zzw) obj).getService()).zze(new zzo(this.zza, (TaskCompletionSource) obj2));
            }
        };
        cA.f158b = 1563;
        return doWrite(cA.a());
    }

    public zzr(Context context) {
        super(context, null, zzc, e.f3381j, k.f3499c);
    }
}
