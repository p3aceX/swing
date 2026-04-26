package m2;

/* JADX INFO: loaded from: classes.dex */
public final class c extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public /* synthetic */ Object f5799a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ e f5800b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f5801c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public c(e eVar, A3.c cVar) {
        super(cVar);
        this.f5800b = eVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f5799a = obj;
        this.f5801c |= Integer.MIN_VALUE;
        return this.f5800b.G(this);
    }
}
