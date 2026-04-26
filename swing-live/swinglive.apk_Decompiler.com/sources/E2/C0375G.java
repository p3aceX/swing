package e2;

/* JADX INFO: renamed from: e2.G, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0375G extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public boolean f4028a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public /* synthetic */ Object f4029b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ L f4030c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f4031d;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0375G(L l2, A3.c cVar) {
        super(cVar);
        this.f4030c = l2;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f4029b = obj;
        this.f4031d |= Integer.MIN_VALUE;
        return L.a(this.f4030c, false, this);
    }
}
