package o3;

/* JADX INFO: loaded from: classes.dex */
public final class z extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public /* synthetic */ Object f6170a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ C0588D f6171b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f6172c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public z(C0588D c0588d, A3.c cVar) {
        super(cVar);
        this.f6171b = c0588d;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f6170a = obj;
        this.f6172c |= Integer.MIN_VALUE;
        return this.f6171b.g(this);
    }
}
