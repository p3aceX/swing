package e2;

/* JADX INFO: loaded from: classes.dex */
public final class t extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public byte[] f4209a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public /* synthetic */ Object f4210b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ D2.A f4211c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f4212d;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public t(D2.A a5, A3.c cVar) {
        super(cVar);
        this.f4211c = a5;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f4210b = obj;
        this.f4212d |= Integer.MIN_VALUE;
        return this.f4211c.c(null, this);
    }
}
