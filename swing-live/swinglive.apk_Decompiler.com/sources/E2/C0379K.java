package e2;

/* JADX INFO: renamed from: e2.K, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0379K extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public L f4044a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public /* synthetic */ Object f4045b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ L f4046c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f4047d;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0379K(L l2, A3.c cVar) {
        super(cVar);
        this.f4046c = l2;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f4045b = obj;
        this.f4047d |= Integer.MIN_VALUE;
        return L.b(this.f4046c, this);
    }
}
