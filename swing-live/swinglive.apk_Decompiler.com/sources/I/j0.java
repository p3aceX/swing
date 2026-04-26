package I;

/* JADX INFO: loaded from: classes.dex */
public final class j0 extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Y3.d f678a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public boolean f679b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public /* synthetic */ Object f680c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ l0 f681d;
    public int e;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public j0(l0 l0Var, A3.c cVar) {
        super(cVar);
        this.f681d = l0Var;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f680c = obj;
        this.e |= Integer.MIN_VALUE;
        return this.f681d.c(null, this);
    }
}
