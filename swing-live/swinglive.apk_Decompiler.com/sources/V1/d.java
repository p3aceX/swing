package V1;

/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class d implements Runnable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f2184a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ f f2185b;

    public /* synthetic */ d(f fVar, int i4) {
        this.f2184a = i4;
        this.f2185b = fVar;
    }

    @Override // java.lang.Runnable
    public final void run() {
        switch (this.f2184a) {
            case 0:
                f fVar = this.f2185b;
                try {
                    fVar.a(false);
                    return;
                } catch (RuntimeException e) {
                    fVar.getClass();
                    throw e;
                }
            default:
                f fVar2 = this.f2185b;
                try {
                    fVar2.a(true);
                    return;
                } catch (RuntimeException e4) {
                    fVar2.getClass();
                    throw e4;
                }
        }
    }
}
