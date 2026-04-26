package y2;

/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class b implements Runnable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f6868a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ g f6869b;

    public /* synthetic */ b(g gVar, int i4) {
        this.f6868a = i4;
        this.f6869b = gVar;
    }

    @Override // java.lang.Runnable
    public final void run() {
        switch (this.f6868a) {
            case 0:
                this.f6869b.h();
                break;
            case 1:
                this.f6869b.h();
                break;
            case 2:
                this.f6869b.h();
                break;
            case 3:
                this.f6869b.b("startStream_v3");
                break;
            default:
                this.f6869b.b("refreshOverlay");
                break;
        }
    }
}
