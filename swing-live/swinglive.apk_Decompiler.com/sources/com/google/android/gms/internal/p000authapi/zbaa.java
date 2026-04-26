package com.google.android.gms.internal.p000authapi;

import D2.C;
import android.accounts.Account;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Parcelable;
import com.google.android.gms.auth.api.identity.AuthorizationRequest;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.api.a;
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
import java.util.ArrayList;
import u0.C0687a;
import u0.o;
import z0.C0773d;

/* JADX INFO: loaded from: classes.dex */
public final class zbaa extends l {
    private static final h zba;
    private static final a zbb;
    private static final i zbc;

    static {
        h hVar = new h();
        zba = hVar;
        zby zbyVar = new zby();
        zbb = zbyVar;
        zbc = new i("Auth.Api.Identity.Authorization.API", zbyVar, hVar);
    }

    /* JADX WARN: Illegal instructions before constructor call */
    public zbaa(Activity activity, o oVar) {
        i iVar = zbc;
        String str = oVar.f6634a;
        if (str != null) {
            F.d(str);
        }
        String strZba = zbat.zba();
        F.d(strZba);
        super(activity, activity, iVar, new o(strZba), k.f3499c);
    }

    public final Task<C0687a> authorize(AuthorizationRequest authorizationRequest) {
        String str;
        boolean z4;
        boolean z5;
        boolean z6;
        String str2;
        F.g(authorizationRequest);
        ArrayList arrayList = authorizationRequest.f3318a;
        F.a("requestedScopes cannot be null or empty", (arrayList == null || arrayList.isEmpty()) ? false : true);
        String str3 = null;
        String str4 = authorizationRequest.f3322f;
        if (str4 != null) {
            F.d(str4);
            str = str4;
        } else {
            str = null;
        }
        Account account = authorizationRequest.e;
        Account account2 = account != null ? account : null;
        boolean z7 = authorizationRequest.f3321d;
        String str5 = authorizationRequest.f3319b;
        if (!z7 || str5 == null) {
            z4 = false;
        } else {
            z4 = true;
            str3 = str5;
        }
        if (!authorizationRequest.f3320c || str5 == null) {
            z5 = false;
            z6 = false;
            str2 = str3;
        } else {
            F.a("two different server client ids provided", str3 == null || str3.equals(str5));
            z6 = authorizationRequest.f3324n;
            str2 = str5;
            z5 = true;
        }
        final AuthorizationRequest authorizationRequest2 = new AuthorizationRequest(arrayList, str2, z5, z4, account2, str, ((o) getApiOptions()).f6634a, z6);
        C cA = AbstractC0273v.a();
        cA.f160d = new C0773d[]{zbas.zbc};
        cA.f159c = new InterfaceC0270s() { // from class: com.google.android.gms.internal.auth-api.zbx
            @Override // com.google.android.gms.common.api.internal.InterfaceC0270s
            public final void accept(Object obj, Object obj2) {
                zbz zbzVar = new zbz(this.zba, (TaskCompletionSource) obj2);
                zbk zbkVar = (zbk) ((zbg) obj).getService();
                AuthorizationRequest authorizationRequest3 = authorizationRequest2;
                F.g(authorizationRequest3);
                zbkVar.zbc(zbzVar, authorizationRequest3);
            }
        };
        cA.f157a = false;
        cA.f158b = 1534;
        return doRead(cA.a());
    }

    public final C0687a getAuthorizationResultFromIntent(Intent intent) throws j {
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
        Parcelable.Creator<C0687a> creator2 = C0687a.CREATOR;
        byte[] byteArrayExtra2 = intent.getByteArrayExtra("authorization_result");
        C0687a c0687a = (C0687a) (byteArrayExtra2 != null ? H0.a.v(byteArrayExtra2, creator2) : null);
        if (c0687a != null) {
            return c0687a;
        }
        throw new j(status);
    }

    /* JADX WARN: Illegal instructions before constructor call */
    public zbaa(Context context, o oVar) {
        i iVar = zbc;
        String str = oVar.f6634a;
        if (str != null) {
            F.d(str);
        }
        String strZba = zbat.zba();
        F.d(strZba);
        super(context, null, iVar, new o(strZba), k.f3499c);
    }
}
