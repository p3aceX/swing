package e2;

/* JADX INFO: renamed from: e2.C, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0371C extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public /* synthetic */ Object f4013a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ L f4014b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f4015c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0371C(L l2, A3.c cVar) {
        super(cVar);
        this.f4014b = l2;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f4013a = obj;
        this.f4015c |= Integer.MIN_VALUE;
        return this.f4014b.c(this);
    }
}
