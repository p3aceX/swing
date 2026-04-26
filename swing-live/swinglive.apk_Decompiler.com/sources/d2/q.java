package D2;

/* JADX INFO: loaded from: classes.dex */
public final class q implements io.flutter.embedding.engine.renderer.k {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ io.flutter.embedding.engine.renderer.j f226a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ F1.a f227b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ r f228c;

    public q(r rVar, io.flutter.embedding.engine.renderer.j jVar, F1.a aVar) {
        this.f228c = rVar;
        this.f226a = jVar;
        this.f227b = aVar;
    }

    @Override // io.flutter.embedding.engine.renderer.k
    public final void b() {
        C0033h c0033h;
        this.f226a.g(this);
        this.f227b.run();
        r rVar = this.f228c;
        if ((rVar.f242f instanceof C0033h) || (c0033h = rVar.e) == null) {
            return;
        }
        c0033h.d();
        C0033h c0033h2 = rVar.e;
        if (c0033h2 != null) {
            c0033h2.f204a.close();
            rVar.removeView(rVar.e);
            rVar.e = null;
        }
    }

    @Override // io.flutter.embedding.engine.renderer.k
    public final void a() {
    }
}
