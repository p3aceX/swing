package r2;

/* JADX INFO: loaded from: classes.dex */
public final class b extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public /* synthetic */ Object f6316a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ i f6317b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f6318c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public b(i iVar, A3.c cVar) {
        super(cVar);
        this.f6317b = iVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f6316a = obj;
        this.f6318c |= Integer.MIN_VALUE;
        return this.f6317b.b(null, this);
    }
}
