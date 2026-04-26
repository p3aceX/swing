package o3;

/* JADX INFO: loaded from: classes.dex */
public final class Q extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public io.ktor.utils.io.v f6034a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public S3.v f6035b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public S3.d f6036c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f6037d;
    public int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f6038f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public int f6039m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public long f6040n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public /* synthetic */ Object f6041o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public final /* synthetic */ V f6042p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public int f6043q;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public Q(V v, A3.c cVar) {
        super(cVar);
        this.f6042p = v;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f6041o = obj;
        this.f6043q |= Integer.MIN_VALUE;
        return V.b(this.f6042p, null, this);
    }
}
