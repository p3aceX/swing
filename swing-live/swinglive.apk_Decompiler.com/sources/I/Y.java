package I;

/* JADX INFO: loaded from: classes.dex */
public final class Y extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Z f626a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Object f627b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Object f628c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public b0 f629d;
    public /* synthetic */ Object e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final /* synthetic */ Z f630f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public int f631m;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public Y(Z z4, A3.c cVar) {
        super(cVar);
        this.f630f = z4;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.e = obj;
        this.f631m |= Integer.MIN_VALUE;
        return this.f630f.b(null, this);
    }
}
