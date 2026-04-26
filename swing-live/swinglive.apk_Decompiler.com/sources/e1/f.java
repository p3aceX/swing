package E1;

/* JADX INFO: loaded from: classes.dex */
public final class f extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public /* synthetic */ Object f327a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ h f328b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f329c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public f(h hVar, A3.c cVar) {
        super(cVar);
        this.f328b = hVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f327a = obj;
        this.f329c |= Integer.MIN_VALUE;
        return this.f328b.b(this);
    }
}
