package m2;

/* JADX INFO: loaded from: classes.dex */
public final class b extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public /* synthetic */ Object f5796a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ e f5797b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f5798c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public b(e eVar, A3.c cVar) {
        super(cVar);
        this.f5797b = eVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f5796a = obj;
        this.f5798c |= Integer.MIN_VALUE;
        return this.f5797b.F(this);
    }
}
