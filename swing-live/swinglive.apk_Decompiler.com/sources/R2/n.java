package r2;

/* JADX INFO: loaded from: classes.dex */
public final class n extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public boolean f6374a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public /* synthetic */ Object f6375b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ r f6376c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f6377d;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public n(r rVar, A3.c cVar) {
        super(cVar);
        this.f6376c = rVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f6375b = obj;
        this.f6377d |= Integer.MIN_VALUE;
        return r.a(this.f6376c, false, this);
    }
}
