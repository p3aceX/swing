package e2;

/* JADX INFO: loaded from: classes.dex */
public final class s extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public /* synthetic */ Object f4206a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ D2.A f4207b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f4208c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public s(D2.A a5, A3.c cVar) {
        super(cVar);
        this.f4207b = a5;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f4206a = obj;
        this.f4208c |= Integer.MIN_VALUE;
        return this.f4207b.b(null, this);
    }
}
