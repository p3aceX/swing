package m2;

/* JADX INFO: loaded from: classes.dex */
public final class a extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public /* synthetic */ Object f5793a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ e f5794b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f5795c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public a(e eVar, A3.c cVar) {
        super(cVar);
        this.f5794b = eVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f5793a = obj;
        this.f5795c |= Integer.MIN_VALUE;
        return this.f5794b.B(this);
    }
}
