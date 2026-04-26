package I;

/* JADX INFO: renamed from: I.k, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0050k extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Object f682a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Object f683b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Object f684c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public J3.r f685d;
    public Q e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public /* synthetic */ Object f686f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final /* synthetic */ C0051l f687m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public int f688n;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0050k(C0051l c0051l, A3.c cVar) {
        super(cVar);
        this.f687m = c0051l;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f686f = obj;
        this.f688n |= Integer.MIN_VALUE;
        return this.f687m.a(null, this);
    }
}
