package Q3;

/* JADX INFO: renamed from: Q3.l, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class C0139l implements I3.q {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f1635a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Object f1636b;

    public /* synthetic */ C0139l(Object obj, int i4) {
        this.f1635a = i4;
        this.f1636b = obj;
    }

    @Override // I3.q
    public final Object b(Object obj, Object obj2, Object obj3) {
        Throwable th = (Throwable) obj;
        switch (this.f1635a) {
            case 0:
                ((M1.a) this.f1636b).invoke(th);
                break;
            default:
                ((Y3.h) this.f1636b).b();
                break;
        }
        return w3.i.f6729a;
    }
}
