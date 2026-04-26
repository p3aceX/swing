package I;

/* JADX INFO: loaded from: classes.dex */
public final class O extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public J3.p f587a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public /* synthetic */ Object f588b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ Q f589c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f590d;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public O(Q q4, A3.c cVar) {
        super(cVar);
        this.f589c = q4;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f588b = obj;
        this.f590d |= Integer.MIN_VALUE;
        return this.f589c.i(null, false, this);
    }
}
