package E1;

/* JADX INFO: loaded from: classes.dex */
public final class g extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public /* synthetic */ Object f330a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ h f331b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f332c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public g(h hVar, A3.c cVar) {
        super(cVar);
        this.f331b = hVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f330a = obj;
        this.f332c |= Integer.MIN_VALUE;
        return this.f331b.f(this);
    }
}
