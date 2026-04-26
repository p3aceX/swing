package I;

/* JADX INFO: renamed from: I.w, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0061w extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Q f733a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Y3.d f734b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public /* synthetic */ Object f735c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ Q f736d;
    public int e;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0061w(Q q4, A3.c cVar) {
        super(cVar);
        this.f736d = q4;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f735c = obj;
        this.e |= Integer.MIN_VALUE;
        return Q.a(this.f736d, this);
    }
}
