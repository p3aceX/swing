package m2;

/* JADX INFO: loaded from: classes.dex */
public final class d extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public /* synthetic */ Object f5802a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ e f5803b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f5804c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public d(e eVar, A3.c cVar) {
        super(cVar);
        this.f5803b = eVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f5802a = obj;
        this.f5804c |= Integer.MIN_VALUE;
        return this.f5803b.H(this);
    }
}
