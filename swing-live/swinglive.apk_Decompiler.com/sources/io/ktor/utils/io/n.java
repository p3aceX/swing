package io.ktor.utils.io;

/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class n implements I3.l {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f4996a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ C0449m f4997b;

    public /* synthetic */ n(C0449m c0449m, int i4) {
        this.f4996a = i4;
        this.f4997b = c0449m;
    }

    @Override // I3.l
    public final Object invoke(Object obj) {
        Throwable th = (Throwable) obj;
        switch (this.f4996a) {
            case 0:
                if (th != null) {
                    this.f4997b.t(th);
                }
                break;
            case 1:
                if (th != null) {
                    C0449m c0449m = this.f4997b;
                    if (!c0449m.f()) {
                        c0449m.t(th);
                    }
                }
                break;
            default:
                if (th != null) {
                    C0449m c0449m2 = this.f4997b;
                    if (!c0449m2.g()) {
                        c0449m2.t(th);
                    }
                }
                break;
        }
        return w3.i.f6729a;
    }
}
