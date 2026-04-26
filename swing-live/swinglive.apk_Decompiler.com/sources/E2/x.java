package e2;

/* JADX INFO: loaded from: classes.dex */
public final class x extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public byte[] f4224a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public /* synthetic */ Object f4225b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ D2.A f4226c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f4227d;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public x(D2.A a5, A3.c cVar) {
        super(cVar);
        this.f4226c = a5;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f4225b = obj;
        this.f4227d |= Integer.MIN_VALUE;
        return this.f4226c.g(null, this);
    }
}
