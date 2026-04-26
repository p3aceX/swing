package b;

import android.window.OnBackInvokedCallback;

/* JADX INFO: renamed from: b.q, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0240q {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final C0240q f3255a = new C0240q();

    public final OnBackInvokedCallback a(I3.l lVar, I3.l lVar2, I3.a aVar, I3.a aVar2) {
        J3.i.e(lVar, "onBackStarted");
        J3.i.e(lVar2, "onBackProgressed");
        J3.i.e(aVar, "onBackInvoked");
        J3.i.e(aVar2, "onBackCancelled");
        return new C0239p(lVar, lVar2, aVar, aVar2);
    }
}
