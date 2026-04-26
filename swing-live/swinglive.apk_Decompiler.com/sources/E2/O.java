package e2;

/* JADX INFO: loaded from: classes.dex */
public final class O extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Object f4067a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f4068b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public /* synthetic */ Object f4069c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ Q f4070d;
    public int e;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public O(Q q4, A3.c cVar) {
        super(cVar);
        this.f4070d = q4;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f4069c = obj;
        this.e |= Integer.MIN_VALUE;
        return this.f4070d.a(this);
    }
}
