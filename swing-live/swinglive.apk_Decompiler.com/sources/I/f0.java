package I;

/* JADX INFO: loaded from: classes.dex */
public final class f0 extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public C0053n f655a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Y3.a f656b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public /* synthetic */ Object f657c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ C0053n f658d;
    public int e;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public f0(C0053n c0053n, A3.c cVar) {
        super(cVar);
        this.f658d = c0053n;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f657c = obj;
        this.e |= Integer.MIN_VALUE;
        return this.f658d.w(this);
    }
}
