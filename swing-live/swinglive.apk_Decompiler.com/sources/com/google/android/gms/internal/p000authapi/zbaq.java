package com.google.android.gms.internal.p000authapi;

import D2.C;
import android.app.Activity;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Parcelable;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.api.a;
import com.google.android.gms.common.api.h;
import com.google.android.gms.common.api.i;
import com.google.android.gms.common.api.internal.AbstractC0273v;
import com.google.android.gms.common.api.internal.C0259g;
import com.google.android.gms.common.api.internal.InterfaceC0270s;
import com.google.android.gms.common.api.j;
import com.google.android.gms.common.api.k;
import com.google.android.gms.common.api.l;
import com.google.android.gms.common.api.o;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import java.util.Iterator;
import java.util.Set;
import u0.b;
import u0.c;
import u0.d;
import u0.e;
import u0.f;
import u0.g;
import u0.m;
import u0.q;
import z0.C0773d;

/* JADX INFO: loaded from: classes.dex */
public final class zbaq extends l {
    private static final h zba;
    private static final a zbb;
    private static final i zbc;
    private final String zbd;

    static {
        h hVar = new h();
        zba = hVar;
        zbal zbalVar = new zbal();
        zbb = zbalVar;
        zbc = new i("Auth.Api.Identity.SignIn.API", zbalVar, hVar);
    }

    public zbaq(Activity activity, q qVar) {
        super(activity, activity, zbc, qVar, k.f3499c);
        this.zbd = zbat.zba();
    }

    public final Task<g> beginSignIn(f fVar) {
        F.g(fVar);
        b bVar = fVar.f6607b;
        F.g(bVar);
        e eVar = fVar.f6606a;
        F.g(eVar);
        d dVar = fVar.f6610f;
        F.g(dVar);
        c cVar = fVar.f6611m;
        F.g(cVar);
        final f fVar2 = new f(eVar, bVar, this.zbd, fVar.f6609d, fVar.e, dVar, cVar);
        C cA = AbstractC0273v.a();
        cA.f160d = new C0773d[]{zbas.zba};
        cA.f159c = new InterfaceC0270s() { // from class: com.google.android.gms.internal.auth-api.zbaj
            @Override // com.google.android.gms.common.api.internal.InterfaceC0270s
            public final void accept(Object obj, Object obj2) {
                zbam zbamVar = new zbam(this.zba, (TaskCompletionSource) obj2);
                zbw zbwVar = (zbw) ((zbar) obj).getService();
                f fVar3 = fVar2;
                F.g(fVar3);
                zbwVar.zbc(zbamVar, fVar3);
            }
        };
        cA.f157a = false;
        cA.f158b = 1553;
        return doRead(cA.a());
    }

    public final String getPhoneNumberFromIntent(Intent intent) throws j {
        Status status = Status.f3374n;
        if (intent == null) {
            throw new j(status);
        }
        Parcelable.Creator<Status> creator = Status.CREATOR;
        byte[] byteArrayExtra = intent.getByteArrayExtra("status");
        Status status2 = (Status) (byteArrayExtra == null ? null : H0.a.v(byteArrayExtra, creator));
        if (status2 == null) {
            throw new j(Status.f3376p);
        }
        if (!status2.b()) {
            throw new j(status2);
        }
        String stringExtra = intent.getStringExtra("phone_number_hint_result");
        if (stringExtra != null) {
            return stringExtra;
        }
        throw new j(status);
    }

    public final Task<PendingIntent> getPhoneNumberHintIntent(final u0.h hVar) {
        F.g(hVar);
        C cA = AbstractC0273v.a();
        cA.f160d = new C0773d[]{zbas.zbh};
        cA.f159c = new InterfaceC0270s() { // from class: com.google.android.gms.internal.auth-api.zbah
            @Override // com.google.android.gms.common.api.internal.InterfaceC0270s
            public final void accept(Object obj, Object obj2) {
                this.zba.zba(hVar, (zbar) obj, (TaskCompletionSource) obj2);
            }
        };
        cA.f158b = 1653;
        return doRead(cA.a());
    }

    public final m getSignInCredentialFromIntent(Intent intent) throws j {
        Status status = Status.f3374n;
        if (intent == null) {
            throw new j(status);
        }
        Parcelable.Creator<Status> creator = Status.CREATOR;
        byte[] byteArrayExtra = intent.getByteArrayExtra("status");
        Status status2 = (Status) (byteArrayExtra == null ? null : H0.a.v(byteArrayExtra, creator));
        if (status2 == null) {
            throw new j(Status.f3376p);
        }
        if (!status2.b()) {
            throw new j(status2);
        }
        Parcelable.Creator<m> creator2 = m.CREATOR;
        byte[] byteArrayExtra2 = intent.getByteArrayExtra("sign_in_credential");
        m mVar = (m) (byteArrayExtra2 != null ? H0.a.v(byteArrayExtra2, creator2) : null);
        if (mVar != null) {
            return mVar;
        }
        throw new j(status);
    }

    public final Task<PendingIntent> getSignInIntent(u0.i iVar) {
        F.g(iVar);
        String str = iVar.f6614a;
        F.g(str);
        final u0.i iVar2 = new u0.i(str, iVar.f6615b, this.zbd, iVar.f6617d, iVar.e, iVar.f6618f);
        C cA = AbstractC0273v.a();
        cA.f160d = new C0773d[]{zbas.zbf};
        cA.f159c = new InterfaceC0270s() { // from class: com.google.android.gms.internal.auth-api.zbak
            @Override // com.google.android.gms.common.api.internal.InterfaceC0270s
            public final void accept(Object obj, Object obj2) {
                zbao zbaoVar = new zbao(this.zba, (TaskCompletionSource) obj2);
                zbw zbwVar = (zbw) ((zbar) obj).getService();
                u0.i iVar3 = iVar2;
                F.g(iVar3);
                zbwVar.zbe(zbaoVar, iVar3);
            }
        };
        cA.f158b = 1555;
        return doRead(cA.a());
    }

    public final Task<Void> signOut() {
        getApplicationContext().getSharedPreferences("com.google.android.gms.signin", 0).edit().clear().apply();
        Set set = o.f3502a;
        synchronized (set) {
        }
        Iterator it = set.iterator();
        if (it.hasNext()) {
            ((o) it.next()).getClass();
            throw new UnsupportedOperationException();
        }
        C0259g.a();
        C cA = AbstractC0273v.a();
        cA.f160d = new C0773d[]{zbas.zbb};
        cA.f159c = new InterfaceC0270s() { // from class: com.google.android.gms.internal.auth-api.zbai
            @Override // com.google.android.gms.common.api.internal.InterfaceC0270s
            public final void accept(Object obj, Object obj2) {
                this.zba.zbb((zbar) obj, (TaskCompletionSource) obj2);
            }
        };
        cA.f157a = false;
        cA.f158b = 1554;
        return doWrite(cA.a());
    }

    public final /* synthetic */ void zba(u0.h hVar, zbar zbarVar, TaskCompletionSource taskCompletionSource) {
        ((zbw) zbarVar.getService()).zbd(new zbap(this, taskCompletionSource), hVar, this.zbd);
    }

    public final /* synthetic */ void zbb(zbar zbarVar, TaskCompletionSource taskCompletionSource) {
        ((zbw) zbarVar.getService()).zbf(new zban(this, taskCompletionSource), this.zbd);
    }

    public zbaq(Context context, q qVar) {
        super(context, null, zbc, qVar, k.f3499c);
        this.zbd = zbat.zba();
    }
}
