package e2;

/* JADX INFO: loaded from: classes.dex */
public final class y extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public /* synthetic */ Object f4228a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ D2.A f4229b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f4230c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public y(D2.A a5, A3.c cVar) {
        super(cVar);
        this.f4229b = a5;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f4228a = obj;
        this.f4230c |= Integer.MIN_VALUE;
        return this.f4229b.h(null, null, this);
    }
}
