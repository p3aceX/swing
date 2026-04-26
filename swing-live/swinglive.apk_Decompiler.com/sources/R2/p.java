package r2;

/* JADX INFO: loaded from: classes.dex */
public final class p extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f6380a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f6381b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public /* synthetic */ Object f6382c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ r f6383d;
    public int e;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public p(r rVar, A3.c cVar) {
        super(cVar);
        this.f6383d = rVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f6382c = obj;
        this.e |= Integer.MIN_VALUE;
        return this.f6383d.c(this);
    }
}
