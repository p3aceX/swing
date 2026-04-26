package I;

/* JADX INFO: renamed from: I.j, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0049j extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public C0053n f674a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public /* synthetic */ Object f675b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ C0053n f676c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f677d;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0049j(C0053n c0053n, A3.c cVar) {
        super(cVar);
        this.f676c = c0053n;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f675b = obj;
        this.f677d |= Integer.MIN_VALUE;
        return this.f676c.f(this);
    }
}
