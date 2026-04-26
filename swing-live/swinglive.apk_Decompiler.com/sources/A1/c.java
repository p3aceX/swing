package A1;

/* JADX INFO: loaded from: classes.dex */
public final class c extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public boolean f72a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public /* synthetic */ Object f73b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ d f74c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f75d;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public c(d dVar, A3.c cVar) {
        super(cVar);
        this.f74c = dVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f73b = obj;
        this.f75d |= Integer.MIN_VALUE;
        return this.f74c.d(false, this);
    }
}
