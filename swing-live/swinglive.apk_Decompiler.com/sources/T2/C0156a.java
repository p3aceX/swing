package T2;

/* JADX INFO: renamed from: T2.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class C0156a implements q {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f1928a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ C0161f f1929b;

    public /* synthetic */ C0156a(C0161f c0161f, int i4) {
        this.f1928a = i4;
        this.f1929b = c0161f;
    }

    @Override // T2.q
    public final void b(String str) {
        switch (this.f1928a) {
            case 0:
                this.f1929b.f1946h.W(str);
                break;
            case 1:
                C0161f c0161f = this.f1929b;
                c0161f.f1946h.B(c0161f.f1963z, "cameraAccess", str);
                break;
            default:
                C0161f c0161f2 = this.f1929b;
                c0161f2.f1946h.B(c0161f2.f1963z, "cameraAccess", str);
                break;
        }
    }
}
