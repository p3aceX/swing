package o3;

/* JADX INFO: loaded from: classes.dex */
public final class y extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public /* synthetic */ Object f6167a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ C0588D f6168b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f6169c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public y(C0588D c0588d, A3.c cVar) {
        super(cVar);
        this.f6168b = c0588d;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f6167a = obj;
        this.f6169c |= Integer.MIN_VALUE;
        return this.f6168b.f(this);
    }
}
