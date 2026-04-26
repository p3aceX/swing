package I;

/* JADX INFO: loaded from: classes.dex */
public final class C extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Q f539a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f540b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public /* synthetic */ Object f541c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ Q f542d;
    public int e;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C(Q q4, A3.c cVar) {
        super(cVar);
        this.f542d = q4;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f541c = obj;
        this.e |= Integer.MIN_VALUE;
        return this.f542d.g(this);
    }
}
