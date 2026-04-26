package I;

/* JADX INFO: loaded from: classes.dex */
public final class X extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Z f621a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public T f622b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public boolean f623c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public /* synthetic */ Object f624d;
    public final /* synthetic */ Z e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f625f;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public X(Z z4, A3.c cVar) {
        super(cVar);
        this.e = z4;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f624d = obj;
        this.f625f |= Integer.MIN_VALUE;
        return this.e.a(null, this);
    }
}
