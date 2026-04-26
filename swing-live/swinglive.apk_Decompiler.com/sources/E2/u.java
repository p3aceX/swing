package e2;

/* JADX INFO: loaded from: classes.dex */
public final class u extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public byte[] f4213a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public byte[] f4214b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public /* synthetic */ Object f4215c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ D2.A f4216d;
    public int e;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public u(D2.A a5, A3.c cVar) {
        super(cVar);
        this.f4216d = a5;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f4215c = obj;
        this.e |= Integer.MIN_VALUE;
        return this.f4216d.d(null, null, this);
    }
}
