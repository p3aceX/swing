package com.google.android.gms.internal.auth;

import D2.C;
import android.accounts.Account;
import android.content.Context;
import android.os.Bundle;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.api.a;
import com.google.android.gms.common.api.e;
import com.google.android.gms.common.api.h;
import com.google.android.gms.common.api.i;
import com.google.android.gms.common.api.internal.AbstractC0273v;
import com.google.android.gms.common.api.internal.InterfaceC0270s;
import com.google.android.gms.common.api.j;
import com.google.android.gms.common.api.k;
import com.google.android.gms.common.api.l;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import q0.AbstractC0632f;
import q0.C0628b;
import z0.C0773d;

/* JADX INFO: loaded from: classes.dex */
final class zzab extends l implements zzg {
    private static final h zza;
    private static final a zzb;
    private static final i zzc;
    private static final C0.a zzd;
    private final Context zze;

    static {
        h hVar = new h();
        zza = hVar;
        zzv zzvVar = new zzv();
        zzb = zzvVar;
        zzc = new i("GoogleAuthService.API", zzvVar, hVar);
        zzd = new C0.a("Auth", "GoogleAuthServiceClient");
    }

    public zzab(Context context) {
        super(context, null, zzc, e.f3381j, k.f3499c);
        this.zze = context;
    }

    public static void zzf(Status status, Object obj, TaskCompletionSource taskCompletionSource) {
        if (status.b() ? taskCompletionSource.trySetResult(obj) : taskCompletionSource.trySetException(new j(status))) {
            return;
        }
        zzd.f("The task is already complete.", new Object[0]);
    }

    @Override // com.google.android.gms.internal.auth.zzg
    public final Task zza(final zzbw zzbwVar) {
        C cA = AbstractC0273v.a();
        cA.f160d = new C0773d[]{AbstractC0632f.f6257c};
        cA.f159c = new InterfaceC0270s() { // from class: com.google.android.gms.internal.auth.zzt
            @Override // com.google.android.gms.common.api.internal.InterfaceC0270s
            public final void accept(Object obj, Object obj2) {
                zzab zzabVar = this.zza;
                ((zzp) ((zzi) obj).getService()).zzd(new zzx(zzabVar, (TaskCompletionSource) obj2), zzbwVar);
            }
        };
        cA.f158b = 1513;
        return doWrite(cA.a());
    }

    @Override // com.google.android.gms.internal.auth.zzg
    public final Task zzb(final C0628b c0628b) {
        F.h(c0628b, "request cannot be null.");
        C cA = AbstractC0273v.a();
        cA.f160d = new C0773d[]{AbstractC0632f.f6256b};
        cA.f159c = new InterfaceC0270s() { // from class: com.google.android.gms.internal.auth.zzu
            @Override // com.google.android.gms.common.api.internal.InterfaceC0270s
            public final void accept(Object obj, Object obj2) {
                zzab zzabVar = this.zza;
                C0628b c0628b2 = c0628b;
                ((zzp) ((zzi) obj).getService()).zze(new zzz(zzabVar, (TaskCompletionSource) obj2), c0628b2);
            }
        };
        cA.f158b = 1515;
        return doWrite(cA.a());
    }

    @Override // com.google.android.gms.internal.auth.zzg
    public final Task zzc(final Account account, final String str, final Bundle bundle) {
        F.h(account, "Account name cannot be null!");
        F.e(str, "Scope cannot be null!");
        C cA = AbstractC0273v.a();
        cA.f160d = new C0773d[]{AbstractC0632f.f6257c};
        cA.f159c = new InterfaceC0270s() { // from class: com.google.android.gms.internal.auth.zzs
            @Override // com.google.android.gms.common.api.internal.InterfaceC0270s
            public final void accept(Object obj, Object obj2) {
                zzab zzabVar = this.zza;
                ((zzp) ((zzi) obj).getService()).zzf(new zzw(zzabVar, (TaskCompletionSource) obj2), account, str, bundle);
            }
        };
        cA.f158b = 1512;
        return doWrite(cA.a());
    }

    @Override // com.google.android.gms.internal.auth.zzg
    public final Task zzd(final Account account) {
        F.h(account, "account cannot be null.");
        C cA = AbstractC0273v.a();
        cA.f160d = new C0773d[]{AbstractC0632f.f6256b};
        cA.f159c = new InterfaceC0270s() { // from class: com.google.android.gms.internal.auth.zzr
            @Override // com.google.android.gms.common.api.internal.InterfaceC0270s
            public final void accept(Object obj, Object obj2) {
                zzab zzabVar = this.zza;
                ((zzp) ((zzi) obj).getService()).zzg(new zzaa(zzabVar, (TaskCompletionSource) obj2), account);
            }
        };
        cA.f158b = 1517;
        return doWrite(cA.a());
    }

    @Override // com.google.android.gms.internal.auth.zzg
    public final Task zze(final String str) {
        F.h(str, "Client package name cannot be null!");
        C cA = AbstractC0273v.a();
        cA.f160d = new C0773d[]{AbstractC0632f.f6256b};
        cA.f159c = new InterfaceC0270s() { // from class: com.google.android.gms.internal.auth.zzq
            @Override // com.google.android.gms.common.api.internal.InterfaceC0270s
            public final void accept(Object obj, Object obj2) {
                zzab zzabVar = this.zza;
                ((zzp) ((zzi) obj).getService()).zzh(new zzy(zzabVar, (TaskCompletionSource) obj2), str);
            }
        };
        cA.f158b = 1514;
        return doWrite(cA.a());
    }
}
