package com.google.android.gms.common.api.internal;

import android.accounts.Account;
import android.content.Context;
import android.os.Handler;
import android.os.Parcel;
import android.os.RemoteException;
import android.util.Log;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.common.internal.AbstractC0283f;
import com.google.android.gms.common.internal.C0285h;
import com.google.android.gms.internal.base.zac;
import java.util.Set;
import y0.C0738b;
import z0.C0771b;

/* JADX INFO: loaded from: classes.dex */
public final class O extends P0.c implements com.google.android.gms.common.api.m, com.google.android.gms.common.api.n {

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public static final B0.b f3426h = O0.b.f1442a;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Context f3427a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Handler f3428b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final B0.b f3429c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final Set f3430d;
    public final C0285h e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public P0.a f3431f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public G f3432g;

    public O(Context context, Handler handler, C0285h c0285h) {
        super("com.google.android.gms.signin.internal.ISignInCallbacks");
        this.f3427a = context;
        this.f3428b = handler;
        this.e = c0285h;
        this.f3430d = c0285h.f3557a;
        this.f3429c = f3426h;
    }

    @Override // com.google.android.gms.common.api.internal.InterfaceC0267o
    public final void a(C0771b c0771b) {
        this.f3432g.b(c0771b);
    }

    @Override // com.google.android.gms.common.api.internal.InterfaceC0258f
    public final void c(int i4) {
        this.f3431f.disconnect();
    }

    @Override // com.google.android.gms.common.api.internal.InterfaceC0258f
    public final void d() {
        P0.a aVar = this.f3431f;
        aVar.getClass();
        try {
            aVar.f1477b.getClass();
            Account account = new Account(AbstractC0283f.DEFAULT_ACCOUNT, "com.google");
            GoogleSignInAccount googleSignInAccountB = AbstractC0283f.DEFAULT_ACCOUNT.equals(account.name) ? C0738b.a(aVar.getContext()).b() : null;
            Integer num = aVar.f1479d;
            com.google.android.gms.common.internal.F.g(num);
            com.google.android.gms.common.internal.A a5 = new com.google.android.gms.common.internal.A(2, account, num.intValue(), googleSignInAccountB);
            P0.d dVar = (P0.d) aVar.getService();
            P0.f fVar = new P0.f(1, a5);
            Parcel parcelZaa = dVar.zaa();
            zac.zac(parcelZaa, fVar);
            zac.zad(parcelZaa, this);
            dVar.zac(12, parcelZaa);
        } catch (RemoteException e) {
            Log.w("SignInClientImpl", "Remote service probably died when signIn is called");
            try {
                this.f3428b.post(new Z(2, this, new P0.g(1, new C0771b(8, null), null)));
            } catch (RemoteException unused) {
                Log.wtf("SignInClientImpl", "ISignInCallbacks#onSignInComplete should be executed from the same process, unexpected RemoteException.", e);
            }
        }
    }
}
