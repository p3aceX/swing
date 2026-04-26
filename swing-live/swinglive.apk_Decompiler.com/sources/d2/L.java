package D2;

/* JADX INFO: loaded from: classes.dex */
public final class L implements io.flutter.embedding.engine.renderer.k {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ Runnable f171a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ N f172b;

    public L(N n4, Runnable runnable) {
        this.f172b = n4;
        this.f171a = runnable;
    }

    @Override // io.flutter.embedding.engine.renderer.k
    public final void b() {
        this.f171a.run();
        io.flutter.embedding.engine.renderer.j jVar = this.f172b.f174b;
        if (jVar != null) {
            jVar.g(this);
        }
    }

    @Override // io.flutter.embedding.engine.renderer.k
    public final void a() {
    }
}
