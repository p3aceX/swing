package D2;

import android.window.OnBackInvokedCallback;

/* JADX INFO: renamed from: D2.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class C0027b implements OnBackInvokedCallback {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f182a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Object f183b;

    public /* synthetic */ C0027b(Object obj, int i4) {
        this.f182a = i4;
        this.f183b = obj;
    }

    public final void onBackInvoked() {
        switch (this.f182a) {
            case 0:
                ((AbstractActivityC0029d) this.f183b).onBackPressed();
                break;
            default:
                I3.a aVar = (I3.a) this.f183b;
                J3.i.e(aVar, "$onBackInvoked");
                aVar.a();
                break;
        }
    }
}
