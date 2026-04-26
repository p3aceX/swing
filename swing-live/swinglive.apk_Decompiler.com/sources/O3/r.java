package o3;

/* JADX INFO: loaded from: classes.dex */
public final class r extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public EnumC0604l f6134a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public J3.r f6135b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public X.N f6136c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public C0597e f6137d;
    public /* synthetic */ Object e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final /* synthetic */ C0588D f6138f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public int f6139m;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public r(C0588D c0588d, A3.c cVar) {
        super(cVar);
        this.f6138f = c0588d;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.e = obj;
        this.f6139m |= Integer.MIN_VALUE;
        return this.f6138f.c(this);
    }
}
