package r2;

/* JADX INFO: loaded from: classes.dex */
public final class u extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f6405a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f6406b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f6407c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public Object f6408d;
    public /* synthetic */ Object e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final /* synthetic */ x f6409f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public int f6410m;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public u(x xVar, A3.c cVar) {
        super(cVar);
        this.f6409f = xVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.e = obj;
        this.f6410m |= Integer.MIN_VALUE;
        return this.f6409f.a(this);
    }
}
