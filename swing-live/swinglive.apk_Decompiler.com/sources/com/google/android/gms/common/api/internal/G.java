package com.google.android.gms.common.api.internal;

import com.google.android.gms.common.internal.InterfaceC0281d;
import com.google.android.gms.common.internal.InterfaceC0290m;
import java.util.Set;
import z0.C0771b;

/* JADX INFO: loaded from: classes.dex */
public final class G implements InterfaceC0281d {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final com.google.android.gms.common.api.g f3407a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final C0253a f3408b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public InterfaceC0290m f3409c = null;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public Set f3410d = null;
    public boolean e = false;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final /* synthetic */ C0259g f3411f;

    public G(C0259g c0259g, com.google.android.gms.common.api.g gVar, C0253a c0253a) {
        this.f3411f = c0259g;
        this.f3407a = gVar;
        this.f3408b = c0253a;
    }

    @Override // com.google.android.gms.common.internal.InterfaceC0281d
    public final void a(C0771b c0771b) {
        this.f3411f.f3481n.post(new Z(1, this, c0771b));
    }

    public final void b(C0771b c0771b) {
        E e = (E) this.f3411f.f3477j.get(this.f3408b);
        if (e != null) {
            com.google.android.gms.common.internal.F.c(e.f3404m.f3481n);
            com.google.android.gms.common.api.g gVar = e.f3394b;
            String name = gVar.getClass().getName();
            String strValueOf = String.valueOf(c0771b);
            StringBuilder sb = new StringBuilder(name.length() + 25 + strValueOf.length());
            sb.append("onSignInFailed for ");
            sb.append(name);
            sb.append(" with ");
            sb.append(strValueOf);
            gVar.disconnect(sb.toString());
            e.p(c0771b, null);
        }
    }
}
