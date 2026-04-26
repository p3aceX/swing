package b;

import D2.C0027b;
import android.window.OnBackInvokedCallback;
import android.window.OnBackInvokedDispatcher;

/* JADX INFO: renamed from: b.o, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0238o {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final C0238o f3250a = new C0238o();

    public final OnBackInvokedCallback a(I3.a aVar) {
        J3.i.e(aVar, "onBackInvoked");
        return new C0027b(aVar, 1);
    }

    public final void b(Object obj, int i4, Object obj2) {
        J3.i.e(obj, "dispatcher");
        J3.i.e(obj2, "callback");
        ((OnBackInvokedDispatcher) obj).registerOnBackInvokedCallback(i4, (OnBackInvokedCallback) obj2);
    }

    public final void c(Object obj, Object obj2) {
        J3.i.e(obj, "dispatcher");
        J3.i.e(obj2, "callback");
        ((OnBackInvokedDispatcher) obj).unregisterOnBackInvokedCallback((OnBackInvokedCallback) obj2);
    }
}
