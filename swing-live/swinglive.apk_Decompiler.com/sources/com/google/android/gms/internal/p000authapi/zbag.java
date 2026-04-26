package com.google.android.gms.internal.p000authapi;

import D2.C;
import android.app.Activity;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Parcelable;
import android.text.TextUtils;
import com.google.android.gms.auth.api.identity.SaveAccountLinkingTokenRequest;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.api.a;
import com.google.android.gms.common.api.h;
import com.google.android.gms.common.api.i;
import com.google.android.gms.common.api.internal.AbstractC0273v;
import com.google.android.gms.common.api.internal.InterfaceC0270s;
import com.google.android.gms.common.api.k;
import com.google.android.gms.common.api.l;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import java.util.ArrayList;
import u0.j;
import u0.p;
import z0.C0773d;

/* JADX INFO: loaded from: classes.dex */
public final class zbag extends l {
    private static final h zba;
    private static final a zbb;
    private static final i zbc;
    private final String zbd;

    static {
        h hVar = new h();
        zba = hVar;
        zbad zbadVar = new zbad();
        zbb = zbadVar;
        zbc = new i("Auth.Api.Identity.CredentialSaving.API", zbadVar, hVar);
    }

    public zbag(Activity activity, p pVar) {
        super(activity, activity, zbc, pVar, k.f3499c);
        this.zbd = zbat.zba();
    }

    public final Status getStatusFromIntent(Intent intent) {
        Status status = Status.f3374n;
        if (intent == null) {
            return status;
        }
        Parcelable.Creator<Status> creator = Status.CREATOR;
        byte[] byteArrayExtra = intent.getByteArrayExtra("status");
        Status status2 = (Status) (byteArrayExtra == null ? null : H0.a.v(byteArrayExtra, creator));
        return status2 == null ? status : status2;
    }

    public final Task<j> saveAccountLinkingToken(SaveAccountLinkingTokenRequest saveAccountLinkingTokenRequest) {
        F.g(saveAccountLinkingTokenRequest);
        new ArrayList();
        TextUtils.isEmpty(saveAccountLinkingTokenRequest.e);
        String str = this.zbd;
        PendingIntent pendingIntent = saveAccountLinkingTokenRequest.f3325a;
        F.a("Consent PendingIntent cannot be null", pendingIntent != null);
        String str2 = saveAccountLinkingTokenRequest.f3326b;
        F.a("Invalid tokenType", "auth_code".equals(str2));
        String str3 = saveAccountLinkingTokenRequest.f3327c;
        F.a("serviceId cannot be null or empty", !TextUtils.isEmpty(str3));
        ArrayList arrayList = saveAccountLinkingTokenRequest.f3328d;
        F.a("scopes cannot be null", arrayList != null);
        final SaveAccountLinkingTokenRequest saveAccountLinkingTokenRequest2 = new SaveAccountLinkingTokenRequest(pendingIntent, str2, str3, arrayList, str, saveAccountLinkingTokenRequest.f3329f);
        C cA = AbstractC0273v.a();
        cA.f160d = new C0773d[]{zbas.zbg};
        cA.f159c = new InterfaceC0270s() { // from class: com.google.android.gms.internal.auth-api.zbab
            @Override // com.google.android.gms.common.api.internal.InterfaceC0270s
            public final void accept(Object obj, Object obj2) {
                zbae zbaeVar = new zbae(this.zba, (TaskCompletionSource) obj2);
                zbn zbnVar = (zbn) ((zbh) obj).getService();
                SaveAccountLinkingTokenRequest saveAccountLinkingTokenRequest3 = saveAccountLinkingTokenRequest2;
                F.g(saveAccountLinkingTokenRequest3);
                zbnVar.zbc(zbaeVar, saveAccountLinkingTokenRequest3);
            }
        };
        cA.f157a = false;
        cA.f158b = 1535;
        return doRead(cA.a());
    }

    public final Task<u0.l> savePassword(u0.k kVar) {
        F.g(kVar);
        final u0.k kVar2 = new u0.k(kVar.f6620a, this.zbd, kVar.f6622c);
        C cA = AbstractC0273v.a();
        cA.f160d = new C0773d[]{zbas.zbe};
        cA.f159c = new InterfaceC0270s() { // from class: com.google.android.gms.internal.auth-api.zbac
            @Override // com.google.android.gms.common.api.internal.InterfaceC0270s
            public final void accept(Object obj, Object obj2) {
                zbaf zbafVar = new zbaf(this.zba, (TaskCompletionSource) obj2);
                zbn zbnVar = (zbn) ((zbh) obj).getService();
                u0.k kVar3 = kVar2;
                F.g(kVar3);
                zbnVar.zbd(zbafVar, kVar3);
            }
        };
        cA.f157a = false;
        cA.f158b = 1536;
        return doRead(cA.a());
    }

    public zbag(Context context, p pVar) {
        super(context, null, zbc, pVar, k.f3499c);
        this.zbd = zbat.zba();
    }
}
