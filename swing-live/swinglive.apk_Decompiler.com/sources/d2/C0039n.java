package D2;

import z.InterfaceC0769a;

/* JADX INFO: renamed from: D2.n, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class C0039n implements InterfaceC0769a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f221a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Object f222b;

    public /* synthetic */ C0039n(Object obj, int i4) {
        this.f221a = i4;
        this.f222b = obj;
    }

    @Override // z.InterfaceC0769a
    public final void accept(Object obj) {
        switch (this.f221a) {
            case 0:
                ((r) this.f222b).setWindowInfoListenerDisplayFeatures((i0.j) obj);
                break;
            default:
                ((S3.j) ((S3.u) this.f222b)).k((i0.j) obj);
                break;
        }
    }
}
