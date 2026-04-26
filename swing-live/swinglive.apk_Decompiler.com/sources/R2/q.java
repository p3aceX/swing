package r2;

/* JADX INFO: loaded from: classes.dex */
public final class q extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public r f6384a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public /* synthetic */ Object f6385b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ r f6386c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f6387d;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public q(r rVar, A3.c cVar) {
        super(cVar);
        this.f6386c = rVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f6385b = obj;
        this.f6387d |= Integer.MIN_VALUE;
        return r.b(this.f6386c, this);
    }
}
