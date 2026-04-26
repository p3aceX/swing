package I;

/* JADX INFO: renamed from: I.z, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0064z extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Q f744a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Y3.d f745b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public /* synthetic */ Object f746c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ Q f747d;
    public int e;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0064z(Q q4, A3.c cVar) {
        super(cVar);
        this.f747d = q4;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f746c = obj;
        this.e |= Integer.MIN_VALUE;
        return Q.c(this.f747d, this);
    }
}
