package I;

/* JADX INFO: loaded from: classes.dex */
public final class i0 extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Object f670a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Y3.d f671b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public /* synthetic */ Object f672c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ l0 f673d;
    public int e;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public i0(l0 l0Var, A3.c cVar) {
        super(cVar);
        this.f673d = l0Var;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f672c = obj;
        this.e |= Integer.MIN_VALUE;
        return this.f673d.b(null, this);
    }
}
