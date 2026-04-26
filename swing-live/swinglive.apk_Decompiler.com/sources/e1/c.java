package E1;

/* JADX INFO: loaded from: classes.dex */
public final class c extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public b f315a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public /* synthetic */ Object f316b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ b f317c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f318d;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public c(b bVar, A3.c cVar) {
        super(cVar);
        this.f317c = bVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f316b = obj;
        this.f318d |= Integer.MIN_VALUE;
        return b.k(this.f317c, this);
    }
}
